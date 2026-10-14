-- Canvi de nivell de l'usuari (des del perfil o després de la prova de nivell).
--   * El nivell ja no el canvia el client directament: la política "own profile" deixava que
--     l'usuari escriguera qualsevol columna de la seua fila. Ara el trigger que protegix el rol
--     també protegix el nivell i el grup d'edat; el canvi passa pel backend
--     (POST /api/profile/level), que el valida, arxiva la ruta de la IA i en guarda l'historial.
--   * level_changes: historial dels canvis (només el llig i l'escriu el backend).

CREATE TABLE IF NOT EXISTS public.level_changes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  from_level text NOT NULL,
  to_level text NOT NULL,
  -- manual: des del perfil; placement: acceptant el resultat de la prova de nivell.
  reason text NOT NULL CHECK (reason = ANY (ARRAY['manual'::text, 'placement'::text])),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT level_changes_levels_check CHECK (
    from_level = ANY (ARRAY['nivell0'::text, 'A1'::text, 'A2'::text, 'B1'::text, 'B2'::text, 'C1'::text, 'C2'::text])
    AND to_level = ANY (ARRAY['nivell0'::text, 'A1'::text, 'A2'::text, 'B1'::text, 'B2'::text, 'C1'::text, 'C2'::text])
  )
);

CREATE INDEX IF NOT EXISTS idx_level_changes_user ON public.level_changes (user_id, created_at DESC);

-- Sense polítiques: només el backend (service_role).
ALTER TABLE public.level_changes ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.profiles_protect_role()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  -- Només les peticions de l'app (amb JWT d'usuari) estan limitades; la service_role,
  -- el trigger de registre i l'SQL Editor poden assignar el rol i canviar el nivell.
  IF coalesce(auth.role(), '') NOT IN ('anon', 'authenticated') THEN
    RETURN NEW;
  END IF;
  IF TG_OP = 'INSERT' THEN
    NEW.role := 'user';
  ELSIF NEW.role IS DISTINCT FROM OLD.role THEN
    RAISE EXCEPTION 'No es pot canviar el rol del perfil' USING ERRCODE = '42501';
  ELSIF NEW.level IS DISTINCT FROM OLD.level OR NEW.age_group IS DISTINCT FROM OLD.age_group THEN
    RAISE EXCEPTION 'El nivell es canvia des del perfil de l''app' USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$$;
