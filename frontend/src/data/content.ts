import { CHAT_CATEGORIES, isPracticeArea, MOTHER_TONGUES } from '@parlaval/shared';
import type { Resource, Scenario } from '../lib/types';

export type Page = 'home' | 'auth' | 'dashboard' | 'learningpath' | 'scenarioselect' | 'chat' | 'exam' | 'practice' | 'errors' | 'tutorhistory' | 'summary' | 'profile';

/* Rutes URL de cada pàgina. La de xat porta l'escenari com a paràmetre de ruta
 * (/xat/:scenario): l'entrada `chat` és només un valor per defecte, no s'hi
 * navega mai directament — s'usa `chatRoute(scenario)` en el seu lloc. */
export const ROUTES: Record<Page, string> = {
  home: '/',
  auth: '/auth',
  dashboard: '/dashboard',
  learningpath: '/ruta',
  scenarioselect: '/scenaris',
  chat: '/xat',
  exam: '/examen',
  practice: '/practica',
  errors: '/errors',
  tutorhistory: '/converses',
  summary: '/resum',
  profile: '/perfil',
};

// Món d'illes del Nivell 0 (xiquets): el tauler i les activitats hi redirigixen.
export const KIDS_ROUTES = { home: '/xiquets', island: '/xiquets/illa', album: '/xiquets/album', lessons: '/xiquets/llicons', lesson: '/xiquets/llico' };

export const chatRoute = (scenario: Scenario) => `/xat/${scenario}`;
export const examRoute = (resourceId: string) => `/examen/${resourceId}`;
export const practiceRoute = (resourceId: string) => `/practica/${resourceId}`;

// Pantalla de joc de cada categoria de resources: els escenaris i l'Expressió oral s'obrin al xat
// (per `type`), els exàmens al visor de l'examen i els continguts de les àrees
// del temari a la pantalla d'exercicis (per `id`).
export const activityRoute = (resource: Pick<Resource, 'id' | 'type' | 'category'>): string | null => {
  if (CHAT_CATEGORIES.includes(resource.category)) return chatRoute(resource.type);
  switch (resource.category) {
    case 'examen': return examRoute(resource.id);
    default: return isPracticeArea(resource.category) ? practiceRoute(resource.id) : null;
  }
};




// Salutacions d'inici pregenerades com a fitxers estàtics, una per veu TTS
// (resources.metadata.voice). En obrir l'escenari es reprodueixen al moment;
// si la veu no en té, el xat la genera amb el TTS del backend.
export const GREETING_BY_VOICE: Record<string, string> = {
  lluc: '/audio/salutacio-lluc.wav',
  gina: '/audio/salutacio-gina.wav',
};

export const LEVEL_OPTIONS = [
  { value: 'nivell0', label: 'Nivell 0' },
  { value: 'principiant', label: 'Principiant' },
  { value: 'intermedi', label: 'Intermedi' },
  { value: 'avancat', label: 'Avançat' },
];

/* Públic de l'aprenent (profiles.age_group). Els xiquets no trien nivell: comencen en principiant. */
export const AGE_GROUP_OPTIONS = [
  { value: 'child', label: 'Xiquet o xiqueta' },
  { value: 'adult', label: 'Persona adulta' },
];

/* Llengua materna que es tria en crear el compte (codi ISO 639-1 a profiles.mother_tongue). */
export const MOTHER_TONGUE_OPTIONS = MOTHER_TONGUES;

/* Valors del perfil demo (sense sessió de Supabase). */
export const DEFAULT_PROFILE = { name: 'Aina', level: 'principiant', xp: 35, ageGroup: 'adult' };

export const HOME_IMAGES = [
  {
    src: '/images/Ciudad de las Artes y las Ciencias Complejo arquitectónico moderno con edificios blancos y formas futuristas rodeados de agua, símbolo de innovación.jpeg',
    label: '🏛️ Ciutat de les Arts i les Ciències · València',
    alt: 'Ciutat de les Arts i les Ciències de València',
  },
  {
    src: '/images/Mercado Central Espacio lleno de vida con puestos de comida fresca, colores y productos típicos valencianos.jpeg',
    label: '🍊 Mercat Central · València',
    alt: 'Mercat Central de València',
  },
  {
    src: '/images/Plaza del Ayuntamiento Centro neurálgico de la ciudad, rodeado de edificios históricos y escenario de eventos importantes.jpeg',
    label: '🏙️ Plaça de l’Ajuntament · València',
    alt: 'Plaça de l’Ajuntament de València',
  },
  {
    src: '/images/Playa de la Malvarrosa Amplia playa urbana con arena dorada y paseo marítimo muy animado.jpeg',
    label: '🌊 Platja de la Malva-rosa · València',
    alt: 'Platja de la Malva-rosa de València',
  },
  {
    src: '/images/Playa de Gandía Playa extensa, de aguas tranquilas y arena fina, ideal para familias.jpeg',
    label: '🏖️ Platja de Gandia',
    alt: 'Platja de Gandia',
  },
  {
    src: '/images/Calas de Jávea Pequeñas calas de aguas cristalinas y rocas, perfectas para bucear.jpeg',
    label: '🐠 Caletes de Xàbia',
    alt: 'Caletes de Xàbia',
  },
  {
    src: '/images/Castillo del Papa Luna Fortaleza situada sobre una roca junto al mar, imponente y bien conservada.jpeg',
    label: '🏰 Castell del Papa Luna · Peníscola',
    alt: 'Castell del Papa Luna de Peníscola',
  },
];
