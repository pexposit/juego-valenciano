// El progrés d'exàmens i pràctiques es guarda en localStorage, que és compartit per tots els comptes
// d'un mateix navegador: la clau porta l'id de l'usuari perquè un compte no veja les respostes d'un altre.
let currentUserId: string | undefined;

/** L'App l'actualitza amb l'usuari que ha iniciat sessió (undefined si no n'hi ha cap). */
export const setProgressUser = (id: string | undefined) => { currentUserId = id; };

/** Clau de localStorage pròpia de l'usuari actual. */
export const userKey = (key: string) => `parlaval:u:${currentUserId ?? 'anon'}:${key}`;

// Les claus anteriors no portaven l'usuari i no es poden atribuir a ningú: s'esborren.
const LEGACY_PREFIXES = ['parlaval:exam:', 'parlaval:practice:', 'parlaval:practice-fixed:'];
export function clearLegacyProgress() {
  try {
    for (const key of Object.keys(localStorage)) {
      if (LEGACY_PREFIXES.some(p => key.startsWith(p))) localStorage.removeItem(key);
    }
  } catch {
    // Sense storage: no hi ha res a esborrar.
  }
}
