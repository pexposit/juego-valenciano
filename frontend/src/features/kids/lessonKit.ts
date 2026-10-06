/**
 * Peces comunes de les lliçons del Nivell 0 (lessons.ts i preA1.ts): el registre de
 * frases (p, word, it), els tipus de pàgina i els constructors de pàgines.
 * Només dades i funcions pures: també el lligen els scripts de l'àudio i les traduccions.
 */
import {
  ACTIONS, ANIMALS, BODY, capital, COLORS, EXTRA_ANIMALS, FAMILY, FOOD, itemAudio, OPPOSITES, pick, shuffle, sortRound,
  type KidsItem, type Round,
} from './content';

export const LESSON_AUDIO: Record<string, string> = {};

const hash = (text: string) => {
  let h = 0x811c9dc5;
  for (let i = 0; i < text.length; i++) {
    h ^= text.charCodeAt(i);
    h = Math.imul(h, 0x01000193);
  }
  return (h >>> 0).toString(36);
};

/** Registra una frase i en torna la clau d'àudio. */
export const p = (text: string) => {
  const key = `ll-${hash(text)}`;
  LESSON_AUDIO[key] = text;
  return key;
};

// Frases que són vocabulari (el nom d'un pictograma: «El sol!»): no es tradueixen en els
// subtítols, perquè el que s'aprén és justament la paraula en valencià.
export const VOCABULARY = new Set<string>();
export const word = (text: string) => {
  const key = p(text);
  VOCABULARY.add(key);
  return key;
};

/** Un pictograma nou amb el seu nom en veu alta («El sol!») o una frase pròpia. */
export const it = (emoji: string, name: string, extra: Partial<KidsItem> & { say?: string } = {}): KidsItem => {
  const { say, ...rest } = extra;
  return { id: `${emoji}-${name}`, word: name, emoji, audio: say ? p(say) : word(`${capital(name)}!`), ...rest };
};

export type LessonPage =
  | { kind: 'intro'; say: string; emoji: string }
  // Explicació: la Taronjeta parla i es veuen els pictogrames del que diu.
  | { kind: 'explain'; say: string; items: KidsItem[] }
  // Descobrir: cal tocar tots els pictogrames (i escoltar-los) per a continuar.
  | { kind: 'discover'; say: string; items: KidsItem[] }
  // Parelles: el gos → els gossos, gran ↔ xicotet...
  | { kind: 'pairs'; say: string; pairs: [KidsItem, KidsItem][] }
  // Barreja de colors: es toquen els dos pots i ix el color nou.
  | { kind: 'mix'; say: string; a: KidsItem; b: KidsItem; result: KidsItem; reveal: string }
  // Conversa curta entre dos personatges, frase a frase.
  | { kind: 'dialog'; lines: { who: string; say: string }[] }
  // Pràctica: un joc de les illes (es torna a barrejar cada vegada).
  | { kind: 'game'; round: () => Round }
  | { kind: 'summary'; say: string; items: KidsItem[] }
  // Conte en vinyetes: cada vinyeta (una escena d'emojis) es narra per ordre.
  | { kind: 'story'; panels: { scene: string; say: string }[] }
  // Cançó o rodolí: les línies s'il·luminen mentre la Taronjeta les canta.
  | { kind: 'chant'; lines: { emoji: string; say: string }[] };

export type Lesson = {
  id: string;
  title: string;
  emoji: string;
  color: string;
  say: string; // el títol en veu alta
  summary: string; // una línia del que s'aprén (en la llista de lliçons)
  island?: string; // l'illa on es practica
  category?: 'preA1'; // la guia Pre-A1 (a l'estil de Cambridge Pre A1 Starters)
  pages: LessonPage[];
};

export const intro = (emoji: string, text: string): LessonPage => ({ kind: 'intro', emoji, say: p(text) });
export const explain = (text: string, items: KidsItem[]): LessonPage => ({ kind: 'explain', say: p(text), items });
export const discover = (text: string, items: KidsItem[]): LessonPage => ({ kind: 'discover', say: p(text), items });
export const pairs = (text: string, list: [KidsItem, KidsItem][]): LessonPage => ({ kind: 'pairs', say: p(text), pairs: list });
export const summary = (text: string, items: KidsItem[]): LessonPage => ({ kind: 'summary', say: p(text), items });
export const game = (round: () => Round): LessonPage => ({ kind: 'game', round });
export const dialog = (lines: [who: string, text: string][]): LessonPage =>
  ({ kind: 'dialog', lines: lines.map(([who, text]) => ({ who, say: p(text) })) });
export const story = (panels: [scene: string, text: string][]): LessonPage =>
  ({ kind: 'story', panels: panels.map(([scene, text]) => ({ scene, say: p(text) })) });
export const chant = (lines: [emoji: string, text: string][]): LessonPage =>
  ({ kind: 'chant', lines: lines.map(([emoji, text]) => ({ emoji, say: p(text) })) });
export const mix = (text: string, a: KidsItem, b: KidsItem, result: KidsItem, reveal: string): LessonPage =>
  ({ kind: 'mix', say: p(text), a, b, result, reveal: p(reveal) });

/* ── Activitats (les rondes de les illes i la pràctica de les lliçons) ─── */

/**
 * Una activitat torna una ronda nova (barrejada) cada vegada que es juga. Les frases
 * es registren amb p() en definir-la, no en jugar-la, perquè els scripts les vegen.
 */
export type Activity = () => Round;

export const play = (activities: Activity[]): Round[] => activities.map(activity => activity());
/** Una de les activitats, a l'atzar: cada partida de l'illa és un poc diferent. */
export const oneOf = (...activities: Activity[]): Activity => () => pick(activities, 1)[0]();

/** Es toca la resposta bona entre unes quantes. */
export const ask = (prompt: string, answer: KidsItem, wrong: KidsItem[], extra: { picture?: string; style?: 'letters' } = {}): Activity =>
  () => ({ kind: 'tap', prompt, target: answer, options: shuffle([answer, ...wrong]), ...extra });

/** Pregunta de comprovació: es toca la resposta bona entre 2 o 3. */
export const quiz = (...args: Parameters<typeof ask>): LessonPage => game(ask(...args));

const LISTEN = p('Escolta i toca!');
/** Escolta i toca: la Taronjeta diu un dels elements del grup i es busca entre `size`. */
export const listen = (pool: KidsItem[], size = 3, style?: 'letters'): Activity => () => {
  const [target, ...others] = pick(pool, size);
  return { kind: 'tap', prompt: [LISTEN, itemAudio(target)], target, options: shuffle([target, ...others]), style };
};

/** Quin va amb...? Un element bo (dels `right`) entre dos que no ho són. */
export const oneRight = (prompt: string, right: KidsItem[], wrong: KidsItem[], size = 3): Activity => () => {
  const target = pick(right, 1)[0];
  return { kind: 'tap', prompt, target, options: shuffle([target, ...pick(wrong, size - 1)]) };
};

/** Classificar: [element, calaix]; amb `perBin`, cada partida en tria uns quants de cada calaix. */
export const classify = (prompt: string, bins: KidsItem[], items: [KidsItem, KidsItem][], perBin?: number): Activity => () =>
  sortRound(prompt, bins, bins.flatMap(bin => {
    const mine = items.filter(([, b]) => b.id === bin.id).map(([item]) => ({ item, bin: bin.id }));
    return perBin ? pick(mine, perBin) : mine;
  }));

/** Un dibuix sense nom (per a les preguntes de sí o no). */
export const pic = (emoji: string): KidsItem => ({ id: `pic-${emoji}`, word: '', emoji, stack: [...emoji].length > 2 });

/** Mira i respon sí o no: [dibuix, frase, és veritat?]; amb `n`, cada partida en tria unes quantes. */
export const trueFalse = (list: [KidsItem, string, boolean][], n = list.length): Activity => {
  const statements = list.map(([item, text, yes]) => ({ item, key: p(text), yes }));
  return () => ({ kind: 'yesno', statements: pick(statements, n) });
};

const SPELL_PROMPT = p('Escolta i escriu la paraula, lletra a lletra!');
/** Lletreja: les lletres (o dígrafs, com LL) de la paraula, en ordre. */
export const spelling = (item: KidsItem, letters: string[]): Activity =>
  () => ({ kind: 'spell', prompt: [SPELL_PROMPT, itemAudio(item)], item, letters });

const DIFF_PROMPT = p('Mira bé les dues files. Què ha canviat? Toca el dibuix diferent de la fila de baix!');
/** Busca la diferència: la fila i els canvis [posició, dibuix nou]. */
export const difference = (row: KidsItem[], changes: [number, KidsItem][]): Activity => () => {
  const b = [...row];
  for (const [i, item] of changes) b[i] = item;
  return { kind: 'diff', prompt: DIFF_PROMPT, a: row, b };
};

/**
 * La Taronjeta diu: [dibuix, ho diu la Taronjeta?, ordre]. L'ordre per defecte és «toca el nas»;
 * per a les accions es passa el verb («salta»).
 */
export const simonSays = (options: KidsItem[], commands: [KidsItem, boolean, string?][]): Activity => {
  const list = commands.map(([item, says, order]) => {
    const text = order ?? `toca ${item.word}`;
    return { item: item.id, simon: says, key: p(says ? `La Taronjeta diu: ${text}!` : `${capital(text)}!`) };
  });
  return () => ({ kind: 'simon', options: shuffle(options), commands: list });
};

export const byId = <T extends KidsItem>(list: T[], id: string) => {
  const found = list.find(x => x.id === id);
  if (!found) throw new Error(`Falta l'element ${id}`);
  return found;
};
export const animal = (id: string) => byId([...ANIMALS, ...EXTRA_ANIMALS], id);
export const food = (id: string) => byId(FOOD, id);
export const body = (id: string) => byId(BODY, id);
export const family = (id: string) => byId(FAMILY, id);
export const color = (id: string) => byId(COLORS, id);
export const action = (id: string) => byId(ACTIONS, `acc-${id}`);
export const opposite = (id: string) => byId(OPPOSITES.flat(), `op-${id}`);

// Prefixos de les frases de content.ts que són vocabulari: noms, números, lletres i sons d'animals.
const VOCABULARY_PREFIXES = ['w-', 'n-', 'fa-', 'abc-de-', 'lletra-'];

/**
 * Les frases que es tradueixen en els subtítols: consignes, explicacions i diàlegs (no el
 * vocabulari). Les llig backend/scripts/generate-kids-translations.ts.
 */
export function translatableKeys(kidsAudio: Record<string, string>): string[] {
  return [...Object.keys(kidsAudio), ...Object.keys(LESSON_AUDIO)]
    .filter(key => !VOCABULARY.has(key) && !VOCABULARY_PREFIXES.some(prefix => key.startsWith(prefix)));
}
