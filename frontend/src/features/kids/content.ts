/**
 * Contingut del Nivell 0 per a xiquets (món d'illes)
 * ===================================================
 * Principis (document de disseny pedagògic del Nivell 0):
 * - Zero barrera lectora: tot es diu amb àudio (i es mostra amb il·lustracions).
 * - Sempre amb l'article: el gos, la poma, l'ocell.
 * - Error suau: un «boing» i es torna a provar, sense perdre res.
 * - Micro-sessions de 3 a 5 minuts amb 4-6 elements nous.
 *
 * Este fitxer és només dades (sense dependències del navegador): també el llig
 * backend/scripts/generate-kids-audio.ts per a generar els àudios amb el TTS.
 * Cada frase de KIDS_AUDIO es servix en /audio/kids/<clau>.wav.
 */

export type KidsItem = {
  id: string;
  word: string; // amb l'article: «el gos»
  emoji: string;
  plural?: boolean; // «els ulls»: On són...?
  sound?: string; // onomatopeia o frase pròpia: «El gos fa bub, bub!»
  noise?: string; // l'onomatopeia sola, per a «Qui fa bub, bub?»
  color?: string; // per als colors i les bambolles
  audio?: string; // clau de l'àudio del seu nom, si no és `w-<id>`
  count?: number; // es dibuixa l'emoji repetit (comptar, un i molts)
  scale?: number; // mida de l'emoji (gran i xicotet)
  glyph?: string; // text gran en lloc d'emoji (lletres, dies)
  ink?: string; // color del glyph
  pos?: Pos; // escena del gat i la caixa (dins, damunt...)
  stack?: boolean; // emoji compost de diversos dibuixos (calaixos de classificar)
};

export type Pos = 'dins' | 'fora' | 'damunt' | 'davall' | 'davant' | 'darrere' | 'costat';

/** Clau de l'àudio que diu el nom d'un element. */
export const itemAudio = (item: KidsItem) => item.audio ?? `w-${item.id}`;

/* ── Vocabulari per blocs ─────────────────────────────────────────────── */

const animal = (id: string, word: string, emoji: string, noise: string): KidsItem =>
  ({ id, word, emoji, noise, sound: `${word.charAt(0).toUpperCase()}${word.slice(1)} fa ${noise}!` });

export const ANIMALS: KidsItem[] = [
  animal('gos', 'el gos', '🐕', 'bub, bub'),
  animal('gat', 'el gat', '🐈', 'mèu, mèu'),
  animal('ocell', "l'ocell", '🐦', 'piu, piu'),
  animal('peix', 'el peix', '🐟', 'glub, glub'),
  animal('vaca', 'la vaca', '🐄', 'muuu'),
  animal('cavall', 'el cavall', '🐎', 'hi, hi, hi'),
  animal('porc', 'el porc', '🐖', 'oinc, oinc'),
  animal('ovella', "l'ovella", '🐑', 'beee'),
  animal('gallina', 'la gallina', '🐔', 'co, co, co'),
  animal('anec', "l'ànec", '🦆', 'cuac, cuac'),
  animal('granota', 'la granota', '🐸', 'rac, rac'),
  animal('lleo', 'el lleó', '🦁', 'grrr'),
  animal('elefant', "l'elefant", '🐘', 'pruuu'),
  animal('mona', 'la mona', '🐒', 'uh, uh, ah, ah'),
  animal('ratoli', 'el ratolí', '🐭', 'ii, ii'),
  animal('conill', 'el conill', '🐇', 'nyam, nyam'),
];

export const COLORS: KidsItem[] = [
  { id: 'roig', word: 'el roig', emoji: '🔴', color: '#EF4444' },
  { id: 'blau', word: 'el blau', emoji: '🔵', color: '#3B82F6' },
  { id: 'groc', word: 'el groc', emoji: '🟡', color: '#FACC15' },
  { id: 'verd', word: 'el verd', emoji: '🟢', color: '#22C55E' },
  { id: 'taronja-color', word: 'el taronja', emoji: '🟠', color: '#F97316' },
  { id: 'negre', word: 'el negre', emoji: '⚫', color: '#1F2937' },
  { id: 'blanc', word: 'el blanc', emoji: '⚪', color: '#FFFFFF' },
  { id: 'rosa', word: 'el rosa', emoji: '🩷', color: '#F472B6' },
  { id: 'morat', word: 'el morat', emoji: '🟣', color: '#A855F7' },
  { id: 'marro', word: 'el marró', emoji: '🟤', color: '#92400E' },
  { id: 'gris', word: 'el gris', emoji: '🩶', color: '#9CA3AF' },
];

export const NUMBERS = ['u', 'dos', 'tres', 'quatre', 'cinc', 'sis', 'set', 'huit', 'nou', 'deu'];

export const FOOD: KidsItem[] = [
  { id: 'poma', word: 'la poma', emoji: '🍎' },
  { id: 'pa', word: 'el pa', emoji: '🍞' },
  { id: 'aigua', word: "l'aigua", emoji: '💧' },
  { id: 'llet', word: 'la llet', emoji: '🥛' },
  { id: 'formatge', word: 'el formatge', emoji: '🧀' },
  { id: 'platan', word: 'el plàtan', emoji: '🍌' },
  { id: 'taronja', word: 'la taronja', emoji: '🍊' },
  { id: 'maduixa', word: 'la maduixa', emoji: '🍓' },
  { id: 'raim', word: 'el raïm', emoji: '🍇' },
  { id: 'pera', word: 'la pera', emoji: '🍐' },
  { id: 'sindria', word: 'la síndria', emoji: '🍉' },
  { id: 'ou', word: "l'ou", emoji: '🥚' },
  { id: 'galeta', word: 'la galeta', emoji: '🍪' },
  { id: 'pastanaga', word: 'la pastanaga', emoji: '🥕' },
  { id: 'tomaca', word: 'la tomaca', emoji: '🍅' },
  { id: 'gelat', word: 'el gelat', emoji: '🍦' },
];
const FRUIT_IDS = ['poma', 'platan', 'taronja', 'maduixa', 'raim', 'pera', 'sindria'];
export const FRUIT = FOOD.filter(f => FRUIT_IDS.includes(f.id));

export const BODY: KidsItem[] = [
  { id: 'cap', word: 'el cap', emoji: '🟢' },
  { id: 'ulls', word: 'els ulls', emoji: '👀', plural: true },
  { id: 'nas', word: 'el nas', emoji: '👃' },
  { id: 'boca', word: 'la boca', emoji: '👄' },
  { id: 'braç', word: 'el braç', emoji: '💪' },
  { id: 'mà', word: 'la mà', emoji: '✋' },
  { id: 'cama', word: 'la cama', emoji: '🦵' },
  { id: 'peu', word: 'el peu', emoji: '🦶' },
  { id: 'orelles', word: 'les orelles', emoji: '👂', plural: true },
  { id: 'dents', word: 'les dents', emoji: '🦷', plural: true },
  { id: 'llengua', word: 'la llengua', emoji: '👅' },
  { id: 'dit', word: 'el dit', emoji: '☝️' },
];
// El cap del monstre és una taca verda: per a «On és...?» només les parts que es veuen bé.
const BODY_CARDS = BODY.filter(b => b.id !== 'cap');

export const EMOTIONS: KidsItem[] = [
  { id: 'feliç', word: 'feliç', emoji: '😀', sound: 'Està feliç!' },
  { id: 'trist', word: 'trist', emoji: '😢', sound: 'Està trist!' },
  { id: 'enfadat', word: 'enfadat', emoji: '😠', sound: 'Està enfadat!' },
  { id: 'espantat', word: 'espantat', emoji: '😨', sound: 'Té por!' },
  { id: 'sorpres', word: 'sorprès', emoji: '😲', sound: 'Està sorprès!' },
  { id: 'adormit', word: 'adormit', emoji: '😴', sound: 'Té son!' },
];

export const CLOTHES: KidsItem[] = [
  { id: 'sabates', word: 'les sabates', emoji: '👟', plural: true },
  { id: 'barret', word: 'el barret', emoji: '🎩' },
  { id: 'samarreta', word: 'la samarreta', emoji: '👕' },
  { id: 'pantalons', word: 'els pantalons', emoji: '👖', plural: true },
  { id: 'jaqueta', word: 'la jaqueta', emoji: '🧥' },
  { id: 'calcetins', word: 'els calcetins', emoji: '🧦', plural: true },
  { id: 'ulleres', word: 'les ulleres', emoji: '👓', plural: true },
  { id: 'guants', word: 'els guants', emoji: '🧤', plural: true },
  { id: 'bufanda', word: 'la bufanda', emoji: '🧣' },
];

export const FAMILY: KidsItem[] = [
  { id: 'pare', word: 'el pare', emoji: '👨' },
  { id: 'mare', word: 'la mare', emoji: '👩' },
  { id: 'germà', word: 'el germà', emoji: '👦' },
  { id: 'germana', word: 'la germana', emoji: '👧' },
  { id: 'bebe', word: 'el bebé', emoji: '👶' },
  { id: 'iaio', word: 'el iaio', emoji: '👴' },
  { id: 'iaia', word: 'la iaia', emoji: '👵' },
];

export const HOME_PLACES: KidsItem[] = [
  { id: 'casa', word: 'la casa', emoji: '🏠' },
  { id: 'porta', word: 'la porta', emoji: '🚪' },
  { id: 'llit', word: 'el llit', emoji: '🛏️' },
  { id: 'cuina', word: 'la cuina', emoji: '🍳' },
  { id: 'sofa', word: 'el sofà', emoji: '🛋️' },
  { id: 'banyera', word: 'la banyera', emoji: '🛁' },
];

// L'intrús: coses que no són de la família que es demana (ni animals ni menjar).
export const INTRUDERS: KidsItem[] = [
  CLOTHES.find(c => c.id === 'samarreta')!,
  { id: 'cotxe', word: 'el cotxe', emoji: '🚗' },
  { id: 'pilota', word: 'la pilota', emoji: '⚽' },
  { id: 'llapis', word: 'el llapis', emoji: '✏️' },
];

// «De quin color és...?»: coses conegudes amb un color clar.
export const COLOR_THINGS: { thing: KidsItem; color: string }[] = [
  { thing: FOOD.find(f => f.id === 'poma')!, color: 'roig' },
  { thing: FOOD.find(f => f.id === 'platan')!, color: 'groc' },
  { thing: ANIMALS.find(a => a.id === 'granota')!, color: 'verd' },
  { thing: FOOD.find(f => f.id === 'taronja')!, color: 'taronja-color' },
  { thing: FOOD.find(f => f.id === 'raim')!, color: 'morat' },
  { thing: ANIMALS.find(a => a.id === 'porc')!, color: 'rosa' },
  { thing: ANIMALS.find(a => a.id === 'elefant')!, color: 'gris' },
  { thing: { id: 'os', word: "l'ós", emoji: '🐻' }, color: 'marro' },
  { thing: { id: 'balena', word: 'la balena', emoji: '🐳' }, color: 'blau' },
  { thing: { id: 'nuvol', word: 'el núvol', emoji: '☁️' }, color: 'blanc' },
];

export type TraceLetter = { id: string; glyph: string; word: string; emoji: string; say: string };

// Traçat de grafies especials: la lletra, el so exagerat i una paraula d'exemple.
export const LETTERS: TraceLetter[] = [
  { id: 'ç', glyph: 'ç', word: 'el braç', emoji: '💪', say: 'La ce trencada! Sss! Com en el braç!' },
  { id: 'ny', glyph: 'ny', word: 'la pinya', emoji: '🍍', say: 'Nya, nye, nyi! Com en la pinya!' },
  { id: 'tx', glyph: 'tx', word: 'el cotxe', emoji: '🚗', say: 'Txe, txe, txe! Com en el cotxe!' },
  { id: 'tg', glyph: 'tg', word: 'el metge', emoji: '🧑‍⚕️', say: 'La te i la ge, juntes! Com en el metge!' },
  { id: 'll', glyph: 'll', word: 'la lluna', emoji: '🌙', say: 'Lla, lle, lli! Com en la lluna!' },
  { id: 'lgeminada', glyph: 'l·l', word: 'el col·legi', emoji: '🏫', say: 'La ela geminada! Com en el col·legi!' },
  { id: 'ix', glyph: 'ix', word: 'el peix', emoji: '🐟', say: 'Ix, ix, ix! Com en el peix!' },
  { id: 'gu', glyph: 'gu', word: 'la guitarra', emoji: '🎸', say: 'Gui, gue! Com en la guitarra!' },
];

// L'abecedari: cada lletra (en majúscula, com a l'escola infantil), el seu nom i una paraula.
// Sense la w ni la y, que quasi no apareixen en paraules valencianes.
const ABC_DATA: [letter: string, name: string, word: string, emoji: string][] = [
  ['a', 'la a', "l'abella", '🐝'], ['b', 'la be', 'la balena', '🐋'], ['c', 'la ce', 'la casa', '🏠'],
  ['d', 'la de', 'el dofí', '🐬'], ['e', 'la e', "l'elefant", '🐘'], ['f', 'la efe', 'la flor', '🌸'],
  ['g', 'la ge', 'el gat', '🐈'], ['h', 'la hac', "l'helicòpter", '🚁'], ['i', 'la i', "l'illa", '🏝️'],
  ['j', 'la jota', 'la jirafa', '🦒'], ['k', 'la ka', 'el koala', '🐨'], ['l', 'la ela', 'la lluna', '🌙'],
  ['m', 'la ema', 'la maduixa', '🍓'], ['n', 'la ena', 'el núvol', '☁️'], ['o', 'la o', "l'ovella", '🐑'],
  ['p', 'la pe', 'la poma', '🍎'], ['q', 'la cu', 'el quatre', '4️⃣'], ['r', 'la erre', 'el ratolí', '🐭'],
  ['s', 'la essa', 'el sol', '☀️'], ['t', 'la te', 'la tortuga', '🐢'], ['u', 'la u', "l'unicorn", '🦄'],
  ['v', 'la ve', 'la vaca', '🐄'], ['x', 'la xeix', 'la xocolata', '🍫'], ['z', 'la zeta', 'la zebra', '🦓'],
];
export const ALPHABET = ABC_DATA.map(([letter, name, word, emoji]) => ({
  letter, name, word, emoji,
  card: { id: `abc-${letter}`, word: name, emoji: letter.toUpperCase() } as KidsItem,
  trace: { id: `abc-${letter}`, glyph: letter.toUpperCase(), word, emoji, say: '' } as TraceLetter,
}));
const ABC_TRACE = ['a', 'e', 'i', 'o', 'u', 'l', 'm', 'p', 's', 't'];
const VOWELS = ['a', 'e', 'i', 'o', 'u'];

// Els números com a targetes de punts (sense xifres): per a ordenar i per a «On n'hi ha més?».
export const NUM_ITEMS: KidsItem[] = NUMBERS.map((n, i) => ({ id: `num-${i + 1}`, word: n, emoji: '🍬', count: i + 1, audio: `n-${i + 1}` }));
export const FRUIT_COUNT = ['🍓', '🍎', '🍌', '🍇', '🍊'];
const counter = (n: number, emoji: string): KidsItem => ({ id: `num-${n}-${emoji}`, word: NUMBERS[n - 1], emoji, count: n, audio: `n-${n}` });

// On viu cada animal: al cel, a l'aigua o a la terra.
export const HABITAT_BINS: KidsItem[] = [
  { id: 'cel', word: 'al cel', emoji: '☁️' },
  { id: 'aigua-mar', word: "a l'aigua", emoji: '🌊' },
  { id: 'terra', word: 'a la terra', emoji: '🌳' },
];
export const EXTRA_ANIMALS: KidsItem[] = [
  { id: 'abella', word: "l'abella", emoji: '🐝' },
  { id: 'papallona', word: 'la papallona', emoji: '🦋' },
  { id: 'aguila', word: "l'àguila", emoji: '🦅' },
  { id: 'dofi', word: 'el dofí', emoji: '🐬' },
  { id: 'balena', word: 'la balena', emoji: '🐳' },
  { id: 'pop', word: 'el pop', emoji: '🐙' },
  { id: 'cranc', word: 'el cranc', emoji: '🦀' },
];
const animalById = (id: string) => [...ANIMALS, ...EXTRA_ANIMALS].find(a => a.id === id)!;
const HABITAT: Record<string, string[]> = {
  cel: ['ocell', 'abella', 'papallona', 'aguila'],
  'aigua-mar': ['peix', 'dofi', 'balena', 'pop', 'cranc'],
  terra: ['gos', 'gat', 'vaca', 'cavall', 'lleo', 'elefant', 'porc', 'conill'],
};

// La fruita i la verdura.
export const VEGGIES: KidsItem[] = [
  FOOD.find(f => f.id === 'pastanaga')!,
  { id: 'enciam', word: "l'enciam", emoji: '🥬' },
  { id: 'broquil', word: 'el bròquil', emoji: '🥦' },
  { id: 'creilla', word: 'la creïlla', emoji: '🥔' },
  { id: 'ceba', word: 'la ceba', emoji: '🧅' },
  { id: 'pebrot', word: 'el pebrot', emoji: '🫑' },
  { id: 'albergina', word: "l'albergina", emoji: '🍆' },
];
const FOOD_BINS: KidsItem[] = [
  { id: 'bin-fruita', word: 'la fruita', emoji: '🍎🍌🍇', stack: true },
  { id: 'bin-verdura', word: 'la verdura', emoji: '🥦🥕🥬', stack: true },
];

// Les accions: «Qui dorm?» (tercera persona) i el nom de l'acció («Dormir!»).
export const ACTIONS: (KidsItem & { does: string })[] = [
  { id: 'acc-menjar', word: 'menjar', emoji: '😋', does: 'menja' },
  { id: 'acc-beure', word: 'beure', emoji: '🥤', does: 'beu' },
  { id: 'acc-dormir', word: 'dormir', emoji: '😴', does: 'dorm' },
  { id: 'acc-correr', word: 'córrer', emoji: '🏃', does: 'corre' },
  { id: 'acc-saltar', word: 'saltar', emoji: '🤸', does: 'salta' },
  { id: 'acc-nadar', word: 'nadar', emoji: '🏊', does: 'nada' },
  { id: 'acc-ballar', word: 'ballar', emoji: '💃', does: 'balla' },
  { id: 'acc-cantar', word: 'cantar', emoji: '🎤', does: 'canta' },
  { id: 'acc-pintar', word: 'pintar', emoji: '🎨', does: 'pinta' },
  { id: 'acc-llegir', word: 'llegir', emoji: '📖', does: 'llig' },
  { id: 'acc-plorar', word: 'plorar', emoji: '😭', does: 'plora' },
  { id: 'acc-riure', word: 'riure', emoji: '😂', does: 'riu' },
];

// Els contraris: cada parella amb la seua pregunta («Qui és ràpid?»).
type Opposite = KidsItem & { ask: string };
export const OPPOSITES: [Opposite, Opposite][] = [
  [{ id: 'op-dia', word: 'el dia', emoji: '☀️', ask: 'On és el dia?' }, { id: 'op-nit', word: 'la nit', emoji: '🌙', ask: 'On és la nit?' }],
  [{ id: 'op-calent', word: 'calent', emoji: '🔥', ask: 'Què està calent?' }, { id: 'op-fred', word: 'fred', emoji: '🧊', ask: 'Què està fred?' }],
  [{ id: 'op-rapid', word: 'ràpid', emoji: '🐇', ask: 'Qui és ràpid?' }, { id: 'op-lent', word: 'lent', emoji: '🐢', ask: 'Qui és lent?' }],
  [{ id: 'op-alt', word: 'alt', emoji: '🦒', ask: 'Qui és alt?' }, { id: 'op-baix', word: 'baix', emoji: '🐧', ask: 'Qui és baix?' }],
  [{ id: 'op-obert', word: 'obert', emoji: '📖', ask: 'Quin llibre està obert?' }, { id: 'op-tancat', word: 'tancat', emoji: '📕', ask: 'Quin llibre està tancat?' }],
  [{ id: 'op-content', word: 'content', emoji: '😀', ask: 'Qui està content?' }, { id: 'op-trist', word: 'trist', emoji: '😢', ask: 'Qui està trist?' }],
];
const SIZE_EMOJIS = ['🐘', '🐻', '🍎', '🚗', '🐸', '🎈', '🦁', '🐟'];
export const sizeItem = (emoji: string, big: boolean): KidsItem =>
  ({ id: `${big ? 'gran' : 'xicotet'}-${emoji}`, word: big ? 'gran' : 'xicotet', emoji, scale: big ? 1.25 : 0.5, audio: big ? 'w-gran' : 'w-xicotet' });
const HOT_COLD_BINS: KidsItem[] = [
  { id: 'bin-calent', word: 'calent', emoji: '🔥' },
  { id: 'bin-fred', word: 'fred', emoji: '🧊' },
];
const HOT_COLD: { item: KidsItem; bin: string }[] = [
  { item: { id: 'sol', word: 'el sol', emoji: '☀️' }, bin: 'bin-calent' },
  { item: { id: 'sopa', word: 'la sopa', emoji: '🍲' }, bin: 'bin-calent' },
  { item: { id: 'xocolata-calenta', word: 'la xocolata calenta', emoji: '☕' }, bin: 'bin-calent' },
  { item: { id: 'neu', word: 'la neu', emoji: '❄️' }, bin: 'bin-fred' },
  { item: FOOD.find(f => f.id === 'gelat')!, bin: 'bin-fred' },
  { item: { id: 'ninot', word: 'el ninot de neu', emoji: '⛄' }, bin: 'bin-fred' },
];

/* ── Frases que es diuen (una per fitxer d'àudio) ─────────────────────── */

const onEs = (item: KidsItem) => `On ${item.plural ? 'són' : 'és'} ${item.word}?`;
export const capital = (s: string) => s.charAt(0).toUpperCase() + s.slice(1);
// «a la casa», «al llit», «a la porta»
const aLloc = (word: string) => (word.startsWith('el ') ? `al ${word.slice(3)}` : `a ${word}`);
// «de balena», «d'abella»
const noun = (word: string) => word.replace(/^(el |la |els |les |l')/, '');
const de = (word: string) => (/^[aeiouàèéíòóúh]/i.test(noun(word)) ? `d'${noun(word)}` : `de ${noun(word)}`);
for (const l of ALPHABET) l.trace.say = `${capital(l.name)}! Com en ${l.word}!`;

// Al monstre només se li posen les parts i la roba que tenen lloc en el seu cos.
const MONSTER_IDS = ['cap', 'ulls', 'nas', 'boca', 'braç', 'mà', 'cama', 'peu', 'sabates', 'barret', 'samarreta'];

export const DRAG_TASKS = {
  plat: FOOD.map(f => ({ item: f, zone: 'plat', key: `plat-${f.id}`, text: `Posa ${f.word} al plat!` })),
  motxilla: FOOD.map(f => ({ item: f, zone: 'motxilla', key: `motxilla-${f.id}`, text: `Posa ${f.word} a la motxilla!` })),
  monstre: [...BODY, ...CLOTHES].filter(b => MONSTER_IDS.includes(b.id))
    .map(b => ({ item: b, zone: b.id, key: `posali-${b.id}`, text: `Posa-li ${b.word}!` })),
  casa: FAMILY.flatMap(item => HOME_PLACES.map(target =>
    ({ item, zone: target.id, key: `porta-${item.id}-${target.id}`, text: `Porta ${item.word} ${aLloc(target.word)}!` }))),
};

const counted = (n: number) => (n === 1 ? 'un caramel' : `${NUMBERS[n - 1]} caramels`);

export const KIDS_AUDIO: Record<string, string> = {
  // Generals
  'hola': 'Hola! Soc la Taronjeta. Tria una illa per a jugar!',
  'album': 'El teu àlbum de cromos! Toca un cromo per a posar-lo on vulgues.',
  'cromo-nou': 'Molt bé! Has guanyat un cromo nou!',
  'be-1': 'Molt bé!',
  'be-2': 'Fantàstic!',
  'be-3': 'Què bé!',
  'be-4': 'Ho has aconseguit!',
  'torna-1': 'Ups! Torna-ho a provar!',
  'torna-2': 'Prova una altra vegada!',
  // Noms de les illes
  'illa-animals': "L'illa dels animals!",
  'illa-colors': "L'illa dels colors!",
  'illa-numeros': "L'illa dels números!",
  'illa-menjar': "L'illa del menjar!",
  'illa-cos': "L'illa del cos!",
  'illa-familia': "L'illa de la família!",
  'illa-lletres': "L'illa de les lletres!",
  'illa-abecedari': "L'illa de l'abecedari!",
  // L'intrús
  'intrus-animals': 'Els animals! Quin no és un animal?',
  'intrus-fruita': 'La fruita! Quina no és una fruita?',
  'intrus-menjar': 'El menjar! Quin no es pot menjar?',
};

for (const item of [...ANIMALS, ...FOOD, ...BODY, ...CLOTHES, ...FAMILY, ...HOME_PLACES, ...INTRUDERS]) {
  KIDS_AUDIO[`w-${item.id}`] = capital(`${item.word}!`);
  KIDS_AUDIO[`on-${item.id}`] = onEs(item);
}
for (const item of ANIMALS) {
  KIDS_AUDIO[`fa-${item.id}`] = item.sound!;
  KIDS_AUDIO[`qui-${item.id}`] = `Qui fa ${item.noise}?`;
}
for (const item of COLORS) {
  KIDS_AUDIO[`w-${item.id}`] = capital(`${item.word}!`);
  KIDS_AUDIO[`toca-${item.id}`] = `Toca ${item.word}!`;
  KIDS_AUDIO[`bamb-${item.id}`] = `Explota les bambolles de color ${item.word.slice(3)}!`;
}
for (const { thing } of COLOR_THINGS) KIDS_AUDIO[`dequin-${thing.id}`] = `De quin color és ${thing.word}?`;
for (const item of EMOTIONS) KIDS_AUDIO[`emo-${item.id}`] = item.sound!;
NUMBERS.forEach((n, i) => {
  KIDS_AUDIO[`n-${i + 1}`] = capital(`${n}!`);
  KIDS_AUDIO[`dona-${i + 1}`] = `Dona-li ${counted(i + 1)} a la Taronjeta!`;
  KIDS_AUDIO[`onhiha-${i + 1}`] = i === 0 ? 'On n\'hi ha un?' : `On n'hi ha ${n}?`;
});
for (const tasks of Object.values(DRAG_TASKS)) for (const t of tasks) KIDS_AUDIO[t.key] = t.text;
for (const l of [...LETTERS, ...ALPHABET.map(a => a.trace)]) {
  KIDS_AUDIO[`lletra-${l.id}`] = l.say;
  KIDS_AUDIO[`w-lletra-${l.id}`] = capital(`${l.word}!`);
}
for (const l of ALPHABET) {
  KIDS_AUDIO[`on-abc-${l.letter}`] = `On és ${l.name}?`;
  KIDS_AUDIO[`abc-de-${l.letter}`] = `${capital(l.name)}, ${de(l.word)}!`;
  KIDS_AUDIO[`comenca-${l.letter}`] = `${capital(l.word)}! Amb quina lletra comença?`;
  KIDS_AUDIO[`w-abc-${l.letter}`] = `${capital(l.name)}!`;
}

// Jocs nous: parelles, ordre, classificar, més i menys.
Object.assign(KIDS_AUDIO, {
  'illa-accions': "L'illa de les accions!",
  'illa-contraris': "L'illa dels contraris!",
  'parelles': 'Busca les parelles! Gira dues cartes iguals.',
  'primer': 'Primer, toca...',
  'despres': 'I després...',
  'ordre-numeros': "Toca'ls en ordre, de menys a més!",
  'ordre-vocals': 'Toca les vocals en ordre: a, e, i, o, u!',
  'mes': "On n'hi ha més?",
  'menys': "On n'hi ha menys?",
  'sort-habitat': "On viu? Al cel, a l'aigua o a la terra?",
  'sort-fruita': 'La fruita, a un costat! La verdura, a l\'altre!',
  'sort-calent': 'Les coses calentes, al foc! Les coses fredes, al gel!',
  'quin-gran': 'Quin és gran?',
  'quin-xicotet': 'Quin és xicotet?',
  'w-gran': 'Gran!',
  'w-xicotet': 'Xicotet!',
});
for (const item of [...EXTRA_ANIMALS, ...VEGGIES, ...HABITAT_BINS, ...FOOD_BINS, ...HOT_COLD_BINS, ...HOT_COLD.map(h => h.item)]) {
  KIDS_AUDIO[`w-${item.id}`] = capital(`${item.word}!`);
}
for (const item of ACTIONS) {
  KIDS_AUDIO[`w-${item.id}`] = capital(`${item.word}!`);
  KIDS_AUDIO[`qui-${item.id}`] = `Qui ${item.does}?`;
}
for (const item of OPPOSITES.flat()) {
  KIDS_AUDIO[`w-${item.id}`] = capital(`${item.word}!`);
  KIDS_AUDIO[`ask-${item.id}`] = item.ask;
}

/* ── Rondes i illes ───────────────────────────────────────────────────── */

export type Round =
  | { kind: 'tap'; prompt: string; target: KidsItem; options: KidsItem[]; style?: 'cards' | 'faces' | 'letters'; react?: string; picture?: string }
  | { kind: 'odd'; prompt: string; options: KidsItem[]; target: KidsItem }
  | { kind: 'bubbles'; prompt: string; color: KidsItem; others: KidsItem[] }
  | { kind: 'count'; prompt: string; n: number }
  | { kind: 'dots'; prompt: string; n: number; options: number[] }
  | { kind: 'drag'; scene: 'plat' | 'motxilla' | 'monstre' | 'casa'; tasks: { item: KidsItem; zone: string; key: string }[] }
  | { kind: 'trace'; letter: TraceLetter }
  // Memòria: girar cartes fins a trobar totes les parelles.
  | { kind: 'memory'; prompt: string; items: KidsItem[]; style?: 'letters' }
  // Ordre: tocar diversos elements en l'ordre que diu la consigna (o en l'ordre natural).
  | { kind: 'seq'; prompt: string[]; targets: KidsItem[]; options: KidsItem[]; style?: 'letters' }
  // Classificar: cada element que apareix va a un dels calaixos.
  | { kind: 'sort'; prompt: string; bins: KidsItem[]; items: { item: KidsItem; bin: string }[] };

export type Island = {
  id: string;
  name: string;
  emoji: string;
  color: string;
  cromo: { emoji: string; name: string }; // el cromo que guanya qui acaba l'illa
  lesson?: string; // la lliçó de teoria relacionada
  rounds: () => Round[]; // cada sessió es barreja de nou
};

export const shuffle = <T,>(list: readonly T[]): T[] => {
  const copy = [...list];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
};
export const pick = <T,>(list: readonly T[], n: number) => shuffle(list).slice(0, n);

// Ronda de «Toca i escolta»: l'objectiu i distractors del mateix grup. Les primeres
// rondes de cada illa tenen menys opcions (2-3) i les últimes, més (4).
type TapExtra = Partial<Pick<Extract<Round, { kind: 'tap' }>, 'prompt' | 'react' | 'picture' | 'style'>>;
const tapRound = (pool: KidsItem[], target: KidsItem, size = 3, extra: TapExtra = {}): Round => ({
  kind: 'tap',
  prompt: `on-${target.id}`,
  target,
  options: shuffle([target, ...pick(pool.filter(p => p.id !== target.id), size - 1)]),
  ...extra,
});

const oddRound = (prompt: string, group: KidsItem[], outsiders: KidsItem[]): Round => {
  const target = pick(outsiders, 1)[0];
  return { kind: 'odd', prompt, target, options: shuffle([...pick(group, 3), target]) };
};

const colorById = (id: string) => COLORS.find(c => c.id === id)!;

// «De quin color és la poma?»: es veu la cosa i es toca el color.
const colorOfRound = ({ thing, color }: (typeof COLOR_THINGS)[number], size: number): Round => {
  const target = colorById(color);
  return { ...tapRound(COLORS, target, size, { prompt: `dequin-${thing.id}`, react: `w-${target.id}`, picture: thing.emoji }) };
};

const bubbleRound = (color: KidsItem): Round =>
  ({ kind: 'bubbles', prompt: `bamb-${color.id}`, color, others: pick(COLORS.filter(c => c.id !== color.id), 3) });

// Porta cada familiar a un lloc de la casa (familiars diferents, llocs a l'atzar).
const casaRound = (n: number): Round => ({
  kind: 'drag',
  scene: 'casa',
  tasks: pick(FAMILY, n).map(person => pick(DRAG_TASKS.casa.filter(t => t.item.id === person.id), 1)[0]),
});

const monsterRound = (zones: string[]): Round =>
  ({ kind: 'drag', scene: 'monstre', tasks: DRAG_TASKS.monstre.filter(t => zones.includes(t.zone)) });

const emotionRound = (emotion: KidsItem, size: number): Round =>
  ({ ...tapRound(EMOTIONS, emotion, size, { prompt: `emo-${emotion.id}`, style: 'faces' }) });

// Memòria: N parelles del grup.
export const memoryRound = (pool: KidsItem[], pairs: number, style?: 'letters'): Round =>
  ({ kind: 'memory', prompt: 'parelles', items: pick(pool, pairs), style });

// «Primer, toca el gos... I després, la poma!»: memòria auditiva de 2 o 3 passos.
export const thenRound = (pool: KidsItem[], steps: number, size: number): Round => {
  const options = pick(pool, size);
  const targets = options.slice(0, steps);
  const prompt = ['primer', ...targets.flatMap((t, i) => (i ? ['despres', itemAudio(t)] : [itemAudio(t)]))];
  return { kind: 'seq', prompt, targets, options: shuffle(options) };
};

// Ordenar: els elements es toquen en l'ordre en què venen.
export const orderRound = (prompt: string, ordered: KidsItem[], style?: 'letters'): Round =>
  ({ kind: 'seq', prompt: [prompt], targets: ordered, options: shuffle(ordered), style });

export const sortRound = (prompt: string, bins: KidsItem[], items: { item: KidsItem; bin: string }[]): Round =>
  ({ kind: 'sort', prompt, bins, items: shuffle(items) });

// «On n'hi ha més?»: dos grups de la mateixa fruita, amb almenys dos de diferència.
export const moreRound = (more: boolean): Round => {
  const emoji = pick(FRUIT_COUNT, 1)[0];
  const small = 1 + Math.floor(Math.random() * 5);
  const big = small + 2 + Math.floor(Math.random() * 3);
  const [a, b] = [counter(big, emoji), counter(small, emoji)];
  return { kind: 'tap', prompt: more ? 'mes' : 'menys', target: more ? a : b, options: shuffle([a, b]) };
};
const numbersInOrder = (n: number) => pick(NUM_ITEMS.slice(0, 8), n).sort((a, b) => a.count! - b.count!);

export const habitatRound = (): Round => sortRound('sort-habitat', HABITAT_BINS,
  HABITAT_BINS.flatMap(bin => pick(HABITAT[bin.id], 2).map(id => ({ item: animalById(id), bin: bin.id }))));

const fruitVegRound = (): Round => sortRound('sort-fruita', FOOD_BINS, [
  ...pick(FRUIT, 3).map(item => ({ item, bin: 'bin-fruita' })),
  ...pick(VEGGIES, 3).map(item => ({ item, bin: 'bin-verdura' })),
]);

export const hotColdRound = (): Round => sortRound('sort-calent', HOT_COLD_BINS, HOT_COLD);

const sizeRound = (big: boolean): Round => {
  const emoji = pick(SIZE_EMOJIS, 1)[0];
  const [a, b] = [sizeItem(emoji, true), sizeItem(emoji, false)];
  return { kind: 'tap', prompt: big ? 'quin-gran' : 'quin-xicotet', target: big ? a : b, options: shuffle([a, b]) };
};

// Un contrari de la parella, amb l'altre i, si size = 3, un element d'una altra parella
// (mai el dia amb el calent, que el sol també crema).
const oppositeRound = (pair: [KidsItem, KidsItem], size: number): Round => {
  const target = pick(pair, 1)[0];
  const clash = (p: [KidsItem, KidsItem]) => [p[0].id, pair[0].id].sort().join() === 'op-calent,op-dia';
  const others = OPPOSITES.filter(p => p !== pair && !clash(p)).flat();
  const options = shuffle([...pair, ...pick(others, size - 2)]);
  return { kind: 'tap', prompt: `ask-${target.id}`, target, options };
};

const LETTER_CARDS: KidsItem[] = LETTERS.map(l => ({ id: `lt-${l.id}`, word: l.glyph, emoji: l.glyph, audio: `lletra-${l.id}` }));

export const ISLANDS: Island[] = [
  {
    id: 'animals', name: 'Els animals', emoji: '🐶', color: '#FFD8A8', lesson: 'articles',
    cromo: { emoji: '🐕', name: 'El gos' },
    rounds: () => {
      const [a, b, c, d, e, f, g] = pick(ANIMALS, 7);
      const sound = (t: KidsItem) => `fa-${t.id}`;
      const tap = (t: KidsItem, size: number) => tapRound(ANIMALS, t, size, { react: sound(t) });
      // «Qui fa mèu?»: només se sent l'onomatopeia i es busca l'animal.
      const who = (t: KidsItem, size: number) => tapRound(ANIMALS, t, size, { prompt: `qui-${t.id}`, react: sound(t) });
      return [
        tap(a, 2), tap(b, 3), who(c, 3), memoryRound(ANIMALS, 3),
        tap(d, 4), habitatRound(), oddRound('intrus-animals', ANIMALS, INTRUDERS), who(e, 4),
        thenRound(ANIMALS, 2, 4), tap(f, 4), memoryRound(ANIMALS, 4), who(g, 4),
      ];
    },
  },
  {
    id: 'colors', name: 'Els colors', emoji: '🎨', color: '#D0EBFF', lesson: 'colors',
    cromo: { emoji: '🌈', name: "L'arc de Sant Martí" },
    rounds: () => {
      const [b1, b2, b3, t1, t2] = pick(COLORS, 5);
      const [c1, c2, c3] = pick(COLOR_THINGS, 3);
      const touch = (c: KidsItem, size: number) => tapRound(COLORS, c, size, { prompt: `toca-${c.id}`, react: `w-${c.id}` });
      return [
        bubbleRound(b1), touch(t1, 3), colorOfRound(c1, 2), memoryRound(COLORS, 3),
        bubbleRound(b2), touch(t2, 4), thenRound(COLORS, 2, 4), colorOfRound(c2, 3),
        bubbleRound(b3), memoryRound(COLORS, 4), colorOfRound(c3, 4), thenRound(COLORS, 3, 6),
      ];
    },
  },
  {
    id: 'numeros', name: 'Els números', emoji: '🔢', color: '#E5DBFF', lesson: 'numeros',
    cromo: { emoji: '🍬', name: 'Els caramels' },
    rounds: () => {
      const count = (n: number) => ({ kind: 'count', prompt: `dona-${n}`, n }) as Round;
      const dots = (n: number) => ({ kind: 'dots', prompt: `onhiha-${n}`, n, options: shuffle([n, ...pick([1, 2, 3, 4, 5, 6, 7].filter(x => x !== n), 2)]) }) as Round;
      const [s1, s2] = pick([1, 2, 3], 2);
      const [m1, m2] = pick([4, 5, 6], 2);
      const [d1, d2, d3] = [pick([1, 2, 3], 1)[0], ...pick([4, 5, 6, 7], 2)];
      const big = pick([7, 8, 9, 10], 1)[0];
      return [
        count(s1), dots(d1), orderRound('ordre-numeros', numbersInOrder(3)), count(s2),
        moreRound(true), dots(d2), orderRound('ordre-numeros', numbersInOrder(4)), count(m1),
        moreRound(false), dots(d3), orderRound('ordre-numeros', numbersInOrder(5)), count(m2), count(big),
      ];
    },
  },
  {
    id: 'menjar', name: 'El menjar', emoji: '🍎', color: '#FFE3E3',
    cromo: { emoji: '🥪', name: 'El berenar' },
    rounds: () => {
      const [a, b, c, d] = pick(FOOD, 4);
      const notFood = [...INTRUDERS, ...ANIMALS.filter(x => ['gos', 'gat'].includes(x.id))];
      return [
        { kind: 'drag', scene: 'plat', tasks: pick(DRAG_TASKS.plat, 2) },
        tapRound(FOOD, a, 2), tapRound(FOOD, b, 3),
        oddRound('intrus-fruita', FRUIT, notFood),
        memoryRound(FOOD, 3),
        { kind: 'drag', scene: 'motxilla', tasks: pick(DRAG_TASKS.motxilla, 3) },
        fruitVegRound(),
        tapRound(FOOD, c, 4),
        oddRound('intrus-menjar', FOOD, INTRUDERS),
        thenRound(FOOD, 2, 4),
        tapRound(FOOD, d, 4),
        memoryRound(FOOD, 4),
        { kind: 'drag', scene: 'plat', tasks: pick(DRAG_TASKS.plat, 3) },
      ];
    },
  },
  {
    id: 'cos', name: 'El cos', emoji: '🧒', color: '#D3F9D8', lesson: 'cos',
    cromo: { emoji: '👾', name: 'El monstre simpàtic' },
    rounds: () => {
      const [b1, b2, b3] = pick(BODY_CARDS, 3);
      const [e1, e2] = pick(EMOTIONS, 2);
      const [c1, c2] = pick(CLOTHES, 2);
      return [
        monsterRound(['cap', 'ulls', 'nas', 'boca']),
        tapRound(BODY_CARDS, b1, 3),
        emotionRound(e1, 3),
        monsterRound(['braç', 'mà', 'cama', 'peu']),
        thenRound(BODY_CARDS, 2, 4),
        tapRound(BODY_CARDS, b2, 4),
        tapRound(CLOTHES, c1, 3),
        memoryRound(BODY_CARDS, 3),
        emotionRound(e2, 4),
        monsterRound(['barret', 'samarreta', 'sabates']),
        tapRound(CLOTHES, c2, 4),
        thenRound(BODY_CARDS, 3, 6),
        tapRound(BODY_CARDS, b3, 4),
      ];
    },
  },
  {
    id: 'familia', name: 'La família', emoji: '🏠', color: '#FFF3BF', lesson: 'familia',
    cromo: { emoji: '👨‍👩‍👦', name: 'La família' },
    rounds: () => {
      const [a, b, c, d, e] = pick(FAMILY, 5);
      const places = pick(HOME_PLACES, 2);
      return [
        tapRound(FAMILY, a, 2), tapRound(FAMILY, b, 3), casaRound(2), memoryRound(FAMILY, 3),
        tapRound(HOME_PLACES, places[0], 3), tapRound(FAMILY, c, 4), casaRound(3), thenRound(FAMILY, 2, 4),
        tapRound(FAMILY, d, 4), tapRound(HOME_PLACES, places[1], 4), memoryRound(FAMILY, 4), tapRound(FAMILY, e, 4), casaRound(3),
      ];
    },
  },
  {
    id: 'accions', name: 'Les accions', emoji: '🤸', color: '#FFEDD5', lesson: 'accions',
    cromo: { emoji: '🏅', name: 'La medalla' },
    rounds: () => {
      const [a, b, c, d, e, f] = pick(ACTIONS, 6);
      const who = (t: KidsItem, size: number) => tapRound(ACTIONS, t, size, { prompt: `qui-${t.id}` });
      return [
        who(a, 2), who(b, 3), memoryRound(ACTIONS, 3), who(c, 3), thenRound(ACTIONS, 2, 4),
        who(d, 4), memoryRound(ACTIONS, 4), who(e, 4), thenRound(ACTIONS, 3, 6), who(f, 4),
      ];
    },
  },
  {
    id: 'contraris', name: 'Els contraris', emoji: '🌗', color: '#E0E7FF', lesson: 'contraris',
    cromo: { emoji: '🎭', name: 'Les dues cares' },
    rounds: () => {
      const pairs = shuffle(OPPOSITES);
      return [
        sizeRound(true), oppositeRound(pairs[0], 2), sizeRound(false), oppositeRound(pairs[1], 2),
        hotColdRound(), oppositeRound(pairs[2], 3), sizeRound(Math.random() < 0.5), oppositeRound(pairs[3], 3),
        oppositeRound(pairs[4], 3), sizeRound(Math.random() < 0.5), oppositeRound(pairs[5], 3),
      ];
    },
  },
  {
    id: 'lletres', name: 'Les lletres', emoji: '✨', color: '#FCE7F3', lesson: 'sons',
    cromo: { emoji: '⭐', name: "L'estrela de les lletres" },
    rounds: () => {
      const traces = pick(LETTERS, 7).map(letter => ({ kind: 'trace', letter }) as Round);
      return [
        traces[0], traces[1], memoryRound(LETTER_CARDS, 3, 'letters'), traces[2], traces[3],
        memoryRound(LETTER_CARDS, 3, 'letters'), traces[4], traces[5], memoryRound(LETTER_CARDS, 4, 'letters'), traces[6],
      ];
    },
  },
  {
    id: 'abecedari', name: "L'abecedari", emoji: '🔤', color: '#C5F6FA', lesson: 'sons',
    cromo: { emoji: '🐝', name: "L'abella de l'abecedari" },
    rounds: () => {
      const cards = ALPHABET.map(l => l.card);
      const letter = (l: (typeof ALPHABET)[number], size: number) =>
        tapRound(cards, l.card, size, { style: 'letters', react: `abc-de-${l.letter}` });
      // «La balena! Amb quina lletra comença?»: es veu el dibuix i es toca la lletra.
      const starts = (l: (typeof ALPHABET)[number], size: number) =>
        tapRound(cards, l.card, size, { style: 'letters', prompt: `comenca-${l.letter}`, react: `abc-de-${l.letter}`, picture: l.emoji });
      const trace = (id: string) => ({ kind: 'trace', letter: ALPHABET.find(l => l.letter === id)!.trace }) as Round;
      const vowels = VOWELS.map(v => ALPHABET.find(l => l.letter === v)!.card);
      const [a, b, c, d, e, f, g] = pick(ALPHABET, 7);
      const [t1, t2] = pick(ABC_TRACE, 2);
      return [
        letter(a, 2), letter(b, 3), trace(t1), starts(c, 2),
        orderRound('ordre-vocals', vowels, 'letters'), memoryRound(cards, 3, 'letters'), letter(d, 3), trace(t2),
        starts(e, 3), memoryRound(cards, 4, 'letters'), letter(f, 4), starts(g, 4),
      ];
    },
  },
];

export const islandById = (id: string | undefined) => ISLANDS.find(i => i.id === id);
export const FEEDBACK_OK = ['be-1', 'be-2', 'be-3', 'be-4'];
export const FEEDBACK_RETRY = ['torna-1', 'torna-2'];
