/**
 * Filtre heurístic de prompt injection per als missatges de l'aprenent (català, castellà i anglés).
 *
 * No pretén ser infal·lible: talla els intents evidents (ignorar les instruccions, demanar el prompt del sistema,
 * canviar el rol, imitar etiquetes del sistema, escriure els camps de l'eixida estructurada) abans de gastar una
 * crida al model. Cada patró suma punts i només es marca el missatge a partir d'un llindar: les frases que per si
 * soles també podrien ser normals en un xat de pràctica («actua com un cambrer») no el disparen.
 */

type Rule = { id: string; weight: number; pattern: RegExp };

// Pesos: 2 = prou per a marcar-lo; 1 = només junt amb una altra senyal.
const RULES: Rule[] = [
  {
    id: 'ignorar_instruccions',
    weight: 2,
    pattern: /\b(ignore|ignora|ignorar|ignoreu|disregard|forget|olvida|olvidar|olvidate de|oblida|oblidar|oblida't de|omite|omet|override|anula|anular|salta|saltate)\b.{0,40}\b(instructions?|instrucciones|instruccions|rules|reglas|regles|prompt|directives?|directrices|indicacions|indicaciones|restrictions|restricciones|restriccions|guidelines)\b/,
  },
  {
    id: 'revelar_prompt',
    weight: 2,
    pattern: /\b(show|reveal|print|repeat|tell|say|display|leak|muestra|muestrame|ensename|dime|escribe|repite|revela|ensenya|mostra|digues|escriu|repeteix|revela'm)\b.{0,50}\b(system|sistema|initial|inicial|original|hidden|oculto|ocult|secret|secreto|secret)\b.{0,20}\b(prompt|message|mensaje|missatge|instructions?|instrucciones|instruccions)\b|\b(show|reveal|print|repeat|tell|say|display|leak|muestra|muestrame|ensename|dime|escribe|repite|revela|ensenya|mostra|digues|escriu|repeteix)\b.{0,40}\b(prompt|missatge|mensaje|instruccions|instrucciones)\s+(del|de el|of the)\s+(sistema|system)\b/,
  },
  {
    id: 'preguntar_instruccions',
    weight: 2,
    pattern: /\b(what|which|cual|cuales|que|quin|quines|quins)\b.{0,15}\b(is|are|es|son|son|han estat)\b.{0,25}\b(your|tu|tus|el teu|els teus|les teues|la teua)\b.{0,25}\b(system prompt|prompt|instructions|instrucciones|instruccions)\b/,
  },
  {
    id: 'jailbreak',
    weight: 2,
    pattern: /\b(jailbreak|dan mode|do anything now|developer mode|modo desarrollador|mode desenvolupador|modo dios|sin restricciones|sense restriccions|without (any )?restrictions|bypass (the )?(filters?|rules|safety))\b/,
  },
  {
    id: 'etiquetes_del_sistema',
    weight: 2,
    pattern: /<\/?\s*(system|instructions?|prompt|assistant)\s*>|\[\/?inst\]|<\|im_(start|end)\|>|#{2,}\s*(system|instruction)/,
  },
  {
    id: 'camps_de_l_eixida',
    weight: 2,
    pattern: /\b(reply_text|exercici_tema|tipus_dubte|consulta_gnv|corregir_text|area_practica|leccio_id|help_text|response_format|json_schema)\b/,
  },
  {
    id: 'canvi_de_rol',
    weight: 1,
    pattern: /\b(you are now|from now on,? you|ahora eres|a partir de ahora (eres|actua|responde)|ara ets|a partir d ara (ets|actues|respons)|pretend (to be|you)|finge (ser|que eres)|fes veure que ets|act as (an? )?(unrestricted|different)|actua como si no)\b/,
  },
  {
    id: 'rol_en_linia',
    weight: 1,
    pattern: /(^|\n)\s*(system|sistema|assistant|asistente|assistent|developer|desarrollador)\s*:/,
  },
  {
    id: 'ordre_de_format',
    weight: 1,
    pattern: /\b(respond|reply|answer|responde|respon|contesta)\b.{0,15}\b(only|solely|just|unicamente|solo|nomes|solament)\b.{0,15}\b(with|con|amb)\b.{0,10}\b(json|yes|no|si|ok)\b/,
  },
  {
    id: 'desactivar_normes',
    weight: 1,
    pattern: /\b(no (rules|restrictions|limits)|sin (reglas|limites)|sense (regles|limits)|stop (being|acting)|deja de ser|deixa de ser)\b/,
  },
];

const THRESHOLD = 2;

// Caràcters invisibles, lletres d'amplària completa i accents: s'eliminen perquè no servisquen per a esquivar els patrons.
export function normalizeForDetection(text: string): string {
  return text
    .normalize('NFKC')
    .replace(/[​-‏‪-‮⁠﻿]/g, '')
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/[’‘`´]/g, "'")
    .replace(/[^\S\n]+/g, ' ');
}

export type InjectionVerdict = { flagged: boolean; score: number; reasons: string[] };

export function detectPromptInjection(text: string): InjectionVerdict {
  const normalized = normalizeForDetection(text);
  const hits = RULES.filter(rule => rule.pattern.test(normalized));
  const score = hits.reduce((sum, rule) => sum + rule.weight, 0);
  return { flagged: score >= THRESHOLD, score, reasons: hits.map(rule => rule.id) };
}

// Resposta fixa (en el personatge, sense passar pel model) quan el missatge s'ha marcat.
export const INJECTION_REPLY = "Això no ho puc fer. Tornem a la nostra conversa i continuem practicant valencià, d'acord?";
