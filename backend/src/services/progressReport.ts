/**
 * Lògica pura de l'informe de progrés de l'alumnat adult (sense accés a la base de dades), compartida pel
 * professorat (`routes/teacherReport.ts`, per a tota una classe) i per l'alumne (`routes/myProgress.ts`, el seu).
 */
export type ActivityRow = {
  resource_id: string;
  name: string;
  icon: string | null;
  category: string;
  kind: 'practice' | 'exam';
  score: number | null;
  total: number | null;
  pending_errors: number;
  last_at: string;
};

type ResourceMeta = { section_name?: unknown; icon?: unknown } | null;

/** Resultat d'una pràctica o examen (de més nou a més antic en la consulta). */
export type ResultRow = {
  user_id: string;
  resource_id: string;
  kind: 'practice' | 'exam';
  score: number | null;
  total: number | null;
  created_at: string;
  resources: { name: string; category: string; metadata: ResourceMeta } | null;
};

export type PendingError = { user_id: string; resource_id: string };

const sectionName = (meta: ResourceMeta, fallback: string) =>
  typeof meta?.section_name === 'string' && meta.section_name ? meta.section_name : fallback;

/**
 * Per a cada alumne, l'última nota de cada recurs i els errors encara sense corregir. Els resultats han de vindre de
 * més nou a més antic; els alumnes sense activitat tornen una llista buida.
 */
export function buildActivity(students: string[], results: ResultRow[], errors: PendingError[]): Record<string, ActivityRow[]> {
  const pending = new Map<string, number>();
  for (const e of errors) {
    const key = `${e.user_id}|${e.resource_id}`;
    pending.set(key, (pending.get(key) ?? 0) + 1);
  }
  const byStudent: Record<string, ActivityRow[]> = Object.fromEntries(students.map(id => [id, []]));
  const seen = new Set<string>();
  for (const r of results) {
    const key = `${r.user_id}|${r.resource_id}`;
    if (seen.has(key) || !byStudent[r.user_id]) continue;
    seen.add(key);
    byStudent[r.user_id].push({
      resource_id: r.resource_id,
      name: sectionName(r.resources?.metadata ?? null, r.resources?.name ?? ''),
      icon: typeof r.resources?.metadata?.icon === 'string' ? r.resources.metadata.icon : null,
      category: r.resources?.category ?? '',
      kind: r.kind,
      score: r.score,
      total: r.total,
      pending_errors: pending.get(key) ?? 0,
      last_at: r.created_at,
    });
  }
  return byStudent;
}

export type RouteInfo = { id: string; title: string; description: string; level: string; steps: { resource_id: string; name: string; icon: string | null; category: string }[] };
export type ClassRoutes = {
  paths: RouteInfo[];
  predefined: RouteInfo[];
  progress: Record<string, Record<string, { score: number | null; total: number | null }>>;
};

export type PathRow = { id: string; title: string; description: string; level: string; study_path_steps: { position: number; resource_id: string }[] };
export type ResourceInfo = { name: string; icon: string | null; category: string };

/** El nom, la icona i la categoria de cada recurs de les rutes. */
export function resourceInfo(rows: { id: string; name: string; category: string; metadata: ResourceMeta }[]): Map<string, ResourceInfo> {
  const info = new Map<string, ResourceInfo>();
  for (const r of rows) {
    info.set(r.id, {
      name: sectionName(r.metadata, r.name),
      icon: typeof r.metadata?.icon === 'string' ? r.metadata.icon : null,
      category: r.category,
    });
  }
  return info;
}

export function toRoute(p: PathRow, info: Map<string, ResourceInfo>): RouteInfo {
  return {
    id: p.id,
    title: p.title,
    description: p.description,
    level: p.level,
    steps: [...p.study_path_steps]
      .sort((a, b) => a.position - b.position)
      .map(s => ({ resource_id: s.resource_id, name: info.get(s.resource_id)?.name ?? '', icon: info.get(s.resource_id)?.icon ?? null, category: info.get(s.resource_id)?.category ?? '' })),
  };
}

/**
 * Una activitat compta com a feta si té un resultat posterior a l'últim reinici («Tornar a fer»). Els resultats han
 * de vindre de més nou a més antic: es guarda la nota de l'últim.
 */
export function buildProgress(
  students: string[],
  results: { user_id: string; resource_id: string; score: number | null; total: number | null; created_at: string }[],
  restarts: { user_id: string; resource_id: string; restarted_at: string }[],
): ClassRoutes['progress'] {
  const restartedAt = new Map<string, number>(restarts.map(r => [`${r.user_id}|${r.resource_id}`, Date.parse(r.restarted_at)]));
  const progress: ClassRoutes['progress'] = Object.fromEntries(students.map(id => [id, {}]));
  for (const r of results) {
    if (!progress[r.user_id] || progress[r.user_id][r.resource_id]) continue; // ja hi ha l'última
    if (Date.parse(r.created_at) <= (restartedAt.get(`${r.user_id}|${r.resource_id}`) ?? 0)) continue;
    progress[r.user_id][r.resource_id] = { score: r.score ?? null, total: r.total ?? null };
  }
  return progress;
}
