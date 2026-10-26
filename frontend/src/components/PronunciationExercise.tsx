import { Ear, Lightbulb, Loader2, Mic, Square, Volume2 } from 'lucide-react';
import { useEffect, useRef, useState } from 'react';
import { QuestionNumber } from './ExamExercises';
import { SILENCE_PEAK } from './VoiceInput';
import { checkPronunciation, fetchKidsVoice } from '../lib/api';
import type { PronunciationResult, PronunciationWord } from '../lib/types';

// Una lectura més llarga es talla: la frase de l'exercici es llig en uns pocs segons.
const MAX_RECORDING_MS = 20_000;
// El micròfon tarda un poc a donar so net (la supressió de soroll i el guany s'ajusten): no es diu «Ara!» fins passat
// este temps des que la gravació ha començat de veres. I en tocar «Para» se seguix gravant un poc, perquè l'última
// paraula no quede tallada. En les primeres proves amb veu real es perdien la primera i les últimes paraules.
const WARMUP_MS = 300;
const TAIL_MS = 700;

// Micròfons que tallen l'àudio: alguns auriculars Bluetooth (els AirPods, en mode trucada) passen a zeros exactes a
// mitja frase. Amb el micròfon de l'ordinador, després de començar a parlar no hi ha mai ni un tram de zeros (0 de 20
// gravacions); amb els AirPods n'hi havia de 0,7 a 3,6 s.
const VOICE_LEVEL = 0.02;
const DIGITAL_SILENCE = 1e-4;
const MAX_DIGITAL_SILENCE_S = 0.5;

/** Volum màxim (0-1) i si l'àudio s'ha tallat a zeros després de començar a parlar; null si no es pot descodificar. */
async function analyzeRecording(blob: Blob): Promise<{ peak: number; cut: boolean } | null> {
  const ctx = new AudioContext();
  try {
    const decoded = await ctx.decodeAudioData(await blob.arrayBuffer());
    const samples = decoded.getChannelData(0);
    const maxRun = MAX_DIGITAL_SILENCE_S * decoded.sampleRate;
    let peak = 0;
    let speaking = false;
    let run = 0;
    let cut = false;
    for (const sample of samples) {
      const v = Math.abs(sample);
      peak = Math.max(peak, v);
      if (v > VOICE_LEVEL) speaking = true;
      run = speaking && v < DIGITAL_SILENCE ? run + 1 : 0;
      if (run >= maxRun) cut = true;
    }
    return { peak, cut };
  } catch {
    return null;
  } finally {
    void ctx.close();
  }
}

// idle → starting (demanant el micròfon) → recording (pot llegir) → stopping (cua final) → idle.
type Phase = 'idle' | 'starting' | 'recording' | 'stopping';

/* ── «Llig en veu alta»: l'aprenent llig la frase i es marquen les paraules amb els sons de l'exercici ── */
export function PronunciationExercise({
  n, exerciseId, prompt, text, explanation, result, onResult,
}: {
  n: number;
  exerciseId: string;
  prompt: string;
  text: string;
  explanation: string | null;
  result: PronunciationResult | undefined;
  onResult: (result: PronunciationResult) => void;
}) {
  const [phase, setPhase] = useState<Phase>('idle');
  const [checking, setChecking] = useState(false);
  const [error, setError] = useState<string>();
  const [playing, setPlaying] = useState(false);
  const recorder = useRef<MediaRecorder>();
  const audio = useRef<HTMLAudioElement>();
  const modelUrl = useRef<string>();
  // L'última gravació, per a escoltar-se i comparar-la amb la frase ben dita.
  const [ownUrl, setOwnUrl] = useState<string>();
  // L'última gravació l'ha tallada el micròfon (vegeu analyzeRecording).
  const [micCut, setMicCut] = useState(false);

  useEffect(() => () => {
    recorder.current?.state === 'recording' && recorder.current.stop();
    audio.current?.pause();
  }, []);
  useEffect(() => () => { if (ownUrl) URL.revokeObjectURL(ownUrl); }, [ownUrl]);

  const send = async (blob: Blob) => {
    setOwnUrl(URL.createObjectURL(blob));
    const analysis = await analyzeRecording(blob);
    setMicCut(Boolean(analysis?.cut));
    if (analysis && analysis.peak < SILENCE_PEAK) return setError("No t'hem sentit: comprova el micròfon i llig la frase en veu alta.");
    setChecking(true);
    try {
      const base64 = await new Promise<string>((resolve, reject) => {
        const reader = new FileReader();
        reader.onloadend = () => resolve((reader.result as string).split(',')[1]);
        reader.onerror = () => reject(reader.error);
        reader.readAsDataURL(blob);
      });
      onResult(await checkPronunciation(exerciseId, base64, blob.type || 'audio/webm'));
    } catch (err) {
      setError(err instanceof Error ? err.message : 'No hem pogut escoltar la gravació');
    } finally {
      setChecking(false);
    }
  };

  const stop = () => {
    const r = recorder.current;
    if (r?.state !== 'recording') return;
    setPhase('stopping');
    window.setTimeout(() => r.state === 'recording' && r.stop(), TAIL_MS);
  };

  const toggle = async () => {
    if (phase === 'recording') return stop();
    if (phase !== 'idle') return;
    setError(undefined);
    setPhase('starting');
    try {
      // Supressió de soroll i d'eco del navegador, i un sol canal: el reconeixedor de fonemes és molt sensible al soroll.
      const stream = await navigator.mediaDevices.getUserMedia({
        audio: { noiseSuppression: true, echoCancellation: true, autoGainControl: true, channelCount: 1 },
      });
      const r = new MediaRecorder(stream);
      const chunks: Blob[] = [];
      recorder.current = r;
      r.ondataavailable = e => chunks.push(e.data);
      r.onstop = () => {
        stream.getTracks().forEach(t => t.stop());
        window.clearTimeout(timer);
        setPhase('idle');
        void send(new Blob(chunks, { type: r.mimeType || 'audio/webm' }));
      };
      const timer = window.setTimeout(() => r.state === 'recording' && r.stop(), MAX_RECORDING_MS);
      r.onstart = () => window.setTimeout(() => r.state === 'recording' && setPhase('recording'), WARMUP_MS);
      r.start();
    } catch {
      setPhase('idle');
      setError('Necessitem permís per al micròfon.');
    }
  };

  // La frase ben dita, amb la veu gina del DeepLab (la mateixa amb què s'han provat les frases): `remot:` perquè no
  // depenga del laboratori de veu local. Sense `url`, la frase model; amb `url`, la gravació de l'aprenent.
  const listen = async (url?: string) => {
    if (playing) return;
    setPlaying(true);
    setError(undefined);
    try {
      audio.current = new Audio(url ?? (modelUrl.current ??= await fetchKidsVoice(text, 'remot:gina')));
      audio.current.onended = () => setPlaying(false);
      await audio.current.play();
    } catch {
      setPlaying(false);
      setError("Ara no podem reproduir la frase. Torna-ho a provar d'ací a una estona.");
    }
  };

  const failed = result?.understood ? result.words.filter(w => w.target && !w.ok && !w.missing) : [];
  const missing = result?.understood ? result.words.filter(w => w.target && w.missing) : [];

  return (
    <div>
      <div className="mb-3 flex items-center gap-3">
        {/* Només el check quan està tot bé: si falla, es queda el número (és difícil encertar-ho a la primera). */}
        <QuestionNumber n={n} result={result?.understood && result.score === result.total ? true : undefined} />
        <p className="font-bold opacity-80">{prompt}</p>
      </div>
      <div className="flex flex-col gap-4 pl-11">
        <p className="rounded-2xl bg-cream px-5 py-4 text-2xl font-black leading-relaxed">
          {result?.understood ? <MarkedText words={result.words} /> : text}
        </p>

        <div className="flex flex-wrap items-center gap-3">
          <button
            onClick={toggle}
            disabled={checking || phase === 'starting' || phase === 'stopping'}
            aria-label={phase === 'recording' ? 'Para la gravació' : 'Grava la lectura'}
            className={`btn-press relative flex items-center gap-2 rounded-full px-5 py-2.5 font-black text-white shadow disabled:opacity-60 ${phase === 'recording' ? 'recording bg-coral' : 'bg-orange hover:bg-orange/90'}`}
          >
            {checking || phase === 'starting' || phase === 'stopping' ? <Loader2 size={18} className="animate-spin" /> : phase === 'recording' ? <Square size={18} /> : <Mic size={18} />}
            {checking ? 'Escoltant...'
              : phase === 'starting' ? 'Preparant el micròfon...'
              : phase === 'recording' ? 'Ara! Llig la frase i toca ací quan acabes'
              : phase === 'stopping' ? 'Acabant...'
              : result ? 'Torna a llegir' : 'Llig en veu alta'}
          </button>
          <button
            onClick={() => listen()}
            disabled={playing}
            className="btn-press flex items-center gap-2 rounded-full bg-cream px-4 py-2.5 text-sm font-black text-teal hover:bg-teal/10 disabled:opacity-60"
          >
            <Volume2 size={18} /> Escolta com sona
          </button>
          {ownUrl && (
            <button
              onClick={() => listen(ownUrl)}
              disabled={playing || phase !== 'idle'}
              className="btn-press flex items-center gap-2 rounded-full bg-cream px-4 py-2.5 text-sm font-black text-teal hover:bg-teal/10 disabled:opacity-60"
            >
              <Ear size={18} /> Escolta't
            </button>
          )}
        </div>

        {error && <p role="alert" className="text-sm font-bold text-coral">{error}</p>}

        {result && micCut && (!result.understood || result.words.some(w => w.missing)) ? (
          <p role="alert" className="rounded-xl bg-coral/10 px-4 py-3 text-sm font-bold">
            El micròfon ha tallat l'àudio a mitja frase. Passa sovint amb auriculars Bluetooth com els AirPods.{' '}
            <span className="text-teal">Solució: usa el micròfon de l'ordinador</span> i torna a llegir la frase.
          </p>
        ) : result && !result.understood && (
          <p className="rounded-xl bg-coral/10 px-4 py-3 text-sm font-bold">
            No hem entés bé la frase. Llig-la sencera, a poc a poc i en un lloc sense soroll.
          </p>
        )}
        {result?.understood && (
          <div className="flex flex-col gap-2 text-sm">
            <p className="font-black">
              {failed.length === 0 && missing.length === 0
                ? 'Molt bé! Has pronunciat bé tots els sons.'
                : `${result.score} de ${result.total} paraules ben pronunciades.`}
            </p>
            {failed.map((w, i) => (
              <p key={i}>
                <b className="text-coral">{clean(w.word)}</b>: havia de sonar {soundName(w.expected!)} i hem sentit {w.heard ? soundName(w.heard) : 'un altre so'}.
              </p>
            ))}
            {missing.length > 0 && <p className="opacity-70">No hem sentit: {missing.map(w => clean(w.word)).join(', ')}.</p>}
            {failed.length > 0 && explanation && (
              <p className="mt-1 flex items-start gap-2 rounded-xl bg-cream px-4 py-3">
                <Lightbulb size={16} className="mt-0.5 shrink-0 text-orange" />
                <span>{explanation}</span>
              </p>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

const clean = (word: string) => word.replace(/[.,;:!?¡¿«»"]/g, '');

// Els sons en AFI que torna l'API, explicats amb una lletra i una paraula d'exemple; si no n'hi ha, l'AFI entre [].
const SOUND_NAMES: Record<string, string> = {
  'ʃ': 'el so de la x de «caixa»',
  'ʒ': 'el so de la j de «platja»',
  'tʃ': 'el so de la tx de «cotxe»',
  'dʒ': 'el so de la tg de «metge»',
  's': 'una s com la de «sol»',
  'z': 'una s sonora com la de «casa»',
  'j': 'una i com la de «iogurt»',
  'x': 'una jota castellana',
  'θ': 'una z castellana',
};
const soundName = (ipa: string) => SOUND_NAMES[ipa] ?? `el so [${ipa}]`;

// Les paraules amb els sons de l'exercici en verd (bé) o roig (malament); les no sentides, ratllades.
function MarkedText({ words }: { words: PronunciationWord[] }) {
  return (
    <>
      {words.map((w, i) => (
        <span key={i}>
          {i > 0 && ' '}
          <span
            className={!w.target ? '' : w.missing ? 'text-ink/40 line-through' : w.ok ? 'text-teal underline decoration-2 underline-offset-4' : 'text-coral underline decoration-wavy decoration-2 underline-offset-4'}
            title={w.target && !w.ok && !w.missing ? `Hem sentit ${w.heard ? soundName(w.heard) : 'un altre so'} en lloc de ${soundName(w.expected!)}` : undefined}
          >
            {w.word}
          </span>
        </span>
      ))}
    </>
  );
}
