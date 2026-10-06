/**
 * Lliçons i illes del Nivell 0 per a xiquets
 * ===========================================
 * Teoria completa i molt visual dels temes bàsics: cada lliçó és una seqüència
 * de pàgines que la Taronjeta explica en veu alta, amb pictogrames que es toquen
 * per a escoltar-los, diàlegs, barreges de colors, classificacions i preguntes
 * de comprovació. Les paraules es mostren també escrites (amb l'article de
 * color: blau per a el/els, rosa per a la/les i morat per a l'), per als adults
 * que acompanyen i per a anar familiaritzant-se amb la lletra.
 *
 * Darrere de cada lliçó hi ha la seua illa: unes quinze activitats de tota mena (escolta i
 * toca, classificar, ordenar, memòria, sí o no, pintar, unir...) que repassen TOT el que
 * explica la lliçó, amb el mateix vocabulari. Qui acaba l'illa guanya el seu cromo.
 *
 * Com content.ts, és només dades: també el llig backend/scripts/generate-kids-audio.ts.
 * Cada frase nova té la clau `ll-<hash del text>`: si es canvia el text, canvia
 * la clau i el script en genera l'àudio nou. Les frases s'han de registrar amb p()
 * en carregar el mòdul (no dins de les funcions dels jocs), perquè el script les veja.
 */
import {
  ABC_TRACE, ACTIONS, ALPHABET, ANIMALS, BODY, BODY_CARDS, bubbleRound, capital, casaRound, CLOTHES, COLOR_THINGS, colorOfRound,
  COLORS, EMOTIONS, emotionRound, FAMILY, FOOD, FREE_ISLANDS, habitatRound, HOME_PLACES, hotColdRound, INTRUDERS, LETTER_CARDS,
  LETTERS, memoryRound, monsterRound, moreRound, NUM_ITEMS, NUMBERS, numbersInOrder, oddRound, OPPOSITES, oppositeRound,
  orderRound, pick, shuffle, sizeItem, sizeRound, sortRound, tapRound, thenRound, type Island, type KidsItem, type Pos,
} from './content';
import {
  action, animal, ask, body, byId, classify, color, dialog, discover, explain, family, food, game, intro, it, listen, mix,
  oneOf, oneRight, opposite, p, pairs, pic, play, LESSON_AUDIO, quiz, simonSays, spelling, summary, trueFalse, word,
  type Activity, type Lesson,
} from './lessonKit';
import { PICTOGRAM_LESSONS } from './pictogramLessons';
import { NAME_CHIPS, PRE_A1_LESSONS } from './preA1';

// Es re-exporten perquè els llegien d'ací (sound.ts, els scripts de l'àudio i les traduccions).
export { LESSON_AUDIO, translatableKeys, type Lesson, type LessonPage } from './lessonKit';

/** L'illa on es practica una lliçó: totes les activitats, una darrere de l'altra. */
const islandFor = (lesson: Lesson, cromo: Island['cromo'], activities: Activity[], extra: Partial<Island> = {}): Island => ({
  id: lesson.island!, name: lesson.title, emoji: lesson.emoji, color: lesson.color, lesson: lesson.id, cromo,
  rounds: () => play(activities), ...extra,
});

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
  id: 'salutacions', title: 'Hola i adéu', summary: "Saludar segons l'hora i les paraules màgiques.", emoji: '👋', color: '#FFE8BA', say: p('Hola i adéu!'), island: 'salutacions',
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

const GREETINGS = [hola, bonDia, bonaVesprada, bonaNit, adeu, finsDema];
const MAGIC_WORDS = [perFavor, gracies, deRes, perdo];
const SALUDAR = it('🤗', 'per a saludar', { say: 'Per a saludar!' });
const DIR_ADEU = it('🚪', 'per a dir adéu', { say: 'Per a dir adéu!' });

const SALUTACIONS_ILLA = islandFor(SALUTACIONS, { emoji: '🌞', name: 'El sol del bon dia' }, [
  listen(GREETINGS, 2),
  ask(p("Arribes a l'escola pel matí. Què dius?"), bonDia, [bonaNit, adeu], { picture: '🏫' }),
  classify(p('Saludem o diem adéu? Toca la caixa bona!'), [SALUDAR, DIR_ADEU], [
    [hola, SALUDAR], [bonDia, SALUDAR], [bonaVesprada, SALUDAR], [adeu, DIR_ADEU], [finsDema, DIR_ADEU],
  ]),
  ask(p("Després de dinar, la iaia ve a vore't. Què li dius?"), bonaVesprada, [bonDia, bonaNit], { picture: '👵' }),
  () => orderRound(p('Ordena el dia! Primer el matí, després la vesprada i, al final, la nit.'), [bonDia, bonaVesprada, bonaNit]),
  ask(p("És de nit i te'n vas a dormir. Què dius?"), bonaNit, [bonDia, hola], { picture: '🛏️' }),
  () => memoryRound([hola, bonDia, bonaNit, adeu, perFavor, gracies, perdo], 3),
  ask(p("Te'n vas a casa i demà tornaràs a l'escola. Què dius?"), finsDema, [bonDia, perFavor], { picture: '🎒' }),
  listen(MAGIC_WORDS, 3),
  ask(p('La iaia et dona un regal. Què dius?'), gracies, [perdo, bonaNit], { picture: '🎁' }),
  ask(p('Pep et diu: Gràcies! Què li contestes?'), deRes, [perdo, adeu], { picture: '🐸' }),
  oneOf(
    ask(p("Sense voler, trepitges el peu d'un amic. Què dius?"), perdo, [deRes, bonDia], { picture: '🦶' }),
    ask(p('Sense voler, tires el got de la teua amiga. Què dius?'), perdo, [gracies, hola], { picture: '🥛' }),
  ),
  ask(p('Tens set i vols aigua. Com la demanes?'), perFavor, [adeu, perdo], { picture: '💧' }),
  trueFalse([
    [pic('☀️'), 'Pel matí diem: Bon dia!', true],
    [pic('🌙'), "Quan ens n'anem a dormir, diem: Bon dia!", false],
    [pic('🌇'), 'Per la vesprada diem: Bona vesprada!', true],
    [pic('🎁'), 'Quan ens donen un regal, diem: Gràcies!', true],
    [pic('🦶'), 'Si fem mal a algú sense voler, diem: De res!', false],
    [pic('👋'), "Quan ens n'anem, diem: Adéu!", true],
    [pic('💧'), 'Per a demanar aigua, diem: Perdó!', false],
  ], 4),
  () => thenRound([...GREETINGS, ...MAGIC_WORDS], 2, 4),
]);

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
  id: 'presentar', title: 'Qui soc jo?', summary: "Dir el nom, l'edat i on vius.", emoji: '🙋', color: '#FFE3E3', say: p('Qui soc jo?'), island: 'presentar',
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

const AGES = [3, 4, 5, 6, 7, 8];
const AGE_QUESTIONS = AGES.map(n => ({ n, prompt: p(`Qui diu: Tinc ${NUMBERS[n - 1]} anys? Compta les espelmes!`) }));
// Una edat a l'atzar: es compten les espelmes.
const howOld: Activity = () => {
  const { n, prompt } = pick(AGE_QUESTIONS, 1)[0];
  return ask(prompt, anys(n), pick(AGES.filter(a => a !== n), 2).map(anys))();
};
// Escolta i uneix: el nom de cada amic amb les espelmes de la seua edat.
const AGE_FRIENDS = ([['Laia', 3], ['Pau', 6], ['Marta', 8], ['Joan', 4]] as const)
  .map(([name, n]) => ({ name: NAME_CHIPS[name], candles: anys(n), key: p(`${name} té ${NUMBERS[n - 1]} anys.`) }));
const friendsAges: Activity = () => {
  const chosen = pick(AGE_FRIENDS, 3);
  const extra = anys(pick(AGES.filter(n => !chosen.some(c => c.candles.count === n)), 1)[0]);
  return {
    kind: 'lines',
    names: chosen.map(c => c.name),
    people: shuffle([...chosen.map(c => c.candles), extra]),
    tasks: chosen.map(c => ({ name: c.name.id, person: c.candles.id, key: c.key })),
  };
};
const ME = [emDic, comEtDius, quantsAnys, onVius, visc, encantat];

const PRESENTAR_ILLA = islandFor(PRESENTAR, { emoji: '🏷️', name: 'La targeta del meu nom' }, [
  listen(ME, 2),
  ask(p("Vols saber el nom d'una amiga. Què li preguntes?"), comEtDius, [quantsAnys, onVius], { picture: '👧' }),
  ask(p('Pep et pregunta: Com et dius? Què li contestes?'), emDic, [quantsAnys, visc], { picture: '🐸' }),
  howOld,
  ask(p('Vols saber quants anys té el teu amic. Què li preguntes?'), quantsAnys, [comEtDius, onVius], { picture: '🎂' }),
  oneOf(
    ask(p('Pau és un xiquet. Què diu Pau?'), xiquet, [xiqueta]),
    ask(p('Laia és una xiqueta. Què diu Laia?'), xiqueta, [xiquet]),
  ),
  friendsAges,
  ask(p('Vols saber on viu la teua amiga. Què li preguntes?'), onVius, [comEtDius, quantsAnys], { picture: '🗺️' }),
  ask(p('Pep et pregunta: On vius? Què li contestes?'), visc, [emDic, comEtDius], { picture: '🐸' }),
  () => memoryRound(ME, 3),
  ask(p('Coneixes una amiga nova. Què li dius?'), encantat, [perdo, bonaNit], { picture: '👋' }),
  trueFalse([
    [comEtDius, 'Per a preguntar el nom, diem: Com et dius?', true],
    [quantsAnys, "Per a preguntar l'edat, diem: On vius?", false],
    [anys(4), 'Mira les espelmes: tinc quatre anys!', true],
    [anys(6), 'Mira les espelmes: tinc tres anys!', false],
    [xiqueta, 'Una xiqueta diu: Soc un xiquet.', false],
    [xiquet, 'Un xiquet diu: Soc un xiquet.', true],
    [visc, 'Per a dir on vius, diem: Visc a València.', true],
    [encantat, 'Quan coneixem algú, diem: Bona nit!', false],
  ], 4),
  howOld,
  () => thenRound(ME, 2, 4),
]);

/* ── 3. El, la, l', els, les ──────────────────────────────────────────── */

const sol = it('☀️', 'el sol');
const lluna = it('🌙', 'la lluna');
const flor = it('🌸', 'la flor');
const cotxe = byId(INTRUDERS, 'cotxe');
const llapis = byId(INTRUDERS, 'llapis');
const pilota = byId(INTRUDERS, 'pilota');
const casa = byId(HOME_PLACES, 'casa');
const llibre = it('📖', 'el llibre');
const taula = it('🪑', 'la taula');
const gossos = it('🐕', 'els gossos', { count: 3 });
const gats = it('🐈', 'els gats', { count: 3 });
const pomes = it('🍎', 'les pomes', { count: 3 });
const flors = it('🌸', 'les flors', { count: 3 });
const BIN_EL: KidsItem = { id: 'bin-el', word: 'el', emoji: '', glyph: 'EL', ink: '#2563EB', audio: word('El!') };
const BIN_LA: KidsItem = { id: 'bin-la', word: 'la', emoji: '', glyph: 'LA', ink: '#DB2777', audio: word('La!') };
const EL_WORDS = [animal('gos'), animal('gat'), food('pa'), sol, cotxe, llapis, llibre];
const LA_WORDS = [food('poma'), animal('vaca'), casa, lluna, flor, pilota, taula];
const sortElLa = p("Ajuda'm a ordenar! Si diem EL, a la caixa blava. Si diem LA, a la caixa rosa.");
const sortElLaRound: Activity = () => sortRound(sortElLa, [BIN_EL, BIN_LA], [
  ...pick(EL_WORDS, 3).map(item => ({ item, bin: BIN_EL.id })),
  ...pick(LA_WORDS, 3).map(item => ({ item, bin: BIN_LA.id })),
]);

const ARTICLES: Lesson = {
  id: 'articles', title: "El, la, l', els, les", summary: 'Les paraules xicotetes que van davant de les coses.', emoji: '🔤', color: '#D0EBFF', say: p('El, la, els i les!'), island: 'articles',
  pages: [
    intro('📚', "Hola! Hui descobrirem unes paraules molt xicotetes que van davant de les coses: el, la, l', els i les!"),
    explain('Moltes paraules van amb EL: el gos, el pa, el sol.', [animal('gos'), food('pa'), sol]),
    discover('Toca-les i escolta: totes van amb EL!', EL_WORDS),
    explain('Altres paraules van amb LA: la poma, la casa, la lluna.', [food('poma'), casa, lluna]),
    discover('Toca-les i escolta: totes van amb LA!', LA_WORDS),
    game(sortElLaRound),
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

const BIN_L: KidsItem = { id: 'bin-l', word: "l'", emoji: '', glyph: "L'", ink: '#7C3AED', audio: p('La ela amb apòstrof!') };
const BIN_ELS: KidsItem = { id: 'bin-els', word: 'els', emoji: '', glyph: 'ELS', ink: '#2563EB', audio: word('Els!') };
const BIN_LES: KidsItem = { id: 'bin-les', word: 'les', emoji: '', glyph: 'LES', ink: '#DB2777', audio: word('Les!') };
const L_WORDS = [animal('ocell'), animal('abella'), food('aigua'), animal('elefant'), food('ou'), animal('ovella')];
const ELS_WORDS = [gossos, gats, it('🐟', 'els peixos', { count: 3 }), it('🚗', 'els cotxes', { count: 3 })];
const LES_WORDS = [pomes, flors, it('🍪', 'les galetes', { count: 3 }), it('🐄', 'les vaques', { count: 3 })];

const ARTICLES_ILLA = islandFor(ARTICLES, { emoji: '📦', name: 'Les caixes de paraules' }, [
  sortElLaRound,
  oneRight(p('Quina va amb EL? El...'), EL_WORDS, LA_WORDS),
  oneRight(p('Quina va amb LA? La...'), LA_WORDS, EL_WORDS),
  () => memoryRound([...EL_WORDS, ...LA_WORDS], 3),
  listen(L_WORDS, 3),
  oneRight(p("Quina comença per vocal i va amb L'?"), L_WORDS, [...EL_WORDS, ...LA_WORDS]),
  classify(p("El, la o l'? Toca la caixa bona!"), [BIN_EL, BIN_LA, BIN_L], [
    ...EL_WORDS.map((w): [KidsItem, KidsItem] => [w, BIN_EL]),
    ...LA_WORDS.map((w): [KidsItem, KidsItem] => [w, BIN_LA]),
    ...L_WORDS.map((w): [KidsItem, KidsItem] => [w, BIN_L]),
  ], 2),
  oneOf(
    ask(p('On són els gossos?'), gossos, [animal('gos')]),
    ask(p('On són els gats?'), gats, [animal('gat')]),
    ask('on-gat', animal('gat'), [gats]),
  ),
  oneOf(
    ask(p('On és la poma?'), food('poma'), [pomes]),
    ask(p('On són les pomes?'), pomes, [food('poma')]),
    ask(p('On són les flors?'), flors, [flor, gats]),
  ),
  classify(p("N'hi ha molts! Va amb ELS o amb LES? Toca la caixa!"), [BIN_ELS, BIN_LES], [
    ...ELS_WORDS.map((w): [KidsItem, KidsItem] => [w, BIN_ELS]),
    ...LES_WORDS.map((w): [KidsItem, KidsItem] => [w, BIN_LES]),
  ], 2),
  trueFalse([
    [animal('gos'), 'Diem: la gos.', false],
    [food('poma'), 'Diem: la poma.', true],
    [animal('ocell'), "Diem: l'ocell.", true],
    [sol, 'Diem: la sol.', false],
    [gossos, 'Diem: els gossos.', true],
    [pomes, 'Diem: els pomes.', false],
    [casa, 'Diem: el casa.', false],
    [lluna, 'Diem: la lluna.', true],
  ], 5),
  () => thenRound([...EL_WORDS, ...LA_WORDS], 2, 4),
  sortElLaRound,
]);

/* ── 4. Comptem! ──────────────────────────────────────────────────────── */

const num = (n: number, emoji: string): KidsItem => ({ id: `ln-${n}-${emoji}`, word: NUMBERS[n - 1], emoji, count: n, audio: `n-${n}` });
const TEENS = ['onze', 'dotze', 'tretze', 'catorze', 'quinze', 'setze', 'dèsset', 'díhuit', 'dènou', 'vint'];
const INKS = ['#EF4444', '#F97316', '#EAB308', '#22C55E', '#14B8A6', '#3B82F6', '#6366F1', '#A855F7', '#EC4899', '#0F766E'];
const teen = (i: number): KidsItem => ({ id: `teen-${i}`, word: TEENS[i], emoji: '', glyph: `${11 + i}`, ink: INKS[i], audio: word(`${capital(TEENS[i])}!`) });
const zero = it('🍽️', 'zero');
const dits = it('🖐️', 'deu dits', { count: 2, say: 'Cinc i cinc, deu dits!' });
const orderOneToFive = p("Toca'ls en ordre: u, dos, tres, quatre i cinc!");
const unGos = it('🐕', 'un gos');
const unaPoma = it('🍎', 'una poma');
const dosGossos = it('🐕', 'dos gossos', { count: 2 });
const duesPomes = it('🍎', 'dues pomes', { count: 2 });

const NUMEROS: Lesson = {
  id: 'numeros', title: 'Comptem!', summary: 'Del zero al vint, un i una, més i menys.', emoji: '🔢', color: '#E5DBFF', say: p('Comptem!'), island: 'numeros',
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

const TEEN_ITEMS = TEENS.map((_, i) => teen(i));
const giveSweets = (choices: number[]): Activity => () => {
  const n = pick(choices, 1)[0];
  return { kind: 'count', prompt: `dona-${n}`, n };
};
const findGroup = (choices: number[]): Activity => () => {
  const n = pick(choices, 1)[0];
  return { kind: 'dots', prompt: `onhiha-${n}`, n, options: shuffle([n, ...pick(NUMBERS.map((_, i) => i + 1).filter(x => x !== n), 2)]) };
};

const NUMEROS_ILLA = islandFor(NUMEROS, { emoji: '🍬', name: 'Els caramels' }, [
  giveSweets([1, 2, 3]),
  findGroup([1, 2, 3]),
  () => orderRound('ordre-numeros', numbersInOrder(4)),
  giveSweets([4, 5, 6]),
  () => moreRound(true),
  ask(p('En quin plat hi ha zero galetes?'), zero, [num(1, '🍪'), num(3, '🍪')]),
  findGroup([5, 6, 7, 8]),
  ask(p('Quants dits tens en una mà? Compta!'), num(5, '☝️'), [num(3, '☝️'), num(7, '☝️')]),
  listen(TEEN_ITEMS, 3),
  () => orderRound('ordre-numeros', pick(TEEN_ITEMS, 4).sort((a, b) => Number(a.glyph) - Number(b.glyph))),
  oneOf(
    ask(p('Toca on hi ha una poma!'), unaPoma, [duesPomes, num(3, '🍎')]),
    ask(p('Toca on hi ha dues pomes!'), duesPomes, [unaPoma, num(3, '🍎')]),
  ),
  oneOf(
    ask(p('Toca on hi ha un gos!'), unGos, [dosGossos, num(3, '🐕')]),
    ask(p('Toca on hi ha dos gossos!'), dosGossos, [unGos, num(3, '🐕')]),
  ),
  () => moreRound(false),
  trueFalse([
    [unaPoma, 'Diem: un poma.', false],
    [duesPomes, 'Diem: dues pomes.', true],
    [dosGossos, 'Diem: dues gossos.', false],
    [unGos, 'Diem: un gos.', true],
    [dits, 'Tenim deu dits.', true],
    [zero, 'En el plat hi ha tres galetes.', false],
    [num(4, '🍓'), 'Ací hi ha quatre maduixes.', true],
    [num(6, '🍓'), 'Ací hi ha dues maduixes.', false],
  ], 4),
  () => memoryRound(NUM_ITEMS.slice(0, 6), 3),
  giveSweets([7, 8, 9, 10]),
]);

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
  id: 'colors', title: 'Els colors', summary: 'Els colors, roig i roja, i barreges de pintura.', emoji: '🎨', color: '#C5F6FA', say: p('Els colors!'), island: 'colors',
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

const MIX_RESULTS = ['verd', 'taronja-color', 'morat', 'rosa'].map(color);
// «El groc i el blau, junts, fan...»: es veuen els dos pots i es toca el color que ix.
const mixQuiz = (a: string, b: string, result: string) => {
  const [first, second, made] = [color(a), color(b), color(result)];
  return ask(p(`${capital(first.word)} i ${second.word}, junts, fan...`), made, MIX_RESULTS.filter(c => c !== made).slice(0, 2), {
    picture: `${first.emoji}➕${second.emoji}`,
  });
};
const touchColor = (size: number): Activity => () => {
  const c = pick(COLORS, 1)[0];
  return tapRound(COLORS, c, size, { prompt: `toca-${c.id}`, react: `w-${c.id}` });
};
const colorOf = (size: number): Activity => () => colorOfRound(pick(COLOR_THINGS, 1)[0], size);
const bubbles: Activity = () => bubbleRound(pick(COLORS.filter(c => c.id !== 'blanc'), 1)[0]);

// Escolta i pinta: cada objecte té dos colors possibles (frases fixes, perquè tinguen àudio).
const PAINT_PALETTE = ['roig', 'blau', 'groc', 'verd', 'taronja-color', 'rosa', 'morat', 'marro'].map(color);
const PAINT_OBJECTS = [cotxe, pilota, casa, flor];
const PAINT_TASKS = ([
  [cotxe, 'roig'], [cotxe, 'blau'], [pilota, 'verd'], [pilota, 'groc'], [casa, 'rosa'], [casa, 'taronja-color'], [flor, 'morat'], [flor, 'groc'],
] as const).map(([item, c]) => ({ item: item.id, color: c, key: p(`Pinta ${item.word} de ${color(c).word.replace(/^el /, '')}!`) }));
const paintRound: Activity = () => ({
  kind: 'paint',
  objects: shuffle(PAINT_OBJECTS),
  palette: PAINT_PALETTE,
  tasks: pick(PAINT_OBJECTS, 3).map(item => pick(PAINT_TASKS.filter(t => t.item === item.id), 1)[0]),
});
const GENDER_COLORS = [cotxeRoig, pomaRoja, polletGroc, florGroga, barretNegre, gataNegra, ovellaBlanca, marBlau, balenaBlava];

const COLORS_ILLA = islandFor(COLORS_LESSON, { emoji: '🌈', name: "L'arc de Sant Martí" }, [
  bubbles,
  touchColor(3),
  colorOf(2),
  oneOf(mixQuiz('groc', 'blau', 'verd'), mixQuiz('roig', 'groc', 'taronja-color')),
  () => memoryRound(COLORS, 3),
  listen(GENDER_COLORS, 3),
  paintRound,
  bubbles,
  trueFalse([
    [pomaRoja, 'Diem: la poma roja.', true],
    [cotxeRoig, 'Diem: el cotxe roja.', false],
    [florGroga, 'Diem: la flor groga.', true],
    [polletGroc, 'Diem: el pollet groga.', false],
    [gataNegra, 'Diem: la gata negre.', false],
    [ovellaBlanca, "Diem: l'ovella blanca.", true],
    [balenaBlava, 'Diem: la balena blau.', false],
    [marBlau, 'Diem: el mar blau.', true],
  ], 5),
  oneOf(mixQuiz('roig', 'blau', 'morat'), mixQuiz('roig', 'blanc', 'rosa')),
  colorOf(3),
  touchColor(4),
  () => thenRound(COLORS, 2, 4),
  paintRound,
  colorOf(4),
]);

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
  id: 'cos', title: 'El meu cos', summary: 'Les parts del cos i els cinc sentits.', emoji: '🧒', color: '#D3F9D8', say: p('El meu cos!'), island: 'cos',
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

const FACE = ['ulls', 'orelles', 'nas', 'boca', 'dents', 'llengua'].map(body);
const LIMBS = ['braç', 'mà', 'dit', 'cama', 'peu'].map(body);
const SENSES = [veig, sent, olore, taste, toque];
const LA_CARA = it('🙂', 'la cara');
const LA_RESTA = it('🧍', 'el cos');
const bodyTap = (pool: KidsItem[], size: number): Activity => () => tapRound(pool, pick(pool, 1)[0], size);
const BODY_SIMON = ['nas', 'ulls', 'boca', 'orelles', 'mà', 'peu'].map(body);

const COS_ILLA = islandFor(COS, { emoji: '👾', name: 'El monstre simpàtic' }, [
  () => monsterRound(['cap', 'ulls', 'nas', 'boca']),
  bodyTap(FACE, 3),
  listen(SENSES, 3),
  oneOf(
    ask(p('Amb què escoltes la música?'), body('orelles'), [body('nas'), body('peu')], { picture: '🎵' }),
    ask(p('Amb què olores una flor?'), body('nas'), [body('mà'), body('orelles')], { picture: '🌸' }),
  ),
  classify(p('És de la cara o de la resta del cos? Toca la caixa!'), [LA_CARA, LA_RESTA], [
    ...FACE.map((b): [KidsItem, KidsItem] => [b, LA_CARA]),
    ...LIMBS.map((b): [KidsItem, KidsItem] => [b, LA_RESTA]),
  ], 3),
  () => monsterRound(['braç', 'mà', 'cama', 'peu']),
  oneOf(
    ask(p('Amb què xutes la pilota?'), body('peu'), [body('boca'), body('ulls')], { picture: '⚽' }),
    ask(p('Amb què mires els dibuixos?'), body('ulls'), [body('dents'), body('cama')], { picture: '🖼️' }),
  ),
  trueFalse([
    [unNas, 'Tenim un nas.', true],
    [dosUlls, 'Tenim tres ulls.', false],
    [duesMans, 'Tenim dues mans.', true],
    [deuDits, 'Tenim deu dits.', true],
    [duesOrelles, 'Tenim una orella.', false],
    [unaBoca, 'Tenim dues boques.', false],
    [veig, 'Amb els ulls, veig.', true],
    [olore, 'Amb el nas, escolte la música.', false],
  ], 5),
  oneOf(
    simonSays(BODY_SIMON, [[body('nas'), true], [body('boca'), true], [body('peu'), false], [body('orelles'), true]]),
    simonSays(BODY_SIMON, [[body('ulls'), true], [body('mà'), false], [body('peu'), true], [body('nas'), false], [body('boca'), true]]),
  ),
  bodyTap(LIMBS, 3),
  oneOf(
    ask(p('Amb què mossegues la poma?'), body('dents'), [body('orelles'), body('peu')], { picture: '🍎' }),
    ask(p('Amb què tastes el gelat?'), body('llengua'), [body('orelles'), body('mà')], { picture: '🍦' }),
    ask(p('Amb què acaricies el gat?'), body('mà'), [body('nas'), body('dents')], { picture: '🐈' }),
  ),
  () => memoryRound(BODY_CARDS, 3),
  () => thenRound(BODY_CARDS, 2, 4),
  bodyTap(BODY_CARDS, 4),
  listen(SENSES, 4),
]);

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
  id: 'familia', title: 'La meua família', summary: 'Pares, germans, iaios, oncles i cosins.', emoji: '👨‍👩‍👧', color: '#FFF3BF', say: p('La meua família!'), island: 'familia',
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

const BIG_FAMILY = [...FAMILY, oncle, tia, cosi, cosina];
const BIN_MEU: KidsItem = { id: 'bin-meu', word: 'el meu', emoji: '', glyph: 'EL MEU', ink: '#2563EB', audio: word('El meu!') };
const BIN_MEUA: KidsItem = { id: 'bin-meua', word: 'la meua', emoji: '', glyph: 'LA MEUA', ink: '#DB2777', audio: word('La meua!') };
const familyTap = (size: number): Activity => () => tapRound(FAMILY, pick(FAMILY, 1)[0], size);
const iaioF = family('iaio');
const iaiaF = family('iaia');

const FAMILIA_ILLA = islandFor(FAMILIA, { emoji: '👨‍👩‍👦', name: 'La família' }, [
  familyTap(2),
  oneOf(
    ask(p('Qui és la mare de la teua mare?'), iaiaF, [tia, family('germana')]),
    ask(p('Qui és el pare del teu pare?'), iaioF, [oncle, family('pare')]),
  ),
  () => casaRound(2),
  listen(BIG_FAMILY, 3),
  classify(p('El meu o la meua? Toca la caixa bona!'), [BIN_MEU, BIN_MEUA], [
    ...[family('pare'), family('germà'), iaioF, oncle, cosi].map((f): [KidsItem, KidsItem] => [f, BIN_MEU]),
    ...[family('mare'), family('germana'), iaiaF, tia, cosina].map((f): [KidsItem, KidsItem] => [f, BIN_MEUA]),
  ], 3),
  oneOf(
    ask(p('Qui és el germà del teu pare?'), oncle, [iaioF, cosi]),
    ask(p('Qui és la germana de la teua mare?'), tia, [iaiaF, cosina]),
  ),
  () => memoryRound(BIG_FAMILY, 3),
  () => orderRound(p('Ordena de més gran a més xicotet: el iaio, el pare i el bebé!'), [iaioF, family('pare'), family('bebe')]),
  () => tapRound(HOME_PLACES, pick(HOME_PLACES, 1)[0], 3),
  trueFalse([
    [meuPare, 'Diem: el meu pare.', true],
    [meuaMare, 'Diem: el meu mare.', false],
    [meuaGermana, 'Diem: la meua germana.', true],
    [meuGerma, 'Diem: la meua germà.', false],
    [iaiaF, 'Diem: la meua iaia.', true],
    [iaioF, 'Diem: la meua iaio.', false],
  ], 4),
  () => casaRound(3),
  oneOf(
    ask(p('Qui és el fill del teu oncle?'), cosi, [family('germà'), oncle]),
    ask(p('Qui és la filla de la teua tia?'), cosina, [tia, family('germana')]),
    ask(p('Qui és el més xicotet de tots?'), family('bebe'), [iaioF, family('pare')]),
  ),
  () => thenRound(FAMILY, 2, 4),
  listen(BIG_FAMILY, 4),
]);

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
  id: 'emocions', title: 'Com estàs?', summary: 'Estic feliç, tinc fam: com ens sentim.', emoji: '😀', color: '#FCE7F3', say: p('Com estàs?'), island: 'emocions',
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

const ESTIC = [felic, trist, enfadat, sorpres, cansat, malalt];
const TINC = [por, son, fam, set, fred, calor];
const BIN_ESTIC: KidsItem = { id: 'bin-estic', word: 'estic', emoji: '', glyph: 'ESTIC', ink: '#0F766E', audio: word('Estic!') };
const BIN_TINC: KidsItem = { id: 'bin-tinc', word: 'tinc', emoji: '', glyph: 'TINC', ink: '#EA580C', audio: word('Tinc!') };

const EMOCIONS_ILLA = islandFor(EMOCIONS, { emoji: '🥰', name: 'La cara contenta' }, [
  listen(ESTIC, 3),
  oneOf(
    ask(p("S'ha trencat la teua joguina preferida. Com estàs?"), trist, [felic, sorpres], { picture: '🧸' }),
    ask(p('Hui és el teu aniversari! Com estàs?'), felic, [trist, malalt], { picture: '🎂' }),
    ask(p('El teu germà et pren la joguina. Com estàs?'), enfadat, [felic, cansat], { picture: '👦' }),
  ),
  classify(p('Diem ESTIC o diem TINC? Toca la caixa bona!'), [BIN_ESTIC, BIN_TINC], [
    ...ESTIC.map((e): [KidsItem, KidsItem] => [e, BIN_ESTIC]),
    ...TINC.map((e): [KidsItem, KidsItem] => [e, BIN_TINC]),
  ], 3),
  listen(TINC, 3),
  oneOf(
    ask(p('Fa molt de temps que no menges. Què tens?'), fam, [son, fred], { picture: '🍽️' }),
    ask(p('Has jugat molt i vols beure aigua. Què tens?'), set, [fam, son], { picture: '💧' }),
  ),
  oneOf(
    ask(p('Neva i no portes jaqueta. Què tens?'), fred, [calor, set], { picture: '❄️' }),
    ask(p('Corres molt i fa molt de sol. Què tens?'), calor, [fred, por], { picture: '☀️' }),
  ),
  () => emotionRound(pick(EMOTIONS, 1)[0], 3),
  oneOf(
    ask(p('Pau ha corregut molt. Què diu?'), cansatXic, [cansadaXica]),
    ask(p('Laia ha corregut molt. Què diu?'), cansadaXica, [cansatXic]),
  ),
  oneOf(
    ask(p("És molt tard i se't tanquen els ulls. Què tens?"), son, [fam, por], { picture: '🌙' }),
    ask(p('És fosc i sents un soroll estrany. Què tens?'), por, [calor, fam], { picture: '🌑' }),
  ),
  trueFalse([
    [pic('❄️'), 'Neva i diem: tinc calor.', false],
    [pic('🍽️'), 'Quan volem menjar, diem: tinc fam.', true],
    [pic('🌙'), "Quan se'ns tanquen els ulls, diem: tinc son.", true],
    [trist, 'Esta cara està feliç.', false],
    [felic, 'Esta cara està feliç.', true],
    [pic('💧'), 'Quan volem beure, diem: tinc set.', true],
    [enfadat, 'Diem: tinc enfadat.', false],
  ], 5),
  oneOf(
    ask(p('Et fan una festa sorpresa! Com estàs?'), sorpres, [enfadat, malalt], { picture: '🎉' }),
    ask(p('Et fa mal la panxa i tens febre. Com estàs?'), malalt, [felic, sorpres], { picture: '🌡️' }),
  ),
  () => memoryRound([...ESTIC, ...TINC], 3),
  ask(p('Pep et pregunta: Com estàs? I tu estàs molt content. Què li dius?'), felic, [trist, malalt], { picture: '🐸' }),
  () => thenRound([...ESTIC, ...TINC], 2, 4),
  listen([...ESTIC, ...TINC], 4),
]);

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
  id: 'accions', title: 'Què fem?', summary: 'Menjar, dormir, jugar... i jo menge, jo dorm.', emoji: '🏃', color: '#FFEDD5', say: p('Què fem?'), island: 'accions',
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

const JO = [joMenge, joBec, joDorm, joJugue];
const ANIMALS_DO = [gatDorm, peixNada, ocellCanta, granotaSalta];
const AMB_BOCA = it('👄', 'amb la boca');
const AMB_CAMES = it('🦵', 'amb les cames');
const whoDoes = (size: number): Activity => () => {
  const target = pick(ACTIONS, 1)[0];
  return tapRound(ACTIONS, target, size, { prompt: `qui-${target.id}` });
};
const MOVES = ['saltar', 'ballar', 'cantar', 'dormir', 'correr'].map(action);

const ACCIONS_ILLA = islandFor(ACCIONS, { emoji: '🏅', name: 'La medalla' }, [
  whoDoes(2),
  listen(JO, 3),
  oneOf(
    ask(p("És l'hora de dinar. Què dius?"), joMenge, [joBec, joDorm], { picture: '🍽️' }),
    ask(p('Tens molta set. Què dius?'), joBec, [joDorm, joJugue], { picture: '🥵' }),
  ),
  () => memoryRound(ACTIONS, 3),
  classify(p('Ho fem amb la boca o amb les cames? Toca la caixa!'), [AMB_BOCA, AMB_CAMES], [
    ...['menjar', 'beure', 'cantar'].map((a): [KidsItem, KidsItem] => [action(a), AMB_BOCA]),
    ...['correr', 'saltar', 'ballar'].map((a): [KidsItem, KidsItem] => [action(a), AMB_CAMES]),
  ]),
  whoDoes(3),
  listen(ANIMALS_DO, 3),
  oneOf(
    ask(p('Tens molta son. Què dius?'), joDorm, [joMenge, joJugue], { picture: '🌙' }),
    ask(p('Vas al parc amb la pilota. Què dius?'), joJugue, [joBec, joDorm], { picture: '🛝' }),
  ),
  oneOf(
    simonSays(MOVES, [[action('saltar'), true, 'salta'], [action('ballar'), true, 'balla'], [action('dormir'), false, 'dorm'], [action('cantar'), true, 'canta']]),
    simonSays(MOVES, [[action('correr'), true, 'corre'], [action('cantar'), false, 'canta'], [action('saltar'), true, 'salta'], [action('ballar'), false, 'balla']]),
  ),
  oneOf(
    ask(p('Abans de menjar, què has de fer?'), rentarMans, [action('correr'), action('plorar')], { picture: '🍽️' }),
    ask(p('Tens set. Què fas?'), action('beure'), [action('dormir'), action('ballar')], { picture: '🥵' }),
  ),
  trueFalse([
    [gatDorm, 'El gat dorm.', true],
    [peixNada, 'El peix canta.', false],
    [ocellCanta, "L'ocell canta.", true],
    [granotaSalta, 'La granota dorm.', false],
    [joMenge, 'Jo menge.', true],
    [joBec, 'Jo dorm.', false],
  ], 4),
  whoDoes(4),
  ask(p("Què fa el peix en l'aigua?"), action('nadar'), [action('cantar'), action('llegir')], { picture: '🐟' }),
  () => thenRound(ACTIONS, 2, 4),
  () => memoryRound(ACTIONS, 4),
]);

/* ── 10. Els dies i el temps ──────────────────────────────────────────── */

const DAYS: [word: string, glyph: string][] = [
  ['dilluns', 'Dl'], ['dimarts', 'Dt'], ['dimecres', 'Dc'], ['dijous', 'Dj'], ['divendres', 'Dv'], ['dissabte', 'Ds'], ['diumenge', 'Dg'],
];
const days = DAYS.map(([day, glyph], i): KidsItem => ({ id: `dia-${day}`, word: day, emoji: '', glyph, ink: INKS[i + 1], audio: word(`${capital(day)}!`) }));
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
const sortDaysRound: Activity = () => sortRound(sortDays, [escola, capSetmana], [
  ...pick(days.slice(0, 5), 3).map(item => ({ item, bin: escola.id })),
  ...days.slice(5).map(item => ({ item, bin: capSetmana.id })),
]);

const TEMPS: Lesson = {
  id: 'temps', title: 'Els dies i el temps', summary: 'La setmana, les estacions i el temps que fa.', emoji: '📅', color: '#E0E7FF', say: p('Els dies i el temps!'), island: 'temps',
  pages: [
    intro('📅', 'Hola! Hui aprendrem els dies de la setmana, les estacions i el temps que fa.'),
    discover('La setmana té set dies. Toca-los i escolta: dilluns, dimarts, dimecres, dijous, divendres, dissabte i diumenge!', days),
    explain("De dilluns a divendres anem a l'escola. I dissabte i diumenge és cap de setmana: a jugar i a descansar!", [escola, capSetmana]),
    game(sortDaysRound),
    discover("L'any té quatre estacions. Toca-les i escolta!", [primavera, estiu, tardor, hivern]),
    discover('I quin temps fa hui? Toca i escolta!', WEATHER),
    quiz(p('Plou molt! Què necessites?'), paraigua, [ulleresSol, banyador], { picture: '🌧️' }),
    quiz(p('Fa molta calor i anem a la platja. Quina estació és?'), estiu, [hivern, tardor], { picture: '🏖️' }),
    quiz(p('Cauen les fulles dels arbres. Quina estació és?'), tardor, [primavera, estiu], { picture: '🌳' }),
    quiz(p('Neva i fem un ninot de neu. Quina estació és?'), hivern, [estiu, primavera], { picture: '⛄' }),
    summary("Molt bé! Ja saps els set dies de la setmana i les quatre estacions: la primavera, l'estiu, la tardor i l'hivern!", [...days, primavera, estiu, tardor, hivern]),
  ],
};

const ORDER_DAYS = p('Toca els dies en ordre, com van en la setmana!');
const weekRun: Activity = () => {
  const start = Math.floor(Math.random() * 4);
  return orderRound(ORDER_DAYS, days.slice(start, start + 4));
};
const SEASONS = [primavera, estiu, tardor, hivern];
const [faSol, plou, faVent, , ennuvolat] = WEATHER;
const bufanda = byId(CLOTHES, 'bufanda');

const TEMPS_ILLA = islandFor(TEMPS, { emoji: '⛅', name: 'El sol i el núvol' }, [
  listen(days, 3),
  weekRun,
  sortDaysRound,
  listen(SEASONS, 3),
  oneOf(
    ask(p('Fa molta calor i anem a la platja. Quina estació és?'), estiu, [hivern, tardor], { picture: '🏖️' }),
    ask(p('Ixen les flors i els ocells canten. Quina estació és?'), primavera, [tardor, hivern], { picture: '🌷' }),
  ),
  () => orderRound(p("Toca les estacions en ordre: la primavera, l'estiu, la tardor i l'hivern!"), SEASONS),
  listen(WEATHER, 3),
  ask(p('Plou molt! Què necessites?'), paraigua, [ulleresSol, banyador], { picture: '🌧️' }),
  oneOf(
    ask(p('Cauen les fulles dels arbres. Quina estació és?'), tardor, [primavera, estiu], { picture: '🌳' }),
    ask(p('Neva i fem un ninot de neu. Quina estació és?'), hivern, [estiu, primavera], { picture: '⛄' }),
  ),
  ask(p('Fa molt de sol a la platja. Què et poses?'), ulleresSol, [paraigua, bufanda], { picture: '🏖️' }),
  trueFalse([
    [faSol, 'Fa sol.', true],
    [plou, 'Neva.', false],
    [faVent, 'Fa vent.', true],
    [ennuvolat, 'Hi ha tempesta.', false],
    [hivern, "A l'hivern fa fred.", true],
    [estiu, "A l'estiu neva.", false],
    [capSetmana, "Dissabte i diumenge anem a l'escola.", false],
    [pic('📅'), 'La setmana té set dies.', true],
  ], 5),
  () => memoryRound(WEATHER, 3),
  weekRun,
  listen(WEATHER, 4),
]);

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
  id: 'llocs', title: 'On és el gat?', summary: 'Dins, fora, damunt, davall, davant i darrere.', emoji: '📦', color: '#FFE8BA', say: p('On és el gat?'), island: 'llocs',
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

const CAT_PLACES = [dins, fora, damunt, davall, davant, darrere, costat];
const CAT_QUESTIONS = CAT_PLACES.map(item => ({ item, prompt: touchCat(item.word) }));
const findCat = (size: number): Activity => () => {
  const { item, prompt } = pick(CAT_QUESTIONS, 1)[0];
  return ask(prompt, item, pick(CAT_PLACES.filter(x => x !== item), size - 1))();
};
// «Quin és el contrari de damunt?»: damunt i davall, davant i darrere, dins i fora.
const PLACE_OPPOSITES = ([[damunt, davall], [davant, darrere], [dins, fora]] as const).flatMap(([a, b]) => [[a, b], [b, a]])
  .map(([from, to]) => ({ to, prompt: p(`Quin és el contrari de ${from.word.replace(' de la caixa', '')}?`) }));
const oppositePlace: Activity = () => {
  const { to, prompt } = pick(PLACE_OPPOSITES, 1)[0];
  return ask(prompt, to, pick(CAT_PLACES.filter(x => x !== to), 2))();
};

const catTrueFalse = trueFalse(CAT_PLACES.flatMap((item, i): [KidsItem, string, boolean][] => [
  [item, `Mira: el gat és ${item.word}.`, true],
  [item, `Mira: el gat és ${CAT_PLACES[(i + 2) % CAT_PLACES.length].word}.`, false],
]), 5);

const LLOCS_ILLA = islandFor(LLOCS, { emoji: '🐈', name: 'El gat Pelut' }, [
  findCat(2),
  findCat(2),
  findCat(3),
  oppositePlace,
  listen(CAT_PLACES, 3),
  () => memoryRound(CAT_PLACES, 3),
  findCat(3),
  catTrueFalse,
  oppositePlace,
  () => thenRound(CAT_PLACES, 2, 4),
  findCat(4),
  catTrueFalse,
  oppositePlace,
  () => memoryRound(CAT_PLACES, 3),
  findCat(4),
]);

/* ── 12. Els contraris ────────────────────────────────────────────────── */

const gran = sizeItem('🐘', true);
const xicotet = sizeItem('🐘', false);

const CONTRARIS: Lesson = {
  id: 'contraris', title: 'Els contraris', summary: 'Gran i xicotet, calent i fred, ràpid i lent.', emoji: '🌗', color: '#E5DBFF', say: p('Els contraris!'), island: 'contraris',
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

// «Quin és el contrari del dia?», «...de calent?», «...d'obert?»
const ofWord = (w: string) => (w.startsWith('el ') ? `del ${w.slice(3)}` : /^[aeiouàèéíòóú]/i.test(w) ? `d'${w}` : `de ${w}`);
const CONTRARY_OF = OPPOSITES.flatMap(pair => pair.map((from, i) => ({ from, to: pair[1 - i], prompt: p(`Quin és el contrari ${ofWord(from.word)}?`) })));
const contraryOf: Activity = () => {
  const { from, to, prompt } = pick(CONTRARY_OF, 1)[0];
  const other = pick(OPPOSITES.flat().filter(o => o !== from && o !== to), 1);
  return ask(prompt, to, [from, ...other])();
};
const DAY_THINGS = [it('🌈', "l'arc de Sant Martí"), it('🐓', 'el gall'), it('🏫', "l'escola"), it('🌻', 'el gira-sol')];
const NIGHT_THINGS = [it('⭐', 'les estrelles'), it('🦉', 'el mussol'), it('🦇', 'el ratpenat'), byId(HOME_PLACES, 'llit')];

const CONTRARIS_ILLA = islandFor(CONTRARIS, { emoji: '🎭', name: 'Les dues cares' }, [
  () => sizeRound(true),
  () => oppositeRound(OPPOSITES[0], 2),
  () => sizeRound(false),
  () => oppositeRound(OPPOSITES[1], 2),
  () => hotColdRound(),
  contraryOf,
  () => oppositeRound(OPPOSITES[2], 3),
  classify(p('És del dia o de la nit? Toca la caixa!'), [opposite('dia'), opposite('nit')], [
    ...DAY_THINGS.map((t): [KidsItem, KidsItem] => [t, opposite('dia')]),
    ...NIGHT_THINGS.map((t): [KidsItem, KidsItem] => [t, opposite('nit')]),
  ], 2),
  () => oppositeRound(OPPOSITES[3], 3),
  trueFalse([
    [opposite('rapid'), 'El conill és lent.', false],
    [opposite('lent'), 'La tortuga és lenta.', true],
    [opposite('alt'), 'La girafa és alta.', true],
    [opposite('baix'), 'El pingüí és alt.', false],
    [opposite('obert'), 'El llibre està tancat.', false],
    [opposite('fred'), 'El gel està fred.', true],
    [opposite('calent'), 'El foc està fred.', false],
    [opposite('trist'), 'Està content.', false],
  ], 5),
  () => sizeRound(Math.random() < 0.5),
  () => oppositeRound(OPPOSITES[4], 3),
  contraryOf,
  () => oppositeRound(OPPOSITES[5], 3),
]);

/* ── 13. Les lletres i els sons ───────────────────────────────────────── */

const abc = (letter: string) => ALPHABET.find(l => l.letter === letter)!;
const vowel = (letter: string): KidsItem => ({ id: `v-${letter}`, word: letter, emoji: '', glyph: letter.toUpperCase(), ink: '#7C3AED', audio: `abc-de-${letter}` });
const letterGlyph = (letter: string): KidsItem => ({ id: `g-${letter}`, word: abc(letter).name, emoji: '', glyph: letter.toUpperCase(), ink: '#0F766E', audio: word(`${capital(abc(letter).name)}!`) });
const VOWEL_ITEMS = ['a', 'e', 'i', 'o', 'u'].map(vowel);
const SOUNDS = LETTERS.map((l): KidsItem => ({ id: `so-${l.id}`, word: l.glyph, emoji: '', glyph: l.glyph, ink: '#DB2777', audio: `lletra-${l.id}` }));
const pinya = it('🍍', 'la pinya');
const VOWEL_WORDS = [it('✈️', "l'avió"), animal('elefant'), it('🏝️', "l'illa"), food('ou'), it('👁️', "l'ull")];
const startsWith = (letter: string, others: string[]) =>
  quiz(`comenca-${letter}`, abc(letter).card, others.map(o => abc(o).card), { picture: abc(letter).emoji, style: 'letters' });

const SONS: Lesson = {
  id: 'sons', title: 'Les lletres i els sons', summary: 'Les vocals i els sons especials del valencià.', emoji: '🔤', color: '#C5F6FA', say: p('Les lletres i els sons!'), island: 'lletres',
  pages: [
    intro('🔤', "Hola! Les paraules estan fetes de sons, i els sons s'escriuen amb lletres. Escoltem-les!"),
    explain('Hi ha cinc lletres molt especials: les vocals! A, e, i, o, u. Sonen fort i clar.', VOWEL_ITEMS),
    discover('Toca cada vocal i escolta una paraula que comença així!', VOWEL_ITEMS),
    discover('Més paraules que comencen per vocal: l\'avió, l\'elefant, l\'illa, l\'ou i l\'ull! Toca-les.', VOWEL_WORDS),
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

// Les paraules d'exemple dels sons especials (el braç, la pinya...), amb el seu àudio.
const SOUND_WORDS = LETTERS.map((l): KidsItem => ({ id: `so-paraula-${l.id}`, word: l.word, emoji: l.emoji, audio: `w-lletra-${l.id}` }));
const SOUND_NAMES: Record<string, string> = {
  'ç': 'la ce trencada', ny: 'el so nya, nye, nyi', tx: 'el so txe, txe', tg: 'la te i la ge juntes',
  ll: 'el so lla, lle, lli', lgeminada: 'la ela geminada', ix: 'el so ix, ix', gu: 'el so gue, gui',
};
const SOUND_QUESTIONS = LETTERS.map((l, i) => ({ target: SOUND_WORDS[i], prompt: p(`Quina paraula té ${SOUND_NAMES[l.id]}?`) }));
const whichSound: Activity = () => {
  const { target, prompt } = pick(SOUND_QUESTIONS, 1)[0];
  return ask(prompt, target, pick(SOUND_WORDS.filter(w => w !== target), 2))();
};
const CONSONANTS = ['b', 'c', 'd', 'f', 'g', 'l', 'm', 'n', 'p', 'r', 's', 't', 'v'];
// «La balena! Amb quina lletra comença?»: es veu el dibuix i es toca la lletra.
const startsWithAny = (letters: string[]): Activity => () => {
  const l = abc(pick(letters, 1)[0]);
  return ask(`comenca-${l.letter}`, l.card, pick(ALPHABET.filter(o => o !== l), 2).map(o => o.card), { picture: l.emoji, style: 'letters' })();
};
const traceSound: Activity = () => ({ kind: 'trace', letter: pick(LETTERS, 1)[0] });
const traceLetter: Activity = () => ({ kind: 'trace', letter: abc(pick(ABC_TRACE, 1)[0]).trace });

const LLETRES_ILLA = islandFor(SONS, { emoji: '⭐', name: "L'estrela de les lletres" }, [
  listen(VOWEL_ITEMS, 3),
  () => orderRound('ordre-vocals', ['a', 'e', 'i', 'o', 'u'].map(v => abc(v).card), 'letters'),
  startsWithAny(['a', 'e', 'i', 'o', 'u']),
  traceSound,
  listen(SOUNDS, 3),
  whichSound,
  () => memoryRound(LETTER_CARDS, 3, 'letters'),
  startsWithAny(CONSONANTS),
  oneOf(
    spelling(food('pa'), ['P', 'A']),
    spelling(sol, ['S', 'O', 'L']),
    spelling(lluna, ['LL', 'U', 'N', 'A']),
  ),
  traceLetter,
  whichSound,
  listen(SOUNDS, 4),
  traceSound,
  startsWithAny(CONSONANTS),
  () => memoryRound(LETTER_CARDS, 4, 'letters'),
], { emoji: '✨' });

/* ── 14. Els animals ──────────────────────────────────────────────────── */

// Cada animal diu el seu so: «El gos fa bub, bub!» (els mateixos àudios que l'illa).
const withSound = (a: KidsItem): KidsItem => ({ ...a, audio: `fa-${a.id}` });
const FARM = ['vaca', 'porc', 'ovella', 'gallina', 'cavall', 'anec'].map(animal).map(withSound);
const HOME_PETS = ['gos', 'gat', 'peix', 'ocell', 'conill', 'ratoli'].map(animal).map(withSound);
const WILD = ['lleo', 'elefant', 'mona', 'granota'].map(animal).map(withSound);
const gosset = it('🐶', 'el gosset', { say: 'El gos xicotet és el gosset!' });
const gatet = it('🐱', 'el gatet', { say: 'El gat xicotet és el gatet!' });
const pollet = it('🐤', 'el pollet', { say: 'La gallina té pollets!' });

const ANIMALS_LESSON: Lesson = {
  id: 'animals', title: 'Els animals', summary: 'Com es diuen i quin so fan els animals.', emoji: '🐶', color: '#FFD8A8', say: p('Els animals!'), island: 'animals',
  pages: [
    intro('🐶', 'Hola! Hui coneixerem els animals. Cada animal fa un so diferent: escolta bé!'),
    discover('Primer, els animals de casa. Toca cada un i escolta quin so fa!', HOME_PETS),
    discover('Ara, els animals de la granja. Toca i escolta!', FARM),
    discover('I estos viuen lluny, a la selva o a la bassa. Toca i escolta!', WILD),
    quiz('qui-gos', animal('gos'), [animal('gat'), animal('vaca')]),
    quiz('qui-vaca', animal('vaca'), [animal('porc'), animal('ovella')]),
    quiz('qui-gallina', animal('gallina'), [animal('anec'), animal('ocell')]),
    quiz('qui-lleo', animal('lleo'), [animal('elefant'), animal('mona')]),
    explain('Els animals xicotets tenen un nom molt dolç: el gosset, el gatet, el pollet.', [gosset, gatet, pollet]),
    explain('Uns animals volen pel cel, uns altres naden en l\'aigua, i molts caminen per la terra.', [animal('ocell'), animal('peix'), animal('cavall')]),
    game(() => habitatRound()),
    game(() => memoryRound(ANIMALS, 3)),
    summary('Molt bé! Ja coneixes molts animals i els seus sons. Recorda: el gos fa bub, bub, i el gat fa mèu, mèu!', [...HOME_PETS, ...FARM, ...WILD]),
  ],
};

const animalTap = (size: number): Activity => () => {
  const target = pick(ANIMALS, 1)[0];
  return tapRound(ANIMALS, target, size, { react: `fa-${target.id}` });
};
// «Qui fa mèu?»: només se sent l'onomatopeia i es busca l'animal.
const whoSays = (size: number): Activity => () => {
  const target = pick(ANIMALS, 1)[0];
  return tapRound(ANIMALS, target, size, { prompt: `qui-${target.id}`, react: `fa-${target.id}` });
};
const A_CASA = it('🏡', 'a casa', { say: 'Els animals de casa!' });
const A_GRANJA = it('🚜', 'a la granja', { say: 'Els animals de la granja!' });
const A_SELVA = it('🌴', 'a la selva', { say: 'Els animals de la selva!' });

const ANIMALS_ILLA = islandFor(ANIMALS_LESSON, { emoji: '🐕', name: 'El gos' }, [
  animalTap(2),
  whoSays(3),
  () => memoryRound(ANIMALS, 3),
  classify(p('On viu? A casa, a la granja o a la selva?'), [A_CASA, A_GRANJA, A_SELVA], [
    ...HOME_PETS.map((a): [KidsItem, KidsItem] => [a, A_CASA]),
    ...FARM.map((a): [KidsItem, KidsItem] => [a, A_GRANJA]),
    ...WILD.filter(a => a.id !== 'granota').map((a): [KidsItem, KidsItem] => [a, A_SELVA]),
  ], 2),
  animalTap(4),
  () => habitatRound(),
  () => oddRound('intrus-animals', ANIMALS, INTRUDERS),
  oneOf(
    ask(p('Com es diu el gos xicotet?'), gosset, [gatet, pollet], { picture: '🐕' }),
    ask(p('Com es diu el gat xicotet?'), gatet, [gosset, pollet], { picture: '🐈' }),
    ask(p('Com es diuen els fills de la gallina?'), pollet, [gosset, gatet], { picture: '🐔' }),
  ),
  whoSays(4),
  trueFalse([
    [animal('vaca'), 'La vaca fa muuu.', true],
    [animal('gos'), 'El gos fa mèu, mèu.', false],
    [animal('peix'), "El peix viu a l'aigua.", true],
    [animal('cavall'), 'El cavall vola pel cel.', false],
    [gatet, 'El gat xicotet és el gatet.', true],
    [animal('lleo'), 'El lleó viu a la granja.', false],
    [animal('gallina'), 'La gallina fa co, co, co.', true],
  ], 5),
  () => thenRound(ANIMALS, 2, 4),
  () => memoryRound(ANIMALS, 4),
  whoSays(4),
]);

export const LESSONS: Lesson[] = [
  SALUTACIONS, PRESENTAR, ARTICLES, NUMEROS, COLORS_LESSON, ANIMALS_LESSON, COS, FAMILIA, EMOCIONS, ACCIONS, TEMPS, LLOCS, CONTRARIS, SONS,
];

// Totes: les de la Taronjeta i les de la guia Pre-A1 (categoria pròpia en la pàgina de lliçons).
export const ALL_LESSONS: Lesson[] = [...LESSONS, ...PRE_A1_LESSONS, ...PICTOGRAM_LESSONS];
export { PICTOGRAM_LESSONS, PRE_A1_LESSONS };

export const lessonById = (id: string | undefined) => ALL_LESSONS.find(l => l.id === id);

// El mapa d'illes: una per lliçó, en el mateix ordre, i després les que no en tenen.
export const ISLANDS: Island[] = [
  SALUTACIONS_ILLA, PRESENTAR_ILLA, ARTICLES_ILLA, NUMEROS_ILLA, COLORS_ILLA, ANIMALS_ILLA, COS_ILLA, FAMILIA_ILLA,
  EMOCIONS_ILLA, ACCIONS_ILLA, TEMPS_ILLA, LLOCS_ILLA, CONTRARIS_ILLA, LLETRES_ILLA, ...FREE_ISLANDS,
];
export const islandById = (id: string | undefined) => ISLANDS.find(i => i.id === id);

Object.assign(LESSON_AUDIO, {
  'llicons': 'Les lliçons de la Taronjeta! Tria una lliçó i aprendrem moltes coses noves.',
  'llico-medalla': 'Molt bé! Has acabat la lliçó i has guanyat una medalla!',
  'llico-fi': 'Molt bé! Has acabat la lliçó una altra vegada!',
});
