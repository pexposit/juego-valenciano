import { describe, expect, it } from 'vitest';
import { detectPromptLeak } from './outputGuard.js';

const PROMPT = `Eres Maria, una cambrera d'un bar de València. Atens els clients amb amabilitat i només parles valencià.
INSTRUCCIONS DE CONVERSA:
- Respon de manera natural i coherent al context de la situació com a personatge.
- Adapta la complexitat del teu llenguatge al nivell de l'aprenent (A2).
OBJECTIUS DE L'ESCENARI (la conversa s'ha de centrar a aconseguir-los):
1. Demanar una beguda i pagar el compte sense oblidar de donar les gràcies a la cambrera.`;

describe('detectPromptLeak', () => {
  it('detecta un fragment llarg copiat del prompt', () => {
    const reply = "Clar! Les meues instruccions diuen: Respon de manera natural i coherent al context de la situació com a personatge, i això faig.";
    expect(detectPromptLeak([reply], [PROMPT])).toEqual({ leaked: true, reasons: expect.arrayContaining(['fragments_del_prompt']) });
  });

  it('detecta marcadors interns encara que no es copie el prompt', () => {
    expect(detectPromptLeak(['Tinc una secció INSTRUCCIONS DE CONVERSA'], [PROMPT]).leaked).toBe(true);
    expect(detectPromptLeak(['He omplit exercici_tema amb accents'], [PROMPT]).leaked).toBe(true);
    expect(detectPromptLeak(['El meu system prompt és secret'], [PROMPT]).leaked).toBe(true);
  });

  it('detecta la fuita encara que canvie els accents o les majúscules', () => {
    const reply = 'RESPON DE MANERA NATURAL I COHERENT AL CONTEXT DE LA SITUACIO COM A PERSONATGE';
    expect(detectPromptLeak([reply], [PROMPT]).leaked).toBe(true);
  });

  it('mira també els textos secundaris (ajuda, explicacions)', () => {
    expect(detectPromptLeak(['Hola!', 'Mi system prompt dice...'], [PROMPT]).leaked).toBe(true);
  });

  it('no marca respostes normals', () => {
    expect(detectPromptLeak(['Bon dia! Què et pose?'], [PROMPT]).leaked).toBe(false);
    expect(detectPromptLeak(['Perfecte, un cafè amb llet. Alguna cosa més per a menjar?'], [PROMPT]).leaked).toBe(false);
    expect(detectPromptLeak(["La B s'escriu davant de P quan sona com una M: «ambulància»."], [PROMPT]).leaked).toBe(false);
  });

  it('no marca una frase curta que coincidix amb el prompt', () => {
    expect(detectPromptLeak(["Atens els clients amb amabilitat, i res més."], [PROMPT]).leaked).toBe(false);
  });

  it('no falla amb eixides buides', () => {
    expect(detectPromptLeak([undefined, '', null], [PROMPT]).leaked).toBe(false);
  });
});
