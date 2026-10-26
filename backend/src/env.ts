import { existsSync, readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import dotenv from 'dotenv';

// Claves compartides entre servicis (backend, RAG...): viuen en un sol lloc, el `.env` de l'arrel del repositori (el mateix que
// llig docker compose). Només es copien estes; la resta de variables d'eixe fitxer (secrets de Supabase...) no entren al backend.
export const SHARED_KEYS = ['OPENAI_API_KEY', 'TYPESAFE_API_KEY'] as const;

const ROOT_ENV = fileURLToPath(new URL('../../.env', import.meta.url));

/**
 * Carrega les claus compartides del `.env` de l'arrel en `target`. Les variables ja definides en l'entorn manen, i van
 * abans que `backend/.env` (que dotenv carrega després i tampoc no sobreescriu): si una clau està en els dos, guanya la de l'arrel.
 */
export function loadSharedKeys(file: string = ROOT_ENV, target: NodeJS.ProcessEnv = process.env): void {
  if (!existsSync(file)) return;
  const values = dotenv.parse(readFileSync(file));
  for (const key of SHARED_KEYS) {
    if (values[key] && target[key] === undefined) target[key] = values[key];
  }
}

loadSharedKeys();
