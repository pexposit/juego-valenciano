import { useEffect, useRef, useState, type CSSProperties } from 'react';
import { ROBOT_AVATAR } from './config';
import type { RobotState } from './states';
import type { RobotEngine, RobotEngineOptions } from './robotEngine';

/**
 * [robot-avatar] Avatar robot 3D animat (three.js + GLB de Blender).
 * Si WebGL no està disponible o el model no carrega, mostra la imatge estàtica.
 */
export function RobotAvatar({
  state = 'idle',
  talking = false,
  className = '',
  style,
  label = 'Avatar robot',
  camera,
}: {
  state?: RobotState;
  talking?: boolean;
  className?: string;
  style?: CSSProperties;
  label?: string;
  camera?: Pick<RobotEngineOptions, 'cameraPosition' | 'cameraTarget' | 'fov'>;
}) {
  const box = useRef<HTMLDivElement>(null);
  const engine = useRef<RobotEngine>();
  const [failed, setFailed] = useState(false);
  const [ready, setReady] = useState(false);
  const latest = useRef({ state, talking });
  latest.current = { state, talking };

  useEffect(() => {
    const el = box.current;
    if (!el) return;
    let cancelled = false;
    let created: RobotEngine | undefined;
    import('./robotEngine')
      .then(({ createRobotEngine }) => createRobotEngine(el, { modelUrl: ROBOT_AVATAR.modelUrl, ...camera }))
      .then(e => {
        if (cancelled) return e.dispose();
        created = e;
        engine.current = e;
        e.setState(latest.current.state);
        e.setTalking(latest.current.talking);
        setReady(true);
      })
      .catch(err => {
        console.warn('[robot-avatar] No s\'ha pogut carregar el robot 3D:', err);
        if (!cancelled) setFailed(true);
      });
    return () => {
      cancelled = true;
      created?.dispose();
      engine.current = undefined;
    };
    // La càmera només es llig en muntar.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => { engine.current?.setState(state); }, [state]);
  useEffect(() => { engine.current?.setTalking(talking); }, [talking]);

  return (
    <div
      ref={box}
      role="img"
      aria-label={label}
      data-robot-state={state}
      data-robot-talking={talking || undefined}
      className={`relative ${className}`}
      style={style}
    >
      {/* Imatge estàtica mentre carrega el 3D, o de manera permanent si falla. */}
      {(failed || !ready) && (
        <img
          src={ROBOT_AVATAR.fallbackUrl}
          alt=""
          aria-hidden="true"
          className="pointer-events-none absolute inset-0 h-full w-full object-contain"
        />
      )}
    </div>
  );
}
