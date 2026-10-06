import { useEffect, useLayoutEffect, useMemo, useRef, useState } from 'react';
import { Check, Hand, X } from 'lucide-react';
import { itemAudio, KIDS_AUDIO, type KidsItem, type Round } from '../content';
import { phraseText, say, sayAll, sfxCorrect, sfxPop, sfxTick, stopVoice } from '../sound';
import { Translation, useKidsTranslation } from '../translations';
import { useRound } from '../useRound';
import { Card } from './ChoiceGames';
import { ItemFace } from './ItemFace';
import { SpeakerButton } from './SpeakerButton';

/*
 * Jocs de la guia Pre-A1, a l'estil de les tasques de Cambridge Pre A1 Starters.
 * Quasi tots van per passos: cada pas té la seua consigna (que es diu en veu alta i es
 * veu escrita, amb la traducció si està activada) i, quan s'encerten tots, la ronda acaba.
 */

type Props<K extends Round['kind']> = { round: Extract<Round, { kind: K }>; onDone: () => void };

/** Consigna escrita del pas actual, amb la traducció davall. */
function StepCaption({ phrase }: { phrase?: string }) {
  const translate = useKidsTranslation();
  if (!phrase) return null;
  return (
    <p className="kid-lesson-caption">
      {phraseText(phrase)}
      <Translation text={translate(phrase)} />
    </p>
  );
}

/** Passos amb consigna: diu la del pas actual en arribar-hi; `next` passa al següent o acaba. */
function useSteps(keys: string[], onDone: () => void) {
  const { locked, win, miss } = useRound(undefined, onDone);
  const [step, setStep] = useState(0);
  const [busy, setBusy] = useState(false);
  const key = keys[step];

  useEffect(() => {
    if (!key) return;
    const timer = window.setTimeout(() => void say(key), 350);
    return () => {
      window.clearTimeout(timer);
      stopVoice();
    };
  }, [key]);

  /** Encert del pas: si era l'últim, celebra i acaba; si no, una pausa i el següent. */
  const next = (word?: string) => {
    if (step === keys.length - 1) {
      setStep(s => s + 1);
      return void win(word);
    }
    sfxCorrect();
    setBusy(true);
    window.setTimeout(() => {
      setBusy(false);
      setStep(s => s + 1);
    }, word ? 1100 : 700);
    if (word) void say(word);
  };
  return { step, key, next, miss, blocked: locked || busy, repeat: () => key && void say(key) };
}

/* ── Escolta i pinta ──────────────────────────────────────────────────── */

export function PaintGame({ round, onDone }: Props<'paint'>) {
  const { step, key, next, miss, blocked, repeat } = useSteps(round.tasks.map(t => t.key), onDone);
  const [brush, setBrush] = useState<string>();
  const [painted, setPainted] = useState<Record<string, string>>({});
  const [wrong, setWrong] = useState<string>();
  const task = round.tasks[step];
  const colorOf = (id: string) => round.palette.find(c => c.id === id)?.color;

  const tapObject = (item: KidsItem) => {
    if (blocked || !task) return;
    if (!brush) return void say('tria-color');
    if (item.id === task.item && brush === task.color) {
      setPainted(p => ({ ...p, [item.id]: brush }));
      return next();
    }
    setWrong(item.id);
    window.setTimeout(() => setWrong(undefined), 600);
    miss(itemAudio(item));
  };

  return (
    <div className="kid-stage">
      <StepCaption phrase={key} />
      <SpeakerButton onClick={repeat} />
      <div className={`kid-cards kid-cards-${round.objects.length}`}>
        {round.objects.map(item => {
          const paint = painted[item.id] ? colorOf(painted[item.id]) : undefined;
          return (
            <button
              key={item.id}
              onClick={() => tapObject(item)}
              aria-label={item.word}
              className={`kid-card kid-paint-obj ${paint ? 'painted' : ''} ${wrong === item.id ? 'kid-nope' : ''}`}
              style={paint ? { background: `radial-gradient(circle, #fff 0 30%, ${paint} 31%)`, borderColor: paint } : undefined}
            >
              <ItemFace item={item} />
            </button>
          );
        })}
      </div>
      <div className="kid-palette" role="radiogroup" aria-label="Colors">
        {round.palette.map(c => (
          <button
            key={c.id}
            role="radio"
            aria-checked={brush === c.id}
            aria-label={c.word}
            onClick={() => {
              setBrush(c.id);
              sfxPop();
              void say(itemAudio(c));
            }}
            className={`kid-palette-color ${brush === c.id ? 'on' : ''}`}
            style={{ background: c.color, borderColor: c.id === 'blanc' ? '#CBD5E1' : '#fff' }}
          />
        ))}
      </div>
    </div>
  );
}

/* ── Escolta i uneix ──────────────────────────────────────────────────── */

export function LinesGame({ round, onDone }: Props<'lines'>) {
  const { step, key, next, miss, blocked, repeat } = useSteps(round.tasks.map(t => t.key), onDone);
  const [joined, setJoined] = useState<{ name: string; person: string }[]>([]);
  const [wrong, setWrong] = useState<string>();
  const [segments, setSegments] = useState<{ x1: number; y1: number; x2: number; y2: number }[]>([]);
  const box = useRef<HTMLDivElement>(null);
  const refs = useRef<Record<string, HTMLElement | null>>({});
  const task = round.tasks[step];

  // Les línies es calculen a partir de la posició real dels botons (i es refan si canvia la mida).
  useLayoutEffect(() => {
    const draw = () => {
      const frame = box.current?.getBoundingClientRect();
      if (!frame) return;
      setSegments(joined.flatMap(({ name, person }) => {
        const a = refs.current[name]?.getBoundingClientRect();
        const b = refs.current[person]?.getBoundingClientRect();
        if (!a || !b) return [];
        return [{ x1: a.right - frame.left, y1: a.top + a.height / 2 - frame.top, x2: b.left - frame.left, y2: b.top + b.height / 2 - frame.top }];
      }));
    };
    draw();
    window.addEventListener('resize', draw);
    return () => window.removeEventListener('resize', draw);
  }, [joined]);

  const tapPerson = (item: KidsItem) => {
    if (blocked || !task || joined.some(j => j.person === item.id)) return;
    if (item.id === task.person) {
      setJoined(j => [...j, { name: task.name, person: item.id }]);
      return next();
    }
    setWrong(item.id);
    window.setTimeout(() => setWrong(undefined), 600);
    miss(itemAudio(item));
  };

  return (
    <div className="kid-stage">
      <StepCaption phrase={key} />
      <SpeakerButton onClick={repeat} />
      <div ref={box} className="kid-lines">
        <svg className="kid-lines-svg" aria-hidden="true">
          {segments.map((s, i) => <line key={i} x1={s.x1} y1={s.y1} x2={s.x2} y2={s.y2} />)}
        </svg>
        <div className="kid-lines-col">
          {round.names.map(name => (
            <button
              key={name.id}
              ref={el => { refs.current[name.id] = el; }}
              onClick={() => void say(itemAudio(name))}
              className={`kid-name-chip ${task?.name === name.id ? 'now' : ''} ${joined.some(j => j.name === name.id) ? 'done' : ''}`}
            >
              {name.word}
            </button>
          ))}
        </div>
        <div className="kid-lines-col kid-lines-people">
          {round.people.map(item => (
            <button
              key={item.id}
              ref={el => { refs.current[item.id] = el; }}
              onClick={() => tapPerson(item)}
              aria-label={item.word}
              className={`kid-card kid-person ${joined.some(j => j.person === item.id) ? 'done' : ''} ${wrong === item.id ? 'kid-nope' : ''}`}
            >
              <ItemFace item={item} />
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}

/* ── Mira i respon: sí o no ───────────────────────────────────────────── */

export function YesNoGame({ round, onDone }: Props<'yesno'>) {
  const { step, key, next, miss, blocked, repeat } = useSteps(round.statements.map(s => s.key), onDone);
  const [wrong, setWrong] = useState<boolean>();
  const statement = round.statements[step] ?? round.statements[round.statements.length - 1];

  const answer = (yes: boolean) => {
    if (blocked || step >= round.statements.length) return;
    if (yes === statement.yes) return next(yes ? 'si' : 'no');
    setWrong(yes);
    window.setTimeout(() => setWrong(undefined), 600);
    miss();
  };

  return (
    <div className="kid-stage">
      <StepCaption phrase={key} />
      <SpeakerButton onClick={repeat} />
      <div key={step} className="kid-card kid-yesno-picture"><ItemFace item={statement.item} /></div>
      <div className="kid-yesno">
        <button onClick={() => answer(true)} aria-label="Sí" className={`kid-yesno-btn yes btn-press ${wrong === true ? 'kid-nope' : ''}`}><Check className="h-12 w-12" /></button>
        <button onClick={() => answer(false)} aria-label="No" className={`kid-yesno-btn no btn-press ${wrong === false ? 'kid-nope' : ''}`}><X className="h-12 w-12" /></button>
      </div>
      <div className="kids-progress kid-yesno-progress" aria-hidden="true">
        {round.statements.map((_, i) => <span key={i} className={i < step ? 'on' : i === step ? 'now' : ''}>●</span>)}
      </div>
    </div>
  );
}

/* ── Escolta i col·loca ───────────────────────────────────────────────── */

export function PlaceGame({ round, onDone }: Props<'place'>) {
  const { step, key, next, miss, blocked, repeat } = useSteps(round.tasks.map(t => t.key), onDone);
  const [picked, setPicked] = useState<string>();
  const [placed, setPlaced] = useState<{ item: KidsItem; zone: string }[]>([]);
  const [wrong, setWrong] = useState<string>();
  const task = round.tasks[step];

  const pick = (item: KidsItem) => {
    if (blocked || placed.some(p => p.item.id === item.id)) return;
    setPicked(item.id);
    sfxTick();
    void say(itemAudio(item));
  };
  const drop = (zone: string, label: string) => {
    if (blocked || !task) return;
    if (!picked) return void say(label);
    if (picked === task.item && zone === task.zone) {
      const item = round.items.find(i => i.id === picked)!;
      setPlaced(p => [...p, { item, zone }]);
      setPicked(undefined);
      return next();
    }
    setWrong(zone);
    window.setTimeout(() => setWrong(undefined), 600);
    miss(label);
  };

  return (
    <div className="kid-stage">
      <StepCaption phrase={key} />
      <SpeakerButton onClick={repeat} />
      <div className="kid-place" style={{ background: round.scene.background }}>
        {round.scene.zones.map(z => (
          <button
            key={z.id}
            onClick={() => drop(z.id, z.label)}
            aria-label={phraseText(z.label)}
            className={`kid-place-zone ${picked ? 'ready' : ''} ${wrong === z.id ? 'kid-nope' : ''}`}
            style={{ left: `${z.left}%`, top: `${z.top}%`, width: `${z.width}%`, height: `${z.height}%`, background: z.tint }}
          >
            {z.emoji && <span className="kid-place-zone-emoji" aria-hidden="true">{z.emoji}</span>}
            <span className="kid-place-zone-label" aria-hidden="true">{phraseText(z.label).replace(/!$/, '')}</span>
            <span className="kid-place-zone-items" aria-hidden="true">
              {placed.filter(p => p.zone === z.id).map(p => <span key={p.item.id} className="kid-snap">{p.item.emoji}</span>)}
            </span>
          </button>
        ))}
      </div>
      <div className="kid-tray">
        {round.items.map(item => {
          const gone = placed.some(p => p.item.id === item.id);
          return (
            <button
              key={item.id}
              onClick={() => pick(item)}
              disabled={gone}
              aria-label={item.word}
              aria-pressed={picked === item.id}
              className={`kid-draggable ${gone ? 'kid-gone' : ''} ${picked === item.id ? 'kid-picked' : ''}`}
            >
              {item.emoji}
            </button>
          );
        })}
      </div>
    </div>
  );
}

/* ── Lletreja ─────────────────────────────────────────────────────────── */

// L'àudio del nom de cada lletra («La pe!»); els dígrafs com LL tenen el seu so propi.
const letterAudio = (letter: string) => {
  const l = letter.toLowerCase();
  if (KIDS_AUDIO[`w-abc-${l}`]) return `w-abc-${l}`;
  if (KIDS_AUDIO[`lletra-${l}`]) return `lletra-${l}`;
  return undefined;
};

export function SpellGame({ round, onDone }: Props<'spell'>) {
  const { locked, repeat, win, miss } = useRound(round.prompt, onDone);
  const tiles = useMemo(() => round.letters.map((letter, i) => ({ letter, i })).sort(() => Math.random() - 0.5), [round]);
  const [used, setUsed] = useState<number[]>([]);
  const [wrong, setWrong] = useState<number>();
  const filled = used.length;

  const tap = (tile: { letter: string; i: number }) => {
    if (locked || used.includes(tile.i)) return;
    if (tile.letter === round.letters[filled]) {
      const now = [...used, tile.i];
      setUsed(now);
      if (now.length === round.letters.length) return void win(itemAudio(round.item));
      sfxTick(filled);
      const audio = letterAudio(tile.letter);
      if (audio) void say(audio);
      return;
    }
    setWrong(tile.i);
    window.setTimeout(() => setWrong(undefined), 600);
    miss(letterAudio(tile.letter));
  };

  return (
    <div className="kid-stage">
      <SpeakerButton onClick={repeat} />
      <div className="kid-card kid-spell-picture"><ItemFace item={round.item} /></div>
      <div className="kid-spell-slots" aria-label={`${filled} de ${round.letters.length} lletres`}>
        {round.letters.map((letter, i) => <span key={i} className={i < filled ? 'on' : ''}>{i < filled ? letter : ''}</span>)}
      </div>
      <div className="kid-spell-tiles">
        {tiles.map(tile => (
          <button
            key={tile.i}
            onClick={() => tap(tile)}
            disabled={used.includes(tile.i)}
            aria-label={tile.letter}
            className={`kid-spell-tile btn-press ${used.includes(tile.i) ? 'used' : ''} ${wrong === tile.i ? 'kid-nope' : ''}`}
          >
            {tile.letter}
          </button>
        ))}
      </div>
    </div>
  );
}

/* ── Busca la diferència ──────────────────────────────────────────────── */

export function DiffGame({ round, onDone }: Props<'diff'>) {
  const { locked, repeat, win, miss } = useRound(round.prompt, onDone);
  const changed = round.b.map((item, i) => (item.id !== round.a[i].id ? i : -1)).filter(i => i >= 0);
  const [found, setFound] = useState<number[]>([]);
  const [wrong, setWrong] = useState<number>();

  const tap = (i: number) => {
    if (locked || found.includes(i)) return;
    if (changed.includes(i)) {
      const now = [...found, i];
      setFound(now);
      if (now.length === changed.length) return void win(itemAudio(round.b[i]));
      sfxCorrect();
      return void say(itemAudio(round.b[i]));
    }
    setWrong(i);
    window.setTimeout(() => setWrong(undefined), 600);
    miss(itemAudio(round.b[i]));
  };

  return (
    <div className="kid-stage">
      <SpeakerButton onClick={repeat} />
      <div className="kid-diff-row kid-diff-a" aria-label="Fila de dalt">
        {round.a.map((item, i) => <span key={i} className="kid-diff-cell"><ItemFace item={item} /></span>)}
      </div>
      <div className="kid-diff-row" aria-label="Fila de baix">
        {round.b.map((item, i) => (
          <button
            key={i}
            onClick={() => tap(i)}
            aria-label={item.word}
            className={`kid-diff-cell kid-diff-btn ${found.includes(i) ? 'found' : ''} ${wrong === i ? 'kid-nope' : ''}`}
          >
            <ItemFace item={item} />
          </button>
        ))}
      </div>
      {changed.length > 1 && (
        <div className="kids-progress kid-yesno-progress" aria-hidden="true">
          {changed.map((_, i) => <span key={i} className={i < found.length ? 'on' : ''}>●</span>)}
        </div>
      )}
    </div>
  );
}

/* ── La Taronjeta diu ─────────────────────────────────────────────────── */

export function SimonGame({ round, onDone }: Props<'simon'>) {
  const { step, key, next, miss, blocked, repeat } = useSteps(round.commands.map(c => c.key), onDone);
  const [states, setStates] = useState<Record<string, 'ok' | 'no'>>({});
  const command = round.commands[step];

  const flash = (id: string, state: 'ok' | 'no') => {
    setStates(s => ({ ...s, [id]: state }));
    window.setTimeout(() => setStates(({ [id]: _removed, ...rest }) => rest), 700);
  };
  const tap = (item: KidsItem) => {
    if (blocked || !command) return;
    if (command.simon && item.id === command.item) {
      flash(item.id, 'ok');
      return next();
    }
    flash(item.id, 'no');
    // Si la Taronjeta ho havia dit, però era una altra cosa, es diu què s'ha tocat.
    miss(command.simon ? itemAudio(item) : undefined);
    // Ha fet una cosa que la Taronjeta no havia dit: s'explica per què no valia.
    if (!command.simon) window.setTimeout(() => void sayAll(['simon-no', command.key]), 400);
  };
  const refuse = () => {
    if (blocked || !command) return;
    if (!command.simon) return next('no-ho-faig');
    flash('refuse', 'no');
    miss();
  };

  return (
    <div className="kid-stage">
      <StepCaption phrase={key} />
      <SpeakerButton onClick={repeat} />
      <div className={`kid-cards kid-cards-${round.options.length}`}>
        {round.options.map(item => <Card key={item.id} item={item} state={states[item.id]} onTap={() => tap(item)} />)}
      </div>
      <button onClick={refuse} className={`kid-simon-refuse btn-press ${states.refuse === 'no' ? 'kid-nope' : ''}`}>
        <Hand className="h-9 w-9" /> {phraseText('no-ho-faig')}
      </button>
    </div>
  );
}
