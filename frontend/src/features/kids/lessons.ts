import { ANIMALS, COLORS, FAMILY, NUMBERS } from './content';

/**
 * Lliçons bàsiques de valencià per a xiquets (pestanya «Lliçons»).
 * Cada lliçó és una llista de targetes: es toca una targeta i se sent la paraula.
 */
export type LessonCard = { text: string; emoji: string; note?: string; color?: string; say?: string };
export type Lesson = { id: string; title: string; emoji: string; intro: string; cards: LessonCard[] };

const fromItems = (items: { word: string; emoji: string; color?: string }[]): LessonCard[] =>
  items.map(({ word, emoji, color }) => ({ text: word, emoji, color }));

export const KIDS_LESSONS: Lesson[] = [
  {
    id: 'salutacions',
    title: 'Salutacions',
    emoji: '👋',
    intro: 'Així es saluda en valencià.',
    cards: [
      { text: 'Hola', emoji: '👋', note: 'Per a saludar' },
      { text: 'Bon dia', emoji: '☀️', note: 'Pel matí' },
      { text: 'Bona vesprada', emoji: '🌤️', note: 'Per la vesprada' },
      { text: 'Bona nit', emoji: '🌙', note: 'Per la nit' },
      { text: 'Adéu', emoji: '🙋', note: 'Per a acomiadar-se' },
      { text: 'Gràcies', emoji: '🙏', note: 'Quan algú t’ajuda' },
      { text: 'Per favor', emoji: '🥺', note: 'Per a demanar bé' },
      { text: 'Perdó', emoji: '😅', note: 'Quan et confons' },
    ],
  },
  {
    id: 'vocals',
    title: 'Les vocals',
    emoji: '🔤',
    intro: 'Al valencià hi ha cinc vocals: a, e, i, o, u.',
    cards: [
      { text: 'A d’avió', emoji: '✈️', say: 'A, d’avió' },
      { text: 'E d’elefant', emoji: '🐘', say: 'E, d’elefant' },
      { text: 'I d’illa', emoji: '🏝️', say: 'I, d’illa' },
      { text: 'O d’ou', emoji: '🥚', say: 'O, d’ou' },
      { text: 'U d’ull', emoji: '👁️', say: 'U, d’ull' },
    ],
  },
  {
    id: 'numeros',
    title: 'Els números',
    emoji: '🔢',
    intro: 'Comptem del u al deu.',
    cards: NUMBERS.map((n, i) => ({ text: n, emoji: String(i + 1), say: n })),
  },
  {
    id: 'colors',
    title: 'Els colors',
    emoji: '🎨',
    intro: 'De quin color és?',
    cards: fromItems(COLORS),
  },
  {
    id: 'animals',
    title: 'Els animals',
    emoji: '🐶',
    intro: 'Cada animal fa un so diferent.',
    cards: ANIMALS.map(a => ({ text: a.word, emoji: a.emoji, note: a.noise, say: a.sound })),
  },
  {
    id: 'familia',
    title: 'La família',
    emoji: '👨‍👩‍👧',
    intro: 'Qui hi ha a casa?',
    cards: fromItems(FAMILY),
  },
  {
    id: 'setmana',
    title: 'Els dies de la setmana',
    emoji: '📅',
    intro: 'Set dies, una setmana.',
    cards: [
      { text: 'dilluns', emoji: '1️⃣' },
      { text: 'dimarts', emoji: '2️⃣' },
      { text: 'dimecres', emoji: '3️⃣' },
      { text: 'dijous', emoji: '4️⃣' },
      { text: 'divendres', emoji: '5️⃣' },
      { text: 'dissabte', emoji: '🎈', note: 'Cap de setmana' },
      { text: 'diumenge', emoji: '🌞', note: 'Cap de setmana' },
    ],
  },
  {
    id: 'articles',
    title: 'El i la',
    emoji: '🧩',
    intro: 'Les paraules van amb «el» (masculí) o «la» (femení).',
    cards: [
      { text: 'el gos', emoji: '🐕' },
      { text: 'el sol', emoji: '☀️' },
      { text: 'el llibre', emoji: '📖' },
      { text: 'la lluna', emoji: '🌙' },
      { text: 'la casa', emoji: '🏠' },
      { text: 'la taula', emoji: '🪑' },
      { text: 'l’ou', emoji: '🥚', note: 'Davant de vocal: l’' },
      { text: 'l’ocell', emoji: '🐦', note: 'Davant de vocal: l’' },
    ],
  },
];
