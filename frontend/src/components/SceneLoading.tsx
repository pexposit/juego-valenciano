import { useEffect, useState } from 'react';
import type { Resource } from '../lib/types';
import { isRobotAvatarEnabled, loadRobotAvatar } from '../features/robot-avatar'; // [robot-avatar]

// L'indicador només apareix si la càrrega tarda més de SHOW_DELAY_MS (si tot ja està
// en memòria cau, s'entra directament sense parpelleig). Si una baixada va lenta o
// falla, als MAX_MS s'entra igualment a l'escena.
const SHOW_DELAY_MS = 200;
const MAX_MS = 10_000;

const loadImage = (src: string) =>
  new Promise<void>(resolve => {
    const img = new Image();
    img.onload = img.onerror = () => resolve();
    img.src = src;
  });

/**
 * Espera el que necessita una escena abans de mostrar-la: la fila del catàleg
 * (`section`, undefined mentre arriba), la foto de fons i el robot de l'escenari
 * (amb la seua roba). El robot només depén de l'escenari de la URL, així que es
 * comença a baixar alhora que el catàleg. Torna true quan ja s'hi pot entrar.
 */
export function useSceneAssets(scenario: string | undefined, section: Resource | null | undefined) {
  const [robotLoaded, setRobotLoaded] = useState(false);
  const [backgroundLoaded, setBackgroundLoaded] = useState(false);
  const [timedOut, setTimedOut] = useState(false);

  useEffect(() => {
    let cancelled = false;
    setRobotLoaded(false);
    setTimedOut(false);
    const max = window.setTimeout(() => setTimedOut(true), MAX_MS);
    const robot = scenario && isRobotAvatarEnabled('chat') ? loadRobotAvatar(scenario).catch(() => {}) : Promise.resolve();
    robot.then(() => { if (!cancelled) setRobotLoaded(true); });
    return () => { cancelled = true; window.clearTimeout(max); };
  }, [scenario]);

  useEffect(() => {
    if (section === undefined) return;
    let cancelled = false;
    setBackgroundLoaded(false);
    (section?.background ? loadImage(section.background) : Promise.resolve())
      .then(() => { if (!cancelled) setBackgroundLoaded(true); });
    return () => { cancelled = true; };
  }, [section]);

  return (section !== undefined && robotLoaded && backgroundLoaded) || timedOut;
}

/**
 * Espera el que necessita el tauler abans de mostrar-lo: el perfil (`profileReady`,
 * perquè no isca el nom per defecte), el fons de l'aula, la bombolla i el robot.
 * Si alguna baixada va lenta o falla, als MAX_MS s'entra igualment.
 */
export function useDashboardAssets(profileReady: boolean) {
  const [assetsLoaded, setAssetsLoaded] = useState(false);
  const [timedOut, setTimedOut] = useState(false);

  useEffect(() => {
    let cancelled = false;
    const max = window.setTimeout(() => setTimedOut(true), MAX_MS);
    const robot = isRobotAvatarEnabled('dashboard') ? loadRobotAvatar().catch(() => {}) : Promise.resolve();
    Promise.all([loadImage('/images/classroom.jpg'), loadImage('/images/speachBubble.svg'), robot])
      .then(() => { if (!cancelled) setAssetsLoaded(true); });
    return () => { cancelled = true; window.clearTimeout(max); };
  }, []);

  return (profileReady && assetsLoaded) || timedOut;
}

/** Pantalla de càrrega abans d'entrar en una escena del xat o en el tauler. */
export function SceneLoading() {
  const [visible, setVisible] = useState(false);
  useEffect(() => {
    const id = window.setTimeout(() => setVisible(true), SHOW_DELAY_MS);
    return () => window.clearTimeout(id);
  }, []);

  return (
    <main className="grid min-h-screen place-items-center" style={{ background: '#FFF9ED' }}>
      {visible && (
        <div className="flex flex-col items-center gap-4" role="status" aria-live="polite">
          <div className="h-12 w-12 rounded-full border-4 border-teal/20 border-t-teal motion-safe:animate-spin" aria-hidden="true" />
          <p className="text-lg font-extrabold text-teal">Carregant…</p>
        </div>
      )}
    </main>
  );
}
