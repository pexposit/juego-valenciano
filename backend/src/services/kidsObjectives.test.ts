import { describe, expect, it } from 'vitest';
import { checkObjectives, parseObjectives } from './kidsObjectives.js';

describe('parseObjectives', () => {
  it('llig la llista de complits', () => {
    expect(parseObjectives('{"complits": [true, false, true]}', 3)).toEqual([true, false, true]);
  });

  it('tolera text o un bloc ```json``` al voltant', () => {
    expect(parseObjectives('Ací la tens:\n```json\n{"complits": [false, true]}\n```', 2)).toEqual([false, true]);
  });

  it('rebutja respostes que no quadren amb els objectius', () => {
    expect(parseObjectives('{"complits": [true]}', 2)).toBeNull();
    expect(parseObjectives('{"complits": ["sí", "no"]}', 2)).toBeNull();
    expect(parseObjectives('No ho sé', 1)).toBeNull();
  });
});

describe('checkObjectives', () => {
  it('sense LLM configurat, deixa cada objectiu sense revisar (null)', async () => {
    const key = process.env.OPENAI_API_KEY;
    delete process.env.OPENAI_API_KEY;
    await expect(checkObjectives(['Saludar.', 'Comptar fins a cinc.'], [{ role: 'user', content_text: 'Hola!' }])).resolves.toEqual([null, null]);
    if (key) process.env.OPENAI_API_KEY = key;
  });
});
