/**
 * Factor d'error per paraula (WER): la mètrica amb què la fase 4 decideix si
 * el model «small» de Vosk basta o cal un altre motor.
 *
 *   WER = (substitucions + esborrats + insercions) / paraules de referència
 *
 * La normalització (minúscules, sense puntuació) és la mateixa que exigix la
 * gramàtica restringida de Vosk: així el bench no penalitza diferències de
 * format que no són errors de reconeixement.
 */

export type WerResult = {
  /** Tant per u (0 = transcripció exacta). Pot passar d'1 amb insercions. */
  wer: number
  substitutions: number
  deletions: number
  insertions: number
  refWords: number
  hypWords: number
};

/** Minúscules, sense puntuació ni espais sobrants, separat per paraules. */
export function normalizeWords(text: string): string[] {
  return text
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\s']/gu, ' ')
    .split(/\s+/)
    .filter(Boolean);
}

/** Distància de Levenshtein a nivell de paraula amb recompte d'operacions. */
export function wordErrorRate(hypothesis: string, reference: string): WerResult {
  const ref = normalizeWords(reference);
  const hyp = normalizeWords(hypothesis);
  const rows = ref.length + 1;
  const cols = hyp.length + 1;

  const cost: number[][] = Array.from({ length: rows }, (_, i) => [i]);
  for (let j = 1; j < cols; j += 1) cost[0]![j] = j;
  for (let i = 1; i < rows; i += 1) {
    for (let j = 1; j < cols; j += 1) {
      cost[i]![j] = Math.min(
        cost[i - 1]![j]! + 1,
        cost[i]![j - 1]! + 1,
        cost[i - 1]![j - 1]! + (ref[i - 1] === hyp[j - 1] ? 0 : 1),
      );
    }
  }

  // Camina enrere per classificar cada error (substitució/esborrat/inserció).
  let substitutions = 0;
  let deletions = 0;
  let insertions = 0;
  let i = ref.length;
  let j = hyp.length;
  while (i > 0 || j > 0) {
    if (i > 0 && j > 0 && ref[i - 1] === hyp[j - 1]) {
      i -= 1;
      j -= 1;
    } else if (i > 0 && j > 0 && cost[i]![j] === cost[i - 1]![j - 1]! + 1) {
      substitutions += 1;
      i -= 1;
      j -= 1;
    } else if (i > 0 && cost[i]![j] === cost[i - 1]![j]! + 1) {
      deletions += 1;
      i -= 1;
    } else {
      insertions += 1;
      j -= 1;
    }
  }

  const errors = substitutions + deletions + insertions;
  return {
    wer: ref.length === 0 ? (hyp.length === 0 ? 0 : 1) : errors / ref.length,
    substitutions,
    deletions,
    insertions,
    refWords: ref.length,
    hypWords: hyp.length,
  };
}
