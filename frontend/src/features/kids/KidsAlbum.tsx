import { useEffect, useRef, useState, type PointerEvent } from 'react';
import { Home, Trash2 } from 'lucide-react';
import { ISLANDS } from './content';
import { loadBoard, loadCromos, saveBoard, type Sticker } from './progress';
import { say, sfxPop, sfxTick, stopVoice } from './sound';
import './kids.css';

/**
 * Àlbum de cromos: a dalt, la col·lecció (un cromo per illa acabada); a baix, una
 * pàgina per a decorar lliurement: tocar un cromo el posa en la pàgina i es pot
 * arrossegar on vulga. Arrossegar-lo a la paperera el lleva.
 */
export function KidsAlbum({ uid, onHome }: { uid: string | undefined; onHome: () => void }) {
  const [cromos, setCromos] = useState<string[]>([]);
  const [stickers, setStickers] = useState<Sticker[]>(() => loadBoard(uid));
  const [drag, setDrag] = useState<{ id: string; dx: number; dy: number }>();
  const page = useRef<HTMLDivElement>(null);
  const bin = useRef<HTMLDivElement>(null);

  useEffect(() => {
    let cancelled = false;
    void loadCromos(uid).then(c => { if (!cancelled) setCromos(c); });
    const timer = window.setTimeout(() => void say('album'), 400);
    return () => {
      cancelled = true;
      window.clearTimeout(timer);
      stopVoice();
    };
  }, [uid]);

  useEffect(() => saveBoard(uid, stickers), [uid, stickers]);

  const add = (island: string) => {
    sfxPop();
    setStickers(s => [...s, {
      id: `${island}-${Date.now()}`,
      island,
      x: 15 + Math.random() * 70,
      y: 15 + Math.random() * 65,
      scale: 0.9 + Math.random() * 0.4,
      rotate: Math.round(Math.random() * 30 - 15),
    }]);
  };

  const percent = (e: PointerEvent) => {
    const box = page.current!.getBoundingClientRect();
    return { x: ((e.clientX - box.left) / box.width) * 100, y: ((e.clientY - box.top) / box.height) * 100 };
  };
  const overBin = (e: PointerEvent) => {
    const box = bin.current?.getBoundingClientRect();
    return !!box && e.clientX >= box.left && e.clientX <= box.right && e.clientY >= box.top && e.clientY <= box.bottom;
  };

  return (
    <main className="kids-world kids-album">
      <header className="kids-bar">
        <button onClick={onHome} aria-label="Tornar a les illes" className="kid-round-btn btn-press"><Home className="h-8 w-8" /></button>
        <span className="kids-island-badge" aria-hidden="true">📒</span>
      </header>

      <div className="kid-collection">
        {ISLANDS.map(island => {
          const owned = cromos.includes(island.id);
          return (
            <button
              key={island.id}
              disabled={!owned}
              onClick={() => add(island.id)}
              aria-label={owned ? island.cromo.name : 'Cromo per guanyar'}
              className={`kid-cromo btn-press ${owned ? '' : 'kid-cromo-locked'}`}
              style={{ ['--island' as string]: island.color }}
            >
              <span className="kid-cromo-emoji">{owned ? island.cromo.emoji : island.emoji}</span>
            </button>
          );
        })}
      </div>

      <div
        ref={page}
        className="kid-board"
        onPointerMove={e => {
          if (!drag) return;
          const p = percent(e);
          setStickers(s => s.map(st => (st.id === drag.id ? { ...st, x: Math.min(95, Math.max(5, p.x - drag.dx)), y: Math.min(92, Math.max(8, p.y - drag.dy)) } : st)));
        }}
        onPointerUp={e => {
          if (drag && overBin(e)) {
            sfxPop();
            setStickers(s => s.filter(st => st.id !== drag.id));
          }
          setDrag(undefined);
        }}
      >
        {stickers.map(st => {
          const island = ISLANDS.find(i => i.id === st.island);
          if (!island) return null;
          return (
            <span
              key={st.id}
              className={`kid-sticker ${drag?.id === st.id ? 'kid-lifted' : ''}`}
              style={{ left: `${st.x}%`, top: `${st.y}%`, transform: `translate(-50%, -50%) rotate(${st.rotate}deg) scale(${st.scale})` }}
              onPointerDown={e => {
                e.currentTarget.setPointerCapture(e.pointerId);
                sfxTick();
                const p = percent(e);
                setDrag({ id: st.id, dx: p.x - st.x, dy: p.y - st.y });
              }}
              aria-label={island.cromo.name}
            >
              {island.cromo.emoji}
            </span>
          );
        })}
        <div ref={bin} className={`kid-bin ${drag ? 'show' : ''}`} aria-hidden="true"><Trash2 className="h-8 w-8" /></div>
      </div>
    </main>
  );
}
