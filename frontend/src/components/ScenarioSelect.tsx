import { useEffect, useState } from 'react';
import { Logo, ProfileButton } from './ui';
import type { Scenario } from '../lib/types';
import { SCENARIO_STYLE, type ScenarioResource } from '../lib/scenarioResources';
import { fetchScenarioResources } from '../lib/api';

type Activitat = 'escenaris' | 'dictats' | 'expressio';

const ACTIVITATS: { id: Activitat; label: string }[] = [
  { id: 'escenaris', label: 'Escenaris' },
  { id: 'dictats', label: 'Dictats' },
  { id: 'expressio', label: 'Expressió escrita' },
];

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
  const [activitat, setActivitat] = useState<Activitat>('escenaris');
  const [scenarios, setScenarios] = useState<ScenarioResource[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  useEffect(() => {
    let cancelled = false;
    fetchScenarioResources()
      .then(rows => { if (!cancelled) setScenarios(rows); })
      .catch(() => { if (!cancelled) setError(true); })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, []);

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

      {/* Scenario desk grid: 2 rows x 3 columns */}
      <div className="relative z-10 mx-auto max-w-4xl px-5 pt-6 pb-20">
        <h1 className="mb-4 text-3xl text-center font-black uppercase tracking-wider opacity-55">
          ACTIVITATS
        </h1>

        {/* Tipus d'activitat: de moment només "Escenaris" té contingut. */}
        <div className="mb-6 flex items-center justify-center gap-3">
          {ACTIVITATS.map(a => (
            <button
              key={a.id}
              onClick={() => setActivitat(a.id)}
              className={`btn-press rounded-full px-4 py-2 text-sm font-black transition-colors ${
                activitat === a.id ? 'bg-teal text-white' : 'bg-white text-teal hover:bg-teal/10'
              }`}
            >
              {a.label}
            </button>
          ))}
        </div>

        {activitat !== 'escenaris' && (
          <p className="mt-10 text-center text-sm font-bold opacity-50">
            Pròximament disponible.
          </p>
        )}

        {activitat === 'escenaris' && loading && (
          <p className="mt-10 text-center text-sm font-bold opacity-50">Carregant escenaris…</p>
        )}

        {activitat === 'escenaris' && !loading && error && (
          <p className="mt-10 text-center text-sm font-bold opacity-50">
            No hem pogut carregar els escenaris. Torna-ho a provar més tard.
          </p>
        )}

        {activitat === 'escenaris' && !loading && !error && (
        <div className="desk-grid grid grid-cols-2 gap-4">
          {scenarios.map((s) => {
            const style = SCENARIO_STYLE[s.scenario];
            return (
              <button
                key={s.id}
                id={`scenario-select-${s.scenario}`}
                onClick={() => onSelectScenario(s.scenario)}
                className="desk-card flex items-stretch text-left"
                style={{ background: '#fff' }}
              >
                <div
                  className="relative flex h-28 w-28 shrink-0 items-center justify-center overflow-hidden rounded-l-[20px]"
                  style={{ background: style.color }}
                >
                  <span className="text-6xl select-none">{style.icon}</span>
                </div>
                <div className="flex flex-1 flex-col justify-center px-4 py-3">
                  <h1 className="block text-base font-black text-2xl"> {s.name} </h1>
                  <p>{s.content || 'Descripció'}</p>
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