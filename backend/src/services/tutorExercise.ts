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
// El tema té exercicis, però tots d'un nivell superior al de l'aprenent.
export const TOO_HIGH = 'too_high' as const;
export const TOO_HIGH_MESSAGE = "És massa prompte per a este tema. Practica primer amb les activitats del teu nivell i de les rutes d'aprenentatge";
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

// Dels exercicis donats, els del nivell de l'aprenent si n'hi ha; si no, els del nivell més pròxim per davall (mai
// d'un nivell superior al seu). Sense nivell conegut, tots valen.
const closestLevel = (rows: Row[], level: string | null | undefined) => {
  const learner = CEFR.indexOf(level ?? '');
  if (learner === -1) return rows;
  const allowed = rows.filter(r => CEFR.indexOf(r.level) <= learner);
  if (allowed.length === 0) return [];
  const distance = (r: Row) => learner - CEFR.indexOf(r.level);
  const best = Math.min(...allowed.map(distance));
  return allowed.filter(r => distance(r) === best);
};

// Puntuació mínima (0 a 1) del reranker perquè un exercici es considere del tema. Per davall, és preferible no mostrar
// cap exercici que un d'irrellevant. Cada reranker té la seua escala; ajustables amb TUTOR_EXERCISE_MIN_SCORE (local) i
// TUTOR_EXERCISE_MIN_SCORE_JEV segons el que mostren els logs de rànquing.
const MIN_RELEVANCE: Record<Reranker, number> = {
  local: Number(process.env.TUTOR_EXERCISE_MIN_SCORE ?? 0.1),
  jev: Number(process.env.TUTOR_EXERCISE_MIN_SCORE_JEV ?? 0.5),
};

// Entre els exercicis donats, el que millor respon a la pregunta segons el reranker del RAG (llig enunciat, opcions i
// explicació: p. ex. distingix els de b/v dels d'altres consonants de la mateixa activitat). Sense RAG o si el reranker
// falla, `undefined` (es tria sense rànquing); si cap no arriba a la puntuació mínima, `null` (no es mostra cap).
async function mostRelevant(rows: Row[], query: string): Promise<Row | null | undefined> {
  if (rows.length < 2 || !query.trim() || !gnvRagEnabled()) return undefined;
  try {
    // Enunciat, resposta correcta i explicació: les opcions falses només fan soroll.
    const candidates = rows.slice(0, 120);
    const texts = candidates.map(r => `${r.prompt} Resposta: ${r.answers[0]}. ${r.explanation ?? ''}`);
    const { scores, reranker } = await puntuarTextos(query, texts);
    const min = MIN_RELEVANCE[reranker];
    const ranked = scores.map((score, i) => ({ score, i })).sort((a, b) => b.score - a.score);
    const top = ranked.slice(0, 3).filter(x => x.score >= min);
    if (top.length === 0) {
      console.log(`[tutor-exercise] rànquing (${reranker}): ${texts.length} exercicis, el millor (${ranked[0].score.toExponential(2)}) no arriba al mínim ${min} → cap`);
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
 * Tria un exercici del catàleg per a què ha explicat el tutor, del nivell de l'aprenent. Criteris, per ordre:
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
): Promise<TutorExercise | typeof TOO_HIGH | null> {
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
  // Per seccions de la GNV, el primer grup amb exercicis que l'aprenent ja pot fer; si cap en té, el primer (massa prompte).
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
      if (wanted.length === 0) return { found: false, rows: [] };
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
  // Primer el nivell (el de l'aprenent o el més pròxim) i, dins d'ell, el que tracta de la pregunta (reranker del RAG);
  // sense RAG, de preferència els que nomenen el tema.
  const levelPool = closestLevel(pool, level);
  // Si tot el que hi ha del tema és d'un nivell superior al de l'aprenent, no se li'n mostra cap.
  if (levelPool.length === 0) {
    console.log(`[tutor-exercise] criteri=${criterion} tema="${topic}" → només hi ha exercicis de nivell superior a ${level}`);
    return TOO_HIGH;
  }
  const fallback = closestLevel(onTopicRows.length ? onTopicRows : pool, level);
  if (fallback.length === 0) return null;
  const ranked = await mostRelevant(levelPool, question || topic);
  if (ranked === null) return null;
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

// Destreses que no es poden practicar dins del xat (redaccions, àudios, textos, conversa): s'enllaça una activitat
// de l'àrea, de preferència del nivell de l'aprenent (i que parle del que ha dit, si hi ha alguna).
// Destreses que es practiquen conversant amb un personatge: les activitats són escenaris, sense exercicis.
const CHAT_SKILLS = ['expressio_oral', 'escenari'];
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
