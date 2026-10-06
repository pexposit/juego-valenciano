-- Valor 'nivell0' per a resources.difficulty, perquè hi haja activitats del Nivell 0
-- (xiquets), igual que profiles.level. Va en una migració pròpia: un valor nou d'un
-- enum no es pot usar en la mateixa transacció que l'afegix. Tornar-la a aplicar no
-- canvia res.

ALTER TYPE public.difficulties ADD VALUE IF NOT EXISTS 'nivell0' BEFORE 'principiant';
