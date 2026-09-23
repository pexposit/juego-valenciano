/**
 * Proveïdor de lots sobre el mateix sidecar de Vosk del streaming.
 *
 * Reutilitza la sessió WebSocket (`open` + WAV sencer + `eof`): és el mateix
 * truc que `bench/werBench.ts`, però ací com a `BatchStt` de primera classe
 * perquè `/api/transcribe?provider=vosk-batch` i el comparador A/B de la
 * pàgina el puguen usar sense cap via especial.
 */
import { WebSocket } from 'ws';
import { config } from '../config.js';
import type { BatchStt, BatchSttOptions, BatchTranscript } from './types.js';

/** Enviem el WAV en trossos de 256 ms (el mateix ritme que l'smoke). */
const CHUNK_MS = 256;

class VoskBatchStt implements BatchStt {
  readonly id = 'vosk-batch';
  readonly modelId = 'vosk-model-small-ca-0.4';

  async transcribe(wavPath: string, options: BatchSttOptions = {}): Promise<BatchTranscript> {
    const { readFile } = await import('node:fs/promises');
    const { readPcm16Wav } = await import('../bench/wav.js');
    const wav = readPcm16Wav(await readFile(wavPath));
    const started = Date.now();

    const url = `ws://localhost:${config.port}/ws/transcribe`;
    const bytesPerChunk = Math.round((wav.sampleRate * CHUNK_MS) / 1000) * 2;

    const { text, computeMs } = await new Promise<{ text: string; computeMs: number }>(
      (resolve, reject) => {
        const socket = new WebSocket(url);
        // Vosk talla els àudios llargs en diversos finals (endpointing): cal
        // concatenar-los tots, no quedar-se amb l'últim. Vist amb 30 s: el
        // primer final duu mitja frase i el segon la resta.
        const finals: string[] = [];
        let compute = 0;
        socket.on('open', () => {
          socket.send(JSON.stringify({ config: { sample_rate: wav.sampleRate } }));
          for (let offset = 0; offset < wav.data.length; offset += bytesPerChunk) {
            socket.send(wav.data.subarray(offset, offset + bytesPerChunk));
          }
          socket.send(JSON.stringify({ eof: 1 }));
        });
        socket.on('message', (raw) => {
          let payload: unknown;
          try {
            payload = JSON.parse(raw.toString());
          } catch {
            socket.close();
            reject(new Error('Resposta no vàlida del laboratori'));
            return;
          }
          const data = payload as Record<string, unknown>;
          if (data.type === 'final') {
            const text = String(data.text ?? '').trim();
            if (text) finals.push(text);
            compute += Number(data.latencyMs ?? 0);
          } else if (data.type === 'metrics') {
            socket.close();
            resolve({ text: finals.join(' '), computeMs: compute });
          } else if (data.type === 'error') {
            socket.close();
            reject(new Error(String(data.message ?? 'error del laboratori')));
          }
        });
        socket.on('error', (error) => reject(error));
      },
    );

    const audioSecs = wav.data.length / 2 / wav.sampleRate;
    return {
      text,
      language: options.language ?? 'ca',
      // Vosk per lots no dóna marques de temps: un sol segment sencer.
      segments: text ? [{ startMs: 0, endMs: Math.round(audioSecs * 1000), text }] : [],
      words: [],
      computeMs,
      audioSecs: Number(audioSecs.toFixed(2)),
    };
  }

  async dispose(): Promise<void> {
    // Sense procés propi: el sidecar el gestiona el proveïdor de streaming.
  }
}

/** Crea el proveïdor de lots sobre Vosk (sense estat: una instància val). */
export function createVoskBatchStt(): BatchStt {
  return new VoskBatchStt();
}
