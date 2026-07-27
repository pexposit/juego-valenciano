import type { Scenario, TurnResponse } from './types';
import { supabase } from './supabase';
export async function sendTurn(payload:{session_id:string;scenario:Scenario;level:string;input_mode:'text'|'voice';text:string;audio_base64?:string|null}):Promise<TurnResponse>{
  const token=(await supabase?.auth.getSession())?.data.session?.access_token;
  const res=await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/turn`,{method:'POST',headers:{'Content-Type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})},body:JSON.stringify(payload)});
  if(!res.ok) throw new Error('No hem pogut connectar'); return res.json();
}
export async function createSession(scenario:Scenario,level:string):Promise<string>{const token=(await supabase?.auth.getSession())?.data.session?.access_token;const res=await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/sessions`,{method:'POST',headers:{'Content-Type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})},body:JSON.stringify({scenario,level})});if(!res.ok)throw new Error('No hem pogut iniciar la conversa');return (await res.json()).session_id}
