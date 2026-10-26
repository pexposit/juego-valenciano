import { consultarGnv, type GnvResultat } from './gnvRag.js';

// Cites de la GNV per als errors d'un text corregit. Un error repetit (mateix fragment i correcció) comparteix una sola
// consulta al RAG (≈3 s cada una): com a molt MAX_CITATION_QUERIES de diferents, en sèrie perquè el RAG les atén així.
// No es comparteix per contingut: dos errors del mateix contingut (p. ex. dos accents) poden ser de seccions diferents.
export const MAX_CITATION_QUERIES = 8;

export type CitableError = { error_text: string; correction: string; category: string; subcategory: string | null };
export type Citation = { seccio: string; etiqueta: string };

const groupKey = (e: CitableError) => `${e.error_text.trim().toLowerCase()}|${e.correction.trim().toLowerCase()}`;

/**
 * Per a cada error, la secció de la GNV que el cobrix (o null). Un error sense respaldo o fora dels primers
 * MAX_CITATION_QUERIES errors diferents no porta cita. `consult` és injectable per als tests.
 */
export async function citeErrors(
  errors: CitableError[],
  consult: (query: string, k: number) => Promise<GnvResultat> = consultarGnv,
  signal?: AbortSignal,
): Promise<(Citation | null)[]> {
  const groups = new Map<string, CitableError>();
  for (const e of errors) if (!groups.has(groupKey(e))) groups.set(groupKey(e), e);

  const found = new Map<string, Citation | null>();
  for (const [key, sample] of [...groups].slice(0, MAX_CITATION_QUERIES)) {
    if (signal?.aborted) break;
    try {
      const result = await consult(`«${sample.error_text}» s'escriu «${sample.correction}»`.slice(0, 400), 2);
      const [source] = result.hay_respaldo ? result.fuentes : [];
      found.set(key, source ? { seccio: source.seccion, etiqueta: source.etiqueta } : null);
    } catch (error) {
      console.warn("[gnv-citations] no s'ha pogut consultar la GNV:", error instanceof Error ? error.message : error);
      found.set(key, null);
    }
  }
  return errors.map((e) => found.get(groupKey(e)) ?? null);
}
