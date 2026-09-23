/**
 * Prova de fum: envia un WAV PCM16 pel WebSocket del laboratori i mostra els
 * resultats parcials, el final i les mètriques de la sessió. Servix per a
 * validar tota la canonada (navegador → servidor → Vosk) sense micròfon.
 *
 * Ús:
 *   npm run smoke -- --wav bench/samples/salutacio-gina-16k.wav
 *   npm run smoke -- --wav … --phrases "bon dia|com et puc ajudar hui"
 *   npm run smoke -- --wav … --pace        (envia a temps real, com el micròfon)
 *
 * També cobreix els endpoints nous de la fase A/B sense navegador:
 *   npm run smoke -- --api-transcribe --wav … [--provider aina]
 *   npm run smoke -- --api-tts --text "Bon dia" [--voice gina]
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
  if (args['api-transcribe'] === true) return smokeTranscribe(args);
  if (args['api-tts'] === true) return smokeTts(args);
  return smokeStreaming(args);
}

/** POST /api/transcribe amb el WAV tal qual (el que envia la pàgina). */
async function smokeTranscribe(args: Record<string, string | boolean>): Promise<number> {
  const wavPath = path.resolve(labRoot, (args.wav as string) ?? 'bench/samples/salutacio-gina-16k.wav');
  const base = (args.url as string) ?? `http://localhost:${config.port}`;
  const provider = typeof args.provider === 'string' ? args.provider : 'aina';
  const body = await readFile(wavPath);

  console.log(`[smoke] POST ${base}/api/transcribe?provider=${provider} (${body.length} bytes)`);
  const response = await fetch(`${base}/api/transcribe?provider=${provider}&words=1`, {
    method: 'POST',
    headers: { 'content-type': 'audio/wav' },
    body,
    signal: AbortSignal.timeout(300_000),
  });
  const payload = await response.json() as Record<string, unknown>;
  if (!response.ok) {
    console.error(`[smoke] error ${response.status}: ${payload.error}`);
    return 1;
  }
  const segments = payload.segments as Array<{ text?: string }>;
  console.log(`[smoke] text: "${payload.text}"`);
  console.log(
    `[smoke] provider=${payload.provider} model=${payload.model}`
    + ` compute=${payload.computeMs}ms audio=${payload.audioSecs}s`
    + ` segments=${segments.length}`,
  );
  const okText = typeof payload.text === 'string' && payload.text.length > 0;
  const okSegments = Array.isArray(segments) && segments.length > 0;
  console.log(okText && okSegments ? '[smoke] OK: text + segments' : '[smoke] FALTA text o segments');
  return okText && okSegments ? 0 : 1;
}

/** POST /api/tts: comprova que torna un WAV vàlid. */
async function smokeTts(args: Record<string, string | boolean>): Promise<number> {
  const base = (args.url as string) ?? `http://localhost:${config.port}`;
  const text = (args.text as string) ?? 'Bon dia! Com et puc ajudar hui?';
  const voice = (args.voice as string) ?? 'gina';

  console.log(`[smoke] POST ${base}/api/tts voice=${voice} text="${text.slice(0, 40)}"`);
  const response = await fetch(`${base}/api/tts`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ text, voice }),
    signal: AbortSignal.timeout(120_000),
  });
  if (!response.ok) {
    const detail = await response.json().catch(() => ({}));
    console.error(`[smoke] error ${response.status}: ${(detail as { error?: string }).error}`);
    return 1;
  }
  const audio = Buffer.from(await response.arrayBuffer());
  const isWav = audio.subarray(0, 4).toString('ascii') === 'RIFF';
  console.log(
    `[smoke] ${audio.length} bytes (${response.headers.get('content-type')})`
    + ` voice=${response.headers.get('x-tts-voice')} primer_byte=${response.headers.get('x-tts-first-byte-ms')}ms`,
  );
  console.log(isWav ? '[smoke] OK: WAV vàlid' : '[smoke] FALTA capçalera RIFF');
  return isWav ? 0 : 1;
}

async function smokeStreaming(args: Record<string, string | boolean>): Promise<number> {
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
