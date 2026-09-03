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

export async function requireAuth(req: AuthRequest, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.replace('Bearer ', '');

  // Si no hay token, modo demo: asignar usuario demo
  if (!token) {
    req.userId = 'demo-user';
    return next();
  }

  const client = getAdmin();
  if (!client) {
    // Sin Supabase configurado, modo demo
    req.userId = 'demo-user';
    return next();
  }

  const { data: { user }, error } = await client.auth.getUser(token);
  if (error || !user) {
    // Token inválido: permitir como demo en lugar de bloquear
    req.userId = 'demo-user';
    return next();
  }
  req.userId = user.id;
  next();
}