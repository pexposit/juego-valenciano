/**
 * Port exacte de `difflib.SequenceMatcher(None, a, b, autojunk=…).get_opcodes()`
 * de Python 3.
 *
 * El detector compara la transcripció fonètica central i la valenciana de
 * cada paraula i mira on difereixen; les posicions han de coincidir amb les
 * del prototip en Python fil per fil, empats inclosos (el bloc més llarg més
 * a l'esquerra en `a` i, després, en `b`). Sense funció de brossa (`isjunk`
 * = None); l'heurística `autojunk` només actua amb seqüències de 200
 * elements o més i el detector la desactiva.
 */

export type OpcodeTag = 'replace' | 'delete' | 'insert' | 'equal';
/** `[tag, i1, i2, j1, j2]`: `a[i1:i2]` es convertix en `b[j1:j2]`. */
export type Opcode = [OpcodeTag, number, number, number, number];
type MatchBlock = [number, number, number];

export class SequenceMatcher<T> {
  private readonly b2j = new Map<T, number[]>();

  constructor(private readonly a: readonly T[], private readonly b: readonly T[], autojunk = true) {
    b.forEach((elt, i) => {
      const indices = this.b2j.get(elt);
      if (indices) indices.push(i);
      else this.b2j.set(elt, [i]);
    });
    // Elements «populars» (no brossa): Python els trau de b2j si n >= 200.
    const n = b.length;
    if (autojunk && n >= 200) {
      const ntest = Math.floor(n / 100) + 1;
      const popular = [...this.b2j].filter(([, idxs]) => idxs.length > ntest).map(([elt]) => elt);
      for (const elt of popular) this.b2j.delete(elt);
    }
  }

  /** Bloc comú més llarg dins de `a[alo:ahi]` i `b[blo:bhi]`. */
  findLongestMatch(alo: number, ahi: number, blo: number, bhi: number): MatchBlock {
    const { a, b, b2j } = this;
    let besti = alo;
    let bestj = blo;
    let bestsize = 0;
    let j2len = new Map<number, number>();
    for (let i = alo; i < ahi; i += 1) {
      const newj2len = new Map<number, number>();
      for (const j of b2j.get(a[i]) ?? []) {
        if (j < blo) continue;
        if (j >= bhi) break;
        const k = (j2len.get(j - 1) ?? 0) + 1;
        newj2len.set(j, k);
        if (k > bestsize) {
          besti = i - k + 1;
          bestj = j - k + 1;
          bestsize = k;
        }
      }
      j2len = newj2len;
    }
    // Sense brossa, només cal estendre amb els elements populars que
    // l'autojunk haja tret de b2j (els bucles de brossa de Python no fan res).
    while (besti > alo && bestj > blo && a[besti - 1] === b[bestj - 1]) {
      besti -= 1;
      bestj -= 1;
      bestsize += 1;
    }
    while (besti + bestsize < ahi && bestj + bestsize < bhi && a[besti + bestsize] === b[bestj + bestsize]) {
      bestsize += 1;
    }
    return [besti, bestj, bestsize];
  }

  getMatchingBlocks(): MatchBlock[] {
    const la = this.a.length;
    const lb = this.b.length;
    const queue: [number, number, number, number][] = [[0, la, 0, lb]];
    const blocks: MatchBlock[] = [];
    while (queue.length > 0) {
      const [alo, ahi, blo, bhi] = queue.pop()!;
      const x = this.findLongestMatch(alo, ahi, blo, bhi);
      const [i, j, k] = x;
      if (k) {
        blocks.push(x);
        if (alo < i && blo < j) queue.push([alo, i, blo, j]);
        if (i + k < ahi && j + k < bhi) queue.push([i + k, ahi, j + k, bhi]);
      }
    }
    blocks.sort((p, q) => p[0] - q[0] || p[1] - q[1] || p[2] - q[2]);

    // Ajunta blocs adjacents, com fa Python.
    let i1 = 0;
    let j1 = 0;
    let k1 = 0;
    const nonAdjacent: MatchBlock[] = [];
    for (const [i2, j2, k2] of blocks) {
      if (i1 + k1 === i2 && j1 + k1 === j2) {
        k1 += k2;
      } else {
        if (k1) nonAdjacent.push([i1, j1, k1]);
        [i1, j1, k1] = [i2, j2, k2];
      }
    }
    if (k1) nonAdjacent.push([i1, j1, k1]);
    nonAdjacent.push([la, lb, 0]);
    return nonAdjacent;
  }

  getOpcodes(): Opcode[] {
    let i = 0;
    let j = 0;
    const answer: Opcode[] = [];
    for (const [ai, bj, size] of this.getMatchingBlocks()) {
      let tag: OpcodeTag | '' = '';
      if (i < ai && j < bj) tag = 'replace';
      else if (i < ai) tag = 'delete';
      else if (j < bj) tag = 'insert';
      if (tag) answer.push([tag, i, ai, j, bj]);
      i = ai + size;
      j = bj + size;
      if (size) answer.push(['equal', ai, i, bj, j]);
    }
    return answer;
  }
}

/** Drecera: `SequenceMatcher(None, a, b, autojunk).get_opcodes()`. */
export function getOpcodes<T>(a: readonly T[], b: readonly T[], autojunk = true): Opcode[] {
  return new SequenceMatcher(a, b, autojunk).getOpcodes();
}
