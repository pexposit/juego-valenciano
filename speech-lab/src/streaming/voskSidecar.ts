/**
 * Proveïdor de veu en temps real sobre el sidecar de Python (Vosk + model català).
 *
 * Per qué un procés de Python i no els bindings npm de `vosk`: el paquet de npm
 * depén de `ffi-napi`, que no té binari precompilat per a Node 22 i falla en
 * compilar (comprovat en esta màquina). El wheel de Python són 7 MB, no compila
 * res i carrega el model en ~300 ms.
 *
 * El processament és FIFO: Vosk respon exactament un missatge per cada fragment
 * enviat, així que la latència es mesura amb una cua de marques de temps (no amb
 * l'últim enviament, que donaria números falsos quan s'envia més ràpid que la parla).
 */
import { spawn, type ChildProcess } from 'node:child_process';
import { createConnection } from 'node:net';
import { WebSocket } from 'ws';
import { assertVoskSetup, config, SETUP_HINT } from '../config.js';
import {
  buildConfigMessage,
  buildEofMessage,
  parseSidecarMessage,
} from './voskProtocol.js';
import type {
  StreamingStt,
  StreamingSttOptions,
  StreamingSttSession,
  StreamingTranscript,
} from './types.js';

/** Marge per a rebre el resultat final després d'enviar `{"eof": 1}`. */
const EOF_TIMEOUT_MS = 4000;

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

class VoskSidecarStt implements StreamingStt {
  readonly id = 'vosk';
  private child: ChildProcess | null = null;
  private startPromise: Promise<void> | null = null;

  async open(options: StreamingSttOptions = {}): Promise<StreamingSttSession> {
    await this.ensureRunning();
    return openSession(options);
  }

  async dispose(): Promise<void> {
    const child = this.child;
    this.child = null;
    this.startPromise = null;
    if (!child || child.exitCode !== null) return;

    child.kill('SIGTERM');
    await Promise.race([
      new Promise((resolve) => child.once('exit', resolve)),
      sleep(3000),
    ]);
    if (child.exitCode === null) child.kill('SIGKILL');
  }

  private async ensureRunning(): Promise<void> {
    if (this.child && this.child.exitCode === null) return;
    this.startPromise ??= this.start();
    try {
      await this.startPromise;
    } catch (error) {
      this.startPromise = null;
      this.child = null;
      throw error;
    }
  }

  private async start(): Promise<void> {
    assertVoskSetup();
    const { python, script, modelPath, host, port } = config.vosk;
    const child = spawn(
      python,
      [script, '--model', modelPath, '--host', host, '--port', String(port),
        '--sample-rate', String(config.sampleRate)],
      { stdio: ['ignore', 'pipe', 'pipe'] },
    );
    this.child = child;

    const log = (line: string) => console.log(line.startsWith('[vosk]') ? line : `[vosk] ${line}`);
    pipeLines(child.stdout, log);
    pipeLines(child.stderr, log);
    child.on('exit', (code, signal) => {
      console.warn(`[vosk] el sidecar ha acabat (code=${code} signal=${signal})`);
      if (this.child === child) {
        this.child = null;
        this.startPromise = null;
      }
    });

    await waitForPort(host, port, config.vosk.startTimeoutMs, () => child.exitCode !== null);
  }
}

/** Crea el proveïdor de Vosk (una instància per procés: comparteix el sidecar). */
export function createVoskSidecarStt(): StreamingStt {
  return new VoskSidecarStt();
}

/** Obre una sessió de streaming contra el sidecar ja arrancat. */
function openSession(options: StreamingSttOptions): Promise<StreamingSttSession> {
  const sampleRate = options.sampleRate ?? config.sampleRate;
  const url = `ws://${config.vosk.host}:${config.vosk.port}`;

  return new Promise((resolve, reject) => {
    const socket = new WebSocket(url);
    const handlers = new Set<(transcript: StreamingTranscript) => void>();
    const errorHandlers = new Set<(message: string) => void>();
    /** Una marca de temps per cada missatge enviat: Vosk respon en el mateix ordre. */
    const pending: number[] = [];
    const startedAt = Date.now();
    let audioBytes = 0;
    let closed = false;

    const emit = (transcript: StreamingTranscript) => {
      for (const handler of handlers) handler(transcript);
    };
    const fail = (message: string) => {
      for (const handler of errorHandlers) handler(message);
    };

    const session: StreamingSttSession = {
      get audioMs() {
        return (audioBytes / 2 / sampleRate) * 1000;
      },
      push(chunk: Buffer) {
        if (closed || socket.readyState !== WebSocket.OPEN) return;
        pending.push(Date.now());
        audioBytes += chunk.length;
        socket.send(chunk);
      },
      on(handler) {
        handlers.add(handler);
        return () => handlers.delete(handler);
      },
      onError(handler) {
        errorHandlers.add(handler);
        return () => errorHandlers.delete(handler);
      },
      async end() {
        if (closed) return;
        closed = true;
        await new Promise<void>((done) => {
          const timer = setTimeout(done, EOF_TIMEOUT_MS);
          socket.once('close', () => {
            clearTimeout(timer);
            done();
          });
          if (socket.readyState === WebSocket.OPEN) {
            pending.push(Date.now());
            socket.send(buildEofMessage());
          } else {
            clearTimeout(timer);
            done();
          }
        });
        if (socket.readyState !== WebSocket.CLOSED) socket.close();
      },
      close() {
        closed = true;
        if (socket.readyState === WebSocket.OPEN || socket.readyState === WebSocket.CONNECTING) {
          socket.terminate();
        }
      },
    };

    socket.on('open', () => {
      socket.send(buildConfigMessage({
        sample_rate: sampleRate,
        phrase_list: options.phraseList,
        words: options.words ?? false,
      }));
      resolve(session);
    });

    socket.on('message', (raw) => {
      const pushedAt = pending.shift() ?? startedAt;
      const atMs = Date.now() - startedAt;

      let event;
      try {
        event = parseSidecarMessage(raw.toString());
      } catch (error) {
        fail(error instanceof Error ? error.message : String(error));
        return;
      }
      if (event.kind === 'error') {
        fail(event.message);
        return;
      }
      // Els resultats sense text (silenci inicial, talls) no aporten res i
      // tallarien el torn abans d'hora.
      if (!event.text) return;

      // El motor informa el seu còmput (`compute_ms`); si no ho fera, cauríem
      // al temps de tornada, que inclou tota la cua quan enviem massa de pressa.
      const latencyMs = event.computeMs ?? Date.now() - pushedAt;

      emit({ text: event.text, isFinal: event.kind === 'final', atMs, latencyMs });
    });

    socket.on('error', (error) => {
      fail(`No hem pogut parlar amb el motor de veu (${url}): ${error.message}. ${SETUP_HINT}`);
      reject(error);
    });

    socket.on('close', () => {
      closed = true;
    });
  });
}

/** Reenvia les línies d'un flux (stdout/stderr del sidecar) cap al log del laboratori. */
function pipeLines(stream: NodeJS.ReadableStream | null, write: (line: string) => void): void {
  if (!stream) return;
  let buffer = '';
  stream.setEncoding('utf8');
  stream.on('data', (chunk: string) => {
    buffer += chunk;
    const lines = buffer.split('\n');
    buffer = lines.pop() ?? '';
    for (const line of lines) {
      if (line.trim()) write(line.trim());
    }
  });
}

/** Espera que el sidecar escolte; així el model ja està carregat quan obrim sessió. */
async function waitForPort(
  host: string,
  port: number,
  timeoutMs: number,
  isDead: () => boolean,
): Promise<void> {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    if (await probePort(host, port)) return;
    if (isDead()) throw new Error(`El sidecar de Vosk ha mort durant l'arrencada. ${SETUP_HINT}`);
    await sleep(150);
  }
  throw new Error(
    `El sidecar de Vosk no escolta a ${host}:${port} després de ${timeoutMs} ms. ${SETUP_HINT}`,
  );
}

function probePort(host: string, port: number, timeoutMs = 500): Promise<boolean> {
  return new Promise((resolve) => {
    const socket = createConnection({ host, port });
    const finish = (reachable: boolean) => {
      socket.removeAllListeners();
      socket.destroy();
      resolve(reachable);
    };
    socket.setTimeout(timeoutMs);
    socket.once('connect', () => finish(true));
    socket.once('error', () => finish(false));
    socket.once('timeout', () => finish(false));
  });
}