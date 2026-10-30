import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { db } from '../db.js';
import { buildActivity, buildProgress, resourceInfo, toRoute, type ClassRoutes, type PathRow, type ResultRow } from '../services/progressReport.js';

export type { ActivityRow } from '../services/progressReport.js';

export const teacherReportRouter = Router();

/**
 * Activitat de l'alumnat adult d'una classe (pràctiques i exàmens), per a l'informe del professorat: els
 * resultats i els errors es llig només el servidor (cap taula d'ells és visible des del client), així que la
 * docent els demana ací. Cada alumne torna, per activitat, l'última nota i els errors encara sense corregir.
 * Els escenaris no hi són: els objectius es llegixen directament de kids_scenario_reviews.
 */

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

    res.json(buildActivity(students, (results.data ?? []) as ResultRow[], errors.data ?? []));
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
      client.from('study_paths').select(columns).is('teacher_id', null).is('class_id', null).is('student_id', null).in('level', klass.levels as string[]).order('sort_order'),
    ]);
    if (classPaths.error) throw classPaths.error;
    if (predefinedPaths.error) throw predefinedPaths.error;
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

    const info = resourceInfo((resources.data ?? []) as Parameters<typeof resourceInfo>[0]);
    const progress = buildProgress(students, (results.data ?? []) as Parameters<typeof buildProgress>[1], (restarts.data ?? []) as Parameters<typeof buildProgress>[2]);
    res.json({ paths: rows.map(p => toRoute(p, info)), predefined: predefinedRows.map(p => toRoute(p, info)), progress } satisfies ClassRoutes);
  } catch (error) {
    console.error("[teacher-report] Error carregant les rutes de la classe:", error);
    res.status(500).json({ error: 'No hem pogut carregar les rutes de la classe' });
  }
});
