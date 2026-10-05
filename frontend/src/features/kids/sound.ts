import { KIDS_AUDIO } from './content';
import { LESSON_AUDIO } from './lessons';

/**
 * So del Nivell 0: frases pregenerades amb el TTS (/audio/kids/<clau>.wav) i
 * efectes sintetitzats amb Web Audio (sense fitxers): arpa i campanetes quan
 * s'encerta, un «boing» suau quan no, i sons curts per a bambolles i comptes.
 */

let current: HTMLAudioElement | null = null;
let token = 0; // canvia cada vegada que comença una frase nova o es para la veu

/** El text d'una frase (per als subtítols de les lliçons i la veu de respatller). */
export const phraseText = (key: string) => KIDS_AUDIO[key] ?? LESSON_AUDIO[key] ?? '';

/**
 * Diu una frase. Para la que sonava. Es resol quan acaba (o si falla) amb true
 * si ningú l'ha interrompuda.
 */
export function say(key: string): Promise<boolean> {
  current?.pause();
  window.speechSynthesis?.cancel();
  const mine = ++token;
  return new Promise(resolve => {
    const audio = new Audio(`/audio/kids/${encodeURIComponent(key)}.wav`);
    current = audio;
    const done = () => resolve(mine === token);
    audio.onended = done;
    audio.onerror = () => fallback(key).then(done);
    audio.play().catch(() => fallback(key).then(done));
  });
}

/** Diu diverses frases seguides; s'atura si se'n diu una altra o es para la veu. */
export async function sayAll(keys: readonly string[]): Promise<boolean> {
  for (const key of keys) if (!(await say(key))) return false;
  return true;
}

export const stopVoice = () => {
  token++;
  current?.pause();
  window.speechSynthesis?.cancel();
};

// Si el fitxer no hi és, la veu del navegador (en català, si n'hi ha).
function fallback(key: string): Promise<void> {
  const text = phraseText(key);
  if (!text || !window.speechSynthesis) return Promise.resolve();
  return new Promise(resolve => {
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = 'ca-ES';
    utterance.onend = () => resolve();
    utterance.onerror = () => resolve();
    window.speechSynthesis.speak(utterance);
  });
}

let ctx: AudioContext | null = null;
const audioContext = () => {
  ctx ??= new AudioContext();
  if (ctx.state === 'suspended') void ctx.resume();
  return ctx;
};

function tone(freq: number, start: number, duration: number, type: OscillatorType = 'sine', gain = 0.18, glideTo?: number) {
  const ac = audioContext();
  const osc = ac.createOscillator();
  const amp = ac.createGain();
  const t = ac.currentTime + start;
  osc.type = type;
  osc.frequency.setValueAtTime(freq, t);
  if (glideTo) osc.frequency.exponentialRampToValueAtTime(glideTo, t + duration);
  amp.gain.setValueAtTime(0.0001, t);
  amp.gain.exponentialRampToValueAtTime(gain, t + 0.015);
  amp.gain.exponentialRampToValueAtTime(0.0001, t + duration);
  osc.connect(amp).connect(ac.destination);
  osc.start(t);
  osc.stop(t + duration + 0.05);
}

/** Encert: arpegi d'arpa i dues campanetes. */
export function sfxCorrect() {
  [523.25, 659.25, 783.99, 1046.5].forEach((f, i) => tone(f, i * 0.07, 0.45, 'triangle', 0.16));
  tone(1567.98, 0.32, 0.6, 'sine', 0.08);
  tone(2093, 0.4, 0.7, 'sine', 0.06);
}

/** Error: «boing» suau, sense cap to de càstig. */
export function sfxBoing() {
  tone(330, 0, 0.18, 'sine', 0.2, 140);
  tone(150, 0.16, 0.3, 'sine', 0.16, 260);
}

/** Bambolla que esclata. */
export function sfxPop() {
  tone(500, 0, 0.09, 'sine', 0.22, 1400);
}

/** Cada peça que es compta o s'encaixa. */
export function sfxTick(step = 0) {
  tone(660 + step * 40, 0, 0.12, 'triangle', 0.14);
}

/** Cromo nou: fanfàrria curta. */
export function sfxFanfare() {
  [392, 523.25, 659.25, 783.99, 1046.5, 1318.5].forEach((f, i) => tone(f, i * 0.09, 0.5, 'triangle', 0.14));
}

export const randomOf = <T,>(list: readonly T[]) => list[Math.floor(Math.random() * list.length)];
