import { Router } from 'express';
import { z } from 'zod';
import { VOICE_BY_SCENARIO } from '@parlaval/shared';
import { tts } from '../services/voice.js';
import { validationError } from '../validation.js';
import { ttsSchema } from '../schemas.js';

export const ttsRouter = Router();

ttsRouter.post('/api/tts', async (req, res) => {
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
