/**
 * Proveïdor de transcripció per lots sobre el sidecar de faster-whisper.
 *
 * A diferència de Vosk (WebSocket persistent), ací el diàleg és NDJSON per
 * stdio: una línia per petició, una línia per resposta, sempre en ordre. El
 * model és seqüencial, així que les peticions s'encuen (FIFO) i mai n'hi ha
 * dos en vol.
 */
import { spawn, type ChildProcess } from 'node:child_process';
import { createInterface, type Interface } from 'node:readline';
import { config, SETUP_AINA_HINT } from '../config.js';
import { buildBatchRequest, parseBatchResponse } from './protocol.js';
import type { BatchStt, BatchSttOptions, BatchTranscript } from './types.js';

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

class WhisperBatchStt implements BatchStt {
  readonly id = 'aina';
  readonly modelId = process.env.AINA_MODEL_ID?.trim()
    || 'projecte-aina/faster-whisper-large-v3-ca-3catparla';
  private child: ChildProcess | null = null;
  private lines: Interface | null = null;
  private startPromise: Promise<void> | null = null;
  /** Cua FIFO: cada petició resol quan arriba la seua línia de resposta. */
  private queue: Promise<BatchTranscript>[] = [];
  private resolvers: Array<{
    resolve: (value: BatchTranscript) => void
    reject: (error: Error) => void
  }> = [];

  async transcribe(wavPath: string, options: BatchSttOptions = {}): Promise<BatchTranscript> {
    await this.ensureRunning();
    const child = this.child;
    if (!child?.stdin?.writable) throw new Error('El sidecar de lots no accepta peticions');

    const pending = new Promise<BatchTranscript>((resolve, reject) => {
      this.resolvers.push({ resolve, reject });
    });
    this.queue.push(pending);
    child.stdin.write(`${buildBatchRequest(wavPath, options)}\n`);
    return pending;
  }

  async dispose(): Promise<void> {
    const child = this.child;
    this.child = null;
    this.startPromise = null;
    this.lines?.close();
    this.lines = null;
    for (const { reject } of this.resolvers.splice(0)) {
      reject(new Error('El laboratori s\u2019est\u00e0 aturant'));
    }
    if (!child || child.exitCode !== null) return;
    child.kill('SIGTERM');
    await Promise.race([
      new Promise((resolve) => child.once('exit', resolve)),
      sleep(5000),
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
    assertBatchSetup();
    const { python, script, modelPath, modelId } = config.batch;
    const child = spawn(
      python,
      [script, '--model', modelPath, '--model-id', modelId],
      { stdio: ['pipe', 'pipe', 'pipe'] },
    );
    this.child = child;

    const log = (line: string) => console.log(line.startsWith('[whisper]') ? line : `[whisper] ${line}`);
    child.stderr?.setEncoding('utf8');
    child.stderr?.on('data', (chunk: string) => {
      for (const line of String(chunk).split('\n')) {
        if (line.trim()) log(line.trim());
      }
    });
    child.on('exit', (code, signal) => {
      console.warn(`[whisper] el sidecar ha acabat (code=${code} signal=${signal})`);
      if (this.child === child) {
        this.child = null;
        this.startPromise = null;
        for (const { reject } of this.resolvers.splice(0)) {
          reject(new Error('El sidecar de lots ha mort durant la transcripció'));
        }
      }
    });

    // Les respostes ixen per stdout, una línia JSON per petició, en ordre.
    this.lines = createInterface({ input: child.stdout! });
    this.lines.on('line', (line) => {
      const next = this.resolvers.shift();
      if (!next) {
        console.warn(`[whisper] resposta sense petició: ${line.slice(0, 120)}`);
        return;
      }
      try {
        next.resolve(parseBatchResponse(line));
      } catch (error) {
        next.reject(error instanceof Error ? error : new Error(String(error)));
      }
    });

    // El model triga a carregar (GB en GPU): esperem el senyal per stderr.
    await this.waitForReady(child);
  }

  private waitForReady(child: ChildProcess): Promise<void> {
    const timeoutMs = config.batch.startTimeoutMs;
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        reject(new Error(
          `El sidecar de lots no ha carregat el model en ${timeoutMs} ms. ${SETUP_AINA_HINT}`,
        ));
      }, timeoutMs);
      const onData = (chunk: string) => {
        if (String(chunk).includes('[whisper] llest')) {
          clearTimeout(timer);
          child.stderr?.off('data', onData);
          resolve();
        }
      };
    child.stderr?.on('data', onData);
      child.once('exit', (code) => {
        clearTimeout(timer);
        reject(new Error(`El sidecar de lots ha mort durant l'arrencada (code=${code}). ${SETUP_AINA_HINT}`));
      });
    });
  }
}

/** Crea el proveïdor de lots (una instància per procés: comparteix el sidecar). */
export function createWhisperBatchStt(): BatchStt {
  return new WhisperBatchStt();
}

function assertBatchSetup(): void {
  if (!config.batch.python || !config.batch.script) {
    throw new Error(`Falta la posada a punt de lots. ${SETUP_AINA_HINT}`);
  }
}
