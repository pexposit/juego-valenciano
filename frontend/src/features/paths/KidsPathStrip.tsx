import { useEffect, useMemo, useState } from 'react';
import { loadMyPaths, type MyPath } from '../../lib/paths';
import type { Resource } from '../../lib/types';
import { resolveItem } from './catalog';
import { useAssignmentState } from './PathSteps';

/**
 * Nivell 0: en el mapa d'illes, els deures de la mestra (els que vencen abans, si n'hi ha
 * de vigents) o, si no, la ruta que ha assignat (o la que ha triat la família). Mostra un
 * estel per pas i, gran, el següent pas per a tocar-lo. No bloqueja res: la resta d'illes
 * es poden jugar igual.
 */
export function KidsPathStrip({ uid, resources, onRoute }: { uid: string | undefined; resources: Resource[]; onRoute: (route: string) => void }) {
  const [path, setPath] = useState<MyPath | null>(null);
  useEffect(() => {
    if (!uid) return;
    loadMyPaths(uid).then(paths => {
      const now = Date.now();
      const homework = paths.filter(p => p.due_at && Date.parse(p.due_at) > now).sort((a, b) => Date.parse(a.due_at!) - Date.parse(b.due_at!));
      setPath(homework[0] ?? paths.find(p => !p.due_at) ?? null);
    }).catch(console.error);
  }, [uid]);
  if (!uid || !path) return null;
  return <Strip uid={uid} path={path} resources={resources} onRoute={onRoute} />;
}

function Strip({ uid, path, resources, onRoute }: { uid: string; path: MyPath; resources: Resource[]; onRoute: (route: string) => void }) {
  const state = useAssignmentState(path.assignment_id, path.id, uid);
  const byId = useMemo(() => new Map(resources.map(r => [r.id, r])), [resources]);
  if (!state?.items.length) return null;
  const next = state.items.find(i => !state.done.get(i.id));
  const shown = next ? resolveItem(next, byId) : null;

  return (
    <section className="kids-scenarios" aria-label={`La ruta: ${path.title}`}>
      <span className="kids-scenarios-title">
        <span aria-hidden="true">{path.due_at ? '🎒' : '🧭'}</span> {path.due_at ? 'Els deures' : path.title}
        <span className="ml-2" aria-hidden="true">
          {state.items.map(i => <span key={i.id} style={{ opacity: state.done.get(i.id) ? 1 : 0.3 }}>★</span>)}
        </span>
      </span>
      <div className="kids-scenarios-list">
        {shown?.route ? (
          <button onClick={() => onRoute(shown.route!)} aria-label={`Següent: ${shown.title}`} title={shown.title} className="kid-scenario btn-press kid-jump">
            <span className="kid-scenario-face" style={{ background: '#FCDD09' }}>
              <span aria-hidden="true">{shown.emoji}</span>
            </span>
            <span className="kid-scenario-name">{shown.title}</span>
          </button>
        ) : !next && (
          <span className="kid-scenario kid-jump" aria-label={path.due_at ? 'Deures fets' : 'Ruta acabada'}>
            <span className="kid-scenario-face" style={{ background: '#2CA99B' }}><span aria-hidden="true">🏆</span></span>
            <span className="kid-scenario-name">{path.due_at ? 'Deures fets!' : 'Ruta acabada!'}</span>
          </span>
        )}
      </div>
    </section>
  );
}
