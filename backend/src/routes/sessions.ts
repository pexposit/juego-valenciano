import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';
import { sessionSchema } from '../schemas.js';
import { runPedagogicalEvaluation } from '../services/subagentRecommendation.js';


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
  category: z.string().default('libre'),
  scenario: z.string(), // o el nombre/tipo de la actividad
});

sessionsRouter.post('/api/sessions/:sessionId/resources', requireAuth, async (req: AuthRequest, res) => {
  try {
    const { sessionId } = req.params;
    const body = sessionResourceSchema.parse(req.body);

    const client = db(req.userId);
    if (!client) {
      return res.status(201).json({
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
    console.log(userSession);
    if (sessionCheckError) {
      console.error('[session_resource] Error verificant sessió:', sessionCheckError);
      return res.status(500).json({ error: 'Error verificant la sessió' });
    }

    if (!userSession) {
      return res.status(404).json({ error: 'Sessió no trobada o no autoritzada' });
    }


    // A. Buscar el recurso existente por categoría y tipo
    const { data: resourceData, error: resourceError } = await client
      .from('resources')
      .select('id')
      .eq('category', body.category)
      .eq('type', body.scenario)
      .mayBesingle();

    if (resourceError || !resourceData) {
      console.error('[session_resource] Recurso no encontrado:', resourceError);
      return res.status(404).json({ error: 'No s\'ha trobat el recurs especificat' });
    }

    // B. Insertar la instancia de actividad en session_resource
    // Nota: en la BDD la columna es 'sesion_id' con una sola 's'
    const { data: sessionResourceData, error: sessionResourceError } = await client
      .from('session_resource')
      .insert({
        sesion_id: sessionId,
        recurso_id: resourceData.id,
        resolved: false,
      })
      .select('sesion_id, recurso_id, resolved')
      .single();

    if (sessionResourceError) throw sessionResourceError;

    
    res.status(201).json(sessionResourceData);
  } catch (error) {
    if (error instanceof z.ZodError) return validationError(res, error);
    console.error('[session_resource] Error:', error);
    res.status(500).json({ error: 'No s\'ha pogut vincular el recurs a la sessió' });
  }
});



// Endpoint temporal només per a testejar el disparador de recomanació
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

    // 1. Tanquem la sessió assegurant que pertany a l'usuari autenticat
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

    // 2. Responem immediatament al frontend
    res.json({ ok: true });

    // 3. Avaluació en segon pla (sense bloquejar la resposta HTTP)
    const userId = req.userId;
    void (async () => {
      try {
        console.log(`[testEvaluator] Disparant avaluació per a usuari ${userId}...`);
        const evalStart = Date.now();
        const report = await runPedagogicalEvaluation(userId);

        if (report) {
          console.log(
            `[testEvaluator] Exit! Categoria: ${report.priority_focus} en ${Date.now() - evalStart}ms`
          );
        } else {
          console.log('[testEvaluator] No hi ha errors pendents suficients per a avaluar.');
        }
      } catch (err: any) {
        console.error('[testEvaluator] Error:', err.message);
      }
    })();
  } catch (error) {
    console.error('[sessions] Error finish:', error);
    res.status(500).json({ error: 'Error intern' });
  }
});