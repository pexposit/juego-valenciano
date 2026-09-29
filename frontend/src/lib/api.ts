import type { Resource, Scenario, TurnResponse } from './types';
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
export async function startSessionResource(sessionId: string, scenario: Scenario): Promise<SessionResource> {
  const token = (await supabase?.auth.getSession())?.data.session?.access_token;
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/sessions/${sessionId}/resources`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: JSON.stringify({ type: scenario, category: 'escenari' }),
  });
  if (!res.ok) throw new Error("No s'ha pogut vincular l'escenari a la sessió");
  return res.json();
}
