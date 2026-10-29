import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

let fetchMock: ReturnType<typeof vi.fn>;
/** El reranker simulat: puntua cada text amb la seua longitud i diu quin reranker és. */
const reranker = (name = 'jev') => async (_url: string, init: { body: string }) => {
  const { textos } = JSON.parse(init.body) as { textos: string[] };
  return { ok: true, status: 200, json: async () => ({ puntuaciones: textos.map(t => t.length / 100), reranker: name }) };
};
const sentTexts = () => fetchMock.mock.calls.map(([, init]) => JSON.parse(init.body).textos as string[]);

beforeEach(() => {
  vi.resetModules();
  fetchMock = vi.fn(reranker());
  vi.stubGlobal('fetch', fetchMock);
  vi.spyOn(console, 'log').mockImplementation(() => {});
});
afterEach(() => {
  vi.unstubAllGlobals();
  vi.restoreAllMocks();
});

describe('puntuarTextos', () => {
  it('reutilitza les puntuacions de la mateixa consulta (normalitzada) i només envia els textos nous', async () => {
    const { puntuarTextos } = await import('./gnvRag.js');
    await puntuarTextos('Accentuació', ['a', 'bb']);
    const result = await puntuarTextos('accentuació.', ['bb', 'ccc', 'a']);

    expect(result).toEqual({ scores: [0.02, 0.03, 0.01], reranker: 'jev' });
    expect(sentTexts()).toEqual([['a', 'bb'], ['ccc']]);
    expect(JSON.parse(fetchMock.mock.calls[1][1].body).consulta).toBe('accentuació');
  });

  it('sense textos nous no crida el reranker', async () => {
    const { puntuarTextos } = await import('./gnvRag.js');
    await puntuarTextos('plurals', ['a', 'bb']);
    await puntuarTextos('plurals', ['bb']);
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  it("si el reranker canvia d'escala, torna a puntuar-los tots", async () => {
    const { puntuarTextos } = await import('./gnvRag.js');
    await puntuarTextos('plurals', ['a']);
    fetchMock.mockImplementation(reranker('local'));
    const result = await puntuarTextos('plurals', ['a', 'bb']);

    expect(result.reranker).toBe('local');
    expect(sentTexts()).toEqual([['a'], ['bb'], ['a', 'bb']]);
  });

  it('una consulta diferent no reutilitza les puntuacions', async () => {
    const { puntuarTextos } = await import('./gnvRag.js');
    await puntuarTextos('plurals', ['a']);
    await puntuarTextos('accentuació', ['a']);
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });
});
