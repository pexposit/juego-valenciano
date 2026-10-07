import { supabase } from './supabase';

/**
 * Dades de l'usuari que poden ser sensibles (el que escriu o diu): es guarden només en este
 * navegador (IndexedDB), no al servidor. Persistixen en este dispositiu i navegador; si
 * l'usuari esborra les dades del lloc o canvia de dispositiu, es perden.
 *   * messages / conversations: les converses (escenaris i tutor del tauler) i els seus títols.
 *   * errors: el text dels errors (frase, correcció, explicació, context). El servidor en té les
 *     metadades amb el mateix id (categoria, si està resolt...).
 *   * evaluations: les avaluacions pedagògiques (resum i punts febles) en acabar un xat.
 * Cada registre porta el userId: en un mateix navegador hi pot haver diversos comptes.
 * Per a cada usuari es guarden com a molt MAX_CONVERSATIONS converses (de MAX_MESSAGES missatges),
 * MAX_ERRORS errors i MAX_EVALUATIONS avaluacions: en passar-se'n, s'esborra el més antic.
 * Si IndexedDB no està disponible (navegació privada en alguns navegadors...), no es guarda res.
 */

const DB_NAME = 'parlaval-local';
const DB_VERSION = 1;

const MAX_CONVERSATIONS = 30;
const MAX_MESSAGES = 1000; // per conversa
const MAX_ERRORS = 2000;
const MAX_EVALUATIONS = 100;

export type ConversationKind = 'scenario' | 'tutor';

export type LocalMessage = {
  id: string;
  userId: string;
  conversationId: string; // session_resource_id
  role: 'user' | 'character';
  text: string;
  createdAt: string;
};

export type LocalConversation = {
  id: string; // session_resource_id
  userId: string;
  kind: ConversationKind;
  startedAt: string;
  // Converses amb el tutor: el nom que ha posat l'usuari ('user') o el resum del LLM ('auto').
  title: string | null;
  titleSource: 'user' | 'auto' | null;
  titleMessageCount: number | null;
  // La conversa amb el tutor oberta ara (la que continua el tauler).
  current: boolean;
};

export type LocalError = {
  id: string; // el mateix que user_errors.id al servidor
  userId: string;
  source: 'chat' | 'practice' | 'writing';
  errorText: string;
  correction: string;
  category: string;
  explanation: string;
  context: string | null;
  options: string[] | null;
  exerciseId: string | null;
  sessionResourceId: string | null;
  // Activitat on es va cometre (nom de l'escenari o de la pràctica).
  scenario: string | null;
  // Els errors del xat amb el tutor del tauler no es practiquen en la pestanya «Errors».
  practicable: boolean;
  resolved: boolean;
  createdAt: string;
};

export type LocalEvaluation = {
  id: string;
  userId: string;
  sessionResourceId: string;
  summary: string;
  weaknesses: string[];
  priorityFocus: string;
  createdAt: string;
};

type Stores = {
  messages: LocalMessage;
  conversations: LocalConversation;
  errors: LocalError;
  evaluations: LocalEvaluation;
};
type StoreName = keyof Stores;

let dbPromise: Promise<IDBDatabase | null> | undefined;

function openDb(): Promise<IDBDatabase | null> {
  dbPromise ??= new Promise(resolve => {
    try {
      if (typeof indexedDB === 'undefined') return resolve(null);
      const request = indexedDB.open(DB_NAME, DB_VERSION);
      request.onupgradeneeded = () => {
        const db = request.result;
        db.createObjectStore('messages', { keyPath: 'id' }).createIndex('conversationId', 'conversationId');
        db.createObjectStore('conversations', { keyPath: 'id' }).createIndex('userId', 'userId');
        db.createObjectStore('errors', { keyPath: 'id' }).createIndex('userId', 'userId');
        db.createObjectStore('evaluations', { keyPath: 'id' }).createIndex('userId', 'userId');
      };
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => {
        console.warn("[localStore] No s'ha pogut obrir IndexedDB:", request.error);
        resolve(null);
      };
      request.onblocked = () => resolve(null);
    } catch (error) {
      console.warn('[localStore] IndexedDB no disponible:', error);
      resolve(null);
    }
  });
  return dbPromise;
}

const done = <T>(request: IDBRequest<T>) =>
  new Promise<T>((resolve, reject) => {
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });

const committed = (tx: IDBTransaction) =>
  new Promise<void>((resolve, reject) => {
    tx.oncomplete = () => resolve();
    tx.onerror = tx.onabort = () => reject(tx.error);
  });

async function getAllBy<S extends StoreName>(store: S, index: string, value: string): Promise<Stores[S][]> {
  const db = await openDb();
  if (!db) return [];
  return done(db.transaction(store).objectStore(store).index(index).getAll(value)) as Promise<Stores[S][]>;
}

async function getOne<S extends StoreName>(store: S, id: string): Promise<Stores[S] | undefined> {
  const db = await openDb();
  if (!db) return undefined;
  return done(db.transaction(store).objectStore(store).get(id)) as Promise<Stores[S] | undefined>;
}

async function putAll<S extends StoreName>(store: S, rows: Stores[S][]) {
  const db = await openDb();
  if (!db || rows.length === 0) return;
  const tx = db.transaction(store, 'readwrite');
  for (const row of rows) tx.objectStore(store).put(row);
  await committed(tx);
}

async function deleteKeys(store: StoreName, ids: string[]) {
  const db = await openDb();
  if (!db || ids.length === 0) return;
  const tx = db.transaction(store, 'readwrite');
  for (const id of ids) tx.objectStore(store).delete(id);
  await committed(tx);
}

// Els registres que sobren per a arribar a `max`, dels més antics als més nous.
const oldestBeyond = <T>(rows: T[], max: number, dateOf: (row: T) => string) =>
  [...rows].sort((a, b) => dateOf(a).localeCompare(dateOf(b))).slice(0, Math.max(0, rows.length - max));

/** L'usuari amb sessió en este navegador (sense sessió, mode demo, no es guarda res). */
export async function currentUserId(): Promise<string | null> {
  return (await supabase?.auth.getSession())?.data.session?.user.id ?? null;
}

const byDate = <T extends { createdAt: string }>(a: T, b: T) => a.createdAt.localeCompare(b.createdAt);

/* ── Converses ────────────────────────────────────────────────────────── */

/** Afig missatges a una conversa (i la crea si encara no hi era). */
export async function addMessages(
  conversationId: string,
  kind: ConversationKind,
  messages: { role: 'user' | 'character'; text: string; createdAt?: string }[],
) {
  const userId = await currentUserId();
  if (!userId || messages.length === 0) return;
  const now = Date.now();
  // Mil·lisegons consecutius: l'ordre es manté encara que s'afigen en el mateix instant.
  const rows: LocalMessage[] = messages.map((m, i) => ({
    id: crypto.randomUUID(),
    userId,
    conversationId,
    role: m.role,
    text: m.text,
    createdAt: m.createdAt ?? new Date(now + i).toISOString(),
  }));
  const created = !(await getOne('conversations', conversationId));
  if (created) {
    await putAll('conversations', [{
      id: conversationId, userId, kind, startedAt: rows[0].createdAt, title: null, titleSource: null, titleMessageCount: null, current: false,
    }]);
  }
  await putAll('messages', rows);

  // Una conversa massa llarga perd els missatges més antics.
  const all = await getAllBy('messages', 'conversationId', conversationId);
  await deleteKeys('messages', oldestBeyond(all, MAX_MESSAGES, m => m.createdAt).map(m => m.id));
  if (created) await pruneConversations(userId);
}

// Sobren converses: s'esborren les començades fa més temps (amb els seus missatges), però
// mai la conversa amb el tutor oberta ara.
async function pruneConversations(userId: string) {
  const all = await getAllBy('conversations', 'userId', userId);
  const removable = all.filter(c => !c.current);
  const excess = Math.max(0, all.length - MAX_CONVERSATIONS);
  const doomed = oldestBeyond(removable, removable.length - excess, c => c.startedAt);
  for (const c of doomed) {
    const messages = await getAllBy('messages', 'conversationId', c.id);
    await deleteKeys('messages', messages.map(m => m.id));
  }
  await deleteKeys('conversations', doomed.map(c => c.id));
}

/** Els missatges d'una conversa de l'usuari, en ordre (buit si no és d'este navegador). */
export async function getMessages(conversationId: string): Promise<LocalMessage[]> {
  const userId = await currentUserId();
  if (!userId) return [];
  return (await getAllBy('messages', 'conversationId', conversationId)).filter(m => m.userId === userId).sort(byDate);
}

export async function listConversations(kind: ConversationKind): Promise<LocalConversation[]> {
  const userId = await currentUserId();
  if (!userId) return [];
  return (await getAllBy('conversations', 'userId', userId)).filter(c => c.kind === kind);
}

export async function updateConversation(id: string, patch: Partial<Pick<LocalConversation, 'title' | 'titleSource' | 'titleMessageCount'>>) {
  const conversation = await getOne('conversations', id);
  if (conversation && conversation.userId === (await currentUserId())) await putAll('conversations', [{ ...conversation, ...patch }]);
}

/** Marca la conversa amb el tutor oberta ara (la crea, buida, si encara no hi era). */
export async function setCurrentTutorConversation(id: string) {
  const userId = await currentUserId();
  if (!userId) return;
  const all = await listConversations('tutor');
  const existing = all.find(c => c.id === id);
  await putAll('conversations', [
    ...all.filter(c => c.current && c.id !== id).map(c => ({ ...c, current: false })),
    existing
      ? { ...existing, current: true }
      : { id, userId, kind: 'tutor' as const, startedAt: new Date().toISOString(), title: null, titleSource: null, titleMessageCount: null, current: true },
  ]);
  if (!existing) await pruneConversations(userId);
}

/* ── Errors ───────────────────────────────────────────────────────────── */

export async function addErrors(errors: Omit<LocalError, 'userId'>[]) {
  const userId = await currentUserId();
  if (!userId) return;
  await putAll('errors', errors.map(e => ({ ...e, userId })));
  // Sobren errors: s'esborren els més antics.
  const all = await getAllBy('errors', 'userId', userId);
  await deleteKeys('errors', oldestBeyond(all, MAX_ERRORS, e => e.createdAt).map(e => e.id));
}

export async function listErrors(): Promise<LocalError[]> {
  const userId = await currentUserId();
  if (!userId) return [];
  return getAllBy('errors', 'userId', userId);
}

export async function markErrorsResolved(ids: string[]) {
  const wanted = new Set(ids);
  await putAll('errors', (await listErrors()).filter(e => wanted.has(e.id) && !e.resolved).map(e => ({ ...e, resolved: true })));
}

/* ── Avaluacions ──────────────────────────────────────────────────────── */

export async function addEvaluation(evaluation: Omit<LocalEvaluation, 'id' | 'userId'>) {
  const userId = await currentUserId();
  if (!userId) return;
  await putAll('evaluations', [{ ...evaluation, id: crypto.randomUUID(), userId }]);
  // Sobren avaluacions: s'esborren les més antigues.
  const all = await getAllBy('evaluations', 'userId', userId);
  await deleteKeys('evaluations', oldestBeyond(all, MAX_EVALUATIONS, e => e.createdAt).map(e => e.id));
}

/** Les últimes avaluacions de l'usuari, de més nova a més antiga. */
export async function latestEvaluations(limit: number): Promise<LocalEvaluation[]> {
  const userId = await currentUserId();
  if (!userId) return [];
  return (await getAllBy('evaluations', 'userId', userId)).sort((a, b) => byDate(b, a)).slice(0, limit);
}
