import type { ErrorCategory } from './subagentErrorDetector.js';

// Categories d'error comunes (les del detector dels xats, subagentErrorDetector) per a
// comptar i resoldre els errors de tots els orígens igual. Cada origen guarda la seua:
//   * chat: ja és una categoria del detector.
//   * practice: el nom del contingut; es traduïx amb el focus del contingut (focusOf).
//   * writing: la de la rúbrica de l'avaluador de redaccions (WRITING_CATEGORIES).

/* ── Focus de cada contingut ──────────────────────────────────────────── */
// Categories d'error del detector (subagentErrorDetector) que treballa cada
// contingut, deduïdes del `type`. Van en codi i no a metadata perquè les
// migracions del catàleg reescriuen metadata en cada aplicació.
const FOCUS_BY_TYPE: [RegExp, ErrorCategory[]][] = [
  [/accentuacio|tonicitat|sillaba|vocals/, ['accentuació']],
  [/apostrof/, ['apostrofació']],
  [/dieresi/, ['accentuació', 'apostrofació']],
  [/alfabet|grafi|alveolars|palatals|laterals|rotiques|oclusives|majuscules|puntuacio|elocucio/, ['ortografia']],
  [/genere_nombre|substantius|adjectius|determinants|numerals|quantit/, ['concordança', 'morfologia']],
  [/pronoms|interrogatius|relatius|combinacions/, ['pronoms']],
  [/preposicions|regim/, ['preposicions']],
  [/verb|modes|subjuntiu|ser_estar|infinitiu|perifrasis/, ['morfologia']],
  [/adverbis|conjuncions|connectors/, ['sintaxi']],
];

export function focusOf(resource: { category: string; type: string }): ErrorCategory[] {
  if (resource.category === 'lexic_semantica') return ['lèxic'];
  if (!['fonetica_ortografia', 'morfosintaxi'].includes(resource.category)) return [];
  return FOCUS_BY_TYPE.find(([pattern]) => pattern.test(resource.type))?.[1] ?? [];
}

// Categories dels errors de les redaccions (rúbriques de l'A1, l'A2 i el B1/B2).
const WRITING_CATEGORIES: Record<string, ErrorCategory> = {
  'lèxic': 'lèxic',
  ortografia: 'ortografia',
  morfologia: 'morfologia',
  'concordança': 'concordança',
  morfosintaxi: 'morfologia',
  connector: 'sintaxi',
};

export type ErrorRow = { source: string; category: string; resources?: { category: string; type: string } | null };

// Categories del detector d'un error (la primera és la principal). Buit si no n'és un de
// llengua: p. ex. una pregunta fallada de comprensió, que ja es reflectix en la nota de l'àrea.
export function errorCategoriesOf(error: ErrorRow): string[] {
  if (error.source === 'practice') return error.resources ? focusOf(error.resources) : [];
  if (error.source === 'writing') {
    const category = WRITING_CATEGORIES[error.category];
    return category ? [category] : [];
  }
  return [error.category];
}
