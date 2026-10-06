import { useEffect, useState } from 'react';
import { Plus, X } from 'lucide-react';
import { assignPathToClass, loadClassPaths, unenrollPath, type StudyPath } from '../../lib/paths';
import type { Resource } from '../../lib/types';
import { countDone, loadPathState, PathSteps, usePathState, type PathState } from './PathSteps';

type ClassPath = StudyPath & { assignment_id: string };

/**
 * Les rutes assignades a una classe: la docent n'assigna de les seues o de les públiques,
 * i veu quants passos porta cada alumne de cada ruta.
 */
export function ClassPaths({ uid, classId, students, paths }: {
  uid: string;
  classId: string;
  students: { id: string; name: string }[];
  paths: StudyPath[];
}) {
  const [assigned, setAssigned] = useState<ClassPath[]>();
  const [choice, setChoice] = useState('');
  // Progrés per ruta i alumne: `${path}:${student}` → estat.
  const [progress, setProgress] = useState<Record<string, PathState | null>>({});
  const [error, setError] = useState<string>();
  const studentIds = students.map(s => s.id).join(',');

  const reload = () => loadClassPaths(classId).then(setAssigned).catch(e => {
    console.error(e);
    setError("No s'han pogut carregar les rutes de la classe.");
  });

  useEffect(() => { void reload(); }, [classId]); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    if (!assigned) return;
    let cancelled = false;
    for (const p of assigned) {
      for (const s of students) {
        loadPathState(p.id, s.id)
          .then(state => { if (!cancelled) setProgress(old => ({ ...old, [`${p.id}:${s.id}`]: state })); })
          .catch(() => { if (!cancelled) setProgress(old => ({ ...old, [`${p.id}:${s.id}`]: null })); });
      }
    }
    return () => { cancelled = true; };
    // Per ids: la llista d'alumnes arriba com un array nou en cada render.
  }, [assigned, studentIds]); // eslint-disable-line react-hooks/exhaustive-deps

  const assign = async () => {
    if (!choice) return;
    try {
      await assignPathToClass(uid, choice, classId);
      setChoice('');
      await reload();
    } catch (e) {
      console.error(e);
      setError("No s'ha pogut assignar la ruta.");
    }
  };

  const unassign = async (p: ClassPath) => {
    if (!confirm(`Vols traure la ruta «${p.title}» d'esta classe? L'alumnat no perd el que ha fet.`)) return;
    await unenrollPath(p.assignment_id).catch(console.error);
    await reload();
  };

  const free = paths.filter(p => !assigned?.some(a => a.id === p.id));

  return (
    <section className="mt-5 rounded-3xl bg-white p-5 shadow-sm">
      <h3 className="text-2xl font-black">Rutes de la classe</h3>
      <p className="mt-1 text-base opacity-60">L'alumnat les veu en «Les meues rutes» (i els xiquets del Nivell 0, en el seu mapa d'illes).</p>
      {error && <p className="mt-2 text-coral">{error}</p>}

      {assigned && assigned.length > 0 && (
        <div className="mt-3 overflow-x-auto">
          <table className="w-full min-w-[480px] text-left text-lg">
            <thead className="text-sm font-extrabold uppercase tracking-wide opacity-50">
              <tr>
                <th className="py-2">Ruta</th>
                {students.map(s => <th key={s.id} className="px-2">{s.name || 'Sense nom'}</th>)}
                <th />
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {assigned.map(p => (
                <tr key={p.id}>
                  <td className="py-3 font-extrabold">{p.title}</td>
                  {students.map(s => {
                    const state = progress[`${p.id}:${s.id}`];
                    return <td key={s.id} className="px-2">{state ? `${countDone(state)}/${state.items.length}` : state === null ? '—' : '…'}</td>;
                  })}
                  <td className="text-right">
                    <button onClick={() => void unassign(p)} aria-label={`Trau la ruta ${p.title}`} className="btn-press p-2 text-gray-400 hover:text-coral">
                      <X size={18} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      {assigned?.length === 0 && <p className="mt-3 text-lg opacity-70">Esta classe encara no té cap ruta.</p>}

      {free.length > 0 ? (
        <div className="mt-4 flex gap-2">
          <select value={choice} onChange={e => setChoice(e.target.value)} className="w-full rounded-2xl border-2 border-gray-100 p-3 text-lg outline-none focus:border-[#0F47AF]">
            <option value="">Tria una ruta per a assignar…</option>
            {free.map(p => <option key={p.id} value={p.id}>{p.title}{p.owner_id !== uid ? ' (pública)' : ''}</option>)}
          </select>
          <button onClick={() => void assign()} disabled={!choice} className="btn-press flex shrink-0 items-center gap-2 rounded-2xl bg-[#0F47AF] px-5 text-xl font-extrabold text-white disabled:opacity-40">
            <Plus size={20} /> Assigna
          </button>
        </div>
      ) : !paths.length && (
        <p className="mt-3 text-lg opacity-70">Crea una ruta en la pestanya «Rutes» per a poder-la assignar.</p>
      )}
    </section>
  );
}

/** Les rutes de la classe en la fitxa d'un alumne: cada pas, fet o no. */
export function StudentPaths({ classId, student, resources }: { classId: string; student: string; resources: Map<string, Resource> }) {
  const [assigned, setAssigned] = useState<ClassPath[]>();
  useEffect(() => { loadClassPaths(classId).then(setAssigned).catch(console.error); }, [classId]);
  if (!assigned?.length) return null;
  return (
    <section className="mb-6 flex flex-col gap-4">
      {assigned.map(p => <StudentPath key={p.id} path={p} student={student} resources={resources} />)}
    </section>
  );
}

function StudentPath({ path, student, resources }: { path: ClassPath; student: string; resources: Map<string, Resource> }) {
  const state = usePathState(path.id, student);
  return (
    <div className="rounded-3xl bg-cream/60 p-4">
      <h3 className="text-2xl font-black">
        {path.title}
        {state && <span className="ml-2 text-lg font-bold opacity-60">{countDone(state)}/{state.items.length}</span>}
      </h3>
      <div className="mt-3">{state ? <PathSteps state={state} resources={resources} /> : <p className="opacity-60">…</p>}</div>
    </div>
  );
}
