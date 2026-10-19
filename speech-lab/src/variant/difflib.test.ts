/**
 * Proves del port de difflib: els opcodes han de ser idèntics als de Python
 * (`SequenceMatcher(None, a, b, autojunk).get_opcodes()`), empats inclosos.
 * El fixture el genera Python amb seqüències de fonemes aleatòries, casos
 * tramposos i seqüències de més de 200 elements (on actua l'autojunk).
 */
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { getOpcodes, type Opcode } from './difflib.js';

type Case = { a: string[]; b: string[]; autojunk: boolean; ops: Opcode[] };
const cases = JSON.parse(readFileSync(new URL('./fixtures/difflib-expected.json', import.meta.url), 'utf8')) as Case[];

describe('getOpcodes (port de difflib)', () => {
  it('coincidix amb Python en tots els casos del fixture', () => {
    const wrong = cases.filter((c) => JSON.stringify(getOpcodes(c.a, c.b, c.autojunk)) !== JSON.stringify(c.ops));
    expect(cases.length).toBeGreaterThan(400);
    expect(wrong).toEqual([]);
  });

  it("inclou seqüències llargues on l'autojunk canvia el resultat", () => {
    const long = cases.filter((c) => c.b.length >= 200);
    expect(long.length).toBeGreaterThan(0);
    for (const c of long) expect(getOpcodes(c.a, c.b, c.autojunk)).toEqual(c.ops);
  });

  it('parteix ə r → e ɾ en un replace de dos', () => {
    expect(getOpcodes(['p', 'ə', 'r'], ['p', 'e', 'ɾ'], false)).toEqual([
      ['equal', 0, 1, 0, 1],
      ['replace', 1, 3, 1, 3],
    ]);
  });
});
