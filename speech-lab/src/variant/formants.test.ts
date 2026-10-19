/**
 * Paritat de la mesura de formants amb `formants.py` del prototip sobre
 * vocals sintètiques (polsos glotals per ressonadors F1/F2/F3, generades i
 * mesurades amb Python): `np.roots`, `formants()` i `measure()`.
 */
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { frameFormants, measureFormants, polyRoots } from './formants.js';
import { decodeWav } from './segment.js';

type Expected = {
  measure: { t: number; m: [number, number] | null }[]
  frames: { t: number; frame10: number[]; formants: number[] | null }[]
  polys: { p: number[]; roots: [number, number][] }[]
};
const fixture = (name: string) => new URL(`./fixtures/${name}`, import.meta.url);
const expected = JSON.parse(readFileSync(fixture('formants-expected.json'), 'utf8')) as Expected;

const relDiff = (a: number, b: number) => Math.abs(a - b) / Math.max(1e-12, Math.abs(b));

describe('formants (port de formants.py)', () => {
  it('troba les mateixes arrels que np.roots', () => {
    for (const { p, roots } of expected.polys) {
      const mine = polyRoots(p);
      expect(mine).toHaveLength(roots.length);
      // Aparella cada arrel de Python amb la més pròxima (l'ordre pot variar).
      const left = [...mine];
      for (const [re, im] of roots) {
        let best = 0;
        left.forEach((z, i) => {
          if (Math.hypot(z.re - re, z.im - im) < Math.hypot(left[best].re - re, left[best].im - im)) best = i;
        });
        const z = left.splice(best, 1)[0];
        expect(Math.hypot(z.re - re, z.im - im)).toBeLessThan(1e-9);
        // Les reals han de ser reals de veritat (el filtre és `imag > 0`).
        if (im === 0) expect(z.im).toBe(0);
      }
    }
  });

  it('dona els mateixos formants per tros que formants()', () => {
    for (const { frame10, formants } of expected.frames) {
      const mine = frameFormants(frame10, 10_000, 12);
      if (formants === null) {
        expect(mine).toBeNull();
        continue;
      }
      expect(mine).toHaveLength(formants.length);
      mine!.forEach((f, i) => expect(relDiff(f, formants[i])).toBeLessThan(1e-9));
    }
  });

  it('mesura F1/F2 com measure() al llarg de tot el senyal', () => {
    const { samples, sampleRate } = decodeWav(readFileSync(fixture('vowels.wav')));
    let measured = 0;
    for (const { t, m } of expected.measure) {
      const mine = measureFormants(samples, sampleRate, t);
      if (m === null) {
        expect(mine, `t=${t}`).toBeNull();
        continue;
      }
      measured += 1;
      expect(mine, `t=${t}`).not.toBeNull();
      expect(relDiff(mine![0], m[0])).toBeLessThan(1e-9);
      expect(relDiff(mine![1], m[1])).toBeLessThan(1e-9);
    }
    expect(measured).toBeGreaterThan(100);
  });

  it('recupera aproximadament els formants sintètics', () => {
    const { samples, sampleRate } = decodeWav(readFileSync(fixture('vowels.wav')));
    const [f1, f2] = measureFormants(samples, sampleRate, 0.15)!; // vocal /a/: 750 / 1300 Hz
    expect(f1).toBeGreaterThan(650);
    expect(f1).toBeLessThan(850);
    expect(f2).toBeGreaterThan(1150);
    expect(f2).toBeLessThan(1450);
  });
});
