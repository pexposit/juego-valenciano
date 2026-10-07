import { Router } from 'express';
import { z } from 'zod';
import { ASSISTANT_CATEGORY, normalizeAnswer } from '@parlaval/shared';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';

export const errorsRouter = Router();

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

// Errors sense resoldre de l'usuari, per a la pestanya de pràctica d'errors: venen dels
// xats (source 'chat'), dels exercicis de pràctica ('practice') i de l'Expressió escrita ('writing').
errorsRouter.get('/api/errors', requireAuth, async (req: AuthRequest, res) => {
  const client = db(req.userId);
  if (!client || !req.userId) return res.json([]);

  const { data, error } = await client
    .from('user_errors')
    .select(
      'id, error_text, correction, category, explanation, source, context, created_at, ' +
      'conversation_messages(content_text), resources(name), session_resource(resources(name, category)), practice_exercises(kind, options)',
    )
    .eq('user_id', req.userId)
    .eq('resolved', false)
    .order('created_at', { ascending: false })
    .limit(200);

  if (error) {
    console.error('[errors] Error carregant els errors:', error);
    return res.status(500).json({ error: "No hem pogut carregar els errors" });
  }

  // Un mateix error repetit es practica una sola vegada: es queda el més recent.
  const seen = new Set<string>();
  // Els errors del xat amb el professor del tauler (categoria 'assistent') no es practiquen ací.
  const fromAssistant = (e: any) => e.session_resource?.resources?.category === ASSISTANT_CATEGORY;
  const unique = (data ?? []).filter((e: any) => {
    if (fromAssistant(e)) return false;
    const key = `${e.error_text.trim().toLowerCase()}|${e.correction.trim().toLowerCase()}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  }).slice(0, 100);
  // `message` és la frase/enunciat on es va cometre l'error; `scenario`, l'activitat on va passar.
  res.json(unique.map(({ conversation_messages, resources, session_resource, practice_exercises, context, ...e }: any) => ({
    ...e,
    // Preguntes tancades de pràctica: es tornen a mostrar les opcions en lloc d'un camp de text.
    options: practice_exercises?.kind === 'choice' ? practice_exercises.options : null,
    message: conversation_messages?.content_text ?? context ?? null,
    scenario: resources?.name ?? session_resource?.resources?.name ?? null,
  })));
});

// Marca com a resolt un error (i els duplicats exactes) després de contestar-lo bé en la pràctica.
errorsRouter.post('/api/errors/:id/resolve', requireAuth, async (req: AuthRequest, res) => {
  const id = req.params.id as string;
  if (!UUID.test(id)) return res.status(400).json({ error: 'Identificador no vàlid' });

  const client = db(req.userId);
  if (!client || !req.userId) return res.json({ ok: true, demo: true });

  const { data: row, error: findError } = await client
    .from('user_errors')
    .select('id, error_text, correction')
    .eq('id', id)
    .eq('user_id', req.userId)
    .maybeSingle();

  if (findError) {
    console.error('[errors] Error verificant l\'error:', findError);
    return res.status(500).json({ error: "No s'ha pogut verificar l'error" });
  }
  if (!row) return res.status(404).json({ error: 'Error no trobat' });

  const { error: updateError } = await client
    .from('user_errors')
    .update({ resolved: true, resolved_at: new Date().toISOString() })
    .eq('user_id', req.userId)
    .eq('error_text', row.error_text)
    .eq('correction', row.correction)
    .eq('resolved', false);

  if (updateError) {
    console.error('[errors] Error resolent:', updateError);
    return res.status(500).json({ error: "No s'ha pogut actualitzar l'error" });
  }
  res.json({ ok: true });
});

// Respostes d'una tanda d'exercicis de pràctica (preguntes tancades i d'escriure la resposta). La
// correcció es fa ací, no al client: una resposta errònia guarda l'error i una d'encertada resol
// el que hi haguera pendent d'eixe exercici.
const practiceAnswersSchema = z.object({
  answers: z.array(z.object({ exercise_id: z.string().uuid(), answer: z.string().max(500) })).min(1).max(100),
});

errorsRouter.post('/api/errors/practice', requireAuth, async (req: AuthRequest, res) => {
  const parsed = practiceAnswersSchema.safeParse(req.body);
  if (!parsed.success) return validationError(res, parsed.error);

  const client = db(req.userId);
  if (!client || !req.userId) return res.json({ ok: true, demo: true });

  const { data: exercises, error } = await client
    .from('practice_exercises')
    .select('id, kind, prompt, answers, explanation, resource_id, resources(name)')
    .in('id', parsed.data.answers.map(a => a.exercise_id))
    .in('kind', ['choice', 'fill']);

  if (error) {
    console.error('[errors] Error carregant els exercicis:', error);
    return res.status(500).json({ error: "No s'han pogut carregar els exercicis" });
  }

  const byId = new Map<string, any>((exercises ?? []).map((e: any) => [e.id, e]));
  const wrong: Record<string, unknown>[] = [];
  const right: string[] = [];
  for (const { exercise_id, answer } of parsed.data.answers) {
    const exercise = byId.get(exercise_id);
    if (!exercise || !answer.trim()) continue;
    const ok = (exercise.answers as string[]).some(a => normalizeAnswer(a) === normalizeAnswer(answer));
    if (ok) right.push(exercise_id);
    else {
      wrong.push({
        user_id: req.userId,
        source: 'practice',
        resource_id: exercise.resource_id,
        exercise_id,
        error_text: answer.trim(),
        correction: exercise.answers[0],
        category: exercise.resources?.name ?? 'Pràctica',
        explanation: exercise.explanation ?? '',
        context: exercise.prompt,
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
    if (fresh.length) {
      const { error: insertError } = await client.from('user_errors').insert(fresh);
      if (insertError && insertError.code !== '23505') console.error('[errors] Error guardant errors de pràctica:', insertError);
    }
  }

  res.json({ ok: true, wrong: wrong.length, right: right.length });
});

type WritingError = { original: string; correction: string; category: string };

// Errors que el LLM assenyala en avaluar una redacció o un formulari (A1: errors_destacats;
// A2/B1: errors_detectats), guardats perquè es puguen practicar.
export function writingErrorsOf(evaluation: any): WritingError[] {
  const a1 = (evaluation?.errors_destacats ?? []).map((e: any) => ({ original: e.element_original, correction: e.correccio_suggerida, category: e.tipus }));
  const a2 = (evaluation?.errors_detectats ?? []).map((e: any) => ({ original: e.segment_original, correction: e.proposta_correccio, category: e.categoria }));
  return [...a1, ...a2].filter(
    (e: WritingError) => typeof e.original === 'string' && e.original.trim() && typeof e.correction === 'string' && e.correction.trim(),
  );
}

export async function saveWritingErrors(
  userId: string | undefined,
  exercise: { resource_id: string; resources?: { name?: string } | null },
  evaluation: unknown,
  text: string,
) {
  const client = db(userId);
  const errors = writingErrorsOf(evaluation);
  if (!client || !userId || errors.length === 0) return;

  const { error } = await client.from('user_errors').insert(
    errors.map(e => ({
      user_id: userId,
      source: 'writing',
      resource_id: exercise.resource_id,
      error_text: e.original.trim(),
      correction: e.correction.trim(),
      category: e.category || exercise.resources?.name || 'Expressió escrita',
      explanation: e.category ? `Error de ${e.category}` : "Errada detectada en l'avaluació de la redacció",
      context: text,
    })),
  );
  if (error) console.error('[errors] Error guardant errors de redacció:', error);
}
