import { supabase } from '../../lib/supabase';

/**
 * Progrés del Nivell 0. Àlbum de cromos: cada illa acabada desbloqueja el seu
 * cromo; lliçons: cada lliçó acabada guanya la seua medalla. Es guarden en
 * profiles.badges («cromo:<illa>», «llico:<lliçó>») perquè no es perden en canviar
 * de dispositiu; sense sessió (mode demostració), només en el navegador. La
 * decoració lliure de l'àlbum (on ha posat cada cromo) es guarda en el navegador.
 */

const CROMO = { prefix: 'cromo:', local: 'parlaval:kids:cromos' };
const LESSON = { prefix: 'llico:', local: 'parlaval:kids:llicons' };
type Kind = typeof CROMO;
const boardKey = (uid: string | undefined) => `parlaval:kids:album:${uid ?? 'demo'}`;

export type Sticker = { id: string; island: string; x: number; y: number; scale: number; rotate: number };

const readLocal = (kind: Kind): string[] => {
  try {
    return JSON.parse(localStorage.getItem(kind.local) ?? '[]');
  } catch {
    return [];
  }
};

async function loadMarks(kind: Kind, uid: string | undefined): Promise<string[]> {
  if (!supabase || !uid) return readLocal(kind);
  const { data, error } = await supabase.from('profiles').select('badges').eq('id', uid).single();
  if (error || !data) return readLocal(kind);
  return (data.badges as string[]).filter(b => b.startsWith(kind.prefix)).map(b => b.slice(kind.prefix.length));
}

/** Afig una marca (cromo o lliçó). Torna true si és nova. */
async function addMark(kind: Kind, uid: string | undefined, id: string): Promise<boolean> {
  const owned = await loadMarks(kind, uid);
  if (owned.includes(id)) return false;
  if (!supabase || !uid) {
    try {
      localStorage.setItem(kind.local, JSON.stringify([...owned, id]));
    } catch {
      // Sense storage: la marca només dura mentre la pàgina estiga oberta.
    }
    return true;
  }
  const { data } = await supabase.from('profiles').select('badges').eq('id', uid).single();
  const badges = [...new Set([...((data?.badges as string[]) ?? []), `${kind.prefix}${id}`])];
  await supabase.from('profiles').update({ badges }).eq('id', uid);
  return true;
}

export const loadCromos = (uid: string | undefined) => loadMarks(CROMO, uid);
export const unlockCromo = (uid: string | undefined, island: string) => addMark(CROMO, uid, island);
export const loadLessonsDone = (uid: string | undefined) => loadMarks(LESSON, uid);
export const markLessonDone = (uid: string | undefined, lesson: string) => addMark(LESSON, uid, lesson);

export function loadBoard(uid: string | undefined): Sticker[] {
  try {
    return JSON.parse(localStorage.getItem(boardKey(uid)) ?? '[]');
  } catch {
    return [];
  }
}

export function saveBoard(uid: string | undefined, stickers: Sticker[]) {
  try {
    localStorage.setItem(boardKey(uid), JSON.stringify(stickers));
  } catch {
    // Sense storage: la decoració no es guarda.
  }
}
