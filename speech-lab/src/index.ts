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
import { disposeLocalTts, localTtsModels, synthesizeLocal, TtsRequestError } from './tts/local.js';
import type { StreamingSttSession } from './streaming/types.js';
import { VariantSession } from './variant/detector.js';
import { decodeWav } from './variant/segment.js';
import {
  analyseRecordingTimed, anyUnreachable, apiFailure, describeResult, describeSegment, MAX_INPUT_RATE, MIN_INPUT_RATE,
  PHONETIC_HINT, pingPhoneticApi, resampleTo, speechNotes, TARGET_RATE, VariantSessionStore, type PingResult,
} from './variant/service.js';

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
      // Sense ping ací (seria lent si l'API no respon): /api/variant/health el fa.
      phoneticApi: config.phonetic.baseUrl,
    }));
    return;
  }

  // ── Detector de variant: GET /api/variant/health ─────────────────────
  // Comprova que l'API fonètica de la UJI respon.
  if (url.pathname === '/api/variant/health' && req.method === 'GET') {
    const ping = await pingPhoneticApi();
    rememberPing(ping);
    res.writeHead(ping.ok ? 200 : 502, { 'content-type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify(ping.ok ? ping : { ...ping, hint: PHONETIC_HINT }));
    return;
  }

  // ── Detector de variant: POST /api/variant ───────────────────────────
  // Cos: WAV PCM16 (qualsevol freqüència: es remostreja a 16 kHz).
  // ?ref=… text llegit (model sense lèxic) · ?session=… acumula l'evidència
  // de la mateixa persona entre peticions · ?reset=1 buida la sessió (sense
  // cos, només reinicia). Resposta: veredicte, contribucions i segments.
  if (url.pathname === '/api/variant' && req.method === 'POST') {
    // La lectura del cos també va dins del `.catch`: si el client talla la
    // pujada (tanca la pestanya), `readBody` falla i no ha de tombar el procés.
    void readBody(req, MAX_UPLOAD_BYTES).then((body) => handleVariant(url, body, res)).catch((error: unknown) => {
      const message = error instanceof Error ? error.message : String(error);
      if (req.destroyed || res.destroyed) {
        console.warn(`[variant] el client ha tallat la connexió: ${message}`);
        return;
      }
      console.error('[variant] error:', message);
      if (!res.headersSent) {
        res.writeHead(500, { 'content-type': 'application/json; charset=utf-8' })
          .end(JSON.stringify({ error: message }));
      }
    });
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

  // ── Catàleg de models de l'apartat «Generació d'àudio» ──────────────
  if (url.pathname === '/api/tts/models' && req.method === 'GET') {
    res.writeHead(200, { 'content-type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify({ models: localTtsModels() }));
    return;
  }

  // ── Síntesi: POST /api/tts ───────────────────────────────────────────
  // Cos JSON: {text, voice?} → WAV del proveïdor TTS actiu (el que usa el
  // mode trucada). Amb `model` (id de /api/tts/models) genera amb aquell
  // model: remot, Matxa local, un fine-tune, una veu derivada o un personatge RVC.
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
          if (parsed.data.model) {
            const { model, ...options } = parsed.data;
            const started = Date.now();
            const result = await synthesizeLocal({ ...options, model });
            const totalMs = Date.now() - started;
            console.log(
              `[tts] model=${result.model}${result.checkpoint ? `@${result.checkpoint}` : ''}`
              + ` total=${totalMs}ms matxa=${Math.round(result.matxaMs)}ms`
              + `${result.rvcMs !== undefined ? ` rvc=${Math.round(result.rvcMs)}ms` : ''}`
              + ` àudio=${result.audioSecs}s${result.cached ? '' : ' (càrrega del model)'}`,
            );
            res.writeHead(200, {
              'content-type': 'audio/wav',
              'content-length': result.audio.length,
              'x-tts-model': result.model,
              'x-tts-checkpoint': result.checkpoint ?? '',
              'x-tts-total-ms': String(totalMs),
              'x-tts-matxa-ms': String(Math.round(result.matxaMs)),
              'x-tts-rvc-ms': result.rvcMs !== undefined ? String(Math.round(result.rvcMs)) : '',
              'x-tts-audio-secs': String(result.audioSecs),
              'x-tts-cached': result.cached ? '1' : '0',
            });
            res.end(result.audio);
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
          res.writeHead(error instanceof TtsRequestError ? 400 : 502, { 'content-type': 'application/json; charset=utf-8' })
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

/* ── Detector de variant (valencià / central) ───────────────────────────── */

/** Mateix límit que /api/transcribe: prou per a minuts de veu, no per a penjar el laboratori. */
const MAX_UPLOAD_BYTES = 25 * 1024 * 1024;

/**
 * Llig el cos sencer. Si passa del límit torna de seguida amb `tooLarge`
 * (per a contestar 413 sense esperar) i la resta es descarta sense guardar-la.
 */
function readBody(req: http.IncomingMessage, maxBytes: number): Promise<{ body: Buffer; tooLarge: boolean }> {
  return new Promise((resolve, reject) => {
    const chunks: Buffer[] = [];
    let received = 0;
    const onData = (chunk: Buffer) => {
      received += chunk.length;
      if (received > maxBytes) {
        chunks.length = 0;
        req.off('data', onData);
        req.resume();
        resolve({ body: Buffer.alloc(0), tooLarge: true });
        return;
      }
      chunks.push(chunk);
    };
    req.on('data', onData);
    req.on('end', () => resolve({ body: Buffer.concat(chunks), tooLarge: false }));
    req.on('error', reject);
  });
}

const variantSessions = new VariantSessionStore();

/**
 * Darrer ping bo a l'API fonètica. Si l'API no respon, una connexió pot
 * quedar penjada fins al temps màxim (2 min per crida): amb el ping de 5 s
 * abans d'analitzar es falla de seguida. Si ha anat bé fa poc, no es repetix.
 */
let lastPingOk = 0;
const PING_FRESH_MS = 60_000;

function rememberPing(ping: PingResult): void {
  lastPingOk = ping.ok ? Date.now() : 0;
}

function sendJson(res: http.ServerResponse, status: number, payload: unknown): void {
  res.writeHead(status, { 'content-type': 'application/json; charset=utf-8' }).end(JSON.stringify(payload));
}

async function handleVariant(
  url: URL,
  { body, tooLarge }: { body: Buffer; tooLarge: boolean },
  res: http.ServerResponse,
): Promise<void> {
  const started = Date.now();
  if (tooLarge) {
    sendJson(res, 413, { error: 'L’àudio passa de 25 MB' });
    return;
  }

  const sessionId = url.searchParams.get('session')?.trim() || null;
  if (sessionId !== null && !VariantSessionStore.validId(sessionId)) {
    sendJson(res, 400, { error: 'L’identificador de sessió només pot tindre lletres, xifres, - i _ (màxim 64)' });
    return;
  }
  const reset = url.searchParams.get('reset') === '1';
  const ref = url.searchParams.get('ref')?.trim() || null;
  if (ref !== null && ref.length > 2000) {
    sendJson(res, 400, { error: 'El text llegit no pot passar de 2000 caràcters' });
    return;
  }
  if (sessionId && reset) variantSessions.reset(sessionId);

  // Només reiniciar: sense cos, es torna la sessió buida.
  if (body.length === 0) {
    if (reset && sessionId) {
      console.log(`[variant] sessió ${sessionId} reiniciada`);
      sendJson(res, 200, { reset: true, session: { id: sessionId, recordings: 0 } });
    } else {
      sendJson(res, 400, { error: 'Cal enviar un WAV al cos de la petició' });
    }
    return;
  }

  let decoded;
  try {
    decoded = decodeWav(body);
  } catch (error) {
    sendJson(res, 400, { error: error instanceof Error ? error.message : String(error) });
    return;
  }
  if (decoded.sampleRate < MIN_INPUT_RATE || decoded.sampleRate > MAX_INPUT_RATE) {
    sendJson(res, 400, {
      error: `Freqüència d'amostratge no acceptada (${decoded.sampleRate} Hz):`
        + ` ha d'estar entre ${MIN_INPUT_RATE / 1000} i ${MAX_INPUT_RATE / 1000} kHz`,
    });
    return;
  }
  const audioSeconds = decoded.samples.length / decoded.sampleRate;
  if (audioSeconds > config.variant.maxSeconds) {
    sendJson(res, 413, {
      error: `L'àudio dura ${Math.round(audioSeconds)} s i el màxim és ${config.variant.maxSeconds} s:`
        + ' talla’l o envia’l en trossos amb la mateixa sessió.',
    });
    return;
  }
  const decodeStarted = Date.now();
  const audio = resampleTo(decoded, TARGET_RATE);
  const resampleMs = Date.now() - decodeStarted;

  // Fallar ràpid si l'API fonètica no és accessible.
  if (Date.now() - lastPingOk > PING_FRESH_MS) {
    const ping = await pingPhoneticApi();
    rememberPing(ping);
    if (!ping.ok) {
      console.warn(`[variant] l'API fonètica no respon (${ping.url}): ${ping.error}`);
      sendJson(res, 502, {
        error: `No s'ha pogut connectar amb l'API fonètica (${ping.url}): ${ping.error}`,
        hint: PHONETIC_HINT,
      });
      return;
    }
  }

  // Si el client se'n va (pestanya tancada), no es continuen enviant
  // segments a l'API: la fila és única i faria esperar la resta de peticions.
  const controller = new AbortController();
  res.on('close', () => {
    if (!res.writableFinished) controller.abort();
  });
  const analysisStarted = Date.now();
  const recording = await analyseRecordingTimed(audio, { referenceText: ref, filename: 'gravacio', signal: controller.signal });
  const analysisMs = Date.now() - analysisStarted;
  // Una fallada de xarxa a mitja gravació també invalida el ping recent.
  if (anyUnreachable(recording.analyses)) lastPingOk = 0;
  if (recording.aborted) {
    console.warn(
      `[variant] el client ha tancat la connexió: s'atura l'anàlisi`
      + ` (${recording.analyses.length} trossos fets, ${recording.skipped} sense enviar)`,
    );
    return;
  }
  const failure = apiFailure(recording.analyses);
  if (failure) {
    lastPingOk = 0;
    const status = failure.status === -1 ? 'no ha respost' : `ha respost ${failure.status}`;
    console.warn(`[variant] l'API fonètica ${status} en tots els segments`);
    sendJson(res, 502, {
      error: `L'API fonètica (${config.phonetic.baseUrl}) ${status}: no s'ha pogut analitzar l'àudio.`,
      hint: PHONETIC_HINT,
    });
    return;
  }

  // Amb sessió, l'evidència s'afig a la de les gravacions anteriors.
  const entry = sessionId ? variantSessions.get(sessionId) : null;
  const session = entry?.session ?? new VariantSession();
  session.addAnalyses(recording.analyses.map((a) => a.analysis));
  if (entry) entry.recordings += 1;
  const result = session.result();

  const segments = recording.analyses.map(describeSegment);
  const usableNow = segments.filter((s) => s.usable).length;
  const notes = [
    ...recording.notes,
    ...speechNotes(result, entry ? Math.max(audioSeconds, result.speechSeconds) : audioSeconds),
  ];
  const totalMs = Date.now() - started;
  console.log(
    `[variant] àudio=${audioSeconds.toFixed(2)}s${decoded.sampleRate !== TARGET_RATE ? ` (${decoded.sampleRate} Hz)` : ''}`
    + ` segments=${usableNow}/${segments.length} model=${result.model}`
    + ` p=${result.pValencia === null ? '—' : result.pValencia.toFixed(3)} veredicte=${result.verdict}`
    + `${result.reason ? `(${result.reason})` : ''} n_ae=${result.nAe}`
    + `${recording.usedReference ? ' ref=sí' : ''}`
    + `${entry ? ` sessió=${sessionId}#${entry.recordings} veu=${result.speechSeconds.toFixed(1)}s` : ''}`
    + ` paret=${totalMs}ms`,
  );
  sendJson(res, 200, {
    ...describeResult(result),
    segments,
    totals: {
      audioSeconds: Number(audioSeconds.toFixed(2)),
      sampleRate: decoded.sampleRate,
      speechSeconds: Number(result.speechSeconds.toFixed(2)),
      usableSegments: result.usableSegments,
      nAe: result.nAe,
    },
    texts: result.texts,
    usedReference: recording.usedReference,
    session: entry ? { id: sessionId, recordings: entry.recordings } : null,
    notes,
    timings: { resampleMs, analysisMs, totalMs },
  });
}

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
  model: z.string().min(1).max(128).optional(),
  checkpoint: z.string().min(1).max(128).optional(),
  temperature: z.number().min(0).max(1.5).optional(),
  speed: z.number().min(0.5).max(2).optional(),
  pitch: z.number().int().min(-24).max(24).optional(),
  indexRate: z.number().min(0).max(1).optional(),
  formant: z.number().min(0.7).max(1.5).optional(),
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
  await Promise.all([disposeProviders(), disposeBatchProviders(), disposeTtsProviders(), disposeLocalTts()]);
  server.close(() => process.exit(0));
  setTimeout(() => process.exit(0), 2000).unref();
}

process.on('SIGINT', () => void shutdown());
process.on('SIGTERM', () => void shutdown());