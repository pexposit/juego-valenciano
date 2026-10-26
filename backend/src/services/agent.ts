import { z } from 'zod';
import type { ScenarioDefinition } from './scenarios.js';
import { consultarGnv, gnvContext, type GnvResultat, type GnvRule } from './gnvRag.js';
import { conjugationContext, consultarConjugacioVerb, type VerbConjugation } from './conjugacio.js';
import { OWN_PATH_TOPIC_MAX, type StudyPathRef } from '@parlaval/shared';
import { guardedFetch, NO_CACHE_HEADER } from './openaiGuard.js';
import { detectPromptLeak, LEAK_REPLY } from './outputGuard.js';
import { createLoopGuard, type LoopGuard } from './loopGuard.js';
import { reasoningEffortFor, type ReasoningEffort } from './reasoningEffort.js';



const outputSchema = z.object({
  reply_text: z.string().min(1),
  mood: z.enum(['neutral', 'content', 'confus']),
  // Només amb `extraInstructions` (tutor infantil): la mateixa idea en la llengua materna del xiquet.
  help_text: z.string().optional(),
  // Tutor: la consulta per a la GNV que ha decidit fer el model (buida si no és de normativa).
  consulta_gnv: z.string().optional(),
  // Tutor: el verb (en infinitiu) del qual l'aprenent demana la conjugació ('' si no en demana cap).
  verb_conjugar: z.string().optional(),
  // Tutor: l'aprenent ha enviat un text perquè el corregisca; la llista d'errors la dóna l'anàlisi, no esta resposta.
  corregir_text: z.boolean().optional(),
  // Tutor: el tema de l'exercici del catàleg que vol oferir ('' si no n'ofereix cap).
  exercici_tema: z.string().optional(),
  // Tutor: tipus de la pregunta de l'aprenent; decidix si es pot mostrar un exercici i amb quin rigor.
  tipus_dubte: z.enum(['cap', 'simple', 'complex', 'demana_exercici']).optional(),
  // Tutor: la destresa que l'aprenent vol millorar i que no es pot practicar dins del xat ('' si no n'hi ha cap).
  area_practica: z.string().optional(),
  // Tutor del Nivell 0: la lliçó de l'app relacionada amb la pregunta ('' si no n'hi ha cap).
  leccio_id: z.string().optional(),
  // Tutor: rutes d'aprenentatge. La ruta que vol obrir (codi de la llista, '' si cap), el que diu que li costa ('' si
  // res) i, si hi havia una oferta de ruta pendent, si l'accepta.
  ruta_id: z.string().optional(),
  ruta_dificultat: z.string().optional(),
  ruta_acceptada: z.boolean().optional(),
  // Només quan el tutor ha consultat la GNV i hi ha trobat respaldo.
  gnv: z.object({
    fonts: z.array(z.number().int()),
    contingut: z.string().min(1),
    explicacio: z.string().min(1),
  }).optional(),
});

// Què vol fer l'aprenent amb les rutes: obrir-ne una (`path`), rebre l'oferta d'una de nova sobre el que li costa
// (`offer`, el tema) o acceptar l'oferta pendent (`accepted`).
export type TutorRouteIntent = { path?: StudyPathRef; offer?: string; accepted?: boolean };

export type AgentReply = Omit<z.infer<typeof outputSchema>, 'gnv' | 'help_text' | 'consulta_gnv' | 'verb_conjugar' | 'ruta_id' | 'ruta_dificultat' | 'ruta_acceptada'> & { gnv?: GnvRule; conjugacio?: VerbConjugation; ruta?: TutorRouteIntent };

// Cadena de models: el principal (OPENAI_MODEL) i dos de reserva per si falla.
// El nom ha d'existir a OpenAI: un valor inventat gasta dos intents (404) en
// cada torn abans de passar al model de reserva.
// El tutor del tauler va fix amb este model i este esforç de raonament: mai un altre (gpt-4o, models de reserva...).
export const DASHBOARD_AGENT = { model: 'gpt-6-luna', reasoningEffort: 'low' } as const satisfies { model: string; reasoningEffort: ReasoningEffort };

const OPENAI_MODELS = [
  process.env.OPENAI_MODEL
].filter((model, index, models) => models.indexOf(model) === index);

// Límite por petición: si un modelo cuelga, se corta y se prueba el siguiente
// en lugar de esperar indefinidamente. Ajustable con OPENAI_TIMEOUT_MS.
const OPENAI_TIMEOUT_MS = Number(process.env.OPENAI_TIMEOUT_MS) || 30_000;

// Tutor: el model decidix si el missatge és un dubte de normativa i, si ho és, escriu la consulta
// per a la GNV (RAG). Es fa amb un camp de la resposta estructurada i no amb una eina (function
// calling) perquè no tots els models de raonament admeten eines en /chat/completions.
const GNV_QUERY_DESCRIPTION =
  "Si l'últim missatge de l'aprenent és un dubte de normativa del valencià (pronunciació, ortografia, accentuació, " +
  'dièresi, apostrofació, guionet, puntuació, majúscules, morfologia —gènere, plural, articles, pronoms, possessius, ' +
  'numerals, verbs i conjugació—, sintaxi, preposicions, adverbis, conjuncions o formació de paraules), la pregunta ' +
  'reescrita en valencià per a buscar-la en la Gramàtica Normativa Valenciana: anomena el fenomen gramatical amb ' +
  "terminologia general i conserva les paraules clau de l'aprenent. Exemples: \"Quan s'escriu la ç?\" -> " +
  "\"regles d'ús de la grafia ç, c trencada\"; \"Es diu 'la casa seua' o 'la seua casa'?\" -> \"posició del possessiu " +
  'en el sintagma nominal, la casa seua i la seua casa". Cadena buida si NO és un dubte de normativa (salutació, ' +
  "conversa, significat o traducció d'una paraula, cultura, consells d'estudi...).";

const CORRECT_TEXT_DESCRIPTION =
  "true només si l'últim missatge de l'aprenent és un text seu (diverses frases) que et demana corregir o revisar; false en un dubte puntual, una pregunta o una conversa.";

const GNV_INSTRUCTIONS = `CONSULTA DE LA GRAMÀTICA NORMATIVA VALENCIANA (GNV):
- Si l'aprenent pregunta un dubte de normativa (com es pronuncia, com s'escriu, quan porta accent, com es forma el plural o el femení, com es conjuga, quina preposició o pronom va...), omple consulta_gnv: després rebràs la regla oficial de la GNV per a respondre-la.
- Si l'aprenent t'envia un text (diverses frases seues) perquè el corregisques o el revises, posa corregir_text a true i deixa consulta_gnv buida: l'aplicació li mostrarà després la llista completa d'errors. En eixe cas, en reply_text escriu només una frase curta dient que revises el text i que ara li mostres els errors, sense corregir res ni citar cap regla.
- Si no és un dubte de normativa, deixa consulta_gnv buida i respon directament.`;

// Tutor: si l'aprenent demana la conjugació d'un verb concret, el model n'escriu l'infinitiu i l'aplicació la consulta
// al DNV (ferramenta consultar_conjugacio del MCP). Com la GNV, és un camp de la resposta estructurada i no una eina.
const VERB_QUERY_DESCRIPTION =
  "Si l'últim missatge de l'aprenent demana la conjugació (o les formes, o un temps) d'un verb concret, eixe verb en " +
  'infinitiu, en minúscules i sense pronoms ("Com es conjuga anar?" -> "anar"; "el present de rentar-se" -> "rentar"; ' +
  '"conjugació de vindre" -> "vindre"; "com és el passat de fer?" -> "fer"). Cadena buida si no demana la conjugació ' +
  "d'un verb concret (dubtes generals sobre verbs, salutació, conversa...).";

const CONJUGATION_INSTRUCTIONS = `CONJUGACIÓ DE VERBS (DICCIONARI NORMATIU VALENCIÀ):
- Si l'aprenent demana com es conjuga un verb concret (o un temps o les formes d'un verb concret), omple verb_conjugar amb el verb en infinitiu i sense pronoms: després rebràs la conjugació oficial del DNV i l'aplicació li mostrarà la taula completa. En eixe cas deixa consulta_gnv buida.
- Per a dubtes generals sobre els verbs (com es formen els temps, quan s'usa un temps...) deixa verb_conjugar buit.`;

// Tutor: les rutes d'aprenentatge que pot obrir l'aprenent (codis curts r1, r2...: el model copia malament els UUID) i,
// si en el torn anterior se li va oferir preparar-ne una, el tema de l'oferta.
const routeCode = (i: number) => `r${i + 1}`;

const routeInstructions = (paths: StudyPathRef[], pendingOffer?: string) => `RUTES D'APRENENTATGE:
${paths.length ? `- Rutes que l'aprenent pot obrir (codi: títol — descripció):
${paths.map((p, i) => `  ${routeCode(i)}: ${p.title}${p.description ? ` — ${p.description.slice(0, 160)}` : ''}`).join('\n')}
- Si l'aprenent demana practicar o obrir una ruta concreta (pel nom) o una ruta que treballe un tema, omple ruta_id amb el codi de la que millor hi encaixe i en reply_text digues només una frase curta que la presente (p. ex. «Ací tens la ruta «Títol».»): l'aplicació li mostrarà l'enllaç. Si cap no hi encaixa, deixa ruta_id buit, digues-li que no en tens cap d'eixe tema i omple ruta_dificultat amb el tema (l'aplicació li oferirà preparar-ne una).` : `- L'aprenent encara no té cap ruta per a obrir. Si en demana una d'un tema, digues-li que no en té cap i omple ruta_dificultat amb el tema (l'aplicació li oferirà preparar-ne una).`}
- Si l'aprenent diu que li costa molt alguna cosa de la llengua, que no l'entén o que sempre s'hi equivoca (p. ex. «em costen molt els pronoms febles», «no entenc mai quan va accent»), omple ruta_dificultat amb eixe tema, en valencià i normalitzat (1 a 5 paraules, com el nom d'una lliçó: "pronoms febles", "accentuació"). En reply_text anima'l breument i, si cal, respon-li el dubte; NO li preguntes si vol una ruta: l'aplicació li ho pregunta davall de la teua resposta. Per a un dubte puntual sense dificultat expressa, deixa ruta_dificultat buit.${pendingOffer ? `
- En el torn anterior li vas oferir preparar-li una ruta sobre «${pendingOffer}». Si l'últim missatge accepta l'oferta (sí, d'acord, vale, prepara-la...), posa ruta_acceptada a true i en reply_text digues només una frase curta (p. ex. «Perfecte! Te la prepare ara mateix.»): l'aplicació la prepararà. Si la rebutja o parla d'una altra cosa, posa ruta_acceptada a false i respon normalment.` : ''}`;

const EXERCISE_INSTRUCTIONS = `EXERCICIS DEL CATÀLEG:
- Mai no t'inventes exercicis: l'aplicació en mostra un de real del catàleg dins del xat, si n'hi ha, quan omples exercici_tema.
- Classifica l'últim missatge de l'aprenent en tipus_dubte:
  * 'complex': dubte de llengua que demana una regla o una explicació amb matisos (normativa, accentuació, ortografia, gramàtica, verbs, pronoms, preposicions, diferències entre formes...).
  * 'simple': dubte de llengua puntual i ràpid d'una sola resposta (significat o traducció d'una paraula, com es diu una cosa, confirmar una forma).
  * 'demana_exercici': l'aprenent demana expressament practicar o fer un exercici.
  * 'cap': salutació, xarrada, cultura, consells d'estudi o res de llengua.
- Només en 'complex' i 'demana_exercici' l'aprenent pot veure un exercici; en 'simple' només si n'hi ha un molt estretament relacionat amb el que pregunta (el sentit de la pregunta, no les paraules amb què l'escriu). Per tant, no t'esforces a buscar un exercici per a dubtes simples.
- Si tipus_dubte és 'complex', 'simple' o 'demana_exercici', omple exercici_tema amb el concepte de llengua que s'ha de practicar, ja normalitzat (1 a 3 paraules en valencià, com el nom d'una lliçó: "accentuació", "pronoms febles", "verbs", "plurals"), no amb les paraules literals de l'aprenent. Si és 'cap', deixa'l buit. NO mencions l'exercici en reply_text (excepte en 'demana_exercici'): pot ser que no n'hi haja cap.
- Si l'aprenent demana practicar o fer un exercici (tipus_dubte 'demana_exercici'), en reply_text digues només una frase curta que presente l'exercici (p. ex. «Prova este exercici!»).
- Mai no t'inventes escenaris (ni noms, ni situacions, ni activitats de conversa): només l'aplicació n'enllaça un de real del catàleg quan omples area_practica amb 'escenari'. No en descrigues ni en proposes cap pel teu compte en reply_text. Si el que vol practicar és la conversa o l'expressió oral (area_practica 'escenari' o 'expressio_oral'), reply_text no pot quedar buit: escriu només una frase curta («Et deixe una activitat per a practicar la conversa.»), sense consells, situacions, diàlegs ni exemples de rol (l'aplicació la substituïx per la seua).
- Si l'aprenent demana com millorar o practicar una DESTRESA que no es pot fer dins del xat (redactar o escriure textos → expressio_escrita; entendre àudios → comprensio_oral; entendre textos escrits → comprensio_escrita; practicar la conversa, xarrar o fer un escenari → escenari; parlar en veu alta o millorar la pronunciació → expressio_oral), omple area_practica amb eixa àrea, dóna-li 2 o 3 consells breus i diu-li que li deixes una activitat per a practicar-ho (l'aplicació l'enllaçarà). En eixe cas deixa exercici_tema buit. Si no, deixa area_practica buit.`;

type ChatMessage = { role: 'system' | 'user' | 'assistant'; content: string };

const PRACTICE_SKILLS = ['expressio_escrita', 'comprensio_oral', 'comprensio_escrita', 'expressio_oral', 'escenari'] as const;

// Els objectius de l'escenari (metadata.objectius) arriben al prompt del personatge: la conversa s'ha de centrar a complir-los.
const objectivesInstructions = (objectius: string[]) => `OBJECTIUS DE L'ESCENARI (la conversa s'ha de centrar a aconseguir-los):
${objectius.map((o, i) => `${i + 1}. ${o}`).join('\n')}
- La teua missió com a personatge és portar l'aprenent, de manera natural i pas a pas, a complir TOTS estos objectius. Tot el que digues ha d'encaminar la conversa cap a algun objectiu encara pendent.
- Segons el que ja s'ha dit en la conversa, decidix quins objectius ja s'han complit i quins falten, i centra't en el següent pendent, d'un en un. No repetisques els que ja s'han complit.
- Planteja els objectius amb preguntes i situacions pròpies de l'escenari: no els amolles com una llista ni dius la paraula «objectiu».
- Si l'aprenent s'allunya del tema, respon-li amb amabilitat en una frase breu i torna a l'objectiu pendent. No obris temes nous que no ajuden a complir-los.
- Quan s'hagen complit tots, tanca la situació amb naturalitat i acomiada't.`;

export type LessonRef = { id: string; title: string; summary: string };

const lessonInstructions = (lessons: LessonRef[]) => `LLIÇONS DE L'APP:
- Si el que pregunta o diu el xiquet té relació amb alguna d'estes lliçons, omple leccio_id amb el seu id i digues-li, en una frase molt curta i amb paraules senzilles, que li deixes la lliçó. Només una, la més adequada. Si cap no té relació, deixa leccio_id buit. Mai no t'inventes lliçons ni ids.
${lessons.map(l => `- ${l.id}: ${l.title}${l.summary ? ` (${l.summary})` : ''}`).join('\n')}`;

function replySchema(withHelp: boolean, withGnv: boolean, askGnvQuery = false, askExercise = false, lessons: LessonRef[] = [], askVerb = false, routes?: { count: number; pending: boolean }) {
  return {
    type: 'json_schema',
    json_schema: {
      name: 'agent_reply',
      strict: true,
      schema: {
        type: 'object',
        properties: {
          ...(withHelp ? {
            help_text: {
              type: 'string',
              description: "La mateixa idea que reply_text, explicada breument en la llengua materna de l'aprenent (traducció de les paraules noves inclosa).",
            },
          } : {}),
          mood: {
            type: 'string',
            enum: ['neutral', 'content', 'confus'],
            description: "L'estat d'ànim del personatge.",
          },
          reply_text: {
            type: 'string',
            description: 'La resposta directa del personatge a la conversa.',
          },
          ...(askGnvQuery ? { consulta_gnv: { type: 'string', description: GNV_QUERY_DESCRIPTION } } : {}),
          ...(askVerb ? { verb_conjugar: { type: 'string', description: VERB_QUERY_DESCRIPTION } } : {}),
          ...(askGnvQuery ? { corregir_text: { type: 'boolean', description: CORRECT_TEXT_DESCRIPTION } } : {}),
          ...(routes?.count ? { ruta_id: { type: 'string', enum: ['', ...Array.from({ length: routes.count }, (_, i) => routeCode(i))], description: "El codi de la ruta d'aprenentatge que l'aprenent vol obrir; cadena buida si no en demana cap." } } : {}),
          ...(routes ? { ruta_dificultat: { type: 'string', description: "El tema de la llengua que l'aprenent diu que li costa molt (1 a 5 paraules, normalitzat); cadena buida si no en diu cap." } } : {}),
          ...(routes?.pending ? { ruta_acceptada: { type: 'boolean', description: "true si l'últim missatge accepta l'oferta de preparar-li una ruta; false si no." } } : {}),
          ...(lessons.length ? { leccio_id: { type: 'string', enum: ['', ...lessons.map(l => l.id)], description: "L'id de la lliçó de l'app relacionada amb la pregunta del xiquet; cadena buida si no n'hi ha cap." } } : {}),
          ...(askExercise ? { area_practica: { type: 'string', enum: ['', ...PRACTICE_SKILLS], description: "La destresa que l'aprenent vol practicar si no es pot fer dins del xat; cadena buida si no n'hi ha cap." } } : {}),
          ...(askExercise ? { tipus_dubte: { type: 'string', enum: ['cap', 'simple', 'complex', 'demana_exercici'], description: "Tipus de l'últim missatge de l'aprenent: dubte de llengua complex, dubte simple, petició d'exercici o res de llengua ('cap')." } } : {}),
          ...(askExercise ? { exercici_tema: { type: 'string', description: "Tema de l'exercici del catàleg que ofereixes a l'aprenent; cadena buida si no n'ofereixes cap." } } : {}),
          ...(withGnv ? {
            gnv: {
              type: 'object',
              description: 'La regla de la GNV que respon la pregunta.',
              properties: {
                fonts: {
                  type: 'array',
                  items: { type: 'integer' },
                  description: "Els ids de les fonts (<font id=...>) que has fet servir: primer la que respon directament la pregunta i després les que la completen (el cas contrari, excepcions...).",
                },
                contingut: {
                  type: 'string',
                  description: 'La regla completa tal com la diu la norma, fidel a les fonts: quan s\'aplica, quin és el cas contrari i les excepcions o observacions que hi afecten.',
                },
                explicacio: {
                  type: 'string',
                  description: "La regla explicada per a un estudiant que no sap gramàtica, sense tecnicismes, en punts curts que comencen per «• »: per què la seua paraula és així, el cas contrari, més exemples i un truc.",
                },
              },
              required: ['fonts', 'contingut', 'explicacio'],
              additionalProperties: false,
            },
          } : {}),
        },
        required: [...(withHelp ? ['help_text'] : []), 'mood', 'reply_text', ...(askGnvQuery ? ['consulta_gnv', 'corregir_text'] : []), ...(askVerb ? ['verb_conjugar'] : []), ...(askExercise ? ['tipus_dubte', 'exercici_tema', 'area_practica'] : []), ...(lessons.length ? ['leccio_id'] : []), ...(routes?.count ? ['ruta_id'] : []), ...(routes ? ['ruta_dificultat'] : []), ...(routes?.pending ? ['ruta_acceptada'] : []), ...(withGnv ? ['gnv'] : [])],
        additionalProperties: false,
      },
    },
  };
}

// Una petició a chat/completions; retorna el contingut de la resposta.
// `fresh`: en un reintent no es llig la cache (la resposta anterior ha fallat) i la nova no la substituïx fins que es valide.
async function complete(
  guard: LoopGuard, key: string, model: string, body: Record<string, unknown>, fresh = false, effort: ReasoningEffort = 'none',
): Promise<string | null | undefined> {
  // L'últim missatge enviat: si és el mateix una vegada i una altra, el model no avança.
  const last = (body.messages as { content?: unknown }[] | undefined)?.at(-1)?.content;
  guard.llmCall(typeof last === 'string' ? last : JSON.stringify(last ?? ''));
  const response = await guardedFetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${key}`,
      'Content-Type': 'application/json',
      ...(fresh ? { [NO_CACHE_HEADER]: '1' } : {}),
    },
    signal: AbortSignal.any([AbortSignal.timeout(OPENAI_TIMEOUT_MS), guard.signal]),
    // Amb l'esforç per defecte, gpt-6-luna dedicava ~1200 tokens a pensar la resposta amb la regla de la GNV (~15 s de
    // 21); sense raonament, la regla i l'explicació són igual de correctes. Qui crida tria l'esforç de cada crida.
    body: JSON.stringify({ model, ...reasoningEffortFor(model, effort), ...body }),
  });
  if (!response.ok) throw new Error(`OpenAI API error (${model}): ${response.status}`);
  const payload = (await response.json()) as { choices?: { message?: { content?: string | null } }[] };
  return payload.choices?.[0]?.message?.content;
}

// Resultat de la GNV per al LLM, en un missatge final abans de demanar-li la resposta.
function gnvSourcesMessage(consulta: string, resultat: GnvResultat | null): string {
  const intro = `Has consultat la Gramàtica Normativa Valenciana amb: "${consulta}".`;
  if (!resultat) {
    return `${intro} La consulta no està disponible ara mateix. Respon amb prudència, sense citar cap regla, i no inventes normativa.`;
  }
  if (!resultat.hay_respaldo) {
    return `${intro} Resultat: ${resultat.mensaje} Digues-li a l'aprenent, amb naturalitat, que no ho has trobat a la Gramàtica Normativa Valenciana; si ho saps, orienta'l amb prudència, sense inventar cap regla.`;
  }
  return `${intro} Fonts trobades (de més a menys rellevant):

${gnvContext(resultat)}

Respon ara l'últim missatge de l'aprenent NOMÉS amb el que diuen estes fonts, en text pla (sense Markdown ni asteriscs; per a citar paraules usa cometes «»):
- reply_text: resposta breu i directa a la pregunta (1-2 frases), com a professor i en paraules senzilles, sense tecnicismes.
- gnv.fonts: els ids de les fonts que fas servir; primer la que respon la pregunta i després les que la completen.
- gnv.contingut: el que diu la norma, complet i fidel a les fonts (3-5 frases). No et quedes amb la meitat de la regla: si la norma depén d'un contrast (so sord / so sonor, tònica / àtona, davant de vocal / de consonant...), explica els dos casos, i afig les excepcions o observacions que hi afecten. No digues que una cosa passa "sempre" si les fonts diuen que depén d'alguna condició.
- gnv.explicacio: la regla explicada com un bon professor a un estudiant que no sap gramàtica, siga quin siga el seu nivell (ací NO apliques les pautes de nivell sobre terminologia o registre):
  - Paraules del dia a dia i frases curtes. Res de tecnicismes (alveolar, fricatiu, sord, sonor, àton, sintagma...): si un és imprescindible, explica'l amb una comparació senzilla (p. ex. sord = «sona fort, com una serp: sss»; sonor = «sona suau i vibra, com una abella: zzz»).
  - Escriu-la en 3-5 punts curts, cada un en una línia que comence per «• »:
    • per què la paraula de l'aprenent s'escriu (o es diu) així;
    • què passaria en el cas contrari, amb un parell de paraules que es diferencien només en això si n'hi ha (p. ex. «casa» / «cassa»);
    • 2-3 exemples més, molt comuns;
    • un truc pràctic per a encertar-ho la pròxima vegada.
  - Simplificar NO vol dir llevar la condició que decidix la regla: si depén del so (com sona la s, si la e és oberta o tancada...), explica com distingir-ho amb la comparació senzilla. Abans d'escriure el truc, comprova'l amb l'exemple del cas contrari: ha d'encertar en els dos (p. ex. un truc per a la ss ha de funcionar amb «cassa» i també amb «casa»).`;
}

// El model ha detectat un text per a corregir (la llista d'errors la mostra el client amb l'anàlisi).
function correctTextOf(content: string): boolean {
  try {
    return (parseJsonResponse(content) as { corregir_text?: unknown }).corregir_text === true;
  } catch {
    return false;
  }
}

// Conjugació del DNV per al LLM, en un missatge final abans de demanar-li la resposta.
// `undefined`: la consulta ha fallat; `null`: el DNV no té la conjugació d'eixe verb.
function conjugationMessage(verb: string, conjugation: VerbConjugation | null | undefined): string {
  const intro = `Has consultat la conjugació del verb «${verb}» en el Diccionari Normatiu Valencià (DNV) de l'AVL.`;
  if (conjugation === undefined) {
    return `${intro} La consulta no està disponible ara mateix. Digues-li a l'aprenent, amb naturalitat, que ara no pots mostrar-li la conjugació i que ho torne a provar d'ací a un moment; no t'inventes formes verbals.`;
  }
  if (conjugation === null) {
    return `${intro} No l'has trobada: pot ser que no siga un verb o que no estiga escrit en infinitiu. Digues-li-ho amb naturalitat i demana-li el verb en infinitiu; no t'inventes formes verbals.`;
  }
  return `${intro} Esta és la conjugació oficial:

${conjugationContext(conjugation)}

L'aplicació mostrarà la taula completa davall de la teua resposta. Respon ara l'últim missatge de l'aprenent en text pla (sense Markdown ni asteriscs; per a citar paraules usa cometes «»):
- reply_text: 1-3 frases breus. Presenta la conjugació (p. ex. «Ací tens la conjugació del verb «anar».») i, si ha preguntat per un temps o una forma concreta, respon-ho directament. Si el verb és irregular, destaca una o dues formes que solen costar. No copies la taula sencera i usa NOMÉS formes que apareguen en la conjugació de dalt.`;
}

// Què vol fer l'aprenent amb les rutes, segons la primera resposta del tutor (la segona, amb la GNV o la conjugació, ja
// no ho torna a preguntar). Acceptar l'oferta pendent té preferència; després, obrir una ruta; si no, oferir-ne una.
function routeIntentOf(content: string, paths: StudyPathRef[], pendingOffer?: string): TutorRouteIntent | undefined {
  try {
    const value = parseJsonResponse(content) as { ruta_id?: unknown; ruta_dificultat?: unknown; ruta_acceptada?: unknown };
    if (pendingOffer && value.ruta_acceptada === true) return { accepted: true };
    const code = typeof value.ruta_id === 'string' ? value.ruta_id : '';
    const path = paths.find((_, i) => routeCode(i) === code);
    if (path) return { path };
    const offer = typeof value.ruta_dificultat === 'string' ? value.ruta_dificultat.trim().slice(0, OWN_PATH_TOPIC_MAX) : '';
    return offer ? { offer } : undefined;
  } catch {
    return undefined;
  }
}

// Un camp de text de la primera resposta del tutor ('' si no n'hi ha o no es pot llegir).
function queryFieldOf(content: string, field: 'consulta_gnv' | 'verb_conjugar', max: number): string {
  try {
    const value = (parseJsonResponse(content) as Record<string, unknown>)[field];
    return typeof value === 'string' ? value.trim().slice(0, max) : '';
  } catch {
    return '';
  }
}

// Les fonts de la GNV porten èmfasi Markdown (conv**e**ni): el xat i el TTS mostren text pla.
const plain = (text: string) => text.replace(/\*+/g, '').trim();

function gnvRuleFrom(resultat: GnvResultat, gnv: NonNullable<z.infer<typeof outputSchema>['gnv']>): GnvRule {
  // Fonts usades, sense ids inexistents ni repetits; si no n'hi ha cap de vàlida, la més rellevant.
  const used = [...new Set(gnv.fonts)].map((id) => resultat.fuentes[id - 1]).filter(Boolean);
  const [main, ...rest] = used.length ? used : [resultat.fuentes[0]];
  // Una secció llarga pot vindre partida en dos fonts: es cita una vegada amb tot el text.
  const related = new Map<string, { regla: string; seccio: string; ruta: string; text: string }>();
  for (const font of rest) {
    if (font.etiqueta === main.etiqueta) continue;
    const prev = related.get(font.etiqueta);
    if (prev) prev.text = `${prev.text}\n\n${plain(font.texto)}`;
    else related.set(font.etiqueta, { regla: font.etiqueta, seccio: font.seccion, ruta: font.ruta, text: plain(font.texto) });
  }
  return {
    regla: main.etiqueta,
    seccio: main.seccion,
    ruta: main.ruta,
    contingut: plain(gnv.contingut),
    explicacio: plain(gnv.explicacio),
    text_original: rest.filter((f) => f.etiqueta === main.etiqueta).reduce((text, f) => `${text}\n\n${plain(f.texto)}`, plain(main.texto)),
    relacionades: [...related.values()],
  };
}

export async function replyFromAgent(args: {
  scenario: Pick<ScenarioDefinition, 'character' | 'systemPrompt'> & Partial<Pick<ScenarioDefinition, 'objectius'>>;
  level: string;
  message: string;
  history: { role: string; content_text: string }[];
  // Instruccions addicionals per a esta conversa (p. ex. la llengua materna del xiquet al tutor infantil).
  extraInstructions?: string;
  // Pautes segons el nivell i el públic de l'aprenent (no activen la ajuda en la llengua materna).
  levelInstructions?: string;
  // Tutor: pot consultar la Gramàtica Normativa Valenciana (RAG) quan el missatge és un dubte de normativa.
  gnvTool?: boolean;
  // Tutor: pot mostrar la conjugació d'un verb del DNV (ferramenta consultar_conjugacio del MCP).
  conjugationTool?: boolean;
  // Tutor: pot oferir un exercici real del catàleg (exercici_tema); el resol qui crida.
  exerciseTool?: boolean;
  // Tutor del Nivell 0: les lliçons que pot enllaçar (leccio_id); les resol qui crida.
  lessons?: LessonRef[];
  // Tutor: pot portar l'aprenent a una de les seues rutes (`paths`) i oferir-li preparar-ne una de nova sobre el que li
  // costa. `pendingRouteOffer`: el tema de l'oferta del torn anterior, si encara no l'ha contestada.
  routeTool?: boolean;
  paths?: StudyPathRef[];
  pendingRouteOffer?: string;
  // Tutor del tauler: SEMPRE el model i l'esforç de DASHBOARD_AGENT, independentment d'OPENAI_MODEL i sense models de reserva.
  dashboardAgent?: boolean;
  // Cancel·lació externa (el client tanca la connexió): talla el bucle i les crides en vol.
  signal?: AbortSignal;
}): Promise<AgentReply> {
  const key = process.env.OPENAI_API_KEY;
  if (!key) throw new Error('OPENAI_API_KEY no està configurada');

  const def = args.scenario;
  const withHelp = Boolean(args.extraInstructions);
  const paths = args.routeTool ? args.paths ?? [] : [];
  const routes = args.routeTool ? { count: paths.length, pending: Boolean(args.pendingRouteOffer) } : undefined;
  const context = args.history
    .map((m) => `${m.role === 'character' ? def.character : 'Aprenent'}: ${m.content_text}`)
    .join('\n');

  const messages: ChatMessage[] = [
    {
      role: 'system',
      content: `${def.systemPrompt}

        ${def.objectius?.length ? objectivesInstructions(def.objectius) : ''}

        Nivell de referència de l'aprenent: ${args.level}.

        INSTRUCCIONS DE CONVERSA:
        - Respon de manera natural i coherent al context de la situació com a personatge.
        - Tingues sempre en compte tot el que s'ha dit abans en la conversa: continua amb el tema que l'aprenent ha triat o ha dit en l'últim missatge, no el canvies per iniciativa pròpia ni tornes a preguntar el que ja t'ha contat. Si has de canviar de tema o d'activitat, fes-ho només quan l'actual ja s'haja tractat prou i enllaça el canvi amb el que ha dit.
        - Adapta la complexitat del teu llenguatge al nivell de l'aprenent (${args.level}).
        - Si no entens què et vol dir l'aprenent (el missatge és incomprensible, sense sentit o no el pots interpretar), no t'ho inventes ni canvies de tema: respon exactament «No sé què em vols dir. Pots repetir?» i tria l'estat d'ànim 'confus'.
        - Tria l'estat d'ànim ('mood') que millor represente la teua reacció com a personatge ('neutral', 'content', 'confus').

        ${args.levelInstructions ?? ''}

        ${args.extraInstructions ?? ''}

        ${args.gnvTool ? GNV_INSTRUCTIONS : ''}

        ${args.conjugationTool ? CONJUGATION_INSTRUCTIONS : ''}

        ${args.exerciseTool ? EXERCISE_INSTRUCTIONS : ''}

        ${args.lessons?.length ? lessonInstructions(args.lessons) : ''}

        ${args.routeTool ? routeInstructions(paths, args.pendingRouteOffer) : ''}

        Respon ÚNICAMENT amb JSON vàlid amb les claus: reply_text, mood${withHelp ? ', help_text' : ''}${args.gnvTool ? ', consulta_gnv, corregir_text' : ''}${args.conjugationTool ? ', verb_conjugar' : ''}${args.exerciseTool ? ', tipus_dubte, exercici_tema, area_practica' : ''}${args.lessons?.length ? ', leccio_id' : ''}${args.routeTool ? `${paths.length ? ', ruta_id' : ''}, ruta_dificultat${args.pendingRouteOffer ? ', ruta_acceptada' : ''}` : ''}.`.trim(),
    },
    {
      role: 'user',
      content: `Context recent de la conversa:\n${context || '(inici)'}\n\nÚltim missatge de l'aprenent a analitzar i respondre:\n"${args.message}"`,
    },
  ];

  // La consulta a la GNV es fa una sola vegada encara que l'OpenAI falle i es reintente.
  const gnvLookups = new Map<string, Promise<GnvResultat | null>>();
  const lookupGnv = (consulta: string) => {
    if (!gnvLookups.has(consulta)) {
      const started = Date.now();
      gnvLookups.set(consulta, consultarGnv(consulta)
        .then((resultat) => {
          console.log(`[agent] gnv="${consulta}" respaldo=${resultat.hay_respaldo} puntuació=${resultat.mejor_puntuacion.toFixed(3)} ${Date.now() - started}ms`);
          return resultat;
        })
        .catch((error) => {
          console.warn('[agent] el RAG de la GNV ha fallat:', error instanceof Error ? error.message : error);
          return null;
        }));
    }
    return gnvLookups.get(consulta)!;
  };

  // La conjugació també es consulta una sola vegada per verb.
  const conjugationLookups = new Map<string, Promise<VerbConjugation | null | undefined>>();
  const lookupConjugation = (verb: string) => {
    if (!conjugationLookups.has(verb)) {
      const started = Date.now();
      conjugationLookups.set(verb, consultarConjugacioVerb(verb)
        .then((conjugation) => {
          console.log(`[agent] conjugació="${verb}" trobada=${Boolean(conjugation)} ${Date.now() - started}ms`);
          return conjugation;
        })
        .catch((error) => {
          console.warn('[agent] la consulta de la conjugació ha fallat:', error instanceof Error ? error.message : error);
          return undefined;
        }));
    }
    return conjugationLookups.get(verb)!;
  };

  // Detecció de bucles: massa crides o el mateix missatge una vegada i una altra talla la petició (LoopDetectedError).
  const guard = createLoopGuard({ label: 'agent', signal: args.signal, maxIterations: 8 });
  const effort = (model: string) => (args.dashboardAgent ? reasoningEffortFor(model, DASHBOARD_AGENT.reasoningEffort) : {});
  let lastError = 'OpenAI no ha retornat una resposta vàlida';
  for (const model of args.dashboardAgent ? [DASHBOARD_AGENT.model] : OPENAI_MODELS) {
    for (let attempt = 0; attempt < 2; attempt += 1) {
      try {
        // La primera crida decidix què fer (respondre, consultar la GNV, proposar exercici): un poc de raonament (low).
        // La segunda només redacta amb les fonts que ja té: sense raonament (none).
        let content = await complete(guard, key, model!, {
          ...effort(model!),
          response_format: replySchema(withHelp, false, args.gnvTool, args.exerciseTool, args.lessons, args.conjugationTool, routes),
          messages,
        }, attempt > 0, 'low');

        // L'aprenent demana la conjugació d'un verb: es consulta el DNV i es torna a demanar la resposta (té preferència
        // sobre la GNV: la taula ja respon la pregunta).
        // Rutes: es decidix amb la primera resposta, encara que després se'n demane una altra amb la GNV o la conjugació.
        const ruta = args.routeTool && content ? routeIntentOf(content, paths, args.pendingRouteOffer) : undefined;
        let conjugation: VerbConjugation | null | undefined;
        // Un text per a corregir no consulta res: la llista d'errors la mostra el client amb l'anàlisi.
        const correcting = content ? correctTextOf(content) : false;
        const verb = args.conjugationTool && content && !correcting ? queryFieldOf(content, 'verb_conjugar', 60).toLowerCase() : '';
        // El model ha decidit que és un dubte de normativa: es consulta la GNV i es torna a demanar la resposta.
        let gnvResult: GnvResultat | null = null;
        const consulta = !verb && args.gnvTool && content && !correcting ? queryFieldOf(content, 'consulta_gnv', 500) : '';
        if (verb) {
          conjugation = await lookupConjugation(verb);
          content = await complete(guard, key, model!, {
            ...effort(model!),
            response_format: replySchema(withHelp, false, false, args.exerciseTool, args.lessons),
            messages: [...messages, { role: 'system', content: conjugationMessage(verb, conjugation) }],
          }, attempt > 0);
        } else if (consulta) {
          gnvResult = await lookupGnv(consulta);
          content = await complete(guard, key, model!, {
            ...effort(model!),
            response_format: replySchema(withHelp, Boolean(gnvResult?.hay_respaldo), false, args.exerciseTool, args.lessons),
            messages: [...messages, { role: 'system', content: gnvSourcesMessage(consulta, gnvResult) }],
          }, attempt > 0);
        }

        if (!content) {
          lastError = `OpenAI (${model}) no ha retornat contingut`;
          continue;
        }
        console.log(`[agent] resposta vàlida de ${model}`);

        const { help_text, gnv, consulta_gnv: _, verb_conjugar: __, ruta_id: _r1, ruta_dificultat: _r2, ruta_acceptada: _r3, ...fields } = outputSchema.parse(parseJsonResponse(content));
        const parsed = ruta ? { ...fields, ruta } : fields;
        // Filtre d'eixida: si la resposta reproduïx el prompt del sistema, no arriba a l'aprenent (ni res del que du
        // associat: exercici, activitat, lliçó o regla de la GNV).
        const leak = detectPromptLeak([parsed.reply_text, help_text, gnv?.contingut, gnv?.explicacio], [messages[0].content]);
        if (leak.leaked) {
          console.warn(`[agent] possible fuita del prompt del sistema (motius=${leak.reasons.join(',')}); es substituïx la resposta`);
          return { reply_text: LEAK_REPLY, mood: 'neutral' };
        }
        const reply: AgentReply = gnv && gnvResult?.hay_respaldo
          ? { ...parsed, reply_text: plain(parsed.reply_text), gnv: gnvRuleFrom(gnvResult, gnv) }
          : conjugation
            ? { ...parsed, reply_text: plain(parsed.reply_text), conjugacio: conjugation }
            : parsed;
        // La llengua materna va en una línia a part: el TTS només llig la primera (en valencià).
        return help_text?.trim() ? { ...reply, reply_text: `${reply.reply_text.trim()}
${help_text.trim()}` } : reply;
      } catch (error) {
        // Un bucle tallat (o una petició cancel·lada) no es reintenta: es propaga a qui crida.
        const stop = guard.stopped(error);
        if (stop) throw stop;
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
