import { useEffect, useMemo, useState } from 'react';
import { Home, BookHeart, RotateCcw } from 'lucide-react';
import { islandById, type Round } from './content';
import { BubbleGame, ChoiceGame, CountGame, DotsGame } from './games/ChoiceGames';
import { DragGame } from './games/DragGame';
import { TraceGame } from './games/TraceGame';
import { unlockCromo } from './progress';
import { say, sfxFanfare, stopVoice } from './sound';
import './kids.css';

function RoundView({ round, onDone }: { round: Round; onDone: () => void }) {
  switch (round.kind) {
    case 'tap':
    case 'odd': return <ChoiceGame round={round} onDone={onDone} />;
    case 'dots': return <DotsGame round={round} onDone={onDone} />;
    case 'bubbles': return <BubbleGame round={round} onDone={onDone} />;
    case 'count': return <CountGame round={round} onDone={onDone} />;
    case 'drag': return <DragGame round={round} onDone={onDone} />;
    case 'trace': return <TraceGame round={round} onDone={onDone} />;
  }
}

/** Una illa: micro-sessió de 4 o 5 rondes; en acabar, el cromo de l'illa per a l'àlbum. */
export function KidsIsland({ id, uid, onHome, onAlbum }: { id: string | undefined; uid: string | undefined; onHome: () => void; onAlbum: () => void }) {
  const island = islandById(id);
  const [session, setSession] = useState(0);
  const rounds = useMemo(() => island?.rounds() ?? [], [island, session]);
  const [index, setIndex] = useState(0);
  const [finished, setFinished] = useState(false);

  useEffect(() => () => stopVoice(), []);
  // Enllaç a una illa que no existix: torna al mapa.
  useEffect(() => {
    if (!island) onHome();
  }, [island, onHome]);
  if (!island) return null;

  const next = async () => {
    if (index + 1 < rounds.length) return setIndex(i => i + 1);
    setFinished(true);
    const isNew = await unlockCromo(uid, island.id);
    sfxFanfare();
    await new Promise(r => window.setTimeout(r, 500));
    void say(isNew ? 'cromo-nou' : 'be-4');
  };

  const again = () => {
    setSession(s => s + 1);
    setIndex(0);
    setFinished(false);
  };

  return (
    <main className="kids-world" style={{ ['--island' as string]: island.color }}>
      <header className="kids-bar">
        <button onClick={onHome} aria-label="Tornar a les illes" className="kid-round-btn btn-press"><Home className="h-8 w-8" /></button>
        <div className="kids-progress" aria-label={`Ronda ${Math.min(index + 1, rounds.length)} de ${rounds.length}`}>
          {rounds.map((_, i) => <span key={i} className={i < index || finished ? 'on' : i === index ? 'now' : ''}>★</span>)}
        </div>
        <span className="kids-island-badge" aria-hidden="true">{island.emoji}</span>
      </header>

      {!finished ? (
        <RoundView key={`${session}-${index}`} round={rounds[index]} onDone={() => void next()} />
      ) : (
        <div className="kid-finish">
          <div className="kid-confetti" aria-hidden="true">{Array.from({ length: 24 }, (_, i) => <i key={i} style={{ left: `${(i * 41) % 100}%`, animationDelay: `${(i % 8) * 0.12}s` }} />)}</div>
          <div className="kid-cromo kid-cromo-win">
            <span className="kid-cromo-emoji">{island.cromo.emoji}</span>
            <span className="kid-cromo-name">{island.cromo.name}</span>
          </div>
          <div className="kid-finish-actions">
            <button onClick={onAlbum} aria-label="Vés a l'àlbum de cromos" className="kid-big-btn btn-press" style={{ background: '#F97316' }}><BookHeart className="h-10 w-10" /></button>
            <button onClick={again} aria-label="Torna a jugar" className="kid-big-btn btn-press" style={{ background: '#2CA99B' }}><RotateCcw className="h-10 w-10" /></button>
            <button onClick={onHome} aria-label="Tornar a les illes" className="kid-big-btn btn-press" style={{ background: '#3B82F6' }}><Home className="h-10 w-10" /></button>
          </div>
        </div>
      )}
    </main>
  );
}
