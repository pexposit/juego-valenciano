import { LogOut, RotateCcw } from 'lucide-react';
import { OrangeHeader, Stat } from '../components/ui';
import { LEVEL_OPTIONS } from '../data/content';

const FIELD_CLASS = 'mt-1 w-full rounded-2xl border-2 border-gray-100 p-3 font-normal outline-none focus:border-[#0D9488] transition-colors';

export function Profile({
  name, setName, level, setLevel, xp, back, onLogOut, isDemo,
}: {
  name: string;
  setName: (v: string) => void;
  level: string;
  setLevel: (v: string) => void;
  xp: number;
  back: () => void;
  onLogOut: () => void;
  isDemo: boolean;
}) {
  return (
    <main className="fade-up" style={{ background: '#FAFAF9', minHeight: '100vh' }}>
      <OrangeHeader showOranges={false}>
        <div className="px-5 pb-2">
          <button
            onClick={back}
            className="btn-press font-bold text-sm"
            style={{ color: '#0D9488' }}
          >
            ← Tornar al mapa
          </button>
        </div>
      </OrangeHeader>

      <div className="mx-auto max-w-lg px-5 pt-6 pb-10">
        <h1 className="text-3xl font-black">El teu progrés 🏆</h1>

        <div className="mt-5 rounded-3xl bg-white p-6 shadow-sm space-y-4">
          <label className="block font-extrabold text-sm">
            Nom
            <input
              value={name}
              onChange={e => setName(e.target.value)}
              id="profile-name"
              className={FIELD_CLASS}
            />
          </label>
          <label className="block font-extrabold text-sm">
            Nivell
            <select
              value={level}
              onChange={e => setLevel(e.target.value)}
              id="profile-level"
              className={`${FIELD_CLASS} bg-white`}
            >
              {LEVEL_OPTIONS.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
            </select>
          </label>
        </div>

        <div className="mt-5 grid grid-cols-2 gap-3">
          <Stat icon="⚡" label="XP total" value={String(xp)} />
          <Stat icon="🗺️" label="Escenaris" value="1 / 6" />
          <Stat icon="💬" label="Paraules" value="24" />
          <Stat icon="🏆" label="Insígnies" value="1" />
        </div>

        <div className="mt-8 flex flex-col gap-3">
          <button
            onClick={() => confirm('Vols reiniciar el teu progrés?') && location.reload()}
            id="profile-reset-btn"
            className="btn-press flex items-center justify-center gap-2 rounded-2xl border-2 border-coral/20 bg-coral/5 py-3 text-sm font-extrabold text-coral hover:bg-coral/10 transition-colors"
          >
            <RotateCcw size={16} /> Reinicia el progrés
          </button>

          {!isDemo && (
            <button
              onClick={() => confirm('Segur que vols tancar la sessió?') && onLogOut()}
              id="profile-logout-btn"
              className="btn-press flex items-center justify-center gap-2 rounded-2xl border-2 border-gray-200 bg-white py-3 text-sm font-extrabold text-gray-500 hover:bg-gray-50 hover:text-gray-700 transition-colors"
            >
              <LogOut size={16} /> Tanca la sessió
            </button>
          )}
        </div>
      </div>
    </main>
  );
}
