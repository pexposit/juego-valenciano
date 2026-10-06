import { useEffect, useState } from 'react';
import { Check, Play, RotateCcw } from 'lucide-react';
import { loadAssignmentProgress, loadPathItems, loadPathProgress, type PathItem } from '../../lib/paths';
import type { Resource } from '../../lib/types';
import { resolveItem } from './catalog';

// done: si l'ha fet; at (només deures): quan, per a saber si va ser dins del termini.
export type PathState = { items: PathItem[]; done: Map<string, boolean>; at?: Map<string, string | null> };

/** Els passos d'una ruta i quins ha fet l'aprenent (alguna vegada). */
export async function loadPathState(pathId: string, student: string): Promise<PathState> {
  const [items, done] = await Promise.all([loadPathItems(pathId), loadPathProgress(pathId, student)]);
  return { items, done };
}

/** Els passos d'una assignació: per a uns deures, només compta el que s'ha fet des que es van posar. */
export async function loadAssignmentState(assignmentId: string, pathId: string, student: string): Promise<PathState> {
  const [items, progress] = await Promise.all([loadPathItems(pathId), loadAssignmentProgress(assignmentId, student)]);
  return {
    items,
    done: new Map([...progress].map(([id, p]) => [id, p.done])),
    at: new Map([...progress].map(([id, p]) => [id, p.at])),
  };
}

export const countDone = (state: PathState) => state.items.filter(i => state.done.get(i.id)).length;

function useLoaded(load: () => Promise<PathState>, deps: unknown[]) {
  const [state, setState] = useState<PathState | null>();
  useEffect(() => {
    let cancelled = false;
    const reload = () => load()
      .then(s => { if (!cancelled) setState(s); })
      .catch(e => {
        console.error(e);
        if (!cancelled) setState(null);
      });
    void reload();
    // En tornar d'una activitat (altra pestanya o pàgina), el progrés pot haver canviat.
    window.addEventListener('focus', reload);
    return () => {
      cancelled = true;
      window.removeEventListener('focus', reload);
    };
  }, deps); // eslint-disable-line react-hooks/exhaustive-deps
  return state;
}

export const usePathState = (pathId: string, student: string) => useLoaded(() => loadPathState(pathId, student), [pathId, student]);
export const useAssignmentState = (assignmentId: string, pathId: string, student: string) =>
  useLoaded(() => loadAssignmentState(assignmentId, pathId, student), [assignmentId, pathId, student]);

/**
 * La llista de passos amb el següent destacat. Amb `onOpen`, cada pas es pot obrir (aprenent);
 * sense, només es llig (seguiment de la docent). No hi ha bloqueig: qualsevol pas es pot fer.
 */
export function PathSteps({ state, resources, onOpen }: {
  state: PathState;
  resources: Map<string, Resource>;
  onOpen?: (route: string) => void;
}) {
  const next = state.items.find(i => !state.done.get(i.id));
  return (
    <ol className="flex flex-col gap-2">
      {state.items.map((item, i) => {
        const r = resolveItem(item, resources);
        const done = !!state.done.get(item.id);
        const isNext = item.id === next?.id;
        return (
          <li
            key={item.id}
            className={`flex items-center gap-3 rounded-2xl bg-white p-3 shadow-sm ${isNext ? 'border-2 border-mustard' : 'border border-stone-200'} ${done ? 'opacity-75' : ''}`}
          >
            <span
              className="grid h-10 w-10 shrink-0 place-items-center rounded-full font-black text-white"
              style={{ background: done ? '#2CA99B' : isNext ? '#0F47AF' : '#A8A29E' }}
              aria-label={done ? 'Fet' : `Pas ${i + 1}`}
            >
              {done ? <Check size={20} strokeWidth={3} /> : i + 1}
            </span>
            <span className="text-2xl" aria-hidden="true">{r.emoji}</span>
            <span className="min-w-0 flex-1">
              <span className="block font-extrabold leading-tight">{r.title}</span>
              <span className="block text-sm opacity-60">
                {r.kindLabel}{isNext && <b className="text-orange"> · Següent pas</b>}
              </span>
              {item.note && <span className="mt-0.5 block text-sm italic opacity-80">{item.note}</span>}
            </span>
            {onOpen && r.route && (
              <button
                onClick={() => onOpen(r.route!)}
                aria-label={done ? `Torna a fer ${r.title}` : `Comença ${r.title}`}
                className={`btn-press flex shrink-0 items-center gap-1 rounded-full px-4 py-2 text-sm font-black ${done ? 'bg-cream text-teal' : 'bg-teal text-white hover:bg-teal/90'}`}
              >
                {done ? <RotateCcw size={16} /> : <Play size={16} />}
                <span className="hidden sm:inline">{done ? 'Repeteix' : 'Comença'}</span>
              </button>
            )}
          </li>
        );
      })}
    </ol>
  );
}

export function ProgressBar({ done, total, onDark = false }: { done: number; total: number; onDark?: boolean }) {
  const pct = total ? Math.round((done / total) * 100) : 0;
  return (
    <div>
      <div className="flex justify-between text-sm font-bold opacity-70">
        <span>{done} de {total} passos</span>
        <span>{pct} %</span>
      </div>
      <div className={`mt-1 h-2.5 overflow-hidden rounded-full ${onDark ? 'bg-white/15' : 'bg-ink/10'}`}>
        <div className={`h-full rounded-full transition-all ${onDark ? 'bg-mustard' : 'bg-teal'}`} style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}
