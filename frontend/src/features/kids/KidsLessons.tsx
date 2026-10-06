import { useEffect, useMemo, useState } from 'react';
import { ChevronLeft, ChevronRight, Gamepad2, GraduationCap, RotateCcw } from 'lucide-react';
import { itemAudio, type KidsItem } from './content';
import { RoundCaption, RoundView } from './games/RoundView';
import { ItemFace } from './games/ItemFace';
import { lessonById, type LessonPage } from './lessons';
import { markLessonDone } from './progress';
import { saveLessonDone } from './tracking';
import { phraseText, say, sfxCorrect, sfxFanfare, sfxTick, stopVoice } from './sound';
import { Translation, useKidsTranslation } from './translations';
import './kids.css';

/* ── Peces comunes ────────────────────────────────────────────────────── */

// L'article de color: blau per a el/els/un, rosa per a la/les/una i morat per a l'.
const ARTICLE = /^(els |el |les |la |l'|unes |uns |una |un )/i;
function Label({ text }: { text: string }) {
  const m = text.match(ARTICLE);
  if (!m) return <span className="kid-label">{text}</span>;
  const art = m[1].trim().toLowerCase();
  const tone = art === "l'" ? 'l' : ['la', 'les', 'una', 'unes'].includes(art) ? 'la' : 'el';
  return (
    <span className="kid-label">
      <b className={`kid-art kid-art-${tone}`}>{m[1].trimEnd()}</b>
      {m[1].endsWith(' ') ? ' ' : ''}{text.slice(m[1].length)}
    </span>
  );
}

/** Pictograma de lliçó: dibuix + paraula escrita. Tocar-lo diu el nom. */
function Picto({ item, onTap, heard, size = 'md' }: { item: KidsItem; onTap: () => void; heard?: boolean; size?: 'md' | 'lg' }) {
  const [hop, setHop] = useState(0);
  return (
    <button
      onClick={() => {
        setHop(h => h + 1);
        onTap();
      }}
      aria-label={item.word}
      className={`kid-picto kid-picto-${size} ${heard ? 'heard' : ''}`}
    >
      <span key={hop} className={`kid-picto-face ${hop ? 'kid-hop' : ''}`}><ItemFace item={item} /></span>
      <Label text={item.word} />
      {heard && <span className="kid-picto-star" aria-hidden="true">★</span>}
    </button>
  );
}

/**
 * La Taronjeta explica: el bocadillo amb el text del que diu i, si el perfil ho té activat,
 * la traducció a la llengua materna davall. Tocar-la ho repetix.
 */
function Bubble({ phrase, onRepeat, talking }: { phrase: string; onRepeat: () => void; talking: boolean }) {
  const translate = useKidsTranslation();
  return (
    <div className="kid-lesson-bubble">
      <button onClick={onRepeat} aria-label="Escolta una altra vegada" className={`kid-lesson-mascot btn-press ${talking ? 'talking' : ''}`}>
        <span aria-hidden="true">🍊</span>
      </button>
      <p>
        {phraseText(phrase)}
        <Translation text={translate(phrase)} />
      </p>
    </div>
  );
}

/** Diu la frase de la pàgina en entrar-hi; `talking` mentre sona; `onEnd` quan acaba sense interrupcions. */
function useNarration(key: string | undefined, onEnd?: () => void) {
  const [talking, setTalking] = useState(false);
  const play = () => {
    if (!key) return;
    setTalking(true);
    void say(key).then(ok => {
      setTalking(false);
      if (ok) onEnd?.();
    });
  };
  useEffect(() => {
    const timer = window.setTimeout(play, 400);
    return () => {
      window.clearTimeout(timer);
      stopVoice();
    };
    // Només en entrar a la pàgina.
  }, [key]);
  return { talking, play };
}

const speak = (item: KidsItem) => void say(itemAudio(item));

/* ── Pàgines ──────────────────────────────────────────────────────────── */

type PageProps<K extends LessonPage['kind']> = { page: Extract<LessonPage, { kind: K }>; onReady: () => void; onDone: () => void };

function IntroPage({ page, onReady }: PageProps<'intro'>) {
  const { talking, play } = useNarration(page.say, onReady);
  return (
    <div className="kid-lesson-page">
      <div className="kid-lesson-hero" aria-hidden="true">{page.emoji}</div>
      <Bubble phrase={page.say} onRepeat={play} talking={talking} />
    </div>
  );
}

function ItemsPage({ page, onReady }: PageProps<'explain' | 'summary'>) {
  const { talking, play } = useNarration(page.say, onReady);
  const size = page.items.length <= 3 ? 'lg' : 'md';
  return (
    <div className="kid-lesson-page">
      <Bubble phrase={page.say} onRepeat={play} talking={talking} />
      <div className={`kid-picto-grid ${page.kind === 'summary' ? 'kid-summary' : ''}`}>
        {page.items.map(item => <Picto key={item.id} item={item} size={size} onTap={() => speak(item)} />)}
      </div>
    </div>
  );
}

function DiscoverPage({ page, onReady }: PageProps<'discover'>) {
  const { talking, play } = useNarration(page.say);
  const [heard, setHeard] = useState<string[]>([]);
  const tap = (item: KidsItem) => {
    speak(item);
    if (!heard.includes(item.id)) sfxTick(heard.length);
    setHeard(h => (h.includes(item.id) ? h : [...h, item.id]));
  };
  useEffect(() => {
    if (heard.length === page.items.length) onReady();
  }, [heard, page.items.length, onReady]);
  return (
    <div className="kid-lesson-page">
      <Bubble phrase={page.say} onRepeat={play} talking={talking} />
      <div className="kid-picto-grid">
        {page.items.map(item => <Picto key={item.id} item={item} heard={heard.includes(item.id)} onTap={() => tap(item)} />)}
      </div>
      <div className="kid-heard-meter" aria-label={`${heard.length} de ${page.items.length}`}>
        {page.items.map((item, i) => <span key={item.id} className={i < heard.length ? 'on' : ''}>★</span>)}
      </div>
    </div>
  );
}

function PairsPage({ page, onReady }: PageProps<'pairs'>) {
  const { talking, play } = useNarration(page.say, onReady);
  return (
    <div className="kid-lesson-page">
      <Bubble phrase={page.say} onRepeat={play} talking={talking} />
      <div className="kid-pairs">
        {page.pairs.map(([a, b]) => (
          <div key={`${a.id}-${b.id}`} className="kid-pair">
            <Picto item={a} onTap={() => speak(a)} />
            <span className="kid-pair-arrow" aria-hidden="true">⇄</span>
            <Picto item={b} onTap={() => speak(b)} />
          </div>
        ))}
      </div>
    </div>
  );
}

function MixPage({ page, onReady }: PageProps<'mix'>) {
  const { talking, play } = useNarration(page.say);
  const [poured, setPoured] = useState<string[]>([]);
  const [mixed, setMixed] = useState(false);
  const pour = (item: KidsItem) => {
    if (mixed || poured.includes(item.id)) return speak(item);
    speak(item);
    const now = [...poured, item.id];
    setPoured(now);
    if (now.length < 2) return;
    window.setTimeout(async () => {
      setMixed(true);
      sfxCorrect();
      await new Promise(r => window.setTimeout(r, 400));
      await say(page.reveal);
      onReady();
    }, 700);
  };
  return (
    <div className="kid-lesson-page">
      <Bubble phrase={mixed ? page.reveal : page.say} onRepeat={mixed ? () => void say(page.reveal) : play} talking={talking} />
      <div className="kid-mix">
        {[page.a, page.b].map((item, i) => (
          <button
            key={item.id}
            onClick={() => pour(item)}
            aria-label={item.word}
            className={`kid-pot kid-pot-${i ? 'r' : 'l'} ${poured.includes(item.id) ? 'poured' : ''}`}
          >
            <span className="kid-pot-paint" style={{ background: item.color, borderColor: item.id === 'blanc' ? '#CBD5E1' : '#fff' }} />
            <Label text={item.word} />
          </button>
        ))}
        <span className="kid-mix-plus" aria-hidden="true">＋</span>
        <div className={`kid-mix-result ${mixed ? 'show' : ''}`} aria-hidden={!mixed}>
          <span className="kid-mix-splash" style={{ background: page.result.color }} />
          {mixed && <Label text={page.result.word} />}
        </div>
      </div>
    </div>
  );
}

function DialogPage({ page, onReady }: PageProps<'dialog'>) {
  const translate = useKidsTranslation();
  const [active, setActive] = useState(-1);
  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      await new Promise(r => window.setTimeout(r, 400));
      for (let i = 0; i < page.lines.length; i++) {
        if (cancelled) return;
        setActive(i);
        if (!(await say(page.lines[i].say))) return;
        await new Promise(r => window.setTimeout(r, 250));
      }
      if (!cancelled) {
        setActive(-1);
        onReady();
      }
    };
    void run();
    return () => {
      cancelled = true;
      stopVoice();
    };
  }, [page, onReady]);
  const first = page.lines[0]?.who;
  return (
    <div className="kid-lesson-page">
      <div className="kid-dialog">
        {page.lines.map((line, i) => (
          <button
            key={i}
            onClick={() => {
              setActive(i);
              void say(line.say).then(() => setActive(a => (a === i ? -1 : a)));
            }}
            className={`kid-dialog-line ${line.who === first ? 'left' : 'right'} ${active === i ? 'now' : ''}`}
            style={{ animationDelay: `${i * 0.15}s` }}
          >
            <span className="kid-dialog-who" aria-hidden="true">{line.who}</span>
            <span className="kid-dialog-text">
              {phraseText(line.say)}
              <Translation text={translate(line.say)} />
            </span>
          </button>
        ))}
      </div>
    </div>
  );
}

/** Diu una llista de frases per ordre i marca quina sona; `onReady` en acabar. */
function useSequence(keys: string[], onReady: () => void) {
  const [active, setActive] = useState(-1);
  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      await new Promise(r => window.setTimeout(r, 400));
      for (let i = 0; i < keys.length; i++) {
        if (cancelled) return;
        setActive(i);
        if (!(await say(keys[i]))) return;
        await new Promise(r => window.setTimeout(r, 300));
      }
      if (!cancelled) {
        setActive(-1);
        onReady();
      }
    };
    void run();
    return () => {
      cancelled = true;
      stopVoice();
    };
    // Les claus no canvien dins d'una pàgina.
  }, [onReady]);
  const replay = (i: number) => {
    setActive(i);
    void say(keys[i]).then(() => setActive(a => (a === i ? -1 : a)));
  };
  return { active, replay };
}

/** Conte en vinyetes: es narra cada vinyeta per ordre; la que sona s'il·lumina. */
function StoryPage({ page, onReady }: PageProps<'story'>) {
  const translate = useKidsTranslation();
  const { active, replay } = useSequence(page.panels.map(x => x.say), onReady);
  const current = page.panels[active];
  return (
    <div className="kid-lesson-page">
      <div className="kid-story">
        {page.panels.map((panel, i) => (
          <button key={i} onClick={() => replay(i)} className={`kid-story-panel ${active === i ? 'now' : ''}`}>
            <span className="kid-story-num">{i + 1}</span>
            <span className="kid-story-scene" aria-hidden="true">{panel.scene}</span>
          </button>
        ))}
      </div>
      {current && (
        <p className="kid-story-text">
          {phraseText(current.say)}
          <Translation text={translate(current.say)} />
        </p>
      )}
    </div>
  );
}

/** Cançó o rodolí: les línies s'il·luminen mentre la Taronjeta les canta. */
function ChantPage({ page, onReady }: PageProps<'chant'>) {
  const translate = useKidsTranslation();
  const { active, replay } = useSequence(page.lines.map(x => x.say), onReady);
  return (
    <div className="kid-lesson-page">
      <div className="kid-chant" aria-label="Cançó">
        {page.lines.map((line, i) => (
          <button key={i} onClick={() => replay(i)} className={`kid-chant-line ${active === i ? 'now' : ''}`}>
            <span className="kid-chant-emoji" aria-hidden="true">{line.emoji}</span>
            <span>
              ♪ {phraseText(line.say)}
              <Translation text={translate(line.say)} />
            </span>
          </button>
        ))}
      </div>
    </div>
  );
}

function GamePage({ page, onDone }: PageProps<'game'>) {
  const round = useMemo(() => page.round(), [page]);
  return (
    <div className="kid-lesson-game">
      <RoundCaption round={round} className="kid-lesson-caption" />
      <RoundView round={round} onDone={onDone} />
    </div>
  );
}

function PageView(props: { page: LessonPage; onReady: () => void; onDone: () => void }) {
  const { page } = props;
  switch (page.kind) {
    case 'intro': return <IntroPage {...props} page={page} />;
    case 'explain':
    case 'summary': return <ItemsPage {...props} page={page} />;
    case 'discover': return <DiscoverPage {...props} page={page} />;
    case 'pairs': return <PairsPage {...props} page={page} />;
    case 'mix': return <MixPage {...props} page={page} />;
    case 'dialog': return <DialogPage {...props} page={page} />;
    case 'game': return <GamePage {...props} page={page} />;
    case 'story': return <StoryPage {...props} page={page} />;
    case 'chant': return <ChantPage {...props} page={page} />;
  }
}

// Pàgines que s'han de completar per a passar (tocar-ho tot, barrejar, jugar).
const mustComplete = (page: LessonPage) => page.kind === 'discover' || page.kind === 'mix' || page.kind === 'game';

/* ── Lliçó ────────────────────────────────────────────────────────────── */

export function KidsLesson({ id, uid, onLessons, onIsland }: {
  id: string | undefined;
  uid: string | undefined;
  onLessons: () => void;
  onIsland: (id: string) => void;
}) {
  const lesson = lessonById(id);
  const [session, setSession] = useState(0);
  const [index, setIndex] = useState(0);
  const [readyFor, setReadyFor] = useState<string>();
  const [finished, setFinished] = useState(false);
  const pageKey = `${session}-${index}`;

  useEffect(() => () => stopVoice(), []);
  useEffect(() => {
    if (!lesson) onLessons();
  }, [lesson, onLessons]);
  const onReady = useMemo(() => () => setReadyFor(pageKey), [pageKey]);
  if (!lesson) return null;

  const page = lesson.pages[index];
  const ready = readyFor === pageKey;
  const canNext = !mustComplete(page) || ready;

  const finish = async () => {
    stopVoice();
    setFinished(true);
    // La medalla (una vegada) i, cada vegada, la lliçó acabada amb data (per als deures i el seguiment).
    void saveLessonDone(uid, lesson.id);
    const isNew = await markLessonDone(uid, lesson.id);
    sfxFanfare();
    await new Promise(r => window.setTimeout(r, 500));
    void say(isNew ? 'llico-medalla' : 'llico-fi');
  };
  const next = () => {
    if (index + 1 < lesson.pages.length) return setIndex(i => i + 1);
    void finish();
  };
  const prev = () => index > 0 && setIndex(i => i - 1);
  const again = () => {
    setSession(s => s + 1);
    setIndex(0);
    setFinished(false);
  };

  return (
    <main className="kids-world kids-lesson" style={{ ['--island' as string]: lesson.color }}>
      <header className="kids-bar">
        <button onClick={onLessons} aria-label="Tornar a les lliçons" className="kid-round-btn btn-press"><GraduationCap className="h-8 w-8" /></button>
        <div className="kid-lesson-progress" aria-label={`Pàgina ${Math.min(index + 1, lesson.pages.length)} de ${lesson.pages.length}`}>
          <span style={{ width: `${((finished ? lesson.pages.length : index) / lesson.pages.length) * 100}%` }} />
        </div>
        <span className="kids-island-badge" aria-hidden="true">{lesson.emoji}</span>
      </header>

      {!finished ? (
        <>
          <PageView key={pageKey} page={page} onReady={onReady} onDone={next} />
          <nav className="kid-lesson-nav">
            <button onClick={prev} disabled={index === 0} aria-label="Enrere" className="kid-nav-btn btn-press"><ChevronLeft className="h-10 w-10" /></button>
            {page.kind !== 'game' && (
              <button
                onClick={next}
                disabled={!canNext}
                aria-label="Endavant"
                className={`kid-nav-btn kid-nav-next btn-press ${ready ? 'kid-nav-ready' : ''}`}
              >
                <ChevronRight className="h-10 w-10" />
              </button>
            )}
          </nav>
        </>
      ) : (
        <div className="kid-finish">
          <div className="kid-confetti" aria-hidden="true">{Array.from({ length: 24 }, (_, i) => <i key={i} style={{ left: `${(i * 41) % 100}%`, animationDelay: `${(i % 8) * 0.12}s` }} />)}</div>
          <div className="kid-medal kid-cromo-win" aria-label={`Medalla: ${lesson.title}`}>
            <span className="kid-medal-ribbon" aria-hidden="true" />
            <span className="kid-medal-disc"><span aria-hidden="true">{lesson.emoji}</span></span>
            <span className="kid-medal-name">{lesson.title}</span>
          </div>
          <div className="kid-finish-actions">
            <button onClick={onLessons} aria-label="Tornar a les lliçons" className="kid-big-btn btn-press" style={{ background: '#7C3AED' }}><GraduationCap className="h-10 w-10" /></button>
            <button onClick={again} aria-label="Repetir la lliçó" className="kid-big-btn btn-press" style={{ background: '#2CA99B' }}><RotateCcw className="h-10 w-10" /></button>
            {lesson.island && (
              <button onClick={() => onIsland(lesson.island!)} aria-label="Juga en l'illa" className="kid-big-btn btn-press" style={{ background: '#F97316' }}><Gamepad2 className="h-10 w-10" /></button>
            )}
          </div>
        </div>
      )}
    </main>
  );
}
