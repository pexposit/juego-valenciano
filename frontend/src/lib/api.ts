import type { ActivityResult, Exam, LatestEvaluation, LearningPath, Lesson, Practice, Resource, Scenario, TurnResponse, WritingEvaluation } from './types';
import { sanitizeHistory } from '@parlaval/shared';
import { supabase } from './supabase';
import {
  addErrors, addEvaluation, addMessages, getMessages, latestEvaluations, listConversations, listErrors, markErrorsResolved,
  setCurrentTutorConversation, updateConversation, type LocalError,
} from './localStore';
export type HistoryItem = { role: 'user' | 'character'; content_text: string };
// Catàleg d'activitats de la BDD (taula resources). Es demana una sola vegada
// per càrrega de la pàgina: el comparteixen la selecció d'activitats i el xat.
let resourcesRequest: Promise<Resource[]> | undefined;
export function fetchResources(): Promise<Resource[]> {
  resourcesRequest ??= fetch(`${import.meta.env.VITE_API_BASE_URL}/api/resources`)
    .then(res => {
      if (!res.ok) throw new Error('No hem pogut carregar les activitats');
      return res.json() as Promise<Resource[]>;
    })
    .catch(error => {
      resourcesRequest = undefined; // permet tornar-ho a provar
      throw error;
    });
  return resourcesRequest;
}
// Contingut complet d'un examen (preguntes, opcions i solucions). null si no existix.
export async function fetchExam(id: string): Promise<Exam | null> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/exams/${encodeURIComponent(id)}`);
  if (res.status === 404) return null;
  if (!res.ok) throw new Error("No hem pogut carregar l'examen");
  return res.json();
}
// Exercicis d'un contingut del temari (fonètica, morfosintaxi, lèxic). null si no existix.
export async function fetchPractice(id: string): Promise<Practice | null> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/practice/${encodeURIComponent(id)}`);
  if (res.status === 404) return null;
  if (!res.ok) throw new Error('No hem pogut carregar els exercicis');
  return res.json();
}
// Lliçó fixa d'un contingut (teoria del nivell a partir de l'AVL). null si no en té.
export async function fetchLesson(id: string): Promise<Lesson | null> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/resources/${encodeURIComponent(id)}/lesson`);
  if (res.status === 404) return null;
  if (!res.ok) throw new Error('No hem pogut carregar la lliçó');
  return res.json();
}
// Avalua amb el LLM una redacció o un formulari de l'àrea d'Expressió escrita.
export async function evaluatePracticeExercise(
  exerciseId: string,
  body: { answers: Record<string, string> } | { text: string },
  // Nom de la pràctica, per a mostrar-lo amb els errors que se'n guarden.
  scenario: string | null = null,
): Promise<WritingEvaluation> {
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/practice/exercises/${encodeURIComponent(exerciseId)}/evaluate`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    const payload = await res.json().catch(() => null) as { error?: string } | null;
    throw new Error(res.status === 429 ? 'Has fet massa avaluacions seguides. Espera un minut.' : payload?.error ?? "No hem pogut avaluar l'exercici");
  }
  // Els errors de la redacció: el servidor en guarda les metadades i el text es guarda ací.
  const { saved_errors: saved, ...evaluation } = await res.json() as WritingEvaluation & { saved_errors?: ServerError[] };
  await storeErrors(saved ?? [], { scenario }).catch(error => console.error('Error guardant els errors:', error));
  return evaluation as WritingEvaluation;
}
// Avalua amb el LLM (rúbrica oficial de la JQCV) un exercici d'expressió escrita:
// el formulari de l'A1 (`answers`) o una redacció de l'A2/B1 (`text` i, si té opcions, `choice`).
export async function evaluateExamWriting(
  examId: string,
  exerciseN: number,
  body: { answers: Record<string, string> } | { text: string; choice?: string },
): Promise<WritingEvaluation> {
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(
    `${import.meta.env.VITE_API_BASE_URL}/api/exams/${encodeURIComponent(examId)}/exercises/${exerciseN}/evaluate`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
      body: JSON.stringify(body),
    },
  );
  if (!res.ok) {
    const payload = await res.json().catch(() => null) as { error?: string } | null;
    throw new Error(res.status === 429 ? 'Has fet massa avaluacions seguides. Espera un minut.' : payload?.error ?? "No hem pogut avaluar l'exercici");
  }
  return res.json();
}
export async function sendTurn(payload:{session_id:string;session_resource_id:string;scenario:Scenario;level:string;input_mode:'text'|'voice';text:string;audio_base64?:string|null;history?:HistoryItem[];include_audio?:boolean}):Promise<TurnResponse>{
  const token=(await supabase?.auth.getSession())?.data.session?.access_token;
  // L'historial es retalla amb el pressupost compartit abans d'enviar-lo:
  // el servidor, a més, ho tornarà a aplicar (defensa en profunditat).
  const body={...payload, history: payload.history ? sanitizeHistory(payload.history) : undefined};
  const res=await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/turn`,{method:'POST',headers:{'Content-Type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})},body:JSON.stringify(body)});
  if(!res.ok) throw new Error('No hem pogut connectar'); return res.json();
}
// Àudio TTS d'un text (veu del personatge de l'escenari). El token fa que la
// petició compte contra el límit de l'usuari amb sessió: el backend limita molt
// més les peticions anònimes. Retorna una URL `data:` reproduïble.
export async function fetchTts(text:string,scenario:Scenario):Promise<string>{
  const token=(await supabase?.auth.getSession())?.data.session?.access_token;
  const res=await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/tts`,{method:'POST',headers:{'Content-Type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})},body:JSON.stringify({text,scenario})});
  if(!res.ok) throw new Error(`tts ${res.status}`);
  const payload=await res.json() as {audio_base64:string;mime_type:string};
  return `data:${payload.mime_type};base64,${payload.audio_base64}`;
}

// Veu de la Taronjeta (Nivell 0) per a una frase que no té el seu fitxer pregenerat:
// la mateixa veu del TTS que fa servir scripts/generate-kids-audio.ts.
export async function fetchKidsVoice(text: string): Promise<string> {
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/tts`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: JSON.stringify({ text, voice: 'gina' }),
  });
  if (!res.ok) throw new Error(`tts ${res.status}`);
  const payload = await res.json() as { audio_base64: string; mime_type: string };
  return `data:${payload.mime_type};base64,${payload.audio_base64}`;
}

// La sessió es crea en iniciar sessió (login), no en triar escenari.
// Es pot passar el token directament per a no tornar a consultar supabase.auth
// des de dins d'onAuthStateChange (evita bloquejos del lock intern).
export async function createSession(level: string, accessToken?: string): Promise<string> {
  const token = accessToken ?? (await supabase?.auth.getSession())?.data.session?.access_token;

  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/sessions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: JSON.stringify({ level }),
  });

  if (!res.ok) {
    throw new Error('No hem pogut iniciar la conversa');
  }

  const data = await res.json();
  return data.session_id;
}

export async function finishSession(sessionId: string, accessToken?: string): Promise<void> {
  const token = accessToken ?? (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/sessions/finish`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: JSON.stringify({ session_id: sessionId }),
  });
  if (!res.ok) console.warn(`[finishSession] El backend ha respost amb codi ${res.status}`);
}

// L'id de la sessió creada en el login es guarda a sessionStorage perquè la
// reutilitzen tots els escenaris fins que l'usuari tanca la sessió.
const SESSION_KEY = 'parlaval:session_id';

export function getStoredSession(): string | undefined {
  try {
    return sessionStorage.getItem(SESSION_KEY) ?? undefined;
  } catch {
    return undefined;
  }
}

function storeSession(sessionId: string | undefined) {
  try {
    if (sessionId) sessionStorage.setItem(SESSION_KEY, sessionId);
    else sessionStorage.removeItem(SESSION_KEY);
  } catch {
    // Sense storage: es crearà una sessió nova en obrir l'escenari.
  }
}

// Crea la sessió al backend (en fer login) i la guarda.
export async function startSession(level: string, accessToken?: string): Promise<string> {
  const sessionId = await createSession(level, accessToken);
  storeSession(sessionId);
  return sessionId;
}

// Retorna la sessió del login o, si no n'hi ha (p. ex. pestanya nova), en crea una.
export async function ensureSession(level: string): Promise<string> {
  return getStoredSession() ?? startSession(level);
}

// Tanca la sessió al backend (logout) i l'oblida localment.
export async function endSession(): Promise<void> {
  const sessionId = getStoredSession();
  storeSession(undefined);
  if (sessionId) await finishSession(sessionId);
}

export type SessionResource = { id: string; sesion_id: string; recurso_id: string; resolved: boolean | null };

// Tanca el recurs (escenari) actual en pulsar "Eixir": marca session_resource com resolt i el
// backend en fa l'avaluació pedagògica. Les dades per a avaluar-lo són en este navegador: els
// errors pendents del recurs i les últimes avaluacions (o, en el Nivell 0, la conversa, per a
// revisar-ne els objectius). L'avaluació que torna es guarda ací.
export async function finishSessionResource(
  sessionId: string,
  sessionResourceId: string,
  { includeMessages = false }: { includeMessages?: boolean } = {},
): Promise<void> {
  // Primer, que acaben les anàlisis d'errors encara en curs d'este recurs.
  await Promise.allSettled([...(pendingAnalyses.get(sessionResourceId) ?? [])]);
  const [messages, errors, evaluations] = await Promise.all([
    includeMessages ? getMessages(sessionResourceId) : Promise.resolve([]),
    listErrors(),
    latestEvaluations(4),
  ]);
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(
    `${import.meta.env.VITE_API_BASE_URL}/api/sessions/${sessionId}/resources/${sessionResourceId}/finish`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
      body: JSON.stringify({
        messages: messages.map(m => ({ role: m.role, text: m.text, created_at: m.createdAt })),
        errors: errors
          .filter(e => e.sessionResourceId === sessionResourceId && !e.resolved)
          .map(e => ({ error_text: e.errorText, correction: e.correction, category: e.category, explanation: e.explanation })),
        evaluations: evaluations.map(e => ({ summary: e.summary, weaknesses: e.weaknesses, priority_focus: e.priorityFocus, created_at: e.createdAt })),
      }),
    },
  );
  if (!res.ok) return console.warn(`[finishSessionResource] El backend ha respost amb codi ${res.status}`);
  const { evaluation } = await res.json() as { evaluation?: LatestEvaluation | null };
  if (evaluation) {
    await addEvaluation({
      sessionResourceId,
      summary: evaluation.summary,
      weaknesses: evaluation.weaknesses,
      priorityFocus: evaluation.priority_focus,
      createdAt: evaluation.created_at,
    });
  }
}

// Vincula l'escenari triat a la sessió actual: crea una entrada nova a session_resource.
// `category` és la del recurs: 'escenari' o una àrea de conversa (p. ex. 'expressio_oral').
export async function startSessionResource(sessionId: string, scenario: Scenario, category = 'escenari'): Promise<SessionResource> {
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/sessions/${sessionId}/resources`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: JSON.stringify({ type: scenario, category }),
  });
  if (!res.ok) throw new Error("No s'ha pogut vincular l'escenari a la sessió");
  return res.json();
}

// Errors tal com els torna el servidor en crear-los (amb el text, que només es guarda ací).
type ServerError = {
  id: string; source: LocalError['source']; error_text: string; correction: string; category: string; explanation: string;
  context: string | null; options: string[] | null; exercise_id: string | null; resource_id?: string | null; created_at: string;
};

async function storeErrors(
  errors: ServerError[],
  { scenario = null, sessionResourceId = null, practicable = true }: { scenario?: string | null; sessionResourceId?: string | null; practicable?: boolean },
) {
  await addErrors(errors.map(e => ({
    id: e.id,
    source: e.source,
    errorText: e.error_text,
    correction: e.correction,
    category: e.category,
    explanation: e.explanation,
    context: e.context,
    options: e.options,
    exerciseId: e.exercise_id,
    resourceId: e.resource_id ?? null,
    sessionResourceId,
    scenario,
    practicable,
    resolved: false,
    createdAt: e.created_at,
  })));
}

// Anàlisis d'errors en curs per recurs: en tancar-lo, s'esperen abans d'avaluar-lo.
const pendingAnalyses = new Map<string, Set<Promise<void>>>();

// Busca els errors d'un missatge de l'usuari en un xat (després de /api/turn, sense fer-lo
// esperar) i en guarda el text ací. `practicable`: false per al xat amb el tutor del tauler.
export function analyzeMessage(
  payload: { session_id: string; session_resource_id: string; text: string },
  options: { scenario: string | null; practicable: boolean },
) {
  const run = (async () => {
    const token = (await supabase?.auth.getSession())?.data.session?.access_token;
    const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/errors/analyze`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
      body: JSON.stringify(payload),
    });
    if (!res.ok) throw new Error(`El backend ha respost amb codi ${res.status}`);
    await storeErrors(await res.json(), { ...options, sessionResourceId: payload.session_resource_id });
  })().catch(error => console.error('Error analitzant el missatge:', error));
  const set = pendingAnalyses.get(payload.session_resource_id) ?? new Set();
  pendingAnalyses.set(payload.session_resource_id, set.add(run));
  void run.finally(() => set.delete(run));
}

// Errors sense resoldre de l'usuari, per a la pestanya de pràctica d'errors. El text és en este
// navegador; el servidor diu quins continuen pendents (la ruta en pot donar per resolts).
export type UserError = { id: string; error_text: string; correction: string; category: string; explanation: string; message: string | null; scenario: string | null; source: 'chat' | 'practice' | 'writing'; options: string[] | null; resource_id: string | null; exercise_id: string | null };
const errorKey = (e: Pick<LocalError, 'errorText' | 'correction'>) => `${e.errorText.trim().toLowerCase()}|${e.correction.trim().toLowerCase()}`;
export async function fetchUserErrors(): Promise<UserError[]> {
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/errors`, {
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  });
  if (!res.ok) throw new Error('No hem pogut carregar els errors');
  const pending = new Set(await res.json() as string[]);
  const local = await listErrors();
  // Els que el servidor ja no té pendents queden resolts també ací.
  await markErrorsResolved(local.filter(e => !e.resolved && !pending.has(e.id)).map(e => e.id));

  // Un mateix error repetit es practica una sola vegada: es queda el més recent.
  const seen = new Set<string>();
  return local
    .filter(e => pending.has(e.id) && e.practicable)
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt))
    .filter(e => {
      const key = errorKey(e);
      if (seen.has(key)) return false;
      seen.add(key);
      return true;
    })
    .slice(0, 100)
    .map(e => ({
      id: e.id,
      error_text: e.errorText,
      correction: e.correction,
      category: e.category,
      explanation: e.explanation,
      message: e.context,
      scenario: e.scenario,
      source: e.source,
      options: e.options,
      resource_id: e.resourceId ?? null,
      exercise_id: e.exerciseId,
    }));
}
// Marca un error com a resolt (amb els seus duplicats exactes) després de corregir-lo bé en la pràctica.
export async function resolveUserError(id: string): Promise<void> {
  const local = await listErrors();
  const target = local.find(e => e.id === id);
  const ids = target ? local.filter(e => !e.resolved && errorKey(e) === errorKey(target)).map(e => e.id) : [id];
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/errors/resolve`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: JSON.stringify({ ids: ids.slice(0, 200) }),
  });
  if (!res.ok) throw new Error("No s'ha pogut desar el progrés");
  await markErrorsResolved(ids);
  // La pantalla d'exercicis guarda les respostes en este navegador: se li deixa dit quines preguntes s'han
  // corregit ací, perquè en obrir-la no les mostre com a errònies.
  try {
    for (const e of local) if (ids.includes(e.id) && e.exerciseId) localStorage.setItem(`${FIXED_PREFIX}${e.exerciseId}`, '1');
  } catch {
    // Sense storage: l'exercici mostrarà la resposta antiga fins que es torne a fer.
  }
}
/** Marca (a localStorage) d'una pregunta de pràctica corregida des de la pestanya «Errors»; la llig Practice. */
export const FIXED_PREFIX = 'parlaval:practice-fixed:';
// Envia les respostes d'una tanda d'exercicis de pràctica: el backend corregix i torna els errors,
// que es guarden ací per a la pestanya «Errors».
export async function recordPracticeAnswers(answers: { exercise_id: string; answer: string }[], scenario: string | null = null): Promise<void> {
  if (answers.length === 0) return;
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/errors/practice`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: JSON.stringify({ answers }),
  });
  if (!res.ok) throw new Error(`El backend ha respost amb codi ${res.status}`);
  const { errors } = await res.json() as { errors?: ServerError[] };
  await storeErrors(errors ?? [], { scenario });
}

// Conversa del xiquet amb el tutor de valencià del tauler: la represa o una de nova. El servidor
// diu quina és (session_resource_id) i la salutació; els missatges són en este navegador.
// `session_id` és el de la conversa existent, que pot ser d'un login anterior, i és el que
// s'ha d'enviar a /api/turn.
export type AssistantConversation = {
  session_id: string;
  session_resource_id: string;
  messages: { role: 'user' | 'character'; text: string }[];
};
async function callAssistant(action: 'open' | 'restart', sessionId: string): Promise<AssistantConversation> {
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/assistant/${action}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: JSON.stringify({ session_id: sessionId }),
  });
  if (!res.ok) throw new Error("No s'ha pogut obrir la conversa amb el professor");
  const opened = await res.json() as { session_id: string; session_resource_id: string; greeting: string };
  await setCurrentTutorConversation(opened.session_resource_id);
  let messages = (await getMessages(opened.session_resource_id)).map(m => ({ role: m.role, text: m.text }));
  // Conversa nova (o d'un altre dispositiu, sense missatges ací): comença amb la salutació.
  if (messages.length === 0) {
    messages = [{ role: 'character', text: opened.greeting }];
    await addMessages(opened.session_resource_id, 'tutor', messages);
  }
  return { session_id: opened.session_id, session_resource_id: opened.session_resource_id, messages };
}
export const openAssistant = (sessionId: string) => callAssistant('open', sessionId);
// Tanca la conversa actual i en comença una de nova (amb la salutació); els missatges antics es conserven ací.
export const restartAssistant = (sessionId: string) => callAssistant('restart', sessionId);

// Converses anteriors del xiquet amb el tutor (pestanya «Converses» del tauler infantil).
// `title`: el nom que ha posat l'usuari (title_edited) o el resum del LLM; si encara no n'hi ha, el primer missatge.
export type TutorConversation = { id: string; started_at: string; message_count: number; title: string; title_edited: boolean; preview: string; current: boolean };
export type TutorMessage = { role: 'user' | 'character'; text: string; created_at: string };

const toTutorMessages = (messages: Awaited<ReturnType<typeof getMessages>>): TutorMessage[] =>
  messages.map(m => ({ role: m.role, text: m.text, created_at: m.createdAt }));

// Una conversa del Nivell 0 (escenari) per al seguiment de la família: els missatges, en ordre.
// Només es poden llegir en el navegador on es va fer la conversa, amb el compte del xiquet.
export async function fetchKidsConversation(id: string): Promise<TutorMessage[]> {
  const messages = await getMessages(id);
  if (messages.length === 0) throw new Error('Esta conversa només es pot llegir en el dispositiu on es va fer.');
  return toTutorMessages(messages);
}
// Reobri una conversa anterior com a l'actual; en tornar al tauler el professor la continua.
export async function resumeTutorConversation(id: string): Promise<void> {
  const sessionId = await ensureSession('principiant');
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/assistant/resume`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: JSON.stringify({ session_id: sessionId, session_resource_id: id }),
  });
  if (!res.ok) throw new Error("No s'ha pogut reprendre la conversa");
  await setCurrentTutorConversation(id);
}

// Títols automàtics: es generen en llistar les converses que encara no en tenen (com a molt
// TITLES_PER_REQUEST cada vegada, perquè la llista no tarde) i es tornen a generar quan la
// conversa ha crescut almenys TITLE_REFRESH_AFTER missatges des de l'últim resum.
const TITLES_PER_REQUEST = 6;
const TITLE_REFRESH_AFTER = 8;
const TITLE_MESSAGES = 16;
const TITLE_MAX = 40;
const PREVIEW_CHARS = 80;
const CONVERSATIONS_LIMIT = 50;

async function summarizeTitle(messages: TutorMessage[]): Promise<string | null> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/assistant/title`, {
    method: 'POST',
    headers: await authHeaders(),
    body: JSON.stringify({ messages: messages.slice(0, TITLE_MESSAGES).map(m => ({ role: m.role, text: m.text })) }),
  });
  if (!res.ok) return null;
  return ((await res.json()) as { title: string | null }).title;
}

// Només es llisten les que tenen algun missatge del xiquet: les que només tenen la salutació
// (p. ex. en tornar a començar sense escriure res) no aporten res. La data és la del primer missatge.
export async function fetchTutorConversations(): Promise<TutorConversation[]> {
  const conversations = await listConversations('tutor');
  const withMessages = await Promise.all(conversations.map(async c => ({ c, messages: toTutorMessages(await getMessages(c.id)) })));

  const list = withMessages.flatMap(({ c, messages }) => {
    const first = messages.find(m => m.role === 'user');
    if (!first) return [];
    const preview = first.text.length > PREVIEW_CHARS ? `${first.text.slice(0, PREVIEW_CHARS - 1).trimEnd()}…` : first.text;
    const edited = c.titleSource === 'user' && !!c.title;
    const stale = c.titleSource === 'auto' && messages.length >= (c.titleMessageCount ?? 0) + TITLE_REFRESH_AFTER;
    const conversation: TutorConversation = {
      id: c.id,
      started_at: messages[0].created_at,
      message_count: messages.length,
      title: c.title ?? preview,
      title_edited: edited,
      preview,
      current: c.current,
    };
    return [{ conversation, messages, needsTitle: !edited && (!c.title || stale) }];
  });
  list.sort((a, b) => b.conversation.started_at.localeCompare(a.conversation.started_at));
  const page = list.slice(0, CONVERSATIONS_LIMIT);

  // Resumix amb el LLM les que no tenen títol (o el tenen antic), les més noves primer.
  await Promise.all(page.filter(c => c.needsTitle).slice(0, TITLES_PER_REQUEST).map(async item => {
    const title = await summarizeTitle(item.messages).catch(() => null);
    if (!title) return;
    item.conversation.title = title;
    await updateConversation(item.conversation.id, { title, titleSource: 'auto', titleMessageCount: item.messages.length });
  }));

  return page.map(c => c.conversation);
}
// Canvia el nom d'una conversa; amb un nom buit torna al títol automàtic.
export async function renameTutorConversation(id: string, title: string): Promise<{ title: string | null; title_edited: boolean }> {
  const clean = title.trim().replace(/\s+/g, ' ').slice(0, TITLE_MAX);
  await updateConversation(id, clean
    ? { title: clean, titleSource: 'user', titleMessageCount: null }
    : { title: null, titleSource: null, titleMessageCount: null });
  return { title: clean || null, title_edited: !!clean };
}
export const fetchTutorConversation = async (id: string) => toTutorMessages(await getMessages(id));
/* ── Ruta d'aprenentatge ──────────────────────────────────────────────── */
// Estat d'una activitat per a l'usuari (per resource id): acabada (amb nota si en té), acabada amb errors per corregir o començada.
export type ActivityStatus = { status: 'done' | 'incomplete' | 'partial' | 'in_progress'; score: number | null; total: number | null; answered: number | null; pending_errors: number };
export async function fetchActivityStatus(): Promise<Record<string, ActivityStatus>> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/activity-status`, { headers: await authHeaders() });
  if (!res.ok) throw new Error("No hem pogut carregar l'estat de les activitats");
  return res.json();
}

const authHeaders = async (): Promise<Record<string, string>> => {
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  return { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) };
};

// Ruta activa de l'usuari. La primera vegada el backend la genera (pot tardar uns segons).
export async function fetchLearningPath(): Promise<LearningPath> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/learning-path`, { headers: await authHeaders() });
  const payload = await res.json().catch(() => null);
  if (!res.ok) throw new Error(payload?.error ?? 'No hem pogut carregar la ruta');
  return payload;
}

export async function regenerateLearningPath(): Promise<LearningPath> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/learning-path/regenerate`, { method: 'POST', headers: await authHeaders() });
  const payload = await res.json().catch(() => null);
  if (!res.ok) throw new Error(res.status === 429 ? 'Has generat massa rutes seguides. Espera uns minuts.' : payload?.error ?? 'No hem pogut generar una ruta nova');
  return payload;
}

// Última avaluació pedagògica (null si encara no n'hi ha o no hi ha sessió). Es guarda en este navegador.
export async function fetchLatestEvaluation(): Promise<LatestEvaluation | null> {
  const [latest] = await latestEvaluations(1);
  return latest
    ? { summary: latest.summary, weaknesses: latest.weaknesses, priority_focus: latest.priorityFocus, created_at: latest.createdAt }
    : null;
}

// Guarda el resultat d'una pràctica o d'un examen: marca el pas de la ruta i
// pot fer que se'n genere una de nova. No bloqueja la pantalla si falla.
export async function saveActivityResult(kind: 'practice' | 'exam', resourceId: string, result: ActivityResult): Promise<void> {
  const path = kind === 'practice' ? 'practice' : 'exams';
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/${path}/${encodeURIComponent(resourceId)}/results`, {
    method: 'POST',
    headers: await authHeaders(),
    body: JSON.stringify(result),
  });
  if (!res.ok) console.warn(`[saveActivityResult] El backend ha respost amb codi ${res.status}`);
}
