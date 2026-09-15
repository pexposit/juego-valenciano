import { getAdmin } from './middleware/auth.js';

/** Helper to get the Supabase client cast to `any` so it works without generated types */
export function db(userId?: string) {
  // Demo user: skip database operations
  if (userId === 'demo-user') return null;
  const client = getAdmin();
  if (!client) return null;
  return client as any;
}
