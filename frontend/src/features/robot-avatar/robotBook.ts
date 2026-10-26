/**
 * [robot-avatar] Diccionari que el robot del tutor llig mentre pensa (estat 'reading').
 * Es construïx amb three.js (no va en els GLB): així el porten totes les versions del robot.
 * Mentre llig, els braços el sostenen, el cap mira les pàgines i, de tant en tant, en passa una.
 */
import * as THREE from 'three';

const PAGE_W = 0.54;
const PAGE_H = 0.7;
const BLOCK = 0.05; // gruix del bloc de fulls de cada costat
const OPEN = 0.16; // angle (rad) de cada mitat del llibre obert en V
const FLIP_EVERY = 2.8; // s entre pàgina i pàgina
const FLIP_TIME = 0.8;

// Posició del llibre respecte de l'os `body` i postura dels braços i el cap (espai del pare de cada os).
const BOOK_POSITION = new THREE.Vector3(0, 0.66, 1.0);
const BOOK_TILT = -0.95; // les pàgines miren amunt i una mica cap a la càmera
const HAND_DIRECTION = new THREE.Vector3(0.22, -0.3, 0.8); // braç esquerre; el dret és simètric
const HEAD_DOWN = 0.28;

/** Pàgina de diccionari: dues columnes de línies grises amb alguna entrada en negreta. */
function pageTexture(): THREE.CanvasTexture {
  const canvas = document.createElement('canvas');
  canvas.width = 256;
  canvas.height = 344;
  const ctx = canvas.getContext('2d')!;
  ctx.fillStyle = '#FBF5E6';
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  let seed = 7;
  const rnd = () => ((seed = (seed * 9301 + 49297) % 233280) / 233280);
  for (const x of [18, 136]) {
    for (let y = 26; y < canvas.height - 18; y += 13) {
      const entry = rnd() < 0.2;
      ctx.fillStyle = entry ? '#3B2A1E' : '#9C948A';
      ctx.fillRect(x + (entry ? 0 : 6), y, entry ? 30 + rnd() * 20 : 60 + rnd() * 40, entry ? 6 : 4);
    }
  }
  ctx.fillStyle = '#A3302A';
  ctx.fillRect(18, 8, 220, 3);
  const texture = new THREE.CanvasTexture(canvas);
  texture.colorSpace = THREE.SRGBColorSpace;
  texture.anisotropy = 4;
  return texture;
}

const smooth = (x: number) => {
  const t = Math.min(1, Math.max(0, x));
  return t * t * (3 - 2 * t);
};

export type RobotBook = {
  /** Cridar després de mixer.update: sobreescriu braços, cap i ulls amb el pes de la lectura. */
  update: (dt: number, elapsed: number, reading: boolean) => void;
  dispose: () => void;
};

export function attachRobotBook(model: THREE.Object3D, reducedMotion: boolean): RobotBook | undefined {
  const body = model.getObjectByName('body');
  const head = model.getObjectByName('head');
  const armL = model.getObjectByName('arm_L');
  const armR = model.getObjectByName('arm_R');
  const eyes = ['eye_L', 'eye_R'].map(n => model.getObjectByName(n)).filter((o): o is THREE.Object3D => !!o);
  if (!body || !head || !armL || !armR) return undefined;

  const texture = pageTexture();
  const paper = new THREE.MeshStandardMaterial({ color: '#F4ECD8', roughness: 0.9 });
  const printed = new THREE.MeshStandardMaterial({ map: texture, roughness: 0.85 });
  const leaf = new THREE.MeshStandardMaterial({ map: texture, roughness: 0.85, side: THREE.DoubleSide });
  const cover = new THREE.MeshStandardMaterial({ color: '#8E2B26', roughness: 0.55, metalness: 0.05 });
  const blockMaterials = [paper, paper, paper, paper, printed, paper]; // la cara +Z és la pàgina impresa

  const book = new THREE.Group();
  book.name = 'Diccionari';
  // Cada mitat ix del llom (x = 0) cap a fora i s'alça una mica: llibre obert en V.
  for (const side of [-1, 1]) {
    const half = new THREE.Group();
    half.rotation.y = side * -OPEN;
    const coverMesh = new THREE.Mesh(new THREE.BoxGeometry(PAGE_W + 0.03, PAGE_H + 0.04, 0.025), cover);
    coverMesh.position.set(side * (PAGE_W + 0.03) / 2, 0, -0.0125);
    const block = new THREE.Mesh(new THREE.BoxGeometry(PAGE_W, PAGE_H, BLOCK), blockMaterials);
    block.position.set(side * PAGE_W / 2, 0, BLOCK / 2);
    half.add(coverMesh, block);
    book.add(half);
  }
  const spine = new THREE.Mesh(new THREE.CylinderGeometry(0.035, 0.035, PAGE_H + 0.04, 12, 1, false, Math.PI / 2, Math.PI), cover);
  spine.position.z = -0.01;
  book.add(spine);
  // Full que es passa: gira sobre el llom de la dreta a l'esquerra.
  const flip = new THREE.Group();
  flip.position.z = BLOCK;
  const flipLeaf = new THREE.Mesh(new THREE.PlaneGeometry(PAGE_W, PAGE_H), leaf);
  flipLeaf.position.x = PAGE_W / 2;
  flip.add(flipLeaf);
  book.add(flip);

  book.position.copy(BOOK_POSITION);
  book.rotation.x = BOOK_TILT;
  book.scale.setScalar(0);
  book.visible = false;
  body.add(book);

  // Postura de sostindre el llibre: cada braç (l'eix local Y apunta a la mà) cap a la vora del llibre.
  const holdPose = (arm: THREE.Object3D, side: number) => {
    const rest = arm.quaternion.clone();
    const from = new THREE.Vector3(0, 1, 0).applyQuaternion(rest);
    const to = HAND_DIRECTION.clone().setX(HAND_DIRECTION.x * side).normalize();
    return new THREE.Quaternion().setFromUnitVectors(from, to).multiply(rest);
  };
  const holdL = holdPose(armL, armL.position.x < 0 ? 1 : -1);
  const holdR = holdPose(armR, armR.position.x < 0 ? 1 : -1);
  const turnR = holdR.clone().premultiply(new THREE.Quaternion().setFromEuler(new THREE.Euler(0.25, 0, 0.35)));
  const headPose = new THREE.Quaternion();
  const euler = new THREE.Euler();
  const armPose = new THREE.Quaternion();

  let weight = 0;
  const update = (dt: number, elapsed: number, reading: boolean) => {
    weight += ((reading ? 1 : 0) - weight) * Math.min(1, dt * 5);
    if (weight < 0.002) {
      if (book.visible) { book.visible = false; book.scale.setScalar(0); }
      return;
    }
    book.visible = true;
    book.scale.setScalar(smooth(weight));

    // Pàgina: espera estesa a la dreta i, cada FLIP_EVERY s, passa a l'esquerra.
    const speed = reducedMotion ? 0.5 : 1;
    const p = ((elapsed * speed) % FLIP_EVERY) / FLIP_TIME;
    const turning = p < 1 ? Math.sin(Math.PI * p) : 0;
    flip.rotation.y = -OPEN - (Math.PI - 2 * OPEN) * smooth(p);
    flip.visible = p < 1;

    armL.quaternion.slerp(holdL, weight);
    // La mà dreta acompanya el full que es passa.
    armR.quaternion.slerp(armPose.copy(holdR).slerp(turnR, turning), weight);
    // El cap mira les pàgines i les recorre de costat a costat.
    euler.set(HEAD_DOWN, 0.1 * Math.sin(elapsed * 1.6) - 0.06 * turning, 0.03 * Math.sin(elapsed * 0.8));
    head.quaternion.slerp(headPose.setFromEuler(euler), weight);
    for (const eye of eyes) eye.position.y -= 0.07 * weight;
  };

  const dispose = () => {
    body.remove(book);
    book.traverse(o => {
      const mesh = o as THREE.Mesh;
      if (mesh.isMesh) mesh.geometry.dispose();
    });
    [paper, printed, leaf, cover].forEach(m => m.dispose());
    texture.dispose();
  };

  return { update, dispose };
}
