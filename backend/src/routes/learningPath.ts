import { Router } from 'express';
import { z } from 'zod';
import { isPracticeArea } from '@parlaval/shared';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { rateLimit } from '../middleware/rateLimit.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';
import { EXAM_CATEGORY } from '../services/catalog.js';
import { generateLearningPath, getLearningPath, onResourceFinished } from '../services/learningPath.js';

export const learningPathRouter = Router();

// Regenerar la ruta crida el LLM: es limita perquè no es puga fer sense parar.
const REGENERATE_RATE_LIMIT = { max: 5, windowMs: 10 * 60_000 };

const resultSchema = z.object({
  level: z.enum(['A1', 'A2', 'B1', 'B2', 'C1', 'C2']).nullable().optional(),
  score: z.number().nonnegative().nullable().optional(),
  total: z.number().positive().nullable().optional(),
  // Resum de les redaccions avaluades, àrees de l'examen...: no cal guardar-ne el text.
  details: z.record(z.string(), z.unknown()).refine(d => JSON.stringify(d).length <= 20_000, 'details és massa gran').optional(),
}).refine(r => r.score == null || (r.total != null && r.score <= r.total), 'score ha de ser menor o igual que total');

// Ruta activa de l'usuari; la primera vegada se'n genera una (diagnòstica si encara no hi ha dades).
learningPathRouter.get('/api/learning-path', requireAuth, async (req: AuthRequest, res) => {
  const client = db(req.userId);
  if (!client) return res.status(401).json({ error: 'Inicia sessió per a tindre una ruta personalitzada' });
  try {
    const path = await getLearningPath(client, req.userId!);
    if (!path) return res.status(404).json({ error: 'Encara no hi ha activitats per al teu nivell' });
    res.json(path);
  } catch (error) {
    console.error('[learning-path] Error carregant la ruta:', error);
    res.status(500).json({ error: 'No hem pogut carregar la ruta' });
  }
});

learningPathRouter.post('/api/learning-path/regenerate', requireAuth, rateLimit(REGENERATE_RATE_LIMIT), async (req: AuthRequest, res) => {
  const client = db(req.userId);
  if (!client) return res.status(401).json({ error: 'Inicia sessió per a tindre una ruta personalitzada' });
  try {
    await generateLearningPath(client, req.userId!);
    res.json(await getLearningPath(client, req.userId!));
  } catch (error) {
    console.error('[learning-path] Error regenerant la ruta:', error);
    res.status(503).json({ error: 'No hem pogut generar una ruta nova. Torna-ho a provar.' });
  }
});

// Resultat d'una pràctica o d'un examen acabat. Es respon de seguida: marcar el
// pas i regenerar la ruta (amb el LLM) es fa en segon pla.
function resultRoute(kind: 'practice' | 'exam', matches: (category: string) => boolean) {
  return async (req: AuthRequest, res: import('express').Response) => {
    const parsed = resultSchema.safeParse(req.body);
    if (!parsed.success) return validationError(res, parsed.error);
    if (!z.string().uuid().safeParse(req.params.id).success) return res.status(404).json({ error: 'El recurs no existix' });
    const client = db(req.userId);
    if (!client) return res.json({ ok: true, demo: true });

    const { data: resource, error } = await client.from('resources').select('category').eq('id', req.params.id).maybeSingle();
    if (error) {
      console.error('[results] Error carregant el recurs:', error);
      return res.status(500).json({ error: 'No hem pogut guardar el resultat' });
    }
    if (!resource || !matches(resource.category)) return res.status(404).json({ error: 'El recurs no existix' });

    res.json({ ok: true });
    const userId = req.userId!;
    onResourceFinished(client, userId, { resourceId: req.params.id as string, kind, ...parsed.data })
      .catch(err => console.error(`[results] Error processant el resultat de ${userId}:`, err));
  };
}

learningPathRouter.post('/api/practice/:id/results', requireAuth, resultRoute('practice', isPracticeArea));
learningPathRouter.post('/api/exams/:id/results', requireAuth, resultRoute('exam', c => c === EXAM_CATEGORY));
