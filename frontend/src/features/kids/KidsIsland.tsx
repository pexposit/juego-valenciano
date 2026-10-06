import { useCallback, useEffect, useRef, useState } from 'react';
import { Home, BookHeart, GraduationCap, Play, RotateCcw } from 'lucide-react';
import type { KidsItem, Round } from './content';
import { RoundCaption, RoundView } from './games/RoundView';
import { nextEase, planSession, stageCount } from './islandSession';
import { islandById } from './lessons';
import { loadCromos, loadPractice, loadStages, markStage, savePractice, stagesDone, unlockCromo, type Practice } from './progress';
import { say, sfxFanfare, stopVoice } from './sound';
import { MissContext } from './useRound';
import './kids.css';

type Session = { key: number; rounds: Round[]; stage: number | null; done: number };

/**
 * Una illa: es juga per etapes curtes (unes cinc rondes, vegeu islandSession.ts). Cada
 * etapa acabada és una estrela de l'illa; amb totes, el cromo de l'illa per a l'àlbum.
 * Després, cada partida és un repàs. El que costa es torna a preguntar més avant i, si
 * una partida costa molt, la següent és més fàcil.
 */
export function KidsIsland({ id, uid, onHome, onAlbum, onLesson }: { id: string | undefined; uid: string | undefined; onHome: () => void; onAlbum: () => void; onLesson: (id: string) => void }) {
  const island = islandById(id);
  const total = island ? stageCount(island) : 1;
  const [session, setSession] = useState<Session>();
  const [index, setIndex] = useState(0);
  const [finished, setFinished] = useState<'stage' | 'cromo'>();
  const practice = useRef<Practice>({ mistakes: [], easy: false });
  const missedRound = useRef(false);
  const misses = useRef(0);

  useEffect(() => () => stopVoice(), []);
  // Enllaç a una illa que no existix: torna al mapa.
  useEffect(() => {
    if (!island) onHome();
  }, [island, onHome]);

  // Una partida nova: la primera etapa per fer o, si ja estan totes, un repàs.
  const start = useCallback(async () => {
    if (!island) return;
    const [stages, cromos] = await Promise.all([loadStages(uid), loadCromos(uid)]);
    const done = cromos.includes(island.id) ? total : Math.min(total, stagesDone(stages, island.id));
    practice.current = loadPractice(uid, island.id);
    const stage = done < total ? done : null;
    missedRound.current = false;
    misses.current = 0;
    setIndex(0);
    setFinished(undefined);
    setSession(s => ({ key: (s?.key ?? 0) + 1, rounds: planSession(island, stage, practice.current), stage, done }));
  }, [island, uid, total]);

  useEffect(() => {
    void start();
  }, [start]);

  const remember = (mistakes: KidsItem[]) => {
    practice.current = { ...practice.current, mistakes };
    if (island) savePractice(uid, island.id, practice.current);
  };

  // Cada error: l'element que calia tocar es guarda per a repassar-lo (els 8 últims).
  const noteMiss = useCallback((expected?: KidsItem) => {
    missedRound.current = true;
    misses.current++;
    if (expected?.word) remember([expected, ...practice.current.mistakes.filter(m => m.id !== expected.id)].slice(0, 8));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [island, uid]);

  if (!island || !session) return null;
  const { rounds } = session;

  const next = async () => {
    // Encertat a la primera: si era una cosa que costava, ja no cal repassar-la.
    const round = rounds[index];
    if (round.kind === 'tap' && !missedRound.current && practice.current.mistakes.some(m => m.id === round.target.id)) {
      remember(practice.current.mistakes.filter(m => m.id !== round.target.id));
    }
    missedRound.current = false;
    if (index + 1 < rounds.length) return setIndex(i => i + 1);

    practice.current = { ...practice.current, easy: nextEase(practice.current, misses.current, rounds.length) };
    savePractice(uid, island.id, practice.current);
    const done = session.stage === null ? total : session.stage + 1;
    if (session.stage !== null) await markStage(uid, island.id, session.stage);
    setSession(s => s && { ...s, done });
    const complete = done >= total;
    const isNew = complete && (await unlockCromo(uid, island.id));
    setFinished(complete ? 'cromo' : 'stage');
    sfxFanfare();
    await new Promise(r => window.setTimeout(r, 500));
    void say(!complete ? 'etapa-feta' : isNew ? 'cromo-nou' : 'be-4');
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
        <MissContext.Provider value={noteMiss}>
          {/* Amb la llengua materna activada, la consigna escrita i traduïda. */}
          <RoundCaption key={`c-${session.key}-${index}`} round={rounds[index]} className="kid-lesson-caption" onlyTranslated />
          <RoundView key={`${session.key}-${index}`} round={rounds[index]} onDone={() => void next()} />
        </MissContext.Provider>
      ) : (
        <div className="kid-finish">
          <div className="kid-confetti" aria-hidden="true">{Array.from({ length: 24 }, (_, i) => <i key={i} style={{ left: `${(i * 41) % 100}%`, animationDelay: `${(i % 8) * 0.12}s` }} />)}</div>
          {finished === 'stage' ? (
            <div className="kid-stage-stars" aria-label={`${session.done} de ${total} parts de l'illa`}>
              {Array.from({ length: total }, (_, i) => <span key={i} className={i < session.done ? 'on' : ''} style={{ animationDelay: `${i * 0.15}s` }}>★</span>)}
            </div>
          ) : (
            <div className="kid-cromo kid-cromo-win">
              <span className="kid-cromo-emoji">{island.cromo.emoji}</span>
              <span className="kid-cromo-name">{island.cromo.name}</span>
            </div>
          )}
          <div className="kid-finish-actions">
            {finished === 'stage' ? (
              <button onClick={() => void start()} aria-label="Continua l'illa" className="kid-big-btn btn-press" style={{ background: '#F97316' }}><Play className="h-10 w-10" /></button>
            ) : (
              <>
                <button onClick={onAlbum} aria-label="Vés a l'àlbum de cromos" className="kid-big-btn btn-press" style={{ background: '#F97316' }}><BookHeart className="h-10 w-10" /></button>
                <button onClick={() => void start()} aria-label="Torna a jugar" className="kid-big-btn btn-press" style={{ background: '#2CA99B' }}><RotateCcw className="h-10 w-10" /></button>
              </>
            )}
            {island.lesson && (
              <button onClick={() => onLesson(island.lesson!)} aria-label="Aprèn més en la lliçó" className="kid-big-btn btn-press" style={{ background: '#7C3AED' }}><GraduationCap className="h-10 w-10" /></button>
            )}
            <button onClick={onHome} aria-label="Tornar a les illes" className="kid-big-btn btn-press" style={{ background: '#3B82F6' }}><Home className="h-10 w-10" /></button>
          </div>
        </div>
      )}
    </main>
  );
}
