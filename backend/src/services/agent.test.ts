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
  scenario: { character: 'Maria, cambrera', systemPrompt: "Ets Maria, una cambrera propera d'un bar valencià." },
  level: 'B1',
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
      expect(body.response_format.type).toBe('json_schema');
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
      expect(system.content).toContain("Nivell de referència de l'aprenent: B1");
      expect(user.role).toBe('user');
      expect(user.content).toContain('Maria, cambrera: Hola! Què et poses?');
      expect(user.content).toContain('Aprenent: Hola!');
      expect(user.content).toContain('"Hola, em poses una cervesa?"');
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

    it('reintenta 2 veces amb el mateix model quan OpenAI falla (no hi ha model de reserva)', async () => {
      const { replyFromAgent } = await loadAgent();
      fetchMock.mockResolvedValue(openAiResponse('', { ok: false, status: 500 }));

      await expect(replyFromAgent(defaultArgs)).rejects.toThrow('OpenAI API error');

      expect(fetchMock).toHaveBeenCalledTimes(2);
      const models = requestedModels();
      expect(models).toEqual(['gpt-5.6-luna', 'gpt-5.6-luna']);
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

    it('usa el modelo configurat via OPENAI_MODEL', async () => {
      const { replyFromAgent } = await loadAgent({ model: 'gpt-4o-mini' });
      fetchMock.mockResolvedValue(openAiResponse('', { ok: false, status: 500 }));

      await expect(replyFromAgent(defaultArgs)).rejects.toThrow('OpenAI API error');

      const models = requestedModels();
      expect(models).toEqual(['gpt-4o-mini', 'gpt-4o-mini']);
    });
  });

  describe('tutor del tauler (dashboardAgent)', () => {
    it('usa sempre gpt-6-luna amb reasoning_effort low, encara que OPENAI_MODEL siga un altre, i sense models de reserva', async () => {
      const { replyFromAgent } = await loadAgent({ model: 'gpt-4o' });
      fetchMock.mockResolvedValue(openAiResponse('', { ok: false, status: 500 }));

      await expect(replyFromAgent({ ...defaultArgs, dashboardAgent: true })).rejects.toThrow('OpenAI API error');

      expect(requestedModels()).toEqual(['gpt-6-luna', 'gpt-6-luna']);
      const bodies = fetchMock.mock.calls.map(([, init]) => JSON.parse((init as { body: string }).body));
      expect(bodies.every(body => body.reasoning_effort === 'low')).toBe(true);
    });

    it('sense dashboardAgent no envia reasoning_effort (gpt-4o) ni força el model', async () => {
      const { replyFromAgent } = await loadAgent({ model: 'gpt-4o' });
      fetchMock.mockResolvedValue(openAiResponse(jsonReply()));
      await replyFromAgent(defaultArgs);
      const body = JSON.parse((fetchMock.mock.calls[0][1] as { body: string }).body);
      expect(body.model).toBe('gpt-4o');
      expect(body.reasoning_effort).toBeUndefined();
    });
  });

  describe('consulta de la GNV (tutor)', () => {
    const gnvArgs = { ...defaultArgs, message: "Quan porta accent 'què'?", gnvTool: true };
    const ragResult = {
      hay_respaldo: true,
      mejor_puntuacion: 0.97,
      mensaje: '',
      fuentes: [
        { seccion: '5.1.3', ruta: 'Ortografia > 5.1.3. L\'accentuació diacrítica', etiqueta: 'GNV § 5.1.3 · Ortografia > 5.1.3. L\'accentuació diacrítica', puntuacion: 0.97, texto: 'El pronom **què** porta accent.' },
        { seccion: '5.1.1', ruta: 'Ortografia > 5.1.1. Regles generals', etiqueta: 'GNV § 5.1.1 · Ortografia > 5.1.1. Regles generals', puntuacion: 0.6, texto: 'Les agudes porten accent.' },
        { seccion: '9.9', ruta: 'Altres', etiqueta: 'GNV § 9.9 · Altres', puntuacion: 0.2, texto: 'No usada.' },
      ],
    };

    /** Separa les crides a OpenAI de les del RAG pel URL. */
    function route(openAi: string[], rag: unknown = ragResult) {
      const replies = [...openAi];
      fetchMock.mockImplementation(async (url: string) => {
        if (String(url).includes('/consultar')) return { ok: true, status: 200, json: async () => rag };
        return openAiResponse(replies.shift() ?? '');
      });
    }
    const ragCalls = () => fetchMock.mock.calls.filter(([url]) => String(url).includes('/consultar'));

    it('no consulta la GNV si el model deixa consulta_gnv buida', async () => {
      const { replyFromAgent } = await loadAgent();
      route([jsonReply({ consulta_gnv: '' })]);

      const reply = await replyFromAgent(gnvArgs);
      expect(reply.gnv).toBeUndefined();
      expect(reply).not.toHaveProperty('consulta_gnv');
      expect(ragCalls()).toHaveLength(0);
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });

    it('consulta la GNV i retorna la regla amb la cita del RAG i sense Markdown', async () => {
      const { replyFromAgent } = await loadAgent();
      route([
        jsonReply({ consulta_gnv: 'accentuació diacrítica de què i que' }),
        jsonReply({ reply_text: 'Porta accent quan és **pronom**.', gnv: { fonts: [1, 2, 7], contingut: 'Què tònic porta accent.', explicacio: 'Si preguntes, accent.' } }),
      ]);

      const reply = await replyFromAgent(gnvArgs);
      expect(JSON.parse(ragCalls()[0][1].body)).toEqual({ consulta: 'accentuació diacrítica de què i que', k: 4 });
      expect(reply.reply_text).toBe('Porta accent quan és pronom.');
      expect(reply.gnv).toEqual({
        regla: ragResult.fuentes[0].etiqueta,
        seccio: '5.1.3',
        ruta: ragResult.fuentes[0].ruta,
        contingut: 'Què tònic porta accent.',
        explicacio: 'Si preguntes, accent.',
        text_original: 'El pronom què porta accent.',
        // La font 2 completa la regla; la 7 no existix i la 3 no s'ha usat.
        relacionades: [{ regla: 'GNV § 5.1.1 · Ortografia > 5.1.1. Regles generals', seccio: '5.1.1', ruta: 'Ortografia > 5.1.1. Regles generals', text: 'Les agudes porten accent.' }],
      });
      // La segona petició porta les fonts i exigix el camp gnv.
      const second = JSON.parse(fetchMock.mock.calls.at(-1)![1].body);
      expect(second.messages.at(-1).content).toContain('<font id="1" seccio="5.1.3"');
      expect(second.response_format.json_schema.schema.required).toContain('gnv');
    });

    it('sense respaldo en la GNV respon sense regla', async () => {
      const { replyFromAgent } = await loadAgent();
      route([jsonReply({ consulta_gnv: 'paella valenciana' }), jsonReply({ reply_text: 'No ho trobe a la GNV.' })],
        { hay_respaldo: false, mejor_puntuacion: 0.01, mensaje: 'No ho trobe a la Gramàtica Normativa Valenciana.', fuentes: [] });

      const reply = await replyFromAgent(gnvArgs);
      expect(reply.gnv).toBeUndefined();
      const second = JSON.parse(fetchMock.mock.calls.at(-1)![1].body);
      expect(second.response_format.json_schema.schema.required).not.toContain('gnv');
    });

    it('si el RAG falla, el tutor respon igual', async () => {
      const { replyFromAgent } = await loadAgent();
      vi.spyOn(console, 'warn').mockImplementation(() => {});
      const replies = [jsonReply({ consulta_gnv: 'plural de sofà' }), jsonReply({ reply_text: 'Es diu sofàs.' })];
      fetchMock.mockImplementation(async (url: string) => {
        if (String(url).includes('/consultar')) throw new Error('ECONNREFUSED');
        return openAiResponse(replies.shift() ?? '');
      });

      const reply = await replyFromAgent(gnvArgs);
      expect(reply.reply_text).toBe('Es diu sofàs.');
      expect(reply.gnv).toBeUndefined();
    });

    it('sense gnvTool no demana consulta_gnv', async () => {
      const { replyFromAgent } = await loadAgent();
      route([jsonReply()]);

      await replyFromAgent(defaultArgs);
      const body = JSON.parse(fetchMock.mock.calls[0][1].body);
      expect(body.response_format.json_schema.schema.properties).not.toHaveProperty('consulta_gnv');
    });
  });
});
