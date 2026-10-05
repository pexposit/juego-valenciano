import OpenAI from 'openai';
import type { ChatCompletionMessageParam } from 'openai/resources/chat/completions';
import { zodResponseFormat } from 'openai/helpers/zod';
import { z } from 'zod';
import { countWords, usedRequiredWords } from '@parlaval/shared';
import { getMcpTools } from './subagentErrorDetector.js';

// Avaluadors de l'Àrea 3 (Expressió i Interacció Escrites) dels exàmens de la
// JQCV amb la rúbrica oficial de cada nivell: el formulari de l'A1 i la redacció
// de l'A2. Fan servir les mateixes eines MCP (DNV, softvalencia, apertium) que
// el detector d'errors.

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
  const request = () => client.chat.completions.parse({
    model: MODEL_NAME,
    messages,
    tools: tools.length > 0 ? tools : undefined,
    response_format: zodResponseFormat(args.schema, args.name),
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
  console.log(`[exam-eval] ${args.name}: ${Date.now() - tStart}ms`);

  const parsed = choice?.message?.parsed;
  if (!parsed) throw new Error("El model no ha retornat una avaluació vàlida");
  return parsed;
}

export async function evaluateA1Writing(args: {
  instructions: string;
  fields: string[];
  answers: Record<string, string>;
}): Promise<A1WritingEvaluation & { rubrica: 'a1_formulari' }> {
  // Els camps en blanc també s'envien: l'adequació depén de si s'ha completat la tasca.
  const form = args.fields
    .map(field => `- ${field}: ${args.answers[field]?.trim() || '(en blanc)'}`)
    .join('\n');

  const parsed = await runEvaluation({
    systemPrompt: SYSTEM_PROMPT_A1_EIE,
    userContent: `Consigna de l'exercici 7:\n${args.instructions}\n\nFormulari omplit per l'aspirant:\n${form}`,
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
  })),
  retorn_pedagogic: z.string(),
});

export type B1WritingEvaluation = z.infer<typeof B1WritingEvaluationSchema>;

export const SYSTEM_PROMPT_B1_EIE = `# ROL I CONTEXT
Actues com a avaluador oficial de la Junta Qualificadora de Coneixements de Valencià (JQCV), seguint fidelment la normativa de l'Acadèmia Valenciana de la Llengua (AVL).
La teua tasca és avaluar les produccions d'expressió i interacció escrita de nivell B1 aplicant estrictament la rúbrica oficial de competències comunicatives.

---

# RÚBRICA D'AVALUACIÓ OFICIAL (NIVELL B1)
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

---

# CONTEXT DE LA TASCA
Rebràs la consigna exacta a la qual respon l'aspirant. L'objectiu de la tasca s'avalua SEMPRE respecte d'eixa consigna:
- **Exercici 6 (redacció amb opcions):** l'aspirant ha triat una de les dos opcions (A o B) i rebràs NOMÉS la consigna d'eixa opció: la situació comunicativa i els punts que ha de desenvolupar. Avalua l'Adequació exclusivament respecte d'eixa consigna; no n'hi ha cap altra i no has d'esperar que el text parle de res més.
  - L'objectiu es complix si el text respon a eixa situació (gènere textual, destinatari i registre: correu, blog, entrada web...) i tracta tots els punts indicats.
  - Un punt es considera tractat si el text en parla de manera identificable, encara que siga breument i amb paraules pròpies: no cal que en repetisca la formulació ni que el desenvolupe en profunditat.
  - Només si falta del tot algun punt, o el text no respon a la situació, l'ítem «objectiu» NO es complix. Abans de decidir-ho, repassa el text punt per punt.
- **Exercici 7 (text a partir d'un enunciat):** l'objectiu es complix si el text respon a la situació i a totes les demandes de l'enunciat (gènere textual, destinatari, registre i continguts que es demanen). Quan l'enunciat demana tindre en compte una imatge, rebràs la transcripció del seu contingut: el text ha d'aprofitar-ne la informació (per exemple, incorporant alguns dels consells o dades, amb paraules pròpies i integrats en el discurs, no copiats com una llista). Si no n'aprofita res, l'ítem «objectiu» de l'Adequació NO es complix; si només copia la infografia sense elaboració, no pot tindre 10 en Adequació.
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
  "retorn_pedagogic": "Comentari en valencià dirigit a l'aspirant, subratllant punts forts i consells concrets de millora per al nivell B1."
}
\`\`\``;

export async function evaluateB1Writing(args: {
  exerciseN: number;
  instructions: string;
  choice?: { key: string; text: string; points?: string[] };
  imageText?: string; // contingut de la imatge de suport (exercici 7)
  sourceText?: string; // text o transcripció de l'àudio de referència (pràctica)
  text: string;
  minWords: number;
  maxWords: number;
}): Promise<B1WritingEvaluation & { rubrica: 'b1_redaccio'; opcio?: string }> {
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
  ].join('\n\n');
  // EXAM_EVAL_DEBUG=1 mostra al log exactament què rep l'avaluador.
  if (process.env.EXAM_EVAL_DEBUG) console.log(`[exam-eval] Entrada B1:\n${userContent}`);

  const parsed = await runEvaluation({
    systemPrompt: SYSTEM_PROMPT_B1_EIE,
    userContent,
    schema: B1WritingEvaluationSchema,
    name: 'avaluacio_eie_b1',
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
    rubrica: 'b1_redaccio',
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
