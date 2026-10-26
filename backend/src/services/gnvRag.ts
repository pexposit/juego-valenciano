/**
 * Client del servici RAG de la Gramàtica Normativa Valenciana (contenidor rag_gnv/).
 * El servici fa la recerca padre/fill (vectors + BM25 fusionats amb RRF, reranker i
 * negativa si la millor puntuació no arriba al llindar) i retorna les seccions de la GNV.
 * Exemple: curl -X POST http://localhost:8010/consultar -H 'Content-Type: application/json' \
 *   -d '{"consulta":"accentuació diacrítica de què i que"}'
 */
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
  if (!gnvRagEnabled()) return Promise.resolve(false);
  if (gpuCheck && Date.now() - gpuCheck.at < GPU_CHECK_TTL_MS) return gpuCheck.busy;
  const busy = fetch(`${baseUrl}/salut`, { signal: AbortSignal.timeout(1_500) })
    .then(async response => response.ok && ((await response.json()) as { device?: string }).device !== 'cpu')
    .catch(() => false);
  gpuCheck = { at: Date.now(), busy };
  return busy;
}

export async function consultarGnv(consulta: string, k = 4): Promise<GnvResultat> {
  const response = await fetch(`${baseUrl}/consultar`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ consulta, k }),
    signal: AbortSignal.timeout(RAG_GNV_TIMEOUT_MS),
  });
  if (!response.ok) throw new Error(`El RAG de la GNV ha respost ${response.status}`);
  return response.json() as Promise<GnvResultat>;
}

/**
 * Puntua (0 a 1) lo bé que respon cada text a la consulta, amb el reranker del mateix servici. El tutor ho fa servir per a
 * triar, entre els exercicis d'una activitat, el que tracta de la pregunta de l'aprenent.
 */
export async function puntuarTextos(consulta: string, textos: string[]): Promise<number[]> {
  const response = await fetch(`${baseUrl}/ordenar`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ consulta, textos }),
    signal: AbortSignal.timeout(RAG_GNV_TIMEOUT_MS),
  });
  if (!response.ok) throw new Error(`El RAG de la GNV ha respost ${response.status}`);
  const { puntuaciones } = await response.json() as { puntuaciones: number[] };
  if (!Array.isArray(puntuaciones) || puntuaciones.length !== textos.length) throw new Error('Resposta invàlida del RAG');
  return puntuaciones;
}

// Context numerat per al LLM (com contexto_para_llm de rag_gnv.py): ha de citar l'id de la font.
export function gnvContext(resultat: GnvResultat): string {
  if (!resultat.hay_respaldo) return '';
  return resultat.fuentes
    .map((f, i) => `<font id="${i + 1}" seccio="${f.seccion}" ruta="${f.ruta}">\n${f.texto.trim()}\n</font>`)
    .join('\n\n');
}
