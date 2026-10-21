import { useEffect, useState, type RefObject } from 'react';
import { Check, Loader2 } from 'lucide-react';
import { fetchVoiceOptions, type VoiceOption } from '../lib/api';

// Veu triada per al robot, en este navegador. Buida = la veu per defecte del professor.
const VOICE_KEY = 'parlaval:robot:voice';
export const savedRobotVoice = () => {
  try {
    return localStorage.getItem(VOICE_KEY) || undefined;
  } catch {
    return undefined;
  }
};
const saveRobotVoice = (voice: string | undefined) => {
  try {
    if (voice) localStorage.setItem(VOICE_KEY, voice);
    else localStorage.removeItem(VOICE_KEY);
  } catch {
    // Sense storage: la veu només dura mentre la pàgina estiga oberta.
  }
};

// Menú que ix en tocar el robot: tria amb quina veu parla (un locutor del servidor o un model del laboratori de veu).
// `anchor` és el contenidor del robot i del menú: tocar-hi no compta com a tocar fora (el robot mateix obri i tanca el menú).
export function RobotVoiceMenu({ anchor, voice, onChange, onClose }: { anchor: RefObject<HTMLElement>; voice?: string; onChange: (voice: string | undefined) => void; onClose: () => void }) {
  const [options, setOptions] = useState<VoiceOption[] | null>(null);
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    let cancelled = false;
    fetchVoiceOptions()
      .then(found => { if (!cancelled) setOptions(found); })
      .catch(() => { if (!cancelled) setFailed(true); });
    return () => { cancelled = true; };
  }, []);

  // Es tanca amb Escape o tocant fora.
  useEffect(() => {
    const onKey = (event: KeyboardEvent) => event.key === 'Escape' && onClose();
    const onPointer = (event: PointerEvent) => !anchor.current?.contains(event.target as Node) && onClose();
    window.addEventListener('keydown', onKey);
    window.addEventListener('pointerdown', onPointer);
    return () => {
      window.removeEventListener('keydown', onKey);
      window.removeEventListener('pointerdown', onPointer);
    };
  }, [anchor, onClose]);

  const choose = (next: string | undefined) => {
    saveRobotVoice(next);
    onChange(next);
    onClose();
  };

  const item = (id: string | undefined, label: string) => (
    <li key={id ?? 'default'}>
      <button
        role="menuitemradio"
        aria-checked={voice === id}
        onClick={() => choose(id)}
        className="flex w-full items-center justify-between gap-3 rounded-xl px-3 py-2 text-left font-bold hover:bg-cream"
      >
        {label}
        {voice === id && <Check size={18} className="text-teal" />}
      </button>
    </li>
  );

  // Els grups ixen en l'ordre que els dona el servidor.
  const groups = [...new Set(options?.map(o => o.group))]
    .map(group => ({ group, voices: options!.filter(o => o.group === group) }));

  return (
    <div
      role="menu"
      aria-label="Veu del robot"
      className="absolute left-1/2 top-4 z-30 max-h-[70vh] w-64 -translate-x-1/2 overflow-y-auto rounded-2xl bg-white p-2 shadow-xl ring-2 ring-white"
    >
      <p className="px-3 pb-1 pt-1 text-sm font-bold opacity-60">Amb quina veu parle?</p>
      <ul>{item(undefined, 'Per defecte')}</ul>
      {!options && !failed && <p className="flex items-center gap-2 px-3 py-2 text-sm opacity-60"><Loader2 size={16} className="animate-spin" /> Carregant veus…</p>}
      {failed && <p className="px-3 py-2 text-sm text-orange">No hem pogut carregar les veus.</p>}
      {groups.map(({ group, voices }) => (
        <div key={group}>
          <p className="px-3 pb-1 pt-2 text-xs font-bold uppercase opacity-50">{group}</p>
          <ul>{voices.map(v => item(v.id, v.label))}</ul>
        </div>
      ))}
    </div>
  );
}
