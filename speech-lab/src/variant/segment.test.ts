/**
 * Proves del tall en segments: veu sintètica (tons modulats) separada per
 * silencis, per a comprovar que els segments queden entre 3 i 15 s, que els
 * trossos curts s'ajunten i que els llargs es parteixen per un silenci.
 */
import { describe, expect, it } from 'vitest';
import { decodeWav, encodeWav, segmentSpeech } from './segment.js';

const SR = 16_000;

/** Concatena trossos de «veu» (to amb vibrato) i de silenci amb un soroll de fons fix. */
function build(parts: [kind: 'veu' | 'silenci', seconds: number][]): Float32Array {
  const total = parts.reduce((acc, [, s]) => acc + Math.round(s * SR), 0);
  const out = new Float32Array(total);
  let seed = 1;
  let at = 0;
  for (const [kind, seconds] of parts) {
    const n = Math.round(seconds * SR);
    for (let i = 0; i < n; i += 1) {
      seed = (seed * 1103515245 + 12345) % 2 ** 31;
      const noise = (seed / 2 ** 31 - 0.5) * 0.002;
      const t = (at + i) / SR;
      out[at + i] = noise + (kind === 'veu' ? 0.3 * Math.sin(2 * Math.PI * (180 + 30 * Math.sin(2 * Math.PI * 3 * t)) * t) : 0);
    }
    at += n;
  }
  return out;
}

describe('segmentSpeech', () => {
  it('ajunta frases curtes fins a passar de 3 s', () => {
    const samples = build([['silenci', 0.5], ['veu', 1.2], ['silenci', 0.6], ['veu', 1.5], ['silenci', 0.6], ['veu', 1.4], ['silenci', 0.5]]);
    const segments = segmentSpeech({ samples, sampleRate: SR });
    expect(segments).toHaveLength(1);
    const [s] = segments;
    expect(s.endS - s.startS).toBeGreaterThan(3);
    expect(s.startS).toBeGreaterThan(0.2);
  });

  it('parteix la veu llarga pels silencis sense passar de 15 s', () => {
    const parts: [('veu' | 'silenci'), number][] = [];
    for (let i = 0; i < 10; i += 1) parts.push(['veu', 3.5], ['silenci', 0.25]);
    const segments = segmentSpeech({ samples: build(parts), sampleRate: SR });
    expect(segments.length).toBeGreaterThanOrEqual(3);
    for (const s of segments) {
      expect(s.endS - s.startS).toBeLessThanOrEqual(15 + 1e-9);
      expect(s.endS - s.startS).toBeGreaterThanOrEqual(3);
    }
    // Cada tall cau en un silenci.
    for (const s of segments.slice(1)) {
      const k = Math.round(s.startS * SR);
      const around = s.samples.slice(0, 160);
      expect(Math.max(...Array.from(around, Math.abs)), `tall a ${s.startS}s (${k})`).toBeLessThan(0.01);
    }
  });

  it('descarta el silenci i els sorolls curts', () => {
    expect(segmentSpeech({ samples: build([['silenci', 3]]), sampleRate: SR })).toHaveLength(0);
    expect(segmentSpeech({ samples: build([['silenci', 1], ['veu', 0.3], ['silenci', 1]]), sampleRate: SR })).toHaveLength(0);
  });

  it('codifica cada segment com a WAV que es llig igual', () => {
    const samples = build([['veu', 4]]);
    const [s] = segmentSpeech({ samples, sampleRate: SR });
    const back = decodeWav(s.wav);
    expect(back.sampleRate).toBe(SR);
    expect(back.samples.length).toBe(s.samples.length);
    // int16 / 32768 anada i tornada: exacte per a mostres que ja venen de PCM16.
    const pcm = decodeWav(encodeWav(back.samples, SR)).samples;
    expect(Array.from(pcm)).toEqual(Array.from(back.samples));
  });
});
