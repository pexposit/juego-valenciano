export type Scenario='mercat'|'bar'|'oficina'|'ajuntament'|'colegi'|'turisme'; export type Mood='neutral'|'content'|'confus';
export type ScenarioInfo={ character:string; objectius:string[] };
export type TurnResponse={reply_text:string;transcription?:string|null;reply_audio_base64?:string|null;reply_audio_mime_type?:string|null;mood:Mood;detected_level_signal:'below'|'on'|'above';error_flags:string[];xp_delta:number};
