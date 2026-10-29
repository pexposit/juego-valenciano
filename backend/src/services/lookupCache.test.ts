import { describe, expect, it, vi } from 'vitest';
import { createLookupCache, normalizeQuery } from './lookupCache.js';

describe('normalizeQuery', () => {
  it('ignora majúscules, cometes, puntuació i espais', () => {
    expect(normalizeQuery('  Regles d’ús de la GRAFIA «ç», c trencada?  ')).toBe("regles d'ús de la grafia ç c trencada");
    expect(normalizeQuery('regles d\'ús de la grafia ç c trencada')).toBe("regles d'ús de la grafia ç c trencada");
  });

  it('manté els accents, la ç, el guionet i la l·l', () => {
    expect(normalizeQuery('Què')).not.toBe(normalizeQuery('que'));
    expect(normalizeQuery('ç')).not.toBe(normalizeQuery('c'));
    expect(normalizeQuery('Rentar-se i col·legi')).toBe('rentar-se i col·legi');
  });
});

describe('createLookupCache', () => {
  it('reutilitza la resposta i comparteix les crides simultànies', async () => {
    const cache = createLookupCache<number>({ ttlMs: 60_000, maxEntries: 10 });
    const load = vi.fn(async () => 1);
    await Promise.all([cache.get('a', load), cache.get('a', load)]);
    await cache.get('a', load);
    expect(load).toHaveBeenCalledTimes(1);
  });

  it('no guarda els errors ni el que `keep` rebutja', async () => {
    const cache = createLookupCache<number>({ ttlMs: 60_000, maxEntries: 10, keep: v => v > 0 });
    await expect(cache.get('a', async () => { throw new Error('x'); })).rejects.toThrow();
    await cache.get('b', async () => 0);
    expect(cache.size).toBe(0);
  });

  it('expulsa la menys usada i respecta la caducitat', async () => {
    vi.useFakeTimers();
    const cache = createLookupCache<string>({ ttlMs: 1_000, maxEntries: 2 });
    await cache.get('a', async () => 'a');
    await cache.get('b', async () => 'b');
    await cache.get('a', async () => 'a2'); // a és ara la més recent
    await cache.get('c', async () => 'c'); // fora b
    expect(await cache.get('b', async () => 'b2')).toBe('b2');
    vi.advanceTimersByTime(1_001);
    expect(await cache.get('c', async () => 'c2')).toBe('c2');
    vi.useRealTimers();
  });
});
