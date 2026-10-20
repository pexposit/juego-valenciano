import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowRight } from 'lucide-react';
import { activityRoute } from '../../data/content';
import { nextInRoute, type NextInRoute as Next } from './routeContext';

/**
 * «Següent activitat de la ruta», per a la pantalla d'una activitat ja corregida. Només es veu si l'activitat
 * s'ha obert des d'una ruta i no n'és l'última.
 */
export function NextInRouteButton({ resourceId }: { resourceId: string }) {
  const navigate = useNavigate();
  const [next, setNext] = useState<Next | null>(null);

  useEffect(() => {
    let cancelled = false;
    nextInRoute(resourceId)
      .then(n => { if (!cancelled) setNext(n); })
      .catch(() => { if (!cancelled) setNext(null); });
    return () => { cancelled = true; };
  }, [resourceId]);

  const route = next && activityRoute(next.resource);
  if (!next || !route) return null;
  return (
    <button
      onClick={() => {
        navigate(route);
        window.scrollTo({ top: 0 }); // la nova activitat comença dalt de tot
      }}
      id="route-next-btn"
      title={`Activitat ${next.position} de ${next.total} de la ruta`}
      className="btn-press flex items-center gap-2 rounded-full bg-green-600 px-6 py-3 font-black text-white shadow hover:bg-green-600/90"
    >
      Següent activitat de la ruta
      <span className="hidden max-w-[14rem] truncate font-bold opacity-80 sm:inline">· {next.resource.section_name ?? next.resource.name}</span>
      <ArrowRight size={18} />
    </button>
  );
}
