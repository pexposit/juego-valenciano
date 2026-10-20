import type { ActivityResult, Exam, GnvRule, LatestEvaluation, LearningPath, Lesson, Practice, Resource, MyClass, Scenario, StudyPath, TurnResponse, TutorExercise, WritingEvaluation } from './types';
import { sanitizeHistory, type TeacherActivity, type TeacherActivityInput } from '@parlaval/shared';
import { supabase } from './supabase';
import { userKey } from './progressStorage';
import { markRestartedAt } from '../features/paths/progress';
import { addErrors, addEvaluation, addMessages, getMessages, latestEvaluations, listConversations, listErrors, markErrorsResolved, setCurrentTutorConversation, updateConversation, updateMessageTexts, type LocalError, forgetLevelData } from './localStore';
export type HistoryItem = { role: 'user' | 'character'; content_text: string };
// Catàleg d'activitats de la BDD (taula resources). Es demana una sola vegada
// per càrrega de la pàgina: el comparteixen la selecció d'activitats i el xat.
// Amb sessió, el catàleg inclou les activitats del professorat que pot vore l'usuari (les de
// les seues classes): per això es torna a demanar en canviar d'usuari (invalidateResources).
let resourcesRequest: Promise<Resource[]> | undefined;
export function invalidateResources() {
  resourcesRequest = undefined;
}
export function fetchResources(): Promise<Resource[]> {
  resourcesRequest ??= (async () => {
    const token = (await supabase?.auth.getSession())?.data.session?.access_token;
    return fetch(`${import.meta.env.VITE_API_BASE_URL}/api/resources`, { headers: token ? { Authorization: `Bearer ${token}` } : {} });
  })()
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
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/practice/${encodeURIComponent(id)}`, {
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  });
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
export async function sendTurn(payload:{session_id:string;session_resource_id:string;scenario:Scenario;level:string;input_mode:'text'|'voice';text:string;audio_base64?:string|null;history?:HistoryItem[];shown_exercises?:string[];include_audio?:boolean}):Promise<TurnResponse>{
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
// reutilitzen tots els escenaris fins que l'usuari tanca la sessió. Es guarda amb
// l'usuari a qui pertany: si la pestanya canvia de compte (p. ex. s'ha tancat la
// sessió des d'una altra pestanya), la d'un altre usuari no es fa servir.
const SESSION_KEY = 'parlaval:session';
type StoredSession = { userId: string; sessionId: string };

function readStoredSession(): StoredSession | undefined {
  try {
    const raw = sessionStorage.getItem(SESSION_KEY);
    return raw ? JSON.parse(raw) as StoredSession : undefined;
  } catch {
    return undefined;
  }
}

function storeSession(value: StoredSession | undefined) {
  try {
    if (value) sessionStorage.setItem(SESSION_KEY, JSON.stringify(value));
    else sessionStorage.removeItem(SESSION_KEY);
  } catch {
    // Sense storage: es crearà una sessió nova en obrir l'escenari.
  }
}

// Sense sessió de Supabase (mode demo), les sessions són de l'usuari 'demo'.
const sessionOwner = async () => (await supabase?.auth.getSession())?.data.session?.user.id ?? 'demo';

/** La sessió guardada de l'usuari actual (no la d'un altre compte que haja usat esta pestanya). */
export async function getStoredSession(): Promise<string | undefined> {
  const stored = readStoredSession();
  return stored && stored.userId === (await sessionOwner()) ? stored.sessionId : undefined;
}

// Crea la sessió al backend i la guarda.
export async function startSession(level: string, accessToken?: string): Promise<string> {
  const userId = await sessionOwner();
  const sessionId = await createSession(level, accessToken);
  storeSession({ userId, sessionId });
  return sessionId;
}

// Retorna la sessió de l'usuari o, si no n'hi ha (login, pestanya nova...), en crea una. Les
// crides simultànies (el login i el tutor del tauler en entrar) comparteixen la mateixa.
let ensuring: Promise<string> | undefined;
export function ensureSession(level: string): Promise<string> {
  ensuring ??= (async () => (await getStoredSession()) ?? startSession(level))()
    .finally(() => { ensuring = undefined; });
  return ensuring;
}

// Oblida la sessió guardada (quan es tanca la sessió de Supabase per qualsevol via).
export function forgetSession() {
  storeSession(undefined);
}

// Tanca la sessió al backend (logout) i l'oblida localment.
export async function endSession(): Promise<void> {
  const sessionId = await getStoredSession();
  storeSession(undefined);
  if (sessionId) await finishSession(sessionId);
}

export type SessionResource = { id: string; sesion_id: string; recurso_id: string; resolved: boolean | null };

// Tanca el recurs (escenari) actual en pulsar "Eixir": marca session_resource com resolt i el
// backend en fa l'avaluació pedagògica. Les dades per a avaluar-lo són en este navegador: els
// errors pendents del recurs i les últimes avaluacions (o, en el Nivell 0, la conversa, per a
// revisar-ne els objectius). L'avaluació que torna es guarda ací.
// Si es crida dues vegades per al mateix recurs (botó i eixida de la pantalla), es fa una sola petició.
const finishing = new Map<string, Promise<void>>();
const ANALYSIS_WAIT_MS = 15_000;
export function finishSessionResource(
  sessionId: string,
  sessionResourceId: string,
  options: { includeMessages?: boolean } = {},
): Promise<void> {
  let run = finishing.get(sessionResourceId);
  if (!run) {
    run = sendFinishResource(sessionId, sessionResourceId, options).finally(() => finishing.delete(sessionResourceId));
    finishing.set(sessionResourceId, run);
  }
  return run;
}

async function sendFinishResource(
  sessionId: string,
  sessionResourceId: string,
  { includeMessages = false }: { includeMessages?: boolean },
): Promise<void> {
  // Primer, que acaben les anàlisis d'errors encara en curs d'este recurs (com a molt ANALYSIS_WAIT_MS: si una es queda
  // penjada, l'escenari s'ha de tancar igualment).
  await Promise.race([
    Promise.allSettled([...(pendingAnalyses.get(sessionResourceId) ?? [])]),
    new Promise(resolve => window.setTimeout(resolve, ANALYSIS_WAIT_MS)),
  ]);
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
          .map(e => ({ error_text: e.errorText, correction: e.correction, category: e.category, subcategory: e.subcategory ?? null, explanation: e.explanation })),
        evaluations: evaluations.map(e => ({ summary: e.summary, weaknesses: e.weaknesses, priority_focus: e.priorityFocus, created_at: e.createdAt })),
      }),
    },
  );
  // 404: el recurs ja no existix o no és d'este usuari; no té sentit tornar-ho a provar.
  if (res.ok || res.status === 404) forgetOpenResource(sessionResourceId);
  if (!res.ok) {
    const detail = await res.text().catch(() => '');
    return console.warn(`[finishSessionResource] El backend ha respost amb codi ${res.status}`, detail.slice(0, 500));
  }
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

// Escenaris oberts i encara no tancats. Si l'usuari tanca la pestanya, perd la connexió o la
// pàgina es recarrega, no s'arriba a cridar finishSessionResource: es queden ací (localStorage,
// perquè sobrevisquen a tancar la pestanya) i es tanquen en la pròxima càrrega de l'app, amb
// les dades que hi ha en este navegador. Només es tanquen els que porten un temps sense
// activitat, per a no tancar un escenari que l'usuari té obert en una altra pestanya.
const OPEN_RESOURCES_KEY = 'parlaval:open-resources';
const ABANDONED_AFTER_MS = 15 * 60 * 1000;
type OpenResource = { userId: string; sessionId: string; sessionResourceId: string; includeMessages: boolean; touchedAt: number };

function readOpenResources(): OpenResource[] {
  try {
    const raw = localStorage.getItem(OPEN_RESOURCES_KEY);
    return raw ? JSON.parse(raw) as OpenResource[] : [];
  } catch {
    return [];
  }
}

function writeOpenResources(rows: OpenResource[]) {
  try {
    if (rows.length > 0) localStorage.setItem(OPEN_RESOURCES_KEY, JSON.stringify(rows));
    else localStorage.removeItem(OPEN_RESOURCES_KEY);
  } catch {
    // Sense storage: un escenari abandonat no es podrà tancar després.
  }
}

/** Apunta (o refresca, en cada torn) un escenari obert, per a tancar-lo després si s'abandona. */
export async function trackOpenResource(sessionId: string, sessionResourceId: string, includeMessages: boolean) {
  const userId = await sessionOwner();
  const others = readOpenResources().filter(r => r.sessionResourceId !== sessionResourceId);
  writeOpenResources([...others, { userId, sessionId, sessionResourceId, includeMessages, touchedAt: Date.now() }]);
}

function forgetOpenResource(sessionResourceId: string) {
  writeOpenResources(readOpenResources().filter(r => r.sessionResourceId !== sessionResourceId));
}

/** Tanca (i avalua) els escenaris de l'usuari actual que es van quedar oberts sense activitat. */
export async function finishAbandonedResources(): Promise<void> {
  const userId = await sessionOwner();
  const abandoned = readOpenResources()
    .filter(r => r.userId === userId && Date.now() - r.touchedAt > ABANDONED_AFTER_MS);
  // Un a un: cada avaluació llig les anteriors, que s'acaben de guardar.
  for (const r of abandoned) {
    await finishSessionResource(r.sessionId, r.sessionResourceId, { includeMessages: r.includeMessages })
      .catch(error => console.warn('[finishAbandonedResources] No s\'ha pogut tancar un escenari:', error));
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
  id: string; source: LocalError['source']; error_text: string; correction: string; category: string; subcategory: string | null; explanation: string;
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
    subcategory: e.subcategory ?? null,
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
export type UserError = { id: string; error_text: string; correction: string; category: string; subcategory: string | null; explanation: string; message: string | null; scenario: string | null; source: 'chat' | 'practice' | 'writing'; options: string[] | null; resource_id: string | null; exercise_id: string | null; created_at: string };
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
      subcategory: e.subcategory ?? null,
      explanation: e.explanation,
      message: e.context,
      scenario: e.scenario,
      source: e.source,
      options: e.options,
      resource_id: e.resourceId ?? null,
      exercise_id: e.exerciseId,
      created_at: e.createdAt,
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
    for (const e of local) if (ids.includes(e.id) && e.exerciseId) localStorage.setItem(fixedKey(e.exerciseId), '1');
  } catch {
    // Sense storage: l'exercici mostrarà la resposta antiga fins que es torne a fer.
  }
}
/** Marca (a localStorage) d'una pregunta de pràctica corregida des de la pestanya «Errors»; la llig Practice. */
export const fixedKey = (exerciseId: string) => userKey(`practice-fixed:${exerciseId}`);
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
  messages: { role: 'user' | 'character'; text: string; gnv?: GnvRule; exercise?: TutorExercise }[];
};
// Llengües maternes amb traducció (les mateixes que els subtítols del Nivell 0).
const TRANSLATED_TONGUES = ['es', 'en', 'fr', 'it', 'ro', 'uk'];
// Canvi de llengua materna en curs: obrir el xat del tauler l'espera, perquè no mostre les traduccions velles.
let retranslating: Promise<void> | undefined;

/**
 * Quan canvia la llengua materna, les frases del professor de la conversa del tauler porten la traducció
 * (la segona línia) en l'anterior, guardada dins de cada missatge. Es tornen a traduir a la nova llengua; si
 * la nova no té traducció (valencià o una altra), s'esborren. Si no es pot traduir, la conversa queda com estava.
 */
export function retranslateTutorConversation(tongue: string): Promise<void> {
  const run = (async () => {
    const current = (await listConversations('tutor')).find(c => c.current);
    if (!current) return;
    const messages = (await getMessages(current.id)).filter(m => m.role === 'character' && m.text.includes('\n'));
    if (messages.length === 0) return;
    const valencian = (text: string) => text.split('\n')[0];

    if (!TRANSLATED_TONGUES.includes(tongue)) {
      await updateMessageTexts(messages.map(m => ({ id: m.id, text: valencian(m.text) })));
      return;
    }
    const recent = messages.slice(-60);
    const token = (await supabase?.auth.getSession())?.data.session?.access_token;
    const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/assistant/translate`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
      body: JSON.stringify({ tongue, lines: recent.map(m => valencian(m.text)) }),
    });
    if (!res.ok) throw new Error(`El backend ha respost amb codi ${res.status}`);
    const { translations } = await res.json() as { translations: string[] };
    await updateMessageTexts(recent.map((m, i) => ({ id: m.id, text: `${valencian(m.text)}\n${translations[i]}` })));
  })().catch(error => console.error('Error actualitzant les traduccions del xat:', error));
  retranslating = run;
  void run.finally(() => { if (retranslating === run) retranslating = undefined; });
  return run;
}

async function callAssistant(action: 'open' | 'restart', sessionId: string): Promise<AssistantConversation> {
  await retranslating;
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/assistant/${action}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: JSON.stringify({ session_id: sessionId }),
  });
  if (!res.ok) throw new Error("No s'ha pogut obrir la conversa amb el professor");
  const opened = await res.json() as { session_id: string; session_resource_id: string; greeting: string };
  await setCurrentTutorConversation(opened.session_resource_id);
  let messages: AssistantConversation['messages'] = (await getMessages(opened.session_resource_id)).map(m => ({ role: m.role, text: m.text, gnv: m.gnv, exercise: m.exercise }));
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
export type TutorMessage = { role: 'user' | 'character'; text: string; gnv?: GnvRule; created_at: string };

const toTutorMessages = (messages: Awaited<ReturnType<typeof getMessages>>): TutorMessage[] =>
  messages.map(m => ({ role: m.role, text: m.text, gnv: m.gnv, created_at: m.createdAt }));

// Reobri una conversa anterior com a l'actual; en tornar al tauler el professor la continua.
export async function resumeTutorConversation(id: string): Promise<void> {
  const sessionId = await ensureSession('A1');
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

// Ruta activa de l'usuari, o null si encara no en té (es genera amb regenerateLearningPath).
export async function fetchLearningPath(): Promise<LearningPath | null> {
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

// Rutes de l'A2, el B1 i el B2 (les predefinides i les del professorat de les classes de l'usuari), amb el progrés.
// Reinicia una activitat («Tornar a fer»): en les rutes deixa de vore's com a corregida i sense nota fins que es torne a corregir.
export async function restartActivity(resourceId: string): Promise<void> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/activities/${encodeURIComponent(resourceId)}/restart`, {
    method: 'POST',
    headers: await authHeaders(),
  });
  if (!res.ok) return console.warn(`[restartActivity] El backend ha respost amb codi ${res.status}`);
  // L'hora del reinici és la del servidor, com la dels errors: s'apunta perquè els errors anteriors no isquen en l'activitat.
  const { restarted_at } = await res.json().catch(() => ({})) as { restarted_at?: string };
  if (restarted_at) markRestartedAt({ id: resourceId }, restarted_at);
}

export async function fetchStudyPaths(): Promise<{ level: string; paths: StudyPath[] }> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/study-paths`, { headers: await authHeaders() });
  const payload = await res.json().catch(() => null);
  if (!res.ok) throw new Error(payload?.error ?? 'No hem pogut carregar les rutes');
  return payload;
}

/* ── Nivell i prova de nivell ─────────────────────────────────────────── */
// Canvia el nivell de l'usuari (el client no pot escriure profiles.level). Torna les classes on
// està que no són del nivell nou, per a avisar-ne.
export async function changeLevel(level: string, reason: 'manual' | 'placement' = 'manual'): Promise<{ level: string; classes_outside: string[] }> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/profile/level`, {
    method: 'POST',
    headers: await authHeaders(),
    body: JSON.stringify({ level, reason }),
  });
  const payload = await res.json().catch(() => null);
  if (!res.ok) throw new Error(payload?.error ?? 'No hem pogut canviar el nivell');
  invalidateResources();
  // El servidor ha esborrat els errors pendients i les avaluacions del nivell anterior.
  await forgetLevelData().catch(err => console.error('Error esborrant les dades locals del nivell anterior:', err));
  return payload;
}

export type PlacementTest = {
  writing: { prompt: string; min_words: number; max_words: number };
  questions: { id: string; level: string; prompt: string; options: string[] }[];
};

export type PlacementResult = {
  suggested: string;
  questions: { level: string; per_level: Record<string, { correct: number; total: number }> };
  // Redacció avaluada amb la rúbrica de l'Expressió escrita del nivell actual (nota sobre 10).
  text: { rubric: string; mark: number; pass_mark: number; passed: boolean; feedback: string } | null;
  text_status: 'ok' | 'short' | 'unavailable' | 'not_needed';
};

export async function fetchPlacementTest(): Promise<PlacementTest> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/placement-test`, { headers: await authHeaders() });
  const payload = await res.json().catch(() => null);
  if (!res.ok) throw new Error(payload?.error ?? 'No hem pogut preparar la prova de nivell');
  return payload;
}

export async function submitPlacementTest(answers: { exercise_id: string; answer: string }[], text: string): Promise<PlacementResult> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/placement-test`, {
    method: 'POST',
    headers: await authHeaders(),
    body: JSON.stringify({ answers, text }),
  });
  const payload = await res.json().catch(() => null);
  if (!res.ok) throw new Error(res.status === 429 ? 'Has enviat massa proves seguides. Espera un minut.' : payload?.error ?? 'No hem pogut corregir la prova');
  return payload;
}

// Les classes de l'alumne amb les seues activitats i rutes (secció «Classe»).
export async function fetchMyClasses(): Promise<MyClass[]> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/my-classes`, { headers: await authHeaders() });
  const payload = await res.json().catch(() => null);
  if (!res.ok) throw new Error(payload?.error ?? 'No hem pogut carregar les teues classes');
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

/* ── Activitats del professorat ───────────────────────────────────────── */
async function teacherRequest<T>(path: string, init: RequestInit, fallback: string): Promise<T> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}${path}`, { ...init, headers: await authHeaders() });
  const payload = await res.json().catch(() => null);
  if (!res.ok) {
    const issue = payload?.issues?.[0]?.message as string | undefined;
    throw new Error(issue ? `${payload.error}: ${issue}` : payload?.error ?? fallback);
  }
  return payload as T;
}

export const fetchTeacherActivities = () =>
  teacherRequest<TeacherActivity[]>('/api/teacher/activities', {}, 'No hem pogut carregar les activitats');

// Crea (sense id) o guarda una activitat. El catàleg es torna a demanar perquè hi aparega.
export async function saveTeacherActivity(input: TeacherActivityInput, id?: string): Promise<TeacherActivity> {
  const saved = await teacherRequest<TeacherActivity>(
    id ? `/api/teacher/activities/${encodeURIComponent(id)}` : '/api/teacher/activities',
    { method: id ? 'PUT' : 'POST', body: JSON.stringify(input) },
    "No hem pogut guardar l'activitat",
  );
  invalidateResources();
  return saved;
}

export async function deleteTeacherActivity(id: string): Promise<void> {
  await teacherRequest(`/api/teacher/activities/${encodeURIComponent(id)}`, { method: 'DELETE' }, "No hem pogut esborrar l'activitat");
  invalidateResources();
}

// Activitats soltes assignades a una classe (de la docent o del catàleg).
export const fetchClassActivities = (classId: string) =>
  teacherRequest<{ resource_id: string; assigned_at: string }[]>(`/api/teacher/classes/${encodeURIComponent(classId)}/activities`, {}, "No hem pogut carregar les activitats de la classe");

export async function assignClassActivities(classId: string, resourceIds: string[]): Promise<void> {
  await teacherRequest(`/api/teacher/classes/${encodeURIComponent(classId)}/activities`, { method: 'POST', body: JSON.stringify({ resource_ids: resourceIds }) }, "No hem pogut assignar les activitats");
}

export async function unassignClassActivity(classId: string, resourceId: string): Promise<void> {
  await teacherRequest(`/api/teacher/classes/${encodeURIComponent(classId)}/activities/${encodeURIComponent(resourceId)}`, { method: 'DELETE' }, "No hem pogut llevar l'activitat");
}
