import { supabase } from '../../lib/supabase';

/**
 * Seguiment del Nivell 0 per a la família i el professorat: cada partida d'una illa i,
 * per a cada paraula preguntada, si ha costat. Amb sessió es guarda en la BD
 * (kids_sessions i kids_word_stats, amb la funció kids_finish_session); en el mode
 * demostració, només en este navegador. Les classes són en la BD (kids_classes).
 */

export type PlayedWord = { id: string; word: string; emoji: string; missed: boolean };

export type SessionReport = {
  island: string;
  stage: number | null; // null: repàs de l'illa ja acabada
  rounds: number;
  firstTry: number; // rondes encertades a la primera
  misses: number;
  easy: boolean;
  seconds: number;
  words: PlayedWord[];
};

export type SessionRow = { island: string; stage: number | null; rounds: number; first_try: number; misses: number; easy: boolean; seconds: number; created_at: string };
export type WordRow = { item_id: string; word: string; emoji: string; island: string; attempts: number; misses: number; last_seen: string };
export type ChildData = { name: string; badges: string[]; sessions: SessionRow[]; words: WordRow[] };

const localKey = (uid: string | undefined) => `parlaval:kids:seguiment:${uid ?? 'demo'}`;
type LocalData = { sessions: SessionRow[]; words: Record<string, WordRow> };

function readLocal(uid: string | undefined): LocalData {
  try {
    return { sessions: [], words: {}, ...JSON.parse(localStorage.getItem(localKey(uid)) ?? '{}') };
  } catch {
    return { sessions: [], words: {} };
  }
}

function saveLocal(uid: string | undefined, report: SessionReport) {
  const data = readLocal(uid);
  const now = new Date().toISOString();
  data.sessions = [{
    island: report.island, stage: report.stage, rounds: report.rounds, first_try: report.firstTry,
    misses: report.misses, easy: report.easy, seconds: report.seconds, created_at: now,
  }, ...data.sessions].slice(0, 200);
  for (const w of report.words) {
    const old = data.words[w.id];
    data.words[w.id] = {
      item_id: w.id, word: w.word, emoji: w.emoji, island: report.island, last_seen: now,
      attempts: (old?.attempts ?? 0) + 1, misses: (old?.misses ?? 0) + (w.missed ? 1 : 0),
    };
  }
  try {
    localStorage.setItem(localKey(uid), JSON.stringify(data));
  } catch {
    // Sense storage: el seguiment d'esta partida es perd.
  }
}

/** Una paraula per element: si en la partida s'ha preguntat més d'una vegada, compta com a fallada si alguna ha costat. */
const uniqueWords = (words: PlayedWord[]) => {
  const byId = new Map<string, PlayedWord>();
  for (const w of words) byId.set(w.id, { ...w, missed: w.missed || !!byId.get(w.id)?.missed });
  return [...byId.values()];
};

/** Guarda una partida acabada. Mai falla cap amunt: el joc continua encara que no es puga guardar. */
export async function saveSessionReport(uid: string | undefined, report: SessionReport) {
  const words = uniqueWords(report.words).slice(0, 80);
  if (!supabase || !uid) return saveLocal(uid, { ...report, words });
  const { error } = await supabase.rpc('kids_finish_session', {
    p_island: report.island, p_stage: report.stage, p_rounds: report.rounds, p_first_try: report.firstTry,
    p_misses: report.misses, p_easy: report.easy, p_seconds: Math.round(report.seconds), p_words: words,
  });
  if (error) console.error('Error guardant el seguiment de la partida:', error);
}

/** Tot el seguiment d'un xiquet: el seu (família) o el d'un alumne (professorat, gràcies a RLS). */
export async function loadChildData(uid: string | undefined): Promise<ChildData> {
  if (!supabase || !uid) {
    const data = readLocal(uid);
    const badges = ['cromos', 'llicons', 'etapes'].flatMap(kind => {
      try {
        const prefix = { cromos: 'cromo:', llicons: 'llico:', etapes: 'etapa:' }[kind];
        return (JSON.parse(localStorage.getItem(`parlaval:kids:${kind}`) ?? '[]') as string[]).map(b => `${prefix}${b}`);
      } catch {
        return [];
      }
    });
    return { name: '', badges, sessions: data.sessions, words: Object.values(data.words) };
  }
  const since = new Date(Date.now() - 90 * 86_400_000).toISOString();
  const [profile, sessions, words] = await Promise.all([
    supabase.from('profiles').select('display_name, badges').eq('id', uid).single(),
    supabase.from('kids_sessions').select('island, stage, rounds, first_try, misses, easy, seconds, created_at')
      .eq('user_id', uid).gte('created_at', since).order('created_at', { ascending: false }).limit(500),
    supabase.from('kids_word_stats').select('item_id, word, emoji, island, attempts, misses, last_seen').eq('user_id', uid),
  ]);
  const error = profile.error ?? sessions.error ?? words.error;
  if (error) throw error;
  return {
    name: profile.data?.display_name ?? '',
    badges: (profile.data?.badges as string[] | undefined) ?? [],
    sessions: (sessions.data ?? []) as SessionRow[],
    words: (words.data ?? []) as WordRow[],
  };
}

/* ── Classes ──────────────────────────────────────────────────────────── */

export type KidsClass = { id: string; name: string; code: string; created_at: string };
export type Student = { id: string; joined_at: string; data: ChildData };

const need = () => {
  if (!supabase) throw new Error('Cal connexió amb el servidor');
  return supabase;
};

/** Les classes de la docent que ha iniciat sessió. */
export async function loadMyClasses(teacher: string): Promise<KidsClass[]> {
  const { data, error } = await need().from('kids_classes').select('id, name, code, created_at').eq('teacher_id', teacher).order('created_at');
  if (error) throw error;
  return data as KidsClass[];
}

export async function createClass(name: string): Promise<KidsClass> {
  const { data, error } = await need().rpc('kids_create_class', { p_name: name });
  if (error) throw error;
  return data as KidsClass;
}

export async function deleteClass(id: string) {
  const { error } = await need().from('kids_classes').delete().eq('id', id);
  if (error) throw error;
}

/** Els alumnes d'una classe, cada un amb el seu seguiment. */
export async function loadStudents(classId: string): Promise<Student[]> {
  const { data, error } = await need().from('kids_class_members').select('student_id, joined_at').eq('class_id', classId).order('joined_at');
  if (error) throw error;
  return Promise.all((data ?? []).map(async m => ({ id: m.student_id as string, joined_at: m.joined_at as string, data: await loadChildData(m.student_id as string) })));
}

export async function removeStudent(classId: string, student: string) {
  const { error } = await need().from('kids_class_members').delete().eq('class_id', classId).eq('student_id', student);
  if (error) throw error;
}

/** Les classes on és el xiquet (per al seguiment de la família). */
export async function loadJoinedClasses(student: string): Promise<{ id: string; name: string }[]> {
  if (!supabase) return [];
  const { data, error } = await supabase.from('kids_class_members').select('class_id, kids_classes(name)').eq('student_id', student);
  if (error) throw error;
  return (data ?? []).map(row => ({ id: row.class_id as string, name: (row.kids_classes as unknown as { name: string } | null)?.name ?? '' }));
}

export async function joinClass(code: string): Promise<{ id: string; name: string }> {
  const { data, error } = await need().rpc('kids_join_class', { p_code: code });
  if (error) throw error;
  const row = (data as { id: string; name: string }[])[0];
  if (!row) throw new Error('No hi ha cap classe amb este codi');
  return row;
}

export const leaveClass = (classId: string, student: string) => removeStudent(classId, student);
