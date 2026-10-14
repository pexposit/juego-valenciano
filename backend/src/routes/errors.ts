import { Router } from 'express';
import { z } from 'zod';
import { normalizeAnswer } from '@parlaval/shared';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { rateLimit } from '../middleware/rateLimit.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';
import { analyzeSchema } from '../schemas.js';
import { analyzeErrorsWithLocalLLM } from '../services/subagentErrorDetector.js';
import { classify, loadLevelContents, type LevelContent } from '../services/levelContents.js';

export const errorsRouter = Router();

// Els errors de l'usuari es guarden en dos llocs amb el mateix id:
//   * al servidor (user_errors), només les metadades: àrea (category), contingut del catàleg
//     (content_id), origen i si està resolt. És el que fa servir la ruta d'aprenentatge, i on es
//     marquen com a resolts.
//   * al navegador de l'usuari (IndexedDB), el text: la frase, la correcció, l'explicació i el
//     context. Per això cada endpoint que crea errors els torna al client perquè els guarde.
export type ClientError = {
  id: string;
  source: 'chat' | 'practice' | 'writing';
  error_text: string;
  correction: string;
  // Àrea general (fonetica_ortografia, morfosintaxi, lexic_semantica o la de l'activitat).
  category: string;
  // Nom del contingut (subcategoria) on encaixa; null si no en té.
  subcategory: string | null;
  explanation: string;
  // La frase/enunciat on es va cometre l'error (per als xats, el missatge sencer).
  context: string | null;
  // Opcions de les preguntes tancades de pràctica (la correcta és la primera).
  options: string[] | null;
  exercise_id: string | null;
  // Contingut de pràctica de l'error (per a enllaçar la pregunta); null en els xats.
  resource_id: string | null;
  created_at: string;
};

type NewError = Omit<ClientError, 'id' | 'created_at' | 'resource_id'> & { resource_id?: string | null; session_resource_id?: string | null; content_id: string | null };

// Guarda les metadades dels errors i torna cada error amb el seu id, per al client.
async function insertErrors(client: any, userId: string, errors: NewError[]): Promise<ClientError[]> {
  if (errors.length === 0) return [];
  const { data, error } = await client
    .from('user_errors')
    .insert(errors.map(e => ({
      user_id: userId,
      source: e.source,
      category: e.category,
      resource_id: e.resource_id ?? null,
      session_resource_id: e.session_resource_id ?? null,
      content_id: e.content_id,
      exercise_id: e.exercise_id,
    })))
    .select('id, created_at');
  if (error) throw error;
  return (data as { id: string; created_at: string }[]).map((row, i) => {
    const { resource_id, session_resource_id: _s, content_id: _c, ...e } = errors[i];
    return { ...e, resource_id: resource_id ?? null, id: row.id, created_at: row.created_at };
  });
}

// Ids dels errors sense resoldre de l'usuari: el client hi creua el text que té guardat.
errorsRouter.get('/api/errors', requireAuth, async (req: AuthRequest, res) => {
  const client = db(req.userId);
  if (!client || !req.userId) return res.json([]);

  const { data, error } = await client
    .from('user_errors')
    .select('id')
    .eq('user_id', req.userId)
    .eq('resolved', false)
    .order('created_at', { ascending: false })
    .limit(1000);

  if (error) {
    console.error('[errors] Error carregant els errors:', error);
    return res.status(500).json({ error: "No hem pogut carregar els errors" });
  }
  res.json((data ?? []).map((e: { id: string }) => e.id));
});

const resolveSchema = z.object({ ids: z.array(z.string().uuid()).min(1).max(200) });

// Marca com a resolts uns errors (el que s'ha contestat bé en la pràctica i els seus duplicats,
// que el client reconeix pel text).
errorsRouter.post('/api/errors/resolve', requireAuth, async (req: AuthRequest, res) => {
  const parsed = resolveSchema.safeParse(req.body);
  if (!parsed.success) return validationError(res, parsed.error);

  const client = db(req.userId);
  if (!client || !req.userId) return res.json({ ok: true, demo: true });

  const { error } = await client
    .from('user_errors')
    .update({ resolved: true, resolved_at: new Date().toISOString() })
    .eq('user_id', req.userId)
    .eq('resolved', false)
    .in('id', parsed.data.ids);

  if (error) {
    console.error('[errors] Error resolent:', error);
    return res.status(500).json({ error: "No s'ha pogut actualitzar l'error" });
  }
  res.json({ ok: true });
});

const ANALYZE_RATE_LIMIT = {
  windowMs: 60_000,
  max: Number(process.env.RATE_LIMIT_AUTHED_PER_MIN) || 30,
  maxAnonymous: Number(process.env.RATE_LIMIT_ANON_PER_MIN) || 6,
};

// Busca els errors d'un missatge de l'usuari en un xat (es crida després de /api/turn). El
// missatge no es guarda: només les metadades dels errors, que es tornen amb el text al client.
errorsRouter.post('/api/errors/analyze', requireAuth, rateLimit(ANALYZE_RATE_LIMIT), async (req: AuthRequest, res) => {
  const parsed = analyzeSchema.safeParse(req.body);
  if (!parsed.success) return validationError(res, parsed.error);

  const client = db(req.userId);
  if (!client || !req.userId) return res.json([]);
  const { session_id, session_resource_id, text } = parsed.data;

  try {
    // El session_resource ha de ser d'una sessió de l'usuari.
    const { data: owned, error: ownedError } = await client
      .from('session_resource')
      .select('id, sessions!inner(user_id)')
      .eq('id', session_resource_id)
      .eq('sesion_id', session_id)
      .eq('sessions.user_id', req.userId)
      .maybeSingle();
    if (ownedError) throw ownedError;
    if (!owned) return res.status(403).json({ error: 'Recurs de sessió no vàlid o no autoritzat' });

    // Nivell 0 (xiquets): no es busquen errors gramaticals de la conversa.
    const { data: profile } = await client.from('profiles').select('level').eq('id', req.userId).maybeSingle();
    if (!profile || profile.level === 'nivell0') return res.json([]);

    // Els errors es classifiquen en els continguts del nivell de l'alumne.
    const start = Date.now();
    const contents = await loadLevelContents(client, profile.level);
    const detected = await analyzeErrorsWithLocalLLM(text, { level: profile.level, contents });
    const saved = await insertErrors(client, req.userId, detected.flatMap(e => {
      const { category, content_id, subcategory } = classify(contents, e.area, e.contingut);
      // Amb llista de continguts, un error que no encaixa en cap és d'un nivell superior.
      if (contents.length && !content_id) return [];
      return [{
      source: 'chat' as const,
      session_resource_id,
      error_text: e.error_text,
      correction: e.correction,
      category,
      subcategory,
      content_id,
      explanation: e.explanation,
      context: text,
      options: null,
      exercise_id: null,
      }];
    }));
    console.log(`[analyze] ${saved.length} errors en ${Date.now() - start}ms`);
    res.json(saved);
  } catch (error: any) {
    console.error('[analyze] Error analitzant el missatge:', error.message ?? error);
    res.status(500).json({ error: "No hem pogut analitzar el missatge" });
  }
});

// Respostes d'una tanda d'exercicis de pràctica (preguntes tancades i d'escriure la resposta). La
// correcció es fa ací, no al client: una resposta errònia crea l'error (i es torna al client
// perquè en guarde el text) i una d'encertada resol el que hi haguera pendent d'eixe exercici.
const practiceAnswersSchema = z.object({
  answers: z.array(z.object({ exercise_id: z.string().uuid(), answer: z.string().max(500) })).min(1).max(100),
});

errorsRouter.post('/api/errors/practice', requireAuth, async (req: AuthRequest, res) => {
  const parsed = practiceAnswersSchema.safeParse(req.body);
  if (!parsed.success) return validationError(res, parsed.error);

  const client = db(req.userId);
  if (!client || !req.userId) return res.json({ ok: true, demo: true, errors: [] });

  const { data: exercises, error } = await client
    .from('practice_exercises')
    .select('id, kind, prompt, options, answers, explanation, resource_id, resources(name, category, metadata)')
    .in('id', parsed.data.answers.map(a => a.exercise_id))
    .in('kind', ['choice', 'fill']);

  if (error) {
    console.error('[errors] Error carregant els exercicis:', error);
    return res.status(500).json({ error: "No s'han pogut carregar els exercicis" });
  }

  const byId = new Map<string, any>((exercises ?? []).map((e: any) => [e.id, e]));
  const wrong: NewError[] = [];
  const right: string[] = [];
  for (const { exercise_id, answer } of parsed.data.answers) {
    const exercise = byId.get(exercise_id);
    if (!exercise || !answer.trim()) continue;
    const ok = (exercise.answers as string[]).some(a => normalizeAnswer(a) === normalizeAnswer(answer));
    if (ok) right.push(exercise_id);
    else {
      wrong.push({
        source: 'practice',
        resource_id: exercise.resource_id,
        exercise_id,
        error_text: answer.trim(),
        correction: exercise.answers[0],
        // L'àrea de l'activitat, i l'activitat mateix com a contingut.
        category: exercise.resources?.category ?? 'practica',
        subcategory: exercise.resources?.metadata?.section_name ?? exercise.resources?.name ?? null,
        content_id: exercise.resource_id,
        explanation: exercise.explanation ?? '',
        context: exercise.prompt,
        options: exercise.kind === 'choice' ? exercise.options : null,
      });
    }
  }

  if (right.length) {
    const { error: resolveError } = await client
      .from('user_errors')
      .update({ resolved: true, resolved_at: new Date().toISOString() })
      .eq('user_id', req.userId)
      .eq('resolved', false)
      .in('exercise_id', right);
    if (resolveError) console.error('[errors] Error resolent exercicis:', resolveError);
  }

  let saved: ClientError[] = [];
  if (wrong.length) {
    // Només un error pendent per exercici (índex únic parcial): es salten els que ja hi són.
    const { data: pending } = await client
      .from('user_errors')
      .select('exercise_id')
      .eq('user_id', req.userId)
      .eq('resolved', false)
      .in('exercise_id', wrong.map(w => w.exercise_id));
    const already = new Set((pending ?? []).map((p: { exercise_id: string }) => p.exercise_id));
    const fresh = wrong.filter(w => !already.has(w.exercise_id as string));
    try {
      saved = await insertErrors(client, req.userId, fresh);
    } catch (insertError: any) {
      if (insertError?.code !== '23505') console.error('[errors] Error guardant errors de pràctica:', insertError);
    }
  }

  res.json({ ok: true, wrong: wrong.length, right: right.length, errors: saved });
});

type WritingError = { original: string; correction: string; category: string; contingut: string | null };

// Errors que el LLM assenyala en avaluar una redacció o un formulari (A1: errors_destacats;
// A2/B1: errors_detectats), guardats perquè es puguen practicar.
export function writingErrorsOf(evaluation: any): WritingError[] {
  const a1 = (evaluation?.errors_destacats ?? []).map((e: any) => ({ original: e.element_original, correction: e.correccio_suggerida, category: e.tipus, contingut: e.contingut ?? null }));
  const a2 = (evaluation?.errors_detectats ?? []).map((e: any) => ({ original: e.segment_original, correction: e.proposta_correccio, category: e.categoria, contingut: e.contingut ?? null }));
  return [...a1, ...a2].filter(
    (e: WritingError) => typeof e.original === 'string' && e.original.trim() && typeof e.correction === 'string' && e.correction.trim(),
  );
}

// Àrea de les categories de les rúbriques de redacció (A1: tipus; A2, B1 i B2: categoria).
const WRITING_AREAS: Record<string, string> = {
  'lèxic': 'lexic_semantica',
  ortografia: 'fonetica_ortografia',
  morfologia: 'morfosintaxi',
  morfosintaxi: 'morfosintaxi',
  'concordança': 'morfosintaxi',
  connector: 'morfosintaxi',
};

// Guarda les metadades dels errors d'una redacció i els torna amb el text, per al client.
// `contents`: els continguts del nivell de l'alumne que s'han passat a l'avaluador; amb llista,
// només es guarden els errors que encaixen en algun (els altres són d'un nivell superior).
export async function saveWritingErrors(
  userId: string | undefined,
  exercise: { resource_id: string },
  evaluation: unknown,
  text: string,
  contents: LevelContent[],
): Promise<ClientError[]> {
  const client = db(userId);
  const errors = writingErrorsOf(evaluation).flatMap(e => {
    const classified = classify(contents, WRITING_AREAS[e.category] ?? 'morfosintaxi', e.contingut);
    return contents.length && !classified.content_id ? [] : [{ ...e, ...classified }];
  });
  if (!client || !userId || errors.length === 0) return [];

  try {
    return await insertErrors(client, userId, errors.map(e => ({
      source: 'writing',
      resource_id: exercise.resource_id,
      error_text: e.original.trim(),
      correction: e.correction.trim(),
      category: e.category,
      subcategory: e.subcategory,
      content_id: e.content_id,
      explanation: e.subcategory ? `Error de ${e.subcategory}` : "Errada detectada en l'avaluació de la redacció",
      context: text,
      options: null,
      exercise_id: null,
    })));
  } catch (error) {
    console.error('[errors] Error guardant errors de redacció:', error);
    return [];
  }
}
