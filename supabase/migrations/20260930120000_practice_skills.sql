-- Àrees de destreses del Quadern A2 de la JQCV (objectius per àrees):
-- Comprensió oral, Comprensió escrita, Expressió escrita i Expressió oral, al
-- costat de les àrees de continguts lingüístics (20260930110000).
--   * Comprensió oral i escrita: textos o àudios (practice_passages) amb preguntes.
--     Els àudios són fitxers estàtics (`audio_url`) generats amb el TTS a partir de
--     la transcripció, torn a torn i amb la veu de cada personatge: després
--     d'afegir-ne o de canviar-ne, cal executar backend/scripts/generate-practice-audio.ts.
--   * Expressió escrita: redaccions (`writing`) i formularis (`form`) que avalua
--     el LLM amb la rúbrica de la JQCV; la consigna va a `task`.
--   * Expressió oral: xats amb un personatge, com els escenaris (metadata amb
--     character, system_prompt, objectius, voice...), sense practice_exercises.

CREATE TABLE IF NOT EXISTS public.practice_passages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_id uuid NOT NULL REFERENCES public.resources(id) ON UPDATE CASCADE ON DELETE CASCADE,
  level text NOT NULL CHECK (level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  position smallint NOT NULL,
  -- text: es llig en pantalla; audio: s'escolta i la transcripció es mostra en corregir.
  media text NOT NULL CHECK (media IN ('text', 'audio')),
  title text,
  -- [{text, speaker?, voice?}]: paràgrafs d'un text o torns d'un diàleg.
  lines jsonb NOT NULL CHECK (jsonb_typeof(lines) = 'array' AND jsonb_array_length(lines) > 0),
  CONSTRAINT practice_passages_position_key UNIQUE (resource_id, level, position)
);

-- Àudio estàtic de frontend/public (/audio/practice/<type>-<nivell>-<posició>.wav).
ALTER TABLE public.practice_passages ADD COLUMN IF NOT EXISTS audio_url text;

ALTER TABLE public.practice_passages ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.practice_exercises
  ADD COLUMN IF NOT EXISTS passage_id uuid REFERENCES public.practice_passages(id) ON DELETE CASCADE,
  -- writing: {min_words, max_words, words?, min_words_used?}; form: {fields}.
  ADD COLUMN IF NOT EXISTS task jsonb;

CREATE INDEX IF NOT EXISTS idx_practice_exercises_passage ON public.practice_exercises (passage_id);

ALTER TABLE public.practice_exercises ALTER COLUMN answers DROP NOT NULL;
ALTER TABLE public.practice_exercises DROP CONSTRAINT IF EXISTS practice_exercises_kind_check;
ALTER TABLE public.practice_exercises DROP CONSTRAINT IF EXISTS practice_exercises_answers_check;
ALTER TABLE public.practice_exercises DROP CONSTRAINT IF EXISTS practice_exercises_task_check;
ALTER TABLE public.practice_exercises
  ADD CONSTRAINT practice_exercises_kind_check CHECK (kind IN ('choice', 'fill', 'writing', 'form')),
  -- Les preguntes tancades porten solució; les redaccions i els formularis, la consigna.
  ADD CONSTRAINT practice_exercises_answers_check CHECK (kind NOT IN ('choice', 'fill') OR cardinality(answers) > 0),
  ADD CONSTRAINT practice_exercises_task_check CHECK (
    (kind <> 'writing' OR (task ? 'min_words' AND task ? 'max_words'))
    AND (kind <> 'form' OR jsonb_typeof(task->'fields') = 'array')
  );

-- Catàleg. Cada recurs porta `exercises` o bé `blocks` ({passage, exercises}).
-- Exercicis: {q, o (la primera, correcta), e} | {q, a (respostes acceptades), e}
-- | {q, w: task d'una redacció} | {q, f: camps d'un formulari}.
-- `metadata` s'afig a {icon, color, section_name} (p. ex. el personatge d'un xat).
DO $do$
DECLARE
  catalog jsonb := $data$[
  {
    "id": "296c0bc1-40b2-4663-9a3c-c1f30eb8e635", "category": "comprensio_oral", "type": "co_personal", "sort_order": 1,
    "title": "Informació personal", "name": "Presentacions i dades personals",
    "content": "Entén converses lentes i clares sobre família, residència i ocupació.", "icon": "👋", "color": "#B2EBF2",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "Nous veïns", "lines": [
          {"speaker": "Laura", "voice": "gina", "text": "Hola, bon dia! Tu deus ser el nou veí del tercer, no?"},
          {"speaker": "Pau", "voice": "lluc", "text": "Sí, bon dia! Em dic Pau. Vaig arribar dilluns passat. I tu?"},
          {"speaker": "Laura", "voice": "gina", "text": "Jo soc Laura i visc ací davant, al tercer B. D'on eres?"},
          {"speaker": "Pau", "voice": "lluc", "text": "Soc de Morella, però ara treballe a València, en una llibreria del centre."},
          {"speaker": "Laura", "voice": "gina", "text": "Ah, que bé! Jo soc infermera a l'hospital. I vius a soles?"},
          {"speaker": "Pau", "voice": "lluc", "text": "No, visc amb la meua germana, Carme. Ella estudia Medicina a la universitat."},
          {"speaker": "Laura", "voice": "gina", "text": "Doncs si necessiteu alguna cosa, ja sabeu on estic. Benvinguts!"},
          {"speaker": "Pau", "voice": "lluc", "text": "Moltes gràcies, Laura. Fins després!"}
        ]},
        "exercises": [
          {"q": "De quin poble és Pau?", "o": ["De Morella", "De València", "De Castelló"], "e": "«Soc de Morella, però ara treballe a València.»"},
          {"q": "On treballa Pau?", "o": ["En una llibreria", "En un hospital", "En la universitat"], "e": "«Treballe a València, en una llibreria del centre.»"},
          {"q": "Quina és la professió de Laura?", "o": ["Infermera", "Llibretera", "Estudiant"], "e": "«Jo soc infermera a l'hospital.»"},
          {"q": "Amb qui viu Pau?", "o": ["Amb la seua germana", "A soles", "Amb els seus pares"], "e": "«Visc amb la meua germana, Carme.»"},
          {"q": "Quan va arribar Pau al pis?", "o": ["Dilluns passat", "Fa un mes", "Ahir"], "e": "«Vaig arribar dilluns passat.»"}
        ]
      }
    ]
  },
  {
    "id": "4c658569-e553-4eab-858b-dd44b95d92a4", "category": "comprensio_oral", "type": "co_instruccions", "sort_order": 2,
    "title": "Instruccions", "name": "Indicacions a classe i en una oficina",
    "content": "Seguix instruccions de primera necessitat de l'àmbit acadèmic i institucional.", "icon": "📋", "color": "#FFE0B2",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "El primer dia de classe", "lines": [
          {"speaker": "Professor", "voice": "lluc", "text": "Bon dia a tots i a totes. Abans de començar, escolteu bé. Primer, obriu el llibre per la pàgina dotze. Després, feu l'exercici tres a soles, sense mirar el diccionari. Teniu quinze minuts."},
          {"speaker": "Professor", "voice": "lluc", "text": "Quan acabeu, compareu les respostes amb el company del costat. Els deures per a dijous són els exercicis cinc i sis. I recordeu: divendres no hi ha classe perquè és festa."}
        ]},
        "exercises": [
          {"q": "Per quina pàgina cal obrir el llibre?", "o": ["Per la dotze", "Per la tres", "Per la quinze"], "e": "«Obriu el llibre per la pàgina dotze.»"},
          {"q": "Com cal fer l'exercici tres?", "o": ["A soles i sense diccionari", "En parella", "Amb el diccionari"], "e": "«Feu l'exercici tres a soles, sense mirar el diccionari.»"},
          {"q": "Què cal fer en acabar l'exercici?", "o": ["Comparar les respostes amb un company", "Donar-lo al professor", "Fer l'exercici cinc"], "e": "«Compareu les respostes amb el company del costat.»"},
          {"q": "Per què no hi ha classe divendres?", "o": ["Perquè és festa", "Perquè el professor està malalt", "Perquè hi ha examen"], "e": "«Divendres no hi ha classe perquè és festa.»"}
        ]
      },
      {
        "passage": {"media": "audio", "title": "A l'oficina de l'ajuntament", "lines": [
          {"speaker": "Funcionària", "voice": "gina", "text": "Per a demanar el certificat d'empadronament, agafeu un número en la màquina de l'entrada i espereu que isca en la pantalla. Porteu el DNI o el passaport. El certificat és gratuït i vos el donem en el moment."}
        ]},
        "exercises": [
          {"q": "Què cal fer primer?", "o": ["Agafar un número", "Anar a la pantalla", "Pagar el certificat"], "e": "«Agafeu un número en la màquina de l'entrada.»"},
          {"q": "Quant costa el certificat?", "o": ["Res, és gratuït", "Cinc euros", "Depén del document"], "e": "«El certificat és gratuït.»"}
        ]
      }
    ]
  },
  {
    "id": "b13de171-1883-4f5b-bc30-6cec8a22bc74", "category": "comprensio_oral", "type": "co_dialegs", "sort_order": 3,
    "title": "Diàlegs quotidians", "name": "Compres en una botiga",
    "content": "Capta el sentit general i les dades concretes d'un diàleg senzill.", "icon": "👟", "color": "#C8E6C9",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "En una sabateria", "lines": [
          {"speaker": "Dependenta", "voice": "gina", "text": "Bona vesprada! Puc ajudar-te?"},
          {"speaker": "Client", "voice": "lluc", "text": "Sí, per favor. Busque unes sabates esportives per a córrer."},
          {"speaker": "Dependenta", "voice": "gina", "text": "Quin número uses?"},
          {"speaker": "Client", "voice": "lluc", "text": "El quaranta-dos."},
          {"speaker": "Dependenta", "voice": "gina", "text": "Tenim estes en blanc i en blau. Les blanques costen seixanta euros i les blaves, cinquanta-cinc."},
          {"speaker": "Client", "voice": "lluc", "text": "M'agraden més les blaves. Puc provar-me-les?"},
          {"speaker": "Dependenta", "voice": "gina", "text": "Clar que sí. Com et van?"},
          {"speaker": "Client", "voice": "lluc", "text": "Em van un poc xicotetes. Tens el quaranta-tres?"},
          {"speaker": "Dependenta", "voice": "gina", "text": "Sí, ací el tens."},
          {"speaker": "Client", "voice": "lluc", "text": "Estes em van perfectes. Me les quede. Puc pagar amb targeta?"},
          {"speaker": "Dependenta", "voice": "gina", "text": "Sí, sense cap problema."}
        ]},
        "exercises": [
          {"q": "Què vol comprar el client?", "o": ["Unes sabates esportives", "Unes botes", "Una camiseta"], "e": "«Busque unes sabates esportives per a córrer.»"},
          {"q": "De quin color les tria?", "o": ["Blaves", "Blanques", "Negres"], "e": "«M'agraden més les blaves.»"},
          {"q": "Quant li costen?", "o": ["Cinquanta-cinc euros", "Seixanta euros", "Quaranta-dos euros"], "e": "Les blaves costen cinquanta-cinc euros."},
          {"q": "Quin número s'endú finalment?", "o": ["El quaranta-tres", "El quaranta-dos", "El quaranta-quatre"], "e": "El quaranta-dos li va xicotet i es queda el quaranta-tres."},
          {"q": "Com paga?", "o": ["Amb targeta", "En efectiu", "Encara no paga"], "e": "«Puc pagar amb targeta?» — «Sí, sense cap problema.»"}
        ]
      }
    ]
  },
  {
    "id": "49c60d99-e4da-40de-a362-4ef97181833c", "category": "comprensio_oral", "type": "co_debats", "sort_order": 4,
    "title": "Debats i discussions", "name": "Opinions sobre un tema",
    "content": "Identifica el tema general i les opinions d'una discussió lenta i clara.", "icon": "💬", "color": "#D1C4E9",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "Un debat a la ràdio del poble", "lines": [
          {"speaker": "Neus", "voice": "gina", "text": "Hui parlem d'un tema que interessa molt al poble: tancar el centre als cotxes els caps de setmana. Jordi, tu què en penses?"},
          {"speaker": "Jordi", "voice": "lluc", "text": "Jo estic a favor. El centre serà més tranquil, hi haurà menys soroll i els xiquets podran jugar al carrer."},
          {"speaker": "Neus", "voice": "gina", "text": "Però molts comerciants diuen que vendran menys, perquè la gent no podrà aparcar prop de les tendes."},
          {"speaker": "Jordi", "voice": "lluc", "text": "Jo crec que no. En molts pobles ho han fet i ara passeja més gent pel centre i compra més."},
          {"speaker": "Neus", "voice": "gina", "text": "I els veïns grans, que caminen poc?"},
          {"speaker": "Jordi", "voice": "lluc", "text": "Per a ells, l'ajuntament posarà un autobús xicotet i gratuït."}
        ]},
        "exercises": [
          {"q": "De quin tema parlen?", "o": ["De tancar el centre als cotxes", "De construir un aparcament", "D'obrir tendes noves"], "e": "«Tancar el centre als cotxes els caps de setmana.»"},
          {"q": "Què pensa Jordi?", "o": ["Està a favor", "Està en contra", "No té opinió"], "e": "«Jo estic a favor.»"},
          {"q": "Per què estan preocupats alguns comerciants?", "o": ["Pensen que vendran menys", "No volen soroll", "No tenen autobús"], "e": "«Diuen que vendran menys, perquè la gent no podrà aparcar.»"},
          {"q": "Quina solució hi ha per a la gent gran?", "o": ["Un autobús gratuït", "Aparcaments nous", "Taxis més barats"], "e": "«L'ajuntament posarà un autobús xicotet i gratuït.»"}
        ]
      }
    ]
  },
  {
    "id": "13f987c9-442d-454c-b6a7-c3badafc914b", "category": "comprensio_oral", "type": "co_mitjans", "sort_order": 5,
    "title": "Ràdio i televisió", "name": "Falques i previsió del temps",
    "content": "Entén el sentit general i les dades d'un anunci de ràdio i de la previsió meteorològica.", "icon": "📻", "color": "#FFCDD2",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "Falca de ràdio", "lines": [
          {"speaker": "Locutor", "voice": "lluc", "text": "Arriba la Fira del Llibre de Castelló! Del dotze al vint d'abril, a la plaça Major, trobareu més de cinquanta parades amb llibres en valencià, contacontes per als xiquets i signatures d'autors. Obrim cada dia de deu del matí a nou de la nit. L'entrada és lliure. Fira del Llibre de Castelló: llig, viu, gaudix!"}
        ]},
        "exercises": [
          {"q": "Què anuncia la falca?", "o": ["Una fira del llibre", "Un festival de música", "Un mercat de roba"], "e": "«Arriba la Fira del Llibre de Castelló!»"},
          {"q": "On es fa?", "o": ["A la plaça Major", "A la biblioteca", "Al port"], "e": "«A la plaça Major.»"},
          {"q": "Quant costa entrar?", "o": ["Res, l'entrada és lliure", "Deu euros", "Cinc euros"], "e": "«L'entrada és lliure»: no cal pagar."}
        ]
      },
      {
        "passage": {"media": "audio", "title": "El temps", "lines": [
          {"speaker": "Presentadora", "voice": "gina", "text": "Bon dia! Demà dissabte el temps canviarà. Al matí farà sol a tot el territori, però a la vesprada arribaran núvols i plourà a l'interior de Castelló i de València. Les temperatures baixaran: a la costa, la màxima serà de díhuit graus. Diumenge tornarà el sol, però farà vent a la costa d'Alacant."}
        ]},
        "exercises": [
          {"q": "Quin temps farà dissabte al matí?", "o": ["Sol", "Pluja", "Vent"], "e": "«Al matí farà sol a tot el territori.»"},
          {"q": "On plourà dissabte de vesprada?", "o": ["A l'interior de Castelló i de València", "A la costa d'Alacant", "A tot arreu"], "e": "«Plourà a l'interior de Castelló i de València.»"},
          {"q": "Què passarà diumenge a la costa d'Alacant?", "o": ["Farà vent", "Nevarà", "Plourà molt"], "e": "«Farà vent a la costa d'Alacant.»"}
        ]
      }
    ]
  },
  {
    "id": "5d5c0103-fabf-40c7-9528-e550e7fbd42e", "category": "comprensio_oral", "type": "co_megafonia", "sort_order": 6,
    "title": "Megafonia i avisos", "name": "Estacions, aeroports i botigues",
    "content": "Entén missatges i indicacions públiques per megafonia.", "icon": "📢", "color": "#FFF9C4",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "Tres avisos", "lines": [
          {"speaker": "Estació", "voice": "gina", "text": "Atenció, per favor. El tren regional amb destinació a Xàtiva, que havia d'eixir a les deu i quart, eixirà amb vint minuts de retard per la via tres."},
          {"speaker": "Aeroport", "voice": "lluc", "text": "Senyores i senyors passatgers del vol amb destinació a Palma: es prega que vagen a la porta d'embarcament B12. L'embarcament començarà d'ací a deu minuts."},
          {"speaker": "Supermercat", "voice": "gina", "text": "Benvolguts clients: el supermercat tancarà d'ací a quinze minuts. Per favor, passen per caixa. Recordem que demà, diumenge, obrim de deu a dues."}
        ]},
        "exercises": [
          {"q": "A quina hora eixirà el tren de Xàtiva?", "o": ["A les deu i trenta-cinc", "A les deu i quart", "A les deu i vint"], "e": "Havia d'eixir a les deu i quart, amb vint minuts de retard: a les deu i trenta-cinc."},
          {"q": "Per quina via eixirà?", "o": ["Per la tres", "Per la dotze", "Per la dos"], "e": "«Per la via tres.»"},
          {"q": "On han d'anar els passatgers del vol a Palma?", "o": ["A la porta B12", "A la via tres", "A la caixa"], "e": "«A la porta d'embarcament B12.»"},
          {"q": "Què demanen als clients del supermercat?", "o": ["Que vagen a pagar", "Que tornen demà", "Que agafen un número"], "e": "«Tancarà d'ací a quinze minuts. Per favor, passen per caixa.»"},
          {"q": "Quin horari té el supermercat diumenge?", "o": ["De deu a dues", "No obri", "De deu a deu"], "e": "«Demà, diumenge, obrim de deu a dues.»"}
        ]
      }
    ]
  },
  {
    "id": "d5eec6dc-3e42-4564-8505-083fe2803f2d", "category": "comprensio_oral", "type": "co_orientacio", "sort_order": 7,
    "title": "Orientació", "name": "Com arribar a un lloc",
    "content": "Seguix instruccions pas a pas per a arribar a peu o en transport públic.", "icon": "🧭", "color": "#DCEDC8",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "On és Correus?", "lines": [
          {"speaker": "Turista", "voice": "lluc", "text": "Perdone, sap on és l'oficina de Correus?"},
          {"speaker": "Veïna", "voice": "gina", "text": "Sí, no està lluny. Seguisca tot recte per este carrer fins a la plaça de l'Església. Allí, gire a la dreta i agafe el segon carrer a l'esquerra. Correus està al costat d'una farmàcia, davant del parc."},
          {"speaker": "Turista", "voice": "lluc", "text": "Hi ha molta distància?"},
          {"speaker": "Veïna", "voice": "gina", "text": "No, a peu són uns deu minuts. Si està cansat, l'autobús número quatre para just davant."},
          {"speaker": "Turista", "voice": "lluc", "text": "Moltes gràcies!"}
        ]},
        "exercises": [
          {"q": "Fins a on ha de seguir recte?", "o": ["Fins a la plaça de l'Església", "Fins al parc", "Fins a la farmàcia"], "e": "«Seguisca tot recte fins a la plaça de l'Església.»"},
          {"q": "Què ha de fer en la plaça?", "o": ["Girar a la dreta", "Girar a l'esquerra", "Seguir recte"], "e": "«Allí, gire a la dreta.»"},
          {"q": "Què hi ha al costat de Correus?", "o": ["Una farmàcia", "Una església", "Una parada de taxis"], "e": "«Correus està al costat d'una farmàcia, davant del parc.»"},
          {"q": "Quant es tarda a peu?", "o": ["Uns deu minuts", "Mitja hora", "Dos minuts"], "e": "«A peu són uns deu minuts.»"},
          {"q": "Quin autobús pot agafar?", "o": ["El quatre", "El deu", "El dos"], "e": "«L'autobús número quatre para just davant.»"}
        ]
      }
    ]
  },
  {
    "id": "2da45308-17e5-43b6-958c-c14dc9497160", "category": "comprensio_escrita", "type": "ce_noticies", "sort_order": 1,
    "title": "Notícies", "name": "Notícies breus de premsa",
    "content": "Comprén una notícia breu i extrau-ne les dades clau.", "icon": "📰", "color": "#CFD8DC",
    "blocks": [
      {
        "passage": {"media": "text", "title": "La biblioteca de Sueca obrirà també els diumenges", "lines": [
          {"text": "La biblioteca municipal de Sueca obrirà també els diumenges a partir del pròxim mes de novembre. L'horari serà de deu del matí a dues de la vesprada."},
          {"text": "Segons l'ajuntament, la decisió respon a la petició de molts estudiants, que necessiten un lloc tranquil per a estudiar durant els caps de setmana, sobretot en època d'exàmens."},
          {"text": "A més, la biblioteca oferirà cada diumenge una activitat per a xiquets: contacontes, tallers de dibuix i jocs de taula. Les activitats són gratuïtes, però cal inscriure's abans en la web de l'ajuntament."}
        ]},
        "exercises": [
          {"q": "Què canvia a la biblioteca?", "o": ["Obrirà també els diumenges", "Tancarà els dissabtes", "Canviarà de lloc"], "e": "Primer paràgraf: obrirà també els diumenges."},
          {"q": "Quan comença el nou horari?", "o": ["Al novembre", "Demà", "A l'estiu"], "e": "«A partir del pròxim mes de novembre.»"},
          {"q": "Qui havia demanat el canvi?", "o": ["Molts estudiants", "Els xiquets", "Els treballadors"], "e": "«Respon a la petició de molts estudiants.»"},
          {"q": "Què cal fer per a participar en les activitats per a xiquets?", "o": ["Inscriure's en la web", "Pagar a l'entrada", "Portar un llibre"], "e": "«Són gratuïtes, però cal inscriure's abans en la web.»"}
        ]
      }
    ]
  },
  {
    "id": "024f0b76-81a9-4c47-8a58-f99d0ae29e75", "category": "comprensio_escrita", "type": "ce_opinio", "sort_order": 2,
    "title": "Textos d'opinió", "name": "Identificar la tesi principal",
    "content": "Comprén un text argumentatiu senzill i identifica'n la idea principal.", "icon": "🚲", "color": "#C8E6C9",
    "blocks": [
      {
        "passage": {"media": "text", "title": "Per què vaig en bici a la faena", "lines": [
          {"text": "Cada dia vaig a la faena en bicicleta i estic convençuda que és la millor opció per a moure's per la ciutat."},
          {"text": "En primer lloc, és bo per a la salut: faig exercici sense anar al gimnàs. En segon lloc, estalvie diners, perquè no gaste gasolina ni pague l'aparcament. A més, la bici no contamina."},
          {"text": "És veritat que quan plou no és gens agradable i que en alguns barris falten carrils bici. Però crec que l'ajuntament n'ha de fer més i que tots hauríem de provar-ho almenys un dia a la setmana."}
        ]},
        "exercises": [
          {"q": "Quina és la idea principal del text?", "o": ["Anar en bici a la faena és la millor opció", "Els carrils bici són perillosos", "El gimnàs és massa car"], "e": "La tesi apareix a la primera frase i es defén en la resta del text."},
          {"q": "Quin avantatge NO diu l'autora?", "o": ["Que arriba abans que en cotxe", "Que fa exercici", "Que estalvia diners"], "e": "Parla de la salut, dels diners i de la contaminació, però no del temps."},
          {"q": "Quin problema reconeix?", "o": ["Que quan plou no és agradable", "Que la bici és cara", "Que no té on deixar-la"], "e": "«És veritat que quan plou no és gens agradable.»"},
          {"q": "Què proposa al final?", "o": ["Fer més carrils i provar-ho un dia a la setmana", "Prohibir els cotxes", "Regalar bicis"], "e": "L'última frase recull la proposta."}
        ]
      }
    ]
  },
  {
    "id": "58bff655-a995-468c-b76f-7d5dd33af249", "category": "comprensio_escrita", "type": "ce_instruccions", "sort_order": 3,
    "title": "Instruccions", "name": "Textos instructius breus",
    "content": "Comprén instruccions breus i poc complexes de l'entorn immediat.", "icon": "📝", "color": "#FFE0B2",
    "blocks": [
      {
        "passage": {"media": "text", "title": "Com fer-se el carnet de la biblioteca", "lines": [
          {"text": "1. Omple el formulari d'inscripció. El trobaràs en el taulell de l'entrada o en la web."},
          {"text": "2. Porta el formulari, el DNI i una foto de carnet."},
          {"text": "3. Si tens menys de catorze anys, el pare o la mare ha de firmar el formulari."},
          {"text": "4. Arreplega el carnet en el mateix moment. És gratuït."},
          {"text": "5. Amb el carnet pots endur-te tres llibres durant quinze dies."}
        ]},
        "exercises": [
          {"q": "On pots trobar el formulari?", "o": ["En el taulell o en la web", "Només en la web", "A l'ajuntament"], "e": "Instrucció 1."},
          {"q": "Què NO cal portar?", "o": ["Una factura de la llum", "Una foto de carnet", "El DNI"], "e": "Instrucció 2: formulari, DNI i foto."},
          {"q": "Qui ha de firmar el formulari d'un xiquet de deu anys?", "o": ["El pare o la mare", "El bibliotecari", "El mateix xiquet"], "e": "Instrucció 3: té menys de catorze anys."},
          {"q": "Quants llibres pots endur-te alhora?", "o": ["Tres", "Quinze", "Catorze"], "e": "Instrucció 5: tres llibres durant quinze dies."}
        ]
      }
    ]
  },
  {
    "id": "12e436ef-c398-4f36-96ca-f1d5b6db92eb", "category": "comprensio_escrita", "type": "ce_retols", "sort_order": 4,
    "title": "Rètols i descripcions", "name": "Senyalística i descripcions",
    "content": "Entén rètols, cartells i avisos, i descripcions de persones, llocs i objectes.", "icon": "🪧", "color": "#FFCCBC",
    "blocks": [
      {
        "passage": {"media": "text", "title": "Rètols", "lines": [
          {"text": "Rètol A · PROHIBIT FUMAR"},
          {"text": "Rètol B · TANCAT PER VACANCES. TORNEM L'1 DE SETEMBRE"},
          {"text": "Rètol C · PERILL: TERRA MULLAT"},
          {"text": "Rètol D · ESTACIÓ DE METRO → 200 m"},
          {"text": "Rètol E · MENÚ DEL DIA: 12 € (PRIMER, SEGON, POSTRES I BEGUDA)"}
        ]},
        "exercises": [
          {"q": "Vols dinar sense gastar molts diners.", "o": ["Rètol E", "Rètol A", "Rètol C"], "e": "El menú del dia costa 12 € amb tot inclòs."},
          {"q": "Busques per on anar al metro.", "o": ["Rètol D", "Rètol B", "Rètol E"], "e": "La fletxa indica l'estació a 200 metres."},
          {"q": "Has de caminar amb compte per a no caure.", "o": ["Rètol C", "Rètol A", "Rètol D"], "e": "El terra està mullat."},
          {"q": "Esta botiga no obri en agost.", "o": ["Rètol B", "Rètol E", "Rètol C"], "e": "Està tancada per vacances fins a l'1 de setembre."},
          {"q": "No pots encendre un cigarret.", "o": ["Rètol A", "Rètol D", "Rètol B"], "e": "Prohibit fumar."}
        ]
      },
      {
        "passage": {"media": "text", "title": "Cartell al carrer", "lines": [
          {"text": "HE PERDUT LA MEUA GOSSA!"},
          {"text": "Es diu Lluna. És xicoteta, de color marró i té una taca blanca a la cara. Porta un collar roig."},
          {"text": "Es va perdre dimarts de vesprada prop del parc de l'Alameda. És molt bona i no mossega."},
          {"text": "Si la veus, telefona al 612 345 678. Gràcies!"}
        ]},
        "exercises": [
          {"q": "Com és la Lluna?", "o": ["Xicoteta i marró, amb una taca blanca", "Gran i blanca", "Negra, amb un collar blau"], "e": "Segon paràgraf del cartell."},
          {"q": "On es va perdre?", "o": ["Prop d'un parc", "A la platja", "A casa"], "e": "«Prop del parc de l'Alameda.»"},
          {"q": "Què vol dir «no mossega»?", "o": ["Que no fa mal amb les dents", "Que no menja", "Que no borda"], "e": "Mossegar: clavar les dents. Es pot deduir pel context: «És molt bona»."}
        ]
      }
    ]
  },
  {
    "id": "559b9e61-3da9-4c1d-95f3-7813adf78292", "category": "comprensio_escrita", "type": "ce_documents", "sort_order": 5,
    "title": "Documents quotidians", "name": "Horaris, preus i anuncis",
    "content": "Localitza informació específica en horaris, tarifes i anuncis, i deduïx significats pel context.", "icon": "🗓️", "color": "#B3E5FC",
    "blocks": [
      {
        "passage": {"media": "text", "title": "Piscina municipal", "lines": [
          {"text": "De dilluns a divendres: de 7.00 a 22.00 h · Dissabtes: de 9.00 a 20.00 h · Diumenges i festius: tancat"},
          {"text": "Entrada individual: 4 €. Menors de 12 anys i majors de 65: 2 €. Abonament mensual: 30 €."},
          {"text": "És obligatori portar gorra de bany. Prohibit menjar dins del recinte."}
        ]},
        "exercises": [
          {"q": "Pots nadar diumenge al matí?", "o": ["No, està tancat", "Sí, de 9 a 20 h", "Sí, de 7 a 22 h"], "e": "Diumenges i festius: tancat."},
          {"q": "Quant paga una xiqueta de 10 anys?", "o": ["2 €", "4 €", "30 €"], "e": "Menors de 12 anys: 2 €."},
          {"q": "Què és obligatori portar?", "o": ["Gorra de bany", "Ulleres", "Tovallola"], "e": "«És obligatori portar gorra de bany.»"},
          {"q": "Vas a nadar tres vegades per setmana. Què et convé més?", "o": ["L'abonament mensual", "L'entrada individual", "Anar-hi els diumenges"], "e": "Unes dotze entrades de 4 € costen més que l'abonament de 30 €."}
        ]
      },
      {
        "passage": {"media": "text", "title": "Anunci", "lines": [
          {"text": "ES LLOGA pis al centre d'Alcoi. Tres habitacions, dos banys, cuina moblada i balcó. Molt lluminós. A prop de l'estació de tren."},
          {"text": "550 € al mes. Interessats, telefoneu de 17 a 20 h al 965 00 11 22."}
        ]},
        "exercises": [
          {"q": "Què vol dir «es lloga»?", "o": ["Que s'hi pot viure pagant cada mes", "Que es ven", "Que ja està ocupat"], "e": "Llogar: pagar per a usar una cosa durant un temps. Ho indica el preu «al mes»."},
          {"q": "Quan pots telefonar?", "o": ["De 17 a 20 h", "Al matí", "A qualsevol hora"], "e": "«Telefoneu de 17 a 20 h.»"},
          {"q": "Què NO té el pis?", "o": ["Piscina", "Balcó", "Cuina moblada"], "e": "L'anunci no parla de piscina."}
        ]
      }
    ]
  },
  {
    "id": "e2118fdc-8cf9-4cfe-ac1f-2c70b69c9cea", "category": "comprensio_escrita", "type": "ce_correus", "sort_order": 6,
    "title": "Cartes i correus", "name": "Comunicació interpersonal",
    "content": "Comprén cartes, correus, invitacions, confirmacions i comandes.", "icon": "✉️", "color": "#F8BBD0",
    "blocks": [
      {
        "passage": {"media": "text", "title": "Correu d'Anna", "lines": [
          {"text": "Hola, Marc:"},
          {"text": "Com estàs? T'escric per a convidar-te al meu aniversari. Faré una festa el dissabte 14 a les nou de la nit a casa meua. Vindran els amics de la universitat i també la meua cosina Júlia, que ja coneixes."},
          {"text": "Si pots, porta alguna cosa per a beure; jo prepararé el sopar. Ah! I no cal que em compres cap regal, de veritat."},
          {"text": "Confirma'm si vens abans de dijous, per favor, que he de saber quanta gent serem."},
          {"text": "Una abraçada,\nAnna"}
        ]},
        "exercises": [
          {"q": "Per què escriu Anna?", "o": ["Per a convidar Marc a una festa", "Per a demanar-li un regal", "Per a donar-li les gràcies"], "e": "«T'escric per a convidar-te al meu aniversari.»"},
          {"q": "On serà la festa?", "o": ["A casa d'Anna", "A la universitat", "A casa de Júlia"], "e": "«A casa meua.»"},
          {"q": "Què ha de portar Marc?", "o": ["Alguna cosa per a beure", "El sopar", "Un regal"], "e": "«Porta alguna cosa per a beure; jo prepararé el sopar.»"},
          {"q": "Què ha de fer Marc abans de dijous?", "o": ["Confirmar si hi va", "Comprar el regal", "Telefonar a Júlia"], "e": "«Confirma'm si vens abans de dijous.»"}
        ]
      }
    ]
  },
  {
    "id": "4b489174-128e-44bd-9f19-f032ea21d116", "category": "expressio_escrita", "type": "ee_descripcio", "sort_order": 1,
    "title": "Descripcions i relats", "name": "Escriptura bàsica amb connectors",
    "content": "Escriu descripcions i històries senzilles amb connectors bàsics.", "icon": "🖊️", "color": "#FFE0B2",
    "exercises": [
      {"q": "Descriu la teua casa o el teu pis: on està, quantes estances té, com és la teua habitació i què és el que més t'agrada. Usa connectors com «i», «però», «a més» o «perquè».", "w": {"min_words": 60, "max_words": 80}},
      {"q": "Conta què vas fer el cap de setmana passat: on vas anar, amb qui i què et va agradar més. Ordena les accions amb «primer», «després» i «finalment».", "w": {"min_words": 60, "max_words": 80, "words": ["primer", "després", "finalment"], "min_words_used": 2}}
    ]
  },
  {
    "id": "c8628719-f1d2-4176-a15f-0e665e5eba2d", "category": "expressio_escrita", "type": "ee_vida", "sort_order": 2,
    "title": "La meua vida", "name": "Rutina, família i faena",
    "content": "Escriu sobre la rutina diària, la família, les condicions de vida i la faena.", "icon": "🏡", "color": "#DCEDC8",
    "exercises": [
      {"q": "Explica la teua rutina d'un dia normal: a quina hora t'alces, què fas al matí i a la vesprada, i què fas abans de dormir.", "w": {"min_words": 60, "max_words": 80, "words": ["prompte", "dinar", "sempre", "de vegades", "tard"], "min_words_used": 3}},
      {"q": "Presenta la teua família o els teus amics: qui són, com són (físic i caràcter) i què feu junts.", "w": {"min_words": 60, "max_words": 80}},
      {"q": "Explica en què treballes o què estudies (o què feies abans): l'horari, el lloc i el que més t'agrada i el que menys.", "w": {"min_words": 60, "max_words": 80}}
    ]
  },
  {
    "id": "0c6366f8-7a2c-4b74-b564-98da8b54071c", "category": "expressio_escrita", "type": "ee_formularis", "sort_order": 3,
    "title": "Formularis", "name": "Fitxes i sol·licituds",
    "content": "Completa formularis i models textuals breus i tancats.", "icon": "🗂️", "color": "#C5CAE9",
    "exercises": [
      {"q": "Vols apuntar-te a una activitat del poliesportiu municipal. Omple la fitxa d'inscripció.", "f": ["Nom i cognoms", "Data de naixement", "Adreça", "Telèfon", "Activitat que vols fer", "Dies i horari que prefereixes", "Per què vols fer esta activitat?"]},
      {"q": "Has perdut la maleta a l'aeroport. Omple el formulari de reclamació.", "f": ["Nom i cognoms", "Número de vol", "Data del viatge", "Descripció de la maleta (color, grandària...)", "Què hi havia dins de la maleta?", "Telèfon i correu electrònic"]}
    ]
  },
  {
    "id": "fbd2efb4-79e9-4935-b3a9-db66f12a53b6", "category": "expressio_escrita", "type": "ee_notes", "sort_order": 4,
    "title": "Notes i missatges", "name": "Missatges breus i dubtes",
    "content": "Anota missatges breus i expressa per escrit dubtes o incomprensió.", "icon": "🗒️", "color": "#FFF9C4",
    "exercises": [
      {"q": "Deixa una nota a la persona amb qui comparteixes pis: hui arribaràs tard, cal comprar pa i llet i ha telefonat el propietari del pis.", "w": {"min_words": 25, "max_words": 40}},
      {"q": "Escriu un missatge a la teua professora: no has entés els deures per a dilluns. Explica què no has entés i demana-li ajuda.", "w": {"min_words": 25, "max_words": 40}},
      {"q": "Has contestat una telefonada per a un company de faena que no hi era. Deixa-li una nota: qui ha telefonat, per què i què ha de fer.", "w": {"min_words": 25, "max_words": 40}}
    ]
  },
  {
    "id": "3f56c1b7-d9c8-476d-9040-7a87ce8d0e59", "category": "expressio_escrita", "type": "ee_correus", "sort_order": 5,
    "title": "Cartes i correus", "name": "Disculpar-se, excusar-se i agrair",
    "content": "Escriu cartes personals i correus per a disculpar-te, excusar-te o donar les gràcies.", "icon": "💌", "color": "#F8BBD0",
    "exercises": [
      {"q": "Una amiga t'ha convidat al sopar del seu aniversari, però no pots anar-hi. Escriu-li un correu per a disculpar-te: explica per què no pots anar, felicita-la i proposa-li quedar un altre dia.", "w": {"min_words": 60, "max_words": 80}},
      {"q": "Has passat uns dies a casa d'uns amics. Escriu-los un correu per a donar-los les gràcies: conta què és el que més t'ha agradat i convida'ls a vindre a ta casa.", "w": {"min_words": 60, "max_words": 80}},
      {"q": "La setmana que ve no podràs anar a classe de valencià. Escriu un correu formal a l'acadèmia per a excusar-te, explicar el motiu i demanar els materials.", "w": {"min_words": 50, "max_words": 70}}
    ]
  },
  {
    "id": "afeec18e-6204-4efc-bdc2-4b1c87e0957d", "category": "expressio_oral", "type": "eo_descripcio", "sort_order": 1,
    "title": "Descriure i narrar", "name": "Conversa amb Marta",
    "content": "Descriu persones, espais i rutines, i conta fets recents, gustos i preferències.", "icon": "🧑‍🤝‍🧑", "color": "#B2EBF2",
    "metadata": {
      "character": "Marta, companya d'intercanvi", "voice": "gina",
      "initial_prompt": "Hola! Soc Marta, encantada! Com que és el primer dia de l'intercanvi, conta'm una mica de tu: com eres i on vius?",
      "objectius": ["Descriu-te: com eres físicament i de caràcter.", "Descriu la teua casa o el teu barri.", "Conta què vas fer el cap de setmana passat.", "Explica què t'agrada fer en el temps lliure."],
      "system_prompt": "Ets Marta, una jove valenciana simpàtica que fa un intercanvi de conversa amb una persona que prepara el nivell A2 de la JQCV. Fes-li preguntes perquè descriga persones (físic i caràcter), la seua casa, el seu barri, la seua rutina, fets recents i els seus gustos. Parla en valencià general, amb frases curtes i clares, vocabulari quotidià i una sola pregunta per torn. Si s'equivoca, repetix la frase de manera correcta dins de la teua resposta, sense fer lliçons. Anima-la a allargar les respostes (per exemple: «I com és?», «I què més vas fer?»)."
    }
  },
  {
    "id": "6c707bd9-a1e6-4370-ad37-82f0c065d021", "category": "expressio_oral", "type": "eo_entrevista", "sort_order": 2,
    "title": "Preguntes i respostes", "name": "Entrevista de faena amb Andreu",
    "content": "Pregunta i respon sobre assumptes personals, d'estudi i de faena.", "icon": "💼", "color": "#FFE0B2",
    "metadata": {
      "character": "Andreu, responsable d'un alberg", "voice": "lluc",
      "initial_prompt": "Bon dia, passa i seu. Soc Andreu, el responsable de l'alberg. Busquem una persona per a treballar este estiu. Com et dius i d'on eres?",
      "objectius": ["Presenta't: nom, origen i edat.", "Explica què estudies o en què has treballat.", "Respon què saps fer i quins idiomes parles.", "Pregunta per l'horari i el sou de la faena."],
      "system_prompt": "Ets Andreu, responsable d'un alberg juvenil de Morella, i fas una entrevista de treball per a l'estiu a una persona que prepara el nivell A2 de la JQCV. Fes preguntes senzilles, una per torn, sobre dades personals, estudis, faenes anteriors, idiomes i disponibilitat. Quan la persona pregunte per l'horari, el sou o les tasques, respon amb dades concretes (per exemple: de 8 a 15 h, 1.200 € al mes, atendre la recepció i organitzar activitats). Parla en valencià general, amb frases curtes i un registre formal però amable. Si s'equivoca, reformula-ho bé dins de la teua resposta, sense corregir-la explícitament."
    }
  },
  {
    "id": "d6da3054-2982-431e-b05c-300cd9b19472", "category": "expressio_oral", "type": "eo_exposicio", "sort_order": 3,
    "title": "Exposició breu", "name": "Presentació davant del professor",
    "content": "Fes una presentació breu i preparada sobre plans, la vida quotidiana o una opinió simple.", "icon": "🎤", "color": "#D1C4E9",
    "metadata": {
      "character": "Josep, professor de valencià", "voice": "lluc",
      "initial_prompt": "Bon dia! Hui toca l'exposició oral. Tens un parell de minuts per a parlar dels teus plans per a les pròximes vacances. Quan vulgues, comença!",
      "objectius": ["Explica on aniràs i amb qui.", "Explica com hi aniràs i quants dies.", "Conta què faràs allí.", "Dona la teua opinió: per què t'agrada eixe pla?"],
      "system_prompt": "Ets Josep, professor de valencià, i escoltes l'exposició oral breu d'una persona que prepara el nivell A2 de la JQCV. El tema són els seus plans per a les vacances, però si en vol parlar d'un altre de quotidià (el seu poble, una festa, la seua faena), accepta-ho. Deixa-la parlar i, després de cada intervenció, fes una sola pregunta breu perquè amplie la informació (on, quan, amb qui, per què). Quan haja cobert els objectius, fes-li un comentari final breu i positiu amb una o dues coses per millorar. Parla en valencià general i amb frases clares."
    }
  },
  {
    "id": "df177758-c43b-4ebf-ba2c-58e7b539e8c6", "category": "expressio_oral", "type": "eo_estrategies", "sort_order": 4,
    "title": "Estratègies d'interacció", "name": "Xarrar amb Pepa, la veïna",
    "content": "Inicia, mantín i tanca una conversa; demana que et repetisquen o que t'aclarisquen una paraula.", "icon": "👵", "color": "#FFCDD2",
    "metadata": {
      "character": "Pepa, veïna del poble", "voice": "gina",
      "initial_prompt": "Ai, bon dia! Què fas per ací tan de matí? Vas cap al forn o vas a la plaça, que hui hi ha mercat?",
      "objectius": ["Saluda i respon a Pepa.", "Demana-li que repetisca o que parle més a poc a poc.", "Pregunta què vol dir una paraula que no entens.", "Acomiada't amablement per a acabar la conversa."],
      "system_prompt": "Ets Pepa, una veïna gran, xarraire i afectuosa d'un poble valencià, que conversa amb una persona que prepara el nivell A2 de la JQCV. L'objectiu és que practique estratègies d'interacció: iniciar, mantindre i acabar una conversa, demanar que li repetisques una cosa i preguntar el significat de paraules. De tant en tant usa alguna paraula o expressió col·loquial poc coneguda (per exemple: «estar fet pols», «fer la migdiada», «el porrat») i, quan la persona et pregunte què vol dir, explica-ho amb paraules senzilles. Si et demana que repetisques o que parles més a poc a poc, fes-ho amb una frase més curta. Parla en valencià general, amb frases no massa llargues. Si la persona s'acomiada, acomiada't tu també."
    }
  }
  ]$data$;
  r jsonb;
  b jsonb;
  e jsonb;
  rid uuid;
  pid uuid;
  ppos smallint;
  epos smallint;
BEGIN
  FOR r IN SELECT * FROM jsonb_array_elements(catalog) LOOP
    rid := (r->>'id')::uuid;
    INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
    VALUES (
      rid, r->>'name', r->>'type', r->>'category', r->>'content', 'principiant', 10, (r->>'sort_order')::smallint,
      jsonb_build_object('icon', r->>'icon', 'color', r->>'color', 'section_name', r->>'title') || coalesce(r->'metadata', '{}')
    )
    ON CONFLICT (id) DO UPDATE SET
      name = EXCLUDED.name,
      type = EXCLUDED.type,
      category = EXCLUDED.category,
      content = EXCLUDED.content,
      sort_order = EXCLUDED.sort_order,
      metadata = EXCLUDED.metadata;

    -- Es reescriu el contingut A2 del recurs: tornar a aplicar el fitxer no el duplica.
    DELETE FROM public.practice_exercises WHERE resource_id = rid AND level = 'A2';
    DELETE FROM public.practice_passages WHERE resource_id = rid AND level = 'A2';

    ppos := 0;
    epos := 0;
    FOR b IN SELECT * FROM jsonb_array_elements(
      coalesce(r->'blocks', CASE WHEN r ? 'exercises' THEN jsonb_build_array(jsonb_build_object('exercises', r->'exercises')) ELSE '[]' END)
    ) LOOP
      pid := NULL;
      IF b ? 'passage' THEN
        ppos := ppos + 1;
        INSERT INTO public.practice_passages (resource_id, level, position, media, title, lines, audio_url)
        VALUES (
          rid, 'A2', ppos, b->'passage'->>'media', b->'passage'->>'title', b->'passage'->'lines',
          CASE WHEN b->'passage'->>'media' = 'audio' THEN format('/audio/practice/%s-a2-%s.wav', r->>'type', ppos) END
        )
        RETURNING id INTO pid;
      END IF;

      FOR e IN SELECT * FROM jsonb_array_elements(b->'exercises') LOOP
        epos := epos + 1;
        INSERT INTO public.practice_exercises (resource_id, level, position, passage_id, kind, prompt, options, answers, task, explanation)
        VALUES (
          rid, 'A2', epos, pid,
          CASE WHEN e ? 'o' THEN 'choice' WHEN e ? 'a' THEN 'fill' WHEN e ? 'w' THEN 'writing' ELSE 'form' END,
          e->>'q',
          CASE WHEN e ? 'o' THEN ARRAY(SELECT jsonb_array_elements_text(e->'o')) END,
          CASE WHEN e ? 'o' THEN ARRAY[e->'o'->>0] WHEN e ? 'a' THEN ARRAY(SELECT jsonb_array_elements_text(e->'a')) END,
          CASE WHEN e ? 'w' THEN e->'w' WHEN e ? 'f' THEN jsonb_build_object('fields', e->'f') END,
          e->>'e'
        );
      END LOOP;
    END LOOP;
  END LOOP;
END
$do$;
