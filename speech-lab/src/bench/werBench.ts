/**
 * Bench de WER: passa cada WAV de `bench/samples/` pels proveïdors de lots i
 * compara amb el seu .txt de referència (mateix nom). És la peça que tanca la
 * fase 4: decidir amb dades si el model «small» de Vosk basta o cal Aina.
 *
 * Ús:
 *   npm run wer                        (tots els proveïdors, totes les mostres)
 *   npm run wer -- --provider aina     (només faster-whisper)
 *   npm run wer -- --words              (amb marques per paraula)
 *
 * El proveïdor `vosk-batch` no és streaming: reutilitza el sidecar de Vosk
 * enviant el WAV sencer i demanant el final (mateix truc que l'smoke).
 */
import { readdir, readFile } from 'node:fs/promises';
import path from 'node:path';
import { WebSocket } from 'ws';
import { getBatchStt } from '../batch/registry.js';
import { config, labRoot } from '../config.js';
import { readPcm16Wav } from './wav.js';
import { wordErrorRate } from './wer.js';

function parseArgs(argv: string[]): Record<string, string | boolean> {
  const result: Record<string, string | boolean> = {};
  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];
    if (!token.startsWith('--')) continue;
    const key = token.slice(2);
    const next = argv[index + 1];
    if (next === undefined || next.startsWith('--')) {
      result[key] = true;
    } else {
      result[key] = next;
      index += 1;
    }
  }
  return result;
}

/** Transcriu un WAV amb el sidecar de Vosk (per lots, via WebSocket + eof). */
async function transcribeVosk(wavPath: string): Promise<{ text: string; computeMs: number }> {
  const wav = readPcm16Wav(await readFile(wavPath));
  const url = `ws://localhost:${config.port}/ws/transcribe`;
  const socket = new WebSocket(url);
  const bytesPerChunk = Math.round((wav.sampleRate * 256) / 1000) * 2;

  return await new Promise((resolve, reject) => {
    let finalText = '';
    let computeMs = 0;
    socket.on('open', () => {
      socket.send(JSON.stringify({ config: { sample_rate: wav.sampleRate } }));
      for (let offset = 0; offset < wav.data.length; offset += bytesPerChunk) {
        socket.send(wav.data.subarray(offset, offset + bytesPerChunk));
      }
      socket.send(JSON.stringify({ eof: 1 }));
    });
    socket.on('message', (raw) => {
      const payload = JSON.parse(raw.toString()) as Record<string, unknown>;
      if (payload.type === 'final') {
        finalText = String(payload.text);
        computeMs = Number(payload.latencyMs ?? 0);
      } else if (payload.type === 'metrics') {
        socket.close();
        resolve({ text: finalText, computeMs });
      } else if (payload.type === 'error') {
        socket.close();
        reject(new Error(String(payload.message)));
      }
    });
    socket.on('error', (error) => reject(error));
  });
}

async function main(): Promise<number> {
  const args = parseArgs(process.argv.slice(2));
  const onlyProvider = typeof args.provider === 'string' ? args.provider : undefined;
  const withWords = args.words === true;

  const samplesDir = path.join(labRoot, 'bench', 'samples');
  const files = (await readdir(samplesDir)).filter((f) => f.endsWith('.wav')).sort();
  if (files.length === 0) {
    console.error('[wer] no hi ha mostres a bench/samples/*.wav');
    return 1;
  }

  // Proveïdors: lots directes + Vosk per WebSocket (cal el laboratori arrancat).
  const providers = onlyProvider ? [onlyProvider] : ['aina', 'vosk-batch'];
  let failures = 0;

  for (const file of files) {
    const wavPath = path.join(samplesDir, file);
    const refPath = wavPath.replace(/\.wav$/, '.txt');
    let reference: string;
    try {
      reference = (await readFile(refPath, 'utf8')).trim();
    } catch {
      console.log(`[wer] ${file}: sense ${path.basename(refPath)} (ground truth), se salta`);
      continue;
    }
    if (!reference) {
      console.log(`[wer] ${file}: referència buida, se salta`);
      continue;
    }

    for (const providerId of providers) {
      try {
        const started = Date.now();
        let text: string;
        let computeMs: number;
        let model = '';
        if (providerId === 'vosk-batch') {
          ({ text, computeMs } = await transcribeVosk(wavPath));
          model = 'vosk-model-small-ca-0.4';
        } else {
          const provider = getBatchStt(providerId);
          const wav = readPcm16Wav(await readFile(wavPath));
          const durationMs = (wav.data.length / 2 / wav.sampleRate) * 1000;
          void durationMs;
          const transcript = await provider.transcribe(wavPath, {
            language: 'ca',
            wordTimestamps: withWords,
          });
          text = transcript.text;
          computeMs = transcript.computeMs;
          model = provider.modelId;
        }
        const wallMs = Date.now() - started;
        const result = wordErrorRate(text, reference);
        console.log(
          `[wer] ${file} · ${providerId} (${model})`
          + ` → WER=${(result.wer * 100).toFixed(1)}%`
          + ` (S=${result.substitutions} D=${result.deletions} I=${result.insertions}/${result.refWords})`
          + ` compute=${Math.round(computeMs)}ms paret=${wallMs}ms`,
        );
        console.log(`      ref: "${reference}"`);
        console.log(`      hyp: "${text}"`);
      } catch (error) {
        failures += 1;
        console.error(
          `[wer] ${file} · ${providerId}: ${error instanceof Error ? error.message : String(error)}`,
        );
      }
    }
  }
  return failures === 0 ? 0 : 1;
}

process.exit(await main());
