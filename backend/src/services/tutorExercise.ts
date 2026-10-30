import { getAdmin } from '../middleware/auth.js';
import { gnvRagEnabled, puntuarTextos, type Reranker } from './gnvRag.js';

// Exercici del catàleg que el tutor mostra dins del xat. Només preguntes tancades (choice) de les
// activitats de pràctica del catàleg (no les de docents) i sense text o àudio al davant.
export type TutorExercise = {
  id: string;
  resource_id: string;
  resource_name: string;
  level: string;
  prompt: string;
  options: string[]; // barrejades: en el catàleg la correcta va la primera
  answer: string;
  explanation: string;
};

const fold = (text: string) => text.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');
// Paraules que apareixen en quasi tots els temes de llengua («grafies», «regles», «paraules»...): no diuen de què va
// la pregunta, i deixades en el recompte emparellen el tema amb activitats que no hi tenen res a vore.
const GENERIC_WORDS = new Set([
  'grafia', 'grafies', 'lletra', 'lletres', 'paraula', 'paraules', 'regla', 'regles', 'forma', 'formes', 'usos', 'cas', 'casos',
  'exemple', 'exemples', 'ortografia', 'gramatica', 'normativa', 'llengua', 'valencia', 'valencian', 'escriu', 'escriure',
  'quan', 'diferencia', 'diferencies', 'tema', 'temes', 'general', 'generals',
]);
const words = (text: string) => fold(text).split(/[^a-z0-9]+/).filter(w => w.length >= 4 && !GENERIC_WORDS.has(w));

// Mateixa paraula amb marge per a plurals i derivats (no val un tros d'una altra: «lèxic» no és «lexicalitzats»).
const same = (a: string, b: string) => {
  const n = Math.min(6, a.length, b.length);
  return Math.abs(a.length - b.length) <= 3 && a.slice(0, n) === b.slice(0, n);
};

const LANGUAGE_AREAS = ['fonetica_ortografia', 'morfosintaxi', 'lexic_semantica', 'expressio_escrita', 'comprensio_escrita'];

type CatalogResource = {
  id: string; name: string; type: string; category: string; section_name: string | null;
  sources: { gram?: string; section?: string }[] | null; practice_exercises?: { count: number }[];
};
// El tema té exercicis, però cap del nivell de l'aprenent.
export const NO_AT_LEVEL = 'no_at_level' as const;
export const NO_AT_LEVEL_MESSAGE = "Encara no hi ha cap exercici d'això per al teu nivell";
export const NO_EXERCISE_MESSAGE = "Encara no hi ha cap exercici sobre això. De moment pots practicar amb les activitats del teu nivell.";
const label = (r: { section_name: string | null; name: string }) => r.section_name || r.name;

// Activitats de pràctica del catàleg (no les de docents), amb les seccions de la GNV que citen les seues lliçons.
// El catàleg canvia poc: es guarda uns minuts en memòria.
let catalogCache: { at: number; rows: CatalogResource[] } | undefined;
const CATALOG_TTL_MS = 10 * 60_000;

async function loadCatalog(): Promise<CatalogResource[]> {
  if (catalogCache && Date.now() - catalogCache.at < CATALOG_TTL_MS) return catalogCache.rows;
  const client = getAdmin() as any;
  if (!client) return [];
  const { data, error } = await client
    .from('resources')
    .select('id, name, type, category, section_name:metadata->>section_name, sources:metadata->lesson->sources, practice_exercises(count)')
    .is('teacher_id', null)
    .in('category', LANGUAGE_AREAS)
    .limit(1000);
  if (error) {
    console.warn("[tutor-exercise] no s'ha pogut consultar el catàleg:", error.message);
    return catalogCache?.rows ?? [];
  }
  const rows = ((data ?? []) as CatalogResource[]).filter(r => (r.practice_exercises?.[0]?.count ?? 0) > 0);
  catalogCache = { at: Date.now(), rows };
  return rows;
}

/**
 * Activitats de les quals la lliçó cita una secció de la GNV (el mateix que el RAG retorna com a «§ 5.1.3»).
 * `sections` va de més a menys important (la regla principal i després les que la completen): es torna
 * el primer grup que tinga activitats; primer les que citen exactament la secció i després les que citen
 * una de pare o de fill (5.1 per a 5.1.3).
 */
export function resourcesCitingGnv(catalog: CatalogResource[], sections: string[]): CatalogResource[] {
  return gnvCitationGroups(catalog, sections)[0] ?? [];
}

// Tots els grups de resourcesCitingGnv, en el mateix ordre: si el primer només té exercicis d'un nivell superior al de
// l'aprenent, el següent pot tindre'n del seu (p. ex. «s/ss» cita la 4.2.2 en C1 i la 4.3 en B2).
function gnvCitationGroups(catalog: CatalogResource[], sections: string[]): CatalogResource[][] {
  const cites = (r: CatalogResource, test: (section: string) => boolean) =>
    (r.sources ?? []).some(src => src.gram === 'GNV' && typeof src.section === 'string' && test(src.section));
  const related = (a: string, b: string) => a.startsWith(`${b}.`) || b.startsWith(`${a}.`);
  const groups: CatalogResource[][] = [];
  for (const section of sections.filter(Boolean)) groups.push(catalog.filter(r => cites(r, x => x === section)));
  for (const section of sections.filter(Boolean)) groups.push(catalog.filter(r => cites(r, x => related(x, section))));
  return groups.filter(group => group.length > 0);
}

// Activitats el nom de les quals parla del tema (paraules senceres).
const resourcesNamedLike = (catalog: CatalogResource[], topic: string) => {
  const wanted = words(topic);
  if (wanted.length === 0) return [];
  const scored = catalog
    .map(r => {
      const tokens = words(`${r.name} ${r.section_name ?? ''}`);
      return { r, score: wanted.filter(w => tokens.some(t => same(t, w))).length };
    })
    .filter(x => x.score > 0);
  const best = Math.max(0, ...scored.map(x => x.score));
  return scored.filter(x => x.score === best).map(x => x.r);
};

type Row = {
  id: string; level: string; prompt: string; options: string[]; answers: string[]; explanation: string | null; resource_id: string;
};
const EXERCISE_COLUMNS = 'id, level, prompt, options, answers, explanation, resource_id';

function shuffle<T>(items: T[]): T[] {
  const out = [...items];
  for (let i = out.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [out[i], out[j]] = [out[j], out[i]];
  }
  return out;
}

// Preguntes tancades vàlides i sense les ja mostrades.
const usable = (rows: Row[] | null, exclude: string[]) =>
  (rows ?? []).filter(r => Array.isArray(r.options) && r.options.length >= 2 && r.answers?.length && !exclude.includes(r.id));

const CEFR = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

// Dels exercicis donats, només els del nivell exacte de l'aprenent (ni d'un altre més baix ni més alt). Sense nivell
// conegut, tots valen.
const closestLevel = (rows: Row[], level: string | null | undefined) =>
  CEFR.includes(level ?? '') ? rows.filter(r => r.level === level) : rows;

// Puntuació mínima (0 a 1) del reranker perquè un exercici es considere del tema. Per davall, és preferible no mostrar
// cap exercici que un d'irrellevant. Cada reranker té la seua escala i, dins d'ella, el mínim depén del tipus de pregunta:
// en un dubte complex o quan demana practicar, el mínim de sempre; en un dubte simple, molt més exigent (només si
// l'exercici tracta de debò del que pregunta). Ajustables segons el que mostren els logs de rànquing:
// TUTOR_EXERCISE_MIN_SCORE i TUTOR_EXERCISE_MIN_SCORE_SIMPLE (local), TUTOR_EXERCISE_MIN_SCORE_JEV i
// TUTOR_EXERCISE_MIN_SCORE_SIMPLE_JEV (JEV).
export type ExerciseMode = 'complex' | 'simple' | 'request';
const MIN_RELEVANCE: Record<Reranker, { base: number; simple: number }> = {
  local: {
    base: Number(process.env.TUTOR_EXERCISE_MIN_SCORE ?? 0.1),
    simple: Number(process.env.TUTOR_EXERCISE_MIN_SCORE_SIMPLE ?? 0.5),
  },
  jev: {
    base: Number(process.env.TUTOR_EXERCISE_MIN_SCORE_JEV ?? 0.5),
    simple: Number(process.env.TUTOR_EXERCISE_MIN_SCORE_SIMPLE_JEV ?? 0.8),
  },
};
const minRelevance = (reranker: Reranker, mode: ExerciseMode) => MIN_RELEVANCE[reranker][mode === 'simple' ? 'simple' : 'base'];

// Entre els exercicis donats, el que millor respon a la pregunta segons el reranker del RAG (llig enunciat, opcions i
// explicació: p. ex. distingix els de b/v dels d'altres consonants de la mateixa activitat). Sense RAG o si el reranker
// falla, `undefined` (es tria sense rànquing); si cap no arriba a la puntuació mínima, `null` (no es mostra cap).
async function mostRelevant(rows: Row[], query: string, mode: ExerciseMode): Promise<Row | null | undefined> {
  if (!query.trim() || !gnvRagEnabled()) return undefined;
  // Un dubte simple només admet un exercici que el reranker avale, encara que n'hi haja un de sol.
  if (rows.length < 2 && mode !== 'simple') return undefined;
  try {
    // Enunciat, resposta correcta i explicació: les opcions falses només fan soroll.
    const candidates = rows.slice(0, 120);
    const texts = candidates.map(r => `${r.prompt} Resposta: ${r.answers[0]}. ${r.explanation ?? ''}`);
    const { scores, reranker } = await puntuarTextos(query, texts);
    const min = minRelevance(reranker, mode);
    const ranked = scores.map((score, i) => ({ score, i })).sort((a, b) => b.score - a.score);
    const top = ranked.slice(0, 3).filter(x => x.score >= min);
    if (top.length === 0) {
      console.log(`[tutor-exercise] rànquing (${reranker}): ${texts.length} exercicis, el millor (${ranked[0].score.toExponential(2)}) no arriba al mínim ${min} (${mode}) → cap`);
      return null;
    }
    // Un dels 3 millors a l'atzar: tots tracten del tema i així no ix sempre el mateix.
    const chosen = top[Math.floor(Math.random() * top.length)];
    console.log(`[tutor-exercise] rànquing (${reranker}): ${texts.length} exercicis, triat=${chosen.score.toExponential(2)} «${texts[chosen.i].slice(0, 70)}»`);
    return candidates[chosen.i];
  } catch (error) {
    console.warn("[tutor-exercise] no s'ha pogut ordenar amb el RAG:", error instanceof Error ? error.message : error);
    return undefined;
  }
}

/**
 * Tria un exercici del catàleg per a què ha explicat el tutor, només del nivell de l'aprenent. Criteris, per ordre:
 *   1. activitats que citen la mateixa secció de la GNV que la regla donada (`gnvSections`);
 *   2. activitats el nom de les quals parla del tema;
 *   3. exercicis l'enunciat o l'explicació dels quals parlen del tema;
 * Si el reranker del RAG no troba cap exercici amb la puntuació mínima, no es mostra cap.
 * `exclude`: els que ja s'han mostrat en esta conversa.
 */
export async function pickTutorExercise(
  topic: string,
  level: string | null | undefined,
  exclude: string[] = [],
  gnvSections: string[] = [],
  // El que ha escrit l'aprenent: amb ell es tria, entre els exercicis del tema, el que en parla de debò.
  question = '',
  mode: ExerciseMode = 'complex',
): Promise<TutorExercise | typeof NO_AT_LEVEL | null> {
  const client = getAdmin() as any;
  if (!client) return null;
  const catalog = await loadCatalog();
  const byId = new Map(catalog.map(r => [r.id, r]));
  const allIds = catalog.map(r => r.id);

  const fromResources = async (resources: CatalogResource[]): Promise<Row[]> => {
    if (resources.length === 0) return [];
    const { data, error } = await client
      .from('practice_exercises')
      .select(EXERCISE_COLUMNS)
      .eq('kind', 'choice')
      .is('passage_id', null)
      .in('resource_id', resources.map(r => r.id))
      .limit(2000);
    if (error) console.warn("[tutor-exercise] no s'han pogut carregar els exercicis:", error.message);
    return usable(data, exclude);
  };

  // `found`: el criteri ha identificat activitats o exercicis del tema (siga quin siga el nivell). El primer que ho
  // aconseguix decidix: si no hi ha exercicis del nivell de l'aprenent, no se'n mostra cap en lloc de
  // baixar a un criteri més fluix (que hi posaria un exercici de qualsevol cosa).
  const viaResources = async (resources: CatalogResource[]) => ({ found: resources.length > 0, rows: await fromResources(resources) });
  // Per seccions de la GNV, el primer grup amb exercicis del nivell de l'aprenent; si cap en té, el primer.
  const viaGnv = async () => {
    let first: { found: boolean; rows: Row[] } | undefined;
    for (const group of gnvCitationGroups(catalog, gnvSections)) {
      const result = await viaResources(group);
      first ??= result;
      if (closestLevel(result.rows, level).length > 0) return result;
    }
    return first ?? { found: false, rows: [] };
  };
  const attempts: [string, () => Promise<{ found: boolean; rows: Row[] }>][] = [
    ['secció GNV', viaGnv],
    ["nom d'activitat", () => viaResources(resourcesNamedLike(catalog, topic))],
    ['text dels exercicis', async () => {
      const wanted = words(topic);
      // Les coincidències de paraules no diuen si l'exercici és de la pregunta: en un dubte simple no valen.
      if (mode === 'simple' || wanted.length === 0) return { found: false, rows: [] };
      const filters = wanted.flatMap(w => [`prompt.ilike.%${w}%`, `explanation.ilike.%${w}%`]).join(',');
      const { data } = await client.from('practice_exercises').select(EXERCISE_COLUMNS)
        .eq('kind', 'choice').is('passage_id', null).in('resource_id', allIds).or(filters).limit(600);
      // Paraules senceres, no trossos d'altres: «grafia» no val per a «fotografia».
      const rows = usable(data, exclude).filter(r => {
        const tokens = words(`${r.prompt} ${r.explanation ?? ''}`);
        return wanted.some(w => tokens.some(t => same(t, w)));
      });
      return { found: rows.length > 0, rows };
    }],
  ];
  let pool: Row[] = [];
  let criterion = '';
  let identified = false;
  for (const [name, load] of attempts) {
    const { found, rows } = await load();
    if (!found) continue;
    identified = true;
    criterion = name;
    pool = rows;
    break;
  }
  if (identified && pool.length === 0) {
    console.log(`[tutor-exercise] criteri=${criterion} tema="${topic}" secció=${gnvSections[0] ?? '-'} → l'activitat no té exercicis que càpiguen en el xat`);
    return null;
  }
  // Sense cap coincidència amb el tema no es mostra res: un exercici «de qualsevol cosa» del nivell seria irrellevant.
  if (pool.length === 0) return null;

  // Dins de l'activitat triada, de preferència els exercicis que parlen del tema.
  const wantedWords = words(topic);
  const onTopicRows = pool.filter(r => {
    const tokens = words(`${r.prompt} ${r.explanation ?? ''}`);
    return wantedWords.some(w => tokens.some(t => same(t, w)));
  });
  // Només el nivell de l'aprenent i, dins d'ell, el que tracta de la pregunta (reranker del RAG);
  // sense RAG, de preferència els que nomenen el tema.
  const levelPool = closestLevel(pool, level);
  // Si el tema no té exercicis del nivell de l'aprenent, no se li'n mostra cap d'un altre.
  if (levelPool.length === 0) {
    console.log(`[tutor-exercise] criteri=${criterion} tema="${topic}" → cap exercici del nivell ${level}`);
    return NO_AT_LEVEL;
  }
  const fallback = closestLevel(onTopicRows.length ? onTopicRows : pool, level);
  if (fallback.length === 0) return null;
  const ranked = await mostRelevant(levelPool, question || topic, mode);
  if (ranked === null) return null;
  // Dubte simple sense reranker (RAG apagat o amb error): no es pot garantir que siga estret, no es mostra res.
  if (ranked === undefined && mode === 'simple') return null;
  const pick = ranked ?? fallback[Math.floor(Math.random() * fallback.length)];
  const resource = byId.get(pick.resource_id);
  console.log(`[tutor-exercise] criteri=${criterion} tema="${topic}" secció=${gnvSections[0] ?? '-'} → ${resource ? label(resource) : pick.resource_id}`);
  return {
    id: pick.id,
    resource_id: pick.resource_id,
    resource_name: resource ? label(resource) : '',
    level: pick.level,
    prompt: pick.prompt,
    options: shuffle(pick.options),
    answer: pick.answers[0],
    explanation: pick.explanation ?? '',
  };
}

// Activitat del catàleg que parla del tema, per a quan hi ha pràctica però no es pot mostrar dins del xat
// (només té huecos, redaccions, formularis o textos): el xat posa un enllaç. Primer per secció de la GNV i
// després pel nom de l'activitat.
export type TutorActivity = { resource_id: string; resource_name: string; type: string; category: string };

export async function findTutorActivity(topic: string, gnvSections: string[] = []): Promise<TutorActivity | null> {
  const catalog = await loadCatalog();
  const [best] = resourcesCitingGnv(catalog, gnvSections).concat(resourcesNamedLike(catalog, topic));
  return best ? { resource_id: best.id, resource_name: label(best), type: best.type, category: best.category } : null;
}

// Botó «Practica-ho» del tutor: després d'un dubte complex no es busca l'exercici (és lent i sovint no es fa), només
// es mira en el catàleg en memòria si hi ha pràctica del tema. L'exercici es busca quan l'aprenent prem el botó.
export type PracticeOffer = { id: string; topic: string; sections: string[] };

export async function hasTutorPractice(topic: string, gnvSections: string[] = []): Promise<boolean> {
  const catalog = await loadCatalog();
  return resourcesCitingGnv(catalog, gnvSections).length > 0 || resourcesNamedLike(catalog, topic).length > 0;
}

/**
 * L'exercici del botó «Practica-ho», com si l'aprenent l'haguera demanat: el del tema (la secció de la GNV primer), o
 * l'activitat per a enllaçar si cap no cap en el xat, o l'avís. Es puntua amb el tema i no amb la pregunta de l'aprenent:
 * per a la mateixa regla, el rànquing del reranker és sempre el mateix i ix de la cache.
 */
export async function practiceForTutor(topic: string, gnvSections: string[], level: string | null | undefined, exclude: string[]):
  Promise<{ exercise: TutorExercise } | { activity: TutorActivity } | { message: string }> {
  const picked = await pickTutorExercise(topic, level, exclude, gnvSections, topic, 'request');
  if (picked === NO_AT_LEVEL) return { message: `${NO_AT_LEVEL_MESSAGE}.` };
  if (picked) return { exercise: picked };
  const activity = await findTutorActivity(topic, gnvSections);
  return activity ? { activity } : { message: NO_EXERCISE_MESSAGE };
}

// Destreses que no es poden practicar dins del xat (redaccions, àudios, textos, conversa): s'enllaça una activitat
// de l'àrea, de preferència del nivell de l'aprenent (i que parle del que ha dit, si hi ha alguna).
// Destreses que es practiquen conversant amb un personatge: les activitats són escenaris, sense exercicis.
export const CHAT_SKILLS = ['expressio_oral', 'escenari'];
// Frases fixes de l'app per a estes destreses: el model no escriu res que puga descriure o proposar un escenari.
export const CHAT_ACTIVITY_MESSAGE = 'Et deixe una activitat per a practicar la conversa.';
export const NO_CHAT_ACTIVITY_MESSAGE = 'Encara no hi ha cap activitat de conversa per al teu nivell.';
export const PRACTICE_SKILLS = ['expressio_escrita', 'comprensio_oral', 'comprensio_escrita', 'expressio_oral', 'escenari'];

export async function findSkillActivity(skill: string, level: string | null | undefined, hint = ''): Promise<TutorActivity | null> {
  const client = getAdmin() as any;
  if (!client || !PRACTICE_SKILLS.includes(skill)) return null;
  const { data, error } = await client
    .from('resources')
    .select('id, name, type, category, difficulty, metadata, practice_exercises(count)')
    .is('teacher_id', null)
    .eq('category', skill)
    .limit(200);
  if (error) {
    console.warn("[tutor-exercise] no s'ha pogut consultar el catàleg:", error.message);
    return null;
  }
  type Res = { id: string; name: string; type: string; category: string; difficulty: string; metadata: { section_name?: string; audience?: string } | null; practice_exercises?: { count: number }[] };
  // L'expressió oral són escenaris sense exercicis; la resta han de tindre'n. Els del Nivell 0 no (són d'infants).
  const rows = ((data ?? []) as Res[]).filter(r => r.difficulty !== 'nivell0' &&
    (CHAT_SKILLS.includes(skill) || (r.practice_exercises?.[0]?.count ?? 0) > 0));
  if (rows.length === 0) return null;
  // Només activitats del nivell de l'aprenent.
  const pool = rows.filter(r => !level || r.difficulty === level);
  if (pool.length === 0) return null;
  const wanted = words(hint);
  const score = (r: Res) => {
    const tokens = words(`${r.name} ${r.metadata?.section_name ?? ''}`);
    return wanted.filter(w => tokens.some(t => same(t, w))).length;
  };
  const best = Math.max(...pool.map(score));
  const candidates = best > 0 ? pool.filter(r => score(r) === best) : pool;
  const pick = candidates[Math.floor(Math.random() * candidates.length)];
  return { resource_id: pick.id, resource_name: (pick.metadata?.section_name || pick.name).replace(/^[d.]+s+/, ''), type: pick.type, category: pick.category };
}
