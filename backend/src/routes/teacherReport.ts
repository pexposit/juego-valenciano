import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { db } from '../db.js';

export const teacherReportRouter = Router();

/**
 * Activitat de l'alumnat adult d'una classe (pràctiques i exàmens), per a l'informe del professorat: els
 * resultats i els errors es llig només el servidor (cap taula d'ells és visible des del client), així que la
 * docent els demana ací. Cada alumne torna, per activitat, l'última nota i els errors encara sense corregir.
 * Els escenaris no hi són: els objectius es llegixen directament de kids_scenario_reviews.
 */
export type ActivityRow = {
  resource_id: string;
  name: string;
  icon: string | null;
  category: string;
  kind: 'practice' | 'exam';
  score: number | null;
  total: number | null;
  pending_errors: number;
  last_at: string;
};

teacherReportRouter.get('/api/teacher/classes/:classId/activity', requireAuth, async (req: AuthRequest, res) => {
  if (!z.string().uuid().safeParse(req.params.classId).success) return res.status(404).json({ error: 'La classe no existix' });
  const client = db(req.userId);
  if (!client || !req.userId) return res.status(401).json({ error: 'Cal iniciar sessió' });

  try {
    // Només la docent d'esta classe.
    const { data: klass, error: classError } = await client
      .from('kids_classes')
      .select('id')
      .eq('id', req.params.classId)
      .eq('teacher_id', req.userId)
      .maybeSingle();
    if (classError) throw classError;
    if (!klass) return res.status(403).json({ error: 'Esta classe no és teua' });

    const { data: members, error: membersError } = await client
      .from('kids_class_members')
      .select('student_id')
      .eq('class_id', req.params.classId);
    if (membersError) throw membersError;
    const students = (members ?? []).map((m: { student_id: string }) => m.student_id);
    if (students.length === 0) return res.json({});

    const [results, errors] = await Promise.all([
      client
        .from('user_resource_results')
        .select('user_id, resource_id, kind, score, total, created_at, resources!inner(name, category, metadata)')
        .in('user_id', students)
        .in('kind', ['practice', 'exam'])
        .order('created_at', { ascending: false })
        .limit(3000),
      client
        .from('user_errors')
        .select('user_id, resource_id')
        .in('user_id', students)
        .eq('resolved', false)
        .not('resource_id', 'is', null)
        .limit(5000),
    ]);
    if (results.error) throw results.error;
    if (errors.error) throw errors.error;

    const pending = new Map<string, number>();
    for (const e of errors.data ?? []) {
      const key = `${e.user_id}|${e.resource_id}`;
      pending.set(key, (pending.get(key) ?? 0) + 1);
    }

    // L'última nota de cada recurs de cada alumne (els resultats venen de més nou a més antic).
    const byStudent: Record<string, ActivityRow[]> = Object.fromEntries(students.map((id: string) => [id, []]));
    const seen = new Set<string>();
    for (const r of results.data ?? []) {
      const key = `${r.user_id}|${r.resource_id}`;
      if (seen.has(key)) continue;
      seen.add(key);
      const meta = (r.resources?.metadata ?? {}) as { section_name?: unknown; icon?: unknown };
      byStudent[r.user_id].push({
        resource_id: r.resource_id,
        name: typeof meta.section_name === 'string' && meta.section_name ? meta.section_name : r.resources?.name ?? '',
        icon: typeof meta.icon === 'string' ? meta.icon : null,
        category: r.resources?.category ?? '',
        kind: r.kind,
        score: r.score,
        total: r.total,
        pending_errors: pending.get(key) ?? 0,
        last_at: r.created_at,
      });
    }
    res.json(byStudent);
  } catch (error) {
    console.error("[teacher-report] Error carregant l'activitat de la classe:", error);
    res.status(500).json({ error: "No hem pogut carregar l'activitat de la classe" });
  }
});
