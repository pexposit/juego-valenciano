/**
 * Cache en memòria per a respostes reutilitzables (regles de la GNV per secció, DNV i conjugacions del MCP): la mateixa
 * clau torna la mateixa resposta sense tornar a demanar-la. Com la de `openaiGuard`, només viu en la memòria del procés.
 * Es guarda la promesa: consultes idèntiques simultànies comparteixen una sola crida. Una crida que falla no es guarda.
 */

/**
 * Forma canònica d'una consulta, perquè la mateixa pregunta escrita d'una altra manera tinga la mateixa clau: minúscules,
 * cometes i puntuació fora, apòstrofs tipogràfics com a ' i espais simples. Els accents i la ç es mantenen: «què» i
 * «que» o «ç» i «c» són consultes diferents.
 */
export function normalizeQuery(text: string): string {
  return text
    .normalize('NFC')
    .replace(/[’‘`´]/g, "'")
    .replace(/[«»"“”„]/g, ' ')
    .replace(/[¿¡?!.,;:()[\]{}]/g, ' ')
    .toLocaleLowerCase('ca')
    .replace(/\s+/g, ' ')
    .trim();
}

export interface LookupCache<T> {
  get(key: string, load: () => Promise<T>): Promise<T>;
  /** El valor guardat si n'hi ha (sense carregar-lo). */
  peek(key: string): Promise<T> | undefined;
  set(key: string, value: T): void;
  clear(): void;
  readonly size: number;
}

/**
 * `keep`: si una resposta (correcta) es pot guardar; p. ex. un resultat d'error del MCP no.
 * Quan s'arriba a `maxEntries`, s'expulsa la menys usada.
 */
export function createLookupCache<T>({ ttlMs, maxEntries, keep = () => true }: {
  ttlMs: number;
  maxEntries: number;
  keep?: (value: T) => boolean;
}): LookupCache<T> {
  const entries = new Map<string, { expiresAt: number; value: Promise<T> }>(); // l'ordre d'inserció és l'ordre d'ús

  const fresh = (key: string) => {
    const hit = entries.get(key);
    entries.delete(key);
    if (!hit || hit.expiresAt <= Date.now()) return undefined;
    entries.set(key, hit); // el marca com a recent
    return hit.value;
  };
  const store = (key: string, value: Promise<T>) => {
    const entry = { expiresAt: Date.now() + ttlMs, value };
    entries.delete(key);
    entries.set(key, entry);
    for (const oldKey of entries.keys()) {
      if (entries.size <= maxEntries) break;
      entries.delete(oldKey);
    }
    return entry;
  };

  return {
    get(key, load) {
      const hit = fresh(key);
      if (hit) return hit;
      const value = load();
      const entry = store(key, value);
      const drop = () => {
        if (entries.get(key) === entry) entries.delete(key);
      };
      value.then(result => { if (!keep(result)) drop(); }, drop);
      return value;
    },
    peek: fresh,
    set(key, value) {
      store(key, Promise.resolve(value));
    },
    clear: () => entries.clear(),
    get size() {
      return entries.size;
    },
  };
}
