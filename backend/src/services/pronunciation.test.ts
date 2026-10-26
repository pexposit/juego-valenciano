import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { scorePronunciation, type PhoneticResponse } from './pronunciation.js';

// Respostes reals de l'API (DeepLab, 2026-10-26) a la veu gina llegint la frase bé, amb faltes o una altra frase.
const fixture = (name: string) =>
  JSON.parse(readFileSync(new URL(`./fixtures/pronunciation/${name}.json`, import.meta.url), 'utf8')) as PhoneticResponse;
const PALATALS = ['ʃ', 'ʒ', 'tʃ', 'dʒ'];
const failed = (result: ReturnType<typeof scorePronunciation>) =>
  result.words.filter(w => w.target && !w.ok).map(w => `${w.word} ${w.expected}→${w.heard ?? '∅'}`);

describe('scorePronunciation', () => {
  it('dona per bona la frase ben llegida, encara que alguna palatal isca amb poca confiança', () => {
    const result = scorePronunciation(fixture('xiqueta-be'), PALATALS);
    expect(result).toMatchObject({ understood: true, score: 4, total: 4 });
    expect(result.words.filter(w => w.target).map(w => w.word)).toEqual(['xiqueta', 'menja', 'xocolata', 'cotxe.']);
  });

  it('marca les palatals dites com a [s] i diu quin so esperava (africada sencera) i quin ha sentit', () => {
    const result = scorePronunciation(fixture('xiqueta-malament'), PALATALS);
    expect(result).toMatchObject({ understood: true, score: 0, total: 4 });
    expect(failed(result)).toEqual(['xiqueta tʃ→s', 'menja dʒ→s', 'xocolata tʃ→s', 'cotxe. tʃ→s']);
  });

  it('marca la [j] de «plaia» però no castiga el ensordiment de «jove»', () => {
    const result = scorePronunciation(fixture('platja-malament'), PALATALS);
    expect(result.understood).toBe(true);
    expect(failed(result).map(f => f.split(' ')[0])).toEqual(['viatja', 'platja.']);
    expect(result.words.find(w => w.word === 'jove')?.ok).toBe(true);
  });

  it('entén una lectura real sencera encara que el PER passe de 0,7', () => {
    expect(scorePronunciation(fixture('platja-veu-real-per-alt'), PALATALS).understood).toBe(true);
  });

  it('no puntua una altra frase', () => {
    const result = scorePronunciation(fixture('xiqueta-altra-frase'), PALATALS);
    expect(result).toMatchObject({ understood: false, score: 0 });
  });

  it('amb diverses famílies, cada so es corregix amb la seua; la ll oïda com a [j] es dona per bona', () => {
    const phone = (ipa: string) => ({ ipa, confidence: 0.9, alternatives: [] });
    const op = (ref: string, hyp_j: number, word: number) => ({ ref, hyp_j, word });
    const response: PhoneticResponse = {
      phones: [phone('ʎ'), phone('j'), phone('l'), phone('ɾ')],
      alignment: {
        reference: [{ word: 'lluna', phones: ['ʎ'] }, { word: 'llibre', phones: ['ʎ'] }, { word: 'falla', phones: ['ʎ'] }, { word: 'carro', phones: ['r'] }],
        ops: [op('ʎ', 0, 0), op('ʎ', 1, 1), op('ʎ', 2, 2), op('r', 3, 3)],
        words: [{ word: 'lluna', cost: 0 }, { word: 'llibre', cost: 0.1 }, { word: 'falla', cost: 0.1 }, { word: 'carro', cost: 0.1 }],
        summary: { per: 0.5 },
      },
    };
    const result = scorePronunciation(response, [['ʎ'], ['r']]);
    expect(failed(result)).toEqual(['falla ʎ→l', 'carro r→ɾ']);
    expect(result).toMatchObject({ score: 2, total: 4 });
  });

  it('sense alineació no hi ha res a corregir', () => {
    expect(scorePronunciation({ alignment: null }, PALATALS)).toEqual({ understood: false, words: [], score: 0, total: 0 });
  });
});
