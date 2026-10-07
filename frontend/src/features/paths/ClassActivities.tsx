import { useCallback, useEffect, useMemo, useState } from 'react';
import { LayoutGrid, Plus, X } from 'lucide-react';
import { classAcceptsLearner, levelLabel } from '@parlaval/shared';
import { categoryLabel } from '../../components/ScenarioSelect';
import { assignClassActivities, fetchClassActivities, fetchResources, unassignClassActivity } from '../../lib/api';
import type { Resource } from '../../lib/types';
import { ActivityPicker } from './ActivityPicker';

const messageOf = (error: unknown) => (error instanceof Error ? error.message : 'Hi ha hagut un error');

/**
 * Activitats soltes d'una classe: la docent n'assigna de les seues o del catàleg (dels nivells de
 * la classe) i l'alumnat les veu en la seua secció «Classe». Les activitats de les
 * rutes de la classe també hi són (s'hi assignen soles en posar-les en una ruta).
 */
export function ClassActivities({ classId, classLevels }: { classId: string; classLevels: string[] }) {
  const [assigned, setAssigned] = useState<string[]>();
  const [catalog, setCatalog] = useState<Resource[]>([]);
  const [picking, setPicking] = useState(false);
  const [error, setError] = useState<string>();

  useEffect(() => {
    setAssigned(undefined);
    setPicking(false);
    fetchClassActivities(classId).then(rows => setAssigned(rows.map(r => r.resource_id))).catch(e => setError(messageOf(e)));
  }, [classId]);

  useEffect(() => {
    fetchResources().then(setCatalog).catch(console.error);
  }, []);

  const byId = useMemo(() => new Map(catalog.map(r => [r.id, r])), [catalog]);
  const exclude = useMemo(() => new Set(assigned ?? []), [assigned]);
  // Les de la docent, pel seu nivell del MECR; les del catàleg, si el seu tram cobrix algun nivell de la classe.
  const accepts = useCallback(
    (r: Resource) => (r.class_activity ? classLevels.includes(r.cefr_level ?? '') : classAcceptsLearner(classLevels, r.difficulty ?? '')),
    [classLevels],
  );

  const add = async (r: Resource) => {
    setError(undefined);
    try {
      await assignClassActivities(classId, [r.id]);
      setAssigned(list => [r.id, ...(list ?? [])]);
    } catch (e) {
      setError(messageOf(e));
    }
  };

  const remove = async (id: string) => {
    setError(undefined);
    try {
      await unassignClassActivity(classId, id);
      setAssigned(list => list?.filter(x => x !== id));
    } catch (e) {
      setError(messageOf(e));
    }
  };

  return (
    <section className="mt-5 rounded-3xl bg-white p-5 shadow-sm">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h3 className="flex items-center gap-2 text-2xl font-black"><LayoutGrid size={24} /> Activitats de la classe</h3>
        <button
          onClick={() => setPicking(p => !p)}
          className="btn-press flex items-center gap-2 rounded-2xl bg-[#0F47AF] px-4 py-2 font-extrabold text-white"
        >
          {picking ? <><X size={18} /> Tanca</> : <><Plus size={18} /> Assigna activitats</>}
        </button>
      </div>
      <p className="mt-1 text-base opacity-60">
        Activitats soltes, teues o del catàleg. L'alumnat les veu en la secció «Classe».
      </p>
      {error && <p className="mt-3 rounded-2xl bg-coral/10 p-3 text-coral">{error}</p>}

      {picking && (
        <div className="mt-4">
          <ActivityPicker catalog={catalog} accepts={accepts} showLevel exclude={exclude} onPick={r => void add(r)} />
        </div>
      )}

      {assigned === undefined && !error ? (
        <p className="mt-4 text-lg opacity-60">Carregant les activitats...</p>
      ) : assigned?.length === 0 ? (
        <p className="mt-4 text-lg opacity-70">Encara no hi ha cap activitat assignada a esta classe.</p>
      ) : (
        <ul className="mt-4 flex flex-col gap-2">
          {assigned?.map(id => {
            const r = byId.get(id);
            return (
              <li key={id} className="flex items-center gap-3 rounded-2xl border border-gray-100 px-4 py-3">
                <span className="text-2xl" aria-hidden="true">{r?.icon ?? '📘'}</span>
                <span className="min-w-0 flex-1">
                  <span className="block truncate text-lg font-black">{r?.section_name ?? r?.name ?? 'Activitat'}</span>
                  <span className="block text-sm opacity-60">
                    {r ? `${categoryLabel(r.category)} · ${r.class_activity && r.cefr_level ? r.cefr_level : levelLabel(r.difficulty ?? '')}` : ''}
                  </span>
                </span>
                <span className={`rounded-full px-2.5 py-0.5 text-xs font-black ${r?.class_activity ? 'bg-mustard/30' : 'bg-gray-100'}`}>
                  {r?.class_activity ? 'Teua' : 'Catàleg'}
                </span>
                <button onClick={() => void remove(id)} aria-label={`Lleva ${r?.section_name ?? 'l\'activitat'} de la classe`} className="btn-press p-2 text-gray-400 hover:text-coral">
                  <X size={18} />
                </button>
              </li>
            );
          })}
        </ul>
      )}
    </section>
  );
}
