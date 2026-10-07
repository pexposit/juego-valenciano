import { Router, type Response } from 'express';
import { z } from 'zod';
import { ASSISTANT_CATEGORY, KID_ASSISTANT_TYPE } from '@parlaval/shared';
import { getAdmin, requireAuth, type AuthRequest } from '../middleware/auth.js';
import { rateLimit } from '../middleware/rateLimit.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';
import { summarizeConversationTitle } from '../services/conversationTitle.js';
import { MESSAGE_MAX_CHARS } from '@parlaval/shared';
import { bilingualGreeting } from '../services/motherTongue.js';
import { assistantGreeting, assistantGreetingIsTranslated } from '../services/assistantLevel.js';

export const assistantRouter = Router();

const openSchema = z.object({ session_id: z.string().uuid() });

// Obri la conversa del xiquet amb el tutor de valencià. La conversa dura tot un login: si ja n'hi ha
// una d'oberta en la sessió actual es torna la mateixa (carregar el tauler un altre cop, recarregar la
// pàgina...); si no, o si l'única oberta és d'un login anterior, es tanca i es crea una de nova dins de
// la sessió actual. Amb `restart` (botó de tornar a començar) sempre es comença una de nova. Tancar és
// marcar session_resource.resolved. Els missatges no es guarden al servidor: els té el navegador de
// l'usuari, que els busca per session_resource_id; si no en té cap, mostra la salutació (`greeting`).
const openConversation = (restart: boolean) => async (req: AuthRequest, res: Response) => {
  const parsed = openSchema.safeParse(req.body);
  if (!parsed.success) return validationError(res, parsed.error);

  // El recurs és públic (com el catàleg): es llig amb el client admin també en mode demo.
  const admin = getAdmin() as any;
  if (!admin) return res.status(503).json({ error: 'El servei no està disponible' });
  const { data: resource, error: resourceError } = await admin
    .from('resources')
    .select('id, metadata')
    .eq('category', ASSISTANT_CATEGORY)
    .eq('type', KID_ASSISTANT_TYPE)
    .limit(1)
    .maybeSingle();
  if (resourceError || !resource) {
    console.error('[assistant] Recurs del tutor no trobat:', resourceError);
    return res.status(404).json({ error: 'El tutor no està disponible' });
  }
  const client = db(req.userId);
  // Mode demo (sense BD): no es guarda res, només la salutació.
  if (!client || !req.userId) {
    return res.json({
      session_id: parsed.data.session_id,
      session_resource_id: crypto.randomUUID(),
      greeting: assistantGreeting('principiant'),
    });
  }

  try {
    // Conversa oberta de l'usuari amb el tutor (no tancada).
    const { data: open, error: existingError } = await client
      .from('session_resource')
      .select('id, sesion_id, sessions!inner(user_id)')
      .eq('recurso_id', resource.id)
      .eq('sessions.user_id', req.userId)
      .or('resolved.is.null,resolved.eq.false');
    if (existingError) throw existingError;

    const existing = restart ? undefined : open?.find((o: { sesion_id: string }) => o.sesion_id === parsed.data.session_id);
    const stale = (open ?? []).filter((o: { id: string }) => o.id !== existing?.id);
    if (stale.length) {
      const { error: closeError } = await client
        .from('session_resource')
        .update({ resolved: true })
        .in('id', stale.map((o: { id: string }) => o.id));
      if (closeError) throw closeError;
    }

    let sessionId: string = parsed.data.session_id;
    let sessionResourceId: string;

    if (existing) {
      sessionId = existing.sesion_id;
      sessionResourceId = existing.id;
    } else {
      // Només es pot crear dins d'una sessió de l'usuari autenticat.
      const { data: session, error: sessionError } = await client
        .from('sessions')
        .select('id')
        .eq('id', sessionId)
        .eq('user_id', req.userId)
        .maybeSingle();
      if (sessionError) throw sessionError;
      if (!session) return res.status(404).json({ error: 'Sessió no trobada o no autoritzada' });

      const { data: created, error: createError } = await client
        .from('session_resource')
        .insert({ sesion_id: sessionId, recurso_id: resource.id, resolved: false })
        .select('id')
        .single();
      if (createError) throw createError;
      sessionResourceId = created.id;
    }

    // La salutació, en valencià (segons el nivell de l'usuari) i en la seua llengua materna.
    const { data: profile } = await client.from('profiles').select('mother_tongue, level').eq('id', req.userId).maybeSingle();
    const greeting = assistantGreeting(profile?.level);
    const greetingText = assistantGreetingIsTranslated(profile?.level) ? bilingualGreeting(greeting, profile?.mother_tongue) : greeting;

    res.json({ session_id: sessionId, session_resource_id: sessionResourceId, greeting: greetingText });
  } catch (error) {
    console.error('[assistant] Error obrint la conversa:', error);
    res.status(500).json({ error: "No s'ha pogut obrir la conversa" });
  }
};

assistantRouter.post('/api/assistant/open', requireAuth, openConversation(false));
assistantRouter.post('/api/assistant/restart', requireAuth, openConversation(true));

const resumeSchema = z.object({ session_id: z.string().uuid(), session_resource_id: z.string().uuid() });

// Torna a una conversa anterior: tanca l'oberta, reobri la triada i la mou a la sessió actual
// perquè /api/assistant/open (que només reprén les de la sessió actual) la trobe en carregar el tauler.
assistantRouter.post('/api/assistant/resume', requireAuth, async (req: AuthRequest, res) => {
  const parsed = resumeSchema.safeParse(req.body);
  if (!parsed.success) return validationError(res, parsed.error);

  const client = db(req.userId);
  const resourceId = await tutorResourceId();
  if (!client || !req.userId || !resourceId) return res.status(503).json({ error: 'El servei no està disponible' });

  try {
    const { data: session, error: sessionError } = await client
      .from('sessions')
      .select('id')
      .eq('id', parsed.data.session_id)
      .eq('user_id', req.userId)
      .maybeSingle();
    if (sessionError) throw sessionError;
    if (!session) return res.status(404).json({ error: 'Sessió no trobada o no autoritzada' });

    const { data: owned, error: ownedError } = await client
      .from('session_resource')
      .select('id, sessions!inner(user_id)')
      .eq('id', parsed.data.session_resource_id)
      .eq('recurso_id', resourceId)
      .eq('sessions.user_id', req.userId)
      .maybeSingle();
    if (ownedError) throw ownedError;
    if (!owned) return res.status(404).json({ error: 'Conversa no trobada' });

    const { error: closeError } = await client
      .from('session_resource')
      .update({ resolved: true })
      .eq('recurso_id', resourceId)
      .neq('id', owned.id)
      .or('resolved.is.null,resolved.eq.false');
    if (closeError) throw closeError;

    const { error: reopenError } = await client
      .from('session_resource')
      .update({ resolved: false, sesion_id: parsed.data.session_id })
      .eq('id', owned.id);
    if (reopenError) throw reopenError;

    res.json({ ok: true });
  } catch (error) {
    console.error('[assistant] Error reprenent la conversa:', error);
    res.status(500).json({ error: "No s'ha pogut reprendre la conversa" });
  }
});

async function tutorResourceId() {
  const admin = getAdmin() as any;
  if (!admin) return null;
  const { data } = await admin
    .from('resources')
    .select('id')
    .eq('category', ASSISTANT_CATEGORY)
    .eq('type', KID_ASSISTANT_TYPE)
    .limit(1)
    .maybeSingle();
  return (data?.id as string | undefined) ?? null;
}

// Títol automàtic d'una conversa amb el tutor (pestanya «Converses»). La llista de converses, els
// missatges i els títols els guarda el navegador: este endpoint només resumix els missatges que
// rep amb el LLM i torna el títol, sense guardar res.
const titleSchema = z.object({
  messages: z.array(z.object({
    role: z.enum(['user', 'character']),
    text: z.string().max(MESSAGE_MAX_CHARS),
  })).min(1).max(40),
});

assistantRouter.post(
  '/api/assistant/title',
  requireAuth,
  rateLimit({ windowMs: 60_000, max: 30, maxAnonymous: 6 }),
  async (req: AuthRequest, res) => {
    const parsed = titleSchema.safeParse(req.body);
    if (!parsed.success) return validationError(res, parsed.error);
    const title = await summarizeConversationTitle(parsed.data.messages.map(m => ({ role: m.role, content_text: m.text })));
    res.json({ title });
  },
);
