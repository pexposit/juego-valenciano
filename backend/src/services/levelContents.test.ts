/**
 * Pruebas unitarias de la clasificación de errores por área y contenido del nivel
 * (backend/src/services/levelContents.ts). No se hace ninguna llamada a la base de datos.
 */
import { describe, expect, it } from 'vitest';
import { classify, contentsForPrompt, type LevelContent } from './levelContents.js';

const contents: LevelContent[] = [
  { code: 'c1', id: 'id-accent', area: 'fonetica_ortografia', name: 'Accentuació', detail: "Regles bàsiques de l'accent gràfic" },
  { code: 'c2', id: 'id-pronoms', area: 'morfosintaxi', name: 'Pronoms', detail: 'Personals, febles, interrogatius i relatius' },
  { code: 'c3', id: 'id-menjar', area: 'lexic_semantica', name: 'Aliments', detail: 'Aliments, begudes, envasos i mesures' },
];

describe('classify', () => {
  it('usa el área y el contenido del código elegido', () => {
    expect(classify(contents, 'morfosintaxi', 'c2')).toEqual({ category: 'morfosintaxi', content_id: 'id-pronoms', subcategory: 'Pronoms' });
  });

  it('el área la manda el contenido, aunque el LLM diga otra', () => {
    expect(classify(contents, 'morfosintaxi', 'c1').category).toBe('fonetica_ortografia');
  });

  it('sin código válido deja solo el área', () => {
    expect(classify(contents, 'lexic_semantica', 'c99')).toEqual({ category: 'lexic_semantica', content_id: null, subcategory: null });
    expect(classify(contents, 'lexic_semantica', '')).toEqual({ category: 'lexic_semantica', content_id: null, subcategory: null });
    expect(classify([], 'ortografia', 'c1')).toEqual({ category: 'morfosintaxi', content_id: null, subcategory: null });
  });
});

describe('contentsForPrompt', () => {
  it('lista los contenidos agrupados por área con su código', () => {
    const text = contentsForPrompt(contents);
    expect(text).toContain('morfosintaxi:\n  - c2: Pronoms (Personals, febles, interrogatius i relatius)');
    expect(text.indexOf('fonetica_ortografia')).toBeLessThan(text.indexOf('lexic_semantica'));
  });
});
