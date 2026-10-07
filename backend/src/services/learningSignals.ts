// Dades d'aprenentatge d'un usuari per a generar-li la ruta: el focus de les últimes
// avaluacions pedagògiques dels xats, els errors encara no resolts (per categoria) i els
// resultats dels recursos acabats (pràctica, exàmens i xats). Al servidor no hi ha cap
// text de l'usuari: el resum de les avaluacions i el text dels errors els guarda el client.

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

export async function loadLearningSignals(client: any, userId: string): Promise<LearningSignals> {
  const [evaluations, errors, results] = await Promise.all([
    client
      .from('user_evaluations')
      .select('priority_focus, created_at')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(5),
    // user_errors no té user_id: l'usuari s'obté per session_resource → sessions.
    client
      .from('user_errors')
      .select('category, session_resource!inner(sessions!inner(user_id))')
      .eq('resolved', false)
      .eq('session_resource.sessions.user_id', userId)
      .limit(UNRESOLVED_ERRORS),
    client
      .from('user_resource_results')
      .select('resource_id, kind, score, total, created_at, resources!inner(category)')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(RECENT_RESULTS),
  ]);
  for (const { error } of [evaluations, errors, results]) if (error) throw error;

  const errorCounts = new Map<string, number>();
  for (const { category } of errors.data as { category: string }[]) {
    errorCounts.set(category, (errorCounts.get(category) ?? 0) + 1);
  }

  const recent: ResultSignal[] = (results.data as any[]).map(r => ({
    resource_id: r.resource_id,
    category: r.resources.category,
    kind: r.kind,
    score: r.score === null ? null : Number(r.score),
    total: r.total === null ? null : Number(r.total),
    created_at: r.created_at,
  }));

  // Mitjana d'encerts (0-1) per àrea, només amb els resultats que tenen nota.
  const byArea = new Map<string, { attempts: number; ratios: number[] }>();
  for (const r of recent) {
    const area = byArea.get(r.category) ?? { attempts: 0, ratios: [] };
    area.attempts += 1;
    if (r.score !== null && r.total) area.ratios.push(r.score / r.total);
    byArea.set(r.category, area);
  }
  const areaStats = [...byArea].map(([category, { attempts, ratios }]) => ({
    category,
    attempts,
    average: ratios.length ? Math.round((ratios.reduce((a, b) => a + b, 0) / ratios.length) * 100) / 100 : null,
  }));

  return {
    evaluations: evaluations.data as EvaluationSignal[],
    errorCounts: [...errorCounts].map(([category, count]) => ({ category, count })).sort((a, b) => b.count - a.count),
    areaStats,
    recent,
  };
}
