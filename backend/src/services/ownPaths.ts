import { hasOwnPaths, hasPredefinedPaths, type OwnPathResult, type StudyPathRef } from '@parlaval/shared';
import { generatePath, loadPathCandidates } from './teacherAgent.js';

/**
 * Rutes d'aprenentatge per al tutor del xat:
 * - les que l'aprenent pot obrir (predefinides del seu nivell, de les seues classes i pròpies), perquè el tutor el
 *   porte a la que demana;
 * - les rutes pròpies, que el tutor li prepara amb activitats que ja existixen quan diu que li costa alguna cosa i
 *   accepta l'oferta. Es munten amb el mateix agent que les rutes de la docent (generatePath) i es guarden amb
 *   save_own_study_path, que en torna a validar el nivell i les activitats.
 */

// Rutes que es passen al model com a màxim (les pròpies i les de classe, primer).
const MAX_VISIBLE = 60;

const COLUMNS = 'id, title, description';
const none = Promise.resolve({ data: [], error: null });

/**
 * Les rutes que l'aprenent pot obrir en /ruta: les seues, les de les classes on és i les predefinides del seu nivell (si
 * en té). El client del backend és l'admin (sense RLS): cada consulta filtra explícitament per l'usuari.
 */
export async function loadVisiblePaths(client: any, userId: string, level: string): Promise<StudyPathRef[]> {
  const { data: memberships, error: membershipsError } = await client.from('kids_class_members').select('class_id').eq('student_id', userId);
  if (membershipsError) throw membershipsError;
  const classIds = ((memberships ?? []) as { class_id: string }[]).map(m => m.class_id);
  const [own, classes, predefined] = await Promise.all([
    client.from('study_paths').select(COLUMNS).eq('student_id', userId).order('created_at', { ascending: false }),
    classIds.length ? client.from('study_paths').select(COLUMNS).in('class_id', classIds).order('created_at', { ascending: false }) : none,
    // Les predefinides només es veuen en /ruta en els nivells que en tenen, i només les del seu nivell.
    hasPredefinedPaths(level)
      ? client.from('study_paths').select(COLUMNS).is('teacher_id', null).is('student_id', null).eq('level', level).order('sort_order')
      : none,
  ]);
  for (const result of [own, classes, predefined]) if (result.error) throw result.error;
  return [...own.data, ...classes.data, ...predefined.data]
    .slice(0, MAX_VISIBLE)
    .map(({ id, title, description }: StudyPathRef) => ({ id, title, description }));
}

const NOT_AVAILABLE = "No he pogut preparar la ruta ara mateix. Torna-ho a provar d'ací a un moment.";

/** Prepara i guarda una ruta pròpia sobre `topic` (el que li costa a l'aprenent) amb activitats del seu nivell. */
export async function generateOwnPath(client: any, userId: string, level: string, topic: string, signal?: AbortSignal): Promise<OwnPathResult> {
  if (!hasOwnPaths(level)) return { status: 'error', message: 'El teu nivell encara no té rutes.' };

  // Les activitats d'un tema concret solen ser poques: es completa amb alguna d'aplicació del nivell (que l'agent de la
  // docent, sense esta indicació, no hi posaria per no omplir la ruta amb activitats d'un altre tema).
  const prompt = `Ruta per a un aprenent de nivell ${level} a qui li costa: «${topic}». Primer, totes les activitats que treballen eixe tema, de les més bàsiques a les més complexes. Després, per a aplicar-lo, 1 o 2 activitats del nivell de lectura, redacció o conversa on haja de fer-lo servir. Estes d'aplicació són rellevants per a la petició.`;
  // Només activitats del catàleg: l'alumne no en té de pròpies (save_own_study_path tampoc les accepta).
  const candidates = (await loadPathCandidates(client, userId, [level], prompt)).filter(c => !c.own);
  const result = await generatePath(prompt, candidates, [level], signal);

  if (result.status === 'error') return { status: 'error', message: NOT_AVAILABLE };
  if (result.status === 'insufficient' || !result.steps.length) {
    return {
      status: 'insufficient',
      message: `Encara no hi ha prou activitats de ${level} sobre «${topic}» per a preparar-te una ruta. De moment, pots practicar-ho amb les rutes del teu nivell.`,
    };
  }

  const { data, error } = await client.rpc('save_own_study_path', {
    p_student: userId,
    p_title: result.title,
    p_description: result.description,
    p_resources: result.steps.map(s => s.resource_id),
  });
  if (error) {
    // Validacions de la BDD (p. ex. el límit de rutes pròpies): el missatge ja és per a l'aprenent.
    if (error.code === '22023') return { status: 'error', message: error.message };
    throw error;
  }
  const saved = data as { id: string; title: string; description: string };
  return {
    status: 'ok',
    path: { id: saved.id, title: saved.title, description: saved.description },
    message: `T'he preparat la ruta «${saved.title}» amb ${result.steps.length} activitats. La tens en «Les teues rutes».`,
  };
}
