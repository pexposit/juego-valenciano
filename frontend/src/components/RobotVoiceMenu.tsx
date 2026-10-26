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

  // Una veu ocupada (necessita la GPU i l'ocupa el RAG) es veu però no es pot triar.
  const item = (id: string | undefined, label: string, busy?: string) => (
    <li key={id ?? 'default'}>
      <button
        role="menuitemradio"
        aria-checked={voice === id}
        aria-disabled={Boolean(busy)}
        disabled={Boolean(busy)}
        title={busy}
        onClick={() => choose(id)}
        className="flex w-full items-center justify-between gap-3 rounded-xl px-3 py-1.5 text-left font-bold enabled:hover:bg-cream disabled:cursor-not-allowed disabled:opacity-40"
      >
        {label}
        {voice === id && <Check size={18} className="text-teal" />}
      </button>
    </li>
  );

  // Els grups ixen en l'ordre que els dona el servidor.
  // Si les veus d'un grup estan ocupades, l'avís va una vegada davall del títol.
  const groups = [...new Set(options?.map(o => o.group))]
    .map(group => ({ group, voices: options!.filter(o => o.group === group) }))
    .map(g => ({ ...g, busy: [...new Set(g.voices.map(v => v.busy).filter(Boolean))].join(' · ') }));

  return (
    <div
      role="menu"
      aria-label="Veu del robot"
      className="absolute left-1/2 top-4 z-30 max-h-[calc(100dvh-var(--app-footer,0px)-15rem)] w-64 -translate-x-1/2 overflow-y-auto rounded-2xl bg-white p-2 shadow-xl ring-2 ring-white"
    >
      <p className="px-3 pb-1 pt-1 text-sm font-bold opacity-60">Amb quina veu parle?</p>
      <ul>{item(undefined, 'Per defecte')}</ul>
      {!options && !failed && <p className="flex items-center gap-2 px-3 py-2 text-sm opacity-60"><Loader2 size={16} className="animate-spin" /> Carregant veus…</p>}
      {failed && <p className="px-3 py-2 text-sm text-orange">No hem pogut carregar les veus.</p>}
      {groups.map(({ group, voices, busy }) => (
        <div key={group}>
          <p className="px-3 pb-1 pt-2 text-xs font-bold uppercase opacity-50">{group}</p>
          {busy && <p className="mx-3 mb-1 rounded-lg bg-orange/10 px-2 py-1 text-xs font-bold text-orange">{busy}. Ara no es poden triar.</p>}
          <ul>{voices.map(v => item(v.id, v.label, v.busy))}</ul>
        </div>
      ))}
    </div>
  );
}
