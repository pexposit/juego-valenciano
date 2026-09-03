export type Scenario='mercat'|'bar'|'oficina'|'ajuntament'; export type Mood='neutral'|'content'|'confus';
export type TurnResponse={reply_text:string;transcription?:string|null;reply_audio_base64?:string|null;reply_audio_mime_type?:string|null;mood:Mood;detected_level_signal:'below'|'on'|'above';error_flags:string[];xp_delta:number};
