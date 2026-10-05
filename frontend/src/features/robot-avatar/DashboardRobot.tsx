import { useEffect, useState } from 'react';
import { RobotAvatar } from './RobotAvatar';
import type { RobotState } from './states';

/**
 * [robot-avatar] Robot del Dashboard (substituïx avatar_professor.svg).
 * Saluda en aparéixer i quan li passes el ratolí per damunt; fa un bot d'alegria si el cliques.
 */
export function DashboardRobot({ className = '', size = 400, talking = false, thinking = false }: { className?: string; size?: number; talking?: boolean; thinking?: boolean }) {
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

  return (
    <div
      className={className}
      style={{ width: size, height: size, cursor: 'pointer' }}
      onMouseEnter={() => state === 'idle' && trigger('wave', 2400)}
      onClick={() => trigger('happy', 1600)}
    >
      <RobotAvatar state={thinking ? 'thinking' : state} talking={talking} label="El robot professor" className="h-full w-full" />
    </div>
  );
}
