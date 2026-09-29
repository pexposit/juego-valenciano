import type { Scenario } from '../lib/types';

export type Page = 'home' | 'auth' | 'dashboard' | 'scenarioselect' | 'chat' | 'summary' | 'profile';

/* Rutes URL de cada pàgina. La de xat porta l'escenari com a paràmetre de ruta
 * (/xat/:scenario): l'entrada `chat` és només un valor per defecte, no s'hi
 * navega mai directament — s'usa `chatRoute(scenario)` en el seu lloc. */
export const ROUTES: Record<Page, string> = {
  home: '/',
  auth: '/auth',
  dashboard: '/dashboard',
  scenarioselect: '/scenaris',
  chat: '/xat',
  summary: '/resum',
  profile: '/perfil',
};

export const chatRoute = (scenario: Scenario) => `/xat/${scenario}`;




// Salutacions d'inici pregenerades com a fitxers estàtics, una per veu TTS
// (resources.metadata.voice). En obrir l'escenari es reprodueixen al moment;
// si la veu no en té, el xat la genera amb el TTS del backend.
export const GREETING_BY_VOICE: Record<string, string> = {
  lluc: '/audio/salutacio-lluc.wav',
  gina: '/audio/salutacio-gina.wav',
};

export const LEVEL_OPTIONS = [
  { value: 'principiant', label: 'Principiant' },
  { value: 'intermedi', label: 'Intermedi' },
  { value: 'avancat', label: 'Avançat' },
];

/* Valors del perfil demo (sense sessió de Supabase). */
export const DEFAULT_PROFILE = { name: 'Aina', level: 'principiant', xp: 35 };

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
