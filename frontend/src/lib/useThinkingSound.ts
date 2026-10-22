import { useEffect } from 'react';

const THINKING_SOUND = '/audio/robot_thinking.mp3';

/** Fa sonar en bucle, de fons i baixet, el so del robot mentre `active` és true (pensant). */
export function useThinkingSound(active: boolean) {
  useEffect(() => {
    if (!active) return;
    const audio = new Audio(THINKING_SOUND);
    audio.loop = true;
    audio.volume = 0.25;
    void audio.play().catch(() => {});
    return () => {
      audio.pause();
      audio.currentTime = 0;
    };
  }, [active]);
}
