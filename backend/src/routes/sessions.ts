import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';
import { scenarioSchema, sessionSchema } from '../schemas.js';
import { runPedagogicalEvaluation } from '../services/subagentRecommendation.js';
import { waitForPendingErrorAnalysis } from '../services/pendingErrorAnalysis.js';
import { onResourceFinished } from '../services/learningPath.js';

const text = (value: unknown) => (typeof value === 'string' && value.trim() ? value.trim() : undefined);


export const sessionsRouter = Router();

sessionsRouter.post('/api/sessions', requireAuth, async (req: AuthRequest, res) => {
  try {
    const body = sessionSchema.parse(req.body);
    const client = db(req.userId);
    if (!client) {
      // Demo mode: return a fake session
      return res.status(201).json({ session_id: crypto.randomUUID() });
    }

    // 1. Insertar la sesión de conversación
    const { data: sessionData, error: sessionError } = await client
      .from('sessions')
      // De momento asumimos que el mundo es abierto: false = abierto, true = cerrado
      .insert({
        user_id: req.userId!,
        level_at_start: body.level,
        world_type: false,
      })
      .select('id')
      .single();

    if (sessionError) throw sessionError;

    console.log(`[sessions] Nueva sesión creada: ${sessionData.id} para usuario ${req.userId}`);
    res.status(201).json({ 
      session_id: sessionData.id,
      // extra_id: extraData.id // opcional si necesitas devolverlo al frontend
    });
  } catch (error) {
    if (error instanceof z.ZodError) return validationError(res, error);
    console.error(error);
    res.status(500).json({ error: 'No hem pogut iniciar la sessió' });
  }
});

const sessionResourceSchema = z.object({
  category: z.string().default('escenari'),
  type: scenarioSchema,
});

sessionsRouter.post('/api/sessions/:sessionId/resources', requireAuth, async (req: AuthRequest, res) => {
  try {
    
    const { sessionId } = req.params;
    const body = sessionResourceSchema.parse(req.body);
    console.log(body);
    const client = db(req.userId);
    if (!client) {
      return res.status(201).json({
        id: crypto.randomUUID(),
        sesion_id: sessionId,
        recurso_id: crypto.randomUUID(),
        resolved: false,
      });
    }
    // A. Blindatge: verificar que la sessió existeix i pertany a l'usuari autenticat
    const { data: userSession, error: sessionCheckError } = await client
      .from('sessions')
      .select('id')
      .eq('id', sessionId)
      .eq('user_id', req.userId)
      .maybeSingle();

    if (sessionCheckError) {
      console.error('[session_resource] Error verificant sessió:', sessionCheckError);
      return res.status(500).json({ error: 'Error verificant la sessió' });
    }

    if (!userSession) {
      return res.status(404).json({ error: 'Sessió no trobada o no autoritzada' });
    }

    
    // B. Buscar el recurs de l'escenari per categoria, tipus i nom
    const { data: resourceData, error: resourceError } = await client
      .from('resources')
      .select('id, metadata')
      .eq('category', body.category)
      .eq('type', body.type)
      .limit(1)
      .maybeSingle();

    if (resourceError || !resourceData) {
      console.error('[session_resource] Recurso no encontrado:', resourceError);
      return res.status(404).json({ error: 'No s\'ha trobat el recurs especificat' });
    }

    // C. Inserir una entrada nova a session_resource (una per cada vegada que s'obri l'escenari)
    // Nota: en la BDD la columna es 'sesion_id' con una sola 's'
    const { data: sessionResourceData, error: sessionResourceError } = await client
      .from('session_resource')
      .insert({
        sesion_id: sessionId,
        recurso_id: resourceData.id,
        resolved: false,
      })
      .select('id, sesion_id, recurso_id, resolved')
      .single();

    if (sessionResourceError) throw sessionResourceError;

    // D. El primer missatge de l'escenari és la salutació del personatge
    // (resources.metadata.initial_prompt), guardada com a torn 'character' perquè
    // forme part de l'historial que llig /api/turn.
    const initialPrompt = text((resourceData.metadata as Record<string, unknown> | null)?.initial_prompt);
    if (initialPrompt) {
      const { error: greetingError } = await client
        .from('conversation_messages')
        .insert({
          session_resource_id: sessionResourceData.id,
          role: 'character',
          content_text: initialPrompt,
          input_mode: 'text',
        });
      if (greetingError) {
        console.error('[session_resource] Error guardant la salutació inicial:', greetingError.message);
      }
    }

    res.status(201).json(sessionResourceData);
  } catch (error) {
    if (error instanceof z.ZodError) {
      console.warn('[session_resource] Petició invàlida:', error.issues);
      return validationError(res, error);
    }
    console.error('[session_resource] Error:', error);
    res.status(500).json({ error: 'No s\'ha pogut vincular el recurs a la sessió' });
  }
});



// Tanca la sessió sencera (p. ex. en fer logout). Ja NO dispara l'avaluació
// pedagògica: ara es dispara per recurs individual, veure l'endpoint de baix.
sessionsRouter.post('/api/sessions/finish', requireAuth, async (req: AuthRequest, res) => {
  try {
    const { session_id } = req.body;

    if (!session_id) {
      return res.status(400).json({ error: 'Falta el camp session_id' });
    }

    const client = db(req.userId);

    // Si estem en mode demo o sense client configurat
    if (!client || !req.userId) {
      return res.json({ ok: true, demo: true });
    }

    // Tanquem la sessió assegurant que pertany a l'usuari autenticat
    const { data: updatedSession, error: updateError } = await client
      .from('sessions')
      .update({ ended_at: new Date().toISOString() })
      .eq('id', session_id)
      .eq('user_id', req.userId)
      .select('id')
      .maybeSingle();

    if (updateError) {
      console.error('[sessions] Error tancant sessió:', updateError);
      return res.status(500).json({ error: 'No s\'ha pogut tancar la sessió' });
    }

    if (!updatedSession) {
      return res.status(404).json({ error: 'Sessió no trobada o no autoritzada' });
    }

    res.json({ ok: true });
  } catch (error) {
    console.error('[sessions] Error finish:', error);
    res.status(500).json({ error: 'Error intern' });
  }
});

// Tanca un recurs individual (botó "Eixir" dins de l'escenari) i dispara
// l'avaluació pedagògica diagnòstica per a eixe recurs concret.
sessionsRouter.post(
  '/api/sessions/:sessionId/resources/:sessionResourceId/finish',
  requireAuth,
  async (req: AuthRequest, res) => {
    try {
      const sessionId = req.params.sessionId as string;
      const sessionResourceId = req.params.sessionResourceId as string;
      const client = db(req.userId);

      if (!client || !req.userId) {
        return res.json({ ok: true, demo: true });
      }

      // Blindatge: el session_resource ha d'existir i pertànyer a una sessió de l'usuari autenticat.
      const { data: sessionResource, error: sessionResourceError } = await client
        .from('session_resource')
        .select('id, sesion_id, recurso_id, sessions!inner(id, user_id)')
        .eq('id', sessionResourceId)
        .eq('sesion_id', sessionId)
        .eq('sessions.user_id', req.userId)
        .maybeSingle();

      if (sessionResourceError) {
        console.error('[session_resource finish] Error verificant recurs:', sessionResourceError);
        return res.status(500).json({ error: 'Error verificant el recurs' });
      }

      if (!sessionResource) {
        return res.status(404).json({ error: 'Recurs de sessió no trobat o no autoritzat' });
      }

      const { error: updateError } = await client
        .from('session_resource')
        .update({ resolved: true })
        .eq('id', sessionResourceId);

      if (updateError) {
        console.error('[session_resource finish] Error tancant recurs:', updateError);
        return res.status(500).json({ error: 'No s\'ha pogut tancar el recurs' });
      }

      // Responem immediatament: l'avaluació es fa en segon pla, sense bloquejar el "Eixir".
      res.json({ ok: true });

      const userId = req.userId;
      void (async () => {
        try {
          // Esperem que acaben totes les anàlisis d'errors (LLM) encara en curs
          // per a aquest recurs abans d'avaluar, si no, l'avaluació pot arribar
          // abans que l'últim torn haja acabat de guardar els seus errors.
          console.log(`[evaluator] Esperant que acabe l'anàlisi d'errors del recurs ${sessionResourceId}...`);
          await waitForPendingErrorAnalysis(sessionResourceId);

          console.log(`[evaluator] Disparant avaluació per a recurs ${sessionResourceId} (usuari ${userId})...`);
          const evalStart = Date.now();
          const report = await runPedagogicalEvaluation(userId, sessionResourceId);

          if (report) {
            console.log(
              `[evaluator] Exit! Categoria: ${report.priority_focus} en ${Date.now() - evalStart}ms`
            );
          } else {
            console.log('[evaluator] No hi ha errors pendents suficients per a avaluar.');
          }
        } catch (err: any) {
          console.error('[evaluator] Error:', err.message);
        }

        // Després de l'avaluació (que pot canviar el focus prioritari) s'actualitza la ruta.
        try {
          await onResourceFinished(client, userId, { resourceId: sessionResource.recurso_id, kind: 'chat' });
        } catch (err: any) {
          console.error('[learning-path] Error actualitzant la ruta:', err.message);
        }
      })();
    } catch (error) {
      console.error('[session_resource finish] Error:', error);
      res.status(500).json({ error: 'Error intern' });
    }
  }
);