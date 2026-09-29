import { useEffect, useMemo, useState } from 'react';
import { Logo, ProfileButton } from './ui';
import { fetchResources } from '../lib/api';
import type { Resource, Scenario } from '../lib/types';

// Noms visibles de les categories conegudes; la resta es mostren capitalitzades.
const CATEGORY_LABELS: Record<string, string> = {
  escenari: 'Escenaris',
};

const capitalize = (s: string) => s.charAt(0).toUpperCase() + s.slice(1).replace(/_/g, ' ');
const categoryLabel = (c: string) => CATEGORY_LABELS[c] ?? capitalize(c);

type Section = { type: string; resources: Resource[] };
type Category = { id: string; sections: Section[] };

// Agrupa els recursos per categoria i, dins de cada categoria, per tipus
// (secció), mantenint l'ordre en què arriben del backend.
function groupResources(resources: Resource[]): Category[] {
  const categories = new Map<string, Map<string, Resource[]>>();
  for (const r of resources) {
    const sections = categories.get(r.category) ?? new Map<string, Resource[]>();
    sections.set(r.type, [...(sections.get(r.type) ?? []), r]);
    categories.set(r.category, sections);
  }
  return [...categories].map(([id, sections]) => ({
    id,
    sections: [...sections].map(([type, list]) => ({ type, resources: list })),
  }));
}

export function ScenarioSelect({
  name,
  onSelectScenario,
  onBack,
  onProfile,
}: {
  name: string;
  onSelectScenario: (s: Scenario) => void;
  onBack: () => void;
  onProfile: () => void;
}) {
  const [resources, setResources] = useState<Resource[] | null>(null);
  const [loadError, setLoadError] = useState(false);
  const [selected, setSelected] = useState<string>();

  useEffect(() => {
    let cancelled = false;
    fetchResources()
      .then(data => { if (!cancelled) setResources(data); })
      .catch(error => {
        console.error('Error carregant les activitats:', error);
        if (!cancelled) setLoadError(true);
      });
    return () => { cancelled = true; };
  }, []);

  const categories = useMemo(() => groupResources(resources ?? []), [resources]);
  const current = categories.find(c => c.id === selected) ?? categories[0];

  return (
    <main className="fade-up relative min-h-screen" style={{ background: '#FFF9ED' }}>
      {/* Classroom header */}
      <header className="classroom-header z-10">
        <div className="relative isolate flex items-center justify-between px-5 p-4">
          <button
            onClick={onBack}
            className="text-xl btn-press rounded-full bg-white/90 px-4 py-2 text-sm font-extrabold text-teal shadow hover:bg-white transition-colors"
          >
            ← Tornar
          </button>
          <Logo />
          <ProfileButton name={name} onClick={onProfile} />
        </div>
      </header>

      <div className="relative z-10 mx-auto max-w-4xl px-5 pt-6 pb-20">
        <h1 className="mb-4 text-3xl text-center font-black uppercase tracking-wider opacity-55">
          ACTIVITATS
        </h1>

        {loadError && (
          <p className="mt-10 text-center text-sm font-bold opacity-50">
            No hem pogut carregar les activitats. Torna-ho a provar més tard.
          </p>
        )}

        {!loadError && !resources && (
          <p className="mt-10 text-center text-sm font-bold opacity-50">Carregant activitats…</p>
        )}

        {resources && categories.length === 0 && (
          <p className="mt-10 text-center text-sm font-bold opacity-50">Encara no hi ha activitats disponibles.</p>
        )}

        {/* Categories (resources.category), generades a partir de la BDD. */}
        {categories.length > 0 && (
          <div className="mb-6 flex flex-wrap items-center justify-center gap-3">
            {categories.map(c => (
              <button
                key={c.id}
                onClick={() => setSelected(c.id)}
                className={`btn-press rounded-full px-4 py-2 text-sm font-black transition-colors ${
                  current?.id === c.id ? 'bg-teal text-white' : 'bg-white text-teal hover:bg-teal/10'
                }`}
              >
                {categoryLabel(c.id)}
              </button>
            ))}
          </div>
        )}

        {/* Seccions de la categoria triada (resources.type). */}
        {current && (
          <div key={current.id} className="desk-grid grid grid-cols-2 gap-4">
            {current.sections.map(({ type, resources: list }) => {
              const [first] = list;
              // L'aparença de la secció ve de metadata; es pren del primer recurs que la tinga.
              const icon = list.find(r => r.icon)?.icon ?? '📘';
              const color = list.find(r => r.color)?.color ?? '#E7E5E4';
              const title = list.find(r => r.section_name)?.section_name ?? capitalize(type);
              // El backend decidix si té xat (escenari amb prompt del personatge).
              const playable = list.some(r => r.playable);
              return (
                <button
                  key={type}
                  id={`activity-${current.id}-${type}`}
                  disabled={!playable}
                  title={playable ? undefined : 'Pròximament disponible'}
                  onClick={() => playable && onSelectScenario(type)}
                  className="desk-card flex items-stretch text-left"
                  style={{ background: '#fff' }}
                >
                  <div
                    className="relative flex min-h-28 w-28 shrink-0 self-stretch items-center justify-center overflow-hidden rounded-l-[20px]"
                    style={{ background: color }}
                  >
                    <span className="text-6xl select-none">{icon}</span>
                  </div>
                  <div className="flex flex-1 flex-col justify-center gap-1 px-4 py-3">
                    <h2 className="block text-2xl font-black">{title}</h2>
                    {list.length === 1 ? (
                      <>
                        <p className="text-sm font-bold">{first.name}</p>
                        {first.content && <p className="text-sm opacity-70">{first.content}</p>}
                      </>
                    ) : (
                      <ul className="list-disc pl-4 text-sm">
                        {list.map(r => <li key={r.id}>{r.name}</li>)}
                      </ul>
                    )}
                    {!playable && <p className="text-xs font-bold opacity-50">Pròximament disponible</p>}
                  </div>
                </button>
              );
            })}
          </div>
        )}
      </div>
    </main>
  );
}
