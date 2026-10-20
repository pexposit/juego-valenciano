/**
 * Proves del catàleg de veus derivades (scripts/veus.json → `veu:<nom>`).
 *
 * El fitxer el llig el servidor a cada petició: estes proves fixen com es
 * converteix cada entrada en model sense arrancar Matxa, i que les veus del
 * repositori (narradora i nena) parteixen de gina, la locutora valenciana.
 */
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { config } from '../config.js';
import { derivedVoiceModels, localTtsModels, type DerivedVoice } from './local.js';

describe('localTtsModels', () => {
  // Depén dels models que hi haja en disc: sense cap RVC, la prova no comprova res.
  it('els personatges RVC van abans que la resta de models', () => {
    const kinds = localTtsModels().map((m) => m.id.startsWith('rvc:'));
    expect(kinds).toEqual([...kinds].sort((a, b) => Number(b) - Number(a)));
  });
});

describe('derivedVoiceModels', () => {
  it('sense camps, és gina amb els valors de Matxa sense tocar', () => {
    expect(derivedVoiceModels({ prova: {} })).toEqual([{
      id: 'veu:prova', label: 'prova (gina · valencià)', group: 'Matxa local · veus derivades',
      baseSpeaker: 7, temperature: 0.667, speed: 1, pitch: 0, formant: 1,
    }]);
  });

  it('respecta el locutor, la prosòdia, el to i els formants de cada entrada', () => {
    const [model] = derivedVoiceModels({
      avi: { nom: 'Avi', base: 6, temperatura: 0.4, durada: 1.2, to: -2, formants: 0.95 },
    });
    expect(model).toMatchObject({
      id: 'veu:avi', label: 'Avi (lluc · valencià)', baseSpeaker: 6,
      temperature: 0.4, speed: 1.2, pitch: -2, formant: 0.95,
    });
  });
});

describe('scripts/veus.json', () => {
  const voices = JSON.parse(readFileSync(config.localTts.derivedVoices, 'utf8')) as Record<string, DerivedVoice>;
  const models = derivedVoiceModels(voices);

  it('té la narradora i la nena, totes dues sobre gina (valenciana)', () => {
    expect(models.map((m) => m.id)).toEqual(expect.arrayContaining(['veu:narradora', 'veu:nena']));
    for (const model of models) expect(model.label).toMatch(/gina · valencià/);
  });

  it('la nena puja to i formants; la narradora conserva la veu de gina', () => {
    const nena = models.find((m) => m.id === 'veu:nena')!;
    const narradora = models.find((m) => m.id === 'veu:narradora')!;
    expect(nena.pitch).toBeGreaterThan(0);
    expect(nena.formant).toBeGreaterThan(1);
    expect(narradora).toMatchObject({ pitch: 0, formant: 1 });
    expect(narradora.speed).toBeGreaterThan(1);
  });
});
