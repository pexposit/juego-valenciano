// Font única de veritat: el tipus viu al paquet compartit i es reexporta amb
// el nom canònic del frontend per no tocar tots els import existents.
export type { ScenarioKey as Scenario, LevelKey } from '@parlaval/shared';
export type Mood='neutral'|'content'|'confus';

export type ScenarioInfo={ character:string; objectius:string[] };
export type TurnResponse={reply_text:string;transcription?:string|null;reply_audio_base64?:string|null;reply_audio_mime_type?:string|null;mood:Mood;detected_level_signal:'below'|'on'|'above';error_flags:string[];xp_delta:number};

// Fila de la taula resources: `category` agrupa les activitats (p. ex. 'escenari')
// i `type` n'és la secció dins de la categoria (p. ex. 'mercat').
export type Resource={ id:string; name:string; type:string; category:string; difficulty:string|null; xp_earned:number; content:string|null; url:string|null };
