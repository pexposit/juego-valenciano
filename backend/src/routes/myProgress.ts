import { Router } from 'express';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { db } from '../db.js';
import { buildActivity, buildProgress, resourceInfo, toRoute, type ActivityRow, type ClassRoutes, type PathRow, type ResultRow } from '../services/progressReport.js';

export const myProgressRouter = Router();

/**
 * El progrés de l'alumne adult, per al seu perfil: les mateixes dades que veu la docent (`teacherReport.ts`) però només
 * les de qui fa la petició. Els resultats i els errors es llig només el servidor; la consulta sempre és de `req.userId`
 * (res ve del client). Torna l'última nota de cada pràctica o examen i les rutes (les de les classes on és i les
 * predefinides del seu nivell) amb el seu progrés, en el mateix format que `ClassRoutes` (progrés indexat pel seu id).
 */
export type MyProgress = { activities: ActivityRow[]; routes: ClassRoutes };

myProgressRouter.get('/api/me/progress', requireAuth, async (req: AuthRequest, res) => {
  const client = db(req.userId);
  const uid = req.userId;
  if (!client || !uid) return res.status(401).json({ error: 'Cal iniciar sessió' });

  try {
    const [profile, memberships] = await Promise.all([
      client.from('profiles').select('level').eq('id', uid).maybeSingle(),
      client.from('kids_class_members').select('class_id').eq('student_id', uid),
    ]);
    if (profile.error) throw profile.error;
    if (memberships.error) throw memberships.error;
    const level = (profile.data?.level as string | null | undefined) ?? null;
    const classIds = (memberships.data ?? []).map((m: { class_id: string }) => m.class_id);

    const columns = 'id, title, description, level, created_at, sort_order, study_path_steps(position, resource_id)';
    const [results, errors, classPaths, predefinedPaths] = await Promise.all([
      client
        .from('user_resource_results')
        .select('user_id, resource_id, kind, score, total, created_at, resources!inner(name, category, metadata)')
        .eq('user_id', uid)
        .in('kind', ['practice', 'exam'])
        .order('created_at', { ascending: false })
        .limit(1000),
      client
        .from('user_errors')
        .select('user_id, resource_id')
        .eq('user_id', uid)
        .eq('resolved', false)
        .not('resource_id', 'is', null)
        .limit(2000),
      classIds.length
        ? client.from('study_paths').select(columns).in('class_id', classIds).order('created_at')
        : Promise.resolve({ data: [], error: null }),
      level
        ? client.from('study_paths').select(columns).is('teacher_id', null).is('class_id', null).eq('level', level).order('sort_order')
        : Promise.resolve({ data: [], error: null }),
    ]);
    if (results.error) throw results.error;
    if (errors.error) throw errors.error;
    if (classPaths.error) throw classPaths.error;
    if (predefinedPaths.error) throw predefinedPaths.error;

    const activities = buildActivity([uid], (results.data ?? []) as ResultRow[], errors.data ?? [])[uid] ?? [];
    const rows = (classPaths.data ?? []) as PathRow[];
    const predefinedRows = (predefinedPaths.data ?? []) as PathRow[];
    if (rows.length === 0 && predefinedRows.length === 0) {
      return res.json({ activities, routes: { paths: [], predefined: [], progress: {} } } satisfies MyProgress);
    }

    const resourceIds = [...new Set([...rows, ...predefinedRows].flatMap(p => p.study_path_steps.map(s => s.resource_id)))];
    const [resources, routeResults, restarts] = await Promise.all([
      client.from('resources').select('id, name, category, metadata').in('id', resourceIds),
      client.from('user_resource_results').select('user_id, resource_id, score, total, created_at').eq('user_id', uid).in('resource_id', resourceIds).order('created_at', { ascending: false }).limit(2000),
      client.from('activity_restarts').select('user_id, resource_id, restarted_at').eq('user_id', uid).in('resource_id', resourceIds),
    ]);
    if (resources.error) throw resources.error;
    if (routeResults.error) throw routeResults.error;
    if (restarts.error) throw restarts.error;

    const info = resourceInfo(resources.data ?? []);
    res.json({
      activities,
      routes: {
        paths: rows.map(p => toRoute(p, info)),
        predefined: predefinedRows.map(p => toRoute(p, info)),
        progress: buildProgress([uid], routeResults.data ?? [], restarts.data ?? []),
      },
    } satisfies MyProgress);
  } catch (error) {
    console.error("[my-progress] Error carregant el progrés de l'alumne:", error);
    res.status(500).json({ error: "No hem pogut carregar el teu progrés" });
  }
});
