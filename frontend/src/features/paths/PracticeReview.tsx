import { useEffect, useState } from 'react';
import { Check, X } from 'lucide-react';
import { normalizeAnswer } from '@parlaval/shared';
import { fetchPractice } from '../../lib/api';
import type { Practice, PracticeExercise } from '../../lib/types';

type Gradable = Extract<PracticeExercise, { kind: 'choice' | 'fill' }>;
const isGradable = (e: PracticeExercise): e is Gradable => e.kind === 'choice' || e.kind === 'fill';

/**
 * Les respostes d'un alumne en uns exercicis, per a la docent: cada pregunta amb el que ha
 * contestat, si és correcte, la resposta bona i l'explicació. `answers` ve dels detalls del
 * resultat (exercise_id → text contestat); `level`, del nivell que va fer (A1, A2...).
 */
export function PracticeReview({ resourceId, level, answers, name, when, onClose }: {
  resourceId: string;
  level: string | null;
  answers: Record<string, string>;
  name: string;
  when: string;
  onClose: () => void;
}) {
  const [practice, setPractice] = useState<Practice | null>();
  const [onlyWrong, setOnlyWrong] = useState(false);

  useEffect(() => {
    fetchPractice(resourceId).then(setPractice).catch(e => {
      console.error(e);
      setPractice(null);
    });
  }, [resourceId]);

  useEffect(() => {
    // En captura i sense propagar: Escape tanca només esta finestra, no la de davall.
    const onKey = (e: KeyboardEvent) => {
      if (e.key !== 'Escape') return;
      e.stopPropagation();
      onClose();
    };
    window.addEventListener('keydown', onKey, true);
    return () => window.removeEventListener('keydown', onKey, true);
  }, [onClose]);

  // Les preguntes del nivell que va fer (si no se sap, les que va contestar).
  const exercises = (practice?.exercises ?? []).filter(isGradable).filter(e => (level ? e.level === level : e.id in answers));
  const isRight = (e: Gradable) => e.id in answers && e.answers.some(a => normalizeAnswer(a) === normalizeAnswer(answers[e.id]));
  const right = exercises.filter(isRight).length;
  const shown = onlyWrong ? exercises.filter(e => !isRight(e)) : exercises;

  return (
    <div className="fixed inset-0 z-[60] grid place-items-center bg-ink/50 p-4" onClick={onClose} role="dialog" aria-modal="true" aria-label={`Respostes de ${name}`}>
      <div className="max-h-[92vh] w-full max-w-3xl overflow-y-auto rounded-3xl bg-[#FAFAF9] p-5 shadow-xl" onClick={e => e.stopPropagation()}>
        <div className="flex items-start justify-between gap-3">
          <div>
            <h2 className="text-3xl font-black">{practice?.section_name ?? practice?.name ?? 'Exercicis'}</h2>
            <p className="opacity-70">{name || 'Alumne'} · {when}{level ? ` · ${level}` : ''}</p>
          </div>
          <button onClick={onClose} aria-label="Tanca" className="btn-press rounded-full bg-white p-2 shadow-sm"><X size={20} /></button>
        </div>

        {practice === undefined && <p className="mt-4 opacity-60">Carregant…</p>}
        {practice === null && <p className="mt-4 text-coral">No s'han pogut carregar els exercicis.</p>}
        {practice && (
          <>
            <div className="mt-4 flex flex-wrap items-center gap-3">
              <span className="rounded-full bg-white px-4 py-1.5 text-lg font-black shadow-sm">{right}/{exercises.length} correctes</span>
              <label className="flex items-center gap-2 font-bold">
                <input type="checkbox" checked={onlyWrong} onChange={e => setOnlyWrong(e.target.checked)} className="h-4 w-4" />
                Només les fallades
              </label>
            </div>
            <ol className="mt-4 flex flex-col gap-3">
              {shown.map(e => {
                const given = answers[e.id];
                const ok = isRight(e);
                return (
                  <li key={e.id} className={`rounded-2xl border-2 bg-white p-4 ${ok ? 'border-teal/30' : 'border-coral/40'}`}>
                    <div className="flex items-start gap-3">
                      <span className={`grid h-8 w-8 shrink-0 place-items-center rounded-full text-white ${ok ? 'bg-teal' : given ? 'bg-coral' : 'bg-gray-300'}`}>
                        {ok ? <Check size={18} strokeWidth={3} /> : <X size={18} strokeWidth={3} />}
                      </span>
                      <div className="min-w-0 flex-1">
                        <p className="whitespace-pre-line text-lg font-bold">{e.prompt}</p>
                        {e.kind === 'choice' ? (
                          <ul className="mt-2 flex flex-wrap gap-2">
                            {e.options.map(option => {
                              const correct = e.answers.some(a => normalizeAnswer(a) === normalizeAnswer(option));
                              const chosen = given !== undefined && normalizeAnswer(given) === normalizeAnswer(option);
                              return (
                                <li
                                  key={option}
                                  className={`rounded-xl border-2 px-3 py-1 ${correct ? 'border-teal bg-teal/10 font-bold' : chosen ? 'border-coral bg-coral/10' : 'border-gray-100 opacity-60'}`}
                                >
                                  <span className={chosen && !correct ? 'line-through' : ''}>{option}</span>
                                  {chosen && <span className="ml-1 text-xs font-black">← {name || 'alumne'}</span>}
                                </li>
                              );
                            })}
                          </ul>
                        ) : (
                          <p className="mt-2">
                            <span className="opacity-60">Ha escrit: </span>
                            <b className={ok ? 'text-teal' : 'text-coral'}>{given ?? '(sense resposta)'}</b>
                            {!ok && <><span className="ml-3 opacity-60">Correcta: </span><b className="text-teal">{e.answers[0]}</b></>}
                          </p>
                        )}
                        {!given && <p className="mt-1 text-sm opacity-60">No la va contestar.</p>}
                        {!ok && e.explanation && <p className="mt-2 rounded-xl bg-cream px-3 py-2 text-sm">{e.explanation}</p>}
                      </div>
                    </div>
                  </li>
                );
              })}
            </ol>
            {onlyWrong && !shown.length && <p className="mt-4 text-lg font-bold text-teal">Totes correctes!</p>}
          </>
        )}
      </div>
    </div>
  );
}

/** Una resposta fallada guardada en user_errors (per als intents sense totes les respostes). */
export type SavedError = { prompt: string; answer: string; correction: string; explanation: string | null };

/**
 * Les fallades d'un intent antic d'exercicis: d'abans que es guardaren totes les respostes,
 * només hi ha les que va fallar (pregunta, què va contestar, la bona i l'explicació).
 */
export function ErrorsReview({ title, errors, score, total, name, when, onClose }: {
  title: string;
  errors: SavedError[];
  score: number | null;
  total: number | null;
  name: string;
  when: string;
  onClose: () => void;
}) {
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key !== 'Escape') return;
      e.stopPropagation();
      onClose();
    };
    window.addEventListener('keydown', onKey, true);
    return () => window.removeEventListener('keydown', onKey, true);
  }, [onClose]);

  return (
    <div className="fixed inset-0 z-[60] grid place-items-center bg-ink/50 p-4" onClick={onClose} role="dialog" aria-modal="true" aria-label={`Fallades de ${name}`}>
      <div className="max-h-[92vh] w-full max-w-3xl overflow-y-auto rounded-3xl bg-[#FAFAF9] p-5 shadow-xl" onClick={e => e.stopPropagation()}>
        <div className="flex items-start justify-between gap-3">
          <div>
            <h2 className="text-3xl font-black">{title}</h2>
            <p className="opacity-70">{name || 'Alumne'} · {when}</p>
          </div>
          <button onClick={onClose} aria-label="Tanca" className="btn-press rounded-full bg-white p-2 shadow-sm"><X size={20} /></button>
        </div>
        <div className="mt-4 flex flex-wrap items-center gap-3">
          {score !== null && total ? <span className="rounded-full bg-white px-4 py-1.5 text-lg font-black shadow-sm">{score}/{total} correctes</span> : null}
          <span className="rounded-full bg-coral/10 px-4 py-1.5 text-lg font-black text-coral">{errors.length} fallades</span>
        </div>
        <p className="mt-2 text-sm opacity-60">D'este intent només es van guardar les preguntes fallades (les respostes completes es guarden des d'ara).</p>
        <ol className="mt-4 flex flex-col gap-3">
          {errors.map((e, i) => (
            <li key={i} className="rounded-2xl border-2 border-coral/40 bg-white p-4">
              <div className="flex items-start gap-3">
                <span className="grid h-8 w-8 shrink-0 place-items-center rounded-full bg-coral text-white"><X size={18} strokeWidth={3} /></span>
                <div className="min-w-0 flex-1">
                  <p className="whitespace-pre-line text-lg font-bold">{e.prompt}</p>
                  <p className="mt-2">
                    <span className="opacity-60">Va contestar: </span><b className="text-coral line-through">{e.answer}</b>
                    <span className="ml-3 opacity-60">Correcta: </span><b className="text-teal">{e.correction}</b>
                  </p>
                  {e.explanation && <p className="mt-2 rounded-xl bg-cream px-3 py-2 text-sm">{e.explanation}</p>}
                </div>
              </div>
            </li>
          ))}
        </ol>
      </div>
    </div>
  );
}
