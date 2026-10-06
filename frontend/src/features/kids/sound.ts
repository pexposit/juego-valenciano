import { fetchKidsVoice } from '../../lib/api';
import { KIDS_AUDIO } from './content';
import { LESSON_AUDIO } from './lessons';

/**
 * So del Nivell 0: frases pregenerades amb el TTS (/audio/kids/<clau>.wav; si en falta
 * alguna, la demana al servidor en el moment) i
 * efectes sintetitzats amb Web Audio (sense fitxers): arpa i campanetes quan
 * s'encerta, un «boing» suau quan no, i sons curts per a bambolles i comptes.
 */

let current: HTMLAudioElement | null = null;
let token = 0; // canvia cada vegada que comença una frase nova o es para la veu

// Para la frase que sonava i allibera el fitxer: un àudio només pausat continua
// ocupant la connexió, i amb unes quantes pausades les frases noves no carreguen.
function release() {
  if (!current) return;
  current.onended = current.onerror = null;
  current.pause();
  current.removeAttribute('src');
  current.load();
  current = null;
}

/** El text d'una frase (per als subtítols de les lliçons i la veu de respatller). */
export const phraseText = (key: string) => KIDS_AUDIO[key] ?? LESSON_AUDIO[key] ?? '';

/** Reprodueix un àudio. Es resol amb true quan acaba i amb false si falla (una sola vegada). */
function play(src: string): Promise<boolean> {
  return new Promise(resolve => {
    const audio = new Audio(src);
    current = audio;
    // Si falla, onerror i el rebuig de play() arriben tots dos: només compta el primer.
    let settled = false;
    const end = (ok: boolean) => {
      if (settled) return;
      settled = true;
      resolve(ok);
    };
    audio.onended = () => end(true);
    audio.onerror = () => end(false);
    audio.play().catch(() => end(false));
  });
}

/**
 * Diu una frase. Para la que sonava. Es resol quan acaba (o si falla) amb true
 * si ningú l'ha interrompuda. Els xiquets no llegixen: si falta el fitxer, la frase
 * es demana al TTS del servidor i, si tampoc respon, la diu la veu del navegador.
 */
export function say(key: string): Promise<boolean> {
  release();
  window.speechSynthesis?.cancel();
  const mine = ++token;
  const live = () => mine === token;
  return (async () => {
    if (await play(`/audio/kids/${encodeURIComponent(key)}.wav`)) return live();
    if (!live()) return false;
    const text = phraseText(key);
    const url = text ? await serverVoice(key, text) : null;
    if (url && live() && (await play(url))) return live();
    if (live()) await browserVoice(text);
    return live();
  })();
}

/** Diu una frase però no espera més de `ms`: per a no bloquejar la navegació si l'àudio s'encalla. */
export const sayBriefly = (key: string, ms = 2500): Promise<unknown> =>
  Promise.race([say(key), new Promise(r => window.setTimeout(r, ms))]);

/** Diu diverses frases seguides; s'atura si se'n diu una altra o es para la veu. */
export async function sayAll(keys: readonly string[]): Promise<boolean> {
  for (const key of keys) if (!(await say(key))) return false;
  return true;
}

export const stopVoice = () => {
  token++;
  release();
  window.speechSynthesis?.cancel();
};

// Les frases que s'han hagut de demanar al servidor, per a no tornar-les a demanar.
const fromServer = new Map<string, Promise<string | null>>();
const serverVoice = (key: string, text: string) => {
  if (!fromServer.has(key)) {
    console.warn(`Falta l'àudio /audio/kids/${key}.wav («${text}»): executeu scripts/generate-kids-audio.ts`);
    fromServer.set(key, fetchKidsVoice(text).catch(() => null));
  }
  return fromServer.get(key)!;
};

// L'última opció: la veu del navegador, en català si n'hi ha i, si no, en castellà
// (pronuncia el valencià prou millor que el silenci o una veu anglesa).
function browserVoice(text: string): Promise<void> {
  if (!text || !window.speechSynthesis) return Promise.resolve();
  return new Promise(resolve => {
    const utterance = new SpeechSynthesisUtterance(text);
    const voices = window.speechSynthesis.getVoices();
    const voice = voices.find(v => /^(ca|va)\b/i.test(v.lang)) ?? voices.find(v => /^es\b/i.test(v.lang));
    utterance.lang = voice?.lang ?? 'ca-ES';
    if (voice) utterance.voice = voice;
    // Hi ha navegadors sense veu que mai avisen que han acabat: no es queda esperant.
    const timer = window.setTimeout(resolve, 1500 + text.length * 90);
    const end = () => {
      window.clearTimeout(timer);
      resolve();
    };
    utterance.onend = end;
    utterance.onerror = end;
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
