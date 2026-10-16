import { countWords, normalizeAnswer } from '@parlaval/shared';
import { evaluateA2Writing, evaluateB1Writing, evaluateC1Writing } from './examWritingEvaluator.js';

// Prova de nivell: preguntes tancades del catàleg (morfosintaxi i lèxic de l'A2, el B1, el B2 i el
// C1) i una redacció breu que s'avalua com les de l'Expressió escrita, amb la rúbrica
// del nivell actual de l'usuari. El resultat és només una proposta: l'usuari decidix si canvia
// de nivell (POST /api/profile/level). No es guarda res: ni les respostes ni el text, ni els
// errors de la redacció.

// Nivells amb continguts de llengua al catàleg: per davall de l'A2 la proposta és l'A1, i no
// se'n pot proposar cap per damunt del C1.
export const PLACEMENT_LEVELS = ['A2', 'B1', 'B2', 'C1'] as const;
const AREAS = ['morfosintaxi', 'lexic_semantica'] as const;
// Preguntes de cada àrea per nivell: 10 per nivell, 40 en total.
const PER_AREA: Record<(typeof AREAS)[number], number> = { morfosintaxi: 6, lexic_semantica: 4 };
// Un nivell es dona per superat amb el 75 % d'encerts (8 de 10).
const PASS_RATIO = 0.75;

export const PLACEMENT_WRITING = {
  prompt:
    "Presenta't en un text breu: com et dius, d'on eres i on vius, a què et dediques, per què aprens valencià i què t'agrada fer en el temps lliure.",
  min_words: 30,
  max_words: 200,
};

const ORDER = ['nivell0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
const rank = (level: string) => ORDER.indexOf(level);
const lower = (a: string, b: string) => (rank(a) <= rank(b) ? a : b);
// El nivell de davall (com a molt fins a l'A1: la prova no proposa el Nivell 0).
const below = (level: string) => ORDER[Math.max(rank('A1'), rank(level) - 1)];

// Rúbrica de la redacció per al nivell de l'usuari, com en la pràctica d'Expressió escrita: la de
// l'A2 per a l'A1 i l'A2 (la de l'A1 és per a formularis), i la del B1, la del B2 i la del C1 per a cada un
// (el C2 amb la del C1).
// La nota mínima és la de l'àrea en l'examen (la mitjana sobre 10 de la rúbrica).
const RUBRICS = {
  A2: { pass: 4 },
  B1: { pass: 5 },
  B2: { pass: 4 },
  C1: { pass: 5 },
} as const;
type RubricLevel = keyof typeof RUBRICS;
const rubricFor = (level: string): RubricLevel | null =>
  level === 'nivell0' ? null : rank(level) <= rank('A2') ? 'A2' : level === 'B1' ? 'B1' : level === 'B2' ? 'B2' : 'C1';

function shuffle<T>(items: T[]): T[] {
  const out = [...items];
  for (let i = out.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [out[i], out[j]] = [out[j], out[i]];
  }
  return out;
}

export type PlacementQuestion = { id: string; level: string; prompt: string; options: string[] };

type ExerciseRow = { id: string; resource_id: string; level: string; prompt: string; options: string[] };

// Tria a l'atzar els continguts de cada nivell i àrea (PER_AREA), i una pregunta tancada (sense text de
// suport) de cadascun. Les opcions van barrejades i sense dir quina és la correcta.
export async function buildPlacementTest(client: any): Promise<{ writing: typeof PLACEMENT_WRITING; questions: PlacementQuestion[] }> {
  const { data: resources, error } = await client
    .from('resources')
    .select('id, difficulty, category')
    .in('difficulty', PLACEMENT_LEVELS)
    .in('category', AREAS)
    .is('teacher_id', null);
  if (error) throw error;

  const rows = resources as { id: string; difficulty: string; category: string }[];
  const perLevel = await Promise.all(PLACEMENT_LEVELS.map(async level => {
    const chosen = AREAS.flatMap(area => shuffle(rows.filter(r => r.difficulty === level && r.category === area)).slice(0, PER_AREA[area]));
    if (!chosen.length) return [];
    // Una consulta per nivell: així no s'arriba al límit de files de PostgREST.
    const { data, error: exercisesError } = await client
      .from('practice_exercises')
      .select('id, resource_id, level, prompt, options')
      .in('resource_id', chosen.map(r => r.id))
      .eq('level', level)
      .eq('kind', 'choice')
      .is('passage_id', null);
    if (exercisesError) throw exercisesError;
    const exercises = data as ExerciseRow[];
    return chosen.flatMap(r => {
      const [picked] = shuffle(exercises.filter(e => e.resource_id === r.id));
      return picked ? [{ id: picked.id, level, prompt: picked.prompt, options: shuffle(picked.options) }] : [];
    });
  }));

  return { writing: PLACEMENT_WRITING, questions: perLevel.flat() };
}

export type PlacementResult = {
  suggested: string;
  questions: { level: string; per_level: Record<string, { correct: number; total: number }> };
  // Avaluació de la redacció amb la rúbrica del nivell actual (null si no s'ha avaluat).
  text: { rubric: RubricLevel; mark: number; pass_mark: number; passed: boolean; feedback: string } | null;
  // not_needed: Nivell 0, sense rúbrica de redacció.
  text_status: 'ok' | 'short' | 'unavailable' | 'not_needed';
};

// Corregix les preguntes (la solució es llig de la BDD) i avalua la redacció amb la rúbrica del
// nivell actual. La proposta parteix del nivell de les preguntes (l'últim superat seguit,
// començant per l'A2); si la redacció no arriba al mínim del nivell actual, com a molt és el de
// davall de l'actual.
export async function gradePlacementTest(
  client: any,
  answers: { exercise_id: string; answer: string }[],
  text: string,
  currentLevel: string,
): Promise<PlacementResult> {
  const perLevel: Record<string, { correct: number; total: number }> = Object.fromEntries(PLACEMENT_LEVELS.map(l => [l, { correct: 0, total: 0 }]));

  if (answers.length) {
    const { data, error } = await client
      .from('practice_exercises')
      .select('id, level, answers, resources!inner(category, teacher_id)')
      .in('id', answers.map(a => a.exercise_id))
      .eq('kind', 'choice');
    if (error) throw error;
    type Row = { id: string; level: string; answers: string[]; resources: { category: string; teacher_id: string | null } };
    const byId = new Map((data as Row[])
      .filter(e => (PLACEMENT_LEVELS as readonly string[]).includes(e.level)
        && (AREAS as readonly string[]).includes(e.resources.category) && !e.resources.teacher_id)
      .map(e => [e.id, e]));
    for (const { exercise_id, answer } of answers) {
      const exercise = byId.get(exercise_id);
      if (!exercise) continue;
      perLevel[exercise.level].total += 1;
      if (answer.trim() && normalizeAnswer(answer) === normalizeAnswer(exercise.answers[0])) perLevel[exercise.level].correct += 1;
    }
  }

  let questionsLevel = 'A1';
  for (const level of PLACEMENT_LEVELS) {
    const { correct, total } = perLevel[level];
    if (!total || correct < Math.ceil(total * PASS_RATIO)) break;
    questionsLevel = level;
  }

  // Les preguntes arriben fins al C1: si l'usuari és del C2 i les supera totes, no
  // diuen res en contra del seu nivell.
  if (questionsLevel === 'C1' && rank(currentLevel) > rank('C1')) questionsLevel = currentLevel;

  const rubric = rubricFor(currentLevel);
  let textResult: PlacementResult['text'] = null;
  let textStatus: PlacementResult['text_status'] = rubric ? 'short' : 'not_needed';
  if (rubric && countWords(text) >= PLACEMENT_WRITING.min_words) {
    try {
      textResult = await evaluateWriting(rubric, text.trim());
      textStatus = 'ok';
    } catch (err) {
      console.error("[placement] No s'ha pogut avaluar la redacció:", err instanceof Error ? err.message : err);
      textStatus = 'unavailable';
    }
  }

  return {
    suggested: textResult && !textResult.passed ? lower(questionsLevel, below(currentLevel)) : questionsLevel,
    questions: { level: questionsLevel, per_level: perLevel },
    text: textResult,
    text_status: textStatus,
  };
}

// La redacció de la prova, amb la rúbrica de l'Expressió escrita del nivell (sense paraules
// obligatòries ni llista de continguts: els errors no es guarden).
async function evaluateWriting(rubric: RubricLevel, text: string): Promise<NonNullable<PlacementResult['text']>> {
  const task = { instructions: PLACEMENT_WRITING.prompt, text, minWords: PLACEMENT_WRITING.min_words, maxWords: PLACEMENT_WRITING.max_words };
  const pass_mark = RUBRICS[rubric].pass;
  if (rubric === 'A2') {
    const r = await evaluateA2Writing({ ...task, words: [], minWordsUsed: 0 });
    return { rubric, mark: r.mitjana_ponderada_base_10, pass_mark, passed: r.mitjana_ponderada_base_10 >= pass_mark, feedback: r.comentari_global };
  }
  if (rubric === 'C1') {
    const r = await evaluateC1Writing({ ...task, exerciseN: 7 });
    return { rubric, mark: r.mitjana_base_10, pass_mark, passed: r.mitjana_base_10 >= pass_mark, feedback: r.retorn_pedagogic };
  }
  const r = await evaluateB1Writing({ ...task, level: rubric, exerciseN: 7 });
  return { rubric, mark: r.mitjana_base_10, pass_mark, passed: r.mitjana_base_10 >= pass_mark, feedback: r.retorn_pedagogic };
}
