import { Router, type Response } from 'express';
import { z } from 'zod';
import { ASSISTANT_CATEGORY, KID_ASSISTANT_TYPE } from '@parlaval/shared';
import { getAdmin, requireAuth, type AuthRequest } from '../middleware/auth.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';
import { bilingualGreeting } from '../services/motherTongue.js';
import { assistantGreeting, assistantGreetingIsTranslated } from '../services/assistantLevel.js';

export const assistantRouter = Router();

const HISTORY_LIMIT = 40;

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
  const client = db(req.userId);
  // Mode demo (sense BD): no es guarda res, només la salutació.
  if (!client || !req.userId) {
    return res.json({
      session_id: parsed.data.session_id,
      session_resource_id: crypto.randomUUID(),
      messages: [{ role: 'character', text: assistantGreeting('principiant') }] satisfies Message[],
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
    // en valencià (segons el nivell de l'usuari) i en la seua llengua materna.
    if (messages.length === 0) {
      const { data: profile } = await client.from('profiles').select('mother_tongue, level').eq('id', req.userId).maybeSingle();
      const greeting = assistantGreeting(profile?.level);
      const text = assistantGreetingIsTranslated(profile?.level) ? bilingualGreeting(greeting, profile?.mother_tongue) : greeting;
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
  preview: string;
  current: boolean;
};

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
      .select('id, resolved, sessions!inner(user_id)')
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

    const conversations: PastConversation[] = [];
    for (const o of owned as { id: string; resolved: boolean | null }[]) {
      const messages = byConversation.get(o.id) ?? [];
      const firstUserMessage = messages.find(m => m.role === 'user');
      if (!firstUserMessage) continue;
      conversations.push({
        id: o.id,
        started_at: messages[0].created_at,
        message_count: messages.length,
        preview: firstUserMessage.content_text,
        current: !o.resolved,
      });
    }
    conversations.sort((a, b) => b.started_at.localeCompare(a.started_at));
    res.json(conversations.slice(0, CONVERSATIONS_LIMIT));
  } catch (error) {
    console.error('[assistant] Error llistant les converses:', error);
    res.status(500).json({ error: "No hem pogut carregar les converses" });
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
