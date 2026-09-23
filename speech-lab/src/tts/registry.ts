/** Registre de veus: TTS remot (matxa/UJI, el que ja usa el joc) i locals. */
import { config } from '../config.js';
import { createMatxaRemoteTts } from './matxaRemote.js';
import type { StreamingTts } from './types.js';

const factories: Record<string, () => StreamingTts> = {
  matxa: createMatxaRemoteTts,
};

/** Una sola instància per proveïdor (els clients HTTP es comparteixen). */
const instances = new Map<string, StreamingTts>();

export function getStreamingTts(id: string = config.tts.provider): StreamingTts {
  const cached = instances.get(id);
  if (cached) return cached;

  const factory = factories[id];
  if (!factory) {
    throw new Error(
      `Proveïdor de TTS desconegut: ${id} (disponibles: ${availableTtsProviders.join(', ')})`,
    );
  }
  const provider = factory();
  instances.set(id, provider);
  return provider;
}

export const availableTtsProviders = Object.keys(factories);

/** Atura els proveïdors arrancats (per a un tancament net del servidor). */
export async function disposeTtsProviders(): Promise<void> {
  const providers = [...instances.values()];
  instances.clear();
  await Promise.all(providers.map((provider) => provider.dispose()));
}
