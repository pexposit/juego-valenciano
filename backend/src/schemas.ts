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
  recurso_id: z.string().uuid(), // <--- AÑADE ESTO AQUÍ
  scenario: scenarioSchema,
  level: levelSchema,
  input_mode: z.enum(['text', 'voice']),
  text: z.string().max(MESSAGE_MAX_CHARS).optional().default(''),
  audio_base64: z.string().nullable().optional(),
  include_audio: z.boolean().optional().default(true),
  history: z.array(z.object({
    role: z.enum(['user', 'character']),
    content_text: z.string().max(MESSAGE_MAX_CHARS),
    recurso_id: z.string().uuid().optional(),
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
  categoria: z.string().optional().default('libre'),
  type: z.string().optional().default('escenario'),
});
