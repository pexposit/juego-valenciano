import { useEffect, useMemo, useState } from 'react';
import { Home, BookHeart, GraduationCap, RotateCcw } from 'lucide-react';
import { islandById } from './content';
import { RoundCaption, RoundView } from './games/RoundView';
import { unlockCromo } from './progress';
import { say, sfxFanfare, stopVoice } from './sound';
import './kids.css';

/** Una illa: sessió d'unes 12 rondes de jocs variats; en acabar, el cromo de l'illa per a l'àlbum. */
export function KidsIsland({ id, uid, onHome, onAlbum, onLesson }: { id: string | undefined; uid: string | undefined; onHome: () => void; onAlbum: () => void; onLesson: (id: string) => void }) {
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
        <>
          {/* Amb la llengua materna activada, la consigna escrita i traduïda. */}
          <RoundCaption key={`c-${session}-${index}`} round={rounds[index]} className="kid-lesson-caption" onlyTranslated />
          <RoundView key={`${session}-${index}`} round={rounds[index]} onDone={() => void next()} />
        </>
      ) : (
        <div className="kid-finish">
          <div className="kid-confetti" aria-hidden="true">{Array.from({ length: 24 }, (_, i) => <i key={i} style={{ left: `${(i * 41) % 100}%`, animationDelay: `${(i % 8) * 0.12}s` }} />)}</div>
          <div className="kid-cromo kid-cromo-win">
            <span className="kid-cromo-emoji">{island.cromo.emoji}</span>
            <span className="kid-cromo-name">{island.cromo.name}</span>
          </div>
          <div className="kid-finish-actions">
            <button onClick={onAlbum} aria-label="Vés a l'àlbum de cromos" className="kid-big-btn btn-press" style={{ background: '#F97316' }}><BookHeart className="h-10 w-10" /></button>
            {island.lesson && (
              <button onClick={() => onLesson(island.lesson!)} aria-label="Aprèn més en la lliçó" className="kid-big-btn btn-press" style={{ background: '#7C3AED' }}><GraduationCap className="h-10 w-10" /></button>
            )}
            <button onClick={again} aria-label="Torna a jugar" className="kid-big-btn btn-press" style={{ background: '#2CA99B' }}><RotateCcw className="h-10 w-10" /></button>
            <button onClick={onHome} aria-label="Tornar a les illes" className="kid-big-btn btn-press" style={{ background: '#3B82F6' }}><Home className="h-10 w-10" /></button>
          </div>
        </div>
      )}
    </main>
  );
}
