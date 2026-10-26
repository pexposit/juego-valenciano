import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { loadSharedKeys } from './env.js';

describe('loadSharedKeys', () => {
  let dir: string;
  let file: string;
  beforeEach(() => {
    dir = mkdtempSync(join(tmpdir(), 'env-'));
    file = join(dir, '.env');
  });
  afterEach(() => rmSync(dir, { recursive: true, force: true }));

  it('copia solo las claves compartidas del .env de la raíz', () => {
    writeFileSync(file, 'OPENAI_API_KEY=sk-1\nTYPESAFE_API_KEY=ts-1\nJWT_SECRET=secreto\nDOMAIN=localhost\n');
    const target: NodeJS.ProcessEnv = {};
    loadSharedKeys(file, target);
    expect(target).toEqual({ OPENAI_API_KEY: 'sk-1', TYPESAFE_API_KEY: 'ts-1' });
  });

  it('no pisa una variable ya definida en el entorno', () => {
    writeFileSync(file, 'OPENAI_API_KEY=de-la-raiz\n');
    const target: NodeJS.ProcessEnv = { OPENAI_API_KEY: 'del-entorno' };
    loadSharedKeys(file, target);
    expect(target.OPENAI_API_KEY).toBe('del-entorno');
  });

  it('ignora las claves vacías y no falla si el archivo no existe', () => {
    writeFileSync(file, 'OPENAI_API_KEY=\n');
    const target: NodeJS.ProcessEnv = {};
    loadSharedKeys(file, target);
    loadSharedKeys(join(dir, 'no-existe.env'), target);
    expect(target).toEqual({});
  });
});
