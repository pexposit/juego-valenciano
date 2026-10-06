import { useCallback, useEffect, useRef, useState } from 'react';
import { FEEDBACK_OK, FEEDBACK_RETRY } from './content';
import { randomOf, say, sayAll, sfxBoing, sfxCorrect, stopVoice } from './sound';

/**
 * Comportament comú de les rondes: diu la consigna en començar (i quan es toca
 * l'altaveu), i dona el feedback. Encert: arpa + paraula/felicitació i passa a
 * la següent ronda. Error: «boing», de tant en tant «Torna-ho a provar!», i es
 * pot tornar a intentar sense perdre res. La consigna pot ser una frase o
 * diverses seguides («Primer, toca...», «El gos!», «I després...», «La poma!»).
 */
export function useRound(prompt: string | readonly string[] | undefined, onDone: () => void) {
  const [locked, setLocked] = useState(false); // mentre es celebra un encert
  const done = useRef(false);
  const misses = useRef(0);

  const keys = typeof prompt === 'string' ? prompt : prompt?.join('|');
  const repeat = useCallback(() => {
    if (keys) void sayAll(keys.split('|'));
  }, [keys]);

  useEffect(() => {
    done.current = false;
    setLocked(false);
    const timer = window.setTimeout(repeat, 350);
    return () => {
      window.clearTimeout(timer);
      stopVoice();
    };
  }, [repeat]);

  /** Encert final de la ronda: celebra i, quan acaba l'àudio, passa a la següent. */
  const win = useCallback(async (word?: string) => {
    if (done.current) return;
    done.current = true;
    setLocked(true);
    sfxCorrect();
    await new Promise(r => window.setTimeout(r, 450));
    if (word) await say(word);
    await say(randomOf(FEEDBACK_OK));
    onDone();
  }, [onDone]);

  /** Error suau: boing i, cada dos errors, una frase d'ànim. */
  const miss = useCallback(() => {
    sfxBoing();
    misses.current++;
    if (misses.current % 2 === 0) window.setTimeout(() => void say(randomOf(FEEDBACK_RETRY)), 350);
  }, []);

  return { locked, repeat, win, miss };
}
