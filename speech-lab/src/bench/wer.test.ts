/**
 * Pruebas del cálculo del WER (src/bench/wer.ts).
 *
 * El WER és la xifra amb què es decidirà el motor (fase 4), així que ací es
 * fixa què compta com a error: la puntuació i les majúscules no (és format),
 * cada paraula canviada, perduda o afegida sí.
 */
import { describe, expect, it } from 'vitest';
import { normalizeWords, wordErrorRate } from './wer.js';

describe('normalizeWords', () => {
  it('passa a minúscules i lleva la puntuació', () => {
    expect(normalizeWords('Bon dia! Com et puc ajudar, hui?')).toEqual(
      ['bon', 'dia', 'com', 'et', 'puc', 'ajudar', 'hui'],
    );
  });
});

describe('wordErrorRate', () => {
  it('val 0 amb transcripció exacta', () => {
    const result = wordErrorRate(
      'bon dia com et puc ajudar hui',
      'Bon dia! Com et puc ajudar hui?',
    );
    expect(result.wer).toBe(0);
    expect(result).toMatchObject({ substitutions: 0, deletions: 0, insertions: 0, refWords: 7 });
  });

  it('compta una substitució (el cas `una`/`hui` vist amb Vosk)', () => {
    const result = wordErrorRate(
      'bon dia com et puc ajudar una',
      'bon dia com et puc ajudar hui',
    );
    expect(result).toMatchObject({ substitutions: 1, deletions: 0, insertions: 0 });
    expect(result.wer).toBeCloseTo(1 / 7, 5);
  });

  it('compta un esborrat quan falta una paraula', () => {
    const result = wordErrorRate('bon dia', 'bon dia hui');
    expect(result).toMatchObject({ substitutions: 0, deletions: 1, insertions: 0 });
    expect(result.wer).toBeCloseTo(1 / 3, 5);
  });

  it('compta una inserció quan sobra una paraula', () => {
    const result = wordErrorRate('bon dia hui hui', 'bon dia hui');
    expect(result).toMatchObject({ substitutions: 0, deletions: 0, insertions: 1 });
  });

  it('val 1 amb hipòtesi buida i referència no buida', () => {
    expect(wordErrorRate('', 'bon dia').wer).toBe(1);
  });

  it('val 0 amb les dos buides', () => {
    expect(wordErrorRate('', '').wer).toBe(0);
  });
});
