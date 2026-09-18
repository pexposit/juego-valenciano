/**
 * Pruebas del protocolo del sidecar de Vosk (src/streaming/voskProtocol.ts).
 *
 * El sidecar es un proceso de Python: estos tests fijan el contrato sin
 * arrancarlo, que es justo lo que hay que blindar para poder cambiar de motor
 * (UJI por trozos, servicio en la nube…) sin que el servidor note la diferencia.
 */
import { describe, expect, it } from 'vitest';
import {
  buildConfigMessage,
  buildEofMessage,
  parseSidecarMessage,
} from './voskProtocol.js';

describe('buildConfigMessage', () => {
  it('envuelve la configuración bajo la clave "config" como vosk-server', () => {
    expect(JSON.parse(buildConfigMessage({ sample_rate: 16000 }))).toEqual({
      config: { sample_rate: 16000 },
    });
  });

  it('incluye la gramática restringida cuando se pide', () => {
    const payload = JSON.parse(buildConfigMessage({
      sample_rate: 16000,
      phrase_list: ['bon dia', 'quant costa'],
      words: false,
    }));
    expect(payload.config.phrase_list).toEqual(['bon dia', 'quant costa']);
    expect(payload.config.words).toBe(false);
  });

  it('no envía claves indefinidas', () => {
    const payload = JSON.parse(buildConfigMessage({ sample_rate: 16000, phrase_list: undefined }));
    expect(Object.keys(payload.config)).toEqual(['sample_rate']);
  });
});

describe('buildEofMessage', () => {
  it('pide el resultado final con {"eof": 1}', () => {
    expect(JSON.parse(buildEofMessage())).toEqual({ eof: 1 });
  });
});

describe('parseSidecarMessage', () => {
  it('reconoce un resultado parcial', () => {
    expect(parseSidecarMessage('{"partial": "bon dia com"}')).toEqual({
      kind: 'partial',
      text: 'bon dia com',
    });
  });

  it('reconoce un resultado final (endpointing detectado)', () => {
    expect(parseSidecarMessage('{"text": "bon dia com et puc ajudar hui"}')).toEqual({
      kind: 'final',
      text: 'bon dia com et puc ajudar hui',
    });
  });

  it('recorta los espacios sobrantes', () => {
    expect(parseSidecarMessage('{"partial": "  bon dia  "}')).toEqual({
      kind: 'partial',
      text: 'bon dia',
      computeMs: undefined,
    });
  });

  it('lee el tiempo de cómputo que informa el motor', () => {
    expect(parseSidecarMessage('{"partial": "bon", "compute_ms": 12.5}')).toEqual({
      kind: 'partial',
      text: 'bon',
      computeMs: 12.5,
    });
  });

  it('ignora un compute_ms con forma inválida', () => {
    expect(parseSidecarMessage('{"text": "bon dia", "compute_ms": "molt"}')).toEqual({
      kind: 'final',
      text: 'bon dia',
      computeMs: undefined,
    });
  });

  it('propaga los errores del sidecar', () => {
    expect(parseSidecarMessage('{"error": "no trobe el model"}')).toEqual({
      kind: 'error',
      message: 'no trobe el model',
    });
  });

  it('devuelve el final vacío del silencio sin romperse', () => {
    expect(parseSidecarMessage('{"text": ""}')).toEqual({ kind: 'final', text: '' });
  });

  it('falla con un JSON inválido', () => {
    expect(() => parseSidecarMessage('no és json')).toThrow(/JSON no vàlid/);
  });

  it('falla con un mensaje que no es un objeto', () => {
    expect(() => parseSidecarMessage('"hola"')).toThrow(/missatge buit/);
  });

  it('falla con un objeto desconocido', () => {
    expect(() => parseSidecarMessage('{"spk": [1, 2]}')).toThrow(/Missatge desconegut/);
  });
});
