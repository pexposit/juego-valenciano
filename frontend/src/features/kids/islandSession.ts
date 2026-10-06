import { itemAudio, pick, shuffle, type Island, type KidsItem, type Round } from './content';
import { LISTEN } from './lessonKit';
import type { Practice } from './progress';

/**
 * Sessions de les illes del Nivell 0: micro-sessions de 3 a 5 minuts. Cada illa es
 * reparteix en etapes d'unes cinc rondes, en l'ordre de la lliçó; quan s'han fet totes
 * (i s'ha guanyat el cromo), cada partida és un repàs de cinc rondes a l'atzar. A més:
 * - Repàs: abans i després de l'etapa torna a preguntar el que ha costat («Escolta i toca»).
 * - Més fàcil: si l'última partida va costar molt, menys opcions i memòries més curtes.
 */

const STAGE_ROUNDS = 5;
const REVIEWS = 2;

const counts = new Map<string, number>();
/** Quantes etapes té una illa (les rondes es reparteixen a parts iguals). */
export function stageCount(island: Island) {
  if (!counts.has(island.id)) counts.set(island.id, Math.max(1, Math.round(island.rounds().length / STAGE_ROUNDS)));
  return counts.get(island.id)!;
}

// Com es dibuixa un element: els distractors del repàs han de ser de la mateixa mena.
const look = (item: KidsItem) => (item.pos ? 'pos' : item.color ? 'color' : item.count ? 'count' : item.glyph ? 'glyph' : 'emoji');
// El que es veu en la targeta: dos distractors no poden semblar iguals (el gat de Pelut és sempre 🐈).
const face = (item: KidsItem) => item.pos ?? item.color ?? item.glyph ?? `${item.emoji}${item.count ?? ''}`;
// Les targetes de l'abecedari i de les lletres porten la lletra en lloc d'emoji.
const isLetterCard = (item: KidsItem) => /^(abc|lt)-/.test(item.id);

/** El vocabulari que apareix en les rondes de l'illa (per a triar distractors). */
function vocabulary(rounds: Round[]): KidsItem[] {
  const items = rounds.flatMap((round): KidsItem[] => {
    if (round.kind === 'tap') return round.style === 'faces' ? [] : round.options;
    if (round.kind === 'odd' || round.kind === 'seq') return round.options;
    if (round.kind === 'memory') return round.items;
    if (round.kind === 'sort') return round.items.map(i => i.item);
    return [];
  });
  return [...new Map(items.map(item => [item.id, item])).values()];
}

/** «Escolta i toca» amb una cosa que ha costat, entre dibuixos de la mateixa mena. */
function reviewRound(item: KidsItem, pool: KidsItem[], options: number, first: boolean): Round | undefined {
  const others = pool.filter(o => o.id !== item.id && face(o) !== face(item) && look(o) === look(item));
  if (!others.length) return undefined;
  const prompt = first ? ['repas', LISTEN, itemAudio(item)] : [LISTEN, itemAudio(item)];
  return {
    kind: 'tap', prompt, target: item,
    options: shuffle([item, ...pick(others, options - 1)]),
    style: isLetterCard(item) ? 'letters' : undefined,
  };
}

/** La mateixa ronda, però més fàcil: dues opcions, memòries de tres parelles, ordres de dos passos. */
function easier(round: Round): Round {
  if (round.kind === 'tap' && round.style !== 'faces' && round.options.length > 2) {
    return { ...round, options: shuffle([round.target, ...pick(round.options.filter(o => o.id !== round.target.id), 1)]) };
  }
  if (round.kind === 'odd' && round.options.length > 3) {
    return { ...round, options: shuffle([round.target, ...pick(round.options.filter(o => o.id !== round.target.id), 2)]) };
  }
  if (round.kind === 'memory' && round.items.length > 3) return { ...round, items: round.items.slice(0, 3) };
  // «Primer, toca... I després...»: es queda en dos passos.
  if (round.kind === 'seq' && round.prompt[0] === 'primer' && round.targets.length > 2) {
    return { ...round, prompt: round.prompt.slice(0, 4), targets: round.targets.slice(0, 2) };
  }
  return round;
}

/** Les rondes d'una partida: l'etapa `stage` (o un repàs lliure si és null), amb el repàs del que ha costat. */
export function planSession(island: Island, stage: number | null, practice: Practice): Round[] {
  const all = island.rounds();
  const size = all.length / stageCount(island);
  const base = stage === null ? pick(all, STAGE_ROUNDS) : all.slice(Math.round(stage * size), Math.round((stage + 1) * size));
  const pool = vocabulary(all);
  const reviews = pick(practice.mistakes, REVIEWS)
    .map((item, i) => reviewRound(item, pool, practice.easy ? 2 : 3, i === 0))
    .filter((r): r is Round => !!r);
  const rounds = [...reviews.slice(0, 1), ...base, ...reviews.slice(1)];
  return practice.easy ? rounds.map(easier) : rounds;
}

/** Després de la partida: si ha costat molt, la pròxima serà més fàcil; si ha anat bé, normal. */
export function nextEase(practice: Practice, misses: number, rounds: number): boolean {
  if (misses > rounds) return true;
  if (misses <= rounds / 3) return false;
  return practice.easy;
}

/**
 * Les paraules que pregunta una ronda (per al seguiment de les persones adultes): el que
 * calia tocar, ordenar, classificar o arrastrar. Les cares del monstre no tenen nom propi.
 */
export function testedItems(round: Round): KidsItem[] {
  switch (round.kind) {
    case 'tap': return round.style === 'faces' ? [] : [round.target];
    case 'odd': return [round.target];
    case 'seq': return round.targets;
    case 'sort': return round.items.map(i => i.item);
    case 'bubbles': return [round.color];
    case 'drag': return round.tasks.map(t => t.item);
    default: return [];
  }
}
