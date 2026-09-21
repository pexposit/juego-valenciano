import { Router } from 'express';
import { z } from 'zod';
import { VOICE_BY_SCENARIO } from '@parlaval/shared';
import { requireAuth } from '../middleware/auth.js';
import { rateLimit } from '../middleware/rateLimit.js';
import { tts } from '../services/voice.js';
import { validationError } from '../validation.js';
import { ttsSchema } from '../schemas.js';

export const ttsRouter = Router();

// El TTS depén d'un servici extern (matxa, servidor DeepLab de la UJI): sense
// límit, qualsevol que trobe l'URL el podria fer servir de sintetitzador
// gratuït. Per això va darrere d'autenticació (o mode demostració) i d'un límit.
const TTS_RATE_LIMIT = {
  windowMs: 60_000,
  max: Number(process.env.RATE_LIMIT_AUTHED_PER_MIN) || 30,
  maxAnonymous: Number(process.env.RATE_LIMIT_ANON_PER_MIN) || 6,
};

ttsRouter.post('/api/tts', requireAuth, rateLimit(TTS_RATE_LIMIT), async (req, res) => {
  try {
    const { text, scenario, voice } = ttsSchema.parse(req.body);
    const audio = await tts.synthesize(
      text,
      voice ?? (scenario ? VOICE_BY_SCENARIO[scenario] : undefined),
    );
    if (!audio) return res.status(503).json({ error: 'No hem pogut generar l’àudio' });
    res.json({
      audio_base64: audio.audio.toString('base64'),
      mime_type: audio.mimeType,
    });
  } catch (error) {
    if (error instanceof z.ZodError) return validationError(res, error);
    console.error(error);
    res.status(503).json({ error: 'No hem pogut generar l’àudio' });
  }
});
