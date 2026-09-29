import { Router } from 'express';
import { z } from 'zod';
import { getAdmin, requireAuth } from '../middleware/auth.js';
import { rateLimit } from '../middleware/rateLimit.js';
import { validationError } from '../validation.js';
import { evaluateA1Writing, evaluateA2Writing } from '../services/examWritingEvaluator.js';
import { isScenarioPlayable, SCENARIO_CATEGORY } from '../services/scenarios.js';

export const resourcesRouter = Router();

type Metadata = Record<string, unknown> | null;
type ResourceRow = { category: string; url: string | null; metadata: Metadata };

const text = (value: unknown) => (typeof value === 'string' && value.trim() ? value : null);

export const EXAM_CATEGORY = 'examen';

// Cada categoria té la seua pantalla de joc i decidix si una fila té les dades
// que necessita. Les categories sense pantalla es mostren com a "Pròximament".
const PLAYABLE_BY_CATEGORY: Record<string, (row: ResourceRow) => boolean> = {
  // Xat amb un personatge.
  [SCENARIO_CATEGORY]: row => isScenarioPlayable(row.metadata),
  // Examen interactiu: contingut a metadata.exam i, opcionalment, l'àudio de comprensió oral a `url`.
  [EXAM_CATEGORY]: row => hasExam(row.metadata),
};

function hasExam(metadata: Metadata) {
  const exam = metadata?.exam as { areas?: unknown } | undefined;
  return Array.isArray(exam?.areas) && exam.areas.length > 0;
}

const isPlayable = (row: ResourceRow) => PLAYABLE_BY_CATEGORY[row.category]?.(row) ?? false;

// Catàleg d'activitats (taula resources). El frontend l'agrupa per `category`
// i, dins de cada categoria, per `type`: afegir una fila a la BDD fa aparéixer
// l'activitat sense tocar codi. És públic: el catàleg no té dades d'usuari.
resourcesRouter.get('/api/resources', async (_req, res) => {
  const client = getAdmin() as any;
  if (!client) return res.json([]);

  const { data, error } = await client
    .from('resources')
    .select('id, name, type, category, difficulty, xp_earned, content, url, metadata')
    .order('category')
    .order('type')
    .order('name');

  if (error) {
    console.error('[resources] Error carregant el catàleg:', error);
    return res.status(500).json({ error: "No hem pogut carregar les activitats" });
  }

  // De metadata només s'exposa el que necessiten les pantalles, no el prompt del personatge.
  res.json((data ?? []).map(({ metadata, ...resource }: ResourceRow & Record<string, unknown>) => ({
    ...resource,
    icon: text(metadata?.icon),
    color: text(metadata?.color),
    section_name: text(metadata?.section_name),
    background: text(metadata?.background),
    voice: text(metadata?.voice),
    playable: isPlayable({ ...resource, metadata }),
  })));
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

// Formulari de l'A1 (`answers`: camp -> resposta) o redacció de l'A2 (`text`).
const evaluateSchema = z.object({
  answers: z.record(z.string().max(500)).optional(),
  text: z.string().max(3000).optional(),
});

type EvaluableExercise = {
  n: number; kind: string; instructions: string;
  fields?: string[];
  min_words?: number; max_words?: number; words?: string[]; min_words_used?: number;
};

// Avaluació amb LLM de l'Àrea 3 (Expressió escrita): el formulari de l'A1 i la
// redacció de l'A2, cadascun amb la seua rúbrica. La consigna, els camps i les
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
