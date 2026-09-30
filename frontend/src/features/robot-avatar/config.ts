/**
 * [robot-avatar] Configuració del mòdul de l'avatar robot 3D.
 *
 * Per a desactivar-lo sense tocar codi:
 *   - tot el mòdul:   VITE_ROBOT_AVATAR=off   (fitxer .env del frontend)
 *   - només un lloc:  posa `false` en `places` ací baix.
 * Amb el mòdul desactivat, l'aplicació torna a mostrar els avatars originals
 * (professor SVG al Dashboard i personatges il·lustrats al Chat).
 */
export const ROBOT_AVATAR = {
  enabled: import.meta.env.VITE_ROBOT_AVATAR !== 'off',
  places: {
    dashboard: true, // substituïx /images/avatar_professor.svg
    chat: true, // substituïx els personatges de SceneArt (mercat, bar, oficina...)
  },
  modelUrl: '/avatar-robot/robot.glb',
  fallbackUrl: '/avatar-robot/robot.png',
} as const;

export type RobotPlace = keyof typeof ROBOT_AVATAR.places;

export const isRobotAvatarEnabled = (place: RobotPlace) => ROBOT_AVATAR.enabled && ROBOT_AVATAR.places[place];
