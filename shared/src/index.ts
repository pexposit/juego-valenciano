/**
 * Font única de veritat per a escenaris, nivells i límits compartits entre el
 * backend i el frontend. En afegir un escenari nou només cal tocar aquest
 * fitxer: `ScenarioKey` deriva de `SCENARIO_KEYS` i tots els `Record` tipats
 * obliguen a cobrir-lo (el compilador falla si se n'oblida alguno).
 */

export const SCENARIO_KEYS = [
  'mercat',
  'bar',
  'oficina',
  'ajuntament',
  'colegi',
  'turisme',
] as const;

export type ScenarioKey = (typeof SCENARIO_KEYS)[number];

export const LEVELS = ['principiant', 'intermedi', 'avancat'] as const;

export type LevelKey = (typeof LEVELS)[number];

// Cada escenari té el seu personatge amb una veu TTS pròpia.
export const VOICE_BY_SCENARIO: Record<ScenarioKey, string> = {
  mercat: 'lluc',
  bar: 'gina',
  oficina: 'lluc',
  ajuntament: 'gina',
  colegi: 'gina',
  turisme: 'gina',
};

/** XP necessària per completar un escenari. */
export const SCENARIO_XP = 100;

/* ── Límits de l'historial de conversa ────────────────────────────────── */
/** Longitud màxima d'un missatge individual. */
export const MESSAGE_MAX_CHARS = 2000;
/** Nombre màxim de missatges de context. */
export const HISTORY_MAX_MESSAGES = 20;
/** Pressupost total de caràcters de l'historial (anti-inflació de tokens). */
export const HISTORY_MAX_CHARS = 8000;

export type HistoryMessage = { role: 'user' | 'character'; content_text: string };

/**
 * Limita l'historial a un pressupost fix: només els últims missatges que
 * caben dins de HISTORY_MAX_MESSAGES i HISTORY_MAX_CHARS. Protegeix contra
 * clients que envien historial inventat per manipular l'agent o inflar
 * el consum de tokens.
 */
export function sanitizeHistory(history: HistoryMessage[]): HistoryMessage[] {
  const limited = history
    .slice(-HISTORY_MAX_MESSAGES)
    .map((m) => ({
      role: m.role,
      content_text: typeof m.content_text === 'string' ? m.content_text.slice(0, MESSAGE_MAX_CHARS) : '',
    }));
  // Recorre de més recent a més antic i descarta els missatges que es
  // passarien del pressupost total de caràcters.
  let total = 0;
  const out: HistoryMessage[] = [];
  for (let i = limited.length - 1; i >= 0; i -= 1) {
    total += limited[i].content_text.length;
    if (total > HISTORY_MAX_CHARS) break;
    out.unshift(limited[i]);
  }
  return out;
}
