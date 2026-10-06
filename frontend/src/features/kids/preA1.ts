/**
 * Guia Pre-A1 del Nivell 0
 * ========================
 * Lliçons a l'estil de les guies de nivell Pre-A1 (pre A1) per a xiquets, adaptades al
 * valencià: els temes i el vocabulari de Cambridge Pre A1 Starters (animals, el cos,
 * la roba, els colors, la família, el menjar, la casa, l'escola, les joguines, el
 * transport, els esports, el món que ens envolta, els llocs, el temps...), les seues
 * estructures («Què és açò? És un...», «M'agrada», «Tinc», «Hi ha», «Saps...?», «On
 * és...?», «De qui és?») i els seus tipus de tasca, fets jocs:
 *   - Escolta i uneix (Listening, part 1): una línia de cada nom a la persona.
 *   - Escolta i tria (Listening, part 3): es toca el dibuix correcte.
 *   - Escolta i pinta (Listening, part 4): es pinta cada objecte del color que diu la veu.
 *   - Mira i respon sí o no (Reading & Writing, parts 1-2).
 *   - Lletreja (Reading & Writing, part 3): les lletres desordenades.
 *   - Contes en vinyetes amb preguntes (Reading & Writing, parts 4-5).
 *   - Escolta i col·loca (activitats «At the beach» i «A day with my family»).
 *   - Cançons i rodolins («Sing and learn»), busca la diferència i «La Taronjeta diu»
 *     (el «Simon says» de les classes d'infantil), per al Speaking.
 * Els descriptors Pre-A1 del Marc europeu (MECR, volum complementari) guien el nivell:
 * frases molt curtes, molt de suport visual, repetició i salutacions bàsiques.
 *
 * Com lessons.ts, és només dades: les frases es registren amb p()/word() en carregar el
 * mòdul, i els scripts en generen l'àudio i les traduccions.
 */
import {
  ACTIONS, ANIMALS, capital, COLORS, CLOTHES, FAMILY, HOME_PLACES, memoryRound, NUMBERS, orderRound, pick, shuffle, sortRound, VEGGIES,
  type KidsItem, type PlaceScene, type Pos,
} from './content';
import {
  animal, body, chant, color, dialog, difference, discover, explain, family, food, game, intro, it, p, pairs, quiz, simonSays, spelling,
  story, summary, trueFalse, word, type Lesson, type LessonPage,
} from './lessonKit';

/* ── Peces de la guia ─────────────────────────────────────────────────── */

const colorName = (id: string) => color(id).word.replace(/^el /, '');
const PALETTE = ['roig', 'blau', 'groc', 'verd', 'taronja-color', 'rosa', 'morat', 'marro', 'gris', 'negre'].map(color);

// Els amics de la guia, amb noms valencians.
const NAMES = ['Laia', 'Pau', 'Marta', 'Joan', 'Neus', 'Biel', 'Aina', 'Vicent'] as const;
type Name = (typeof NAMES)[number];
const nameChip = (name: Name): KidsItem => ({ id: `nom-${name}`, word: name, emoji: '', glyph: name, ink: '#0F47AF', audio: word(`${name}!`) });
export const NAME_CHIPS = Object.fromEntries(NAMES.map(n => [n, nameChip(n)])) as Record<Name, KidsItem>;

/** Una persona fent alguna cosa (dibuix compost): per a «Escolta i uneix». */
const person = (emoji: string, what: string): KidsItem => ({ ...it(emoji, what), stack: [...emoji].length > 2 });

/** Escolta i pinta: cada tasca és [objecte, color]. */
const paint = (objects: KidsItem[], tasks: [KidsItem, string][]): LessonPage => {
  const list = tasks.map(([item, c]) => ({ item: item.id, color: c, key: p(`Pinta ${item.word} de ${colorName(c)}!`) }));
  return game(() => ({ kind: 'paint', objects: shuffle(objects), palette: PALETTE, tasks: list }));
};

/** Escolta i uneix: cada tasca és [nom, persona, frase que la descriu]; `extra` és una persona que sobra. */
const lines = (tasks: [Name, KidsItem, string][], extra: KidsItem): LessonPage => {
  const list = tasks.map(([name, who, text]) => ({ name: NAME_CHIPS[name].id, person: who.id, key: p(text) }));
  const names = tasks.map(([name]) => NAME_CHIPS[name]);
  const people = [...tasks.map(([, who]) => who), extra];
  return game(() => ({ kind: 'lines', names, people: shuffle(people), tasks: list }));
};

/** Mira i respon: [dibuix, frase, és veritat?]. */
const yesno = (list: [KidsItem, string, boolean][]): LessonPage => game(trueFalse(list));

/** Escolta i col·loca: [element, zona, consigna]. */
const place = (scene: PlaceScene, tasks: [KidsItem, string, string][], extra: KidsItem[] = []): LessonPage => {
  const list = tasks.map(([item, zone, text]) => ({ item: item.id, zone, key: p(text) }));
  const items = [...tasks.map(([item]) => item), ...extra];
  return game(() => ({ kind: 'place', scene, items: shuffle(items), tasks: list }));
};

/** Lletreja: les lletres (o dígrafs, com LL) de la paraula, en ordre. */
const spell = (item: KidsItem, letters: string[]): LessonPage => game(spelling(item, letters));

/** Busca la diferència: la fila i els canvis [posició, dibuix nou]. */
const diff = (row: KidsItem[], changes: [number, KidsItem][]): LessonPage => game(difference(row, changes));

/** La Taronjeta diu: [dibuix, ho diu la Taronjeta?, ordre] (vegeu simonSays). */
const simon = (options: KidsItem[], commands: [KidsItem, boolean, string?][]): LessonPage => game(simonSays(options, commands));

const SIMON_RULES = explain(
  'Juguem a «La Taronjeta diu»! Si dic «La Taronjeta diu», ho fas. Si no ho dic, no ho fas: toca la mà que diu «No ho faig!».',
  [it('🍊', 'la Taronjeta diu...', { say: 'La Taronjeta diu...' }), it('✋', 'no ho faig!', { say: 'No ho faig!' })],
);

const q = (text: string) => p(text); // consigna d'una pregunta (per a llegir-ho millor)
const sortBins = (prompt: string, bins: KidsItem[], items: [KidsItem, KidsItem][]): LessonPage =>
  game(() => sortRound(prompt, bins, items.map(([item, bin]) => ({ item, bin: bin.id }))));

const ani = (id: string) => ANIMALS.find(a => a.id === id) ?? animal(id);
const cloth = (id: string) => CLOTHES.find(c => c.id === id)!;
const home = (id: string) => HOME_PLACES.find(h => h.id === id)!;
const veg = (id: string) => VEGGIES.find(v => v.id === id)!;
const act = (id: string) => ACTIONS.find(a => a.id === `acc-${id}`)!;

/* ── Escenes d'«Escolta i col·loca» ───────────────────────────────────── */

const zone = (id: string, name: string, emoji: string, left: number, top: number, width: number, height: number, tint?: string) =>
  ({ id, label: word(`${capital(name)}!`), emoji, left, top, width, height, tint });

const SCENES = {
  platja: {
    background: 'linear-gradient(180deg, #BAE6FD 0 34%, #38BDF8 34% 62%, #FDE68A 62% 100%)',
    zones: [
      zone('cel', 'el cel', '☁️', 2, 2, 96, 30),
      zone('mar', 'el mar', '🌊', 2, 36, 96, 24),
      zone('sorra', 'la sorra', '⛱️', 2, 64, 96, 34),
    ],
  },
  casa: {
    background: 'linear-gradient(180deg, #FFF7ED, #FFEDD5)',
    zones: [
      zone('cuina', 'la cuina', '🍳', 2, 2, 47, 47, '#FEF3C7'),
      zone('salo', 'el saló', '🛋️', 51, 2, 47, 47, '#DCFCE7'),
      zone('bany', 'el bany', '🚽', 2, 51, 47, 47, '#DBEAFE'),
      zone('dormitori', 'el dormitori', '🛏️', 51, 51, 47, 47, '#FCE7F3'),
    ],
  },
  casaJardi: {
    background: 'linear-gradient(180deg, #FFF7ED, #FFEDD5)',
    zones: [
      zone('cuina', 'la cuina', '🍳', 2, 2, 47, 47, '#FEF3C7'),
      zone('salo', 'el saló', '🛋️', 51, 2, 47, 47, '#DCFCE7'),
      zone('dormitori', 'el dormitori', '🛏️', 2, 51, 47, 47, '#FCE7F3'),
      zone('jardi', 'el jardí', '🌳', 51, 51, 47, 47, '#BBF7D0'),
    ],
  },
  taula: {
    background: 'linear-gradient(180deg, #FDE7C8, #F5C99B)',
    zones: [
      zone('plat', 'el plat', '🍽️', 4, 20, 30, 60, '#FFFFFF'),
      zone('cistella', 'la cistella', '🧺', 36, 20, 28, 60, '#FEF3C7'),
      zone('got', 'el got', '🥛', 66, 20, 30, 60, '#E0F2FE'),
    ],
  },
  parc: {
    background: 'linear-gradient(180deg, #BAE6FD 0 30%, #86EFAC 30% 100%)',
    zones: [
      zone('arbre', "l'arbre", '🌳', 2, 4, 30, 56),
      zone('banc', 'el banc', '🪑', 34, 40, 30, 30),
      zone('font', 'la font', '⛲', 68, 30, 30, 36),
      zone('tobogan', 'el tobogan', '🛝', 34, 72, 64, 26),
    ],
  },
  classe: {
    background: 'linear-gradient(180deg, #F1F5F9, #E2E8F0)',
    zones: [
      zone('pissarra', 'la pissarra', '🟩', 2, 2, 62, 34, '#BBF7D0'),
      zone('prestatgeria', 'la prestatgeria', '📚', 66, 2, 32, 60, '#FDE68A'),
      zone('taula', 'la taula', '🪵', 2, 40, 62, 30, '#FED7AA'),
      zone('motxilla', 'la motxilla', '🎒', 2, 74, 96, 24, '#FECACA'),
    ],
  },
} satisfies Record<string, PlaceScene>;

/* ── Vocabulari comú ──────────────────────────────────────────────────── */

const n = (k: number, emoji = '🍎'): KidsItem => ({ id: `pa-n-${k}-${emoji}`, word: NUMBERS[k - 1] ?? `${k}`, emoji, count: k, audio: `n-${k}` });
const TEENS = ['onze', 'dotze', 'tretze', 'catorze', 'quinze', 'setze', 'dèsset', 'díhuit', 'dènou', 'vint'];
const teen = (i: number): KidsItem => ({ id: `pa-t-${i}`, word: TEENS[i], emoji: '', glyph: `${11 + i}`, ink: '#7C3AED', audio: word(`${capital(TEENS[i])}!`) });
const ORDER_PROMPT = p("Toca'ls en ordre, de menys a més!");
const candles = (k: number): KidsItem => it('🕯️', `${NUMBERS[k - 1]} anys`, { count: k });

/* ═══ 1. Hola! Qui és qui? ═══════════════════════════════════════════════ */

const comEtDius = it('🏷️', 'com et dius?', { say: 'Com et dius?' });
const quantsAnys = it('🎂', 'quants anys tens?', { say: 'Quants anys tens?' });
const comSescriu = it('🔤', "com s'escriu?", { say: "Com s'escriu?" });
const laiaLlig = person('👧📖', 'llig un llibre');
const pauFutbol = person('👦⚽', 'juga a futbol');
const martaPinta = person('👧🎨', 'pinta un dibuix');
const joanBici = person('👦🚲', 'va amb bici');
const xiquetGelat = person('🧒🍦', 'menja un gelat');

const PA1: Lesson = {
  id: 'pa1-hola', category: 'preA1', title: 'Hola! Qui és qui?', summary: 'Els noms, l\'edat i els números de l\'1 al 20.', emoji: '🙋', color: '#FFE8BA',
  say: p('Hola! Qui és qui?'),
  pages: [
    intro('🙋', 'Benvinguts a la guia Pre-A1! Hui coneixerem uns amics nous i aprendrem a dir com ens diem i quants anys tenim.'),
    discover('Estos són els nostres amics. Toca cada nom i escolta com es diu!', NAMES.slice(0, 6).map(n => NAME_CHIPS[n])),
    dialog([
      ['👧', 'Hola! Em dic Laia. I tu, com et dius?'],
      ['👦', 'Hola, Laia! Jo em dic Pau.'],
      ['👧', 'Quants anys tens, Pau?'],
      ['👦', 'Tinc sis anys. I tu?'],
      ['👧', 'Jo tinc set anys!'],
    ]),
    explain("Per a saber el nom d'algú, preguntem: Com et dius? I per a saber l'edat: Quants anys tens?", [comEtDius, quantsAnys]),
    quiz(q('Quants anys té Pau? Toca les espelmes!'), candles(6), [candles(4), candles(9)]),
    quiz(q('I Laia, quants anys té?'), candles(7), [candles(5), candles(3)]),
    discover("Comptem de l'u al deu! Toca cada grup.", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(k => n(k))),
    discover('I ara, de l\'onze al vint! Toca cada número.', TEENS.map((_, i) => teen(i))),
    game(() => orderRound(ORDER_PROMPT, pick([1, 2, 3, 4, 5, 6, 7, 8], 5).sort((a, b) => a - b).map(k => n(k, '⭐')))),
    lines([
      ['Laia', laiaLlig, 'Laia llig un llibre.'],
      ['Pau', pauFutbol, 'Pau juga a futbol.'],
      ['Marta', martaPinta, 'Marta pinta un dibuix.'],
      ['Joan', joanBici, 'Joan va amb bici.'],
    ], xiquetGelat),
    explain("I per a saber com s'escriu un nom, preguntem: Com s'escriu? Pau: P, A, U!", [comSescriu, NAME_CHIPS.Pau]),
    spell(NAME_CHIPS.Pau, ['P', 'A', 'U']),
    spell(NAME_CHIPS.Aina, ['A', 'I', 'N', 'A']),
    yesno([
      [laiaLlig, 'Laia llig un llibre.', true],
      [pauFutbol, 'Pau dorm.', false],
      [joanBici, 'Joan va amb bici.', true],
      [martaPinta, 'Marta menja un gelat.', false],
    ]),
    summary(
      "Molt bé! Ja saps preguntar: Com et dius? Quants anys tens? Com s'escriu? I ja saps comptar fins a vint!",
      [comEtDius, quantsAnys, comSescriu, NAME_CHIPS.Laia, NAME_CHIPS.Pau, teen(9)],
    ),
  ],
};

/* ═══ 2. Al zoo ═══════════════════════════════════════════════════════════ */

const tigre = it('🐅', 'el tigre');
const zebra = it('🦓', 'la zebra');
const girafa = it('🦒', 'la girafa');
const hipopotam = it('🦛', "l'hipopòtam");
const cocodril = it('🐊', 'el cocodril');
const serp = it('🐍', 'la serp');
const os = it('🐻', "l'ós");
const osPolar = it('🐻‍❄️', "l'ós polar");
const cabra = it('🐐', 'la cabra');
const aranya = it('🕷️', "l'aranya");
const sargantana = it('🦎', 'la sargantana');
const queEs = it('❓', 'què és açò?', { say: 'Què és açò?' });
const magrada = it('👍', "m'agrada", { say: "M'agrada!" });
const noMagrada = it('👎', "no m'agrada", { say: "No m'agrada!" });
const granja = it('🐄🐖', 'la granja', { stack: true });
const zoo = it('🦁🦒', 'el zoo', { stack: true });

const ZOO = [ani('lleo'), tigre, zebra, girafa, ani('elefant'), hipopotam, cocodril, ani('mona'), serp, os, osPolar];

const PA2: Lesson = {
  id: 'pa2-zoo', category: 'preA1', title: 'Al zoo', summary: 'Els animals, «Què és açò?» i «M\'agrada».', emoji: '🦁', color: '#FFD8A8',
  say: p('Al zoo!'),
  pages: [
    intro('🦁', 'Hui anem al zoo! Hi ha animals grans, xicotets, ràpids i lents. Escolta i descobrix-los!'),
    discover('Els animals del zoo! Toca cada un i escolta el seu nom.', ZOO),
    discover('I estos viuen a la granja. Toca i escolta!', [ani('vaca'), ani('cavall'), ani('ovella'), ani('gallina'), ani('anec'), cabra, ani('porc')]),
    discover('I estos són xicotets, xicotets! Toca i escolta.', [animal('abella'), aranya, sargantana, ani('ratoli'), ani('granota'), ani('ocell'), ani('peix')]),
    chant([
      ['🦁', 'Al zoo, al zoo, anem tots al zoo!'],
      ['🦒', 'La girafa és molt alta i té el coll llarg.'],
      ['🐘', "L'elefant és molt gran i té la trompa llarga."],
      ['🐒', 'La mona salta i salta, de branca en branca!'],
      ['🐍', 'La serp fa sss, sss, i no té cames.'],
      ['🦁', 'Al zoo, al zoo, anem tots al zoo!'],
    ]),
    explain('Per a preguntar què és una cosa, diem: Què és açò? I contestem: És un tigre! És una zebra!', [queEs, tigre, zebra]),
    yesno([
      [tigre, 'És un tigre.', true],
      [hipopotam, 'És un cocodril.', false],
      [girafa, 'És una girafa.', true],
      [serp, 'És una aranya.', false],
      [osPolar, 'És un ós polar.', true],
    ]),
    explain("Per a dir el que ens agrada, diem: M'agrada! I si no ens agrada: No m'agrada!", [magrada, noMagrada]),
    dialog([
      ['👦', 'Mira, Laia! Què és açò?'],
      ['👧', 'És un cocodril! Té moltes dents!'],
      ['👦', "M'agraden els cocodrils!"],
      ['👧', "A mi no m'agraden. M'agraden les girafes!"],
    ]),
    quiz(q("A Laia, quin animal li agrada?"), girafa, [cocodril, serp]),
    quiz(q('Quin animal fa sss, sss?'), serp, [ani('gat'), ani('vaca')]),
    sortBins(p('On viu cada animal? A la granja o al zoo?'), [granja, zoo], [
      [ani('vaca'), granja], [ani('porc'), granja], [cabra, granja], [ani('gallina'), granja],
      [ani('lleo'), zoo], [girafa, zoo], [zebra, zoo], [hipopotam, zoo],
    ]),
    diff([ani('lleo'), ani('elefant'), girafa, ani('mona'), zebra], [[2, tigre]]),
    game(() => memoryRound(ZOO, 4)),
    summary('Molt bé! Ja coneixes molts animals del zoo i de la granja. I saps preguntar: Què és açò?', [...ZOO.slice(0, 8), magrada, noMagrada]),
  ],
};

/* ═══ 3. El cos i la cara ═════════════════════════════════════════════════ */

const cara = it('🙂', 'la cara');
const cabells = it('💇', 'els cabells');
const somriure = it('😁', 'el somriure');
const cos = it('🧍', 'el cos');
const peus = it('🦶', 'els peus', { count: 2 });
const mans = it('✋', 'les mans', { count: 2 });

const PA3: Lesson = {
  id: 'pa3-cos', category: 'preA1', title: 'El cos i la cara', summary: 'Les parts del cos, «Tinc...» i «La Taronjeta diu».', emoji: '🙂', color: '#D3F9D8',
  say: p('El cos i la cara!'),
  pages: [
    intro('🙂', "Hui coneixerem la cara i el cos. Mira't a l'espill i toca cada part del teu cos!"),
    discover('Primer, la cara! Toca i escolta.', [cara, body('ulls'), body('nas'), body('boca'), body('orelles'), cabells, somriure]),
    discover('Ara, el cos! Toca i escolta.', [cos, { ...body('cap'), emoji: '🧑' }, body('braç'), mans, body('cama'), peus, body('dit')]),
    explain('Per a dir les parts del cos, diem: Tinc dos ulls, un nas i una boca. Tinc dues mans i dos peus!', [body('ulls'), body('nas'), body('boca'), mans, peus]),
    chant([
      ['🧑', 'Cap, espatlles, genolls i peus, genolls i peus!'],
      ['🧑', 'Cap, espatlles, genolls i peus, genolls i peus!'],
      ['👀', 'Ulls, orelles, boca i nas!'],
      ['🧑', 'Cap, espatlles, genolls i peus, genolls i peus!'],
    ]),
    SIMON_RULES,
    simon([body('nas'), body('boca'), body('orelles'), body('ulls'), body('mà'), body('peu')], [
      [body('nas'), true], [body('boca'), false], [body('orelles'), true], [body('ulls'), true], [body('peu'), false], [body('mà'), true],
    ]),
    paint([body('ulls'), body('nas'), body('boca'), body('orelles'), cabells], [
      [body('nas'), 'roig'], [cabells, 'groc'], [body('ulls'), 'blau'], [body('boca'), 'rosa'],
    ]),
    yesno([
      [body('ulls'), 'Són les orelles.', false],
      [body('peu'), 'És el peu.', true],
      [body('boca'), 'És la boca.', true],
      [body('nas'), 'És la mà.', false],
    ]),
    spell(body('nas'), ['N', 'A', 'S']),
    spell(body('peu'), ['P', 'E', 'U']),
    quiz(q('Amb què somriem?'), body('boca'), [body('peu'), body('orelles')], { picture: '😁' }),
    quiz(q('Què et pentines cada matí?'), cabells, [body('nas'), body('dit')], { picture: '🪮' }),
    summary('Molt bé! Ja saps les parts de la cara i del cos. I has jugat a «La Taronjeta diu»!', [cara, body('ulls'), body('nas'), body('boca'), body('orelles'), cabells, body('braç'), mans, body('cama'), peus]),
  ],
};

/* ═══ 4. La roba ══════════════════════════════════════════════════════════ */

const pantalonsCurts = it('🩳', 'els pantalons curts');
const vestit = it('👗', 'el vestit');
const camisa = it('👔', 'la camisa');
const gorra = it('🧢', 'la gorra');
const botes = it('🥾', 'les botes');
const motxilla = it('🎒', 'la motxilla');
const bolso = it('👜', 'el bolso');
const barretSol = it('👒', 'el barret');
const bufanda = cloth('bufanda');
const porte = it('🧍', 'porte', { say: 'Jo porte una samarreta!' });
const fred = it('🥶', 'fa fred');
const calor = it('🥵', 'fa calor');
const ROBA = [cloth('samarreta'), cloth('pantalons'), pantalonsCurts, vestit, camisa, cloth('jaqueta'), barretSol, gorra, cloth('sabates'), botes, cloth('calcetins'), cloth('ulleres'), bufanda, cloth('guants')];

const PA4: Lesson = {
  id: 'pa4-roba', category: 'preA1', title: 'La roba', summary: 'La roba, «porte...» i què ens posem quan fa fred o calor.', emoji: '👕', color: '#E5DBFF',
  say: p('La roba!'),
  pages: [
    intro('👕', 'Què portes hui? Anem a conéixer la roba que ens posem cada dia!'),
    discover('Toca cada peça de roba i escolta el seu nom!', ROBA.slice(0, 7)),
    discover("Encara n'hi ha més! Toca i escolta.", [...ROBA.slice(7), motxilla, bolso]),
    explain('Per a dir la roba que tenim posada, diem: porte. Jo porte una samarreta! Laia porta un vestit.', [porte, cloth('samarreta'), vestit]),
    lines([
      ['Laia', person('👧👗', 'porta un vestit'), 'Laia porta un vestit.'],
      ['Pau', person('👦🧢', 'porta una gorra'), 'Pau porta una gorra.'],
      ['Marta', person('👧🥾', 'porta botes'), 'Marta porta botes.'],
      ['Joan', person('👦👓', 'porta ulleres'), 'Joan porta ulleres.'],
    ], person('🧒🧣', 'porta una bufanda')),
    paint([cloth('samarreta'), cloth('pantalons'), gorra, cloth('sabates'), cloth('jaqueta')], [
      [cloth('samarreta'), 'verd'], [cloth('pantalons'), 'blau'], [gorra, 'roig'], [cloth('sabates'), 'negre'],
    ]),
    explain('Quan fa fred, portem jaqueta, botes, bufanda i guants. Quan fa calor, portem pantalons curts i gorra!', [fred, cloth('jaqueta'), bufanda, calor, pantalonsCurts, gorra]),
    sortBins(p('Què ens posem? Quan fa fred, o quan fa calor?'), [fred, calor], [
      [cloth('jaqueta'), fred], [botes, fred], [bufanda, fred], [cloth('guants'), fred],
      [pantalonsCurts, calor], [gorra, calor], [cloth('ulleres'), calor],
    ]),
    dialog([
      ['👩', 'Pau, fa fred! Posa\'t la jaqueta!'],
      ['👦', 'I la gorra també?'],
      ['👩', 'No, la gorra no. Posa\'t la bufanda i els guants!'],
      ['👦', "D'acord, mama!"],
    ]),
    quiz(q('Què li diu la mare a Pau que es pose?'), cloth('jaqueta'), [pantalonsCurts, gorra]),
    yesno([
      [vestit, 'És un vestit.', true],
      [cloth('calcetins'), 'Són unes sabates.', false],
      [gorra, 'És una gorra.', true],
      [botes, 'És una camisa.', false],
    ]),
    diff([cloth('samarreta'), cloth('pantalons'), gorra, cloth('sabates'), cloth('jaqueta')], [[1, pantalonsCurts], [4, bufanda]]),
    summary('Molt bé! Ja coneixes la roba. I saps dir: jo porte una samarreta!', ROBA.slice(0, 10)),
  ],
};

/* ═══ 5. Els colors del món ═══════════════════════════════════════════════ */

const pilota = it('⚽', 'la pilota');
const globus = it('🎈', 'el globus');
const cotxe = it('🚗', 'el cotxe');
const estrela = it('⭐', "l'estrela");
const flor = it('🌸', 'la flor');
const deQuin = it('🎨', 'de quin color és?', { say: 'De quin color és?' });
const arcSantMarti = it('🌈', "l'arc de Sant Martí");

const PA5: Lesson = {
  id: 'pa5-colors', category: 'preA1', title: 'Els colors del món', summary: '«De quin color és?» i «Escolta i pinta».', emoji: '🎨', color: '#D0EBFF',
  say: p('Els colors del món!'),
  pages: [
    intro('🎨', 'El món està ple de colors! Hui escoltarem i pintarem, com els pintors.'),
    discover('Toca cada color i escolta el seu nom!', COLORS),
    explain('Per a preguntar el color, diem: De quin color és? I contestem: És roig! És blau!', [deQuin, color('roig'), color('blau')]),
    chant([
      ['🌈', "Roig, taronja, groc i verd, l'arc de Sant Martí!"],
      ['🌈', 'Blau i morat, i ja està: quin arc més bonic!'],
      ['☀️', 'Quan plou i fa sol alhora, mira cap al cel!'],
      ['🌈', "Roig, taronja, groc i verd, l'arc de Sant Martí!"],
    ]),
    explain('Ara jugarem a «Escolta i pinta». Primer, toca un color. Després, toca el dibuix que diu la veu!', [color('roig'), pilota]),
    paint([pilota, globus, cotxe, estrela, flor], [
      [pilota, 'blau'], [globus, 'roig'], [estrela, 'groc'], [flor, 'rosa'], [cotxe, 'verd'],
    ]),
    quiz('dequin-poma', color('roig'), [color('blau'), color('verd')], { picture: '🍎' }),
    quiz('dequin-granota', color('verd'), [color('groc'), color('rosa')], { picture: '🐸' }),
    quiz('dequin-elefant', color('gris'), [color('morat'), color('taronja-color')], { picture: '🐘' }),
    yesno([
      [ani('granota'), 'La granota és verda.', true],
      [food('platan'), 'El plàtan és blau.', false],
      [it('☁️', 'el núvol'), 'El núvol és blanc.', true],
      [food('maduixa'), 'La maduixa és groga.', false],
    ]),
    paint([food('poma'), food('platan'), food('raim'), food('taronja'), food('pera')], [
      [food('platan'), 'groc'], [food('raim'), 'morat'], [food('poma'), 'roig'], [food('pera'), 'verd'],
    ]),
    game(() => memoryRound(COLORS, 4)),
    summary("Molt bé! Ja saps preguntar: De quin color és? I has pintat com un artista. Mira l'arc de Sant Martí!", [arcSantMarti, ...COLORS]),
  ],
};

/* ═══ 6. La família i els amics ═══════════════════════════════════════════ */

const cosi = it('🧑‍🦱', 'el cosí');
const cosina = it('👱‍♀️', 'la cosina');
const amic = it('🧑‍🤝‍🧑', "l'amic");
const company = it('🏫', 'el company de classe');
const home_ = it('👨', "l'home");
const dona = it('👩', 'la dona');
const xiquet = it('👦', 'el xiquet');
const xiqueta = it('👧', 'la xiqueta');
const jove = it('🧒', 'jove');
const vell = it('👴', 'vell');
const esteEs = it('👨', 'este és el meu pare', { say: 'Este és el meu pare!' });
const estaEs = it('👩', 'esta és la meua mare', { say: 'Esta és la meua mare!' });
const autobus = it('🚌', "l'autobús");
const bici = it('🚲', 'la bici');

const PA6: Lesson = {
  id: 'pa6-familia', category: 'preA1', title: 'La família i els amics', summary: '«Este és el meu...» i un dia amb la família.', emoji: '👨‍👩‍👧', color: '#FFF3BF',
  say: p('La família i els amics!'),
  pages: [
    intro('👨‍👩‍👧', 'Hui coneixerem la família i els amics de Laia. Vols vindre?'),
    discover('La família! Toca i escolta.', [...FAMILY, cosi, cosina]),
    discover('I altres persones que coneixem! Toca i escolta.', [amic, company, xiquet, xiqueta, home_, dona]),
    explain('Per a presentar la família, diem: Este és el meu pare. Esta és la meua mare.', [esteEs, estaEs]),
    pairs('Mira: jove i vell són contraris. El xiquet és jove. El iaio és vell.', [[jove, vell]]),
    story([
      ['🌅🥣', 'Pel matí, Laia esmorza amb tota la família a la cuina.'],
      ['🚌🏫', "Després, va a l'escola amb autobús amb el seu germà."],
      ['🛝⚽', 'Per la vesprada, juga al parc amb la seua amiga Marta.'],
      ['🍝👵', 'Per la nit, sopen, i la iaia els conta un conte.'],
      ['🛏️🌙', 'I després, a dormir! Bona nit, Laia!'],
    ]),
    quiz(q("Amb què va Laia a l'escola?"), autobus, [bici, cotxe]),
    quiz(q('Qui conta un conte per la nit?'), family('iaia'), [family('pare'), family('germà')]),
    quiz(q('Amb qui juga Laia al parc?'), xiqueta, [vell, family('bebe')]),
    place(SCENES.casaJardi, [
      [family('iaia'), 'jardi', 'Posa la iaia al jardí!'],
      [family('pare'), 'cuina', 'Posa el pare a la cuina!'],
      [family('bebe'), 'dormitori', 'Posa el bebé al dormitori!'],
      [ani('gos'), 'salo', 'Posa el gos al saló!'],
    ], [family('mare')]),
    yesno([
      [family('iaio'), 'És el iaio.', true],
      [family('bebe'), 'És la mare.', false],
      [xiqueta, 'És una xiqueta.', true],
      [vell, 'És jove.', false],
    ]),
    game(() => memoryRound([...FAMILY, cosi, cosina], 4)),
    summary('Molt bé! Ja saps presentar la família: este és el meu pare, esta és la meua mare!', [...FAMILY, amic, cosi, cosina]),
  ],
};

/* ═══ 7. El menjar i la beguda ════════════════════════════════════════════ */

const pinya = it('🍍', 'la pinya');
const coco = it('🥥', 'el coco');
const mango = it('🥭', 'el mango');
const kiwi = it('🥝', 'el kiwi');
const llimona = it('🍋', 'la llimona');
const pollastre = it('🍗', 'el pollastre');
const carn = it('🥩', 'la carn');
const arros = it('🍚', "l'arròs");
const fregides = it('🍟', 'les creïlles fregides');
const hamburguesa = it('🍔', "l'hamburguesa");
const salsitxa = it('🌭', 'la salsitxa');
const pastis = it('🎂', 'el pastís');
const xocolata = it('🍫', 'la xocolata');
const caramels = it('🍬', 'els caramels');
const mongetes = it('🫘', 'les mongetes');
const suc = it('🧃', 'el suc');
const llimonada = it('🍹', 'la llimonada');
const esmorzar = it('🥣', "l'esmorzar");
const dinar = it('🍲', 'el dinar');
const berenar = it('🥪', 'el berenar');
const sopar = it('🍝', 'el sopar');
const dolc = it('🍰', 'dolç');
const salat = it('🧂', 'salat');
const vull = it('🙋', 'vull..., per favor', { say: 'Vull un suc, per favor!' });

const PA7: Lesson = {
  id: 'pa7-menjar', category: 'preA1', title: 'El menjar i la beguda', summary: '«M\'agrada», «Vull..., per favor» i «On és...?».', emoji: '🍽️', color: '#FFE3E3',
  say: p('El menjar i la beguda!'),
  pages: [
    intro('🍽️', 'Tens fam? Hui parlarem del menjar i de la beguda. Mmm, quina fam!'),
    discover('La fruita! Toca i escolta.', [food('poma'), food('platan'), food('taronja'), food('pera'), food('raim'), food('maduixa'), food('sindria'), pinya, coco, mango, kiwi, llimona]),
    discover('Més menjar! Toca i escolta.', [food('pa'), food('ou'), food('formatge'), pollastre, carn, arros, fregides, hamburguesa, salsitxa, mongetes, food('pastanaga'), food('tomaca')]),
    discover('Les coses dolces i les begudes! Toca i escolta.', [pastis, xocolata, caramels, food('gelat'), food('galeta'), food('aigua'), food('llet'), suc, llimonada]),
    explain('Cada dia fem quatre menjars: l\'esmorzar, el dinar, el berenar i el sopar.', [esmorzar, dinar, berenar, sopar]),
    explain("Per a dir el que ens agrada, diem: M'agrada el gelat! No m'agrada la ceba!", [magrada, food('gelat'), noMagrada, veg('ceba')]),
    explain('I per a demanar alguna cosa, diem: Vull un suc, per favor!', [vull, suc]),
    dialog([
      ['👦', 'Tinc fam! Què hi ha per a dinar?'],
      ['👩', 'Hi ha arròs i pollastre.'],
      ['👦', "Mmm, m'agrada l'arròs! I de postres?"],
      ['👩', 'Una poma o un plàtan.'],
      ['👦', 'Un plàtan, per favor!'],
    ]),
    quiz(q('Què hi ha per a dinar?'), arros, [hamburguesa, food('pa')]),
    quiz(q('Què vol Pau de postres?'), food('platan'), [food('poma'), pastis]),
    place(SCENES.taula, [
      [food('poma'), 'cistella', 'Posa la poma a la cistella!'],
      [food('pa'), 'plat', 'Posa el pa al plat!'],
      [food('llet'), 'got', 'Posa la llet al got!'],
      [food('platan'), 'cistella', 'Posa el plàtan a la cistella!'],
      [food('formatge'), 'plat', 'Posa el formatge al plat!'],
    ], [food('ou')]),
    quiz('on-gelat', food('gelat'), [food('galeta'), xocolata]),
    sortBins(p('És dolç o és salat?'), [dolc, salat], [
      [food('gelat'), dolc], [xocolata, dolc], [pastis, dolc], [caramels, dolc],
      [food('formatge'), salat], [fregides, salat], [salsitxa, salat],
    ]),
    yesno([
      [hamburguesa, 'És una hamburguesa.', true],
      [food('pastanaga'), 'És una ceba.', false],
      [food('formatge'), 'És formatge.', true],
      [arros, 'És pa.', false],
    ]),
    spell(food('pa'), ['P', 'A']),
    spell(food('poma'), ['P', 'O', 'M', 'A']),
    summary("Molt bé! Ja saps molts menjars i begudes. I saps dir: M'agrada! I: Vull un suc, per favor!", [food('poma'), pinya, food('pa'), arros, pastis, suc, esmorzar, dinar, sopar]),
  ],
};

/* ═══ 8. La meua casa ═════════════════════════════════════════════════════ */

const saloSofa = it('🛋️', 'el saló');
const bany = it('🚽', 'el bany');
const dormitori = it('🛏️', 'el dormitori');
const menjador = it('🍽️', 'el menjador');
const jardi = it('🌷', 'el jardí');
const llit = home('llit');
const sofa = home('sofa');
const butaca = it('💺', 'la butaca');
const taula = it('🪵', 'la taula');
const cadira = it('🪑', 'la cadira');
const armari = it('🗄️', "l'armari");
const espill = it('🪞', "l'espill");
const llum = it('💡', 'el llum');
const tele = it('📺', 'la televisió');
const ordinador = it('💻', "l'ordinador");
const telefon = it('📞', 'el telèfon');
const rellotge = it('🕰️', 'el rellotge');
const finestra = it('🪟', 'la finestra');
const quadre = it('🖼️', 'el quadre');
const prestatgeria = it('📚', 'la prestatgeria');
const caixa = it('📦', 'la caixa');
const osset = it('🧸', "l'osset de peluix");
const hiHa = it('👉', 'hi ha', { say: 'Hi ha!' });

const PA8: Lesson = {
  id: 'pa8-casa', category: 'preA1', title: 'La meua casa', summary: 'Les habitacions, els mobles i «Hi ha...».', emoji: '🏠', color: '#FFEDD5',
  say: p('La meua casa!'),
  pages: [
    intro('🏠', 'Benvinguts a casa meua! Anem a visitar cada habitació. Passa, passa!'),
    discover('Les habitacions de la casa! Toca i escolta.', [home('cuina'), saloSofa, menjador, bany, dormitori, jardi]),
    discover('Els mobles! Toca i escolta.', [llit, sofa, butaca, taula, cadira, armari, espill, prestatgeria]),
    discover('I més coses de casa! Toca i escolta.', [llum, tele, ordinador, telefon, rellotge, home('porta'), finestra, quadre, caixa, osset]),
    explain('Per a dir les coses que trobem, diem: Hi ha. A la cuina hi ha una taula i quatre cadires!', [hiHa, taula, cadira]),
    place(SCENES.casa, [
      [llit, 'dormitori', 'Posa el llit al dormitori!'],
      [sofa, 'salo', 'Posa el sofà al saló!'],
      [home('banyera'), 'bany', 'Posa la banyera al bany!'],
      [tele, 'salo', 'Posa la televisió al saló!'],
      [food('llet'), 'cuina', 'Posa la llet a la cuina!'],
    ], [osset]),
    quiz(q('On dorms?'), dormitori, [home('cuina'), bany]),
    quiz(q('On fem el menjar?'), home('cuina'), [dormitori, jardi]),
    quiz(q('On et rentes les dents?'), bany, [saloSofa, jardi]),
    yesno([
      [sofa, 'Açò és un sofà.', true],
      [espill, 'Açò és una finestra.', false],
      [llum, 'Açò és un llum.', true],
      [rellotge, 'Açò és un telèfon.', false],
    ]),
    dialog([
      ['👧', 'Pau, què hi ha al teu dormitori?'],
      ['👦', 'Hi ha un llit, un armari i moltes joguines.'],
      ['👧', 'I hi ha televisió?'],
      ['👦', "No, la televisió és al saló, al costat del sofà."],
    ]),
    quiz(q('On és la televisió de Pau?'), saloSofa, [dormitori, bany]),
    diff([llit, cadira, llum, quadre, osset], [[3, rellotge]]),
    game(() => memoryRound([llit, sofa, cadira, llum, tele, rellotge, finestra], 4)),
    summary('Molt bé! Ja coneixes la casa: la cuina, el saló, el bany, el dormitori i el jardí. I saps dir: hi ha!', [home('cuina'), saloSofa, bany, dormitori, jardi, llit, sofa, taula, cadira]),
  ],
};

/* ═══ 9. A l'escola ═══════════════════════════════════════════════════════ */

const llibre = it('📕', 'el llibre');
const quadern = it('📓', 'el quadern');
const llapis = it('✏️', 'el llapis');
const boli = it('🖊️', 'el bolígraf');
const ceres = it('🖍️', 'les ceres');
const regle = it('📏', 'el regle');
const tisores = it('✂️', 'les tisores');
const paper = it('📄', 'el paper');
const mestra = it('🧑‍🏫', 'la mestra');
const escolta = it('👂', 'escolta');
const mira = it('👀', 'mira');
const llig = it('📖', 'llig');
const escriu = it('✍️', 'escriu');
const dibuixa = it('🖼️', 'dibuixa');
const pinta = it('🎨', 'pinta');
const seu = it('💺', 'seu');
const alcat = it('🧍', "alça't");
const alcaMa = it('🙋', 'alça la mà');
const silenci = it('🤫', 'silenci');
const llibreLL: KidsItem = { ...llibre, id: 'pa-llibre' };
const ESCOLA = [llibre, quadern, llapis, boli, ceres, regle, tisores, paper, motxilla, cadira, ordinador, mestra];

const PA9: Lesson = {
  id: 'pa9-escola', category: 'preA1', title: "A l'escola", summary: 'Les coses de classe i les ordres de la mestra.', emoji: '🏫', color: '#C5F6FA',
  say: p("A l'escola!"),
  pages: [
    intro('🏫', "Bon dia, classe! Hui coneixerem les coses de l'escola i el que ens diu la mestra."),
    discover('Les coses de classe! Toca i escolta.', ESCOLA),
    discover('La mestra ens diu què hem de fer. Toca i escolta!', [escolta, mira, llig, escriu, dibuixa, pinta, seu, alcat, alcaMa, silenci]),
    dialog([
      ['🧑‍🏫', 'Bon dia, classe! Obriu el llibre, per favor.'],
      ['👦', 'Mestra, no tinc llapis!'],
      ['🧑‍🏫', 'Té, ací tens un llapis.'],
      ['👦', 'Gràcies, mestra!'],
      ['🧑‍🏫', 'De res! Ara, escriviu el vostre nom.'],
    ]),
    quiz(q('Què no té Pau?'), llapis, [llibre, motxilla]),
    lines([
      ['Laia', person('👧✍️', 'escriu'), 'Laia escriu el seu nom.'],
      ['Pau', person('👦📖', 'llig'), 'Pau llig un llibre.'],
      ['Marta', person('👧✂️', 'retalla'), 'Marta retalla un paper amb les tisores.'],
      ['Joan', person('👦🙋', 'alça la mà'), 'Joan alça la mà.'],
    ], person('🧒🎨', 'pinta')),
    SIMON_RULES,
    simon([llibre, llapis, motxilla, regle, ceres, tisores], [
      [llapis, true], [motxilla, false], [regle, true], [ceres, true], [llibre, false], [tisores, true],
    ]),
    paint([llapis, regle, motxilla, llibre, tisores], [
      [llapis, 'groc'], [motxilla, 'roig'], [llibre, 'blau'], [regle, 'verd'],
    ]),
    quiz(q('Amb què retallem el paper?'), tisores, [regle, ceres]),
    quiz(q('Amb què fem una línia recta?'), regle, [tisores, paper]),
    quiz(q('On guardem els llibres per a anar a casa?'), motxilla, [cadira, ordinador]),
    place(SCENES.classe, [
      [llibre, 'prestatgeria', 'Posa el llibre a la prestatgeria!'],
      [llapis, 'taula', 'Posa el llapis damunt de la taula!'],
      [quadern, 'motxilla', 'Posa el quadern dins de la motxilla!'],
      [it('🔤', 'les lletres'), 'pissarra', 'Posa les lletres a la pissarra!'],
    ], [tisores]),
    spell(llibreLL, ['LL', 'I', 'B', 'R', 'E']),
    summary("Molt bé! Ja saps les coses de l'escola. I quan la mestra diu: escolta, mira, llig, escriu!, ja saps què has de fer.", [...ESCOLA.slice(0, 8), escolta, mira, llig, escriu]),
  ],
};

/* ═══ 10. Les joguines ════════════════════════════════════════════════════ */

const jocTaula = it('🎲', 'el joc de taula');
const vaixell = it('⛵', 'el vaixell');
const nina = it('🪆', 'la nina');
const helicopter = it('🚁', "l'helicòpter");
const camio = it('🚚', 'el camió');
const monstre = it('👾', 'el monstre');
const moto = it('🏍️', 'la moto');
const avio = it('✈️', "l'avió");
const robot = it('🤖', 'el robot');
const tren = it('🚂', 'el tren');
const milotxa = it('🪁', 'la milotxa');
const extraterrestre = it('👽', "l'extraterrestre");
const tinc = it('🙌', 'tinc', { say: 'Tinc un robot!' });
const noTinc = it('🤷', 'no tinc', { say: 'No tinc cap milotxa!' });
const deQui = it('❓', 'de qui és?', { say: 'De qui és?' });
const dins = it('🏠', 'dins de casa');
const fora = it('🌳', 'fora de casa');
const JOGUINES = [pilota, globus, bici, jocTaula, vaixell, cotxe, nina, helicopter, camio, monstre, moto, avio, robot, osset, tren, milotxa, extraterrestre];

const PA10: Lesson = {
  id: 'pa10-joguines', category: 'preA1', title: 'Les joguines', summary: '«Tinc...», «No tinc...» i «De qui és?».', emoji: '🧸', color: '#FCE7F3',
  say: p('Les joguines!'),
  pages: [
    intro('🧸', 'A tots ens agrada jugar! Hui coneixerem moltes joguines.'),
    discover('Toca cada joguina i escolta el seu nom!', JOGUINES.slice(0, 9)),
    discover("Encara n'hi ha més! Toca i escolta.", JOGUINES.slice(9)),
    explain('Per a dir les coses que són nostres, diem: Tinc un robot! I si no en tenim: No tinc cap milotxa!', [tinc, robot, noTinc, milotxa]),
    explain('Per a saber de qui és una cosa, preguntem: De qui és? I contestem: És de Laia! És meu!', [deQui, nina]),
    lines([
      ['Laia', person('👧🪁', 'té una milotxa'), 'Laia té una milotxa.'],
      ['Pau', person('👦🤖', 'té un robot'), 'Pau té un robot.'],
      ['Marta', person('👧🪆', 'té una nina'), 'Marta té una nina.'],
      ['Joan', person('👦🚂', 'té un tren'), 'Joan té un tren.'],
    ], person('🧒🎈', 'té un globus')),
    quiz(q('De qui és el robot?'), NAME_CHIPS.Pau, [NAME_CHIPS.Laia, NAME_CHIPS.Marta]),
    paint([robot, cotxe, globus, avio, milotxa], [
      [robot, 'gris'], [cotxe, 'roig'], [globus, 'groc'], [avio, 'blau'], [milotxa, 'verd'],
    ]),
    chant([
      ['🤖', 'Tinc un robot que fa bip, bip, bip!'],
      ['🚂', 'Tinc un tren que fa xu, xu, xu!'],
      ['✈️', 'Tinc un avió que fa rum, rum, rum!'],
      ['⚽', 'I una pilota que bota, bota, bota!'],
    ]),
    quiz(q('Quina joguina fa xu, xu?'), tren, [avio, robot]),
    sortBins(p('On juguem? Dins de casa, o fora de casa?'), [dins, fora], [
      [jocTaula, dins], [nina, dins], [osset, dins], [robot, dins],
      [bici, fora], [milotxa, fora], [pilota, fora],
    ]),
    yesno([
      [helicopter, 'És un helicòpter.', true],
      [tren, 'És un vaixell.', false],
      [extraterrestre, 'És un extraterrestre.', true],
      [nina, 'És un camió.', false],
    ]),
    diff([pilota, robot, nina, tren, globus], [[1, monstre], [3, camio]]),
    spell(robot, ['R', 'O', 'B', 'O', 'T']),
    summary('Molt bé! Ja coneixes moltes joguines. I saps dir: tinc un robot! De qui és?', JOGUINES.slice(0, 12)),
  ],
};

/* ═══ 11. El transport ════════════════════════════════════════════════════ */

const trenRapid = it('🚆', 'el tren');
const vaixellGran = it('🚢', 'el vaixell');
const tractor = it('🚜', 'el tractor');
const aPeu = it('🚶', 'a peu');
const cel = it('☁️', 'pel cel');
const terra = it('🛣️', 'per terra');
const mar = it('🌊', 'pel mar');
const vaig = it('🧒', 'vaig amb...', { say: "Vaig a l'escola amb bici!" });
const TRANSPORT = [cotxe, autobus, trenRapid, bici, moto, camio, avio, helicopter, vaixellGran, tractor, aPeu];

const PA11: Lesson = {
  id: 'pa11-transport', category: 'preA1', title: 'El transport', summary: 'Els vehicles i «Com vas a l\'escola?».', emoji: '🚌', color: '#D0EBFF',
  say: p('El transport!'),
  pages: [
    intro('🚌', 'Pi, pi! Hui coneixerem cotxes, trens, avions i vaixells. Puja, que ens n\'anem!'),
    discover('Toca cada vehicle i escolta el seu nom!', TRANSPORT),
    explain('Els cotxes i els autobusos van per terra. Els avions volen pel cel. I els vaixells naveguen pel mar!', [cotxe, avio, vaixellGran]),
    sortBins(p('Per on va? Pel cel, per terra o pel mar?'), [cel, terra, mar], [
      [avio, cel], [helicopter, cel], [cotxe, terra], [autobus, terra], [trenRapid, terra], [bici, terra], [vaixellGran, mar],
    ]),
    explain("Per a dir com anem a un lloc, diem: Vaig a l'escola amb bici. Vaig amb autobús. O: Vaig a peu!", [vaig, bici, autobus, aPeu]),
    dialog([
      ['👦', "Laia, com vas a l'escola?"],
      ['👧', 'Vaig amb bici. I tu?'],
      ['👦', 'Jo vaig amb autobús, amb el meu germà.'],
      ['👧', 'I la mestra?'],
      ['👦', 'La mestra va a peu!'],
    ]),
    quiz(q("Com va Laia a l'escola?"), bici, [autobus, cotxe]),
    quiz(q("Com va Pau a l'escola?"), autobus, [trenRapid, aPeu]),
    quiz(q("Com va la mestra a l'escola?"), aPeu, [moto, bici]),
    lines([
      ['Laia', person('👧🚲', 'va amb bici'), 'Laia va amb bici.'],
      ['Pau', person('👦🚌', 'va amb autobús'), 'Pau va amb autobús.'],
      ['Marta', person('👧✈️', 'viatja amb avió'), 'Marta viatja amb avió.'],
      ['Joan', person('👦🚆', 'va amb tren'), 'Joan va amb tren.'],
    ], person('🧒🚢', 'va amb vaixell')),
    yesno([
      [tractor, 'És un tractor.', true],
      [helicopter, 'És un avió.', false],
      [camio, 'És un camió.', true],
      [moto, 'És una bici.', false],
    ]),
    spell(it('🚆', 'el tren', { id: 'pa-tren' }), ['T', 'R', 'E', 'N']),
    spell(moto, ['M', 'O', 'T', 'O']),
    diff([cotxe, autobus, trenRapid, avio, vaixellGran], [[0, tractor]]),
    summary("Molt bé! Ja coneixes el transport. I saps dir: vaig a l'escola amb bici!", TRANSPORT),
  ],
};

/* ═══ 12. Esports i jocs ══════════════════════════════════════════════════ */

const futbol = it('⚽', 'el futbol');
const basquet = it('🏀', 'el bàsquet');
const tennis = it('🎾', 'el tennis');
const pingpong = it('🏓', 'el tennis de taula');
const beisbol = it('⚾', 'el beisbol');
const badminton = it('🏸', 'el bàdminton');
const hoquei = it('🏑', "l'hoquei");
const monopati = it('🛹', 'el monopatí');
const xutar = it('🦵', 'xutar');
const llancar = it('🤾', 'llançar');
const pescar = it('🎣', 'pescar');
const foto = it('📸', 'fer fotos');
const guitarra = it('🎸', 'tocar la guitarra');
const piano = it('🎹', 'tocar el piano');
const saps = it('🤔', 'saps nadar?', { say: 'Saps nadar?' });
const seNadar = it('👍', 'sí, sé nadar', { say: 'Sí, sé nadar!' });
const noSe = it('👎', 'no, no sé', { say: 'No, no sé nadar.' });
const ESPORTS = [futbol, basquet, tennis, pingpong, beisbol, badminton, hoquei, monopati, act('nadar')];
const SIMON_ACCIONS = [act('saltar'), act('correr'), act('ballar'), act('cantar'), act('nadar'), act('pintar')];

const PA12: Lesson = {
  id: 'pa12-esports', category: 'preA1', title: 'Esports i jocs', summary: 'Els esports, les aficions i «Saps...?».', emoji: '⚽', color: '#D3F9D8',
  say: p('Esports i jocs!'),
  pages: [
    intro('⚽', 'Som-hi! Hui farem esport i parlarem de les coses que ens agrada fer.'),
    discover('Els esports! Toca i escolta.', ESPORTS),
    discover('I més coses que podem fer! Toca i escolta.', [act('correr'), act('saltar'), xutar, llancar, act('ballar'), act('cantar'), pescar, foto, guitarra, piano, milotxa]),
    explain('Per a preguntar què sap fer algú, diem: Saps nadar? I contestem: Sí, sé nadar! O: No, no sé nadar.', [saps, seNadar, noSe]),
    dialog([
      ['👧', 'Pau, saps nadar?'],
      ['👦', 'Sí, sé nadar molt bé! I tu, saps tocar la guitarra?'],
      ['👧', 'No, no sé. Però sé tocar el piano!'],
      ['👦', 'Que bé! Juguem a futbol?'],
      ['👧', 'Sí! Som-hi!'],
    ]),
    quiz(q('Què sap tocar Laia?'), piano, [guitarra, it('🥁', 'el tambor')]),
    quiz(q('A què juguen Laia i Pau?'), futbol, [tennis, basquet]),
    SIMON_RULES,
    simon(SIMON_ACCIONS, [
      [act('saltar'), true, 'salta'], [act('correr'), false, 'corre'], [act('ballar'), true, 'balla'],
      [act('cantar'), true, 'canta'], [act('nadar'), false, 'nada'], [act('pintar'), true, 'pinta'],
    ]),
    lines([
      ['Laia', person('👧🎾', 'juga a tennis'), 'Laia juga a tennis.'],
      ['Pau', person('👦🏀', 'juga a bàsquet'), 'Pau juga a bàsquet.'],
      ['Marta', person('👧🎸', 'toca la guitarra'), 'Marta toca la guitarra.'],
      ['Joan', person('👦🎣', 'pesca'), 'Joan pesca al riu.'],
    ], person('🧒🛹', 'va amb monopatí')),
    yesno([
      [act('nadar'), 'Està nadant.', true],
      [piano, 'Toca la guitarra.', false],
      [act('saltar'), 'Està saltant.', true],
      [pescar, 'Juga a futbol.', false],
    ]),
    quiz(q('Què necessites per a pescar?'), pescar, [guitarra, monopati]),
    game(() => memoryRound(ESPORTS, 4)),
    summary('Molt bé! Ja coneixes molts esports. I saps preguntar: Saps nadar? Sí, sé nadar!', [...ESPORTS, guitarra, piano]),
  ],
};

/* ═══ 13. A la platja ═════════════════════════════════════════════════════ */

const platja = it('🏖️', 'la platja');
const marPlatja = it('🌊', 'el mar');
const sorra: KidsItem = { ...it('🟨', 'la sorra'), color: '#F4D58D' };
const petxina = it('🐚', 'la petxina');
const sol = it('☀️', 'el sol');
const nuvol = it('☁️', 'el núvol');
const palmera = it('🌴', 'la palmera');
const paraSol = it('⛱️', 'el para-sol');
const poal = it('🪣', 'el poal');
const castell = it('🏰', 'el castell de sorra');
const cranc = animal('cranc');
const faSol = it('🌞', 'fa sol');
const faVent = it('💨', 'fa vent');

const PA13: Lesson = {
  id: 'pa13-platja', category: 'preA1', title: 'A la platja', summary: 'La platja, el temps i «Escolta i col·loca».', emoji: '🏖️', color: '#FFF3BF',
  say: p('A la platja!'),
  pages: [
    intro('🏖️', 'Hui fa sol i anem a la platja! Agafa el poal i la pala, que ens n\'anem!'),
    discover('Què hi ha a la platja? Toca i escolta.', [platja, marPlatja, sorra, petxina, sol, nuvol, palmera, paraSol, poal, castell, cranc, ani('peix')]),
    explain('Quin temps fa? A la platja, fa sol i fa calor. A vegades, fa vent i hi ha núvols.', [faSol, calor, faVent, nuvol]),
    place(SCENES.platja, [
      [sol, 'cel', 'Posa el sol al cel!'],
      [vaixell, 'mar', 'Posa el vaixell al mar!'],
      [cranc, 'sorra', 'Posa el cranc a la sorra!'],
      [ani('peix'), 'mar', 'Posa el peix al mar!'],
      [nuvol, 'cel', 'Posa el núvol al cel!'],
      [petxina, 'sorra', 'Posa la petxina a la sorra!'],
    ], [poal]),
    story([
      ['☀️🏖️', 'Hui fa sol, i Laia i Pau van a la platja amb la família.'],
      ['🪣🏰', 'Pau i Laia fan un castell de sorra molt gran.'],
      ['🌊🏊', "Després, naden al mar. L'aigua està fresqueta!"],
      ['🐚🦀', 'Laia troba una petxina i un cranc xicotet.'],
      ['🍦😋', 'Per acabar, mengen un gelat. Quin dia més bonic!'],
    ]),
    quiz(q('Què fan Pau i Laia amb la sorra?'), castell, [milotxa, bici]),
    quiz(q('Què troba Laia?'), petxina, [pilota, llibre]),
    quiz(q('Què mengen per a acabar?'), food('gelat'), [food('pa'), hamburguesa]),
    yesno([
      [sol, 'És la lluna.', false],
      [petxina, 'És una petxina.', true],
      [palmera, 'És una palmera.', true],
      [cranc, 'És un peix.', false],
    ]),
    paint([paraSol, poal, castell, petxina, vaixell], [
      [paraSol, 'roig'], [poal, 'blau'], [petxina, 'rosa'], [vaixell, 'groc'],
    ]),
    diff([sol, palmera, paraSol, poal, cranc], [[4, petxina]]),
    spell(sol, ['S', 'O', 'L']),
    summary('Molt bé! Ja coneixes la platja: el mar, la sorra, les petxines i el sol. Fa sol i fa calor!', [platja, marPlatja, sorra, petxina, sol, palmera, castell, cranc]),
  ],
};

/* ═══ 14. On és? Llocs i direccions ══════════════════════════════════════ */

const parc = it('🏞️', 'el parc');
const parcJocs = it('🛝', 'el parc de jocs');
const botiga = it('🏪', 'la botiga');
const carrer = it('🛣️', 'el carrer');
const llibreria = it('📚', 'la llibreria');
const escola = it('🏫', "l'escola");
const casa = home('casa');
const aci = it('👇', 'ací');
const alla = it('👉', 'allà');
const at = (pos: Pos, words: string): KidsItem => ({ id: `pa-pos-${pos}`, word: words, emoji: '🐈', pos, audio: p(`El gat és ${words}!`) });
const gatDamunt = at('damunt', 'damunt de la caixa');
const gatDavall = at('davall', 'davall de la caixa');
const gatDins = at('dins', 'dins de la caixa');
const gatDavant = at('davant', 'davant de la caixa');
const gatDarrere = at('darrere', 'darrere de la caixa');
const gatEntre = at('entre', 'entre les caixes');
const gos = ani('gos');
const gat = ani('gat');

const PA14: Lesson = {
  id: 'pa14-llocs', category: 'preA1', title: 'On és? Llocs i direccions', summary: 'Els llocs del poble, «entre», «ací» i «allà».', emoji: '🗺️', color: '#E0E7FF',
  say: p('On és? Llocs i direccions!'),
  pages: [
    intro('🗺️', 'Anem a passejar pel poble! Hui aprendrem els llocs i a dir on són les coses.'),
    discover('Els llocs del poble! Toca i escolta.', [casa, escola, parc, parcJocs, botiga, llibreria, carrer, zoo, platja]),
    explain('Recordes? El gat pot estar damunt, davall, dins, davant o darrere de la caixa.', [gatDamunt, gatDavall, gatDins, gatDavant, gatDarrere]),
    explain('I una paraula nova: entre! El gat és entre les caixes: una a cada costat.', [gatEntre]),
    explain('Ací vol dir prop de mi. Allà vol dir lluny de mi.', [aci, alla]),
    quiz(q('Toca el gat que és entre les caixes!'), gatEntre, [gatDamunt, gatDavant]),
    quiz(q('Toca el gat que és darrere de la caixa!'), gatDarrere, [gatDins, gatDavall]),
    dialog([
      ['👧', 'Pau, on és la llibreria?'],
      ['👦', 'És allà, entre el parc i la botiga.'],
      ['👧', "I l'escola?"],
      ['👦', "L'escola és ací, davant de casa meua!"],
    ]),
    quiz(q('On és la llibreria?'), it('🏞️📚🏪', 'entre el parc i la botiga', { stack: true }), [it('🏫🏠', "davant de l'escola", { stack: true }), it('🦁🏖️', 'al zoo', { stack: true })]),
    place(SCENES.parc, [
      [gat, 'banc', 'Posa el gat damunt del banc!'],
      [ani('ocell'), 'arbre', "Posa l'ocell a l'arbre!"],
      [pilota, 'font', 'Posa la pilota al costat de la font!'],
      [it('🧒', 'el xiquet'), 'tobogan', 'Posa el xiquet al tobogan!'],
      [gos, 'arbre', "Posa el gos davall de l'arbre!"],
    ], [globus]),
    yesno([
      [gatDamunt, 'El gat és damunt de la caixa.', true],
      [gatDavall, 'El gat és dins de la caixa.', false],
      [gatEntre, 'El gat és entre les caixes.', true],
      [gatDavant, 'El gat és darrere de la caixa.', false],
    ]),
    summary('Molt bé! Ja coneixes els llocs del poble i saps dir on són les coses: damunt, davall, dins, davant, darrere i entre!', [casa, escola, parc, botiga, llibreria, gatEntre, aci, alla]),
  ],
};

/* ═══ 15. El dia i l'aniversari ═══════════════════════════════════════════ */

const mati = it('🌅', 'el matí');
const vesprada = it('🌇', 'la vesprada');
const nit = it('🌙', 'la nit');
const hui = it('📅', 'hui');
const aniversari = it('🎂', "l'aniversari");
const any = it('🗓️', "l'any");
const anarEscola = it('🎒', "anar a l'escola");
const jugarParc = it('🛝', 'jugar al parc');
const dormir = act('dormir');
const quanEs = it('❓', 'quan és el teu aniversari?', { say: 'Quan és el teu aniversari?' });

const PA15: Lesson = {
  id: 'pa15-dia', category: 'preA1', title: "El dia i l'aniversari", summary: 'El matí, la vesprada i la nit, i una festa d\'aniversari.', emoji: '🎂', color: '#FFE3E3',
  say: p("El dia i l'aniversari!"),
  pages: [
    intro('🎂', 'Hui és un dia molt especial: és l\'aniversari de Pau! Però primer, aprendrem les parts del dia.'),
    discover('El dia té tres parts! Toca i escolta.', [mati, vesprada, nit]),
    explain('Pel matí esmorzem i anem a l\'escola. Per la vesprada berenem i juguem. Per la nit sopem i dormim.', [esmorzar, anarEscola, berenar, jugarParc, sopar, dormir]),
    sortBins(p('Quan ho fem? Pel matí, per la vesprada, o per la nit?'), [mati, vesprada, nit], [
      [esmorzar, mati], [anarEscola, mati], [berenar, vesprada], [jugarParc, vesprada], [sopar, nit], [dormir, nit],
    ]),
    quiz(q('Quan sopem?'), nit, [mati, vesprada]),
    quiz(q('Quan esmorzem?'), mati, [nit, vesprada]),
    explain("L'aniversari és el dia que fem anys. Per a preguntar-ho, diem: Quan és el teu aniversari? Hui és el meu aniversari!", [aniversari, quanEs, hui]),
    chant([
      ['🎂', 'Hui és el meu aniversari!'],
      ['🕯️', 'Tinc set anys, set espelmes!'],
      ['🌬️', 'Bufe fort: fffff!'],
      ['🎉', 'Per molts anys! Per molts anys!'],
    ]),
    quiz(q('Quantes espelmes té el pastís de Pau? En té set!'), candles(7), [candles(5), candles(9)]),
    story([
      ['🎈🎉', 'Hui és l\'aniversari de Pau, i fa una festa a casa.'],
      ['👧🎁', 'Laia li porta un regal: una milotxa verda!'],
      ['🎂🕯️', 'Pau bufa les espelmes, i tots canten: Per molts anys!'],
      ['🍰😋', 'Després, mengen pastís de xocolata. Que bo!'],
    ]),
    quiz(q('Què li regala Laia a Pau?'), milotxa, [robot, pilota]),
    quiz(q('De què és el pastís?'), xocolata, [food('maduixa'), llimona]),
    paint([globus, it('🎁', 'el regal'), pastis, estrela, milotxa], [
      [globus, 'blau'], [milotxa, 'verd'], [estrela, 'groc'], [pastis, 'marro'],
    ]),
    summary('Molt bé! Ja saps les parts del dia: el matí, la vesprada i la nit. I saps dir: Per molts anys!', [mati, vesprada, nit, aniversari, hui, any]),
  ],
};

/* ═══ 16. Mini-Starters: el gran repàs ═══════════════════════════════════ */

const diploma = it('🎓', 'el diploma');

const PA16: Lesson = {
  id: 'pa16-repas', category: 'preA1', title: 'Mini-Starters: el gran repàs', summary: 'Una prova com la de Cambridge, però en valencià i jugant.', emoji: '🎓', color: '#E5DBFF',
  say: p('Mini-Starters: el gran repàs!'),
  pages: [
    intro('🎓', 'Hui farem una prova com la dels xiquets de Cambridge, però en valencià i jugant! Si l\'acabes, guanyaràs el diploma Pre-A1.'),
    explain('Primera part: escolta i uneix! Toca el dibuix de la persona que diu la veu.', [NAME_CHIPS.Neus, NAME_CHIPS.Biel]),
    lines([
      ['Neus', person('👧🐕', 'passeja el gos'), 'Neus passeja el gos.'],
      ['Biel', person('👦🍎', 'menja una poma'), 'Biel menja una poma.'],
      ['Aina', person('👧🎤', 'canta una cançó'), 'Aina canta una cançó.'],
      ['Vicent', person('👦🪁', 'vola la milotxa'), 'Vicent vola la milotxa.'],
    ], person('🧒📖', 'llig un conte')),
    explain('Segona part: escolta i tria! Toca el dibuix correcte.', [it('👂', 'escolta i tria')]),
    quiz(q('Laia vol un gelat de maduixa. Quin és el seu gelat?'), it('🍓🍦', 'el gelat de maduixa', { stack: true }), [it('🍫🍦', 'el gelat de xocolata', { stack: true }), it('🍋🍦', 'el gelat de llimona', { stack: true })]),
    quiz(q('Pau va al parc amb el seu gos. Quin és Pau?'), person('👦🐕', 'amb el gos'), [person('👦🐈', 'amb el gat'), person('👦🐟', 'amb el peix')]),
    quiz(q('La iaia porta ulleres i un barret. Quina és la iaia?'), person('👵👓👒', 'amb ulleres i barret'), [person('👵🧣', 'amb bufanda'), person('👴👓', 'el iaio amb ulleres')]),
    explain('Tercera part: escolta i pinta!', [color('roig'), pilota]),
    paint([pilota, cotxe, globus, tren, osset], [
      [pilota, 'taronja-color'], [cotxe, 'blau'], [tren, 'verd'], [osset, 'marro'],
    ]),
    explain('Quarta part: mira i respon. És veritat? Sí o no?', [it('✅', 'sí'), it('❌', 'no')]),
    yesno([
      [ani('elefant'), "És un elefant.", true],
      [cloth('sabates'), 'És una gorra.', false],
      [food('platan'), 'El plàtan és groc.', true],
      [avio, 'És un vaixell.', false],
      [dormitori, 'És el dormitori.', true],
    ]),
    explain('Cinquena part: lletreja! Posa les lletres en ordre.', [it('🔤', "l'abecedari")]),
    spell(gat, ['G', 'A', 'T']),
    spell(it('🌊', 'el mar', { id: 'pa-mar' }), ['M', 'A', 'R']),
    explain('Última part: escolta i col·loca!', [platja]),
    place(SCENES.platja, [
      [sol, 'cel', 'Posa el sol al cel!'],
      [ani('peix'), 'mar', 'Posa el peix al mar!'],
      [castell, 'sorra', 'Posa el castell a la sorra!'],
      [nuvol, 'cel', 'Posa el núvol al cel!'],
    ], [petxina]),
    summary("Felicitats! Has acabat el gran repàs i has guanyat el diploma Pre-A1 de la Taronjeta. Ja estàs preparat per al nivell A1!", [diploma, magrada, NAME_CHIPS.Laia, NAME_CHIPS.Pau]),
  ],
};

export const PRE_A1_LESSONS: Lesson[] = [PA1, PA2, PA3, PA4, PA5, PA6, PA7, PA8, PA9, PA10, PA11, PA12, PA13, PA14, PA15, PA16];
