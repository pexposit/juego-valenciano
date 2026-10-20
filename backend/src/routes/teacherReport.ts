import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { db } from '../db.js';

export const teacherReportRouter = Router();

/**
 * Activitat de l'alumnat adult d'una classe (pràctiques i exàmens), per a l'informe del professorat: els
 * resultats i els errors es llig només el servidor (cap taula d'ells és visible des del client), així que la
 * docent els demana ací. Cada alumne torna, per activitat, l'última nota i els errors encara sense corregir.
 * Els escenaris no hi són: els objectius es llegixen directament de kids_scenario_reviews.
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

teacherReportRouter.get('/api/teacher/classes/:classId/activity', requireAuth, async (req: AuthRequest, res) => {
  if (!z.string().uuid().safeParse(req.params.classId).success) return res.status(404).json({ error: 'La classe no existix' });
  const client = db(req.userId);
  if (!client || !req.userId) return res.status(401).json({ error: 'Cal iniciar sessió' });

  try {
    // Només la docent d'esta classe.
    const { data: klass, error: classError } = await client
      .from('kids_classes')
      .select('id')
      .eq('id', req.params.classId)
      .eq('teacher_id', req.userId)
      .maybeSingle();
    if (classError) throw classError;
    if (!klass) return res.status(403).json({ error: 'Esta classe no és teua' });

    const { data: members, error: membersError } = await client
      .from('kids_class_members')
      .select('student_id')
      .eq('class_id', req.params.classId);
    if (membersError) throw membersError;
    const students = (members ?? []).map((m: { student_id: string }) => m.student_id);
    if (students.length === 0) return res.json({});

    const [results, errors] = await Promise.all([
      client
        .from('user_resource_results')
        .select('user_id, resource_id, kind, score, total, created_at, resources!inner(name, category, metadata)')
        .in('user_id', students)
        .in('kind', ['practice', 'exam'])
        .order('created_at', { ascending: false })
        .limit(3000),
      client
        .from('user_errors')
        .select('user_id, resource_id')
        .in('user_id', students)
        .eq('resolved', false)
        .not('resource_id', 'is', null)
        .limit(5000),
    ]);
    if (results.error) throw results.error;
    if (errors.error) throw errors.error;

    const pending = new Map<string, number>();
    for (const e of errors.data ?? []) {
      const key = `${e.user_id}|${e.resource_id}`;
      pending.set(key, (pending.get(key) ?? 0) + 1);
    }

    // L'última nota de cada recurs de cada alumne (els resultats venen de més nou a més antic).
    const byStudent: Record<string, ActivityRow[]> = Object.fromEntries(students.map((id: string) => [id, []]));
    const seen = new Set<string>();
    for (const r of results.data ?? []) {
      const key = `${r.user_id}|${r.resource_id}`;
      if (seen.has(key)) continue;
      seen.add(key);
      const meta = (r.resources?.metadata ?? {}) as { section_name?: unknown; icon?: unknown };
      byStudent[r.user_id].push({
        resource_id: r.resource_id,
        name: typeof meta.section_name === 'string' && meta.section_name ? meta.section_name : r.resources?.name ?? '',
        icon: typeof meta.icon === 'string' ? meta.icon : null,
        category: r.resources?.category ?? '',
        kind: r.kind,
        score: r.score,
        total: r.total,
        pending_errors: pending.get(key) ?? 0,
        last_at: r.created_at,
      });
    }
    res.json(byStudent);
  } catch (error) {
    console.error("[teacher-report] Error carregant l'activitat de la classe:", error);
    res.status(500).json({ error: "No hem pogut carregar l'activitat de la classe" });
  }
});

/**
 * Les rutes d'una classe i el progrés de cada alumne en elles: les que la docent ha creat per a la classe (`paths`)
 * i les predefinides dels nivells de la classe (`predefined`), per separat. Per a cada alumne, les activitats que
 * té fetes (amb l'última nota). Una activitat és de l'alumne com a feta si té un resultat
 * posterior a l'últim reinici («Tornar a fer»). El progrés és per activitat, no per ruta: una activitat feta
 * compta en totes les rutes on apareix.
 */
type RouteInfo = { id: string; title: string; description: string; level: string; steps: { resource_id: string; name: string; icon: string | null; category: string }[] };
export type ClassRoutes = {
  paths: RouteInfo[];
  predefined: RouteInfo[];
  progress: Record<string, Record<string, { score: number | null; total: number | null }>>;
};

teacherReportRouter.get('/api/teacher/classes/:classId/routes', requireAuth, async (req: AuthRequest, res) => {
  if (!z.string().uuid().safeParse(req.params.classId).success) return res.status(404).json({ error: 'La classe no existix' });
  const client = db(req.userId);
  if (!client || !req.userId) return res.status(401).json({ error: 'Cal iniciar sessió' });

  try {
    const { data: klass, error: classError } = await client
      .from('kids_classes')
      .select('id, levels')
      .eq('id', req.params.classId)
      .eq('teacher_id', req.userId)
      .maybeSingle();
    if (classError) throw classError;
    if (!klass) return res.status(403).json({ error: 'Esta classe no és teua' });

    const columns = 'id, title, description, level, created_at, sort_order, study_path_steps(position, resource_id)';
    // Les de la docent per a esta classe i les predefinides dels nivells de la classe.
    const [classPaths, predefinedPaths] = await Promise.all([
      client.from('study_paths').select(columns).eq('class_id', req.params.classId).order('created_at'),
      client.from('study_paths').select(columns).is('teacher_id', null).is('class_id', null).in('level', klass.levels as string[]).order('sort_order'),
    ]);
    if (classPaths.error) throw classPaths.error;
    if (predefinedPaths.error) throw predefinedPaths.error;
    type PathRow = { id: string; title: string; description: string; level: string; study_path_steps: { position: number; resource_id: string }[] };
    const rows = (classPaths.data ?? []) as PathRow[];
    const predefinedRows = (predefinedPaths.data ?? []) as PathRow[];
    if (rows.length === 0 && predefinedRows.length === 0) return res.json({ paths: [], predefined: [], progress: {} } satisfies ClassRoutes);

    const resourceIds = [...new Set([...rows, ...predefinedRows].flatMap(p => p.study_path_steps.map(s => s.resource_id)))];
    const { data: members, error: membersError } = await client.from('kids_class_members').select('student_id').eq('class_id', req.params.classId);
    if (membersError) throw membersError;
    const students = (members ?? []).map((m: { student_id: string }) => m.student_id);

    const [resources, results, restarts] = await Promise.all([
      client.from('resources').select('id, name, category, metadata').in('id', resourceIds),
      students.length
        ? client.from('user_resource_results').select('user_id, resource_id, score, total, created_at').in('user_id', students).in('resource_id', resourceIds).order('created_at', { ascending: false }).limit(5000)
        : Promise.resolve({ data: [], error: null }),
      students.length
        ? client.from('activity_restarts').select('user_id, resource_id, restarted_at').in('user_id', students).in('resource_id', resourceIds)
        : Promise.resolve({ data: [], error: null }),
    ]);
    if (resources.error) throw resources.error;
    if (results.error) throw results.error;
    if (restarts.error) throw restarts.error;

    const info = new Map<string, { name: string; icon: string | null; category: string }>();
    for (const r of (resources.data ?? []) as { id: string; name: string; category: string; metadata: { section_name?: unknown; icon?: unknown } | null }[]) {
      const meta = r.metadata ?? {};
      info.set(r.id, {
        name: typeof meta.section_name === 'string' && meta.section_name ? meta.section_name : r.name,
        icon: typeof meta.icon === 'string' ? meta.icon : null,
        category: r.category,
      });
    }

    const restartedAt = new Map<string, number>(
      (restarts.data ?? []).map((r: { user_id: string; resource_id: string; restarted_at: string }) => [`${r.user_id}|${r.resource_id}`, Date.parse(r.restarted_at)]),
    );
    const progress: ClassRoutes['progress'] = Object.fromEntries(students.map((id: string) => [id, {}]));
    for (const r of (results.data ?? []) as { user_id: string; resource_id: string; score: number | null; total: number | null; created_at: string }[]) {
      if (progress[r.user_id][r.resource_id]) continue; // ja hi ha l'última
      if (Date.parse(r.created_at) <= (restartedAt.get(`${r.user_id}|${r.resource_id}`) ?? 0)) continue;
      progress[r.user_id][r.resource_id] = { score: r.score ?? null, total: r.total ?? null };
    }

    const toRoute = (p: PathRow): RouteInfo => ({
      id: p.id,
      title: p.title,
      description: p.description,
      level: p.level,
      steps: [...p.study_path_steps]
        .sort((a, b) => a.position - b.position)
        .map(s => ({ resource_id: s.resource_id, name: info.get(s.resource_id)?.name ?? '', icon: info.get(s.resource_id)?.icon ?? null, category: info.get(s.resource_id)?.category ?? '' })),
    });
    res.json({ paths: rows.map(toRoute), predefined: predefinedRows.map(toRoute), progress } satisfies ClassRoutes);
  } catch (error) {
    console.error("[teacher-report] Error carregant les rutes de la classe:", error);
    res.status(500).json({ error: 'No hem pogut carregar les rutes de la classe' });
  }
});
