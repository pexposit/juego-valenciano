-- Rol de professorat: només els perfils amb role = 'teacher' poden crear classes.
--   * El rol no es tria en crear el compte: l'assigna un administrador (SQL Editor / Studio
--     o el backend amb la service_role). Exemple:
--       UPDATE public.profiles SET role = 'teacher'
--       WHERE id = (SELECT id FROM auth.users WHERE email = 'docent@exemple.com');
--   * La política "own profile" deixa que cada usuari actualitze la seua fila: el trigger
--     de baix impedix que, des de l'app (anon/authenticated), algú es canvie el rol.

ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_role_check CHECK (role = ANY (ARRAY['admin'::text, 'teacher'::text, 'user'::text]));

-- Qui ja havia creat classes passa a ser docent, perquè no perda l'accés a les seues classes.
UPDATE public.profiles p
SET role = 'teacher'
WHERE p.role = 'user' AND EXISTS (SELECT 1 FROM public.kids_classes c WHERE c.teacher_id = p.id);

CREATE OR REPLACE FUNCTION public.profiles_protect_role()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  -- Només les peticions de l'app (amb JWT d'usuari) estan limitades; la service_role,
  -- el trigger de registre i l'SQL Editor poden assignar el rol.
  IF coalesce(auth.role(), '') NOT IN ('anon', 'authenticated') THEN
    RETURN NEW;
  END IF;
  IF TG_OP = 'INSERT' THEN
    NEW.role := 'user';
  ELSIF NEW.role IS DISTINCT FROM OLD.role THEN
    RAISE EXCEPTION 'No es pot canviar el rol del perfil' USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS profiles_protect_role ON public.profiles;
CREATE TRIGGER profiles_protect_role
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.profiles_protect_role();

-- Crea una classe (només el professorat) amb un codi nou.
CREATE OR REPLACE FUNCTION public.kids_create_class(p_name text)
RETURNS public.kids_classes
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
  alphabet text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  new_code text;
  created kids_classes;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  IF (SELECT role FROM profiles WHERE id = uid) IS DISTINCT FROM 'teacher' THEN
    RAISE EXCEPTION 'Només el professorat pot crear classes' USING ERRCODE = '42501';
  END IF;
  IF char_length(trim(coalesce(p_name, ''))) NOT BETWEEN 1 AND 60 THEN
    RAISE EXCEPTION 'El nom de la classe ha de tindre entre 1 i 60 caràcters' USING ERRCODE = '22023';
  END IF;
  LOOP
    new_code := (SELECT string_agg(substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1), '') FROM generate_series(1, 6));
    BEGIN
      INSERT INTO kids_classes (teacher_id, name, code) VALUES (uid, trim(p_name), new_code) RETURNING * INTO created;
      RETURN created;
    EXCEPTION WHEN unique_violation THEN
      -- Codi repetit: se'n prova un altre.
    END;
  END LOOP;
END;
$$;
