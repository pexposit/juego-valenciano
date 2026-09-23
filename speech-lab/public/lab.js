/**
 * Pàgina de proves del laboratori de veu en temps real.
 *
 * Dos estats que abans anaven junts i no podien anar junts:
 *  - `micOpen`: el graf d'àudio està obert (permís concedit, worklet escoltant).
 *  - `turnActive`: el servidor té una sessió de reconeixement oberta.
 * Creuar-los era el motiu pel qual la pàgina pareixia «connectada però no
 * responia»: en acabar un torn el micròfon es tancava i calia tornar a prémer
 * «Escoltar». Amb el mode continu es manté l'objectiu de seguir escoltant
 * (`wantAudio`) i el torn es reobri sol quan el servidor torna a estar llest.
 *
 * El mesurador de nivell llig el senyal cru del micròfon: si el motor rep
 * sobretot soroll, inventa paraules plausibles i açò és el que ho explica.
 */
const TARGET_RATE = 16000;
/** 2048 mostres PCM16 = 4096 bytes = 128 ms a 16 kHz. */
const CHUNK_BYTES = 4096;
/** Per davall d'este RMS (~-46 dBFS) considerem que el bloc no té veu. */
const VOICE_RMS = 0.005;
const QUIET_DB = -45;
const LOUD_DB = -6;

const el = (id) => document.getElementById(id);
const ui = {
  status: el('status'), engine: el('engine'), toggle: el('toggle'), endTurn: el('endTurn'),
  clear: el('clear'), phrases: el('phrases'), live: el('live'), finals: el('finals'),
  audioHint: el('audioHint'), log: el('log'), mState: el('mState'), mAudio: el('mAudio'),
  mFirst: el('mFirst'), mFinal: el('mFinal'), mCompute: el('mCompute'), mRtf: el('mRtf'),
  mRate: el('mRate'), mSps: el('mSps'), mVoiceDb: el('mVoiceDb'),
  micState: el('micState'), device: el('device'), agc: el('agc'), ns: el('ns'), ec: el('ec'),
  continuous: el('continuous'), meterBar: el('meterBar'), meterPeak: el('meterPeak'),
  levelNow: el('levelNow'), levelPeak: el('levelPeak'), voicePct: el('voicePct'),
  levelVerdict: el('levelVerdict'),
  callBtn: el('callBtn'), callScenario: el('callScenario'), callLevel: el('callLevel'),
  callState: el('callState'), callApi: el('callApi'),
  bargeIn: el('bargeIn'),
};

let socket = null;
let audioContext = null;
let workletNode = null;
let mediaStream = null;
let sampleBuffer = new Float32Array(0);
let micOpen = false;
let turnActive = false;
/** L'usuari vol escoltar: el mode continu el manté encés entre torns. */
let wantAudio = false;
let sentSamples = 0;
let turnStartedAt = 0;
let localFirstPartial = null;

/* Mode trucada: parla amb l'agent del joc consumint la seua API tal com és
   (demo sense token). Res del joc es modifica: el laboratori és el client. */

// Estadístiques del torn (per a saber si al motor li arriba veu o soroll)
let totalBlocks = 0;
let voiceBlocks = 0;
let voiceDbSum = 0;
let voiceDbCount = 0;

// Mesurador de nivell
let levelSmoothed = null;
let peakHold = -100;

const escapeHtml = (text) => String(text)
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

const briefly = (payload) => JSON.stringify(payload).slice(0, 200);

const setStatus = (text, kind = '') => {
  ui.status.textContent = text;
  ui.status.dataset.kind = kind;
};

const setMicState = (text, kind = 'hint') => {
  ui.micState.textContent = text;
  ui.micState.className = kind;
};

const log = (message) => {
  const line = `${new Date().toLocaleTimeString()} ${message}`;
  ui.log.textContent = `${line}\n${ui.log.textContent}`.slice(0, 8000);
};

const toDb = (amplitude) => (amplitude > 0 ? Math.max(-100, 20 * Math.log10(amplitude)) : -100);
const dbToPercent = (db) => Math.max(0, Math.min(100, ((db + 60) / 60) * 100));

const showMetrics = (payload) => {
  ui.mAudio.textContent = `${Math.round(payload.audioMs)} ms`;
  ui.mFirst.textContent = payload.firstPartialMs === null ? '—' : `${payload.firstPartialMs} ms`;
  ui.mFinal.textContent = payload.finalMs === null ? '—' : `${payload.finalMs} ms`;
  ui.mCompute.textContent = `${Math.round(payload.computeMs)} ms`;
  ui.mRtf.textContent = payload.rtf === null ? '—' : String(payload.rtf);
  ui.mRate.textContent = audioContext ? `${audioContext.sampleRate} Hz` : '—';
  if (payload.audioMs === 0) {
    ui.mSps.textContent = '—';
    ui.mVoiceDb.textContent = '—';
  }
};

/* ── Nivell d'entrada ───────────────────────────────────────────────────── */

function updateMeter(rms, peak) {
  const db = toDb(rms);
  levelSmoothed = levelSmoothed === null ? db : levelSmoothed * 0.7 + db * 0.3;
  peakHold = Math.max(peakHold * 0.98, toDb(peak));

  ui.meterBar.style.width = `${dbToPercent(levelSmoothed)}%`;
  ui.meterPeak.style.left = `${dbToPercent(peakHold)}%`;
  ui.levelNow.textContent = `${levelSmoothed.toFixed(1)} dBFS`;
  ui.levelPeak.textContent = `${peakHold.toFixed(1)} dBFS`;

  if (levelSmoothed < QUIET_DB) {
    ui.levelVerdict.className = 'warn';
    ui.levelVerdict.textContent = 'Senyal massa fluix: acosta\'t al micròfon o activa la ganància automàtica. El motor rebrà soroll i inventarà paraules.';
  } else if (levelSmoothed > LOUD_DB) {
    ui.levelVerdict.className = 'bad';
    ui.levelVerdict.textContent = 'Senyal massa alt: pot saturar i distorsionar la parla.';
  } else {
    ui.levelVerdict.className = 'ok';
    ui.levelVerdict.textContent = 'Nivell correcte per al reconeixement.';
  }
}

/** Compta si el bloc duu veu: és l'avís més útil davant d'una transcripció dolenta. */
function trackVoice(rms) {
  totalBlocks += 1;
  if (rms > VOICE_RMS) {
    voiceBlocks += 1;
    voiceDbSum += toDb(rms);
    voiceDbCount += 1;
  }
  if (totalBlocks % 8 === 0) {
    ui.voicePct.textContent = `${Math.round((100 * voiceBlocks) / totalBlocks)}% (${voiceBlocks}/${totalBlocks})`;
  }
}

function voiceSummary() {
  return {
    percent: totalBlocks ? Math.round((100 * voiceBlocks) / totalBlocks) : 0,
    averageDb: voiceDbCount ? voiceDbSum / voiceDbCount : null,
  };
}

function resetTurnStats() {
  totalBlocks = 0;
  voiceBlocks = 0;
  voiceDbSum = 0;
  voiceDbCount = 0;
  sentSamples = 0;
  turnStartedAt = performance.now();
  localFirstPartial = null;
  ui.voicePct.textContent = '—';
}

/** Mostres de 16 kHz per segon real: ha de rondar 16.000. */
function samplesPerSecond() {
  const elapsed = (performance.now() - turnStartedAt) / 1000;
  return elapsed > 0.5 ? sentSamples / elapsed : null;
}

/* ── Àudio: micròfon → PCM16 mono 16 kHz ─────────────────────────────────── */

/** Interpolació lineal per quan el navegador no respecta els 16 kHz demanats. */
function resample(input, inputRate, outputRate) {
  if (inputRate === outputRate) return input;
  const ratio = inputRate / outputRate;
  const output = new Float32Array(Math.floor(input.length / ratio));
  for (let index = 0; index < output.length; index += 1) {
    const position = index * ratio;
    const left = Math.floor(position);
    const fraction = position - left;
    const a = input[left] ?? 0;
    const b = input[left + 1] ?? a;
    output[index] = a + (b - a) * fraction;
  }
  return output;
}

function sendPcm16(samples) {
  if (!turnActive || !socket || socket.readyState !== WebSocket.OPEN) return;
  const pcm = new Int16Array(samples.length);
  for (let index = 0; index < samples.length; index += 1) {
    const value = Math.max(-1, Math.min(1, samples[index]));
    pcm[index] = value < 0 ? value * 0x8000 : value * 0x7fff;
  }
  socket.send(pcm.buffer);
  sentSamples += pcm.length;
  ui.mAudio.textContent = `${Math.round((sentSamples / TARGET_RATE) * 1000)} ms`;
}

function pushSamples(samples) {
  const merged = new Float32Array(sampleBuffer.length + samples.length);
  merged.set(sampleBuffer);
  merged.set(samples, sampleBuffer.length);
  sampleBuffer = merged;

  const chunkSamples = CHUNK_BYTES / 2;
  while (sampleBuffer.length >= chunkSamples) {
    sendPcm16(sampleBuffer.subarray(0, chunkSamples));
    sampleBuffer = sampleBuffer.slice(chunkSamples);
  }
}

/** Un bloc del worklet: sempre mesurem el nivell; només enviem si hi ha torn. */
function handleAudioBlock(block) {
  updateMeter(block.rms, block.peak);
  // Barge-in: si l'agent està parlant i el micròfon rep veu (no altaveu, gràcies
  // a la cancel·lació d'eco), 2 blocs seguits (~256 ms) tallen la reproducció.
  // Només si el interruptor «barge-in» està actiu.
  if (ui.bargeIn.checked && call.active && call.audio && call.abortAudio) {
    call.barge.streak = block.rms > VOICE_RMS ? call.barge.streak + 1 : 0;
    if (call.barge.streak >= 2 && call.abortAudio) {
      call.barge.streak = 0;
      call.abortAudio('has interromput l\'agent');
    }
  }
  // Durant la resposta de l'agent no enviem res: el seu àudio pels altaveus
  // no ha de tornar a entrar al reconeixedor.
  if (!turnActive || call.paused) return;
  trackVoice(block.rms);
  pushSamples(resample(block.samples, audioContext.sampleRate, TARGET_RATE));
}

/* ── Micròfon ───────────────────────────────────────────────────────────── */

async function listDevices() {
  const devices = (await navigator.mediaDevices.enumerateDevices())
    .filter((device) => device.kind === 'audioinput');
  const current = ui.device.value;
  ui.device.innerHTML = '';
  devices.forEach((device, index) => {
    const option = document.createElement('option');
    option.value = device.deviceId;
    option.textContent = device.label || `Micròfon ${index + 1}`;
    ui.device.append(option);
  });
  if (current) ui.device.value = current;
}

async function openMic() {
  if (micOpen) return true;

  const deviceId = ui.device.value;
  const constraints = {
    audio: {
      channelCount: 1,
      echoCancellation: ui.ec.checked,
      noiseSuppression: ui.ns.checked,
      autoGainControl: ui.agc.checked,
      ...(deviceId ? { deviceId: { exact: deviceId } } : {}),
    },
  };

  try {
    mediaStream = await navigator.mediaDevices.getUserMedia(constraints);
  } catch (error) {
    setStatus('permís de micròfon denegat', 'error');
    setMicState(`No hem pogut obrir el micròfon: ${error.name}. Revisa els permisos del navegador.`, 'bad');
    log(`ERROR d'accés al micròfon: ${error.name}`);
    return false;
  }

  audioContext = new AudioContext({ sampleRate: TARGET_RATE });
  if (audioContext.state === 'suspended') await audioContext.resume();
  await audioContext.audioWorklet.addModule('/worklet/pcm16-processor.js');

  workletNode = new AudioWorkletNode(audioContext, 'pcm16-capture');
  workletNode.port.onmessage = (event) => handleAudioBlock(event.data);

  audioContext.createMediaStreamSource(mediaStream).connect(workletNode);
  // El node no es processa si no arriba a la destinació: hi va amb guany 0 per
  // no realimentar l'altaveu.
  const silence = audioContext.createGain();
  silence.gain.value = 0;
  workletNode.connect(silence).connect(audioContext.destination);

  micOpen = true;
  levelSmoothed = null;
  resetPeakHold();
  await listDevices();

  const track = mediaStream.getAudioTracks()[0];
  const settings = track ? track.getSettings() : {};
  log(
    `micròfon obert: ${track?.label || 'dispositiu per defecte'}`
    + ` · context=${audioContext.sampleRate} Hz`
    + (settings.sampleRate ? ` · dispositiu=${settings.sampleRate} Hz` : '')
    + ` · agc=${ui.agc.checked} ns=${ui.ns.checked} ec=${ui.ec.checked}`,
  );
  ui.audioHint.textContent = audioContext.sampleRate === TARGET_RATE
    ? 'Àudio a 16 kHz mono PCM16 (el que espera Vosk).'
    : `El navegador ha obert l'àudio a ${audioContext.sampleRate} Hz: resamplem a 16 kHz; l'aliasing pot degradar la transcripció.`;
  return true;
}

function resetPeakHold() {
  peakHold = -100;
  ui.meterPeak.style.left = '0%';
}

async function closeMic() {
  if (workletNode) {
    workletNode.port.onmessage = null;
    workletNode.disconnect();
    workletNode = null;
  }
  if (mediaStream) {
    for (const track of mediaStream.getTracks()) track.stop();
    mediaStream = null;
  }
  if (audioContext) {
    await audioContext.close();
    audioContext = null;
  }
  micOpen = false;
  sampleBuffer = new Float32Array(0);
  levelSmoothed = null;
  resetPeakHold();
  ui.meterBar.style.width = '0%';
  ui.levelNow.textContent = '— dBFS';
  ui.levelPeak.textContent = '— dBFS';
}

/** Canviar de dispositiu o de filtres no ha de tallar el torn. */
async function reopenMic(reason) {
  log(`reobrint el micròfon (${reason}); el torn continua obert`);
  await closeMic();
  await openMic();
}

/* ── WebSocket amb el laboratori ────────────────────────────────────────── */

function connect() {
  const scheme = location.protocol === 'https:' ? 'wss' : 'ws';
  socket = new WebSocket(`${scheme}://${location.host}/ws/transcribe`);
  socket.binaryType = 'arraybuffer';

  socket.onopen = () => setStatus('connectat', 'ok');
  socket.onerror = () => setStatus('error de connexió', 'error');
  socket.onmessage = (event) => handleMessage(JSON.parse(event.data));

  socket.onclose = () => {
    turnActive = false;
    setStatus('desconnectat');
    // El servidor tanca la sessió després de cada torn: reconnectem i, si
    // l'usuari vol seguir escoltant (mode continu), el torn es reobri sol.
    setTimeout(connect, 1200);
  };
}

function handleMessage(payload) {
  switch (payload.type) {
    case 'ready':
      ui.engine.textContent = `motor: ${payload.provider} · ${payload.sampleRate} Hz`;
      ui.toggle.disabled = false;
      log(`connectat al laboratori (${payload.provider})`);
      if (wantAudio && !turnActive) void openTurn();
      break;
    case 'partial':
      if (localFirstPartial === null) {
        localFirstPartial = payload.atMs;
        ui.mFirst.textContent = `${payload.atMs} ms`;
      }
      ui.live.innerHTML = `${escapeHtml(payload.text)} <span class="pending">…</span>`;
      break;
    case 'final': {
      ui.live.innerHTML = '<span class="pending">—</span>';
      const item = document.createElement('li');
      item.innerHTML = `${escapeHtml(payload.text)}<time>${payload.atMs} ms</time>`;
      ui.finals.prepend(item);
      log(`final: "${payload.text}" (${payload.atMs} ms, còmput ${payload.latencyMs} ms)`);
      if (call.active) void handleCallTurn(payload.text);
      break;
    }
    case 'metrics':
      showMetrics(payload);
      reportTurnDiagnostics();
      if (wantAudio) {
        // L'usuari encara vol escoltar: o torn nou automàtic (mode continu),
        // o cal reiniciar-lo a mà.
        if (ui.continuous.checked) log('mode continu: s\'obrirà un torn nou automàticament');
        else stopListening(false);
      }
      break;
    case 'error':
      setStatus('error del motor', 'error');
      log(`ERROR: ${payload.message}`);
      ui.live.innerHTML = `<span class="pending">${escapeHtml(payload.message)}</span>`;
      break;
    default:
      log(`esdeveniment desconegut: ${briefly(payload)}`);
  }
}

/** Bolca al registre les xifres que expliquen una transcripció dolenta. */
function reportTurnDiagnostics() {
  const voice = voiceSummary();
  const sps = samplesPerSecond();
  ui.voicePct.textContent = `${voice.percent}% (${voiceBlocks}/${totalBlocks})`;
  ui.mVoiceDb.textContent = voice.averageDb === null ? '—' : `${voice.averageDb.toFixed(1)} dBFS`;
  ui.mSps.textContent = sps === null ? '—' : `${Math.round(sps)}/s`;

  log(`veu detectada: ${voice.percent}% dels fragments`
    + (voice.averageDb === null ? '' : `, nivell mitjà ${voice.averageDb.toFixed(1)} dBFS`));
  if (sps !== null) {
    log(`mostres enviades: ${Math.round(sps)}/s (esperat ${TARGET_RATE})`);
    if (Math.abs(sps - TARGET_RATE) > TARGET_RATE * 0.1) {
      log('AVÍS: el ritme d\'enviament no quadra amb 16 kHz; revisa el resampling');
    }
  }
  if (voice.percent < 30) {
    log('AVÍS: el motor ha rebut sobretot silenci o soroll: és la causa més probable d\'una transcripció inventada. Revisa el nivell d\'entrada.');
  }
}

/* ── Torn ───────────────────────────────────────────────────────────────── */

function sendConfig() {
  const phrases = ui.phrases.value.split('\n').map((line) => line.trim()).filter(Boolean);
  socket.send(JSON.stringify({
    config: { sample_rate: TARGET_RATE, ...(phrases.length ? { phrase_list: phrases } : {}) },
  }));
  log(`configuració enviada: sample_rate=${TARGET_RATE} frases=${phrases.length}`);
}

async function openTurn() {
  if (!socket || socket.readyState !== WebSocket.OPEN) return;
  if (!(await openMic())) return;

  sendConfig();
  resetTurnStats();
  turnActive = true;

  ui.toggle.textContent = 'Parar';
  ui.toggle.classList.add('rec');
  ui.endTurn.disabled = false;
  ui.mState.textContent = 'escoltant';
  setMicState('Micròfon obert i torn actiu: parla.', 'ok');
  setStatus('escoltant…', 'live');
}

function closeTurn(notify = true) {
  // L'últim fragment incomplet s'envia abans de tancar per no perdre la síl·laba final.
  const pendingBuffer = sampleBuffer;
  sampleBuffer = new Float32Array(0);
  if (pendingBuffer.length) {
    const wasActive = turnActive;
    turnActive = true;
    sendPcm16(pendingBuffer);
    turnActive = wasActive;
  }

  turnActive = false;
  ui.endTurn.disabled = true;
  if (notify && socket && socket.readyState === WebSocket.OPEN) {
    socket.send(JSON.stringify({ eof: 1 }));
    ui.mState.textContent = 'tancant el torn';
    log('fi del torn demanada');
  }
}

function stopListening(notify = true) {
  wantAudio = false;
  closeTurn(notify);
  void closeMic();
  ui.toggle.textContent = 'Escoltar';
  ui.toggle.classList.remove('rec');
  ui.mState.textContent = 'parat';
  setMicState('Micròfon tancat: prem «Escoltar» per tornar a escoltar.', 'hint');
  setStatus('connectat', 'ok');
}

/* ── Mode trucada: l'agent del joc, sense tocar el joc ──────────────────── */

const CHARACTER_BY_SCENARIO = {
  mercat: 'Lluc', oficina: 'Lluc',
  bar: 'Gina', ajuntament: 'Gina', colegi: 'Gina', turisme: 'Gina',
};
const AGENT_GREETING = 'Bon dia! Com et puc ajudar hui?';
/** Base de l'API de l'agent (la del joc). Es pot canviar amb ?agent=… a l'URL. */
const agentBase = new URLSearchParams(location.search).get('agent') || 'http://localhost:3001';
ui.callApi.textContent = agentBase;

const call = {
  active: false, busy: false, paused: false,
  session: null, history: [], audio: null,
  /** Cancel·la la reproducció en curs quan l'usuari interromp (barge-in). */
  abortAudio: null,
  /** Barge-in: blocs de veu consecutius mentre l'agent parla → talla l'àudio. */
  barge: { streak: 0, interrupted: false },
  prevContinuous: true, prevPhrases: '',
};

const setCallState = (text, kind = 'hint') => {
  ui.callState.textContent = text;
  ui.callState.className = kind;
};

const characterName = () => CHARACTER_BY_SCENARIO[ui.callScenario.value] ?? 'l’agent';

const sleepMs = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

/** POST JSON contra l'API de l'agent amb temps límit generós (el TTS triga). */
async function agentFetch(path, body) {
  const response = await fetch(`${agentBase}${path}`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(45_000),
  });
  if (!response.ok) {
    const detail = await response.json().catch(() => ({}));
    throw new Error(detail.error || `l'API ha respost ${response.status}`);
  }
  return response.json();
}

async function ensureCallSession() {
  if (call.session) return call.session;
  const data = await agentFetch('/api/sessions', {
    scenario: ui.callScenario.value,
    level: ui.callLevel.value,
  });
  call.session = data.session_id;
  // La salutació del joc com a primer missatge del personatge: és el context
  // amb què l'agent comença qualsevol conversa real.
  call.history = [{ role: 'character', content_text: AGENT_GREETING }];
  log(`sessió de l'agent oberta: ${ui.callScenario.value} · ${ui.callLevel.value}`);
  return call.session;
}

/** Un torn de trucada: el text reconegut va a /api/turn i la resposta es parla. */
async function handleCallTurn(text) {
  if (call.busy || !call.active || !text.trim()) return;
  call.busy = true;
  call.paused = true;
  wantAudio = false; // mentre l'agent pensa i parla, cap torn nou de reconeixement
  setCallState(`Tu: «${text}» — ${characterName()} pensa…`, 'warn');

  try {
    const sessionId = await ensureCallSession();
    const reply = await agentFetch('/api/turn', {
      session_id: sessionId,
      scenario: ui.callScenario.value,
      level: ui.callLevel.value,
      input_mode: 'text',
      text,
      history: call.history,
      include_audio: true,
    });
    call.history.push(
      { role: 'user', content_text: text },
      { role: 'character', content_text: reply.reply_text },
    );

    const item = document.createElement('li');
    item.className = 'agent';
    item.style.borderLeft = '3px solid currentColor';
    item.style.paddingLeft = '8px';
    item.innerHTML = `<strong>${escapeHtml(characterName())}:</strong> ${escapeHtml(reply.reply_text)}`;
    ui.finals.prepend(item);
    setCallState(`${characterName()}: «${reply.reply_text}»`, 'ok');
    log(`agent (${characterName()}): "${reply.reply_text}"`);

    if (reply.reply_audio_base64) {
      await playBase64(reply.reply_audio_base64, reply.reply_audio_mime_type || 'audio/wav');
    } else {
      // Resposta només escrita: una pausa mínima perquè la conversa respire.
      await sleepMs(1200);
    }
  } catch (error) {
    if (error?.name === 'InterruptedError') {
      // Barge-in: parem l'àudio a mitja frase. El text queda a l'historial com a
      // context, però l'usuari ja ha passat pàgina: escoltem de seguida.
      if (call.active) {
        log("barge-in: l'usuari ha interromput la resposta de l'agent");
        setCallState("T'he escoltat: parla quan vulgues.", 'hint');
      }
    } else {
      const message = error instanceof Error ? error.message : String(error);
      log(`ERROR de l'agent: ${message}`);
      setCallState(`No s'ha pogut parlar amb l'agent: ${message}`, 'bad');
      await sleepMs(1200);
    }
  } finally {
    call.busy = false;
    call.paused = false;
    if (call.active) resumeListening();
  }
}

/**
 * Reproducció interrumpible: l'àudio del personatge es talla a mitja frase si
 * l'usuari comença a parlar (barge-in) o si es penja la trucada.
 */
function playBase64(base64, mimeType) {
  return new Promise((resolve, reject) => {
    const audio = new Audio(`data:${mimeType};base64,${base64}`);
    call.audio = audio;
    const abort = (reason) => {
      call.abortAudio = null;
      if (call.audio === audio) call.audio = null;
      audio.pause();
      audio.src = '';
      call.barge.interrupted = true;
      const interruption = new Error(reason);
      interruption.name = 'InterruptedError';
      reject(interruption);
    };
    call.abortAudio = abort;
    const done = () => {
      if (call.abortAudio === abort) call.abortAudio = null;
      if (call.audio === audio) call.audio = null;
      resolve();
    };
    audio.onended = done;
    audio.onerror = done;
    void audio.play().catch(done);
  });
}

/** Reobre el torn en acabar de parlar l'agent (o delega al proper «ready»). */
function resumeListening() {
  wantAudio = true;
  if (socket && socket.readyState === WebSocket.OPEN && !turnActive) void openTurn();
}

async function startCall() {
  call.active = true;
  call.prevContinuous = ui.continuous.checked;
  call.prevPhrases = ui.phrases.value;
  // El barge-in necessita cancel·lació d'eco: si no, l'altaveu entraria al
  // micròfon i l'agent s'interrompria a si mateix. Es restaura en penjar.
  call.prevEc = ui.ec.checked;
  ui.continuous.checked = true; // la trucada viu del mode continu
  if (ui.bargeIn.checked) {
    ui.ec.checked = true;
    if (micOpen) void reopenMic('cancel·lació d\'eco per al barge-in');
  }
  if (ui.phrases.value.trim()) {
    ui.phrases.value = ''; // lliure dins la trucada: l'agent entén més enllà de la llista
    log('vocabulari restringit suspés durant la trucada');
  }
  ui.callBtn.textContent = '📞 Penjar';
  ui.callBtn.classList.add('rec');
  ui.callScenario.disabled = true;
  ui.callLevel.disabled = true;
  setCallState(
    `En trucada amb ${characterName()} (demo, sense compte). Parla quan vulgues:`
    + ' cada frase es passa a l’agent i et contesta amb veu.',
    'ok',
  );
  log(`mode trucada iniciat contra ${agentBase}`);
  if (!wantAudio && !turnActive) {
    wantAudio = true;
    if (socket && socket.readyState === WebSocket.OPEN) await openTurn();
  }
}

function hangUp() {
  call.active = false;
  call.paused = false;
  // Barge-in: allibera la reproducció en curs (la promesa es resol, no es penja).
  if (call.abortAudio) call.abortAudio('trucada penjada');
  if (call.audio) {
    call.audio.onended = null;
    call.audio.onerror = null;
    call.audio.pause();
    call.audio = null;
  }
  ui.continuous.checked = call.prevContinuous;
  ui.ec.checked = call.prevEc ?? false;
  ui.phrases.value = call.prevPhrases;
  ui.callBtn.textContent = '📞 Trucar';
  ui.callBtn.classList.remove('rec');
  ui.callScenario.disabled = false;
  ui.callLevel.disabled = false;
  stopListening(true);
  setCallState('Trucada penjada. La conversa amb l’agent queda a la llista de transcripció.', 'hint');
  log('mode trucada acabat');
}

ui.callBtn.addEventListener('click', () => {
  if (call.active) hangUp();
  else void startCall();
});

/* ── Controls ───────────────────────────────────────────────────────────── */

ui.toggle.addEventListener('click', () => {
  if (wantAudio || turnActive) {
    stopListening();
    return;
  }
  wantAudio = true;
  if (socket && socket.readyState === WebSocket.OPEN) {
    void openTurn();
  } else {
    setStatus('connectant…');
    log('esperant la connexió per obrir el torn…');
  }
});

ui.endTurn.addEventListener('click', () => closeTurn(true));

for (const [id, control] of [['device', ui.device], ['agc', ui.agc], ['ns', ui.ns], ['ec', ui.ec]]) {
  control.addEventListener('change', () => {
    if (!micOpen) return;
    const label = id === 'device'
      ? `dispositiu: ${ui.device.selectedOptions[0]?.textContent ?? '?'}`
      : `filtre ${id}`;
    void reopenMic(label);
  });
}

ui.clear.addEventListener('click', () => {
  ui.finals.innerHTML = '';
  ui.live.innerHTML = '<span class="pending">—</span>';
  ui.log.textContent = '';
  showMetrics({ audioMs: 0, firstPartialMs: null, finalMs: null, computeMs: 0, rtf: null });
});

/* ── Transcripció de fitxers: puja un àudio, tria motor, veu el text ──── */
// Tot passa al navegador + /api/transcribe: cap altre endpoint nou.

const fileUi = {
  input: el('fileInput'), provider: el('fileProvider'), btn: el('transcribeBtn'),
  state: el('fileState'), audio: el('fileAudio'), text: el('fileText'),
  segments: el('fileSegments'), metrics: el('fileMetrics'),
  compareBtn: el('compareBtn'), compareOut: el('compareOut'),
};
/** WAV 16 kHz mono ja llest per a enviar (es guarda per al comparador A/B). */
let fileWavBytes = null;

const setFileState = (text, kind = 'hint') => {
  fileUi.state.textContent = text;
  fileUi.state.className = kind;
};

/** Qualsevol àudio (mp3, ogg, webm, wav…) → WAV PCM16 mono 16 kHz. */
async function fileToWav16k(file) {
  const raw = await file.arrayBuffer();
  const OfflineContext = window.OfflineAudioContext || window.webkitOfflineAudioContext;
  // Primer el descodifiquem tal com és (el navegador sap obrir quasi tot).
  const decoded = await new OfflineContext(1, 1, 44100).decodeAudioData(raw.slice(0));
  const channel = decoded.getChannelData(0);
  // A mono: si duu dos canals, mitjana (el segon només si hi és).
  let mono = channel;
  if (decoded.numberOfChannels > 1) {
    const other = decoded.getChannelData(1);
    mono = new Float32Array(channel.length);
    for (let i = 0; i < mono.length; i += 1) mono[i] = (channel[i] + other[i]) / 2;
  }
  // Resample a 16 kHz amb la mateixa interpolació del micròfon en directe.
  const resampled = resample(mono, decoded.sampleRate, TARGET_RATE);
  // Capçalera WAV de 44 bytes + PCM16.
  const buffer = new ArrayBuffer(44 + resampled.length * 2);
  const view = new DataView(buffer);
  const writeAscii = (offset, text) => {
    for (let i = 0; i < text.length; i += 1) view.setUint8(offset + i, text.charCodeAt(i));
  };
  writeAscii(0, 'RIFF');
  view.setUint32(4, 36 + resampled.length * 2, true);
  writeAscii(8, 'WAVE');
  writeAscii(12, 'fmt ');
  view.setUint32(16, 16, true);
  view.setUint16(20, 1, true);
  view.setUint16(22, 1, true);
  view.setUint32(24, TARGET_RATE, true);
  view.setUint32(28, TARGET_RATE * 2, true);
  view.setUint16(32, 2, true);
  view.setUint16(34, 16, true);
  writeAscii(36, 'data');
  view.setUint32(40, resampled.length * 2, true);
  for (let i = 0; i < resampled.length; i += 1) {
    const value = Math.max(-1, Math.min(1, resampled[i]));
    view.setInt16(44 + i * 2, value < 0 ? value * 0x8000 : value * 0x7fff, true);
  }
  return new Uint8Array(buffer);
}

async function transcribeWav(wavBytes, provider) {
  const response = await fetch(`/api/transcribe?provider=${encodeURIComponent(provider)}&words=1`, {
    method: 'POST',
    headers: { 'content-type': 'audio/wav' },
    body: wavBytes,
    signal: AbortSignal.timeout(300_000),
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(body.error || `el servidor ha respost ${response.status}`);
  return body;
}

const formatTime = (ms) => `${(ms / 1000).toFixed(1)}s`;

function showTranscription(result) {
  fileUi.text.textContent = result.text || '(sense text)';
  fileUi.segments.innerHTML = '';
  for (const segment of result.segments ?? []) {
    const item = document.createElement('li');
    const jump = document.createElement('button');
    jump.textContent = '▶';
    jump.title = `Escolta des de ${formatTime(segment.startMs)}`;
    jump.addEventListener('click', () => {
      fileUi.audio.currentTime = segment.startMs / 1000;
      void fileUi.audio.play().catch(() => {});
    });
    const time = document.createElement('time');
    time.textContent = `${formatTime(segment.startMs)}–${formatTime(segment.endMs)}`;
    item.append(jump, time, document.createTextNode(segment.text));
    fileUi.segments.append(item);
  }
  const secs = result.audioSecs ?? 0;
  const rtf = secs > 0 ? (result.computeMs / 1000 / secs).toFixed(3) : '—';
  fileUi.metrics.textContent = `motor ${result.provider} (${result.model ?? '?'}) · `
    + `còmput ${Math.round(result.computeMs)} ms · àudio ${secs}s · RTF ${rtf} · `
    + `${(result.segments ?? []).length} segments · ${(result.words ?? []).length} paraules`;
  log(`fitxer transcrit amb ${result.provider}: "${String(result.text).slice(0, 80)}"`);
}

fileUi.btn.addEventListener('click', async () => {
  const file = fileUi.input.files?.[0];
  if (!file) {
    setFileState('Tria un exemple de dalt o puja un fitxer propi.', 'warn');
    return;
  }
  fileUi.btn.disabled = true;
  setFileState(`Convertint «${file.name}» a 16 kHz…`, 'warn');
  try {
    fileWavBytes = await fileToWav16k(file);
    fileUi.audio.src = URL.createObjectURL(new Blob([fileWavBytes], { type: 'audio/wav' }));
    fileUi.audio.hidden = false;
    const provider = fileUi.provider.value;
    setFileState(`Transcrivint amb ${provider}… (el model gran triga uns segons)`, 'warn');
    const result = await transcribeWav(fileWavBytes, provider);
    showTranscription(result);
    setFileState('Transcripció llesta. Prem ▶ per escoltar cada segment.', 'ok');
  } catch (error) {
    setFileState(`No hem pogut transcriure: ${error.message}`, 'bad');
    log(`ERROR de fitxer: ${error.message}`);
  } finally {
    fileUi.btn.disabled = false;
  }
});

/** Comparador A/B: el mateix WAV pels dos motors, taula costat a costat. */
fileUi.compareBtn.addEventListener('click', async () => {
  if (!fileWavBytes) {
    setFileState('Transcriu primer un fitxer: el comparador reutilitza el seu WAV.', 'warn');
    return;
  }
  fileUi.compareBtn.disabled = true;
  fileUi.compareOut.innerHTML = '<p class="hint">Comparant… (Aina triga uns segons)</p>';
  try {
    const [aina, vosk] = await Promise.all([
      transcribeWav(fileWavBytes, 'aina'),
      transcribeWav(fileWavBytes, 'vosk-batch'),
    ]);
    const row = (label, result) => {
      const secs = result.audioSecs ?? 0;
      const rtf = secs > 0 ? (result.computeMs / 1000 / secs).toFixed(3) : '—';
      return `<tr><td><strong>${label}</strong></td>`
        + `<td>${escapeHtml(result.text || '—')}</td>`
        + `<td>${Math.round(result.computeMs)} ms (RTF ${rtf})</td></tr>`;
    };
    fileUi.compareOut.innerHTML = `<table class="compare">
      <tr><th>Motor</th><th>Text</th><th>Còmput</th></tr>
      ${row('Aina', aina)}${row('Vosk', vosk)}
    </table>`;
    log(`comparador: aina="${String(aina.text).slice(0, 60)}" vosk="${String(vosk.text).slice(0, 60)}"`);
  } catch (error) {
    fileUi.compareOut.innerHTML = `<p class="bad">No hem pogut comparar: ${escapeHtml(error.message)}</p>`;
  } finally {
    fileUi.compareBtn.disabled = false;
  }
});

/** Exemples del servidor: un clic els carrega i transcriu sense buscar res. */
document.querySelectorAll('#sampleRow .sample').forEach((button) => {
  button.addEventListener('click', async () => {
    const url = button.dataset.sample;
    const name = url.split('/').pop();
    fileUi.btn.disabled = true;
    fileUi.compareBtn.disabled = true;
    setFileState(`Carregant l'exemple «${name}»…`, 'warn');
    try {
      const response = await fetch(url, { signal: AbortSignal.timeout(30_000) });
      if (!response.ok) throw new Error(`l'exemple ha respost ${response.status}`);
      // Ja són WAV 16 kHz mono: s'envien tal qual, sense reconvertir.
      fileWavBytes = new Uint8Array(await response.arrayBuffer());
      fileUi.audio.src = url;
      fileUi.audio.hidden = false;
      fileUi.input.value = '';
      const provider = fileUi.provider.value;
      setFileState(`Transcrivint «${name}» amb ${provider}…`, 'warn');
      const result = await transcribeWav(fileWavBytes, provider);
      showTranscription(result);
      setFileState(`«${name}» llesta. Canvia de motor o prem «Comparar Aina vs Vosk».`, 'ok');
    } catch (error) {
      setFileState(`No hem pogut carregar l'exemple: ${error.message}`, 'bad');
      log(`ERROR d'exemple: ${error.message}`);
    } finally {
      fileUi.btn.disabled = false;
      fileUi.compareBtn.disabled = false;
    }
  });
});

showMetrics({ audioMs: 0, firstPartialMs: null, finalMs: null, computeMs: 0, rtf: null });
listDevices().catch(() => log('no hem pogut llistar els dispositius d\'entrada'));
connect();