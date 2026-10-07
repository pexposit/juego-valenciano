import { useMemo, useState } from 'react';
import { Plus, Search } from 'lucide-react';
import { levelLabel } from '@parlaval/shared';
import { categoryLabel } from '../../components/ScenarioSelect';
import type { Resource } from '../../lib/types';

const MINE = 'mine';

const matches = (r: Resource, query: string) =>
  `${r.section_name ?? ''} ${r.name} ${categoryLabel(r.category)}`.toLowerCase().includes(query);

// Nivell visible: el del MECR per a les activitats de la docent; el tram per a les del catàleg.
const levelOf = (r: Resource) => (r.class_activity && r.cefr_level ? r.cefr_level : levelLabel(r.difficulty ?? ''));

/**
 * Llista per a triar activitats: les de la docent (obertes, les primeres) i les del catàleg
 * agrupades per àrea, amb un cercador. `accepts` diu quines es poden triar (p. ex. les dels
 * nivells de la classe). La fan servir les rutes i les activitats de la classe.
 */
export function ActivityPicker({ catalog, accepts, showLevel = false, exclude, disabled = false, onPick }: {
  catalog: Resource[];
  accepts: (resource: Resource) => boolean;
  showLevel?: boolean;
  exclude: ReadonlySet<string>;
  disabled?: boolean;
  onPick: (resource: Resource) => void;
}) {
  const [query, setQuery] = useState('');
  const q = query.trim().toLowerCase();

  const candidates = useMemo(
    () => catalog.filter(r => r.playable && accepts(r) && !exclude.has(r.id)),
    [catalog, accepts, exclude],
  );
  const groups = useMemo(() => {
    const map = new Map<string, Resource[]>([[MINE, []]]);
    for (const r of candidates) {
      const key = r.class_activity ? MINE : r.category;
      map.set(key, [...(map.get(key) ?? []), r]);
    }
    return [...map].filter(([, list]) => list.length);
  }, [candidates]);
  const found = q ? candidates.filter(r => matches(r, q)) : [];

  const item = (r: Resource) => (
    <li key={r.id}>
      <button
        type="button"
        onClick={() => onPick(r)}
        disabled={disabled}
        className="btn-press flex w-full items-center gap-2 rounded-xl px-3 py-1.5 text-left hover:bg-[#0F47AF]/5 disabled:opacity-40"
      >
        <Plus size={16} className="shrink-0 text-[#0F47AF]" />
        <span className="text-lg" aria-hidden="true">{r.icon ?? '📘'}</span>
        <span className="min-w-0 flex-1">
          <span className="block truncate font-bold">{r.section_name ?? r.name}</span>
          <span className="block truncate text-xs opacity-60">
            {q || r.class_activity ? `${categoryLabel(r.category)} · ` : ''}{r.section_name ? r.name : ''}
          </span>
        </span>
        {showLevel && <span className="shrink-0 rounded-full bg-gray-100 px-2 text-xs font-black">{levelOf(r)}</span>}
        {r.class_activity && <span className="shrink-0 rounded-full bg-mustard/30 px-2 text-xs font-black">Teua</span>}
      </button>
    </li>
  );

  return (
    <div className="rounded-2xl border border-gray-100 p-2">
      <label className="flex items-center gap-2 rounded-xl bg-gray-50 px-3 py-2">
        <Search size={18} className="opacity-50" />
        <input
          value={query}
          onChange={e => setQuery(e.target.value)}
          placeholder="Busca una activitat"
          aria-label="Busca una activitat"
          className="min-w-0 flex-1 bg-transparent outline-none"
        />
      </label>
      <div className="mt-2 max-h-[28rem] overflow-y-auto">
        {q ? (
          found.length ? <ul className="flex flex-col">{found.map(item)}</ul> : <p className="p-3 opacity-60">No hi ha cap activitat amb «{query.trim()}».</p>
        ) : groups.length ? (
          groups.map(([category, list]) => (
            <details key={category} open={category === MINE}>
              <summary className="cursor-pointer rounded-xl px-2 py-2 font-black hover:bg-gray-50">
                {category === MINE ? 'Les meues activitats' : categoryLabel(category)} <span className="font-normal opacity-50">({list.length})</span>
              </summary>
              <ul className="mb-2 flex flex-col">{list.map(item)}</ul>
            </details>
          ))
        ) : (
          <p className="p-3 opacity-60">No queda cap activitat per afegir.</p>
        )}
      </div>
    </div>
  );
}
