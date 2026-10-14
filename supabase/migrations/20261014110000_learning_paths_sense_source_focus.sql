-- La ruta personalitzada ja només es genera quan l'usuari ho demana: ja no cal recordar el
-- priority_focus amb què es va generar (servia per a regenerar-la sola quan canviava).

ALTER TABLE public.learning_paths DROP COLUMN IF EXISTS source_focus;
