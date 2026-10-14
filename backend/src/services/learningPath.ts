import OpenAI from 'openai';
import { zodResponseFormat } from 'openai/helpers/zod';
import type { ChatCompletionMessageParam } from 'openai/resources/chat/completions';
import { z } from 'zod';
import { hasAiPath } from '@parlaval/shared';
import { isPlayable, type Metadata } from './catalog.js';
import { loadLearningSignals, type LearningSignals } from './learningSignals.js';

// Ruta d'aprenentatge personalitzada. El LLM rep les dades de l'usuari
// (learningSignals) i el catàleg jugable del seu nivell, i tria 5-7 passos amb
// l'ordre i el perquè. El backend només li filtra el catàleg i en valida la
// resposta: la ruta no pot apuntar a recursos inexistents o d'un altre nivell.

const MODEL_NAME = process.env.OPENAI_MODEL!;
// Es crea en la primera crida: així el mòdul es pot importar (p. ex. als tests) sense clau.
let openaiClient: OpenAI | undefined;
const openai = () => (openaiClient ??= new OpenAI({ apiKey: process.env.OPENAI_API_KEY, maxRetries: 1, timeout: 60_000 }));

export const STAGES = ['aprendre', 'practicar', 'aplicar', 'comprovar'] as const;
export const MIN_STEPS = 5;
export const MAX_STEPS = 7;
// Una pràctica amb un 80 % d'encerts dona per resolts els errors classificats en eixe contingut.
const MASTERY_RATIO = 0.8;
const RECENT_DAYS = 7;

/* ── Catàleg que es passa al LLM ──────────────────────────────────────── */
export type CatalogItem = {
  id: string;
  category: string;
  type: string;
  section: string;
  name: string;
  content: string | null;
  has_lesson: boolean;
  sort_order: number;
};

type CatalogRow = {
  id: string; name: string; type: string; category: string; content: string | null; sort_order: number | null;
  url: string | null; metadata: Metadata; practice_exercises?: { count: number }[];
};

async function loadCatalog(client: any, level: string): Promise<CatalogItem[]> {
  const { data, error } = await client
    .from('resources')
    .select('id, name, type, category, content, sort_order, url, metadata, practice_exercises(count)')
    .eq('difficulty', level)
    // Les activitats del professorat no entren en la ruta de la IA.
    .is('teacher_id', null)
    .order('category')
    .order('sort_order');
  if (error) throw error;
  return (data as CatalogRow[]).filter(isPlayable).map(r => ({
    id: r.id,
    category: r.category,
    type: r.type,
    section: typeof r.metadata?.section_name === 'string' ? r.metadata.section_name : r.name,
    name: r.name,
    content: r.content,
    has_lesson: Boolean(r.metadata?.lesson),
    sort_order: r.sort_order ?? 0,
  }));
}

/* ── Resposta del LLM i validació ─────────────────────────────────────── */
export const PlanSchema = z.object({
  rationale: z.string().describe("2-3 frases en valencià, dirigides a l'aprenent (tu), que expliquen per què se li proposa esta ruta."),
  focus: z.array(z.string()).describe('1-3 aspectes en què se centra la ruta (p. ex. «pronoms febles», «comprensió oral»).'),
  steps: z.array(z.object({
    resource_id: z.string().describe("El codi exacte (camp `id`, p. ex. «r12») d'un recurs del catàleg."),
    stage: z.enum(STAGES),
    reason: z.string().describe("Una frase en valencià, dirigida a l'aprenent, de per què fa este pas."),
  })),
});
export type Plan = z.infer<typeof PlanSchema>;

// Torna el problema de la ruta (per a reintentar-la) o null si és vàlida.
export function validatePlan(plan: Plan, catalogIds: ReadonlySet<string>): string | null {
  if (plan.steps.length < MIN_STEPS || plan.steps.length > MAX_STEPS) {
    return `La ruta ha de tindre entre ${MIN_STEPS} i ${MAX_STEPS} passos i en té ${plan.steps.length}.`;
  }
  const unknown = plan.steps.filter(s => !catalogIds.has(s.resource_id)).map(s => s.resource_id);
  if (unknown.length) return `Estos resource_id no són al catàleg: ${unknown.join(', ')}. Usa només ids del catàleg.`;
  if (new Set(plan.steps.map(s => s.resource_id)).size !== plan.steps.length) return 'Hi ha recursos repetits: cada pas ha de ser un recurs diferent.';
  if (!plan.rationale.trim() || plan.steps.some(s => !s.reason.trim())) return 'Falten el rationale o el reason d\'algun pas.';
  return null;
}

const SYSTEM_PROMPT = `Ets un tutor de valencià que prepara aprenents per als certificats de la JQCV. Has de dissenyar la ruta d'aprenentatge personalitzada dels pròxims dies per a un aprenent, a partir de les seues dades i del catàleg d'activitats del seu nivell.

DADES QUE REPS
- avaluacions: focus de les seues últimes converses (priority_focus = el contingut amb més errors de cada una; en les antigues, una categoria d'error solta).
- errors_pendents: recompte d'errors encara no resolts per contingut: area (fonetica_ortografia, morfosintaxi, lexic_semantica o l'àrea de l'activitat), contingut (el codi «r..» del catàleg que el treballa, o null si no hi és) i quantitat.
- arees: per a cada àrea, quantes activitats ha fet i la mitjana d'encerts (0-1; null si no té nota).
- recents: últims recursos fets (id, àrea, nota).
- passos_fets: recursos de la ruta anterior que ja ha completat.
- cataleg: les ÚNIQUES activitats que pots triar (id = codi curt com «r12», category, section, name, content, has_lesson = té una lliçó de teoria).

CATEGORIES DEL CATÀLEG
- fonetica_ortografia, morfosintaxi, lexic_semantica: exercicis de llengua (molts amb lliçó).
- comprensio_oral, comprensio_escrita: àudios i textos amb preguntes.
- expressio_escrita: redaccions avaluades amb la rúbrica de la JQCV.
- expressio_oral, escenari: conversa amb un personatge.
- examen: simulacre d'examen.

COM HA DE SER LA RUTA
1. Entre ${MIN_STEPS} i ${MAX_STEPS} passos, en ordre, seguint el cicle: «aprendre» (un contingut amb has_lesson = true: primer la teoria i després la pràctica) → «practicar» (exercicis de llengua o de comprensió) → «aplicar» (expressió escrita, expressió oral o escenari, per a usar el que ha treballat) → «comprovar» (un examen o una activitat de comprensió per a veure el progrés). Pots repetir etapes, però comença per aprendre o practicar i acaba aplicant o comprovant.
2. Prioritza els continguts amb més errors pendents (el seu codi «contingut» és directament l'activitat que els treballa) i el priority_focus de l'última avaluació (el nom d'un contingut: tria el de la mateixa section). Si no hi ha avaluacions ni errors, fes una ruta diagnòstica variada.
3. Reforça les àrees amb una mitjana baixa (< 0,6) i inclou alguna àrea que no haja fet mai.
4. Inclou almenys una activitat de comprensió (oral o escrita) i una d'expressió (escrita, oral o escenari).
5. No repetisques recursos de passos_fets ni dels recents dels últims ${RECENT_DAYS} dies, tret que hi haja tret menys de 0,5 i vulgues que el reforce.
6. resource_id ha de ser exactament el codi «id» d'una activitat del cataleg (p. ex. «r12»). No te n'inventes cap.
7. Escriu rationale i reason en valencià normatiu (AVL), en to proper i motivador, i dirigint-te a l'aprenent de tu. Si hi ha errors concrets, esmenta'ls (p. ex. «encara confons "en" i "hi"»).`;

async function askModel(input: unknown, catalogIds: ReadonlySet<string>): Promise<Plan | null> {
  const messages: ChatCompletionMessageParam[] = [
    { role: 'system', content: SYSTEM_PROMPT },
    { role: 'user', content: JSON.stringify(input) },
  ];
  // Un intent i un reintent explicant-li què ha fallat.
  for (let attempt = 1; attempt <= 2; attempt += 1) {
    const response = await openai().chat.completions.parse({
      model: MODEL_NAME,
      messages,
      response_format: zodResponseFormat(PlanSchema, 'ruta_aprenentatge'),
    });
    const message = response.choices[0]?.message;
    const plan = message?.parsed;
    const problem = plan ? validatePlan(plan, catalogIds) : 'La resposta no seguix l\'esquema.';
    if (!problem) return plan!;
    console.warn(`[learning-path] Ruta no vàlida (intent ${attempt}): ${problem}`);
    messages.push({ role: 'assistant', content: message?.content ?? '' });
    messages.push({ role: 'user', content: `${problem} Torna a fer la ruta complint totes les regles.` });
  }
  return null;
}

/* ── Ruta diagnòstica (sense dades o si el LLM falla) ─────────────────── */
const DIAGNOSTIC: { categories: string[]; stage: Plan['steps'][number]['stage']; lesson?: boolean; reason: string }[] = [
  { categories: ['morfosintaxi', 'fonetica_ortografia'], stage: 'aprendre', lesson: true, reason: 'Comencem repassant la teoria d\'un contingut bàsic del nivell i practicant-lo.' },
  { categories: ['lexic_semantica'], stage: 'practicar', reason: 'Veurem quin vocabulari del nivell ja domines.' },
  { categories: ['comprensio_oral'], stage: 'practicar', reason: 'Comprovarem com entens el valencià parlat.' },
  { categories: ['comprensio_escrita'], stage: 'practicar', reason: 'Comprovarem com entens un text escrit.' },
  { categories: ['expressio_escrita'], stage: 'aplicar', reason: 'Escriuràs un text breu perquè vegem com t\'expresses per escrit.' },
  { categories: ['expressio_oral', 'escenari'], stage: 'aplicar', reason: 'Conversaràs amb un personatge per a practicar l\'expressió oral.' },
  { categories: ['examen'], stage: 'comprovar', reason: 'Un simulacre d\'examen et mostrarà on estàs respecte al certificat.' },
];

export function diagnosticPlan(catalog: CatalogItem[]): Plan | null {
  const steps = DIAGNOSTIC.flatMap(({ categories, stage, lesson, reason }) => {
    const item = catalog
      .filter(c => categories.includes(c.category) && (!lesson || c.has_lesson))
      .sort((a, b) => a.sort_order - b.sort_order)[0];
    return item ? [{ resource_id: item.id, stage, reason }] : [];
  }).slice(0, MAX_STEPS);
  if (steps.length < MIN_STEPS) return null;
  return {
    rationale: 'Encara no tenim prou dades sobre tu: esta primera ruta recorre totes les destreses del nivell perquè puguem conéixer els teus punts forts i el que has de reforçar.',
    focus: ['diagnòstic inicial'],
    steps,
  };
}

/* ── Persistència ─────────────────────────────────────────────────────── */
async function activePath(client: any, userId: string) {
  const { data, error } = await client
    .from('learning_paths')
    .select('id, level, focus, rationale, created_at, learning_path_steps(id, position, resource_id, stage, reason, status, completed_at)')
    .eq('user_id', userId)
    .eq('status', 'active')
    .maybeSingle();
  if (error) throw error;
  return data as null | {
    id: string; level: string; focus: string[]; rationale: string; created_at: string;
    learning_path_steps: { id: string; position: number; resource_id: string; stage: string; reason: string; status: string; completed_at: string | null }[];
  };
}

async function savePath(client: any, userId: string, level: string, plan: Plan) {
  const { error: archiveError } = await client
    .from('learning_paths')
    .update({ status: 'archived' })
    .eq('user_id', userId)
    .eq('status', 'active');
  if (archiveError) throw archiveError;

  const { data: path, error } = await client
    .from('learning_paths')
    .insert({ user_id: userId, level, focus: plan.focus, rationale: plan.rationale })
    .select('id')
    .single();
  if (error) throw error;

  const { error: stepsError } = await client.from('learning_path_steps').insert(
    plan.steps.map((s, i) => ({ path_id: path.id, position: i + 1, resource_id: s.resource_id, stage: s.stage, reason: s.reason })),
  );
  if (stepsError) throw stepsError;
}

// Evita generar dues rutes alhora per al mateix usuari (p. ex. dos recursos acabats seguits).
const generating = new Map<string, Promise<boolean>>();

// Genera i guarda una ruta nova. Torna false si no s'ha pogut i s'ha mantingut l'anterior.
export function generateLearningPath(client: any, userId: string): Promise<boolean> {
  const running = generating.get(userId);
  if (running) return running;
  const job = (async () => {
    const { data: profile, error } = await client.from('profiles').select('level').eq('id', userId).single();
    if (error) throw error;
    const level: string = profile.level;
    // Només el B1 i el B2 tenen ruta de la IA (l'A2 té només les predefinides; la resta de
    // nivells encara no tenen continguts de llengua al catàleg).
    if (!hasAiPath(level)) return false;

    const [signals, catalog, previous] = await Promise.all([
      loadLearningSignals(client, userId),
      loadCatalog(client, level),
      activePath(client, userId),
    ]);
    // El LLM treballa amb codis curts (r1, r2...): copia malament els UUID.
    const refs = new Map(catalog.map((c, i) => [`r${i + 1}`, c.id]));
    const hasData = signals.evaluations.length > 0 || signals.recent.length > 0;

    let plan: Plan | null = null;
    if (hasData) {
      try {
        const answer = await askModel(modelInput(signals, catalog, previous), new Set(refs.keys()));
        if (answer) plan = { ...answer, steps: answer.steps.map(st => ({ ...st, resource_id: refs.get(st.resource_id)! })) };
      } catch (err) {
        console.error('[learning-path] Error del LLM:', err instanceof Error ? err.message : err);
      }
    }
    // Sense dades, o si el LLM falla i encara no hi ha cap ruta: la diagnòstica.
    if (!plan && !previous) plan = diagnosticPlan(catalog);
    if (!plan) return false;

    await savePath(client, userId, level, plan);
    console.log(`[learning-path] Ruta nova per a ${userId}: ${plan.steps.length} passos (${plan.focus.join(', ')})`);
    return true;
  })().finally(() => generating.delete(userId));
  generating.set(userId, job);
  return job;
}

// Les dades de l'usuari i el catàleg, amb els recursos identificats pel codi curt
// (r1, r2..., en l'ordre del catàleg). Els recursos fets que ja no són al catàleg
// (d'un altre nivell) es passen sense codi.
function modelInput(signals: LearningSignals, catalog: CatalogItem[], previous: Awaited<ReturnType<typeof activePath>>) {
  const refOf = new Map(catalog.map((c, i) => [c.id, `r${i + 1}`]));
  return {
    avaluacions: signals.evaluations,
    errors_pendents: signals.errorCounts.map(e => ({ area: e.area, contingut: e.content_id ? refOf.get(e.content_id) ?? null : null, quantitat: e.count })),
    arees: signals.areaStats,
    recents: signals.recent.map(r => ({ id: refOf.get(r.resource_id) ?? null, area: r.category, nota: r.score !== null && r.total ? Math.round((r.score / r.total) * 100) / 100 : null, data: r.created_at.slice(0, 10) })),
    passos_fets: previous?.learning_path_steps.filter(s => s.status === 'done').flatMap(s => refOf.get(s.resource_id) ?? []) ?? [],
    cataleg: catalog.map(({ sort_order: _order, id: _id, ...item }, i) => ({ id: `r${i + 1}`, ...item })),
  };
}

/* ── Consultes i esdeveniments ────────────────────────────────────────── */
// Ruta activa amb les dades de cada recurs per a pintar-la, o null si encara no en té. No la genera:
// només es genera quan l'usuari ho demana (POST /api/learning-path/regenerate), perquè crida el LLM.
export async function getLearningPath(client: any, userId: string) {
  const path = await activePath(client, userId);
  if (!path) return null;

  const ids = path.learning_path_steps.map(s => s.resource_id);
  const { data: resources, error } = await client
    .from('resources')
    .select('id, name, type, category, content, metadata')
    .in('id', ids);
  if (error) throw error;
  const byId = new Map((resources as { id: string; name: string; type: string; category: string; content: string | null; metadata: Metadata }[]).map(r => [r.id, r]));

  const { learning_path_steps: steps, ...rest } = path;
  return {
    ...rest,
    steps: steps
      .sort((a, b) => a.position - b.position)
      .flatMap(step => {
        const r = byId.get(step.resource_id);
        if (!r) return [];
        const meta = r.metadata ?? {};
        const text = (v: unknown) => (typeof v === 'string' ? v : null);
        return [{
          ...step,
          resource: {
            id: r.id, name: r.name, type: r.type, category: r.category, content: r.content,
            icon: text(meta.icon), color: text(meta.color), section_name: text(meta.section_name),
            has_lesson: Boolean(meta.lesson),
          },
        }];
      }),
  };
}

// Errors pendents de l'usuari classificats en un contingut, per a donar-los per resolts.
async function resolveContentErrors(client: any, userId: string, contentId: string) {
  const { error } = await client
    .from('user_errors')
    .update({ resolved: true, resolved_at: new Date().toISOString() })
    .eq('user_id', userId)
    .eq('content_id', contentId)
    .eq('resolved', false);
  if (error) throw error;
}

export type ResourceResult = {
  resourceId: string;
  kind: 'practice' | 'exam' | 'chat';
  level?: string | null;
  score?: number | null;
  total?: number | null;
  details?: Record<string, unknown>;
};

// Un usuari ha acabat un recurs: es guarda el resultat i es marca el pas de la ruta. La ruta
// no es regenera ací: només quan l'usuari ho demana. Pensat per a cridar-lo en segon pla.
export async function onResourceFinished(client: any, userId: string, result: ResourceResult) {
  const { error } = await client.from('user_resource_results').insert({
    user_id: userId,
    resource_id: result.resourceId,
    kind: result.kind,
    level: result.level ?? null,
    score: result.score ?? null,
    total: result.total ?? null,
    details: result.details ?? {},
  });
  if (error) throw error;

  const path = await activePath(client, userId);
  const step = path?.learning_path_steps.find(s => s.resource_id === result.resourceId && s.status === 'pending');
  if (step) {
    await client.from('learning_path_steps').update({ status: 'done', completed_at: new Date().toISOString() }).eq('id', step.id);
  }

  // Domini d'un contingut: els errors classificats en ell (de xats, pràctica o redaccions) deixen de comptar.
  if (result.score != null && result.total && result.score / result.total >= MASTERY_RATIO) {
    await resolveContentErrors(client, userId, result.resourceId);
  }
}
