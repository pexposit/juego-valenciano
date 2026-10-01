// [robot-avatar] Punt d'entrada públic del mòdul. Veure README.md en aquesta carpeta.
export { ROBOT_AVATAR, isRobotAvatarEnabled, robotAssets } from './config';
export { RobotAvatar, preloadRobotAvatar, loadRobotAvatar } from './RobotAvatar';
export { RobotSceneArt } from './RobotSceneArt';
export { DashboardRobot } from './DashboardRobot';
export { robotStateFromMood, type RobotState } from './states';
