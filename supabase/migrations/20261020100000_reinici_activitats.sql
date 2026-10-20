-- Reiniciar una activitat («Tornar a fer»): les rutes i les activitats de la classe deixen de mostrar-la com a
-- corregida i amb la seua nota fins que es torne a corregir. No s'esborra cap resultat (user_resource_results és
-- l'historial que fan servir la ruta personalitzada i els informes de la docent): només es guarda des de quan
-- compta cada activitat per a l'alumne. Un resultat és «vigent» si és posterior al reinici.
-- Sense polítiques: només el backend (service_role) la llig i l'escriu.

CREATE TABLE IF NOT EXISTS public.activity_restarts (
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  resource_id uuid NOT NULL REFERENCES public.resources(id) ON DELETE CASCADE,
  restarted_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, resource_id)
);

ALTER TABLE public.activity_restarts ENABLE ROW LEVEL SECURITY;
