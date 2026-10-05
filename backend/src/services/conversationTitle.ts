import OpenAI from 'openai';

/**
 * Títol curt per a una conversa amb el tutor (pestanya «Converses»): el LLM resumix de
 * què s'ha parlat en unes poques paraules, en valencià. Si no hi ha clau o falla, torna
 * null i la llista mostra el primer missatge com fins ara.
 */

const MAX_MESSAGES = 16; // amb el principi de la conversa n'hi ha prou per a saber de què va
const MAX_CHARS = 60;

let client: OpenAI | null = null;
const openai = () => {
  if (!process.env.OPENAI_API_KEY) return null;
  client ??= new OpenAI({ apiKey: process.env.OPENAI_API_KEY, maxRetries: 1, timeout: 20_000 });
  return client;
};

export async function summarizeConversationTitle(messages: { role: string; content_text: string }[]): Promise<string | null> {
  const ai = openai();
  const model = process.env.OPENAI_MODEL;
  if (!ai || !model || !messages.some(m => m.role === 'user')) return null;

  const transcript = messages
    .slice(0, MAX_MESSAGES)
    .map(m => `${m.role === 'user' ? 'Xiquet' : 'Professor'}: ${m.content_text}`)
    .join('\n');

  try {
    const response = await ai.chat.completions.create({
      // Sense temperature ni max_tokens: com en l'agent, el model configurat pot no admetre'ls.
      model,
      messages: [
        {
          role: 'system',
          content:
            "Dones títol a converses entre un xiquet que aprén valencià i el seu professor. " +
            'Respon NOMÉS amb el títol: en valencià, de 2 a 6 paraules, que diga de què han parlat ' +
            '(p. ex. «Els animals de la granja», «Com es diuen els colors»). ' +
            'Sense cometes, sense punt final i sense emojis. No copies la primera frase del xiquet.',
        },
        { role: 'user', content: transcript },
      ],
    });
    return cleanTitle(response.choices[0]?.message?.content ?? '');
  } catch (error) {
    console.error('[assistant] No s\'ha pogut resumir el títol de la conversa:', error instanceof Error ? error.message : error);
    return null;
  }
}

/** Neteja el títol (del LLM o de l'usuari): una línia, sense cometes ni punt final, i curt. */
export function cleanTitle(raw: string): string | null {
  const title = raw
    .split('\n')[0]
    .replace(/^["'«“\s]+|["'»”\s]+$/g, '')
    .replace(/[.。]+$/, '')
    .replace(/\s+/g, ' ')
    .trim();
  if (!title) return null;
  return title.length > MAX_CHARS ? `${title.slice(0, MAX_CHARS - 1).trimEnd()}…` : title;
}
