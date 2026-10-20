import { z } from 'zod';
import type { ScenarioDefinition } from './scenarios.js';
import { consultarGnv, gnvContext, type GnvResultat, type GnvRule } from './gnvRag.js';



const outputSchema = z.object({
  reply_text: z.string().min(1),
  mood: z.enum(['neutral', 'content', 'confus']),
  // Només amb `extraInstructions` (tutor infantil): la mateixa idea en la llengua materna del xiquet.
  help_text: z.string().optional(),
  // Tutor: la consulta per a la GNV que ha decidit fer el model (buida si no és de normativa).
  consulta_gnv: z.string().optional(),
  // Tutor: el tema de l'exercici del catàleg que vol oferir ('' si no n'ofereix cap).
  exercici_tema: z.string().optional(),
  // Tutor: la destresa que l'aprenent vol millorar i que no es pot practicar dins del xat ('' si no n'hi ha cap).
  area_practica: z.string().optional(),
  // Tutor del Nivell 0: la lliçó de l'app relacionada amb la pregunta ('' si no n'hi ha cap).
  leccio_id: z.string().optional(),
  // Només quan el tutor ha consultat la GNV i hi ha trobat respaldo.
  gnv: z.object({
    fonts: z.array(z.number().int()),
    contingut: z.string().min(1),
    explicacio: z.string().min(1),
  }).optional(),
});

export type AgentReply = Omit<z.infer<typeof outputSchema>, 'gnv' | 'help_text' | 'consulta_gnv'> & { gnv?: GnvRule };

// Cadena de models: el principal (OPENAI_MODEL) i dos de reserva per si falla.
// El nom ha d'existir a OpenAI: un valor inventat gasta dos intents (404) en
// cada torn abans de passar al model de reserva.
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

const GNV_INSTRUCTIONS = `CONSULTA DE LA GRAMÀTICA NORMATIVA VALENCIANA (GNV):
- Si l'aprenent pregunta un dubte de normativa (com es pronuncia, com s'escriu, quan porta accent, com es forma el plural o el femení, com es conjuga, quina preposició o pronom va...), omple consulta_gnv: després rebràs la regla oficial de la GNV per a respondre-la.
- Si no és un dubte de normativa, deixa consulta_gnv buida i respon directament.`;

const EXERCISE_INSTRUCTIONS = `EXERCICIS DEL CATÀLEG:
- Mai no t'inventes exercicis: l'aplicació en mostra un de real del catàleg dins del xat, si n'hi ha, quan omples exercici_tema.
- Cada vegada que expliques o resols un dubte sobre la llengua (normativa, ortografia, accents, gramàtica, verbs, lèxic...), omple exercici_tema amb el tema (1 a 3 paraules en valencià, com el nom d'una lliçó: "accentuació", "pronoms febles", "verbs", "plurals"). Si hi ha un exercici d'eixe tema, l'aprenent el veurà davall de la teua resposta. NO el mencions en reply_text: pot ser que no n'hi haja cap.
- Si l'aprenent demana practicar o fer un exercici, omple exercici_tema amb el tema que vol i en reply_text digues només una frase curta que presente l'exercici (p. ex. «Prova este exercici!»).
- Si la conversa no tracta de la llengua (salutació, xarrada, cultura...), deixa exercici_tema buit.
- Si l'aprenent demana com millorar o practicar una DESTRESA que no es pot fer dins del xat (redactar o escriure textos → expressio_escrita; entendre àudios → comprensio_oral; entendre textos escrits → comprensio_escrita; practicar la conversa, xarrar o fer un escenari → escenari; parlar en veu alta o millorar la pronunciació → expressio_oral), omple area_practica amb eixa àrea, dóna-li 2 o 3 consells breus i diu-li que li deixes una activitat per a practicar-ho (l'aplicació l'enllaçarà). En eixe cas deixa exercici_tema buit. Si no, deixa area_practica buit.`;

type ChatMessage = { role: 'system' | 'user' | 'assistant'; content: string };

const PRACTICE_SKILLS = ['expressio_escrita', 'comprensio_oral', 'comprensio_escrita', 'expressio_oral', 'escenari'] as const;

export type LessonRef = { id: string; title: string; summary: string };

const lessonInstructions = (lessons: LessonRef[]) => `LLIÇONS DE L'APP:
- Si el que pregunta o diu el xiquet té relació amb alguna d'estes lliçons, omple leccio_id amb el seu id i digues-li, en una frase molt curta i amb paraules senzilles, que li deixes la lliçó. Només una, la més adequada. Si cap no té relació, deixa leccio_id buit. Mai no t'inventes lliçons ni ids.
${lessons.map(l => `- ${l.id}: ${l.title}${l.summary ? ` (${l.summary})` : ''}`).join('\n')}`;

function replySchema(withHelp: boolean, withGnv: boolean, askGnvQuery = false, askExercise = false, lessons: LessonRef[] = []) {
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
          ...(lessons.length ? { leccio_id: { type: 'string', enum: ['', ...lessons.map(l => l.id)], description: "L'id de la lliçó de l'app relacionada amb la pregunta del xiquet; cadena buida si no n'hi ha cap." } } : {}),
          ...(askExercise ? { area_practica: { type: 'string', enum: ['', ...PRACTICE_SKILLS], description: "La destresa que l'aprenent vol practicar si no es pot fer dins del xat; cadena buida si no n'hi ha cap." } } : {}),
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
        required: [...(withHelp ? ['help_text'] : []), 'mood', 'reply_text', ...(askGnvQuery ? ['consulta_gnv'] : []), ...(askExercise ? ['exercici_tema', 'area_practica'] : []), ...(lessons.length ? ['leccio_id'] : []), ...(withGnv ? ['gnv'] : [])],
        additionalProperties: false,
      },
    },
  };
}

// Una petició a chat/completions; retorna el contingut de la resposta.
async function complete(key: string, model: string, body: Record<string, unknown>): Promise<string | null | undefined> {
  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${key}`,
      'Content-Type': 'application/json',
    },
    signal: AbortSignal.timeout(OPENAI_TIMEOUT_MS),
    body: JSON.stringify({ model, ...body }),
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

// La consulta per a la GNV de la primera resposta del tutor ('' si no n'hi ha o no es pot llegir).
function gnvQueryOf(content: string): string {
  try {
    const value = parseJsonResponse(content) as { consulta_gnv?: unknown };
    return typeof value.consulta_gnv === 'string' ? value.consulta_gnv.trim().slice(0, 500) : '';
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
  scenario: Pick<ScenarioDefinition, 'character' | 'systemPrompt'>;
  level: string;
  message: string;
  history: { role: string; content_text: string }[];
  // Instruccions addicionals per a esta conversa (p. ex. la llengua materna del xiquet al tutor infantil).
  extraInstructions?: string;
  // Pautes segons el nivell i el públic de l'aprenent (no activen la ajuda en la llengua materna).
  levelInstructions?: string;
  // Tutor: pot consultar la Gramàtica Normativa Valenciana (RAG) quan el missatge és un dubte de normativa.
  gnvTool?: boolean;
  // Tutor: pot oferir un exercici real del catàleg (exercici_tema); el resol qui crida.
  exerciseTool?: boolean;
  // Tutor del Nivell 0: les lliçons que pot enllaçar (leccio_id); les resol qui crida.
  lessons?: LessonRef[];
}): Promise<AgentReply> {
  const key = process.env.OPENAI_API_KEY;
  if (!key) throw new Error('OPENAI_API_KEY no està configurada');

  const def = args.scenario;
  const withHelp = Boolean(args.extraInstructions);
  const context = args.history
    .map((m) => `${m.role === 'character' ? def.character : 'Aprenent'}: ${m.content_text}`)
    .join('\n');

  const messages: ChatMessage[] = [
    {
      role: 'system',
      content: `${def.systemPrompt}
        Nivell de referència de l'aprenent: ${args.level}.

        INSTRUCCIONS DE CONVERSA:
        - Respon de manera natural i coherent al context de la situació com a personatge.
        - Adapta la complexitat del teu llenguatge al nivell de l'aprenent (${args.level}).
        - Tria l'estat d'ànim ('mood') que millor represente la teua reacció com a personatge ('neutral', 'content', 'confus').

        ${args.levelInstructions ?? ''}

        ${args.extraInstructions ?? ''}

        ${args.gnvTool ? GNV_INSTRUCTIONS : ''}

        ${args.exerciseTool ? EXERCISE_INSTRUCTIONS : ''}

        ${args.lessons?.length ? lessonInstructions(args.lessons) : ''}

        Respon ÚNICAMENT amb JSON vàlid amb les claus: reply_text, mood${withHelp ? ', help_text' : ''}${args.gnvTool ? ', consulta_gnv' : ''}${args.exerciseTool ? ', exercici_tema, area_practica' : ''}${args.lessons?.length ? ', leccio_id' : ''}.`.trim(),
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

  let lastError = 'OpenAI no ha retornat una resposta vàlida';
  for (const model of OPENAI_MODELS) {
    for (let attempt = 0; attempt < 2; attempt += 1) {
      try {
        let content = await complete(key, model!, {
          response_format: replySchema(withHelp, false, args.gnvTool, args.exerciseTool, args.lessons),
          messages,
        });

        // El model ha decidit que és un dubte de normativa: es consulta la GNV i es torna a demanar la resposta.
        let gnvResult: GnvResultat | null = null;
        const consulta = args.gnvTool && content ? gnvQueryOf(content) : '';
        if (consulta) {
          gnvResult = await lookupGnv(consulta);
          content = await complete(key, model!, {
            response_format: replySchema(withHelp, Boolean(gnvResult?.hay_respaldo), false, args.exerciseTool, args.lessons),
            messages: [...messages, { role: 'system', content: gnvSourcesMessage(consulta, gnvResult) }],
          });
        }

        if (!content) {
          lastError = `OpenAI (${model}) no ha retornat contingut`;
          continue;
        }
        console.log(`[agent] resposta vàlida de ${model}`);

        const { help_text, gnv, consulta_gnv: _, ...parsed } = outputSchema.parse(parseJsonResponse(content));
        const reply: AgentReply = gnv && gnvResult?.hay_respaldo
          ? { ...parsed, reply_text: plain(parsed.reply_text), gnv: gnvRuleFrom(gnvResult, gnv) }
          : parsed;
        // La llengua materna va en una línia a part: el TTS només llig la primera (en valencià).
        return help_text?.trim() ? { ...reply, reply_text: `${reply.reply_text.trim()}
${help_text.trim()}` } : reply;
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
