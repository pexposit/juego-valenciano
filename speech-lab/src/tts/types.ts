/**
 * Síntesi de veu per al laboratori: la peça simètrica de `streaming/` i
 * `batch/`. El cas d'ús és el mode trucada en directe (fase C): el servidor
 * troceja la resposta de l'agent per frases i les sintetitza en paral·lel
 * mentre sona l'anterior.
 *
 * El primer proveïdor (`matxa`) és el mateix endpoint OpenAI-compatible que
 * ja usa el joc (`backend/src/services/voice.ts`): així el laboratori parla
 * amb les veus gina/lluc sense duplicar cap model.
 */

export type TtsAudio = {
  /** WAV sencer (el que retorna matxa-tts amb `response_format=wav`). */
  audio: Buffer
  mimeType: string
  /** Veu demanada (p. ex. `gina`); el proveïdor pot normalitzar-la. */
  voice: string
  /** Mil·lisegons fins al primer byte d'àudio (la latència que percep l'usuari). */
  firstByteMs: number
};

export type TtsOptions = {
  /** Veu del catàleg del proveïdor (`gina`/`lluc` en matxa). */
  voice?: string
  /** Codi de llengua (`ca-es` en matxa-tts). */
  language?: string
};

export interface StreamingTts {
  readonly id: string
  /** Veus disponibles segons el proveïdor (pot requerir xarxa). */
  voices(): Promise<string[]>
  /** Sintetitza un text sencer; resol quan l'àudio està complet. */
  synthesize(text: string, options?: TtsOptions): Promise<TtsAudio>
  /** El proveïdor remot no té procés fill: no-op per defecte. */
  dispose(): Promise<void>
}
