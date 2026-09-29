-- 1. Vaciar la tabla existente
TRUNCATE TABLE resources RESTART IDENTITY CASCADE;

-- 2. Insertar los 6 recursos de escenarios
INSERT INTO resources (name, type, category, difficulty, xp_earned, content, metadata)
VALUES
  (
    'Comprar fruita al mercat central',
    'mercat',
    'escenari',
    'principiant',
    15,
    'Practica com demanar fruita, preguntar el preu i pagar en una parada de mercat.',
    '{
      "scenario": "mercat",
      "character_role": "Venedor del mercat",
      "initial_prompt": "Bon dia! Què et pose hui? Tenim unes taronges boníssimes."
    }'::jsonb
  ),
  (
    'Primer dia a l''oficina',
    'oficina',
    'escenari',
    'principiant',
    15,
    'Presenta''t als teus companys, demana indicacions sobre el lloc de treball i les tasques bàsiques.',
    '{
      "scenario": "oficina",
      "character_role": "Company de feina",
      "initial_prompt": "Hola! Benvingut a l''equip. Jo sóc en Marc. Si necessites qualsevol cosa amb l''ordinador o els accessos, dis-me''l."
    }'::jsonb
  ),
  (
    'Demanar un café i esmorzar al bar',
    'bar',
    'escenari',
    'intermedi',
    25,
    'Aprèn a demanar begudes, esmorzars típics, demanar el compte i pagar.',
    '{
      "scenario": "bar",
      "character_role": "Cambrer",
      "initial_prompt": "Hola! Què prens per a esmorzar? Un tallat, un café amb llet o potser un entrepà?"
    }'::jsonb
  ),
  (
    'Tràmits i empadronament a l''ajuntament',
    'ajuntament',
    'escenari',
    'intermedi',
    25,
    'Sol·licita el certificat d''empadronament, demana informació sobre documentació i taxes.',
    '{
      "scenario": "ajuntament",
      "character_role": "Funcionari d''atenció ciutadana",
      "initial_prompt": "Bona vesprada. Com el puc ajudar? Ha demanat cita prèvia per al tràmit d''empadronament?"
    }'::jsonb
  ),
  (
    'Reunió de tutoria a l''escola',
    'colegi',
    'escenari',
    'avancat',
    40,
    'Comenta el progrés acadèmic, resol dubtes sobre metodologies i planteja objectius del curs.',
    '{
      "scenario": "escola",
      "character_role": "Tutor escolar",
      "initial_prompt": "Molt bon dia. Gràcies per vindre a la tutoria. Volia comentar com ha començat el curs i els objectius que tenim plantejats."
    }'::jsonb
  ),
  (
    'Demanar informació a l''oficina de turisme',
    'turisme',
    'escenari',
    'intermedi',
    25,
    'Pregunta per monuments d''interés, rutes a peu, recomanacions locals i horaris de museus.',
    '{
      "scenario": "turisme",
      "character_role": "Guia de l''oficina de turisme",
      "initial_prompt": "Hola, bon dia! Benvingut a la ciutat. Busques informació sobre llocs d''interés, o t''agradaria alguna recomanació per a visitar hui?"
    }'::jsonb
  );