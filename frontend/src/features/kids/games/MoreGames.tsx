import { useEffect, useMemo, useRef, useState } from 'react';
import { itemAudio, type KidsItem, type Round } from '../content';
import { say, sayAll, sfxTick, stopVoice } from '../sound';
import { useRound } from '../useRound';
import { Card, HearButton } from './ChoiceGames';
import { ItemFace } from './ItemFace';
import { SpeakerButton } from './SpeakerButton';

type Props<K extends Round['kind']> = { round: Extract<Round, { kind: K }>; onDone: () => void };

/** Memòria: girar dues cartes; si són iguals es queden girades. En girar-ne una, diu el seu nom. */
export function MemoryGame({ round, onDone }: Props<'memory'>) {
  const { locked, repeat, win } = useRound(round.prompt, onDone);
  const cards = useMemo(
    () => [...round.items, ...round.items].map((item, i) => ({ key: i, item })).sort(() => Math.random() - 0.5),
    [round],
  );
  const [open, setOpen] = useState<number[]>([]);
  const [matched, setMatched] = useState<string[]>([]);
  const [wait, setWait] = useState(false);

  const flip = (key: number, item: KidsItem) => {
    if (locked || wait || open.includes(key) || matched.includes(item.id)) return;
    sfxTick(open.length);
    void say(itemAudio(item));
    if (open.length === 0) return setOpen([key]);
    const first = cards.find(c => c.key === open[0])!;
    setOpen([open[0], key]);
    if (first.item.id === item.id) {
      const now = [...matched, item.id];
      setMatched(now);
      setOpen([]);
      if (now.length === round.items.length) window.setTimeout(() => void win(), 500);
      return;
    }
    // No són iguals: es tornen a girar, sense «boing» (equivocar-se és part del joc).
    setWait(true);
    window.setTimeout(() => {
      setOpen([]);
      setWait(false);
    }, 1100);
  };

  return (
    <div className="kid-stage">
      <SpeakerButton onClick={repeat} />
      <div className={`kid-memory kid-memory-${cards.length}`}>
        {cards.map(({ key, item }) => {
          const shown = open.includes(key) || matched.includes(item.id);
          return (
            <button
              key={key}
              onClick={() => flip(key, item)}
              aria-label={shown ? item.word : 'Carta girada'}
              className={`kid-memory-card ${shown ? 'shown' : ''} ${matched.includes(item.id) ? 'kid-jump' : ''}`}
            >
              <span className="kid-memory-inner">
                <span className="kid-memory-back" aria-hidden="true">⭐</span>
                <span className="kid-memory-front"><ItemFace item={item} letter={round.style === 'letters'} /></span>
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

/** Ordre: tocar els elements en l'ordre de la consigna. Cada encert es queda marcat amb el seu número. */
export function SeqGame({ round, onDone }: Props<'seq'>) {
  const { locked, repeat, win, miss } = useRound(round.prompt, onDone);
  const [step, setStep] = useState(0);
  const [wrong, setWrong] = useState<string>();

  const tap = (item: KidsItem) => {
    if (locked) return;
    const done = round.targets.slice(0, step).some(t => t.id === item.id);
    if (done) return;
    if (item.id === round.targets[step].id) {
      if (step === round.targets.length - 1) {
        setStep(s => s + 1);
        return void win(itemAudio(item));
      }
      sfxTick(step);
      void say(itemAudio(item));
      setStep(s => s + 1);
    } else {
      setWrong(item.id);
      window.setTimeout(() => setWrong(undefined), 600);
      miss(itemAudio(item), round.targets[step]);
    }
  };

  return (
    <div className="kid-stage">
      <SpeakerButton onClick={repeat} />
      <div className={`kid-cards kid-cards-${round.options.length}`}>
        {round.options.map(item => {
          const order = round.targets.findIndex(t => t.id === item.id);
          const done = order >= 0 && order < step;
          return (
            <Card key={item.id} item={item} letter={round.style === 'letters'} state={done ? 'ok' : wrong === item.id ? 'no' : undefined} onTap={() => tap(item)}>
              {done && <span className="kid-seq-badge" aria-hidden="true">{order + 1}</span>}
            </Card>
          );
        })}
      </div>
    </div>
  );
}

/** Classificar: apareix un element (i diu el seu nom) i es toca el calaix on va. */
export function SortGame({ round, onDone }: Props<'sort'>) {
  // La consigna la diu este joc: primer la general i després el nom de l'element.
  const { locked, win, miss } = useRound(undefined, onDone);
  const [step, setStep] = useState(0);
  const [inBins, setInBins] = useState<Record<string, KidsItem[]>>({});
  const [wrong, setWrong] = useState<string>();
  const [fly, setFly] = useState(false);
  const [showing, setShowing] = useState<string>(); // el calaix que s'està presentant
  const first = useRef(true);
  const current = round.items[step];

  // La primera vegada, la consigna i la presentació de cada calaix (bota mentre se'n diu
  // el nom: n'hi ha que només tenen text, com EL i LA); després, el nom de cada element.
  useEffect(() => {
    if (!current) return;
    const intro = first.current;
    first.current = false;
    let cancelled = false;
    const timer = window.setTimeout(async () => {
      if (intro) {
        if (!(await say(round.prompt))) return;
        for (const bin of round.bins) {
          if (cancelled) return;
          setShowing(bin.id);
          const heard = await say(itemAudio(bin));
          setShowing(undefined);
          if (!heard) return;
        }
      }
      if (!cancelled) void say(itemAudio(current.item));
    }, 350);
    return () => {
      cancelled = true;
      setShowing(undefined);
      window.clearTimeout(timer);
      stopVoice();
    };
  }, [current, round.prompt, round.bins]);

  const drop = (bin: KidsItem) => {
    if (locked || fly || !current) return;
    if (bin.id !== current.bin) {
      setWrong(bin.id);
      window.setTimeout(() => setWrong(undefined), 600);
      return miss(itemAudio(bin), current.item);
    }
    setInBins(b => ({ ...b, [bin.id]: [...(b[bin.id] ?? []), current.item] }));
    if (step === round.items.length - 1) {
      setStep(s => s + 1);
      return void win();
    }
    sfxTick(step);
    setFly(true);
    window.setTimeout(() => {
      setFly(false);
      setStep(s => s + 1);
    }, 450);
  };

  return (
    <div className="kid-stage">
      <SpeakerButton onClick={() => current && void sayAll([round.prompt, itemAudio(current.item)])} />
      <div className="kid-sort-current">
        {current && (
          <button
            key={current.item.id}
            onClick={() => void say(itemAudio(current.item))}
            aria-label={current.item.word}
            className={`kid-card kid-sort-item ${fly ? 'kid-sort-fly' : ''}`}
          >
            <ItemFace item={current.item} />
          </button>
        )}
      </div>
      <div className={`kid-sort-bins kid-sort-bins-${round.bins.length}`}>
        {round.bins.map(bin => (
          <div key={bin.id} className="kid-card-wrap kid-sort-bin-wrap">
            <button
              onClick={() => drop(bin)}
              aria-label={bin.word}
              className={`kid-sort-bin ${wrong === bin.id ? 'kid-nope' : ''} ${showing === bin.id ? 'kid-jump' : ''}`}
              style={bin.ink ? { background: `${bin.ink}1f`, borderColor: bin.ink } : undefined}
            >
              <span className="kid-sort-bin-label"><ItemFace item={bin} /></span>
              <span className="kid-sort-bin-items" aria-hidden="true">
                {(inBins[bin.id] ?? []).map(item => <span key={item.id} className="kid-snap" style={item.ink ? { color: item.ink } : undefined}>{item.glyph ?? item.emoji}</span>)}
              </span>
            </button>
            <HearButton item={bin} />
          </div>
        ))}
      </div>
    </div>
  );
}
