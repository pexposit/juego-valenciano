/**
 * Pruebas unitarias del agente conversacional (backend/src/services/agent.ts).
 *
 * Cubren el «resultado» y el «estado» de lo que devuelve el LLM de OpenAI:
 * - Respuesta 200 con JSON válido -> AgentReply con campos normalizados.
 * - Normalización de `mood` y `detected_level_signal` (sinónimos, mayúsculas).
 * - Estados HTTP de error (4xx/5xx): reintentos por petición y modelo de respaldo.
 * - Cuerpo de la petición enviada a chat/completions (URL, método, auth, model, prompts).
 * - Fallos de contenido (vacío, JSON inválido) y fallos de esquema Zod.
 * - Ausencia de OPENAI_API_KEY.
 *
 * La API de OpenAI se simula con un `fetch` global mockeado; no se hace ninguna
 * llamada real de red.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import type { ScenarioKey } from '../scenarios/types.js';

/**
 * Devuelve el módulo agent reimportado con estado determinista:
 * resetea la caché de módulos y garantiza que OPENAI_MODELS sea
 * ['gpt-5.6-luna', 'gpt-4o-mini', 'gpt-4o'] (sin OPENAI_MODEL definido), sea cual
 * sea el entorno donde se ejecuten los tests.
 */
async function loadAgent(options: { model?: string } = {}) {
  vi.resetModules();
  delete process.env.OPENAI_MODEL;
  process.env.OPENAI_MODEL = options.model || 'gpt-5.6-luna';
  return import('./agent.js');
}

/** Crea una respuesta HTTP con forma de la API de chat/completions. */
function openAiResponse(content: string, options: { ok?: boolean; status?: number } = {}) {
  const { ok = true, status = 200 } = options;
  return {
    ok,
    status,
    json: async () => ({
      choices: [{ message: { content } }],
      ...(!ok ? { error: { message: `code_${status}` } } : {}),
    }),
  };
}

/** Construye un JSON de respuesta del LLM con valores por defecto válidos. */
function jsonReply(partial: Record<string, unknown> = {}) {
  return JSON.stringify({
    reply_text: 'Hola, com et puc ajudar?',
    mood: 'content',
    detected_level_signal: 'on',
    error_flags: [],
    ...partial,
  });
}

const defaultArgs = {
  scenario: 'bar' as ScenarioKey,
  level: 'intermedi',
  message: 'Hola, em poses una cervesa?',
  history: [] as { role: string; content_text: string }[],
};

let fetchMock: ReturnType<typeof vi.fn>;

/** Extrae el campo `model` del body JSON de cada llamada a fetch. */
function requestedModels() {
  return fetchMock.mock.calls.map(([, init]) => JSON.parse((init as { body: string }).body).model);
}

beforeEach(() => {
  process.env.OPENAI_API_KEY = 'test-key';
  fetchMock = vi.fn();
  vi.stubGlobal('fetch', fetchMock);
  // Silencia el console.log interno del agente para una salida de test limpia.
  vi.spyOn(console, 'log').mockImplementation(() => {});
});

afterEach(() => {
  vi.unstubAllGlobals();
  vi.restoreAllMocks();
  delete process.env.OPENAI_API_KEY;
  delete process.env.OPENAI_MODEL;
});

describe('replyFromAgent', () => {
  describe('resultado con respuesta HTTP 200 (éxito)', () => {
    it('devuelve el AgentReply completo y validado cuando el LLM responde JSON válido', async () => {
      const { replyFromAgent } = await loadAgent();
      fetchMock.mockResolvedValue(openAiResponse(jsonReply()));

      await expect(replyFromAgent(defaultArgs)).resolves.toEqual({
        reply_text: 'Hola, com et puc ajudar?',
        mood: 'content',
        detected_level_signal: 'on',
        error_flags: [],
      });
    });

    it('acepta una respuesta envuelta en bloques de código markdown ```json', async () => {
      const { replyFromAgent } = await loadAgent();
      const wrapped = `\`\`\`json\n${jsonReply({ reply_text: 'Encantat!' })}\n\`\`\``;
      fetchMock.mockResolvedValue(openAiResponse(wrapped));

      const reply = await replyFromAgent(defaultArgs);
      expect(reply.reply_text).toBe('Encantat!');
    });

    it.each([
      ['friendly', 'content'],
      ['happy', 'content'],
      ['amable', 'content'],
      ['alegre', 'content'],
      ['helpful', 'content'],
      ['confused', 'confus'],
      ['confós', 'confus'],
    ])('normaliza el mood sinónimo "%s" a "%s"', async (rawMood, expected) => {
      const { replyFromAgent } = await loadAgent();
      fetchMock.mockResolvedValue(openAiResponse(jsonReply({ mood: rawMood })));

      const reply = await replyFromAgent(defaultArgs);
      expect(reply.mood).toBe(expected);
    });

    it.each([
      ['CONTENT', 'content'],
      ['NEUTRAL', 'neutral'],
      ['CONFUS', 'confus'],
    ])('normaliza el mood en mayúsculas "%s" a "%s"', async (rawMood, expected) => {
      const { replyFromAgent } = await loadAgent();
      fetchMock.mockResolvedValue(openAiResponse(jsonReply({ mood: rawMood })));

      const reply = await replyFromAgent(defaultArgs);
      expect(reply.mood).toBe(expected);
    });

    it.each([
      ['beginner', 'below'],
      ['principiant', 'below'],
      ['per davall', 'below'],
      ['por debajo', 'below'],
      ['intermediate', 'on'],
      ['intermedi', 'on'],
      ['al nivell', 'on'],
      ['at level', 'on'],
      ['neutral', 'on'],
      ['correcte', 'on'],
      ['correct', 'on'],
      ['advanced', 'above'],
      ['avancat', 'above'],
      ['per damunt', 'above'],
      ['por encima', 'above'],
      ['completament-desconegut', 'on'],
    ])('normaliza detected_level_signal "%s" a "%s"', async (rawSignal, expected) => {
      const { replyFromAgent } = await loadAgent();
      fetchMock.mockResolvedValue(openAiResponse(jsonReply({ detected_level_signal: rawSignal })));

      const reply = await replyFromAgent(defaultArgs);
      expect(reply.detected_level_signal).toBe(expected);
    });

    it('propaga los error_flags que devuelve el LLM', async () => {
      const { replyFromAgent } = await loadAgent();
      fetchMock.mockResolvedValue(openAiResponse(jsonReply({ error_flags: ['paraules-en-castella'] })));

      const reply = await replyFromAgent(defaultArgs);
      expect(reply.error_flags).toEqual(['paraules-en-castella']);
    });
});
describe('estado de la petición enviada a OpenAI', () => {
    it('llama a POST https://api.openai.com/v1/chat/completions con la API key y el modelo por defecto', async () => {
      const { replyFromAgent } = await loadAgent();
      fetchMock.mockResolvedValue(openAiResponse(jsonReply()));

      await replyFromAgent(defaultArgs);

      expect(fetchMock).toHaveBeenCalledTimes(1);
      const [url, init] = fetchMock.mock.calls[0];
      expect(url).toBe('https://api.openai.com/v1/chat/completions');
      expect((init as { method: string }).method).toBe('POST');
      expect((init as { headers: Record<string, string> }).headers.Authorization).toBe('Bearer test-key');
      expect((init as { headers: Record<string, string> }).headers['Content-Type']).toBe('application/json');

      const body = JSON.parse((init as { body: string }).body);
      expect(body.model).toBe('gpt-5.6-luna');
      expect(body.max_completion_tokens).toBe(450);
      expect(body.response_format).toEqual({ type: 'json_object' });
    });

    it('incluye el prompt de sistema, nivel actual, contexto e historial en los mensajes', async () => {
      const { replyFromAgent } = await loadAgent();
      const history = [
        { role: 'character' as const, content_text: 'Hola! Què et poses?' },
        { role: 'user' as const, content_text: 'Hola!' },
      ];
      fetchMock.mockResolvedValue(openAiResponse(jsonReply()));

      await replyFromAgent({ ...defaultArgs, history });

      const [, init] = fetchMock.mock.calls[0];
      const body = JSON.parse((init as { body: string }).body);
      const [system, user] = body.messages;

      expect(system.role).toBe('system');
      expect(system.content).toContain('Nivell actual: intermedi');
      expect(user.role).toBe('user');
      expect(user.content).toContain('Pau, cambrer: Hola! Què et poses?');
      expect(user.content).toContain('Aprenent: Hola!');
      expect(user.content).toContain('Aprenent: Hola, em poses una cervesa?');
    });
  });

  describe('estados HTTP de error y reintentos', () => {
    it.each([400, 401, 403, 404, 429, 500, 502, 503])(
      'lanza un error que refleja el estado HTTP %i de OpenAI',
      async (status) => {
        const { replyFromAgent } = await loadAgent();
        fetchMock.mockResolvedValue(openAiResponse('', { ok: false, status }));
        await expect(replyFromAgent(defaultArgs)).rejects.toThrow('OpenAI API error');
        await expect(replyFromAgent(defaultArgs)).rejects.toThrow(String(status));
      },
    );

    it('reintenta 2 veces con cada modelo de respaldo cuando OpenAI falla (6 llamadas: 3 modelos x 2 intentos)', async () => {
      const { replyFromAgent } = await loadAgent();
      fetchMock.mockResolvedValue(openAiResponse('', { ok: false, status: 500 }));

      await expect(replyFromAgent(defaultArgs)).rejects.toThrow('OpenAI API error');

      expect(fetchMock).toHaveBeenCalledTimes(6);
      const models = requestedModels();
      expect(models).toEqual(['gpt-5.6-luna', 'gpt-5.6-luna', 'gpt-4o-mini', 'gpt-4o-mini', 'gpt-4o', 'gpt-4o']);
    });

    it('cae al modelo de respaldo cuando el primero devuelve 500 y el segundo responde 200', async () => {
      const { replyFromAgent } = await loadAgent();
      fetchMock
        // model 'gpt-5.6-luna': dos intentos fallidos
        .mockResolvedValueOnce(openAiResponse('', { ok: false, status: 500 }))
        .mockResolvedValueOnce(openAiResponse('', { ok: false, status: 500 }))
        // modelo 'gpt-4o-mini': éxito
        .mockResolvedValue(openAiResponse(jsonReply({ reply_text: 'Hola des del model de reserva' })));

      const reply = await replyFromAgent(defaultArgs);

      expect(reply.reply_text).toBe('Hola des del model de reserva');
      const models = requestedModels();
      expect(models.slice(0, 3)).toEqual(['gpt-5.6-luna', 'gpt-5.6-luna', 'gpt-4o-mini']);
    });

    it('recupera tras una respuesta 200 con contenido vacío en el segundo intento', async () => {
      const { replyFromAgent } = await loadAgent();
      fetchMock
        .mockResolvedValueOnce(openAiResponse(''))
        .mockResolvedValue(openAiResponse(jsonReply({ reply_text: 'Recuperat!' })));

      const reply = await replyFromAgent(defaultArgs);
      expect(reply.reply_text).toBe('Recuperat!');
    });
  });
  describe('respuestas inválidas del LLM', () => {
    it('lanza error cuando el contenido del mensaje está vacío y fallan todos los reintentos', async () => {
      const { replyFromAgent } = await loadAgent();
      fetchMock.mockResolvedValue(openAiResponse(''));

      await expect(replyFromAgent(defaultArgs)).rejects.toThrow(/no ha retornat contingut/i);
    });

    it('lanza error cuando el contenido no es JSON válido', async () => {
      const { replyFromAgent } = await loadAgent();
      fetchMock.mockResolvedValue(openAiResponse('això no és JSON, és text pla'));

      await expect(replyFromAgent(defaultArgs)).rejects.toThrow(/JSON/i);
    });

    it('lanza error de esquema cuando reply_text está vacío', async () => {
      const { replyFromAgent } = await loadAgent();
      fetchMock.mockResolvedValue(openAiResponse(jsonReply({ reply_text: '' })));

      const error = await replyFromAgent(defaultArgs).catch((e: unknown) => e);
      expect(error).toBeInstanceOf(Error);
      expect((error as Error).message).toMatch(/reply_text/);
    });

    it('lanza error de esquema cuando error_flags supera el máximo de 4 elementos', async () => {
      const { replyFromAgent } = await loadAgent();
      fetchMock.mockResolvedValue(
        openAiResponse(jsonReply({ error_flags: ['a', 'b', 'c', 'd', 'e'] })),
      );

      const error = await replyFromAgent(defaultArgs).catch((e: unknown) => e);
      expect(error).toBeInstanceOf(Error);
      expect((error as Error).message).toMatch(/error_flags/);
    });

    it('lanza error de esquema cuando el mood no es uno de los valores permitidos', async () => {
      const { replyFromAgent } = await loadAgent();
      fetchMock.mockResolvedValue(openAiResponse(jsonReply({ mood: 'trist' })));

      const error = await replyFromAgent(defaultArgs).catch((e: unknown) => e);
      expect(error).toBeInstanceOf(Error);
      expect((error as Error).message).toMatch(/mood/);
    });
  });

  describe('configuración', () => {
    it('lanza un error claro si falta OPENAI_API_KEY y no llama a la API', async () => {
      const { replyFromAgent } = await loadAgent();
      delete process.env.OPENAI_API_KEY;

      await expect(replyFromAgent(defaultArgs)).rejects.toThrow('OPENAI_API_KEY no està configurada');
      expect(fetchMock).not.toHaveBeenCalled();
    });

    it('usa el modelo configurado vía OPENAI_MODEL sin duplicados con los de respaldo', async () => {
      const { replyFromAgent } = await loadAgent({ model: 'gpt-4o-mini' });
      fetchMock.mockResolvedValue(openAiResponse('', { ok: false, status: 500 }));

      await expect(replyFromAgent(defaultArgs)).rejects.toThrow('OpenAI API error');

      const models = requestedModels();
      expect(new Set(models).size).toBe(2); // gpt-4o-mini + gpt-4o (sin duplicados)
      expect(models).toEqual(['gpt-4o-mini', 'gpt-4o-mini', 'gpt-4o', 'gpt-4o']);
    });
  });
});