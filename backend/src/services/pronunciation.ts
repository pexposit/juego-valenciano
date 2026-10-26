/**
 * Correcció de pronúncia amb l'API fonètica PhoneticXeus del DeepLab de la UJI (`POST /transcribe`).
 *
 * L'aprenent llig en veu alta una frase de l'exercici; l'API reconeix els fonemes de l'àudio i, amb `align=true`,
 * els alinea amb la transcripció fonètica de la frase feta amb espeak `ca-va`. Només es puntuen els sons de l'exercici
 * (p. ex. les palatals): la resta d'eixida és massa sorollosa per a corregir (les vocals àtones ixen [ə], la
 * referència no du la ligadura de les africades...). Calibrat amb la veu gina llegint bé i amb faltes (2026-10-26).
 *
 * El fonetitzador d'espeak del servidor no és segur entre fils: dues peticions amb `align` alhora es corrompen les
 * referències sense cap error. Per això totes les peticions d'este procés passen per una sola fila.
 */

const API_URL = (process.env.PHONETIC_API_URL?.trim() || 'https://krono.act.uji.es/deeplab/api').replace(/\/$/, '');
const TIMEOUT_MS = Number(process.env.PHONETIC_API_TIMEOUT_MS) || 30_000;

// Un so de l'exercici es dona per bo si la probabilitat que siga de la família (el fonema reconegut més les seues
// alternatives) arriba a este llindar: «menja» ben dita pot eixir [s] amb 0,42 de confiança i 0,52 de palatals.
const FAMILY_MASS_OK = 0.35;
// Per davall d'esta distància (PER) l'àudio és la frase: llegida bé dona 0,24-0,57 (veu gina); una altra frase, 0,83.
const MAX_PER_UNDERSTOOD = 0.7;
// Amb veu real el PER d'una lectura sencera pot passar de 0,7 (micròfon de l'ordinador: fins a 0,74), però el cost
// mitjà de les paraules es queda en 0,05-0,19; una altra frase, o una gravació tallada, en dona 0,29.
const MAX_MEAN_COST_UNDERSTOOD = 0.25;
// Una paraula amb este cost o més no s'ha dit (llegida, fins i tot amb faltes, no passa de 0,3).
const MIN_COST_MISSING = 0.45;
// Sons que el reconeixedor confon amb un so de l'exercici encara que estiga ben dit: la ll ben dita (veu gina) ix
// sovint com a [j] o [i]. Es donen per bons; per això la ll només detecta la confusió amb la l, no el ieisme.
const TOLERATED: Record<string, string[]> = { 'ʎ': ['j', 'i'] };

type Phone = { ipa: string; confidence: number; alternatives?: { ipa: string; prob: number }[] };
type Op = { ref: string | null; hyp_j: number | null; word: number | null };
export type PhoneticResponse = {
  phones?: Phone[];
  alignment?: {
    reference: { word: string; phones: string[] }[];
    ops: Op[];
    words: { word: string; cost: number }[];
    summary: { per: number };
  } | null;
  alignment_error?: string | null;
};

export type PronunciationWord = {
  word: string;
  // Té algun so de l'exercici; `ok` diu si tots estan ben dits i `heard`, què s'ha sentit en lloc del primer que falla.
  target: boolean;
  ok: boolean;
  missing?: boolean;
  expected?: string;
  heard?: string;
};
export type PronunciationResult = { understood: boolean; words: PronunciationWord[]; score: number; total: number };

// La referència no du ligadura (dʒ) i el reconeixedor sí (d͡ʒ).
const plain = (ipa: string) => ipa.replace(/͡/g, '');

/**
 * Corregix els sons de `sounds` a partir de la resposta de l'API. `sounds` és una família (p. ex. les palatals
 * ['ʃ', 'ʒ', 'tʃ', 'dʒ']: qualsevol val per qualsevol) o una llista de famílies que no es poden confondre entre si
 * (p. ex. [['s'], ['z']]: la s de «passa» ha de sonar [s] i la de «casa», [z]).
 */
export function scorePronunciation(response: PhoneticResponse, sounds: string[] | string[][]): PronunciationResult {
  const alignment = response.alignment;
  const phones = response.phones ?? [];
  if (!alignment) return { understood: false, words: [], score: 0, total: 0 };

  const families = (sounds.length && Array.isArray(sounds[0]) ? sounds as string[][] : [sounds as string[]])
    .map(family => new Set(family.map(plain)));
  const familyOf = (ipa: string | null | undefined) => (ipa ? families.find(f => f.has(plain(ipa))) : undefined);
  const isTarget = (ipa: string | null | undefined) => Boolean(familyOf(ipa));
  const accepted = (family: Set<string>) => new Set([...family].flatMap(ipa => [ipa, ...(TOLERATED[ipa] ?? [])]));
  const mass = (phone: Phone, family: Set<string>) => {
    const ok = accepted(family);
    return (ok.has(plain(phone.ipa)) ? phone.confidence : 0)
      + (phone.alternatives ?? []).filter(a => ok.has(plain(a.ipa))).reduce((sum, a) => sum + a.prob, 0);
  };

  const words: PronunciationWord[] = alignment.reference.map((ref, i) => ({
    word: ref.word,
    target: ref.phones.some(isTarget),
    ok: true,
    missing: (alignment.words[i]?.cost ?? 0) >= MIN_COST_MISSING || undefined,
  }));

  alignment.ops.forEach((op, k) => {
    const family = familyOf(op.ref);
    if (op.word === null || !family) return;
    const word = words[op.word];
    if (!word || word.missing || !word.ok) return;
    const phone = op.hyp_j === null ? undefined : phones[op.hyp_j];
    // Sense fonema propi: l'africada sencera (d͡ʒ) pot haver quedat alineada amb la consonant d'abans (la d de «dʒ»).
    const previous = alignment.ops[k - 1];
    const absorbed = !phone && previous?.word === op.word && previous.hyp_j !== null && family.has(plain(phones[previous.hyp_j]?.ipa ?? ''));
    if (absorbed || (phone && mass(phone, family) >= FAMILY_MASS_OK)) return;
    // La referència partix les africades (t + ʃ): el so esperat és l'africada sencera si està en la família.
    const affricate = previous?.word === op.word && previous.ref ? plain(previous.ref + op.ref) : '';
    const expected = family.has(affricate) ? affricate : plain(op.ref!);
    Object.assign(word, { ok: false, expected, heard: phone ? plain(phone.ipa) : undefined });
  });

  const costs = alignment.words.map(w => w.cost);
  const meanCost = costs.reduce((sum, c) => sum + c, 0) / Math.max(costs.length, 1);
  const understood = alignment.summary.per < MAX_PER_UNDERSTOOD || meanCost < MAX_MEAN_COST_UNDERSTOOD;
  const scored = words.filter(w => w.target && !w.missing);
  return {
    understood,
    words,
    score: understood ? scored.filter(w => w.ok).length : 0,
    total: words.filter(w => w.target).length,
  };
}

let tail: Promise<unknown> = Promise.resolve();
// Executa `task` quan han acabat totes les anteriors (vegeu la nota d'espeak de dalt).
function serial<T>(task: () => Promise<T>): Promise<T> {
  const run = tail.then(task, task);
  tail = run.catch(() => undefined);
  return run;
}

/** Envia l'àudio i la frase a l'API i torna la resposta en brut (amb l'alineació). */
export function transcribePhonetic(audio: Buffer, filename: string, referenceText: string): Promise<PhoneticResponse> {
  return serial(async () => {
    const query = new URLSearchParams({ align: 'true', top_k: '3', reference_text: referenceText });
    const form = new FormData();
    form.append('file', new Blob([new Uint8Array(audio)]), filename);
    const response = await fetch(`${API_URL}/transcribe?${query}`, { method: 'POST', body: form, signal: AbortSignal.timeout(TIMEOUT_MS) });
    if (!response.ok) throw new Error(`L'API fonètica ha respost ${response.status}`);
    const body = await response.json() as PhoneticResponse;
    if (body.alignment_error) throw new Error(`L'API fonètica no ha pogut alinear: ${body.alignment_error}`);
    return body;
  });
}
