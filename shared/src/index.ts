/**
 * Font única de veritat per a nivells i límits compartits entre el backend i
 * el frontend. Els escenaris (clau, personatge, prompt, veu) ja no viuen ací:
 * es defineixen a la taula resources de la BDD.
 */

export const LEVELS = ['principiant', 'intermedi', 'avancat'] as const;

export type LevelKey = (typeof LEVELS)[number];

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

/* ── Redaccions dels exàmens ──────────────────────────────────────────── */
// El frontend (comptador en directe) i el backend (dades per a l'avaluador)
// han de comptar igual les paraules i les paraules obligatòries usades.

export const countWords = (text: string) => text.trim().split(/\s+/).filter(Boolean).length;

const normalizeWord = (text: string) => text.toLocaleLowerCase('ca').normalize('NFD').replace(/\p{M}/gu, '');

// Formes acceptades d'una paraula: singular i plural (estoig/estoigs, agenda/agendes).
// Una paraula amb gènere com «malalt/a» accepta també el femení (malalta, malaltes).
const wordForms = (word: string) => {
  const [base, feminine] = normalizeWord(word).split('/');
  const forms = (w: string) => [w, `${w}s`, w.endsWith('a') ? `${w.slice(0, -1)}es` : w];
  return new Set([...forms(base), ...(feminine ? forms(base + feminine) : [])]);
};

/** Paraules de la llista que apareixen en el text (en qualsevol de les seues formes). */
export function usedRequiredWords(text: string, words: string[]): string[] {
  const tokens = new Set(normalizeWord(text).split(/[^\p{L}·]+/u).filter(Boolean));
  return words.filter(w => [...wordForms(w)].some(f => tokens.has(f)));
}
