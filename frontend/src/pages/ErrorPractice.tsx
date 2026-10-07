import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, CheckCircle2, XCircle } from 'lucide-react';
import { normalizeAnswer } from '@parlaval/shared';
import { Logo } from '../components/ui';
import { practiceRoute } from '../data/content';
import { fetchUserErrors, resolveUserError, type UserError } from '../lib/api';

type Result = 'right' | 'wrong';

const hash = (s: string) => [...s].reduce((h, c) => (Math.imul(h, 31) + c.charCodeAt(0)) | 0, 7);

// Frase de l'usuari amb la part errònia ressaltada (si no hi apareix literalment, es mostra sense ressaltar).
function Highlighted({ text, part }: { text: string; part: string }) {
  const i = text.toLowerCase().indexOf(part.trim().toLowerCase());
  if (i === -1 || part.trim() === '') return <>{text}</>;
  const end = i + part.trim().length;
  return <>{text.slice(0, i)}<mark className="rounded bg-orange/20 px-0.5 text-orange">{text.slice(i, end)}</mark>{text.slice(end)}</>;
}

// Una targeta per error: es mostra el text erroni i cal escriure'n la correcció.
// Si l'encerta, l'error queda resolt a la BDD.
function ErrorCard({ error, n, total, onFixed }: { error: UserError; n: number; total: number; onFixed: () => void }) {
  const [answer, setAnswer] = useState('');
  const [result, setResult] = useState<Result | null>(null);
  // Ordre estable però barrejat: en la BDD la correcta és sempre la primera.
  const options = useMemo(() => error.options && [...error.options].sort((a, b) => hash(error.id + a) - hash(error.id + b)), [error]);

  const check = () => {
    if (result === 'right' || answer.trim() === '') return;
    const ok = normalizeAnswer(answer) === normalizeAnswer(error.correction);
    setResult(ok ? 'right' : 'wrong');
    if (ok) {
      onFixed();
      resolveUserError(error.id).catch(err => console.error(err));
    }
  };

  return (
    <article className="rounded-3xl bg-white p-6 shadow-lg">
      <p className="text-sm font-extrabold uppercase tracking-wider opacity-55">
        Error {n} de {total} · {error.category}
      </p>
      {error.message && (
        <div className="mt-4 rounded-2xl bg-cream px-4 py-3">
          <p className="text-xs font-extrabold uppercase tracking-wider opacity-55">
            {error.source === 'practice' ? 'Pregunta' : 'Context'}{error.scenario ? ` · ${error.scenario}` : ''}
          </p>
          <p className="mt-1 font-semibold">
            {error.source === 'practice' ? error.message : <Highlighted text={error.message} part={error.error_text} />}
          </p>
          {/* Enllaç a la pregunta dins de la pràctica: també es pot corregir allí (obri la pàgina i la ressalta). */}
          {error.source === 'practice' && error.resource_id && (
            <Link
              to={`${practiceRoute(error.resource_id)}${error.exercise_id ? `?pregunta=${error.exercise_id}` : ''}`}
              className="mt-2 inline-flex items-center gap-1 text-sm font-extrabold text-teal underline-offset-2 hover:underline"
            >
              <ArrowRight size={14} /> Anar a la pregunta
            </Link>
          )}
        </div>
      )}
      <p className="mt-4 font-bold">{error.source === 'practice' ? 'La teua resposta (errònia):' : 'Com es corregix?'}</p>
      <p className="mt-1 rounded-2xl bg-orange/10 px-4 py-3 text-xl font-black text-orange">{error.error_text}</p>

      {options ? (
        <div className="mt-4 flex flex-col gap-2" role="radiogroup" aria-label={`Opcions de l'error ${n}`}>
          {options.map(option => (
            <button
              key={option}
              role="radio"
              aria-checked={answer === option}
              disabled={result === 'right'}
              onClick={() => { setAnswer(option); if (result === 'wrong') setResult(null); }}
              className={`btn-press rounded-2xl border-2 px-4 py-3 text-left text-lg font-bold ${
                answer === option ? 'border-teal bg-teal/10' : 'border-ink/15 bg-white'
              }`}
            >
              {option}
            </button>
          ))}
        </div>
      ) : null}

      <div className="mt-4 flex flex-wrap gap-3">
        {!options && (
          <input
            value={answer}
            onChange={e => { setAnswer(e.target.value); if (result === 'wrong') setResult(null); }}
            onKeyDown={e => { if (e.key === 'Enter') check(); }}
            disabled={result === 'right'}
            placeholder="Escriu la correcció"
            aria-label={`Correcció de l'error ${n}`}
            className="min-w-0 flex-1 rounded-2xl border-2 border-ink/15 px-4 py-3 text-lg font-bold outline-none focus:border-teal"
          />
        )}
        <button
          onClick={check}
          disabled={result === 'right' || answer.trim() === ''}
          className="btn-press rounded-full bg-teal px-6 py-3 font-black text-white disabled:opacity-40"
        >
          Comprova
        </button>
      </div>

      {result && (
        <div className={`mt-4 rounded-2xl p-4 ${result === 'right' ? 'bg-green-100' : 'bg-orange/10'}`}>
          <p className="flex items-center gap-2 font-black">
            {result === 'right' ? <CheckCircle2 size={20} /> : <XCircle size={20} />}
            {result === 'right' ? 'Correcte!' : `La forma correcta és: ${error.correction}`}
          </p>
          <p className="mt-1 font-semibold opacity-80">{error.explanation}</p>
        </div>
      )}
    </article>
  );
}

// Pràctica dels errors que l'usuari ha comés en els xats, tots en una llista amb scroll.
export function ErrorPractice({ onBack }: { onBack: () => void }) {
  // undefined = carregant; null = error de càrrega.
  const [errors, setErrors] = useState<UserError[] | null>();
  const [fixed, setFixed] = useState(0);

  useEffect(() => {
    let cancelled = false;
    fetchUserErrors()
      .then(data => { if (!cancelled) setErrors(data); })
      .catch(error => {
        console.error('Error carregant els errors:', error);
        if (!cancelled) setErrors(null);
      });
    return () => { cancelled = true; };
  }, []);

  const body = () => {
    if (errors === undefined) return <p className="text-center font-bold opacity-60">Carregant…</p>;
    if (errors === null) return <p className="text-center font-bold text-orange">No hem pogut carregar els errors. Torna-ho a provar més tard.</p>;
    if (errors.length === 0) {
      return (
        <div className="rounded-3xl bg-white p-8 text-center shadow-lg">
          <p className="text-2xl font-black">Cap error pendent! 🎉</p>
          <p className="mt-2 font-semibold opacity-70">Quan cometes errors als xats, els trobaràs ací per a practicar-los.</p>
        </div>
      );
    }
    return (
      <div className="flex flex-col gap-5">
        <p className="text-center font-bold opacity-70">Corregits: {fixed} de {errors.length}</p>
        {errors.map((error, i) => (
          <ErrorCard key={error.id} error={error} n={i + 1} total={errors.length} onFixed={() => setFixed(n => n + 1)} />
        ))}
      </div>
    );
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
      <div className="mx-auto max-w-2xl px-5 pt-6 pb-24">
        <h1 className="mb-6 text-center text-4xl font-black uppercase tracking-wider opacity-55">Els meus errors</h1>
        {body()}
      </div>
    </main>
  );
}
