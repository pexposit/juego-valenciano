import { useEffect, useRef, useState } from 'react';
import { RobotAvatar } from './RobotAvatar';
import { robotStateFromMood, type RobotState } from './states';
import type { Mood } from '../../lib/types';

/**
 * [robot-avatar] Robot del Dashboard (substituïx avatar_professor.svg).
 * Mentre pensa consulta un diccionari (el tutor pot estar buscant en la GNV) i, quan té la resposta, fa un bot d'alegria.
 * Saluda en aparéixer i quan li passes el ratolí per damunt; fa un bot d'alegria si el cliques (i avisa `onClick`).
 */
export function DashboardRobot({ className = '', size = 400, talking = false, thinking = false, mood = 'neutral', onClick }: { className?: string; size?: number; talking?: boolean; thinking?: boolean; mood?: Mood; onClick?: () => void }) {
  const [state, setState] = useState<RobotState>('wave');
  const [until, setUntil] = useState(Date.now() + 3200);

  useEffect(() => {
    const id = window.setTimeout(() => setState('idle'), Math.max(0, until - Date.now()));
    return () => window.clearTimeout(id);
  }, [until]);

  const trigger = (s: RobotState, ms: number) => {
    setState(s);
    setUntil(Date.now() + ms);
  };

  // Acaba de pensar: content amb la resposta (si no s'ha quedat confús).
  const wasThinking = useRef(thinking);
  useEffect(() => {
    if (wasThinking.current && !thinking && mood !== 'confus') trigger('happy', 2200);
    wasThinking.current = thinking;
  }, [thinking, mood]);

  return (
    <div
      className={className}
      style={{ width: size, height: size, cursor: 'pointer' }}
      onMouseEnter={() => state === 'idle' && trigger('wave', 2400)}
      onClick={() => { trigger('happy', 1600); onClick?.(); }}
    >
      <RobotAvatar state={thinking ? 'reading' : mood === 'confus' ? robotStateFromMood(mood) : state} talking={talking} label="El robot professor" className="h-full w-full" />
    </div>
  );
}
