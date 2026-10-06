import { useEffect, useState } from 'react';
import { Check, Plus } from 'lucide-react';
import { assignPathToClass, loadPathClasses, unenrollPath } from '../../lib/paths';

/**
 * En la targeta d'una ruta: les classes de la docent, marcades si la ruta hi està
 * assignada. Tocar-ne una l'assigna o la trau.
 */
export function PathClassPicker({ uid, pathId, classes }: { uid: string; pathId: string; classes: { id: string; name: string }[] }) {
  // class_id → id de l'assignació; undefined mentre carrega.
  const [assigned, setAssigned] = useState<Map<string, string>>();
  const [busy, setBusy] = useState<string>();

  const reload = () => loadPathClasses(pathId).then(setAssigned).catch(console.error);
  useEffect(() => { void reload(); }, [pathId]); // eslint-disable-line react-hooks/exhaustive-deps

  const toggle = async (classId: string, name: string) => {
    const assignment = assigned?.get(classId);
    if (assignment && !confirm(`Vols traure esta ruta de la classe «${name}»? L'alumnat no perd el que ha fet.`)) return;
    setBusy(classId);
    try {
      if (assignment) await unenrollPath(assignment);
      else await assignPathToClass(uid, pathId, classId);
      await reload();
    } catch (e) {
      console.error(e);
    } finally {
      setBusy(undefined);
    }
  };

  if (!classes.length) return <p className="mt-3 text-sm opacity-60">Crea una classe per a poder-li assignar la ruta.</p>;
  return (
    <div className="mt-3">
      <span className="text-sm font-extrabold opacity-60">Assignada a:</span>
      <div className="mt-1 flex flex-wrap gap-2">
        {classes.map(c => {
          const on = !!assigned?.has(c.id);
          return (
            <button
              key={c.id}
              onClick={() => void toggle(c.id, c.name)}
              disabled={!assigned || busy === c.id}
              aria-pressed={on}
              title={on ? 'Toca per a traure-la de la classe' : 'Toca per a assignar-la a la classe'}
              className={`btn-press flex items-center gap-1 rounded-full border-2 px-3 py-1 text-sm font-bold disabled:opacity-50 ${on ? 'border-teal bg-teal text-white' : 'border-gray-200 text-gray-600 hover:border-teal'}`}
            >
              {on ? <Check size={14} /> : <Plus size={14} />} {c.name}
            </button>
          );
        })}
      </div>
    </div>
  );
}
