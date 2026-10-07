import {
  TEACHER_ACTIVITY_LIMITS as L,
  type TeacherActivityContent,
  type TeacherActivityInput,
  type TeacherActivityKind,
  type TeacherChoiceQuestion,
  type TeacherFillQuestion,
} from '@parlaval/shared';
import type { Practice, PracticeExercise } from '../../lib/types';

/** Les plantilles que pot omplir la docent, amb el nom que veu. */
export const ACTIVITY_KINDS: { kind: TeacherActivityKind; label: string; hint: string; icon: string }[] = [
  { kind: 'exercises', label: 'Exercicis', hint: "Preguntes d'opció múltiple i d'escriure la resposta, com les de gramàtica, ortografia i lèxic.", icon: '🧩' },
  { kind: 'reading', label: 'Comprensió lectora', hint: 'Un text i preguntes d\'opció múltiple sobre el text.', icon: '📖' },
  { kind: 'writing', label: 'Redacció', hint: 'Un enunciat i un nombre de paraules. La IA la corregix amb la rúbrica de la JQCV.', icon: '✍️' },
  { kind: 'scenario', label: 'Escenari de conversa', hint: 'Un personatge i una situació: la IA fa de personatge i guia l\'alumne pels objectius.', icon: '💬' },
];

export const ICONS = ['📘', '🧩', '📖', '✍️', '💬', '🗣️', '🎯', '🏠', '🛒', '🍽️', '🚆', '🏥', '🏛️', '💼', '🎭', '⚽', '🌳', '🎉', '📰', '💡'];

// Paraules per defecte d'una redacció segons el nivell (les de les proves de la JQCV, aproximades).
const WRITING_WORDS: Record<string, [number, number]> = { A1: [30, 50], A2: [50, 70], B1: [80, 120], B2: [150, 180], C1: [200, 250], C2: [250, 300] };

export const emptyChoice = (): TeacherChoiceQuestion => ({ type: 'choice', prompt: '', options: ['', ''], correct: 0, explanation: '' });
export const emptyFill = (): TeacherFillQuestion => ({ type: 'fill', prompt: '', answers: [''], explanation: '' });

export function emptyContent(kind: TeacherActivityKind, level: TeacherActivityInput['level']): TeacherActivityContent {
  switch (kind) {
    case 'exercises': return { kind, area: 'morfosintaxi', questions: [emptyChoice()] };
    case 'reading': return { kind, text_title: '', text: '', questions: [emptyChoice()] };
    case 'writing': {
      const [min_words, max_words] = WRITING_WORDS[level] ?? WRITING_WORDS.B1;
      return { kind, prompt: '', min_words, max_words };
    }
    case 'scenario': return { kind, character: '', situation: '', greeting: '', objectives: [''], voice: 'gina', background: '/images/classroom.jpg' };
  }
}

export function emptyActivity(kind: TeacherActivityKind): TeacherActivityInput {
  return {
    level: 'B1',
    title: '',
    description: '',
    icon: ACTIVITY_KINDS.find(k => k.kind === kind)?.icon ?? '📘',
    class_ids: [],
    content: emptyContent(kind, 'B1'),
  };
}

/* ── Validació (els mateixos límits que el backend) ───────────────────── */

function questionProblems(q: TeacherChoiceQuestion | TeacherFillQuestion, n: number): string[] {
  const problems: string[] = [];
  if (!q.prompt.trim()) problems.push(`La pregunta ${n} no té enunciat.`);
  if (q.type === 'choice') {
    const options = q.options.map(o => o.trim());
    if (options.some(o => !o)) problems.push(`La pregunta ${n} té alguna opció buida.`);
    if (new Set(options.map(o => o.toLowerCase())).size !== options.length) problems.push(`La pregunta ${n} té opcions repetides.`);
  } else if (!q.answers.some(a => a.trim())) {
    problems.push(`La pregunta ${n} no té cap resposta correcta.`);
  }
  return problems;
}

/** Què falta per a poder guardar l'activitat (buit si està bé). */
export function problemsOf(a: TeacherActivityInput): string[] {
  const problems: string[] = [];
  if (!a.title.trim()) problems.push("Falta el títol de l'activitat.");
  const c = a.content;
  switch (c.kind) {
    case 'exercises':
    case 'reading':
      if (c.kind === 'reading' && !c.text.trim()) problems.push('Falta el text de la lectura.');
      if (!c.questions.length) problems.push('Afig almenys una pregunta.');
      c.questions.forEach((q, i) => problems.push(...questionProblems(q, i + 1)));
      break;
    case 'writing':
      if (!c.prompt.trim()) problems.push("Falta l'enunciat de la redacció.");
      if (!(c.min_words >= L.minWords && c.max_words <= L.maxWords && c.min_words < c.max_words)) {
        problems.push(`El nombre de paraules ha d'anar de ${L.minWords} a ${L.maxWords}, i el mínim ha de ser menor que el màxim.`);
      }
      break;
    case 'scenario':
      if (!c.character.trim()) problems.push('Falta el personatge.');
      if (!c.situation.trim()) problems.push('Falta la situació.');
      if (!c.greeting.trim()) problems.push('Falta la primera frase del personatge.');
      if (!c.objectives.some(o => o.trim())) problems.push('Afig almenys un objectiu.');
      break;
  }
  return problems;
}

/** Lleva les línies buides que el formulari permet tindre a mitges (objectius, respostes...). */
export function cleanActivity(a: TeacherActivityInput): TeacherActivityInput {
  const c = a.content;
  const content: TeacherActivityContent =
    c.kind === 'scenario' ? { ...c, objectives: c.objectives.map(o => o.trim()).filter(Boolean) }
    : c.kind === 'exercises' ? { ...c, questions: c.questions.map(q => (q.type === 'fill' ? { ...q, answers: q.answers.map(x => x.trim()).filter(Boolean) } : q)) }
    : c;
  return { ...a, title: a.title.trim(), description: a.description.trim(), content };
}

/* ── Vista prèvia: la mateixa forma que torna /api/practice/:id ───────── */

const CATEGORY = { reading: 'comprensio_escrita', writing: 'expressio_escrita' } as const;

export function toPracticePreview(a: TeacherActivityInput): Practice | null {
  const c = a.content;
  if (c.kind === 'scenario') return null;
  const level = a.level;
  const passageId = 'preview-text';
  const question = (q: TeacherChoiceQuestion | TeacherFillQuestion, i: number, passage: string | null): PracticeExercise =>
    q.type === 'choice'
      ? { id: `preview-${i}`, level, prompt: q.prompt, explanation: q.explanation || null, passage_id: passage, kind: 'choice', options: q.options, answers: [q.options[q.correct]] }
      : { id: `preview-${i}`, level, prompt: q.prompt, explanation: q.explanation || null, passage_id: passage, kind: 'fill', answers: q.answers.filter(x => x.trim()) };

  const base = { id: 'preview', name: a.title, type: 'preview', content: a.description || null, icon: a.icon, color: null, section_name: a.title };
  switch (c.kind) {
    case 'exercises':
      return { ...base, category: c.area, passages: [], exercises: c.questions.map((q, i) => question(q, i, null)) };
    case 'reading':
      return {
        ...base,
        category: CATEGORY.reading,
        passages: [{
          id: passageId, level, media: 'text', title: c.text_title || null, audio_url: null,
          lines: c.text.split(/\n\s*\n/).map(p => p.trim()).filter(Boolean).map(text => ({ text })),
        }],
        exercises: c.questions.map((q, i) => question(q, i, passageId)),
      };
    case 'writing':
      return {
        ...base,
        category: CATEGORY.writing,
        passages: [],
        exercises: [{ id: 'preview-0', level, prompt: c.prompt, explanation: null, passage_id: null, kind: 'writing', task: { min_words: c.min_words, max_words: c.max_words } }],
      };
  }
}
