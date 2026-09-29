-- "resources" té RLS activat però cap política: ningú (ni autenticat) pot
-- llegir-lo. És catàleg compartit (no dades d'usuari), per tant lectura oberta.
CREATE POLICY "Allow read resources" ON "public"."resources"
  FOR SELECT
  USING (true);
