/**
 * Proves de la peça d'unió del detector (servidor i CLI): remostreig,
 * anàlisi d'una gravació amb o sense text conegut, sessions amb caducitat i
 * límit, ping a l'API i textos de l'explicació. Sense xarxa: l'API és falsa
 * o reprodueix les respostes desades dels fixtures d'espeak.
 */
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { scoreSegments, type SegmentAnalysis } from './detector.js';
import type { PhoneticBackend, PhoneticResponse, TranscribeParams } from './phoneticApi.js';
import { decodeWav } from './segment.js';
import {
  analyseRecordingTimed, anyUnreachable, apiFailure, describeResult, describeSegment, explainContributions, pingPhoneticApi,
  REFERENCE_MAX_S, resampleTo, speechNotes, VariantSessionStore,
} from './service.js';

const fixture = (name: string) => new URL(`./fixtures/${name}`, import.meta.url);

/** To pur de `hz` a `rate` durant `seconds`. */
function tone(hz: number, rate: number, seconds: number, amplitude = 0.5): Float32Array {
  const out = new Float32Array(Math.round(rate * seconds));
  for (let i = 0; i < out.length; i += 1) out[i] = amplitude * Math.sin((2 * Math.PI * hz * i) / rate);
  return out;
}

const rms = (x: Float32Array, from = 0, to = x.length) => {
  let acc = 0;
  for (let i = from; i < to; i += 1) acc += x[i] * x[i];
  return Math.sqrt(acc / (to - from));
};

/** «Veu» sintètica: trossos de to separats per silencis, perquè el segmentador hi trobe parla. */
function burstyAudio(seconds: number, rate = 16000): Float32Array {
  const out = new Float32Array(Math.round(rate * seconds));
  for (let i = 0; i < out.length; i += 1) {
    const t = i / rate;
    out[i] = t % 2 < 1.6 ? 0.3 * Math.sin(2 * Math.PI * 220 * t) : 0;
  }
  return out;
}

/** API falsa que apunta les crides i contesta sempre el mateix. */
function fakeBackend(answer: PhoneticResponse) {
  const calls: { filename: string; params: TranscribeParams }[] = [];
  const backend: PhoneticBackend = {
    async transcribe(audio, params) {
      calls.push({ filename: audio.filename, params });
      return answer;
    },
  };
  return { backend, calls };
}

describe('remostreig a 16 kHz', () => {
  it('no toca un àudio que ja és a 16 kHz', () => {
    const audio = { samples: tone(440, 16000, 0.1), sampleRate: 16000 };
    expect(resampleTo(audio)).toBe(audio);
  });

  it('conserva un to dins de banda i en manté la durada', () => {
    const out = resampleTo({ samples: tone(1000, 44100, 1), sampleRate: 44100 });
    expect(out.sampleRate).toBe(16000);
    expect(Math.abs(out.samples.length - 16000)).toBeLessThanOrEqual(1);
    // Lluny de les vores, el nivell és el del to original (0,5 / √2).
    expect(rms(out.samples, 1000, 15000)).toBeCloseTo(0.5 / Math.SQRT2, 2);
  });

  it('filtra el que passa del Nyquist nou en lloc de replegar-ho', () => {
    // 11 kHz a 44,1 kHz es replegaria a 5 kHz amb una interpolació sense filtre.
    const out = resampleTo({ samples: tone(11000, 44100, 1), sampleRate: 44100 });
    expect(rms(out.samples, 1000, 15000)).toBeLessThan(0.01);
  });

  it('també puja de 8 kHz a 16 kHz', () => {
    const out = resampleTo({ samples: tone(500, 8000, 1), sampleRate: 8000 });
    expect(Math.abs(out.samples.length - 16000)).toBeLessThanOrEqual(1);
    expect(rms(out.samples, 1000, 15000)).toBeCloseTo(0.5 / Math.SQRT2, 2);
  });
});

describe("anàlisi d'una gravació", () => {
  it('amb text conegut puja la gravació sencera i dona el mateix que el prototip', async () => {
    const recorded = JSON.parse(readFileSync(fixture('espeak-responses.json'), 'utf8')) as Record<string, {
      prompt: string; calls: { params: TranscribeParams; response: PhoneticResponse }[]
    }>;
    const expected = JSON.parse(readFileSync(fixture('espeak-expected.json'), 'utf8')) as Record<string, { known: { p: number } }>;
    const backend: PhoneticBackend = {
      async transcribe(_audio, params) {
        const hit = recorded['valencia-1'].calls.find((c) => JSON.stringify(c.params) === JSON.stringify(params));
        if (!hit) throw new Error(`Crida sense resposta desada: ${JSON.stringify(params)}`);
        return hit.response;
      },
    };
    const audio = decodeWav(readFileSync(fixture('valencia-1.wav')));
    const run = await analyseRecordingTimed(audio, { backend, referenceText: recorded['valencia-1'].prompt });
    expect(run.usedReference).toBe(true);
    expect(run.analyses).toHaveLength(1);
    const [{ analysis }] = run.analyses;
    expect(analysis.ok).toBe(true);
    if (!analysis.ok) return;
    const result = scoreSegments([analysis.segment]);
    expect(result.model).toBe('no_lex');
    expect(result.pValencia).toBeCloseTo(expected['valencia-1'].known.p, 9);
  });

  it('amb text conegut i una gravació massa llarga, la tracta com a parla lliure i ho avisa', async () => {
    const { backend, calls } = fakeBackend({ _status: 200, phones: [] });
    const run = await analyseRecordingTimed(
      { samples: burstyAudio(REFERENCE_MAX_S + 6), sampleRate: 16000 },
      { backend, referenceText: 'bon dia' },
    );
    expect(run.usedReference).toBe(false);
    expect(run.notes[0]).toMatch(/parla lliure/);
    expect(run.analyses.length).toBeGreaterThan(1);
    expect(calls.every((c) => c.params.reference_text === undefined)).toBe(true);
    expect(run.analyses.every(({ analysis }) => !analysis.ok && analysis.reason === 'pocs-fonemes')).toBe(true);
  });

  it('puja fitxers amb nom .wav (mai `blob`)', async () => {
    const { backend, calls } = fakeBackend({ _status: 200, phones: [] });
    await analyseRecordingTimed({ samples: burstyAudio(8), sampleRate: 16000 }, { backend, filename: 'veu de prova.webm' });
    expect(calls.length).toBeGreaterThan(0);
    for (const call of calls) expect(call.filename).toMatch(/^veu_de_prova-\d+\.wav$/);
  });

  it("deixa d'insistir si l'API no respon i ho detecta com a fallada de l'API", async () => {
    const { backend, calls } = fakeBackend({ _status: -1, _error: 'fetch failed' });
    const run = await analyseRecordingTimed({ samples: burstyAudio(40), sampleRate: 16000 }, { backend });
    expect(calls).toHaveLength(1);
    expect(run.analyses).toHaveLength(1);
    expect(apiFailure(run.analyses)).toEqual({ status: -1 });
    expect(run.skipped).toBeGreaterThan(0);
  });

  it("si l'API deixa de respondre a mitja gravació, ho diu en una nota", async () => {
    let n = 0;
    const backend: PhoneticBackend = {
      // El primer segment respon (i es descarta per la veu); el segon ja no.
      async transcribe() { n += 1; return n === 1 ? { _status: 200, phones: [] } : { _status: -1, _error: 'fetch failed' }; },
    };
    const run = await analyseRecordingTimed({ samples: burstyAudio(40), sampleRate: 16000 }, { backend });
    expect(run.analyses).toHaveLength(2);
    expect(run.skipped).toBeGreaterThan(0);
    expect(apiFailure(run.analyses)).toBeNull();
    expect(anyUnreachable(run.analyses)).toBe(true);
    expect(run.notes.join(' ')).toMatch(/només s'han analitzat 2 de \d+ trossos/);
  });

  it('amb el senyal avortat no envia més segments', async () => {
    const controller = new AbortController();
    const backend: PhoneticBackend = {
      async transcribe() { controller.abort(); return { _status: 200, phones: [] }; },
    };
    const run = await analyseRecordingTimed(
      { samples: burstyAudio(40), sampleRate: 16000 }, { backend, signal: controller.signal },
    );
    expect(run.analyses).toHaveLength(1);
    expect(run.aborted).toBe(true);
    expect(run.notes).toEqual([]);
  });

  it('un segment rebutjat per la veu no és una fallada de l’API', () => {
    const rejected: SegmentAnalysis = { ok: false, startS: 0, endS: 3, reason: 'pocs-fonemes' };
    const api: SegmentAnalysis = { ok: false, startS: 3, endS: 6, reason: 'error-api', status: 500 };
    expect(apiFailure([{ analysis: rejected, ms: 1 }, { analysis: api, ms: 1 }])).toBeNull();
    expect(apiFailure([{ analysis: api, ms: 1 }])).toEqual({ status: 500 });
    expect(apiFailure([])).toBeNull();
    expect(describeSegment({ analysis: api, ms: 7 })).toMatchObject({ usable: false, reason: 'error-api', status: 500, ms: 7 });
  });
});

describe('sessions en memòria', () => {
  it('valida els identificadors', () => {
    expect(VariantSessionStore.validId('abc-123_X')).toBe(true);
    expect(VariantSessionStore.validId('')).toBe(false);
    expect(VariantSessionStore.validId('a b')).toBe(false);
    expect(VariantSessionStore.validId('x'.repeat(65))).toBe(false);
  });

  it('torna la mateixa sessió mentre no caduca, i una de nova després', () => {
    let now = 0;
    const store = new VariantSessionStore(1000, 10, () => now);
    const a = store.get('persona');
    a.recordings = 2;
    now = 900;
    expect(store.get('persona')).toBe(a);
    now = 1800; // 900 ms des de l'últim ús: encara viva
    expect(store.get('persona')).toBe(a);
    now = 3000;
    expect(store.get('persona')).not.toBe(a);
  });

  it('en passar del màxim cau la que fa més temps que no s’usa', () => {
    let now = 0;
    const store = new VariantSessionStore(60_000, 2, () => now);
    const a = store.get('a');
    now = 1;
    store.get('b');
    now = 2;
    store.get('a'); // «a» és ara la més recent
    now = 3;
    store.get('c');
    expect(store.size).toBe(2);
    expect(store.get('a')).toBe(a);
  });

  it('reiniciar buida l’evidència i el comptador', () => {
    const store = new VariantSessionStore();
    const entry = store.get('p');
    entry.recordings = 3;
    entry.session.addAnalyses([{ ok: false, startS: 0, endS: 1, reason: 'pocs-fonemes' }]);
    store.reset('p');
    expect(entry.recordings).toBe(0);
    expect(entry.session.analyses).toHaveLength(0);
  });
});

describe("ping a l'API fonètica", () => {
  it('llig el model i el dispositiu del /health', async () => {
    const fetchImpl = (async () => Response.json({ status: 'ok', model: 'PhoneticXeus', device: 'cuda:1' })) as unknown as typeof fetch;
    const ping = await pingPhoneticApi('http://api.test/', 1000, fetchImpl);
    expect(ping).toMatchObject({ ok: true, url: 'http://api.test', model: 'PhoneticXeus', device: 'cuda:1' });
  });

  it('torna l’error quan no hi ha xarxa', async () => {
    const fetchImpl = (async () => { throw new TypeError('fetch failed'); }) as unknown as typeof fetch;
    const ping = await pingPhoneticApi('http://api.test', 1000, fetchImpl);
    expect(ping.ok).toBe(false);
    if (!ping.ok) expect(ping.error).toMatch(/fetch failed/);
  });
});

describe('explicació del resultat', () => {
  const result = scoreSegments([{
    startS: 0, endS: 6, text: 'este matí eixirem hui',
    evidence: { a_schwa: [-1, -0.5, 0.2], e_schwa: [-0.3, 0.4], base_a: [-0.2], base_e: [-0.1] },
    formants: {}, dPer: 0.05, lex: 3,
  }]);

  it('ordena les contribucions pel pes i diu cap a on empenyen', () => {
    const items = explainContributions(result);
    expect(items.map((c) => c.feature).sort()).toEqual(['d_per', 'f1_a_rel', 'f1_ae', 'f2_ea', 'lex', 'norm_ae', 'norm_o_u']);
    for (let i = 1; i < items.length; i += 1) {
      expect(Math.abs(items[i - 1].contribution)).toBeGreaterThanOrEqual(Math.abs(items[i].contribution));
    }
    const lex = items.find((c) => c.feature === 'lex')!;
    expect(lex.value).toBe(3);
    expect(lex.towards).toBe('valencia');
    // Les variables sense mesura (formants) queden al farciment: no empenyen.
    expect(items.find((c) => c.feature === 'f1_ae')!.towards).toBeNull();
    expect(lex.text).toMatch(/Paraules marcadores/);
  });

  it('no fa veredicte amb poca evidència i ho explica', () => {
    const described = describeResult(result);
    expect(described.verdict).toBe('indeterminat');
    expect(described.reason).toBe('poca-evidencia');
    expect(described.reasonText).toMatch(/poques vocals/);
  });

  it('avisa quan hi ha poca veu', () => {
    expect(speechNotes(result, 2)[0]).toMatch(/massa curt/);
    expect(speechNotes(result, 6)[0]).toMatch(/orientatiu/);
    expect(speechNotes({ ...result, speechSeconds: 12 }, 12)).toEqual([]);
  });
});
