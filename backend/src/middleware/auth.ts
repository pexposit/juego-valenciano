import type { NextFunction, Request, Response } from 'express';
import { createClient } from '@supabase/supabase-js';

let adminClient: ReturnType<typeof createClient> | null = null;

export function getAdmin() {
  if (!adminClient) {
    const url = process.env.SUPABASE_URL;
    const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
    if (url && key) {
      adminClient = createClient(url, key);
    }
  }
  return adminClient;
}

export { getAdmin as admin };

export interface AuthRequest extends Request {
  userId?: string;
}

/**
 * El modo demostración (jugar sin cuenta) deja probar el juego sin registrarse,
 * pero también deja la API abierta a cualquiera. En producción se desactiva con
 * ALLOW_DEMO=false: entonces las rutas protegidas exigen un token de Supabase.
 */
function demoAllowed() {
  return process.env.ALLOW_DEMO !== 'false';
}

export async function requireAuth(req: AuthRequest, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.replace('Bearer ', '');

  // Si no hay token, modo demo: asignar usuario demo (si está permitido)
  if (!token) {
    if (!demoAllowed()) return res.status(401).json({ error: 'Cal iniciar sessió per a continuar' });
    req.userId = 'demo-user';
    return next();
  }

  const client = getAdmin();
  if (!client) {
    // Sin Supabase configurado no se puede verificar el token: modo demo
    if (!demoAllowed()) {
      return res.status(503).json({ error: 'El servicio de autenticación no está configurado' });
    }
    req.userId = 'demo-user';
    return next();
  }

  const { data: { user }, error } = await client.auth.getUser(token);
  if (error || !user) {
    // Token presente pero inválido/caducado: rechazar (no degradar a demo)
    return res.status(401).json({ error: 'Token inválido o caducado' });
  }
  req.userId = user.id;
  next();
}