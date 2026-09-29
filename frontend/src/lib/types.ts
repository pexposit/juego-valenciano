export type { LevelKey } from '@parlaval/shared';
// Clau d'un escenari: el `type` d'un recurs de category 'escenari' a la BDD.
export type Scenario = string;
export type Mood='neutral'|'content'|'confus';

export type TurnResponse={reply_text:string;transcription?:string|null;reply_audio_base64?:string|null;reply_audio_mime_type?:string|null;mood:Mood;detected_level_signal:'below'|'on'|'above';error_flags:string[];xp_delta:number};

// Fila de la taula resources: `category` agrupa les activitats (p. ex. 'escenari')
// i `type` n'és la secció dins de la categoria (p. ex. 'mercat').
// `icon`, `color`, `section_name`, `background` i `voice` venen de resources.metadata; `playable` indica si la seua categoria té pantalla
// de joc i la fila en té les dades (el decidix el backend).
export type Resource={ id:string; name:string; type:string; category:string; difficulty:string|null; xp_earned:number; content:string|null; url:string|null; icon:string|null; color:string|null; section_name:string|null; background:string|null; voice:string|null; playable:boolean };

// Contingut d'un examen (resources.metadata.exam). Els exercicis `choice`,
// `binary` i `match` es corregixen sols amb `answer`; `form`, `writing` i
// `oral` són de pràctica lliure.
export type ExamOption = { key: string; text?: string; image?: string; sign?: { title: string; lines: string[] } };
// `scored: false`: la pregunta es corregix en pantalla però no suma punts (p. ex. els
// enunciats «No surt» de l'exercici d'ordenar del B1, on només puntuen els 5 que apareixen).
export type ExamQuestion = { n: number; prompt?: string; image?: string; options?: ExamOption[]; answer: string; scored?: boolean };
export type ExamCriterion = { title: string; items: { name: string; description: string }[] };
// Consigna alternativa d'una redacció (opció A o B), amb els punts que cal incloure.
export type ExamWritingChoice = { key: string; text: string; points?: string[] };
// Text de lectura que acompanya un exercici de comprensió escrita.
export type ExamReading = { title?: string; paragraphs: string[] };
export type ExamProposal = {
  title: string;
  duration?: string;
  intro?: string;
  questions: string[];
  images: { prompt: string; image: string }[];
  // Diàleg: cada aspirant defén el paper d'una persona.
  roles?: { name: string; text: string }[];
};
type GradableExercise = { n: number; kind: 'choice' | 'binary' | 'match'; instructions: string; reading?: ExamReading; options_title?: string; options?: ExamOption[]; questions: ExamQuestion[] };
export type ExamExercise =
  | GradableExercise
  | { n: number; kind: 'form'; title?: string; instructions: string; fields: string[]; max_points: number; criteria: ExamCriterion[] }
  | {
      n: number; kind: 'writing'; title?: string; instructions: string; min_words: number; max_words: number;
      words?: string[]; min_words_used?: number;
      // Imatge de suport (p. ex. una infografia) i consignes alternatives entre les quals cal triar.
      image?: string; choices?: ExamWritingChoice[];
    }
  | { n: number; kind: 'oral'; instructions: string; proposals: ExamProposal[] };
// Puntuació oficial d'una àrea: cada encert val `points_per_correct` (resultat arredonit)
// i cal arribar a `pass_points` per a continuar en la prova. Si els exercicis valen
// diferent, `points_per_exercise` fixa el valor d'un encert per número d'exercici.
export type ExamScoring = { points_per_correct?: number; points_per_exercise?: Record<string, number>; max_points: number; pass_points: number };
export type ExamArea = { n: number; title: string; weight: number; duration: string; intro?: string; audio?: boolean; scoring?: ExamScoring; exercises: ExamExercise[] };
export type ExamContent = { level: string; session: string; body: string; source_url?: string; audio_source_url?: string; pass_rule?: string; areas: ExamArea[] };
export type Exam = Pick<Resource, 'id' | 'name' | 'type' | 'category' | 'difficulty' | 'xp_earned' | 'content' | 'url' | 'icon' | 'color'> & { exam: ExamContent };

// Avaluació amb LLM de l'Àrea 3 (Expressió escrita), amb la rúbrica oficial de la JQCV de cada nivell.
// A1 (formulari): cada criteri en una franja i nota global sobre 15.
export type WritingBand = '15-12' | '11-9' | '8-6' | '5-1';
export type WritingCriterionKey = 'lexic' | 'estructures' | 'ortografia' | 'comprensibilitat_coherencia' | 'adequacio';
export type A1WritingEvaluation = {
  rubrica?: 'a1_formulari'; // les avaluacions guardades abans de l'A2 no el porten
  criteris: Record<WritingCriterionKey, { franja: WritingBand; observacions: string }>;
  puntuacio_global: number;
  resultat: 'no eliminatòria' | 'eliminatòria';
  errors_destacats: { element_original: string; correccio_suggerida: string; tipus: string; gravetat: 'lleu' | 'greu' }[];
  retorn_pedagogic: string;
};
// A2 (redacció): cada criteri val 10, 6, 4 o 1; total sobre 50 i mitjana sobre 10.
export type A2CriterionKey = 'lexic' | 'morfosintaxi' | 'ortografia' | 'coherencia_cohesio' | 'adequacio';
export type A2WritingEvaluation = {
  rubrica: 'a2_redaccio';
  recompte_paraules: number;
  criteris: Record<A2CriterionKey, { puntuacio: number; justificacio: string }>;
  paraules_obligatories: { utilitzades: string[]; compleix_minim: boolean };
  puntuacio_total_rubrica: number;
  mitjana_ponderada_base_10: number;
  errors_detectats: { segment_original: string; proposta_correccio: string; categoria: string; sistematic: boolean }[];
  comentari_global: string;
};
export type WritingEvaluation = A1WritingEvaluation | A2WritingEvaluation;
