import { z } from 'zod';
import { scenarios } from '../scenarios/index.js';
import type { ScenarioKey } from '../scenarios/types.js';



const outputSchema = z.object({
  reply_text: z.string().min(1),
  mood: z.enum(['neutral', 'content', 'confus']),
});

export type AgentReply = z.infer<typeof outputSchema>;

// Cadena de models: el principal (OPENAI_MODEL) i dos de reserva per si falla.
// El nom ha d'existir a OpenAI: un valor inventat gasta dos intents (404) en
// cada torn abans de passar al model de reserva.
const OPENAI_MODELS = [
  process.env.OPENAI_MODEL || 'gpt-4o-mini',
  'gpt-4o-mini',
  'gpt-4o',
].filter((model, index, models) => models.indexOf(model) === index);

// Límite por petición: si un modelo cuelga, se corta y se prueba el siguiente
// en lugar de esperar indefinidamente. Ajustable con OPENAI_TIMEOUT_MS.
const OPENAI_TIMEOUT_MS = Number(process.env.OPENAI_TIMEOUT_MS) || 30_000;

export async function replyFromAgent(args: {
  scenario: ScenarioKey;
  level: string;
  message: string;
  history: { role: string; content_text: string }[];
}): Promise<AgentReply> {
  const key = process.env.OPENAI_API_KEY;
  if (!key) throw new Error('OPENAI_API_KEY no està configurada');

  const def = scenarios[args.scenario];
  const context = args.history
    .map((m) => `${m.role === 'character' ? def.character : 'Aprenent'}: ${m.content_text}`)
    .join('\n');

  let lastError = 'OpenAI no ha retornat una resposta vàlida';
  for (const model of OPENAI_MODELS) {
    for (let attempt = 0; attempt < 2; attempt += 1) {
      try {
        const response = await fetch('https://api.openai.com/v1/chat/completions', {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${key}`,
            'Content-Type': 'application/json',
          },
          signal: AbortSignal.timeout(OPENAI_TIMEOUT_MS),
          body: JSON.stringify({
            model,
            temperature:0.1,
            max_completion_tokens: 450,
            response_format: {
            type: 'json_schema',
            json_schema: {
              name: 'agent_reply',
              strict: true,
              schema: {
                type: 'object',
                properties: {
                  mood: {
                    type: 'string',
                    enum: ['neutral', 'content', 'confus'],
                    description: "L'estat d'ànim del personatge.",
                  },
                  reply_text: {
                    type: 'string',
                    description: 'La resposta directa del personatge a la conversa.',
                  },
                },
                required: ['mood', 'reply_text'],
                additionalProperties: false,
              },
            },
          },
            messages: [
                        {
                          role: 'system',
                          content: `${def.systemPrompt}
                            Nivell de referència de l'aprenent: ${args.level}.

                            INSTRUCCIONS DE CONVERSA:
                            - Respon de manera natural i coherent al context de la situació com a personatge.
                            - Adapta la complexitat del teu llenguatge al nivell de l'aprenent (${args.level}).
                            - Tria l'estat d'ànim ('mood') que millor represente la teua reacció com a personatge ('neutral', 'content', 'confus').

                            Respon ÚNICAMENT amb JSON vàlid amb les claus: reply_text, mood.`.trim(),
                        },

                        {
                          role: 'user',
                          content: `Context recent de la conversa:\n${context || '(inici)'}\n\nÚltim missatge de l'aprenent a analitzar i respondre:\n"${args.message}"`,
                        },
                       
                      ]
          }),
        });

        if (!response.ok) {
          lastError = `OpenAI API error (${model}): ${response.status}`;
          continue;
        }
        const payload = (await response.json()) as { choices?: { message?: { content?: string } }[] };
        const content = payload.choices?.[0]?.message?.content;
        if (!content) {
          lastError = `OpenAI (${model}) no ha retornat contingut`;
          continue;
        }
        console.log(`[agent] resposta vàlida de ${model}`);

        const parsed = outputSchema.parse(parseJsonResponse(content));
        return parsed;
      } catch (error) {
        //console.error('[agent DEBUG ERROR]:', error); // <--- AÑADE ESTO
        lastError = error instanceof Error ? error.message : lastError;
      }
    }
  }
  throw new Error(lastError);
}

function parseJsonResponse(content: string): unknown {
  const normalized = content.trim().replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/, '');
  const value = JSON.parse(normalized) as Record<string, unknown>;

  // 1. Garantizar que error_flags sea siempre un array
  if (typeof value.error_flags === 'string') {
    value.error_flags = value.error_flags.trim() ? [value.error_flags] : [];
  } else if (!Array.isArray(value.error_flags)) {
    value.error_flags = [];
  }

  // 2. Normalización de mood
  if (typeof value.mood === 'string') {
    const mood = value.mood.toLowerCase();
    value.mood = {
      friendly: 'content',
      happy: 'content',
      amable: 'content',
      alegre: 'content',
      helpful: 'content',
      confused: 'confus',
      confós: 'confus',
    }[mood] || mood;
  }

  // 3. Normalización de detected_level_signal
  if (typeof value.detected_level_signal === 'string') {
    const levelSignal = value.detected_level_signal.toLowerCase();
    value.detected_level_signal = {
      beginner: 'below',
      principiant: 'below',
      intermediate: 'on',
      intermedi: 'on',
      'al nivell': 'on',
      'at level': 'on',
      advanced: 'above',
      avancat: 'above',
      'per damunt': 'above',
      'por encima': 'above',
      'per davall': 'below',
      'por debajo': 'below',
      neutral: 'on',
      correcte: 'on',
      correct: 'on',
      'al seu nivell': 'on',
    }[levelSignal] || (['below', 'on', 'above'].includes(levelSignal) ? levelSignal : 'on');
  }

  return value;
}
