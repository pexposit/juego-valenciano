/**
 * Control central de l'àudio de l'app: tot el que sona (àudios dels xats, de les lliçons, de la pràctica, els
 * sons del Nivell 0...) es registra en començar a reproduir-se, i `stopAllAudio()` ho para tot. App.tsx
 * la crida en canviar de pantalla, perquè res continue sonant en una vista que ja no és en pantalla.
 */

const playing = new Set<HTMLMediaElement>();
let installed = false;

/** Fa que cada àudio o vídeo que es reproduïsca quede registrat. Es pot cridar més d'una vegada. */
export function installAudioTracking() {
  if (installed || typeof HTMLMediaElement === 'undefined') return;
  installed = true;
  const originalPlay = HTMLMediaElement.prototype.play;
  HTMLMediaElement.prototype.play = function (this: HTMLMediaElement) {
    if (!playing.has(this)) {
      playing.add(this);
      const forget = () => playing.delete(this);
      this.addEventListener('ended', forget);
      this.addEventListener('pause', forget);
      this.addEventListener('error', forget);
    }
    return originalPlay.call(this);
  };
}

/** Para tot l'àudio que sona (inclosa la veu del navegador). */
export function stopAllAudio() {
  for (const media of [...playing]) media.pause();
  playing.clear();
  window.speechSynthesis?.cancel();
}
