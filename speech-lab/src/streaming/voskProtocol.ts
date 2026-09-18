/**
 * Protocol del sidecar de Vosk: exactament el que usa `vosk-server`
 * (`{"config": …}`, frames binaris, `{"partial"|"text"}`), de manera que el
 * proveïdor es pot substituir sense tocar ni el servidor ni la pàgina de proves.
 * Estos helpers estan aïllats perquè es poden provar sense arrancar Python.
 */

export type SidecarConfig = {
  sample_rate?: number
  phrase_list?: string[]
  words?: boolean
}

export type SidecarEvent =
  | { kind: 'partial'; text: string; computeMs?: number }
  | { kind: 'final'; text: string; computeMs?: number }
  | { kind: 'error'; message: string }

export function buildConfigMessage(options: SidecarConfig): string {
  return JSON.stringify({ config: options })
}

export function buildEofMessage(): string {
  return JSON.stringify({ eof: 1 })
}

export function parseSidecarMessage(raw: string): SidecarEvent {
  let payload: unknown;
  try {
    payload = JSON.parse(raw);
  } catch {
    throw new Error('El sidecar de Vosk ha respost un JSON no vàlid');
  }
  if (typeof payload !== 'object' || payload === null) {
    throw new Error('El sidecar de Vosk ha respost un missatge buit');
  }

  const data = payload as Record<string, unknown>;
  const computeMs = typeof data.compute_ms === 'number' ? data.compute_ms : undefined;

  if (typeof data.error === 'string') return { kind: 'error', message: data.error };
  if (typeof data.partial === 'string') {
    return { kind: 'partial', text: data.partial.trim(), computeMs };
  }
  if (typeof data.text === 'string') {
    return { kind: 'final', text: data.text.trim(), computeMs };
  }
  throw new Error(`Missatge desconegut del sidecar de Vosk: ${raw.slice(0, 120)}`);
}
