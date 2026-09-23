/**
 * Transcripció per lots (fitxer sencer, no streaming): la peça que faltava al
 * costat de `streaming/`. El cas d'ús és la transcripció automàtica
 * (`POST /api/transcribe`) i el bench de WER amb veu humana (fase 4): ací la
 * latència parcial no importa, importa la qualitat del text final amb marques
 * de temps.
 */

export type BatchSegment = {
  /** Inici del segment, en mil·lisegons des de l'inici de l'àudio. */
  startMs: number
  endMs: number
  text: string
};

export type BatchWord = {
  word: string
  startMs: number
  endMs: number
  /** Probabilitat mitjana del token (0–1); pot faltar segons el motor. */
  probability?: number
};

export type BatchTranscript = {
  text: string
  language?: string
  segments: BatchSegment[]
  words: BatchWord[]
  /** Mil·lisegons de còmput del motor (mateix esperit que `compute_ms`). */
  computeMs: number
  /** Segons d'àudio processats (per al factor de temps real). */
  audioSecs: number
};

export type BatchSttOptions = {
  /** Codi de llengua (per defecte `ca`). */
  language?: string
  /** `transcribe` (defecte) o `translate` (a l'anglés, estil Whisper). */
  task?: 'transcribe' | 'translate'
  /** Inclou marques de temps per paraula (costa una mica més de còmput). */
  wordTimestamps?: boolean
};

export interface BatchStt {
  readonly id: string
  /** Model concret (p. ex. `projecte-aina/faster-whisper-large-v3-ca-3catparla`). */
  readonly modelId: string
  /** Transcriu un WAV PCM16 mono; resol amb text, segments i paraules. */
  transcribe(wavPath: string, options?: BatchSttOptions): Promise<BatchTranscript>
  /** Allibera el sidecar i els processos fills que haja arrancat. */
  dispose(): Promise<void>
}
