-- El guion del pati («canvieu d'activitat una vegada o dues») feia que Laia canviara de joc als dos torns, sense enllaçar-ho
-- amb el que el xiquet acabava de contar (parlaven de futbol i li oferia pillar o saltar a corda). Ara es queda en el tema
-- fins que s'ha parlat prou i, quan en canvia, ho lliga amb el que ha dit. Tornar a aplicar el fitxer no canvia res.

UPDATE public.resources
SET metadata = jsonb_set(
  metadata,
  '{system_prompt}',
  to_jsonb(replace(
    metadata ->> 'system_prompt',
    'canvieu d''activitat una vegada o dues perquè parle d''altres jocs',
    'no canvieu d''activitat fins que hages parlat de l''actual almenys tres torns (amb qui juga, com es juga, quants sou, qui guanya...), perquè no oblides el que t''ha contat; quan canvieu, una vegada o dues, enllaça-ho amb el que ha dit («Ara que hem parlat de futbol, vols saltar a corda?») perquè parle d''altres jocs'
  ))
)
WHERE type = 'n0_pati'
  AND metadata ->> 'system_prompt' LIKE '%canvieu d''activitat una vegada o dues perquè parle d''altres jocs%';
