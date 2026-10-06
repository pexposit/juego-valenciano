import { useEffect, useMemo, useState } from 'react';
import { ArrowDown, ArrowUp, ChevronLeft, ChevronRight, Pencil, Plus, Send, X } from 'lucide-react';
import {
  addDays, createHomework, deletePath, loadPathItems, updateHomeworkDue, loadClassHomework, savePath, unenrollPath, weekEnd, weekStart, type Homework, type PathItemDraft, type StudyPath,
} from '../../lib/paths';
import type { Resource } from '../../lib/types';
import { summarize } from '../kids/report';
import type { ChildData } from '../kids/tracking';
import { itemKey, resolveItem } from './catalog';
import { CatalogPicker } from './CatalogPicker';
import { countDone, loadAssignmentState, PathSteps, useAssignmentState, type PathState } from './PathSteps';

type Student = { id: string; data: ChildData };

const DAY = 86_400_000;
const shortDate = (d: Date | string) => new Date(d).toLocaleDateString('ca-ES', { day: 'numeric', month: 'short' });
const weekLabel = (start: Date) => `Setmana del ${shortDate(start)} al ${shortDate(addDays(start, 6))}`;
const inWeek = (date: string, start: Date) => {
  const t = Date.parse(date);
  return t >= start.getTime() && t < start.getTime() + 7 * DAY;
};
const forStudent = (hw: Homework, student: string) => hw.class_id !== null || hw.student_id === student;

/** Estat d'uns deures per a un alumne: fets, fets fora de termini, a mitges o sense començar. */
export function homeworkStatus(hw: Homework, state: PathState) {
  const total = state.items.length;
  const done = countDone(state);
  const late = state.items.some(i => {
    const at = state.at?.get(i.id);
    return at && Date.parse(at) > Date.parse(hw.due_at);
  });
  const overdue = Date.now() > Date.parse(hw.due_at);
  if (total && done === total) return { done, total, tone: late ? 'late' : 'ok', label: late ? 'Fets fora de termini' : 'Fets' } as const;
  return { done, total, tone: overdue ? 'missing' : done ? 'partial' : 'todo', label: overdue ? 'No acabats' : done ? 'A mitges' : 'Sense començar' } as const;
}

const TONE: Record<string, string> = {
  ok: 'bg-teal text-white',
  late: 'bg-mustard text-ink',
  partial: 'bg-cream text-ink',
  todo: 'bg-gray-100 text-gray-500',
  missing: 'bg-coral/20 text-coral',
};

/** El que ha fet l'alumne per compte propi en la setmana: illes, lliçons, converses i minuts. */
function weekActivity(data: ChildData, start: Date) {
  const sessions = data.sessions.filter(s => inWeek(s.created_at, start));
  return {
    games: sessions.length,
    minutes: Math.round(sessions.reduce((sum, s) => sum + s.seconds, 0) / 60),
    lessons: (data.lessons ?? []).filter(l => inWeek(l.created_at, start)).length,
    chats: data.conversations.filter(c => inWeek(c.created_at, start)).length,
    days: new Set(sessions.map(s => s.created_at.slice(0, 10))).size,
  };
}

/**
 * Els deures setmanals d'una classe. La docent tria la setmana, posa deures (una ruta,
 * a tota la classe o a un alumne, amb termini) i veu, per a cada alumne, com els porta i
 * què ha fet pel seu compte eixa setmana.
 */
export function ClassHomework({ uid, classId, students, paths, resources }: { uid: string; classId: string; students: Student[]; paths: StudyPath[]; resources: Resource[] }) {
  const [week, setWeek] = useState(() => weekStart());
  const [homework, setHomework] = useState<Homework[]>();
  // `${homework}:${student}` → estat.
  const [states, setStates] = useState<Record<string, PathState | null>>({});
  const [adding, setAdding] = useState(false);
  const [editing, setEditing] = useState<Homework>();
  const [error, setError] = useState<string>();
  const studentIds = students.map(s => s.id).join(',');

  const reload = () => {
    setHomework(undefined);
    loadClassHomework(classId, students.map(s => s.id), week, addDays(week, 7))
      .then(setHomework)
      .catch(e => {
        console.error(e);
        setError("No s'han pogut carregar els deures.");
        setHomework([]);
      });
  };

  useEffect(reload, [classId, week, studentIds]); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    if (!homework) return;
    let cancelled = false;
    setStates({});
    for (const hw of homework) {
      for (const s of students.filter(st => forStudent(hw, st.id))) {
        loadAssignmentState(hw.id, hw.path.id, s.id)
          .then(state => { if (!cancelled) setStates(old => ({ ...old, [`${hw.id}:${s.id}`]: state })); })
          .catch(() => { if (!cancelled) setStates(old => ({ ...old, [`${hw.id}:${s.id}`]: null })); });
      }
    }
    return () => { cancelled = true; };
  }, [homework]); // eslint-disable-line react-hooks/exhaustive-deps

  const remove = async (hw: Homework) => {
    if (!confirm(`Vols esborrar els deures «${hw.path.title}»? L'alumnat no perd el que ha fet.`)) return;
    // Unes activitats soltes (ruta interna) no serveixen per a res més: s'esborra la ruta sencera.
    await (hw.path.is_adhoc ? deletePath(hw.path.id) : unenrollPath(hw.id)).catch(console.error);
    reload();
  };

  const nameOf = (id: string | null) => students.find(s => s.id === id)?.data.name || 'un alumne';
  const thisWeek = weekStart().getTime() === week.getTime();
  // Les setmanes passades només es consulten: no s'hi poden posar deures.
  const pastWeek = week.getTime() < weekStart().getTime();

  return (
    <section className="mt-5 rounded-3xl bg-white p-5 shadow-sm">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h3 className="text-2xl font-black">Deures de la setmana</h3>
        <div className="flex items-center gap-1">
          <button onClick={() => setWeek(w => addDays(w, -7))} aria-label="Setmana anterior" className="btn-press rounded-full p-2 hover:bg-gray-100"><ChevronLeft size={20} /></button>
          <span className="min-w-[14rem] text-center font-bold">{thisWeek ? 'Esta setmana' : weekLabel(week)}</span>
          <button onClick={() => setWeek(w => addDays(w, 7))} aria-label="Setmana següent" className="btn-press rounded-full p-2 hover:bg-gray-100"><ChevronRight size={20} /></button>
        </div>
      </div>
      {thisWeek && <p className="text-sm opacity-60">{weekLabel(week)}</p>}
      {error && <p className="mt-2 text-coral">{error}</p>}

      <div className="mt-4 overflow-x-auto">
        <table className="w-full min-w-[560px] text-left">
          <thead>
            <tr className="align-bottom text-sm">
              <th className="py-2 font-extrabold uppercase tracking-wide opacity-50">Alumne</th>
              {homework?.map(hw => (
                <th key={hw.id} className="px-2 py-2">
                  <span className="flex items-start gap-1">
                    <span>
                      <span className="block font-black">{hw.path.title}</span>
                      <span className="block text-xs font-bold opacity-60">
                        fins al {shortDate(hw.due_at)}{hw.student_id ? ` · només ${nameOf(hw.student_id)}` : ''}
                      </span>
                    </span>
                    <button onClick={() => { setAdding(false); setEditing(hw); }} aria-label={`Edita els deures ${hw.path.title}`} className="btn-press text-gray-300 hover:text-[#0F47AF]"><Pencil size={15} /></button>
                    <button onClick={() => void remove(hw)} aria-label={`Esborra els deures ${hw.path.title}`} className="btn-press text-gray-300 hover:text-coral"><X size={16} /></button>
                  </span>
                </th>
              ))}
              <th className="px-2 py-2 font-extrabold uppercase tracking-wide opacity-50" title="Partides d'illes, lliçons i converses de la setmana, dins i fora dels deures">
                Activitat de la setmana
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {students.map(s => {
              const free = s.data.ageGroup === 'adult' ? null : weekActivity(s.data, week);
              return (
                <tr key={s.id}>
                  <td className="py-3 font-extrabold">{s.data.name || 'Sense nom'}</td>
                  {homework?.map(hw => {
                    if (!forStudent(hw, s.id)) return <td key={hw.id} className="px-2 opacity-30">—</td>;
                    const state = states[`${hw.id}:${s.id}`];
                    if (!state) return <td key={hw.id} className="px-2 opacity-40">{state === null ? '—' : '…'}</td>;
                    const st = homeworkStatus(hw, state);
                    return (
                      <td key={hw.id} className="px-2">
                        <span className={`inline-block rounded-full px-3 py-1 text-sm font-black ${TONE[st.tone]}`} title={st.label}>
                          {st.done}/{st.total} · {st.label}
                        </span>
                      </td>
                    );
                  })}
                  <td className="px-2 text-sm">
                    {!free ? '—' : free.games + free.lessons + free.chats === 0 ? <span className="opacity-50">Res</span> : (
                      <span title={`${free.days} dies`}>
                        🏝️ {free.games} · 📖 {free.lessons} · 💬 {free.chats} · {free.minutes} min
                      </span>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
      {homework?.length === 0 && <p className="mt-2 text-lg opacity-70">No hi ha deures que vencen esta setmana.</p>}

      {editing ? (
        <HomeworkForm
          key={editing.id}
          uid={uid}
          classId={classId}
          students={students}
          paths={paths}
          resources={resources}
          week={week}
          editing={editing}
          onDone={() => { setEditing(undefined); reload(); }}
          onCancel={() => setEditing(undefined)}
        />
      ) : pastWeek ? (
        <p className="mt-4 text-base opacity-60">És una setmana passada: no s'hi poden posar deures nous (sí allargar el termini dels que hi ha, amb el llapis).</p>
      ) : adding ? (
        <HomeworkForm
          uid={uid}
          classId={classId}
          students={students}
          paths={paths}
          resources={resources}
          week={week}
          onDone={() => { setAdding(false); reload(); }}
          onCancel={() => setAdding(false)}
        />
      ) : (
        <button onClick={() => setAdding(true)} className="btn-press mt-4 flex items-center gap-2 rounded-2xl bg-[#0F47AF] px-5 py-2 text-lg font-extrabold text-white">
          <Plus size={20} /> Posa deures
        </button>
      )}
    </section>
  );
}

const toDateInput = (d: Date) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;

/** Títol dels deures amb activitats soltes: les dues primeres i quantes més. */
const looseTitle = (titles: string[]) =>
  (titles.length <= 2 ? titles.join(' i ') : `${titles.slice(0, 2).join(', ')} i ${titles.length - 2} més`).slice(0, 80);

/**
 * Posar deures o editar-ne uns (`editing`). En editar, el destinatari no canvia; d'uns deures
 * solts es poden canviar les activitats, i d'una ruta només el termini (les activitats de la
 * ruta s'editen en la ruta, perquè canviarien per a totes les classes on està).
 */
function HomeworkForm({ uid, classId, students, paths, resources, week, editing, onDone, onCancel }: {
  uid: string;
  classId: string;
  students: Student[];
  paths: StudyPath[];
  resources: Resource[];
  week: Date;
  editing?: Homework;
  onDone: () => void;
  onCancel: () => void;
}) {
  const [mode, setMode] = useState<'loose' | 'path'>(editing && !editing.path.is_adhoc ? 'path' : 'loose');
  const [pathId, setPathId] = useState(editing?.path.id ?? '');
  const [items, setItems] = useState<PathItemDraft[]>([]);
  const [target, setTarget] = useState(editing?.student_id ?? 'class');
  // No es poden posar deures per a dies passats: el termini és com a prompte hui.
  const today = toDateInput(new Date());
  const initialDue = editing ? toDateInput(new Date(editing.due_at)) : toDateInput(weekEnd(week));
  const [due, setDue] = useState(initialDue < today ? today : initialDue);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string>();
  // El catàleg de lliçons i illes només té sentit si a la classe hi ha xiquets.
  const audience = students.length && students.every(s => s.data.ageGroup === 'adult') ? 'adult' : 'child';
  const byId = useMemo(() => new Map(resources.map(r => [r.id, r])), [resources]);

  useEffect(() => {
    if (!editing?.path.is_adhoc) return;
    loadPathItems(editing.path.id)
      .then(list => setItems(list.map(({ kind, resource_id, kids_ref, note }) => ({ kind, resource_id, kids_ref, note }))))
      .catch(e => {
        console.error(e);
        setError("No s'han pogut carregar les activitats.");
      });
  }, [editing]);

  const move = (i: number, delta: number) => setItems(list => {
    const copy = [...list];
    [copy[i], copy[i + delta]] = [copy[i + delta], copy[i]];
    return copy;
  });

  const save = async () => {
    // Comencen ara (o el dilluns, si és una setmana futura) i acaben a les 23:59 del dia triat.
    const starts = new Date(Math.max(Date.now(), week.getTime()));
    const dueAt = new Date(`${due}T23:59:00`);
    if (due < today || dueAt.getTime() <= Date.now() || (!editing && dueAt <= starts)) return setError('El termini no pot ser un dia passat.');
    setSaving(true);
    try {
      if (editing) {
        if (editing.path.is_adhoc) {
          await savePath({
            ...editing.path,
            title: looseTitle(items.map(i => resolveItem(i, byId).title)),
          }, items);
        }
        if (due !== toDateInput(new Date(editing.due_at))) await updateHomeworkDue(editing.id, dueAt);
        return onDone();
      }
      let id = pathId;
      if (mode === 'loose') {
        // Les activitats soltes es guarden com una ruta interna, que no apareix en la llista de rutes.
        const path = await savePath({
          owner_id: uid,
          title: looseTitle(items.map(i => resolveItem(i, byId).title)),
          description: '',
          audience,
          level: null,
          is_public: false,
          is_adhoc: true,
        }, items);
        id = path.id;
      }
      await createHomework(uid, id, target === 'class' ? { classId } : { studentId: target }, starts, dueAt);
      onDone();
    } catch (e) {
      console.error(e);
      setError(editing ? "No s'han pogut guardar els canvis." : "No s'han pogut posar els deures.");
      setSaving(false);
    }
  };

  const field = 'w-full rounded-2xl border-2 border-gray-100 p-3 text-lg outline-none focus:border-[#0F47AF]';
  const tab = (m: 'loose' | 'path') => `btn-press rounded-full px-4 py-1.5 font-black ${mode === m ? 'bg-[#0F47AF] text-white' : 'bg-white text-[#0F47AF]'}`;
  const ready = mode === 'loose' ? items.length > 0 : !!pathId;

  return (
    <div className="mt-4 grid gap-3 rounded-2xl bg-cream/60 p-4 sm:grid-cols-3">
      {editing ? (
        <p className="text-xl font-black sm:col-span-3">Edita «{editing.path.title}»</p>
      ) : (
      <div className="flex gap-2 sm:col-span-3" role="tablist">
        <button role="tab" aria-selected={mode === 'loose'} onClick={() => setMode('loose')} className={tab('loose')}>Activitats soltes</button>
        <button role="tab" aria-selected={mode === 'path'} onClick={() => setMode('path')} className={tab('path')}>Una ruta</button>
      </div>
      )}

      {editing && mode === 'path' ? (
        <p className="opacity-70 sm:col-span-3">
          Són deures d'una ruta: ací pots canviar el termini. Les activitats es canvien editant la ruta (pestanya «Rutes»), i el canvi val per a totes les classes on està.
        </p>
      ) : mode === 'path' ? (
        <label className="sm:col-span-3">
          <span className="block font-extrabold">Ruta</span>
          <select value={pathId} onChange={e => setPathId(e.target.value)} className={field}>
            <option value="">Tria una ruta…</option>
            {paths.map(p => <option key={p.id} value={p.id}>{p.title}</option>)}
          </select>
        </label>
      ) : (
        <div className="grid gap-3 sm:col-span-3 md:grid-cols-2">
          <div>
            <span className="block font-extrabold">Activitats ({items.length})</span>
            {!items.length ? (
              <p className="mt-1 opacity-60">Toca les activitats del catàleg per a afegir-les.</p>
            ) : (
              <ol className="mt-1 flex flex-col gap-1">
                {items.map((item, i) => {
                  const r = resolveItem(item, byId);
                  return (
                    <li key={itemKey(item)} className="flex items-center gap-2 rounded-xl bg-white px-3 py-2">
                      <span className="w-5 text-right font-black opacity-40">{i + 1}</span>
                      <span aria-hidden="true">{r.emoji}</span>
                      <span className="min-w-0 flex-1 truncate font-bold">{r.title}</span>
                      <span className="text-xs opacity-50">{r.kindLabel}</span>
                      <button onClick={() => move(i, -1)} disabled={i === 0} aria-label={`Puja ${r.title}`} className="btn-press text-gray-400 hover:text-ink disabled:opacity-20"><ArrowUp size={16} /></button>
                      <button onClick={() => move(i, 1)} disabled={i === items.length - 1} aria-label={`Baixa ${r.title}`} className="btn-press text-gray-400 hover:text-ink disabled:opacity-20"><ArrowDown size={16} /></button>
                      <button onClick={() => setItems(list => list.filter((_, j) => j !== i))} aria-label={`Lleva ${r.title}`} className="btn-press text-gray-400 hover:text-coral"><X size={16} /></button>
                    </li>
                  );
                })}
              </ol>
            )}
          </div>
          <div>
            <CatalogPicker
              resources={resources}
              level={null}
              audience={audience}
              exclude={new Set(items.map(itemKey))}
              onAdd={item => setItems(list => [...list, item])}
              className="max-h-72"
            />
          </div>
        </div>
      )}

      <label className="sm:col-span-2">
        <span className="block font-extrabold">Per a</span>
        <select value={target} onChange={e => setTarget(e.target.value)} disabled={!!editing} className={`${field} disabled:opacity-60`}>
          <option value="class">Tota la classe</option>
          {students.map(s => <option key={s.id} value={s.id}>{s.data.name || 'Sense nom'}</option>)}
        </select>
      </label>
      <label>
        <span className="block font-extrabold">Termini</span>
        <input type="date" value={due} min={today} onChange={e => setDue(e.target.value)} className={field} />
      </label>
      {error && <p className="text-coral sm:col-span-3">{error}</p>}
      <div className="flex gap-2 sm:col-span-3">
        <button onClick={() => void save()} disabled={!ready || !due || saving} className="btn-press rounded-2xl bg-[#0F47AF] px-5 py-2 text-lg font-extrabold text-white disabled:opacity-40">
          {saving ? 'Guardant…' : editing ? 'Guarda els canvis' : 'Posa els deures'}
        </button>
        <button onClick={onCancel} className="btn-press rounded-2xl px-4 py-2 text-lg font-bold text-gray-500">Cancel·la</button>
      </div>
    </div>
  );
}

/**
 * Reforç per a un alumne: una ruta amb les illes que més li costen (i la lliçó de cada una
 * abans), posada de deures fins diumenge. Torna null si no hi ha res per a reforçar.
 */
export async function sendReinforcement(uid: string, student: Student): Promise<string | null> {
  const report = summarize(student.data);
  // Les que li costen i, després, les jugades amb menys del 80 % d'encerts (no les que va bé però no ha acabat).
  const weak = [...report.costa, ...report.practicar.filter(i => i.accuracy !== null && i.accuracy < 0.8)].slice(0, 3);
  if (!weak.length) return null;
  const items: PathItemDraft[] = weak.flatMap(island => [
    ...(island.lesson ? [{ kind: 'kids_lesson' as const, resource_id: null, kids_ref: island.lesson, note: 'Repassa la lliçó' }] : []),
    { kind: 'kids_island' as const, resource_id: null, kids_ref: island.id, note: '' },
  ]);
  const name = student.data.name || 'alumne';
  const path = await savePath({
    owner_id: uid,
    title: `Reforç · ${name} · ${shortDate(new Date())}`.slice(0, 80),
    description: `Per a repassar: ${weak.map(i => i.name).join(', ')}.`,
    audience: 'child',
    level: 'nivell0',
    is_public: false,
    is_adhoc: true,
  }, items);
  await createHomework(uid, path.id, { studentId: student.id }, new Date(), weekEnd(addDays(new Date(), 2)));
  return weak.map(i => `${i.emoji} ${i.name}`).join(', ');
}

/** Els deures d'esta setmana d'un alumne, en la seua fitxa: cada pas, fet o no. */
export function StudentHomework({ uid, classId, student, resources, onReinforce }: {
  uid: string;
  classId: string;
  student: Student;
  resources: Map<string, Resource>;
  onReinforce?: () => void;
}) {
  const [homework, setHomework] = useState<Homework[]>();
  const [message, setMessage] = useState<string>();
  const [sending, setSending] = useState(false);
  const week = useMemo(() => weekStart(), []);

  const reload = () => loadClassHomework(classId, [student.id], week, addDays(week, 7))
    .then(list => setHomework(list.filter(hw => forStudent(hw, student.id))))
    .catch(console.error);
  useEffect(() => { void reload(); }, [classId, student.id]); // eslint-disable-line react-hooks/exhaustive-deps

  const reinforce = async () => {
    setSending(true);
    try {
      const what = await sendReinforcement(uid, student);
      setMessage(what ? `Reforç enviat: ${what}.` : 'No hi ha cap illa que li coste: no cal reforç.');
      await reload();
      onReinforce?.();
    } catch (e) {
      console.error(e);
      setMessage("No s'ha pogut enviar el reforç.");
    } finally {
      setSending(false);
    }
  };

  return (
    <section className="mb-6 rounded-3xl bg-white p-5 shadow-sm">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h3 className="text-2xl font-black">Deures d'esta setmana</h3>
        {student.data.ageGroup !== 'adult' && (
          <button
            onClick={() => void reinforce()}
            disabled={sending}
            title="Crea uns deures només per a este alumne amb les illes que més li costen"
            className="btn-press flex items-center gap-2 rounded-2xl bg-mustard px-4 py-2 font-extrabold text-ink disabled:opacity-50"
          >
            <Send size={18} /> {sending ? 'Enviant…' : 'Envia reforç'}
          </button>
        )}
      </div>
      {message && <p className="mt-2 font-bold text-teal">{message}</p>}
      {!homework ? <p className="mt-2 opacity-60">…</p> : !homework.length ? (
        <p className="mt-2 text-lg opacity-70">No té deures esta setmana.</p>
      ) : (
        <div className="mt-3 flex flex-col gap-4">
          {homework.map(hw => <StudentHomeworkItem key={hw.id} hw={hw} student={student.id} resources={resources} />)}
        </div>
      )}
    </section>
  );
}

function StudentHomeworkItem({ hw, student, resources }: { hw: Homework; student: string; resources: Map<string, Resource> }) {
  const state = useAssignmentState(hw.id, hw.path.id, student);
  const st = state ? homeworkStatus(hw, state) : null;
  return (
    <div className="rounded-2xl bg-cream/60 p-4">
      <div className="flex flex-wrap items-center gap-2">
        <h4 className="text-xl font-black">{hw.path.title}</h4>
        <span className="text-sm opacity-60">fins al {shortDate(hw.due_at)}</span>
        {st && <span className={`rounded-full px-3 py-0.5 text-sm font-black ${TONE[st.tone]}`}>{st.done}/{st.total} · {st.label}</span>}
      </div>
      <div className="mt-3">{state ? <PathSteps state={state} resources={resources} /> : <p className="opacity-60">…</p>}</div>
    </div>
  );
}
