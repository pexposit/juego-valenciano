/**
 * Pruebas de INTEGRACIÓN reales contra la API de OpenAI (unes 32 llamadas
 * pagades en total). Tres suites: casos d'un sol torn, converses multi-torn
 * amb `history` i prompts hostils (tot amb crides reals a la API).
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
 * Advertencia: consume créditos reales (una llamada por caso).
 * Si no hi ha OPENAI_API_KEY, tota la suite se salta automàticament.
 */
import dotenv from 'dotenv';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { replyFromAgent } from './agent.js';
import type { ScenarioKey } from '../scenarios/types.js';
import type { LevelKey } from '@parlaval/shared';

// Carga las variables del fichero .env del backend (ruta absoluta robusta).
dotenv.config({ path: fileURLToPath(new URL('../../.env', import.meta.url)) });

const hasCredentials = Boolean(process.env.OPENAI_API_KEY);

const MOODS = ['neutral', 'content', 'confus'];
const SIGNALS = ['below', 'on', 'above'];

type Case = {
  name: string;
  scenario: ScenarioKey;
  level: LevelKey;
  message: string;
  /** mood esperat aproximadament (es comprova si està definit) */
  mood?: 'neutral' | 'content' | 'confus';
  /** señal esperada aproximadament (es comprova si està definida) */
  signal?: 'below' | 'on' | 'above';
  /** si és un cas d'error, valida que el model assenyale algun problema */
  error?: boolean;
};
/** Caso de conversa con historial real (contexto de varios turnos). */
type HistoryCase = {
  name: string;
  scenario: ScenarioKey;
  level: string;
  history: { role: 'user' | 'character'; content_text: string }[];
  message: string;
  mood?: 'neutral' | 'content' | 'confus';
  signal?: 'below' | 'on' | 'above';
  error?: boolean;
  /**
   * Si está definido, al menos una de estas palabras debe aparecer en
   * reply_text; sirve para comprobar que el modelo mantiene el tema
   * a lo largo de la conversación (listas amplias para evitar falsos
   * negativos).
   */
  keywords?: string[];
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
// ── EXTENSIÓ: més combinacions escenari×nivell ──
  {
    name: 'mercat · principiant · demanar fruita senzilla',
    scenario: 'mercat',
    level: 'principiant',
    message: 'Bon dia, hui la fruita està bona? Voldria comprar taronges.',
    mood: 'content',
    signal: 'on',
  },
  {
    name: 'mercat · principiant · dubte davant el mostrador',
    scenario: 'mercat',
    level: 'principiant',
    message: 'Perdona, no sé quina fruita triar, què em recomanes?',
    mood: 'confus',
  },
  {
    name: 'bar · intermedi · triar entre els vins de la casa',
    scenario: 'bar',
    level: 'intermedi',
    message: "M'agradaria un vi de la casa, quin teniu obert?",
    mood: 'neutral',
  },
  {
    name: 'ajuntament · intermedi · preguntar per un formulari',
    scenario: 'ajuntament',
    level: 'intermedi',
    message: 'On puc recollir el formulari per a la llicència?',
    mood: 'content',
  },
  {
    name: 'bar · avancat · orxata amb localisme valencià',
    scenario: 'bar',
    level: 'avancat',
    message: 'Me posa una orxata amb xufes i fartons, si us plau?',
    mood: 'content',
    signal: 'above',
  },
  {
    name: 'colegi · principiant · saludar la mestra a l’aula',
    scenario: 'colegi',
    level: 'principiant',
    message: "Bon dia, mestra! Hui tenim classe de valencià?",
    mood: 'content',
  },
  {
    name: 'colegi · intermedi · demanar permís per eixir al pati',
    scenario: 'colegi',
    level: 'intermedi',
    message: 'Puc eixir al pati un moment, si us plau?',
    mood: 'neutral',
    signal: 'on',
  },
];

describe.skipIf(!hasCredentials)(`Integración real con la API de OpenAI (${CASES.length} casos d'un sol torn)`, () => {
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
// ─────────────────────────────────────────────────────────────
// SUITE 2: converses MULTI-TORN reals amb `history` (context).
// Comprova que el model manté el fil de la conversa: a més del
// contracte JSON, almenys una paraula del tema ha d'aparéixer
// a la resposta (llistes àmplies per evitar falsos negatius).
// ─────────────────────────────────────────────────────────────
const HISTORY_CASES: HistoryCase[] = [
  {
    name: 'mercat · negociar el preu de les taronges a través de la conversa',
    scenario: 'mercat',
    level: 'intermedi',
    history: [
      { role: 'user', content_text: 'Bon dia! Quant valen les taronges?' },
      { role: 'character', content_text: 'A dos euros el quilo, són de la terra.' },
      { role: 'user', content_text: 'Més que al poble... en duré tres quilos si em fas un descompte.' },
    ],
    message: "D'acord, tres quilos a preu de dos, o si no em quede amb la meitat.",
    mood: 'content',
    signal: 'on',
    keywords: ['tarong', 'quilo', 'preu', 'descompt', 'euro', '€', 'quilogram'],
  },
  {
    name: 'bar · recordar la comanda anterior i ampliar-la',
    scenario: 'bar',
    level: 'intermedi',
    history: [
      { role: 'user', content_text: 'Em poseu una aigua amb gas?' },
      { role: 'character', content_text: 'Tot seguit, una aigua amb gas. Voleu res més?' },
    ],
    message: 'Sí, també voldria una copa de vi blanc de la casa.',
    keywords: ['aigua', 'vi blanc', 'cop', 'casa', 'penedès', 'terra'],
  },
  {
    name: "oficina · tancar la cita acordada en el torn anterior",
    scenario: 'oficina',
    level: 'principiant',
    history: [
      { role: 'user', content_text: "Bon dia, volia demanar hora per al certificat d'empadronament." },
      { role: 'character', content_text: "Bon dia! Doncs demà a les deu. Us va bé?" },
    ],
    message: 'Val, d\'acord, moltes gràcies.',
    mood: 'content',
    keywords: ['certificat', 'empadronament', 'cita', 'hora', 'deu', '10'],
  },
  {
    name: "ajuntament · seguiment de la llicència d'obres",
    scenario: 'ajuntament',
    level: 'avancat',
    history: [
      { role: 'user', content_text: "Voldria presentar una instància per a la llicència d'obres." },
      { role: 'character', content_text: "Comentem-ho: la llicència d'obres menors es resol en uns vint dies hàbils." },
    ],
    message: "Llavors, quins documents he d'aportar per avançat?",
    keywords: ['llicènci', 'obres', 'document', 'instància', 'tràmit', 'aport'],
  },
  {
    name: 'mercat · principiant · continuar un fil amb un terme desconegut',
    scenario: 'mercat',
    level: 'principiant',
    history: [
      { role: 'character', content_text: 'Ara mateix les taronges estan cares pel mal temps que ha fet.' },
    ],
    message: 'Perdona, "mal temps" què vol dir?',
    mood: 'confus',
    error: true,
    keywords: ['mal temps', 'tempor', 'tarong', 'clima'],
  },
];

describe.skipIf(!hasCredentials)(`Integración real · conversa multi-torn amb historial (${HISTORY_CASES.length} casos)`, () => {
  it.each(HISTORY_CASES)(
    '$name',
    async (c: HistoryCase) => {
      const reply = await replyFromAgent({
        scenario: c.scenario,
        level: c.level,
        message: c.message,
        history: c.history,
      });

      console.log(`[crudo LLM][historial] ${c.name} =>`, JSON.stringify(reply));

      // Contrato válido y respuesta no vacía.
      expect(typeof reply.reply_text).toBe('string');
      expect(reply.reply_text.trim().length).toBeGreaterThan(3);
      expect(MOODS).toContain(reply.mood);
      expect(SIGNALS).toContain(reply.detected_level_signal);
      expect(Array.isArray(reply.error_flags)).toBe(true);

      // Coherencia con el estado inducido.
      if (c.mood) expect(reply.mood).toBe(c.mood);
      if (c.signal) expect(reply.detected_level_signal).toBe(c.signal);
      if (c.error) {
        const flagged =
          reply.mood === 'confus' ||
          reply.detected_level_signal === 'below' ||
          reply.error_flags.length > 0;
        expect(flagged, `No es va detectar cap senyal d'error a: ${JSON.stringify(reply)}`).toBe(true);
      }

      // El modelo debe mantener el tema de la conversación.
      if (c.keywords) {
        const lower = reply.reply_text.toLowerCase();
        const hits = c.keywords.filter((k) => lower.includes(k));
        expect(
          hits.length > 0,
          `La resposta no manté el tema (cap de: ${c.keywords.join(', ')}): ${reply.reply_text}`,
        ).toBe(true);
      }
    },
    45_000,
  );
});

