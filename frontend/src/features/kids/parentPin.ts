import { supabase } from '../../lib/supabase';

/**
 * PIN de la família (4 xifres): el tria la persona adulta en crear el compte infantil i
 * protegix el seguiment. Amb sessió, només en guarda el hash el servidor (kids_parent_pins,
 * amb funcions que limiten els intents). En el mode demostració, en este navegador.
 */

export type PinCheck = { ok: boolean; lockedSeconds: number; attemptsLeft: number };

export const isPin = (pin: string) => /^\d{4}$/.test(pin);

const DEMO_KEY = 'parlaval:kids:pin-demo';
const demoPin = () => {
  try {
    return localStorage.getItem(DEMO_KEY);
  } catch {
    return null;
  }
};
const saveDemoPin = (pin: string) => {
  try {
    localStorage.setItem(DEMO_KEY, pin);
  } catch {
    // Sense storage: el PIN només dura mentre la pàgina estiga oberta.
  }
};

const online = (uid: string | undefined) => (supabase && uid ? supabase : null);

export async function hasPin(uid: string | undefined): Promise<boolean> {
  const client = online(uid);
  if (!client) return !!demoPin();
  const { data, error } = await client.rpc('kids_has_pin');
  if (error) throw error;
  return !!data;
}

/** El primer PIN del compte (no en substituïx cap). */
export async function setPin(uid: string | undefined, pin: string) {
  const client = online(uid);
  if (!client) return saveDemoPin(pin);
  const { error } = await client.rpc('kids_set_pin', { p_pin: pin });
  if (error) throw error;
}

export async function checkPin(uid: string | undefined, pin: string): Promise<PinCheck> {
  const client = online(uid);
  if (!client) return { ok: pin === demoPin(), lockedSeconds: 0, attemptsLeft: 5 };
  const { data, error } = await client.rpc('kids_check_pin', { p_pin: pin });
  if (error) throw error;
  const result = data as { ok: boolean; locked_seconds: number; attempts_left: number };
  return { ok: result.ok, lockedSeconds: result.locked_seconds, attemptsLeft: result.attempts_left };
}

/** PIN oblidat: un de nou amb la contrasenya del compte. */
export async function resetPin(uid: string | undefined, password: string, pin: string): Promise<{ ok: boolean; lockedSeconds: number }> {
  const client = online(uid);
  if (!client) {
    saveDemoPin(pin);
    return { ok: true, lockedSeconds: 0 };
  }
  const { data, error } = await client.rpc('kids_reset_pin', { p_password: password, p_pin: pin });
  if (error) throw error;
  const result = data as { ok: boolean; locked_seconds: number };
  return { ok: result.ok, lockedSeconds: result.locked_seconds };
}
