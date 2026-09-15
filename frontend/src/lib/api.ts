import type { Scenario, ScenarioInfo, TurnResponse } from './types';
import { sanitizeHistory } from '@parlaval/shared';
import { supabase } from './supabase';
export type HistoryItem = { role: 'user' | 'character'; content_text: string };
export async function fetchScenarios(): Promise<Record<Scenario, ScenarioInfo>> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/scenarios`);
  if (!res.ok) throw new Error('No hem pogut carregar els escenaris');
  return res.json();
}
export async function sendTurn(payload:{session_id:string;scenario:Scenario;level:string;input_mode:'text'|'voice';text:string;audio_base64?:string|null;history?:HistoryItem[];include_audio?:boolean}):Promise<TurnResponse>{
  const token=(await supabase?.auth.getSession())?.data.session?.access_token;
  // L'historial es retalla amb el pressupost compartit abans d'enviar-lo:
  // el servidor, a més, ho tornarà a aplicar (defensa en profunditat).
  const body={...payload, history: payload.history ? sanitizeHistory(payload.history) : undefined};
  const res=await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/turn`,{method:'POST',headers:{'Content-Type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})},body:JSON.stringify(body)});
  if(!res.ok) throw new Error('No hem pogut connectar'); return res.json();
}
export async function createSession(scenario:Scenario,level:string):Promise<string>{const token=(await supabase?.auth.getSession())?.data.session?.access_token;const res=await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/sessions`,{method:'POST',headers:{'Content-Type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})},body:JSON.stringify({scenario,level})});if(!res.ok)throw new Error('No hem pogut iniciar la conversa');return (await res.json()).session_id}
