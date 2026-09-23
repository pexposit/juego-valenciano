/**
 * Registre de proveïdors de transcripció per lots. Mateix patró que
 * `streaming/registry.ts`: afegir un motor nou és una entrada més ací.
 */
import { config } from '../config.js';
import { createWhisperBatchStt } from './whisperSidecar.js';
import type { BatchStt } from './types.js';

const factories: Record<string, () => BatchStt> = {
  aina: createWhisperBatchStt,
};

/** El model de lots és car (GB en GPU): una sola instància per proveïdor. */
const instances = new Map<string, BatchStt>();

export function getBatchStt(id: string = config.batchProvider): BatchStt {
  const cached = instances.get(id);
  if (cached) return cached;

  const factory = factories[id];
  if (!factory) {
    throw new Error(
      `Proveïdor de lots desconegut: ${id} (disponibles: ${availableBatchProviders.join(', ')})`,
    );
  }
  const provider = factory();
  instances.set(id, provider);
  return provider;
}

export const availableBatchProviders = Object.keys(factories);

/** Atura els proveïdors arrancats (per a un tancament net del servidor). */
export async function disposeBatchProviders(): Promise<void> {
  const providers = [...instances.values()];
  instances.clear();
  await Promise.all(providers.map((provider) => provider.dispose()));
}
