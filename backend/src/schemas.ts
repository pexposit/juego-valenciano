import { z } from 'zod';
import {
  HISTORY_MAX_MESSAGES,
  LEVELS,
  MESSAGE_MAX_CHARS,
  OWN_PATH_TOPIC_MAX,
} from '@parlaval/shared';

// Els escenaris viuen a la BDD (resources.type): ací només es valida la forma
// de la clau; si existix i és jugable es comprova en consultar-la.
export const scenarioSchema = z.string().trim().min(1).max(50);
export const levelSchema = z.enum(LEVELS);

export const turnSchema = z.object({
  session_id: z.string().uuid(),
  // Entrada de session_resource creada en obrir l'escenari (sessió + recurs).
  session_resource_id: z.string().uuid(),
  scenario: scenarioSchema,
  level: levelSchema,
  input_mode: z.enum(['text', 'voice']),
  text: z.string().max(MESSAGE_MAX_CHARS).optional().default(''),
  audio_base64: z.string().nullable().optional(),
  include_audio: z.boolean().optional().default(true),
  history: z.array(z.object({
    role: z.enum(['user', 'character']),
    content_text: z.string().max(MESSAGE_MAX_CHARS),
  })).max(HISTORY_MAX_MESSAGES).optional().default([]),
  // Tutor: exercicis del catàleg ja mostrats en la conversa (no es repetixen).
  shown_exercises: z.array(z.string().uuid()).max(100).optional().default([]),
  // Tutor del Nivell 0: les lliçons de l'app (el catàleg és al frontend), per a enllaçar-ne una a la pregunta del xiquet.
  lessons: z.array(z.object({
    id: z.string().max(60),
    title: z.string().max(120),
    summary: z.string().max(200).optional().default(''),
  })).max(80).optional().default([]),
  // Tutor: el tema de la ruta que va oferir en el torn anterior, si l'aprenent encara no l'ha contestada.
  pending_route_offer: z.string().trim().max(OWN_PATH_TOPIC_MAX).optional(),
});

export const ttsSchema = z.object({
  text: z.string().min(1).max(MESSAGE_MAX_CHARS),
  scenario: scenarioSchema.optional(),
  voice: z.string().min(1).max(50).optional(),
});

export const sessionSchema = z.object({
  // La sessió es crea en fer login, abans de triar escenari: l'escenari és opcional.
  scenario: scenarioSchema.optional(),
  level: levelSchema,
  categoria: z.string().optional().default('lliure'),
  type: z.string().optional().default('scenari'),
});


// Dades que guarda el navegador de l'usuari (no el servidor) i que envia quan el servidor les
// necessita per a avaluar. El servidor les fa servir i no les guarda.
const clientText = z.string().max(MESSAGE_MAX_CHARS);

export const clientMessageSchema = z.object({
  role: z.enum(['user', 'character']),
  text: clientText,
  created_at: z.string().datetime(),
});

export const clientErrorSchema = z.object({
  error_text: clientText,
  correction: clientText,
  category: z.string().max(100),
  subcategory: z.string().max(200).nullable().optional(),
  explanation: clientText,
});

export const clientEvaluationSchema = z.object({
  summary: z.string().max(4000),
  weaknesses: z.array(clientText).max(30),
  priority_focus: z.string().max(200),
  created_at: z.string().datetime(),
});

// En tancar un recurs: la conversa (Nivell 0, per a revisar els objectius) o els errors
// pendents del recurs i les últimes avaluacions (per a l'avaluació pedagògica).
// Una llista tolerant: les entrades que no passen la validació (un text massa llarg, un camp que falta) es descarten
// i la resta es manté, en compte de rebutjar tota la petició. Si no, un sol missatge o error estrany deixaria
// l'escenari sense tancar ni revisar mai.
const lenientList = <T extends z.ZodTypeAny>(item: T, max: number) =>
  z.array(z.unknown()).optional().default([]).transform(list => {
    const valid = list.flatMap(entry => {
      const parsed = item.safeParse(entry);
      return parsed.success ? [parsed.data as z.infer<T>] : [];
    });
    if (valid.length < list.length) console.warn(`[finish] S'han descartat ${list.length - valid.length} entrades invàlides de ${list.length}`);
    return valid.slice(-max);
  });

export const finishResourceSchema = z.object({
  messages: lenientList(clientMessageSchema, 400),
  errors: lenientList(clientErrorSchema, 100),
  evaluations: lenientList(clientEvaluationSchema, 4),
});

// Un missatge de l'usuari en un xat, per a buscar-hi errors.
export const analyzeSchema = z.object({
  session_id: z.string().uuid(),
  session_resource_id: z.string().uuid(),
  text: z.string().trim().min(1).max(MESSAGE_MAX_CHARS),
});
