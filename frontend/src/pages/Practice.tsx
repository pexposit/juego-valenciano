import { useEffect, useMemo, useState } from 'react';
import { Headphones, Lightbulb, RotateCcw } from 'lucide-react';
import { LEVEL_CEFR, normalizeAnswer, PRACTICE_AREAS, type LevelKey, type PracticeArea } from '@parlaval/shared';
import { Logo } from '../components/ui';
import { ChoiceExercise, FormExercise, QuestionNumber, WritingEvaluationPanel, WritingExercise } from '../components/ExamExercises';
import { evaluatePracticeExercise } from '../lib/api';
import type { ExamQuestion, Practice as PracticeResource, PracticeExercise, PracticePassage, WritingEvaluation } from '../lib/types';

type Progress = {
  answers: Record<string, string>; // preguntes tancades: id de l'exercici -> resposta
  checked: boolean;
  writings: Record<string, string>; // redaccions: id -> text
  forms: Record<string, Record<string, string>>; // formularis: id -> camp -> valor
  evaluations: Record<string, WritingEvaluation>; // avaluació amb IA per exercici
};
const EMPTY: Progress = { answers: {}, checked: false, writings: {}, forms: {}, evaluations: {} };

// El progrés es guarda al navegador per nivell, com el dels exàmens.
const storageKey = (id: string, level: string) => `parlaval:practice:${id}:${level}`;
function loadProgress(id: string, level: string): Progress {
  try {
    const raw = localStorage.getItem(storageKey(id, level));
    return raw ? { ...EMPTY, ...JSON.parse(raw) } : EMPTY;
  } catch {
    return EMPTY;
  }
}

type Gradable = Extract<PracticeExercise, { kind: 'choice' | 'fill' }>;
type Evaluable = Extract<PracticeExercise, { kind: 'writing' | 'form' }>;
const isGradable = (e: PracticeExercise): e is Gradable => e.kind === 'choice' || e.kind === 'fill';

// Ordre estable però barrejat de les opcions: en la BDD la correcta és sempre la
// primera, i així no canvia de lloc en recarregar la pàgina.
const hash = (s: string) => [...s].reduce((h, c) => (Math.imul(h, 31) + c.charCodeAt(0)) | 0, 7);
const shuffled = (id: string, options: string[]) => [...options].sort((a, b) => hash(id + a) - hash(id + b));

const KEYS = 'abcdefgh';
// Pregunta tancada en el format dels exàmens, per a reutilitzar ChoiceExercise.
const asQuestion = (e: Extract<PracticeExercise, { kind: 'choice' }>, n: number): ExamQuestion => {
  const options = shuffled(e.id, e.options).map((text, i) => ({ key: KEYS[i], text }));
  return { n, prompt: e.prompt, options, answer: options.find(o => o.text === e.answers[0])!.key };
};

const isCorrect = (e: Gradable, question: ExamQuestion | undefined, answer: string | undefined) => {
  if (!answer) return false;
  if (e.kind === 'choice') return answer === question?.answer;
  return e.answers.some(a => normalizeAnswer(a) === normalizeAnswer(answer));
};

// Exercicis consecutius que comparteixen text o àudio es mostren junts, darrere d'ell.
type Group = { passage?: PracticePassage; exercises: { exercise: PracticeExercise; n: number }[] };
function groupByPassage(exercises: PracticeExercise[], passages: PracticePassage[]): Group[] {
  const groups: Group[] = [];
  exercises.forEach((exercise, i) => {
    const last = groups[groups.length - 1];
    if (last && (last.passage?.id ?? null) === exercise.passage_id) last.exercises.push({ exercise, n: i + 1 });
    else groups.push({ passage: passages.find(p => p.id === exercise.passage_id), exercises: [{ exercise, n: i + 1 }] });
  });
  return groups;
}

export function Practice({ practice, userLevel, onBack }: { practice: PracticeResource; userLevel: string; onBack: () => void }) {
  // Només els nivells del MECR de l'aprenent (A1-A2, B1-B2 o C1-C2); si el
  // contingut no en té cap (p. ex. un enllaç directe), es mostren tots.
  const levels = useMemo(() => {
    const all = [...new Set(practice.exercises.map(e => e.level))];
    const own = all.filter(l => LEVEL_CEFR[userLevel as LevelKey]?.includes(l));
    return own.length ? own : all;
  }, [practice, userLevel]);
  const [level, setLevel] = useState(levels[0]);
  const [progress, setProgress] = useState<Progress>(() => loadProgress(practice.id, level));
  const [evaluating, setEvaluating] = useState<string>();
  const [evaluationError, setEvaluationError] = useState<{ id: string; message: string }>();

  const exercises = useMemo(() => practice.exercises.filter(e => e.level === level), [practice, level]);
  const groups = useMemo(() => groupByPassage(exercises, practice.passages), [exercises, practice.passages]);
  const gradable = useMemo(() => exercises.filter(isGradable), [exercises]);
  const questions = useMemo(
    () => Object.fromEntries(exercises.flatMap((e, i) => (e.kind === 'choice' ? [[e.id, asQuestion(e, i + 1)]] : []))),
    [exercises],
  );

  useEffect(() => {
    try {
      localStorage.setItem(storageKey(practice.id, level), JSON.stringify(progress));
    } catch {
      // Sense storage: el progrés només dura mentre la pàgina estiga oberta.
    }
  }, [progress, practice.id, level]);

  const changeLevel = (next: string) => {
    setLevel(next);
    setProgress(loadProgress(practice.id, next));
  };
  const answer = (id: string, value: string) =>
    setProgress(p => ({ ...p, answers: { ...p.answers, [id]: value } }));
  const check = () => {
    setProgress(p => ({ ...p, checked: true }));
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };
  const reset = () => {
    setProgress(p => ({ ...p, answers: {}, checked: false }));
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };
  const evaluationBody = (e: Evaluable) =>
    e.kind === 'form'
      ? { answers: Object.fromEntries(e.task.fields.map(f => [f, progress.forms[e.id]?.[f] ?? ''])) }
      : { text: progress.writings[e.id] ?? '' };
  const hasContent = (e: Evaluable) =>
    e.kind === 'form' ? e.task.fields.some(f => progress.forms[e.id]?.[f]?.trim()) : Boolean(progress.writings[e.id]?.trim());
  const evaluate = async (e: Evaluable) => {
    setEvaluating(e.id);
    setEvaluationError(undefined);
    try {
      const evaluation = await evaluatePracticeExercise(e.id, evaluationBody(e));
      setProgress(p => ({ ...p, evaluations: { ...p.evaluations, [e.id]: evaluation } }));
    } catch (error) {
      setEvaluationError({ id: e.id, message: error instanceof Error ? error.message : "No hem pogut avaluar l'exercici" });
    } finally {
      setEvaluating(undefined);
    }
  };

  const { answers, checked } = progress;
  const answered = gradable.filter(e => answers[e.id]?.trim()).length;
  const correct = gradable.filter(e => isCorrect(e, questions[e.id], answers[e.id])).length;
  const area = PRACTICE_AREAS[practice.category as PracticeArea];

  const renderExercise = (e: PracticeExercise, n: number) => {
    switch (e.kind) {
      case 'choice':
        return (
          <ChoiceExercise
            questions={[{ ...questions[e.id], n }]}
            answers={{ [n]: answers[e.id] }}
            checked={checked}
            onAnswer={(_n, key) => answer(e.id, key)}
          />
        );
      case 'fill':
        return (
          <FillQuestion
            n={n}
            prompt={e.prompt}
            value={answers[e.id] ?? ''}
            onChange={value => answer(e.id, value)}
            checked={checked}
            correct={isCorrect(e, undefined, answers[e.id])}
            solution={e.answers[0]}
          />
        );
      case 'writing':
      case 'form':
        return (
          <>
            <div className="mb-5 flex items-start gap-3">
              <span className="shrink-0 rounded-xl bg-orange px-3 py-1 text-sm font-black text-white">Tasca {n}</span>
              <p className="font-bold opacity-80">{e.prompt}</p>
            </div>
            {e.kind === 'writing' ? (
              <WritingExercise
                minWords={e.task.min_words}
                maxWords={e.task.max_words}
                words={e.task.words}
                minWordsUsed={e.task.min_words_used}
                value={progress.writings[e.id] ?? ''}
                onChange={value => setProgress(p => ({ ...p, writings: { ...p.writings, [e.id]: value } }))}
              />
            ) : (
              <FormExercise
                fields={e.task.fields}
                criteria={[]}
                maxPoints={0}
                values={progress.forms[e.id] ?? {}}
                onChange={(field, value) =>
                  setProgress(p => ({ ...p, forms: { ...p.forms, [e.id]: { ...p.forms[e.id], [field]: value } } }))}
              />
            )}
            <WritingEvaluationPanel
              evaluation={progress.evaluations[e.id]}
              loading={evaluating === e.id}
              error={evaluationError?.id === e.id ? evaluationError.message : undefined}
              canEvaluate={hasContent(e)}
              emptyHint={e.kind === 'form' ? 'Omple el formulari per a poder avaluar-lo.' : 'Escriu el text per a poder avaluar-lo.'}
              onEvaluate={() => evaluate(e)}
            />
          </>
        );
    }
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

      <div className="mx-auto flex max-w-3xl flex-col gap-6 px-5 pt-6 pb-24">
        {/* Portada */}
        <section className="relative overflow-hidden rounded-[2rem] bg-navy p-8 text-white shadow-xl">
          <div className="absolute -right-10 -top-10 h-48 w-48 rounded-full bg-mustard/20" aria-hidden="true" />
          <div className="relative flex flex-wrap items-center gap-6">
            <div
              className="grid h-24 w-24 shrink-0 place-items-center rounded-3xl text-5xl shadow-lg"
              style={{ background: practice.color ?? '#FFD166' }}
            >
              {practice.icon ?? '📘'}
            </div>
            <div className="min-w-[12rem] flex-1">
              <p className="text-sm font-black uppercase tracking-widest text-mustard">{area} · Nivell {level}</p>
              <h1 className="mt-1 text-3xl font-black">{practice.section_name ?? practice.name}</h1>
              {practice.content && <p className="mt-2 max-w-xl text-white/75">{practice.content}</p>}
            </div>
          </div>
          {levels.length > 1 && (
            <div className="relative mt-6 flex flex-wrap gap-2">
              {levels.map(l => (
                <button
                  key={l}
                  onClick={() => changeLevel(l)}
                  className={`btn-press rounded-full px-4 py-1.5 text-sm font-black ${l === level ? 'bg-mustard text-navy' : 'bg-white/10 hover:bg-white/20'}`}
                >
                  {l}
                </button>
              ))}
            </div>
          )}
        </section>

        {checked && gradable.length > 0 && <PracticeResult correct={correct} total={gradable.length} onReset={reset} />}

        {groups.map(group => (
          <section key={group.passage?.id ?? group.exercises[0].exercise.id} className="flex flex-col gap-4">
            {group.passage && <Passage passage={group.passage} showTranscript={checked} />}
            {group.exercises.map(({ exercise: e, n }) => (
              <article key={e.id} className="rounded-[1.75rem] bg-white p-6 shadow-sm">
                {renderExercise(e, n)}
                {checked && isGradable(e) && e.explanation && (
                  <p className="mt-4 flex items-start gap-2 rounded-xl bg-cream px-4 py-3 text-sm">
                    <Lightbulb size={16} className="mt-0.5 shrink-0 text-orange" />
                    <span>{e.explanation}</span>
                  </p>
                )}
              </article>
            ))}
          </section>
        ))}

        {gradable.length > 0 && (
          <div className="flex flex-wrap items-center justify-between gap-3">
            <p className="text-sm font-bold opacity-60">
              {checked ? `${correct} de ${gradable.length} encerts` : `${answered} de ${gradable.length} preguntes respostes`}
            </p>
            {checked ? (
              <button
                onClick={reset}
                className="btn-press flex items-center gap-2 rounded-full bg-teal px-6 py-3 font-black text-white shadow hover:bg-teal/90"
              >
                <RotateCcw size={18} /> Tornar a fer
              </button>
            ) : (
              <button
                onClick={check}
                disabled={answered === 0}
                className="btn-press rounded-full bg-orange px-6 py-3 font-black text-white shadow hover:bg-orange/90 disabled:opacity-50"
              >
                Corregir
              </button>
            )}
          </div>
        )}
      </div>
    </main>
  );
}

/* ── Text de lectura o àudio (amb la transcripció, un cop corregit) ─────── */
function Passage({ passage, showTranscript }: { passage: PracticePassage; showTranscript: boolean }) {
  const lines = (
    <div className="flex flex-col gap-3 whitespace-pre-line leading-relaxed">
      {passage.lines.map((line, i) => (
        <p key={i}>
          {line.speaker && <b>{line.speaker}: </b>}
          {line.text}
        </p>
      ))}
    </div>
  );
  if (passage.media === 'text') {
    return (
      <div className="rounded-2xl border-l-4 border-mustard bg-white px-6 py-5 shadow-sm">
        {passage.title && <h3 className="mb-3 text-xl font-black">{passage.title}</h3>}
        {lines}
      </div>
    );
  }
  return (
    <div className="flex flex-col gap-4 rounded-2xl border-2 border-teal/30 bg-white p-5">
      <div className="flex flex-wrap items-center gap-4">
        <span className="grid h-12 w-12 place-items-center rounded-full bg-teal text-white">
          <Headphones size={22} />
        </span>
        <div className="min-w-[12rem] flex-1">
          <p className="font-black">{passage.title ?? 'Àudio'}</p>
          <p className="text-sm opacity-60">Escolta'l dues vegades abans de respondre.</p>
        </div>
        {passage.audio_url ? (
          <audio controls preload="metadata" src={passage.audio_url} className="w-full sm:w-72" aria-label={`Àudio: ${passage.title ?? ''}`} />
        ) : (
          <p className="text-sm font-bold opacity-50">Àudio pròximament disponible</p>
        )}
      </div>
      {showTranscript && (
        <details className="rounded-xl bg-cream px-4 py-3">
          <summary className="cursor-pointer text-sm font-black">Transcripció</summary>
          <div className="mt-3 text-sm">{lines}</div>
        </details>
      )}
    </div>
  );
}

/* ── Pregunta de resposta escrita ──────────────────────────────────────── */
function FillQuestion({
  n, prompt, value, onChange, checked, correct, solution,
}: {
  n: number;
  prompt: string;
  value: string;
  onChange: (value: string) => void;
  checked: boolean;
  correct: boolean;
  solution: string;
}) {
  return (
    <div>
      <div className="mb-3 flex items-center gap-3">
        <QuestionNumber n={n} result={checked ? correct : undefined} />
        <p className="text-lg font-black">{prompt}</p>
      </div>
      <div className="flex flex-wrap items-center gap-3 pl-11">
        <input
          value={value}
          onChange={event => onChange(event.target.value)}
          disabled={checked}
          placeholder="Escriu la resposta"
          aria-label={`Resposta de la pregunta ${n}`}
          autoComplete="off"
          spellCheck={false}
          className={`w-full max-w-xs rounded-xl border-2 px-4 py-2.5 font-bold outline-none transition-colors focus:border-teal disabled:bg-white ${
            !checked ? 'border-ink/10' : correct ? 'border-teal bg-teal/10' : 'border-coral bg-coral/10'
          }`}
        />
        {checked && !correct && (
          <span className="text-sm font-bold">
            Resposta correcta: <span className="text-teal">{solution}</span>
          </span>
        )}
      </div>
    </div>
  );
}

function PracticeResult({ correct, total, onReset }: { correct: number; total: number; onReset: () => void }) {
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
        <p className="text-sm font-black uppercase tracking-wide text-teal">Exercicis corregits</p>
        <p className="text-2xl font-black">{message}</p>
        <p className="mt-1 text-sm opacity-70">Revisa les explicacions de cada pregunta.</p>
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
