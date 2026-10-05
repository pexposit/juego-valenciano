-- Preferència dels comptes infantils: mostrar o no l'ajuda en la llengua materna (les línies en gris)
-- en els missatges del tutor. Només afecta la visualització: el tutor continua generant-la i es
-- guarda amb els missatges, així que es pot tornar a activar i veure-la també en les converses anteriors.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS show_mother_tongue boolean NOT NULL DEFAULT true;
