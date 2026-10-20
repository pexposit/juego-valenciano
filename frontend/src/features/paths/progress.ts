import { userKey } from '../../lib/progressStorage';
import type { Resource } from '../../lib/types';

/**
 * Què hi ha guardat en este navegador d'una pràctica o d'un examen (Practice.tsx i Exam.tsx el guarden amb
 * userKey): les respostes i si s'han corregit. Les rutes ho fan servir per a dir si l'activitat està sense
 * començar, començada o corregida, i per a deixar tornar-hi a vore les respostes sense reiniciar-la.
 *   - pràctica: `practice:<id>:<nivell>`, una entrada per nivell, amb `answers`, `checked` i `retry` (les
 *     preguntes que han quedat obertes després de corregir);
 *   - examen: `exam:<id>`, amb `answers`, `form` i `checked` (les àrees corregides).
 * Els escenaris (xats) no guarden res ací.
 */
export type LocalState = 'none' | 'started' | 'corrected';

const hasValues = (record: unknown) =>
  Boolean(record) && typeof record === 'object' && Object.values(record as Record<string, unknown>).some(v =>
    typeof v === 'string' ? v.trim() !== '' : v !== null && typeof v === 'object' && Object.keys(v).length > 0);

const read = (key: string): Record<string, unknown> | null => {
  try {
    const raw = localStorage.getItem(key);
    const parsed = raw ? JSON.parse(raw) : null;
    return parsed && typeof parsed === 'object' ? parsed : null;
  } catch {
    return null;
  }
};

// Les claus de localStorage d'una activitat de l'usuari actual.
function keysOf(resource: Pick<Resource, 'id' | 'category'>): string[] {
  if (resource.category === 'examen') return [userKey(`exam:${resource.id}`)];
  const prefix = userKey(`practice:${resource.id}:`);
  const keys: string[] = [];
  try {
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key?.startsWith(prefix)) keys.push(key);
    }
  } catch {
    // Sense localStorage no es pot saber.
  }
  return keys;
}

/** L'estat de l'activitat en este navegador: sense res, començada (respostes sense corregir) o corregida. */
export function localProgress(resource: Pick<Resource, 'id' | 'category'> | undefined): LocalState {
  if (!resource) return 'none';
  let state: LocalState = 'none';
  for (const key of keysOf(resource)) {
    const progress = read(key);
    if (!progress) continue;
    const started = hasValues(progress.answers) || hasValues(progress.writings) || hasValues(progress.forms) || hasValues(progress.form);
    if (resource.category === 'examen') {
      const corrected = Array.isArray(progress.checked) && progress.checked.length > 0;
      if (corrected) return 'corrected';
      if (started) state = 'started';
      continue;
    }
    const openQuestions = Object.values((progress.retry ?? {}) as Record<string, boolean>).some(Boolean);
    if (progress.checked === true && !openQuestions) return 'corrected';
    if (started || progress.checked === true) state = 'started';
  }
  return state;
}

const restartKey = (resource: Pick<Resource, 'id'>) => userKey(`restart:${resource.id}`);

/** Quan es va reiniciar l'activitat per l'última vegada en este navegador (0 si mai). */
export function restartedAtOf(resource: Pick<Resource, 'id'>): number {
  try {
    return Date.parse(localStorage.getItem(restartKey(resource)) ?? '') || 0;
  } catch {
    return 0;
  }
}

/**
 * El servidor ha confirmat el reinici: es guarda la seua hora (la dels errors també és del servidor), per si el rellotge
 * del navegador no coincidix. Només s'avança, mai es retrocedix.
 */
export function markRestartedAt(resource: Pick<Resource, 'id'>, serverTime: string) {
  try {
    const at = Date.parse(serverTime);
    if (at > restartedAtOf(resource)) localStorage.setItem(restartKey(resource), new Date(at).toISOString());
  } catch {
    // Sense localStorage es queda amb l'hora del navegador.
  }
}

/**
 * Esborra el que hi ha guardat d'una activitat en este navegador: «Tornar a fer» la comença de zero. També en deixa
 * apuntat el moment: els errors pendents d'abans (que continuen en el servidor fins que es corregisquen) no han de
 * tornar a eixir marcats en l'activitat reiniciada.
 */
export function resetLocalProgress(resource: Pick<Resource, 'id' | 'category'>) {
  try {
    localStorage.setItem(restartKey(resource), new Date().toISOString());
    for (const key of keysOf(resource)) localStorage.removeItem(key);
  } catch {
    // Sense localStorage no hi ha res a esborrar.
  }
}
