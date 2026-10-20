/**
 * Paritat del detector amb `classify.py` del prototip.
 *
 * Els fixtures són frases sintetitzades amb espeak-ng (dues amb la veu
 * central `ca` i dues amb la valenciana `ca-va`, 16 kHz) i les respostes
 * reals de PhoneticXeus per a cada crida, desades una vegada. Els valors
 * esperats els ha calculat el prototip en Python amb les mateixes
 * respostes i els mateixos WAV. L'àudio sintètic NO és el domini del detector (les veus
 * sintètiques sonen centrals): ací només es comprova que els números
 * coincidixen.
 */
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { analyseRecording, scoreSegments, VariantSession, type SegmentEvidence } from './detector.js';
import type { PhoneticBackend, PhoneticResponse, TranscribeParams } from './phoneticApi.js';
import { decodeWav } from './segment.js';

const fixture = (name: string) => new URL(`./fixtures/${name}`, import.meta.url);
type Recorded = Record<string, { prompt: string; calls: { params: TranscribeParams; response: PhoneticResponse }[] }>;
type ExpectedRun = {
  text: string
  ev: Record<string, number[]>
  fm: Record<string, [number, number][]>
  d_per: number
  p: number
  verdict: string
  n_ae: number
  features: Record<string, number | null>
  contributions: Record<string, number>
};
const recorded = JSON.parse(readFileSync(fixture('espeak-responses.json'), 'utf8')) as Recorded;
const expected = JSON.parse(readFileSync(fixture('espeak-expected.json'), 'utf8')) as Record<string, Record<'free' | 'known', ExpectedRun>>
  & Record<string, { p: number; verdict: string; n_ae: number }>;
const CLIPS = ['central-1', 'central-2', 'valencia-1', 'valencia-2'];

/** Backend que contesta amb les respostes desades i apunta les crides. */
function replay(name: string, log: TranscribeParams[] = []): PhoneticBackend {
  return {
    async transcribe(audio, params) {
      expect(audio.filename).toMatch(/\.wav$/);
      log.push(params);
      const hit = recorded[name].calls.find((c) => JSON.stringify(c.params) === JSON.stringify(params));
      if (!hit) throw new Error(`Crida sense resposta desada: ${JSON.stringify(params)}`);
      return hit.response;
    },
  };
}

const close = (a: number | null, b: number | null, tol = 1e-9) => {
  if (a === null || b === null) return a === b;
  return Math.abs(a - b) <= tol * Math.max(1, Math.abs(b));
};

async function analyse(name: string, known: boolean): Promise<SegmentEvidence> {
  const [analysis] = await analyseRecording(readFileSync(fixture(`${name}.wav`)), {
    backend: replay(name),
    segment: false,
    filename: `${name}.wav`,
    referenceText: known ? recorded[name].prompt : null,
  });
  if (!analysis.ok) throw new Error(`Segment rebutjat: ${analysis.reason}`);
  return analysis.segment;
}

describe('detector: paritat amb classify.py', () => {
  for (const name of CLIPS) {
    for (const mode of ['free', 'known'] as const) {
      it(`${name} (${mode === 'free' ? 'parla lliure' : 'text conegut'})`, async () => {
        const want = expected[name][mode];
        const segment = await analyse(name, mode === 'known');
        expect(segment.text).toBe(want.text);
        expect(close(segment.dPer, want.d_per, 1e-12)).toBe(true);

        // Evidència fonètica: les mateixes categories, valors i ordre.
        expect(Object.keys(segment.evidence).sort()).toEqual(Object.keys(want.ev).sort());
        for (const [cat, values] of Object.entries(want.ev)) {
          const mine = segment.evidence[cat as keyof typeof segment.evidence]!;
          expect(mine).toHaveLength(values.length);
          values.forEach((v, i) => expect(close(mine[i], v, 1e-12)).toBe(true));
        }

        // Formants (LPC) a les mateixes vocals.
        expect(Object.keys(segment.formants).sort()).toEqual(Object.keys(want.fm).sort());
        for (const [cat, values] of Object.entries(want.fm)) {
          const mine = segment.formants[cat as keyof typeof segment.formants]!;
          expect(mine).toHaveLength(values.length);
          values.forEach(([f1, f2], i) => {
            expect(close(mine[i][0], f1, 1e-9)).toBe(true);
            expect(close(mine[i][1], f2, 1e-9)).toBe(true);
          });
        }

        const result = scoreSegments([segment]);
        expect(result.model).toBe(mode === 'free' ? 'with_lex' : 'no_lex');
        expect(result.nAe).toBe(want.n_ae);
        for (const [key, value] of Object.entries(want.features)) {
          // Amb text conegut el port no calcula la variable lèxica (el model no_lex no l'usa).
          if (key === 'lex' && mode === 'known') continue;
          expect(close(result.features[key as keyof typeof result.features], value, 1e-9), key).toBe(true);
        }
        for (const [key, value] of Object.entries(want.contributions)) {
          expect(close(result.contributions[key as keyof typeof result.contributions]!, value, 1e-9), key).toBe(true);
        }
        expect(close(result.pValencia, want.p, 1e-9)).toBe(true);
        expect(result.verdict).toBe(want.verdict);
      });
    }
  }

  it("ajunta l'evidència de dues gravacions abans de puntuar", async () => {
    for (const group of ['central', 'valencia']) {
      const session = new VariantSession({ segment: false });
      for (const n of [1, 2]) {
        const name = `${group}-${n}`;
        await session.addRecording(readFileSync(fixture(`${name}.wav`)), { backend: replay(name), filename: name });
      }
      const want = expected[`pooled-${group}`];
      const result = session.result();
      expect(result.nAe).toBe(want.n_ae);
      expect(close(result.pValencia, want.p, 1e-9)).toBe(true);
      expect(result.verdict).toBe(want.verdict);
      expect(result.usableSegments).toBe(2);
    }
  });
});

describe('detector: crides i descarts', () => {
  it('fa les tres crides de classify.py en ordre', async () => {
    const log: TranscribeParams[] = [];
    await analyseRecording(readFileSync(fixture('central-1.wav')), { backend: replay('central-1', log), segment: false });
    const text = expected['central-1'].free.text;
    expect(log).toEqual([
      { include_text: 'true', align: 'true', top_k: '5' },
      { align: 'true', g2p_language: 'ca', reference_text: text },
      { align: 'true', g2p_language: 'ca-va', variants: 'false', reference_text: text },
    ]);
  });

  it('amb text conegut no talla la gravació encara que siga llarga', async () => {
    // Quatre còpies amb 1 s de silenci entre elles: sense text es tallaria en trossos.
    const one = decodeWav(readFileSync(fixture('central-1.wav')));
    const gap = new Float32Array(one.sampleRate);
    const samples = new Float32Array((one.samples.length + gap.length) * 4);
    for (let i = 0; i < 4; i += 1) samples.set(one.samples, i * (one.samples.length + gap.length));
    expect(samples.length / one.sampleRate).toBeGreaterThan(15);
    const log: TranscribeParams[] = [];
    const names: string[] = [];
    const inner = replay('central-1', log);
    const backend: PhoneticBackend = {
      async transcribe(audio, params) { names.push(audio.filename); return inner.transcribe(audio, params); },
    };
    const analyses = await analyseRecording({ samples, sampleRate: one.sampleRate }, {
      backend, referenceText: recorded['central-1'].prompt,
    });
    expect(analyses).toHaveLength(1);
    expect(log).toHaveLength(3);
    expect(names).toEqual(['gravacio.wav', 'gravacio.wav', 'gravacio.wav']);
  });

  const wav = () => readFileSync(fixture('central-1.wav'));
  const backendWith = (patch: (params: TranscribeParams, original: PhoneticResponse) => PhoneticResponse): PhoneticBackend => {
    const inner = replay('central-1');
    return { async transcribe(audio, params) { return patch(params, await inner.transcribe(audio, params)); } };
  };

  it("rebutja el segment si l'API falla", async () => {
    const [a] = await analyseRecording(wav(), { backend: backendWith(() => ({ _status: 500 })), segment: false });
    expect(a).toMatchObject({ ok: false, reason: 'error-api', status: 500 });
  });

  it('rebutja el segment amb massa pocs fonemes', async () => {
    const backend = backendWith((p, r) => (p.include_text ? { ...r, phones: r.phones!.slice(0, 14) } : r));
    const [a] = await analyseRecording(wav(), { backend, segment: false });
    expect(a).toMatchObject({ ok: false, reason: 'pocs-fonemes' });
  });

  it('rebutja el segment si Whisper falla en parla lliure', async () => {
    const backend = backendWith((p, r) => (p.include_text ? { ...r, text_error: 'timeout', text_transcript: null } : r));
    const [a] = await analyseRecording(wav(), { backend, segment: false });
    expect(a).toMatchObject({ ok: false, reason: 'sense-text' });
  });

  it('rebutja el segment si el text no casa amb la veu (PER > 0,7)', async () => {
    const backend = backendWith((p, r) => (p.g2p_language === 'ca-va'
      ? { ...r, alignment: { ...r.alignment!, summary: { ...r.alignment!.summary, per: 0.71 } } }
      : r));
    const [a] = await analyseRecording(wav(), { backend, segment: false });
    expect(a).toMatchObject({ ok: false, reason: 'referencia-dubtosa' });
  });

  it('sense cap segment útil, el veredicte és indeterminat', () => {
    const result = scoreSegments([]);
    expect(result).toMatchObject({ verdict: 'indeterminat', reason: 'sense-veu-utilitzable', pValencia: null });
  });

  it('amb poques vocals àtones no decidix encara que la probabilitat siga clara', async () => {
    const segment = await analyse('valencia-1', false);
    const few: SegmentEvidence = { ...segment, evidence: { ...segment.evidence, a_schwa: [1, 1, 1], e_schwa: [1, 1] } };
    const result = scoreSegments([few]);
    expect(result.nAe).toBe(5);
    expect(result).toMatchObject({ verdict: 'indeterminat', reason: 'poca-evidencia' });
    expect(result.label).toBe('No es pot determinar la pronunciació');
  });

  it('suma la variable lèxica de tots els segments sense límit, com en l\'entrenament', async () => {
    const segment = await analyse('valencia-2', false);
    const result = scoreSegments([{ ...segment, lex: 9 }, { ...segment, lex: 3 }]);
    expect(result.features.lex).toBe(12);
  });
});
