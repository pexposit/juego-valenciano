import { z } from 'zod';
import {
  HISTORY_MAX_MESSAGES,
  LEVELS,
  MESSAGE_MAX_CHARS,
  SCENARIO_KEYS,
} from '@parlaval/shared';

// Una única definició per a l'enum d'escenaris i de nivells: deriven de la
// font compartida, així que un escenari nou s'accepta automàticament.
export const scenarioSchema = z.enum(SCENARIO_KEYS);
export const levelSchema = z.enum(LEVELS);

export const turnSchema = z.object({
  session_id: z.string().uuid(),
  scenario: scenarioSchema,
  level: levelSchema,
  input_mode: z.enum(['text', 'voice']),
  text: z.string().max(MESSAGE_MAX_CHARS).optional().default(''),
  audio_base64: z.string().nullable().optional(),
  // Si el cliente pide omitir el audio (p. ej. lo pedirá después a /api/tts),
  // el turno responde solo con texto y gana el tiempo del TTS.
  include_audio: z.boolean().optional().default(true),
  // Historial de la conversación enviado por el cliente en tiempo real; solo
  // se usa en modo demo (sin base de datos). Con usuario real se reconstruye
  // desde la BD y este campo se ignora.
  history: z.array(z.object({
    role: z.enum(['user', 'character']),
    content_text: z.string().max(MESSAGE_MAX_CHARS),
  })).max(HISTORY_MAX_MESSAGES).optional().default([]),
});

export const ttsSchema = z.object({
  text: z.string().min(1).max(MESSAGE_MAX_CHARS),
  scenario: scenarioSchema.optional(),
  voice: z.string().min(1).max(50).optional(),
});

export const sessionSchema = z.object({
  scenario: scenarioSchema,
  level: levelSchema,
});
