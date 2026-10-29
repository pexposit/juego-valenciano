import { describe, expect, it } from 'vitest';
import { buildActivity, buildProgress, resourceInfo, toRoute, type ResultRow } from './progressReport.js';

const result = (over: Partial<ResultRow>): ResultRow => ({
  user_id: 'u1', resource_id: 'r1', kind: 'practice', score: 3, total: 5, created_at: '2026-01-02T00:00:00Z',
  resources: { name: 'Recurs', category: 'gramatica', metadata: { section_name: 'Secció', icon: '📘' } },
  ...over,
});

describe('buildActivity', () => {
  it("es queda amb l'última nota de cada recurs i compta els errors pendents", () => {
    const rows = [result({ score: 4, created_at: '2026-01-03T00:00:00Z' }), result({ score: 1, created_at: '2026-01-01T00:00:00Z' })];
    const out = buildActivity(['u1', 'u2'], rows, [{ user_id: 'u1', resource_id: 'r1' }, { user_id: 'u1', resource_id: 'r1' }]);
    expect(out.u1).toEqual([{
      resource_id: 'r1', name: 'Secció', icon: '📘', category: 'gramatica', kind: 'practice', score: 4, total: 5,
      pending_errors: 2, last_at: '2026-01-03T00:00:00Z',
    }]);
    expect(out.u2).toEqual([]);
  });

  it('usa el nom del recurs sense secció i ignora els resultats d’altres usuaris', () => {
    const out = buildActivity(['u1'], [
      result({ resources: { name: 'Nom', category: 'examen', metadata: null } }),
      result({ user_id: 'altre', resource_id: 'r2' }),
    ], []);
    expect(out.u1[0]).toMatchObject({ name: 'Nom', icon: null, category: 'examen', pending_errors: 0 });
    expect(Object.keys(out)).toEqual(['u1']);
  });
});

describe('buildProgress', () => {
  const results = [
    { user_id: 'u1', resource_id: 'r1', score: 5, total: 5, created_at: '2026-01-05T00:00:00Z' },
    { user_id: 'u1', resource_id: 'r1', score: 1, total: 5, created_at: '2026-01-01T00:00:00Z' },
    { user_id: 'u1', resource_id: 'r2', score: 2, total: 4, created_at: '2026-01-02T00:00:00Z' },
  ];

  it('guarda la nota de l’últim resultat', () => {
    expect(buildProgress(['u1'], results, [])).toEqual({ u1: { r1: { score: 5, total: 5 }, r2: { score: 2, total: 4 } } });
  });

  it('no compta com a feta una activitat anterior al reinici', () => {
    const out = buildProgress(['u1'], results, [{ user_id: 'u1', resource_id: 'r2', restarted_at: '2026-01-03T00:00:00Z' }]);
    expect(out.u1).toEqual({ r1: { score: 5, total: 5 } });
  });
});

describe('toRoute', () => {
  it('ordena els passos per posició i omple el nom i la icona del recurs', () => {
    const info = resourceInfo([{ id: 'a', name: 'A', category: 'c', metadata: { icon: '🎯' } }]);
    const route = toRoute({ id: 'p', title: 'Ruta', description: '', level: 'a1', study_path_steps: [{ position: 2, resource_id: 'b' }, { position: 1, resource_id: 'a' }] }, info);
    expect(route.steps).toEqual([
      { resource_id: 'a', name: 'A', icon: '🎯', category: 'c' },
      { resource_id: 'b', name: '', icon: null, category: '' },
    ]);
  });
});
