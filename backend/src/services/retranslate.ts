import OpenAI from 'openai';
import { guardedFetch } from './openaiGuard.js';
import { motherTongueLabel } from '@parlaval/shared';

/**
 * Tornar a traduir les frases del professor (el xat del tauler) a una altra llengua materna: quan el
 * perfil canvia de llengua, les traduccions que ja estan en la conversa continuen en l'anterior.
 * Torna les traduccions en el mateix ordre, o null si no hi ha clau o el LLM falla (el client deixa
 * la conversa com estava). No es guarda res: el text el guarda el client.
 */

let client: OpenAI | null = null;
const openai = () => {
  if (!process.env.OPENAI_API_KEY) return null;
  client ??= new OpenAI({ apiKey: process.env.OPENAI_API_KEY, fetch: guardedFetch, maxRetries: 1, timeout: 40_000 });
  return client;
};

export async function retranslateLines(lines: string[], tongue: string): Promise<string[] | null> {
  const ai = openai();
  const model = process.env.OPENAI_MODEL;
  if (!ai || !model || lines.length === 0) return null;
  const language = motherTongueLabel(tongue);

  try {
    const response = await ai.chat.completions.create({
      // Sense temperature ni max_tokens: com en l'agent, el model configurat pot no admetre'ls.
      model,
      response_format: { type: 'json_object' },
      messages: [
        {
          role: 'system',
          content:
            `Tradueixes frases curtes d'un professor de valencià per a xiquets a ${language}. ` +
            `Rebràs un JSON amb la clau «frases» (una llista de frases en valencià). ` +
            `Respon NOMÉS amb un JSON {"traduccions": [...]} amb exactament una traducció per frase, ` +
            `en el mateix ordre, en frases curtes i naturals en ${language}. No afigues res més.`,
        },
        { role: 'user', content: JSON.stringify({ frases: lines }) },
      ],
    });
    const parsed = JSON.parse(response.choices[0]?.message?.content ?? '{}') as { traduccions?: unknown };
    const out = parsed.traduccions;
    if (!Array.isArray(out) || out.length !== lines.length || out.some(t => typeof t !== 'string')) return null;
    return (out as string[]).map(t => t.trim());
  } catch (error) {
    console.error("[assistant] No s'han pogut tornar a traduir les frases:", error instanceof Error ? error.message : error);
    return null;
  }
}
