import { createHash } from 'node:crypto';
import type { Request, Response } from 'express';

/**
 * Detecció de bucles infinits en les crides a LLMs i a les seues eines (MCP).
 *
 * Un `LoopGuard` acompanya UNA execució (un torn, una anàlisi, una avaluació) i la talla amb un `LoopDetectedError`
 * quan passa alguna d'estes coses:
 * - massa crides al LLM (`maxIterations`);
 * - el mateix missatge o la mateixa crida a una eina repetida massa voltes (`maxRepeats`): el senyal típic d'un
 *   model que torna a demanar el mateix una i altra vegada;
 * - massa crides a eines (`maxToolCalls`);
 * - massa temps (`maxMs`);
 * - cancel·lació externa (`signal`): p. ex. el client tanca la connexió.
 * En tallar, avorta també la petició al LLM que estiga en vol (`guard.signal`).
 *
 * A banda, `createRepeatTracker` detecta el mateix missatge enviat una vegada i una altra pel client (un bucle de
 * reintents al frontend) abans de gastar cap crida.
 */

const num = (name: string, fallback: number) => {
  const value = Number(process.env[name]);
  return Number.isFinite(value) && value > 0 ? value : fallback;
};

export type LoopReason = 'max_iterations' | 'repeated_message' | 'repeated_tool_call' | 'max_tool_calls' | 'timeout' | 'cancelled' | 'repeated_request';

// Avís per a l'usuari (en valencià, com la resta de l'app).
export const LOOP_STOPPED_MESSAGE = "He aturat la petició perquè semblava que entrava en un bucle. Torna-ho a provar o reformula el missatge.";

export class LoopDetectedError extends Error {
  constructor(public readonly reason: LoopReason, public readonly label: string, detail: string) {
    super(`[${label}] bucle aturat (${reason}): ${detail}`);
    this.name = 'LoopDetectedError';
  }
  /** L'usuari mateix ha cancel·lat: no cal avisar-lo. */
  get userCancelled() {
    return this.reason === 'cancelled';
  }
}

export const isLoopError = (error: unknown): error is LoopDetectedError => error instanceof LoopDetectedError;

export type LoopGuardOptions = {
  label: string;
  maxIterations?: number;
  maxToolCalls?: number;
  /** Quantes voltes pot aparéixer el mateix missatge (o la mateixa crida a una eina) abans de considerar-ho un bucle. */
  maxRepeats?: number;
  maxMs?: number;
  /** Cancel·lació externa (p. ex. el client tanca la connexió). */
  signal?: AbortSignal;
};

const hash = (text: string) => createHash('sha256').update(text).digest('hex').slice(0, 16);

export type LoopGuard = ReturnType<typeof createLoopGuard>;

export function createLoopGuard(options: LoopGuardOptions) {
  const label = options.label;
  const maxIterations = options.maxIterations ?? num('LOOP_MAX_ITERATIONS', 12);
  const maxToolCalls = options.maxToolCalls ?? num('LOOP_MAX_TOOL_CALLS', 60);
  const maxRepeats = options.maxRepeats ?? num('LOOP_MAX_REPEATS', 3);
  const maxMs = options.maxMs ?? num('LOOP_MAX_SECONDS', 120) * 1000;
  const startedAt = Date.now();

  const controller = new AbortController();
  const signal = AbortSignal.any([
    controller.signal,
    AbortSignal.timeout(maxMs),
    ...(options.signal ? [options.signal] : []),
  ]);

  let iterations = 0;
  let toolCalls = 0;
  const seen = new Map<string, number>();
  let tripped: LoopDetectedError | null = null;

  const trip = (reason: LoopReason, detail: string): never => {
    tripped ??= new LoopDetectedError(reason, label, detail);
    controller.abort(tripped);
    throw tripped;
  };

  /** Llança si la execució ja s'ha tallat, s'ha cancel·lat o s'ha passat de temps. */
  function assertActive() {
    if (tripped) throw tripped;
    if (options.signal?.aborted) trip('cancelled', 'cancel·lada pel client');
    if (Date.now() - startedAt > maxMs) trip('timeout', `més de ${Math.round(maxMs / 1000)}s`);
  }

  const repeat = (kind: string, key: string) => {
    const id = `${kind}:${hash(key)}`;
    const count = (seen.get(id) ?? 0) + 1;
    seen.set(id, count);
    return count;
  };

  return {
    /** Les crides (reals o no) que s'han fet fins ara. */
    stats: () => ({ iterations, toolCalls, ms: Date.now() - startedAt }),
    /** Per a passar-lo a les crides al LLM: s'avorten si el bucle es talla. */
    signal,
    assertActive,

    /**
     * Es crida abans de cada crida al LLM. `message` és l'últim missatge que se li envia (el de l'usuari o el resultat
     * de l'última eina): si és el mateix una vegada i una altra, el model no avança.
     */
    llmCall(message: string) {
      assertActive();
      iterations += 1;
      if (iterations > maxIterations) trip('max_iterations', `més de ${maxIterations} crides al LLM`);
      const count = repeat('msg', message);
      if (count > maxRepeats) trip('repeated_message', `el mateix missatge ${count} voltes`);
    },

    /** Es crida abans d'executar una eina. Torna quantes voltes s'ha cridat amb els mateixos arguments. */
    toolCall(name: string, args: string) {
      assertActive();
      toolCalls += 1;
      if (toolCalls > maxToolCalls) trip('max_tool_calls', `més de ${maxToolCalls} crides a eines`);
      const count = repeat('tool', `${name}\0${args}`);
      if (count > maxRepeats) trip('repeated_tool_call', `${name} cridada ${count} voltes amb els mateixos arguments`);
      return count;
    },

    /**
     * Per als `catch` que tradueixen errors: si l'error és d'este guard (o la petició s'ha avortat per ell o pel
     * client), torna l'error de bucle perquè es propague; si no, `null`.
     */
    stopped(error: unknown): LoopDetectedError | null {
      if (isLoopError(error)) return error;
      if (tripped) return tripped;
      if (options.signal?.aborted) return new LoopDetectedError('cancelled', label, 'cancel·lada pel client');
      if (signal.aborted) return new LoopDetectedError('timeout', label, `més de ${Math.round(maxMs / 1000)}s`);
      return null;
    },
  };
}

// --- Missatge repetit entre peticions ---

/**
 * Compta quantes voltes arriba la mateixa clau (usuari + missatge) en una finestra de temps. Tot en memòria
 * (una sola instància, com el limitador de peticions).
 */
export function createRepeatTracker(options: { windowMs?: number; max?: number } = {}) {
  const windowMs = options.windowMs ?? 60_000;
  const max = options.max ?? num('LOOP_MAX_REPEATED_REQUESTS', 6);
  const counters = new Map<string, { count: number; resetAt: number }>();

  return {
    /** Registra una petició; `exceeded` si ja s'ha repetit més de `max` voltes dins de la finestra. */
    hit(userId: string | undefined, message: string, now = Date.now()) {
      if (counters.size > 5_000) for (const [key, c] of counters) if (c.resetAt <= now) counters.delete(key);
      const key = `${userId ?? 'anon'}:${hash(message)}`;
      const current = counters.get(key);
      if (!current || current.resetAt <= now) {
        counters.set(key, { count: 1, resetAt: now + windowMs });
        return { count: 1, exceeded: false };
      }
      current.count += 1;
      return { count: current.count, exceeded: current.count > max };
    },
  };
}

/**
 * Senyal que s'avorta quan el client tanca la connexió abans que acabe la resposta (botó «Aturar», pestanya tancada...).
 * Passat als guards i a les crides al LLM, talla el bucle sense seguir gastant.
 */
export function requestAbortSignal(req: Request, res: Response): AbortSignal {
  const controller = new AbortController();
  res.on('close', () => {
    if (!res.writableEnded) controller.abort();
  });
  req.on('aborted', () => controller.abort());
  return controller.signal;
}
