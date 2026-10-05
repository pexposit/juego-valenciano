-- La llengua materna ara es pot editar des del perfil, i la política "own profile" deixa que el client
-- escriga qualsevol text. La restricció la limita al que accepta handle_new_user() en el registre:
-- un codi de dues lletres minúscules (ISO 639-1) o 'other', o null.

ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_mother_tongue_check,
  ADD CONSTRAINT profiles_mother_tongue_check CHECK (mother_tongue IS NULL OR mother_tongue ~ '^([a-z]{2}|other)$');
