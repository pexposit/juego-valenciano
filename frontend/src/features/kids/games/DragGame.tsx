import { useMemo, useRef, useState, type CSSProperties, type PointerEvent } from 'react';
import { FAMILY, FOOD, HOME_PLACES, type KidsItem, type Round } from '../content';
import { say, sfxCorrect, sfxTick } from '../sound';
import { useRound } from '../useRound';
import { SpeakerButton } from './SpeakerButton';

type DragRound = Extract<Round, { kind: 'drag' }>;
type Zone = { id: string; emoji?: string; style: CSSProperties; className?: string };

// Zones de cada escena. En el monstre, cada part del cos té el seu lloc (en %).
const MONSTER_ZONES: Zone[] = [
  { id: 'barret', style: { left: '50%', top: '-3%' } },
  { id: 'cap', style: { left: '50%', top: '9%' } },
  { id: 'ulls', style: { left: '50%', top: '22%' } },
  { id: 'nas', style: { left: '50%', top: '32%' } },
  { id: 'boca', style: { left: '50%', top: '42%' } },
  { id: 'braç', style: { left: '12%', top: '52%' } },
  { id: 'mà', style: { left: '88%', top: '52%' } },
  { id: 'cama', style: { left: '36%', top: '80%' } },
  { id: 'peu', style: { left: '64%', top: '80%' } },
  { id: 'sabates', style: { left: '50%', top: '95%' } },
];

function sceneZones(scene: DragRound['scene']): Zone[] {
  switch (scene) {
    case 'plat': return [{ id: 'plat', emoji: '🍽️', style: { left: '50%', top: '45%' }, className: 'kid-zone-big' }];
    case 'motxilla': return [{ id: 'motxilla', emoji: '🎒', style: { left: '50%', top: '45%' }, className: 'kid-zone-big' }];
    case 'monstre': return MONSTER_ZONES;
    case 'casa': return HOME_PLACES.map((h, i) => ({ id: h.id, emoji: h.emoji, style: { left: `${18 + i * 32}%`, top: '45%' }, className: 'kid-zone-big' }));
  }
}

// Elements que es poden arrossegar: els de les tasques i, en el plat, la motxilla
// i la casa, algun que no s'ha de moure (perquè el xiquet tria).
function sceneItems(round: DragRound): KidsItem[] {
  const needed = [...new Map(round.tasks.map(t => [t.item.id, t.item])).values()];
  const pool = round.scene === 'casa' ? FAMILY : round.scene === 'monstre' ? [] : FOOD;
  const extra = pool.filter(p => !needed.some(n => n.id === p.id)).sort(() => Math.random() - 0.5).slice(0, 2);
  return [...needed, ...extra].sort(() => Math.random() - 0.5);
}

/** B. Arrossegar a l'hàbitat i E. Vesteix el personatge: portar cada element al seu lloc. */
export function DragGame({ round, onDone }: { round: DragRound; onDone: () => void }) {
  const [step, setStep] = useState(0);
  const task = round.tasks[step];
  const { locked, repeat, win, miss } = useRound(task?.key, onDone);
  const zones = useMemo(() => sceneZones(round.scene), [round.scene]);
  const items = useMemo(() => sceneItems(round), [round]);
  const [placed, setPlaced] = useState<{ item: KidsItem; zone: string }[]>([]);
  const [drag, setDrag] = useState<{ item: KidsItem; x: number; y: number }>();
  const [busy, setBusy] = useState(false);
  const stage = useRef<HTMLDivElement>(null);

  // En el plat, la motxilla i la casa, un element ja col·locat no es torna a moure.
  const usedIds = new Set(placed.map(p => p.item.id));
  const reusable = round.scene === 'casa' ? (id: string) => round.tasks.slice(step).some(t => t.item.id === id) : () => false;

  const position = (e: PointerEvent) => {
    const box = stage.current!.getBoundingClientRect();
    return { x: e.clientX - box.left, y: e.clientY - box.top };
  };

  const start = (item: KidsItem) => (e: PointerEvent<HTMLButtonElement>) => {
    if (locked || busy) return;
    e.currentTarget.setPointerCapture(e.pointerId);
    sfxTick();
    setDrag({ item, ...position(e) });
  };
  const move = (e: PointerEvent) => drag && setDrag({ ...drag, ...position(e) });
  const end = async (e: PointerEvent) => {
    if (!drag) return;
    const { item } = drag;
    setDrag(undefined);
    const zone = document.elementsFromPoint(e.clientX, e.clientY)
      .map(el => (el as HTMLElement).dataset?.zone)
      .find(Boolean);
    if (!zone) return; // l'ha deixat fora: torna al seu lloc, sense penalitzar
    if (!task || item.id !== task.item.id || zone !== task.zone) return miss();

    // Encaix amb efecte d'imant i repetició del nom de l'objecte.
    setPlaced(p => [...p.filter(x => round.scene !== 'casa' || x.item.id !== item.id), { item, zone }]);
    if (step === round.tasks.length - 1) return void win(`w-${item.id}`);
    setBusy(true);
    sfxCorrect();
    await say(`w-${item.id}`);
    setBusy(false);
    setStep(s => s + 1);
  };

  return (
    <div ref={stage} className="kid-stage" onPointerMove={move} onPointerUp={end} onPointerCancel={() => setDrag(undefined)}>
      <SpeakerButton onClick={repeat} />
      <div className={`kid-scene kid-scene-${round.scene}`}>
        {round.scene === 'monstre' && <div className="kid-monster-body" aria-hidden="true" />}
        {zones.map(z => {
          const here = placed.filter(p => p.zone === z.id);
          const active = task?.zone === z.id;
          return (
            <div
              key={z.id}
              data-zone={z.id}
              className={`kid-zone ${z.className ?? ''} ${active && round.scene === 'monstre' ? 'kid-zone-active' : ''} ${round.scene === 'monstre' && !active && !here.length ? 'kid-zone-hidden' : ''}`}
              style={z.style}
            >
              {z.emoji && <span className="kid-zone-emoji" aria-hidden="true">{z.emoji}</span>}
              {here.map(p => <span key={p.item.id} className="kid-placed kid-snap" aria-label={p.item.word}>{p.item.emoji}</span>)}
            </div>
          );
        })}
      </div>
      <div className="kid-tray">
        {items.map(item => {
          const gone = usedIds.has(item.id) && !reusable(item.id);
          return (
            <button
              key={item.id}
              aria-label={item.word}
              disabled={gone}
              onPointerDown={start(item)}
              className={`kid-draggable ${gone ? 'kid-gone' : ''} ${drag?.item.id === item.id ? 'kid-lifted' : ''}`}
            >
              {item.emoji}
            </button>
          );
        })}
      </div>
      {drag && (
        <span
          className="kid-drag-ghost"
          aria-hidden="true"
          style={{ left: drag.x, top: drag.y }}
        >
          {drag.item.emoji}
        </span>
      )}
    </div>
  );
}
