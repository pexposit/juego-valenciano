import { supabase } from '../../lib/supabase';

/**
 * Rutes que crea el professorat per a una classe (taula study_paths). Es lligen amb la RLS
 * (cada docent veu les seues) i s'escriuen amb save_study_path, que valida que la classe és
 * de la docent i que totes les activitats són del nivell de la ruta.
 */

export type ClassPath = {
  id: string;
  level: string;
  title: string;
  description: string;
  resources: string[]; // ids de resources, en ordre
};

// Nivells de l'app per als quals el professorat pot crear rutes (com en PREDEFINED_PATH_LEVELS):
// cada un cobrix dos nivells del MECR.
export const PATH_LEVELS = [
  { value: 'principiant', label: 'A1-A2' },
  { value: 'intermedi', label: 'B1-B2' },
] as const;

const need = () => {
  if (!supabase) throw new Error('Cal connexió amb el servidor');
  return supabase;
};

export async function loadClassPaths(classId: string): Promise<ClassPath[]> {
  const { data, error } = await need()
    .from('study_paths')
    .select('id, level, title, description, study_path_steps(position, resource_id)')
    .eq('class_id', classId)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []).map(p => ({
    id: p.id as string,
    level: p.level as string,
    title: p.title as string,
    description: p.description as string,
    resources: [...(p.study_path_steps as { position: number; resource_id: string }[])]
      .sort((a, b) => a.position - b.position)
      .map(s => s.resource_id),
  }));
}

/** Crea (sense `id`) o actualitza una ruta de la classe. */
export async function saveClassPath(classId: string, path: Omit<ClassPath, 'id'> & { id?: string }): Promise<ClassPath> {
  const { data, error } = await need().rpc('save_study_path', {
    p_id: path.id ?? null,
    p_class: classId,
    p_level: path.level,
    p_title: path.title,
    p_description: path.description,
    p_resources: path.resources,
  });
  if (error) throw error;
  const saved = data as { id: string; level: string; title: string; description: string };
  return { id: saved.id, level: saved.level, title: saved.title, description: saved.description, resources: path.resources };
}

export async function deleteClassPath(id: string) {
  const { error } = await need().from('study_paths').delete().eq('id', id);
  if (error) throw error;
}
