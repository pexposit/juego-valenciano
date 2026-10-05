import { supabase } from '../../lib/supabase';

/**
 * Àlbum de cromos del Nivell 0: cada illa acabada desbloqueja el seu cromo.
 * Es guarden en profiles.badges («cromo:<illa>») perquè no es perden en canviar
 * de dispositiu; sense sessió (mode demostració), només en el navegador. La
 * decoració lliure de l'àlbum (on ha posat cada cromo) es guarda en el navegador.
 */

const PREFIX = 'cromo:';
const LOCAL_KEY = 'parlaval:kids:cromos';
const boardKey = (uid: string | undefined) => `parlaval:kids:album:${uid ?? 'demo'}`;

export type Sticker = { id: string; island: string; x: number; y: number; scale: number; rotate: number };

const readLocal = (): string[] => {
  try {
    return JSON.parse(localStorage.getItem(LOCAL_KEY) ?? '[]');
  } catch {
    return [];
  }
};

export async function loadCromos(uid: string | undefined): Promise<string[]> {
  if (!supabase || !uid) return readLocal();
  const { data, error } = await supabase.from('profiles').select('badges').eq('id', uid).single();
  if (error || !data) return readLocal();
  return (data.badges as string[]).filter(b => b.startsWith(PREFIX)).map(b => b.slice(PREFIX.length));
}

/** Afig el cromo d'una illa. Torna true si és nou. */
export async function unlockCromo(uid: string | undefined, island: string): Promise<boolean> {
  const owned = await loadCromos(uid);
  if (owned.includes(island)) return false;
  if (!supabase || !uid) {
    try {
      localStorage.setItem(LOCAL_KEY, JSON.stringify([...owned, island]));
    } catch {
      // Sense storage: el cromo només dura mentre la pàgina estiga oberta.
    }
    return true;
  }
  const { data } = await supabase.from('profiles').select('badges').eq('id', uid).single();
  const badges = [...new Set([...((data?.badges as string[]) ?? []), `${PREFIX}${island}`])];
  await supabase.from('profiles').update({ badges }).eq('id', uid);
  return true;
}

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
