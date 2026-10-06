-- Foto de fons (resources.metadata.background) del taller i dels escenaris del B1
-- (les imatges són a frontend/public/images/). Tornar a aplicar el fitxer no duplica res
-- (és un UPDATE idempotent).

UPDATE public.resources AS r
SET metadata = jsonb_set(r.metadata, '{background}', to_jsonb(v.background), true)
FROM (VALUES
  ('taller',             '/images/car_workshop.jpg'),
  ('b1_persones',        '/images/cooking_workshop.jpg'),
  ('b1_relacions',       '/images/street.jpg'),
  ('b1_vida_quotidiana', '/images/townhall.jpg'),
  ('b1_llocs',           '/images/real_state.jpg'),
  ('b1_viatges',         '/images/travel_agency.jpg'),
  ('b1_oci_esport',      '/images/gym.jpg'),
  ('b1_administracio',   '/images/townhall.jpg'),
  ('b1_treball',         '/images/hotel.jpg'),
  ('b1_salut',           '/images/flat.jpg'),
  ('b1_territori',       '/images/classroom.jpg'),
  ('b1_cultura',         '/images/radio_station.jpg'),
  ('b1_natura_clima',    '/images/Montgó.jpg')
) AS v(type, background)
WHERE r.category = 'escenari' AND r.type = v.type;
