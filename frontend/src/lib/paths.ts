import { supabase } from './supabase';

/**
 * Rutes d'aprenentatge predefinides (study_paths). Les crea el professorat; una ruta
 * pública la pot triar qualsevol aprenent del seu públic, i una docent pot assignar
 * les seues (o les públiques) a les seues classes. Els permisos els posa RLS
 * (20261007100000_rutes_docents.sql); ací només hi ha les consultes.
 */

export type PathAudience = 'child' | 'adult';
export type PathItemKind = 'resource' | 'kids_lesson' | 'kids_island';

export type StudyPath = {
  id: string;
  owner_id: string | null;
  title: string;
  description: string;
  audience: PathAudience;
  level: string | null;
  is_public: boolean;
  // Ruta interna d'uns deures amb activitats soltes (o d'un reforç): no es llista com a ruta.
  is_adhoc?: boolean;
  updated_at: string;
};

export type PathItem = { id: string; position: number; kind: PathItemKind; resource_id: string | null; kids_ref: string | null; note: string };
export type PathItemDraft = Omit<PathItem, 'id' | 'position'>;
/**
 * Una ruta assignada a l'aprenent: per una classe (class_name), a ell sol per la docent, o
 * triada per ell mateix (own). Amb due_at són uns deures: compten des de starts_at.
 */
export type MyPath = StudyPath & { assignment_id: string; class_name: string | null; own: boolean; starts_at: string; due_at: string | null };
/** Uns deures posats per la docent: a la classe (class_id) o a un alumne (student_id). */
export type Homework = { id: string; path: StudyPath; class_id: string | null; student_id: string | null; starts_at: string; due_at: string };
/** Progrés d'una assignació: per pas, si s'ha fet i quan (per als deures, des de starts_at). */
export type AssignmentProgress = Map<string, { done: boolean; at: string | null }>;

const PATH_COLUMNS = 'id, owner_id, title, description, audience, level, is_public, is_adhoc, updated_at';

const need = () => {
  if (!supabase) throw new Error('Cal connexió amb el servidor');
  return supabase;
};

/** Si el compte és docent i si pot publicar rutes per a tothom. */
export async function loadTeacher(uid: string): Promise<{ canPublish: boolean } | null> {
  if (!supabase) return null;
  const { data, error } = await supabase.from('teachers').select('can_publish').eq('user_id', uid).maybeSingle();
  if (error) throw error;
  return data ? { canPublish: data.can_publish as boolean } : null;
}

/** Les rutes de la docent i les públiques (per a assignar-les o duplicar-les). */
export async function loadTeacherPaths(uid: string): Promise<{ mine: StudyPath[]; shared: StudyPath[] }> {
  const { data, error } = await need().from('study_paths').select(PATH_COLUMNS).or(`owner_id.eq.${uid},is_public.eq.true`).eq('is_adhoc', false).order('title');
  if (error) throw error;
  const paths = data as StudyPath[];
  return { mine: paths.filter(p => p.owner_id === uid), shared: paths.filter(p => p.owner_id !== uid) };
}

/** Rutes públiques d'un públic (per a triar-ne una). */
export async function loadPublicPaths(audience: PathAudience): Promise<StudyPath[]> {
  if (!supabase) return [];
  const { data, error } = await supabase.from('study_paths').select(PATH_COLUMNS).eq('is_public', true).eq('audience', audience).order('title');
  if (error) throw error;
  return data as StudyPath[];
}

export async function loadPathItems(pathId: string): Promise<PathItem[]> {
  const { data, error } = await need().from('study_path_items').select('id, position, kind, resource_id, kids_ref, note').eq('path_id', pathId).order('position');
  if (error) throw error;
  return data as PathItem[];
}

export async function savePath(path: Omit<StudyPath, 'id' | 'updated_at'> & { id?: string }, items: PathItemDraft[]): Promise<StudyPath> {
  const client = need();
  const { id, ...fields } = path;
  const query = id ? client.from('study_paths').update(fields).eq('id', id) : client.from('study_paths').insert(fields);
  const { data, error } = await query.select(PATH_COLUMNS).single();
  if (error) throw error;
  const saved = data as StudyPath;
  const { error: itemsError } = await client.rpc('save_study_path_items', { p_path: saved.id, p_items: items });
  if (itemsError) throw itemsError;
  return saved;
}

export async function deletePath(id: string) {
  const { error } = await need().from('study_paths').delete().eq('id', id);
  if (error) throw error;
}

/** Les rutes que té l'aprenent: les de les seues classes i les que ha triat. */
export async function loadMyPaths(uid: string): Promise<MyPath[]> {
  if (!supabase) return [];
  const { data: memberships, error: membersError } = await supabase.from('kids_class_members').select('class_id').eq('student_id', uid);
  if (membersError) throw membersError;
  // Les pròpies i les de les classes on és alumne (una docent també veu les de les classes que porta, però no són seues).
  const classIds = (memberships ?? []).map(m => m.class_id as string);
  const { data, error } = await supabase
    .from('study_path_assignments')
    .select(`id, assigned_by, starts_at, due_at, kids_classes(name), study_paths(${PATH_COLUMNS})`)
    .or([`student_id.eq.${uid}`, ...(classIds.length ? [`class_id.in.(${classIds.join(',')})`] : [])].join(','))
    .order('created_at');
  if (error) throw error;
  type Row = { id: string; assigned_by: string | null; starts_at: string; due_at: string | null; kids_classes: { name: string } | null; study_paths: StudyPath | null };
  // Una ruta permanent només una vegada encara que arribe per dues classes; els deures, tots.
  const seen = new Set<string>();
  return (data as unknown as Row[])
    .filter(row => row.study_paths && (row.due_at || (!seen.has(row.study_paths.id) && !!seen.add(row.study_paths.id))))
    .map(row => ({
      ...row.study_paths!,
      assignment_id: row.id,
      class_name: row.kids_classes?.name ?? null,
      own: row.assigned_by === uid,
      starts_at: row.starts_at,
      due_at: row.due_at,
    }));
}

export async function enrollPath(uid: string, pathId: string) {
  const { error } = await need().from('study_path_assignments').insert({ path_id: pathId, student_id: uid, assigned_by: uid });
  if (error && error.code !== '23505') throw error; // ja hi era
}

export async function unenrollPath(assignmentId: string) {
  const { error } = await need().from('study_path_assignments').delete().eq('id', assignmentId);
  if (error) throw error;
}

/** Les rutes assignades a una classe. */
export async function loadClassPaths(classId: string): Promise<(StudyPath & { assignment_id: string })[]> {
  const { data, error } = await need().from('study_path_assignments').select(`id, study_paths(${PATH_COLUMNS})`).eq('class_id', classId).is('due_at', null).order('created_at');
  if (error) throw error;
  type Row = { id: string; study_paths: StudyPath | null };
  return (data as unknown as Row[]).filter(r => r.study_paths).map(r => ({ ...r.study_paths!, assignment_id: r.id }));
}

export async function assignPathToClass(uid: string, pathId: string, classId: string) {
  const { error } = await need().from('study_path_assignments').insert({ path_id: pathId, class_id: classId, assigned_by: uid });
  if (error && error.code !== '23505') throw error;
}

/** Quins passos de la ruta ha fet l'aprenent (item_id → fet). */
export async function loadPathProgress(pathId: string, student: string): Promise<Map<string, boolean>> {
  const { data, error } = await need().rpc('study_path_progress', { p_path: pathId, p_student: student });
  if (error) throw error;
  return new Map((data as { item_id: string; done: boolean }[]).map(r => [r.item_id, r.done]));
}

/** A quines classes de la docent està assignada una ruta: class_id → id de l'assignació. */
export async function loadPathClasses(pathId: string): Promise<Map<string, string>> {
  const { data, error } = await need().from('study_path_assignments').select('id, class_id').eq('path_id', pathId).not('class_id', 'is', null).is('due_at', null);
  if (error) throw error;
  return new Map((data ?? []).map(r => [r.class_id as string, r.id as string]));
}

/* ── Deures ───────────────────────────────────────────────────────────── */

/** Posa una ruta de deures a una classe o a un alumne, de starts_at a due_at. */
export async function createHomework(uid: string, pathId: string, target: { classId: string } | { studentId: string }, startsAt: Date, dueAt: Date) {
  const { error } = await need().from('study_path_assignments').insert({
    path_id: pathId,
    assigned_by: uid,
    class_id: 'classId' in target ? target.classId : null,
    student_id: 'studentId' in target ? target.studentId : null,
    starts_at: startsAt.toISOString(),
    due_at: dueAt.toISOString(),
  });
  if (error) throw error;
}

/** Els deures d'una classe (i els individuals del seu alumnat) que vencen entre from i to. */
export async function loadClassHomework(classId: string, studentIds: string[], from: Date, to: Date): Promise<Homework[]> {
  const targets = [`class_id.eq.${classId}`, ...(studentIds.length ? [`student_id.in.(${studentIds.join(',')})`] : [])].join(',');
  const { data, error } = await need()
    .from('study_path_assignments')
    .select(`id, class_id, student_id, starts_at, due_at, study_paths(${PATH_COLUMNS})`)
    .or(targets)
    .gte('due_at', from.toISOString())
    .lt('due_at', to.toISOString())
    .order('due_at');
  if (error) throw error;
  type Row = Omit<Homework, 'path'> & { study_paths: StudyPath | null };
  return (data as unknown as Row[]).filter(r => r.study_paths).map(({ study_paths, ...r }) => ({ ...r, path: study_paths! }));
}

export async function loadAssignmentProgress(assignmentId: string, student: string): Promise<AssignmentProgress> {
  const { data, error } = await need().rpc('study_assignment_progress', { p_assignment: assignmentId, p_student: student });
  if (error) throw error;
  return new Map((data as { item_id: string; done: boolean; done_at: string | null }[]).map(r => [r.item_id, { done: r.done, at: r.done_at }]));
}

/** Dilluns 00:00 de la setmana de `date` (hora local). */
export function weekStart(date = new Date()): Date {
  const d = new Date(date);
  d.setHours(0, 0, 0, 0);
  d.setDate(d.getDate() - ((d.getDay() + 6) % 7));
  return d;
}

export const addDays = (date: Date, days: number) => {
  const d = new Date(date);
  d.setDate(d.getDate() + days);
  return d;
};

/** Diumenge 23:59 de la setmana de `date`: el termini per defecte dels deures. */
export const weekEnd = (date = new Date()) => new Date(addDays(weekStart(date), 7).getTime() - 60_000);

/** Canvia el termini d'uns deures (no pot ser passat: ho comprova també la BD). */
export async function updateHomeworkDue(id: string, dueAt: Date) {
  const { error } = await need().from('study_path_assignments').update({ due_at: dueAt.toISOString() }).eq('id', id);
  if (error) throw error;
}

/** Un intent d'un pas: una partida, una lliçó acabada, un resultat o una conversa. */
export type WorkRow = {
  item_id: string;
  source: 'island' | 'lesson' | 'result' | 'conversation' | 'error';
  at: string;
  score: number | null;
  total: number | null;
  extra: Record<string, unknown>;
};

/** Tot el que ha fet l'aprenent en una assignació (per als deures, des que es van posar). */
export async function loadAssignmentWork(assignmentId: string, student: string): Promise<WorkRow[]> {
  const { data, error } = await need().rpc('study_assignment_work', { p_assignment: assignmentId, p_student: student });
  if (error) throw error;
  return data as WorkRow[];
}
