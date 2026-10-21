import { useEffect, useState } from 'react';
import { Search } from 'lucide-react';
import { classLevelLabel, isLevel0Class } from '@parlaval/shared';
import { ago, summarize, summarizeAdult } from './report';
import { loadStudents, type KidsClass, type Student } from './tracking';
// Colors de l'etiqueta de nivell de la vista «Classes»: text #0F47AF sobre #0F47AF al 10 %.
const CLASS_COLORS = { text: '#0F47AF', background: 'rgba(15, 71, 175, 0.1)', ring: 'rgba(15, 71, 175, 0.3)' };

/**
 * Tot l'alumnat de la docent agrupat per classes: una secció per classe amb els seus alumnes.
 * Tocar un alumne n'obri la fitxa de seguiment (la mateixa que dins de la classe).
 */
export function StudentsByClass({ classes, onOpen }: { classes: KidsClass[]; onOpen: (klass: KidsClass, student: Student) => void }) {
  const [byClass, setByClass] = useState<Record<string, Student[]>>();
  const [failed, setFailed] = useState(false);
  const [query, setQuery] = useState('');
  const fold = (text: string) => text.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');
  const wanted = fold(query.trim());

  useEffect(() => {
    let cancelled = false;
    setFailed(false);
    Promise.all(classes.map(async c => [c.id, await loadStudents(c.id, !isLevel0Class(c.levels))] as const))
      .then(entries => { if (!cancelled) setByClass(Object.fromEntries(entries)); })
      .catch(e => {
        console.error(e);
        if (!cancelled) setFailed(true);
      });
    return () => { cancelled = true; };
  }, [classes]);

  return (
    <>
      <h1 className="text-5xl font-black">L'alumnat</h1>
      <p className="mt-2 text-lg opacity-70">Tot l'alumnat de les teues classes, agrupat per classe.</p>

      <label className="relative mt-4 block sm:max-w-sm">
        <Search size={18} className="pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 opacity-40" aria-hidden="true" />
        <input
          type="search"
          value={query}
          onChange={e => setQuery(e.target.value)}
          placeholder="Busca un alumne pel nom"
          aria-label="Busca un alumne pel nom"
          className="w-full rounded-full border-2 border-gray-100 bg-white py-2.5 pl-11 pr-4 text-lg outline-none transition-colors focus:border-gray-500"
        />
      </label>

      {failed ? (
        <p className="mt-6 rounded-2xl bg-coral/10 p-3 text-lg text-coral">No s'ha pogut carregar l'alumnat.</p>
      ) : !classes.length ? (
        <p className="mt-6 text-lg opacity-60">Encara no tens cap classe.</p>
      ) : !byClass ? (
        <p className="mt-6 text-lg opacity-60">Carregant l'alumnat...</p>
      ) : (
        // Per nombre d'alumnes, de menys a més: les classes buides, les primeres (a igualtat, l'ordre de creació).
        [...classes].sort((a, b) => (byClass[a.id]?.length ?? 0) - (byClass[b.id]?.length ?? 0)).map(c => {
          const all = byClass[c.id] ?? [];
          const students = wanted ? all.filter(s => fold(s.data.name || '').includes(wanted)) : all;
          // En cercar, només es mostren les classes amb coincidències.
          if (wanted && !students.length) return null;
          const kids = isLevel0Class(c.levels);
          const badges = c.levels.map(l => <span key={l} className="rounded-full bg-white px-2.5 py-0.5 text-sm font-black text-gray-600 ring-1 ring-gray-300">{classLevelLabel(l)}</span>);
          // Una classe sense alumnat ocupa només una línia.
          if (!students.length) {
            return (
              <div key={c.id} className="mt-3 flex flex-wrap items-center gap-x-3 gap-y-1 rounded-2xl bg-white/70 px-5 py-2.5 shadow-sm">
                <span className="text-lg font-extrabold">{c.name}</span>
                <span className="flex gap-1">{badges}</span>
                <span className="ml-auto text-base opacity-50">Cap alumne encara</span>
              </div>
            );
          }
          return (
            <section key={c.id} className="mt-8 overflow-hidden rounded-3xl bg-white shadow-md ring-2" style={{ '--tw-ring-color': CLASS_COLORS.ring } as React.CSSProperties}>
              <div className="flex flex-wrap items-center justify-between gap-2 px-5 py-3" style={{ background: CLASS_COLORS.background, color: CLASS_COLORS.text }}>
                <h2 className="text-2xl font-black">
                  {c.name}
                  <span className="ml-3 rounded-full bg-white/60 px-3 py-0.5 text-base font-bold">{students.length} {students.length === 1 ? 'alumne' : 'alumnes'}</span>
                </h2>
                <span className="flex gap-1">{badges}</span>
              </div>
              <ul className="divide-y divide-gray-100 px-5 py-1">
                  {students.map(s => (
                    <li key={s.id}>
                      <button onClick={() => onOpen(c, s)} className="btn-press flex w-full flex-wrap items-center justify-between gap-2 py-3 text-left transition-colors hover:bg-gray-200">
                        <span className="text-lg font-extrabold text-gray-600">{s.data.name || 'Sense nom'}</span>
                        <span className="text-base opacity-60">
                          {kids ? 'Última vegada' : 'Última activitat'}: {ago(kids ? summarize(s.data).lastPlayed : summarizeAdult(s.data).lastActivity)}
                        </span>
                      </button>
                    </li>
                  ))}
              </ul>
            </section>
          );
        })
      )}
      {wanted && byClass && !classes.some(c => (byClass[c.id] ?? []).some(s => fold(s.data.name || '').includes(wanted))) && (
        <p className="mt-6 text-lg opacity-60">Cap alumne coincidix amb «{query.trim()}».</p>
      )}
    </>
  );
}
