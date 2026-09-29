export type { LevelKey } from '@parlaval/shared';
// Clau d'un escenari: el `type` d'un recurs de category 'escenari' a la BDD.
export type Scenario = string;
export type Mood='neutral'|'content'|'confus';

export type TurnResponse={reply_text:string;transcription?:string|null;reply_audio_base64?:string|null;reply_audio_mime_type?:string|null;mood:Mood;detected_level_signal:'below'|'on'|'above';error_flags:string[];xp_delta:number};

// Fila de la taula resources: `category` agrupa les activitats (p. ex. 'escenari')
// i `type` n'és la secció dins de la categoria (p. ex. 'mercat').
// `icon`, `color`, `section_name`, `background` i `voice` venen de resources.metadata;
// `playable` indica si té xat (escenari amb prompt del personatge).
export type Resource={ id:string; name:string; type:string; category:string; difficulty:string|null; xp_earned:number; content:string|null; url:string|null; icon:string|null; color:string|null; section_name:string|null; background:string|null; voice:string|null; playable:boolean };
