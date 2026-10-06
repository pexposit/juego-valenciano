import { Router } from 'express';
import { z } from 'zod';
import { getAdmin, requireAuth, type AuthRequest } from '../middleware/auth.js';
import { rateLimit } from '../middleware/rateLimit.js';
import { validationError } from '../validation.js';
import { evaluateA1Writing, evaluateA2Writing, evaluateB1Writing } from '../services/examWritingEvaluator.js';
import { characterOf, isScenarioPlayable } from '../services/scenarios.js';
import { ASSISTANT_CATEGORY, CHAT_CATEGORIES, isPracticeArea } from '@parlaval/shared';
import { saveWritingErrors } from './errors.js';
import { EXAM_CATEGORY, hasExam, isPlayable, type Metadata, type ResourceRow } from '../services/catalog.js';

export const resourcesRouter = Router();

const text = (value: unknown) => (typeof value === 'string' && value.trim() ? value : null);
const textList = (value: unknown) =>
  Array.isArray(value) ? value.filter((v): v is string => typeof v === 'string' && v.trim() !== '') : [];

// Traduccions d'un escenari (metadata.translations): per a cada llengua materna, el resum, els
// objectius i la primera frase del personatge.
const translationsOf = (value: unknown) => {
  const result: Record<string, { content: string | null; initial_prompt: string | null; objectius: string[] }> = {};
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    for (const [lang, entry] of Object.entries(value as Record<string, Record<string, unknown>>)) {
      result[lang] = { content: text(entry?.content), initial_prompt: text(entry?.initial_prompt), objectius: textList(entry?.objectius) };
    }
  }
  return result;
};

// Lliçó fixa del contingut (metadata.lesson), per al botó «Aprendre lliçó»: teoria
// adaptada al nivell a partir de les gramàtiques de l'AVL (fonts en assets-src/avl).
const lessonSchema = z.object({
  intro: z.string(),
  blocks: z.array(z.object({
    title: z.string(),
    text: z.string(),
    table: z.object({ head: z.array(z.string()), rows: z.array(z.array(z.string())) }).optional(),
    examples: z.array(z.string()).optional(),
    watch: z.array(z.object({ wrong: z.string(), right: z.string() })).optional(),
  })).min(1),
  remember: z.array(z.string()),
  sources: z.array(z.object({ gram: z.enum(['GVB', 'GNV']), section: z.string(), title: z.string(), url: z.string().url() })),
});
const lessonOf = (metadata: Metadata) => {
  const parsed = lessonSchema.safeParse(metadata?.lesson);
  return parsed.success ? parsed.data : null;
};

// Catàleg d'activitats (taula resources). El frontend l'agrupa per `category`
// i, dins de cada categoria, per `type`: afegir una fila a la BDD fa aparéixer
// l'activitat sense tocar codi. És públic: el catàleg no té dades d'usuari.
resourcesRouter.get('/api/resources', async (_req, res) => {
  const client = getAdmin() as any;
  if (!client) return res.json([]);

  const { data, error } = await client
    .from('resources')
    .select('id, name, type, category, difficulty, xp_earned, content, url, metadata, practice_exercises(count)')
    // El tutor infantil es xateja des del tauler: no és una activitat del catàleg.
    .neq('category', ASSISTANT_CATEGORY)
    .order('category')
    .order('sort_order')
    .order('type')
    .order('name');

  if (error) {
    console.error('[resources] Error carregant el catàleg:', error);
    return res.status(500).json({ error: "No hem pogut carregar les activitats" });
  }

  // De metadata només s'exposa el que necessiten les pantalles, no el prompt del personatge.
  res.json((data ?? []).map(({ metadata, practice_exercises, ...resource }: ResourceRow & Record<string, unknown>) => ({
    ...resource,
    icon: text(metadata?.icon),
    color: text(metadata?.color),
    section_name: text(metadata?.section_name),
    background: text(metadata?.background),
    voice: text(metadata?.voice),
    initial_prompt: text(metadata?.initial_prompt),
    // Salutació pregenerada de l'escenari (ruta d'un àudio estàtic), si en té.
    greeting_audio: text(metadata?.greeting_audio),
    // Nom i rol del personatge (p. ex. "Vicent, venedor del mercat"), sense separar-los:
    // l'etiqueta de sota l'actor a la pantalla del xat el mostra tal qual.
    character: characterOf(metadata) ?? null,
    // Objectius de la conversa dels escenaris, per al quadre de la pantalla del xat.
    objectius: textList(metadata?.objectius),
    translations: translationsOf(metadata?.translations),
    playable: isPlayable({ ...resource, metadata, practice_exercises }),
    has_lesson: lessonOf(metadata) !== null,
  })));
});

// Lliçó d'un contingut (metadata.lesson). Va a banda del catàleg perquè només la
// necessita el modal «Aprendre lliçó».
resourcesRouter.get('/api/resources/:id/lesson', async (req, res) => {
  const client = getAdmin() as any;
  if (!client) return res.status(503).json({ error: "El catàleg no està disponible" });
  if (!z.string().uuid().safeParse(req.params.id).success) return res.status(404).json({ error: "La lliçó no existix" });

  const { data, error } = await client
    .from('resources')
    .select('id, name, type, category, metadata')
    .eq('id', req.params.id)
    .maybeSingle();
  if (error) {
    console.error('[lesson] Error carregant la lliçó:', error);
    return res.status(500).json({ error: "No hem pogut carregar la lliçó" });
  }
  const lesson = lessonOf(data?.metadata ?? null);
  if (!data || !lesson) return res.status(404).json({ error: "La lliçó no existix" });

  const { metadata, ...resource } = data;
  res.json({ ...resource, section_name: text(metadata?.section_name), icon: text(metadata?.icon), color: text(metadata?.color), ...lesson });
});

// Exercicis d'un contingut del temari (una àrea de PRACTICE_AREAS), de tots els
// nivells, en l'ordre de `position`, i els textos o àudios que acompanyen alguns
// (`passage_id`). Les preguntes tancades porten la solució: es corregixen en
// pantalla, com les dels exàmens.
resourcesRouter.get('/api/practice/:id', async (req, res) => {
  const client = getAdmin() as any;
  if (!client) return res.status(503).json({ error: "El catàleg no està disponible" });
  if (!z.string().uuid().safeParse(req.params.id).success) return res.status(404).json({ error: "Els exercicis no existixen" });

  const { data, error } = await client
    .from('resources')
    .select(`id, name, type, category, content, metadata,
      practice_passages(id, level, position, media, title, lines, audio_url),
      practice_exercises(id, level, position, passage_id, kind, prompt, options, answers, task, explanation)`)
    .eq('id', req.params.id)
    .maybeSingle();

  if (error) {
    console.error('[practice] Error carregant els exercicis:', error);
    return res.status(500).json({ error: "No hem pogut carregar els exercicis" });
  }
  if (!data || !isPracticeArea(data.category) || !data.practice_exercises?.length) {
    return res.status(404).json({ error: "Els exercicis no existixen" });
  }

  type Ordered = { level: string; position: number };
  const byOrder = (a: Ordered, b: Ordered) => a.level.localeCompare(b.level) || a.position - b.position;
  const { metadata, practice_exercises: exercises, practice_passages: passages, ...resource } = data;
  res.json({
    ...resource,
    icon: text(metadata?.icon),
    color: text(metadata?.color),
    section_name: text(metadata?.section_name),
    passages: (passages as Ordered[]).sort(byOrder).map(({ position: _position, ...passage }) => passage),
    exercises: (exercises as Ordered[]).sort(byOrder).map(({ position: _position, ...exercise }) => exercise),
  });
});

// Contingut complet d'un examen (preguntes, opcions i solucions). Va a banda del
// catàleg perquè és gran i només el necessita la pantalla de l'examen.
resourcesRouter.get('/api/exams/:id', async (req, res) => {
  const client = getAdmin() as any;
  if (!client) return res.status(503).json({ error: "El catàleg no està disponible" });
  // Un id que no és UUID faria fallar la consulta: es tracta com a no trobat.
  if (!z.string().uuid().safeParse(req.params.id).success) return res.status(404).json({ error: "L'examen no existix" });

  const { data, error } = await client
    .from('resources')
    .select('id, name, type, category, difficulty, xp_earned, content, url, metadata')
    .eq('id', req.params.id)
    .eq('category', EXAM_CATEGORY)
    .maybeSingle();

  if (error) {
    console.error("[exams] Error carregant l'examen:", error);
    return res.status(500).json({ error: "No hem pogut carregar l'examen" });
  }
  if (!data || !hasExam(data.metadata)) return res.status(404).json({ error: "L'examen no existix" });

  const { metadata, ...resource } = data;
  res.json({ ...resource, icon: text(metadata.icon), color: text(metadata.color), exam: metadata.exam });
});

// L'avaluació crida el LLM (i les eines MCP): és cara, per això va darrere
// d'autenticació (o mode demostració) i d'un límit més estret que el del xat.
const EVALUATE_RATE_LIMIT = {
  windowMs: 60_000,
  max: Number(process.env.RATE_LIMIT_EVALUATE_PER_MIN) || 5,
  maxAnonymous: Number(process.env.RATE_LIMIT_EVALUATE_ANON_PER_MIN) || 2,
};

// Formulari de l'A1 (`answers`: camp -> resposta) o redacció de l'A2/B1 (`text`,
// i `choice` si l'exercici té opcions A/B).
const evaluateSchema = z.object({
  answers: z.record(z.string().max(500)).optional(),
  text: z.string().max(3000).optional(),
  choice: z.string().max(5).optional(),
});

type EvaluableExercise = {
  n: number; kind: string; instructions: string;
  fields?: string[];
  min_words?: number; max_words?: number; words?: string[]; min_words_used?: number;
  choices?: { key: string; text: string; points?: string[] }[];
  image_text?: string; // transcripció de la imatge de suport, per a l'avaluador
};

// Avaluació amb LLM de l'Àrea 3 (Expressió escrita): el formulari de l'A1 i les
// redaccions de l'A2 i el B1, cadascun amb la seua rúbrica. La consigna, els camps i les
// paraules obligatòries es lligen de la BDD, no del client.
resourcesRouter.post('/api/exams/:id/exercises/:n/evaluate', requireAuth, rateLimit(EVALUATE_RATE_LIMIT), async (req, res) => {
  const parsedBody = evaluateSchema.safeParse(req.body);
  if (!parsedBody.success) return validationError(res, parsedBody.error);
  if (!z.string().uuid().safeParse(req.params.id).success) return res.status(404).json({ error: "L'examen no existix" });

  const client = getAdmin() as any;
  if (!client) return res.status(503).json({ error: "El catàleg no està disponible" });

  const { data, error } = await client
    .from('resources')
    .select('metadata')
    .eq('id', req.params.id)
    .eq('category', EXAM_CATEGORY)
    .maybeSingle();
  if (error) {
    console.error("[exams] Error carregant l'examen:", error);
    return res.status(500).json({ error: "No hem pogut carregar l'examen" });
  }

  const exam = data?.metadata?.exam as { level?: string; areas?: { exercises?: EvaluableExercise[] }[] } | undefined;
  const exercise = exam?.areas?.flatMap(a => a.exercises ?? []).find(e => String(e.n) === req.params.n);

  let evaluate: () => Promise<unknown>;
  if (exam?.level === 'A1' && exercise?.kind === 'form' && exercise.fields) {
    const fields = exercise.fields;
    const answers = parsedBody.data.answers ?? {};
    if (!fields.some(f => answers[f]?.trim())) {
      return res.status(400).json({ error: 'Omple el formulari abans d’avaluar-lo' });
    }
    evaluate = () => evaluateA1Writing({ instructions: exercise.instructions, fields, answers });
  } else if (exam?.level === 'A2' && exercise?.kind === 'writing' && exercise.min_words && exercise.max_words) {
    const text = parsedBody.data.text?.trim();
    if (!text) return res.status(400).json({ error: 'Escriu el text abans d’avaluar-lo' });
    evaluate = () => evaluateA2Writing({
      instructions: exercise.instructions,
      text,
      minWords: exercise.min_words!,
      maxWords: exercise.max_words!,
      words: exercise.words ?? [],
      minWordsUsed: exercise.min_words_used ?? 0,
    });
  } else if (exam?.level === 'B1' && exercise?.kind === 'writing' && exercise.min_words && exercise.max_words) {
    const text = parsedBody.data.text?.trim();
    if (!text) return res.status(400).json({ error: 'Escriu el text abans d’avaluar-lo' });
    // Amb opcions A/B, l'avaluador necessita la consigna de l'opció triada.
    const choice = exercise.choices?.find(c => c.key === parsedBody.data.choice);
    if (exercise.choices?.length && !choice) return res.status(400).json({ error: 'Tria una de les opcions abans d’avaluar' });
    evaluate = () => evaluateB1Writing({
      exerciseN: exercise.n,
      instructions: exercise.instructions,
      choice,
      imageText: exercise.image_text,
      text,
      minWords: exercise.min_words!,
      maxWords: exercise.max_words!,
    });
  } else {
    return res.status(404).json({ error: "Este exercici no es pot avaluar" });
  }

  try {
    res.json(await evaluate());
  } catch (err) {
    console.error('[exams] Error avaluant l’exercici:', err);
    res.status(503).json({ error: 'No hem pogut avaluar l’exercici. Torna-ho a provar.' });
  }
});

// Avaluació amb LLM d'una redacció (`writing`) o d'un formulari (`form`) de
// l'àrea d'Expressió escrita. La consigna i els camps es lligen de la BDD.
resourcesRouter.post('/api/practice/exercises/:id/evaluate', requireAuth, rateLimit(EVALUATE_RATE_LIMIT), async (req: AuthRequest, res) => {
  const parsedBody = evaluateSchema.safeParse(req.body);
  if (!parsedBody.success) return validationError(res, parsedBody.error);
  if (!z.string().uuid().safeParse(req.params.id).success) return res.status(404).json({ error: "L'exercici no existix" });

  const client = getAdmin() as any;
  if (!client) return res.status(503).json({ error: "El catàleg no està disponible" });
  const { data: exercise, error } = await client
    .from('practice_exercises')
    .select('kind, level, prompt, task, resource_id, resources(name), practice_passages(title, lines)')
    .eq('id', req.params.id)
    .maybeSingle();
  if (error) {
    console.error("[practice] Error carregant l'exercici:", error);
    return res.status(500).json({ error: "No hem pogut carregar l'exercici" });
  }
  // Del B1 amunt s'avalua amb la rúbrica del B1 i, si la tasca parteix d'un text
  // o d'un àudio (paràfrasi, apunts...), l'avaluador en rep la transcripció.
  const intermediate = exercise && !['A1', 'A2'].includes(exercise.level);
  const passage = exercise?.practice_passages as { title: string | null; lines: { text: string; speaker?: string }[] } | null;
  const sourceText = passage
    ? [passage.title, ...passage.lines.map(l => (l.speaker ? `${l.speaker}: ${l.text}` : l.text))].filter(Boolean).join('\n')
    : undefined;

  let evaluate: () => Promise<unknown>;
  if (exercise?.kind === 'form') {
    const fields: string[] = exercise.task.fields;
    const answers = parsedBody.data.answers ?? {};
    if (!fields.some(f => answers[f]?.trim())) return res.status(400).json({ error: 'Omple el formulari abans d’avaluar-lo' });
    evaluate = () => evaluateA1Writing({ instructions: exercise.prompt, fields, answers });
  } else if (exercise?.kind === 'writing') {
    const text = parsedBody.data.text?.trim();
    if (!text) return res.status(400).json({ error: 'Escriu el text abans d’avaluar-lo' });
    const task = exercise.task as { min_words: number; max_words: number; words?: string[]; min_words_used?: number };
    evaluate = () => intermediate
      ? evaluateB1Writing({
          exerciseN: 7,
          instructions: exercise.prompt,
          sourceText,
          text,
          minWords: task.min_words,
          maxWords: task.max_words,
        })
      : evaluateA2Writing({
          instructions: exercise.prompt,
          text,
          minWords: task.min_words,
          maxWords: task.max_words,
          words: task.words ?? [],
          minWordsUsed: task.min_words_used ?? 0,
        });
  } else {
    return res.status(404).json({ error: "Este exercici no es pot avaluar" });
  }

  try {
    const evaluation = await evaluate();
    // Els errors que assenyala el LLM es guarden perquè es puguen practicar a la pestanya «Errors».
    const written = exercise.kind === 'form' ? Object.values(parsedBody.data.answers ?? {}).join(' · ') : parsedBody.data.text ?? '';
    await saveWritingErrors(req.userId, exercise, evaluation, written);
    res.json(evaluation);
  } catch (err) {
    console.error('[practice] Error avaluant l’exercici:', err);
    res.status(503).json({ error: 'No hem pogut avaluar l’exercici. Torna-ho a provar.' });
  }
});
