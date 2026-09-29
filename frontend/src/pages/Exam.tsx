import { useEffect, useMemo, useState } from 'react';
import { BookOpen, Clock, ExternalLink, Headphones, Mic, PenLine, RotateCcw } from 'lucide-react';
import { Logo } from '../components/ui';
import { BinaryExercise, ChoiceExercise, FormExercise, MatchExercise, OralExercise } from '../components/ExamExercises';
import type { Exam as ExamResource, ExamArea, ExamExercise, ExamQuestion } from '../lib/types';

const AREA_ICONS = [Headphones, BookOpen, PenLine, Mic];

type Progress = {
  answers: Record<number, string>;
  checked: number[]; // àrees corregides
  form: Record<string, string>;
};

const EMPTY: Progress = { answers: {}, checked: [], form: {} };

// El progrés es guarda al navegador perquè no es perda en recarregar la pàgina.
const storageKey = (id: string) => `parlaval:exam:${id}`;
function loadProgress(id: string): Progress {
  try {
    const raw = localStorage.getItem(storageKey(id));
    return raw ? { ...EMPTY, ...JSON.parse(raw) } : EMPTY;
  } catch {
    return EMPTY;
  }
}

const gradable = (e: ExamExercise): e is Extract<ExamExercise, { questions: ExamQuestion[] }> =>
  e.kind === 'choice' || e.kind === 'binary' || e.kind === 'match';

const questionsOf = (area: ExamArea) => area.exercises.filter(gradable).flatMap(e => e.questions);

export function Exam({ exam: resource, onBack }: { exam: ExamResource; onBack: () => void }) {
  const { exam } = resource;
  const [progress, setProgress] = useState<Progress>(() => loadProgress(resource.id));
  const [areaIndex, setAreaIndex] = useState(0);
  const area = exam.areas[areaIndex];

  useEffect(() => {
    try {
      localStorage.setItem(storageKey(resource.id), JSON.stringify(progress));
    } catch {
      // Sense storage: el progrés només dura mentre la pàgina estiga oberta.
    }
  }, [progress, resource.id]);

  const checked = progress.checked.includes(area.n);
  const areaQuestions = useMemo(() => questionsOf(area), [area]);
  const answered = (a: ExamArea) => questionsOf(a).filter(q => progress.answers[q.n]).length;
  const score = (questions: ExamQuestion[]) => questions.filter(q => progress.answers[q.n] === q.answer).length;

  const answer = (n: number, key: string) =>
    setProgress(p => ({ ...p, answers: { ...p.answers, [n]: key } }));
  const check = () => {
    setProgress(p => ({ ...p, checked: [...p.checked, area.n] }));
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };
  const reset = () =>
    setProgress(p => {
      const answers = { ...p.answers };
      for (const q of areaQuestions) delete answers[q.n];
      return { ...p, answers, checked: p.checked.filter(n => n !== area.n) };
    });
  const goToArea = (i: number) => {
    setAreaIndex(i);
    window.scrollTo({ top: 0, behavior: 'smooth' });
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
          <Logo />
          <span className="w-24" aria-hidden="true" />
        </div>
      </header>

      <div className="mx-auto flex max-w-5xl flex-col gap-6 px-5 pt-6 pb-24">
        {/* Portada */}
        <section className="relative overflow-hidden rounded-[2rem] bg-navy p-8 text-white shadow-xl">
          <div className="absolute -right-10 -top-10 h-48 w-48 rounded-full bg-mustard/20" aria-hidden="true" />
          <div className="absolute -bottom-16 right-24 h-40 w-40 rounded-full bg-teal/30" aria-hidden="true" />
          <div className="relative flex flex-wrap items-center gap-6">
            <div className="grid h-24 w-24 shrink-0 place-items-center rounded-3xl bg-mustard text-5xl font-black text-navy shadow-lg">
              {exam.level}
            </div>
            <div className="flex-1">
              <p className="text-sm font-black uppercase tracking-widest text-mustard">
                {exam.body} · Convocatòria {exam.session.toLowerCase()}
              </p>
              <h1 className="mt-1 text-3xl font-black">Prova del certificat de nivell {exam.level}</h1>
              <p className="mt-2 max-w-xl text-white/75">
                Simulacre interactiu de l'examen oficial: respon, corregix cada àrea i practica l'expressió oral.
              </p>
            </div>
          </div>
          <div className="relative mt-6 grid grid-cols-2 gap-3 sm:grid-cols-4">
            {exam.areas.map((a, i) => {
              const Icon = AREA_ICONS[(a.n - 1) % AREA_ICONS.length];
              return (
                <div key={a.n} className="rounded-2xl bg-white/10 p-3">
                  <Icon size={18} className="text-mustard" />
                  <p className="mt-1 text-sm font-black leading-tight">{a.title}</p>
                  <p className="mt-1 flex items-center gap-1 text-xs text-white/70">
                    <span className="font-black text-white">{a.weight} %</span> · <Clock size={12} /> {a.duration}
                  </p>
                </div>
              );
            })}
          </div>
          {exam.source_url && (
            <a
              href={exam.source_url}
              target="_blank"
              rel="noreferrer"
              className="relative mt-4 inline-flex items-center gap-1 text-xs font-bold text-white/60 hover:text-white"
            >
              Basat en l'examen oficial de la {exam.body} <ExternalLink size={12} />
            </a>
          )}
        </section>

        {/* Navegació per àrees */}
        <nav className="sticky top-2 z-20 grid grid-cols-4 gap-2 rounded-2xl bg-white/90 p-2 shadow-md backdrop-blur">
          {exam.areas.map((a, i) => {
            const Icon = AREA_ICONS[(a.n - 1) % AREA_ICONS.length];
            const total = questionsOf(a).length;
            const done = progress.checked.includes(a.n);
            return (
              <button
                key={a.n}
                onClick={() => goToArea(i)}
                className={`btn-press flex flex-col items-center gap-1 rounded-xl px-2 py-2 text-center transition-colors ${
                  i === areaIndex ? 'bg-teal text-white' : 'hover:bg-teal/10'
                }`}
              >
                <span className="flex items-center gap-1 text-xs font-black uppercase tracking-wide">
                  <Icon size={14} /> Àrea {a.n}
                </span>
                <span className="hidden text-xs font-bold opacity-80 sm:block">{a.title}</span>
                {total > 0 && (
                  <span className={`text-[11px] font-black ${i === areaIndex ? 'text-white/80' : 'text-ink/50'}`}>
                    {done ? `✓ ${score(questionsOf(a))}/${total}` : `${answered(a)}/${total}`}
                  </span>
                )}
              </button>
            );
          })}
        </nav>

        {/* Resultat de l'àrea corregida */}
        {checked && areaQuestions.length > 0 && (
          <AreaResult
            area={area}
            correct={score(areaQuestions)}
            total={areaQuestions.length}
            byExercise={area.exercises.filter(gradable).map(e => ({ n: e.n, correct: score(e.questions), total: e.questions.length }))}
            onReset={reset}
          />
        )}

        <section>
          <h2 className="text-2xl font-black">Àrea {area.n} · {area.title}</h2>
          {area.intro && <p className="mt-1 opacity-70">{area.intro}</p>}
        </section>

        {area.audio && resource.url && (
          <section className="flex flex-wrap items-center gap-4 rounded-2xl border-2 border-teal/30 bg-white p-4">
            <span className="grid h-12 w-12 place-items-center rounded-full bg-teal text-white">
              <Headphones size={22} />
            </span>
            <div className="min-w-[14rem] flex-1">
              <p className="font-black">Àudio de la comprensió oral</p>
              <p className="text-sm opacity-60">Conté els àudios dels exercicis 1, 2 i 3. Escolta'ls dos vegades.</p>
            </div>
            <audio controls preload="metadata" src={resource.url} className="w-full sm:w-80" aria-label="Àudio de la comprensió oral" />
          </section>
        )}

        {area.exercises.map(exercise => (
          <article key={exercise.n} className="rounded-[1.75rem] bg-white p-6 shadow-sm">
            <div className="mb-5 flex items-start gap-3">
              <span className="shrink-0 rounded-xl bg-orange px-3 py-1 text-sm font-black text-white">Exercici {exercise.n}</span>
              <p className="font-bold opacity-80">{exercise.instructions}</p>
            </div>
            <ExerciseBody
              exercise={exercise}
              answers={progress.answers}
              checked={checked}
              onAnswer={answer}
              form={progress.form}
              onFormChange={(field, value) => setProgress(p => ({ ...p, form: { ...p.form, [field]: value } }))}
            />
          </article>
        ))}

        {/* Peu de l'àrea: corregir i passar a la següent */}
        <div className="flex flex-wrap items-center justify-between gap-3">
          {areaQuestions.length > 0 && !checked ? (
            <p className="text-sm font-bold opacity-60">
              {answered(area)} de {areaQuestions.length} preguntes respostes
            </p>
          ) : <span />}
          <div className="flex gap-3">
            {areaQuestions.length > 0 && !checked && (
              <button
                onClick={check}
                className="btn-press rounded-full bg-orange px-6 py-3 font-black text-white shadow hover:bg-orange/90"
              >
                Corregir l'àrea
              </button>
            )}
            {areaIndex < exam.areas.length - 1 && (
              <button
                onClick={() => goToArea(areaIndex + 1)}
                className="btn-press rounded-full bg-teal px-6 py-3 font-black text-white shadow hover:bg-teal/90"
              >
                Àrea {exam.areas[areaIndex + 1].n} →
              </button>
            )}
          </div>
        </div>
      </div>
    </main>
  );
}

function ExerciseBody({
  exercise, answers, checked, onAnswer, form, onFormChange,
}: {
  exercise: ExamExercise;
  answers: Record<number, string>;
  checked: boolean;
  onAnswer: (n: number, key: string) => void;
  form: Record<string, string>;
  onFormChange: (field: string, value: string) => void;
}) {
  const props = { answers, checked, onAnswer };
  switch (exercise.kind) {
    case 'choice':
      return <ChoiceExercise questions={exercise.questions} {...props} />;
    case 'binary':
      return <BinaryExercise questions={exercise.questions} options={exercise.options ?? []} {...props} />;
    case 'match':
      return <MatchExercise questions={exercise.questions} options={exercise.options ?? []} {...props} />;
    case 'form':
      return (
        <FormExercise
          fields={exercise.fields}
          criteria={exercise.criteria}
          maxPoints={exercise.max_points}
          values={form}
          onChange={onFormChange}
        />
      );
    case 'oral':
      return <OralExercise proposals={exercise.proposals} />;
  }
}

function AreaResult({
  area, correct, total, byExercise, onReset,
}: {
  area: ExamArea;
  correct: number;
  total: number;
  byExercise: { n: number; correct: number; total: number }[];
  onReset: () => void;
}) {
  const pct = Math.round((correct / total) * 100);
  const message = pct >= 80 ? 'Excel·lent!' : pct >= 50 ? 'Molt bé, vas pel bon camí!' : 'Continua practicant!';
  return (
    <section className="fade-up flex flex-wrap items-center gap-6 rounded-[1.75rem] border-2 border-teal/30 bg-white p-6">
      <div
        className="grid h-24 w-24 shrink-0 place-items-center rounded-full"
        style={{ background: `conic-gradient(#2CA99B ${pct * 3.6}deg, #E7E5E4 0deg)` }}
        aria-label={`${pct} % d'encerts`}
      >
        <div className="grid place-items-center rounded-full bg-white" style={{ height: '4.5rem', width: '4.5rem' }}>
          <span className="text-xl font-black">{correct}/{total}</span>
        </div>
      </div>
      <div className="min-w-[12rem] flex-1">
        <p className="text-sm font-black uppercase tracking-wide text-teal">Àrea {area.n} corregida</p>
        <p className="text-2xl font-black">{message}</p>
        <div className="mt-2 flex flex-wrap gap-2">
          {byExercise.map(e => (
            <span key={e.n} className="rounded-full bg-cream px-3 py-1 text-xs font-black">
              Exercici {e.n}: {e.correct}/{e.total}
            </span>
          ))}
        </div>
      </div>
      <button
        onClick={onReset}
        className="btn-press flex items-center gap-2 rounded-full bg-cream px-4 py-2 text-sm font-black text-teal hover:bg-teal/10"
      >
        <RotateCcw size={16} /> Tornar a fer
      </button>
    </section>
  );
}
