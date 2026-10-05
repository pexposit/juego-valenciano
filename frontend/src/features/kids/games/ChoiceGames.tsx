import { useMemo, useState } from 'react';
import type { KidsItem, Round } from '../content';
import { say, sfxPop } from '../sound';
import { useRound } from '../useRound';
import { SpeakerButton } from './SpeakerButton';

type Props<K extends Round['kind']> = { round: Extract<Round, { kind: K }>; onDone: () => void };

// Targeta il·lustrada gran. `state` anima l'encert (bot) o l'error (rebot suau).
function Card({ item, state, onTap, face }: { item: KidsItem; state?: 'ok' | 'no'; onTap: () => void; face?: boolean }) {
  return (
    <button
      onClick={onTap}
      aria-label={item.word}
      className={`kid-card ${face ? 'kid-card-face' : ''} ${state === 'ok' ? 'kid-jump' : state === 'no' ? 'kid-nope' : ''}`}
    >
      <span className="kid-card-emoji" aria-hidden="true">{item.emoji}</span>
    </button>
  );
}

/** A. Toca i escolta, C. L'intrús visual i E. Canvi d'emoció: tocar la il·lustració que es demana. */
export function ChoiceGame({ round, onDone }: Props<'tap' | 'odd'>) {
  const { locked, repeat, win, miss } = useRound(round.prompt, onDone);
  const [states, setStates] = useState<Record<string, 'ok' | 'no'>>({});
  const react = round.kind === 'tap' ? round.react : undefined;
  const faces = round.kind === 'tap' && round.style === 'faces';

  const tap = (item: KidsItem) => {
    if (locked) return;
    if (item.id === round.target.id) {
      setStates(s => ({ ...s, [item.id]: 'ok' }));
      // En «Toca i escolta» es repetix la paraula (o l'onomatopeia de l'animal).
      void win(round.kind === 'odd' ? `w-${item.id}` : react ?? (faces ? undefined : `w-${item.id}`));
    } else {
      setStates(s => ({ ...s, [item.id]: 'no' }));
      window.setTimeout(() => setStates(({ [item.id]: _removed, ...rest }) => rest), 600);
      miss();
    }
  };

  return (
    <div className="kid-stage">
      <SpeakerButton onClick={repeat} />
      <div className={`kid-cards kid-cards-${round.options.length}`}>
        {round.options.map(item => <Card key={item.id} item={item} state={states[item.id]} onTap={() => tap(item)} face={faces} />)}
      </div>
      {faces && <div className="kid-monster-face" aria-hidden="true">👾</div>}
    </div>
  );
}

/** Comptar: on n'hi ha N? (grups de punts, sense xifres: els xiquets encara no llegixen). */
export function DotsGame({ round, onDone }: Props<'dots'>) {
  const { locked, repeat, win, miss } = useRound(round.prompt, onDone);
  const [wrong, setWrong] = useState<number>();
  return (
    <div className="kid-stage">
      <SpeakerButton onClick={repeat} />
      <div className="kid-cards kid-cards-3">
        {round.options.map(n => (
          <button
            key={n}
            aria-label={`${n}`}
            onClick={() => {
              if (locked) return;
              if (n === round.n) void win(`n-${n}`);
              else {
                setWrong(n);
                window.setTimeout(() => setWrong(undefined), 600);
                miss();
              }
            }}
            className={`kid-card kid-dots ${wrong === n ? 'kid-nope' : ''}`}
          >
            {Array.from({ length: n }, (_, i) => <span key={i} className="kid-dot" style={{ animationDelay: `${i * 60}ms` }}>🍬</span>)}
          </button>
        ))}
      </div>
    </div>
  );
}

/** Els colors: explotar les bambolles del color que demana l'àudio. */
export function BubbleGame({ round, onDone }: Props<'bubbles'>) {
  const { locked, repeat, win, miss } = useRound(round.prompt, onDone);
  // 3 bambolles del color demanat i 5 d'altres, en posicions i velocitats diferents.
  const bubbles = useMemo(() => {
    const list = [
      ...Array.from({ length: 3 }, () => round.color),
      ...Array.from({ length: 5 }, (_, i) => round.others[i % round.others.length]),
    ];
    return list
      .map((color, i) => ({ key: i, color, left: 6 + ((i * 37) % 82), delay: (i * 0.7) % 3.2, duration: 6 + (i % 3) * 1.5, size: 84 + (i % 3) * 14 }))
      .sort(() => Math.random() - 0.5);
  }, [round]);
  const [popped, setPopped] = useState<number[]>([]);
  const [wobble, setWobble] = useState<number>();
  const left = bubbles.filter(b => b.color.id === round.color.id && !popped.includes(b.key)).length;

  return (
    <div className="kid-stage">
      <SpeakerButton onClick={repeat} />
      <div className="kid-bubble-field">
        {bubbles.map(b => !popped.includes(b.key) && (
          <button
            key={b.key}
            aria-label={b.color.word}
            onClick={() => {
              if (locked) return;
              if (b.color.id === round.color.id) {
                sfxPop();
                setPopped(p => [...p, b.key]);
                if (left === 1) void win(`w-${round.color.id}`);
              } else {
                setWobble(b.key);
                window.setTimeout(() => setWobble(undefined), 600);
                miss();
              }
            }}
            className={`kid-bubble ${wobble === b.key ? 'kid-nope' : ''}`}
            style={{
              left: `${b.left}%`, width: b.size, height: b.size,
              animationDelay: `${b.delay}s`, animationDuration: `${b.duration}s`,
              background: `radial-gradient(circle at 30% 30%, #ffffffcc 0 12%, ${b.color.color} 13% 100%)`,
              borderColor: b.color.id === 'blanc' ? '#CBD5E1' : 'transparent',
            }}
          />
        ))}
      </div>
    </div>
  );
}

/** Els números: alimentar la Taronjeta comptant en veu alta cada caramel. */
export function CountGame({ round, onDone }: Props<'count'>) {
  const { locked, repeat, win } = useRound(round.prompt, onDone);
  const total = round.n + 3; // sempre en sobren, perquè compte de veres
  const [eaten, setEaten] = useState<number[]>([]);
  const [chomp, setChomp] = useState(0);

  const feed = (i: number) => {
    if (locked || eaten.includes(i)) return;
    const count = eaten.length + 1;
    setEaten(e => [...e, i]);
    setChomp(c => c + 1);
    if (count === round.n) void win(`n-${count}`);
    else void say(`n-${count}`);
  };

  return (
    <div className="kid-stage">
      <SpeakerButton onClick={repeat} />
      <div key={chomp} className={`kid-mascot ${chomp ? 'kid-chomp' : ''}`} aria-hidden="true">🍊</div>
      <div className="kid-count-row">
        {Array.from({ length: total }, (_, i) => (
          <button
            key={i}
            aria-label="caramel"
            disabled={eaten.includes(i)}
            onClick={() => feed(i)}
            className={`kid-candy ${eaten.includes(i) ? 'kid-eaten' : ''}`}
          >
            🍬
          </button>
        ))}
      </div>
      <div className="kid-count-dots" aria-hidden="true">
        {Array.from({ length: round.n }, (_, i) => <span key={i} className={i < eaten.length ? 'on' : ''} />)}
      </div>
    </div>
  );
}
