/**
 * Proves del client de PhoneticXeus amb un `fetch` fals: nom del fitxer,
 * paràmetres, fila única (l'espeak del servidor no suporta peticions
 * simultànies) i un sol reintent davant d'errors transitoris.
 */
import { describe, expect, it } from 'vitest';
import { createPhoneticApi, uploadFilename } from './phoneticApi.js';

type Seen = { url: string; filename: string | null; size: number };

function fakeFetch(answers: (seen: Seen, n: number) => { status: number; body: unknown }, delayMs = 0) {
  const seen: Seen[] = [];
  let active = 0;
  let maxActive = 0;
  const impl = (async (url: string | URL | Request, init?: RequestInit) => {
    active += 1;
    maxActive = Math.max(maxActive, active);
    const file = (init!.body as FormData).get('file') as File;
    const entry = { url: String(url), filename: file?.name ?? null, size: file?.size ?? 0 };
    seen.push(entry);
    await new Promise((resolve) => setTimeout(resolve, delayMs));
    active -= 1;
    const { status, body } = answers(entry, seen.length);
    return typeof body === 'string'
      ? new Response(body, { status, headers: { 'content-type': 'text/plain' } })
      : Response.json(body, { status });
  }) as typeof fetch;
  return { impl, seen, maxActive: () => maxActive };
}

const audio = { data: new Uint8Array([1, 2, 3, 4]), filename: 'blob' };

describe('client de PhoneticXeus', () => {
  it('posa sempre una extensió acceptada al fitxer', () => {
    expect(uploadFilename('blob')).toBe('blob.wav');
    expect(uploadFilename(undefined)).toBe('segment.wav');
    expect(uploadFilename('veu.WEBM')).toBe('veu.WEBM');
    expect(uploadFilename('a/b.ogg')).toBe('a_b.ogg');
  });

  it('envia el fitxer i els paràmetres, i afig _status', async () => {
    const fake = fakeFetch(() => ({ status: 200, body: { phones: [] } }));
    const api = createPhoneticApi({ baseUrl: 'http://api.test/', fetchImpl: fake.impl });
    const r = await api.transcribe(audio, { align: 'true', g2p_language: 'ca-va', reference_text: 'bon dia' });
    expect(r._status).toBe(200);
    expect(fake.seen[0].filename).toBe('blob.wav');
    expect(fake.seen[0].size).toBe(4);
    const url = new URL(fake.seen[0].url);
    expect(url.pathname).toBe('/transcribe');
    expect(Object.fromEntries(url.searchParams)).toEqual({ align: 'true', g2p_language: 'ca-va', reference_text: 'bon dia' });
  });

  it('no deixa mai dues peticions alhora, encara que vinguen de clients diferents', async () => {
    const fake = fakeFetch(() => ({ status: 200, body: {} }), 5);
    const a = createPhoneticApi({ baseUrl: 'http://api.test', fetchImpl: fake.impl });
    const b = createPhoneticApi({ baseUrl: 'http://api.test', fetchImpl: fake.impl });
    await Promise.all([1, 2, 3].flatMap(() => [a.transcribe(audio, { align: 'true' }), b.transcribe(audio, { align: 'true' })]));
    expect(fake.seen).toHaveLength(6);
    expect(fake.maxActive()).toBe(1);
  });

  it('reintenta una vegada un 500', async () => {
    const fake = fakeFetch((_s, n) => (n === 1 ? { status: 500, body: 'Internal Server Error' } : { status: 200, body: { ok: 1 } }));
    const api = createPhoneticApi({ baseUrl: 'http://api.test', fetchImpl: fake.impl, retryDelayMs: 0 });
    const r = await api.transcribe(audio, {});
    expect(fake.seen).toHaveLength(2);
    expect(r).toMatchObject({ _status: 200, ok: 1 });
  });

  it("reintenta un error d'alineació, però només una vegada", async () => {
    const fake = fakeFetch(() => ({ status: 200, body: { alignment: null, alignment_error: 'espeak failed' } }));
    const api = createPhoneticApi({ baseUrl: 'http://api.test', fetchImpl: fake.impl, retryDelayMs: 0 });
    const r = await api.transcribe(audio, { align: 'true' });
    expect(fake.seen).toHaveLength(2);
    expect(r.alignment_error).toBe('espeak failed');
  });

  it('no reintenta «no reference» ni els errors de petició', async () => {
    const fake = fakeFetch((_s, n) => (n === 1
      ? { status: 200, body: { alignment_error: 'no reference text' } }
      : { status: 422, body: { detail: 'x' } }));
    const api = createPhoneticApi({ baseUrl: 'http://api.test', fetchImpl: fake.impl, retryDelayMs: 0 });
    await api.transcribe(audio, { align: 'true' });
    const r = await api.transcribe(audio, {});
    expect(fake.seen).toHaveLength(2);
    expect(r._status).toBe(422);
  });

  it('una petició que no arriba torna _status -1 sense trencar la fila', async () => {
    const failing = (async () => { throw new Error('ECONNREFUSED'); }) as typeof fetch;
    const api = createPhoneticApi({ baseUrl: 'http://api.test', fetchImpl: failing });
    expect(await api.transcribe(audio, {})).toMatchObject({ _status: -1, _error: 'ECONNREFUSED' });
    const fake = fakeFetch(() => ({ status: 200, body: {} }));
    const ok = createPhoneticApi({ baseUrl: 'http://api.test', fetchImpl: fake.impl });
    expect((await ok.transcribe(audio, {}))._status).toBe(200);
  });
});
