/**
 * Client del servici classificador de nivell (contenidor classificador_llm/).
 * El classificador és qui parla amb OpenAI: el backend només li envia el text.
 * Exemple: curl -X POST http://localhost:8000/classificar -H 'Content-Type: application/json' \
 *   -d '{"text":"Hola, em dic Anna."}'
 */
export type NivellMCER = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';

export interface ResultatNivell {
  grup: 'Bàsic' | 'Mitjà' | 'Superior';
  nivell: NivellMCER;
  confianca: 'alta' | 'mitjana' | 'baixa';
  nivells_dubte: NivellMCER[];
  justificacio: string;
}

const baseUrl = (process.env.CLASSIFICADOR_URL || 'http://localhost:8000').replace(/\/$/, '');

export async function classificarText(text: string): Promise<ResultatNivell> {
  const response = await fetch(`${baseUrl}/classificar`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ text }),
    signal: AbortSignal.timeout(60_000),
  });
  if (!response.ok) throw new Error(`El classificador ha respost ${response.status}`);
  return response.json() as Promise<ResultatNivell>;
}
