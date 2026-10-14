import { Router } from 'express';
import { z } from 'zod';
import { LEVELS, WRITING_MAX_CHARS } from '@parlaval/shared';
import { getAdmin, requireAuth, type AuthRequest } from '../middleware/auth.js';
import { rateLimit } from '../middleware/rateLimit.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';
import { buildPlacementTest, gradePlacementTest } from '../services/placementTest.js';

export const profileRouter = Router();

const levelChangeSchema = z.object({
  level: z.enum(LEVELS),
  reason: z.enum(['manual', 'placement']).optional().default('manual'),
});

// Canvi de nivell de l'usuari: des del perfil o acceptant la proposta de la prova de nivell. El
// client ja no pot escriure profiles.level (el trigger profiles_protect_role ho impedix): ho fa
// el backend, que en guarda l'historial i esborra el que era del nivell anterior: la ruta de la
// IA (s'arxiva), els errors pendients (classificats en continguts d'aquell nivell) i les
// avaluacions (el seu focus orientaria la ruta nova cap a aquells continguts). Els resultats de
// les activitats es mantenen. Les classes no es toquen, però es tornen les que no són del nivell
// nou perquè el client ho avise.
profileRouter.post('/api/profile/level', requireAuth, rateLimit({ windowMs: 60_000, max: 10 }), async (req: AuthRequest, res) => {
  const parsed = levelChangeSchema.safeParse(req.body);
  if (!parsed.success) return validationError(res, parsed.error);
  const { level, reason } = parsed.data;

  const client = db(req.userId);
  if (!client || !req.userId) return res.json({ level, classes_outside: [], demo: true });

  try {
    const { data: profile, error } = await client.from('profiles').select('level, age_group').eq('id', req.userId).single();
    if (error) throw error;
    // El món infantil depén del Nivell 0: els comptes dels xiquets no canvien de nivell.
    if (profile.age_group === 'child') return res.status(403).json({ error: 'Els comptes infantils no poden canviar de nivell' });
    if (profile.level === level) return res.json({ level, classes_outside: [] });

    const { error: updateError } = await client
      .from('profiles')
      .update({ level, updated_at: new Date().toISOString() })
      .eq('id', req.userId);
    if (updateError) throw updateError;

    const [archived, errors, evaluations, history, memberships] = await Promise.all([
      // La ruta de la IA era del nivell anterior: es podrà generar una de nova.
      client.from('learning_paths').update({ status: 'archived' }).eq('user_id', req.userId).eq('status', 'active'),
      // El client deixa de mostrar-los en sincronitzar-se (GET /api/errors ja no els torna).
      client.from('user_errors').delete().eq('user_id', req.userId).eq('resolved', false),
      client.from('user_evaluations').delete().eq('user_id', req.userId),
      client.from('level_changes').insert({ user_id: req.userId, from_level: profile.level, to_level: level, reason }),
      client.from('kids_class_members').select('kids_classes(name, levels)').eq('student_id', req.userId),
    ]);
    if (archived.error) console.error('[profile-level] Error arxivant la ruta:', archived.error.message);
    if (errors.error) console.error('[profile-level] Error esborrant els errors:', errors.error.message);
    if (evaluations.error) console.error('[profile-level] Error esborrant les avaluacions:', evaluations.error.message);
    if (history.error) console.error("[profile-level] Error guardant l'historial:", history.error.message);

    type Membership = { kids_classes: { name: string; levels: string[] } | null };
    const classesOutside = ((memberships.data ?? []) as Membership[])
      .flatMap(m => (m.kids_classes && !m.kids_classes.levels.includes(level) ? [m.kids_classes.name] : []));

    console.log(`[profile-level] ${req.userId}: ${profile.level} → ${level} (${reason})`);
    res.json({ level, classes_outside: classesOutside });
  } catch (error) {
    console.error('[profile-level] Error canviant el nivell:', error);
    res.status(500).json({ error: "No hem pogut canviar el nivell" });
  }
});

// Prova de nivell. El catàleg és públic: es llig amb el client admin també en mode demostració.
profileRouter.get('/api/placement-test', requireAuth, async (_req, res) => {
  const client = getAdmin() as any;
  if (!client) return res.status(503).json({ error: 'La prova de nivell no està disponible' });
  try {
    res.json(await buildPlacementTest(client));
  } catch (error) {
    console.error('[placement] Error preparant la prova:', error);
    res.status(500).json({ error: 'No hem pogut preparar la prova de nivell' });
  }
});

const placementSchema = z.object({
  answers: z.array(z.object({ exercise_id: z.string().uuid(), answer: z.string().max(500) })).max(30).default([]),
  text: z.string().max(WRITING_MAX_CHARS).optional().default(''),
});

// La redacció l'avalua el LLM: el mateix límit que les avaluacions de redaccions.
const PLACEMENT_RATE_LIMIT = {
  windowMs: 60_000,
  max: Number(process.env.RATE_LIMIT_EVALUATE_PER_MIN) || 5,
  maxAnonymous: Number(process.env.RATE_LIMIT_EVALUATE_ANON_PER_MIN) || 2,
};

profileRouter.post('/api/placement-test', requireAuth, rateLimit(PLACEMENT_RATE_LIMIT), async (req: AuthRequest, res) => {
  const parsed = placementSchema.safeParse(req.body);
  if (!parsed.success) return validationError(res, parsed.error);
  const client = getAdmin() as any;
  if (!client) return res.status(503).json({ error: 'La prova de nivell no està disponible' });
  try {
    // La redacció s'avalua amb la rúbrica del nivell actual (en mode demostració, el de per defecte).
    const { data: profile } = req.userId && req.userId !== 'demo-user'
      ? await client.from('profiles').select('level').eq('id', req.userId).maybeSingle()
      : { data: null };
    res.json(await gradePlacementTest(client, parsed.data.answers, parsed.data.text, profile?.level ?? 'A2'));
  } catch (error) {
    console.error('[placement] Error corregint la prova:', error);
    res.status(500).json({ error: 'No hem pogut corregir la prova de nivell' });
  }
});
