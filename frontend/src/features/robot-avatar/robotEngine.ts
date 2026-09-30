/**
 * [robot-avatar] Motor three.js de l'avatar. Es carrega amb import() dinàmic
 * des de RobotAvatar.tsx, de manera que three.js només es descarrega quan hi
 * ha un robot en pantalla (no engrandix el bundle principal).
 */
import * as THREE from 'three';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';
import { RoomEnvironment } from 'three/examples/jsm/environments/RoomEnvironment.js';
import {
  IDLE_BODY_CLIP, LAYER_BONES, STATE_CLIPS, STATE_EYE_COLOR, TALK_CLIP,
  type RobotLayer, type RobotState,
} from './states';

export type RobotEngineOptions = {
  modelUrl: string;
  /** Posició de la càmera (Y amunt) i punt on mira. */
  cameraPosition?: [number, number, number];
  cameraTarget?: [number, number, number];
  fov?: number;
};

export type RobotEngine = {
  setState: (state: RobotState) => void;
  setTalking: (talking: boolean) => void;
  dispose: () => void;
};

const FADE = 0.35;

export async function createRobotEngine(container: HTMLElement, opts: RobotEngineOptions): Promise<RobotEngine> {
  const reducedMotion = window.matchMedia?.('(prefers-reduced-motion: reduce)').matches ?? false;

  const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, powerPreference: 'low-power' });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
  renderer.outputColorSpace = THREE.SRGBColorSpace;
  renderer.toneMapping = THREE.NeutralToneMapping;
  renderer.toneMappingExposure = 1.0;
  renderer.setClearColor(0x000000, 0);
  renderer.domElement.style.width = '100%';
  renderer.domElement.style.height = '100%';
  renderer.domElement.style.display = 'block';
  container.appendChild(renderer.domElement);

  const scene = new THREE.Scene();
  const pmrem = new THREE.PMREMGenerator(renderer);
  const envTex = pmrem.fromScene(new RoomEnvironment(), 0.04).texture;
  scene.environment = envTex;
  scene.environmentIntensity = 0.4;

  const key = new THREE.DirectionalLight(0xfff4e8, 2.4);
  key.position.set(-3.5, 5, 4.5);
  const fill = new THREE.DirectionalLight(0xdbe9ff, 0.9);
  fill.position.set(4.5, 2, 3.5);
  const rim = new THREE.DirectionalLight(0xffe2b0, 1.6);
  rim.position.set(0, 4.5, -4.5);
  scene.add(key, fill, rim, new THREE.HemisphereLight(0xffffff, 0xb9c7e6, 0.6));

  const camera = new THREE.PerspectiveCamera(opts.fov ?? 33, 1, 0.1, 50);
  const [cx, cy, cz] = opts.cameraPosition ?? [2.1, 2.3, 8.2];
  const [tx, ty, tz] = opts.cameraTarget ?? [0.05, 1.5, 0];
  camera.position.set(cx, cy, cz);
  camera.lookAt(tx, ty, tz);

  const gltf = await new GLTFLoader().loadAsync(opts.modelUrl);
  const model = gltf.scene;
  scene.add(model);

  // Materials que canvien segons l'estat.
  let faceMat: THREE.MeshStandardMaterial | undefined;
  let antennaMat: THREE.MeshStandardMaterial | undefined;
  model.traverse(o => {
    const mesh = o as THREE.Mesh;
    if (!mesh.isMesh) return;
    const m = mesh.material as THREE.MeshStandardMaterial;
    // La intensitat del GLB (pensada per a Blender) satura a blanc en three.js; la rebaixem perquè es veja el color.
    if (m.name === 'Ull_Brillant') { faceMat = m; m.emissiveIntensity = 1.1; }
    if (m.name === 'Llum_Antena') { antennaMat = m; m.emissiveIntensity = 1.4; }
    if (m.name === 'Brillo' || m.name === 'Galta') m.emissiveIntensity = 1;
    // Menys reflex de l'entorn en la pantalla perquè no tape la cara quan el cap mira amunt.
    if (m.name === 'Pantalla') {
      m.envMapIntensity = 0.25;
      const phys = m as THREE.MeshPhysicalMaterial;
      m.roughness = 0.4;
      if (phys.isMeshPhysicalMaterial) { phys.clearcoat = 0.25; phys.clearcoatRoughness = 0.35; }
    }
  });
  const antennaBase = antennaMat?.emissiveIntensity ?? 1.4;
  const targetEye = new THREE.Color(STATE_EYE_COLOR.idle);

  // Cada clip exportat conté pistes de tots els ossos; ens quedem només amb les de la seua capa.
  const mixer = new THREE.AnimationMixer(model);
  const actions = new Map<string, THREE.AnimationAction>();
  for (const clip of gltf.animations) {
    const layer = clip.name.split('_')[0] as RobotLayer;
    const bones = LAYER_BONES[layer];
    if (!bones) continue;
    const filtered = new THREE.AnimationClip(
      clip.name,
      clip.duration,
      clip.tracks.filter(t => bones.includes(t.name.split('.')[0])),
    );
    actions.set(clip.name, mixer.clipAction(filtered));
  }

  const current: Partial<Record<RobotLayer, THREE.AnimationAction>> = {};
  const play = (layer: RobotLayer, name: string, once = false) => {
    const next = actions.get(name);
    if (!next || current[layer] === next) return;
    next.reset();
    next.setLoop(once ? THREE.LoopOnce : THREE.LoopRepeat, Infinity);
    next.clampWhenFinished = once;
    next.enabled = true;
    next.setEffectiveWeight(1);
    next.play();
    const prev = current[layer];
    if (prev) prev.crossFadeTo(next, FADE, false);
    else next.fadeIn(FADE);
    current[layer] = next;
  };

  let state: RobotState = 'idle';
  let talking = false;
  let faceMouth = STATE_CLIPS.idle.mouth;

  mixer.addEventListener('finished', e => {
    const finished = (e as unknown as { action: THREE.AnimationAction }).action;
    if (finished === current.body) play('body', IDLE_BODY_CLIP);
  });

  const setState = (s: RobotState) => {
    state = s;
    const clips = STATE_CLIPS[s];
    const body = reducedMotion && clips.bodyOnce ? IDLE_BODY_CLIP : clips.body;
    if (current.body && current.body === actions.get(body)) {
      // Repetix el gest d'un sol ús (p. ex. dos encerts seguits).
      if (clips.bodyOnce) current.body.reset().play();
    } else {
      play('body', body, !!clips.bodyOnce && !reducedMotion);
    }
    play('eyes', clips.eyes);
    faceMouth = clips.mouth;
    play('mouth', talking ? TALK_CLIP : faceMouth);
    targetEye.set(STATE_EYE_COLOR[s]);
  };

  const setTalking = (t: boolean) => {
    talking = t;
    play('mouth', t ? TALK_CLIP : faceMouth);
  };

  setState('idle');
  if (reducedMotion) mixer.timeScale = 0.5;

  // Mida i bucle de render (s'atura quan no es veu).
  const resize = () => {
    const w = container.clientWidth || 1;
    const h = container.clientHeight || 1;
    renderer.setSize(w, h, false);
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
  };
  resize();
  const ro = new ResizeObserver(resize);
  ro.observe(container);

  let visible = true;
  const io = new IntersectionObserver(([entry]) => { visible = entry.isIntersecting; });
  io.observe(container);

  const timer = new THREE.Timer();
  let raf = 0;
  let elapsed = 0;
  const tick = () => {
    raf = requestAnimationFrame(tick);
    timer.update();
    const dt = Math.min(timer.getDelta(), 0.25);
    if (!visible || document.hidden) return;
    elapsed += dt;
    mixer.update(dt);
    if (faceMat) faceMat.emissive.lerp(targetEye, Math.min(1, dt * 4));
    if (antennaMat) {
      const speed = state === 'thinking' ? 7 : talking ? 11 : 1.6;
      antennaMat.emissiveIntensity = antennaBase * (0.55 + 0.45 * (0.5 + 0.5 * Math.sin(elapsed * speed)));
    }
    renderer.render(scene, camera);
  };
  tick();

  const dispose = () => {
    cancelAnimationFrame(raf);
    ro.disconnect();
    io.disconnect();
    mixer.stopAllAction();
    model.traverse(o => {
      const mesh = o as THREE.Mesh;
      if (!mesh.isMesh) return;
      mesh.geometry.dispose();
      (Array.isArray(mesh.material) ? mesh.material : [mesh.material]).forEach(m => m.dispose());
    });
    envTex.dispose();
    pmrem.dispose();
    renderer.dispose();
    renderer.domElement.remove();
  };

  return { setState, setTalking, dispose };
}
