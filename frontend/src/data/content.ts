import type { Scenario, ScenarioInfo } from '../lib/types';

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




/* Objectius per defecte de cada escenari; es mostren mentres el backend respon. */
export const SCENARIO_GOALS: Record<Scenario, ScenarioInfo> = {
  mercat: { character: 'Vicent, venedor del mercat', objectius: ['Saluda a Vicent i pregunta com va tot.', 'Demana un quilo de taronges o una altra fruita.', 'Pregunta el preu o demana el canvi.', "Paga, dona les gràcies i acomiada't."] },
  bar: { character: 'Maria, cambrera', objectius: ['Saluda a Maria i busca una taula.', 'Demana una beguda o el desdejuni del dia.', 'Pregunta quant és o demana el compte.', "Paga, dona les gràcies i acomiada't."] },
  oficina: { character: "Joan, company d'oficina", objectius: ['Saluda a Joan i pregunta com està.', "Pregunta per la reunió o les tasques d'avui.", 'Demana ajuda o un aclariment sobre un tema.', "Confirma el que has de fer i acomiada't."] },
  ajuntament: { character: "Amparo, funcionària d'atenció", objectius: ['Saluda a Amparo i digues què necessites.', 'Explica el tràmit que vols fer.', 'Pregunta els requisits o els horaris.', "Dona les gràcies i acomiada't."] },
  colegi: { character: 'Marta, mestra', objectius: ['Saluda a Marta i pregunta com està.', "Pregunta pels deures o la tasca d'avui.", 'Demana permís o explica un dubte.', "Dona les gràcies i acomiada't."] },
  turisme: { character: 'Laura, guia turística', objectius: ['Saluda a Laura i digues què busques.', 'Demana una recomanació de lloc per a visitar.', 'Pregunta horaris, preus o com arribar-hi.', "Dona les gràcies i acomiada't."] },
};

// Salutacions d'inici pregenerades com a fitxers estàtics (veu segons el sexe del
// personatge: lluc = masculina, gina = femenina). En obrir l'escenari es reprodueixen
// al moment, sense cap crida al TTS del backend.
export const GREETING_BY_SCENARIO: Record<Scenario, string> = {
  mercat: '/audio/salutacio-lluc.wav',
  bar: '/audio/salutacio-gina.wav',
  oficina: '/audio/salutacio-lluc.wav',
  ajuntament: '/audio/salutacio-gina.wav',
  colegi: '/audio/salutacio-gina.wav',
  turisme: '/audio/salutacio-gina.wav',
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
