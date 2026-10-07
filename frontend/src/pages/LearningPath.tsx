import { useCallback, useEffect, useState } from 'react';
import { BookOpen, Check, Play, RefreshCw, RotateCcw, Sparkles } from 'lucide-react';
import { Logo } from '../components/ui';
import { LessonModal } from '../components/LessonModal';
import { categoryLabel } from '../components/ScenarioSelect';
import { fetchLearningPath, fetchResources, regenerateLearningPath } from '../lib/api';
import type { LearningPath as Path, LearningPathStep, LearningStage, Resource } from '../lib/types';

// Etapes del cicle de la ruta: aprendre → practicar → aplicar → comprovar.
const STAGES: Record<LearningStage, { label: string; color: string }> = {
  aprendre: { label: 'Aprén', color: '#7C6FD8' },
  practicar: { label: 'Practica', color: '#2CA99B' },
  aplicar: { label: 'Aplica', color: '#FF8A4C' },
  comprovar: { label: 'Comprova', color: '#203548' },
};

export function LearningPath({ onOpen, onBack }: { onOpen: (resource: Resource) => void; onBack: () => void }) {
  // undefined = carregant.
  const [path, setPath] = useState<Path | null>();
  const [error, setError] = useState<string>();
  const [regenerating, setRegenerating] = useState(false);
  const [catalog, setCatalog] = useState<Map<string, Resource>>(new Map());
  const [lesson, setLesson] = useState<Resource>();

  // El backend actualitza la ruta en segon pla en acabar cada activitat: es torna
  // a demanar en entrar a la pàgina i quan la pestanya recupera el focus.
  const load = useCallback(() => {
    fetchLearningPath()
      .then(data => { setPath(data); setError(undefined); })
      .catch(err => { setError(err instanceof Error ? err.message : 'No hem pogut carregar la ruta'); setPath(null); });
  }, []);

  useEffect(() => {
    load();
    fetchResources().then(rs => setCatalog(new Map(rs.map(r => [r.id, r])))).catch(() => {});
    window.addEventListener('focus', load);
    return () => window.removeEventListener('focus', load);
  }, [load]);

  const regenerate = async () => {
    setRegenerating(true);
    try {
      setPath(await regenerateLearningPath());
      setError(undefined);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'No hem pogut generar una ruta nova');
    } finally {
      setRegenerating(false);
    }
  };

  // Els passos usen la fila completa del catàleg (per a obrir-los i per a la lliçó).
  const resourceOf = (step: LearningPathStep) => catalog.get(step.resource.id);
  const open = (step: LearningPathStep) => {
    const resource = resourceOf(step);
    if (!resource) return;
    if (step.stage === 'aprendre' && resource.has_lesson && step.status === 'pending') setLesson(resource);
    else onOpen(resource);
  };

  const done = path?.steps.filter(s => s.status === 'done').length ?? 0;
  const total = path?.steps.length ?? 0;
  const next = path?.steps.find(s => s.status === 'pending');

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
        {path === undefined && (
          <section className="grid place-items-center gap-4 rounded-[2rem] bg-white p-10 text-center shadow-sm" aria-live="polite">
            <Sparkles size={36} className="animate-pulse text-teal" />
            <p className="text-xl font-black">Preparant la teua ruta…</p>
            <p className="opacity-60">Estem revisant les teues últimes activitats. Pot tardar uns segons.</p>
          </section>
        )}

        {path === null && (
          <section className="rounded-[2rem] bg-white p-8 text-center shadow-sm">
            <p className="text-xl font-black">{error}</p>
            <button onClick={load} className="btn-press mt-4 rounded-full bg-teal px-6 py-3 font-black text-white hover:bg-teal/90">
              Tornar-ho a provar
            </button>
          </section>
        )}

        {path && (
          <>
            {/* Portada: per què esta ruta i quant en portes */}
            <section className="relative overflow-hidden rounded-[2rem] bg-navy p-8 text-white shadow-xl">
              <div className="absolute -right-10 -top-10 h-48 w-48 rounded-full bg-mustard/20" aria-hidden="true" />
              <div className="relative">
                <p className="text-sm font-black uppercase tracking-widest text-mustard">La teua ruta personalitzada</p>
                <h1 className="mt-1 text-3xl font-black">{next ? 'Continuem aprenent!' : 'Ruta completada! 🎉'}</h1>
                <p className="mt-3 max-w-xl text-white/80">{path.rationale}</p>
                {path.focus.length > 0 && (
                  <div className="mt-4 flex flex-wrap gap-2">
                    {path.focus.map(f => (
                      <span key={f} className="rounded-full bg-white/10 px-3 py-1 text-sm font-bold">{f}</span>
                    ))}
                  </div>
                )}
                <div className="mt-6">
                  <div className="flex justify-between text-sm font-bold text-white/70">
                    <span>{done} de {total} passos</span>
                    <span>{total ? Math.round((done / total) * 100) : 0} %</span>
                  </div>
                  <div className="mt-2 h-3 overflow-hidden rounded-full bg-white/10">
                    <div className="xp-bar-fill h-full rounded-full transition-all" style={{ width: `${total ? (done / total) * 100 : 0}%` }} />
                  </div>
                </div>
              </div>
            </section>

            {error && <p className="rounded-xl bg-coral/10 px-4 py-3 text-sm font-bold text-coral">{error}</p>}

            {/* Camí de passos */}
            <ol className="relative flex flex-col gap-4">
              <span className="absolute left-7 top-6 bottom-6 w-1 rounded-full bg-ink/10" aria-hidden="true" />
              {path.steps.map(step => {
                const stage = STAGES[step.stage];
                const isNext = step.id === next?.id;
                const isDone = step.status === 'done';
                const resource = resourceOf(step);
                return (
                  <li key={step.id} className="relative flex gap-4">
                    <span
                      className={`relative z-10 grid h-14 w-14 shrink-0 place-items-center rounded-full border-4 border-cream text-xl font-black text-white shadow ${isNext ? 'ring-4 ring-mustard' : ''}`}
                      style={{ background: isDone ? '#2CA99B' : isNext ? stage.color : '#A8A29E' }}
                      aria-label={isDone ? 'Pas fet' : `Pas ${step.position}`}
                    >
                      {isDone ? <Check size={24} strokeWidth={3} /> : step.position}
                    </span>
                    <article className={`flex-1 rounded-[1.5rem] bg-white p-5 shadow-sm ${isNext ? 'border-2 border-mustard' : 'border border-stone-200'} ${isDone ? 'opacity-75' : ''}`}>
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="rounded-full px-3 py-0.5 text-xs font-black uppercase tracking-wide text-white" style={{ background: stage.color }}>
                          {stage.label}
                        </span>
                        <span className="text-xs font-bold opacity-60">{categoryLabel(step.resource.category)}</span>
                        {isNext && <span className="text-xs font-black text-orange">· Següent pas</span>}
                      </div>
                      <div className="mt-3 flex items-start gap-3">
                        <span className="grid h-12 w-12 shrink-0 place-items-center rounded-2xl text-2xl" style={{ background: step.resource.color ?? '#FFF1D6' }}>
                          {step.resource.icon ?? '📘'}
                        </span>
                        <div className="min-w-0 flex-1">
                          <h2 className="text-lg font-black leading-tight">{step.resource.section_name ?? step.resource.name}</h2>
                          <p className="mt-1 text-sm opacity-75">{step.reason}</p>
                        </div>
                      </div>
                      <div className="mt-4 flex flex-wrap justify-end gap-2">
                        {step.stage === 'aprendre' && resource?.has_lesson && isDone && (
                          <button onClick={() => setLesson(resource)} className="btn-press flex items-center gap-2 rounded-full bg-cream px-4 py-2 text-sm font-black text-teal hover:bg-teal/10">
                            <BookOpen size={16} /> Repassar la lliçó
                          </button>
                        )}
                        <button
                          onClick={() => open(step)}
                          disabled={!resource}
                          className={`btn-press flex items-center gap-2 rounded-full px-5 py-2 text-sm font-black disabled:opacity-50 ${isDone ? 'bg-cream text-teal hover:bg-teal/10' : 'bg-teal text-white hover:bg-teal/90'}`}
                        >
                          {isDone ? <><RotateCcw size={16} /> Tornar a fer</>
                            : step.stage === 'aprendre' && resource?.has_lesson ? <><BookOpen size={16} /> Aprendre i practicar</>
                            : <><Play size={16} /> Començar</>}
                        </button>
                      </div>
                    </article>
                  </li>
                );
              })}
            </ol>

            <div className="flex flex-col items-center gap-2 text-center">
              <button
                onClick={regenerate}
                disabled={regenerating}
                className="btn-press flex items-center gap-2 rounded-full bg-white px-6 py-3 font-black text-teal shadow hover:bg-teal/10 disabled:opacity-60"
              >
                <RefreshCw size={18} className={regenerating ? 'animate-spin' : ''} />
                {regenerating ? 'Generant una ruta nova…' : 'Generar una ruta nova'}
              </button>
              <p className="max-w-md text-sm opacity-60">
                La ruta s'actualitza sola quan acabes activitats. Pots generar-ne una de nova si vols canviar de tema.
              </p>
            </div>
          </>
        )}
      </div>

      {lesson && (
        <LessonModal
          resource={lesson}
          onClose={() => setLesson(undefined)}
          onPractice={lesson.playable ? () => { const r = lesson; setLesson(undefined); onOpen(r); } : undefined}
        />
      )}
    </main>
  );
}
