import { Lock } from 'lucide-react';
import { ClassroomScene } from './ClassroomScene';
import { Logo } from '../App';
import type { Scenario, ScenarioInfo } from '../lib/types';

type ScenarioDef = {
  id: Scenario;
  name: string;
  icon: string;
  required: number;
  color: string;
  bgIllustration: string;
};

export function ScenarioSelect({
  scenarios,
  goals,
  xp,
  onSelectScenario,
  onBack,
}: {
  scenarios: ScenarioDef[];
  goals: Record<Scenario, ScenarioInfo>;
  xp: number;
  onSelectScenario: (s: Scenario) => void;
  onBack: () => void;
}) {
  return (
    <main className="fade-up relative min-h-screen" style={{ background: '#FFF9ED' }}>
      <ClassroomScene opacity={0.18} />

      {/* Classroom header */}
      <header className="classroom-header z-10">
        <div className="relative isolate flex items-center justify-between px-5 pb-3 pt-4">
          <button
            onClick={onBack}
            className="btn-press rounded-full bg-white/90 px-4 py-2 text-sm font-extrabold text-teal shadow hover:bg-white transition-colors"
          >
            ← Tornar
          </button>
          <Logo />
          <div className="w-10" />
        </div>
        <div className="px-5 pb-4">
          <span className="block text-xs font-black uppercase tracking-widest" style={{ color: '#FFD166' }}>
            Aula d'aprenentatge
          </span>
          <p className="mt-1 text-sm opacity-65">Tria on practicar valencià avui</p>
        </div>
      </header>

      {/* Scenario desk grid */}
      <div className="relative z-10 mx-auto max-w-2xl px-5 pt-6 pb-20">
        <p className="mb-4 text-center text-xs font-black uppercase tracking-wider opacity-55">
          Tria una situació
        </p>
                        <div className="desk-grid grid grid-cols-3 gap-4">
          {scenarios.map((s) => {
            const locked = xp < s.required;
            const g = goals[s.id];
            return (
              <button
                key={s.id}
                id={`scenario-select-${s.id}`}
                disabled={locked}
                onClick={() => onSelectScenario(s.id)}
                className="desk-card text-left"
                style={{ background: locked ? '#F5F5F5' : '#fff' }}
              >
                <div
                  className="relative flex h-28 items-center justify-center overflow-hidden rounded-t-[20px]"
                  style={{ background: locked ? '#E8E8E8' : s.color }}
                >
                  <span className="text-6xl select-none">{s.icon}</span>
                  {locked && (
                    <div className="absolute inset-0 flex items-center justify-center bg-black/20 rounded-t-[20px]">
                      <Lock size={24} className="text-white drop-shadow" />
                    </div>
                  )}
                </div>
                <div className="px-4 py-3">
                  <b className="block text-base font-black" style={{ color: locked ? '#aaa' : '#263747' }}>
                    {s.name}
                  </b>
                  {g && (
                    <p className="mt-0.5 text-xs font-bold text-teal">{g.character.split(',')[0]}</p>
                  )}
                  <span className="text-xs font-bold" style={{ color: locked ? '#bbb' : '#0D9488' }}>
                    {locked ? `🔒 ${s.required} XP necessaris` : '✓ Disponible'}
                  </span>
                </div>
              </button>
            );
          })}
        </div>
      </div>
    </main>
  );
}
