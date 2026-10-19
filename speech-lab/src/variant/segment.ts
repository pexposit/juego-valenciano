/**
 * Talla una gravació en segments de veu de 3–15 s per a l'API fonètica.
 *
 * L'alineació de l'API té un cost més que lineal amb la durada (i passa de
 * la memòria de la GPU cap als 100 s), i Whisper s'inventa text amb àudios
 * llargs; amb trossos massa curts, en canvi, no hi ha prou vocals per a
 * decidir. Ací es detecta la veu per energia (trames de 20 ms), s'ajunten
 * els trossos curts i es parteixen els llargs pel punt més silenciós.
 *
 * Cada segment es torna com a WAV PCM16 (el que es puja) i com a mostres
 * Float32 (les que usa la mesura de formants), amb la mateixa escala que
 * `read_wav` del prototip (int16 / 32768).
 */

/** Àudio descodificat: mostres mono en [-1, 1) i freqüència d'amostratge. */
export type MonoAudio = { samples: Float32Array; sampleRate: number };

export type SpeechSegment = MonoAudio & {
  /** Inici i final dins de la gravació original (segons). */
  startS: number
  endS: number
  /** El mateix tros com a fitxer WAV PCM16 mono. */
  wav: Uint8Array
};

export type SegmentOptions = {
  minS?: number
  maxS?: number
  /** Un segment que no s'ha pogut ajuntar es descarta si dura menys d'això. */
  minKeepS?: number
  /** Silencis més curts que això no tallen la veu. */
  bridgeGapS?: number
  /** Marge de silenci que es deixa a cada costat de la veu. */
  padS?: number
};

const DEFAULTS: Required<SegmentOptions> = { minS: 3, maxS: 15, minKeepS: 1, bridgeGapS: 0.3, padS: 0.2 };

const FRAME_S = 0.02;

/* ── WAV ─────────────────────────────────────────────────────────────────── */

/** Llig un WAV PCM16 (mono o estèreo, que es mescla com fa el prototip). */
export function decodeWav(file: Uint8Array): MonoAudio {
  const view = new DataView(file.buffer, file.byteOffset, file.byteLength);
  const tag = (at: number) => String.fromCharCode(file[at], file[at + 1], file[at + 2], file[at + 3]);
  if (file.length < 44 || tag(0) !== 'RIFF' || tag(8) !== 'WAVE') throw new Error('El fitxer no és un WAV vàlid');
  let offset = 12;
  let sampleRate = 0;
  let channels = 0;
  let bits = 0;
  let format = 0;
  let data: Uint8Array | null = null;
  while (offset + 8 <= file.length) {
    const id = tag(offset);
    const size = view.getUint32(offset + 4, true);
    const body = offset + 8;
    if (id === 'fmt ' && body + 16 <= file.length) {
      format = view.getUint16(body, true);
      channels = view.getUint16(body + 2, true);
      sampleRate = view.getUint32(body + 4, true);
      bits = view.getUint16(body + 14, true);
    } else if (id === 'data') {
      data = file.subarray(body, Math.min(body + size, file.length));
    }
    offset = body + size + (size % 2);
  }
  if (!data) throw new Error('El WAV no té cap bloc de dades');
  if (bits !== 16 || (format !== 1 && format !== 0xfffe) || channels < 1) {
    throw new Error(`Cal un WAV PCM de 16 bits i este és de ${bits} bits (format ${format})`);
  }
  const frames = Math.floor(data.length / (2 * channels));
  const pcm = new DataView(data.buffer, data.byteOffset, data.byteLength);
  const samples = new Float32Array(frames);
  for (let i = 0; i < frames; i += 1) {
    let acc = 0;
    for (let ch = 0; ch < channels; ch += 1) acc += pcm.getInt16((i * channels + ch) * 2, true) / 32768;
    samples[i] = channels === 1 ? acc : acc / channels;
  }
  return { samples, sampleRate };
}

/** Escriu mostres en [-1, 1] com a WAV PCM16 mono. */
export function encodeWav(samples: ArrayLike<number>, sampleRate: number): Uint8Array {
  const out = new Uint8Array(44 + samples.length * 2);
  const view = new DataView(out.buffer);
  const text = (at: number, s: string) => [...s].forEach((ch, i) => view.setUint8(at + i, ch.charCodeAt(0)));
  text(0, 'RIFF');
  view.setUint32(4, 36 + samples.length * 2, true);
  text(8, 'WAVE');
  text(12, 'fmt ');
  view.setUint32(16, 16, true);
  view.setUint16(20, 1, true);
  view.setUint16(22, 1, true);
  view.setUint32(24, sampleRate, true);
  view.setUint32(28, sampleRate * 2, true);
  view.setUint16(32, 2, true);
  view.setUint16(34, 16, true);
  text(36, 'data');
  view.setUint32(40, samples.length * 2, true);
  for (let i = 0; i < samples.length; i += 1) {
    // Escala int16 / 32768, la inversa exacta de `decodeWav`: anada i tornada sense pèrdua.
    view.setInt16(44 + i * 2, Math.max(-32768, Math.min(32767, Math.round(samples[i] * 32768))), true);
  }
  return out;
}

/** PCM16 mono (Buffer de bytes little-endian o Int16Array) → mostres Float32. */
export function pcm16ToFloat(pcm: Uint8Array | Int16Array): Float32Array {
  const ints = pcm instanceof Int16Array
    ? pcm
    : new Int16Array(pcm.buffer.slice(pcm.byteOffset, pcm.byteOffset + (pcm.byteLength & ~1)));
  const out = new Float32Array(ints.length);
  for (let i = 0; i < ints.length; i += 1) out[i] = ints[i] / 32768;
  return out;
}

/* ── Detecció de veu i tall ──────────────────────────────────────────────── */

/** Energia (dB) de cada trama de 20 ms. */
function frameEnergies(samples: Float32Array, frameLen: number): Float64Array {
  const count = Math.floor(samples.length / frameLen);
  const db = new Float64Array(count);
  for (let f = 0; f < count; f += 1) {
    let acc = 0;
    for (let i = f * frameLen; i < (f + 1) * frameLen; i += 1) acc += samples[i] * samples[i];
    db[f] = 10 * Math.log10(acc / frameLen + 1e-10);
  }
  return db;
}

/** Percentil (0–1) d'una llista de nombres. */
function percentile(values: Float64Array, q: number): number {
  const s = Array.from(values).sort((a, b) => a - b);
  return s[Math.min(s.length - 1, Math.max(0, Math.round(q * (s.length - 1))))];
}

type Span = { start: number; end: number };

/**
 * Llindar de veu adaptatiu: entre el soroll de fons (percentil 10) i la veu
 * forta (percentil 95), mai per davall de −50 dBFS. Si quasi tot és veu (el
 * percentil 10 ja és veu), el límit de 15 dB per davall de la veu forta
 * evita que el llindar se'n vaja per damunt.
 */
function speechSpans(db: Float64Array): Span[] {
  if (db.length === 0) return [];
  const floor = percentile(db, 0.1);
  const loud = percentile(db, 0.95);
  const threshold = Math.max(-50, Math.min(floor + Math.max(6, (loud - floor) * 0.3), loud - 15));
  const spans: Span[] = [];
  let start = -1;
  db.forEach((value, f) => {
    if (value >= threshold && start < 0) start = f;
    if (value < threshold && start >= 0) {
      spans.push({ start, end: f });
      start = -1;
    }
  });
  if (start >= 0) spans.push({ start, end: db.length });
  return spans;
}

/** Trama més silenciosa dins de [from, to). */
function quietestFrame(db: Float64Array, from: number, to: number): number {
  let best = from;
  for (let f = from; f < to; f += 1) if (db[f] < db[best]) best = f;
  return best;
}

/**
 * Talla la gravació en segments de veu de `minS`–`maxS` segons. Els trossos
 * de veu separats per silencis curts s'ajunten; un tros massa llarg es
 * parteix per la trama més silenciosa de la seua segona meitat útil.
 */
export function segmentSpeech(audio: MonoAudio, options: SegmentOptions = {}): SpeechSegment[] {
  const opts = { ...DEFAULTS, ...options };
  const { samples, sampleRate } = audio;
  const frameLen = Math.max(1, Math.round(FRAME_S * sampleRate));
  const db = frameEnergies(samples, frameLen);
  const toFrames = (s: number) => Math.round(s / FRAME_S);
  const totalFrames = db.length;

  // 1) Veu amb marge, i silencis curts pontejats.
  const pad = toFrames(opts.padS);
  const bridged: Span[] = [];
  for (const span of speechSpans(db)) {
    const s = { start: Math.max(0, span.start - pad), end: Math.min(totalFrames, span.end + pad) };
    const prev = bridged[bridged.length - 1];
    if (prev && s.start - prev.end <= toFrames(opts.bridgeGapS)) prev.end = Math.max(prev.end, s.end);
    else bridged.push(s);
  }

  // 2) Ajunta trossos consecutius mentre el conjunt (silencis inclosos) no passe de maxS.
  const maxF = toFrames(opts.maxS);
  const minF = toFrames(opts.minS);
  const merged: Span[] = [];
  for (const span of bridged) {
    const prev = merged[merged.length - 1];
    if (prev && (prev.end - prev.start < minF || span.end - span.start < minF) && span.end - prev.start <= maxF) {
      prev.end = span.end;
    } else {
      merged.push({ ...span });
    }
  }

  // 3) Parteix els llargs pel punt més silenciós, deixant trossos d'almenys minS.
  const pieces: Span[] = [];
  for (const span of merged) {
    let { start } = span;
    while (span.end - start > maxF) {
      const from = start + Math.min(minF, Math.floor(maxF / 2));
      const to = Math.min(start + maxF, span.end - minF);
      const cut = to > from ? quietestFrame(db, from, to) : start + maxF;
      pieces.push({ start, end: cut });
      start = cut;
    }
    pieces.push({ start, end: span.end });
  }

  const minKeep = toFrames(opts.minKeepS);
  return pieces
    .filter((span) => span.end - span.start >= minKeep)
    .map((span) => {
      const from = span.start * frameLen;
      const to = span.end >= totalFrames ? samples.length : span.end * frameLen;
      const part = samples.slice(from, to);
      return {
        samples: part,
        sampleRate,
        startS: from / sampleRate,
        endS: to / sampleRate,
        wav: encodeWav(part, sampleRate),
      };
    });
}
