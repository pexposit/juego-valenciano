/**
 * Mesures d'una sessió de veu en temps real. Seguix l'estil dels logs del
 * backend (`[turn] stt=…ms agente=…ms tts=…ms`) perquè siguen comparables.
 */
import type { StreamingTranscript } from './streaming/types.js';

export type SessionMetricsPayload = {
  provider: string
  partials: number
  finals: number
  /** Latència fins al primer parcial amb text (ms), la xifra que percep l'usuari. */
  firstPartialMs: number | null
  /** Latència fins a l'últim resultat final (ms). */
  finalMs: number | null
  audioMs: number
  /** Suma del còmput del proveïdor (ms). */
  computeMs: number
  /** Factor de temps real: còmput / àudio. Per davall d'1 va més ràpid que la parla. */
  rtf: number | null
  /** Nivell mitjà de l'àudio rebut (dBFS); serveix per a detectar un micro sense senyal. */
  avgDb: number | null
  /** Percentatge de fragments amb energia de parla (per damunt del llindar). */
  voicePct: number | null
}

/** Per damunt d'este nivell (dBFS) considerem que hi ha veu, no silenci. */
export const VOICE_DB_THRESHOLD = -45;

export class SessionMetrics {
  private partials = 0;
  private finals = 0;
  private firstPartialMs: number | null = null;
  private finalMs: number | null = null;
  private audioMs = 0;
  private computeMs = 0;
  /** Acumulat per a la mitjana energètica (potència × ms) i total de ms. */
  private powerSum = 0;
  private energyMs = 0;
  private voicedMs = 0;

  constructor(private readonly provider: string) {}

  record(transcript: StreamingTranscript): void {
    this.computeMs += transcript.latencyMs;

    if (transcript.isFinal) {
      this.finals += 1;
      if (transcript.text) this.finalMs = transcript.atMs;
      return;
    }

    this.partials += 1;
    if (transcript.text && this.firstPartialMs === null) this.firstPartialMs = transcript.atMs;
  }

  /** L'àudio enviat és PCM16 mono: 2 bytes per mostra. */
  recordAudio(bytes: number, sampleRate: number): void {
    this.audioMs += (bytes / 2 / sampleRate) * 1000;
  }

  /**
   * Energia del fragment rebut (RMS en dBFS). Sense esta mesura, una sessió
   * amb el micròfon equivocat (o sense senyal) sembla idèntica a una de bona
   * fins que passen els segons i cap resultat arriba: ací ho veiem a l'instant.
   */
  recordEnergy(chunk: Buffer, sampleRate: number): void {
    const samples = chunk.length >> 1;
    if (samples === 0) return;
    let sumSquares = 0;
    for (let i = 0; i < samples; i += 1) {
      const value = chunk.readInt16LE(i * 2);
      sumSquares += value * value;
    }
    const ms = (samples / sampleRate) * 1000;
    const rms = Math.sqrt(sumSquares / samples) / 32768;
    this.powerSum += rms * rms * ms;
    this.energyMs += ms;
    const db = 20 * Math.log10(Math.max(rms, 1e-9));
    if (db > VOICE_DB_THRESHOLD) this.voicedMs += ms;
  }

  snapshot(): SessionMetricsPayload {
    const avgRms = this.energyMs > 0 ? Math.sqrt(this.powerSum / this.energyMs) : null;
    return {
      provider: this.provider,
      partials: this.partials,
      finals: this.finals,
      firstPartialMs: round(this.firstPartialMs),
      finalMs: round(this.finalMs),
      audioMs: Math.round(this.audioMs),
      computeMs: Math.round(this.computeMs),
      rtf: this.audioMs > 0 ? Number((this.computeMs / this.audioMs).toFixed(3)) : null,
      avgDb: avgRms === null ? null : Number((20 * Math.log10(Math.max(avgRms, 1e-9))).toFixed(1)),
      voicePct: this.energyMs > 0 ? Number(((this.voicedMs / this.energyMs) * 100).toFixed(0)) : null,
    };
  }

  logLine(): string {
    const m = this.snapshot();
    return (
      `[speech] provider=${m.provider} partials=${m.partials} finals=${m.finals}`
      + ` first_partial=${m.firstPartialMs ?? '-'}ms final=${m.finalMs ?? '-'}ms`
      + ` audio=${(m.audioMs / 1000).toFixed(2)}s rtf=${m.rtf ?? '-'}`
      + ` nivell=${m.avgDb ?? '-'}dB veu=${m.voicePct === null ? '-' : `${m.voicePct}%`}`
    );
  }
}

function round(value: number | null): number | null {
  return value === null ? null : Math.round(value);
}

export function logSummary(metrics: SessionMetrics): void {
  console.log(metrics.logLine());
}
