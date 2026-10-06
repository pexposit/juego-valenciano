import { Router } from 'express';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { db } from '../db.js';

export const kidsRouter = Router();

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

// Una conversa del Nivell 0 (un escenari com el del mag Merlí), per al seguiment: els missatges,
// en ordre. Només per a la família (el compte del xiquet, on entra amb el PIN) i per a les docents
// d'alguna classe on està el xiquet. La política RLS de conversation_messages no ho permet des
// del navegador, per això passa pel backend.
kidsRouter.get('/api/kids/conversations/:id/messages', requireAuth, async (req: AuthRequest, res) => {
  const id = req.params.id as string;
  if (!UUID.test(id)) return res.status(400).json({ error: 'Conversa no vàlida' });
  const client = db(req.userId);
  if (!client || !req.userId) return res.json([]);

  try {
    const { data: review, error: reviewError } = await client
      .from('kids_scenario_reviews')
      .select('user_id')
      .eq('session_resource_id', id)
      .maybeSingle();
    if (reviewError) throw reviewError;
    if (!review || !(review.user_id === req.userId || (await isTeacherOf(client, req.userId, review.user_id)))) {
      return res.status(404).json({ error: 'Conversa no trobada' });
    }

    const { data, error } = await client
      .from('conversation_messages')
      .select('role, content_text, created_at')
      .eq('session_resource_id', id)
      .order('created_at', { ascending: true });
    if (error) throw error;
    res.json((data ?? []).map((m: { role: string; content_text: string; created_at: string }) => ({
      role: m.role === 'user' ? 'user' : 'character',
      text: m.content_text,
      created_at: m.created_at,
    })));
  } catch (error) {
    console.error('[kids] Error carregant la conversa:', error);
    res.status(500).json({ error: 'No hem pogut carregar la conversa' });
  }
});

/** La docent `teacher` té el xiquet `student` en alguna de les seues classes? */
async function isTeacherOf(client: any, teacher: string, student: string): Promise<boolean> {
  const { data, error } = await client
    .from('kids_class_members')
    .select('class_id, kids_classes!inner(teacher_id)')
    .eq('student_id', student)
    .eq('kids_classes.teacher_id', teacher)
    .limit(1);
  if (error) throw error;
  return (data ?? []).length > 0;
}
