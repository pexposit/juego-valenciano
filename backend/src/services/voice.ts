/** Voice providers live behind this interface so vendors can change without routes changing. */
export interface SpeechToText { transcribe(audio:Buffer,mimeType?:string):Promise<string> } export interface TextToSpeech { synthesize(text:string):Promise<Buffer|null> }
export class UnconfiguredStt implements SpeechToText { async transcribe(_audio:Buffer,_mimeType?:string):Promise<string>{throw new Error('El proveïdor STT no està configurat')} }
export class UnconfiguredTts implements TextToSpeech { async synthesize(){return null} }
export const stt:SpeechToText=new UnconfiguredStt(); export const tts:TextToSpeech=new UnconfiguredTts();
