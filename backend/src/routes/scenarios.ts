import { Router } from 'express';
import { VOICE_BY_SCENARIO } from '@parlaval/shared';
import { scenarios } from '../scenarios/index.js';
import { tts } from '../services/voice.js';

export const scenariosRouter = Router();

// Descripció pública de cada escenari (personatge + objectius de la conversa).
scenariosRouter.get('/api/scenarios', (_req, res) => {
  const overview = Object.fromEntries(
    Object.entries(scenarios).map(([key, def]) => [key, { character: def.character, objectius: def.objectius }]),
  );
  res.json(overview);
});

// The first greeting must be audible even when the conversation provider is unavailable.
scenariosRouter.get('/api/greeting-audio', async (req, res) => {
  const scenario = typeof req.query.scenario === 'string' ? req.query.scenario : undefined;
  const voice = scenario && scenario in VOICE_BY_SCENARIO
    ? VOICE_BY_SCENARIO[scenario as keyof typeof VOICE_BY_SCENARIO]
    : undefined;
  const audio = await tts.synthesize('Bon dia! Com et puc ajudar hui?', voice);
  if (!audio) return res.status(503).json({ error: 'No hem pogut generar l’àudio' });
  res.json({
    audio_base64: audio.audio.toString('base64'),
    mime_type: audio.mimeType,
  });
});
