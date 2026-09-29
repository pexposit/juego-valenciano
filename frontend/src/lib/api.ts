import type { Scenario, ScenarioInfo, TurnResponse } from './types';
import { sanitizeHistory } from '@parlaval/shared';
import { supabase } from './supabase';
export type HistoryItem = { role: 'user' | 'character'; content_text: string };
export async function fetchScenarios(): Promise<Record<Scenario, ScenarioInfo>> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/scenarios`);
  if (!res.ok) throw new Error('No hem pogut carregar els escenaris');
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

export type SessionResource = { id: string; sesion_id: string; recurso_id: string; resolved: boolean | null };

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
