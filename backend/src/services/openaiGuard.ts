import { createHash } from 'node:crypto';

/**
 * Cache en memòria i límits per a totes les crides a chat/completions d'OpenAI.
 *
 * S'engancha com a `fetch` del client (`new OpenAI({ fetch: guardedFetch })`) o es crida directament:
 * així cap servei no ha de saber res de la cache.
 *
 * - Cache: la resposta d'una petició idèntica (mateix model, missatges i esquema) es torna de la memòria
 *   i no es torna a pagar. Límit de memòria (OPENAI_CACHE_MB, 20 per defecte) amb expulsió de la menys usada
 *   i caducitat (OPENAI_CACHE_TTL_MIN). Peticions idèntiques simultànies comparteixen una sola crida.
 *   Només viu en la memòria del procés: no s'escriu a disc ni es comparteix entre instàncies.
 * - Límits: crides simultànies (OPENAI_MAX_CONCURRENCY) i crides reals per hora (OPENAI_MAX_CALLS_PER_HOUR)
 *   perquè un error o un abús no puga cremar el crèdit. Les respostes de la cache no compten.
 * 
 * 
 * Para desarrollo 8 llamadas está bien, para producción hay que ajustar los límites. Igual con las 3000 llamadas por hora
 */

const MB = 1024 * 1024;
const num = (name: string, fallback: number) => {
  const value = Number(process.env[name]);
  return Number.isFinite(value) && value > 0 ? value : fallback;
};

const CACHE_MAX_BYTES = num('OPENAI_CACHE_MB', 20) * MB;
const CACHE_TTL_MS = num('OPENAI_CACHE_TTL_MIN', 24 * 60) * 60_000;
// Una resposta sola no pot ocupar més d'una quarta part de la cache.
const ENTRY_MAX_BYTES = CACHE_MAX_BYTES / 4;
const MAX_CONCURRENCY = num('OPENAI_MAX_CONCURRENCY', 8);
const MAX_CALLS_PER_HOUR = num('OPENAI_MAX_CALLS_PER_HOUR', 1000);

/** Capçalera interna: la petició ni llig ni escriu la cache (p. ex. un reintent després d'una resposta invàlida). */
export const NO_CACHE_HEADER = 'x-no-cache';

export class OpenAiLimitError extends Error {}

type Entry = { text: string; bytes: number; expiresAt: number };
const cache = new Map<string, Entry>(); // l'ordre d'inserció és l'ordre d'ús: el primer és el menys recent
const inflight = new Map<string, Promise<string | null>>();
let cacheBytes = 0;
const stats = { hits: 0, misses: 0, shared: 0, blocked: 0 };

const sizeOf = (key: string, text: string) => Buffer.byteLength(text) + key.length + 64;

function cacheGet(key: string): string | null {
  const entry = cache.get(key);
  if (!entry) return null;
  if (entry.expiresAt <= Date.now()) {
    cacheDelete(key);
    return null;
  }
  cache.delete(key);
  cache.set(key, entry); // el marca com a recent
  return entry.text;
}

function cacheDelete(key: string) {
  const entry = cache.get(key);
  if (!entry) return;
  cacheBytes -= entry.bytes;
  cache.delete(key);
}

function cacheSet(key: string, text: string) {
  const bytes = sizeOf(key, text);
  if (bytes > ENTRY_MAX_BYTES) return;
  cacheDelete(key);
  for (const oldKey of cache.keys()) {
    if (cacheBytes + bytes <= CACHE_MAX_BYTES) break;
    cacheDelete(oldKey);
  }
  cache.set(key, { text, bytes, expiresAt: Date.now() + CACHE_TTL_MS });
  cacheBytes += bytes;
}

export const openAiCacheStats = () => ({ ...stats, entries: cache.size, bytes: cacheBytes, maxBytes: CACHE_MAX_BYTES });
export const clearOpenAiCache = () => {
  cache.clear();
  inflight.clear();
  cacheBytes = 0;
};

// Només es guarden respostes completes: una resposta tallada (finish_reason «length») o amb un filtre no es reutilitza.
function cacheable(text: string): boolean {
  try {
    const payload = JSON.parse(text) as { choices?: { finish_reason?: string }[] };
    const reason = payload.choices?.[0]?.finish_reason;
    return reason === 'stop' || reason === 'tool_calls';
  } catch {
    return false;
  }
}

// --- Límits ---
let active = 0;
const waiting: (() => void)[] = [];
const callTimes: number[] = [];

function reserveCall() {
  const now = Date.now();
  while (callTimes.length && callTimes[0] <= now - 3_600_000) callTimes.shift();
  if (callTimes.length >= MAX_CALLS_PER_HOUR) {
    stats.blocked += 1;
    throw new OpenAiLimitError(`S'ha arribat al límit de ${MAX_CALLS_PER_HOUR} crides a OpenAI per hora`);
  }
  callTimes.push(now);
}

async function withConcurrency<T>(task: () => Promise<T>): Promise<T> {
  if (active >= MAX_CONCURRENCY) await new Promise<void>(resolve => waiting.push(resolve));
  active += 1;
  try {
    return await task();
  } finally {
    active -= 1;
    waiting.shift()?.();
  }
}

const isChatCompletion = (url: string) => /\/chat\/completions(\?|$)/.test(url);

type FetchArgs = Parameters<typeof fetch>;

/**
 * `fetch` amb cache i límits per a chat/completions; la resta de peticions passen sense tocar.
 * Si l'eixida és de la cache, la capçalera `x-cache: HIT` ho indica.
 */
export async function guardedFetch(input: FetchArgs[0], init?: FetchArgs[1]): Promise<Response> {
  const url = typeof input === 'string' ? input : input instanceof URL ? input.href : input.url;
  const headers = new Headers(init?.headers);
  const skip = headers.has(NO_CACHE_HEADER);
  headers.delete(NO_CACHE_HEADER);
  const body = typeof init?.body === 'string' ? init.body : null;
  // Sense la capçalera interna, la petició passa tal com ve.
  const realInit = skip ? { ...init, headers } : init;

  const callApi = () => withConcurrency(async () => {
    reserveCall();
    return fetch(input, realInit);
  });

  if (!isChatCompletion(url) || init?.method?.toUpperCase() !== 'POST' || body === null || body.includes('"stream":true')) {
    return callApi();
  }

  // La clau no inclou la clau d'API; sí la URL (OpenAI i altres servidors no comparteixen respostes).
  const key = createHash('sha256').update(url).update('\0').update(body).digest('hex');
  const json = (text: string, cache: 'HIT' | 'SHARED') => new Response(text, { status: 200, headers: { 'content-type': 'application/json', 'x-cache': cache } });

  if (!skip) {
    const hit = cacheGet(key);
    if (hit !== null) {
      stats.hits += 1;
      return json(hit, 'HIT');
    }
    const pending = inflight.get(key);
    if (pending) {
      const text = await pending;
      if (text !== null) {
        stats.shared += 1;
        return json(text, 'SHARED');
      }
      // La crida compartida ha fallat: aquesta fa la seua.
    }
  }

  stats.misses += 1;
  const call = callApi();
  if (skip) {
    const response = await call;
    if (response.ok) cacheDelete(key); // l'anterior era dolenta: no es torna a servir
    return response;
  }
  const shared = call.then(async response => (response.ok ? await response.clone().text() : null)).catch(() => null);
  inflight.set(key, shared);
  try {
    const response = await call;
    const text = await shared;
    if (text !== null && cacheable(text)) cacheSet(key, text);
    return response;
  } finally {
    inflight.delete(key);
  }
}
