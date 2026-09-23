import 'dotenv/config';
import http from 'node:http';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { WebSocketServer, type WebSocket } from 'ws';
import { z } from 'zod';
import { config } from './config.js';
import { getBatchStt, availableBatchProviders, disposeBatchProviders } from './batch/registry.js';
import { wordErrorRate } from './bench/wer.js';
import { readPcm16Wav } from './bench/wav.js';
import { logSummary, SessionMetrics } from './metrics.js';
import { availableProviders, disposeProviders, getStreamingStt } from './streaming/registry.js';
import { availableTtsProviders, disposeTtsProviders, getStreamingTts } from './tts/registry.js';
import type { StreamingSttSession } from './streaming/types.js';

/* ── Servidor HTTP: /health i la pàgina de proves ────────────────────────── */

const MIME_TYPES: Record<string, string> = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.wav': 'audio/wav',
};

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url ?? '/', `http://${req.headers.host ?? 'localhost'}`);

  // Registre de peticions: és el que permet comprovar que el navegador ha
  // arribat a demanar la pàgina quan alguna cosa no carrega.
  res.on('finish', () => {
    console.log(`[lab] ${req.method} ${url.pathname} → ${res.statusCode}`);
  });

  if (url.pathname === '/health') {
    res.writeHead(200, { 'content-type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify({
      ok: true,
      provider: config.provider,
      providers: availableProviders,
      batchProvider: config.batchProvider,
      batchProviders: availableBatchProviders,
      batchModel: process.env.AINA_MODEL_ID?.trim()
        || 'projecte-aina/faster-whisper-large-v3-ca-3catparla',
      ttsProvider: config.tts.provider,
      ttsProviders: availableTtsProviders,
      sampleRate: config.sampleRate,
    }));
    return;
  }

  // ── Transcripció automàtica: POST /api/transcribe ─────────────────────
  // Cos: WAV sencer (PCM16 mono 16 kHz, el format que ja entén el bench).
  // Resposta: text + segments + paraules + WER opcional (?reference=…).
  if (url.pathname === '/api/transcribe' && req.method === 'POST') {
    // Límit de 25 MB: prou per a minuts de veu a 16 kHz, prou curt per a no
    // penjar el laboratori amb una pujada gegant.
    const MAX_BYTES = 25 * 1024 * 1024;
    const chunks: Buffer[] = [];
    let received = 0;
    let tooLarge = false;
    req.on('data', (chunk: Buffer) => {
      received += chunk.length;
      if (received > MAX_BYTES) {
        tooLarge = true;
        return;
      }
      chunks.push(chunk);
    });
    req.on('end', () => {
      void (async () => {
        try {
          if (tooLarge) {
            res.writeHead(413, { 'content-type': 'application/json; charset=utf-8' })
              .end(JSON.stringify({ error: 'L\u2019àudio passa de 25 MB' }));
            return;
          }
          const body = Buffer.concat(chunks);
          let wav;
          try {
            wav = readPcm16Wav(body);
          } catch (error) {
            res.writeHead(400, { 'content-type': 'application/json; charset=utf-8' })
              .end(JSON.stringify({ error: error instanceof Error ? error.message : String(error) }));
            return;
          }

          const reference = url.searchParams.get('reference') ?? undefined;
          const providerId = url.searchParams.get('provider') ?? undefined;
          const provider = getBatchStt(providerId || undefined);

          const dir = await mkdtemp(path.join(tmpdir(), 'speech-lab-'));
          const wavPath = path.join(dir, 'audio.wav');
          try {
            await writeFile(wavPath, body);
            const started = Date.now();
            const transcript = await provider.transcribe(wavPath, {
              language: url.searchParams.get('language') ?? 'ca',
              wordTimestamps: url.searchParams.get('words') === '1',
            });
            const wallMs = Date.now() - started;
            const audioSecs = (wav.data.length / 2 / wav.sampleRate);
            console.log(
              `[transcribe] provider=${provider.id} model=${provider.modelId}`
              + ` audio=${audioSecs.toFixed(2)}s compute=${Math.round(transcript.computeMs)}ms`
              + ` paret=${wallMs}ms text="${transcript.text.slice(0, 80)}"`,
            );
            res.writeHead(200, { 'content-type': 'application/json; charset=utf-8' });
            res.end(JSON.stringify({
              provider: provider.id,
              model: provider.modelId,
              ...transcript,
              audioSecs: Number(audioSecs.toFixed(2)),
              wallMs,
              ...(reference !== undefined
                ? { wer: wordErrorRate(transcript.text, reference) }
                : {}),
            }));
          } finally {
            await rm(dir, { recursive: true, force: true });
          }
        } catch (error) {
          const message = error instanceof Error ? error.message : String(error);
          console.error('[transcribe] error:', message);
          res.writeHead(500, { 'content-type': 'application/json; charset=utf-8' })
            .end(JSON.stringify({ error: message }));
        }
      })();
    });
    return;
  }

  // ── Síntesi: POST /api/tts ───────────────────────────────────────────
  // Cos JSON: {text, voice?}. Resposta: WAV del proveïdor TTS actiu.
  if (url.pathname === '/api/tts' && req.method === 'POST') {
    const chunks: Buffer[] = [];
    req.on('data', (chunk: Buffer) => chunks.push(chunk));
    req.on('end', () => {
      void (async () => {
        try {
          let payload: unknown;
          try {
            payload = JSON.parse(Buffer.concat(chunks).toString('utf8'));
          } catch {
            res.writeHead(400, { 'content-type': 'application/json; charset=utf-8' })
              .end(JSON.stringify({ error: 'Cal un JSON amb {text}' }));
            return;
          }
          const parsed = ttsRequestSchema.safeParse(payload);
          if (!parsed.success) {
            res.writeHead(400, { 'content-type': 'application/json; charset=utf-8' })
              .end(JSON.stringify({ error: 'Cal un JSON amb {text} (i voice opcional)' }));
            return;
          }
          const provider = getStreamingTts();
          const result = await provider.synthesize(parsed.data.text, { voice: parsed.data.voice });
          console.log(
            `[tts] provider=${provider.id} voice=${result.voice}`
            + ` primer_byte=${result.firstByteMs}ms bytes=${result.audio.length}`,
          );
          res.writeHead(200, {
            'content-type': result.mimeType,
            'content-length': result.audio.length,
            'x-tts-voice': result.voice,
            'x-tts-first-byte-ms': String(result.firstByteMs),
          });
          res.end(result.audio);
        } catch (error) {
          const message = error instanceof Error ? error.message : String(error);
          console.error('[tts] error:', message);
          res.writeHead(502, { 'content-type': 'application/json; charset=utf-8' })
            .end(JSON.stringify({ error: message }));
        }
      })();
    });
    return;
  }

  const relative = url.pathname === '/' ? 'index.html' : decodeURIComponent(url.pathname.slice(1));
  const filePath = path.resolve(config.publicDir, relative);
  // La pàgina de proves només pot servir fitxers de public/.
  if (filePath !== config.publicDir && !filePath.startsWith(config.publicDir + path.sep)) {
    res.writeHead(403, { 'content-type': 'text/plain; charset=utf-8' }).end('Prohibit');
    return;
  }

  try {
    const body = await readFile(filePath);
    res.writeHead(200, {
      'content-type': MIME_TYPES[path.extname(filePath)] ?? 'application/octet-stream',
      // Sense caché: si no, el navegador servix el lab.js vell després d'una actualització.
      'cache-control': 'no-store',
    });
    res.end(body);
  } catch {
    res.writeHead(404, { 'content-type': 'text/plain; charset=utf-8' }).end('No trobat');
  }
});

/* ── WebSocket: àudio cap al proveïdor i resultats cap al client ─────────── */

const configMessageSchema = z.object({
  config: z.object({
    sample_rate: z.number().int().min(8000).max(48000).optional(),
    phrase_list: z.array(z.string().min(1)).max(5000).optional(),
    words: z.boolean().optional(),
  }),
});

const controlMessageSchema = z.union([configMessageSchema, z.object({ eof: z.literal(1) })]);

const ttsRequestSchema = z.object({
  text: z.string().min(1).max(2000),
  voice: z.string().min(1).max(64).optional(),
});

function safeJson(raw: string): unknown {
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

const wss = new WebSocketServer({ server, path: '/ws/transcribe' });

wss.on('connection', (socket: WebSocket) => {
  let session: StreamingSttSession | null = null;
  let metrics: SessionMetrics | null = null;
  let sampleRate = config.sampleRate;
  let logged = false;
  let hintSent = false;
  /** Inici de la sessió, per a comprovar que l'àudio arriba a ritme real. */
  let sessionStartedAt = Date.now();
  /** Encadena els missatges: la configuració ha d'obrir la sessió abans de l'àudio. */
  let queue: Promise<void> = Promise.resolve();

  console.log('[speech] client connectat al WebSocket');

  const send = (payload: unknown) => {
    if (socket.readyState === socket.OPEN) socket.send(JSON.stringify(payload));
  };

  send({ type: 'ready', provider: config.provider, sampleRate: config.sampleRate });

  const openSession = async (message: z.infer<typeof configMessageSchema>) => {
    if (session) return;
    sampleRate = message.config.sample_rate ?? config.sampleRate;

    const provider = getStreamingStt();
    const opened = await provider.open({
      sampleRate,
      phraseList: message.config.phrase_list,
      words: message.config.words,
    });
    session = opened;
    metrics = new SessionMetrics(provider.id);
    sessionStartedAt = Date.now();

    opened.on((transcript) => {
      metrics?.record(transcript);
      send({
        type: transcript.isFinal ? 'final' : 'partial',
        text: transcript.text,
        atMs: Math.round(transcript.atMs),
        latencyMs: Math.round(transcript.latencyMs),
      });
      // El text reconegut es guarda al registre: és l'evidència del laboratori
      // (què ha entés el motor amb veu real) i el que permet calcular el WER.
      if (transcript.isFinal) {
        console.log(`[speech] final: "${transcript.text}" (${Math.round(transcript.latencyMs)}ms de còmput)`);
      }
    });
    opened.onError((message_) => send({ type: 'error', message: message_ }));

    console.log(
      `[speech] sessió oberta: provider=${provider.id} sample_rate=${sampleRate}`
      + ` frases=${message.config.phrase_list?.length ?? 0}`,
    );
  };

  const finish = async (waitForFinal: boolean) => {
    const current = session;
    if (!current) return;
    session = null;

    if (waitForFinal) await current.end();
    else current.close();

    if (metrics && !logged) {
      logged = true;
      send({ type: 'metrics', ...metrics.snapshot() });
      logSummary(metrics);
      reportRate();
    }
  };

  /**
   * L'àudio ha d'arribar a ritme real: si `audioMs` se'n va molt de la durada de
   * la sessió, el resampling del client no quadra i el motor rep la parla a una
   * velocitat equivocada (transcripcions plausibles però falses).
   */
  const reportRate = () => {
    const sessionMs = Date.now() - sessionStartedAt;
    if (sessionMs < 500 || !metrics) return;
    const ratio = metrics.snapshot().audioMs / sessionMs;
    console.log(
      `[speech] ritme: àudio=${Math.round(metrics.snapshot().audioMs)}ms`
      + ` sessió=${sessionMs}ms (${ratio.toFixed(2)}×)`
      + (ratio > 2 || ratio < 0.2 ? ' ← AVÍS: ritme sospitós' : ''),
    );
  };

  socket.on('message', (data, isBinary) => {
    queue = queue.then(async () => {
      if (isBinary) {
        if (!session) {
          send({ type: 'error', message: 'Cal enviar la configuració abans de l’àudio' });
          return;
        }
        const chunk = Buffer.isBuffer(data) ? data : Buffer.from(data as ArrayBuffer);
        session.push(chunk);
        metrics?.recordAudio(chunk.length, sampleRate);
        metrics?.recordEnergy(chunk, sampleRate);
        // Un micro sense senyal (dispositiu equivocat, guany a 0…) és la causa
        // més comuna d'una sessió que "no escolta": avem al cap de 4 s, no al
        // final, i ho fem arribar també a la pàgina.
        if (metrics && !hintSent) {
          const snapshot = metrics.snapshot();
          if (snapshot.audioMs > 4000 && snapshot.partials === 0
            && snapshot.voicePct !== null && snapshot.voicePct < 10) {
            hintSent = true;
            console.warn(`[speech] avís: ${Math.round(snapshot.audioMs / 1000)}s d'àudio sense veu (nivell ${snapshot.avgDb} dBFS): micro sense senyal?`);
            send({
              type: 'hint',
              message: "No m'arriba senyal del micròfon: tria el dispositiu correcte o puja el nivell d'entrada.",
            });
          }
        }
        return;
      }

      const parsed = controlMessageSchema.safeParse(safeJson(data.toString()));
      if (!parsed.success) {
        send({ type: 'error', message: 'Missatge de control no vàlid' });
        return;
      }

      if ('eof' in parsed.data) {
        await finish(true);
        socket.close();
        return;
      }

      await openSession(parsed.data);
    }).catch((error: unknown) => {
      const message = error instanceof Error ? error.message : String(error);
      console.error('[speech] error de sessió:', message);
      send({ type: 'error', message });
    });
  });

  socket.on('close', () => {
    console.log('[speech] client desconnectat');
    void finish(false);
  });
});

/* ── Arrancada i tancament net ──────────────────────────────────────────── */

server.listen(config.port, () => {
  console.log(
    `[speech] laboratori de veu en temps real a http://localhost:${config.port}`
    + ` (provider=${config.provider}, sample_rate=${config.sampleRate})`,
  );
});

/**
 * El sidecar de Python és un procés fill: si no el matem explícitament,
 * `tsx watch` deixaria processos orfes a cada reinici.
 */
async function shutdown(): Promise<void> {
  console.log('[speech] aturant el laboratori…');
  for (const client of wss.clients) client.terminate();
  await Promise.all([disposeProviders(), disposeBatchProviders(), disposeTtsProviders()]);
  server.close(() => process.exit(0));
  setTimeout(() => process.exit(0), 2000).unref();
}

process.on('SIGINT', () => void shutdown());
process.on('SIGTERM', () => void shutdown());