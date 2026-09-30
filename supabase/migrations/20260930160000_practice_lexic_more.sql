-- Més exercicis A2 per a Formació de paraules i Sinònims, antònims i cortesia
-- (4.3 Lèxic i semàntica; 20260930110000 en tenia 11 per contingut): s'afigen
-- darrere dels que ja hi ha, a partir de la posició `offset`, fins a 35 per
-- contingut. Tornar a aplicar el fitxer no els duplica.

CREATE TEMP TABLE practice_more AS
SELECT * FROM jsonb_to_recordset($data$[
  {
    "id": "2d99f341-c91b-4c70-9d21-75a239956f97", "offset": 11,
    "exercises": [
      {"q": "Qui fa i arregla sabates?", "o": ["el sabater", "el sabatista", "el sabador"], "e": "Sabata + -er: sabater."},
      {"q": "Qui ven fruita?", "o": ["el fruiter", "el fruitista", "el fruitador"], "e": "Fruita + -er: fruiter."},
      {"q": "Qui cuida els jardins?", "o": ["el jardiner", "el jardinista", "el jardinaire"], "e": "Jardí + -er: jardiner."},
      {"q": "Qui toca el piano?", "o": ["el pianista", "el pianer", "el pianador"], "e": "Piano + -ista: pianista."},
      {"q": "Qui cura les dents?", "o": ["el dentista", "el denter", "el dentador"], "e": "Dent + -ista: dentista."},
      {"q": "Qui condueix un taxi?", "o": ["el taxista", "el taxer", "el taxador"], "e": "Taxi + -ista: taxista."},
      {"q": "Quin és el femení de «periodista»?", "o": ["periodista", "periodistessa", "periodistera"], "e": "El sufix -ista és invariable: el periodista, la periodista."},
      {"q": "Qui juga en un equip de futbol?", "o": ["el jugador", "el juguer", "el jugaire"], "e": "Jugar + -dor: jugador."},
      {"q": "Qui treballa en una fàbrica o en una empresa?", "o": ["el treballador", "el treballer", "el treballista"], "e": "Treballar + -dor: treballador."},
      {"q": "Com es diu una persona que canta cançons populars per afició?", "o": ["cantaire", "cantista", "canter"], "e": "Cantar + -aire: cantaire."},
      {"q": "Com es diu una persona que balla danses populars?", "o": ["dansaire", "dansista", "danser"], "e": "Dansar + -aire: dansaire."},
      {"q": "Un home de València és...", "o": ["valencià", "valencier", "valencés"], "e": "València → valencià, valenciana (-à/-ana)."},
      {"q": "Una dona de Menorca és...", "o": ["menorquina", "menorquesa", "menorquenca"], "e": "Menorca → menorquí, menorquina (-í/-ina)."},
      {"q": "Una dona de Castelló és...", "o": ["castellonenca", "castellonina", "castellonesa"], "e": "Castelló → castellonenc, castellonenca (-enc/-enca)."},
      {"q": "Un home de Barcelona és...", "o": ["barceloní", "barcelonés", "barcelonenc"], "e": "Barcelona → barceloní, barcelonina (-í/-ina)."},
      {"q": "Un home d'Alcoi és...", "o": ["alcoià", "alcoiés", "alcoienc"], "e": "Alcoi → alcoià, alcoiana (-à/-ana)."},
      {"q": "Una dona d'Holanda és...", "o": ["holandesa", "holandina", "holandenca"], "e": "Holanda → holandés, holandesa (-és/-esa)."},
      {"q": "On posem el sucre a la taula?", "o": ["al sucrer", "a la sucrista", "al sucraire"], "e": "Sucre + -er: sucrer."},
      {"q": "On posem el pa a la taula?", "o": ["a la panera", "al panista", "al panaire"], "e": "Pa + -era: panera."},
      {"q": "On guardem els ous a la nevera?", "o": ["a l'ouera", "a l'ouista", "a l'ouaire"], "e": "Ou + -era: ouera."},
      {"q": "Amb quin aparell fem el café?", "o": ["amb la cafetera", "amb el cafetista", "amb el cafetaire"], "e": "Café + -era: cafetera."},
      {"q": "L'arbre que fa pomes és...", "o": ["la pomera", "el pomista", "el pomaire"], "e": "Poma + -era: pomera."},
      {"q": "L'arbre que fa figues és...", "o": ["la figuera", "el figuista", "el figaire"], "e": "Figa + -era: figuera."},
      {"q": "Escriu el nom de l'arbre que fa peres.", "a": ["perera", "la perera"], "e": "Pera + -era: perera."}
    ]
  },
  {
    "id": "e1165f90-cd1d-4006-84f3-75bda93d947e", "offset": 11,
    "exercises": [
      {"q": "Quin és un sinònim de «començar»?", "o": ["iniciar", "acabar", "parar"], "e": "Començar i iniciar volen dir el mateix."},
      {"q": "Quin és un sinònim de «feliç»?", "o": ["content", "trist", "cansat"], "e": "Feliç i content."},
      {"q": "Quin és un sinònim de «ràpid»?", "o": ["veloç", "lent", "tranquil"], "e": "Ràpid i veloç."},
      {"q": "Quin és un sinònim de «casa»?", "o": ["vivenda", "carrer", "poble"], "e": "Casa i vivenda."},
      {"q": "Quin és un sinònim de «alumne»?", "o": ["estudiant", "mestre", "director"], "e": "Alumne i estudiant."},
      {"q": "Quin és un sinònim de «roig»?", "o": ["vermell", "blau", "morat"], "e": "Roig i vermell són el mateix color."},
      {"q": "Quin és el contrari de «entrar»?", "o": ["eixir", "pujar", "obrir"], "e": "Entrar ↔ eixir."},
      {"q": "Quin és el contrari de «pujar»?", "o": ["baixar", "eixir", "entrar"], "e": "Pujar ↔ baixar."},
      {"q": "Quin és el contrari de «comprar»?", "o": ["vendre", "pagar", "gastar"], "e": "Comprar ↔ vendre."},
      {"q": "Quin és el contrari de «encendre» la llum?", "o": ["apagar", "tancar", "obrir"], "e": "Encendre ↔ apagar."},
      {"q": "Quin és el contrari de «guanyar»?", "o": ["perdre", "jugar", "trobar"], "e": "Guanyar ↔ perdre."},
      {"q": "Quin és el contrari de «recordar»?", "o": ["oblidar", "pensar", "saber"], "e": "Recordar ↔ oblidar."},
      {"q": "Gos, gat i conill són...", "o": ["animals", "plantes", "fruites"], "e": "Animal és la paraula general (hiperònim)."},
      {"q": "Taula, cadira i armari són...", "o": ["mobles", "electrodomèstics", "eines"], "e": "Moble és la paraula general."},
      {"q": "Futbol, tenis i natació són...", "o": ["esports", "jocs de taula", "instruments"], "e": "Esport és la paraula general."},
      {"q": "Quina paraula inclou les altres dues?", "o": ["roba", "camisa", "pantalons"], "e": "La camisa i els pantalons són roba: roba és l'hiperònim."},
      {"q": "Com demanes una cosa amb educació?", "o": ["Em dones un got d'aigua, per favor?", "Dona'm aigua ja!", "Aigua!"], "e": "Per favor fa la petició més cortés."},
      {"q": "Com saludes a les cinc de la vesprada?", "o": ["Bona vesprada!", "Bon dia!", "Bon profit!"], "e": "Bon dia pel matí, bona vesprada per la vesprada i bona nit per la nit."},
      {"q": "Què respons quan algú et diu «Moltes gràcies»?", "o": ["De res.", "Perdó.", "Salut!"], "e": "De res (o No es mereixen)."},
      {"q": "Què dius a algú que ha aprovat un examen?", "o": ["Enhorabona!", "Perdona!", "Bon profit!"], "e": "Enhorabona: per a felicitar."},
      {"q": "Què dius a algú que se'n va de viatge?", "o": ["Bon viatge!", "Enhorabona!", "Per molts anys!"], "e": "Bon viatge!"},
      {"q": "Què dius quan coneixes una persona per primera vegada?", "o": ["Encantat de conéixer-te.", "Bon profit.", "Fins demà."], "e": "Encantat (o Molt de gust)."},
      {"q": "Com preguntes a un senyor gran que no coneixes com està?", "o": ["Com està vosté?", "Què passa, tio?", "Com va, xiquet?"], "e": "Amb persones que no coneixem o grans, el tractament de respecte: vosté."},
      {"q": "Què respons quan algú et pregunta «Com estàs?»", "o": ["Molt bé, gràcies. I tu?", "De res.", "Bon profit."], "e": "Molt bé, gràcies. I tu?"}
    ]
  }
]$data$::jsonb) AS t(id uuid, "offset" smallint, exercises jsonb);

DELETE FROM public.practice_exercises e
USING practice_more m
WHERE e.resource_id = m.id AND e.level = 'A2' AND e.position > m."offset";

INSERT INTO public.practice_exercises (resource_id, level, position, kind, prompt, options, answers, explanation)
SELECT m.id, 'A2', m."offset" + x.ord,
       CASE WHEN x.e ? 'a' THEN 'fill' ELSE 'choice' END,
       x.e->>'q',
       CASE WHEN x.e ? 'o' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'o')) END,
       CASE WHEN x.e ? 'a' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'a')) ELSE ARRAY[x.e->'o'->>0] END,
       x.e->>'e'
FROM practice_more m
CROSS JOIN LATERAL jsonb_array_elements(m.exercises) WITH ORDINALITY AS x(e, ord);

DROP TABLE practice_more;
