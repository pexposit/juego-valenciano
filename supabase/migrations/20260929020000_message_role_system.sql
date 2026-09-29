-- El rol del personatge es desa com "system" (conveni user/system dels LLM),
-- no "character". La taula encara no té files, per tant és un simple canvi
-- d'etiqueta de l'enum.
ALTER TYPE "public"."message_role" RENAME VALUE 'character' TO 'system';
