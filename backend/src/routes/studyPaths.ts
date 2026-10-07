import { Router } from 'express';
import { hasPredefinedPaths } from '@parlaval/shared';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { db } from '../db.js';

export const studyPathsRouter = Router();

const toPath = (p: PathRow, done: Set<string>) => ({
  id: p.id,
  level: p.level,
  title: p.title,
  description: p.description,
  class_name: p.kids_classes?.name ?? null,
  steps: [...p.study_path_steps]
    .sort((a, b) => a.position - b.position)
    .map(s => ({ resource_id: s.resource_id, done: done.has(s.resource_id) })),
});

// Activitats que l'usuari ha acabat alguna vegada.
async function doneResources(client: any, userId: string): Promise<Set<string>> {
  const { data, error } = await client.from('user_resource_results').select('resource_id').eq('user_id', userId);
  if (error) throw error;
  return new Set((data ?? []).map((r: { resource_id: string }) => r.resource_id));
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

// Rutes recomanades de l'usuari (A2 i B1): les predefinides del seu nivell. Les que el professorat
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
