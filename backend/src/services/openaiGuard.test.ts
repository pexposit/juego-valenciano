import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { clearOpenAiCache, guardedFetch, NO_CACHE_HEADER, openAiCacheStats } from './openaiGuard.js';

const URL_CHAT = 'https://api.openai.com/v1/chat/completions';
const completion = (content: string, finish = 'stop') =>
  JSON.stringify({ choices: [{ message: { content }, finish_reason: finish }] });
const post = (body: object, headers: Record<string, string> = {}) =>
  guardedFetch(URL_CHAT, { method: 'POST', headers, body: JSON.stringify(body) });

describe('guardedFetch', () => {
  const fetchMock = vi.fn();
  beforeEach(() => {
    clearOpenAiCache();
    fetchMock.mockReset();
    fetchMock.mockImplementation(async () => new Response(completion('hola'), { status: 200 }));
    vi.stubGlobal('fetch', fetchMock);
  });
  afterEach(() => vi.unstubAllGlobals());

  it('serveix de la cache una petició idèntica', async () => {
    const first = await post({ model: 'm', messages: [{ role: 'user', content: 'a' }] });
    const second = await post({ model: 'm', messages: [{ role: 'user', content: 'a' }] });
    expect(fetchMock).toHaveBeenCalledTimes(1);
    expect(second.headers.get('x-cache')).toBe('HIT');
    expect(await first.json()).toEqual(await second.json());
  });

  it('no barreja peticions diferents', async () => {
    await post({ model: 'm', messages: [{ role: 'user', content: 'a' }] });
    await post({ model: 'm', messages: [{ role: 'user', content: 'b' }] });
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it('comparteix una sola crida entre peticions idèntiques simultànies', async () => {
    await Promise.all([post({ q: 1 }), post({ q: 1 }), post({ q: 1 })]);
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  it('no guarda errors ni respostes tallades', async () => {
    fetchMock.mockResolvedValueOnce(new Response('{}', { status: 500 }));
    await post({ q: 2 });
    fetchMock.mockResolvedValueOnce(new Response(completion('tall', 'length'), { status: 200 }));
    await post({ q: 2 });
    await post({ q: 2 });
    expect(fetchMock).toHaveBeenCalledTimes(3);
  });

  it("un reintent (x-no-cache) no llig la cache i esborra l'entrada dolenta", async () => {
    await post({ q: 3 });
    await post({ q: 3 }, { [NO_CACHE_HEADER]: '1' });
    expect(fetchMock).toHaveBeenCalledTimes(2);
    expect(fetchMock.mock.calls[1][1].headers.has(NO_CACHE_HEADER)).toBe(false);
    await post({ q: 3 });
    expect(fetchMock).toHaveBeenCalledTimes(3);
  });

  it('no passa per la cache altres adreces', async () => {
    await guardedFetch('https://api.openai.com/v1/models', { method: 'POST', body: '{}' });
    await guardedFetch('https://api.openai.com/v1/models', { method: 'POST', body: '{}' });
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it('manté la cache dins del límit de memòria', async () => {
    const big = 'x'.repeat(2 * 1024 * 1024);
    fetchMock.mockImplementation(async () => new Response(completion(big), { status: 200 }));
    for (let i = 0; i < 20; i += 1) await post({ q: `big${i}` });
    const { bytes, maxBytes } = openAiCacheStats();
    expect(bytes).toBeLessThanOrEqual(maxBytes);
  });
});
