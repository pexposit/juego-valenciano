/**
 * Font única de veritat per a nivells i límits compartits entre el backend i
 * el frontend. Els escenaris (clau, personatge, prompt, veu) ja no viuen ací:
 * es defineixen a la taula resources de la BDD.
 */

// Els nivells de l'aprenent són els del MECR (A1-C2), més el 'nivell0', el més bàsic: per a
// xiquets que encara no llegixen (món d'illes infantil). profiles.level i resources.difficulty
// fan servir estos mateixos valors.
export const LEVELS = ['nivell0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'] as const;

export type LevelKey = (typeof LEVELS)[number];

/** El món infantil del Nivell 0 és per als xiquets (profiles.age_group = 'child') de nivell 0. */
export const isKidsLevel0 = (profile: { level?: string | null; age_group?: string | null }) =>
  profile.level === 'nivell0' && profile.age_group === 'child';

/** Nivells del MECR (els de practice_exercises i dels exàmens) de cada nivell de l'aprenent: el seu. */
export const LEVEL_CEFR: Record<LevelKey, readonly string[]> = {
  nivell0: [], // previ al MECR: no té exercicis del temari
  A1: ['A1'],
  A2: ['A2'],
  B1: ['B1'],
  B2: ['B2'],
  C1: ['C1'],
  C2: ['C2'],
};

/** Tram del MECR d'un nivell (A: bàsic, B: independent, C: competent), per a adaptar el registre. */
export const levelBand = (level: string | null | undefined): 'A' | 'B' | 'C' | null =>
  level && /^[ABC][12]$/.test(level) ? (level[0] as 'A' | 'B' | 'C') : null;

/* ── Rutes d'aprenentatge ─────────────────────────────────────────────── */
/** Nivells amb rutes predefinides (study_paths). */
export const PREDEFINED_PATH_LEVELS: readonly string[] = ['A2', 'B1', 'B2'];
export const hasPredefinedPaths = (level: string | null | undefined) => !!level && PREDEFINED_PATH_LEVELS.includes(level);
/** Nivells amb ruta personalitzada generada per la IA (learning_paths), a més de les predefinides. */
export const AI_PATH_LEVELS: readonly string[] = ['B1', 'B2', 'C1'];
export const hasAiPath = (level: string | null | undefined) => !!level && AI_PATH_LEVELS.includes(level);
/** Una ruta que el tutor del xat enllaça (la que l'aprenent ha demanat o la que li acaba de preparar). */
export type StudyPathRef = { id: string; title: string; description: string };
/** Ruta pròpia que el tutor prepara quan l'aprenent ho accepta (POST /api/study-paths/generate). */
export type OwnPathResult =
  | { status: 'ok'; path: StudyPathRef; message: string }
  | { status: 'insufficient' | 'error'; message: string };
/** Màxim de caràcters del tema d'una ruta pròpia (el que li costa a l'aprenent, segons el tutor). */
export const OWN_PATH_TOPIC_MAX = 120;
/** Nivells en què el tutor del xat pot preparar rutes pròpies de l'alumne (study_paths.student_id). */
export const OWN_PATH_LEVELS: readonly string[] = ['A1', 'A2', 'B1', 'B2', 'C1'];
export const hasOwnPaths = (level: string | null | undefined) => !!level && OWN_PATH_LEVELS.includes(level);
/** La pantalla de rutes (/ruta) mostra les rutes de study_paths: predefinides, de classe i pròpies. */
export const hasStudyPaths = (level: string | null | undefined) => hasPredefinedPaths(level) || hasOwnPaths(level);

/* ── Límits de l'historial de conversa ────────────────────────────────── */
/* ── Límits del text que avalua un LLM ────────────────────────────────── */
/** Longitud màxima d'un missatge individual (xat dels escenaris i del tutor). */
export const MESSAGE_MAX_CHARS = 2000;
/** Longitud màxima d'una redacció (Expressió escrita, en pràctica i en examen). */
export const WRITING_MAX_CHARS = 2000;
/** El C1 demana textos més llargs: el límit és de 3500 caràcters. */
export const WRITING_MAX_CHARS_C1 = 3500;
export const writingMaxChars = (level: string | null | undefined) => (level === 'C1' ? WRITING_MAX_CHARS_C1 : WRITING_MAX_CHARS);
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

/**
 * Paraules de la llista que apareixen en el text (en qualsevol de les seues formes). Una expressió de
 * diverses paraules («de vegades», «a poc a poc») compta si les seues paraules apareixen seguides i en
 * este ordre; cada una pot anar en singular o plural.
 */
export function usedRequiredWords(text: string, words: string[]): string[] {
  const tokens = normalizeWord(text).split(/[^\p{L}·]+/u).filter(Boolean);
  return words.filter(w => {
    // La «/» es manté dins de la paraula: «malalt/a» és una sola paraula amb dos gèneres.
    const parts = normalizeWord(w).split(/[^\p{L}·/]+/u).filter(Boolean);
    if (parts.length === 0) return false;
    const forms = parts.map(part => wordForms(part));
    return tokens.some((_, start) => forms.every((f, i) => start + i < tokens.length && f.has(tokens[start + i])));
  });
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
// Nivells del MECR: els del perfil de l'alumnat (a banda del Nivell 0), de les classes i de les
// activitats de la docent.
export const CEFR_LEVELS = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'] as const;
export type CefrLevel = (typeof CEFR_LEVELS)[number];

/** Nom visible d'un nivell: «Nivell 0» o el del MECR (B1). */
export const levelLabel = (level: string) => (level === 'nivell0' ? 'Nivell 0' : level);

// Una classe és del Nivell 0 (infantil, sense activitats ni rutes de la docent) o d'un o dos
// nivells contigus del MECR (com valid_class_levels a la BDD).
export const CLASS_LEVELS: readonly { value: string; label: string }[] = [
  { value: 'nivell0', label: 'Nivell 0' },
  ...CEFR_LEVELS.map(l => ({ value: l, label: l })),
];
export const classLevelLabel = (level: string) => (level === 'nivell0' ? 'Nivell 0' : level);
export const isLevel0Class = (levels: readonly string[]) => levels.includes('nivell0');

/** Un alumne (o una activitat del catàleg) d'este nivell pot entrar en una classe d'estos nivells? */
export const classAcceptsLearner = (levels: readonly string[], learner: string) => levels.includes(learner);

/** Tria o desfà la tria d'un nivell: el Nivell 0 sol, o com a molt dos del MECR contigus. */
export function toggleClassLevel(selected: readonly string[], level: string): string[] {
  if (selected.includes(level)) return selected.filter(l => l !== level);
  if (level === 'nivell0') return ['nivell0'];
  const order = CEFR_LEVELS as readonly string[];
  const next = [...selected.filter(l => l !== 'nivell0'), level].sort((a, b) => order.indexOf(a) - order.indexOf(b));
  const contiguous = next.length === 2 && order.indexOf(next[1]) - order.indexOf(next[0]) === 1;
  return next.length === 1 || contiguous ? next : [level];
}

/* ── Agent del professorat: activitats i rutes a partir d'un prompt ──── */
// Màxim de caràcters del prompt de la docent.
export const TEACHER_AGENT_PROMPT_MAX = 1000;
// Tipus d'activitat que l'agent sap crear (els de les plantilles tancades).
export const TEACHER_AGENT_KINDS: readonly TeacherActivityKind[] = ['exercises', 'reading', 'writing', 'scenario'];

/** Un esborrany d'activitat (sense classes: la docent la revisa i la guarda). `ok: false` si no s'ha pogut generar. */
export type AgentActivityResult =
  | { ok: true; activity: TeacherActivityInput; notes: string }
  | { ok: false; message: string };

/** Una activitat que ja existix i que l'agent posa en la ruta, amb el motiu perquè la docent comprove que és rellevant. */
export type AgentPathStep = { resource_id: string; title: string; category: string; icon: string | null; own: boolean; reason: string };
/** Una activitat que falta per a completar la ruta, amb un prompt per a crear-la amb l'agent d'activitats. */
// `kind`: el tipus d'activitat que cal crear; sempre és un dels que l'agent sap crear (TEACHER_AGENT_KINDS).
export type AgentMissingActivity = { title: string; why: string; suggested_prompt: string; kind: TeacherActivityKind };

/**
 * Ruta generada amb activitats que ja existixen. `ok`: totes les passes eren al catàleg o a les de la docent;
 * `partial`: n'hi ha prou per a una ruta però falten activitats (`missing`); `insufficient`: no hi ha prou activitats
 * (no es torna ruta) i es proposa crear-ne de noves.
 */
export type AgentPathResult =
  | { status: 'ok' | 'partial'; level: string; title: string; description: string; steps: AgentPathStep[]; missing: AgentMissingActivity[]; message: string }
  | { status: 'insufficient'; message: string; missing: AgentMissingActivity[]; steps: AgentPathStep[] }
  | { status: 'error'; message: string };

/* ── Documents que la docent adjunta a l'agent (examen o temari) ─────── */
// El fitxer no es guarda: se n'extrau el text i es conserva en la memòria del servidor una estona (no a disc), només per
// a les peticions de la docent. En cada petició s'hi trien els fragments més rellevants (fins a TEACHER_DOCUMENT_MAX_CHARS).
export const TEACHER_DOCUMENT_MAX_BYTES = 100 * 1024 * 1024;
// Text del document que es conserva (la resta es descarta) i text que arriba al model en cada petició.
export const TEACHER_DOCUMENT_MAX_STORED_CHARS = 20_000_000;
export const TEACHER_DOCUMENT_MAX_CHARS = 40_000;
export const TEACHER_DOCUMENT_EXTENSIONS = ['.pdf', '.docx', '.txt', '.md'] as const;

/** Un document adjuntat: el client només en té l'identificador (el text és al servidor). `truncated`: era massa llarg. */
export type AgentDocument = { id: string; name: string; chars: number; truncated: boolean };
