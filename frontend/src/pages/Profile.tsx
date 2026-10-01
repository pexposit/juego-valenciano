import { useState } from 'react';
import { Check, LogOut, Pencil, RotateCcw } from 'lucide-react';
import { OrangeHeader, Stat } from '../components/ui';
import { LEVEL_OPTIONS } from '../data/content';

const FIELD_CLASS = 'mt-1 w-full rounded-2xl border-2 border-gray-100 p-3 font-normal outline-none focus:border-[#0F47AF] transition-colors';

const levelLabel = (value: string) => LEVEL_OPTIONS.find(o => o.value === value)?.label ?? value;

export function Profile({
  name, setName, level, xp, back, onLogOut, isDemo,
}: {
  name: string;
  setName: (v: string) => void;
  level: string;
  xp: number;
  back: () => void;
  onLogOut: () => void;
  isDemo: boolean;
}) {
  // Només el nom és editable, i no directament: cal prémer el llapis primer,
  // i el canvi no es desa a la BD fins que es confirma (botó del check).
  const [editing, setEditing] = useState(false);
  const [draftName, setDraftName] = useState(name);

  const startEditing = () => {
    setDraftName(name);
    setEditing(true);
  };

  const confirmEditing = () => {
    const trimmed = draftName.trim();
    if (trimmed && trimmed !== name) setName(trimmed);
    setEditing(false);
  };

  return (
    <main className="fade-up" style={{ background: '#FAFAF9', minHeight: '100vh' }}>
      <OrangeHeader showOranges={false}>
        <div className="px-5 pb-2">
           <button
            onClick={back}
            className="text-xl btn-press rounded-full bg-white/90 px-4 py-2 text-sm font-extrabold text-teal shadow hover:bg-white transition-colors"
          >
            ← Tornar
          </button>
        </div>
      </OrangeHeader>

      <div className="mx-auto max-w-lg px-5 pt-6 pb-10">
        <h1 className="text-3xl font-black">El teu perfil</h1>

        <div className="mt-5 rounded-3xl bg-white p-6 shadow-sm space-y-4">
          <div className="flex items-center justify-between">
            <span className="font-extrabold text-sm opacity-60">Les teues dades</span>
            <button
              onClick={() => (editing ? confirmEditing() : startEditing())}
              id="profile-edit-toggle"
              aria-label={editing ? 'Guarda el nom' : 'Edita el nom'}
              className="btn-press grid h-9 w-9 place-items-center rounded-full bg-gray-50 text-gray-500 hover:bg-gray-100 hover:text-[#0F47AF] transition-colors"
            >
              {editing ? <Check size={16} /> : <Pencil size={16} />}
            </button>
          </div>

          {editing ? (
            <label className="block font-extrabold text-sm">
              Nom
              <input
                value={draftName}
                onChange={e => setDraftName(e.target.value)}
                onKeyDown={e => { if (e.key === 'Enter') confirmEditing(); }}
                id="profile-name"
                autoFocus
                className={FIELD_CLASS}
              />
            </label>
          ) : (
            <div>
              <span className="block font-extrabold text-sm">Nom</span>
              <span id="profile-name" className="mt-1 block p-3 font-normal">{name}</span>
            </div>
          )}

          <div>
            <span className="block font-extrabold text-sm">Nivell</span>
            <span id="profile-level" className="mt-1 block p-3 font-normal">{levelLabel(level)}</span>
          </div>
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
