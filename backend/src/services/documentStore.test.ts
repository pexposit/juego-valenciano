import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { clearDocuments, documentStoreStats, getDocument, putDocument } from './documentStore.js';

const doc = (name: string, size = 100) => ({ name, text: 'x'.repeat(size), chars: size, truncated: false });
const MIN = 60_000;

describe('documentStore', () => {
  beforeEach(() => clearDocuments());
  afterEach(() => {
    delete process.env.DOCUMENT_MAX_PER_USER;
    delete process.env.DOCUMENT_STORE_MB;
    delete process.env.DOCUMENT_TTL_MIN;
  });

  it('guarda el text i torna només l\'identificador i la mida', () => {
    const saved = putDocument('u1', doc('temari.pdf', 500));
    expect(saved).toMatchObject({ name: 'temari.pdf', chars: 500, truncated: false });
    expect(saved).not.toHaveProperty('text');
    expect(getDocument('u1', saved.id)).toMatchObject({ name: 'temari.pdf', text: 'x'.repeat(500) });
  });

  it('un document només el veu qui l\'ha pujat', () => {
    const saved = putDocument('u1', doc('a.txt'));
    expect(getDocument('u2', saved.id)).toBeNull();
    expect(getDocument('u1', 'no-existix')).toBeNull();
  });

  it('caduca passat el temps, i cada ús el renova', () => {
    const t0 = 1_000_000;
    const saved = putDocument('u1', doc('a.txt'), t0);
    expect(getDocument('u1', saved.id, t0 + 50 * MIN)).not.toBeNull(); // renova fins a t0 + 110 min
    expect(getDocument('u1', saved.id, t0 + 100 * MIN)).not.toBeNull();
    expect(getDocument('u1', saved.id, t0 + 100 * MIN + 61 * MIN)).toBeNull();
  });

  it('cada docent té un màxim de documents: s\'esborra el més antic', () => {
    process.env.DOCUMENT_MAX_PER_USER = '2';
    const a = putDocument('u1', doc('a'), 1);
    const b = putDocument('u1', doc('b'), 2);
    const c = putDocument('u1', doc('c'), 3);
    expect(getDocument('u1', a.id, 4)).toBeNull();
    expect(getDocument('u1', b.id, 4)).not.toBeNull();
    expect(getDocument('u1', c.id, 4)).not.toBeNull();
    // els d'una altra docent no es toquen
    const other = putDocument('u2', doc('z'), 5);
    expect(getDocument('u2', other.id, 6)).not.toBeNull();
  });

  it('manté la memòria total dins del límit, esborrant els més antics', () => {
    process.env.DOCUMENT_STORE_MB = '1'; // 1 MB = 524.288 caràcters (2 bytes cada un)
    const first = putDocument('u1', doc('a', 300_000), 1);
    const second = putDocument('u2', doc('b', 300_000), 2);
    expect(getDocument('u1', first.id, 3)).toBeNull();
    expect(getDocument('u2', second.id, 3)).not.toBeNull();
    expect(documentStoreStats().bytes).toBeLessThanOrEqual(documentStoreStats().maxBytes);
  });
});
