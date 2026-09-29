import { Router } from 'express';
import { z } from 'zod';
import { getAdmin } from '../middleware/auth.js';
import { isScenarioPlayable, SCENARIO_CATEGORY } from '../services/scenarios.js';

export const resourcesRouter = Router();

type Metadata = Record<string, unknown> | null;
type ResourceRow = { category: string; url: string | null; metadata: Metadata };

const text = (value: unknown) => (typeof value === 'string' && value.trim() ? value : null);

export const EXAM_CATEGORY = 'examen';

// Cada categoria té la seua pantalla de joc i decidix si una fila té les dades
// que necessita. Les categories sense pantalla es mostren com a "Pròximament".
const PLAYABLE_BY_CATEGORY: Record<string, (row: ResourceRow) => boolean> = {
  // Xat amb un personatge.
  [SCENARIO_CATEGORY]: row => isScenarioPlayable(row.metadata),
  // Examen interactiu: contingut a metadata.exam i, opcionalment, l'àudio de comprensió oral a `url`.
  [EXAM_CATEGORY]: row => hasExam(row.metadata),
};

function hasExam(metadata: Metadata) {
  const exam = metadata?.exam as { areas?: unknown } | undefined;
  return Array.isArray(exam?.areas) && exam.areas.length > 0;
}

const isPlayable = (row: ResourceRow) => PLAYABLE_BY_CATEGORY[row.category]?.(row) ?? false;

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

  // De metadata només s'exposa el que necessiten les pantalles, no el prompt del personatge.
  res.json((data ?? []).map(({ metadata, ...resource }: ResourceRow & Record<string, unknown>) => ({
    ...resource,
    icon: text(metadata?.icon),
    color: text(metadata?.color),
    section_name: text(metadata?.section_name),
    background: text(metadata?.background),
    voice: text(metadata?.voice),
    initial_prompt: text(metadata?.initial_prompt),
    playable: isPlayable({ ...resource, metadata }),
  })));
});

// Contingut complet d'un examen (preguntes, opcions i solucions). Va a banda del
// catàleg perquè és gran i només el necessita la pantalla de l'examen.
resourcesRouter.get('/api/exams/:id', async (req, res) => {
  const client = getAdmin() as any;
  if (!client) return res.status(503).json({ error: "El catàleg no està disponible" });
  // Un id que no és UUID faria fallar la consulta: es tracta com a no trobat.
  if (!z.string().uuid().safeParse(req.params.id).success) return res.status(404).json({ error: "L'examen no existix" });

  const { data, error } = await client
    .from('resources')
    .select('id, name, type, category, difficulty, xp_earned, content, url, metadata')
    .eq('id', req.params.id)
    .eq('category', EXAM_CATEGORY)
    .maybeSingle();

  if (error) {
    console.error("[exams] Error carregant l'examen:", error);
    return res.status(500).json({ error: "No hem pogut carregar l'examen" });
  }
  if (!data || !hasExam(data.metadata)) return res.status(404).json({ error: "L'examen no existix" });

  const { metadata, ...resource } = data;
  res.json({ ...resource, icon: text(metadata.icon), color: text(metadata.color), exam: metadata.exam });
});
