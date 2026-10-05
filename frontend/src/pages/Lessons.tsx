import { useEffect, useRef, useState } from 'react';
import { ChevronLeft, Volume2 } from 'lucide-react';
import { KID_ASSISTANT_TYPE } from '@parlaval/shared';
import { Logo } from '../components/ui';
import { LESSONS, translateWord, type Lesson } from '../data/lessons';
import { fetchTts } from '../lib/api';

// El TTS retalla el final de les paraules soltes: amb un punt final les pronuncia senceres.
// També canvia l'apòstrof tipogràfic pel normal, que el model llig millor.
const spokenText = (text: string) => {
  const plain = text.replace(/’/g, "'");
  return /[.!?]$/.test(plain) ? plain : `${plain}.`;
};

// Lliçons bàsiques per a xiquets: una llista de temes i, en triar-ne un, les targetes de vocabulari amb àudio.
export function Lessons({ onBack, motherTongue, showHelp }: { onBack: () => void; motherTongue: string | null; showHelp: boolean }) {
  const [selected, setSelected] = useState<Lesson>();
  const [playing, setPlaying] = useState<string>();
  const [failed, setFailed] = useState(false);
  const audio = useRef<HTMLAudioElement>();

  useEffect(() => () => audio.current?.pause(), []);

  const listen = async (text: string) => {
    audio.current?.pause();
    setFailed(false);
    setPlaying(text);
    try {
      const element = new Audio(await fetchTts(spokenText(text), KID_ASSISTANT_TYPE));
      audio.current = element;
      element.onended = element.onpause = () => setPlaying(p => (p === text ? undefined : p));
      await element.play();
    } catch (error) {
      console.error("Error reproduint l'àudio:", error);
      setPlaying(undefined);
      setFailed(true);
    }
  };

  const list = () => (
    <ul className="grid grid-cols-2 gap-4 sm:grid-cols-3">
      {LESSONS.map(l => (
        <li key={l.id}>
          <button
            onClick={() => setSelected(l)}
            className="btn-press flex h-full w-full flex-col items-center gap-2 rounded-3xl bg-white p-5 text-center shadow-lg ring-2 ring-white hover:bg-white/90"
          >
            <span className="text-5xl" aria-hidden="true">{l.emoji}</span>
            <span className="text-xl font-black">{l.title}</span>
          </button>
        </li>
      ))}
    </ul>
  );

  const detail = (lesson: Lesson) => (
    <div>
      <button
        onClick={() => setSelected(undefined)}
        className="btn-press mb-4 flex items-center gap-1 rounded-full bg-white/90 px-4 py-2 text-lg font-extrabold text-teal shadow"
      >
        <ChevronLeft size={20} /> Totes les lliçons
      </button>
      <h2 className="text-3xl font-black">{lesson.emoji} {lesson.title}</h2>
      <p className="mb-5 mt-1 text-lg font-semibold opacity-70">{lesson.intro}</p>
      {failed && <p className="mb-3 text-lg font-bold text-orange">No hem pogut reproduir l’àudio. Torna-ho a provar.</p>}
      <ul className="grid grid-cols-2 gap-4 sm:grid-cols-3">
        {lesson.words.map(w => {
          const translation = showHelp ? translateWord(w.text, motherTongue) : undefined;
          return (
          <li key={w.text}>
            <button
              onClick={() => void listen(w.text)}
              aria-label={`Escolta: ${w.text}`}
              className={`btn-press flex h-full w-full flex-col items-center gap-1 rounded-3xl bg-white p-4 text-center shadow-lg ring-2 ${playing === w.text ? 'ring-teal' : 'ring-white'}`}
            >
              <span className="text-5xl" aria-hidden="true">{w.emoji}</span>
              <span className="text-2xl font-black">{w.text}</span>
              {translation && <span dir="auto" className="text-base font-semibold opacity-70">{translation}</span>}
              {w.hint && <span className="text-sm font-bold opacity-60">{w.hint}</span>}
              <Volume2 size={20} className="text-teal" aria-hidden="true" />
            </button>
          </li>
          );
        })}
      </ul>
    </div>
  );

  return (
    <main className="fade-up relative min-h-screen bg-cream text-ink">
      <header className="classroom-header z-10">
        <div className="relative isolate flex items-center justify-between px-5 p-4">
          <button
            onClick={onBack}
            className="text-xl btn-press rounded-full bg-white/90 px-4 py-2 text-sm font-extrabold text-teal shadow hover:bg-white transition-colors"
          >
            ← Tornar
          </button>
          <Logo onDark />
          <span className="w-24" aria-hidden="true" />
        </div>
      </header>
      <div className="mx-auto max-w-3xl px-5 pt-6 pb-24">
        {!selected && <h1 className="mb-6 text-center text-4xl font-black uppercase tracking-wider opacity-55">Les lliçons</h1>}
        {selected ? detail(selected) : list()}
      </div>
    </main>
  );
}
