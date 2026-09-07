/**
 * Pruebas de INTEGRACIÓN reales contra la API de OpenAI (18 llamadas).
 *
 * NO simulan nada: cada test ejecuta `replyFromAgent`, que hace una
 * llamada HTTP real a `https://api.openai.com/v1/chat/completions` con
 * la OPENAI_API_KEY del `.env` del backend y el modelo real (OPENAI_MODEL).
 *
 * Cada caso intenta inducir un estado de conversación distinto (inici,
 * petició correcta, error de castellanisme, no entendre, negociació,
 * comiat) i comprova que el mood i el detected_level_signal resultants
 * siguin coherents amb l'estat induït.
 *
 * Advertencia: consume créditos reales (una llamada por caso, 18 en total).
 * Si no hi ha OPENAI_API_KEY, tota la suite se salta automàticament.
 */
import dotenv from 'dotenv';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { replyFromAgent } from './agent.js';

// Carga las variables del fichero .env del backend (ruta absoluta robusta).
dotenv.config({ path: fileURLToPath(new URL('../../.env', import.meta.url)) });

const hasCredentials = Boolean(process.env.OPENAI_API_KEY);

const MOODS = ['neutral', 'content', 'confus'];
const SIGNALS = ['below', 'on', 'above'];

type Case = {
  name: string;
  scenario: 'mercat' | 'bar' | 'oficina' | 'ajuntament';
  level: 'principiant' | 'intermedi' | 'avancat';
  message: string;
  /** mood esperat aproximadament (es comprova si està definit) */
  mood?: 'neutral' | 'content' | 'confus';
  /** señal esperada aproximadament (es comprova si està definida) */
  signal?: 'below' | 'on' | 'above';
  /** si és un cas d'error, valida que el model assenyale algun problema */
  error?: boolean;
};

const CASES: Case[] = [
  // ── Estat INICI / salutació ──
  {
    name: 'bar · principiant · salutació inicial',
    scenario: 'bar',
    level: 'principiant',
    message: 'Bon dia! Què em recomanes per a beure?',
    mood: 'neutral',
  },
  {
    name: 'oficina · intermedi · demanar cita',
    scenario: 'oficina',
    level: 'intermedi',
    message: 'Bon dia, vull demanar hora amb el regidor d\'urbanisme.',
    mood: 'content',
  },
  {
    name: 'ajuntament · principiant · inici de conversa',
    scenario: 'ajuntament',
    level: 'principiant',
    message: 'Hola, necessite ajuda amb un tràmit.',
    mood: 'neutral',
  },

  // ── Petició correcta / registre adequat ──
  {
    name: 'bar · intermedi · demanar una cervesa',
    scenario: 'bar',
    level: 'intermedi',
    message: 'Em poses una cervesa, si us plau?',
    mood: 'content',
    signal: 'on',
  },
  {
    name: 'mercat · intermedi · preguntar preus',
    scenario: 'mercat',
    level: 'intermedi',
    message: 'Quant val el quilo de taronges?',
    mood: 'neutral',
    signal: 'on',
  },
  {
    name: 'mercat · avancat · demanar productes',
    scenario: 'mercat',
    level: 'avancat',
    message: 'Necessite tres quilos de tomàquets de la terra, si us plau.',
    signal: 'above',
  },
  {
    name: 'oficina · avancat · explicar un tràmit',
    scenario: 'oficina',
    level: 'avancat',
    message: 'Seria possible obtindre el certificat d\'empadronament per a demà?',
    mood: 'content',
    signal: 'on',
  },
  {
    name: 'ajuntament · intermedi · demanar informació',
    scenario: 'ajuntament',
    level: 'intermedi',
    message: 'M\'agradaria saber els horaris d\'atenció al públic.',
    mood: 'neutral',
    signal: 'on',
  },

  // ── Nivell superior / resposta avançada ──
  {
    name: 'bar · avancat · demanar un vi de la comarca',
    scenario: 'bar',
    level: 'avancat',
    message: 'M\'agradaria un vi negre de la comarca, me\'n pots parlar una miqueta?',
    mood: 'content',
    signal: 'above',
  },
  {
    name: 'mercat · avancat · negociar el preu',
    scenario: 'mercat',
    level: 'avancat',
    message: 'Parlem del preu, crec que és una miqueta car.',
    mood: 'content',
    signal: 'above',
  },
  {
    name: 'bar · intermedi · demanar el compte',
    scenario: 'bar',
    level: 'intermedi',
    message: 'El compte, per favor.',
    mood: 'neutral',
    signal: 'on',
  },

  // ── ESTAT ERROR / castellanisme / no entendre ──
  {
    name: 'bar · principiant · castellanismes',
    scenario: 'bar',
    level: 'principiant',
    message: 'yo querer cerveza por favor',
    error: true,
  },
  {
    name: 'mercat · principiant · no entendre el preu',
    scenario: 'mercat',
    level: 'principiant',
    message: 'perdona, no entenc, pots repetir?',
    mood: 'confus',
    error: true,
  },
  {
    name: 'ajuntament · principiant · no saber què dir',
    scenario: 'ajuntament',
    level: 'principiant',
    message: 'no saber que decir',
    mood: 'confus',
    error: true,
  },
  {
    name: 'oficina · intermedi · frase amb faltes',
    scenario: 'oficina',
    level: 'intermedi',
    message: 'quiero el papel de empadronamiento para el registro',
    error: true,
  },
  {
    name: 'mercat · intermedi · queixa de preu massa alt',
    scenario: 'mercat',
    level: 'intermedi',
    message: 'Això és massa car per a mi!',
    mood: 'confus',
  },
  {
    name: 'ajuntament · avancat · resposta amb argot',
    scenario: 'ajuntament',
    level: 'avancat',
    message: 'Voldria presentar una instància per registrar una denúncia formal.',
    signal: 'above',
  },

  // ── COMIAT / tancament ──
  {
    name: 'oficina · intermedi · comiat',
    scenario: 'oficina',
    level: 'intermedi',
    message: 'Moltes gràcies per la informació, adeu!',
    mood: 'content',
  },
  {
    name: 'bar · principiant · acomiadar-se',
    scenario: 'bar',
    level: 'principiant',
    message: 'Ara me\'n vaig, fins demà!',
    mood: 'content',
  },
];

describe.skipIf(!hasCredentials)('Integración real con la API de OpenAI (18 casos)', () => {
  it.each(CASES)(
    '$name (nivell $level)',
    async (c: Case) => {
      const reply = await replyFromAgent({
        scenario: c.scenario,
        level: c.level,
        message: c.message,
        history: [],
      });

      // Resultado bruto para depuración.
      console.log(`[crudo LLM] ${c.name} =>`, JSON.stringify(reply));

      // 1) El contrato Zod siempre es vàlid i la resposta no és buida.
      expect(typeof reply.reply_text).toBe('string');
      expect(reply.reply_text.trim().length).toBeGreaterThan(0);

      // 2) Tots els camps sempre dins dels valors permesos.
      expect(MOODS).toContain(reply.mood);
      expect(SIGNALS).toContain(reply.detected_level_signal);
      expect(Array.isArray(reply.error_flags)).toBe(true);

      // 3) Coherència amb l'estat induït.
      if (c.mood) expect(reply.mood).toBe(c.mood);
      if (c.signal) expect(reply.detected_level_signal).toBe(c.signal);
      if (c.error) {
        // En un cas d'error, el model deu assenyalar-ho d'alguna manera.
        const flagged =
          reply.mood === 'confus' ||
          reply.detected_level_signal === 'below' ||
          reply.error_flags.length > 0;
        expect(flagged, `No es va detectar cap senyal d'error a: ${JSON.stringify(reply)}`).toBe(true);
      }
    },
    60_000,
  );
});
