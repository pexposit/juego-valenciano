// Continguts de llengua del catàleg d'un nivell: les subcategories en què es classifiquen els
// errors (detector dels xats i avaluació de redaccions). Cada error es guarda amb l'àrea
// (category) i el contingut (content_id), que és l'activitat de pràctica que el treballa.

export const LANGUAGE_AREAS = ['fonetica_ortografia', 'morfosintaxi', 'lexic_semantica'] as const;
export type LanguageArea = (typeof LANGUAGE_AREAS)[number];

export type LevelContent = {
  code: string; // codi curt per al LLM (c1, c2...): copia malament els UUID
  id: string;
  area: LanguageArea;
  name: string; // el nom de la secció, p. ex. «Pronoms febles: formes, col·locació...»
  detail: string; // el nom del contingut, amb el que inclou
};

// Es demanen moltes vegades (un cop per missatge dels xats) i canvien poc: es guarden un temps.
const CACHE_MS = 10 * 60_000;
const cache = new Map<string, { at: number; contents: Promise<LevelContent[]> }>();

export function loadLevelContents(client: any, level: string): Promise<LevelContent[]> {
  const hit = cache.get(level);
  if (hit && Date.now() - hit.at < CACHE_MS) return hit.contents;
  const contents = (async () => {
    const { data, error } = await client
      .from('resources')
      .select('id, name, category, metadata')
      .eq('difficulty', level)
      .in('category', LANGUAGE_AREAS)
      .is('teacher_id', null)
      .order('category')
      .order('sort_order');
    if (error) throw error;
    return (data as { id: string; name: string; category: LanguageArea; metadata: Record<string, unknown> | null }[]).map((r, i) => ({
      code: `c${i + 1}`,
      id: r.id,
      area: r.category,
      name: typeof r.metadata?.section_name === 'string' ? r.metadata.section_name : r.name,
      detail: r.name,
    }));
  })();
  cache.set(level, { at: Date.now(), contents });
  contents.catch(() => cache.delete(level));
  return contents;
}

// La llista per al prompt: una línia per contingut, agrupats per àrea.
export function contentsForPrompt(contents: LevelContent[]): string {
  return LANGUAGE_AREAS.map(area => {
    const lines = contents.filter(c => c.area === area).map(c => `  - ${c.code}: ${c.name} (${c.detail})`);
    return lines.length ? `${area}:\n${lines.join('\n')}` : '';
  }).filter(Boolean).join('\n');
}

// Àrea i contingut d'un error a partir del codi que ha triat el LLM. Un codi desconegut
// (o buit, si el nivell no té continguts) deixa només l'àrea.
export function classify(contents: LevelContent[], area: string, code: string | null | undefined) {
  const content = code ? contents.find(c => c.code === code.trim()) : undefined;
  return {
    category: content?.area ?? (LANGUAGE_AREAS.includes(area as LanguageArea) ? area : 'morfosintaxi'),
    content_id: content?.id ?? null,
    subcategory: content?.name ?? null,
  };
}
