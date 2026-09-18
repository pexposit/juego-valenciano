import 'dotenv/config';
import http from 'node:http';
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { WebSocketServer, type WebSocket } from 'ws';
import { z } from 'zod';
import { config } from './config.js';
import { logSummary, SessionMetrics } from './metrics.js';
import { availableProviders, disposeProviders, getStreamingStt } from './streaming/registry.js';
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
      sampleRate: config.sampleRate,
    }));
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
  await disposeProviders();
  server.close(() => process.exit(0));
  setTimeout(() => process.exit(0), 2000).unref();
}

process.on('SIGINT', () => void shutdown());
process.on('SIGTERM', () => void shutdown());