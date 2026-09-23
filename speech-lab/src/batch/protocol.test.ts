/**
 * Pruebas del protocolo del sidecar de lots (src/batch/protocol.ts).
 *
 * Igual que amb Vosk: el sidecar és un procés de Python i estos tests fixen
 * el contracte sense arrancar-lo. El punt delicat és que les marques de
 * temps han de ser nombres vàlids: un segment sense temps no servix ni per
 * al bench de WER ni per a resaltar la transcripció a la pàgina.
 */
import { describe, expect, it } from 'vitest';
import { buildBatchRequest, parseBatchResponse } from './protocol.js';

describe('buildBatchRequest', () => {
  it('envia la ruta del wav i res més per defecte', () => {
    expect(JSON.parse(buildBatchRequest('/tmp/a.wav'))).toEqual({ wav_path: '/tmp/a.wav' });
  });

  it('inclou idioma, tasca i marques per paraula quan es demanen', () => {
    expect(JSON.parse(buildBatchRequest('/tmp/a.wav', {
      language: 'ca',
      task: 'transcribe',
      wordTimestamps: true,
    }))).toEqual({
      wav_path: '/tmp/a.wav',
      language: 'ca',
      task: 'transcribe',
      word_timestamps: true,
    });
  });
});

describe('parseBatchResponse', () => {
  const ok = JSON.stringify({
    text: 'bon dia',
    language: 'ca',
    segments: [{ start: 0.0, end: 2.5, text: 'bon dia' }],
    words: [{ word: 'bon', start: 0.0, end: 0.4, probability: 0.9 }],
    compute_ms: 320.5,
    audio_secs: 2.59,
  });

  it('convertix segons a mil·lisegons arrodonits', () => {
    expect(parseBatchResponse(ok)).toEqual({
      text: 'bon dia',
      language: 'ca',
      segments: [{ startMs: 0, endMs: 2500, text: 'bon dia' }],
      words: [{ word: 'bon', startMs: 0, endMs: 400, probability: 0.9 }],
      computeMs: 320.5,
      audioSecs: 2.59,
    });
  });

  it('accepta respostes sense segments ni paraules', () => {
    const transcript = parseBatchResponse(JSON.stringify({
      text: 'hui', compute_ms: 10, audio_secs: 1.0,
    }));
    expect(transcript.segments).toEqual([]);
    expect(transcript.words).toEqual([]);
    expect(transcript.language).toBeUndefined();
  });

  it('omet la probabilitat quan no és un nombre', () => {
    const transcript = parseBatchResponse(JSON.stringify({
      text: 'hui',
      words: [{ word: 'hui', start: 0, end: 0.5, probability: 'alta' }],
      compute_ms: 10,
      audio_secs: 1.0,
    }));
    expect(transcript.words).toEqual([{ word: 'hui', startMs: 0, endMs: 500 }]);
  });

  it('propaga els errors del sidecar', () => {
    expect(() => parseBatchResponse('{"error": "no trobe el fitxer"}'))
      .toThrow('no trobe el fitxer');
  });

  it('rebutja segments sense marques de temps', () => {
    expect(() => parseBatchResponse(JSON.stringify({
      text: 'hui',
      segments: [{ text: 'hui' }],
      compute_ms: 10,
      audio_secs: 1.0,
    }))).toThrow(/marques/);
  });

  it('rebutja respostes sense compute_ms', () => {
    expect(() => parseBatchResponse(JSON.stringify({ text: 'hui', audio_secs: 1.0 })))
      .toThrow(/compute_ms/);
  });

  it('falla amb un JSON invàlid', () => {
    expect(() => parseBatchResponse('no és json')).toThrow(/JSON no vàlid/);
  });
});
