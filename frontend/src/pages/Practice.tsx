import { useEffect, useMemo, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { ChevronLeft, ChevronRight, Headphones, Lightbulb, RotateCcw } from 'lucide-react';
import { LEVEL_CEFR, normalizeAnswer, PRACTICE_AREAS, type LevelKey, type PracticeArea } from '@parlaval/shared';
import { Logo } from '../components/ui';
import { ChoiceExercise, FormExercise, QuestionNumber, WritingEvaluationPanel, WritingExercise } from '../components/ExamExercises';
import { evaluatePracticeExercise, fetchUserErrors, recordPracticeAnswers, saveActivityResult } from '../lib/api';
import type { ExamQuestion, Practice as PracticeResource, PracticeExercise, PracticePassage, WritingEvaluation } from '../lib/types';

type Progress = {
  answers: Record<string, string>; // preguntes tancades: id de l'exercici -> resposta
  checked: boolean;
  retry: Record<string, boolean>; // preguntes fallades que s'estan tornant a provar: id -> true
  writings: Record<string, string>; // redaccions: id -> text
  forms: Record<string, Record<string, string>>; // formularis: id -> camp -> valor
  evaluations: Record<string, WritingEvaluation>; // avaluació amb IA per exercici
};
const EMPTY: Progress = { answers: {}, checked: false, retry: {}, writings: {}, forms: {}, evaluations: {} };

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

// Nota d'una redacció o d'un formulari avaluat, per a la ruta d'aprenentatge.
const writingMark = (evaluation: WritingEvaluation) => {
  switch (evaluation.rubrica) {
    case 'a2_redaccio': return { score: evaluation.mitjana_ponderada_base_10, total: 10 };
    case 'b1_redaccio': return { score: evaluation.mitjana_base_10, total: 10 };
    default: return { score: evaluation.puntuacio_global, total: 15 };
  }
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

// Les àrees de continguts lingüístics tenen moltes preguntes soltes (35 o més)
// i es mostren per pàgines; les destreses (textos, àudios, redaccions) no.
const PAGINATED_AREAS: readonly string[] = ['fonetica_ortografia', 'morfosintaxi', 'lexic_semantica'];
const PAGE_SIZE = 10;
// Les preguntes soltes van juntes en un mateix grup (sense text): es partixen
// en grups de PAGE_SIZE, i cada grup és una pàgina. Un text o àudio no es partix.
function paginate(groups: Group[]): Group[][] {
  return groups.flatMap(group => {
    if (group.passage) return [[group]];
    const pages: Group[][] = [];
    for (let i = 0; i < group.exercises.length; i += PAGE_SIZE) {
      pages.push([{ exercises: group.exercises.slice(i, i + PAGE_SIZE) }]);
    }
    return pages;
  });
}

export function Practice({ practice, userLevel, onBack }: { practice: PracticeResource; userLevel: string; onBack: () => void }) {
  // Només els nivells del MECR de l'aprenent (A1-A2, B1-B2 o C1-C2); si el
  // contingut no en té cap (p. ex. un enllaç directe), es mostren tots.
  // ?pregunta=<id> (enllaç des de «Errors»): s'obri el nivell i la pàgina d'eixa pregunta i es ressalta.
  const [searchParams] = useSearchParams();
  const target = practice.exercises.find(e => e.id === searchParams.get('pregunta'));
  const levels = useMemo(() => {
    const all = [...new Set(practice.exercises.map(e => e.level))];
    const own = all.filter(l => LEVEL_CEFR[userLevel as LevelKey]?.includes(l) || l === target?.level);
    return own.length ? own : all;
  }, [practice, userLevel, target?.level]);
  const [level, setLevel] = useState(target?.level ?? levels[0]);
  const [focusId, setFocusId] = useState(target?.id);
  const [progress, setProgress] = useState<Progress>(() => loadProgress(practice.id, level));
  // Preguntes d'este contingut amb un error pendent (pestanya «Errors»): es mostren com a fallades, amb la
  // resposta errònia, fins que es contesten bé (en l'exercici o en «Errors»).
  const [failed, setFailed] = useState<ReadonlySet<string>>(new Set());
  const [evaluating, setEvaluating] = useState<string>();
  const [evaluationError, setEvaluationError] = useState<{ id: string; message: string }>();
  const [page, setPage] = useState(0);

  const exercises = useMemo(() => practice.exercises.filter(e => e.level === level), [practice, level]);
  const groups = useMemo(() => groupByPassage(exercises, practice.passages), [exercises, practice.passages]);
  const pages = useMemo(
    () => (PAGINATED_AREAS.includes(practice.category) ? paginate(groups) : [groups]),
    [groups, practice.category],
  );
  const currentPage = pages[Math.min(page, pages.length - 1)] ?? [];
  const gradable = useMemo(() => exercises.filter(isGradable), [exercises]);

  // Porta a la pregunta de l'enllaç: canvia a la seua pàgina, hi fa scroll i, passats uns segons, lleva el ressaltat.
  useEffect(() => {
    if (!focusId) return;
    const index = pages.findIndex(p => p.some(g => g.exercises.some(x => x.exercise.id === focusId)));
    if (index >= 0 && index !== page) return setPage(index);
    document.getElementById(`pregunta-${focusId}`)?.scrollIntoView({ block: 'center', behavior: 'smooth' });
    const timer = window.setTimeout(() => setFocusId(undefined), 4000);
    return () => window.clearTimeout(timer);
  }, [focusId, pages, page]);
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

  useEffect(() => {
    let cancelled = false;
    fetchUserErrors()
      .then(errors => {
        if (cancelled) return;
        const pending = errors.filter(e => e.source === 'practice' && e.exercise_id && practice.exercises.some(x => x.id === e.exercise_id));
        if (pending.length === 0) return;
        setFailed(new Set(pending.map(e => e.exercise_id!)));
        // La resposta errònia queda marcada: per a les tancades, l'opció amb eixe text.
        setProgress(p => {
          const answers = { ...p.answers };
          for (const e of pending) {
            const exercise = practice.exercises.find(x => x.id === e.exercise_id);
            if (!exercise || !isGradable(exercise) || answers[exercise.id]?.trim()) continue;
            const key = exercise.kind === 'choice'
              ? asQuestion(exercise, 0).options?.find(o => o.text === e.error_text)?.key
              : e.error_text;
            if (key) answers[exercise.id] = key;
          }
          return { ...p, answers };
        });
      })
      .catch(error => console.error('Error carregant els errors pendents:', error));
    return () => { cancelled = true; };
  }, [practice]);

  const changeLevel = (next: string) => {
    setLevel(next);
    setProgress(loadProgress(practice.id, next));
    setPage(0);
  };
  const goToPage = (next: number) => {
    setPage(next);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };
  const answer = (id: string, value: string) =>
    setProgress(p => ({ ...p, answers: { ...p.answers, [id]: value } }));
  const check = () => {
    // El backend corregix les respostes i torna els errors, que es guarden en este navegador
    // perquè isquen a la pestanya «Errors».
    // Les preguntes tancades guarden la clau de l'opció: s'envia el text.
    const sent = gradable.flatMap(e => {
      const value = progress.answers[e.id];
      if (!value?.trim()) return [];
      const text = e.kind === 'choice' ? questions[e.id]?.options?.find(o => o.key === value)?.text : value;
      return text ? [{ exercise_id: e.id, answer: text }] : [];
    });
    recordPracticeAnswers(sent, practice.name).catch(error => console.error('Error enviant les respostes:', error));
    setProgress(p => ({ ...p, checked: true, retry: {} }));
    // El resultat alimenta la ruta d'aprenentatge personalitzada.
    void saveActivityResult('practice', practice.id, { level, score: correct, total: gradable.length });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };
  const reset = () => {
    setProgress(p => ({ ...p, answers: {}, checked: false, retry: {} }));
    setPage(0);
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
      const evaluation = await evaluatePracticeExercise(e.id, evaluationBody(e), practice.name);
      setProgress(p => ({ ...p, evaluations: { ...p.evaluations, [e.id]: evaluation } }));
      void saveActivityResult('practice', practice.id, { level, ...writingMark(evaluation), details: { exercise_id: e.id, rubrica: evaluation.rubrica ?? 'a1_formulari' } });
    } catch (error) {
      setEvaluationError({ id: e.id, message: error instanceof Error ? error.message : "No hem pogut avaluar l'exercici" });
    } finally {
      setEvaluating(undefined);
    }
  };

  const { answers, checked, retry } = progress;
  // Una pregunta fallada es pot tornar a provar sense eixir de l'exercici: s'esborra la resposta, es contesta de nou
  // i «Comprova» la torna a enviar (si és correcta, l'error de la pestanya «Errors» queda resolt).
  const isDone = (id: string) => (checked || failed.has(id)) && !retry[id];
  const retryQuestion = (id: string) =>
    setProgress(p => ({ ...p, answers: { ...p.answers, [id]: '' }, retry: { ...p.retry, [id]: true } }));
  const recheckQuestion = (e: Gradable) => {
    const value = answers[e.id];
    const text = e.kind === 'choice' ? questions[e.id]?.options?.find(o => o.key === value)?.text : value;
    if (!text?.trim()) return;
    recordPracticeAnswers([{ exercise_id: e.id, answer: text }], practice.name).catch(error => console.error('Error enviant la resposta:', error));
    setProgress(p => ({ ...p, retry: { ...p.retry, [e.id]: false } }));
  };
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
            checked={isDone(e.id)}
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
            checked={isDone(e.id)}
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
          <Logo onDark />
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
              style={{ background: practice.color ?? '#FDE94D' }}
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

        {currentPage.map(group => (
          <section key={group.passage?.id ?? group.exercises[0].exercise.id} className="flex flex-col gap-4">
            {group.passage && <Passage passage={group.passage} showTranscript={checked} />}
            {group.exercises.map(({ exercise: e, n }) => (
              <article key={e.id} id={`pregunta-${e.id}`} className={`rounded-[1.75rem] bg-white p-6 shadow-sm ${e.id === focusId ? 'ring-4 ring-mustard' : ''}`}>
                {renderExercise(e, n)}
                {isGradable(e) && isDone(e.id) && !isCorrect(e, questions[e.id], answers[e.id]) && (
                  <button
                    onClick={() => retryQuestion(e.id)}
                    className="btn-press mt-4 flex items-center gap-2 rounded-full bg-cream px-4 py-2 text-sm font-black text-teal hover:bg-teal/10"
                  >
                    <RotateCcw size={16} /> Torna-ho a provar
                  </button>
                )}
                {isGradable(e) && retry[e.id] && (
                  <button
                    onClick={() => recheckQuestion(e)}
                    disabled={!answers[e.id]?.trim()}
                    className="btn-press mt-4 rounded-full bg-orange px-5 py-2 text-sm font-black text-white shadow hover:bg-orange/90 disabled:opacity-50"
                  >
                    Comprova
                  </button>
                )}
                {isGradable(e) && isDone(e.id) && e.explanation && (
                  <p className="mt-4 flex items-start gap-2 rounded-xl bg-cream px-4 py-3 text-sm">
                    <Lightbulb size={16} className="mt-0.5 shrink-0 text-orange" />
                    <span>{e.explanation}</span>
                  </p>
                )}
              </article>
            ))}
          </section>
        ))}

        {pages.length > 1 && <Pagination page={page} pages={pages} answers={answers} onChange={goToPage} />}

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

/* ── Paginació ─────────────────────────────────────────────────────────── */
// Els números de les pàgines amb totes les preguntes respostes es marquen, perquè
// es veja d'un colp d'ull què falta abans de corregir.
function Pagination({
  page, pages, answers, onChange,
}: {
  page: number;
  pages: Group[][];
  answers: Record<string, string>;
  onChange: (page: number) => void;
}) {
  const isDone = (groups: Group[]) =>
    groups.every(g => g.exercises.every(({ exercise: e }) => !isGradable(e) || Boolean(answers[e.id]?.trim())));
  const arrow = 'btn-press grid h-10 w-10 place-items-center rounded-full bg-white shadow-sm hover:bg-teal/10 disabled:opacity-30';
  return (
    <nav aria-label="Pàgines d'exercicis" className="flex flex-wrap items-center justify-center gap-2">
      <button onClick={() => onChange(page - 1)} disabled={page === 0} aria-label="Pàgina anterior" className={arrow}>
        <ChevronLeft size={18} />
      </button>
      {pages.map((groups, i) => (
        <button
          key={i}
          onClick={() => onChange(i)}
          aria-current={i === page ? 'page' : undefined}
          aria-label={`Pàgina ${i + 1}${isDone(groups) ? ', completa' : ''}`}
          className={`btn-press h-10 min-w-10 rounded-full px-3 text-sm font-black shadow-sm transition-colors ${
            i === page ? 'bg-teal text-white' : isDone(groups) ? 'bg-teal/15 text-teal hover:bg-teal/25' : 'bg-white hover:bg-teal/10'
          }`}
        >
          {i + 1}
        </button>
      ))}
      <button onClick={() => onChange(page + 1)} disabled={page === pages.length - 1} aria-label="Pàgina següent" className={arrow}>
        <ChevronRight size={18} />
      </button>
    </nav>
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
        style={{ background: `conic-gradient(#3366C4 ${pct * 3.6}deg, #E7E5E4 0deg)` }}
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
