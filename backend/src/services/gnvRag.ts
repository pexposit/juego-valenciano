/**
 * Client del servici RAG de la Gramàtica Normativa Valenciana (contenidor rag_gnv/).
 * El servici fa la recerca padre/fill (vectors + BM25 fusionats amb RRF, reranker i
 * negativa si la millor puntuació no arriba al llindar) i retorna les seccions de la GNV.
 * Exemple: curl -X POST http://localhost:8010/consultar -H 'Content-Type: application/json' \
 *   -d '{"consulta":"accentuació diacrítica de què i que"}'
 */
import { createHash } from 'node:crypto';
import { createLookupCache, normalizeQuery } from './lookupCache.js';

export interface GnvFont {
  seccion: string;
  ruta: string;
  etiqueta: string; // 'GNV § 5.1.3 · Ortografia > ...'
  puntuacion: number;
  texto: string;
}

export interface GnvResultat {
  hay_respaldo: boolean;
  mejor_puntuacion: number;
  mensaje: string;
  fuentes: GnvFont[];
}

// El que rep el client: la regla oficial (cita), el contingut breu i l'explicació fàcil.
export interface GnvRule {
  regla: string;
  seccio: string;
  ruta: string;
  contingut: string;
  explicacio: string;
  text_original: string;
  // Altres seccions de la GNV que completen la regla (el cas contrari, excepcions...).
  relacionades: { regla: string; seccio: string; ruta: string; text: string }[];
}

const baseUrl = (process.env.RAG_GNV_URL || 'http://localhost:8010').replace(/\/$/, '');
const RAG_GNV_TIMEOUT_MS = Number(process.env.RAG_GNV_TIMEOUT_MS) || 20_000;

export const gnvRagEnabled = () => process.env.RAG_GNV_ENABLED !== 'false';

// La resposta de /salut es guarda uns segons: el menú de veus i cada frase del TTS ho pregunten.
const GPU_CHECK_TTL_MS = 15_000;
let gpuCheck: { at: number; busy: Promise<boolean> } | null = null;

/**
 * true si el RAG està en marxa amb els models en la GPU. El RAG té prioritat: mentre l'ocupa, el backend no demana
 * al laboratori de veu les veus que necessiten GPU (amb 6 GB no caben els dos). Un RAG antic que no diu el
 * `device` es compta com a GPU.
 */
export function gnvRagUsesGpu(): Promise<boolean> {
  // device "api": el reranker és Jev (TypeSafe) i el local no s'ha carregat, així que el RAG no ocupa la GPU.
  if (!gnvRagEnabled()) return Promise.resolve(false);
  if (gpuCheck && Date.now() - gpuCheck.at < GPU_CHECK_TTL_MS) return gpuCheck.busy;
  const busy = fetch(`${baseUrl}/salut`, { signal: AbortSignal.timeout(1_500) })
    .then(async response => response.ok && !['cpu', 'api'].includes(((await response.json()) as { device?: string }).device ?? ''))
    .catch(() => false);
  gpuCheck = { at: Date.now(), busy };
  return busy;
}

/** La consulta es normalitza (`normalizeQuery`): majúscules, cometes o puntuació diferents fan la mateixa recerca. */
export async function consultarGnv(consulta: string, k = 4): Promise<GnvResultat> {
  const response = await fetch(`${baseUrl}/consultar`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ consulta: normalizeQuery(consulta), k }),
    signal: AbortSignal.timeout(RAG_GNV_TIMEOUT_MS),
  });
  if (!response.ok) throw new Error(`El RAG de la GNV ha respost ${response.status}`);
  return response.json() as Promise<GnvResultat>;
}

/**
 * Puntua (0 a 1) lo bé que respon cada text a la consulta, amb el reranker del mateix servici. El tutor ho fa servir per a
 * triar, entre els exercicis d'una activitat, el que tracta de la pregunta de l'aprenent.
 */
export type Reranker = 'jev' | 'local';

// Puntuació de cada text per a cada consulta (normalitzada): el reranker és determinista, així que només se li envien els
// textos que encara no s'han puntuat per a eixa consulta. Una llista que canvia (exercicis ja mostrats, nous...) reutilitza
// la resta.
type Scored = { score: number; reranker: Reranker };
const scoreCache = createLookupCache<Scored>({
  ttlMs: (Number(process.env.RERANK_CACHE_TTL_MIN) || 7 * 24 * 60) * 60_000,
  maxEntries: Number(process.env.RERANK_CACHE_ENTRIES) || 50_000,
});
export const clearRerankCache = () => scoreCache.clear();

async function rerank(consulta: string, textos: string[]): Promise<{ scores: number[]; reranker: Reranker }> {
  const response = await fetch(`${baseUrl}/ordenar`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ consulta, textos }),
    signal: AbortSignal.timeout(RAG_GNV_TIMEOUT_MS),
  });
  if (!response.ok) throw new Error(`El RAG de la GNV ha respost ${response.status}`);
  // Cada reranker té la seua escala: qui ho fa servir tria el llindar segons `reranker` (un RAG antic no el diu: local).
  const { puntuaciones, reranker } = await response.json() as { puntuaciones: number[]; reranker?: Reranker };
  if (!Array.isArray(puntuaciones) || puntuaciones.length !== textos.length) throw new Error('Resposta invàlida del RAG');
  return { scores: puntuaciones, reranker: reranker ?? 'local' };
}

export async function puntuarTextos(consulta: string, textos: string[]): Promise<{ scores: number[]; reranker: Reranker }> {
  const query = normalizeQuery(consulta);
  const all = textos.map((_, i) => i);
  const keys = textos.map(text => `${query}\0${createHash('sha256').update(text).digest('hex')}`);
  const cached: (Scored | undefined)[] = await Promise.all(keys.map(key => scoreCache.peek(key)));
  const known = new Set(cached.flatMap(x => (x ? [x.reranker] : [])));
  const missing = all.filter(i => !cached[i]);
  if (missing.length === 0 && known.size === 1) {
    console.log(`[rerank] ${textos.length}/${textos.length} puntuacions de la cache`);
    return { scores: cached.map(x => x!.score), reranker: [...known][0] };
  }
  // Cada reranker té la seua escala: si les guardades són d'un altre (o barrejades), es tornen a puntuar totes.
  let toScore = known.size <= 1 ? missing : all;
  let fresh = await rerank(query, toScore.map(i => textos[i]));
  if (toScore.length < textos.length && !known.has(fresh.reranker)) {
    toScore = all;
    fresh = await rerank(query, textos);
  }
  toScore.forEach((index, j) => {
    cached[index] = { score: fresh.scores[j], reranker: fresh.reranker };
    scoreCache.set(keys[index], cached[index]!);
  });
  console.log(`[rerank] ${textos.length - toScore.length}/${textos.length} puntuacions de la cache`);
  return { scores: cached.map(x => x!.score), reranker: fresh.reranker };
}

// Context numerat per al LLM (com contexto_para_llm de rag_gnv.py): ha de citar l'id de la font.
export function gnvContext(resultat: GnvResultat): string {
  if (!resultat.hay_respaldo) return '';
  return resultat.fuentes
    .map((f, i) => `<font id="${i + 1}" seccio="${f.seccion}" ruta="${f.ruta}">\n${f.texto.trim()}\n</font>`)
    .join('\n\n');
}
