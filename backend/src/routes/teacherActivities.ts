import { Router, type NextFunction, type Response } from 'express';
import { randomBytes } from 'node:crypto';
import { z } from 'zod';
import { classAcceptsLearner, isLevel0Class, learnerLevelOf, type CefrLevel, type TeacherActivity, type TeacherActivityInput } from '@parlaval/shared';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';
import { practiceRows, resourceFields, teacherActivitySchema } from '../services/teacherActivities.js';

export const teacherActivitiesRouter = Router();

// Només el professorat (profiles.role = 'teacher') gestiona activitats.
async function requireTeacher(req: AuthRequest, res: Response, next: NextFunction) {
  const client = db(req.userId);
  if (!client || !req.userId) return res.status(401).json({ error: 'Cal iniciar sessió' });
  const { data } = await client.from('profiles').select('role').eq('id', req.userId).maybeSingle();
  if (data?.role !== 'teacher') return res.status(403).json({ error: 'Només el professorat pot crear activitats' });
  next();
}

type ActivityRow = {
  id: string;
  difficulty: string;
  content: string | null;
  created_at: string;
  metadata: { icon?: string; section_name?: string; cefr_level?: CefrLevel; teacher_activity?: TeacherActivityInput['content'] } | null;
  teacher_activity_classes: { class_id: string }[];
};

const toActivity = (row: ActivityRow): TeacherActivity => {
  const content = row.metadata!.teacher_activity!;
  return {
    id: row.id,
    created_at: row.created_at,
    level: row.metadata?.cefr_level ?? (row.difficulty === 'principiant' ? 'A2' : 'B1'),
    title: row.metadata?.section_name ?? '',
    // En els escenaris sense descripció, resources.content és la situació.
    description: content.kind === 'scenario' && row.content === content.situation ? '' : row.content ?? '',
    icon: row.metadata?.icon ?? '📘',
    class_ids: row.teacher_activity_classes.map(c => c.class_id),
    content,
  };
};

const SELECT = 'id, difficulty, content, created_at, metadata, teacher_activity_classes(class_id)';

async function loadActivity(client: any, teacherId: string, id: string): Promise<TeacherActivity | null> {
  const { data, error } = await client.from('resources').select(SELECT).eq('id', id).eq('teacher_id', teacherId).maybeSingle();
  if (error) throw error;
  return data ? toActivity(data) : null;
}

// Les classes han de ser de la docent i del nivell de l'activitat. Torna el problema, o null si no n'hi ha.
async function classProblem(client: any, teacherId: string, input: TeacherActivityInput): Promise<string | null> {
  const classIds = [...new Set(input.class_ids)];
  if (!classIds.length) return null;
  const { data, error } = await client.from('kids_classes').select('id, name, levels').eq('teacher_id', teacherId).in('id', classIds);
  if (error) throw error;
  const classes = (data ?? []) as { id: string; name: string; levels: string[] }[];
  if (classes.length !== classIds.length) return 'Alguna classe no és teua';
  const other = classes.find(c => isLevel0Class(c.levels) || !c.levels.includes(input.level));
  return other ? `La classe «${other.name}» no és del nivell de l'activitat (${input.level})` : null;
}

// Torna a escriure els textos, els exercicis i les classes d'una activitat.
async function writeContent(client: any, resourceId: string, input: TeacherActivityInput) {
  for (const table of ['practice_exercises', 'practice_passages', 'teacher_activity_classes']) {
    const { error } = await client.from(table).delete().eq('resource_id', resourceId);
    if (error) throw error;
  }
  const { passage, exercises } = practiceRows(input, resourceId);
  if (passage) {
    const { error } = await client.from('practice_passages').insert(passage);
    if (error) throw error;
  }
  if (exercises.length) {
    const { error } = await client.from('practice_exercises').insert(exercises);
    if (error) throw error;
  }
  const classIds = [...new Set(input.class_ids)];
  if (classIds.length) {
    const { error } = await client.from('teacher_activity_classes').insert(classIds.map(class_id => ({ resource_id: resourceId, class_id })));
    if (error) throw error;
  }
}

const parseInput = (req: AuthRequest, res: Response): TeacherActivityInput | null => {
  const parsed = teacherActivitySchema.safeParse(req.body);
  if (!parsed.success) {
    validationError(res, parsed.error);
    return null;
  }
  return parsed.data as TeacherActivityInput;
};

// Les activitats de la docent, de la més nova a la més antiga.
teacherActivitiesRouter.get('/api/teacher/activities', requireAuth, requireTeacher, async (req: AuthRequest, res) => {
  const client = db(req.userId);
  const { data, error } = await client
    .from('resources')
    .select(SELECT)
    .eq('teacher_id', req.userId)
    .order('created_at', { ascending: false });
  if (error) {
    console.error('[teacher-activities] Error carregant les activitats:', error);
    return res.status(500).json({ error: "No hem pogut carregar les activitats" });
  }
  res.json((data as ActivityRow[]).filter(r => r.metadata?.teacher_activity).map(toActivity));
});

teacherActivitiesRouter.post('/api/teacher/activities', requireAuth, requireTeacher, async (req: AuthRequest, res) => {
  const input = parseInput(req, res);
  if (!input) return;
  const client = db(req.userId);
  let createdId: string | undefined;
  try {
    const problem = await classProblem(client, req.userId!, input);
    if (problem) return res.status(403).json({ error: problem });
    // `type` és la clau de l'activitat (el xat dels escenaris la fa servir en la URL): única i estable.
    const { data, error } = await client
      .from('resources')
      .insert({ ...resourceFields(input, req.userId!), type: `prof_${randomBytes(6).toString('hex')}` })
      .select('id')
      .single();
    if (error) throw error;
    createdId = data.id;
    await writeContent(client, data.id, input);
    res.status(201).json(await loadActivity(client, req.userId!, data.id));
  } catch (error) {
    console.error("[teacher-activities] Error creant l'activitat:", error);
    if (createdId) await client.from('resources').delete().eq('id', createdId);
    res.status(500).json({ error: "No hem pogut crear l'activitat" });
  }
});

teacherActivitiesRouter.put('/api/teacher/activities/:id', requireAuth, requireTeacher, async (req: AuthRequest, res) => {
  if (!z.string().uuid().safeParse(req.params.id).success) return res.status(404).json({ error: "L'activitat no existix" });
  const input = parseInput(req, res);
  if (!input) return;
  const client = db(req.userId);
  const id = req.params.id as string;
  try {
    const current = await loadActivity(client, req.userId!, id);
    if (!current) return res.status(404).json({ error: "L'activitat no existix" });
    const problem = await classProblem(client, req.userId!, input);
    if (problem) return res.status(403).json({ error: problem });
    // Una activitat que ja és en alguna ruta no pot canviar de nivell: la ruta quedaria amb activitats d'un altre.
    if (learnerLevelOf(current.level) !== learnerLevelOf(input.level)) {
      const { count } = await client.from('study_path_steps').select('path_id', { count: 'exact', head: true }).eq('resource_id', id);
      if (count) return res.status(409).json({ error: "No pots canviar el nivell: l'activitat és en alguna ruta" });
    }
    // Les classes que es lleven no poden tindre-la en una ruta: l'alumnat la necessita per a fer-la.
    const removed = current.class_ids.filter(c => !input.class_ids.includes(c));
    if (removed.length) {
      const { data: inPath } = await client
        .from('study_path_steps')
        .select('study_paths!inner(title, class_id)')
        .eq('resource_id', id)
        .in('study_paths.class_id', removed)
        .limit(1);
      if (inPath?.length) {
        return res.status(409).json({ error: `No pots llevar-la d'eixa classe: és en la ruta «${inPath[0].study_paths.title}».` });
      }
    }
    const { error } = await client.from('resources').update(resourceFields(input, req.userId!)).eq('id', id).eq('teacher_id', req.userId);
    if (error) throw error;
    await writeContent(client, id, input);
    res.json(await loadActivity(client, req.userId!, id));
  } catch (error) {
    console.error("[teacher-activities] Error guardant l'activitat:", error);
    res.status(500).json({ error: "No hem pogut guardar l'activitat" });
  }
});

// Esborra l'activitat (i, en cascada, els seus exercicis, les assignacions i els passos de les rutes).
teacherActivitiesRouter.delete('/api/teacher/activities/:id', requireAuth, requireTeacher, async (req: AuthRequest, res) => {
  if (!z.string().uuid().safeParse(req.params.id).success) return res.status(404).json({ error: "L'activitat no existix" });
  const client = db(req.userId);
  const { data, error } = await client.from('resources').delete().eq('id', req.params.id).eq('teacher_id', req.userId).select('id');
  if (error) {
    console.error("[teacher-activities] Error esborrant l'activitat:", error);
    return res.status(500).json({ error: "No hem pogut esborrar l'activitat" });
  }
  if (!data?.length) return res.status(404).json({ error: "L'activitat no existix" });
  res.json({ ok: true });
});

/* ── Activitats soltes d'una classe ───────────────────────────────────── */
// La docent assigna a una classe activitats soltes: seues o del catàleg, d'un dels nivells de la
// classe. L'alumnat les veu en «Activitats», en «De la teua classe».

async function ownClass(client: any, teacherId: string, classId: string): Promise<{ id: string; levels: string[] } | null> {
  if (!z.string().uuid().safeParse(classId).success) return null;
  const { data, error } = await client.from('kids_classes').select('id, levels').eq('id', classId).eq('teacher_id', teacherId).maybeSingle();
  if (error) throw error;
  return data;
}

teacherActivitiesRouter.get('/api/teacher/classes/:classId/activities', requireAuth, requireTeacher, async (req: AuthRequest, res) => {
  const client = db(req.userId);
  try {
    if (!(await ownClass(client, req.userId!, req.params.classId as string))) return res.status(404).json({ error: 'La classe no existix' });
    const { data, error } = await client
      .from('teacher_activity_classes')
      .select('resource_id, assigned_at')
      .eq('class_id', req.params.classId)
      .order('assigned_at', { ascending: false });
    if (error) throw error;
    res.json(data ?? []);
  } catch (error) {
    console.error('[class-activities] Error carregant les activitats:', error);
    res.status(500).json({ error: "No hem pogut carregar les activitats de la classe" });
  }
});

const assignSchema = z.object({ resource_ids: z.array(z.string().uuid()).min(1).max(50) });

teacherActivitiesRouter.post('/api/teacher/classes/:classId/activities', requireAuth, requireTeacher, async (req: AuthRequest, res) => {
  const parsed = assignSchema.safeParse(req.body);
  if (!parsed.success) return validationError(res, parsed.error);
  const client = db(req.userId);
  try {
    const klass = await ownClass(client, req.userId!, req.params.classId as string);
    if (!klass) return res.status(404).json({ error: 'La classe no existix' });
    const ids = [...new Set(parsed.data.resource_ids)];
    if (isLevel0Class(klass.levels)) return res.status(400).json({ error: 'Les classes del Nivell 0 no tenen activitats de la classe' });
    const { data: resources, error } = await client.from('resources').select('id, difficulty, teacher_id, metadata').in('id', ids);
    if (error) throw error;
    // Les de la docent, pel seu nivell del MECR; les del catàleg, si el seu nivell de l'app en cobrix algun de la classe.
    type Row = { difficulty: string; teacher_id: string | null; metadata: { cefr_level?: string } | null };
    const ok = (resources ?? []).filter((r: Row) =>
      (r.teacher_id ? r.teacher_id === req.userId && klass.levels.includes(r.metadata?.cefr_level ?? '')
                    : r.difficulty !== 'nivell0' && classAcceptsLearner(klass.levels, r.difficulty)));
    if (ok.length !== ids.length) return res.status(400).json({ error: 'Les activitats han de ser teues o del catàleg, i dels nivells de la classe' });
    const { error: insertError } = await client
      .from('teacher_activity_classes')
      .upsert(ids.map(resource_id => ({ resource_id, class_id: klass.id })), { onConflict: 'resource_id,class_id', ignoreDuplicates: true });
    if (insertError) throw insertError;
    res.status(201).json({ ok: true });
  } catch (error) {
    console.error('[class-activities] Error assignant:', error);
    res.status(500).json({ error: "No hem pogut assignar les activitats" });
  }
});

teacherActivitiesRouter.delete('/api/teacher/classes/:classId/activities/:resourceId', requireAuth, requireTeacher, async (req: AuthRequest, res) => {
  const client = db(req.userId);
  try {
    const klass = await ownClass(client, req.userId!, req.params.classId as string);
    if (!klass || !z.string().uuid().safeParse(req.params.resourceId).success) return res.status(404).json({ error: 'No existix' });
    // Si és en una ruta de la classe, l'alumnat la necessita per a fer la ruta.
    const { data: inPath } = await client
      .from('study_path_steps')
      .select('study_paths!inner(title, class_id)')
      .eq('resource_id', req.params.resourceId)
      .eq('study_paths.class_id', klass.id)
      .limit(1);
    if (inPath?.length) {
      return res.status(409).json({ error: `No la pots llevar: és en la ruta «${inPath[0].study_paths.title}». Lleva-la primer de la ruta.` });
    }
    const { error } = await client.from('teacher_activity_classes').delete().eq('class_id', klass.id).eq('resource_id', req.params.resourceId);
    if (error) throw error;
    res.json({ ok: true });
  } catch (error) {
    console.error('[class-activities] Error llevant:', error);
    res.status(500).json({ error: "No hem pogut llevar l'activitat" });
  }
});
