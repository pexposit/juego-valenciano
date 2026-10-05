import { useEffect, useState } from 'react';
import type { Mood } from '../../lib/types';
import { robotAssets } from './config';
import { RobotAvatar } from './RobotAvatar';
import { robotStateFromMood } from './states';

const GREETING_MS = 2600;

/**
 * [robot-avatar] Substitut de SceneArt per al xat: la foto de l'escenari de fons
 * i el robot al centre. Saluda en entrar i després reflectix l'estat de la conversa:
 *   neutral → idle · content → happy · confus → confused · esperant resposta → thinking
 *   i mou la boca mentre sona l'àudio del personatge.
 */
export function RobotSceneArt({
  scenario, background, mood, thinking = false, talking = false,
}: {
  scenario?: string;
  background: string | null;
  mood: Mood;
  thinking?: boolean;
  talking?: boolean;
}) {
  const [greeting, setGreeting] = useState(true);
  useEffect(() => {
    const id = window.setTimeout(() => setGreeting(false), GREETING_MS);
    return () => window.clearTimeout(id);
  }, []);

  const state = greeting && !thinking ? 'wave' : robotStateFromMood(mood, thinking);

  return (
    <div className="absolute inset-0 overflow-hidden bg-[#FFF9ED]">
      {background && (
        <img
          src={background}
          alt=""
          aria-hidden="true"
          className="absolute inset-0 h-full w-full object-cover opacity-40"
        />
      )}
      <RobotAvatar
        state={state}
        talking={talking}
        {...robotAssets(scenario)}
        label="Robot que conversa amb tu"
        className="robot-avatar-chat absolute left-1/2 top-[22%] aspect-square h-[52%] [@media(max-width:1023px)_and_(orientation:portrait)]:top-[30%] [@media(max-width:1023px)_and_(orientation:portrait)]:h-[36%] [@media(max-height:500px)_and_(orientation:landscape)]:left-[74%] [@media(max-height:500px)_and_(orientation:landscape)]:top-[14%] [@media(max-height:500px)_and_(orientation:landscape)]:h-[56%] max-w-[96vw] -translate-x-1/2"
      />
    </div>
  );
}
