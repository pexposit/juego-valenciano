import { useEffect, useState } from 'react';
import { ChevronLeft, Volume2 } from 'lucide-react';
import { Logo } from '../components/ui';
import { KIDS_LESSONS, type Lesson } from '../features/kids/lessons';

// Veu del navegador en català (cada targeta es pot tocar per escoltar-la).
function speak(text: string) {
  const synth = window.speechSynthesis;
  if (!synth) return;
  synth.cancel();
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.lang = 'ca-ES';
  utterance.rate = 0.85;
  synth.speak(utterance);
}

// Lliçons de valencià bàsic per a xiquets: la llista de lliçons i, en triar-ne una, les seues targetes.
export function KidsLessons({ onBack }: { onBack: () => void }) {
  const [lesson, setLesson] = useState<Lesson>();

  useEffect(() => () => window.speechSynthesis?.cancel(), []);

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
        {lesson ? (
          <>
            <button
              onClick={() => setLesson(undefined)}
              className="btn-press mb-4 flex items-center gap-1 rounded-full bg-white/90 px-4 py-2 text-lg font-extrabold text-teal shadow"
            >
              <ChevronLeft size={20} /> Totes les lliçons
            </button>
            <h1 className="text-4xl font-black">{lesson.emoji} {lesson.title}</h1>
            <p className="mb-6 mt-1 flex items-center gap-2 text-xl font-bold opacity-70">
              <Volume2 size={22} aria-hidden="true" /> {lesson.intro} Toca una targeta per escoltar-la.
            </p>
            <ul className="grid grid-cols-2 gap-4 sm:grid-cols-3">
              {lesson.cards.map(card => (
                <li key={card.text}>
                  <button
                    onClick={() => speak(card.say ?? card.text)}
                    aria-label={`Escolta: ${card.text}`}
                    className="btn-press flex h-full w-full flex-col items-center gap-2 rounded-3xl bg-white p-5 text-center shadow-lg ring-2 ring-white hover:bg-white/90"
                  >
                    <span
                      className="text-6xl leading-none"
                      style={card.color ? { filter: 'drop-shadow(0 0 1px rgba(0,0,0,.4))' } : undefined}
                    >
                      {card.emoji}
                    </span>
                    <span className="text-2xl font-black">{card.text}</span>
                    {card.note && <span className="text-base font-bold opacity-60">{card.note}</span>}
                  </button>
                </li>
              ))}
            </ul>
          </>
        ) : (
          <>
            <h1 className="mb-6 text-center text-4xl font-black uppercase tracking-wider opacity-55">Lliçons</h1>
            <ul className="grid gap-4 sm:grid-cols-2">
              {KIDS_LESSONS.map(l => (
                <li key={l.id}>
                  <button
                    onClick={() => setLesson(l)}
                    className="btn-press flex w-full items-center gap-4 rounded-3xl bg-white p-5 text-left shadow-lg ring-2 ring-white hover:bg-white/90"
                  >
                    <span className="text-5xl leading-none" aria-hidden="true">{l.emoji}</span>
                    <span>
                      <span className="block text-2xl font-black">{l.title}</span>
                      <span className="block text-base font-bold opacity-60">{l.intro}</span>
                    </span>
                  </button>
                </li>
              ))}
            </ul>
          </>
        )}
      </div>
    </main>
  );
}
