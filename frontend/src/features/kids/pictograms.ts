/**
 * Pictogrames d'ARASAAC (https://arasaac.org) de les lliçons de frases.
 * Autor: Sergio Palao. Origen: ARASAAC (https://arasaac.org). Propietat del Govern d'Aragó,
 * llicència CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/):
 * cal citar-ne l'autoria, no es poden usar amb fins comercials i les obres derivades
 * han de tindre la mateixa llicència.
 *
 * L'identificador de cada paraula és el de https://api.arasaac.org/v1/pictograms/ca/search/<paraula>.
 * Les imatges es descarreguen una vegada a frontend/public/pictograms/<id>.png amb
 * `npx tsx scripts/download-pictograms.ts` (a backend/), així l'app no depén d'ARASAAC en funcionar.
 */
export const PICTOGRAMS = {
  hola: 6009,
  'bon dia': 6944,
  'bona nit': 6942,
  adéu: 5896,
  gràcies: 8128,
  'si us plau': 8194,
  jo: 2617,
  tenir: 7271,
  fam: 35559,
  set: 7273,
  voler: 5441,
  aigua: 2248,
  menjar: 2349,
  beure: 2276,
  jugar: 2439,
  dormir: 2369,
  content: 3245,
  trist: 2606,
  anar: 2432,
  escola: 3082,
  pilota: 2269,
  casa: 2317,
  agradar: 2418,
  ajudar: 4570,
  mare: 2458,
  pare: 2497,
  llegir: 7141,
  pintar: 2348,
  cantar: 2315,
} as const;

export type PictogramName = keyof typeof PICTOGRAMS;

/** La ruta de la imatge d'un pictograma (servida des de public/). */
export const pictogramUrl = (name: PictogramName) => `/pictograms/${PICTOGRAMS[name]}.png`;

export const PICTOGRAM_CREDIT = "Pictogrames d'ARASAAC (arasaac.org), autor Sergio Palao, Govern d'Aragó, llicència CC BY-NC-SA.";
