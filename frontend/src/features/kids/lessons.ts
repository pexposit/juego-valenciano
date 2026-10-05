/**
 * Lliçons del Nivell 0 per a xiquets
 * ===================================
 * Teoria completa i molt visual dels temes bàsics: cada lliçó és una seqüència
 * de pàgines que la Taronjeta explica en veu alta, amb pictogrames que es toquen
 * per a escoltar-los, diàlegs, barreges de colors, classificacions i preguntes
 * de comprovació. Les paraules es mostren també escrites (amb l'article de
 * color: blau per a el/els, rosa per a la/les i morat per a l'), per als adults
 * que acompanyen i per a anar familiaritzant-se amb la lletra.
 *
 * Com content.ts, és només dades: també el llig backend/scripts/generate-kids-audio.ts.
 * Cada frase nova té la clau `ll-<hash del text>`: si es canvia el text, canvia
 * la clau i el script en genera l'àudio nou. Les frases s'han de registrar amb p()
 * en carregar el mòdul (no dins de les funcions dels jocs), perquè el script les veja.
 */
import {
  ACTIONS, ALPHABET, ANIMALS, BODY, capital, COLORS, EXTRA_ANIMALS, FAMILY, FOOD, HOME_PLACES, hotColdRound,
  INTRUDERS, LETTERS, memoryRound, moreRound, NUMBERS, OPPOSITES, orderRound, pick, shuffle, sizeItem, sortRound,
  thenRound, type KidsItem, type Pos, type Round,
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
const p = (text: string) => {
  const key = `ll-${hash(text)}`;
  LESSON_AUDIO[key] = text;
  return key;
};

/** Un pictograma nou amb el seu nom en veu alta («El sol!») o una frase pròpia. */
const it = (emoji: string, word: string, extra: Partial<KidsItem> & { say?: string } = {}): KidsItem => {
  const { say, ...rest } = extra;
  return { id: `${emoji}-${word}`, word, emoji, audio: p(say ?? `${capital(word)}!`), ...rest };
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
  | { kind: 'summary'; say: string; items: KidsItem[] };

export type Lesson = {
  id: string;
  title: string;
  emoji: string;
  color: string;
  say: string; // el títol en veu alta
  island?: string; // l'illa on es practica
  pages: LessonPage[];
};

const intro = (emoji: string, text: string): LessonPage => ({ kind: 'intro', emoji, say: p(text) });
const explain = (text: string, items: KidsItem[]): LessonPage => ({ kind: 'explain', say: p(text), items });
const discover = (text: string, items: KidsItem[]): LessonPage => ({ kind: 'discover', say: p(text), items });
const pairs = (text: string, list: [KidsItem, KidsItem][]): LessonPage => ({ kind: 'pairs', say: p(text), pairs: list });
const summary = (text: string, items: KidsItem[]): LessonPage => ({ kind: 'summary', say: p(text), items });
const game = (round: () => Round): LessonPage => ({ kind: 'game', round });
const dialog = (lines: [who: string, text: string][]): LessonPage =>
  ({ kind: 'dialog', lines: lines.map(([who, text]) => ({ who, say: p(text) })) });
const mix = (text: string, a: KidsItem, b: KidsItem, result: KidsItem, reveal: string): LessonPage =>
  ({ kind: 'mix', say: p(text), a, b, result, reveal: p(reveal) });

/** Pregunta de comprovació: es toca la resposta bona entre 2 o 3. */
const quiz = (prompt: string, answer: KidsItem, wrong: KidsItem[], extra: { picture?: string; style?: 'letters' } = {}): LessonPage =>
  game(() => ({ kind: 'tap', prompt, target: answer, options: shuffle([answer, ...wrong]), ...extra }));

const byId = <T extends KidsItem>(list: T[], id: string) => {
  const found = list.find(x => x.id === id);
  if (!found) throw new Error(`Falta l'element ${id}`);
  return found;
};
const animal = (id: string) => byId([...ANIMALS, ...EXTRA_ANIMALS], id);
const food = (id: string) => byId(FOOD, id);
const body = (id: string) => byId(BODY, id);
const family = (id: string) => byId(FAMILY, id);
const color = (id: string) => byId(COLORS, id);
const action = (id: string) => byId(ACTIONS, `acc-${id}`);
const opposite = (id: string) => byId(OPPOSITES.flat(), `op-${id}`);

/* ── 1. Hola i adéu ───────────────────────────────────────────────────── */

const hola = it('🙋', 'hola');
const bonDia = it('☀️', 'bon dia');
const bonaVesprada = it('🌇', 'bona vesprada');
const bonaNit = it('🌙', 'bona nit');
const adeu = it('👋', 'adéu');
const finsDema = it('📅', 'fins demà');
const perFavor = it('🙏', 'per favor');
const gracies = it('💖', 'gràcies');
const deRes = it('😊', 'de res');
const perdo = it('🙇', 'perdó');

const SALUTACIONS: Lesson = {
  id: 'salutacions', title: 'Hola i adéu', emoji: '👋', color: '#FFE8BA', say: p('Hola i adéu!'),
  pages: [
    intro('👋', 'Hola! Hui aprendrem a saludar i a dir adéu. Escolta bé i toca els dibuixos!'),
    explain('Quan veiem algú, el saludem i diem: Hola!', [hola]),
    explain('Pel matí, quan ix el sol, diem: Bon dia!', [bonDia]),
    explain('Per la vesprada, després de dinar, diem: Bona vesprada!', [bonaVesprada]),
    explain("Per la nit, quan ens n'anem a dormir, diem: Bona nit!", [bonaNit]),
    explain("I quan ens n'anem, diem: Adéu! O també: Fins demà!", [adeu, finsDema]),
    discover('Ara toca tots els dibuixos i repeteix amb mi!', [hola, bonDia, bonaVesprada, bonaNit, adeu, finsDema]),
    dialog([
      ['🍊', 'Bon dia, Pep!'],
      ['🐸', 'Bon dia, Taronjeta!'],
      ['🍊', "Me'n vaig a l'escola. Adéu!"],
      ['🐸', 'Adéu! Fins demà!'],
    ]),
    quiz(p("Arribes a l'escola pel matí. Què dius?"), bonDia, [bonaNit, adeu], { picture: '🏫' }),
    quiz(p("És de nit i te'n vas a dormir. Què dius?"), bonaNit, [bonDia, hola], { picture: '🛏️' }),
    explain('També hi ha paraules màgiques! Són xicotetes, però posen molt contenta la gent.', [perFavor, gracies, deRes, perdo]),
    explain('Quan vols alguna cosa, la demanes per favor: Em dones una galeta, per favor?', [perFavor, food('galeta')]),
    explain("Quan algú et dona alguna cosa, dius: Gràcies! I l'altra persona contesta: De res!", [gracies, deRes]),
    explain('I si fas mal a algú sense voler, dius: Perdó!', [perdo]),
    discover('Toca les paraules màgiques i digues-les amb mi!', [perFavor, gracies, deRes, perdo]),
    quiz(p('La iaia et dona un regal. Què dius?'), gracies, [perdo, bonaNit], { picture: '🎁' }),
    quiz(p("Sense voler, trepitges el peu d'un amic. Què dius?"), perdo, [deRes, bonDia], { picture: '🦶' }),
    quiz(p('Tens set i vols aigua. Com la demanes?'), perFavor, [adeu, perdo], { picture: '💧' }),
    summary(
      'Molt bé! Ja saps saludar: hola, bon dia, bona vesprada i bona nit. I saps dir adéu. I recorda les paraules màgiques: per favor, gràcies, de res i perdó!',
      [hola, bonDia, bonaVesprada, bonaNit, adeu, perFavor, gracies, deRes, perdo],
    ),
  ],
};

/* ── 2. Qui soc jo? ───────────────────────────────────────────────────── */

const emDic = it('🍊', 'em dic Taronjeta');
const comEtDius = it('🏷️', 'com et dius?', { say: 'Com et dius?' });
const xiquet = it('👦', 'soc un xiquet');
const xiqueta = it('👧', 'soc una xiqueta');
const anys = (n: number) => it('🕯️', `tinc ${NUMBERS[n - 1]} anys`, { count: n });
const quantsAnys = it('🎂', 'quants anys tens?', { say: 'Quants anys tens?' });
const onVius = it('🗺️', 'on vius?', { say: 'On vius?' });
const visc = it('🏡', 'visc a València');
const encantat = it('🤝', 'encantat, encantada', { say: 'Encantat! Encantada!' });

const PRESENTAR: Lesson = {
  id: 'presentar', title: 'Qui soc jo?', emoji: '🙋', color: '#FFE3E3', say: p('Qui soc jo?'),
  pages: [
    intro('🙋', 'Hola! Hui aprendràs a presentar-te. Així podràs fer amics nous!'),
    explain('Per a dir el teu nom, diem: Em dic... Jo em dic Taronjeta! I tu, com et dius?', [emDic]),
    explain('Per a preguntar-li el nom a un amic, diem: Com et dius?', [comEtDius]),
    explain('Un xiquet diu: Soc un xiquet. Una xiqueta diu: Soc una xiqueta.', [xiquet, xiqueta]),
    explain('Per a dir quants anys tens, diem: Tinc... anys. Mira les espelmes: jo tinc cinc anys!', [anys(5)]),
    discover('Toca les espelmes i escolta quants anys són!', [3, 4, 5, 6, 7, 8].map(anys)),
    explain("Per a preguntar l'edat, diem: Quants anys tens?", [quantsAnys]),
    explain('I per a saber on viu algú, preguntem: On vius? I contestem: Visc a València!', [onVius, visc]),
    explain('Quan coneixes algú, dius: Encantat! I si ets una xiqueta: Encantada!', [encantat]),
    dialog([
      ['🍊', 'Hola! Com et dius?'],
      ['🐸', 'Em dic Pep. I tu?'],
      ['🍊', 'Jo em dic Taronjeta. Quants anys tens?'],
      ['🐸', 'Tinc sis anys!'],
      ['🍊', 'Jo, cinc. Encantada, Pep!'],
      ['🐸', 'Encantat, Taronjeta!'],
    ]),
    quiz(p('Qui té tres anys? Compta les espelmes!'), anys(3), [anys(5), anys(7)]),
    quiz(p("Vols saber el nom d'una amiga. Què li preguntes?"), comEtDius, [quantsAnys, onVius], { picture: '👧' }),
    quiz(p('Vols saber quants anys té el teu amic. Què li preguntes?'), quantsAnys, [comEtDius, onVius], { picture: '🎂' }),
    summary(
      'Fantàstic! Ja et saps presentar: em dic..., tinc... anys, visc a... I saps preguntar: com et dius?, quants anys tens? i on vius?',
      [emDic, xiquet, xiqueta, anys(5), visc, comEtDius, quantsAnys, onVius, encantat],
    ),
  ],
};

/* ── 3. El, la, l', els, les ──────────────────────────────────────────── */

const sol = it('☀️', 'el sol');
const lluna = it('🌙', 'la lluna');
const flor = it('🌸', 'la flor');
const cotxe = byId(INTRUDERS, 'cotxe');
const llapis = byId(INTRUDERS, 'llapis');
const pilota = byId(INTRUDERS, 'pilota');
const casa = byId(HOME_PLACES, 'casa');
const gossos = it('🐕', 'els gossos', { count: 3 });
const gats = it('🐈', 'els gats', { count: 3 });
const pomes = it('🍎', 'les pomes', { count: 3 });
const flors = it('🌸', 'les flors', { count: 3 });
const BIN_EL: KidsItem = { id: 'bin-el', word: 'el', emoji: '', glyph: 'EL', ink: '#2563EB', audio: p('El!') };
const BIN_LA: KidsItem = { id: 'bin-la', word: 'la', emoji: '', glyph: 'LA', ink: '#DB2777', audio: p('La!') };
const EL_WORDS = [animal('gos'), animal('gat'), food('pa'), sol, cotxe, llapis];
const LA_WORDS = [food('poma'), animal('vaca'), casa, lluna, flor, pilota];
const sortElLa = p("Ajuda'm a ordenar! Si diem EL, a la caixa blava. Si diem LA, a la caixa rosa.");

const ARTICLES: Lesson = {
  id: 'articles', title: "El, la, l', els, les", emoji: '🔤', color: '#D0EBFF', say: p('El, la, els i les!'), island: 'animals',
  pages: [
    intro('📚', "Hola! Hui descobrirem unes paraules molt xicotetes que van davant de les coses: el, la, l', els i les!"),
    explain('Moltes paraules van amb EL: el gos, el pa, el sol.', [animal('gos'), food('pa'), sol]),
    discover('Toca-les i escolta: totes van amb EL!', EL_WORDS),
    explain('Altres paraules van amb LA: la poma, la casa, la lluna.', [food('poma'), casa, lluna]),
    discover('Toca-les i escolta: totes van amb LA!', LA_WORDS),
    game(() => sortRound(sortElLa, [BIN_EL, BIN_LA], [
      ...pick(EL_WORDS, 3).map(item => ({ item, bin: BIN_EL.id })),
      ...pick(LA_WORDS, 3).map(item => ({ item, bin: BIN_LA.id })),
    ])),
    explain(
      "Escolta! Quan la paraula comença per a, e, i, o, u, l'EL i el LA es fan curtets i diem L': l'ocell, l'abella, l'aigua.",
      [animal('ocell'), animal('abella'), food('aigua')],
    ),
    discover("Toca-les i escolta la L' del principi!", [animal('ocell'), animal('abella'), food('aigua'), animal('elefant'), food('ou'), animal('ovella')]),
    pairs("I quan n'hi ha molts? EL es fa ELS: el gos, els gossos. El gat, els gats.", [[animal('gos'), gossos], [animal('gat'), gats]]),
    pairs('I LA es fa LES: la poma, les pomes. La flor, les flors.', [[food('poma'), pomes], [flor, flors]]),
    quiz(p('On són els gossos?'), gossos, [animal('gos')]),
    quiz(p('On és la poma?'), food('poma'), [pomes]),
    quiz(p('On són les flors?'), flors, [flor, gats]),
    summary(
      "Molt bé! Recorda: el gos, la poma. Si la paraula comença per vocal, L': l'ocell. I si n'hi ha molts: els gossos, les pomes!",
      [animal('gos'), food('poma'), animal('ocell'), gossos, pomes],
    ),
  ],
};

/* ── 4. Comptem! ──────────────────────────────────────────────────────── */

const num = (n: number, emoji: string): KidsItem => ({ id: `ln-${n}-${emoji}`, word: NUMBERS[n - 1], emoji, count: n, audio: `n-${n}` });
const TEENS = ['onze', 'dotze', 'tretze', 'catorze', 'quinze', 'setze', 'dèsset', 'díhuit', 'dènou', 'vint'];
const INKS = ['#EF4444', '#F97316', '#EAB308', '#22C55E', '#14B8A6', '#3B82F6', '#6366F1', '#A855F7', '#EC4899', '#0F766E'];
const teen = (i: number): KidsItem => ({ id: `teen-${i}`, word: TEENS[i], emoji: '', glyph: `${11 + i}`, ink: INKS[i], audio: p(`${capital(TEENS[i])}!`) });
const zero = it('🍽️', 'zero');
const dits = it('🖐️', 'deu dits', { count: 2, say: 'Cinc i cinc, deu dits!' });
const orderOneToFive = p("Toca'ls en ordre: u, dos, tres, quatre i cinc!");
const unGos = it('🐕', 'un gos');
const unaPoma = it('🍎', 'una poma');
const dosGossos = it('🐕', 'dos gossos', { count: 2 });
const duesPomes = it('🍎', 'dues pomes', { count: 2 });

const NUMEROS: Lesson = {
  id: 'numeros', title: 'Comptem!', emoji: '🔢', color: '#E5DBFF', say: p('Comptem!'), island: 'numeros',
  pages: [
    intro('🔢', 'Hola! Anem a comptar! Els números ens diuen quantes coses hi ha.'),
    discover("Toca cada grup i compta amb mi, de l'u al cinc!", [1, 2, 3, 4, 5].map(n => num(n, '🍎'))),
    discover('Ara, del sis al deu! Toca i compta.', [6, 7, 8, 9, 10].map(n => num(n, '🍓'))),
    game(() => orderRound(orderOneToFive, [1, 2, 3, 4, 5].map(n => num(n, '🍬')))),
    explain('Mira les teues mans: tens cinc dits en cada mà. Cinc i cinc, deu dits!', [dits]),
    explain('I quan no hi ha res de res? Diem: zero! Mira, el plat està buit: zero galetes.', [zero]),
    discover(
      'Després del deu, venen més números: onze, dotze, tretze, catorze, quinze, setze, dèsset, díhuit, dènou i vint! Toca-los.',
      TEENS.map((_, i) => teen(i)),
    ),
    pairs("Atenció! L'u i el dos canvien una miqueta: un gos, però una poma. Dos gossos, però dues pomes!", [[unGos, unaPoma], [dosGossos, duesPomes]]),
    game(() => moreRound(true)),
    game(() => moreRound(false)),
    quiz('onhiha-7', num(7, '🍬'), [num(5, '🍬'), num(9, '🍬')]),
    quiz(p('Toca on hi ha una poma!'), unaPoma, [duesPomes, num(3, '🍎')]),
    summary('Molt bé! Ja saps comptar fins a vint! I recorda: un gos, una poma; dos gossos, dues pomes.', [num(1, '🍎'), num(5, '🍎'), dits, zero, teen(9), unaPoma, duesPomes]),
  ],
};

/* ── 5. Els colors ────────────────────────────────────────────────────── */

const platanGroc = it('🍌', 'el plàtan groc');
const granotaVerda = it('🐸', 'la granota verda');
const nuvolBlanc = it('☁️', 'el núvol blanc');
const cotxeRoig = it('🚗', 'el cotxe roig');
const pomaRoja = it('🍎', 'la poma roja');
const polletGroc = it('🐤', 'el pollet groc');
const florGroga = it('🌼', 'la flor groga');
const barretNegre = it('🎩', 'el barret negre');
const gataNegra = it('🐈‍⬛', 'la gata negra');
const ovellaBlanca = it('🐑', "l'ovella blanca");
const marBlau = it('🌊', 'el mar blau');
const balenaBlava = it('🐳', 'la balena blava');

const COLORS_LESSON: Lesson = {
  id: 'colors', title: 'Els colors', emoji: '🎨', color: '#C5F6FA', say: p('Els colors!'), island: 'colors',
  pages: [
    intro('🎨', 'Hola! El món està ple de colors! Anem a conéixer-los tots.'),
    discover('Toca cada color i escolta el seu nom!', COLORS.slice(0, 6)),
    discover("Encara n'hi ha més! Toca'ls.", COLORS.slice(6)),
    explain('Cada cosa té el seu color: el plàtan és groc, la granota és verda i el núvol és blanc.', [platanGroc, granotaVerda, nuvolBlanc]),
    pairs(
      'Mira què passa! Amb EL diem roig, però amb LA diem roja: el cotxe roig, la poma roja. I el pollet groc, però la flor groga!',
      [[cotxeRoig, pomaRoja], [polletGroc, florGroga]],
    ),
    pairs('Passa amb molts colors: negre i negra, blanc i blanca, blau i blava!', [[barretNegre, gataNegra], [nuvolBlanc, ovellaBlanca], [marBlau, balenaBlava]]),
    mix('Ara farem màgia! Barregem el groc i el blau. Toca els dos pots!', color('groc'), color('blau'), color('verd'), 'Ix el verd!'),
    mix('Ara, el roig i el groc. Toca els pots!', color('roig'), color('groc'), color('taronja-color'), 'Ix el taronja!'),
    mix('I si barregem el roig i el blau?', color('roig'), color('blau'), color('morat'), 'Ix el morat!'),
    mix('I el roig amb el blanc?', color('roig'), color('blanc'), color('rosa'), 'Ix el rosa!'),
    quiz(p('El groc i el blau, junts, fan...'), color('verd'), [color('morat'), color('taronja-color')]),
    quiz('dequin-platan', color('groc'), [color('blau'), color('roig')], { picture: '🍌' }),
    game(() => memoryRound(COLORS, 3)),
    summary('Molt bé! Ja coneixes els colors i saps fer-ne de nous. I recorda: el cotxe roig, la poma roja!', [...COLORS, cotxeRoig, pomaRoja]),
  ],
};

/* ── 6. El meu cos ────────────────────────────────────────────────────── */

const cap = { ...body('cap'), emoji: '🧑' };
const veig = it('👀', 'amb els ulls, veig');
const sent = it('👂', 'amb les orelles, sent');
const olore = it('👃', 'amb el nas, olore');
const taste = it('👅', 'amb la llengua, taste');
const toque = it('✋', 'amb les mans, toque');
const unNas = it('👃', 'un nas');
const unaBoca = it('👄', 'una boca');
const dosUlls = it('👀', 'dos ulls');
const duesOrelles = it('👂', 'dues orelles', { count: 2 });
const duesMans = it('✋', 'dues mans', { count: 2 });
const deuDits = it('☝️', 'deu dits', { count: 10 });

const COS: Lesson = {
  id: 'cos', title: 'El meu cos', emoji: '🧒', color: '#D3F9D8', say: p('El meu cos!'), island: 'cos',
  pages: [
    intro('🧒', 'Hola! Hui coneixerem el nostre cos. Toca cada part i, si vols, assenyala-la en el teu cos!'),
    discover('Primer, el cap i la cara! Toca i escolta.', [cap, body('ulls'), body('orelles'), body('nas'), body('boca'), body('dents'), body('llengua')]),
    discover('Ara, la resta del cos! Toca i escolta.', [body('braç'), body('mà'), body('dit'), body('cama'), body('peu')]),
    discover('Amb el cos descobrim el món! Toca i escolta què fem amb cada part.', [veig, sent, olore, taste, toque]),
    pairs('Comptem! Tenim un nas i una boca. Però tenim dos ulls, dues orelles i dues mans, amb deu dits!', [[unNas, dosUlls], [unaBoca, duesOrelles], [duesMans, deuDits]]),
    quiz(p('Amb què escoltes la música?'), body('orelles'), [body('nas'), body('peu')], { picture: '🎵' }),
    quiz(p('Amb què olores una flor?'), body('nas'), [body('mà'), body('orelles')], { picture: '🌸' }),
    quiz(p('Amb què xutes la pilota?'), body('peu'), [body('boca'), body('ulls')], { picture: '⚽' }),
    quiz(p('Amb què mires els dibuixos?'), body('ulls'), [body('dents'), body('cama')], { picture: '🖼️' }),
    quiz(p('Amb què mossegues la poma?'), body('dents'), [body('orelles'), body('peu')], { picture: '🍎' }),
    game(() => thenRound(BODY.filter(b => b.id !== 'cap'), 2, 4)),
    summary('Molt bé! Ja coneixes el teu cos: el cap, els ulls, el nas, la boca, els braços, les mans, les cames i els peus!', [cap, body('ulls'), body('nas'), body('boca'), body('orelles'), body('braç'), body('mà'), body('cama'), body('peu')]),
  ],
};

/* ── 7. La meua família ───────────────────────────────────────────────── */

const oncle = it('🧔', "l'oncle");
const tia = it('👩‍🦰', 'la tia');
const cosi = it('🧑‍🦱', 'el cosí');
const cosina = it('👱‍♀️', 'la cosina');
const meuPare = it('👨', 'el meu pare');
const meuaMare = it('👩', 'la meua mare');
const meuGerma = it('👦', 'el meu germà');
const meuaGermana = it('👧', 'la meua germana');

const FAMILIA: Lesson = {
  id: 'familia', title: 'La meua família', emoji: '👨‍👩‍👧', color: '#FFF3BF', say: p('La meua família!'), island: 'familia',
  pages: [
    intro('👨‍👩‍👧‍👦', 'Hola! Vols conéixer la meua família? Anem a aprendre com es diu cada persona!'),
    explain('Este és el pare, i esta és la mare.', [family('pare'), family('mare')]),
    explain('Els altres fills dels teus pares són els teus germans: el germà, la germana... i el bebé, que és molt xicotet!', [family('germà'), family('germana'), family('bebe')]),
    explain('Els pares del teu pare i de la teua mare són els teus iaios: el iaio i la iaia.', [family('iaio'), family('iaia')]),
    explain("El germà de la mare o del pare és l'oncle. I la germana, la tia.", [oncle, tia]),
    explain('I els fills dels oncles són els teus cosins: el cosí i la cosina!', [cosi, cosina]),
    discover('Toca tota la família i escolta!', [...FAMILY, oncle, tia, cosi, cosina]),
    pairs('Quan parlem de la nostra família, diem: el meu pare, la meua mare. El meu germà, la meua germana!', [[meuPare, meuaMare], [meuGerma, meuaGermana]]),
    quiz(p('Qui és la mare de la teua mare?'), family('iaia'), [tia, family('germana')]),
    quiz(p('Qui és el germà del teu pare?'), oncle, [family('iaio'), cosi]),
    quiz(p('Qui és el més xicotet de tots?'), family('bebe'), [family('iaio'), family('pare')]),
    game(() => memoryRound(FAMILY, 3)),
    summary('Molt bé! Ja coneixes tota la família: el pare, la mare, els germans, els iaios, els oncles i els cosins!', [...FAMILY, oncle, tia, cosi, cosina]),
  ],
};

/* ── 8. Com estàs? ────────────────────────────────────────────────────── */

const felic = it('😀', 'estic feliç');
const trist = it('😢', 'estic trist');
const enfadat = it('😠', 'estic enfadat');
const sorpres = it('😲', 'estic sorprès');
const cansat = it('🥱', 'estic cansat');
const malalt = it('🤒', 'estic malalt');
const cansatXic = it('👦', 'estic cansat');
const cansadaXica = it('👧', 'estic cansada');
const por = it('😨', 'tinc por');
const son = it('😴', 'tinc son');
const fam = it('🤤', 'tinc fam');
const set = it('🥤', 'tinc set');
const fred = it('🥶', 'tinc fred');
const calor = it('🥵', 'tinc calor');

const EMOCIONS: Lesson = {
  id: 'emocions', title: 'Com estàs?', emoji: '😀', color: '#FCE7F3', say: p('Com estàs?'), island: 'cos',
  pages: [
    intro('😀', 'Hola! Com estàs hui? Anem a aprendre a dir com ens sentim.'),
    explain('Quan tot va bé i tenim ganes de riure, diem: Estic feliç!', [felic]),
    explain('Quan alguna cosa no ens agrada i tenim ganes de plorar, diem: Estic trist.', [trist]),
    explain('I quan algú ens pren la joguina, a vegades diem: Estic enfadat!', [enfadat]),
    discover('Diem ESTIC per a dir com estem. Toca les cares i escolta!', [felic, trist, enfadat, sorpres, cansat, malalt]),
    explain('Atenció! Un xiquet diu: estic cansat. Una xiqueta diu: estic cansada!', [cansatXic, cansadaXica]),
    explain("A vegades diem TINC: tinc son, quan se'ns tanquen els ulls. Tinc fam, quan volem menjar!", [son, fam]),
    discover('Toca i escolta: tinc por, tinc son, tinc fam, tinc set, tinc fred i tinc calor!', [por, son, fam, set, fred, calor]),
    dialog([
      ['🍊', 'Hola, Pep! Com estàs?'],
      ['🐸', 'Estic molt bé! I tu?'],
      ['🍊', 'Jo estic una miqueta cansada... i tinc fam!'],
      ['🐸', 'Vols una poma?'],
      ['🍊', 'Sí, per favor! Gràcies!'],
      ['🐸', 'De res!'],
    ]),
    quiz(p('Fa molt de temps que no menges. Què tens?'), fam, [son, fred], { picture: '🍽️' }),
    quiz(p('Neva i no portes jaqueta. Què tens?'), fred, [calor, set], { picture: '❄️' }),
    quiz(p("S'ha trencat la teua joguina preferida. Com estàs?"), trist, [felic, sorpres], { picture: '🧸' }),
    quiz(p("És molt tard i se't tanquen els ulls. Què tens?"), son, [fam, por], { picture: '🌙' }),
    quiz(p('Et fan una festa sorpresa! Com estàs?'), sorpres, [enfadat, malalt], { picture: '🎉' }),
    summary('Molt bé! Diem ESTIC per a feliç, trist, enfadat o cansat. I diem TINC per a por, son, fam, set, fred i calor.', [felic, trist, enfadat, cansat, por, son, fam, set, fred, calor]),
  ],
};

/* ── 9. Què fem? (les accions) ────────────────────────────────────────── */

const jugar = it('⚽', 'jugar');
const joMenge = it('😋', 'jo menge');
const joBec = it('🥤', 'jo bec');
const joDorm = it('😴', 'jo dorm');
const joJugue = it('⚽', 'jo jugue');
const gatDorm = it('🐈', 'el gat dorm');
const peixNada = it('🐟', 'el peix nada');
const ocellCanta = it('🐦', "l'ocell canta");
const granotaSalta = it('🐸', 'la granota salta');
const rentarMans = it('🧼', 'rentar-se les mans');

const ACCIONS: Lesson = {
  id: 'accions', title: 'Què fem?', emoji: '🏃', color: '#FFEDD5', say: p('Què fem?'), island: 'accions',
  pages: [
    intro('🏃', 'Hola! Hui aprendrem les accions: són les coses que fem, com córrer, menjar o dormir!'),
    discover('Toca cada dibuix i escolta què fa!', ACTIONS.slice(0, 6)),
    discover("Encara n'hi ha més! Toca i escolta.", ACTIONS.slice(6)),
    pairs(
      'Quan ho fas tu, la paraula canvia! Menjar: jo menge. Beure: jo bec. Dormir: jo dorm. Jugar: jo jugue.',
      [[action('menjar'), joMenge], [action('beure'), joBec], [action('dormir'), joDorm], [jugar, joJugue]],
    ),
    discover("I quan ho fa un altre, també canvia: el gat dorm, el peix nada, l'ocell canta i la granota salta!", [gatDorm, peixNada, ocellCanta, granotaSalta]),
    quiz('qui-acc-dormir', action('dormir'), [action('correr'), action('cantar')]),
    quiz(p('Tens set. Què fas?'), action('beure'), [action('dormir'), action('ballar')], { picture: '🥵' }),
    quiz(p('Abans de menjar, què has de fer?'), rentarMans, [action('correr'), action('plorar')], { picture: '🍽️' }),
    quiz(p("Què fa el peix en l'aigua?"), action('nadar'), [action('cantar'), action('llegir')], { picture: '🐟' }),
    quiz('qui-acc-ballar', action('ballar'), [action('pintar'), action('dormir')]),
    game(() => memoryRound(ACTIONS, 3)),
    summary('Molt bé! Ja coneixes moltes accions. I recorda: jo menge, jo bec, jo dorm i jo jugue!', [...ACTIONS.slice(0, 6), joMenge, joBec, joDorm, joJugue]),
  ],
};

/* ── 10. Els dies i el temps ──────────────────────────────────────────── */

const DAYS: [word: string, glyph: string][] = [
  ['dilluns', 'Dl'], ['dimarts', 'Dt'], ['dimecres', 'Dc'], ['dijous', 'Dj'], ['divendres', 'Dv'], ['dissabte', 'Ds'], ['diumenge', 'Dg'],
];
const days = DAYS.map(([word, glyph], i): KidsItem => ({ id: `dia-${word}`, word, emoji: '', glyph, ink: INKS[i + 1], audio: p(`${capital(word)}!`) }));
const escola = it('🏫', "a l'escola");
const capSetmana = it('🏖️', 'cap de setmana');
const primavera = it('🌸', 'la primavera', { say: 'La primavera: ixen les flors!' });
const estiu = it('☀️', "l'estiu", { say: "L'estiu: fa calor i anem a la platja!" });
const tardor = it('🍂', 'la tardor', { say: 'La tardor: cauen les fulles dels arbres!' });
const hivern = it('❄️', "l'hivern", { say: "L'hivern: fa fred i, a vegades, neva!" });
const WEATHER = [
  it('🌞', 'fa sol'), it('🌧️', 'plou'), it('💨', 'fa vent'), it('🌨️', 'neva'), it('☁️', 'està ennuvolat'), it('⛈️', 'hi ha tempesta'),
];
const sortDays = p("On va cada dia? A l'escola o al cap de setmana?");
const paraigua = it('☂️', 'el paraigua');
const ulleresSol = it('🕶️', 'les ulleres de sol');
const banyador = it('🩱', 'el banyador');

const TEMPS: Lesson = {
  id: 'temps', title: 'Els dies i el temps', emoji: '📅', color: '#E0E7FF', say: p('Els dies i el temps!'),
  pages: [
    intro('📅', 'Hola! Hui aprendrem els dies de la setmana, les estacions i el temps que fa.'),
    discover('La setmana té set dies. Toca-los i escolta: dilluns, dimarts, dimecres, dijous, divendres, dissabte i diumenge!', days),
    explain("De dilluns a divendres anem a l'escola. I dissabte i diumenge és cap de setmana: a jugar i a descansar!", [escola, capSetmana]),
    game(() => sortRound(sortDays, [escola, capSetmana], [
      ...pick(days.slice(0, 5), 3).map(item => ({ item, bin: escola.id })),
      ...days.slice(5).map(item => ({ item, bin: capSetmana.id })),
    ])),
    discover("L'any té quatre estacions. Toca-les i escolta!", [primavera, estiu, tardor, hivern]),
    discover('I quin temps fa hui? Toca i escolta!', WEATHER),
    quiz(p('Plou molt! Què necessites?'), paraigua, [ulleresSol, banyador], { picture: '🌧️' }),
    quiz(p('Fa molta calor i anem a la platja. Quina estació és?'), estiu, [hivern, tardor], { picture: '🏖️' }),
    quiz(p('Cauen les fulles dels arbres. Quina estació és?'), tardor, [primavera, estiu], { picture: '🌳' }),
    quiz(p('Neva i fem un ninot de neu. Quina estació és?'), hivern, [estiu, primavera], { picture: '⛄' }),
    summary("Molt bé! Ja saps els set dies de la setmana i les quatre estacions: la primavera, l'estiu, la tardor i l'hivern!", [...days, primavera, estiu, tardor, hivern]),
  ],
};

/* ── 11. On és el gat? ────────────────────────────────────────────────── */

const where = (pos: Pos, word: string): KidsItem => ({ id: `pos-${pos}`, word, emoji: '🐈', pos, audio: p(`El gat és ${word}!`) });
const dins = where('dins', 'dins de la caixa');
const fora = where('fora', 'fora de la caixa');
const damunt = where('damunt', 'damunt de la caixa');
const davall = where('davall', 'davall de la caixa');
const davant = where('davant', 'davant de la caixa');
const darrere = where('darrere', 'darrere de la caixa');
const costat = where('costat', 'al costat de la caixa');
const touchCat = (word: string) => p(`Toca el gat que és ${word}!`);

const LLOCS: Lesson = {
  id: 'llocs', title: 'On és el gat?', emoji: '📦', color: '#FFE8BA', say: p('On és el gat?'),
  pages: [
    intro('🐈', "Hola! Este és el gat Pelut. És molt juganer i sempre s'amaga. Anem a aprendre a dir on és!"),
    explain('Mira! El gat és dins de la caixa.', [dins]),
    explain('Ara ha eixit: el gat és fora de la caixa!', [fora]),
    explain("Ara puja: el gat és damunt de la caixa! I ara s'amaga baix: el gat és davall de la caixa.", [damunt, davall]),
    explain('El gat és davant de la caixa: el veiem molt bé! I ara, darrere de la caixa: quasi no el veiem!', [davant, darrere]),
    explain('I ara, el gat és al costat de la caixa.', [costat]),
    discover('Toca cada dibuix i digues on és el gat!', [dins, fora, damunt, davall, davant, darrere, costat]),
    pairs('Són contraris! Damunt i davall. Davant i darrere. Dins i fora.', [[damunt, davall], [davant, darrere], [dins, fora]]),
    quiz(touchCat('damunt de la caixa'), damunt, [davall, costat]),
    quiz(touchCat('dins de la caixa'), dins, [fora, davant]),
    quiz(touchCat('darrere de la caixa'), darrere, [davant, damunt]),
    quiz(touchCat('davall de la caixa'), davall, [damunt, dins]),
    quiz(touchCat('al costat de la caixa'), costat, [dins, damunt]),
    summary('Molt bé! Ja saps dir on són les coses: dins, fora, damunt, davall, davant, darrere i al costat!', [dins, fora, damunt, davall, davant, darrere, costat]),
  ],
};

/* ── 12. Els contraris ────────────────────────────────────────────────── */

const gran = sizeItem('🐘', true);
const xicotet = sizeItem('🐘', false);

const CONTRARIS: Lesson = {
  id: 'contraris', title: 'Els contraris', emoji: '🌗', color: '#E5DBFF', say: p('Els contraris!'), island: 'contraris',
  pages: [
    intro('🌗', 'Hola! Hui jugarem amb els contraris: paraules ben diferents, com el dia i la nit!'),
    pairs('Toca i escolta: gran i xicotet. El dia i la nit. Calent i fred.', [[gran, xicotet], [opposite('dia'), opposite('nit')], [opposite('calent'), opposite('fred')]]),
    pairs('Més contraris! El conill és ràpid i la tortuga és lenta. La girafa és alta i el pingüí és baix.', [[opposite('rapid'), opposite('lent')], [opposite('alt'), opposite('baix')]]),
    pairs('I encara més: el llibre obert i el llibre tancat. Content i trist!', [[opposite('obert'), opposite('tancat')], [opposite('content'), opposite('trist')]]),
    quiz('quin-gran', gran, [xicotet]),
    quiz('ask-op-fred', opposite('fred'), [opposite('calent'), opposite('rapid')]),
    quiz('ask-op-lent', opposite('lent'), [opposite('rapid'), opposite('alt')]),
    quiz('ask-op-tancat', opposite('tancat'), [opposite('obert'), opposite('nit')]),
    game(() => hotColdRound()),
    summary('Molt bé! Ja coneixes molts contraris: gran i xicotet, calent i fred, ràpid i lent, alt i baix, obert i tancat!', OPPOSITES.flat()),
  ],
};

/* ── 13. Les lletres i els sons ───────────────────────────────────────── */

const abc = (letter: string) => ALPHABET.find(l => l.letter === letter)!;
const vowel = (letter: string): KidsItem => ({ id: `v-${letter}`, word: letter, emoji: '', glyph: letter.toUpperCase(), ink: '#7C3AED', audio: `abc-de-${letter}` });
const letterGlyph = (letter: string): KidsItem => ({ id: `g-${letter}`, word: abc(letter).name, emoji: '', glyph: letter.toUpperCase(), ink: '#0F766E', audio: p(`${capital(abc(letter).name)}!`) });
const VOWEL_ITEMS = ['a', 'e', 'i', 'o', 'u'].map(vowel);
const SOUNDS = LETTERS.map((l): KidsItem => ({ id: `so-${l.id}`, word: l.glyph, emoji: '', glyph: l.glyph, ink: '#DB2777', audio: `lletra-${l.id}` }));
const pinya = it('🍍', 'la pinya');
const startsWith = (letter: string, others: string[]) =>
  quiz(`comenca-${letter}`, abc(letter).card, others.map(o => abc(o).card), { picture: abc(letter).emoji, style: 'letters' });

const SONS: Lesson = {
  id: 'sons', title: 'Les lletres i els sons', emoji: '🔤', color: '#C5F6FA', say: p('Les lletres i els sons!'), island: 'abecedari',
  pages: [
    intro('🔤', "Hola! Les paraules estan fetes de sons, i els sons s'escriuen amb lletres. Escoltem-les!"),
    explain('Hi ha cinc lletres molt especials: les vocals! A, e, i, o, u. Sonen fort i clar.', VOWEL_ITEMS),
    discover('Toca cada vocal i escolta una paraula que comença així!', VOWEL_ITEMS),
    game(() => orderRound('ordre-vocals', ['a', 'e', 'i', 'o', 'u'].map(v => abc(v).card), 'letters')),
    explain('Les altres lletres es diuen consonants. Si ajuntem lletres, fem paraules: la pe i la a fan... pa!', [letterGlyph('p'), vowel('a'), food('pa')]),
    discover('En valencià tenim sons molt especials! Toca-los i escolta.', SOUNDS),
    startsWith('v', ['b', 'p']),
    startsWith('m', ['n', 'l']),
    quiz(p('Quina paraula té el so nya, nye, nyi?'), pinya, [animal('peix'), lluna]),
    quiz(p('Quina paraula té la ce trencada?'), body('braç'), [body('nas'), body('peu')]),
    summary('Molt bé! Ja coneixes les vocals, a, e, i, o, u, i els sons especials del valencià!', [...VOWEL_ITEMS, ...SOUNDS]),
  ],
};

export const LESSONS: Lesson[] = [
  SALUTACIONS, PRESENTAR, ARTICLES, NUMEROS, COLORS_LESSON, COS, FAMILIA, EMOCIONS, ACCIONS, TEMPS, LLOCS, CONTRARIS, SONS,
];

export const lessonById = (id: string | undefined) => LESSONS.find(l => l.id === id);

Object.assign(LESSON_AUDIO, {
  'llicons': 'Les lliçons de la Taronjeta! Tria una lliçó i aprendrem moltes coses noves.',
  'llico-medalla': 'Molt bé! Has acabat la lliçó i has guanyat una medalla!',
  'llico-fi': 'Molt bé! Has acabat la lliçó una altra vegada!',
  'llicons-boto': 'Les lliçons!',
});
