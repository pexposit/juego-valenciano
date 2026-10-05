import { useEffect, useState } from 'react';
import { fetchLatestEvaluation } from '../lib/api';
import type { LatestEvaluation } from '../lib/types';

// L'avaluació del xat es fa en segon pla en acabar-lo: es consulta cada pocs
// segons fins que n'arriba una de nova (posterior a l'obertura del resum).
const POLL_MS = 4_000;
const POLL_LIMIT_MS = 60_000;

export function Summary({ xp, onMap, onContinue }: { xp: number; onMap: () => void; onContinue: () => void }) {
  // undefined = esperant l'avaluació; null = no ha arribat a temps (o no hi ha sessió).
  const [evaluation, setEvaluation] = useState<LatestEvaluation | null>();

  useEffect(() => {
    const openedAt = Date.now();
    let cancelled = false;
    let timer: ReturnType<typeof setTimeout>;
    const poll = async () => {
      const latest = await fetchLatestEvaluation().catch(() => null);
      if (cancelled) return;
      // Marge d'uns segons per si l'avaluació ha acabat abans d'obrir el resum.
      if (latest && new Date(latest.created_at).getTime() >= openedAt - 10_000) return setEvaluation(latest);
      if (Date.now() - openedAt >= POLL_LIMIT_MS) return setEvaluation(null);
      timer = setTimeout(poll, POLL_MS);
    };
    void poll();
    return () => { cancelled = true; clearTimeout(timer); };
  }, []);

  return (
    <main className="fade-up grid min-h-screen place-items-center p-5" style={{ background: '#FAFAF9' }}>
      <section className="w-full max-w-lg rounded-[40px] bg-white p-8 text-center shadow-xl">
        <div
          className="mx-auto grid h-20 w-20 place-items-center rounded-full text-4xl"
          style={{ background: '#FFE5B4' }}
        >
          🎉
        </div>
        <h1 className="mt-5 text-3xl font-black">Molt bé!</h1>
        <p className="mt-2 opacity-60">Has practicat valencià en una situació real.</p>

        {/* XP total */}
        <div
          className="mt-7 rounded-3xl p-5"
          style={{ background: 'linear-gradient(135deg, #FFF7ED, #FFEDD5)' }}
        >
          <b className="text-4xl font-black" style={{ color: '#F97316' }}>{xp} XP</b>
          <p className="mt-1 text-sm font-bold opacity-60">Experiència acumulada</p>
        </div>

        {/* Avaluació de la conversa */}
        <div className="mt-6 text-left" aria-live="polite">
          {evaluation === undefined && (
            <p className="animate-pulse rounded-2xl bg-cream p-4 text-sm font-bold opacity-70">
              Estem analitzant la teua conversa…
            </p>
          )}
          {evaluation === null && (
            <p className="rounded-2xl bg-cream p-4 text-sm opacity-70">
              L'anàlisi encara no està llesta. Quan acabe, la teua ruta d'aprenentatge s'actualitzarà amb el que has de reforçar.
            </p>
          )}
          {evaluation && (
            <>
              <h2 className="font-black text-lg">Com ha anat 📝</h2>
              <p className="mt-2 text-sm opacity-75">{evaluation.summary}</p>
              {evaluation.weaknesses.length > 0 && (
                <>
                  <h2 className="mt-5 font-black text-lg">A millorar 💪</h2>
                  <ul className="mt-2 flex flex-col gap-2">
                    {evaluation.weaknesses.slice(0, 4).map(w => (
                      <li key={w} className="rounded-2xl p-3 text-sm font-bold" style={{ background: '#E8F7F5', color: '#1a7a6f' }}>{w}</li>
                    ))}
                  </ul>
                </>
              )}
              {evaluation.priority_focus && (
                <p className="mt-4 text-sm"><b>Focus de la teua ruta:</b> {evaluation.priority_focus}</p>
              )}
            </>
          )}
        </div>

        <button
          onClick={onContinue}
          id="summary-continue-btn"
          className="btn-press mt-7 w-full rounded-2xl py-3 font-extrabold text-white transition hover:opacity-90"
          style={{ background: 'linear-gradient(135deg, #0D9488, #0F766E)' }}
        >
          Veure la meua ruta
        </button>
        <button
          onClick={onMap}
          id="summary-map-btn"
          className="btn-press mt-3 font-bold"
          style={{ color: '#0D9488' }}
        >
          Tornar al mapa
        </button>
      </section>
    </main>
  );
}
