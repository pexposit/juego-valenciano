import { getAdmin } from '../middleware/auth.js';

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
const words = (text: string) => fold(text).split(/[^a-z0-9]+/).filter(w => w.length >= 4);

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
  const cites = (r: CatalogResource, test: (section: string) => boolean) =>
    (r.sources ?? []).some(src => src.gram === 'GNV' && typeof src.section === 'string' && test(src.section));
  const related = (a: string, b: string) => a.startsWith(`${b}.`) || b.startsWith(`${a}.`);
  for (const section of sections.filter(Boolean)) {
    const exact = catalog.filter(r => cites(r, x => x === section));
    if (exact.length) return exact;
  }
  for (const section of sections.filter(Boolean)) {
    const near = catalog.filter(r => cites(r, x => related(x, section)));
    if (near.length) return near;
  }
  return [];
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

// Només s'ofereixen exercicis del nivell exacte de l'aprenent. Sense nivell conegut, tots valen.
const sameLevel = (exerciseLevel: string, level: string | null | undefined) => !level || exerciseLevel === level;

/**
 * Tria un exercici del catàleg per a què ha explicat el tutor, del nivell de l'aprenent. Criteris, per ordre:
 *   1. activitats que citen la mateixa secció de la GNV que la regla donada (`gnvSections`);
 *   2. activitats el nom de les quals parla del tema;
 *   3. exercicis l'enunciat o l'explicació dels quals parlen del tema;
 *   4. (només si `onlyOnTopic` és fals, és a dir, si l'aprenent ha demanat practicar) qualsevol del seu nivell.
 * `exclude`: els que ja s'han mostrat en esta conversa.
 */
export async function pickTutorExercise(
  topic: string,
  level: string | null | undefined,
  exclude: string[] = [],
  onlyOnTopic = false,
  gnvSections: string[] = [],
): Promise<TutorExercise | null> {
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

  const attempts: [string, () => Promise<Row[]>][] = [
    ['secció GNV', () => fromResources(resourcesCitingGnv(catalog, gnvSections))],
    ["nom d'activitat", () => fromResources(resourcesNamedLike(catalog, topic))],
    ['text dels exercicis', async () => {
      const wanted = words(topic);
      if (wanted.length === 0) return [];
      const filters = wanted.flatMap(w => [`prompt.ilike.%${w}%`, `explanation.ilike.%${w}%`]).join(',');
      const { data } = await client.from('practice_exercises').select(EXERCISE_COLUMNS)
        .eq('kind', 'choice').is('passage_id', null).in('resource_id', allIds).or(filters).limit(600);
      // Paraules senceres, no trossos d'altres: «grafia» no val per a «fotografia».
      return usable(data, exclude).filter(r => {
        const tokens = words(`${r.prompt} ${r.explanation ?? ''}`);
        return wanted.some(w => tokens.some(t => same(t, w)));
      });
    }],
  ];
  let pool: Row[] = [];
  let criterion = '';
  for (const [name, load] of attempts) {
    // Només del nivell de l'aprenent: un exercici de C1 no és per a qui està en l'A2.
    const rows = (await load()).filter(r => sameLevel(r.level, level));
    if (rows.length) { pool = rows; criterion = name; break; }
  }
  if (pool.length === 0) {
    if (onlyOnTopic) return null;
    const { data } = await client.from('practice_exercises').select(EXERCISE_COLUMNS)
      .eq('kind', 'choice').is('passage_id', null).in('resource_id', allIds).eq('level', level ?? 'A2').limit(500);
    pool = usable(data, exclude);
    criterion = 'nivell';
  }
  if (pool.length === 0) return null;

  // Dins de l'activitat triada, de preferència els exercicis que parlen del tema.
  const wantedWords = words(topic);
  const onTopicRows = pool.filter(r => {
    const tokens = words(`${r.prompt} ${r.explanation ?? ''}`);
    return wantedWords.some(w => tokens.some(t => same(t, w)));
  });
  const candidates = onTopicRows.length ? onTopicRows : pool;
  const pick = candidates[Math.floor(Math.random() * candidates.length)];
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
