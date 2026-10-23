import { randomUUID } from 'node:crypto';
import type { AgentDocument } from '@parlaval/shared';

/**
 * Text dels documents que la docent ha adjuntat a l'agent (examen o temari), en la memòria del procés.
 *
 * El fitxer no es guarda mai. Del text se'n conserva una còpia en RAM, lligada a la docent que l'ha pujat, perquè cada
 * petició puga triar els fragments rellevants (documentSelect.ts). Caduca als 60 minuts sense usar (DOCUMENT_TTL_MIN), cada
 * docent en pot tindre uns quants (DOCUMENT_MAX_PER_USER) i la memòria total és limitada (DOCUMENT_STORE_MB): si s'omple,
 * s'esborren els més antics. Es perd en reiniciar el servidor i no es comparteix entre instàncies.
 */

const MB = 1024 * 1024;
const num = (name: string, fallback: number) => {
  const value = Number(process.env[name]);
  return Number.isFinite(value) && value > 0 ? value : fallback;
};

type Stored = { id: string; userId: string; name: string; text: string; truncated: boolean; bytes: number; createdAt: number; expiresAt: number };
const store = new Map<string, Stored>(); // l'ordre d'inserció és de més antic a més nou
let totalBytes = 0;

const ttlMs = () => num('DOCUMENT_TTL_MIN', 60) * 60_000;
const maxBytes = () => num('DOCUMENT_STORE_MB', 400) * MB;
const maxPerUser = () => num('DOCUMENT_MAX_PER_USER', 5);

function drop(id: string) {
  const doc = store.get(id);
  if (!doc) return;
  totalBytes -= doc.bytes;
  store.delete(id);
}

function purge(now: number, userId?: string) {
  for (const doc of [...store.values()]) if (doc.expiresAt <= now) drop(doc.id);
  if (userId) {
    const mine = [...store.values()].filter(d => d.userId === userId);
    for (const doc of mine.slice(0, Math.max(0, mine.length - maxPerUser() + 1))) drop(doc.id);
  }
  for (const id of [...store.keys()]) {
    if (totalBytes <= maxBytes()) break;
    drop(id);
  }
}

/** Guarda el text d'un document de la docent i torna el que sap el client (l'identificador i la mida). */
export function putDocument(userId: string, doc: { name: string; text: string; chars: number; truncated: boolean }, now = Date.now()): AgentDocument {
  purge(now, userId);
  const id = randomUUID();
  // Una cadena de JS ocupa fins a 2 bytes per caràcter.
  const bytes = doc.text.length * 2;
  store.set(id, { id, userId, name: doc.name, text: doc.text, truncated: doc.truncated, bytes, createdAt: now, expiresAt: now + ttlMs() });
  totalBytes += bytes;
  purge(now);
  return { id, name: doc.name, chars: doc.chars, truncated: doc.truncated };
}

/** El document de la docent, o null si no existix, és d'una altra persona o ha caducat. Cada ús renova el temps. */
export function getDocument(userId: string, id: string, now = Date.now()): { name: string; text: string; truncated: boolean } | null {
  purge(now);
  const doc = store.get(id);
  if (!doc || doc.userId !== userId) return null;
  doc.expiresAt = now + ttlMs();
  return { name: doc.name, text: doc.text, truncated: doc.truncated };
}

export const documentStoreStats = () => ({ documents: store.size, bytes: totalBytes, maxBytes: maxBytes() });
export function clearDocuments() {
  store.clear();
  totalBytes = 0;
}
