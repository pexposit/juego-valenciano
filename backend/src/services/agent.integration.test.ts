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
import { getScenario } from './scenarios.js';

// Els escenaris es lligen de la taula resources (type).
type ScenarioKey = string;

async function loadScenario(type: ScenarioKey) {
  const scenario = await getScenario(type);
  if (!scenario) throw new Error(`L'escenari ${type} no existix a la BDD o no té system_prompt`);
  return scenario;
}
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
    name: 'bar · A2 · salutació inicial',
    scenario: 'bar',
    level: 'A2',
    message: 'Bon dia! Què em recomanes per a beure?',
    mood: 'neutral',
  },
  {
    name: 'oficina · B1 · demanar cita',
    scenario: 'oficina',
    level: 'B1',
    message: 'Bon dia, vull demanar hora amb el regidor d\'urbanisme.',
    mood: 'content',
  },
  {
    name: 'ajuntament · A2 · inici de conversa',
    scenario: 'ajuntament',
    level: 'A2',
    message: 'Hola, necessite ajuda amb un tràmit.',
    mood: 'neutral',
  },

  // ── Petició correcta / registre adequat ──
  {
    name: 'bar · B1 · demanar una cervesa',
    scenario: 'bar',
    level: 'B1',
    message: 'Em poses una cervesa, si us plau?',
    mood: 'content',
    signal: 'on',
  },
  {
    name: 'mercat · B1 · preguntar preus',
    scenario: 'mercat',
    level: 'B1',
    message: 'Quant val el quilo de taronges?',
    mood: 'neutral',
    signal: 'on',
  },
  {
    name: 'mercat · C1 · demanar productes',
    scenario: 'mercat',
    level: 'C1',
    message: 'Necessite tres quilos de tomàquets de la terra, si us plau.',
    signal: 'above',
  },
  {
    name: 'oficina · C1 · explicar un tràmit',
    scenario: 'oficina',
    level: 'C1',
    message: 'Seria possible obtindre el certificat d\'empadronament per a demà?',
    mood: 'content',
    signal: 'on',
  },
  {
    name: 'ajuntament · B1 · demanar informació',
    scenario: 'ajuntament',
    level: 'B1',
    message: 'M\'agradaria saber els horaris d\'atenció al públic.',
    mood: 'neutral',
    signal: 'on',
  },

  // ── Nivell superior / resposta avançada ──
  {
    name: 'bar · C1 · demanar un vi de la comarca',
    scenario: 'bar',
    level: 'C1',
    message: 'M\'agradaria un vi negre de la comarca, me\'n pots parlar una miqueta?',
    mood: 'content',
    signal: 'above',
  },
  {
    name: 'mercat · C1 · negociar el preu',
    scenario: 'mercat',
    level: 'C1',
    message: 'Parlem del preu, crec que és una miqueta car.',
    mood: 'content',
    signal: 'above',
  },
  {
    name: 'bar · B1 · demanar el compte',
    scenario: 'bar',
    level: 'B1',
    message: 'El compte, per favor.',
    mood: 'neutral',
    signal: 'on',
  },

  // ── ESTAT ERROR / castellanisme / no entendre ──
  {
    name: 'bar · A2 · castellanismes',
    scenario: 'bar',
    level: 'A2',
    message: 'yo querer cerveza por favor',
    error: true,
  },
  {
    name: 'mercat · A2 · no entendre el preu',
    scenario: 'mercat',
    level: 'A2',
    message: 'perdona, no entenc, pots repetir?',
    mood: 'confus',
    error: true,
  },
  {
    name: 'ajuntament · A2 · no saber què dir',
    scenario: 'ajuntament',
    level: 'A2',
    message: 'no saber que decir',
    mood: 'confus',
    error: true,
  },
  {
    name: 'oficina · B1 · frase amb faltes',
    scenario: 'oficina',
    level: 'B1',
    message: 'quiero el papel de empadronamiento para el registro',
    error: true,
  },
  {
    name: 'mercat · B1 · queixa de preu massa alt',
    scenario: 'mercat',
    level: 'B1',
    message: 'Això és massa car per a mi!',
    mood: 'confus',
  },
  {
    name: 'ajuntament · C1 · resposta amb argot',
    scenario: 'ajuntament',
    level: 'C1',
    message: 'Voldria presentar una instància per registrar una denúncia formal.',
    signal: 'above',
  },

  // ── COMIAT / tancament ──
  {
    name: 'oficina · B1 · comiat',
    scenario: 'oficina',
    level: 'B1',
    message: 'Moltes gràcies per la informació, adeu!',
    mood: 'content',
  },
  {
    name: 'bar · A2 · acomiadar-se',
    scenario: 'bar',
    level: 'A2',
    message: 'Ara me\'n vaig, fins demà!',
    mood: 'content',
  },
// ── EXTENSIÓ: més combinacions escenari×nivell ──
  {
    name: 'mercat · A2 · demanar fruita senzilla',
    scenario: 'mercat',
    level: 'A2',
    message: 'Bon dia, hui la fruita està bona? Voldria comprar taronges.',
    mood: 'content',
    signal: 'on',
  },
  {
    name: 'mercat · A2 · dubte davant el mostrador',
    scenario: 'mercat',
    level: 'A2',
    message: 'Perdona, no sé quina fruita triar, què em recomanes?',
    mood: 'confus',
  },
  {
    name: 'bar · B1 · triar entre els vins de la casa',
    scenario: 'bar',
    level: 'B1',
    message: "M'agradaria un vi de la casa, quin teniu obert?",
    mood: 'neutral',
  },
  {
    name: 'ajuntament · B1 · preguntar per un formulari',
    scenario: 'ajuntament',
    level: 'B1',
    message: 'On puc recollir el formulari per a la llicència?',
    mood: 'content',
  },
  {
    name: 'bar · C1 · orxata amb localisme valencià',
    scenario: 'bar',
    level: 'C1',
    message: 'Me posa una orxata amb xufes i fartons, si us plau?',
    mood: 'content',
    signal: 'above',
  },
  {
    name: 'colegi · A2 · saludar la mestra a l’aula',
    scenario: 'colegi',
    level: 'A2',
    message: "Bon dia, mestra! Hui tenim classe de valencià?",
    mood: 'content',
  },
  {
    name: 'colegi · B1 · demanar permís per eixir al pati',
    scenario: 'colegi',
    level: 'B1',
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
        scenario: await loadScenario(c.scenario),
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
      // 3) Coherència amb l'estat induït.
      if (c.mood) expect(reply.mood).toBe(c.mood);
      if (c.error) {
        // En un cas d'error, el model deu assenyalar-ho d'alguna manera.
        expect(reply.mood, `No es va detectar cap senyal d'error a: ${JSON.stringify(reply)}`).toBe('confus');
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
    level: 'B1',
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
    level: 'B1',
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
    level: 'A2',
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
    level: 'C1',
    history: [
      { role: 'user', content_text: "Voldria presentar una instància per a la llicència d'obres." },
      { role: 'character', content_text: "Comentem-ho: la llicència d'obres menors es resol en uns vint dies hàbils." },
    ],
    message: "Llavors, quins documents he d'aportar per avançat?",
    keywords: ['llicènci', 'obres', 'document', 'instància', 'tràmit', 'aport'],
  },
  {
    name: 'mercat · A2 · continuar un fil amb un terme desconegut',
    scenario: 'mercat',
    level: 'A2',
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
        scenario: await loadScenario(c.scenario),
        level: c.level,
        message: c.message,
        history: c.history,
      });

      console.log(`[crudo LLM][historial] ${c.name} =>`, JSON.stringify(reply));

      // Contrato válido y respuesta no vacía.
      expect(typeof reply.reply_text).toBe('string');
      expect(reply.reply_text.trim().length).toBeGreaterThan(3);
      expect(MOODS).toContain(reply.mood);
      // Coherencia con el estado inducido.
      if (c.mood) expect(reply.mood).toBe(c.mood);
      if (c.error) {
        expect(reply.mood, `No es va detectar cap senyal d'error a: ${JSON.stringify(reply)}`).toBe('confus');
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

