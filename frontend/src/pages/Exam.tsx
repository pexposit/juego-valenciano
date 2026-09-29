import { useEffect, useMemo, useState } from 'react';
import { BookOpen, Clock, ExternalLink, Headphones, Mic, PenLine, RotateCcw } from 'lucide-react';
import { Logo } from '../components/ui';
import { BinaryExercise, ChoiceExercise, FormExercise, MatchExercise, OralExercise, Reading, WritingEvaluationPanel, WritingExercise } from '../components/ExamExercises';
import { evaluateExamWriting } from '../lib/api';
import type { Exam as ExamResource, ExamArea, ExamExercise, ExamQuestion, ExamScoring, WritingEvaluation } from '../lib/types';

const AREA_ICONS = [Headphones, BookOpen, PenLine, Mic];

type Progress = {
  answers: Record<number, string>;
  checked: number[]; // àrees corregides
  form: Record<string, string>; // camps del formulari i textos de redacció
  evaluations: Record<number, WritingEvaluation>; // avaluació amb IA per exercici
};

const EMPTY: Progress = { answers: {}, checked: [], form: {}, evaluations: {} };

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

// "de l'exercici 1", "dels exercicis 1 i 2", "dels exercicis 1, 2 i 3".
const listExercises = (ns: number[]) =>
  ns.length === 1 ? `de l'exercici ${ns[0]}` : `dels exercicis ${ns.slice(0, -1).join(', ')} i ${ns[ns.length - 1]}`;

type ExerciseScore = { n: number; correct: number; total: number };

// Valor d'un encert en un exercici: el propi de l'exercici o, si no en té, el comú de l'àrea.
const pointsPerCorrect = (scoring: ExamScoring, n: number) =>
  scoring.points_per_exercise?.[n] ?? scoring.points_per_correct ?? 0;
// Punts oficials d'una àrea a partir dels encerts (arredonits, com en la correcció de la JQCV).
const pointsOf = (scoring: ExamScoring, byExercise: ExerciseScore[]) =>
  Math.round(byExercise.reduce((sum, e) => sum + e.correct * pointsPerCorrect(scoring, e.n), 0));
const passes = (scoring: ExamScoring, points: number) => points >= scoring.pass_points;

// De moment només el formulari de l'examen A1 té rúbrica d'avaluació amb IA.
const evaluable = (level: string, e: ExamExercise): e is Extract<ExamExercise, { kind: 'form' }> =>
  level === 'A1' && e.kind === 'form';

const questionsOf = (area: ExamArea) => area.exercises.filter(gradable).flatMap(e => e.questions);

export function Exam({ exam: resource, onBack }: { exam: ExamResource; onBack: () => void }) {
  const { exam } = resource;
  const [progress, setProgress] = useState<Progress>(() => loadProgress(resource.id));
  const [areaIndex, setAreaIndex] = useState(0);
  const area = exam.areas[areaIndex];
  const [evaluating, setEvaluating] = useState<number>();
  const [evaluationError, setEvaluationError] = useState<{ n: number; message: string }>();

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
  const exerciseScores = (a: ExamArea): ExerciseScore[] =>
    a.exercises.filter(gradable).map(e => ({ n: e.n, correct: score(e.questions), total: e.questions.length }));
  const areaPoints = (a: ExamArea) => pointsOf(a.scoring!, exerciseScores(a));

  // Estat global en la prova: amb una àrea puntuable per davall del mínim quedes fora.
  const scoredAreas = exam.areas.filter(a => a.scoring);
  const checkedScored = scoredAreas.filter(a => progress.checked.includes(a.n));
  const failed = checkedScored.filter(a => !passes(a.scoring!, areaPoints(a))).map(a => a.n);
  const examStatus = checkedScored.length > 0
    ? { out: failed.length > 0, failed, checked: checkedScored.length, total: scoredAreas.length }
    : undefined;

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
  const evaluate = async (exercise: Extract<ExamExercise, { kind: 'form' }>) => {
    setEvaluating(exercise.n);
    setEvaluationError(undefined);
    try {
      const answers = Object.fromEntries(exercise.fields.map(f => [f, progress.form[f] ?? '']));
      const evaluation = await evaluateExamWriting(resource.id, exercise.n, answers);
      setProgress(p => ({ ...p, evaluations: { ...p.evaluations, [exercise.n]: evaluation } }));
    } catch (error) {
      setEvaluationError({ n: exercise.n, message: error instanceof Error ? error.message : "No hem pogut avaluar l'exercici" });
    } finally {
      setEvaluating(undefined);
    }
  };
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
          {exam.pass_rule && <p className="relative mt-2 max-w-3xl text-xs text-white/60">{exam.pass_rule}</p>}
          {examStatus && (
            <p className={`relative mt-4 inline-flex items-center gap-2 rounded-full px-4 py-2 text-sm font-black ${
              examStatus.out ? 'bg-coral text-white' : 'bg-teal text-white'
            }`}>
              {examStatus.out
                ? `❌ Quedes fora de la prova: no arribes al mínim en l'àrea ${examStatus.failed.join(' i ')}`
                : `✅ Continues en la prova (${examStatus.checked} de ${examStatus.total} àrees puntuables corregides)`}
            </p>
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
                    {!done
                      ? `${answered(a)}/${total}`
                      : a.scoring
                        ? `${passes(a.scoring, areaPoints(a)) ? '✓' : '✗'} ${areaPoints(a)}/${a.scoring.max_points} punts`
                        : `✓ ${score(questionsOf(a))}/${total}`}
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
            byExercise={exerciseScores(area)}
            scoring={area.scoring}
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
              <p className="text-sm opacity-60">
                Conté els àudios {listExercises(area.exercises.map(e => e.n))}. Escolta'ls dos vegades.
                {exam.audio_source_url && (
                  <>
                    {' '}
                    <a href={exam.audio_source_url} target="_blank" rel="noreferrer" className="font-bold text-teal hover:underline">
                      Àudio oficial
                    </a>
                  </>
                )}
              </p>
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
            {'reading' in exercise && exercise.reading && <Reading reading={exercise.reading} />}
            <ExerciseBody
              exercise={exercise}
              answers={progress.answers}
              checked={checked}
              onAnswer={answer}
              form={progress.form}
              onFormChange={(field, value) => setProgress(p => ({ ...p, form: { ...p.form, [field]: value } }))}
            />
            {evaluable(exam.level, exercise) && (
              <WritingEvaluationPanel
                evaluation={progress.evaluations[exercise.n]}
                loading={evaluating === exercise.n}
                error={evaluationError?.n === exercise.n ? evaluationError.message : undefined}
                canEvaluate={exercise.fields.some(f => progress.form[f]?.trim())}
                onEvaluate={() => evaluate(exercise)}
              />
            )}
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
      return <MatchExercise questions={exercise.questions} options={exercise.options ?? []} optionsTitle={exercise.options_title} {...props} />;
    case 'form':
      return (
        <FormExercise
          title={exercise.title}
          fields={exercise.fields}
          criteria={exercise.criteria}
          maxPoints={exercise.max_points}
          values={form}
          onChange={onFormChange}
        />
      );
    case 'writing': {
      const key = `writing-${exercise.n}`;
      return (
        <WritingExercise
          title={exercise.title}
          minWords={exercise.min_words}
          maxWords={exercise.max_words}
          words={exercise.words}
          minWordsUsed={exercise.min_words_used}
          image={exercise.image}
          choices={exercise.choices}
          choice={form[`${key}-choice`]}
          onChoose={c => onFormChange(`${key}-choice`, c)}
          value={form[key] ?? ''}
          onChange={value => onFormChange(key, value)}
        />
      );
    }
    case 'oral':
      return <OralExercise proposals={exercise.proposals} />;
  }
}

function AreaResult({
  area, correct, total, byExercise, scoring, onReset,
}: {
  area: ExamArea;
  correct: number;
  total: number;
  byExercise: ExerciseScore[];
  scoring?: ExamScoring;
  onReset: () => void;
}) {
  const points = scoring ? pointsOf(scoring, byExercise) : undefined;
  const pass = scoring ? passes(scoring, points!) : undefined;
  const pct = Math.round(scoring ? (points! / scoring.max_points) * 100 : (correct / total) * 100);
  const message = pct >= 80 ? 'Excel·lent!' : pct >= 50 ? 'Molt bé, vas pel bon camí!' : 'Continua practicant!';
  const ring = pass === false ? '#FF675D' : '#2CA99B';
  return (
    <section className={`fade-up flex flex-wrap items-center gap-6 rounded-[1.75rem] border-2 bg-white p-6 ${pass === false ? 'border-coral/40' : 'border-teal/30'}`}>
      <div
        className="grid h-24 w-24 shrink-0 place-items-center rounded-full"
        style={{ background: `conic-gradient(${ring} ${pct * 3.6}deg, #E7E5E4 0deg)` }}
        aria-label={scoring ? `${points} de ${scoring.max_points} punts` : `${pct} % d'encerts`}
      >
        <div className="grid place-items-center rounded-full bg-white" style={{ height: '4.5rem', width: '4.5rem' }}>
          {scoring ? (
            <span className="text-center leading-none">
              <span className="block text-xl font-black">{points}/{scoring.max_points}</span>
              <span className="text-[10px] font-black uppercase opacity-60">punts</span>
            </span>
          ) : (
            <span className="text-xl font-black">{correct}/{total}</span>
          )}
        </div>
      </div>
      <div className="min-w-[12rem] flex-1">
        <p className={`text-sm font-black uppercase tracking-wide ${pass === false ? 'text-coral' : 'text-teal'}`}>Àrea {area.n} corregida</p>
        {scoring ? (
          <>
            <p className="text-2xl font-black">
              {pass ? '✅ Apte · Continues en la prova' : '❌ No apte · Quedes fora de la prova'}
            </p>
            <p className="mt-1 text-sm opacity-70">
              {scoring.points_per_exercise
                ? `${byExercise.map(e => `${e.correct} × ${pointsPerCorrect(scoring, e.n).toLocaleString('ca')}`).join(' + ')} = ${points} punts.`
                : `${correct} encerts × ${pointsPerCorrect(scoring, 0).toLocaleString('ca')} = ${points} punts (arredonit).`}
              Mínim per a continuar: {scoring.pass_points} de {scoring.max_points} punts.
            </p>
          </>
        ) : (
          <p className="text-2xl font-black">{message}</p>
        )}
        <div className="mt-2 flex flex-wrap gap-2">
          {byExercise.map(e => (
            <span key={e.n} className="rounded-full bg-cream px-3 py-1 text-xs font-black">
              Exercici {e.n}: {e.correct}/{e.total}
              {scoring?.points_per_exercise && ` · ${Math.round(e.correct * pointsPerCorrect(scoring, e.n))} punts`}
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
