import { describe, expect, it, vi } from 'vitest';
import { citeErrors, MAX_CITATION_QUERIES, type CitableError } from './gnvCitations.js';
import type { GnvResultat } from './gnvRag.js';

const error = (subcategory: string | null, n = 1): CitableError => ({ error_text: `e${n}`, correction: `c${n}`, category: 'fonetica_ortografia', subcategory });
const result = (seccion: string): GnvResultat => ({
  hay_respaldo: true, mejor_puntuacion: 0.9, mensaje: '',
  fuentes: [{ seccion, ruta: 'r', etiqueta: `GNV § ${seccion}`, puntuacion: 0.9, texto: 't' }],
});

describe('citeErrors', () => {
  it('fa una sola consulta per error repetit i una per cada error diferent', async () => {
    const consult = vi.fn(async () => result('5.1.1'));
    const cites = await citeErrors([error('Accent', 1), error('Accent', 1), error('Accent', 2)], consult);
    expect(consult).toHaveBeenCalledTimes(2);
    expect(cites.map(c => c?.seccio)).toEqual(['5.1.1', '5.1.1', '5.1.1']);
  });

  it('sense respaldo o si el RAG falla, l\'error no porta cita', async () => {
    const none = { ...result('1'), hay_respaldo: false, fuentes: [] };
    expect(await citeErrors([error('A')], async () => none)).toEqual([null]);
    expect(await citeErrors([error('A')], async () => { throw new Error('caigut'); })).toEqual([null]);
  });

  it('acota les consultes diferents', async () => {
    const consult = vi.fn(async () => result('1'));
    const errors = Array.from({ length: MAX_CITATION_QUERIES + 5 }, (_, i) => error('C', i));
    const cites = await citeErrors(errors, consult);
    expect(consult).toHaveBeenCalledTimes(MAX_CITATION_QUERIES);
    expect(cites.filter(Boolean)).toHaveLength(MAX_CITATION_QUERIES);
  });
});
