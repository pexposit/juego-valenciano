/**
 * Mateix esperit que `backend/src/services/voice.ts`: els proveïdors de veu
 * viuen darrere d'una interfície perquè canviar de motor no obligue a tocar
 * ni el servidor ni la pàgina de proves.
 */

export type StreamingTranscript = {
  text: string
  /** `false` per als resultats parcials; `true` quan el proveïdor detecta el final del torn. */
  isFinal: boolean
  /** Mil·lisegons des de l'inici de la sessió fins que s'ha obtingut este resultat. */
  atMs: number
  /**
   * Còmput del motor per al fragment que ha provocat este resultat.
   * Quan el proveïdor l'informa s'usa eixe valor; si no, cau al temps de
   * tornada, que amb àudio enviat més ràpid que la parla inclou la cua.
   */
  latencyMs: number
}

export type StreamingSttSession = {
  /** Envia un fragment d'àudio PCM16 mono little-endian. */
  push(chunk: Buffer): void
  /** Demana el resultat final i tanca la sessió (endpointing del proveïdor). */
  end(): Promise<void>
  /** Subscriu un observador; retorna la funció per a desubscriure's. */
  on(handler: (transcript: StreamingTranscript) => void): () => void
  /** Subscriu un observador d'errors; retorna la funció per a desubscriure's. */
  onError(handler: (message: string) => void): () => void
  /** Allibera el socket sense esperar el final. */
  close(): void
  /** Mil·lisegons d'àudio enviats (per a calcular el factor de temps real). */
  readonly audioMs: number
}

export type StreamingSttOptions = {
  sampleRate?: number
  /**
   * Vocabulari/frases restringides. Retalla molt el còmput i augmenta la
   * precisió, però el proveïdor descarta tot el que no estiga a la llista:
   * les frases han d'anar normalitzades (sense puntuació).
   */
  phraseList?: string[]
  /** Inclou marques de temps per paraula en els resultats finals. */
  words?: boolean
}

export interface StreamingStt {
  readonly id: string
  open(options?: StreamingSttOptions): Promise<StreamingSttSession>
  /** Atura el proveïdor i els processos fills que haja arrancat. */
  dispose(): Promise<void>
}
