/**
 * Pruebas de las métricas de sesión (src/metrics.ts).
 *
 * Son las cifras con las que se decidirá si Vosk vale para el juego
 * (latencia del primer parcial y factor de tiempo real), así que conviene
 * fijar aquí qué se cuenta y qué no: los resultados sin texto (silencio
 * inicial) no cuentan como parcial ni como final.
 */
import { describe, expect, it } from 'vitest';
import { SessionMetrics } from './metrics.js';
import type { StreamingTranscript } from './streaming/types.js';

const partial = (text: string, atMs: number, latencyMs = 10): StreamingTranscript =>
  ({ text, isFinal: false, atMs, latencyMs });

const final = (text: string, atMs: number, latencyMs = 10): StreamingTranscript =>
  ({ text, isFinal: true, atMs, latencyMs });

describe('SessionMetrics', () => {
  it('arranca vacía y sin factor de tiempo real', () => {
    const metrics = new SessionMetrics('vosk');
    expect(metrics.snapshot()).toMatchObject({
      provider: 'vosk',
      partials: 0,
      finals: 0,
      firstPartialMs: null,
      finalMs: null,
      audioMs: 0,
      computeMs: 0,
      rtf: null,
    });
  });

  it('guarda la latencia del primer parcial con texto', () => {
    const metrics = new SessionMetrics('vosk');
    metrics.record(partial('', 40));
    metrics.record(partial('bon', 100, 15));
    metrics.record(partial('bon dia', 220, 12));
    expect(metrics.snapshot().firstPartialMs).toBe(100);
    expect(metrics.snapshot().partials).toBe(3);
  });

  it('usa el último final con texto como latencia de cierre', () => {
    const metrics = new SessionMetrics('vosk');
    metrics.record(final('', 900));
    metrics.record(final('bon dia com et puc ajudar hui', 2590, 31));
    expect(metrics.snapshot().finalMs).toBe(2590);
    expect(metrics.snapshot().finals).toBe(2);
  });

  it('suma el cómputo y calcula el factor de tiempo real', () => {
    const metrics = new SessionMetrics('vosk');
    metrics.record(partial('bon', 100, 24));
    metrics.record(final('bon dia', 2000, 26));
    metrics.recordAudio(16000 * 2 * 2, 16000); // 2 s de PCM16 mono
    const snapshot = metrics.snapshot();
    expect(snapshot.audioMs).toBe(2000);
    expect(snapshot.computeMs).toBe(50);
    expect(snapshot.rtf).toBe(0.025);
  });

  it('resume la sesión en una línea con el mismo estilo que el backend', () => {
    const metrics = new SessionMetrics('vosk');
    metrics.record(partial('bon', 100, 24));
    metrics.record(final('bon dia', 2590, 31));
    metrics.recordAudio(16000 * 2 * 2.5, 16000);
    expect(metrics.logLine()).toBe(
      '[speech] provider=vosk partials=1 finals=1 first_partial=100ms final=2590ms audio=2.50s rtf=0.022'
      + ' nivell=-dB veu=-',
    );
  });

  it('mide la energía del audio recibido (diagnóstico de micro sin señal)', () => {
    const metrics = new SessionMetrics('vosk');
    // Silencio digital: muestras a 0 → nivell -∞ (representat com -120 dB).
    metrics.recordEnergy(Buffer.alloc(16000 * 2), 16000); // 1 s
    expect(metrics.snapshot().voicePct).toBe(0);
    // Tono fuerte (~1000 Hz): PCM16 a media escala → ~-6 dBFS.
    const loud = Buffer.alloc(16000 * 2);
    for (let i = 0; i < 16000; i += 1) loud.writeInt16LE(Math.round(16384 * Math.sin(i * 0.2)), i * 2);
    metrics.recordEnergy(loud, 16000);
    const snapshot = metrics.snapshot();
    expect(snapshot.avgDb).not.toBeNull();
    expect(snapshot.avgDb!).toBeGreaterThan(-20);
    expect(snapshot.voicePct).toBe(50); // 1 s de veu sobre 2 s totals
  });
});
