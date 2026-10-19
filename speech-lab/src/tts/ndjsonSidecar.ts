/**
 * Procés fill de Python que respon peticions JSON per stdio, una línia per
 * petició i una per resposta, en ordre (el mateix diàleg que el sidecar de
 * whisper). Arranca a la primera petició, espera el senyal de llest per stderr
 * i encua les peticions (FIFO): el model de darrere és seqüencial.
 */
import { spawn, type ChildProcess } from 'node:child_process';
import { existsSync } from 'node:fs';
import { createInterface, type Interface } from 'node:readline';

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

export type NdjsonSidecarOptions = {
  /** Prefix del registre (`matxa`, `rvc`…) i del senyal `[nom] llest`. */
  name: string
  python: string
  script: string
  args?: string[]
  cwd?: string
  startTimeoutMs: number
  /** Què cal executar si falta l'entorn. */
  setupHint: string
};

export class NdjsonSidecar<Req extends object, Res extends object> {
  private child: ChildProcess | null = null;
  private lines: Interface | null = null;
  private startPromise: Promise<void> | null = null;
  private resolvers: Array<{ resolve: (value: Res) => void, reject: (error: Error) => void }> = [];

  constructor(private readonly options: NdjsonSidecarOptions) {}

  async request(payload: Req): Promise<Res> {
    await this.ensureRunning();
    const child = this.child;
    if (!child?.stdin?.writable) throw new Error(`El sidecar ${this.options.name} no accepta peticions`);
    const pending = new Promise<Res>((resolve, reject) => {
      this.resolvers.push({ resolve, reject });
    });
    child.stdin.write(`${JSON.stringify(payload)}\n`);
    const answer = await pending;
    if ('error' in answer && typeof answer.error === 'string') throw new Error(answer.error);
    return answer;
  }

  async dispose(): Promise<void> {
    const child = this.child;
    this.child = null;
    this.startPromise = null;
    this.lines?.close();
    this.lines = null;
    for (const { reject } of this.resolvers.splice(0)) {
      reject(new Error('El laboratori s’està aturant'));
    }
    if (!child || child.exitCode !== null) return;
    child.kill('SIGTERM');
    await Promise.race([new Promise((resolve) => child.once('exit', resolve)), sleep(5000)]);
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
    const { name, python, script, args = [], cwd, setupHint } = this.options;
    if (!existsSync(python)) throw new Error(`No trobe ${python}. ${setupHint}`);
    const child = spawn(python, [script, ...args], { cwd, stdio: ['pipe', 'pipe', 'pipe'] });
    this.child = child;

    child.stderr?.setEncoding('utf8');
    child.stderr?.on('data', (chunk: string) => {
      for (const line of String(chunk).split('\n')) {
        const clean = line.trim();
        if (clean) console.log(clean.startsWith(`[${name}]`) ? clean : `[${name}] ${clean}`);
      }
    });
    child.on('exit', (code, signal) => {
      console.warn(`[${name}] el sidecar ha acabat (code=${code} signal=${signal})`);
      if (this.child === child) {
        this.child = null;
        this.startPromise = null;
        for (const { reject } of this.resolvers.splice(0)) {
          reject(new Error(`El sidecar ${name} ha mort durant la petició`));
        }
      }
    });

    this.lines = createInterface({ input: child.stdout! });
    this.lines.on('line', (line) => {
      const next = this.resolvers.shift();
      if (!next) {
        console.warn(`[${name}] resposta sense petició: ${line.slice(0, 120)}`);
        return;
      }
      try {
        next.resolve(JSON.parse(line) as Res);
      } catch {
        next.reject(new Error(`Resposta no vàlida del sidecar ${name}: ${line.slice(0, 120)}`));
      }
    });

    await this.waitForReady(child);
  }

  private waitForReady(child: ChildProcess): Promise<void> {
    const { name, startTimeoutMs, setupHint } = this.options;
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        reject(new Error(`El sidecar ${name} no ha arrancat en ${startTimeoutMs} ms. ${setupHint}`));
      }, startTimeoutMs);
      const onData = (chunk: string) => {
        if (String(chunk).includes(`[${name}] llest`)) {
          clearTimeout(timer);
          child.stderr?.off('data', onData);
          resolve();
        }
      };
      child.stderr?.on('data', onData);
      child.once('exit', (code) => {
        clearTimeout(timer);
        reject(new Error(`El sidecar ${name} ha mort en arrancar (code=${code}). ${setupHint}`));
      });
    });
  }
}
