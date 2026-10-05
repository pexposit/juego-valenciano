export type { LevelKey } from '@parlaval/shared';
// Clau d'un escenari: el `type` d'un recurs de category 'escenari' a la BDD.
export type Scenario = string;
export type Mood='neutral'|'content'|'confus';

export type TurnResponse={reply_text:string;transcription?:string|null;reply_audio_base64?:string|null;reply_audio_mime_type?:string|null;mood:Mood;detected_level_signal:'below'|'on'|'above';error_flags:string[];xp_delta:number};

// Fila de la taula resources: `category` agrupa les activitats (p. ex. 'escenari')
// i `type` n'és la secció dins de la categoria (p. ex. 'mercat').
// `icon`, `color`, `section_name`, `background`, `voice`, `initial_prompt` i `objectius` venen de resources.metadata; `playable` indica si la seua categoria té pantalla
// de joc i la fila en té les dades (el decidix el backend); `has_lesson`, si té lliçó fixa (metadata.lesson).
export type Resource={ id:string; name:string; type:string; category:string; difficulty:string|null; xp_earned:number; content:string|null; url:string|null; icon:string|null; color:string|null; section_name:string|null; background:string|null; voice:string|null; initial_prompt:string|null; objectius:string[]; playable:boolean; has_lesson:boolean };

// Exercici de pràctica del temari (taula practice_exercises). `choice`: la correcta
// és answers[0], una de les `options`; `fill`: val qualsevol de les `answers`;
// `writing` i `form` s'avaluen amb el LLM a partir de `task`.
type PracticeBase = { id: string; level: string; prompt: string; explanation: string | null; passage_id: string | null };
export type PracticeWritingTask = { min_words: number; max_words: number; words?: string[]; min_words_used?: number };
export type PracticeExercise = PracticeBase & (
  | { kind: 'choice'; options: string[]; answers: string[] }
  | { kind: 'fill'; answers: string[] }
  | { kind: 'writing'; task: PracticeWritingTask }
  | { kind: 'form'; task: { fields: string[] } }
);
// Text o àudio (transcripció per torns) que acompanya unes preguntes de comprensió.
export type PracticePassage = { id: string; level: string; media: 'text' | 'audio'; title: string | null; audio_url: string | null; lines: { text: string; speaker?: string; voice?: string }[] };
// Lliçó fixa d'un contingut (metadata.lesson): teoria adaptada al nivell a partir
// de les gramàtiques de l'AVL. Els textos admeten **negreta** i *cursiva*.
export type LessonBlock = {
  title: string;
  text: string;
  table?: { head: string[]; rows: string[][] };
  examples?: string[];
  watch?: { wrong: string; right: string }[]; // errors freqüents («Compte!»)
};
export type LessonSource = { gram: 'GVB' | 'GNV'; section: string; title: string; url: string };
export type Lesson = Pick<Resource, 'id' | 'name' | 'type' | 'category' | 'section_name' | 'icon' | 'color'> & {
  intro: string;
  blocks: LessonBlock[];
  remember: string[];
  sources: LessonSource[];
};
export type Practice = Pick<Resource, 'id' | 'name' | 'type' | 'category' | 'content' | 'icon' | 'color' | 'section_name'> & {
  passages: PracticePassage[];
  exercises: PracticeExercise[];
};

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
// B1 (redaccions dels exercicis 6 i 7): mateixa escala que l'A2, amb comprovació d'extensió (±10 %).
export type B1CriterionKey = A2CriterionKey;
export type B1WritingEvaluation = {
  rubrica: 'b1_redaccio';
  opcio?: string; // opció triada (A/B) en l'exercici 6
  comprovacio_extensio: { paraules_reals: number; objectiu_tasca: string; dins_marge_10_percent: boolean };
  criteris: Record<B1CriterionKey, { puntuacio: number; franja: string; justificacio: string }> & {
    morfosintaxi: { presencia_pronoms_febles: boolean };
    coherencia_cohesio: { items_assolits: string[] };
    adequacio: { items_assolits: string[] };
  };
  puntuacio_total_rubrica: number;
  mitjana_base_10: number;
  errors_detectats: { segment_original: string; proposta_correccio: string; categoria: string; sistematic: boolean }[];
  retorn_pedagogic: string;
};
export type WritingEvaluation = A1WritingEvaluation | A2WritingEvaluation | B1WritingEvaluation;

// Ruta d'aprenentatge personalitzada (GET /api/learning-path): passos que el LLM
// tria del catàleg del nivell de l'usuari a partir de les seues avaluacions.
export type LearningStage = 'aprendre' | 'practicar' | 'aplicar' | 'comprovar';
export type LearningPathStep = {
  id: string;
  position: number;
  stage: LearningStage;
  reason: string;
  status: 'pending' | 'done' | 'skipped';
  completed_at: string | null;
  resource: Pick<Resource, 'id' | 'name' | 'type' | 'category' | 'content' | 'icon' | 'color' | 'section_name' | 'has_lesson'>;
};
export type LearningPath = { id: string; level: string; focus: string[]; rationale: string; created_at: string; steps: LearningPathStep[] };

// Última avaluació pedagògica d'un xat (user_evaluations).
export type LatestEvaluation = { summary: string; weaknesses: string[]; priority_focus: string; created_at: string };

// Resultat d'una pràctica o d'un examen per a la ruta d'aprenentatge.
export type ActivityResult = { level?: string | null; score?: number | null; total?: number | null; details?: Record<string, unknown> };
