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
  // Versions del robot amb roba de l'escenari (GLB + imatge mentre carrega);
  // la resta d'escenaris usen `modelUrl` i `fallbackUrl`. Font: assets-src/robot-avatar/.
  scenarioOutfits: {
    mercat: { // barret de palla, davantal i taronja
      modelUrl: '/avatar-robot/robot-mercat.glb',
      fallbackUrl: '/avatar-robot/robot-mercat.webp',
    },
    farmacia: { // bata blanca, creu verda, ulleres i caixa de medicaments
      modelUrl: '/avatar-robot/robot-farmacia.glb',
      fallbackUrl: '/avatar-robot/robot-farmacia.webp',
    },
    forn: { // gorro de forner, davantal de pitet i barra de pa
      modelUrl: '/avatar-robot/robot-forn.glb',
      fallbackUrl: '/avatar-robot/robot-forn.webp',
    },
    oficina: { // americana blava, camisa, mocador de butxaca, targeta i tassa de café
      modelUrl: '/avatar-robot/robot-oficina.glb',
      fallbackUrl: '/avatar-robot/robot-oficina.webp',
    },
    a2_identificacio: { // festa d'aniversari de Núria: americana granat, pestanyes, perles i copa de cava
      modelUrl: '/avatar-robot/robot-a2_identificacio.glb',
      fallbackUrl: '/avatar-robot/robot-a2_identificacio.webp',
    },
    a2_casa: { // Xavi, nou company de pis: dessuadora oberta, gorra i claus del pis
      modelUrl: '/avatar-robot/robot-a2_casa.glb',
      fallbackUrl: '/avatar-robot/robot-a2_casa.webp',
    },
    a2_activitats: { // Toni, amic del gimnàs: samarreta de tirants, pantaló curt, cinta, tovallola i pesa
      modelUrl: '/avatar-robot/robot-a2_activitats.glb',
      fallbackUrl: '/avatar-robot/robot-a2_activitats.webp',
    },
    a2_menjar: { // Empar, propietària del restaurant: armilla, brusa, fular, pestanyes, arracades i la carta
      modelUrl: '/avatar-robot/robot-a2_menjar.glb',
      fallbackUrl: '/avatar-robot/robot-a2_menjar.webp',
    },
    a2_servicis: { // Lídia, dependenta dels grans magatzems: rebeca, cinta mètrica, placa i pestanyes
      modelUrl: '/avatar-robot/robot-a2_servicis.glb',
      fallbackUrl: '/avatar-robot/robot-a2_servicis.webp',
    },
    a2_faena: { // Sílvia, antiga companya de l'institut: jaqueta texana, top de ratlles, ulleres de sol, bossa i mòbil
      modelUrl: '/avatar-robot/robot-a2_faena.glb',
      fallbackUrl: '/avatar-robot/robot-a2_faena.webp',
    },
    a2_clima: { // Liam, amic irlandés: impermeable verd, jersei de punt, gorra plana de tweed i paraigua
      modelUrl: '/avatar-robot/robot-a2_clima.glb',
      fallbackUrl: '/avatar-robot/robot-a2_clima.webp',
    },
    a2_viatges: { // Jordi, recepcionista de l'hotel: uniforme amb ribets daurats, llacet, placa i clau de l'habitació
      modelUrl: '/avatar-robot/robot-a2_viatges.glb',
      fallbackUrl: '/avatar-robot/robot-a2_viatges.webp',
    },
  } as Record<string, { modelUrl: string; fallbackUrl: string }>,
} as const;

export type RobotPlace = keyof typeof ROBOT_AVATAR.places;

export const isRobotAvatarEnabled = (place: RobotPlace) => ROBOT_AVATAR.enabled && ROBOT_AVATAR.places[place];

export const robotAssets = (scenario?: string) =>
  (scenario && ROBOT_AVATAR.scenarioOutfits[scenario]) ||
  { modelUrl: ROBOT_AVATAR.modelUrl, fallbackUrl: ROBOT_AVATAR.fallbackUrl };
