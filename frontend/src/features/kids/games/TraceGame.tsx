import { useEffect, useMemo, useRef, useState, type PointerEvent } from 'react';
import type { Round } from '../content';
import { say, sfxTick } from '../sound';
import { useRound } from '../useRound';
import { SpeakerButton } from './SpeakerButton';

type TraceRound = Extract<Round, { kind: 'trace' }>;

const SIZE = 300; // viewBox de l'SVG
const STEP = 17; // separació entre estreles
const RADIUS = 24; // a quina distància del dit s'encén una estrela
const GOAL = 0.85; // proporció d'estreles que cal encendre

// La lletra es dibuixa en un canvas: d'ell es trau la imatge-guia i les estreles
// (una cada STEP píxels dins de la forma), així les dues coincidixen sempre.
function letterShape(glyph: string): { image: string; stars: { x: number; y: number }[] } {
  const canvas = document.createElement('canvas');
  canvas.width = SIZE;
  canvas.height = SIZE;
  const ctx = canvas.getContext('2d');
  if (!ctx) return { image: '', stars: [] };
  ctx.font = `900 ${glyph.length > 1 ? 170 : 230}px Nunito, system-ui, sans-serif`;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillStyle = '#7C3AED';
  ctx.fillText(glyph, SIZE / 2, SIZE / 2);
  const { data } = ctx.getImageData(0, 0, SIZE, SIZE);
  const stars: { x: number; y: number }[] = [];
  for (let y = STEP / 2; y < SIZE; y += STEP) {
    for (let x = STEP / 2; x < SIZE; x += STEP) {
      if (data[(Math.round(y) * SIZE + Math.round(x)) * 4 + 3] > 128) stars.push({ x, y });
    }
  }
  return { image: canvas.toDataURL(), stars };
}

/** D. Traçat dinàmic de grafies especials (ç, ny, tx, tg): seguir l'estela d'estreles amb el dit. */
export function TraceGame({ round, onDone }: { round: TraceRound; onDone: () => void }) {
  const { letter } = round;
  const { locked, repeat, win } = useRound(`lletra-${letter.id}`, onDone);
  const [fontReady, setFontReady] = useState(false);
  useEffect(() => {
    void document.fonts?.ready.then(() => setFontReady(true));
  }, []);
  const { image, stars } = useMemo(() => (fontReady ? letterShape(letter.glyph) : { image: '', stars: [] }), [letter.glyph, fontReady]);
  const [lit, setLit] = useState<Set<number>>(new Set());
  const [trail, setTrail] = useState<{ x: number; y: number }[]>([]);
  const drawing = useRef(false);
  const svg = useRef<SVGSVGElement>(null);

  const point = (e: PointerEvent) => {
    const box = svg.current!.getBoundingClientRect();
    return { x: ((e.clientX - box.left) / box.width) * SIZE, y: ((e.clientY - box.top) / box.height) * SIZE };
  };

  const touch = (e: PointerEvent) => {
    if (!drawing.current || locked) return;
    const p = point(e);
    setTrail(t => [...t.slice(-60), p]);
    setLit(prev => {
      const next = new Set(prev);
      stars.forEach((s, i) => {
        if (Math.hypot(s.x - p.x, s.y - p.y) < RADIUS) next.add(i);
      });
      return next.size === prev.size ? prev : next;
    });
  };

  const done = stars.length > 0 && lit.size / stars.length >= GOAL;
  // Cada poques estreles, un so; en acabar, el so exagerat i la paraula d'exemple.
  useEffect(() => {
    if (lit.size && lit.size % 4 === 0 && !done) sfxTick(lit.size % 12);
  }, [lit.size, done]);
  const celebrated = useRef(false);
  useEffect(() => {
    if (!done || celebrated.current) return;
    celebrated.current = true;
    void (async () => {
      await say(`lletra-${letter.id}`);
      await win(`w-lletra-${letter.id}`);
    })();
  }, [done, letter.id, win]);

  return (
    <div className="kid-stage">
      <SpeakerButton onClick={repeat} />
      <div className="kid-trace">
        <svg
          ref={svg}
          viewBox={`0 0 ${SIZE} ${SIZE}`}
          className={`kid-trace-svg ${done ? 'kid-jump' : ''}`}
          onPointerDown={e => {
            e.currentTarget.setPointerCapture(e.pointerId);
            drawing.current = true;
            touch(e);
          }}
          onPointerMove={touch}
          onPointerUp={() => { drawing.current = false; setTrail([]); }}
          role="img"
          aria-label={`Traça la lletra ${letter.glyph}`}
        >
          {image && <image href={image} x={0} y={0} width={SIZE} height={SIZE} className="kid-trace-glyph" />}
          {trail.length > 1 && <polyline points={trail.map(p => `${p.x},${p.y}`).join(' ')} className="kid-trace-trail" />}
          {stars.map((s, i) => (
            <text key={i} x={s.x} y={s.y} textAnchor="middle" dominantBaseline="central" className={`kid-star ${lit.has(i) ? 'on' : ''}`}>★</text>
          ))}
        </svg>
        <div className={`kid-trace-word ${done ? 'kid-jump' : ''}`} aria-hidden="true">{letter.emoji}</div>
      </div>
    </div>
  );
}
