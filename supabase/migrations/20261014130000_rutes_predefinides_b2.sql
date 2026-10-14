-- Rutes d'aprenentatge predefinides del B2, amb la mateixa estructura que les de l'A2 i el B1
-- (20261007225000): una primera volta, la gramàtica, l'ortografia, el vocabulari en context,
-- la precisió lèxica, la comprensió, la conversa i la preparació de l'examen. En el B2 conviuen
-- amb la ruta personalitzada de la IA (learning_paths).
-- Ids fixos perquè la migració es puga tornar a aplicar. Les activitats es busquen pel `type`
-- dins del nivell: si una migració del catàleg esborra i torna a crear un recurs, el seu pas
-- desapareix (ON DELETE CASCADE) i caldrà tornar a aplicar este fitxer.

CREATE OR REPLACE FUNCTION pg_temp.seed_path(p_id uuid, p_level text, p_order int, p_title text, p_description text, p_types text[])
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.study_paths (id, level, title, description, sort_order)
  VALUES (p_id, p_level, p_title, p_description, p_order)
  ON CONFLICT (id) DO UPDATE SET level = excluded.level, title = excluded.title, description = excluded.description,
    sort_order = excluded.sort_order, updated_at = now();
  DELETE FROM public.study_path_steps WHERE path_id = p_id;
  INSERT INTO public.study_path_steps (path_id, position, resource_id)
  SELECT p_id, row_number() OVER (ORDER BY t.n), r.id
  FROM unnest(p_types) WITH ORDINALITY AS t(type, n)
  JOIN public.resources r ON r.type = t.type AND r.difficulty::text = p_level AND r.teacher_id IS NULL;
END;
$$;

SELECT pg_temp.seed_path('b2000000-0000-4000-8000-000000000001', 'B2', 1,
  'Primeres passes en el B2',
  'Una volta per tot el que treballaràs: gramàtica, vocabulari, una conversa i les primeres comprensions i expressions.',
  ARRAY['b2_mor_determinants', 'b2_lex_descripcio', 'b2_gent', 'b2_fon_accentuacio', 'b2_ce_premsa', 'b2_ee_correus', 'b2_eo_experiencies']);

SELECT pg_temp.seed_path('b2000000-0000-4000-8000-000000000002', 'B2', 2,
  'Gramàtica del B2',
  'Tota la morfosintaxi del B2: pronoms febles i les seues combinacions, relatius, preposicions, connectors, subjuntiu i perífrasis.',
  ARRAY['b2_mor_substantius', 'b2_mor_adjectius', 'b2_mor_determinants', 'b2_mor_pronoms_forts', 'b2_mor_pronoms_febles', 'b2_mor_combinacions', 'b2_mor_interrogatius', 'b2_mor_relatius', 'b2_mor_numerals', 'b2_mor_quantitatius', 'b2_mor_preposicions', 'b2_mor_adverbis', 'b2_mor_connectors', 'b2_mor_verbs_irregulars', 'b2_mor_subjuntiu', 'b2_mor_ser_estar', 'b2_mor_perifrasis', 'b2_mor_infinitiu']);

SELECT pg_temp.seed_path('b2000000-0000-4000-8000-000000000003', 'B2', 3,
  'Ortografia i pronunciació del B2',
  'De l''elocució als diacrítics, la dièresi i el guionet, les consonants que més costen i la puntuació.',
  ARRAY['b2_fon_elocucio', 'b2_fon_alfabet', 'b2_fon_sillaba', 'b2_fon_vocals', 'b2_fon_accentuacio', 'b2_fon_dieresi_guionet', 'b2_fon_oclusives', 'b2_fon_alveolars_s', 'b2_fon_alveolars_x', 'b2_fon_palatals', 'b2_fon_laterals_h', 'b2_fon_majuscules', 'b2_fon_puntuacio']);

SELECT pg_temp.seed_path('b2000000-0000-4000-8000-000000000004', 'B2', 4,
  'Vocabulari en context',
  'Cada tema, primer el vocabulari i després una conversa per a fer-lo servir: treball, tràmits, salut, ciència, cultura popular i persones.',
  ARRAY['b2_lex_docent_professional', 'b2_estudis_treball', 'b2_lex_documents_formals', 'b2_politica_societat', 'b2_lex_menjar_salut_esport', 'b2_menjar_salut', 'b2_lex_tecnologia_ciencies', 'b2_actualitat', 'b2_lex_contes_rondalles', 'b2_cultura_llengua', 'b2_lex_descripcio', 'b2_gent']);

SELECT pg_temp.seed_path('b2000000-0000-4000-8000-000000000005', 'B2', 5,
  'Precisió i riquesa lèxica',
  'Com es formen les paraules, locucions i frases fetes, barbarismes, sentit figurat i relacions entre paraules.',
  ARRAY['b2_lex_derivacio', 'b2_lex_composicio', 'b2_lex_locucions', 'b2_lex_polisemia', 'b2_lex_barbarismes', 'b2_lex_metafora', 'b2_lex_sinonims_antonims', 'b2_lex_relacions_textuals', 'b2_lex_llengues_gentilicis']);

SELECT pg_temp.seed_path('b2000000-0000-4000-8000-000000000006', 'B2', 6,
  'Comprensió oral i escrita',
  'Escoltar i llegir, alternant: converses, gestions, mitjans, ficció, debats i conferències, amb premsa, assajos i literatura.',
  ARRAY['b2_co_converses', 'b2_ce_premsa', 'b2_co_gestions', 'b2_ce_administracio', 'b2_co_mitjans', 'b2_ce_especialitzats', 'b2_co_ficcio', 'b2_ce_literaris', 'b2_co_debat', 'b2_ce_argumentatius', 'b2_co_conferencia', 'b2_ce_humor']);

SELECT pg_temp.seed_path('b2000000-0000-4000-8000-000000000007', 'B2', 7,
  'Conversa i expressió oral',
  'Parlar en situacions reals i d''exigència creixent: viatges, cultura, mitjans, debats, actes públics i entrevistes.',
  ARRAY['b2_viatges', 'b2_eo_experiencies', 'b2_cultura_espectacles', 'b2_eo_reunio', 'b2_mitjans', 'b2_eo_debat', 'b2_politica_societat', 'b2_eo_exposicio', 'b2_estudis_treball', 'b2_eo_entrevista']);

SELECT pg_temp.seed_path('b2000000-0000-4000-8000-000000000008', 'B2', 8,
  'Preparar l''examen B2',
  'Connectors, subjuntiu i barbarismes, les tasques d''expressió escrita de l''examen i els simulacres de la JQCV.',
  ARRAY['b2_mor_connectors', 'b2_mor_subjuntiu', 'b2_lex_barbarismes', 'b2_ee_opinio', 'b2_ee_ressenya', 'b2_ee_informe', 'b2_ee_resum', 'b2_ee_apunts', 'jqcv_b2_oct2025', 'jqcv_b2_oct2024', 'jqcv_b2_oct2023', 'jqcv_b2_oct2022']);
