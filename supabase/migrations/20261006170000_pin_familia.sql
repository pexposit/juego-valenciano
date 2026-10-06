-- PIN de la família del Nivell 0: quatre xifres que tria la persona adulta en crear el
-- compte infantil i que protegixen el seguiment (que el xiquet no hi entre). Es guarda
-- només el hash (bcrypt) en una taula a banda, amb RLS i sense polítiques: ningú la pot
-- llegir (tampoc la docent, que sí que llig profiles); només s'hi accedix amb les funcions
-- de baix. Cinc errors seguits bloquegen cinc minuts. Si s'oblida, es canvia amb la
-- contrasenya del compte.

CREATE TABLE IF NOT EXISTS public.kids_parent_pins (
  user_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  pin_hash text NOT NULL,
  fails smallint NOT NULL DEFAULT 0,
  locked_until timestamptz,
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.kids_parent_pins ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.kids_parent_pins FROM anon, authenticated;

-- Té PIN el compte que ha iniciat sessió?
CREATE OR REPLACE FUNCTION public.kids_has_pin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (SELECT 1 FROM kids_parent_pins WHERE user_id = auth.uid());
$$;

-- El primer PIN (en crear el compte o la primera vegada que s'entra al seguiment).
-- Si ja n'hi ha un, no el canvia: per a això cal kids_reset_pin amb la contrasenya.
CREATE OR REPLACE FUNCTION public.kids_set_pin(p_pin text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  IF coalesce(p_pin, '') !~ '^[0-9]{4}$' THEN
    RAISE EXCEPTION 'El PIN ha de tindre 4 xifres' USING ERRCODE = '22023';
  END IF;
  INSERT INTO kids_parent_pins (user_id, pin_hash) VALUES (auth.uid(), crypt(p_pin, gen_salt('bf')))
  ON CONFLICT (user_id) DO NOTHING;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Este compte ja té PIN' USING ERRCODE = '23505';
  END IF;
END;
$$;

-- Comprova el PIN. Torna {ok, locked_seconds, attempts_left}. No llança errors en fallar,
-- perquè el comptador d'intents s'ha de guardar.
CREATE OR REPLACE FUNCTION public.kids_check_pin(p_pin text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  saved kids_parent_pins;
BEGIN
  SELECT * INTO saved FROM kids_parent_pins WHERE user_id = auth.uid() FOR UPDATE;
  IF saved.user_id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'locked_seconds', 0, 'attempts_left', 0, 'missing', true);
  END IF;
  IF saved.locked_until > now() THEN
    RETURN jsonb_build_object('ok', false, 'locked_seconds', ceil(extract(epoch FROM saved.locked_until - now())), 'attempts_left', 0);
  END IF;
  IF crypt(coalesce(p_pin, ''), saved.pin_hash) = saved.pin_hash THEN
    UPDATE kids_parent_pins SET fails = 0, locked_until = NULL WHERE user_id = saved.user_id;
    RETURN jsonb_build_object('ok', true, 'locked_seconds', 0, 'attempts_left', 5);
  END IF;
  IF saved.fails + 1 >= 5 THEN
    UPDATE kids_parent_pins SET fails = 0, locked_until = now() + interval '5 minutes' WHERE user_id = saved.user_id;
    RETURN jsonb_build_object('ok', false, 'locked_seconds', 300, 'attempts_left', 0);
  END IF;
  UPDATE kids_parent_pins SET fails = saved.fails + 1 WHERE user_id = saved.user_id;
  RETURN jsonb_build_object('ok', false, 'locked_seconds', 0, 'attempts_left', 5 - (saved.fails + 1));
END;
$$;

-- PIN oblidat: un PIN nou amb la contrasenya del compte (compta per als intents i el bloqueig).
CREATE OR REPLACE FUNCTION public.kids_reset_pin(p_password text, p_pin text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  uid uuid := auth.uid();
  saved kids_parent_pins;
  stored text;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  IF coalesce(p_pin, '') !~ '^[0-9]{4}$' THEN
    RAISE EXCEPTION 'El PIN ha de tindre 4 xifres' USING ERRCODE = '22023';
  END IF;
  SELECT * INTO saved FROM kids_parent_pins WHERE user_id = uid FOR UPDATE;
  IF saved.locked_until > now() THEN
    RETURN jsonb_build_object('ok', false, 'locked_seconds', ceil(extract(epoch FROM saved.locked_until - now())));
  END IF;
  SELECT encrypted_password INTO stored FROM auth.users WHERE id = uid;
  IF stored IS NULL OR crypt(coalesce(p_password, ''), stored) <> stored THEN
    IF saved.user_id IS NOT NULL THEN
      UPDATE kids_parent_pins
      SET fails = CASE WHEN saved.fails + 1 >= 5 THEN 0 ELSE saved.fails + 1 END,
          locked_until = CASE WHEN saved.fails + 1 >= 5 THEN now() + interval '5 minutes' END
      WHERE user_id = uid;
    END IF;
    RETURN jsonb_build_object('ok', false, 'locked_seconds', 0);
  END IF;
  INSERT INTO kids_parent_pins (user_id, pin_hash) VALUES (uid, crypt(p_pin, gen_salt('bf')))
  ON CONFLICT (user_id) DO UPDATE SET pin_hash = excluded.pin_hash, fails = 0, locked_until = NULL, updated_at = now();
  RETURN jsonb_build_object('ok', true, 'locked_seconds', 0);
END;
$$;

REVOKE ALL ON FUNCTION public.kids_has_pin() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.kids_set_pin(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.kids_check_pin(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.kids_reset_pin(text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.kids_has_pin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.kids_set_pin(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.kids_check_pin(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.kids_reset_pin(text, text) TO authenticated;
