import OpenAI from 'openai';

/**
 * Converses del Nivell 0: en acabar un escenari (p. ex. «El mag i la poció màgica»), el LLM
 * revisa la conversa i només diu quins objectius de l'escenari ha complit el xiquet. No es
 * busquen errors: a esta edat el que compta és que s'atrevisca a dir-ho en valencià. El
 * resultat es guarda en kids_scenario_reviews per al seguiment de la família i del professorat.
 */

const MAX_MESSAGES = 60;

let client: OpenAI | null = null;
const openai = () => {
  if (!process.env.OPENAI_API_KEY) return null;
  client ??= new OpenAI({ apiKey: process.env.OPENAI_API_KEY, maxRetries: 1, timeout: 30_000 });
  return client;
};

type Message = { role: string; content_text: string; created_at: string };

/** Quins objectius s'han complit (en el mateix ordre), o null si no s'ha pogut revisar. */
export async function checkObjectives(objectives: string[], messages: Pick<Message, 'role' | 'content_text'>[]): Promise<(boolean | null)[]> {
  const unknown = objectives.map(() => null);
  const ai = openai();
  const model = process.env.OPENAI_MODEL;
  if (!ai || !model || !objectives.length) return unknown;

  const transcript = messages
    .slice(-MAX_MESSAGES)
    .map(m => `${m.role === 'user' ? 'Xiquet' : 'Personatge'}: ${m.content_text}`)
    .join('\n');
  const list = objectives.map((o, i) => `${i + 1}. ${o}`).join('\n');

  try {
    const response = await ai.chat.completions.create({
      // Sense temperature ni max_tokens: com en l'agent, el model configurat pot no admetre'ls.
      model,
      messages: [
        {
          role: 'system',
          content:
            'Revises una conversa entre un xiquet o una xiqueta que aprén valencià (Nivell 0, infantil) i un personatge. ' +
            'NO busques errors. Per a cada objectiu, digues només si el xiquet l\'ha complit en la conversa. ' +
            'Sigues generós: compta com a complit si el xiquet ho ha dit en valencià, encara que siga amb errors, amb una sola paraula ' +
            'o triant entre les opcions que li ha donat el personatge. Els exemples entre parèntesis són només exemples: n\'hi ha prou ' +
            'que en diga un o dos, no cal que els diga tots. No compta si només ho ha dit el personatge, si el xiquet ho ha ' +
            'dit només en castellà o en una altra llengua, o si no ha arribat a eixa part de la conversa. ' +
            'Respon NOMÉS amb JSON, sense text abans ni després: {"complits": [true, false, ...]}, un valor per objectiu i en el mateix ordre.',
        },
        { role: 'user', content: `Objectius:\n${list}\n\nConversa:\n${transcript}` },
      ],
    });
    return parseObjectives(response.choices[0]?.message?.content ?? '', objectives.length) ?? unknown;
  } catch (error) {
    console.error('[kids-objectives] No s\'ha pogut revisar la conversa:', error instanceof Error ? error.message : error);
    return unknown;
  }
}

/** Llig {"complits": [...]} de la resposta (tolera text o ```json``` al voltant). */
export function parseObjectives(raw: string, count: number): boolean[] | null {
  const match = raw.match(/\{[\s\S]*\}/);
  if (!match) return null;
  try {
    const list = (JSON.parse(match[0]) as { complits?: unknown }).complits;
    if (!Array.isArray(list) || list.length !== count || !list.every(v => typeof v === 'boolean')) return null;
    return list;
  } catch {
    return null;
  }
}

/**
 * Revisa una conversa acabada d'un xiquet del Nivell 0 i la guarda (o l'actualitza, si es
 * torna a tancar). Sense cap missatge del xiquet no es guarda res.
 */
export async function reviewKidsConversation(client: any, userId: string, sessionResourceId: string, resourceId: string) {
  const [{ data: messages }, { data: resource }] = await Promise.all([
    client.from('conversation_messages').select('role, content_text, created_at')
      .eq('session_resource_id', sessionResourceId).order('created_at', { ascending: true }),
    client.from('resources').select('name, metadata').eq('id', resourceId).maybeSingle(),
  ]);
  const list = (messages ?? []) as Message[];
  const turns = list.filter(m => m.role === 'user').length;
  if (!turns || !resource) return;

  const objectives = (Array.isArray(resource.metadata?.objectius) ? resource.metadata.objectius : [])
    .filter((o: unknown): o is string => typeof o === 'string');
  const met = await checkObjectives(objectives, list);
  const seconds = Math.max(0, Math.round((Date.parse(list[list.length - 1].created_at) - Date.parse(list[0].created_at)) / 1000));

  const { error } = await client.from('kids_scenario_reviews').upsert({
    session_resource_id: sessionResourceId,
    user_id: userId,
    resource_id: resourceId,
    scenario_name: resource.metadata?.section_name ?? resource.name,
    objectives: objectives.map((text: string, i: number) => ({ text, met: met[i] })),
    turns: Math.min(turns, 32_000),
    seconds,
  });
  if (error) throw new Error(error.message);
  console.log(`[kids-objectives] ${sessionResourceId}: ${met.filter(Boolean).length}/${objectives.length} objectius, ${turns} torns`);
}
