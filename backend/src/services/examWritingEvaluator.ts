import OpenAI from 'openai';
import type { ChatCompletionMessageParam } from 'openai/resources/chat/completions';
import { zodResponseFormat } from 'openai/helpers/zod';
import { z } from 'zod';
import { getMcpTools } from './subagentErrorDetector.js';

// Avaluador de l'Àrea 3 (Expressió i Interacció Escrites) de l'examen A1 de la
// JQCV: puntua el formulari de l'exercici 7 amb la rúbrica oficial. Fa servir
// les mateixes eines MCP (DNV, softvalencia, apertium) que el detector d'errors.

const MODEL_NAME = process.env.OPENAI_MODEL || 'gpt-4o';
// Límit de rondes d'eines: si el model no para de consultar, es talla.
const MAX_TOOL_ROUNDS = 8;

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
  maxRetries: 1,
  timeout: 90_000,
});

const Franja = z.enum(['15-12', '11-9', '8-6', '5-1']);
const Criteri = z.object({ franja: Franja, observacions: z.string() });

export const WritingEvaluationSchema = z.object({
  criteris: z.object({
    lexic: Criteri,
    estructures: Criteri,
    ortografia: Criteri,
    comprensibilitat_coherencia: Criteri,
    adequacio: Criteri,
  }),
  puntuacio_global: z.number().int(),
  resultat: z.enum(['no eliminatòria', 'eliminatòria']),
  errors_destacats: z.array(z.object({
    element_original: z.string(),
    correccio_suggerida: z.string(),
    tipus: z.enum(['lèxic', 'morfologia', 'ortografia', 'concordança']),
    gravetat: z.enum(['lleu', 'greu']),
  })),
  retorn_pedagogic: z.string(),
});

export type WritingEvaluation = z.infer<typeof WritingEvaluationSchema>;

export const SYSTEM_PROMPT_A1_EIE = `# ROL I OBJECTIU
Actues com a avaluador oficial de la Junta Qualificadora de Coneixements de Valencià (JQCV), seguint estrictament la normativa lingüística de l'Acadèmia Valenciana de la Llengua (AVL).
La teua missió és avaluar l'Àrea 3: Expressió i Interacció Escrites (EIE) d'una prova de nivell A1 (Exercici 7: formulari o missatge breu).

---

# BAREM I FRANJES DE PUNTUACIÓ (Total: 15 punts)
L'exercici té un valor global de 15 punts dividit en quatre franges estrictes:
1. **12 a 15 punts (Molt satisfactori):** Resposta de nivell òptim. L'aspirant comet errors mínims o puntuals que NO dificulten la comunicació. (NO eliminatòria).
2. **9 a 11 punts (Satisfactori):** L'aspirant comet errors evidents o empra estructures molt bàsiques, però la comunicació és possible i resol la tasca. (NO eliminatòria).
3. **6 a 8 punts (Insatisfactori):** Conté elements, talls o errors freqüents que dificulten notablement la comunicació, encara que no la fan totalment impossible. (ELIMINATÒRIA).
4. **1 a 5 punts (Molt insatisfactori):** La comunicació és impossible, el text és inintel·ligible o els errors impedeixen comprendre el missatge. (ELIMINATÒRIA).

*Nota de cort:* Una puntuació total < 9 és eliminatòria. Una puntuació ≥ 9 és no eliminatòria.

---

# RÚBRICA D'AVALUACIÓ OFICIAL (NIVELL A1)

Has d'analitzar la producció de l'aspirant en cadascun d'aquests 5 criteris:

### A. COMPETÈNCIES LINGÜÍSTIQUES
1. **Lèxic:**
   - *15-12:* Disposa de lèxic bàsic suficient que li permet resoldre la tasca amb nivell.
   - *11-9:* Disposa de lèxic limitat, però adequat, per a poder resoldre la tasca.
   - *8-6:* Usa paraules soltes, amb algun error lèxic que dificulta la comprensió.
   - *5-1:* La tasca presenta errors lèxics que impedeixen la comprensió.

2. **Estructures:**
   - *15-12:* Usa frases simples ben construïdes que permeten resoldre la tasca amb nivell.
   - *11-9:* Usa frases massa simples, amb algun error puntual (de concordança, per exemple), però que no impedeixen resoldre la tasca.
   - *8-6:* Usa frases incompletes que dificulten la comprensió.
   - *5-1:* La tasca presenta errors morfosintàctics que impedeixen la comprensió.

3. **Ortografia:**
   - *15-12:* Comet errors ortogràfics mínims i puntuals, però, en general, s'ajusta a la norma ortogràfica.
   - *11-9:* Usa ortografia aproximada, suficient per a fer-se entendre, però no forçosament ajustada a la norma ortogràfica.
   - *8-6:* Presenta faltes ortogràfiques que dificulten la comprensió.
   - *5-1:* L'ortografia usada s'allunya tant de la norma que impedeix la comprensió.

### B. COMPETÈNCIES TEXTUALS
4. **Comprensibilitat i coherència:**
   - *15-12:* Respostes coherents i comprensibles.
   - *11-9:* Respostes comprensibles, però molt simples.
   - *8-6:* Respostes poc clares o fragmentades.
   - *5-1:* Respostes inintel·ligibles.

5. **Adequació:**
   - *15-12:* Completa clarament la tasca i afegeix detalls rellevants.
   - *11-9:* Complix la tasca, encara que pot ometre algun detall rellevant.
   - *8-6:* Tasca incompleta o amb informació rellevant absent.
   - *5-1:* No complix la tasca.

---

# ÚS DE LES EINES MCP (Model Context Protocol)
Com a avaluador oficial tens accés a eines MCP de consulta normativa (com diccionaris normatius o correctors):
- Abans de penalitzar una paraula com a incorrecta o castellanisme, **consulta el servidor MCP si tens el més mínim dubte** de si està admesa per la normativa de l'AVL (Diccionari Normatiu Valencià).
- Recorda el context de nivell: en A1 es permet una ortografia aproximada (franja 11-9) sense que siga necessàriament eliminatòria, sempre que no bloquege la comunicació.
- No inventes regles ni penalitzes variants formals admeses en el valencià estàndard.

---

# FORMAT D'EIXIDA (JSON ESTRICTE)
Retorna exclusivament un objecte JSON vàlid amb l'estructura següent:

\`\`\`json
{
  "criteris": {
    "lexic": {
      "franja": "15-12 | 11-9 | 8-6 | 5-1",
      "observacions": "Justificació breu segons la rúbrica."
    },
    "estructures": {
      "franja": "15-12 | 11-9 | 8-6 | 5-1",
      "observacions": "Justificació breu segons la rúbrica."
    },
    "ortografia": {
      "franja": "15-12 | 11-9 | 8-6 | 5-1",
      "observacions": "Justificació breu (menciona si l'ortografia aproximada afecta la comprensió)."
    },
    "comprensibilitat_coherencia": {
      "franja": "15-12 | 11-9 | 8-6 | 5-1",
      "observacions": "Justificació breu sobre la claredat del missatge."
    },
    "adequacio": {
      "franja": "15-12 | 11-9 | 8-6 | 5-1",
      "observacions": "Justificació breu sobre si ha omés informació clau de la tasca."
    }
  },
  "puntuacio_global": 0,
  "resultat": "no eliminatòria | eliminatòria",
  "errors_destacats": [
    {
      "element_original": "text de l'alumne",
      "correccio_suggerida": "forma normativa segons AVL",
      "tipus": "lèxic | morfologia | ortografia | concordança",
      "gravetat": "lleu | greu"
    }
  ],
  "retorn_pedagogic": "Comentari en valencià encoratjador i adaptat a un estudiant de nivell A1, explicant els punts forts i els aspectes a millorar."
}
\`\`\``;

export async function evaluateA1Writing(args: {
  instructions: string;
  fields: string[];
  answers: Record<string, string>;
}): Promise<WritingEvaluation> {
  if (!process.env.OPENAI_API_KEY) throw new Error('OPENAI_API_KEY no està configurada');

  // Els camps en blanc també s'envien: l'adequació depén de si s'ha completat la tasca.
  const form = args.fields
    .map(field => `- ${field}: ${args.answers[field]?.trim() || '(en blanc)'}`)
    .join('\n');

  const messages: ChatCompletionMessageParam[] = [
    { role: 'system', content: SYSTEM_PROMPT_A1_EIE },
    {
      role: 'user',
      content: `Consigna de l'exercici 7:\n${args.instructions}\n\nFormulari omplit per l'aspirant:\n${form}`,
    },
  ];

  const { client: mcp, tools } = await getMcpTools();
  const request = () => client.chat.completions.parse({
    model: MODEL_NAME,
    messages,
    tools: tools.length > 0 ? tools : undefined,
    response_format: zodResponseFormat(WritingEvaluationSchema, 'avaluacio_eie_a1'),
    reasoning_effort: 'none', // Obligatori per a usar tools amb gpt-6-luna en /v1/chat/completions
  });

  const tStart = Date.now();
  let choice = (await request()).choices[0];
  for (let round = 0; choice?.message?.tool_calls?.length && round < MAX_TOOL_ROUNDS; round += 1) {
    messages.push(choice.message);
    for (const toolCall of choice.message.tool_calls) {
      if (toolCall.type !== 'function') continue;
      console.log(`[exam-eval MCP] ${toolCall.function.name}(${toolCall.function.arguments})`);
      let toolOutput: unknown;
      try {
        const result = await mcp.callTool({
          name: toolCall.function.name,
          arguments: JSON.parse(toolCall.function.arguments || '{}'),
        });
        toolOutput = result.content;
      } catch (err) {
        toolOutput = { error: `Error executant ferramenta: ${err instanceof Error ? err.message : err}` };
      }
      messages.push({
        role: 'tool',
        tool_call_id: toolCall.id,
        content: typeof toolOutput === 'string' ? toolOutput : JSON.stringify(toolOutput),
      });
    }
    choice = (await request()).choices[0];
  }
  console.log(`[exam-eval] Temps total: ${Date.now() - tStart}ms`);

  const parsed = choice?.message?.parsed;
  if (!parsed) throw new Error("El model no ha retornat una avaluació vàlida");

  // La nota de cort és fixa: el resultat es deriva de la puntuació (1-15).
  const puntuacio = Math.min(15, Math.max(1, parsed.puntuacio_global));
  return {
    ...parsed,
    puntuacio_global: puntuacio,
    resultat: puntuacio >= 9 ? 'no eliminatòria' : 'eliminatòria',
  };
}
