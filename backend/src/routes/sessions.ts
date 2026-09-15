import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';
import { sessionSchema } from '../schemas.js';

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
