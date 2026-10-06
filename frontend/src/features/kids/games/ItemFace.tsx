import type { KidsItem, Pos } from '../content';

// On es posa el gat respecte de la caixa (posició en %, mida relativa a l'amplària de l'escena).
const CAT: Record<Pos, { left: string; top: string; size: number; behind?: boolean }> = {
  dins: { left: '50%', top: '40%', size: 0.4, behind: true },
  fora: { left: '86%', top: '64%', size: 0.36 },
  damunt: { left: '50%', top: '22%', size: 0.4 },
  davall: { left: '50%', top: '82%', size: 0.36 },
  davant: { left: '44%', top: '68%', size: 0.5 },
  darrere: { left: '66%', top: '38%', size: 0.34, behind: true },
  costat: { left: '84%', top: '60%', size: 0.38 },
  entre: { left: '50%', top: '62%', size: 0.3 },
};

/** El gat Pelut i la caixa: dins, fora, damunt, davall, davant, darrere, al costat. */
function PosScene({ pos }: { pos: Pos }) {
  const cat = CAT[pos];
  // Davall de la caixa: la caixa puja i el gat queda baix.
  const boxTop = pos === 'davall' ? '36%' : pos === 'damunt' ? '64%' : '60%';
  const boxLeft = pos === 'fora' ? '30%' : pos === 'costat' ? '40%' : '50%';
  // Entre: dues caixes més xicotetes, una a cada costat del gat.
  const boxes = pos === 'entre'
    ? [{ left: '17%', size: '32cqw' }, { left: '83%', size: '32cqw' }]
    : [{ left: boxLeft, size: '50cqw' }];
  return (
    <span className="kid-pos" aria-hidden="true">
      {boxes.map(b => <span key={b.left} className="kid-pos-item" style={{ left: b.left, top: boxTop, fontSize: b.size, zIndex: 2 }}>📦</span>)}
      <span className="kid-pos-item" style={{ left: cat.left, top: cat.top, fontSize: `${cat.size * 100}cqw`, zIndex: cat.behind ? 1 : 3 }}>🐈</span>
    </span>
  );
}

/** El dibuix d'un element: emoji, taca de color, punts per comptar, lletra o escena. */
export function ItemFace({ item, letter }: { item: KidsItem; letter?: boolean }) {
  if (item.pos) return <PosScene pos={item.pos} />;
  if (item.color) {
    return <span className="kid-card-swatch" aria-hidden="true" style={{ background: item.color, borderColor: item.id.includes('blanc') ? '#CBD5E1' : 'transparent' }} />;
  }
  if (item.count !== undefined && item.count > 0) {
    return (
      <span className={`kid-face-dots ${item.count > 6 ? 'many' : ''}`} aria-hidden="true">
        {Array.from({ length: item.count }, (_, i) => <span key={i} className="kid-dot" style={{ animationDelay: `${i * 50}ms` }}>{item.emoji}</span>)}
      </span>
    );
  }
  if (item.glyph) {
    // Els noms llargs (Vicent, Marta) en lletra més xicoteta perquè càpien en la targeta.
    const long = item.glyph.length > 3 ? { fontSize: `clamp(20px, ${item.glyph.length > 5 ? 4 : 5}vw, ${item.glyph.length > 5 ? 34 : 42}px)` } : undefined;
    return <span className="kid-face-glyph" aria-hidden="true" style={{ color: item.ink, ...long }}>{item.glyph}</span>;
  }
  if (letter) return <span className="kid-card-letter" aria-hidden="true">{item.emoji}</span>;
  return (
    <span
      className={`kid-card-emoji ${item.stack ? 'kid-face-stack' : ''}`}
      aria-hidden="true"
      style={item.scale ? { transform: `scale(${item.scale})` } : undefined}
    >
      {item.emoji}
    </span>
  );
}
