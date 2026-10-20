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

type Row = {
  id: string; level: string; prompt: string; options: string[]; answers: string[]; explanation: string | null; passage_id: string | null;
  resources: { id: string; name: string; metadata: { section_name?: string } | null; teacher_id: string | null; category: string };
};

function shuffle<T>(items: T[]): T[] {
  const out = [...items];
  for (let i = out.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [out[i], out[j]] = [out[j], out[i]];
  }
  return out;
}

/**
 * Tria un exercici del catàleg per al tema que ha demanat el tutor i el nivell de l'aprenent. Prefereix els del
 * seu nivell i els que parlen del tema (en l'enunciat, l'explicació o el nom de l'activitat); si el tema no troba
 * res, en pot tornar un del nivell. `exclude`: els que ja s'han mostrat en esta conversa.
 */
export async function pickTutorExercise(topic: string, level: string | null | undefined, exclude: string[] = []): Promise<TutorExercise | null> {
  const client = getAdmin() as any;
  if (!client) return null;
  const { data, error } = await client
    .from('practice_exercises')
    .select('id, level, prompt, options, answers, explanation, passage_id, resources!inner(id, name, metadata, teacher_id, category)')
    .eq('kind', 'choice')
    .is('passage_id', null)
    .is('resources.teacher_id', null)
    .in('resources.category', ['fonetica_ortografia', 'morfosintaxi', 'lexic_semantica', 'expressio_escrita', 'comprensio_escrita'])
    .limit(1500);
  if (error) {
    console.warn('[tutor-exercise] no s\'ha pogut consultar el catàleg:', error.message);
    return null;
  }

  const rows = ((data ?? []) as Row[]).filter(r =>
    Array.isArray(r.options) && r.options.length >= 2 && r.answers?.length && !exclude.includes(r.id));
  if (rows.length === 0) return null;

  const wanted = words(topic);
  const score = (r: Row) => {
    const haystack = fold(`${r.prompt} ${r.explanation ?? ''} ${r.resources.name} ${r.resources.metadata?.section_name ?? ''}`);
    return wanted.filter(w => haystack.includes(w)).length;
  };
  const sameLevel = rows.filter(r => r.level === level);
  const pool = sameLevel.length ? sameLevel : rows;
  const best = Math.max(...pool.map(score));
  // Sense cap coincidència amb el tema, qualsevol del nivell; amb coincidències, només les millors.
  const candidates = best > 0 ? pool.filter(r => score(r) === best) : pool;
  const pick = candidates[Math.floor(Math.random() * candidates.length)];
  return {
    id: pick.id,
    resource_id: pick.resources.id,
    resource_name: pick.resources.metadata?.section_name || pick.resources.name,
    level: pick.level,
    prompt: pick.prompt,
    options: shuffle(pick.options),
    answer: pick.answers[0],
    explanation: pick.explanation ?? '',
  };
}
