-- Buida la categoria "gramatica" del catàleg d'activitats (taula resources).
-- Les files de session_resource (i per cascada els missatges, errors i
-- avaluacions d'eixes sessions) desapareixen amb els recursos.
DELETE FROM public.resources WHERE category = 'gramatica';
