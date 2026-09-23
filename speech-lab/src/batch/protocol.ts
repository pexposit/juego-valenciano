/**
 * Protocol del sidecar de transcripció per lots (`sidecar/whisper_batch.py`).
 *
 * A diferència del sidecar de Vosk (WebSocket persistent amb streaming), ací
 * el diàleg és una línia JSON per petició per l'stdin del procés i una línia
 * JSON per resposta per l'stdout (NDJSON). No cal cap port: el procés és fill
 * del servidor i mor amb ell. Els helpers estan aïllats per provar-los sense
 * arrancar Python, igual que `streaming/voskProtocol.ts`.
 *
 *   node → python:  {"wav_path": "/tmp/xxx.wav", "language": "ca",
 *                     "task": "transcribe", "word_timestamps": false}
 *   python → node:  {"text": "bon dia…", "language": "ca",
 *                     "segments": [{"start": 0.0, "end": 2.5, "text": "bon dia"}],
 *                     "words": [{"word": "bon", "start": 0.0, "end": 0.4}],
 *                     "compute_ms": 320.5, "audio_secs": 2.59}
 *   python → node (error): {"error": "no trobe el fitxer"}
 */

import type { BatchSttOptions, BatchTranscript } from './types.js';

export type BatchRequest = {
  wav_path: string
  language?: string
  task?: 'transcribe' | 'translate'
  word_timestamps?: boolean
};

export function buildBatchRequest(wavPath: string, options: BatchSttOptions = {}): string {
  const request: BatchRequest = { wav_path: wavPath };
  if (options.language) request.language = options.language;
  if (options.task) request.task = options.task;
  if (options.wordTimestamps !== undefined) request.word_timestamps = options.wordTimestamps;
  return JSON.stringify(request);
}

type RawSegment = { start?: unknown; end?: unknown; text?: unknown };
type RawWord = { word?: unknown; start?: unknown; end?: unknown; probability?: unknown };

function toNumber(value: unknown): number | null {
  return typeof value === 'number' && Number.isFinite(value) ? value : null;
}

/**
 * Tot el que no siga un nombre vàlid fa fallar la petició: un segment sense
 * marques de temps no servix per al bench de WER ni per a l'alineat.
 */
export function parseBatchResponse(raw: string): BatchTranscript {
  let payload: unknown;
  try {
    payload = JSON.parse(raw);
  } catch {
    throw new Error('El sidecar de lots ha respost un JSON no vàlid');
  }
  if (typeof payload !== 'object' || payload === null) {
    throw new Error('El sidecar de lots ha respost un missatge buit');
  }
  const data = payload as Record<string, unknown>;
  if (typeof data.error === 'string') throw new Error(data.error);
  if (typeof data.text !== 'string') {
    throw new Error(`Resposta desconeguda del sidecar de lots: ${raw.slice(0, 120)}`);
  }

  const segments: BatchTranscript['segments'] = [];
  if (Array.isArray(data.segments)) {
    for (const item of data.segments as RawSegment[]) {
      const start = toNumber(item.start);
      const end = toNumber(item.end);
      if (start === null || end === null || typeof item.text !== 'string') {
        throw new Error(`Segment sense marques vàlides: ${JSON.stringify(item).slice(0, 120)}`);
      }
      segments.push({ startMs: Math.round(start * 1000), endMs: Math.round(end * 1000), text: item.text });
    }
  }

  const words: BatchTranscript['words'] = [];
  if (Array.isArray(data.words)) {
    for (const item of data.words as RawWord[]) {
      const start = toNumber(item.start);
      const end = toNumber(item.end);
      if (start === null || end === null || typeof item.word !== 'string') {
        throw new Error(`Paraula sense marques vàlides: ${JSON.stringify(item).slice(0, 120)}`);
      }
      const probability = toNumber(item.probability);
      words.push({
        word: item.word,
        startMs: Math.round(start * 1000),
        endMs: Math.round(end * 1000),
        ...(probability === null ? {} : { probability }),
      });
    }
  }

  const computeMs = toNumber(data.compute_ms);
  const audioSecs = toNumber(data.audio_secs);
  if (computeMs === null || audioSecs === null) {
    throw new Error('La resposta de lots no duu compute_ms o audio_secs');
  }

  return {
    text: data.text,
    language: typeof data.language === 'string' ? data.language : undefined,
    segments,
    words,
    computeMs,
    audioSecs,
  };
}
