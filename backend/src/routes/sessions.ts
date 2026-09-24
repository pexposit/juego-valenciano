import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';
import { sessionSchema } from '../schemas.js';
import { runPedagogicalEvaluation } from '../services/subagentRecommendation.js';


export const sessionsRouter = Router();

sessionsRouter.post('/api/sessions', requireAuth, async (req: AuthRequest, res) => {
  try {
    const body = sessionSchema.parse(req.body);

    const client = db(req.userId);
    if (!client) {
      // Demo mode: return a fake session
      return res.status(201).json({ session_id: crypto.randomUUID() });
    }

    const { data, error } = await client
      .from('conversation_sessions')
      .insert({ user_id: req.userId!, scenario: body.scenario, level_at_start: body.level })
      .select('id')
      .single();
    if (error) throw error;
    res.status(201).json({ session_id: data.id });
  } catch (error) {
    if (error instanceof z.ZodError) return validationError(res, error);
    console.error(error);
    res.status(500).json({ error: 'No hem pogut iniciar la sessió' });
  }
});

// Endpoint temporal només per a testejar el disparador de recomanació
sessionsRouter.post('/api/sessions/finish', requireAuth, async (req: AuthRequest, res) => {
  try {
    const client = db(req.userId);

    // Responem a l'instant a la crida del navegador
    res.json({ ok: true });

    // Si hi ha usuari i client, disparem l'avaluació en segon pla sense tocar conversation_sessions
    if (client && req.userId) {
      const userId = req.userId;
      void (async () => {
        try {
          console.log(`[testEvaluator] Disparant avaluació per a usuari ${userId}...`);
          const evalStart = Date.now();
          const report = await runPedagogicalEvaluation(userId);

          if (report) {
            console.log(
              `[testEvaluator] Exit! Categoria: ${report.priority_focus} en ${Date.now() - evalStart}ms`
            );
          } else {
            console.log('[testEvaluator] No hi ha errors pendents suficients per a avaluar.');
          }
        } catch (err: any) {
          console.error('[testEvaluator] Error:', err.message);
        }
      })();
    }
  } catch (error) {
    console.error('[sessions] Error finish:', error);
    res.status(500).json({ error: 'Error intern' });
  }
});