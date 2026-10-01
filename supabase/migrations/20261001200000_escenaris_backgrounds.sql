-- Foto de fons (resources.metadata.background) per als escenaris que encara
-- no en tenien: les noves imatges a frontend/public/images/, triades segons
-- la situació de cada escenari. 'taller' es queda sense foto: no hi ha cap
-- imatge de taller mecànic entre les noves. Tornar a aplicar el fitxer no
-- duplica res (és un UPDATE idempotent).

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/house_party.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'a2_identificacio'; -- festa d'aniversari de Núria

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/flat.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'a2_casa'; -- el pis nou de Xavi

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/gym.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'a2_activitats'; -- Toni, amic del gimnàs

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/street.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'a2_faena'; -- et trobes Sílvia pel carrer

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/restaurant.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'a2_menjar'; -- reserva al restaurant L'Albufera

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/mall.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'a2_servicis'; -- grans magatzems

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/ireland.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'a2_clima'; -- Liam, amic irlandés

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/hotel.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'a2_viatges'; -- reserva a l'Hotel Mar Blau

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/pharmacy.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'farmacia';

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/forn.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'forn';
