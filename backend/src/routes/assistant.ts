import { Router, type Response } from 'express';
import { z } from 'zod';
import { ASSISTANT_CATEGORY, KID_ASSISTANT_TYPE } from '@parlaval/shared';
import { getAdmin, requireAuth, type AuthRequest } from '../middleware/auth.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';
import { summarizeConversationTitle } from '../services/conversationTitle.js';
import { bilingualGreeting } from '../services/motherTongue.js';

export const assistantRouter = Router();

const HISTORY_LIMIT = 40;
const FALLBACK_GREETING = 'En què et puc ajudar?';

type Message = { role: 'user' | 'character'; text: string };

const openSchema = z.object({ session_id: z.string().uuid() });

// Obri la conversa del xiquet amb el tutor de valencià. La conversa dura tot un login: si ja n'hi ha
// una d'oberta en la sessió actual es torna amb els últims missatges (carregar el tauler un altre cop,
// recarregar la pàgina...); si no, o si l'única oberta és d'un login anterior, es tanca i es crea una de
// nova dins de la sessió actual amb la salutació com a primer missatge. Amb `restart` (botó de tornar a
// començar) sempre es comença una de nova. Tancar és marcar session_resource.resolved: els missatges antics
// es conserven a la BDD, però ja no es mostren.
const openConversation = (restart: boolean) => async (req: AuthRequest, res: Response) => {
  const parsed = openSchema.safeParse(req.body);
  if (!parsed.success) return validationError(res, parsed.error);

  // El recurs és públic (com el catàleg): es llig amb el client admin també en mode demo.
  const admin = getAdmin() as any;
  if (!admin) return res.status(503).json({ error: 'El servei no està disponible' });
  const { data: resource, error: resourceError } = await admin
    .from('resources')
    .select('id, metadata')
    .eq('category', ASSISTANT_CATEGORY)
    .eq('type', KID_ASSISTANT_TYPE)
    .limit(1)
    .maybeSingle();
  if (resourceError || !resource) {
    console.error('[assistant] Recurs del tutor no trobat:', resourceError);
    return res.status(404).json({ error: 'El tutor no està disponible' });
  }
  const greetingValue = (resource.metadata as Record<string, unknown> | null)?.initial_prompt;
  const greeting = typeof greetingValue === 'string' && greetingValue.trim() ? greetingValue.trim() : FALLBACK_GREETING;

  const client = db(req.userId);
  // Mode demo (sense BD): no es guarda res, només la salutació.
  if (!client || !req.userId) {
    return res.json({
      session_id: parsed.data.session_id,
      session_resource_id: crypto.randomUUID(),
      messages: [{ role: 'character', text: greeting }] satisfies Message[],
    });
  }

  try {
    // Conversa oberta de l'usuari amb el tutor (no tancada).
    const { data: open, error: existingError } = await client
      .from('session_resource')
      .select('id, sesion_id, sessions!inner(user_id)')
      .eq('recurso_id', resource.id)
      .eq('sessions.user_id', req.userId)
      .or('resolved.is.null,resolved.eq.false');
    if (existingError) throw existingError;

    const existing = restart ? undefined : open?.find((o: { sesion_id: string }) => o.sesion_id === parsed.data.session_id);
    const stale = (open ?? []).filter((o: { id: string }) => o.id !== existing?.id);
    if (stale.length) {
      const { error: closeError } = await client
        .from('session_resource')
        .update({ resolved: true })
        .in('id', stale.map((o: { id: string }) => o.id));
      if (closeError) throw closeError;
    }

    let sessionId: string = parsed.data.session_id;
    let sessionResourceId: string;

    if (existing) {
      sessionId = existing.sesion_id;
      sessionResourceId = existing.id;
    } else {
      // Només es pot crear dins d'una sessió de l'usuari autenticat.
      const { data: session, error: sessionError } = await client
        .from('sessions')
        .select('id')
        .eq('id', sessionId)
        .eq('user_id', req.userId)
        .maybeSingle();
      if (sessionError) throw sessionError;
      if (!session) return res.status(404).json({ error: 'Sessió no trobada o no autoritzada' });

      const { data: created, error: createError } = await client
        .from('session_resource')
        .insert({ sesion_id: sessionId, recurso_id: resource.id, resolved: false })
        .select('id')
        .single();
      if (createError) throw createError;
      sessionResourceId = created.id;
    }

    const { data: rows, error: messagesError } = await client
      .from('conversation_messages')
      .select('role, content_text')
      .eq('session_resource_id', sessionResourceId)
      .order('created_at', { ascending: false })
      .limit(HISTORY_LIMIT);
    if (messagesError) throw messagesError;

    let messages: Message[] = (rows ?? [])
      .reverse()
      .map((m: { role: 'user' | 'character'; content_text: string }) => ({ role: m.role, text: m.content_text }));

    // Conversa nova (o sense cap missatge perquè la salutació no es va poder guardar): es guarda ara,
    // en valencià i en la llengua materna del xiquet.
    if (messages.length === 0) {
      const { data: profile } = await client.from('profiles').select('mother_tongue').eq('id', req.userId).maybeSingle();
      const text = bilingualGreeting(greeting, profile?.mother_tongue);
      const { error: greetingError } = await client
        .from('conversation_messages')
        .insert({ session_resource_id: sessionResourceId, role: 'character', content_text: text, input_mode: 'text' });
      if (greetingError) console.error('[assistant] Error guardant la salutació:', greetingError.message);
      messages = [{ role: 'character', text }];
    }

    res.json({ session_id: sessionId, session_resource_id: sessionResourceId, messages });
  } catch (error) {
    console.error('[assistant] Error obrint la conversa:', error);
    res.status(500).json({ error: "No s'ha pogut obrir la conversa" });
  }
};

assistantRouter.post('/api/assistant/open', requireAuth, openConversation(false));
assistantRouter.post('/api/assistant/restart', requireAuth, openConversation(true));

const resumeSchema = z.object({ session_id: z.string().uuid(), session_resource_id: z.string().uuid() });

// Torna a una conversa anterior: tanca l'oberta, reobri la triada i la mou a la sessió actual
// perquè /api/assistant/open (que només reprén les de la sessió actual) la trobe en carregar el tauler.
assistantRouter.post('/api/assistant/resume', requireAuth, async (req: AuthRequest, res) => {
  const parsed = resumeSchema.safeParse(req.body);
  if (!parsed.success) return validationError(res, parsed.error);

  const client = db(req.userId);
  const resourceId = await tutorResourceId();
  if (!client || !req.userId || !resourceId) return res.status(503).json({ error: 'El servei no està disponible' });

  try {
    const { data: session, error: sessionError } = await client
      .from('sessions')
      .select('id')
      .eq('id', parsed.data.session_id)
      .eq('user_id', req.userId)
      .maybeSingle();
    if (sessionError) throw sessionError;
    if (!session) return res.status(404).json({ error: 'Sessió no trobada o no autoritzada' });

    const { data: owned, error: ownedError } = await client
      .from('session_resource')
      .select('id, sessions!inner(user_id)')
      .eq('id', parsed.data.session_resource_id)
      .eq('recurso_id', resourceId)
      .eq('sessions.user_id', req.userId)
      .maybeSingle();
    if (ownedError) throw ownedError;
    if (!owned) return res.status(404).json({ error: 'Conversa no trobada' });

    const { error: closeError } = await client
      .from('session_resource')
      .update({ resolved: true })
      .eq('recurso_id', resourceId)
      .neq('id', owned.id)
      .or('resolved.is.null,resolved.eq.false');
    if (closeError) throw closeError;

    const { error: reopenError } = await client
      .from('session_resource')
      .update({ resolved: false, sesion_id: parsed.data.session_id })
      .eq('id', owned.id);
    if (reopenError) throw reopenError;

    res.json({ ok: true });
  } catch (error) {
    console.error('[assistant] Error reprenent la conversa:', error);
    res.status(500).json({ error: "No s'ha pogut reprendre la conversa" });
  }
});

type PastConversation = {
  id: string;
  started_at: string;
  message_count: number;
  title: string; // el que ha posat l'usuari, el resum del LLM o, si no n'hi ha, el primer missatge
  title_edited: boolean; // true si l'ha escrit l'usuari
  preview: string;
  current: boolean;
};

type OwnedConversation = {
  id: string;
  resolved: boolean | null;
  title: string | null;
  title_source: 'user' | 'auto' | null;
  title_message_count: number | null;
};

// Títols automàtics: es generen en llistar les converses que encara no en tenen (com a molt
// TITLES_PER_REQUEST per petició, perquè la llista no tarde) i es tornen a generar quan la
// conversa ha crescut almenys TITLE_REFRESH_AFTER missatges des de l'últim resum.
const TITLES_PER_REQUEST = 6;
const TITLE_REFRESH_AFTER = 8;
const PREVIEW_CHARS = 80;

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const CONVERSATIONS_LIMIT = 50;

async function tutorResourceId() {
  const admin = getAdmin() as any;
  if (!admin) return null;
  const { data } = await admin
    .from('resources')
    .select('id')
    .eq('category', ASSISTANT_CATEGORY)
    .eq('type', KID_ASSISTANT_TYPE)
    .limit(1)
    .maybeSingle();
  return (data?.id as string | undefined) ?? null;
}

// Converses anteriors del xiquet amb el tutor (les tancades i l'actual), de més nova a més antiga.
// Només es llisten les que tenen algun missatge del xiquet: les que només tenen la salutació
// (p. ex. en tornar a començar sense escriure res) no aporten res. La data és la del primer missatge.
assistantRouter.get('/api/assistant/conversations', requireAuth, async (req: AuthRequest, res) => {
  const client = db(req.userId);
  const resourceId = await tutorResourceId();
  if (!client || !req.userId || !resourceId) return res.json([]);

  try {
    const { data: owned, error: ownedError } = await client
      .from('session_resource')
      .select('id, resolved, title, title_source, title_message_count, sessions!inner(user_id)')
      .eq('recurso_id', resourceId)
      .eq('sessions.user_id', req.userId);
    if (ownedError) throw ownedError;
    if (!owned?.length) return res.json([]);

    const { data: rows, error: messagesError } = await client
      .from('conversation_messages')
      .select('session_resource_id, role, content_text, created_at')
      .in('session_resource_id', owned.map((o: { id: string }) => o.id))
      .order('created_at', { ascending: true });
    if (messagesError) throw messagesError;

    const byConversation = new Map<string, { created_at: string; role: string; content_text: string }[]>();
    for (const row of rows ?? []) {
      const list = byConversation.get(row.session_resource_id) ?? [];
      list.push(row);
      byConversation.set(row.session_resource_id, list);
    }

    const conversations: (PastConversation & { needsTitle: boolean })[] = [];
    for (const o of owned as OwnedConversation[]) {
      const messages = byConversation.get(o.id) ?? [];
      const firstUserMessage = messages.find(m => m.role === 'user');
      if (!firstUserMessage) continue;
      const preview = firstUserMessage.content_text.length > PREVIEW_CHARS
        ? `${firstUserMessage.content_text.slice(0, PREVIEW_CHARS - 1).trimEnd()}…`
        : firstUserMessage.content_text;
      const edited = o.title_source === 'user' && !!o.title;
      const stale = o.title_source === 'auto' && messages.length >= (o.title_message_count ?? 0) + TITLE_REFRESH_AFTER;
      conversations.push({
        id: o.id,
        started_at: messages[0].created_at,
        message_count: messages.length,
        title: o.title ?? preview,
        title_edited: edited,
        preview,
        current: !o.resolved,
        needsTitle: !edited && (!o.title || stale),
      });
    }
    conversations.sort((a, b) => b.started_at.localeCompare(a.started_at));
    const page = conversations.slice(0, CONVERSATIONS_LIMIT);

    // Resumix amb el LLM les que no tenen títol (o el tenen antic), les més noves primer.
    await Promise.all(page.filter(c => c.needsTitle).slice(0, TITLES_PER_REQUEST).map(async c => {
      const messages = byConversation.get(c.id) ?? [];
      const title = await summarizeConversationTitle(messages);
      if (!title) return;
      c.title = title;
      const { error } = await client
        .from('session_resource')
        .update({ title, title_source: 'auto', title_message_count: messages.length })
        .eq('id', c.id)
        .or('title_source.is.null,title_source.eq.auto'); // si mentrestant l'ha editat l'usuari, es respecta
      if (error) console.error('[assistant] Error guardant el títol:', error.message);
    }));

    res.json(page.map(({ needsTitle: _needsTitle, ...c }) => c));
  } catch (error) {
    console.error('[assistant] Error llistant les converses:', error);
    res.status(500).json({ error: "No hem pogut carregar les converses" });
  }
});

const titleSchema = z.object({ title: z.string().trim().max(40) });

// Canvia el nom d'una conversa. Un nom buit torna al títol automàtic (el resumirà el LLM).
assistantRouter.patch('/api/assistant/conversations/:id/title', requireAuth, async (req: AuthRequest, res) => {
  const id = req.params.id as string;
  if (!UUID.test(id)) return res.status(400).json({ error: 'Identificador no vàlid' });
  const parsed = titleSchema.safeParse(req.body);
  if (!parsed.success) return validationError(res, parsed.error);

  const client = db(req.userId);
  const resourceId = await tutorResourceId();
  if (!client || !req.userId || !resourceId) return res.status(503).json({ error: 'El servei no està disponible' });

  try {
    const { data: owned, error: ownedError } = await client
      .from('session_resource')
      .select('id, sessions!inner(user_id)')
      .eq('id', id)
      .eq('recurso_id', resourceId)
      .eq('sessions.user_id', req.userId)
      .maybeSingle();
    if (ownedError) throw ownedError;
    if (!owned) return res.status(404).json({ error: 'Conversa no trobada' });

    const title = parsed.data.title.replace(/\s+/g, ' ');
    const fields = title
      ? { title, title_source: 'user', title_message_count: null }
      : { title: null, title_source: null, title_message_count: null };
    const { error } = await client.from('session_resource').update(fields).eq('id', id);
    if (error) throw error;
    res.json({ title: title || null, title_edited: !!title });
  } catch (error) {
    console.error('[assistant] Error canviant el nom de la conversa:', error);
    res.status(500).json({ error: "No s'ha pogut canviar el nom de la conversa" });
  }
});

// Missatges d'una conversa anterior amb el tutor (només si és de l'usuari).
assistantRouter.get('/api/assistant/conversations/:id/messages', requireAuth, async (req: AuthRequest, res) => {
  const id = req.params.id as string;
  if (!UUID.test(id)) return res.status(400).json({ error: 'Identificador no vàlid' });

  const client = db(req.userId);
  const resourceId = await tutorResourceId();
  if (!client || !req.userId || !resourceId) return res.json([]);

  try {
    const { data: owned, error: ownedError } = await client
      .from('session_resource')
      .select('id, sessions!inner(user_id)')
      .eq('id', id)
      .eq('recurso_id', resourceId)
      .eq('sessions.user_id', req.userId)
      .maybeSingle();
    if (ownedError) throw ownedError;
    if (!owned) return res.status(404).json({ error: 'Conversa no trobada' });

    const { data: rows, error: messagesError } = await client
      .from('conversation_messages')
      .select('role, content_text, created_at')
      .eq('session_resource_id', id)
      .order('created_at', { ascending: true });
    if (messagesError) throw messagesError;

    res.json((rows ?? []).map((m: { role: 'user' | 'character'; content_text: string; created_at: string }) => (
      { role: m.role, text: m.content_text, created_at: m.created_at }
    )));
  } catch (error) {
    console.error('[assistant] Error carregant la conversa:', error);
    res.status(500).json({ error: "No hem pogut carregar la conversa" });
  }
});
