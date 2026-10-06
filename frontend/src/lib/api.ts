import type { ActivityResult, Exam, LatestEvaluation, LearningPath, Lesson, Practice, Resource, Scenario, TurnResponse, WritingEvaluation } from './types';
import { sanitizeHistory } from '@parlaval/shared';
import { supabase } from './supabase';
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
  return res.json();
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

// Tanca el recurs (escenari) actual en pulsar "Eixir": marca session_resource com resolt
// i dispara en el backend l'avaluació pedagògica diagnòstica d'eixe recurs concret.
export async function finishSessionResource(sessionId: string, sessionResourceId: string): Promise<void> {
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(
    `${import.meta.env.VITE_API_BASE_URL}/api/sessions/${sessionId}/resources/${sessionResourceId}/finish`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
    },
  );
  if (!res.ok) console.warn(`[finishSessionResource] El backend ha respost amb codi ${res.status}`);
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

// Errors sense resoldre de l'usuari (detectats al xat), per a la pestanya de pràctica d'errors.
export type UserError = { id: string; error_text: string; correction: string; category: string; explanation: string; message: string | null; scenario: string | null; source: 'chat' | 'practice' | 'writing'; options: string[] | null };
export async function fetchUserErrors(): Promise<UserError[]> {
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/errors`, {
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  });
  if (!res.ok) throw new Error('No hem pogut carregar els errors');
  return res.json();
}
// Marca un error com a resolt després de corregir-lo bé en la pràctica.
export async function resolveUserError(id: string): Promise<void> {
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/errors/${encodeURIComponent(id)}/resolve`, {
    method: 'POST',
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  });
  if (!res.ok) throw new Error("No s'ha pogut desar el progrés");
}
// Envia les respostes d'una tanda d'exercicis de pràctica: el backend guarda els errors a la pestanya «Errors».
export async function recordPracticeAnswers(answers: { exercise_id: string; answer: string }[]): Promise<void> {
  if (answers.length === 0) return;
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/errors/practice`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: JSON.stringify({ answers }),
  });
}

// Conversa del xiquet amb el tutor de valencià del tauler: la represa (amb els últims
// missatges) o la crea amb la salutació. `session_id` és el de la conversa existent, que
// pot ser d'un login anterior, i és el que s'ha d'enviar a /api/turn.
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
  return res.json();
}
export const openAssistant = (sessionId: string) => callAssistant('open', sessionId);
// Tanca la conversa actual i en comença una de nova (amb la salutació); els missatges antics es conserven a la BDD.
export const restartAssistant = (sessionId: string) => callAssistant('restart', sessionId);

// Converses anteriors del xiquet amb el tutor (pestanya «Converses» del tauler infantil).
// `title`: el nom que ha posat l'usuari (title_edited) o el resum del LLM; si encara no n'hi ha, el primer missatge.
export type TutorConversation = { id: string; started_at: string; message_count: number; title: string; title_edited: boolean; preview: string; current: boolean };
export type TutorMessage = { role: 'user' | 'character'; text: string; created_at: string };
async function authedGet<T>(path: string, errorMessage: string): Promise<T> {
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}${path}`, {
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  });
  if (!res.ok) throw new Error(errorMessage);
  return res.json();
}
// Una conversa del Nivell 0 (escenari) per al seguiment de la família: els missatges, en ordre.
export const fetchKidsConversation = (id: string) =>
  authedGet<TutorMessage[]>(`/api/kids/conversations/${encodeURIComponent(id)}/messages`, 'No hem pogut carregar la conversa');
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
}
export const fetchTutorConversations = () =>
  authedGet<TutorConversation[]>('/api/assistant/conversations', 'No hem pogut carregar les converses');
// Canvia el nom d'una conversa; amb un nom buit torna al títol automàtic.
export async function renameTutorConversation(id: string, title: string): Promise<{ title: string | null; title_edited: boolean }> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/assistant/conversations/${encodeURIComponent(id)}/title`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json', ...(await authHeaders()) },
    body: JSON.stringify({ title }),
  });
  if (!res.ok) throw new Error("No s'ha pogut canviar el nom de la conversa");
  return res.json();
}
export const fetchTutorConversation = (id: string) =>
  authedGet<TutorMessage[]>(`/api/assistant/conversations/${encodeURIComponent(id)}/messages`, 'No hem pogut carregar la conversa');
/* ── Ruta d'aprenentatge ──────────────────────────────────────────────── */
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

// Última avaluació pedagògica (null si encara no n'hi ha o no hi ha sessió).
export async function fetchLatestEvaluation(): Promise<LatestEvaluation | null> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/evaluations/latest`, { headers: await authHeaders() });
  if (!res.ok) return null;
  return res.json();
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
