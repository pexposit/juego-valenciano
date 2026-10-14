// Dades d'aprenentatge d'un usuari per a generar-li la ruta: el focus de les últimes
// avaluacions pedagògiques dels xats, els errors encara no resolts (per categoria) i els
// resultats dels recursos acabats (pràctica, exàmens i xats). Al servidor no hi ha cap
// text de l'usuari: el resum de les avaluacions i el text dels errors els guarda el client.

import { errorCategoriesOf, type ErrorRow } from './errorCategories.js';

export type EvaluationSignal = { priority_focus: string; created_at: string };
export type ResultSignal = { resource_id: string; category: string; kind: string; score: number | null; total: number | null; created_at: string };
export type AreaStat = { category: string; attempts: number; average: number | null };

export type LearningSignals = {
  evaluations: EvaluationSignal[];
  errorCounts: { category: string; count: number }[];
  areaStats: AreaStat[];
  recent: ResultSignal[];
};

const RECENT_RESULTS = 40;
const UNRESOLVED_ERRORS = 200;
// Intents amb nota que compten de cada activitat (els més recents): l'activitat val la mitjana
// d'estos, perquè compte com ha anat les últimes vegades i no només l'última.
const LAST_ATTEMPTS = 2;

// Una mateixa activitat pot guardar resultats de parts diferents: cada àrea d'un examen
// (details.area) i cada redacció avaluada d'una pràctica (details.exercise_id) van a banda.
const activityKey = (r: { resource_id: string; details?: Record<string, unknown> | null }) =>
  [r.resource_id, r.details?.area ?? '', r.details?.exercise_id ?? ''].join('|');

export async function loadLearningSignals(client: any, userId: string): Promise<LearningSignals> {
  const [evaluations, errors, results] = await Promise.all([
    client
      .from('user_evaluations')
      .select('priority_focus, created_at')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(5),
    // Errors pendents de tots els orígens (xats, pràctica i redaccions), els més recents.
    client
      .from('user_errors')
      .select('source, category, resources(category, type)')
      .eq('user_id', userId)
      .eq('resolved', false)
      .order('created_at', { ascending: false })
      .limit(UNRESOLVED_ERRORS),
    client
      .from('user_resource_results')
      .select('resource_id, kind, score, total, details, created_at, resources!inner(category)')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(RECENT_RESULTS),
  ]);
  for (const { error } of [evaluations, errors, results]) if (error) throw error;

  // Per la categoria principal, comuna a tots els orígens (errorCategoriesOf). Els que no
  // en tenen (preguntes de comprensió) no hi compten: ja es veuen en la nota de l'àrea.
  const errorCounts = new Map<string, number>();
  for (const error of errors.data as ErrorRow[]) {
    const [category] = errorCategoriesOf(error);
    if (category) errorCounts.set(category, (errorCounts.get(category) ?? 0) + 1);
  }

  const recent: ResultSignal[] = (results.data as any[]).map(r => ({
    resource_id: r.resource_id,
    category: r.resources.category,
    kind: r.kind,
    score: r.score === null ? null : Number(r.score),
    total: r.total === null ? null : Number(r.total),
    created_at: r.created_at,
  }));

  // Mitjana d'encerts (0-1) per àrea: cada activitat hi compta una vegada, amb la mitjana
  // dels seus LAST_ATTEMPTS últims intents amb nota (els resultats venen del més nou al més antic).
  // Així els intents repetits no hi compten més d'una vegada: només compta com ha acabat.
  const byArea = new Map<string, { attempts: number; ratios: number[] }>();
  const lastRatios = new Map<string, { category: string; ratios: number[] }>();
  (results.data as any[]).forEach((row, i) => {
    const r = recent[i];
    const area = byArea.get(r.category) ?? { attempts: 0, ratios: [] };
    area.attempts += 1;
    byArea.set(r.category, area);
    if (r.score === null || !r.total) return;
    const key = activityKey(row);
    const activity = lastRatios.get(key) ?? { category: r.category, ratios: [] };
    if (activity.ratios.length < LAST_ATTEMPTS) activity.ratios.push(r.score / r.total);
    lastRatios.set(key, activity);
  });
  const mean = (xs: number[]) => xs.reduce((a, b) => a + b, 0) / xs.length;
  for (const { category, ratios } of lastRatios.values()) byArea.get(category)!.ratios.push(mean(ratios));
  const areaStats = [...byArea].map(([category, { attempts, ratios }]) => ({
    category,
    attempts,
    average: ratios.length ? Math.round(mean(ratios) * 100) / 100 : null,
  }));

  return {
    evaluations: evaluations.data as EvaluationSignal[],
    errorCounts: [...errorCounts].map(([category, count]) => ({ category, count })).sort((a, b) => b.count - a.count),
    areaStats,
    recent,
  };
}
