import { CHAT_CATEGORIES, isPracticeArea } from '@parlaval/shared';
import { isScenarioPlayable } from './scenarios.js';

// Quines files del catàleg (taula resources) es poden jugar: les usa el catàleg
// del frontend i el generador de rutes d'aprenentatge.

export type Metadata = Record<string, unknown> | null;
// `practice_exercises` és el recompte embegut ([{ count }]) dels exercicis del recurs.
export type ResourceRow = { category: string; url: string | null; metadata: Metadata; practice_exercises?: { count: number }[] };

export const EXAM_CATEGORY = 'examen';

// Cada categoria té la seua pantalla de joc i decidix si una fila té les dades
// que necessita. Les categories sense pantalla es mostren com a "Pròximament".
const PLAYABLE_BY_CATEGORY: Record<string, (row: ResourceRow) => boolean> = {
  // Xat amb un personatge: els escenaris i les àrees de conversa (Expressió oral).
  ...Object.fromEntries(CHAT_CATEGORIES.map(c => [c, (row: ResourceRow) => isScenarioPlayable(row.metadata)])),
  // Examen interactiu: contingut a metadata.exam i, opcionalment, l'àudio de comprensió oral a `url`.
  [EXAM_CATEGORY]: row => hasExam(row.metadata),
};

export function hasExam(metadata: Metadata) {
  const exam = metadata?.exam as { areas?: unknown } | undefined;
  return Array.isArray(exam?.areas) && exam.areas.length > 0;
}

// Les àrees del temari (PRACTICE_AREAS) comparteixen la pantalla d'exercicis: un
// contingut és jugable si té algun exercici a practice_exercises.
const hasExercises = (row: ResourceRow) => (row.practice_exercises?.[0]?.count ?? 0) > 0;

export const isPlayable = (row: ResourceRow) =>
  isPracticeArea(row.category) ? hasExercises(row) : PLAYABLE_BY_CATEGORY[row.category]?.(row) ?? false;
