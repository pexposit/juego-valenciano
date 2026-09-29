import { Router } from 'express';
import { getAdmin } from '../middleware/auth.js';
import { isPlayable } from '../services/scenarios.js';

export const resourcesRouter = Router();

const text = (value: unknown) => (typeof value === 'string' && value.trim() ? value : null);

// Catàleg d'activitats (taula resources). El frontend l'agrupa per `category`
// i, dins de cada categoria, per `type`: afegir una fila a la BDD fa aparéixer
// l'activitat sense tocar codi. És públic: el catàleg no té dades d'usuari.
resourcesRouter.get('/api/resources', async (_req, res) => {
  const client = getAdmin() as any;
  if (!client) return res.json([]);

  const { data, error } = await client
    .from('resources')
    .select('id, name, type, category, difficulty, xp_earned, content, url, metadata')
    .order('category')
    .order('type')
    .order('name');

  if (error) {
    console.error('[resources] Error carregant el catàleg:', error);
    return res.status(500).json({ error: "No hem pogut carregar les activitats" });
  }

  // De metadata només s'exposa l'aparença i si és jugable, no el prompt del personatge.
  res.json((data ?? []).map(({ metadata, ...resource }: { metadata: Record<string, unknown> | null; category: string }) => ({
    ...resource,
    icon: text(metadata?.icon),
    color: text(metadata?.color),
    section_name: text(metadata?.section_name),
    background: text(metadata?.background),
    voice: text(metadata?.voice),
    playable: isPlayable(resource.category, metadata),
  })));
});
