/**
 * Registre de proveïdors de veu. Afegir un motor nou (UJI per trossos, un
 * servei al núvol…) és una entrada més ací: el servidor i la pàgina de proves
 * no canvien perquè treballen contra `StreamingStt`.
 */
import { config } from '../config.js';
import { createVoskSidecarStt } from './voskSidecar.js';
import type { StreamingStt } from './types.js';

const factories: Record<string, () => StreamingStt> = {
  vosk: createVoskSidecarStt,
};

/** El sidecar del model és car: una sola instància per proveïdor. */
const instances = new Map<string, StreamingStt>();

export function getStreamingStt(id: string = config.provider): StreamingStt {
  const cached = instances.get(id);
  if (cached) return cached;

  const factory = factories[id];
  if (!factory) {
    throw new Error(
      `Proveïdor de veu desconegut: ${id} (disponibles: ${availableProviders.join(', ')})`,
    );
  }
  const provider = factory();
  instances.set(id, provider);
  return provider;
}

export const availableProviders = Object.keys(factories);

/** Atura els proveïdors arrancats (per a un tancament net del servidor). */
export async function disposeProviders(): Promise<void> {
  const providers = [...instances.values()];
  instances.clear();
  await Promise.all(providers.map((provider) => provider.dispose()));
}
