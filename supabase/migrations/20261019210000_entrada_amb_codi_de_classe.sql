-- Tercera forma d'entrar: amb el codi d'una classe, sense compte (ni correu ni contrasenya).
--   * L'alumne escriu el codi i tria un apodo (i el nivell, si la classe en té dos). L'app crea una sessió
--     anònima de Supabase (auth.signInAnonymously) amb el nivell, el grup d'edat i l'apodo com a metadades:
--     handle_new_user() ja en fa el perfil (display_name = l'apodo). El navegador guarda la sessió.
--   * El servidor només guarda l'apodo i el seguiment (resultats, objectius dels escenaris...): és el que la
--     docent veu a la seua taula. El que escriu o diu l'alumne es queda en el seu navegador.
--   * class_code_preview(): amb el codi diu a quina classe va (nom i nivells) i si l'apodo ja és en ús en
--     eixa classe. Es pot cridar sense sessió, perquè l'alumne ho veja abans de crear res.
--   * kids_join_class(): igual que abans, però si qui crida és una sessió anònima també comprova l'apodo
--     (format, i que no el tinga ningú més de la classe).
-- Cal activar els inicis de sessió anònims: `enable_anonymous_sign_ins = true` en supabase/config.toml
-- (en local) i en Authentication → Providers → Anonymous Sign-Ins (en Supabase Cloud).

-- Format de l'apodo: 2 a 20 caràcters (lletres, xifres, punt, guionet i guionet baix), sense espais.
CREATE OR REPLACE FUNCTION public.valid_nick(p text)
RETURNS boolean
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT coalesce(p ~ '^[A-Za-zÀ-ÖØ-öø-ÿ0-9._-]{2,20}$', false);
$$;

-- Si l'apodo ja el té un altre alumne de la classe (sense distinguir majúscules i minúscules).
CREATE OR REPLACE FUNCTION public.nick_taken_in_class(p_class uuid, p_nick text, p_except uuid DEFAULT NULL)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM kids_class_members m
    JOIN profiles p ON p.id = m.student_id
    WHERE m.class_id = p_class
      AND lower(p.display_name) = lower(trim(coalesce(p_nick, '')))
      AND (p_except IS NULL OR m.student_id <> p_except)
  );
$$;
REVOKE ALL ON FUNCTION public.nick_taken_in_class(uuid, text, uuid) FROM PUBLIC;

-- Quina classe és, per al codi (nom, nivells i si l'apodo ja és en ús). Sense sessió: només torna això.
CREATE OR REPLACE FUNCTION public.class_code_preview(p_code text, p_nick text DEFAULT NULL)
RETURNS TABLE (name text, levels text[], nick_taken boolean)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  found kids_classes;
BEGIN
  SELECT * INTO found FROM kids_classes c WHERE c.code = upper(trim(coalesce(p_code, '')));
  IF found.id IS NULL THEN
    RAISE EXCEPTION 'No hi ha cap classe amb este codi' USING ERRCODE = 'P0002';
  END IF;
  RETURN QUERY SELECT found.name, found.levels,
    (p_nick IS NOT NULL AND public.nick_taken_in_class(found.id, p_nick));
END;
$$;
REVOKE ALL ON FUNCTION public.class_code_preview(text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.class_code_preview(text, text) TO anon, authenticated;

-- Unir-se a una classe amb el codi. Una sessió anònima (entrada amb el codi) també ha de tindre un apodo
-- vàlid i que no tinga ningú més de la classe.
CREATE OR REPLACE FUNCTION public.kids_join_class(p_code text)
RETURNS TABLE (id uuid, name text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
  found kids_classes;
  student_level text;
  student_nick text;
  anonymous boolean := coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false);
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO found FROM kids_classes c WHERE c.code = upper(trim(coalesce(p_code, '')));
  IF found.id IS NULL THEN
    RAISE EXCEPTION 'No hi ha cap classe amb este codi' USING ERRCODE = 'P0002';
  END IF;
  SELECT level::text, display_name INTO student_level, student_nick FROM profiles WHERE profiles.id = uid;
  IF NOT (cefr_of(student_level) && found.levels) THEN
    RAISE EXCEPTION 'Esta classe és per a alumnat de %, i el teu nivell és %',
      (SELECT string_agg(level_label(l), ' i ') FROM unnest(found.levels) l), level_label(student_level)
      USING ERRCODE = '42501';
  END IF;
  IF anonymous THEN
    IF NOT valid_nick(student_nick) THEN
      RAISE EXCEPTION 'L''apodo ha de tindre entre 2 i 20 caràcters: lletres, xifres, punt, guionet o guionet baix' USING ERRCODE = '22023';
    END IF;
    IF nick_taken_in_class(found.id, student_nick, uid) THEN
      RAISE EXCEPTION 'Este apodo ja el té algú de la classe: tria''n un altre' USING ERRCODE = '23505';
    END IF;
  END IF;
  INSERT INTO kids_class_members (class_id, student_id) VALUES (found.id, uid) ON CONFLICT DO NOTHING;
  RETURN QUERY SELECT found.id, found.name;
END;
$$;
