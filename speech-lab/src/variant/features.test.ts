/**
 * Proves de la part textual i fonètica del detector (src/variant/features.ts).
 * Els valors esperats del text són els de `fetch.clean`, el plegat de
 * repeticions de `classify.py` i les marques lèxiques de `features.py`
 * (executats amb Python): les regles de `\w`, `\b` i `\s` de Python no són
 * les de JavaScript i és fàcil equivocar-se amb els accents.
 */
import { describe, expect, it } from 'vitest';
import { category, cleanText, collapseLoops, lexicalScore, posterior, referenceText, splitOps } from './features.js';

// [entrada, clean(), plegat, lex]
const TEXT_CASES: [string | null, string, string, number][] = [
  ['Hola, què tal?  Bé!', 'Hola què tal Bé', 'Hola què tal Bé', 0],
  ['l’aigua de l\'Horta', "l'aigua de l'Horta", "l'aigua de l'Horta", 0],
  ['ÉS «això» … 3,5 €', 'ÉS això 3 5', 'ÉS això 3 5', 0],
  ['i va dir que i va dir que i va dir que no', 'i va dir que i va dir que i va dir que no', 'i va dir que no', 0],
  ['aaaaaa aaaaaa aaaaaa', 'aaaaaa aaaaaa aaaaaa', 'aaaaaa', 0],
  ['este xiquet hui vol eixir; aquest nen avui vol sortir', 'este xiquet hui vol eixir aquest nen avui vol sortir',
    'este xiquet hui vol eixir aquest nen avui vol sortir', 0],
  ['Està bé, ESTA casa és meua', 'Està bé ESTA casa és meua', 'Està bé ESTA casa és meua', 2],
  ['meua meues seua teues dènou deset huit', 'meua meues seua teues dènou deset huit', 'meua meues seua teues dènou deset huit', 7],
  ['estes\tcoses\nnoves', 'estes coses noves', 'estes coses noves', 1],
  ['\x1cfoo\x85bar baz', 'foo bar baz', 'foo bar baz', 0],
  ['über_test ñ àèéíòóú ç', 'über_test ñ àèéíòóú ç', 'über_test ñ àèéíòóú ç', 0],
  ['a-b·c l·l', 'a-b·c l·l', 'a-b·c l·l', 0],
  ['pareix que siga així, faça el que puga', 'pareix que siga així faça el que puga', 'pareix que siga així faça el que puga', 4],
  ['el mateix el mateix el mateix', 'el mateix el mateix el mateix', 'el mateix', 0],
  ['la casa gran la casa gran', 'la casa gran la casa gran', 'la casa gran', 0],
  ['abcdef abcdefg', 'abcdef abcdefg', 'abcdef abcdefg', 0],
  ['estaven aquí', 'estaven aquí', 'estaven aquí', 0],
  ['nens i nenes', 'nens i nenes', 'nens i nenes', -1],
  [null, '', '', 0],
  ['', '', '', 0],
];

describe('text de referència', () => {
  it.each(TEXT_CASES)('neteja i plega %j com Python', (input, cleaned, collapsed, lex) => {
    expect(cleanText(input)).toBe(cleaned);
    expect(collapseLoops(cleaned)).toBe(collapsed);
    expect(referenceText(null, input)).toBe(collapsed);
    expect(lexicalScore(collapsed)).toBe(lex);
  });

  it('prefereix el text conegut al de Whisper', () => {
    expect(referenceText('Bon dia!', 'bon dia bon dia')).toBe('Bon dia');
  });
});

describe('fonemes', () => {
  it('suma les alternatives repetides en la probabilitat', () => {
    const d = posterior({
      ipa: 'ə', confidence: 0.6, start_s: 0, end_s: 0.1,
      alternatives: [{ ipa: 'a', prob: 0.2 }, { ipa: 'a', prob: 0.1 }, { ipa: 'ə', prob: 0.05 }],
    });
    expect(d.get('a')).toBeCloseTo(0.3, 12);
    expect(d.get('ə')).toBeCloseTo(0.65, 12);
  });

  it('classifica les diferències central / valenciana', () => {
    expect(category(['ə'], ['a'], false)).toBe('a_schwa');
    expect(category(['ə'], ['ɛ'], false)).toBe('e_schwa');
    expect(category(['u'], ['ɔ'], false)).toBe('o_u');
    expect(category(['ɛ'], ['e'], false)).toBe('mid_open');
    expect(category(['ʒ'], ['j'], false)).toBe('j_jo');
    expect(category([], ['ɾ'], true)).toBe('final_r');
    expect(category([], ['ɾ'], false)).toBe('other');
    expect(category(['k'], ['g'], false)).toBe('other');
  });

  it('parteix els replace multi-fonema d\'igual llargària', () => {
    expect(splitOps(['p', 'ə', 'r'], ['p', 'e', 'ɾ'])).toEqual([
      ['equal', 0, 1, 0, 1],
      ['replace', 1, 2, 1, 2],
      ['replace', 2, 3, 2, 3],
    ]);
  });
});
