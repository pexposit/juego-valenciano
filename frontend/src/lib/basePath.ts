// Ruta base de la web (`/` en dev; p. ex. `/parlaval/` darrere d'un proxy, amb BASE_PATH en el build).
// Fora de Vite (scripts del backend amb tsx que importen el contingut infantil) no hi ha import.meta.env: arrel.
const BASE = import.meta.env?.BASE_URL ?? '/';

/** Antepon la ruta base a un recurs de `public/` (`/images/...`). Les URL completes, blob: i data: no es toquen. */
export function asset(path: string): string;
export function asset(path: string | null | undefined): string | undefined;
export function asset(path: string | null | undefined) {
  if (!path) return path ?? undefined;
  if (!path.startsWith('/') || path.startsWith('//') || BASE === '/' || path.startsWith(BASE)) return path;
  return BASE + path.slice(1);
}

/** Basename del router: la ruta base sense la barra final. */
export const ROUTER_BASENAME = BASE.replace(/\/$/, '') || '/';

/** El camí actual sense la ruta base, com el veu el router (`/perfil`, no `/parlaval/perfil`). */
export function appPath() {
  const path = window.location.pathname;
  if (ROUTER_BASENAME === '/') return path;
  return path.startsWith(ROUTER_BASENAME) ? path.slice(ROUTER_BASENAME.length) || '/' : path;
}
