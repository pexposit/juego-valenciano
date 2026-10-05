/**
 * Font única de veritat per a nivells i límits compartits entre el backend i
 * el frontend. Els escenaris (clau, personatge, prompt, veu) ja no viuen ací:
 * es defineixen a la taula resources de la BDD.
 */

// 'nivell0' és el més bàsic: per a xiquets que encara no llegixen (món d'illes infantil).
export const LEVELS = ['nivell0', 'principiant', 'intermedi', 'avancat'] as const;

export type LevelKey = (typeof LEVELS)[number];

/** El món infantil del Nivell 0 és per als xiquets (profiles.es_adult = false) de nivell 0. */
export const isKidsLevel0 = (profile: { level?: string | null; es_adult?: boolean | null }) =>
  profile.level === 'nivell0' && profile.es_adult === false;

/** Nivells del MECR (els de practice_exercises i dels exàmens) de cada nivell de l'aprenent. */
export const LEVEL_CEFR: Record<LevelKey, readonly string[]> = {
  nivell0: [], // previ al MECR: no té exercicis del temari
  principiant: ['A1', 'A2'],
  intermedi: ['B1', 'B2'],
  avancat: ['C1', 'C2'],
};

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

/* ── Pràctica del temari ──────────────────────────────────────────────── */
/**
 * Àrees del temari de la JQCV amb pantalla d'exercicis: les destreses (menys
 * l'expressió oral) i els continguts lingüístics. Cadascuna és una `category` de
 * resources, i els seus continguts (`type`) tenen exercicis a practice_exercises.
 * L'ordre és el del temari.
 */
export const PRACTICE_AREAS = {
  comprensio_oral: 'Comprensió oral',
  comprensio_escrita: 'Comprensió escrita',
  expressio_escrita: 'Expressió escrita',
  fonetica_ortografia: 'Fonètica i ortografia',
  morfosintaxi: 'Morfosintaxi',
  lexic_semantica: 'Lèxic i semàntica',
} as const;

export type PracticeArea = keyof typeof PRACTICE_AREAS;

/** Àrees que es practiquen conversant amb un personatge, en la pantalla del xat. */
export const CONVERSATION_AREAS = {
  expressio_oral: 'Expressió oral',
} as const;

/** Àrees de conversa on només es pot parlar: el xat no admet missatges escrits. */
export const isVoiceOnlyCategory = (category: string) => category in CONVERSATION_AREAS;

/** Categories de resources que s'obrin al xat: els escenaris i les àrees de conversa. */
/** Categoria del tutor de valencià dels comptes infantils: es xateja amb ell des del tauler, no és una activitat del catàleg. */
export const ASSISTANT_CATEGORY = 'assistent';
/** `type` del recurs del tutor infantil (resources.type). */
export const KID_ASSISTANT_TYPE = 'ajuda_infantil';

export const CHAT_CATEGORIES: readonly string[] = ['escenari', ...Object.keys(CONVERSATION_AREAS), ASSISTANT_CATEGORY];

export const isPracticeArea = (category: string): category is PracticeArea => category in PRACTICE_AREAS;

/** Compara una resposta escrita amb les acceptades: sense diferenciar majúscules,
 * espais sobrants, puntuació final ni la forma de l'apòstrof, però sí els accents. */
export const normalizeAnswer = (text: string) =>
  text.trim().toLocaleLowerCase('ca').replace(/[’`´]/g, "'").replace(/l\.l/g, 'l·l').replace(/\s+/g, ' ').replace(/[.,;:!?¡¿]+$/, '');

/** Llengües maternes que es poden triar en crear el compte (profiles.mother_tongue: codi ISO 639-1 o 'other'). */
export const MOTHER_TONGUES = [
  { value: 'es', label: 'Castellà' },
  { value: 'en', label: 'Anglés' },
  { value: 'fr', label: 'Francés' },
  { value: 'ar', label: 'Àrab' },
  { value: 'ro', label: 'Romanés' },
  { value: 'uk', label: 'Ucraïnés' },
  { value: 'ru', label: 'Rus' },
  { value: 'zh', label: 'Xinés' },
  { value: 'it', label: 'Italià' },
  { value: 'de', label: 'Alemany' },
  { value: 'pt', label: 'Portugués' },
  { value: 'ca', label: 'Valencià / Català' },
  { value: 'other', label: 'Una altra llengua' },
] as const;

/** Nom (en valencià) d'una llengua materna, o undefined si no és una de les triables. */
export const motherTongueLabel = (code: string | null | undefined) =>
  MOTHER_TONGUES.find(t => t.value === code)?.label;
