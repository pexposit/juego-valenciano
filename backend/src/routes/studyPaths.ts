import { Router } from 'express';
import { z } from 'zod';
import { hasPredefinedPaths } from '@parlaval/shared';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { db } from '../db.js';

export const studyPathsRouter = Router();

// L'última nota de cada activitat feta (null si no en té, com un escenari): ix en cada pas de la ruta.
type Grade = { score: number | null; total: number | null };

const toPath = (p: PathRow, done: Map<string, Grade>) => ({
  id: p.id,
  level: p.level,
  title: p.title,
  description: p.description,
  class_name: p.kids_classes?.name ?? null,
  steps: [...p.study_path_steps]
    .sort((a, b) => a.position - b.position)
    .map(s => ({ resource_id: s.resource_id, done: done.has(s.resource_id), score: done.get(s.resource_id)?.score ?? null, total: done.get(s.resource_id)?.total ?? null })),
});

// Activitats que l'usuari ha acabat alguna vegada, cada una amb la seua última nota (els resultats vénen de més nou a més antic).
async function doneResources(client: any, userId: string): Promise<Map<string, Grade>> {
  const [results, restarts] = await Promise.all([
    client
      .from('user_resource_results')
      .select('resource_id, score, total, created_at')
      .eq('user_id', userId)
      .order('created_at', { ascending: false }),
    client.from('activity_restarts').select('resource_id, restarted_at').eq('user_id', userId),
  ]);
  if (results.error) throw results.error;
  if (restarts.error) throw restarts.error;
  // «Tornar a fer»: només compten els resultats posteriors al reinici de l'activitat.
  const restartedAt = new Map<string, number>(
    (restarts.data ?? []).map((r: { resource_id: string; restarted_at: string }) => [r.resource_id, Date.parse(r.restarted_at)]),
  );
  const latest = new Map<string, Grade>();
  for (const r of (results.data ?? []) as { resource_id: string; score: number | null; total: number | null; created_at: string }[]) {
    if (latest.has(r.resource_id)) continue;
    if (Date.parse(r.created_at) <= (restartedAt.get(r.resource_id) ?? 0)) continue;
    latest.set(r.resource_id, { score: r.score ?? null, total: r.total ?? null });
  }
  return latest;
}

type PathRow = {
  id: string;
  level: string;
  title: string;
  description: string;
  class_id: string | null;
  sort_order: number;
  created_at: string;
  kids_classes: { name: string } | null;
  study_path_steps: { position: number; resource_id: string }[];
};

// Rutes recomanades de l'usuari (A2, B1 i B2): les predefinides del seu nivell. Les que el professorat
// crea per a les classes són en /api/my-classes. Cada pas diu si ja l'ha fet (si té algun resultat
// d'eixa activitat): el progrés es calcula ací perquè user_resource_results només el llig el backend.
studyPathsRouter.get('/api/study-paths', requireAuth, async (req: AuthRequest, res) => {
  const client = db(req.userId);
  if (!client || !req.userId) return res.status(401).json({ error: 'Inicia sessió per a vore les rutes' });

  try {
    const { data: profile, error: profileError } = await client.from('profiles').select('level').eq('id', req.userId).single();
    if (profileError) throw profileError;
    if (!hasPredefinedPaths(profile.level)) return res.json({ level: profile.level, paths: [] });

    const [{ data: paths, error: pathsError }, done] = await Promise.all([
      client
        .from('study_paths')
        .select('id, level, title, description, class_id, sort_order, created_at, kids_classes(name), study_path_steps(position, resource_id)')
        .is('teacher_id', null)
        .eq('level', profile.level)
        .order('sort_order'),
      doneResources(client, req.userId),
    ]);
    if (pathsError) throw pathsError;
    res.json({ level: profile.level, paths: (paths as PathRow[]).map(p => toPath(p, done)) });
  } catch (error) {
    console.error('[study-paths] Error carregant les rutes:', error);
    res.status(500).json({ error: 'No hem pogut carregar les rutes' });
  }
});

// Les classes de l'alumne, cadascuna amb el que hi ha posat la docent: les activitats soltes
// (`activities`, amb si ja les ha fetes) i les rutes (`paths`, amb el progrés).
studyPathsRouter.get('/api/my-classes', requireAuth, async (req: AuthRequest, res) => {
  const client = db(req.userId);
  if (!client || !req.userId) return res.json([]);

  try {
    const { data: memberships, error } = await client
      .from('kids_class_members')
      .select('joined_at, kids_classes(id, name, levels, profiles!kids_classes_teacher_id_fkey(display_name))')
      .eq('student_id', req.userId)
      .order('joined_at');
    if (error) throw error;
    type Membership = { kids_classes: { id: string; name: string; levels: string[]; profiles: { display_name: string } | null } | null };
    const classes = (memberships as Membership[]).flatMap(m => (m.kids_classes ? [m.kids_classes] : []));
    if (!classes.length) return res.json([]);
    const classIds = classes.map(c => c.id);

    const [{ data: assigned, error: assignedError }, { data: paths, error: pathsError }, done] = await Promise.all([
      client.from('teacher_activity_classes').select('class_id, resource_id, assigned_at').in('class_id', classIds).order('assigned_at', { ascending: false }),
      client
        .from('study_paths')
        .select('id, level, title, description, class_id, sort_order, created_at, kids_classes(name), study_path_steps(position, resource_id)')
        .in('class_id', classIds)
        .order('created_at', { ascending: false }),
      doneResources(client, req.userId),
    ]);
    if (assignedError) throw assignedError;
    if (pathsError) throw pathsError;

    res.json(classes.map(c => ({
      id: c.id,
      name: c.name,
      levels: c.levels,
      teacher: c.profiles?.display_name || null,
      activities: (assigned ?? [])
        .filter((a: { class_id: string }) => a.class_id === c.id)
        .map((a: { resource_id: string }) => ({ resource_id: a.resource_id, done: done.has(a.resource_id) })),
      paths: (paths as PathRow[]).filter(p => p.class_id === c.id).map(p => toPath(p, done)),
    })));
  } catch (error) {
    console.error('[my-classes] Error carregant les classes:', error);
    res.status(500).json({ error: 'No hem pogut carregar les teues classes' });
  }
});

// L'alumne reinicia una activitat («Tornar a fer»): deixa de comptar com a feta i sense nota fins que es torne a
// corregir. Els resultats anteriors es conserven (historial per a la ruta personalitzada i la docent).
studyPathsRouter.post('/api/activities/:resourceId/restart', requireAuth, async (req: AuthRequest, res) => {
  if (!z.string().uuid().safeParse(req.params.resourceId).success) return res.status(404).json({ error: "L'activitat no existix" });
  const client = db(req.userId);
  if (!client || !req.userId) return res.json({ ok: true, demo: true });
  const restartedAt = new Date().toISOString();
  const { error } = await client
    .from('activity_restarts')
    .upsert({ user_id: req.userId, resource_id: req.params.resourceId, restarted_at: restartedAt });
  if (error) {
    console.error('[restart] Error reiniciant l\'activitat:', error);
    return res.status(500).json({ error: "No s'ha pogut reiniciar l'activitat" });
  }
  // La hora (del servidor) es torna al client: amb ella s'ignoren els errors anteriors al reinici.
  res.json({ ok: true, restarted_at: restartedAt });
});
