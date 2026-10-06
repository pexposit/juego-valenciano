import { useState } from 'react';
import { Plus, Search } from 'lucide-react';
import type { PathItemDraft } from '../../lib/paths';
import type { Resource } from '../../lib/types';
import { catalogEntries } from './catalog';

/**
 * El catàleg d'activitats amb cercador, agrupat. Tocar-ne una la passa a `onAdd`; les de
 * `exclude` (claus d'itemKey, ja triades) no hi apareixen.
 */
export function CatalogPicker({ resources, level, audience, exclude, onAdd, className = 'max-h-[32rem]' }: {
  resources: Resource[];
  level: string | null;
  audience: 'child' | 'adult';
  exclude: Set<string>;
  onAdd: (item: PathItemDraft) => void;
  className?: string;
}) {
  const [query, setQuery] = useState('');
  const q = query.trim().toLowerCase();
  const entries = catalogEntries(resources, level, audience)
    .filter(e => !exclude.has(e.key) && (!q || e.title.toLowerCase().includes(q) || e.group.toLowerCase().includes(q)));
  const groups = [...new Set(entries.map(e => e.group))];

  return (
    <>
      <label className="flex items-center gap-2 rounded-2xl border-2 border-gray-100 bg-white px-3 focus-within:border-[#0F47AF]">
        <Search size={18} className="opacity-40" />
        <input value={query} onChange={e => setQuery(e.target.value)} placeholder="Busca una activitat" className="w-full py-2 text-lg outline-none" />
      </label>
      <div className={`mt-3 overflow-y-auto pr-1 ${className}`}>
        {!entries.length && <p className="text-lg opacity-60">No hi ha cap activitat{level ? ' d\'este nivell' : ''} per afegir.</p>}
        {groups.map(group => (
          <div key={group} className="mb-3">
            <h3 className="text-sm font-extrabold uppercase tracking-wide opacity-50">{group}</h3>
            <ul className="mt-1">
              {entries.filter(e => e.group === group).map(e => (
                <li key={e.key}>
                  <button onClick={() => onAdd(e.item)} className="btn-press flex w-full items-center gap-2 rounded-xl px-2 py-1.5 text-left hover:bg-gray-50">
                    <span className="text-xl" aria-hidden="true">{e.emoji}</span>
                    <span className="flex-1 truncate">{e.title}</span>
                    <Plus size={18} className="text-[#0F47AF]" />
                  </button>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>
    </>
  );
}
