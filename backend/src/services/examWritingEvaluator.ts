import OpenAI from 'openai';
import { guardedFetch } from './openaiGuard.js';
import { createLoopGuard } from './loopGuard.js';
import type { ChatCompletionMessageParam } from 'openai/resources/chat/completions';
import { zodResponseFormat } from 'openai/helpers/zod';
import { contentsForPrompt, type LevelContent } from './levelContents.js';
import { z } from 'zod';
import { countWords, usedRequiredWords } from '@parlaval/shared';
import { getMcpTools } from './subagentErrorDetector.js';
import { reasoningEffortFor } from './reasoningEffort.js';

// Avaluadors de l'Àrea 3 (Expressió i Interacció Escrites) dels exàmens de la
// JQCV amb la rúbrica oficial de cada nivell: el formulari de l'A1 i la redacció
// de l'A2. Fan servir les mateixes eines MCP (DNV, softvalencia, apertium) que
// el detector d'errors.

const MODEL_NAME = process.env.OPENAI_MODEL || 'gpt-4o';
// Límit de rondes d'eines: si el model no para de consultar, es talla.
const MAX_TOOL_ROUNDS = 8;

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
  fetch: guardedFetch,
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
    contingut: z.string().describe("Codi (c1, c2...) del contingut del nivell de l'aprenent on encaixa l'error; buit si no es proporciona la llista o si l'error és d'un nivell superior."),
  })),
  retorn_pedagogic: z.string(),
});

export type A1WritingEvaluation = z.infer<typeof WritingEvaluationSchema>;

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

// Continguts del nivell de l'aprenent per a classificar els errors que es guarden (pràctica):
// s'afigen a l'entrada i no a la rúbrica, perquè no han d'influir en la puntuació.
function contentsSection(contents: LevelContent[] | undefined): string {
  if (!contents?.length) return `## CLASSIFICACIÓ DELS ERRORS\nDeixa buit el camp «contingut» de cada error.`;
  return `## CLASSIFICACIÓ DELS ERRORS (no afecta la puntuació)
Per a cada error que assenyales, indica en «contingut» el codi del contingut del nivell de l'aprenent on encaixa millor:
${contentsForPrompt(contents)}
Un error bàsic, propi d'un nivell inferior, va al contingut de la llista que més s'hi assemble. Si un error correspon a un nivell superior i no encaixa en cap contingut, deixa «contingut» buit.`;
}

// Crida el LLM amb la rúbrica i resol les consultes a les eines MCP que demane,
// fins que retorna l'avaluació amb l'esquema demanat.
async function runEvaluation<T extends z.ZodTypeAny>(args: {
  systemPrompt: string;
  userContent: string;
  schema: T;
  name: string;
}): Promise<z.infer<T>> {
  if (!process.env.OPENAI_API_KEY) throw new Error('OPENAI_API_KEY no està configurada');

  const messages: ChatCompletionMessageParam[] = [
    { role: 'system', content: args.systemPrompt },
    { role: 'user', content: args.userContent },
  ];

  const { client: mcp, tools } = await getMcpTools();
  // Detecció de bucles: la mateixa ferramenta amb els mateixos arguments, massa crides o massa temps talla l'avaluació
  // (LoopDetectedError; la ruta respon amb un error i l'alumne pot tornar-ho a provar).
  const guard = createLoopGuard({ label: `exam-eval:${args.name}` });
  const request = (toolChoice?: 'none') => {
    const last = messages.at(-1)?.content;
    guard.llmCall(typeof last === 'string' ? last : JSON.stringify(last ?? ''));
    return client.chat.completions.parse({
      model: MODEL_NAME,
      messages,
      tools: tools.length > 0 ? tools : undefined,
      tool_choice: tools.length > 0 ? toolChoice : undefined,
      response_format: zodResponseFormat(args.schema, args.name),
      ...reasoningEffortFor(MODEL_NAME),
    }, { signal: guard.signal });
  };

  const tStart = Date.now();
  let choice = (await request()).choices[0];
  for (let round = 0; choice?.message?.tool_calls?.length && round < MAX_TOOL_ROUNDS; round += 1) {
    messages.push(choice.message);
    for (const toolCall of choice.message.tool_calls) {
      if (toolCall.type !== 'function') continue;
      console.log(`[exam-eval MCP] ${toolCall.function.name}(${toolCall.function.arguments})`);
      guard.toolCall(toolCall.function.name, toolCall.function.arguments);
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
  // Si el model seguix demanant ferramentes en l'última ronda, se li obliga a respondre amb el que ja té.
  if (choice?.message?.tool_calls?.length) {
    console.warn(`[exam-eval] ${args.name}: ${MAX_TOOL_ROUNDS} rondes de ferramentes sense resposta; es força l'avaluació`);
    messages.push(choice.message);
    for (const toolCall of choice.message.tool_calls) {
      messages.push({ role: 'tool', tool_call_id: toolCall.id, content: JSON.stringify({ error: 'Límit de consultes assolit' }) });
    }
    choice = (await request('none')).choices[0];
  }
  console.log(`[exam-eval] ${args.name}: ${Date.now() - tStart}ms`);

  const parsed = choice?.message?.parsed;
  if (!parsed) {
    console.error(`[exam-eval] ${args.name}: sense avaluació (finish_reason=${choice?.finish_reason}, refusal=${choice?.message?.refusal ?? '-'})`);
    throw new Error("El model no ha retornat una avaluació vàlida");
  }
  return parsed;
}

export async function evaluateA1Writing(args: {
  instructions: string;
  fields: string[];
  answers: Record<string, string>;
  contents?: LevelContent[]; // per a classificar els errors (pràctica)
}): Promise<A1WritingEvaluation & { rubrica: 'a1_formulari' }> {
  // Els camps en blanc també s'envien: l'adequació depén de si s'ha completat la tasca.
  const form = args.fields
    .map(field => `- ${field}: ${args.answers[field]?.trim() || '(en blanc)'}`)
    .join('\n');

  const parsed = await runEvaluation({
    systemPrompt: SYSTEM_PROMPT_A1_EIE,
    userContent: `Consigna de l'exercici 7:\n${args.instructions}\n\nFormulari omplit per l'aspirant:\n${form}\n\n${contentsSection(args.contents)}`,
    schema: WritingEvaluationSchema,
    name: 'avaluacio_eie_a1',
  });

  // La nota de cort és fixa: el resultat es deriva de la puntuació (1-15).
  const puntuacio = Math.min(15, Math.max(1, parsed.puntuacio_global));
  return {
    ...parsed,
    rubrica: 'a1_formulari',
    puntuacio_global: puntuacio,
    resultat: puntuacio >= 9 ? 'no eliminatòria' : 'eliminatòria',
  };
}

// ── A2: redacció breu amb paraules obligatòries ─────────────────────────────

const A2_SCORES = [10, 6, 4, 1] as const;
const A2Criteri = z.object({ puntuacio: z.number().int(), justificacio: z.string() });

export const A2WritingEvaluationSchema = z.object({
  criteris: z.object({
    lexic: A2Criteri,
    morfosintaxi: A2Criteri,
    ortografia: A2Criteri,
    coherencia_cohesio: A2Criteri,
    adequacio: A2Criteri,
  }),
  paraules_obligatories: z.object({
    utilitzades: z.array(z.string()),
    compleix_minim: z.boolean(),
  }),
  puntuacio_total_rubrica: z.number(),
  mitjana_ponderada_base_10: z.number(),
  errors_detectats: z.array(z.object({
    segment_original: z.string(),
    proposta_correccio: z.string(),
    categoria: z.enum(['lèxic', 'morfosintaxi', 'ortografia', 'connector']),
    sistematic: z.boolean(),
    contingut: z.string().describe("Codi (c1, c2...) del contingut del nivell de l'aprenent on encaixa l'error; buit si no es proporciona la llista o si l'error és d'un nivell superior."),
  })),
  comentari_global: z.string(),
});

export type A2WritingEvaluation = z.infer<typeof A2WritingEvaluationSchema>;

export const SYSTEM_PROMPT_A2_EIE = `# ROL I CONTEXT
Actues com a avaluador oficial de la Junta Qualificadora de Coneixements de Valencià (JQCV), seguint fidelment la normativa lingüística de l'Acadèmia Valenciana de la Llengua (AVL).
La teua missió és avaluar una tasca d'expressió i interacció escrita corresponent al nivell A2 segons la rúbrica oficial de competències comunicatives.

---

# ESCALA I CRITERIS DE PUNTUACIÓ
La rúbrica avalua 5 criteris independents. Cada criteri s'ha de puntuar estrictament amb un dels valors discrets següents: **10**, **6**, **4** o **1** punt.

### 1. COMPETÈNCIES LINGÜÍSTIQUES

* **Lèxic:**
  - **10 punts:** Disposa d'un vocabulari ampli que li permet resoldre la tasca amb nivell; utilitza sinònims, hipònims...
  - **6 punts:** Disposa de vocabulari suficient per a poder resoldre la tasca sense problemes.
  - **4 punts:** Respon a la tasca de manera molt justa i amb algun error lèxic que dificulta la comprensió global.
  - **1 punt:** La tasca presenta errors lèxics que no permeten la comprensió del text.
  - **CALIBRATGE PER A UN A2 (obligatori):** avalua el lèxic amb les expectatives d'un usuari **bàsic** (A2), no d'un B1 o superior. El criteri és la **comprensió i la suficiència per a resoldre la tasca**, no la riquesa ni la precisió estilística.
    · **6 punts és la nota de referència d'un text A2 correcte**: vocabulari quotidià, repetitiu o limitat, però suficient i comprensible. No el rebaixes per repetir paraules, usar lèxic simple, no emprar sinònims o registre poc elaborat.
    · **10 punts** es reserva per a un vocabulari clarament ric per a l'A2 (varietat, alguns sinònims o mots més precisos). Si el text és sòlid i variat per al nivell, no cal que siga perfecte per a arribar-hi.
    · **4 punts** només si els errors lèxics (paraules inventades, calcs o mots en castellà) dificulten de veres la comprensió **global**. Uns quants castellanismes, calcs o imprecisions lèxiques aïllades que no impedeixen entendre el text NO justifiquen baixar de 6; tracta'ls com a observacions en \`errors_detectats\` (gravetat lleu), no com a motiu de penalització.
    · **1 punt** només si el text és pràcticament incomprensible pel lèxic.
    · Una paraula mal triada però que s'entén pel context, o una falta lèxica aïllada, no canvia la franja. Els errors ortogràfics o morfològics NO es compten dins del lèxic (ja tenen el seu criteri).
    · En cas de dubte entre dues franges, tria la **més alta** (principi de benefici del dubte propi del nivell inicial).

* **Morfosintaxi:**
  - **10 punts:** El text presenta un control gramatical sense errors sistemàtics.
  - **6 punts:** Coneix la morfologia del nivell, i els errors que puga fer no són sistemàtics.
  - **4 punts:** Les estructures que usa són senzilles i presenten errors sistemàtics.
  - **1 punt:** No controla els elements bàsics de la norma (concordança, díctics, possessius...).

* **Ortografia:**
  - **10 punts:** El text presenta errors ortogràfics puntuals, però, en general, s'ajusta a la norma.
  - **6 punts:** Utilitza ortografia aproximada, suficient per a fer-se entendre, però no forçosament ajustada a la norma ortogràfica.
  - **4 punts:** Presenta faltes ortogràfiques, però no afecten la comprensió del text.
  - **1 punt:** L'ortografia usada s'allunya tant de la norma que impedix o dificulta molt la comprensió del text.

### 2. COMPETÈNCIES TEXTUALS

* **Coherència i cohesió:**
  - **10 punts:** L'organització de les idees és correcta, les parts estan ben estructurades i l'ús dels connectors és l'adequat (complix els tres aspectes: organització, parts i connectors).
  - **6 punts:** Usa correctament **dos** dels ítems següents: organització, parts o connectors.
  - **4 punts:** Usa correctament **un** dels ítems següents: organització, parts o connectors.
  - **1 punt:** No fa un ús correcte de **cap** dels ítems següents: organització, parts, connectors.

* **Adequació:**
  - **10 punts:** Afig elements de valor a l'objectiu complit de la tasca i el text respecta les indicacions d'extensió.
  - **6 punts:** Complix l'objectiu de la tasca i el text respecta les indicacions d'extensió.
  - **4 punts:** Complix **un** dels dos ítems següents: objectiu o extensió.
  - **1 punt:** No complix **cap** dels ítems següents: objectiu, extensió.
  - **CALIBRATGE PER A UN A2 (obligatori):** l'adequació es jutja amb flexibilitat, atenent només si la tasca s'ha resolt, no la perfecció del text.
    · **Objectiu complit** = el text respon a la situació de la consigna (tema, tipus de text i propòsit comunicatiu bàsics) encara que siga de manera simple, breu o amb alguna idea poc desenvolupada. No exigisques tots els punts de la consigna ni un registre perfecte; un desajust menor de registre (tu/vosté) no implica no complir l'objectiu.
    · **6 punts és la nota de referència** d'un text A2 que resol la tasca i respecta l'extensió.
    · **10 punts:** basta que afija algun element de valor (un detall, una explicació, una idea pròpia) sense necessitat que siga excepcional.
    · **Extensió:** sigues tolerant amb desviacions xicotetes fora del rang (uns pocs mots de més o de menys, aprox. ±10 %) si la resta del text és adequat; només compta com a no respectada si la desviació és clara.
    · **Paraules obligatòries:** compten sempre que s'usen amb un sentit raonable; no exigisques un ús brillant ni penalitzes una paraula usada de manera millorable però comprensible.
    · En cas de dubte entre dues franges, tria la **més alta**.

---

# PARAULES OBLIGATÒRIES I EXTENSIÓ
La consigna dona una llista de paraules i l'aspirant n'ha d'usar un mínim en el text (la consigna indica quantes). Algunes paraules de la llista poden no tindre relació amb la situació: triar les adequades també forma part de la tasca.
- Una paraula compta com a usada si apareix en qualsevol forma flexionada (singular/plural, masculí/femení) i amb un sentit adequat al context. Una paraula inserida sense sentit o com una llista solta NO compta.
- Rebràs un recompte automàtic de paraules i de paraules obligatòries detectades. Pren-lo com a referència: confirma'l, afig les que el recompte no haja detectat per variació morfològica i descarta les usades sense sentit.
- **No arribar al mínim de paraules obligatòries vol dir que NO es complix l'objectiu de la tasca**: el criteri d'Adequació no pot passar de 4 (o 1 si tampoc es respecta l'extensió), i el Lèxic no pot passar de 6.
- **L'extensió** es considera respectada si el nombre de paraules està dins del rang que indica la consigna. Un text fora del rang no complix l'ítem d'extensió en el criteri d'Adequació.
- Indica en \`paraules_obligatories\` les paraules de la llista que realment has comptat com a usades i si s'arriba al mínim.

---

# ÚS D'EINES I SERVIDOR MCP
- Tens accés a ferramentes MCP de consulta normativa (diccionari normatiu AVL, verificador de gramàtica).
- Si dubtes sobre la validesa d'una variant morfològica (p. ex., desinències verbals, combinacions de pronoms clítics, formes dobles admeses) o un terme lèxic abans de catalogar-lo com a error, **invoca la ferramenta MCP pertinent per a verificar la norma oficial de l'AVL**.
- No penalitzes trets lingüístics legítims segons la gramàtica normativa valenciana.

---

# FORMAT D'EIXIDA (JSON ESTRICTE)
Retorna exclusivament un objecte JSON estructurat d'aquesta manera:

\`\`\`json
{
  "criteris": {
    "lexic": {
      "puntuacio": 10,
      "justificacio": "Explicació concisa de la tria del valor segons la rúbrica."
    },
    "morfosintaxi": {
      "puntuacio": 6,
      "justificacio": "Explicació del control gramatical i tipus d'errors detectats."
    },
    "ortografia": {
      "puntuacio": 6,
      "justificacio": "Explicació sobre la precisió ortogràfica o grau d'aproximació."
    },
    "coherencia_cohesio": {
      "puntuacio": 10,
      "justificacio": "Detalla si complix els tres ítems (organització, parts i connectors) o quins fallen."
    },
    "adequacio": {
      "puntuacio": 6,
      "justificacio": "Detalla el grau de compliment de l'objectiu comunicatiu, de les paraules obligatòries i del recompte d'extensió."
    }
  },
  "paraules_obligatories": {
    "utilitzades": ["paraula1", "paraula2"],
    "compleix_minim": true
  },
  "puntuacio_total_rubrica": 38,
  "mitjana_ponderada_base_10": 7.6,
  "errors_detectats": [
    {
      "segment_original": "text amb error",
      "proposta_correccio": "forma normativa segons AVL",
      "categoria": "lèxic | morfosintaxi | ortografia | connector",
      "sistematic": false
    }
  ],
  "comentari_global": "Avaluació constructiva i orientada a l'estudiant de nivell A2."
}
\`\`\``;

// Un valor fora de l'escala es porta al més pròxim (10, 6, 4 o 1).
const snapScore = (value: number) =>
  A2_SCORES.reduce((best, s) => (Math.abs(s - value) < Math.abs(best - value) ? s : best), A2_SCORES[0]);

export async function evaluateA2Writing(args: {
  instructions: string;
  text: string;
  minWords: number;
  maxWords: number;
  words: string[];
  minWordsUsed: number;
  contents?: LevelContent[]; // per a classificar els errors (pràctica)
}): Promise<A2WritingEvaluation & { rubrica: 'a2_redaccio'; recompte_paraules: number }> {
  const count = countWords(args.text);
  const detected = usedRequiredWords(args.text, args.words);

  const parsed = await runEvaluation({
    systemPrompt: SYSTEM_PROMPT_A2_EIE,
    userContent: [
      `Consigna:\n${args.instructions}`,
      `Extensió demanada: entre ${args.minWords} i ${args.maxWords} paraules.`,
      `Paraules de la llista (cal usar-ne almenys ${args.minWordsUsed}): ${args.words.join(', ')}.`,
      `Recompte automàtic: ${count} paraules (${count >= args.minWords && count <= args.maxWords ? 'dins' : 'fora'} del rang). ` +
        `Paraules de la llista detectades (${detected.length}): ${detected.join(', ') || 'cap'}.`,
      `Text de l'aspirant:\n"""\n${args.text.trim()}\n"""`,
      contentsSection(args.contents),
    ].join('\n\n'),
    schema: A2WritingEvaluationSchema,
    name: 'avaluacio_eie_a2',
  });

  // Els totals es calculen ací a partir dels criteris, perquè sempre quadren.
  const criteris = Object.fromEntries(
    Object.entries(parsed.criteris).map(([k, c]) => [k, { ...c, puntuacio: snapScore(c.puntuacio) }]),
  ) as A2WritingEvaluation['criteris'];
  const total = Object.values(criteris).reduce((sum, c) => sum + c.puntuacio, 0);
  return {
    ...parsed,
    rubrica: 'a2_redaccio',
    recompte_paraules: count,
    criteris,
    puntuacio_total_rubrica: total,
    mitjana_ponderada_base_10: Math.round((total / 5) * 10) / 10,
  };
}

// ── B1: redaccions de l'exercici 6 (opció A/B) i 7 (enunciat amb imatge) ────

const B1Criteri = z.object({ puntuacio: z.number().int(), franja: z.string(), justificacio: z.string() });

export const B1WritingEvaluationSchema = z.object({
  comprovacio_extensio: z.object({
    paraules_reals: z.number().int(),
    objectiu_tasca: z.string(),
    dins_marge_10_percent: z.boolean(),
  }),
  criteris: z.object({
    lexic: B1Criteri,
    morfosintaxi: B1Criteri.extend({ presencia_pronoms_febles: z.boolean() }),
    ortografia: B1Criteri,
    coherencia_cohesio: B1Criteri.extend({ items_assolits: z.array(z.enum(['organitzacio', 'parts', 'connectors'])) }),
    adequacio: B1Criteri.extend({ items_assolits: z.array(z.enum(['objectiu', 'extensio'])) }),
  }),
  puntuacio_total_rubrica: z.number(),
  mitjana_base_10: z.number(),
  errors_detectats: z.array(z.object({
    segment_original: z.string(),
    proposta_correccio: z.string(),
    categoria: z.enum(['lèxic', 'morfosintaxi', 'ortografia']),
    sistematic: z.boolean(),
    contingut: z.string().describe("Codi (c1, c2...) del contingut del nivell de l'aprenent on encaixa l'error; buit si no es proporciona la llista o si l'error és d'un nivell superior."),
  })),
  retorn_pedagogic: z.string(),
});

export type B1WritingEvaluation = z.infer<typeof B1WritingEvaluationSchema>;

// Rúbriques oficials de la JQCV per a les redaccions del B1 i del B2: mateixos cinc criteris
// i mateixa escala (10, 6, 4, 1), amb descriptors diferents per a cada nivell.
const EIE_RUBRICS = {
  B1: `# RÚBRICA D'AVALUACIÓ OFICIAL (NIVELL B1)
Has d'avaluar 5 criteris independents. Cada criteri s'ha de puntuar exclusivament amb un dels valors discrets següents: **10**, **6**, **4** o **1** punt.

### 1. COMPETÈNCIES LINGÜÍSTIQUES

* **Lèxic:**
  - **10 punts:** Disposa d'un vocabulari ampli que li permet resoldre la tasca amb precisió. Utilitza polisèmia, homonímia, composició, derivació...
  - **6 punts:** Disposa de vocabulari suficient per a poder resoldre la tasca sense problemes.
  - **4 punts:** Respon a la tasca de manera molt justa i amb alguna interferència lèxica que dificulta la comprensió global.
  - **1 punt:** La tasca presenta errors lèxics que no permeten la comprensió del text.

* **Morfosintaxi:**
  - **10 punts:** El text presenta un control gramatical sense errors sistemàtics i amb ús de pronoms febles.
  - **6 punts:** Coneix la morfologia bàsica, i els errors que puga fer no són sistemàtics.
  - **4 punts:** Les estructures que usa són senzilles i presenten errors sistemàtics.
  - **1 punt:** No controla els elements bàsics de la norma (concordances, díctics, possessius...).

* **Ortografia:**
  - **10 punts:** Presenta una ortografia bàsica correcta i un ús adequat dels signes de puntuació.
  - **6 punts:** Utilitza ortografia bàsica correcta per a fer-se entendre, amb alguna falta no sistemàtica.
  - **4 punts:** Presenta faltes ortogràfiques sistemàtiques, però que no afecten la comprensió del text.
  - **1 punt:** L'ortografia usada s'allunya tant de la norma que impedix o dificulta molt la comprensió del text.

### 2. COMPETÈNCIES TEXTUALS

* **Coherència i cohesió:**
  - **10 punts:** L'organització de les idees és correcta, les parts estan ben estructurades i l'ús dels connectors és l'adequat (complix els 3 aspectes: organització, parts i connectors).
  - **6 punts:** Usa correctament **dos** dels ítems següents: organització, parts o connectors.
  - **4 punts:** Usa correctament **un** dels ítems següents: organització, parts o connectors.
  - **1 punt:** No fa un ús correcte de **cap** dels ítems següents: organització, parts, connectors.

* **Adequació:**
  - **10 punts:** Afig elements de valor a l'objectiu complit de la tasca i el text respecta les indicacions d'extensió.
  - **6 punts:** Complix l'objectiu de la tasca i el text respecta les indicacions d'extensió amb un marge del ±10 %.
  - **4 punts:** Complix **un** dels dos ítems següents: objectiu o extensió.
  - **1 punt:** No complix **cap** dels ítems següents: objectiu, extensió.

### 3. ELEMENTS DEL NIVELL B1 (Quadern B1 de la JQCV, 3.2)
La rúbrica remet al programa per a l'Ortografia (3.2.1), la Morfosintaxi (3.2.2) i el Lèxic (3.2.3): són els elements d'estes llistes. Valora només els elements que apareixen en el text (o que la tasca exigix de manera evident): un text breu no els pot mostrar tots, i l'absència d'un element no és un error. El que compta és si els que usa els usa bé i si els errors són sistemàtics (es repetixen) o aïllats. No penalitzes l'aspirant per no usar elements de nivells superiors.

**3.2.1. Fonètica, elocució i ortografia** (criteri d'Ortografia)
- Grafies: lletres simples i modificades, dígrafs (rr, ll, l·l, ny, gu, qu, ss, tj, tg, tz) i geminacions del vocabulari familiar; síl·labes, diftongs i hiats; paraules agudes, planes i esdrúixoles.
- Vocals: a/e (Miquelet, afaitar), o/u (cobert, Joan, Josep); e inicial en em-, en-, es-, eix- (embastar, entendre, estendre, eixugar); alternances e/i, o/u en verbs irregulars (llig/llegim, ixes/eixim; puc/pot, vullga/volia); vocals obertes i tancades.
- Normes generals d'accentuació (Ramon, camió, fareu; fenomen, plàstic, féreu; fàbrica, justícia); normes bàsiques de la dièresi i del guionet.
- Apostrofació i contracció: el/la i de (l'ase, l'era, l'illa, l'home, l'ungla; la infermera, la universitat; d'amo, d'Isabel); apòstrof en pronoms febles units al verb i en combinacions bàsiques.
- Oclusives i labiodentals: alternances de les oclusives finals en la flexió i la derivació (llop/lloba, cunyat/cunyada, verd/verda, groc/groga, llarg/llargues; rep/rebem); paraules acabades en oclusiva (àrab, covard, sang); cu-/qu- (cua/quota, evacuar/adequar); -xc- i -cc- (excés/accés); -v- en l'imperfet de la primera conjugació (trobava, trobàvem).
- Alveolars: c/ç en la flexió (pinça, pinces; vençut, véncer; forçar, forcem); -ança, -ença (esperança, complaença); x i cc (taxa; examen, exèrcit; acció); -esa, -essa (bellesa, timidesa; alcaldessa, metgessa); gentilicis en -és (xinés, xinesa, xinesos, xineses); derivats d'agudes en vocal + s (gos, gossa; pas, passos; calorós, calorosa; mes, mesos); -sc- (piscina, escena, ascens).
- Palatals: g, j, tg, tj, ig (gener, jove, platja, mitges; raig, fuig) i excepcions (objecte, Jesús); consonant + x (planxa), tx entre vocals (fitxa), x- inicial (xica, xarop); j/tj + a, o, u i g/tg + e, i (boja, bojos, platja; boges, platges); derivats de -tx i -ig (escabetxar, despatxos; rojor, lletja).
- Laterals, nasals, ròtiques i h: l·l (al·l-, col·l-, il·l-, -el·la, -il·la) i tl/tll (ametla, ratlla); m davant de b, p, m (umbracle, irrompre, immens); -ny final (disseny, puny); r inicial i en grups (rosa, parlar, Enric); h inicial i intercalada (harmonia; ahir, vehement); haver en els temps compostos (m'ha agradat).
- Convencions: normes bàsiques de majúscules i minúscules; punt i coma, dos punts, punts suspensius i parèntesis.

**3.2.2. Morfosintaxi** (criteri de Morfosintaxi)
- Substantius i adjectius: gènere (secretari/secretària; cavall/egua; cantaire, homicida) i nombre (llengua/llengües); adjectius d'una i de dos terminacions; gruixut i gros; concordança de l'article amb el nom i l'adjectiu; graus (-íssim; -et, -ó; millor/pitjor, el millor; bo, roín, regular).
- Determinants: article definit i indefinit; contracció i apostrofació (l'amiga, l'infermer, la infermera; del mercat, a l'estadi); demostratius simples i reforçats (este/aquest, eixe/aqueix); possessius tònics i àtons habituals (ta mare, son iaio, sa casa).
- Pronoms: forts (gènere, nombre i persona); febles (morfologia i col·locació, apostrofació i guionet); febles de complement directe i indirecte; combinació CI + CD; interrogatius (què, qui, quin, a on, com; quan/quant).
- Quantificadors: cardinals (catorze, trenta-dos, tres-cents, un milió) i ordinals (primer, quart, cinqué/quint, sisena/sexta, vinté); quant i prou; locucions (bona cosa de, gens ni mica de, un grapat de, un muntó de, un fum de); indefinits (diversos, diferents, qualsevol, tal, tothom, alguna cosa); res, gens i cap/ningun.
- Preposicions i locucions prepositives de mitjà (a, amb, a través de), de tema (de, sobre), de causa (amb motiu de, a causa de, arran de, per culpa de, gràcies a) i de relació (per, en comptes de, en lloc de); a davant de topònims i de classe, casa...; sense a davant del complement directe (Han vist el mestre).
- Adverbis d'afirmació (sens dubte, de veres, prou, i tant) i de negació (de cap manera); adverbis en -ment; comparatius (més/menys que, tant/tan com).
- Connectors: adversatius i concessius (encara que, sinó, tot i que), consecutius (doncs, per tant, així), temporals (quan, mentres, cada vegada que, sempre que, abans que, després que) i condicionals (si, en cas que).
- Verbs: regulars (present, passat simple i perifràstic, perfet, plusquamperfet, futur, present i imperfet de subjuntiu, condicional); irregulars (nàixer, córrer, saber, voler, ser, vore, anar, estar, fer, dir-se, poder, tindre, conéixer, omplir, obrir, tossir); règim preposicional (atrevir-se a, començar a, decidir-se a, negar-se a, pensar en, confiar en); indicatiu, subjuntiu i imperatiu; ser i estar locatius; semblar; obligació (haver de, deure, caldre + infinitiu) i probabilitat (deure + infinitiu).

**3.2.3. Lèxic i semàntica** (criteri de Lèxic)
- Vocabulari usual: família i parentiu; habitatge; treball; el camp i la ciutat; vehicles, trànsit, transports i viatges; plantes, animals, paisatge i oratge; jocs i esports; esdeveniments actuals; música, cinema i teatre; diners, negocis i tecnologia; descripció de persones, objectes, caràcters i estats d'ànim.
- Creació lèxica: derivació (prefixos i sufixos principals) i composició.
- Locucions i frases fetes més usuals.
- Precisió lèxica i genuïnitat: alternatives als barbarismes més usuals.
- Relacions semàntiques: sinonímia, antonímia, hiperonímia i hiponímia del vocabulari usual.

---

`,
  B2: `# RÚBRICA D'AVALUACIÓ OFICIAL (NIVELL B2)
Has d'avaluar 5 criteris independents. Cada criteri s'ha de puntuar exclusivament amb un dels valors discrets següents: **10**, **6**, **4** o **1** punt. Calibra'ls amb les expectatives d'un usuari **independent avançat** (B2): més exigents que en el B1.

### 1. COMPETÈNCIES LINGÜÍSTIQUES

* **Lèxic:**
  - **10 punts:** Utilitza locucions i frases fetes d'ús freqüent. El lèxic és precís i genuí: és capaç de produir alternatives als barbarismes. Usa la comparació, la metàfora i la metonímia com a mecanismes de creació lèxica. Utilitza polisèmia, homonímia, composició, derivació...
  - **6 punts:** Domina un repertori lèxic i fraseològic (locucions i algunes frases fetes) suficient per a comunicar-se de manera detallada.
  - **4 punts:** Respon a la tasca de manera molt justa o ambigua. Utilitza un nombre considerable de barbarismes. Les repeticions en el lèxic són freqüents. No usa cap frase feta ni locució.
  - **1 punt:** La tasca presenta errors lèxics que fan incomprensible el text.

* **Morfosintaxi:**
  - **10 punts:** Pot usar oracions complexes per a oferir un discurs clar. Utilitza correctament pronoms febles, quantificadors, preposicions, adverbis, conjuncions, verbs i relatius del nivell.
  - **6 punts:** Pot usar les diverses categories gramaticals per a formar la major part d'estructures sintàctiques, encara que comet algun error que no dificulta la comunicació. Domina, almenys, la mitat dels elements morfosintàctics del nivell.
  - **4 punts:** Té un coneixement bàsic de la morfologia nominal i verbal i de les categories gramaticals, i això provoca un discurs repetitiu o forçat, amb errors que dificulten o entorpixen la comunicació. Controla menys de la mitat dels elements morfosintàctics del nivell.
  - **1 punt:** No controla els elements bàsics de la norma.

* **Ortografia:**
  - **10 punts:** Coneix les normes d'accentuació (incloent-hi els diacrítics més usuals) i les normes generals de la dièresi i del guionet. No presenta errors sistemàtics en consonantisme ni vocalisme del nivell. Coneix les convencions del nivell.
  - **6 punts:** Coneix la normativa bàsica de l'ortografia del nivell: en domina, almenys, la mitat dels elements.
  - **4 punts:** Presenta faltes ortogràfiques sistemàtiques en més de la mitat dels elements del nivell.
  - **1 punt:** L'ortografia usada s'allunya tant de la norma que no es pot situar el text en un registre estàndard.

### 2. COMPETÈNCIES TEXTUALS

* **Coherència i cohesió:**
  - **10 punts:** L'organització de les idees és correcta, les parts estan ben estructurades i l'ús dels connectors és l'adequat (complix els 3 aspectes: organització, parts i connectors).
  - **6 punts:** Usa correctament **dos** dels ítems següents: organització, parts o connectors.
  - **4 punts:** Usa correctament **un** dels ítems següents: organització, parts o connectors.
  - **1 punt:** No fa un ús correcte de **cap** dels ítems següents: organització, parts, connectors.

* **Adequació:**
  - **10 punts:** Afig elements de valor a l'objectiu complit de la tasca i el text respecta les indicacions d'extensió.
  - **6 punts:** Complix l'objectiu de la tasca i el text respecta les indicacions d'extensió amb un marge del ±10 %.
  - **4 punts:** Complix **un** dels dos ítems següents: objectiu o extensió.
  - **1 punt:** No complix **cap** dels ítems següents: objectiu, extensió.

### 3. ELEMENTS DEL NIVELL B2 (Quadern B2 de la JQCV, 3.2)
La rúbrica remet als «elements del nivell» de l'Ortografia (3.2.1), la Morfosintaxi (3.2.2) i el Lèxic (3.2.3): són els d'estes llistes. Per a decidir si l'aspirant en domina almenys la mitat, valora només els elements que apareixen en el text (o que la tasca exigix de manera evident): un text breu no els pot mostrar tots, i l'absència d'un element no és un error. El que compta és si els que usa els usa bé i si els errors són sistemàtics (es repetixen) o aïllats.

**3.2.1. Fonètica, elocució i ortografia** (criteri d'Ortografia)
- Grafies: lletres simples i modificades, dígrafs (rr, ll, l·l, ny, gu, qu, ss, tj, tg, tz) i geminacions; diftongs, hiats i triftongs; imperfet d'indicatiu (feia, reies...).
- Vocals: a/e (avaria, afaitar), o/u (cobert, Joan, Josep); e inicial en em-, en-, es-, eix- (embastar, entendre, estendre, eixugar); alternances e/i, o/u en verbs irregulars (llig/llegim, ixes/eixim; puc/pot, vullga/volia).
- Accentuació d'homòfons i parònims (patí/pati; mitjà/mitja; mà/ma/m'ha) i els quinze diacrítics (bé, déu, és, mà, més, món, pèl, què, sé, sí, sòl, són, té, ús, vós).
- Dièresi (güe, güi, qüe, qüi; hiats com veïna; verbs en -air, -eir, -oir, -uir) i guionet (numerals; verb + pronom); apostrofació.
- Oclusives i labiodentals: gerundis en -t; -etud, -itud; ab-, ob-, sub-, cap-; b/p (sap/saber, cap/cabut); v/u (neu/nevar); mb i nv (ambició, embolic; convent, invent).
- Alveolars: s sorda i sonora (rosa/rossa; casar/caçar; posar/passar, colze); c/ç en la flexió (pinça, pinces; vençut, véncer; forçar, forcem); -ança, -ença; -esa, -essa (bellesa, timidesa; alcaldessa, metgessa); gentilicis en -és (xinés, xinesa, xinesos, xineses); x i cc (taxa, examen, exèrcit, acció); derivats d'agudes en vocal + s (gos, gossa; pas, passos; calorós, calorosa; mes, mesos); -sc- (piscina, escena, ascens).
- Palatals: j/tj + a, o, u i g/tg + e, i (boja, bojos, platja; boges, platges); derivats de -tx i -ig (capritxós, despatxos; rojor, lletja).
- Laterals, nasals, ròtiques i h: l·l i tl/tll (col·legi, pel·lícula, intel·ligent; ametla, ratlla); h inicial i interior (harmonia, hidratar, hora; alcohol, ahir, tothom, prohibir); homòfons a/ha/ah, em/hem, i/hi.
- Convencions: majúscules i minúscules segons la puntuació; punt i coma, dos punts, punts suspensius, parèntesis, guió de diàleg i cometes en les citacions.

**3.2.2. Morfosintaxi** (criteri de Morfosintaxi)
- Substantius i adjectius: gènere i nombre irregular i invariable (ase/somera, cavall/egua; fisioterapeuta, homicida); canvis de significat segons el gènere (llum, pols, terra, clau); adjectius en -aç, -iç, -oç (capaç/capaços/capaces); -leg/-loga; concordança (anàlisi clínica, estudiant tenaç).
- Determinants: article neutre i construccions alternatives; demostratius (sistema binari i ternari); possessius tònics i àtons.
- Pronoms forts (mi, si, vosté, vostés; sense mi, amb tu).
- Pronoms febles: morfologia i col·locació (apostrofació i guionet); funció d'atribut i de complement circumstancial; combinacions binàries (reflexiu + CD, reflexiu + atribut, CI + CC, CD + CC, CI + CD); anar-se'n, tornar-se'n, eixir-se'n.
- Interrogatius i exclamatius: quin/quina/quins/quines, qui, què, com, a on, quan, quant, per què.
- Relatius: que, què, qual, a on, qui; neutres (amb la qual cosa, cosa que, fet que); subordinades substantives, adjectives (especificatives i explicatives) i adverbials.
- Quantificadors: ordinals i partitius (mig, terç, quart, una quinta part); abreviatures d'ordinals (1r, 1a, 2n, 3r, 4t, 8é, 6a, 1rs); quant i prou; locucions (bona cosa de, gens ni mica de, un grapat de, un muntó de, un fum de); indefinits (diversos, diferents, qualsevol, tal, tothom, alguna cosa); res, gens i cap/ningun.
- Preposicions: amb/en, a/en; davant de parts del dia, mesos, estacions i festes; sense, per i per a davant de sintagma nominal; caiguda de la preposició davant de que àton.
- Adverbis d'afirmació (sí, també, fins i tot/inclús, prou) i de dubte (potser).
- Connectors: adversatius i concessius (en canvi, per contra, no obstant això), distributius (així com, no sols/solament), causals (a causa de, per culpa de, com que, ja que); que a l'inici d'interrogatives i exclamatives.
- Verbs: irregulars velaritzats (córrer, verbs en -ndre, vocal + -ure i -ldre, i derivats); canvis vocàlics (collir, bollir/bullir, tossir); imperfet d'indicatiu (veia, queia, réieu); usos del subjuntiu i ordes en negatiu (no + subjuntiu); ser i estar atributius o locatius; perífrasis incoatives, de probabilitat, de realització recent i d'aproximació; infinitiu (agramatical amb valor d'imperatiu, com *No passar; article davant d'infinitiu substantivat).

**3.2.3. Lèxic i semàntica** (criteri de Lèxic)
- Vocabulari general: àmbits docent i professional; documents formals (cartes, correus electrònics, sol·licituds); menjar, dieta, restauració, salut i esport; tecnologia i ciències de la naturalesa; contes, rondalles i cançons tradicionals; llengües i gentilicis; descripció espacial, física i de personalitat.
- Formació del lèxic: derivació (prefixació i derivació, canvis de categoria, canvis ortogràfics, canvi de posició de l'accent, flexió de la paraula resultant) i composició.
- Locucions i frases fetes d'ús freqüent.
- Precisió lèxica i genuïnitat: polisèmia i homonímia; alternatives als barbarismes; comparació, metàfora i metonímia.
- Relacions semàntiques: sinonímia i antonímia; relacions lexicosemàntiques textuals bàsiques.

---

`,
};

type EieLevel = keyof typeof EIE_RUBRICS | 'C1';

const eieSystemPrompt = (level: EieLevel) => `# ROL I CONTEXT
Actues com a avaluador oficial de la Junta Qualificadora de Coneixements de Valencià (JQCV), seguint fidelment la normativa de l'Acadèmia Valenciana de la Llengua (AVL).
La teua tasca és avaluar les produccions d'expressió i interacció escrita de nivell ${level} aplicant estrictament la rúbrica oficial de competències comunicatives.

---

${EIE_RUBRICS[level as keyof typeof EIE_RUBRICS]}# CONTEXT DE LA TASCA
Rebràs la consigna exacta a la qual respon l'aspirant. L'objectiu de la tasca s'avalua SEMPRE respecte d'eixa consigna:
- **Redacció amb opcions (exercici 6 del B1, exercici 7 del B2, exercicis 4 i 5 del C1):** l'aspirant ha triat una de les dos opcions (A o B) i rebràs NOMÉS la consigna d'eixa opció: la situació comunicativa i els punts que ha de desenvolupar. Avalua l'Adequació exclusivament respecte d'eixa consigna; no n'hi ha cap altra i no has d'esperar que el text parle de res més.
  - L'objectiu es complix si el text respon a eixa situació (gènere textual, destinatari i registre: correu, blog, entrada web...) i tracta tots els punts indicats.
  - Un punt es considera tractat si el text en parla de manera identificable, encara que siga breument i amb paraules pròpies: no cal que en repetisca la formulació ni que el desenvolupe en profunditat.
  - Només si falta del tot algun punt, o el text no respon a la situació, l'ítem «objectiu» NO es complix. Abans de decidir-ho, repassa el text punt per punt.
  - Si l'opció triada porta una imatge de suport (una infografia), rebràs la transcripció del seu contingut i s'aplica el mateix criteri que en els textos a partir d'un enunciat amb imatge (vegeu el punt següent).
- **Text a partir d'un enunciat (exercici 7 del B1, exercici 8 del B2):** l'objectiu es complix si el text respon a la situació i a totes les demandes de l'enunciat (gènere textual, destinatari, registre i continguts que es demanen). Quan l'enunciat demana tindre en compte una imatge, rebràs la transcripció del seu contingut: el text ha d'aprofitar-ne la informació (per exemple, incorporant alguns dels consells o dades, amb paraules pròpies i integrats en el discurs, no copiats com una llista). Si no n'aprofita res, l'ítem «objectiu» de l'Adequació NO es complix; si només copia la infografia sense elaboració, no pot tindre 10 en Adequació.
- **Tasques de pràctica amb text de referència:** de vegades rebràs també un text o la transcripció d'un àudio (un passatge per parafrasejar, una conferència de la qual cal prendre apunts...). L'objectiu inclou recollir-ne fidelment la informació essencial que demana l'enunciat; en una paràfrasi és correcte reaprofitar paraules del text original reorganitzades, i en uns apunts són acceptables les frases curtes i els punts, sempre que l'enunciat ho permeta.
- Indica en la justificació de l'Adequació quins punts o demandes de la consigna s'han tractat i quins no.

# EXTENSIÓ
- Rebràs el recompte automàtic de paraules, el rang demanat i si el text entra en el marge del ±10 %. **Eixe recompte és exacte: NO tornes a comptar les paraules ni el contradigues** en cap justificació.
- L'ítem «extensio» de l'Adequació es complix si el recompte diu que el text està dins del rang o dins del marge del ±10 %.
- Per a la franja de 10 punts d'Adequació el text ha de respectar el rang exacte (sense marge).

---

# PROTOCOL DE CONSULTA AL SERVIDOR MCP (AVL/DNV)
- Disposes d'accés a ferramentes MCP de consulta lingüística (diccionari normatiu DNV i verificador gramatical).
- **Verificació prèvia obligatòria:** Abans de catalogar una paraula com a castellanisme o error lèxic, consulta el servidor MCP. Si el lema està acceptat per l'AVL, no el pots penalitzar.
- No confongues formes legítimes pròpies de l'estàndard valencià (com *este/eixe*, pronoms clítics combinats o variants morfològiques vàlides) amb incorreccions.

---

# FORMAT D'EIXIDA (JSON ESTRICTE)
Retorna únicament un objecte JSON amb el següent esquema:

\`\`\`json
{
  "comprovacio_extensio": {
    "paraules_reals": 0,
    "objectiu_tasca": "p. ex. 100-120 paraules",
    "dins_marge_10_percent": true
  },
  "criteris": {
    "lexic": {
      "puntuacio": 10,
      "franja": "10 | 6 | 4 | 1",
      "justificacio": "Explicació concisa de la selecció segons la rúbrica."
    },
    "morfosintaxi": {
      "puntuacio": 10,
      "franja": "10 | 6 | 4 | 1",
      "presencia_pronoms_febles": true,
      "justificacio": "Anàlisi del control gramatical i de l'ús de pronoms febles."
    },
    "ortografia": {
      "puntuacio": 6,
      "franja": "10 | 6 | 4 | 1",
      "justificacio": "Grau de correcció ortogràfica i ús de puntuació."
    },
    "coherencia_cohesio": {
      "puntuacio": 6,
      "franja": "10 | 6 | 4 | 1",
      "items_assolits": ["organitzacio", "connectors"],
      "justificacio": "Especifica quins dels tres ítems (organització, parts, connectors) s'han complit."
    },
    "adequacio": {
      "puntuacio": 6,
      "franja": "10 | 6 | 4 | 1",
      "items_assolits": ["objectiu", "extensio"],
      "justificacio": "Compliment de l'objectiu comunicatiu (punts de la consigna tractats i omesos) i ajust d'extensió (±10 %)."
    }
  },
  "puntuacio_total_rubrica": 38,
  "mitjana_base_10": 7.6,
  "errors_detectats": [
    {
      "segment_original": "forma usada per l'aspirant",
      "proposta_correccio": "forma normativa segons l'AVL",
      "categoria": "lèxic | morfosintaxi | ortografia",
      "sistematic": false
    }
  ],
  "retorn_pedagogic": "Comentari en valencià dirigit a l'aspirant, subratllant punts forts i consells concrets de millora per al nivell ${level}."
}
\`\`\``;

export const SYSTEM_PROMPT_B1_EIE = eieSystemPrompt('B1');
export const SYSTEM_PROMPT_B2_EIE = eieSystemPrompt('B2');
const EIE_SYSTEM_PROMPTS = { B1: SYSTEM_PROMPT_B1_EIE, B2: SYSTEM_PROMPT_B2_EIE };

type EieArgs = {
  exerciseN: number;
  instructions: string;
  choice?: { key: string; text: string; points?: string[] };
  imageText?: string; // contingut de la imatge de suport (exercici 7 del B1, 8 del B2; opcions de l'exercici 5 del C1)
  sourceText?: string; // text o transcripció de l'àudio de referència (pràctica)
  text: string;
  minWords: number;
  maxWords: number;
  contents?: LevelContent[]; // per a classificar els errors (pràctica)
};

// Consigna, extensió i text de l'aspirant que es passen a l'avaluador (B1, B2 i C1).
function eieInput(args: EieArgs, level: EieLevel) {
  const count = countWords(args.text);
  const inRange = count >= args.minWords && count <= args.maxWords;
  // Marge del ±10 % sobre el rang demanat (p. ex. 150-170 → 135-187).
  // Math.round: 170 * 1.1 dona 187.00000000000003 i Math.ceil el pujaria a 188.
  const marginMin = Math.round(args.minWords * 0.9);
  const marginMax = Math.round(args.maxWords * 1.1);
  const inMargin = count >= marginMin && count <= marginMax;

  // Amb opcions, la consigna que compta és només la de l'opció triada: la general
  // («Tria una de les dos opcions...») no s'envia perquè el model no la prenga per objectiu.
  const task = args.choice
    ? [
        `## CONSIGNA QUE HA DE COMPLIR L'ASPIRANT (exercici ${args.exerciseN}, opció ${args.choice.key} triada)`,
        `Situació comunicativa:\n${args.choice.text}`,
        ...(args.choice.points?.length ? [`Punts que ha de desenvolupar:\n${args.choice.points.map((p, i) => `${i + 1}. ${p}`).join('\n')}`] : []),
        ...(args.imageText ? [`Contingut de la imatge de suport de l'opció:\n${args.imageText}`] : []),
      ]
    : [
        `## CONSIGNA QUE HA DE COMPLIR L'ASPIRANT (exercici ${args.exerciseN})`,
        `Enunciat:\n${args.instructions}`,
        ...(args.imageText ? [`Contingut de la imatge de suport:\n${args.imageText}`] : []),
        ...(args.sourceText ? [`Text de referència de la tasca:\n${args.sourceText}`] : []),
      ];

  const userContent = [
    ...task,
    `## EXTENSIÓ\nDemanada: entre ${args.minWords} i ${args.maxWords} paraules (marge del ±10 %: ${marginMin}-${marginMax}).\n` +
      `Recompte automàtic: ${count} paraules (${inRange ? 'dins del rang' : inMargin ? 'fora del rang, però dins del marge del ±10 %' : 'fora del marge del ±10 %'}).`,
    `## TEXT DE L'ASPIRANT (l'únic text que has d'avaluar)\n"""\n${args.text.trim()}\n"""`,
    contentsSection(args.contents),
  ].join('\n\n');
  // EXAM_EVAL_DEBUG=1 mostra al log exactament què rep l'avaluador.
  if (process.env.EXAM_EVAL_DEBUG) console.log(`[exam-eval] Entrada ${level}:\n${userContent}`);
  return { userContent, count, inRange, inMargin };
}

// Redaccions del B1 i del B2: mateix esquema i mateix càlcul, amb la rúbrica de cada nivell.
export async function evaluateB1Writing(args: EieArgs & {
  level?: 'B1' | 'B2'; // per defecte, B1
}): Promise<B1WritingEvaluation & { rubrica: 'b1_redaccio' | 'b2_redaccio'; opcio?: string }> {
  const level = args.level ?? 'B1';
  const { userContent, count, inRange, inMargin } = eieInput(args, level);

  const parsed = await runEvaluation({
    systemPrompt: EIE_SYSTEM_PROMPTS[level],
    userContent,
    schema: B1WritingEvaluationSchema,
    name: `avaluacio_eie_${level.toLowerCase()}`,
  });

  // Puntuacions a l'escala (10, 6, 4, 1), extensió i totals calculats ací perquè sempre quadren.
  const criteris = Object.fromEntries(
    Object.entries(parsed.criteris).map(([k, c]) => {
      const puntuacio = snapScore(c.puntuacio);
      return [k, { ...c, puntuacio, franja: String(puntuacio) }];
    }),
  ) as B1WritingEvaluation['criteris'];

  // Coherència i cohesió: la nota la dona el nombre d'ítems assolits (3 → 10, 2 → 6, 1 → 4, 0 → 1).
  const cohesionItems = [...new Set(criteris.coherencia_cohesio.items_assolits)];
  const cohesion = ([1, 4, 6, 10] as const)[cohesionItems.length] ?? 10;
  criteris.coherencia_cohesio = { ...criteris.coherencia_cohesio, items_assolits: cohesionItems, puntuacio: cohesion, franja: String(cohesion) };

  // Adequació: l'extensió no la decidix el model (sovint compta malament), sinó el recompte.
  // L'objectiu sí que és judici seu; el 10 exigix, a més, el rang exacte i que el model l'haja donat.
  const objective = criteris.adequacio.items_assolits.includes('objectiu');
  const adequacyItems = [...(objective ? ['objectiu' as const] : []), ...(inMargin ? ['extensio' as const] : [])];
  const adequacy = objective && inMargin
    ? (criteris.adequacio.puntuacio === 10 && inRange ? 10 : 6)
    : objective || inMargin ? 4 : 1;
  criteris.adequacio = { ...criteris.adequacio, items_assolits: adequacyItems, puntuacio: adequacy, franja: String(adequacy) };
  const total = Object.values(criteris).reduce((sum, c) => sum + c.puntuacio, 0);
  return {
    ...parsed,
    rubrica: `${level.toLowerCase() as Lowercase<typeof level>}_redaccio`,
    opcio: args.choice?.key,
    comprovacio_extensio: {
      paraules_reals: count,
      objectiu_tasca: `${args.minWords}-${args.maxWords} paraules`,
      dins_marge_10_percent: inMargin,
    },
    criteris,
    puntuacio_total_rubrica: total,
    mitjana_base_10: Math.round((total / 5) * 10) / 10,
  };
}

// ── C1: rúbrica oficial de la JQCV (2026) d'expressió i interacció escrites ──
// Quatre aspectes, cada un en bandes A-E amb un tram de punts; total sobre 50.

const C1Aspecte = z.object({
  banda: z.enum(['A', 'B', 'C', 'D', 'E']),
  puntuacio: z.number().int(),
  justificacio: z.string(),
});

export const C1_PROBLEMES = ['F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q'] as const;

export const C1WritingEvaluationSchema = z.object({
  comprovacio_extensio: z.object({
    paraules_reals: z.number().int(),
    objectiu_tasca: z.string(),
    dins_marge_10_percent: z.boolean(),
  }),
  criteris: z.object({
    execucio_tasca: C1Aspecte,
    construccio_discurs: C1Aspecte,
    contingut_linguistic: C1Aspecte,
    control_norma: C1Aspecte,
  }),
  problemes_especifics: z.array(z.enum(C1_PROBLEMES)),
  errors_detectats: z.array(z.object({
    segment_original: z.string(),
    proposta_correccio: z.string(),
    categoria: z.enum(['lèxic', 'morfosintaxi', 'ortografia']),
    sistematic: z.boolean(),
    contingut: z.string().describe("Codi (c1, c2...) del contingut del nivell de l'aprenent on encaixa l'error; buit si no es proporciona la llista o si l'error és d'un nivell superior."),
  })),
  retorn_pedagogic: z.string(),
});
export type C1WritingEvaluation = z.infer<typeof C1WritingEvaluationSchema>;

type C1Key = keyof C1WritingEvaluation['criteris'];
type Banda = 'A' | 'B' | 'C' | 'D' | 'E';
// Tram de punts de cada banda, de la més alta a la més baixa: [màxim, mínim].
const C1_BANDS: Record<C1Key, Record<Banda, [number, number]>> = {
  execucio_tasca: { A: [16, 13], B: [12, 8], C: [7, 4], D: [3, 1], E: [0, 0] },
  construccio_discurs: { A: [12, 9], B: [8, 6], C: [5, 3], D: [2, 1], E: [0, 0] },
  contingut_linguistic: { A: [12, 9], B: [8, 6], C: [5, 3], D: [2, 1], E: [0, 0] },
  control_norma: { A: [10, 8], B: [7, 5], C: [4, 3], D: [2, 1], E: [0, 0] },
};
const bandOf = (key: C1Key, points: number): Banda =>
  (Object.entries(C1_BANDS[key]) as [Banda, [number, number]][]).find(([, [max, min]]) => points <= max && points >= min)?.[0] ?? 'E';

const C1_RUBRIC = `# RÚBRICA OFICIAL D'AVALUACIÓ DE L'ÀREA D'EXPRESSIÓ I INTERACCIÓ ESCRITES (NIVELL C1, JQCV 2026)

## Com s'aplica
Els descriptors de cada banda s'interpreten de manera GLOBAL i no són excloents: no s'espera que l'aspirant complisca tots els aspectes d'una banda, ni se li canvia de banda perquè no execute un descriptor. Si complix tres descriptors de la banda A i dos de la B, cal ubicar-lo en la A, però amb la puntuació més baixa d'eixa banda. Per a obtindre la puntuació més alta d'una banda cal complir-ne TOTS els descriptors. Dins de cada banda tria un nombre ENTER del tram indicat.
- Banda A: aspirant excel·lent, amb un control de la llengua ajustat i òptim al nivell.
- Banda B: aspirant suficient; en alguns aspectes té dubtes de control, però arriba a un nivell adequat.
- Banda C: no arriba a demostrar un control suficient del nivell exigit.
- Banda D: control insuficient del nivell exigit.
- Banda E: actuació clarament inferior al nivell exigit, pròpia d'un nivell inferior.
Els quatre aspectes són independents. No s'exigix un domini total de la normativa ni el control d'aspectes controvertits de la llengua.

## 1. EXECUCIÓ DE LA TASCA (objectius comunicatius, adequació, impressió en el lector, ús de la documentació) — màxim 16
- **A (16-13):** Interpreta correctament la informació que se li oferix i redacta un text que complix totes les convencions del gènere. Presenta la informació amb claredat, en destaca els aspectes principals, inclou exemples rellevants i expressa la seua opinió de manera ordenada amb arguments crítics si la classe de text ho demana. El registre és adequat i la veu de l'autor no hi figura o ho fa amb subtilesa. Ajusta el discurs al lector, que en té una impressió positiva perquè s'hi inclouen coneixements compartits; el text és atractiu, amb un títol que crida l'atenció (si cal) i convida a la lectura. Té el nombre de paraules que es demana i la tasca queda resolta.
- **B (12-8):** Es basa en la informació oferta, però té algunes dificultats a l'hora d'interpretar-la i pot inventar algunes dades, usar arguments i exemples poc convincents o no tractar tots els aspectes requerits. L'objectiu comunicatiu es complix, tot i que no respecta totes les convencions del gènere. El registre es desvia lleugerament en algun moment i, a voltes, la veu de l'autor és evident. Les dades no estan ben contextualitzades perquè l'examinand les dona per sabudes; el text és millorable, li falten elements que conviden a la lectura. El text supera el nombre de paraules requerit o no hi arriba (±10 %); s'evidencia falta de recursos i es repetix informació, però la tasca està resolta.
- **C (7-4):** No gestiona bé la informació: inclou massa dades irrellevants, inventades o copiades literalment, i les presenta de manera confusa. Falten alguns punts que es demanen i els arguments són escassos i pobres. El text no s'adequa al gènere proposat. La veu de l'autor és massa evident, amb excessives opinions personals en un registre inadequat. No té en compte el lector o no s'hi adreça adequadament; excés de pressuposicions; mala impressió, presentació deficient i títol equívoc o absent (si cal). El nombre de paraules no arriba al que es demana i la tasca no queda resolta.
- **D (3-1):** No complix la tasca. No argumenta la seua opinió, copia tota la informació que se li oferix o es desvia molt del tema. No es reconeix el gènere. El registre s'allunya molt del convenient i la veu de l'autor és present en tot el text amb to inadequat. El discurs no s'ajusta al lector, que no entén de què es parla; presentació molt deficient i sense títol (si cal). El nombre de paraules està molt lluny del demanat i la tasca no queda resolta.
- **E (0):** Text d'un nivell molt inferior, tasca en blanc o text totalment il·legible.

## 2. CONSTRUCCIÓ DEL DISCURS (organització, progressió temàtica, cohesió, puntuació) — màxim 12
- **A (12-9):** Estructura adequada i ordenada, amb paràgrafs ben diferenciats i un començament i acabament clars. Bona progressió temàtica que ajuda a entendre sense problemes la informació. Usa adequadament els mecanismes de cohesió gramatical i els marcadors textuals. Utilitza correctament tant la puntuació sintàctica com l'estilística.
- **B (8-6):** Estructura adequada, tot i que pot haver-hi algun paràgraf massa llarg o massa curt; hi ha principi i final, però té problemes per a resoldre'ls. Alguns problemes en l'orde de les idees que no afecten en excés la progressió temàtica. Ús acceptable dels mecanismes de cohesió i dels marcadors, amb poca varietat o algun ús inadequat, però la comprensió no es veu afectada. La puntuació és adequada, però a voltes incorrecta, sense dificultar la comprensió de l'oració.
- **C (5-3):** No estructura bé el text: paràgrafs massa curts o massa llargs; l'inici i el final són confusos o no s'identifiquen. Informació desordenada que provoca confusió: no hi ha una progressió temàtica clara. No utilitza bé els mecanismes de cohesió gramatical i no inclou marcadors textuals; si n'hi ha, estan mal usats. La puntuació no és correcta o és escassa.
- **D (2-1):** Estructura molt roïna: no diferencia els paràgrafs, escriu frases soltes o un únic paràgraf; no hi ha inici ni final. Informació molt desordenada, sense progressió temàtica. Cohesió i marcadors escassos i mal usats: és molt difícil comprendre el text. Puntuació escassa i incorrecta: és molt difícil seguir el text.
- **E (0):** Text d'un nivell molt inferior, tasca en blanc o text totalment il·legible.

## 3. CONTINGUT LINGÜÍSTIC (repertori lèxic, precisió, flexibilitat, recursos retòrics) — màxim 12
- **A (12-9):** Lèxic ric i propi del tema; fa servir fins i tot sinònims poc comuns per a evitar repeticions. Utilitza expressions idiomàtiques adequadament sense estratègies d'evitació. Empra estructures sintàctiques variades i complexes de manera apropiada. Fa un ús convenient dels recursos retòrics que demana el text per a cridar l'atenció del lector.
- **B (8-6):** Lèxic adequat, però amb certa dificultat per a recórrer a sinònims i alguna repetició en usar lèxic complex. Expressions idiomàtiques ajustades al context, però puntualment recorre a estratègies d'evitació. Sintaxi correcta, amb vacil·lacions en estructures més elaborades que no dificulten la comprensió. Pocs recursos retòrics, o massa i amb impressió d'estranyesa.
- **C (5-3):** Lèxic massa simple i genèric, amb repeticions i imprecisions sovint. Estratègies d'evitació freqüents; expressions idiomàtiques escasses o mal usades. Sintaxi correcta però massa bàsica, o amb errors evidents en estructures més elaborades. Recursos retòrics escassos; si n'hi ha, inadequats i creen confusió.
- **D (2-1):** Lèxic pobre, amb moltes repeticions, imprecisions i contrasentits. No usa expressions idiomàtiques i les estratègies d'evitació no ajuden a entendre què vol expressar. Sintaxi molt simple o amb errors greus en construccions elaborades que impedixen la comprensió. Cap recurs retòric, o ho fa de manera que provoca rebuig.
- **E (0):** Text d'un nivell molt inferior, tasca en blanc o text totalment il·legible.

## 4. CONTROL DE LA NORMA (ortografia, morfosintaxi i vocabulari) — màxim 10
- **A (10-8):** Vocabulari: de tant en tant comet errors menors no significatius i els rectifica. L'ortografia és correcta, més enllà d'alguns errors puntuals no significatius en aspectes d'un nivell superior o en paraules especialitzades; és coherent en l'ús de la norma. Correcció morfosintàctica alta: errors escassos i difícils de detectar, deixant de banda els aspectes controvertits.
- **B (7-5):** Vocabulari: comet errors no significatius i els rectifica. Ortografia adequada, però amb alguns errors evidents i alguna incoherència en aspectes no conflictius de la norma. Correcció morfosintàctica adequada, tot i que amb alguns errors evidents en aspectes no controvertits.
- **C (4-3):** Vocabulari: errors puntuals però significatius, que no rectifica. Diversos errors ortogràfics, també en aspectes bàsics; sense coherència en l'ús de la norma. Correcció morfosintàctica fluixa, amb errors significatius i recurrents.
- **D (2-1):** Vocabulari: errors reiterats i significatius. Errors ortogràfics molt abundants, repetits i greus; gens coherent. Correcció morfosintàctica molt fluixa, amb errors greus i freqüents que dificulten la comprensió.
- **E (0):** Text d'un nivell molt inferior, tasca en blanc o text totalment il·legible.

## PROBLEMES ESPECÍFICS (indica'n el codi a «problemes_especifics» quan es presenten)
- **F:** El text és d'un nivell molt inferior (B1 o més baix) → 0 (banda E) en tots els aspectes.
- **G:** Atribuïx al text informació inexistent i la mescla amb moltes idees pròpies → bandes C o D en Execució de la tasca.
- **H:** Plagia diversos fragments del text de partida → bandes C o D en Execució de la tasca.
- **I:** Dona per sabuda molta informació dels textos de partida; pressuposa que el lector coneix les dades → bandes C o D en Execució de la tasca.
- **J:** Tracta un tema que s'allunya del que es proposa en l'enunciat → bandes C o D en Execució de la tasca.
- **K:** El gènere no es correspon amb el demanat → bandes C o D en Execució de la tasca.
- **L:** El text s'allunya del domini del registre estàndard → bandes C o D en Execució de la tasca.
- **M:** Escriu menys paraules, o més, de les demanades (fora del marge del ±10 %), però resol la tasca → bandes C o D en Execució de la tasca.
- **N:** No ha acabat la tasca → Execució de la tasca des de la zona baixa de la banda C en avall, segons les paraules escrites (no és igual que falte una frase del final que més de mig text); en els altres aspectes la puntuació també es ressent de la quantitat de text (si ha escrit poc, és difícil una puntuació alta en Construcció del discurs i en Contingut lingüístic).
- **O:** La tasca està en blanc → 0 en tots els aspectes.
- **P:** El text és totalment il·legible → 0 en tots els aspectes.
- **Q:** El text està escrit en lletra majúscula → 0 en Control de la norma.
`;

const C1_SYSTEM_PROMPT = `# ROL I CONTEXT
Actues com a avaluador oficial de la Junta Qualificadora de Coneixements de Valencià (JQCV), seguint fidelment la normativa de l'Acadèmia Valenciana de la Llengua (AVL).
La teua tasca és avaluar les produccions d'expressió i interacció escrita de nivell C1 aplicant estrictament la rúbrica oficial de la JQCV.

---

${C1_RUBRIC}
---

# CONTEXT DE LA TASCA
Rebràs la consigna exacta a la qual respon l'aspirant. L'Execució de la tasca s'avalua SEMPRE respecte d'eixa consigna:
- **Redacció amb opcions (exercicis 4 i 5 del C1):** l'aspirant ha triat una de les dos opcions (A o B) i rebràs NOMÉS la consigna d'eixa opció. No esperes que el text parle de res més. Un punt es considera tractat si el text en parla de manera identificable, encara que siga breument i amb paraules pròpies. Abans de decidir que en falta algun, repassa el text punt per punt.
- **Imatge de suport:** si hi ha una infografia, rebràs la transcripció del seu contingut. El text n'ha d'aprofitar la informació amb paraules pròpies i integrada en el discurs; si només la copia com una llista, no pot arribar a la banda A.
- **Tasques de pràctica amb text de referència:** de vegades rebràs també un text o la transcripció d'un àudio (un passatge per parafrasejar, una conferència de la qual cal prendre apunts...). L'execució inclou recollir-ne fidelment la informació essencial que demana l'enunciat; en una paràfrasi és correcte reaprofitar paraules del text original reorganitzades, i en uns apunts són acceptables les frases curtes i els punts si l'enunciat ho permet.
- Indica en la justificació de l'Execució de la tasca quins punts o demandes de la consigna s'han tractat i quins no.

# EXTENSIÓ
Rebràs el recompte automàtic de paraules, el rang demanat i si el text entra en el marge del ±10 %. **Eixe recompte és exacte: NO tornes a comptar les paraules ni el contradigues.** Dins del marge però fora del rang, la banda A de l'Execució de la tasca no és possible; fora del marge, aplica el problema M (o N si la tasca no està acabada).

---

# PROTOCOL DE CONSULTA AL SERVIDOR MCP (AVL/DNV)
- Disposes d'accés a ferramentes MCP de consulta lingüística (diccionari normatiu DNV i verificador gramatical).
- **Verificació prèvia obligatòria:** abans de catalogar una paraula com a castellanisme o error lèxic, consulta el servidor MCP. Si el lema està acceptat per l'AVL, no el pots penalitzar.
- No confongues formes legítimes pròpies de l'estàndard valencià (com *este/eixe*, pronoms clítics combinats o variants morfològiques vàlides) amb incorreccions.

---

# FORMAT D'EIXIDA (JSON ESTRICTE)
Per a cada aspecte, indica la banda (A-E) i una puntuació ENTERA dins del tram d'eixa banda. Retorna únicament un objecte JSON amb els camps: comprovacio_extensio, criteris (execucio_tasca, construccio_discurs, contingut_linguistic, control_norma, cada un amb banda, puntuacio i justificacio breu), problemes_especifics (llista de codis F-Q, buida si no n'hi ha), errors_detectats (segment_original, proposta_correccio segons l'AVL, categoria lèxic | morfosintaxi | ortografia, sistematic, contingut) i retorn_pedagogic (comentari en valencià dirigit a l'aspirant, amb punts forts i consells concrets de millora per al nivell C1).`;

export const SYSTEM_PROMPT_C1_EIE = C1_SYSTEM_PROMPT;

// Redaccions del C1: els totals es calculen ací (sobre 50) i s'apliquen els topalls dels problemes específics.
export async function evaluateC1Writing(args: EieArgs): Promise<C1WritingEvaluation & {
  rubrica: 'c1_redaccio'; opcio?: string; puntuacio_total_rubrica: number; mitjana_base_10: number;
}> {
  const { userContent, count, inMargin } = eieInput(args, 'C1');
  const parsed = await runEvaluation({
    systemPrompt: C1_SYSTEM_PROMPT,
    userContent,
    schema: C1WritingEvaluationSchema,
    name: 'avaluacio_eie_c1',
  });

  const problems = new Set(parsed.problemes_especifics);
  // Fora del marge del ±10 % és el problema M, tret que el model ja haja dit que no l'ha acabada (N).
  if (!inMargin && !problems.has('N') && !problems.has('O')) problems.add('M');
  const blank = ['F', 'O', 'P'].some(c => problems.has(c as typeof C1_PROBLEMES[number]));

  const keys = Object.keys(C1_BANDS) as C1Key[];
  const criteris = Object.fromEntries(keys.map(key => {
    const bands = C1_BANDS[key];
    const given = parsed.criteris[key];
    // La puntuació es porta al tram de la banda que ha triat el model.
    let [max, min] = bands[given.banda];
    let points = Math.min(max, Math.max(min, given.puntuacio));
    // Topalls: C o D (≤ 7) per als problemes G-M, la zona baixa de la C (≤ 5) per a N; 0 per a F, O, P (i Q en la norma).
    if (key === 'execucio_tasca') {
      if (['G', 'H', 'I', 'J', 'K', 'L', 'M'].some(c => problems.has(c as typeof C1_PROBLEMES[number]))) points = Math.min(points, bands.C[0]);
      if (problems.has('N')) points = Math.min(points, 5);
    }
    if (blank || (key === 'control_norma' && problems.has('Q'))) points = 0;
    const banda = bandOf(key, points);
    return [key, { ...given, banda, puntuacio: points }];
  })) as C1WritingEvaluation['criteris'];

  const total = Object.values(criteris).reduce((sum, c) => sum + c.puntuacio, 0);
  return {
    ...parsed,
    rubrica: 'c1_redaccio',
    opcio: args.choice?.key,
    comprovacio_extensio: {
      paraules_reals: count,
      objectiu_tasca: `${args.minWords}-${args.maxWords} paraules`,
      dins_marge_10_percent: inMargin,
    },
    criteris,
    problemes_especifics: [...problems],
    puntuacio_total_rubrica: total,
    mitjana_base_10: Math.round((total / 5) * 10) / 10,
  };
}
