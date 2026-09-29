-- Aparença de cada secció d'activitats (icona, color i nom visible) guardada a
-- resources.metadata perquè el frontend no la tinga escrita en codi.
-- Es fusiona amb el metadata existent (no esborra character_role, initial_prompt...).
UPDATE resources SET metadata = coalesce(metadata, '{}'::jsonb) || v.visual
FROM (VALUES
  ('mercat',     '{"icon": "🍊", "color": "#FFD98A", "section_name": "El Mercat"}'::jsonb),
  ('bar',        '{"icon": "☕", "color": "#F2B47C", "section_name": "El Bar"}'::jsonb),
  ('oficina',    '{"icon": "💻", "color": "#BDE9E8", "section_name": "L''Oficina"}'::jsonb),
  ('ajuntament', '{"icon": "🏛️", "color": "#C8D7EE", "section_name": "L''Ajuntament"}'::jsonb),
  ('colegi',     '{"icon": "🏫", "color": "#D9C8EE", "section_name": "L''Escola"}'::jsonb),
  ('escola',     '{"icon": "🏫", "color": "#D9C8EE", "section_name": "L''Escola"}'::jsonb),
  ('turisme',    '{"icon": "🗺️", "color": "#9AD0EC", "section_name": "Oficina de Turisme"}'::jsonb)
) AS v(type, visual)
WHERE resources.category = 'escenari' AND resources.type = v.type;
