export type DireccioApertium = 'es_a_va' | 'va_a_es';

/**
 * Tradueix utilitzant estrictament la variant valenciana d'Apertium.
 */
export async function traduirApertium(
  text: string,
  direccio: DireccioApertium = 'es_a_va'
): Promise<{ traduccio: string; direccio: string }> {
  // Construïm els paràmetres segons la direcció
  const params = new URLSearchParams({
    q: text,
  });

  if (direccio === 'es_a_va') {
    // Usem el parell spa|cat amb variant valenciana explícita
    params.set('langpair', 'spa|cat_valencia');
    params.set('variant', 'valencian');
  } else {
    params.set('langpair', 'cat_valencia|spa');
  }

  const apiUrl = `https://apertium.org/apy/translate?${params.toString()}`;

  const response = await fetch(apiUrl, {
    method: 'GET',
    headers: {
      'Accept': 'application/json',
      'User-Agent': 'mcp-valencia-server/1.0',
    },
  });

  if (!response.ok) {
    throw new Error(`Error en Apertium API (${response.status}): ${response.statusText}`);
  }

  const data = (await response.json()) as {
    responseData?: { translatedText?: string };
    responseStatus?: number;
  };

  const traduccio = data.responseData?.translatedText;

  if (!traduccio) {
    throw new Error('Apertium no ha retornat cap traducció en valencià.');
  }

  return {
    traduccio,
    direccio: direccio === 'es_a_va' ? 'Castellà -> Valencià' : 'Valencià -> Castellà',
  };
}