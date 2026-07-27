export type Scenario='mercat'|'bar'|'oficina'|'ajuntament'; export type Mood='neutral'|'content'|'confus';
export type TurnResponse={reply_text:string;reply_audio_base64?:string|null;mood:Mood;detected_level_signal:'below'|'on'|'above';error_flags:string[];xp_delta:number};
