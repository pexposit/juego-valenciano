import { fetchResources } from '../../lib/api';
import type { Resource } from '../../lib/types';
import { appPath } from '../../lib/basePath';

/**
 * La ruta des de la qual s'ha obert l'activitat actual (la ruta personalitzada, una de les recomanades o
 * una de la classe): l'ordre dels seus recursos i l'adreça del detall de la ruta d'on s'ha obert (cada ruta
 * té la seua). Les pantalles d'activitat el fan servir per a dos coses:
 *   - «Següent activitat de la ruta», en acabar de corregir;
 *   - «Tornar»: du al detall de la ruta (amb els seus exercicis), no a l'activitat anterior.
 * Es guarda en sessionStorage i s'oblida quan s'obri una activitat per un altre camí (p. ex. la llista d'Activitats).
 */
const KEY = 'parlaval:route-context';

type RouteContext = {
  ids: string[];
  backTo: string; // el detall de la ruta d'on s'ha obert (p. ex. /ruta/<id>)
};

function read(): RouteContext | null {
  try {
    const parsed = JSON.parse(sessionStorage.getItem(KEY) ?? 'null') as Partial<RouteContext> | null;
    if (!parsed || !Array.isArray(parsed.ids) || typeof parsed.backTo !== 'string') return null;
    return { ids: parsed.ids.filter((id): id is string => typeof id === 'string'), backTo: parsed.backTo };
  } catch {
    return null;
  }
}

function write(context: RouteContext | null) {
  try {
    if (context) sessionStorage.setItem(KEY, JSON.stringify(context));
    else sessionStorage.removeItem(KEY);
  } catch {
    // Sense emmagatzematge no hi ha «següent» ni tornada a la ruta: no passa res.
  }
}

/** S'obri una activitat des d'una ruta: es recorda l'ordre i l'adreça actual (el detall de la ruta). */
export function setRouteContext(resourceIds: string[]) {
  write({ ids: resourceIds, backTo: appPath() });
}

export function clearRouteContext() {
  write(null);
}

/** El detall de la ruta on tornar des de l'activitat donada, o null si no s'ha obert des d'una ruta. */
export function routeBackTo(resourceId: string): string | null {
  const context = read();
  return context && context.ids.includes(resourceId) ? context.backTo : null;
}

export type NextInRoute = { resource: Resource; position: number; total: number };

/** L'activitat que ve després de la donada en la ruta oberta, o null (no hi ha ruta, no n'és de la ruta o és l'última). */
export async function nextInRoute(resourceId: string): Promise<NextInRoute | null> {
  const ids = read()?.ids ?? [];
  const index = ids.indexOf(resourceId);
  if (index === -1 || index === ids.length - 1) return null;
  const catalog = await fetchResources();
  // La següent que existisca en el catàleg (si alguna ha desaparegut, es salta).
  for (let i = index + 1; i < ids.length; i++) {
    const resource = catalog.find(r => r.id === ids[i]);
    if (resource) return { resource, position: i + 1, total: ids.length };
  }
  return null;
}
