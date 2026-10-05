-- Àrees de destreses del Quadern B1 de la JQCV (2. Objectius per àrees):
-- Comprensió oral, Comprensió escrita, Expressió i interacció escrites i
-- Expressió i interacció orals, amb el mateix format que les de l'A2
-- (20260930120000). Són recursos de nivell intermedi amb contingut B1:
--   * Comprensió oral: converses, avisos i instruccions detallades, ràdio i
--     televisió, ficció, debats i xarrades, amb inferències i detalls específics.
--     Els àudios es generen amb el TTS (backend/scripts/generate-practice-audio.ts)
--     a /audio/practice/<type>-b1-<posició>.wav.
--   * Comprensió escrita: correspondència personal, documents oficials curts i
--     fullets, instruccions, premsa, textos dialogats i d'opinió.
--   * Expressió escrita: redaccions que avalua el LLM amb la rúbrica B1 de la JQCV;
--     la paràfrasi i els apunts porten el text o l'àudio de referència.
--   * Expressió oral: xats amb un personatge; el system_prompt es compon amb el del
--     personatge, unes pautes comunes del B1 i els objectius.
-- Tornar a aplicar el fitxer no duplica res: es reescriu el contingut B1.

DO $do$
DECLARE
  catalog jsonb := $data$[
  {
    "id": "bf6aee75-50f7-4d39-8926-ed4261a713ee", "category": "comprensio_oral", "type": "b1_co_converses", "sort_order": 1,
    "title": "Converses quotidianes", "name": "Faena, estudis i temps d'oci",
    "content": "Entén les idees principals i els detalls d'una conversa a ritme normal sobre la faena, els estudis i l'oci.", "icon": "☕", "color": "#B2EBF2",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "Canvis a la faena", "lines": [
          {"speaker": "Marta", "voice": "gina", "text": "Vicent, has llegit el correu de recursos humans? A partir del mes que ve canvien els torns i jo, la veritat, no sé com m'organitzaré."},
          {"speaker": "Vicent", "voice": "lluc", "text": "Sí, l'he llegit esta vesprada. Si no ho he entés malament, els del matí entrarem a les set en compte de les huit, però eixirem a les tres."},
          {"speaker": "Marta", "voice": "gina", "text": "Exacte. I a mi això m'ho complica tot, perquè la xiqueta entra a l'escola a les nou i no tinc ningú que la porte. Mon home treballa a Sagunt i ix de casa molt prompte."},
          {"speaker": "Vicent", "voice": "lluc", "text": "I no pots demanar el torn de vesprada? Jo crec que encara hi ha places. A més, el correu diu que qui tinga fills menors de dotze anys té preferència per a triar."},
          {"speaker": "Marta", "voice": "gina", "text": "Ah, no ho sabia! Doncs ho demanaré demà mateix. El problema és que la vesprada acaba a les deu de la nit, i a eixa hora ja no hi ha autobús fins al meu barri."},
          {"speaker": "Vicent", "voice": "lluc", "text": "Home, això té solució: jo també visc per allà i vinc amb cotxe. Si fem el mateix torn, et puc tornar a casa. Així compartim la gasolina."},
          {"speaker": "Marta", "voice": "gina", "text": "De veritat? Em faries un favor enorme. I tu, per què vols canviar? Tu no tens fills."},
          {"speaker": "Vicent", "voice": "lluc", "text": "Perquè m'he apuntat a un curs d'anglés que fan els matins, dimarts i dijous. Si treballe de vesprada, el puc fer sense problemes. Ja saps que vull presentar-me a la plaça de coordinador, i allí demanen un B2."},
          {"speaker": "Marta", "voice": "gina", "text": "Doncs perfecte, ens convé als dos. Parlem amb Rosa, la cap, abans del divendres, que és l'últim dia per a demanar el canvi."}
        ]},
        "exercises": [
          {"q": "Què canviarà el mes que ve per als treballadors del matí?", "o": ["Entraran una hora abans i eixiran a les tres", "Treballaran també els dissabtes", "Entraran a les nou i eixiran a les tres"], "e": "«Els del matí entrarem a les set en compte de les huit, però eixirem a les tres.»"},
          {"q": "Per què a Marta li preocupa el nou horari del matí?", "o": ["No té qui porte la filla a l'escola", "Viu molt lluny de la faena", "No li agrada alçar-se prompte"], "e": "La xiqueta entra a les nou i el seu home ix de casa molt prompte."},
          {"q": "Què diu el correu sobre les persones amb fills menors de dotze anys?", "o": ["Que tenen preferència per a triar el torn", "Que poden treballar des de casa", "Que tenen un dia lliure més"], "e": "«Qui tinga fills menors de dotze anys té preferència per a triar.»"},
          {"q": "Quin problema té el torn de vesprada per a Marta?", "o": ["A les deu de la nit ja no hi ha autobús al seu barri", "Acaba massa prompte", "Coincidix amb l'horari del seu home"], "e": "«A eixa hora ja no hi ha autobús fins al meu barri.»"},
          {"q": "Com l'ajudarà Vicent?", "o": ["La tornarà a casa amb cotxe", "Li deixarà el seu cotxe", "Parlarà amb la cap per ella"], "e": "«Si fem el mateix torn, et puc tornar a casa.»"},
          {"q": "Per què vol Vicent el torn de vesprada?", "o": ["Per a fer un curs d'anglés al matí", "Perquè té fills a l'escola", "Perquè viu a Sagunt"], "e": "S'ha apuntat a un curs d'anglés els matins de dimarts i dijous."},
          {"q": "Què podem deduir de les ambicions de Vicent?", "o": ["Vol ascendir en l'empresa", "Vol canviar d'empresa", "Vol jubilar-se prompte"], "e": "Vol presentar-se a la plaça de coordinador i per això necessita el B2 d'anglés."},
          {"q": "Fins quan tenen temps per a demanar el canvi de torn?", "o": ["Fins al divendres", "Fins a final de mes", "Fins a demà"], "e": "«Abans del divendres, que és l'últim dia per a demanar el canvi.»"}
        ]
      },
      {
        "passage": {"media": "audio", "title": "Plans per al pont", "lines": [
          {"speaker": "Núria", "voice": "gina", "text": "Bé, què fem al final este pont? Que ja és dimecres i encara no hem decidit res."},
          {"speaker": "Jordi", "voice": "lluc", "text": "Jo havia pensat en Morella. Fa temps que en tinc ganes i diuen que a la tardor és preciós. Però he mirat les cases rurals i les que queden són caríssimes."},
          {"speaker": "Núria", "voice": "gina", "text": "Normal, ho deixem tot per a l'últim moment. I si anem a la Vall d'Albaida? La meua cosina té una caseta a Bocairent i me l'ha oferida, i no ens cobraria res."},
          {"speaker": "Jordi", "voice": "lluc", "text": "Home, gratis és un argument molt bo! A més, podríem fer la ruta de les covetes dels moros i el pas del riu Clariano, que m'han dit que no és gens difícil."},
          {"speaker": "Núria", "voice": "gina", "text": "Això sí: la casa només té dues habitacions, així que no podem dir-ho a tota la colla. Com a molt, a Anna i a Lluís."},
          {"speaker": "Jordi", "voice": "lluc", "text": "D'acord. Jo els escric ara. Ah, i el temps? Ahir van dir que podia ploure dissabte."},
          {"speaker": "Núria", "voice": "gina", "text": "Sí, però només dissabte de matí. Si plou, visitem el museu i el poble, i la ruta la fem diumenge, que farà sol."}
        ]},
        "exercises": [
          {"q": "Per què no van finalment a Morella?", "o": ["Els allotjaments que queden són massa cars", "No els agrada a la tardor", "Està massa lluny"], "e": "«Les que queden són caríssimes.»"},
          {"q": "Per què és una bona opció la casa de Bocairent?", "o": ["No hauran de pagar res", "És molt gran", "Està al costat del museu"], "e": "La cosina no els cobraria res: «gratis és un argument molt bo»."},
          {"q": "Per què no poden convidar tota la colla?", "o": ["La casa només té dues habitacions", "La cosina no vol", "No hi ha prou cotxes"], "e": "«La casa només té dues habitacions.»"},
          {"q": "Què faran si plou dissabte de matí?", "o": ["Visitar el museu i el poble", "Tornar a casa", "Fer la ruta igualment"], "e": "«Si plou, visitem el museu i el poble, i la ruta la fem diumenge.»"},
          {"q": "Quina actitud mostra Núria en la conversa?", "o": ["Pràctica i resolutiva", "Indecisa i pessimista", "Enfadada amb Jordi"], "e": "Proposa alternatives i té un pla B per a la pluja."}
        ]
      }
    ]
  },
  {
    "id": "edbc49a1-e228-43bc-8b61-0f0b0d4e1e8e", "category": "comprensio_oral", "type": "b1_co_avisos", "sort_order": 2,
    "title": "Missatges i instruccions", "name": "Contestadors, anuncis i instruccions detallades",
    "content": "Entén informació específica de missatges i anuncis, i seguix instruccions detallades.", "icon": "☎️", "color": "#FFE0B2",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "Contestador del centre de salut", "lines": [
          {"speaker": "Contestador", "voice": "gina", "text": "Ha telefonat al centre de salut de Benimaclet. Li recordem que, si es tracta d'una urgència vital, ha de penjar i telefonar al cent dotze."},
          {"speaker": "Contestador", "voice": "gina", "text": "Per a demanar, canviar o anul·lar una cita amb el metge de família, premeu u. Recordeu que també ho podeu fer a través de l'aplicació GVA Salut, les vint-i-quatre hores del dia. Per a les analítiques, premeu dos: les extraccions es fan de dilluns a divendres, de huit a deu del matí, i cal vindre en dejú."},
          {"speaker": "Contestador", "voice": "gina", "text": "Si necessiteu renovar una recepta o consultar el resultat d'unes proves, premeu tres. Per a parlar amb el personal administratiu, espereu i la vostra telefonada serà atesa per ordre d'arribada. En este moment, el temps d'espera aproximat és de sis minuts."}
        ]},
        "exercises": [
          {"q": "Què ha de fer qui té una urgència greu?", "o": ["Penjar i telefonar al 112", "Prémer u", "Esperar que l'atenguen"], "e": "«Si es tracta d'una urgència vital, ha de penjar i telefonar al cent dotze.»"},
          {"q": "Vols canviar l'hora d'una cita a les onze de la nit. Què pots fer?", "o": ["Usar l'aplicació GVA Salut", "Prémer dos", "No es pot fer fins l'endemà"], "e": "L'aplicació funciona les vint-i-quatre hores del dia."},
          {"q": "Quina condició hi ha per a fer-se una analítica?", "o": ["Anar-hi sense haver menjat", "Portar la recepta", "Demanar-la amb una setmana d'antelació"], "e": "«Cal vindre en dejú»: sense haver menjat res."},
          {"q": "Quina tecla has de prémer per a saber els resultats d'unes proves?", "o": ["La tres", "La u", "La dos"], "e": "«Per a consultar el resultat d'unes proves, premeu tres.»"},
          {"q": "Què passa si no prems cap tecla?", "o": ["T'atendrà el personal administratiu", "Es talla la telefonada", "Torna a començar el missatge"], "e": "«Espereu i la vostra telefonada serà atesa per ordre d'arribada.»"}
        ]
      },
      {
        "passage": {"media": "audio", "title": "Abans de l'excursió", "lines": [
          {"speaker": "Guia", "voice": "lluc", "text": "Bon dia a tothom i benvinguts a la ruta del Penyagolosa. Abans d'eixir, escolteu-me un moment, que és important. La ruta té uns dotze quilòmetres i tardarem unes cinc hores, comptant les parades. Farem una parada a mig matí per a esmorzar, a la font de Sant Joan, i dinarem dalt del cim si fa bon temps."},
          {"speaker": "Guia", "voice": "lluc", "text": "Comproveu que porteu almenys litre i mig d'aigua, perquè fins a la font no n'hi ha. Al cim fa més fred que ací baix, així que guardeu un tallavent o una jaqueta a la motxilla, encara que ara faça calor."},
          {"speaker": "Guia", "voice": "lluc", "text": "Ana anirà al davant i jo aniré l'últim, al final del grup. Ningú no ha d'avançar Ana ni quedar-se darrere de mi. Si algú es despista i perd el grup, que no seguisca caminant: que es quede on està i que em telefone. El meu número el teniu en el full que us he donat. I recordeu que no podem deixar cap residu a la muntanya: el que portem, ho tornem."}
        ]},
        "exercises": [
          {"q": "Quant durarà aproximadament l'excursió?", "o": ["Unes cinc hores", "Unes dotze hores", "Mig matí"], "e": "«Tardarem unes cinc hores, comptant les parades.»"},
          {"q": "On esmorzaran?", "o": ["A la font de Sant Joan", "Dalt del cim", "A l'aparcament"], "e": "«Farem una parada a mig matí per a esmorzar, a la font de Sant Joan.»"},
          {"q": "Per què cal portar una jaqueta?", "o": ["Perquè al cim farà més fred", "Perquè plourà segur", "Perquè eixiran de nit"], "e": "«Al cim fa més fred que ací baix.»"},
          {"q": "Quin és el paper del guia durant la ruta?", "o": ["Anar al final del grup", "Anar al davant", "Esperar a la font"], "e": "«Ana anirà al davant i jo aniré l'últim.»"},
          {"q": "Què ha de fer qui perd el grup?", "o": ["Quedar-se quiet i telefonar al guia", "Tornar a l'aparcament", "Seguir el camí fins al cim"], "e": "«Que no seguisca caminant: que es quede on està i que em telefone.»"},
          {"q": "Què vol dir «el que portem, ho tornem»?", "o": ["Que cal endur-se els residus", "Que cal tornar el material al guia", "Que no es pot portar menjar"], "e": "Es referix als residus: no s'ha de deixar res a la muntanya."}
        ]
      }
    ]
  },
  {
    "id": "46c7518c-aba7-466e-8d0b-92c0672db0bd", "category": "comprensio_oral", "type": "b1_co_mitjans", "sort_order": 3,
    "title": "Ràdio i televisió", "name": "Notícies i entrevistes",
    "content": "Entén la informació principal i els detalls de notícies i entrevistes sobre temes coneguts.", "icon": "📺", "color": "#FFCDD2",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "Informatiu migdia", "lines": [
          {"speaker": "Presentadora", "voice": "gina", "text": "Bon dia. Comencem l'informatiu amb una bona notícia per als veïns de la Safor: a partir del pròxim dilluns, el tren de rodalia tornarà a unir Gandia i Oliva, després de més de cinquanta anys sense servici. Ens ho explica Pau Ferrer."},
          {"speaker": "Reporter", "voice": "lluc", "text": "Sí, així és. Hi haurà un tren cada mitja hora en les hores de més passatgers, i cada hora la resta del dia. El trajecte durarà només quinze minuts, i amb el mateix bitllet es podrà continuar fins a València. Els veïns ho demanaven des de feia anys, sobretot els estudiants que van cada dia a la universitat. Això sí, les obres d'una de les estacions encara no han acabat, i durant el primer mes els trens no pararan a Bellreguard."},
          {"speaker": "Presentadora", "voice": "gina", "text": "Gràcies, Pau. I canviem de tema: la Fira del Llibre de València arriba enguany als jardins de Vivers amb una novetat: per primera vegada, hi haurà un espai dedicat al còmic i a la novel·la gràfica en valencià. La fira obri dijous i durarà onze dies."}
        ]},
        "exercises": [
          {"q": "Per què és notícia el tren entre Gandia i Oliva?", "o": ["Torna a funcionar després de més de cinquanta anys", "És el primer tren elèctric", "Serà gratuït"], "e": "«Tornarà a unir Gandia i Oliva, després de més de cinquanta anys sense servici.»"},
          {"q": "Amb quina freqüència passarà el tren en les hores de més passatgers?", "o": ["Cada mitja hora", "Cada hora", "Cada quinze minuts"], "e": "«Un tren cada mitja hora en les hores de més passatgers.»"},
          {"q": "Qui demanava especialment este servici?", "o": ["Els estudiants universitaris", "Els turistes", "Els comerciants"], "e": "«Sobretot els estudiants que van cada dia a la universitat.»"},
          {"q": "Què passarà a Bellreguard durant el primer mes?", "o": ["El tren no hi pararà", "Hi haurà autobusos gratuïts", "S'hi farà la inauguració"], "e": "Les obres de l'estació no han acabat i els trens no hi pararan."},
          {"q": "Quina és la novetat de la Fira del Llibre?", "o": ["Un espai per al còmic en valencià", "Un canvi d'ubicació", "Que durarà un mes"], "e": "«Per primera vegada, hi haurà un espai dedicat al còmic i a la novel·la gràfica en valencià.»"}
        ]
      },
      {
        "passage": {"media": "audio", "title": "Entrevista a la ràdio", "lines": [
          {"speaker": "Locutor", "voice": "lluc", "text": "Tenim amb nosaltres Laia Peris, que fa un any va obrir un restaurant a Vilafranca, el seu poble, de poc més de dos mil habitants. Laia, molta gent et va dir que estaves boja, no?"},
          {"speaker": "Laia", "voice": "gina", "text": "Sí, moltíssima! Jo treballava en un restaurant molt conegut de Barcelona i tenia un bon sou. Però em sentia buida: treballava catorze hores al dia i no veia mai la meua família. Un dia vaig pensar: si he de treballar tant, almenys que siga per a mi i al meu poble."},
          {"speaker": "Locutor", "voice": "lluc", "text": "I com ha anat este primer any?"},
          {"speaker": "Laia", "voice": "gina", "text": "Millor del que esperava, la veritat. L'hivern és dur, perquè ve poca gent, però a l'estiu i els caps de setmana està ple. Cuine amb productes de la comarca: la carn, la trufa, el formatge... i això la gent ho valora molt. El que més em va costar va ser trobar personal, perquè els joves se'n van a la ciutat."},
          {"speaker": "Locutor", "voice": "lluc", "text": "I quins són els teus plans de futur?"},
          {"speaker": "Laia", "voice": "gina", "text": "M'agradaria obrir una escola de cuina per a joves de la zona. Si aprenen un ofici ací, potser no hauran d'anar-se'n. Eixe és el meu somni."}
        ]},
        "exercises": [
          {"q": "Per què va deixar Laia la faena a Barcelona?", "o": ["Treballava massa i no veia la família", "La van acomiadar", "Guanyava poc"], "e": "«Treballava catorze hores al dia i no veia mai la meua família.»"},
          {"q": "Com valora Laia el primer any del restaurant?", "o": ["Ha anat millor del que esperava", "Ha sigut un fracàs", "Encara és massa prompte per a dir-ho"], "e": "«Millor del que esperava, la veritat.»"},
          {"q": "Quina dificultat té el restaurant a l'hivern?", "o": ["Hi va poca gent", "No troba productes", "Fa massa fred a la cuina"], "e": "«L'hivern és dur, perquè ve poca gent.»"},
          {"q": "Què va ser el més difícil per a Laia?", "o": ["Trobar treballadors", "Trobar un local", "Aconseguir diners"], "e": "«El que més em va costar va ser trobar personal.»"},
          {"q": "Quin és el somni de Laia?", "o": ["Obrir una escola de cuina per a joves", "Tornar a Barcelona", "Obrir un altre restaurant a València"], "e": "Vol que els joves aprenguen un ofici i no hagen d'anar-se'n del poble."},
          {"q": "Quin to té Laia en l'entrevista?", "o": ["Il·lusionat i realista", "Trist i penedit", "Enfadat i crític"], "e": "Parla amb entusiasme, però reconeix les dificultats."}
        ]
      }
    ]
  },
  {
    "id": "50ad252e-690d-4e8b-9b95-4d2dceba5da7", "category": "comprensio_oral", "type": "b1_co_ficcio", "sort_order": 4,
    "title": "Sèries i pel·lícules", "name": "Escenes de ficció",
    "content": "Seguix una escena de ficció sobre un assumpte quotidià i entén-ne els sentiments, les intencions i el que no es diu directament.", "icon": "🎬", "color": "#D1C4E9",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "Escena: la notícia", "lines": [
          {"speaker": "Mare", "voice": "gina", "text": "Xavi, fill, quina cara fas! Que t'ha passat alguna cosa a la faena?"},
          {"speaker": "Xavi", "voice": "lluc", "text": "No, no, al contrari. És que... bé, no sé com dir-t'ho. M'han oferit una faena a Berlín. Un contracte de dos anys, en una empresa d'energies renovables."},
          {"speaker": "Mare", "voice": "gina", "text": "A Berlín? Però si tu no saps alemany! I amb el fred que fa allà..."},
          {"speaker": "Xavi", "voice": "lluc", "text": "Mama, a l'empresa tots parlen anglés. I el fred no em matarà, tranquil·la. És una oportunitat que no tornaré a tindre: ací fa tres anys que estic amb contractes de sis mesos."},
          {"speaker": "Mare", "voice": "gina", "text": "Ja ho sé, ja ho sé... I ja els has dit que sí?"},
          {"speaker": "Xavi", "voice": "lluc", "text": "Encara no. Tinc fins dilluns per a contestar. Volia parlar-ne primer amb tu i amb el papa."},
          {"speaker": "Mare", "voice": "gina", "text": "Mira, fill, a mi em fa molta pena que te'n vages tan lluny, no t'ho negaré. Però si és el que vols, ves-hi. Nosaltres t'esperarem ací. Això sí: m'hauràs de telefonar cada diumenge."},
          {"speaker": "Xavi", "voice": "lluc", "text": "Cada diumenge, t'ho promet. I per Nadal, a casa, a menjar els teus canelons."}
        ]},
        "exercises": [
          {"q": "Com està Xavi al principi de l'escena?", "o": ["Nerviós, perquè no sap com donar la notícia", "Trist, perquè l'han acomiadat", "Enfadat amb sa mare"], "e": "«No sé com dir-t'ho»: té una bona notícia, però li costa explicar-la."},
          {"q": "Quina és la primera reacció de la mare?", "o": ["Posa objeccions", "S'alegra molt", "No diu res"], "e": "Pensa en l'idioma i en el fred: busca problemes perquè no vol que se'n vaja."},
          {"q": "Per què és important per a Xavi esta oferta?", "o": ["Fa anys que només té contractes curts", "Guanyarà el doble", "Vol aprendre alemany"], "e": "«Fa tres anys que estic amb contractes de sis mesos.»"},
          {"q": "Per què no ha acceptat encara l'oferta?", "o": ["Volia parlar-ne abans amb els pares", "No està segur de voler-hi anar", "L'empresa no li ha confirmat"], "e": "«Volia parlar-ne primer amb tu i amb el papa.»"},
          {"q": "Què sent finalment la mare?", "o": ["Pena, però li dona suport", "Alegria, perquè el fill se'n va", "Enuig, i no accepta la decisió"], "e": "«Em fa molta pena que te'n vages tan lluny... Però si és el que vols, ves-hi.»"},
          {"q": "Què li demana la mare a canvi?", "o": ["Que la telefone cada diumenge", "Que torne cada mes", "Que aprenga alemany"], "e": "«M'hauràs de telefonar cada diumenge.»"}
        ]
      }
    ]
  },
  {
    "id": "bf054f68-7a1a-4fe4-b8fe-6037c8b71802", "category": "comprensio_oral", "type": "b1_co_debat", "sort_order": 5,
    "title": "Debats i opinions", "name": "Tertúlia sobre el teletreball",
    "content": "Identifica les opinions, els arguments i els punts d'acord d'una discussió sobre un tema general.", "icon": "💬", "color": "#C8E6C9",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "Teletreball: sí o no?", "lines": [
          {"speaker": "Clara", "voice": "gina", "text": "Hui parlem del teletreball. Toni, la teua empresa ha decidit que tots han de tornar a l'oficina cinc dies a la setmana. Tu hi estàs d'acord?"},
          {"speaker": "Toni", "voice": "lluc", "text": "En part, sí. Jo vaig teletreballar dos anys i al final em sentia molt aïllat. Les idees, els problemes, les solucions... moltes vegades ixen d'una conversa al passadís o a l'hora del café. Per videoconferència això no passa."},
          {"speaker": "Clara", "voice": "gina", "text": "Ja, però jo pense que el problema no és el teletreball, sinó com l'organitzem. Jo treballe tres dies a casa i dos a l'oficina, i és el millor dels dos mons: els dies a casa em concentre més i m'estalvie dues hores de cotxe."},
          {"speaker": "Toni", "voice": "lluc", "text": "És veritat que el temps de desplaçament és un argument molt fort. I també ho és per al medi ambient: menys cotxes, menys contaminació."},
          {"speaker": "Clara", "voice": "gina", "text": "I per als pobles! Hi ha gent que ha tornat a viure al seu poble perquè pot treballar a distància."},
          {"speaker": "Toni", "voice": "lluc", "text": "D'acord, però no tots els treballs ho permeten, i no tothom té un espai a casa per a treballar bé. Jo, amb dos xiquets xicotets, no podia ni fer una telefonada tranquil·la. Per això crec que l'empresa hauria de deixar triar cada treballador."},
          {"speaker": "Clara", "voice": "gina", "text": "Mira, en això estem completament d'acord: el que no té sentit és imposar el mateix model a tothom."}
        ]},
        "exercises": [
          {"q": "Quina decisió ha pres l'empresa de Toni?", "o": ["Tornar a l'oficina tots els dies", "Teletreballar tres dies", "Deixar triar els treballadors"], "e": "«Tots han de tornar a l'oficina cinc dies a la setmana.»"},
          {"q": "Què va trobar a faltar Toni quan teletreballava?", "o": ["El contacte amb els companys", "Un ordinador millor", "Més temps lliure"], "e": "«Em sentia molt aïllat»: les idees ixen de les converses informals."},
          {"q": "Quin model de treball té Clara?", "o": ["Mixt: tres dies a casa i dos a l'oficina", "Tots els dies a casa", "Tots els dies a l'oficina"], "e": "«Tres dies a casa i dos a l'oficina.»"},
          {"q": "Quin argument a favor del teletreball NO apareix?", "o": ["Que es guanyen més diners", "Que es contamina menys", "Que afavorix la vida als pobles"], "e": "Parlen del temps, la contaminació i els pobles, però no del sou."},
          {"q": "Per què a Toni li costava teletreballar?", "o": ["Tenia xiquets xicotets a casa", "Vivia en un poble sense internet", "No sabia usar l'ordinador"], "e": "«Amb dos xiquets xicotets, no podia ni fer una telefonada tranquil·la.»"},
          {"q": "En què estan d'acord al final?", "o": ["Que no s'ha d'imposar el mateix model a tothom", "Que el teletreball és la millor opció", "Que cal tornar a l'oficina"], "e": "«El que no té sentit és imposar el mateix model a tothom.»"}
        ]
      }
    ]
  },
  {
    "id": "d79df22c-2b07-44cc-b108-6904098eb4fa", "category": "comprensio_oral", "type": "b1_co_xarrada", "sort_order": 6,
    "title": "Xarrades i explicacions", "name": "Una xarrada sobre el malbaratament d'aliments",
    "content": "Seguix una explicació estructurada sobre un tema general i n'identifica les idees principals.", "icon": "🎙️", "color": "#FFF9C4",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "No llancem el menjar", "lines": [
          {"speaker": "Ponent", "voice": "gina", "text": "Bona vesprada i gràcies per vindre. Hui vull parlar-vos d'un problema que tenim tots a casa, encara que no ens n'adonem: el malbaratament d'aliments. Segons les dades europees, cada persona llança a la brossa uns setanta quilos de menjar a l'any. I més de la meitat d'este menjar es perd a les cases, no als supermercats ni als restaurants."},
          {"speaker": "Ponent", "voice": "gina", "text": "Per què passa això? Principalment per tres raons. La primera, comprem més del que necessitem, sobretot quan anem a comprar amb fam o sense una llista. La segona, no entenem bé les etiquetes: «consumir preferentment abans de» no vol dir que l'aliment siga perillós després d'eixa data, només que pot perdre una mica de qualitat. En canvi, la «data de caducitat» sí que s'ha de respectar. I la tercera, no sabem aprofitar les sobres."},
          {"speaker": "Ponent", "voice": "gina", "text": "Què podem fer? Us propose tres hàbits senzills. Primer, planificar els menús de la setmana i fer la llista abans d'eixir de casa. Segon, a la nevera, posar davant el que s'ha de menjar abans. I tercer, cuinar amb les sobres: la nostra cuina tradicional ja ho feia, pensem en l'arròs al forn, que naix per a aprofitar el que sobrava del putxero. Les nostres àvies no llançaven res, i tenien raó."}
        ]},
        "exercises": [
          {"q": "On es perd la major part del menjar que es llança?", "o": ["A les cases", "Als supermercats", "Als restaurants"], "e": "«Més de la meitat d'este menjar es perd a les cases.»"},
          {"q": "Quina és una de les causes del malbaratament, segons la ponent?", "o": ["Anar a comprar amb fam o sense llista", "Els preus massa alts", "La falta de neveres"], "e": "Primera raó: comprem més del que necessitem."},
          {"q": "Què indica «consumir preferentment abans de»?", "o": ["Que després l'aliment pot perdre qualitat, però no és perillós", "Que després de la data és perillós", "Que s'ha de congelar"], "e": "La ponent ho distingix de la data de caducitat, que sí que s'ha de respectar."},
          {"q": "Quin consell dona per a la nevera?", "o": ["Posar davant el que s'ha de menjar abans", "Tindre-la sempre plena", "Guardar-hi el pa"], "e": "Segon hàbit: «a la nevera, posar davant el que s'ha de menjar abans»."},
          {"q": "Per què parla de l'arròs al forn?", "o": ["Com a exemple de plat que aprofita les sobres", "Perquè és el plat que més es llança", "Perquè és el seu plat preferit"], "e": "«Naix per a aprofitar el que sobrava del putxero.»"},
          {"q": "Com està organitzada la xarrada?", "o": ["Presenta el problema, les causes i les solucions", "Conta la història de la cuina valenciana", "Compara països europeus"], "e": "Primer el problema i les dades, després tres causes i, finalment, tres hàbits."}
        ]
      }
    ]
  },
  {
    "id": "33ce6509-4f9a-424e-b8e2-e76aea116c03", "category": "comprensio_escrita", "type": "b1_ce_correspondencia", "sort_order": 1,
    "title": "Correspondència personal", "name": "Correus i cartes d'amistats",
    "content": "Comprén la descripció de fets, sentiments i desitjos en escrits personals.", "icon": "✉️", "color": "#F8BBD0",
    "blocks": [
      {
        "passage": {"media": "text", "title": "Correu des de Bolonya", "lines": [
          {"text": "Estimada Carla:"},
          {"text": "Perdona que no t'haja escrit abans, però estos dos primers mesos han sigut un remolí. Com saps, vaig arribar a Bolonya a mitjan setembre amb la beca Erasmus i, al principi, ho vaig passar bastant malament: no entenia res a classe, el pis que havia llogat per internet era molt més xicotet que en les fotos i trobava a faltar la família i, sobretot, a vosaltres."},
          {"text": "Ara, però, les coses han canviat molt. M'he mudat a un pis amb dues xiques italianes i un xic portugués, i ens hem fet molt amics. Ells m'ajuden amb l'italià i jo els ensenye a fer paella (de moment, no els ix massa bé, però s'hi esforcen!). A la universitat ja seguisc les classes sense problemes, i una professora m'ha proposat col·laborar en un projecte de recerca sobre arquitectura medieval. Encara no m'ho crec!"},
          {"text": "L'únic que no em convenç és el temps: ací fa una humitat que et cala els ossos i fa setmanes que no veig el sol. Quina enveja em feu amb les vostres fotos a la platja!"},
          {"text": "Per cert, per què no véns a visitar-me al desembre? El vol des de València no és car si el compres amb temps, i podríem anar a Florència un cap de setmana. Pensa-t'ho i digues-me alguna cosa."},
          {"text": "Una abraçada molt forta,\nIrene"}
        ]},
        "exercises": [
          {"q": "Per què no havia escrit abans Irene?", "o": ["Ha tingut uns mesos molt intensos", "Estava enfadada amb Carla", "No tenia internet"], "e": "«Estos dos primers mesos han sigut un remolí.»"},
          {"q": "Com se sentia Irene al principi de l'estada?", "o": ["Desorientada i trista", "Molt contenta", "Avorrida"], "e": "No entenia les classes, el pis la va decebre i trobava a faltar la gent."},
          {"q": "Què va canviar la situació d'Irene?", "o": ["Mudar-se a un pis amb nous companys", "Tornar a València", "Canviar d'universitat"], "e": "«M'he mudat a un pis amb dues xiques italianes i un xic portugués, i ens hem fet molt amics.»"},
          {"q": "Què vol dir «Encara no m'ho crec!» en el text?", "o": ["Que està sorpresa i contenta per la proposta", "Que no confia en la professora", "Que pensa que és una broma"], "e": "Expressa sorpresa i alegria per la proposta de recerca."},
          {"q": "Què és el que menys li agrada de Bolonya?", "o": ["El temps", "El menjar", "La universitat"], "e": "«L'únic que no em convenç és el temps.»"},
          {"q": "Què li proposa a Carla?", "o": ["Que la visite al desembre", "Que faça també l'Erasmus", "Que li envie fotos de la platja"], "e": "«Per què no véns a visitar-me al desembre?»"}
        ]
      }
    ]
  },
  {
    "id": "7d4b9934-691d-4c9e-bfc4-e19cb230acc7", "category": "comprensio_escrita", "type": "b1_ce_documents", "sort_order": 2,
    "title": "Documents i fullets", "name": "Avisos oficials, ajudes i cursos",
    "content": "Localitza i entén informació rellevant en documents oficials curts, cartes i fullets.", "icon": "🏛️", "color": "#CFD8DC",
    "blocks": [
      {
        "passage": {"media": "text", "title": "Ajuntament de Vila-real · Ajudes per a la bicicleta elèctrica", "lines": [
          {"text": "L'Ajuntament de Vila-real convoca ajudes per a la compra de bicicletes elèctriques amb l'objectiu de fomentar una mobilitat més sostenible."},
          {"text": "Qui pot sol·licitar-les? Les persones majors de 16 anys empadronades a Vila-real almenys des de fa un any. Només es concedirà una ajuda per persona."},
          {"text": "Quantia: el 40 % del preu de la bicicleta, amb un màxim de 400 €. Les persones en situació d'atur o amb una discapacitat igual o superior al 33 % rebran el 60 %, amb un màxim de 600 €."},
          {"text": "Documentació: còpia del DNI, factura de compra a nom de la persona sol·licitant i amb data posterior a l'1 de gener, i número de compte bancari."},
          {"text": "Termini: del 3 al 28 de febrer, o fins que s'esgote el pressupost. Les sol·licituds s'atendran per ordre de presentació, a través de la seu electrònica o en l'oficina de l'Ajuntament (planta baixa), de 9 a 14 h."}
        ]},
        "exercises": [
          {"q": "Quin és l'objectiu d'estes ajudes?", "o": ["Fomentar una mobilitat més sostenible", "Ajudar les botigues de bicicletes", "Promoure l'esport entre els joves"], "e": "Primer paràgraf."},
          {"q": "Una xica de 17 anys que viu a Vila-real des de fa tres anys pot demanar-la?", "o": ["Sí, complix els requisits", "No, ha de ser major d'edat", "No, ha de portar cinc anys empadronada"], "e": "Majors de 16 anys empadronats almenys des de fa un any."},
          {"q": "Una persona en atur compra una bicicleta de 1.200 €. Quant rebrà?", "o": ["600 €", "480 €", "720 €"], "e": "El 60 % serien 720 €, però el màxim és de 600 €."},
          {"q": "Quina factura NO servix?", "o": ["Una factura del mes de desembre anterior", "Una factura de febrer a nom propi", "Una factura de gener a nom propi"], "e": "La data ha de ser posterior a l'1 de gener."},
          {"q": "Què vol dir que les sol·licituds s'atendran «per ordre de presentació»?", "o": ["Que qui la presente abans té més opcions d'aconseguir-la", "Que s'ha de fer una presentació oral", "Que es fa un sorteig"], "e": "El pressupost es pot esgotar: les primeres sol·licituds s'atenen primer."}
        ]
      },
      {
        "passage": {"media": "text", "title": "Universitat Popular · Cursos de tardor", "lines": [
          {"text": "FOTOGRAFIA AMB EL MÒBIL · Dimarts, de 18 a 20 h · 8 sessions · 35 €. No cal cap coneixement previ. Cal portar el mòbil carregat."},
          {"text": "CUINA DE TEMPORADA · Dijous, de 19 a 21.30 h · 6 sessions · 60 € (ingredients inclosos). Places limitades: 12 persones."},
          {"text": "IOGA PER A TOTES LES EDATS · Dilluns i dimecres, de 10 a 11 h · Tot el trimestre · 45 €. Cal portar estoreta."},
          {"text": "VALENCIÀ PER A LA VIDA QUOTIDIANA · Dimarts i dijous, de 20 a 21.30 h · Tot el trimestre · Gratuït. Prepara per al nivell B1 de la JQCV."},
          {"text": "Inscripcions a partir del 15 de setembre a l'oficina de la Universitat Popular o a la web. Les persones jubilades i els estudiants tenen un 20 % de descompte en tots els cursos de pagament."}
        ]},
        "exercises": [
          {"q": "Treballes de dilluns a divendres de 9 a 17 h. Quin curs NO pots fer?", "o": ["Ioga per a totes les edats", "Fotografia amb el mòbil", "Cuina de temporada"], "e": "El ioga és de 10 a 11 h del matí."},
          {"q": "Quin curs inclou el material en el preu?", "o": ["Cuina de temporada", "Fotografia amb el mòbil", "Ioga per a totes les edats"], "e": "«60 € (ingredients inclosos).»"},
          {"q": "Quant pagarà una persona jubilada pel curs de fotografia?", "o": ["28 €", "35 €", "15 €"], "e": "35 € amb un 20 % de descompte: 28 €."},
          {"q": "Quin curs coincidix en dia amb el de fotografia, però no en hora?", "o": ["Valencià per a la vida quotidiana", "Cuina de temporada", "Ioga"], "e": "Tots dos són dimarts: fotografia de 18 a 20 h i valencià de 20 a 21.30 h."}
        ]
      }
    ]
  },
  {
    "id": "6066bf0f-2d3e-4541-b4cb-c032d7ebd5f7", "category": "comprensio_escrita", "type": "b1_ce_instruccions", "sort_order": 3,
    "title": "Instruccions", "name": "Com arribar a un lloc i com usar un aparell",
    "content": "Comprén textos instructius clars: indicacions per a arribar a un lloc i instruccions d'ús d'aparells.", "icon": "🧭", "color": "#FFE0B2",
    "blocks": [
      {
        "passage": {"media": "text", "title": "Com arribar a la casa rural Mas de la Font", "lines": [
          {"text": "Des de València, agafeu l'autovia A-23 en direcció a Terol i eixiu a l'eixida 33, Sogorb-Altura. A la rotonda, preneu la tercera eixida, en direcció a Altura."},
          {"text": "Travesseu el poble per l'avinguda principal i, just després de la gasolinera, gireu a la dreta, cap a l'ermita de la Cova Santa. Seguiu esta carretera uns sis quilòmetres. És estreta i té moltes corbes: aneu a poc a poc."},
          {"text": "Quan passeu un pont de pedra, a l'esquerra veureu un camí de terra amb un rètol de fusta que diu «Mas de la Font». La casa és a uns 800 metres. Si arribeu a l'ermita, és que us l'heu passat: torneu arrere dos quilòmetres."},
          {"text": "Atenció: en este tram no hi ha cobertura de mòbil. Si arribeu després de les vuit de la vesprada, aviseu-nos abans d'eixir d'Altura i deixarem el llum de la porta encés."}
        ]},
        "exercises": [
          {"q": "Què cal fer a la rotonda de l'eixida 33?", "o": ["Prendre la tercera eixida", "Girar a la dreta cap a l'ermita", "Seguir recte fins a Terol"], "e": "«A la rotonda, preneu la tercera eixida, en direcció a Altura.»"},
          {"q": "On cal girar per a anar cap a la Cova Santa?", "o": ["Després de la gasolinera", "Abans d'entrar al poble", "Al pont de pedra"], "e": "«Just després de la gasolinera, gireu a la dreta.»"},
          {"q": "Per què recomanen conduir a poc a poc?", "o": ["La carretera és estreta i té moltes corbes", "Hi ha radars", "Hi ha animals"], "e": "«És estreta i té moltes corbes: aneu a poc a poc.»"},
          {"q": "Què vol dir si arribes a l'ermita?", "o": ["Que t'has passat el desviament", "Que ja hi has arribat", "Que has d'aparcar allí"], "e": "«Si arribeu a l'ermita, és que us l'heu passat.»"},
          {"q": "Per què demanen que avises abans d'eixir d'Altura si arribes tard?", "o": ["Perquè després no tindràs cobertura", "Perquè tanquen la carretera", "Perquè has de pagar abans"], "e": "En l'últim tram no hi ha cobertura de mòbil."}
        ]
      },
      {
        "passage": {"media": "text", "title": "Cafetera de càpsules · Guia ràpida", "lines": [
          {"text": "Primer ús: abans de fer el primer café, ompliu el dipòsit d'aigua i feu passar l'aigua dues vegades sense càpsula, per a netejar els conductes."},
          {"text": "Preparar un café: premeu el botó d'encesa i espereu que la llum deixe de parpellejar (uns 25 segons). Alceu la palanca, introduïu la càpsula i tanqueu. Premeu el botó xicotet per a un expresso (40 ml) o el gran per a un café llarg (110 ml)."},
          {"text": "Manteniment: buideu el recipient de càpsules usades i el dipòsit cada dia. Una vegada cada tres mesos, o quan la llum taronja s'encenga, feu el procés de descalcificació (vegeu la pàgina 12)."},
          {"text": "Problemes freqüents: si no ix café, comproveu que el dipòsit té aigua i que la càpsula està ben col·locada. Si la llum roja parpelleja, desconnecteu l'aparell, espereu deu minuts i torneu-lo a connectar. Si el problema continua, telefoneu al servici tècnic."}
        ]},
        "exercises": [
          {"q": "Què cal fer abans del primer café?", "o": ["Fer passar l'aigua dues vegades sense càpsula", "Descalcificar la cafetera", "Telefonar al servici tècnic"], "e": "«Feu passar l'aigua dues vegades sense càpsula.»"},
          {"q": "Com saps que la cafetera ja està preparada?", "o": ["La llum deixa de parpellejar", "La llum es posa roja", "Fa un soroll"], "e": "«Espereu que la llum deixe de parpellejar.»"},
          {"q": "Vols un café llarg. Quin botó prems?", "o": ["El gran", "El xicotet", "El d'encesa dues vegades"], "e": "«El gran per a un café llarg (110 ml).»"},
          {"q": "Què indica la llum taronja?", "o": ["Que cal descalcificar", "Que no hi ha aigua", "Que la cafetera està avariada"], "e": "«Quan la llum taronja s'encenga, feu el procés de descalcificació.»"},
          {"q": "Què has de fer primer si la llum roja parpelleja?", "o": ["Desconnectar-la i esperar deu minuts", "Telefonar al servici tècnic", "Canviar la càpsula"], "e": "Només si el problema continua cal telefonar al servici tècnic."}
        ]
      }
    ]
  },
  {
    "id": "64ba127c-f96e-49fa-9b46-71d10ec98122", "category": "comprensio_escrita", "type": "b1_ce_premsa", "sort_order": 4,
    "title": "Premsa", "name": "Notícies i reportatges",
    "content": "Reconeix els punts essencials d'articles de premsa sobre temes coneguts.", "icon": "📰", "color": "#B3E5FC",
    "blocks": [
      {
        "passage": {"media": "text", "title": "La llúdriga torna al riu Millars", "lines": [
          {"text": "Un equip de biòlegs de la Universitat Jaume I ha confirmat la presència de llúdrigues al tram baix del riu Millars, entre Almassora i Vila-real, quaranta anys després que hi desaparegueren."},
          {"text": "Les càmeres instal·lades a la ribera han gravat almenys tres exemplars, entre els quals una femella amb una cria, cosa que indica que l'espècie no només passa pel riu, sinó que s'hi reproduïx."},
          {"text": "Segons els investigadors, la tornada de la llúdriga és una bona notícia, perquè és un animal molt sensible a la contaminació: si viu en un riu, vol dir que l'aigua és de qualitat. Els experts l'atribuïxen a la millora de les depuradores i a la recuperació de la vegetació de la ribera durant l'última dècada."},
          {"text": "Tot i això, advertixen que l'espècie encara és fràgil. La sequera, que reduïx el cabal del riu, i els atropellaments en les carreteres pròximes són ara les principals amenaces. Per això demanen a les administracions que construïsquen passos per a la fauna i que garantisquen un cabal mínim tot l'any."}
        ]},
        "exercises": [
          {"q": "Quina és la notícia principal?", "o": ["La llúdriga ha tornat al riu Millars", "El riu Millars està més contaminat", "S'han construït noves depuradores"], "e": "El primer paràgraf resumix la notícia."},
          {"q": "Per què la femella amb una cria és un detall important?", "o": ["Indica que l'espècie s'hi reproduïx", "Demostra que l'animal és perillós", "Mostra que són animals domèstics"], "e": "«No només passa pel riu, sinó que s'hi reproduïx.»"},
          {"q": "Per què la presència de la llúdriga és una bona notícia per al riu?", "o": ["Indica que l'aigua és de qualitat", "Atrau turistes", "Elimina els peixos invasors"], "e": "És molt sensible a la contaminació."},
          {"q": "Quina és una de les amenaces actuals per a l'espècie?", "o": ["Els atropellaments", "Els caçadors", "Les depuradores"], "e": "La sequera i els atropellaments en les carreteres pròximes."},
          {"q": "Què demanen els experts?", "o": ["Passos per a la fauna i un cabal mínim tot l'any", "Tancar el riu al públic", "Portar més llúdrigues d'altres llocs"], "e": "Últim paràgraf."}
        ]
      },
      {
        "passage": {"media": "text", "title": "Teletreballar des del poble", "lines": [
          {"text": "Fa tres anys, l'escola de Vallat, a l'Alt Millars, estava a punt de tancar: només tenia quatre alumnes. Enguany en té onze. El motiu és l'arribada de diverses famílies joves que han deixat la ciutat i que treballen a distància."},
          {"text": "És el cas de Sílvia i Marc, dissenyadors gràfics, que es van mudar des de València amb els dos fills. «Ací tenim una qualitat de vida que a la ciutat no podíem pagar», explica Sílvia. «Una casa amb pati, aire net i temps per a nosaltres.»"},
          {"text": "No tot és fàcil, però. Els nouvinguts es queixen de la connexió a internet, que falla els dies de tempesta, i de la falta de servicis: el centre de salut més pròxim és a vint minuts i no hi ha cap botiga al poble."},
          {"text": "L'alcaldessa reconeix les dificultats, però es mostra optimista: l'ajuntament ha habilitat l'antiga casa del metge com a espai de treball compartit, amb fibra òptica, i negocia amb un forner de la comarca perquè obri un punt de venda dos dies a la setmana."}
        ]},
        "exercises": [
          {"q": "Quin és el tema principal del reportatge?", "o": ["L'arribada de famílies que teletreballen a un poble xicotet", "El tancament d'una escola rural", "Els problemes d'internet a les ciutats"], "e": "L'escola, l'exemple de Sílvia i Marc i les dificultats giren al voltant d'este fenomen."},
          {"q": "Per què es va salvar l'escola?", "o": ["Han arribat famílies joves amb fills", "L'ajuntament hi ha posat diners", "Han ajuntat dues escoles"], "e": "Ha passat de quatre a onze alumnes per l'arribada de famílies joves."},
          {"q": "Què valora més Sílvia de la vida al poble?", "o": ["La qualitat de vida", "Els servicis", "La connexió a internet"], "e": "«Una casa amb pati, aire net i temps per a nosaltres.»"},
          {"q": "De què es queixen els nouvinguts?", "o": ["De la connexió a internet i de la falta de servicis", "Dels veïns", "Del preu de les cases"], "e": "Tercer paràgraf."},
          {"q": "Quina actitud té l'alcaldessa?", "o": ["Reconeix els problemes, però és optimista", "Nega que hi haja problemes", "Pensa que el poble no té futur"], "e": "«Reconeix les dificultats, però es mostra optimista.»"}
        ]
      }
    ]
  },
  {
    "id": "2d7bde44-1444-45e9-9511-2b2388109b3d", "category": "comprensio_escrita", "type": "b1_ce_dialogats", "sort_order": 5,
    "title": "Textos dialogats", "name": "Entrevistes i converses escrites",
    "content": "Entén textos dialogats en un registre estàndard: entrevistes de revista i converses de missatgeria.", "icon": "🗨️", "color": "#DCEDC8",
    "blocks": [
      {
        "passage": {"media": "text", "title": "Entrevista a Maria, jugadora de pilota valenciana", "lines": [
          {"speaker": "Revista", "text": "Com vas començar a jugar a pilota?"},
          {"speaker": "Maria", "text": "Per casualitat. Al meu poble, Pedreguer, hi havia un trinquet al costat de l'escola i, a l'hora del pati, veia jugar els xics. Un dia em vaig atrevir a demanar-los si podia jugar, i des d'aleshores no ho he deixat."},
          {"speaker": "Revista", "text": "Fa uns anys, que una xica jugara a pilota era estrany. Ha canviat la situació?"},
          {"speaker": "Maria", "text": "Moltíssim. Quan vaig començar, érem quatre i no teníem lliga pròpia. Ara hi ha campionats femenins professionals i les partides es retransmeten per televisió. Tot i això, encara cobrem molt menys que els hòmens, i això cal canviar-ho."},
          {"speaker": "Revista", "text": "Què li diries a una xiqueta que vol jugar?"},
          {"speaker": "Maria", "text": "Que no tinga por del que diran. Que vaja al trinquet del seu poble, que demane una pilota i que s'ho passe bé. La pilota no és un esport de xics ni de xiques: és el nostre esport."}
        ]},
        "exercises": [
          {"q": "Com va descobrir Maria la pilota?", "o": ["Veient jugar uns xics a prop de l'escola", "Gràcies a son pare", "En una classe d'educació física"], "e": "Hi havia un trinquet al costat de l'escola i veia jugar els xics."},
          {"q": "Què ha millorat per a les jugadores?", "o": ["Hi ha campionats professionals i surten per televisió", "Cobren el mateix que els hòmens", "Hi ha més trinquets"], "e": "Ara hi ha campionats femenins professionals i retransmissions."},
          {"q": "Què critica Maria?", "o": ["La diferència de sou amb els hòmens", "Que hi haja massa jugadores", "Les retransmissions"], "e": "«Encara cobrem molt menys que els hòmens.»"},
          {"q": "Què vol dir «que no tinga por del que diran»?", "o": ["Que no es preocupe per l'opinió dels altres", "Que no parle amb ningú", "Que no tinga por de la pilota"], "e": "El que diran: les crítiques o els comentaris de la gent."}
        ]
      },
      {
        "passage": {"media": "text", "title": "Grup «Sopar de classe 2016»", "lines": [
          {"speaker": "Àlex", "text": "Bon dia, gent! Fa deu anys que vam acabar el batxillerat. Organitzem un sopar? 🎉"},
          {"speaker": "Lorena", "text": "Siii! Quina il·lusió! Jo proposaria el 15 de novembre, que és dissabte."},
          {"speaker": "Hèctor", "text": "Eixe cap de setmana no puc, que tinc les noces de mon germà 😅 El 22 em va millor."},
          {"speaker": "Lorena", "text": "Per mi el 22 també està bé. I on? El restaurant de la plaça encara existix?"},
          {"speaker": "Àlex", "text": "Sí, però han canviat d'amo i diuen que ha empitjorat molt. Jo preferiria anar a la Masia del Riu: és un poc més car, uns 30 € per persona, però té un saló per a nosaltres a soles."},
          {"speaker": "Hèctor", "text": "Doncs Masia del Riu, el 22. Algú té el número de la professora Elvira? Estaria bé convidar-la."},
          {"speaker": "Lorena", "text": "Jo el tinc! Li escric jo. Àlex, et pots encarregar tu de reservar?"},
          {"speaker": "Àlex", "text": "Fet. Però necessite saber quants serem abans del dia 10, que la masia ho demana. Contesteu ací, per favor 🙏"}
        ]},
        "exercises": [
          {"q": "Per què organitzen el sopar?", "o": ["Fa deu anys que van acabar el batxillerat", "És l'aniversari d'Àlex", "Es casa el germà d'Hèctor"], "e": "«Fa deu anys que vam acabar el batxillerat.»"},
          {"q": "Per què no fan el sopar el 15 de novembre?", "o": ["Hèctor té unes noces eixe dia", "El restaurant està tancat", "Lorena treballa"], "e": "«Tinc les noces de mon germà.»"},
          {"q": "Per què no van al restaurant de la plaça?", "o": ["Diuen que ha empitjorat", "Ha tancat", "És massa car"], "e": "«Han canviat d'amo i diuen que ha empitjorat molt.»"},
          {"q": "Quin avantatge té la Masia del Riu?", "o": ["Un saló només per al grup", "És més barata", "Està a la plaça"], "e": "«Té un saló per a nosaltres a soles.»"},
          {"q": "Qui s'encarregarà de convidar la professora?", "o": ["Lorena", "Àlex", "Hèctor"], "e": "«Jo el tinc! Li escric jo.»"},
          {"q": "Què han de fer tots abans del dia 10?", "o": ["Confirmar si hi aniran", "Pagar els 30 €", "Telefonar a la masia"], "e": "Àlex necessita saber quants seran per a la reserva."}
        ]
      }
    ]
  },
  {
    "id": "01fbd544-4486-47b1-9479-105532bbda76", "category": "comprensio_escrita", "type": "b1_ce_opinio", "sort_order": 6,
    "title": "Cartes al director", "name": "Opinions i queixes en la premsa",
    "content": "Identifica l'opinió, els arguments i les propostes d'una carta al director sobre un tema conegut.", "icon": "🖋️", "color": "#FFCCBC",
    "blocks": [
      {
        "passage": {"media": "text", "title": "Carta al director: «Volem dormir»", "lines": [
          {"text": "Visc des de fa vint anys al barri de Russafa, a València, i fins fa poc estava orgullós del meu barri: animat, divers, ple de vida. Ara, però, he de reconéixer que molts veïns estem farts."},
          {"text": "En els últims cinc anys, el nombre de bars i de terrasses s'ha triplicat. No tinc res en contra de l'oci: jo també isc a sopar i m'agrada prendre alguna cosa amb els amics. El problema és que moltes terrasses no respecten l'horari de tancament i que, a les dues de la matinada, el carrer continua ple de gent cridant. Els que hem de matinar per a anar a treballar no podem descansar."},
          {"text": "A més, els lloguers han pujat tant que moltes famílies se n'han hagut d'anar, i les botigues de tota la vida han deixat lloc a locals per a turistes."},
          {"text": "No demane que tanquen els bars, sinó que l'Ajuntament faça complir les normes: més controls de la policia local, limitar el nombre de terrasses per carrer i multar els locals que no respecten els horaris. Un barri viu ha de ser també un barri on es puga viure."},
          {"text": "Ernest Llopis (València)"}
        ]},
        "exercises": [
          {"q": "Quina és la queixa principal de l'autor?", "o": ["El soroll de les terrasses de nit", "La falta de bars", "La brutícia dels carrers"], "e": "Els veïns no poden descansar pel soroll a la matinada."},
          {"q": "Què pensa l'autor de l'oci nocturn en general?", "o": ["No hi està en contra", "Vol que es prohibisca", "No li interessa gens"], "e": "«No tinc res en contra de l'oci.»"},
          {"q": "Quin altre problema del barri esmenta?", "o": ["La pujada dels lloguers", "La falta de transport", "La inseguretat"], "e": "Moltes famílies se n'han hagut d'anar pels lloguers."},
          {"q": "Què demana a l'Ajuntament?", "o": ["Que faça complir les normes", "Que tanque tots els bars", "Que baixe els lloguers"], "e": "Més controls, limitar terrasses i multar qui no respecte els horaris."},
          {"q": "Què vol dir la frase final «Un barri viu ha de ser també un barri on es puga viure»?", "o": ["Que l'ambient no ha d'impedir la vida dels veïns", "Que el barri està mort", "Que cal construir més cases"], "e": "Joc de paraules entre «viu» (animat) i «viure» (residir-hi)."}
        ]
      }
    ]
  },
  {
    "id": "d31ebc48-6efd-4b24-9a3f-4a108d4c22d2", "category": "expressio_escrita", "type": "b1_ee_correus", "sort_order": 1,
    "title": "Cartes i correus personals", "name": "Escriure a amistats i familiars",
    "content": "Escriu cartes i correus informals per a contar novetats, expressar sentiments i fer propostes.", "icon": "💌", "color": "#F8BBD0",
    "exercises": [
      {"q": "Fa uns mesos que t'has mudat a una altra ciutat per motius de faena. Escriu un correu a un amic o una amiga: explica-li per què vas prendre la decisió, com és la teua nova vida, com et sents i què és el que més trobes a faltar.", "w": {"min_words": 100, "max_words": 120}},
      {"q": "Una amiga t'ha escrit que vindrà a la teua ciutat o al teu poble un cap de setmana. Contesta-li: dis-li que t'alegres, proposa-li un pla per a cada dia (llocs, menjar, activitats) i explica-li per què els has triat.", "w": {"min_words": 100, "max_words": 120}},
      {"q": "Ton cosí t'ha demanat consell: dubta entre estudiar a la seua ciutat o anar-se'n a estudiar fora. Escriu-li una carta en què li dones la teua opinió, li expliques una experiència teua o d'algú que conegues i li dones ànims.", "w": {"min_words": 100, "max_words": 120}}
    ]
  },
  {
    "id": "0eef01d0-169f-454f-8c46-3f44fe6f1cfa", "category": "expressio_escrita", "type": "b1_ee_narracio", "sort_order": 2,
    "title": "Narrar experiències", "name": "Viatges, anècdotes i històries",
    "content": "Narra per escrit un esdeveniment, un viatge real o imaginat o una història, amb els sentiments i les reaccions.", "icon": "🧳", "color": "#FFE0B2",
    "exercises": [
      {"q": "Conta un viatge que recordes especialment (real o imaginat): on vas anar i amb qui, què vau fer, quin imprevist va passar i com et vas sentir. Ordena el relat amb connectors temporals (primer, després, mentre, de sobte, al final...).", "w": {"min_words": 120, "max_words": 150}},
      {"q": "Escriu una història que comence així: «Aquell matí, quan vaig obrir la porta de casa, no m'ho podia creure...». Explica què va passar, com vas reaccionar i com va acabar.", "w": {"min_words": 120, "max_words": 150}},
      {"q": "Per a la revista del barri, escriu sobre una festa o una celebració que hages viscut (unes falles, unes festes del poble, unes noces...): quan i on va ser, què hi va passar i per què la recordes.", "w": {"min_words": 120, "max_words": 150}}
    ]
  },
  {
    "id": "cbda925f-bf51-4fa1-af69-54762a8abd30", "category": "expressio_escrita", "type": "b1_ee_descripcio", "sort_order": 3,
    "title": "Descriure persones i somnis", "name": "Persones reals i imaginàries",
    "content": "Escriu sobre tu mateix o sobre persones imaginàries: on viuen, què fan, com són i què desitgen.", "icon": "🧑‍🎨", "color": "#D1C4E9",
    "exercises": [
      {"q": "Escriu per al blog del curs un text sobre una persona que ha sigut important en la teua vida: qui és, com és físicament i de caràcter, què heu viscut junts i per què t'ha influït.", "w": {"min_words": 100, "max_words": 120}},
      {"q": "Inventa el personatge principal d'una novel·la: com es diu, on viu, a què es dedica, com és, quin problema té i quin és el seu somni.", "w": {"min_words": 100, "max_words": 120}},
      {"q": "Com t'imagines la teua vida d'ací a deu anys? Explica on t'agradaria viure, a què et voldries dedicar, quins projectes t'agradaria haver complit i què faràs per a aconseguir-ho.", "w": {"min_words": 100, "max_words": 120}}
    ]
  },
  {
    "id": "d8d8dd9a-44f3-4353-852b-2a86e022bbe7", "category": "expressio_escrita", "type": "b1_ee_formal", "sort_order": 4,
    "title": "Correus formals", "name": "Demanar informació, justificar-se i reclamar",
    "content": "Redacta textos breus en un format estàndard per a donar o demanar informació i explicar les raons d'una actuació.", "icon": "📧", "color": "#C5CAE9",
    "exercises": [
      {"q": "Has vist l'anunci d'un curs intensiu de valencià a l'estiu. Escriu un correu a l'escola per a demanar informació (horaris, preu, nivell, possibilitat de beca) i explica per què t'interessa fer-lo.", "w": {"min_words": 80, "max_words": 100}},
      {"q": "No vas poder anar a una reunió important de la faena o de l'associació de la qual formes part. Escriu un correu a la persona responsable: disculpa't, explica'n el motiu i proposa una solució per a recuperar la informació.", "w": {"min_words": 80, "max_words": 100}},
      {"q": "Has comprat una tauleta per internet i t'ha arribat amb la pantalla trencada i sense el carregador. Escriu una reclamació a la botiga: explica què vas comprar i quan, quins problemes té i què vols que facen.", "w": {"min_words": 100, "max_words": 120}}
    ]
  },
  {
    "id": "9f0a2ac5-b24c-4b61-aed6-0cacf079c5f3", "category": "expressio_escrita", "type": "b1_ee_parafrasi", "sort_order": 5,
    "title": "Parafrasejar", "name": "Explicar un text amb altres paraules",
    "content": "Reorganitza la informació d'un text escrit amb les paraules originals per a explicar-lo a una altra persona.", "icon": "🔁", "color": "#FFF9C4",
    "blocks": [
      {
        "passage": {"media": "text", "title": "Avís de la comunitat de propietaris", "lines": [
          {"text": "Es comunica a tots els veïns que, a causa de les obres de substitució de l'ascensor, este quedarà fora de servici des del dilluns 9 fins al divendres 20 de març, ambdós inclosos."},
          {"text": "Durant este període, l'empresa instal·ladora treballarà de 8 a 15 h. Es prega que no es deixen bicicletes ni cotxets en el vestíbul, ja que s'hi emmagatzemarà el material."},
          {"text": "Les persones amb mobilitat reduïda que necessiten ajuda per a pujar la compra poden posar-se en contacte amb l'administrador de finques, que coordinarà un servici d'ajuda amb els veïns voluntaris."},
          {"text": "La Junta de la Comunitat"}
        ]},
        "exercises": [
          {"q": "La teua veïna del cinqué, una senyora gran, no ha vist l'avís del portal. Escriu-li un missatge per a explicar-li amb les teues paraules què hi diu: què passarà, quan, què cal tindre en compte i com pot demanar ajuda. Pots reaprofitar paraules del text, però reorganitza-les i adapta el registre.", "w": {"min_words": 60, "max_words": 80}}
        ]
      },
      {
        "passage": {"media": "text", "title": "El Tribunal de les Aigües", "lines": [
          {"text": "Cada dijous a les dotze del migdia, davant de la porta dels Apòstols de la catedral de València, es reunix el Tribunal de les Aigües, la institució de justícia més antiga d'Europa que encara funciona. Està format per huit síndics, triats pels llauradors de cadascuna de les sèquies de l'horta."},
          {"text": "El Tribunal resol els conflictes sobre el reg entre els llauradors: per exemple, si algú ha agafat aigua quan no li tocava. Els judicis són orals, ràpids i en valencià, i les sentències no es poden recórrer. Des de 2009, el Tribunal forma part del Patrimoni Cultural Immaterial de la Humanitat de la UNESCO."}
        ]},
        "exercises": [
          {"q": "Un grup de xiquets de dotze anys visitarà la catedral dijous. Reescriu el text perquè l'entenguen: explica què és el Tribunal, qui el forma, què fa i per què és especial. Reorganitza la informació en un ordre que els resulte fàcil de seguir.", "w": {"min_words": 70, "max_words": 90}}
        ]
      }
    ]
  },
  {
    "id": "8bfc4765-b947-4bf8-bee7-74a1d0b34029", "category": "expressio_escrita", "type": "b1_ee_apunts", "sort_order": 6,
    "title": "Prendre apunts", "name": "Resumir una xarrada o una reunió",
    "content": "Pren nota dels punts clau d'una xarrada o d'una reunió sobre un tema general i transmet-los per escrit.", "icon": "🗒️", "color": "#DCEDC8",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "Xarrada: estalviar energia a casa", "lines": [
          {"speaker": "Ponent", "voice": "lluc", "text": "Bona vesprada. En esta xarrada us explicaré com podem estalviar energia a casa sense perdre comoditat. Començarem per la calefacció i l'aire condicionat, que són més de la meitat del consum d'una casa. A l'hivern, la temperatura ideal és de vint graus durant el dia; cada grau de més augmenta el consum un set per cent. A l'estiu, l'aire condicionat no hauria de baixar de vint-i-sis graus."},
          {"speaker": "Ponent", "voice": "lluc", "text": "En segon lloc, els electrodomèstics. Quan en compreu un, mireu l'etiqueta energètica: la lletra A és la més eficient. Poseu la rentadora i el rentaplats només quan estiguen plens, i millor amb programes de baixa temperatura. A més, molts aparells consumixen encara que estiguen apagats, en mode d'espera: una regleta amb interruptor us ajudarà a desconnectar-los tots alhora."},
          {"speaker": "Ponent", "voice": "lluc", "text": "I finalment, la llum. Canvieu les bombetes antigues per bombetes LED, que gasten fins a un huitanta per cent menys i duren molt més. I sobretot, aprofiteu la llum natural: obriu les persianes durant el dia. Amb estos gestos, una família pot estalviar uns tres-cents euros a l'any."}
        ]},
        "exercises": [
          {"q": "Escolta la xarrada i pren apunts dels punts clau. Després, a partir dels teus apunts, escriu un resum per a un company de classe que no hi va poder anar: els tres àmbits de què va parlar el ponent, els consells principals de cadascun i les dades més importants.", "w": {"min_words": 80, "max_words": 100}}
        ]
      },
      {
        "passage": {"media": "audio", "title": "Reunió del viatge de fi de curs", "lines": [
          {"speaker": "Directora", "voice": "gina", "text": "Bona vesprada a totes les famílies. Us hem convocat per a explicar-vos el viatge de fi de curs de sisé. Enguany anirem tres dies a Morella, del vint-i-dos al vint-i-quatre de maig. Eixirem dimecres a les huit del matí des de la porta de l'escola i tornarem divendres cap a les set de la vesprada."},
          {"speaker": "Directora", "voice": "gina", "text": "El preu total és de cent cinquanta euros, que inclou l'autobús, l'alberg, totes les menjades i les activitats: una visita guiada al castell, una ruta per a veure dinosaures fòssils i un taller d'astronomia. Podeu pagar-lo en dos terminis: setanta-cinc euros abans del quinze d'abril i la resta abans del deu de maig."},
          {"speaker": "Directora", "voice": "gina", "text": "És molt important que, abans del quinze d'abril, ens torneu també l'autorització firmada i la fitxa mèdica, sobretot si el xiquet o la xiqueta té alguna al·lèrgia o pren algun medicament. Els xiquets no poden portar mòbil; cada nit, els mestres penjaran fotos al blog de l'escola perquè pugueu veure com va."}
        ]},
        "exercises": [
          {"q": "Has anat a la reunió de l'escola de ta filla i la teua parella no hi ha pogut anar. Pren apunts mentre escoltes i, després, escriu-li un missatge amb tota la informació important: dates i horaris, preu i què inclou, terminis de pagament i què cal entregar.", "w": {"min_words": 80, "max_words": 100}}
        ]
      }
    ]
  },
  {
    "id": "4449a0b1-06db-4086-973c-923a787235bd", "category": "expressio_oral", "type": "b1_eo_experiencies", "sort_order": 1,
    "title": "Narrar experiències", "name": "Xarrar amb Laura, una vella amiga",
    "content": "Explica amb detall experiències, sentiments i reaccions, i reacciona al que et conten.", "icon": "🧑‍🤝‍🧑", "color": "#B2EBF2",
    "metadata": {
      "character": "Laura, una amiga de la infància", "voice": "gina",
      "initial_prompt": "No m'ho puc creure! Quant de temps sense veure'ns, almenys cinc anys! Conta'm, conta'm: què ha sigut de la teua vida en tot este temps?",
      "objectius": ["Explica els canvis més importants de la teua vida en els últims anys.", "Conta amb detall una experiència que t'haja marcat i com et vas sentir.", "Reacciona a les notícies de Laura (sorpresa, alegria, pena...) i fes-li preguntes.", "Parla d'un somni o d'un projecte que tens per al futur."],
      "prompt": "Ets Laura, una amiga de la infància de l'aprenent, que te l'has trobat per casualitat en una cafeteria després de cinc anys sense veure-vos. Ets alegre, curiosa i expressiva. Pregunta-li pels canvis en la seua vida (faena, estudis, on viu, família, parella) i demana-li que et conte amb detall alguna experiència important: un viatge, un canvi de faena, una cosa que li va anar molt bé o molt malament. Interessa't pels seus sentiments («I com et vas sentir?», «No tenies por?»). Conta també les teues notícies perquè hi haja de reaccionar: t'has separat de la teua parella, però estàs bé; has deixat la faena al banc per a obrir una floristeria; i ta mare ha estat malalta, però ja està millor. Al final, pregunta-li pels seus somnis i projectes, i proposa-li tornar a quedar."
    }
  },
  {
    "id": "43c957fe-5e9e-4bda-820f-bab3f500261e", "category": "expressio_oral", "type": "b1_eo_opinio", "sort_order": 2,
    "title": "Opinar i argumentar", "name": "Reunió de veïns amb Ferran",
    "content": "Dona la teua opinió sobre un tema general, justifica-la i reacciona als arguments de l'interlocutor.", "icon": "🗳️", "color": "#FFE0B2",
    "metadata": {
      "character": "Ferran, president de l'associació de veïns", "voice": "lluc",
      "initial_prompt": "Bona vesprada i gràcies per vindre. Com saps, l'Ajuntament vol convertir el solar del costat del mercat en un aparcament. Nosaltres hem de donar la nostra opinió. Tu què en penses?",
      "objectius": ["Dona la teua opinió sobre el projecte de l'aparcament i justifica-la.", "Respon als arguments contraris de Ferran.", "Proposa una alternativa per al solar i explica'n els avantatges.", "Arriba a un acord o resumix les dues postures."],
      "prompt": "Ets Ferran, president de l'associació de veïns d'un barri d'Alacant, un home d'uns seixanta anys, dialogant però amb opinions fermes. L'Ajuntament proposa fer un aparcament de dues plantes en el solar buit que hi ha al costat del mercat municipal. Tu estàs més aviat a favor, perquè els comerciants del mercat diuen que perden clients per falta d'aparcament i els veïns grans no poden carregar la compra molt de lluny. Demana a l'aprenent la seua opinió i que la justifique. Si està en contra, rebat-li els arguments amb respecte; si està a favor, planteja-li tu els inconvenients (més trànsit, més contaminació, el barri no té cap parc). Demana-li que propose una alternativa per al solar (un parc, un jardí, un espai per als joves, horts urbans...) i que n'explique els avantatges. Al final, intenteu arribar a un acord o resumiu les dues postures per a presentar-les a l'Ajuntament."
    }
  },
  {
    "id": "42e380d5-cd97-42b1-8521-bd8b24f99cb8", "category": "expressio_oral", "type": "b1_eo_imprevistos", "sort_order": 3,
    "title": "Resoldre imprevistos", "name": "Un problema a l'hotel amb Sergi",
    "content": "Fes front a una situació menys corrent: explica una dificultat, comprova i confirma informació i negocia una solució.", "icon": "🏨", "color": "#FFCDD2",
    "metadata": {
      "character": "Sergi, recepcionista d'un hotel de Dénia", "voice": "lluc",
      "initial_prompt": "Bona nit, l'Hotel Montgó li dona la benvinguda. Té reserva? Em pot dir el seu nom, per favor?",
      "objectius": ["Identifica't i explica que tens una reserva.", "Explica el problema amb detall i per què és una dificultat per a tu.", "Comprova i confirma les dades i les condicions que et proposen.", "Negocia una solució que et convinga i acomiada't."],
      "prompt": "Ets Sergi, recepcionista de l'Hotel Montgó de Dénia. Són les onze de la nit i l'aprenent arriba cansat per a fer el registre. Tracta'l de vosté, amb educació professional. Quan et done el nom, digues que no trobes la reserva; si insistix, la trobes, però per a la setmana que ve (un error de dates de la web), i l'hotel està ple esta nit. Demana-li que t'explique la situació i comprova les dades (nom, dates, número de reserva, correu de confirmació). Que t'explique per què és un problema (per exemple: és tard, ve amb maleta, demà té un compromís a Dénia). Oferix-li opcions amb detalls concrets perquè les haja de comprovar i confirmar: una habitació en un hotel germà a Xàbia, a quinze minuts, amb el taxi pagat; o un sofà llit en una suite familiar per 20 € més, que no és culpa seua. Deixa que negocie i accepta una solució raonable. Al final, confirma les condicions resumint-les i pregunta-li si necessita res més."
    }
  },
  {
    "id": "f0e4724a-a9cf-4f61-877e-e1af2c177f55", "category": "expressio_oral", "type": "b1_eo_mediacio", "sort_order": 4,
    "title": "Mediació", "name": "Ajudar Sofia amb una carta de l'Ajuntament",
    "content": "Explica a una altra persona, amb paraules senzilles, la informació d'un text que no entén.", "icon": "🤝", "color": "#D1C4E9",
    "metadata": {
      "character": "Sofia, veïna nouvinguda", "voice": "gina",
      "initial_prompt": "Hola! Perdona que et moleste... Fa poc que visc ací i m'ha arribat esta carta de l'Ajuntament, però hi ha coses que no les entenc. Te la llig i m'ajudes?",
      "objectius": ["Escolta el que diu la carta i explica a Sofia què és i per què l'ha rebuda.", "Explica-li amb paraules senzilles què ha de fer i fins quan.", "Aclarix el significat de les paraules que no entén.", "Dona-li algun consell pràctic i comprova que ho ha entés."],
      "prompt": "Ets Sofia, una dona d'uns trenta-cinc anys que va arribar de Romania fa uns mesos i viu a Torrent. Entens el valencià quotidià, però no el llenguatge administratiu. Has rebut una carta de l'Ajuntament i la llegiràs a trossos a l'aprenent perquè te l'explique. Contingut de la carta (llig-ne un fragment cada vegada, no tot de colp): «Benvolguda senyora: li comuniquem que el seu fill, Andrei, ha obtingut plaça a l'Escola Infantil Municipal El Molí per al curs vinent. Per a formalitzar la matrícula, haurà de presentar-se a la secretaria del centre entre el 15 i el 30 de juny, de 9 a 13 h, amb la documentació següent: llibre de família o document equivalent, cartilla de vacunació, certificat d'empadronament i justificant del pagament de la quota de matrícula (60 €). Si no formalitza la matrícula en el termini indicat, s'entendrà que renuncia a la plaça. Pot sol·licitar la bonificació de la quota si la renda familiar no supera l'import establit.» Pregunta per les paraules o expressions difícils (formalitzar, termini, s'entendrà que renuncia, empadronament, bonificació, quota) i demana que t'ho explique amb exemples. Mostra preocupació per si no tens algun document (no trobes la cartilla de vacunació) perquè t'aconselle. Al final, resumix tu el que has entés, amb algun error, perquè l'aprenent t'haja de corregir. Parla amb frases senzilles i algun error lleu propi d'una persona que aprén."
    }
  },
  {
    "id": "8d337d14-1bc7-49f9-919d-209a59f64514", "category": "expressio_oral", "type": "b1_eo_exposicio", "sort_order": 5,
    "title": "Exposició oral", "name": "Presentar un projecte davant de Mireia",
    "content": "Fes una exposició ben estructurada sobre un tema d'interés personal i respon a les preguntes.", "icon": "🎤", "color": "#C8E6C9",
    "metadata": {
      "character": "Mireia, tutora d'un programa d'emprenedoria", "voice": "gina",
      "initial_prompt": "Bon dia! Et donem la benvinguda a la selecció del programa Emprén Jove. Tens uns minuts per a presentar-nos el teu projecte o la teua idea: de què es tracta, per què l'has triada i com la faries realitat. Quan vulgues!",
      "objectius": ["Presenta el projecte o la idea i explica per què l'has triada.", "Explica com el duràs a terme: passos, recursos i temps.", "Explica'n els avantatges i reconeix alguna dificultat.", "Respon a les preguntes de Mireia i tanca l'exposició."],
      "prompt": "Ets Mireia, tutora d'un programa municipal que ajuda joves a posar en marxa projectes (un negoci, una associació, un projecte cultural o social). L'aprenent fa una exposició oral breu del seu projecte o idea; si no en té cap, ajuda'l a triar-ne un (una botiga de segona mà, una app per al poble, una escola de música, un hort comunitari...). Al principi, deixa'l parlar i fes només comentaris breus d'ànim. Després, fes-li preguntes, una o dues per torn, perquè complete l'exposició: per què l'ha triat, a qui va dirigit, quins passos seguirà, quants diners i quin temps necessita, què el fa diferent i quines dificultats preveu. Fes-li alguna pregunta que l'obligue a justificar o defendre la idea. Al final, valora l'exposició amb un comentari breu: un punt fort i un aspecte per millorar (estructura, connectors, claredat)."
    }
  }
  ]$data$;
  pautes text := E'\n\n' ||
    'Pautes: l''aprenent prepara el nivell B1 (intermedi) de la JQCV i practica l''expressió i interacció orals. Parla en valencià general (normativa de l''AVL), amb un registre natural i un vocabulari variat propi del B1: usa connectors (perquè, ja que, però, en canvi, a més, per tant), oracions subordinades i, de tant en tant, alguna frase feta freqüent, sempre de manera clara. ' ||
    'Fes torns breus (màxim 3-4 frases) amb una o dues preguntes per torn. Demana-li que done detalls i exemples, que expresse opinions i sentiments i que els justifique; si respon amb monosíl·labs o frases molt curtes, repregunta perquè s''allargue. ' ||
    'Mai no ixes del personatge ni fas lliçons de gramàtica: si l''aprenent s''equivoca o usa un castellanisme, reformula la frase correcta dins de la teua resposta amb naturalitat. Si et demana que repetisques o que parles més a poc a poc, fes-ho amb altres paraules. ' ||
    E'\nObjectius que ha de complir l''aprenent (guia la conversa perquè els complisca d''un en un, sense enumerar-los): ';
  r jsonb;
  b jsonb;
  e jsonb;
  m jsonb;
  rid uuid;
  pid uuid;
  ppos smallint;
  epos smallint;
BEGIN
  FOR r IN SELECT * FROM jsonb_array_elements(catalog) LOOP
    rid := (r->>'id')::uuid;
    -- Xats: el system_prompt és el del personatge, les pautes del B1 i els objectius.
    m := coalesce(r->'metadata', '{}');
    IF m ? 'prompt' THEN
      m := (m - 'prompt') || jsonb_build_object('system_prompt',
        (m->>'prompt') || pautes ||
        (SELECT string_agg(o, ' | ') FROM jsonb_array_elements_text(m->'objectius') AS o) ||
        ' Quan els haja complit tots, tanca la conversa amb naturalitat i acomiada''t.');
    END IF;

    INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
    VALUES (
      rid, r->>'name', r->>'type', r->>'category', r->>'content', 'intermedi', 15, (r->>'sort_order')::smallint,
      jsonb_build_object('icon', r->>'icon', 'color', r->>'color', 'section_name', r->>'title') || m
    )
    ON CONFLICT (id) DO UPDATE SET
      name = EXCLUDED.name,
      type = EXCLUDED.type,
      category = EXCLUDED.category,
      content = EXCLUDED.content,
      difficulty = EXCLUDED.difficulty,
      xp_earned = EXCLUDED.xp_earned,
      sort_order = EXCLUDED.sort_order,
      metadata = EXCLUDED.metadata;

    DELETE FROM public.practice_exercises WHERE resource_id = rid AND level = 'B1';
    DELETE FROM public.practice_passages WHERE resource_id = rid AND level = 'B1';

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
          rid, 'B1', ppos, b->'passage'->>'media', b->'passage'->>'title', b->'passage'->'lines',
          CASE WHEN b->'passage'->>'media' = 'audio' THEN format('/audio/practice/%s-b1-%s.wav', r->>'type', ppos) END
        )
        RETURNING id INTO pid;
      END IF;

      FOR e IN SELECT * FROM jsonb_array_elements(b->'exercises') LOOP
        epos := epos + 1;
        INSERT INTO public.practice_exercises (resource_id, level, position, passage_id, kind, prompt, options, answers, task, explanation)
        VALUES (
          rid, 'B1', epos, pid,
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
