import { Router } from 'express';
import { getAdmin } from '../middleware/auth.js';

export const resourcesRouter = Router();

// Catàleg d'activitats (taula resources). El frontend l'agrupa per `category`
// i, dins de cada categoria, per `type`: afegir una fila a la BDD fa aparéixer
// l'activitat sense tocar codi. És públic: el catàleg no té dades d'usuari.
resourcesRouter.get('/api/resources', async (_req, res) => {
  const client = getAdmin() as any;
  if (!client) return res.json([]);

  const { data, error } = await client
    .from('resources')
    // De metadata només s'exposa l'aparença de la secció, no els prompts.
    .select('id, name, type, category, difficulty, xp_earned, content, url, icon:metadata->>icon, color:metadata->>color, section_name:metadata->>section_name')
    .order('category')
    .order('type')
    .order('name');

  if (error) {
    console.error('[resources] Error carregant el catàleg:', error);
    return res.status(500).json({ error: "No hem pogut carregar les activitats" });
  }
  res.json(data ?? []);
});
