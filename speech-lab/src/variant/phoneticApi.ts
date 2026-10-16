/**
 * Client de l'API fonètica PhoneticXeus (DeepLab UJI, `POST /transcribe`).
 *
 * L'API torna els fonemes que sent (amb les alternatives i les seues
 * probabilitats) i, amb `align=true`, l'alineació amb la transcripció
 * fonètica d'un text de referència feta amb espeak. Dos detalls manen:
 *
 * - El fonetitzador d'espeak del servidor NO és segur entre fils: dues
 *   peticions amb `align` alhora es corrompen les referències sense cap
 *   error. Per això totes les peticions d'este procés passen per UNA sola
 *   fila (`serial`), siga qui siga qui les faça.
 * - El fitxer pujat ha de dur una extensió acceptada (.wav, .webm, …); amb
 *   el nom per defecte de FormData (`blob`) l'API el rebutja.
 *
 * `PhoneticBackend` és la interfície que usa el detector: les proves i la
 * comprovació de paritat amb el corpus hi injecten respostes desades.
 */
import { config } from '../config.js';

/** Paràmetres de consulta de `/transcribe` (tots van com a text, igual que en Python). */
export type TranscribeParams = {
  include_text?: 'true' | 'false'
  align?: 'true' | 'false'
  top_k?: string
  g2p_language?: string
  reference_text?: string
  variants?: 'true' | 'false'
};

/** Una alternativa d'un fonema reconegut. */
export type PhoneAlternative = { ipa: string; prob: number };

/** Un fonema reconegut per l'API (només els camps que usa el detector). */
export type HypPhone = {
  ipa: string
  confidence: number
  start_s: number
  end_s: number
  alternatives?: PhoneAlternative[]
};

/** Una operació de l'alineació referència ↔ fonemes reconeguts. */
export type AlignmentOp = {
  ref_i: number | null
  hyp_j: number | null
  kind: 'match' | 'substitution' | 'deletion' | 'insertion' | string
  cost: number
};

export type Alignment = {
  reference: { word: string; phones: string[] }[]
  ops: AlignmentOp[]
  words: { word: string; cost: number }[]
  summary: { per: number; mean_cost: number }
};

/**
 * Resposta de `/transcribe`. `_status` l'afig el client (com en Python):
 * el codi HTTP, o -1 si la petició ni tan sols ha arribat.
 */
export type PhoneticResponse = {
  _status: number
  _error?: string
  phones?: HypPhone[]
  text_transcript?: string | null
  text_error?: string | null
  alignment?: Alignment | null
  alignment_error?: string | null
  [key: string]: unknown
};

/** Àudio que es puja: els bytes del fitxer i un nom amb extensió vàlida. */
export type UploadAudio = { data: Uint8Array; filename: string };

export interface PhoneticBackend {
  transcribe(audio: UploadAudio, params: TranscribeParams): Promise<PhoneticResponse>
}

/** Extensions que accepta l'API; qualsevol altre nom es canvia a `.wav`. */
const ACCEPTED_EXTENSIONS = ['.wav', '.webm', '.m4a', '.mp3', '.ogg', '.flac'];

const MIME_BY_EXTENSION: Record<string, string> = {
  '.wav': 'audio/wav',
  '.webm': 'audio/webm',
  '.m4a': 'audio/mp4',
  '.mp3': 'audio/mpeg',
  '.ogg': 'audio/ogg',
  '.flac': 'audio/flac',
};

/** Garantix que el nom porta una extensió acceptada (mai `blob`). */
export function uploadFilename(name: string | undefined): string {
  const clean = (name ?? '').trim().replace(/[\\/]/g, '_');
  const lower = clean.toLowerCase();
  if (clean && ACCEPTED_EXTENSIONS.some((ext) => lower.endsWith(ext))) return clean;
  return `${clean || 'segment'}.wav`;
}

/* ── Fila única de peticions ─────────────────────────────────────────────── */

let tail: Promise<unknown> = Promise.resolve();

/**
 * Executa `task` quan han acabat totes les anteriors. És global al mòdul a
 * propòsit: dos detectors (o dos usuaris) no han de poder solapar peticions.
 */
export function serial<T>(task: () => Promise<T>): Promise<T> {
  const run = tail.then(task, task);
  tail = run.catch(() => undefined);
  return run;
}

const pause = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Cal repetir? Un 500 o un error d'alineació (llevat de «no reference»): són
 * els errors transitoris del servidor. Un temps esgotat no es repetix, que
 * doblaria l'espera de qui ha parlat.
 */
function shouldRetry(response: PhoneticResponse, params: TranscribeParams): boolean {
  if (response._status === 500) return true;
  const alignmentError = response.alignment_error;
  return response._status === 200 && params.align === 'true'
    && typeof alignmentError === 'string' && alignmentError.length > 0
    && !alignmentError.includes('no reference');
}

export type PhoneticApiOptions = {
  baseUrl?: string
  timeoutMs?: number
  /** Espera abans del segon intent (ms). */
  retryDelayMs?: number
  fetchImpl?: typeof fetch
};

/** Client HTTP real; totes les instàncies compartixen la mateixa fila. */
export function createPhoneticApi(options: PhoneticApiOptions = {}): PhoneticBackend {
  const baseUrl = (options.baseUrl ?? config.phonetic.baseUrl).replace(/\/$/, '');
  const timeoutMs = options.timeoutMs ?? config.phonetic.timeoutMs;
  const retryDelayMs = options.retryDelayMs ?? 1000;
  const fetchImpl = options.fetchImpl ?? fetch;

  async function once(audio: UploadAudio, params: TranscribeParams): Promise<PhoneticResponse> {
    const query = new URLSearchParams();
    for (const [key, value] of Object.entries(params)) {
      if (value !== undefined) query.set(key, value);
    }
    const filename = uploadFilename(audio.filename);
    const extension = filename.slice(filename.lastIndexOf('.')).toLowerCase();
    const form = new FormData();
    // Còpia en un ArrayBuffer propi: un Buffer de Node pot ser una vista d'un
    // bloc compartit més gran i Blob el pujaria sencer.
    const bytes = new Uint8Array(audio.data.byteLength);
    bytes.set(audio.data);
    form.append('file', new Blob([bytes], { type: MIME_BY_EXTENSION[extension] ?? 'application/octet-stream' }), filename);
    try {
      const response = await fetchImpl(`${baseUrl}/transcribe?${query.toString()}`, {
        method: 'POST',
        body: form,
        signal: AbortSignal.timeout(timeoutMs),
      });
      const type = response.headers.get('content-type') ?? '';
      if (type.startsWith('application/json')) {
        const body = await response.json() as Record<string, unknown>;
        return { ...body, _status: response.status } as PhoneticResponse;
      }
      return { _status: response.status, _error: (await response.text()).slice(0, 300) };
    } catch (error) {
      return { _status: -1, _error: error instanceof Error ? error.message : String(error) };
    }
  }

  return {
    transcribe(audio, params) {
      // El reintent va dins del mateix torn de la fila: ningú no s'hi cola.
      return serial(async () => {
        const first = await once(audio, params);
        if (!shouldRetry(first, params)) return first;
        await pause(retryDelayMs);
        return once(audio, params);
      });
    },
  };
}
