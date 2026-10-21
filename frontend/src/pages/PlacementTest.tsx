import { useEffect, useState } from 'react';
import { countWords, levelLabel, WRITING_MAX_CHARS } from '@parlaval/shared';
import { Logo } from '../components/ui';
import { noClipboard } from '../components/ExamExercises';
import { fetchPlacementTest, submitPlacementTest, type PlacementResult, type PlacementTest as Test } from '../lib/api';

type Step = 'intro' | 'test' | 'sending' | 'result' | 'changed';

const BUTTON = 'btn-press rounded-full px-6 py-3 text-lg font-black shadow transition-colors disabled:opacity-50';
const PRIMARY = `${BUTTON} bg-[#0F47AF] text-white hover:bg-[#0F47AF]/90`;
const SECONDARY = `${BUTTON} bg-gray-100 text-gray-600 hover:bg-gray-200`;

/**
 * Prova de nivell per a adults: preguntes tancades de l'A2 al C1 i una redacció breu que s'avalua
 * amb la rúbrica de l'Expressió escrita del nivell actual. El resultat és una proposta: l'usuari
 * decidix si canvia de nivell.
 */
export function PlacementTest({ level, onAccept, onDone }: {
  level: string;
  // Canvia el nivell i torna les classes on està que no són del nivell nou.
  onAccept: (level: string) => Promise<string[]>;
  onDone: () => void;
}) {
  const [step, setStep] = useState<Step>('intro');
  // undefined = carregant; null = error.
  const [test, setTest] = useState<Test | null>();
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [text, setText] = useState('');
  const [result, setResult] = useState<PlacementResult>();
  const [classesOutside, setClassesOutside] = useState<string[]>([]);
  const [error, setError] = useState<string>();

  useEffect(() => {
    if (step !== 'test' || test !== undefined) return;
    fetchPlacementTest()
      .then(setTest)
      .catch(err => { console.error(err); setTest(null); });
  }, [step, test]);

  const words = countWords(text);
  const answered = Object.keys(answers).length;

  const send = async () => {
    if (!test) return;
    setError(undefined);
    setStep('sending');
    try {
      const r = await submitPlacementTest(
        test.questions.map(q => ({ exercise_id: q.id, answer: answers[q.id] ?? '' })),
        text,
      );
      setResult(r);
      setStep('result');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'No hem pogut corregir la prova');
      setStep('test');
    }
  };

  const accept = async () => {
    if (!result) return;
    setError(undefined);
    try {
      setClassesOutside(await onAccept(result.suggested));
      setStep('changed');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'No hem pogut canviar el nivell');
    }
  };

  const body = () => {
    switch (step) {
      case 'intro':
        return (
          <div className="rounded-3xl bg-white p-8 shadow-lg">
            <h2 className="text-2xl font-black">Quin és el teu nivell?</h2>
            <p className="mt-3 text-lg">
              Contestaràs 40 preguntes de gramàtica i vocabulari (10 de cada nivell, de l'A2 al C1, de més fàcils a més difícils) i escriuràs un text breu sobre tu.
              Tardaràs uns 25 minuts.
            </p>
            <p className="mt-3 text-lg">
              Al final et proposarem un nivell i <strong>tu decidixes</strong> si el vols. De moment tens el nivell <strong>{levelLabel(level)}</strong>,
              i el podràs canviar quan vulgues des del perfil.
            </p>
            <div className="mt-6 flex flex-wrap gap-3">
              <button onClick={() => setStep('test')} className={PRIMARY}>Comença la prova</button>
              <button onClick={onDone} className={SECONDARY}>Ara no</button>
            </div>
          </div>
        );

      case 'test':
      case 'sending':
        if (test === undefined) return <p className="text-center font-bold opacity-60">Preparant la prova…</p>;
        if (test === null) return <p className="text-center font-bold text-orange">No hem pogut preparar la prova. Torna-ho a provar més tard.</p>;
        return (
          <div className="flex flex-col gap-5">
            {test.questions.map((q, i) => (
              <article key={q.id} className="rounded-3xl bg-white p-6 shadow-lg">
                <p className="text-sm font-extrabold uppercase tracking-wider opacity-55">Pregunta {i + 1} de {test.questions.length}</p>
                <p className="mt-2 text-lg font-bold">{q.prompt}</p>
                <div className="mt-3 flex flex-col gap-2" role="radiogroup" aria-label={`Opcions de la pregunta ${i + 1}`}>
                  {q.options.map(option => (
                    <button
                      key={option}
                      role="radio"
                      aria-checked={answers[q.id] === option}
                      disabled={step === 'sending'}
                      onClick={() => setAnswers(a => ({ ...a, [q.id]: option }))}
                      className={`btn-press rounded-2xl border-2 px-4 py-3 text-left text-lg font-bold ${
                        answers[q.id] === option ? 'border-teal bg-teal/10' : 'border-ink/15 bg-white'
                      }`}
                    >
                      {option}
                    </button>
                  ))}
                </div>
              </article>
            ))}

            <article className="rounded-3xl bg-white p-6 shadow-lg">
              <p className="text-sm font-extrabold uppercase tracking-wider opacity-55">Redacció</p>
              <p className="mt-2 text-lg font-bold">{test.writing.prompt}</p>
              <p className="mt-1 text-sm opacity-70">
                Entre {test.writing.min_words} i {test.writing.max_words} paraules. Si no saps escriure-la, pots deixar-la en blanc:
                aleshores el nivell es proposarà només amb les preguntes.
              </p>
              <textarea
                value={text}
                onChange={e => setText(e.target.value)}
                maxLength={WRITING_MAX_CHARS}
                {...noClipboard}
                disabled={step === 'sending'}
                rows={7}
                className="mt-3 w-full rounded-2xl border-2 border-gray-100 p-3 text-lg outline-none focus:border-[#0F47AF] transition-colors"
              />
              <p className={`mt-1 text-sm font-bold ${words > 0 && words < test.writing.min_words ? 'text-orange' : 'opacity-60'}`}>
                {words} {words === 1 ? 'paraula' : 'paraules'}
              </p>
            </article>

            <div className="flex flex-wrap items-center gap-3">
              <button onClick={() => void send()} disabled={step === 'sending'} className={PRIMARY}>
                {step === 'sending' ? 'Corregint…' : 'Envia la prova'}
              </button>
              <span className="font-bold opacity-60">Has contestat {answered} de {test.questions.length} preguntes.</span>
            </div>
          </div>
        );

      case 'result': {
        if (!result) return null;
        const same = result.suggested === level;
        return (
          <div className="rounded-3xl bg-white p-8 shadow-lg">
            <p className="text-sm font-extrabold uppercase tracking-wider opacity-55">El nivell que et proposem</p>
            <p className="mt-1 text-5xl font-black text-[#0F47AF]">{levelLabel(result.suggested)}</p>

            <h3 className="mt-6 text-lg font-black">Preguntes</h3>
            <ul className="mt-1 space-y-1">
              {Object.entries(result.questions.per_level).map(([l, { correct, total }]) => (
                <li key={l} className="font-semibold">{l}: {correct} de {total} encerts</li>
              ))}
            </ul>

            {result.text_status !== 'not_needed' && <h3 className="mt-4 text-lg font-black">Redacció</h3>}
            {result.text ? (
              <>
                <p className="font-semibold">
                  {result.text.mark.toLocaleString('ca')} de 10 amb la rúbrica de l'{result.text.rubric}
                  {' '}(mínim {result.text.pass_mark}): {result.text.passed ? 'superada ✅' : 'no superada ❌'}
                </p>
                <p className="mt-1 opacity-80">{result.text.feedback}</p>
              </>
            ) : result.text_status !== 'not_needed' && (
              <p className="opacity-80">
                {result.text_status === 'unavailable'
                  ? "Ara mateix no l'hem poguda avaluar: la proposta es basa només en les preguntes."
                  : 'Era massa curta per a avaluar-la: la proposta es basa només en les preguntes.'}
              </p>
            )}

            <p className="mt-6 text-lg">
              {same
                ? <>Ja estàs en el nivell <strong>{levelLabel(level)}</strong>. 🎉</>
                : <>Ara estàs en el nivell <strong>{levelLabel(level)}</strong>. Vols canviar al <strong>{levelLabel(result.suggested)}</strong>? S'esborraran la teua ruta personalitzada i els errors pendents, i ho pots tornar a canviar quan vulgues des del perfil.</>}
            </p>
            <div className="mt-5 flex flex-wrap gap-3">
              {same ? (
                <button onClick={onDone} className={PRIMARY}>Continua</button>
              ) : (
                <>
                  <button onClick={() => void accept()} className={PRIMARY}>Canvia al nivell {levelLabel(result.suggested)}</button>
                  <button onClick={onDone} className={SECONDARY}>Em quede en {levelLabel(level)}</button>
                </>
              )}
            </div>
          </div>
        );
      }

      case 'changed':
        return (
          <div className="rounded-3xl bg-white p-8 shadow-lg">
            <p className="text-2xl font-black">Ara estàs en el nivell {levelLabel(level)}. 🎉</p>
            <p className="mt-2 text-lg opacity-80">Les activitats i les rutes ja són les del teu nivell nou.</p>
            {classesOutside.length > 0 && (
              <p className="mt-3 rounded-2xl bg-orange/10 px-4 py-3 font-semibold text-orange">
                {classesOutside.length === 1 ? 'La classe' : 'Les classes'} «{classesOutside.join('», «')}» no {classesOutside.length === 1 ? 'és' : 'són'} del teu nivell nou.
                Continues dins, però potser cal que en parles amb la docent.
              </p>
            )}
            <button onClick={onDone} className={`${PRIMARY} mt-5`}>Continua</button>
          </div>
        );
    }
  };

  return (
    <main className="fade-up relative min-h-screen bg-cream text-ink">
      <header className="classroom-header z-10">
        <div className="relative isolate flex items-center justify-between px-5 p-4">
          <button
            onClick={onDone}
            className="text-xl btn-press rounded-full bg-white/90 px-4 py-2 text-sm font-extrabold text-teal shadow hover:bg-white transition-colors"
          >
            ← Tornar
          </button>
          <Logo onDark />
          <span className="w-24" aria-hidden="true" />
        </div>
      </header>
      <div className="mx-auto max-w-2xl px-5 pt-6 pb-24">
        <h1 className="mb-6 text-center text-4xl font-black uppercase tracking-wider opacity-55">Prova de nivell</h1>
        {error && <p role="alert" className="mb-4 rounded-2xl bg-orange/10 px-4 py-3 text-center font-bold text-orange">{error}</p>}
        {body()}
      </div>
    </main>
  );
}
