export interface ErrorOrtografic {
  tipus: string;
  missatge: string;
  paraula: string;
  suggeriments: string[];
}

/**
 * Correcció ortogràfica, gramatical i d'estil preferent segons els criteris de l'AVL.
 */
export async function corregirSoftvalencia(text: string): Promise<{
  esValid: boolean;
  errors: ErrorOrtografic[];
}> {
  const endpoint = 'https://api.softcatala.org/corrector/v2/check';

  // Forcem la variant valenciana i activem específicament les regles d'estil i dialecte
  const params = new URLSearchParams({
    text,
    language: 'ca-ES-valencia',
    level: 'picky', // Mode exigent per a incloure avisos d'estil
    enabledOnly: 'false',
    // Categories clau de LanguageTool per al valencià
    enabledCategories: 'VALENCIAN,DIALECTAL,STYLE,GRAMMAR,CONFUSED_WORDS,TYPOGRAPHY',
    // Regles explícites de preferències lèxiques valencianes (este/aquest, eixir/sortir, etc.)
  });

  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'User-Agent': 'mcp-valencia-server/1.0',
    },
    body: params.toString(),
  });

  if (!response.ok) {
    throw new Error(`Error al servidor de Softvalencià (${response.status}): ${response.statusText}`);
  }

  interface LtMatch {
    message: string;
    shortMessage?: string;
    context: { text: string; offset: number; length: number };
    replacements: Array<{ value: string }>;
    rule?: { id?: string; issueType?: string; description?: string };
  }

  const data = (await response.json()) as { matches?: LtMatch[] };
  const matches = data.matches || [];

  if (matches.length === 0) {
    return { esValid: true, errors: [] };
  }

  const errors: ErrorOrtografic[] = matches.map((m) => {
    const errorWord = m.context.text.substring(
      m.context.offset,
      m.context.offset + m.context.length
    );

    // Identifiquem si és falta ortogràfica o suggeriment d'estil valencià
    const esEstil =
      m.rule?.issueType === 'style' ||
      m.rule?.issueType === 'locale-violation' ||
      m.rule?.id?.includes('VALENCIA');

    return {
      tipus: esEstil ? 'Preferència d\'estil valencià' : 'Error normatiu / ortogràfic',
      missatge: m.message,
      paraula: errorWord,
      suggeriments: m.replacements.slice(0, 4).map((r) => r.value),
    };
  });

  return {
    esValid: false,
    errors,
  };
}