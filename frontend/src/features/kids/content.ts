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
  color?: string; // per als colors i les bambolles
};

/* ── Vocabulari per blocs ─────────────────────────────────────────────── */

export const ANIMALS: KidsItem[] = [
  { id: 'gos', word: 'el gos', emoji: '🐕', sound: 'El gos fa bub, bub!' },
  { id: 'gat', word: 'el gat', emoji: '🐈', sound: 'El gat fa mèu, mèu!' },
  { id: 'ocell', word: "l'ocell", emoji: '🐦', sound: "L'ocell fa piu, piu!" },
  { id: 'peix', word: 'el peix', emoji: '🐟', sound: 'El peix fa glub, glub!' },
  { id: 'vaca', word: 'la vaca', emoji: '🐄', sound: 'La vaca fa muuu!' },
  { id: 'cavall', word: 'el cavall', emoji: '🐎', sound: 'El cavall fa hi, hi, hi!' },
  { id: 'porc', word: 'el porc', emoji: '🐖', sound: 'El porc fa oinc, oinc!' },
];

export const COLORS: KidsItem[] = [
  { id: 'roig', word: 'el roig', emoji: '🔴', color: '#EF4444' },
  { id: 'blau', word: 'el blau', emoji: '🔵', color: '#3B82F6' },
  { id: 'groc', word: 'el groc', emoji: '🟡', color: '#FACC15' },
  { id: 'verd', word: 'el verd', emoji: '🟢', color: '#22C55E' },
  { id: 'taronja-color', word: 'el taronja', emoji: '🟠', color: '#F97316' },
  { id: 'negre', word: 'el negre', emoji: '⚫', color: '#1F2937' },
  { id: 'blanc', word: 'el blanc', emoji: '⚪', color: '#FFFFFF' },
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
];

export const BODY: KidsItem[] = [
  { id: 'cap', word: 'el cap', emoji: '🟢' },
  { id: 'ulls', word: 'els ulls', emoji: '👀', plural: true },
  { id: 'nas', word: 'el nas', emoji: '👃' },
  { id: 'boca', word: 'la boca', emoji: '👄' },
  { id: 'braç', word: 'el braç', emoji: '💪' },
  { id: 'mà', word: 'la mà', emoji: '✋' },
  { id: 'cama', word: 'la cama', emoji: '🦵' },
  { id: 'peu', word: 'el peu', emoji: '🦶' },
];

export const EMOTIONS: KidsItem[] = [
  { id: 'feliç', word: 'feliç', emoji: '😀', sound: 'Està feliç!' },
  { id: 'trist', word: 'trist', emoji: '😢', sound: 'Està trist!' },
  { id: 'enfadat', word: 'enfadat', emoji: '😠', sound: 'Està enfadat!' },
];

export const CLOTHES: KidsItem[] = [
  { id: 'sabates', word: 'les sabates', emoji: '👟', plural: true },
  { id: 'barret', word: 'el barret', emoji: '🎩' },
];

export const FAMILY: KidsItem[] = [
  { id: 'pare', word: 'el pare', emoji: '👨' },
  { id: 'mare', word: 'la mare', emoji: '👩' },
  { id: 'germà', word: 'el germà', emoji: '👦' },
  { id: 'iaio', word: 'el iaio', emoji: '👴' },
  { id: 'iaia', word: 'la iaia', emoji: '👵' },
];

export const HOME_PLACES: KidsItem[] = [
  { id: 'casa', word: 'la casa', emoji: '🏠' },
  { id: 'porta', word: 'la porta', emoji: '🚪' },
  { id: 'llit', word: 'el llit', emoji: '🛏️' },
];

// L'intrús: un element que no és de la família que es demana.
export const INTRUDERS = {
  samarreta: { id: 'samarreta', word: 'la samarreta', emoji: '👕' } as KidsItem,
};

// Traçat de grafies especials: la lletra, el so exagerat i una paraula d'exemple.
export const LETTERS = [
  { id: 'ç', glyph: 'ç', word: 'el braç', emoji: '💪', say: 'La ce trencada! Sss! Com en el braç!' },
  { id: 'ny', glyph: 'ny', word: 'la pinya', emoji: '🍍', say: 'Nya, nye, nyi! Com en la pinya!' },
  { id: 'tx', glyph: 'tx', word: 'el cotxe', emoji: '🚗', say: 'Txe, txe, txe! Com en el cotxe!' },
  { id: 'tg', glyph: 'tg', word: 'el metge', emoji: '🧑‍⚕️', say: 'La te i la ge, juntes! Com en el metge!' },
] as const;

/* ── Frases que es diuen (una per fitxer d'àudio) ─────────────────────── */

const onEs = (item: KidsItem) => `On ${item.plural ? 'són' : 'és'} ${item.word}?`;
const capital = (s: string) => s.charAt(0).toUpperCase() + s.slice(1);
// «a la casa», «al llit», «a la porta»
const aLloc = (word: string) => (word.startsWith('el ') ? `al ${word.slice(3)}` : `a ${word}`);

export const DRAG_TASKS = {
  plat: FOOD.map(f => ({ item: f, zone: 'plat', key: `plat-${f.id}`, text: `Posa ${f.word} al plat!` })),
  motxilla: FOOD.map(f => ({ item: f, zone: 'motxilla', key: `motxilla-${f.id}`, text: `Posa ${f.word} a la motxilla!` })),
  monstre: [...BODY, ...CLOTHES].map(b => ({ item: b, zone: b.id, key: `posali-${b.id}`, text: `Posa-li ${b.word}!` })),
  casa: [
    { person: 'germà', place: 'llit' }, { person: 'iaia', place: 'casa' }, { person: 'pare', place: 'porta' },
    { person: 'mare', place: 'llit' }, { person: 'iaio', place: 'porta' }, { person: 'germà', place: 'casa' },
  ].map(({ person, place }) => {
    const item = FAMILY.find(f => f.id === person)!;
    const target = HOME_PLACES.find(h => h.id === place)!;
    return { item, zone: place, key: `porta-${person}-${place}`, text: `Porta ${item.word} ${aLloc(target.word)}!` };
  }),
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
  // L'intrús
  'intrus-animals': 'Els animals! Quin no és un animal?',
  'intrus-fruita': 'La fruita! Quina no és una fruita?',
};

for (const item of [...ANIMALS, ...FOOD, ...BODY, ...CLOTHES, ...FAMILY, ...HOME_PLACES, INTRUDERS.samarreta]) {
  KIDS_AUDIO[`w-${item.id}`] = capital(`${item.word}!`);
  KIDS_AUDIO[`on-${item.id}`] = onEs(item);
}
for (const item of ANIMALS) KIDS_AUDIO[`fa-${item.id}`] = item.sound!;
for (const item of COLORS) {
  KIDS_AUDIO[`w-${item.id}`] = capital(`${item.word}!`);
  KIDS_AUDIO[`bamb-${item.id}`] = `Explota les bambolles de color ${item.word.slice(3)}!`;
}
for (const item of EMOTIONS) KIDS_AUDIO[`emo-${item.id}`] = item.sound!;
NUMBERS.forEach((n, i) => {
  KIDS_AUDIO[`n-${i + 1}`] = capital(`${n}!`);
  KIDS_AUDIO[`dona-${i + 1}`] = `Dona-li ${counted(i + 1)} a la Taronjeta!`;
  KIDS_AUDIO[`onhiha-${i + 1}`] = i === 0 ? 'On n\'hi ha un?' : `On n'hi ha ${n}?`;
});
for (const tasks of Object.values(DRAG_TASKS)) for (const t of tasks) KIDS_AUDIO[t.key] = t.text;
for (const l of LETTERS) {
  KIDS_AUDIO[`lletra-${l.id}`] = l.say;
  KIDS_AUDIO[`w-lletra-${l.id}`] = capital(`${l.word}!`);
}

/* ── Rondes i illes ───────────────────────────────────────────────────── */

export type Round =
  | { kind: 'tap'; prompt: string; target: KidsItem; options: KidsItem[]; style?: 'cards' | 'faces'; react?: string }
  | { kind: 'odd'; prompt: string; options: KidsItem[]; target: KidsItem }
  | { kind: 'bubbles'; prompt: string; color: KidsItem; others: KidsItem[] }
  | { kind: 'count'; prompt: string; n: number }
  | { kind: 'dots'; prompt: string; n: number; options: number[] }
  | { kind: 'drag'; scene: 'plat' | 'motxilla' | 'monstre' | 'casa'; tasks: { item: KidsItem; zone: string; key: string }[] }
  | { kind: 'trace'; letter: (typeof LETTERS)[number] };

export type Island = {
  id: string;
  name: string;
  emoji: string;
  color: string;
  cromo: { emoji: string; name: string }; // el cromo que guanya qui acaba l'illa
  rounds: () => Round[]; // cada sessió es barreja de nou
};

const shuffle = <T,>(list: readonly T[]): T[] => {
  const copy = [...list];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
};
const pick = <T,>(list: readonly T[], n: number) => shuffle(list).slice(0, n);

// Ronda de «Toca i escolta»: l'objectiu i distractors del mateix grup.
const tapRound = (pool: KidsItem[], target: KidsItem, size = 3, react?: (t: KidsItem) => string): Round => ({
  kind: 'tap',
  prompt: `on-${target.id}`,
  target,
  options: shuffle([target, ...pick(pool.filter(p => p.id !== target.id), size - 1)]),
  react: react?.(target),
});

export const ISLANDS: Island[] = [
  {
    id: 'animals', name: 'Els animals', emoji: '🐶', color: '#FFD8A8',
    cromo: { emoji: '🐕', name: 'El gos' },
    rounds: () => {
      const targets = pick(ANIMALS, 4);
      return [
        ...targets.map((t, i) => tapRound(ANIMALS, t, i < 2 ? 3 : 4, a => `fa-${a.id}`)),
        { kind: 'odd', prompt: 'intrus-animals', target: INTRUDERS.samarreta, options: shuffle([...pick(ANIMALS, 3), INTRUDERS.samarreta]) },
      ];
    },
  },
  {
    id: 'colors', name: 'Els colors', emoji: '🎨', color: '#D0EBFF',
    cromo: { emoji: '🌈', name: "L'arc de Sant Martí" },
    rounds: () => pick(COLORS, 4).map(color => ({
      kind: 'bubbles', prompt: `bamb-${color.id}`, color, others: pick(COLORS.filter(c => c.id !== color.id), 3),
    }) as Round),
  },
  {
    id: 'numeros', name: 'Els números', emoji: '🔢', color: '#E5DBFF',
    cromo: { emoji: '🍬', name: 'Els caramels' },
    rounds: () => {
      const small = pick([1, 2, 3, 4, 5], 2);
      const big = pick([6, 7, 8, 9, 10], 1);
      const dots = pick([2, 3, 4, 5, 6], 2);
      return [
        ...small.map(n => ({ kind: 'count', prompt: `dona-${n}`, n }) as Round),
        ...dots.map(n => ({ kind: 'dots', prompt: `onhiha-${n}`, n, options: shuffle([n, ...pick([1, 2, 3, 4, 5, 6, 7].filter(x => x !== n), 2)]) }) as Round),
        ...big.map(n => ({ kind: 'count', prompt: `dona-${n}`, n }) as Round),
      ];
    },
  },
  {
    id: 'menjar', name: 'El menjar', emoji: '🍎', color: '#FFE3E3',
    cromo: { emoji: '🥪', name: 'El berenar' },
    rounds: () => [
      { kind: 'drag', scene: 'plat', tasks: pick(DRAG_TASKS.plat, 3) },
      tapRound(FOOD, pick(FOOD, 1)[0], 3),
      { kind: 'odd', prompt: 'intrus-fruita', target: ANIMALS[0], options: shuffle([...FOOD.filter(f => ['poma', 'platan', 'taronja'].includes(f.id)), ANIMALS[0]]) },
      { kind: 'drag', scene: 'motxilla', tasks: pick(DRAG_TASKS.motxilla, 2) },
    ],
  },
  {
    id: 'cos', name: 'El cos', emoji: '🧒', color: '#D3F9D8',
    cromo: { emoji: '👾', name: 'El monstre simpàtic' },
    rounds: () => {
      const monster = (zones: string[]): Round => ({ kind: 'drag', scene: 'monstre', tasks: DRAG_TASKS.monstre.filter(t => zones.includes(t.zone)) });
      const emotion = pick(EMOTIONS, 1)[0];
      return [
        monster(['cap', 'ulls', 'nas', 'boca']),
        monster(['braç', 'mà', 'cama', 'peu']),
        { kind: 'tap', prompt: `emo-${emotion.id}`, target: emotion, options: shuffle(EMOTIONS), style: 'faces' },
        monster(['sabates', 'barret']),
      ];
    },
  },
  {
    id: 'familia', name: 'La família', emoji: '🏠', color: '#FFF3BF',
    cromo: { emoji: '👨‍👩‍👦', name: 'La família' },
    rounds: () => [
      ...pick(FAMILY, 3).map(t => tapRound(FAMILY, t, 3)),
      { kind: 'drag', scene: 'casa', tasks: pick(DRAG_TASKS.casa, 3) },
    ],
  },
  {
    id: 'lletres', name: 'Les lletres', emoji: '✨', color: '#FCE7F3',
    cromo: { emoji: '⭐', name: "L'estrela de les lletres" },
    rounds: () => LETTERS.map(letter => ({ kind: 'trace', letter }) as Round),
  },
];

export const islandById = (id: string | undefined) => ISLANDS.find(i => i.id === id);
export const FEEDBACK_OK = ['be-1', 'be-2', 'be-3', 'be-4'];
export const FEEDBACK_RETRY = ['torna-1', 'torna-2'];
