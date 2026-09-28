import { useState } from 'react';
import { Logo, ProfileButton } from './ui';
import type { Scenario, ScenarioInfo } from '../lib/types';
import type { ScenarioDef } from '../data/content';

type Activitat = 'escenaris' | 'dictats' | 'expressio';

const ACTIVITATS: { id: Activitat; label: string }[] = [
  { id: 'escenaris', label: 'Escenaris' },
  { id: 'dictats', label: 'Dictats' },
  { id: 'expressio', label: 'Expressió escrita' },
];

export function ScenarioSelect({
  scenarios,
  goals,
  name,
  onSelectScenario,
  onBack,
  onProfile,
}: {
  scenarios: ScenarioDef[];
  goals: Record<Scenario, ScenarioInfo>;
  name: string;
  onSelectScenario: (s: Scenario) => void;
  onBack: () => void;
  onProfile: () => void;
}) {
  const [activitat, setActivitat] = useState<Activitat>('escenaris');

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

        {activitat === 'escenaris' && (
        <div className="desk-grid grid grid-cols-2 gap-4">
          {scenarios.map((s) => {
            const g = goals[s.id];
            return (
              <button
                key={s.id}
                id={`scenario-select-${s.id}`}
                onClick={() => onSelectScenario(s.id)}
                className="desk-card flex items-stretch text-left"
                style={{ background: '#fff' }}
              >
                <div
                  className="relative flex h-28 w-28 shrink-0 items-center justify-center overflow-hidden rounded-l-[20px]"
                  style={{ background: s.color }}
                >
                  <span className="text-6xl select-none">{s.icon}</span>
                </div>
                <div className="flex flex-1 flex-col justify-center px-4 py-3">
                  <h1 className="block text-base font-black text-2xl"> {s.name} </h1>
                  <p>Descripció</p>
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