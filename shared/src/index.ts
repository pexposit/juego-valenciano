/**
 * Font única de veritat per a nivells i límits compartits entre el backend i
 * el frontend. Els escenaris (clau, personatge, prompt, veu) ja no viuen ací:
 * es defineixen a la taula resources de la BDD.
 */

// 'nivell0' és el més bàsic: per a xiquets que encara no llegixen (món d'illes infantil).
export const LEVELS = ['nivell0', 'principiant', 'intermedi', 'avancat'] as const;

export type LevelKey = (typeof LEVELS)[number];

/** El món infantil del Nivell 0 és per als xiquets (profiles.age_group = 'child') de nivell 0. */
export const isKidsLevel0 = (profile: { level?: string | null; age_group?: string | null }) =>
  profile.level === 'nivell0' && profile.age_group === 'child';

/** Nivells del MECR (els de practice_exercises i dels exàmens) de cada nivell de l'aprenent. */
export const LEVEL_CEFR: Record<LevelKey, readonly string[]> = {
  nivell0: [], // previ al MECR: no té exercicis del temari
  principiant: ['A1', 'A2'],
  intermedi: ['B1', 'B2'],
  avancat: ['C1', 'C2'],
};

/* ── Rutes d'aprenentatge ─────────────────────────────────────────────── */
/** Nivells amb rutes predefinides (i del professorat) en lloc de la ruta generada per la IA. */
export const PREDEFINED_PATH_LEVELS: readonly string[] = ['principiant', 'intermedi'];
export const hasPredefinedPaths = (level: string | null | undefined) => !!level && PREDEFINED_PATH_LEVELS.includes(level);

/* ── Límits de l'historial de conversa ────────────────────────────────── */
/* ── Límits del text que avalua un LLM ────────────────────────────────── */
/** Longitud màxima d'un missatge individual (xat dels escenaris i del tutor). */
export const MESSAGE_MAX_CHARS = 2000;
/** Longitud màxima d'una redacció (Expressió escrita, en pràctica i en examen). */
export const WRITING_MAX_CHARS = 2000;
/** Longitud màxima de cada camp d'un formulari (A1). */
export const FORM_FIELD_MAX_CHARS = 500;
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
  { value: 'it', label: 'Italià' },
  { value: 'ro', label: 'Romanés' },
  { value: 'uk', label: 'Ucraïnés' },
  { value: 'other', label: 'Una altra llengua' },
] as const;

 /*{ value: 'ru', label: 'Rus' },
  { value: 'zh', label: 'Xinés' },
  { value: 'de', label: 'Alemany' },
  { value: 'pt', label: 'Portugués' },*/


/** Llengües amb traducció (ajuda del tutor i subtítols del Nivell 0): totes menys 'ca' i 'other'. */
export const TRANSLATED_TONGUES = ['es', 'en', 'fr', 'it', 'ro', 'uk'] as const;
export type TranslatedTongue = (typeof TRANSLATED_TONGUES)[number];
export const isTranslatedTongue = (code: string | null | undefined): code is TranslatedTongue =>
  !!code && (TRANSLATED_TONGUES as readonly string[]).includes(code);

/** Nom (en valencià) d'una llengua materna, o undefined si no és una de les triables. */
export const motherTongueLabel = (code: string | null | undefined) =>
  MOTHER_TONGUES.find(t => t.value === code)?.label;

/* ── Activitats del professorat ───────────────────────────────────────── */
// Plantilles tancades: cada tipus té la mateixa forma que les activitats del catàleg i es pinta
// amb les mateixes pantalles. El backend valida estos límits; el formulari els mostra.
export const TEACHER_ACTIVITY_LIMITS = {
  title: 80,
  description: 300,
  questions: 40,
  prompt: 300,
  options: 5,
  option: 150,
  answers: 5,
  explanation: 300,
  readingTitle: 120,
  readingText: 4000,
  readingQuestions: 20,
  writingPrompt: 1000,
  minWords: 20,
  maxWords: 300,
  character: 80,
  situation: 600,
  greeting: 300,
  objectives: 5,
  objective: 200,
} as const;

// Àrees on pot anar un full d'exercicis (preguntes tancades i d'escriure la resposta).
export const TEACHER_EXERCISE_AREAS = ['fonetica_ortografia', 'morfosintaxi', 'lexic_semantica'] as const;
export type TeacherExerciseArea = (typeof TEACHER_EXERCISE_AREAS)[number];

// Veus i fons dels escenaris (els mateixos que fan servir els del catàleg).
export const SCENARIO_VOICES = [
  { value: 'gina', label: 'Gina (veu de dona)' },
  { value: 'lluc', label: 'Lluc (veu d\'home)' },
] as const;
export const SCENARIO_BACKGROUNDS = [
  { value: '/images/bar.jpg', label: 'Bar' },
  { value: '/images/restaurant.jpg', label: 'Restaurant' },
  { value: '/images/forn.jpg', label: 'Forn' },
  { value: '/images/market.jpg', label: 'Mercat' },
  { value: '/images/mall.jpg', label: 'Centre comercial' },
  { value: '/images/pharmacy.jpg', label: 'Farmàcia' },
  { value: '/images/office.jpg', label: 'Oficina' },
  { value: '/images/townhall.jpg', label: 'Ajuntament' },
  { value: '/images/tourism.jpg', label: 'Oficina de turisme' },
  { value: '/images/travel_agency.jpg', label: 'Agència de viatges' },
  { value: '/images/hotel.jpg', label: 'Hotel' },
  { value: '/images/real_state.jpg', label: 'Immobiliària' },
  { value: '/images/car_workshop.jpg', label: 'Taller mecànic' },
  { value: '/images/cooking_workshop.jpg', label: 'Taller de cuina' },
  { value: '/images/gym.jpg', label: 'Gimnàs' },
  { value: '/images/radio_station.jpg', label: 'Ràdio' },
  { value: '/images/flat.jpg', label: 'Pis' },
  { value: '/images/house_party.jpg', label: 'Festa a casa' },
  { value: '/images/classroom.jpg', label: 'Aula' },
  { value: '/images/street.jpg', label: 'Carrer' },
  { value: '/images/Montgó.jpg', label: 'Muntanya' },
] as const;

export type TeacherChoiceQuestion = { type: 'choice'; prompt: string; options: string[]; correct: number; explanation: string };
export type TeacherFillQuestion = { type: 'fill'; prompt: string; answers: string[]; explanation: string };
export type TeacherQuestion = TeacherChoiceQuestion | TeacherFillQuestion;

export type TeacherActivityContent =
  | { kind: 'exercises'; area: TeacherExerciseArea; questions: TeacherQuestion[] }
  | { kind: 'reading'; text_title: string; text: string; questions: TeacherChoiceQuestion[] }
  | { kind: 'writing'; prompt: string; min_words: number; max_words: number }
  | { kind: 'scenario'; character: string; situation: string; greeting: string; objectives: string[]; voice: string; background: string };
export type TeacherActivityKind = TeacherActivityContent['kind'];

/** El que envia el formulari de la docent (i el que torna el backend per a editar-la). */
export type TeacherActivityInput = {
  // Nivell del MECR de l'activitat (resources.difficulty serà el nivell de l'app que el cobrix).
  level: CefrLevel;
  title: string;
  description: string;
  icon: string;
  class_ids: string[];
  content: TeacherActivityContent;
};
export type TeacherActivity = TeacherActivityInput & { id: string; created_at: string };

/* ── Nivells de les classes i de les activitats del professorat ──────── */
// Nivells del MECR. El perfil de l'alumnat té els nivells de l'app (LEVEL_CEFR diu quins del MECR
// cobrix cadascun); les classes i les activitats de la docent van per nivells del MECR.
export const CEFR_LEVELS = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'] as const;
export type CefrLevel = (typeof CEFR_LEVELS)[number];

/** El nivell de l'app que cobrix un nivell del MECR (A1 → principiant...). */
export const learnerLevelOf = (cefr: string): LevelKey =>
  (Object.entries(LEVEL_CEFR).find(([, list]) => list.includes(cefr))?.[0] as LevelKey | undefined) ?? 'nivell0';

/** Nom visible d'un nivell, siga de l'app (principiant → A1-A2) o del MECR (B1). */
export const levelLabel = (level: string) =>
  level === 'nivell0' ? 'Nivell 0' : LEVEL_CEFR[level as LevelKey]?.join('-') || level;

// Una classe és del Nivell 0 (infantil, sense activitats ni rutes de la docent) o d'un o dos
// nivells contigus del MECR (com valid_class_levels a la BDD).
export const CLASS_LEVELS: readonly { value: string; label: string }[] = [
  { value: 'nivell0', label: 'Nivell 0' },
  ...CEFR_LEVELS.map(l => ({ value: l, label: l })),
];
export const classLevelLabel = (level: string) => (level === 'nivell0' ? 'Nivell 0' : level);
export const isLevel0Class = (levels: readonly string[]) => levels.includes('nivell0');

/** Un alumne d'este nivell de l'app pot entrar en una classe d'estos nivells? */
export const classAcceptsLearner = (levels: readonly string[], learner: string) =>
  learner === 'nivell0' ? levels.includes('nivell0') : (LEVEL_CEFR[learner as LevelKey] ?? []).some(l => levels.includes(l));

/** Tria o desfà la tria d'un nivell: el Nivell 0 sol, o com a molt dos del MECR contigus. */
export function toggleClassLevel(selected: readonly string[], level: string): string[] {
  if (selected.includes(level)) return selected.filter(l => l !== level);
  if (level === 'nivell0') return ['nivell0'];
  const order = CEFR_LEVELS as readonly string[];
  const next = [...selected.filter(l => l !== 'nivell0'), level].sort((a, b) => order.indexOf(a) - order.indexOf(b));
  const contiguous = next.length === 2 && order.indexOf(next[1]) - order.indexOf(next[0]) === 1;
  return next.length === 1 || contiguous ? next : [level];
}
