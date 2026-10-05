/**
 * Pruebas unitarias de la ruta de aprendizaje (backend/src/services/learningPath.ts):
 * - focusOf: categorías de error que trabaja cada contenido según su `type`.
 * - validatePlan: la respuesta del LLM solo puede usar recursos del catálogo enviado,
 *   sin repetir, y con entre 5 y 7 pasos.
 * - diagnosticPlan: ruta fija cuando aún no hay datos del usuario.
 * No se hace ninguna llamada al LLM ni a la base de datos.
 */
import { describe, expect, it } from 'vitest';
import { diagnosticPlan, focusOf, validatePlan, type CatalogItem, type Plan } from './learningPath.js';

const item = (id: string, category: string, extra: Partial<CatalogItem> = {}): CatalogItem => ({
  id, category, type: id, section: id, name: id, content: null, focus: [], has_lesson: false, sort_order: 1, ...extra,
});

const plan = (ids: string[]): Plan => ({
  rationale: 'Treballarem els pronoms febles.',
  focus: ['pronoms'],
  steps: ids.map(id => ({ resource_id: id, stage: 'practicar', reason: 'Per a reforçar-ho.' })),
});

describe('focusOf', () => {
  it('deduce el foco de los contenidos de lengua por su type', () => {
    expect(focusOf({ category: 'morfosintaxi', type: 'b1_mor_pronoms_cd_ci' })).toEqual(['pronoms']);
    expect(focusOf({ category: 'fonetica_ortografia', type: 'b1_fon_accentuacio' })).toEqual(['accentuació']);
    expect(focusOf({ category: 'morfosintaxi', type: 'b1_mor_regim' })).toEqual(['preposicions']);
    expect(focusOf({ category: 'lexic_semantica', type: 'b1_vocab_salut' })).toEqual(['lèxic']);
  });

  it('no asigna foco a las destrezas ni a los escenarios', () => {
    expect(focusOf({ category: 'comprensio_oral', type: 'b1_co_converses' })).toEqual([]);
    expect(focusOf({ category: 'escenari', type: 'b1_persones' })).toEqual([]);
  });
});

describe('validatePlan', () => {
  const ids = new Set(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']);

  it('acepta una ruta de 5 a 7 recursos del catálogo', () => {
    expect(validatePlan(plan(['a', 'b', 'c', 'd', 'e']), ids)).toBeNull();
    expect(validatePlan(plan(['a', 'b', 'c', 'd', 'e', 'f', 'g']), ids)).toBeNull();
  });

  it('rechaza rutas demasiado cortas o largas', () => {
    expect(validatePlan(plan(['a', 'b', 'c', 'd']), ids)).toMatch(/entre 5 i 7/);
    expect(validatePlan(plan(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']), ids)).toMatch(/entre 5 i 7/);
  });

  it('rechaza ids inventados o de otro nivel', () => {
    expect(validatePlan(plan(['a', 'b', 'c', 'd', 'zzz']), ids)).toMatch(/zzz/);
  });

  it('rechaza recursos repetidos', () => {
    expect(validatePlan(plan(['a', 'b', 'c', 'd', 'a']), ids)).toMatch(/repetits/);
  });

  it('rechaza pasos sin justificación', () => {
    const p = plan(['a', 'b', 'c', 'd', 'e']);
    p.steps[2].reason = ' ';
    expect(validatePlan(p, ids)).toMatch(/reason/);
  });
});

describe('diagnosticPlan', () => {
  it('recorre todas las destrezas empezando por un contenido con lección', () => {
    const catalog = [
      item('mor-sense', 'morfosintaxi'),
      item('mor-llico', 'morfosintaxi', { has_lesson: true, sort_order: 2 }),
      item('lex', 'lexic_semantica'),
      item('co', 'comprensio_oral'),
      item('ce', 'comprensio_escrita'),
      item('ee', 'expressio_escrita'),
      item('eo', 'expressio_oral'),
      item('ex', 'examen'),
    ];
    const result = diagnosticPlan(catalog)!;
    expect(result.steps.map(s => s.resource_id)).toEqual(['mor-llico', 'lex', 'co', 'ce', 'ee', 'eo', 'ex']);
    expect(result.steps[0].stage).toBe('aprendre');
    expect(validatePlan(result, new Set(catalog.map(c => c.id)))).toBeNull();
  });

  it('no genera ruta si el catálogo no da para 5 pasos', () => {
    expect(diagnosticPlan([item('co', 'comprensio_oral'), item('ce', 'comprensio_escrita')])).toBeNull();
  });
});
