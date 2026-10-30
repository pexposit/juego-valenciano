import express, { Router } from 'express';
import { z } from 'zod';
import { CEFR_LEVELS, isLevel0Class, TEACHER_AGENT_KINDS, TEACHER_AGENT_PROMPT_MAX, TEACHER_DOCUMENT_MAX_BYTES, type AgentActivityResult, type AgentDocument, type AgentPathResult, type TeacherActivityKind } from '@parlaval/shared';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { rateLimit } from '../middleware/rateLimit.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';
import { requireTeacher } from './teacherActivities.js';
import { generateActivity, generatePath, loadPathCandidates, PATH_LEVELS, SUPPORTED_KINDS_TEXT } from '../services/teacherAgent.js';
import { detectPromptInjection } from '../services/promptInjection.js';
import { DocumentError, extractDocument } from '../services/documentText.js';
import { getDocument, putDocument } from '../services/documentStore.js';
import { selectRelevant } from '../services/documentSelect.js';
import { isLoopError, LOOP_STOPPED_MESSAGE, requestAbortSignal } from '../services/loopGuard.js';

export const teacherAgentRouter = Router();

// Cada petició és una (o dues) crides al model: límit més estret que el de la resta de rutes.
const AGENT_RATE_LIMIT = { windowMs: 60_000, max: Number(process.env.RATE_LIMIT_TEACHER_AGENT_PER_MIN) || 10 };

const prompt = z.string().trim().min(5, 'Escriu què vols crear').max(TEACHER_AGENT_PROMPT_MAX);
// L'examen o temari adjuntat (l'identificador que torna /api/teacher/agent/document): el text és al servidor.
const attachment = z.string().uuid().optional();
// El nivell és obligatori: la docent sempre tria per a quin nivell és l'activitat.
const activityBody = z.object({ prompt, level: z.enum(CEFR_LEVELS, { errorMap: () => ({ message: "Tria el nivell de l'activitat" }) }), document_id: attachment,
  // Tipus d'activitat que es vol (en crear una proposta d'una ruta): sempre un dels que l'agent sap crear.
  kind: z.enum(TEACHER_AGENT_KINDS as [string, ...string[]]).optional() });
const pathBody = z.object({ prompt, class_id: z.string().uuid(), document_id: attachment });

const REJECTED = "No puc atendre eixa petició. Descriu quin contingut de valencià vols treballar.";
const DOCUMENT_EXPIRED = "El document adjuntat ha caducat (només es conserva una hora). Torna a adjuntar-lo.";

// Petició amb instruccions per a manipular el model: es talla abans de gastar cap crida. Torna el missatge per a la
// docent, o null si tot està bé.
function injectionMessage(userId: string | undefined, prompt: string): string | null {
  const verdict = detectPromptInjection(prompt);
  if (!verdict.flagged) return null;
  console.warn(`[teacher-agent] possible prompt injection (usuari=${userId} motius=${verdict.reasons.join(',')})`);
  return REJECTED;
}

/**
 * Els fragments del document adjuntat que més s'assemblen a la petició (fins a TEACHER_DOCUMENT_MAX_CHARS), o `undefined`
 * si no n'hi ha cap d'adjuntat; `'expired'` si l'identificador ja no existix. Els fragments amb instruccions per a la IA
 * (prompt injection) es descarten: el document són dades.
 */
function documentFor(userId: string | undefined, documentId: string | undefined, query: string): string | undefined | 'expired' {
  if (!documentId) return undefined;
  const doc = userId ? getDocument(userId, documentId) : null;
  if (!doc) return 'expired';
  const selection = selectRelevant(doc.text, query, { exclude: chunk => detectPromptInjection(chunk).flagged });
  console.log(`[teacher-agent] document «${doc.name}»: ${selection.selected}/${selection.total} fragments (${selection.mode}, ${selection.text.length} car.)`);
  return selection.text;
}

/**
 * Genera l'esborrany d'una activitat a partir d'un prompt. No es guarda res: la docent la revisa i la guarda
 * amb POST /api/teacher/activities. Si no es pot generar, torna `{ ok: false, message }` (200) perquè la
 * pantalla ho mostre com a avís i no com a error del servidor.
 */
teacherAgentRouter.post('/api/teacher/agent/activity', requireAuth, requireTeacher, rateLimit(AGENT_RATE_LIMIT), async (req: AuthRequest, res) => {
  const parsed = activityBody.safeParse(req.body);
  if (!parsed.success) return validationError(res, parsed.error);
  const abortSignal = requestAbortSignal(req, res);

  const rejected = injectionMessage(req.userId, parsed.data.prompt);
  if (rejected) return res.json({ ok: false, message: rejected } satisfies AgentActivityResult);
  const document = documentFor(req.userId, parsed.data.document_id, parsed.data.prompt);
  if (document === 'expired') return res.json({ ok: false, message: DOCUMENT_EXPIRED } satisfies AgentActivityResult);
  try {
    res.json(await generateActivity(parsed.data.prompt, parsed.data.level, abortSignal, document, parsed.data.kind as TeacherActivityKind | undefined));
  } catch (error) {
    if (isLoopError(error)) {
      console.warn(error.message);
      if (error.userCancelled || res.headersSent) return;
      return res.json({ ok: false, message: LOOP_STOPPED_MESSAGE } satisfies AgentActivityResult);
    }
    console.error("[teacher-agent] Error generant l'activitat:", error);
    res.status(500).json({ error: "No hem pogut generar l'activitat" });
  }
});

/**
 * Genera l'esborrany d'una ruta per a una classe de la docent, amb activitats que ja existixen. No es guarda res: la
 * docent la revisa en l'editor de rutes i la guarda. Si no hi ha activitats suficients, torna `status: 'insufficient'`
 * amb propostes d'activitats noves.
 */
teacherAgentRouter.post('/api/teacher/agent/path', requireAuth, requireTeacher, rateLimit(AGENT_RATE_LIMIT), async (req: AuthRequest, res) => {
  const parsed = pathBody.safeParse(req.body);
  if (!parsed.success) return validationError(res, parsed.error);
  const abortSignal = requestAbortSignal(req, res);
  const client = db(req.userId);
  if (!client) return res.status(401).json({ error: 'Cal iniciar sessió' });

  try {
    const { data: klass, error } = await client
      .from('kids_classes').select('id, levels').eq('id', parsed.data.class_id).eq('teacher_id', req.userId).maybeSingle();
    if (error) throw error;
    if (!klass) return res.status(404).json({ error: 'La classe no existix' });
    const levels = (klass.levels as string[]).filter(l => (PATH_LEVELS as readonly string[]).includes(l));
    if (isLevel0Class(klass.levels) || !levels.length) {
      return res.json({ status: 'error', message: "Les rutes són per a classes d'A1 a C2." } satisfies AgentPathResult);
    }

    const rejected = injectionMessage(req.userId, parsed.data.prompt);
    if (rejected) return res.json({ status: 'error', message: rejected } satisfies AgentPathResult);
    const document = documentFor(req.userId, parsed.data.document_id, parsed.data.prompt);
    if (document === 'expired') return res.json({ status: 'error', message: DOCUMENT_EXPIRED } satisfies AgentPathResult);

    const candidates = await loadPathCandidates(client, req.userId!, klass.levels, parsed.data.prompt);
    res.json(await generatePath(parsed.data.prompt, candidates, klass.levels, abortSignal, document));
  } catch (error) {
    if (isLoopError(error)) {
      console.warn(error.message);
      if (error.userCancelled || res.headersSent) return;
      return res.json({ status: 'error', message: LOOP_STOPPED_MESSAGE } satisfies AgentPathResult);
    }
    console.error('[teacher-agent] Error generant la ruta:', error);
    res.status(500).json({ error: 'No hem pogut generar la ruta' });
  }
});

/**
 * Extrau el text d'un examen o temari (PDF, Word, text) perquè l'agent el use de font. El fitxer arriba en base64 i no es
 * guarda; el text es conserva una hora en la memòria del servidor i es torna només un identificador, que el client envia
 * en cada petició de generar (documentStore.ts). El servidor n'hi tria els fragments rellevants (documentSelect.ts).
 */
const documentBody = z.object({
  name: z.string().trim().min(1).max(200),
  data_base64: z.string().min(1).max(Math.ceil(TEACHER_DOCUMENT_MAX_BYTES * 4 / 3) + 16),
});

// El cos (base64: un 33 % més que el fitxer) només es llig després d'autenticar la docent i comprovar el límit de peticions.
const documentJson = express.json({ limit: Math.ceil(TEACHER_DOCUMENT_MAX_BYTES * 4 / 3) + 4096 });

teacherAgentRouter.post('/api/teacher/agent/document', requireAuth, requireTeacher, rateLimit(AGENT_RATE_LIMIT), documentJson, async (req: AuthRequest, res) => {
  const parsed = documentBody.safeParse(req.body);
  if (!parsed.success) return validationError(res, parsed.error);
  try {
    const extracted = await extractDocument(parsed.data.name, Buffer.from(parsed.data.data_base64, 'base64'));
    res.json(putDocument(req.userId!, extracted) satisfies AgentDocument);
  } catch (error) {
    if (error instanceof DocumentError) return res.status(422).json({ error: error.message });
    console.error('[teacher-agent] Error llegint el document:', error);
    res.status(500).json({ error: "No hem pogut llegir el document" });
  }
});

// Els tipus d'activitat que l'agent sap crear, per a mostrar-los a la docent abans d'escriure el prompt.
teacherAgentRouter.get('/api/teacher/agent/capabilities', requireAuth, requireTeacher, (_req, res) => {
  res.json({ activity_kinds: SUPPORTED_KINDS_TEXT, prompt_max: TEACHER_AGENT_PROMPT_MAX });
});
