import { useState } from 'react';
import { BarChart3, Check, LogOut, Pencil, RotateCcw, School } from 'lucide-react';
import { OrangeHeader, Stat } from '../components/ui';
import { motherTongueLabel } from '@parlaval/shared';
import { LEVEL_OPTIONS, MOTHER_TONGUE_OPTIONS } from '../data/content';

const FIELD_CLASS = 'mt-1 w-full rounded-2xl border-2 border-gray-100 p-3 text-2xl font-normal outline-none focus:border-[#0F47AF] transition-colors';

const levelLabel = (value: string) => LEVEL_OPTIONS.find(o => o.value === value)?.label ?? value;

export function Profile({
  name, setName, level, xp, back, onLogOut, isDemo, ageGroup, motherTongue, setMotherTongue, showMotherTongue, setShowMotherTongue,
  onProgress, isTeacher, onClasses,
}: {
  name: string;
  setName: (v: string) => void;
  level: string;
  xp: number;
  back: () => void;
  onLogOut: () => void;
  isDemo: boolean;
  ageGroup: string;
  motherTongue: string | null;
  setMotherTongue: (v: string) => void;
  showMotherTongue: boolean;
  setShowMotherTongue: (v: boolean) => void;
  onProgress: () => void;
  isTeacher: boolean;
  onClasses: () => void;
}) {
  const isChild = ageGroup === 'child';
  // La llengua materna i l'ajuda amb la traducció són per als xiquets i per a qui està en el Nivell 0.
  const hasHelp = isChild || level === 'nivell0';
  // El nom (i, en els comptes infantils, la llengua materna) són editables, però no directament:
  // cal prémer el llapis primer, i el canvi no es desa a la BD fins que es confirma (botó «Confirma els canvis» davall de les dades).
  const [editing, setEditing] = useState(false);
  const [draftName, setDraftName] = useState(name);
  const [draftTongue, setDraftTongue] = useState(motherTongue ?? '');

  const startEditing = () => {
    setDraftName(name);
    setDraftTongue(motherTongue ?? '');
    setEditing(true);
  };

  const confirmEditing = () => {
    const trimmed = draftName.trim();
    if (trimmed && trimmed !== name) setName(trimmed);
    if (hasHelp && draftTongue && draftTongue !== motherTongue) setMotherTongue(draftTongue);
    setEditing(false);
  };

  // L'ajuda en la llengua materna només té sentit amb una llengua materna que no siga el valencià.
  const helpLanguage = hasHelp && motherTongue && motherTongue !== 'ca' && motherTongue !== 'other'
    ? motherTongueLabel(motherTongue)
    : undefined;

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
        <h1 className="text-5xl font-black">El teu perfil</h1>

        <div className="mt-5 rounded-3xl bg-white p-6 shadow-sm space-y-4">
          <div className="flex items-center justify-between">
            <span className="font-extrabold text-xl opacity-60">Les teues dades</span>
            {!editing && (
              <button
                onClick={startEditing}
                id="profile-edit-toggle"
                aria-label="Edita les dades"
                className="btn-press grid h-11 w-11 place-items-center rounded-full bg-gray-50 text-gray-500 hover:bg-gray-100 hover:text-[#0F47AF] transition-colors"
              >
                <Pencil size={20} />
              </button>
            )}
          </div>

          {editing ? (
            <label className="block font-extrabold text-xl">
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
              <span className="block font-extrabold text-xl">Nom</span>
              <span id="profile-name" className="mt-1 block p-3 text-2xl font-normal">{name}</span>
            </div>
          )}

          <div>
            <span className="block font-extrabold text-xl">Nivell</span>
            <span id="profile-level" className="mt-1 block p-3 text-2xl font-normal">{isChild ? 'Xiquet' : levelLabel(level)}</span>
          </div>

          {hasHelp && (
            editing ? (
              <label className="block font-extrabold text-xl">
                Llengua materna
                <select
                  value={draftTongue}
                  onChange={e => setDraftTongue(e.target.value)}
                  id="profile-mother-tongue"
                  className={`${FIELD_CLASS} bg-white`}
                >
                  {!draftTongue && <option value="" disabled>Tria una llengua</option>}
                  {MOTHER_TONGUE_OPTIONS.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
                </select>
              </label>
            ) : (
              <div>
                <span className="block font-extrabold text-xl">Llengua materna</span>
                <span id="profile-mother-tongue" className="mt-1 block p-3 text-2xl font-normal">{motherTongueLabel(motherTongue) ?? 'Sense indicar'}</span>
              </div>
            )
          )}

          {editing && (
            <div className="flex flex-wrap gap-3 pt-2">
              <button
                onClick={confirmEditing}
                id="profile-confirm"
                className="btn-press inline-flex items-center gap-2 rounded-full bg-[#0F47AF] px-6 py-3 text-lg font-black text-white shadow hover:bg-[#0F47AF]/90 transition-colors"
              >
                <Check size={20} /> Confirma els canvis
              </button>
              <button
                onClick={() => setEditing(false)}
                id="profile-cancel"
                className="btn-press rounded-full bg-gray-100 px-6 py-3 text-lg font-extrabold text-gray-600 hover:bg-gray-200 transition-colors"
              >
                Cancel·la
              </button>
            </div>
          )}
        </div>

        {helpLanguage && (
          <div className="mt-5 flex items-center justify-between gap-4 rounded-3xl bg-white p-6 shadow-sm">
            <div>
              <span id="profile-mother-tongue-label" className="block font-extrabold text-xl">Ajuda en la meua llengua</span>
              <span className="mt-1 block text-lg font-normal opacity-70">
                Mostra, en gris, la traducció en {helpLanguage.toLowerCase()} dels missatges del professor.
              </span>
            </div>
            <button
              role="switch"
              aria-checked={showMotherTongue}
              aria-labelledby="profile-mother-tongue-label"
              id="profile-mother-tongue-toggle"
              onClick={() => setShowMotherTongue(!showMotherTongue)}
              className={`btn-press relative h-8 w-14 shrink-0 rounded-full transition-colors ${showMotherTongue ? 'bg-[#0F47AF]' : 'bg-gray-300'}`}
            >
              <span className={`absolute top-1 h-6 w-6 rounded-full bg-white shadow transition-all ${showMotherTongue ? 'left-7' : 'left-1'}`} />
            </button>
          </div>
        )}

        <div className="mt-8 flex flex-col gap-3">
          {/* El seguiment del xiquet (compte infantil) o les classes (només el professorat). */}
          {isChild ? (
            <button
              onClick={onProgress}
              id="profile-progress-btn"
              className="btn-press flex items-center justify-center gap-2 rounded-2xl bg-[#0F47AF] py-3 text-xl font-extrabold text-white hover:opacity-90 transition-opacity"
            >
              <BarChart3 size={20} /> Seguiment per a la família
            </button>
          ) : isTeacher && (
            <button
              onClick={onClasses}
              id="profile-classes-btn"
              className="btn-press flex items-center justify-center gap-2 rounded-2xl bg-[#0F47AF] py-3 text-xl font-extrabold text-white hover:opacity-90 transition-opacity"
            >
              <School size={20} /> Les meues classes (professorat)
            </button>
          )}

          <button
            onClick={() => confirm('Vols reiniciar el teu progrés?') && location.reload()}
            id="profile-reset-btn"
            className="btn-press flex items-center justify-center gap-2 rounded-2xl border-2 border-coral/20 bg-coral/5 py-3 text-xl font-extrabold text-coral hover:bg-coral/10 transition-colors"
          >
            <RotateCcw size={20} /> Reinicia el progrés
          </button>

          {!isDemo && (
            <button
              onClick={() => confirm('Segur que vols tancar la sessió?') && onLogOut()}
              id="profile-logout-btn"
              className="btn-press flex items-center justify-center gap-2 rounded-2xl border-2 border-gray-200 bg-white py-3 text-xl font-extrabold text-gray-500 hover:bg-gray-50 hover:text-gray-700 transition-colors"
            >
              <LogOut size={20} /> Tanca la sessió
            </button>
          )}
        </div>
      </div>
    </main>
  );
}
