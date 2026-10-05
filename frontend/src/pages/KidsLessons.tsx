import { useEffect, useState } from 'react';
import { Logo } from '../components/ui';
import { LESSONS, type Lesson } from '../features/kids/lessons';
import { loadLessonsDone } from '../features/kids/progress';
import { say, sayBriefly, stopVoice } from '../features/kids/sound';

// Lliçons de valencià bàsic per a xiquets, explicades per la Taronjeta. Com que encara no
// llegixen, en entrar se sent la benvinguda i, en tocar una lliçó, el seu títol; després
// s'obri a pantalla completa, amb veu i jocs.
export function KidsLessons({ uid, onBack, onOpenLesson }: { uid: string | undefined; onBack: () => void; onOpenLesson: (id: string) => void }) {
  const [done, setDone] = useState<string[]>([]);
  const [opening, setOpening] = useState<string>();

  useEffect(() => {
    let cancelled = false;
    void loadLessonsDone(uid).then(d => { if (!cancelled) setDone(d); });
    const timer = window.setTimeout(() => void say('llicons'), 400);
    return () => {
      cancelled = true;
      window.clearTimeout(timer);
      stopVoice();
    };
  }, [uid]);

  const open = async (lesson: Lesson) => {
    if (opening) return;
    setOpening(lesson.id);
    await sayBriefly(lesson.say);
    onOpenLesson(lesson.id);
  };

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
        <h1 className="mb-6 text-center text-4xl font-black uppercase tracking-wider opacity-55">Lliçons</h1>
        <ul className="grid gap-4 sm:grid-cols-2">
          {LESSONS.map(l => (
            <li key={l.id}>
              <button
                onClick={() => void open(l)}
                className={`btn-press flex h-full w-full items-center gap-4 rounded-3xl bg-white p-5 text-left shadow-lg ring-2 ring-white hover:bg-white/90 ${opening === l.id ? 'scale-95' : ''}`}
              >
                <span className="text-5xl leading-none" aria-hidden="true">{l.emoji}</span>
                <span className="flex-1">
                  <span className="block text-2xl font-black">{l.title}</span>
                  <span className="block text-base font-bold opacity-60">{l.summary}</span>
                </span>
                {done.includes(l.id) && <span className="text-4xl leading-none" title="Lliçó acabada">🏅</span>}
              </button>
            </li>
          ))}
        </ul>
      </div>
    </main>
  );
}
