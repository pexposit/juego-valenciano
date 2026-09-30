import type { Mood } from '../../lib/types';

/**
 * [robot-avatar] Estats de l'avatar i clips d'animació (exportats des de Blender
 * en /avatar-robot/robot.glb). L'animació va en tres capes independents perquè
 * es puguen combinar: cos (postura/gest), ulls i boca (parlar substituïx la boca).
 */
export type RobotState = 'idle' | 'wave' | 'happy' | 'confused' | 'thinking';

export type RobotLayer = 'body' | 'eyes' | 'mouth';

/** Ossos que anima cada capa (noms dels ossos del rig de Blender). */
export const LAYER_BONES: Record<RobotLayer, string[]> = {
  body: ['root', 'body', 'head', 'antenna', 'arm_L', 'arm_R'],
  eyes: ['eye_L', 'eye_R'],
  mouth: ['mouth'],
};

type StateClips = { body: string; eyes: string; mouth: string; bodyOnce?: boolean };

export const STATE_CLIPS: Record<RobotState, StateClips> = {
  idle: { body: 'body_idle', eyes: 'eyes_neutral', mouth: 'mouth_neutral' },
  wave: { body: 'body_wave', eyes: 'eyes_happy', mouth: 'mouth_happy' },
  // El bot d'alegria es fa una vegada i després torna a body_idle (la cara continua contenta).
  happy: { body: 'body_happy', eyes: 'eyes_happy', mouth: 'mouth_happy', bodyOnce: true },
  confused: { body: 'body_confused', eyes: 'eyes_confused', mouth: 'mouth_confused' },
  thinking: { body: 'body_thinking', eyes: 'eyes_thinking', mouth: 'mouth_thinking' },
};

export const TALK_CLIP = 'mouth_talk';
export const IDLE_BODY_CLIP = 'body_idle';

/** Color de la llum de la pantalla (ulls + somriure) per estat. */
export const STATE_EYE_COLOR: Record<RobotState, string> = {
  idle: '#4FE3FF',
  wave: '#4FE3FF',
  happy: '#5CFFB0',
  confused: '#FFC24A',
  thinking: '#B794FF',
};

/** Traducció dels estats del xat (Mood del backend) a estats del robot. */
export function robotStateFromMood(mood: Mood, thinking = false): RobotState {
  if (thinking) return 'thinking';
  if (mood === 'content') return 'happy';
  if (mood === 'confus') return 'confused';
  return 'idle';
}
