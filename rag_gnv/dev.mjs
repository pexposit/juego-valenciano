// Arranca el RAG de la GNV con el Python del venv (Windows o Linux/Mac). Si no hi ha venv, avisa i ix
// sense error: `npm run dev` continua sense el RAG (el tutor contesta igual, sense la regla de la GNV).
import { spawn } from 'node:child_process';
import { existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const python = process.env.RAG_GNV_PYTHON
  ?? [join(here, '.venv', 'Scripts', 'python.exe'), join(here, '.venv', 'bin', 'python')].find(existsSync);

if (!python) {
  console.warn('[rag] No hi ha rag_gnv/.venv: el RAG de la GNV no s\'arranca. Crea-la amb:');
  console.warn('[rag]   cd rag_gnv && python -m venv .venv && .venv/Scripts/python -m pip install -r requirements.txt');
  process.exit(0);
}

const child = spawn(python, ['servidor.py'], { cwd: here, stdio: 'inherit' });
child.on('exit', code => process.exit(code ?? 0));
for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => child.kill(signal));
