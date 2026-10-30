import { useSyncExternalStore } from 'react';

/** `true` mentre la consulta de mitjans (CSS) es complix; es torna a avaluar quan canvia (girar la pantalla, redimensionar). */
export function useMediaQuery(query: string): boolean {
  return useSyncExternalStore(
    notify => {
      const list = window.matchMedia(query);
      list.addEventListener('change', notify);
      return () => list.removeEventListener('change', notify);
    },
    () => window.matchMedia(query).matches,
    () => false,
  );
}
