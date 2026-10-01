import { useEffect, useRef, useState, type CSSProperties } from 'react';
import { ROBOT_AVATAR, robotAssets } from './config';
import type { RobotState } from './states';
import type { RobotEngine, RobotEngineOptions } from './robotEngine';

/**
 * [robot-avatar] Avança la descàrrega de three.js i del robot d'un escenari (GLB + imatge
 * de càrrega) perquè aparega abans en el xat. Sense escenari, el robot normal.
 * Es pot cridar moltes vegades: cada GLB es baixa una sola vegada (fetchRobotModel).
 */
const preloaded = new Set<string>();
export function preloadRobotAvatar(scenario?: string) {
  const { modelUrl } = robotAssets(scenario);
  if (preloaded.has(modelUrl)) return;
  preloaded.add(modelUrl);
  loadRobotAvatar(scenario).catch(() => preloaded.delete(modelUrl)); // si falla, es pot tornar a intentar
}

/** Com preloadRobotAvatar, però es pot esperar: resol quan three.js, el GLB i la imatge
 *  de càrrega de l'escenari ja estan baixats (la pantalla de càrrega de l'escena l'espera). */
export function loadRobotAvatar(scenario?: string): Promise<void> {
  const { modelUrl, fallbackUrl } = robotAssets(scenario);
  const image = new Promise<void>(resolve => {
    const img = new Image();
    img.onload = img.onerror = () => resolve();
    img.src = fallbackUrl;
  });
  const model = import('./robotEngine').then(({ fetchRobotModel, preloadDracoDecoder }) => {
    preloadDracoDecoder();
    return fetchRobotModel(modelUrl);
  });
  return Promise.all([image, model]).then(() => undefined);
}

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
  modelUrl = ROBOT_AVATAR.modelUrl,
  fallbackUrl = ROBOT_AVATAR.fallbackUrl,
}: {
  state?: RobotState;
  talking?: boolean;
  className?: string;
  style?: CSSProperties;
  label?: string;
  camera?: Pick<RobotEngineOptions, 'cameraPosition' | 'cameraTarget' | 'fov'>;
  /** GLB a carregar (p. ex. la versió amb roba de l'escenari). */
  modelUrl?: string;
  /** Imatge mentre carrega el 3D (hauria de coincidir amb `modelUrl`). */
  fallbackUrl?: string;
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
      .then(({ createRobotEngine }) => createRobotEngine(el, { modelUrl, ...camera }))
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
    // La càmera només es llig en muntar; si canvia el model, es torna a crear el motor.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [modelUrl]);

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
          src={fallbackUrl}
          alt=""
          aria-hidden="true"
          className="pointer-events-none absolute inset-0 h-full w-full object-contain"
        />
      )}
    </div>
  );
}
