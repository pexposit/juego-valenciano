import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

// Los documentos que sube la docente (examen o temario) NO se guardan en la base de datos ni en disco: solo viven
// en la memoria del servidor, con caducidad (documentStore.ts). Este test impide que los módulos que los tratan
// importen nada que persista datos; si hace falta cambiar esa política, hay que hacerlo a propósito.
const read = (file: string) => readFileSync(new URL(file, import.meta.url), 'utf8');
const imports = (source: string) => [...source.matchAll(/^\s*import\s[^;]*?from\s+['"]([^'"]+)['"]/gm)].map(m => m[1]);

const FORBIDDEN = [/supabase/i, /\/db(\.js)?$/, /middleware\/auth/, /^node:fs/, /^fs(\/|$)/, /^pg$/];

describe('los documentos adjuntados no se persisten', () => {
  it.each(['./documentStore.ts', './documentText.ts', './documentSelect.ts'])('%s no importa base de datos ni sistema de ficheros', file => {
    const found = imports(read(file)).filter(spec => FORBIDDEN.some(re => re.test(spec)));
    expect(found).toEqual([]);
  });

  it('la ruta de subida no escribe en la base de datos', () => {
    const route = read('../routes/teacherAgent.ts');
    const upload = route.slice(route.indexOf("'/api/teacher/agent/document'"), route.indexOf("'/api/teacher/agent/capabilities'"));
    expect(upload).toContain('putDocument');
    expect(upload).not.toMatch(/\bdb\(|\.from\(['"`]|\.insert\(|\.upsert\(|\.update\(|writeFile|createWriteStream/);
  });
});
