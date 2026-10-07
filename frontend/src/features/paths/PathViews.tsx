import { BookOpen, Check, ChevronRight, Play, RotateCcw } from 'lucide-react';
import { levelLabel } from '@parlaval/shared';
import { categoryLabel } from '../../components/ScenarioSelect';
import type { Resource, StudyPath } from '../../lib/types';

// Peces de les rutes que comparteixen «Rutes» (les recomanades) i «Classe» (les de la docent).

export const progressOf = (path: StudyPath) => {
  const done = path.steps.filter(s => s.done).length;
  return { done, total: path.steps.length, pct: path.steps.length ? Math.round((done / path.steps.length) * 100) : 0 };
};

export function ProgressBar({ pct, onDark = false }: { pct: number; onDark?: boolean }) {
  return (
    <div className={`h-3 overflow-hidden rounded-full ${onDark ? 'bg-white/10' : 'bg-ink/10'}`}>
      <div className="xp-bar-fill h-full rounded-full transition-all" style={{ width: `${pct}%` }} />
    </div>
  );
}

/** Una activitat amb lliçó que encara no s'ha fet comença per la lliçó. */
export const startActivity = (resource: Resource, done: boolean, onOpen: (r: Resource) => void, onLesson: (r: Resource) => void) =>
  resource.has_lesson && !done ? onLesson(resource) : onOpen(resource);

export function PathCard({ path, onSelect }: { path: StudyPath; onSelect: () => void }) {
  const { done, total, pct } = progressOf(path);
  return (
    <li>
      <button
        onClick={onSelect}
        className="btn-press flex w-full items-center gap-4 rounded-[1.5rem] border border-stone-200 bg-white p-5 text-left shadow-sm hover:border-teal"
      >
        <div className="min-w-0 flex-1">
          <div className="flex flex-wrap items-center gap-2">
            <span className="rounded-full bg-cream px-2.5 py-0.5 text-xs font-black text-teal">{levelLabel(path.level)}</span>
            {done === total && total > 0 && <span className="text-xs font-black text-teal">· Completada</span>}
          </div>
          <h2 className="mt-2 text-xl font-black leading-tight">{path.title}</h2>
          {path.description && <p className="mt-1 text-sm opacity-70">{path.description}</p>}
          <div className="mt-3">
            <div className="mb-1 flex justify-between text-xs font-bold opacity-60">
              <span>{done} de {total} activitats</span>
              <span>{pct} %</span>
            </div>
            <ProgressBar pct={pct} />
          </div>
        </div>
        <ChevronRight className="shrink-0 opacity-40" />
      </button>
    </li>
  );
}

/** Una ruta oberta: la portada amb el progrés i els passos, el següent marcat. */
export function PathDetail({ path, eyebrow, catalog, onOpen, onLesson }: {
  path: StudyPath;
  eyebrow: string;
  catalog: Map<string, Resource>;
  onOpen: (resource: Resource) => void;
  onLesson: (resource: Resource) => void;
}) {
  const { done, total, pct } = progressOf(path);
  const next = path.steps.find(s => !s.done);
  return (
    <>
      <section className="relative overflow-hidden rounded-[2rem] bg-navy p-8 text-white shadow-xl">
        <div className="absolute -right-10 -top-10 h-48 w-48 rounded-full bg-mustard/20" aria-hidden="true" />
        <div className="relative">
          <p className="text-sm font-black uppercase tracking-widest text-mustard">{eyebrow}</p>
          <h1 className="mt-1 text-3xl font-black">{path.title}</h1>
          {path.description && <p className="mt-3 max-w-xl text-white/80">{path.description}</p>}
          <div className="mt-6">
            <div className="flex justify-between text-sm font-bold text-white/70">
              <span>{done} de {total} activitats</span>
              <span>{pct} %</span>
            </div>
            <div className="mt-2"><ProgressBar pct={pct} onDark /></div>
          </div>
        </div>
      </section>

      <ol className="relative flex flex-col gap-4">
        <span className="absolute left-7 top-6 bottom-6 w-1 rounded-full bg-ink/10" aria-hidden="true" />
        {path.steps.map((step, i) => {
          const resource = catalog.get(step.resource_id);
          const isNext = step === next;
          return (
            <li key={step.resource_id} className="relative flex gap-4">
              <span
                className={`relative z-10 grid h-14 w-14 shrink-0 place-items-center rounded-full border-4 border-cream text-xl font-black text-white shadow ${isNext ? 'ring-4 ring-mustard' : ''}`}
                style={{ background: step.done ? '#2CA99B' : isNext ? '#FF8A4C' : '#A8A29E' }}
                aria-label={step.done ? 'Activitat feta' : `Activitat ${i + 1}`}
              >
                {step.done ? <Check size={24} strokeWidth={3} /> : i + 1}
              </span>
              <article className={`flex-1 rounded-[1.5rem] bg-white p-5 shadow-sm ${isNext ? 'border-2 border-mustard' : 'border border-stone-200'} ${step.done ? 'opacity-75' : ''}`}>
                <div className="flex flex-wrap items-center gap-2">
                  <span className="text-xs font-bold opacity-60">{resource ? categoryLabel(resource.category) : 'Activitat'}</span>
                  {isNext && <span className="text-xs font-black text-orange">· Següent</span>}
                </div>
                <div className="mt-2 flex items-start gap-3">
                  <span className="grid h-12 w-12 shrink-0 place-items-center rounded-2xl text-2xl" style={{ background: resource?.color ?? '#FFF1D6' }}>
                    {resource?.icon ?? '📘'}
                  </span>
                  <div className="min-w-0 flex-1">
                    <h2 className="text-lg font-black leading-tight">{resource?.section_name ?? resource?.name ?? 'Carregant…'}</h2>
                    {resource?.section_name && <p className="mt-1 text-sm opacity-75">{resource.name}</p>}
                  </div>
                </div>
                <div className="mt-4 flex flex-wrap justify-end gap-2">
                  {resource?.has_lesson && step.done && (
                    <button onClick={() => onLesson(resource)} className="btn-press flex items-center gap-2 rounded-full bg-cream px-4 py-2 text-sm font-black text-teal hover:bg-teal/10">
                      <BookOpen size={16} /> Repassar la lliçó
                    </button>
                  )}
                  <button
                    onClick={() => resource && startActivity(resource, step.done, onOpen, onLesson)}
                    disabled={!resource}
                    className={`btn-press flex items-center gap-2 rounded-full px-5 py-2 text-sm font-black disabled:opacity-50 ${step.done ? 'bg-cream text-teal hover:bg-teal/10' : 'bg-teal text-white hover:bg-teal/90'}`}
                  >
                    {step.done ? <><RotateCcw size={16} /> Tornar a fer</>
                      : resource?.has_lesson ? <><BookOpen size={16} /> Aprendre i practicar</>
                      : <><Play size={16} /> Començar</>}
                  </button>
                </div>
              </article>
            </li>
          );
        })}
      </ol>
    </>
  );
}
