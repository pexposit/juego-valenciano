import type { Scenario, ScenarioInfo, TurnResponse } from './types';
import { sanitizeHistory } from '@parlaval/shared';
import { supabase } from './supabase';
import { SCENARIO_BY_RESOURCE_NAME, sortByDisplayOrder, type ScenarioResource } from './scenarioResources';
export type HistoryItem = { role: 'user' | 'character'; content_text: string };
export async function fetchScenarios(): Promise<Record<Scenario, ScenarioInfo>> {
  const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/scenarios`);
  if (!res.ok) throw new Error('No hem pogut carregar els escenaris');
  return res.json();
}

// Catàleg d'escenaris: dades de domini compartides (no d'un usuari concret),
// per això es llig directament de Supabase en lloc de passar pel backend.
export async function fetchScenarioResources(): Promise<ScenarioResource[]> {
  if (!supabase) return [];
  const { data, error } = await supabase
    .from('resources')
    .select('id,name,content,xp_earned')
    .eq('category', 'escenari');
  if (error) throw error;
  const resources = (data ?? [])
    .map((row): ScenarioResource | null => {
      const scenario = SCENARIO_BY_RESOURCE_NAME[row.name];
      if (!scenario) return null;
      return { id: row.id, name: row.name, content: row.content, xp_earned: row.xp_earned, scenario };
    })
    .filter((r): r is ScenarioResource => r !== null);
  return sortByDisplayOrder(resources);
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
// Avisa el backend que l'usuari ha eixit de la conversa, perquè llance
// l'avaluació pedagògica en segon pla. Si falla, no cal bloquejar l'eixida.
export async function finishSession(sessionId:string):Promise<void>{
  const token=(await supabase?.auth.getSession())?.data.session?.access_token;
  const res=await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/sessions/finish`,{method:'POST',headers:{'Content-Type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})},body:JSON.stringify({session_id:sessionId})});
  if(!res.ok) console.warn(`[finishSession] El backend ha respost amb codi ${res.status}`);
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
