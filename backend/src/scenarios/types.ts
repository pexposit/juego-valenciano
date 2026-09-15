// Font única de veritat: el tipus viu al paquet compartit i es reexporta
// amb el nom canònic del backend per no tocar tots els import existents.
import type { ScenarioKey } from '@parlaval/shared';
export type { ScenarioKey };
export interface ScenarioDefinition { key:ScenarioKey; character:string; systemPrompt:string; objectius:string[] }

