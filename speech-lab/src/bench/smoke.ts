/**
 * Prova de fum: envia un WAV PCM16 pel WebSocket del laboratori i mostra els
 * resultats parcials, el final i les mètriques de la sessió. Servix per a
 * validar tota la canonada (navegador → servidor → Vosk) sense micròfon.
 *
 * Ús:
 *   npm run smoke -- --wav bench/samples/salutacio-gina-16k.wav
 *   npm run smoke -- --wav … --phrases "bon dia|com et puc ajudar hui"
 *   npm run smoke -- --wav … --pace        (envia a temps real, com el micròfon)
 */
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { WebSocket } from 'ws';
import { config, labRoot } from '../config.js';
import { readPcm16Wav } from './wav.js';

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

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

async function main(): Promise<number> {
  const args = parseArgs(process.argv.slice(2));
  const wavPath = path.resolve(labRoot, (args.wav as string) ?? 'bench/samples/salutacio-gina-16k.wav');
  const url = (args.url as string) ?? `ws://localhost:${config.port}/ws/transcribe`;
  const chunkMs = Number(args['chunk-ms'] ?? 256);
  const pace = args.pace === true;
  const phrases = typeof args.phrases === 'string'
    ? args.phrases.split('|').map((phrase) => phrase.trim()).filter(Boolean)
    : undefined;

  const wav = readPcm16Wav(await readFile(wavPath));
  const durationMs = (wav.data.length / 2 / wav.sampleRate) * 1000;
  console.log(
    `[smoke] ${path.relative(labRoot, wavPath)} · ${wav.sampleRate} Hz · ${(durationMs / 1000).toFixed(2)} s`
    + ` · chunk=${chunkMs}ms · ${pace ? 'temps real' : 'el més ràpid possible'}`,
  );

  const socket = new WebSocket(url);
  const bytesPerChunk = Math.round((wav.sampleRate * chunkMs) / 1000) * 2;
  const startedAt = Date.now();
  let firstPartialLogged = false;
  let finalText = '';

  return await new Promise<number>((resolve) => {
    const done = (code: number) => {
      socket.removeAllListeners();
      socket.close();
      resolve(code);
    };

    socket.on('open', () => {
      void (async () => {
        socket.send(JSON.stringify({
          config: { sample_rate: wav.sampleRate, ...(phrases ? { phrase_list: phrases } : {}) },
        }));

        for (let offset = 0; offset < wav.data.length; offset += bytesPerChunk) {
          const chunk = wav.data.subarray(offset, offset + bytesPerChunk);
          if (pace) await sleep((chunk.length / 2 / wav.sampleRate) * 1000);
          socket.send(chunk);
        }
        socket.send(JSON.stringify({ eof: 1 }));
      })();
    });

    socket.on('message', (raw) => {
      const payload = JSON.parse(raw.toString()) as Record<string, unknown>;
      if (payload.type === 'ready') {
        console.log(`[smoke] connectat (provider=${payload.provider})`);
        return;
      }
      if (payload.type === 'error') {
        console.error(`[smoke] error: ${payload.message}`);
        done(1);
        return;
      }
      if (payload.type === 'partial') {
        if (!firstPartialLogged) {
          firstPartialLogged = true;
          console.log(`[smoke] primer parcial a ${payload.atMs} ms`);
        }
        console.log(`  ~ ${payload.text}  (còmput=${payload.latencyMs}ms)`);
        return;
      }
      if (payload.type === 'final') {
        finalText = String(payload.text);
        console.log(`  ✓ ${finalText}  (a ${payload.atMs} ms, còmput=${payload.latencyMs}ms)`);
        return;
      }
      if (payload.type === 'metrics') {
        console.log(
          `[smoke] resum: audio=${payload.audioMs}ms còmput=${payload.computeMs}ms rtf=${payload.rtf}`
          + ` primer_parcial=${payload.firstPartialMs}ms final=${payload.finalMs}ms`,
        );
        console.log(`[smoke] text final: "${finalText}"`);
        done(finalText ? 0 : 1);
      }
    });

    socket.on('error', (error) => {
      console.error(`[smoke] no hem pogut connectar amb ${url}: ${error.message}`);
      console.error('[smoke] el servidor està arrancat? (npm run dev:speech)');
      resolve(1);
    });

    socket.on('close', () => {
      console.log(`[smoke] sessió tancada després de ${Date.now() - startedAt} ms`);
      resolve(finalText ? 0 : 1);
    });
  });
}

process.exit(await main());
