-- Més exercicis A2 per als continguts de 4.2 Morfosintaxi (20260930110000 en
-- tenia 9-14 per contingut): s'afigen darrere dels que ja hi ha, a partir de la
-- posició `offset`, fins a 35 per contingut. Tornar a aplicar el fitxer no els
-- duplica: primer s'esborren les posicions > offset.

CREATE TEMP TABLE practice_more AS
SELECT * FROM jsonb_to_recordset($data$[
  {
    "id": "8e2976bb-d06b-4230-8887-fcf23f45bbdd", "offset": 10,
    "exercises": [
      {"q": "Quin és el femení de «professor»?", "o": ["professora", "professoressa", "professor"], "e": "Professor → professora: s'afig -a."},
      {"q": "Quin és el femení de «actor»?", "o": ["actriu", "actora", "actoressa"], "e": "Actor → actriu: és un femení irregular."},
      {"q": "Quin és el femení de «rei»?", "o": ["reina", "reia", "reïna"], "e": "Rei → reina."},
      {"q": "Quin és el femení de «nebot»?", "o": ["neboda", "nebota", "nebotessa"], "e": "Nebot → neboda: la -t final canvia a -d-."},
      {"q": "Quin és el femení de «amic»?", "o": ["amiga", "amica", "amiqua"], "e": "Amic → amiga: la -c final canvia a -g-."},
      {"q": "Quin és el femení de «llop»?", "o": ["lloba", "llopa", "llopessa"], "e": "Llop → lloba: la -p final canvia a -b-."},
      {"q": "Quin és el femení de l'adjectiu «nou»?", "o": ["nova", "noua", "nouva"], "e": "Nou → nova: la -u final canvia a -v-."},
      {"q": "Quin és el femení de «blanc»?", "o": ["blanca", "blanqua", "blanc"], "e": "Blanc → blanca."},
      {"q": "Quin és el femení de «home»?", "o": ["dona", "homa", "homessa"], "e": "Home i dona són paraules diferents per a cada sexe."},
      {"q": "Quin és el femení de «jove»?", "o": ["jove", "jova", "jovena"], "e": "Jove és invariable: un xic jove, una xica jove."},
      {"q": "Quin és el femení de «feliç»?", "o": ["feliç", "feliça", "felissa"], "e": "Feliç és invariable: un home feliç, una dona feliç."},
      {"q": "Quin és el plural de «casa»?", "o": ["cases", "casas", "casos"], "e": "Les paraules acabades en -a fan el plural en -es: cases."},
      {"q": "Quin és el plural de «platja»?", "o": ["platges", "platjes", "platjas"], "e": "Platja → platges: davant de e, tj canvia a tg."},
      {"q": "Quin és el plural de «amiga»?", "o": ["amigues", "amigas", "amiges"], "e": "Amiga → amigues: davant de e, g canvia a gu."},
      {"q": "Quin és el plural de «peix»?", "o": ["peixos", "peixs", "peixes"], "e": "Les paraules acabades en -x fan el plural en -os: peixos."},
      {"q": "Quin és el plural de «gos»?", "o": ["gossos", "gosos", "goss"], "e": "Gos → gossos: afig -os i la s passa a ss."},
      {"q": "Quin és el plural de «mà»?", "o": ["mans", "màs", "manes"], "e": "Mà → mans: recupera la n."},
      {"q": "Quin és el plural de «llapis»?", "o": ["llapis", "llapissos", "llapisos"], "e": "Llapis és invariable: un llapis, dos llapis."},
      {"q": "Quin és el plural de «francés»?", "o": ["francesos", "francéss", "franceses"], "e": "Francés → francesos (masculí plural)."},
      {"q": "Completa: Les meues germanes són molt ___.", "o": ["altes", "alts", "alta"], "e": "L'adjectiu concorda amb el nom: femení plural."},
      {"q": "Completa: M'he comprat uns pantalons ___.", "o": ["nous", "noves", "nou"], "e": "Pantalons és masculí plural: nous."},
      {"q": "Completa: La paella està molt ___.", "o": ["bona", "bo", "bones"], "e": "Paella és femení singular: bona."},
      {"q": "Escriu el plural de «taronja».", "a": ["taronges"], "e": "Taronja → taronges: davant de e, j canvia a g."},
      {"q": "Escriu el femení de «valencià».", "a": ["valenciana"], "e": "Valencià → valenciana: recupera la n i perd l'accent."},
      {"q": "Escriu el plural de «cançó».", "a": ["cançons"], "e": "Cançó → cançons: recupera la n i perd l'accent."}
    ]
  },
  {
    "id": "79dd1db4-40ff-4860-8f49-279ee059ab46", "offset": 9,
    "exercises": [
      {"q": "Completa: M'agraden molt ___ pomes.", "o": ["les", "els", "la"], "e": "Pomes és femení plural: les."},
      {"q": "Completa: ___ dimarts tinc classe d'anglés.", "o": ["El", "La", "Lo"], "e": "Els dies de la setmana són masculins: el dimarts."},
      {"q": "Completa: Tinc ___ amic a Londres.", "o": ["un", "una", "uns"], "e": "Amic és masculí singular: un."},
      {"q": "Completa: Hi ha ___ taronges a la taula.", "o": ["unes", "uns", "una"], "e": "Taronges és femení plural: unes."},
      {"q": "Completa (la jaqueta la portes tu posada i parles d'ella): ___ jaqueta és meua.", "o": ["Esta", "Eixa", "Aquella"], "e": "Prop de qui parla: esta."},
      {"q": "Completa (la cadira és al costat de qui t'escolta): Seu en ___ cadira.", "o": ["eixa", "esta", "aquella"], "e": "Prop de qui escolta: eixa."},
      {"q": "Completa (els núvols són molt lluny): Mira ___ núvols!", "o": ["aquells", "estos", "eixos"], "e": "Lluny de tots dos: aquells."},
      {"q": "Completa (les claus les té qui t'escolta): Dona'm ___ claus.", "o": ["eixes", "estes", "aquelles"], "e": "Prop de qui escolta: eixes."},
      {"q": "Completa: ___ any (l'any en què estem) vaig a Itàlia.", "o": ["Este", "Eixe", "Aquell"], "e": "El temps present s'expressa amb el demostratiu de proximitat: este any."},
      {"q": "Completa: Recordes ___ estiu de 2010? Va ser genial.", "o": ["aquell", "este", "eixe"], "e": "Un temps llunyà en el passat: aquell."},
      {"q": "Quina forma és correcta?", "o": ["estos xiquets", "estes xiquets", "este xiquets"], "e": "Masculí plural: estos."},
      {"q": "Quina forma és correcta?", "o": ["eixes cases", "eixos cases", "eixa cases"], "e": "Femení plural: eixes."},
      {"q": "Completa: Este és ___ cotxe.", "o": ["el meu", "la meua", "els meus"], "e": "Cotxe és masculí singular: el meu."},
      {"q": "Completa: ___ amigues són molt simpàtiques.", "o": ["Les teues", "Els teus", "La teua"], "e": "Amigues és femení plural: les teues."},
      {"q": "Completa: La Maria ve amb ___ germà.", "o": ["el seu", "la seua", "els seus"], "e": "El possessiu concorda amb la cosa posseïda (germà), no amb qui la posseïx: el seu."},
      {"q": "Completa: Nosaltres vivim amb ___ àvia.", "o": ["la nostra", "el nostre", "les nostres"], "e": "Àvia és femení singular: la nostra."},
      {"q": "Completa: On teniu ___ maletes?", "o": ["les vostres", "els vostres", "la vostra"], "e": "Maletes és femení plural: les vostres."},
      {"q": "Completa: Estos llibres són ___.", "o": ["meus", "meues", "meu"], "e": "Llibres és masculí plural: meus."},
      {"q": "Completa (la casa és de Joan): Aquella casa és ___.", "o": ["seua", "seu", "seues"], "e": "Casa és femení singular: seua."},
      {"q": "Completa amb la forma curta (la mare de qui parla): Visc amb ___ mare.", "o": ["ma", "mon", "mos"], "e": "Amb alguns noms de parentiu es pot usar la forma curta: ma mare (= la meua mare)."},
      {"q": "Completa amb la forma curta (el pare de qui parla): ___ pare és metge.", "o": ["Mon", "Ma", "Mos"], "e": "Mon pare (= el meu pare)."},
      {"q": "Quina frase és correcta?", "o": ["Els meus cosins viuen a Gandia.", "Els meues cosins viuen a Gandia.", "Les meus cosins viuen a Gandia."], "e": "Cosins és masculí plural: els meus."},
      {"q": "Escriu el possessiu (de mi, femení singular): Esta és la ___ bicicleta.", "a": ["meua", "meva"], "e": "La meua (o la meva) bicicleta."},
      {"q": "Escriu el demostratiu (lluny, femení singular): ___ casa del fons és molt gran.", "a": ["aquella"], "e": "Lluny de qui parla i de qui escolta: aquella."},
      {"q": "Escriu el demostratiu (prop de qui escolta, femení plural): ___ sabates que portes són molt boniques.", "a": ["eixes"], "e": "Prop de qui escolta: eixes."},
      {"q": "Escriu l'article: ___ xiquets juguen al parc.", "a": ["els"], "e": "Xiquets és masculí plural: els."}
    ]
  },
  {
    "id": "725395e1-be2e-47a3-89bb-432fc4f4a152", "offset": 11,
    "exercises": [
      {"q": "Completa: ___ som de València.", "o": ["Nosaltres", "Vosaltres", "Ells"], "e": "Som és la primera persona del plural: nosaltres."},
      {"q": "Completa: I ___, d'on sou?", "o": ["vosaltres", "nosaltres", "elles"], "e": "Sou és la segona persona del plural: vosaltres."},
      {"q": "Completa: Este regal és per a ___ (la persona que parla).", "o": ["mi", "jo", "me"], "e": "Darrere de preposició s'usa «mi»: per a mi."},
      {"q": "Completa: Com ___ dieu?", "o": ["vos", "nos", "es"], "e": "Segona persona del plural: vos dieu."},
      {"q": "Completa: Ells ___ diuen Pere i Joan.", "o": ["es", "els", "li"], "e": "Tercera persona del verb dir-se: es diuen."},
      {"q": "Completa: Nosaltres ___ alcem prompte.", "o": ["ens", "vos", "es"], "e": "Primera persona del plural: ens alcem."},
      {"q": "Completa: ___ agrada molt la música (a mi).", "o": ["M'", "Em", "Me"], "e": "Davant de vocal, em s'apostrofa: m'agrada."},
      {"q": "Completa: ___ agrada el futbol? (a tu)", "o": ["T'", "Et", "Te"], "e": "Davant de vocal, et s'apostrofa: t'agrada."},
      {"q": "Completa: A Joan ___ agrada el cine.", "o": ["li", "el", "la"], "e": "Complement indirecte de tercera persona singular: li."},
      {"q": "Completa: Als meus pares ___ agrada viatjar.", "o": ["els", "li", "los"], "e": "Complement indirecte de tercera persona plural davant del verb: els."},
      {"q": "Substituïx el complement directe: «Mire la tele.»", "o": ["La mire.", "El mire.", "Li mire."], "e": "La tele és femení singular: la."},
      {"q": "Substituïx el complement directe: «Compre els llibres.»", "o": ["Els compre.", "Les compre.", "Li compre."], "e": "Els llibres és masculí plural: els."},
      {"q": "Substituïx el complement directe: «Vull comprar el pa.»", "o": ["Vull comprar-lo.", "Vull comprar-el.", "Vull comprar-li."], "e": "Darrere de l'infinitiu, el pronom va amb guionet: comprar-lo."},
      {"q": "Substituïx el complement directe: «Obri la porta!»", "o": ["Obri-la!", "La obri!", "Obri-li!"], "e": "Darrere de l'imperatiu, el pronom va amb guionet: obri-la."},
      {"q": "Substituïx el complement indirecte: «Escric un missatge a la meua amiga.»", "o": ["Li escric un missatge.", "La escric un missatge.", "Els escric un missatge."], "e": "Complement indirecte singular (masculí o femení): li."},
      {"q": "Substituïx el complement indirecte: «Done caramels als xiquets.»", "o": ["Els done caramels.", "Li done caramels.", "Los done caramels."], "e": "Complement indirecte plural davant del verb: els."},
      {"q": "Completa: ___ et dius? — Anna.", "o": ["Com", "Què", "Qui"], "e": "Per a preguntar el nom: com."},
      {"q": "Completa: ___ vius? — A Alzira.", "o": ["On", "Quan", "Com"], "e": "Per a preguntar pel lloc: on (o a on)."},
      {"q": "Completa: ___ és eixe home? — És el meu tio.", "o": ["Qui", "Què", "Quin"], "e": "Per a preguntar per una persona: qui."},
      {"q": "Completa: ___ vols per a sopar? — Una truita.", "o": ["Què", "Qui", "On"], "e": "Per a preguntar per una cosa: què."},
      {"q": "Completa: ___ anys tens?", "o": ["Quants", "Quantes", "Quant"], "e": "Anys és masculí plural: quants."},
      {"q": "Completa: ___ germanes tens?", "o": ["Quantes", "Quants", "Quanta"], "e": "Germanes és femení plural: quantes."},
      {"q": "Completa: La xica ___ parla amb Pere és ma germana.", "o": ["que", "qui", "què"], "e": "El relatiu que unix les dues frases: la xica que parla."},
      {"q": "Substituïx «la carta» pel pronom: «Llig la carta.» → ___ llig.", "a": ["la"], "e": "La carta és femení singular: la llig."}
    ]
  },
  {
    "id": "9d900655-f7cc-4ca6-9611-6fc2f32bbc2b", "offset": 11,
    "exercises": [
      {"q": "Com s'escriu el número 12?", "o": ["dotze", "doce", "dotse"], "e": "Dotze, amb tz."},
      {"q": "Com s'escriu el número 17?", "o": ["dèsset", "desisset", "dietset"], "e": "Dèsset (també disset o desset)."},
      {"q": "Com s'escriu el número 19?", "o": ["dènou", "dieunou", "deunou"], "e": "Dènou (també dinou o denou)."},
      {"q": "Com s'escriu el número 30?", "o": ["trenta", "treinta", "tretanta"], "e": "Trenta."},
      {"q": "Com s'escriu el número 40?", "o": ["quaranta", "cuaranta", "quatranta"], "e": "Quaranta."},
      {"q": "Com s'escriu el número 100?", "o": ["cent", "cen", "cente"], "e": "Cent."},
      {"q": "Com s'escriu el número 200?", "o": ["dos-cents", "docents", "dos cent"], "e": "Dos-cents: les centenes s'escriuen amb guionet."},
      {"q": "Quin número és «vint-i-dos»?", "o": ["22", "12", "20"], "e": "Vint-i-dos = 22."},
      {"q": "Completa (si comencem per dilluns): Diumenge és el ___ dia de la setmana.", "o": ["seté", "sisé", "huité"], "e": "Diumenge és el seté dia (7é)."},
      {"q": "Completa: Visc al ___ pis (4t).", "o": ["quart", "quatré", "quarté"], "e": "L'ordinal de quatre és quart."},
      {"q": "Completa: És la ___ vegada que vinc a València (1a).", "o": ["primera", "primer", "una"], "e": "Vegada és femení: primera."},
      {"q": "Completa: No hi ha ___ al parc: està buit.", "o": ["ningú", "algú", "res"], "e": "Ningú: cap persona."},
      {"q": "Completa: He vist ___ amics teus al cine.", "o": ["alguns", "cap", "ningú"], "e": "Alguns: una quantitat indeterminada de persones."},
      {"q": "Completa: No m'ha telefonat ___ en tot el dia.", "o": ["ningú", "res", "cap"], "e": "Ningú es referix a persones."},
      {"q": "Completa: Has menjat ___? — No, encara no.", "o": ["res", "ningú", "cap"], "e": "Res es referix a coses (= alguna cosa, en preguntes)."},
      {"q": "Completa: Parles ___ bé el valencià!", "o": ["molt", "molta", "molts"], "e": "Davant d'un adverbi (bé), molt és invariable."},
      {"q": "Completa: Hui fa ___ calor: quaranta graus!", "o": ["molta", "molt", "pocs"], "e": "La calor és femení: molta calor."},
      {"q": "Completa: Tinc ___ temps: només cinc minuts.", "o": ["poc", "molt", "massa"], "e": "Poc: una quantitat xicoteta."},
      {"q": "Completa: No puc dormir: hi ha ___ soroll.", "o": ["massa", "prou", "gens"], "e": "Massa: més del que convé."},
      {"q": "Completa: Tenim cadires per a tots? — Sí, n'hi ha ___.", "o": ["prou", "massa", "gens"], "e": "Prou: la quantitat necessària."},
      {"q": "Completa: ___ les xiques han vingut a la festa.", "o": ["Totes", "Tots", "Tot"], "e": "Xiques és femení plural: totes."},
      {"q": "Completa: Hi ha ___ gent al concert: està ple.", "o": ["molta", "molts", "poca"], "e": "Gent és femení singular: molta gent."},
      {"q": "Escriu en lletres el número 50.", "a": ["cinquanta"], "e": "Cinquanta."},
      {"q": "Escriu en lletres el número 35.", "a": ["trenta-cinc"], "e": "Trenta-cinc: desenes i unitats s'unixen amb guionet."}
    ]
  },
  {
    "id": "a8c6af22-1a37-49d0-a8b9-35c91f26bff9", "offset": 9,
    "exercises": [
      {"q": "Completa: Esta vesprada anem ___ la platja.", "o": ["a", "en", "de"], "e": "Destinació: a."},
      {"q": "Completa: Visc ___ Gandia.", "o": ["a", "en", "de"], "e": "Davant de noms de lloc s'usa a: visc a Gandia."},
      {"q": "Completa: Hui em quede ___ casa.", "o": ["a", "de", "per"], "e": "Situació: a casa."},
      {"q": "Completa: Vinc a l'escola ___ peu.", "o": ["a", "en", "de"], "e": "Es diu «a peu»."},
      {"q": "Completa: El llibre és ___ Maria.", "o": ["de", "a", "per"], "e": "Possessió: de."},
      {"q": "Completa: Vull una tassa ___ café.", "o": ["de", "a", "per"], "e": "Contingut: una tassa de café."},
      {"q": "Completa: He comprat pa ___ sopar.", "o": ["per a", "per", "de"], "e": "Finalitat davant d'infinitiu: per a."},
      {"q": "Completa: L'avió ix ___ les deu.", "o": ["a", "en", "per"], "e": "Hora: a les deu."},
      {"q": "Completa: Estudie valencià ___ fa dos anys.", "o": ["des de", "de", "per"], "e": "Punt d'inici en el temps: des de."},
      {"q": "Completa: Treballe ___ les nou ___ les tres.", "o": ["de / a", "a / de", "en / per"], "e": "Interval de temps: de... a..."},
      {"q": "Completa: Passem ___ el parc per a anar a l'escola.", "o": ["per", "per a", "a"], "e": "Lloc per on es passa: per."},
      {"q": "Completa: El gat està ___ la taula (a dalt).", "o": ["damunt de", "davall de", "dins de"], "e": "A dalt: damunt de."},
      {"q": "Completa: Les claus estan ___ la bossa.", "o": ["dins de", "fora de", "entre"], "e": "A l'interior: dins de."},
      {"q": "Completa: El banc està ___ la farmàcia (tocant-la).", "o": ["al costat de", "dins de", "entre"], "e": "Tocant: al costat de."},
      {"q": "Completa: La parada està ___ l'escola (en la part de davant).", "o": ["davant de", "darrere de", "dins de"], "e": "En la part de davant: davant de."},
      {"q": "Completa: El jardí està ___ la casa (en la part de darrere).", "o": ["darrere de", "davant de", "damunt de"], "e": "En la part de darrere: darrere de."},
      {"q": "Completa: Isc ___ treballar a les tres.", "o": ["de", "a", "per"], "e": "Eixir de: isc de treballar."},
      {"q": "Completa: Sempre pense ___ tu.", "o": ["en", "a", "de"], "e": "Pensar en algú."},
      {"q": "Completa: Parlem ___ viatge de l'estiu.", "o": ["del", "de el", "en el"], "e": "Parlar de + el → del."},
      {"q": "Completa: Estic ___ acord amb tu.", "o": ["d'", "en", "a"], "e": "Es diu «d'acord»."},
      {"q": "Completa: ___ on eres?", "o": ["D'", "A", "Per"], "e": "Origen: d'on (de + on)."},
      {"q": "Completa: ___ què servix açò?", "o": ["Per a", "De", "En"], "e": "Finalitat: per a què."},
      {"q": "Completa: ___ qui és este paraigua?", "o": ["De", "A", "Amb"], "e": "Possessió: de qui."},
      {"q": "Completa: ___ quina hora comença la classe?", "o": ["A", "En", "De"], "e": "Hora: a quina hora."},
      {"q": "Escriu la preposició: Demà vaig ___ Alacant.", "a": ["a"], "e": "Destinació: a Alacant."},
      {"q": "Escriu la preposició: Isc al cine ___ la meua germana.", "a": ["amb"], "e": "Companyia: amb."}
    ]
  },
  {
    "id": "03d45225-e0a6-4178-8574-ba4960ef05c1", "offset": 10,
    "exercises": [
      {"q": "Completa: Hui és dilluns; ___ serà dimarts.", "o": ["demà", "ahir", "abans"], "e": "El dia següent: demà."},
      {"q": "Completa: ___ va ser diumenge.", "o": ["Ahir", "Demà", "Després"], "e": "El dia anterior: ahir."},
      {"q": "Completa: Ara no puc, t'ho explique ___.", "o": ["més tard", "ahir", "abans"], "e": "En un moment posterior: més tard."},
      {"q": "Completa: — Ha arribat Pere? — Sí, ___ ha arribat.", "o": ["ja", "encara", "mai"], "e": "Ja: la cosa ha passat."},
      {"q": "Completa: Són les deu i el meu germà ___ dorm.", "o": ["encara", "ja", "mai"], "e": "Encara: l'acció continua."},
      {"q": "Completa: ___ esmorze a les set: tots els dies.", "o": ["Sempre", "Mai", "De tant en tant"], "e": "Tots els dies: sempre."},
      {"q": "Completa: Vaig al teatre ___: no gaire sovint.", "o": ["de tant en tant", "sempre", "cada dia"], "e": "Algunes vegades: de tant en tant."},
      {"q": "Completa: El meu amic viu ___, a l'altra punta del món.", "o": ["lluny", "prop", "ací"], "e": "A molta distància: lluny."},
      {"q": "Completa: La farmàcia està molt ___: a dos minuts.", "o": ["prop", "lluny", "fora"], "e": "A poca distància: prop."},
      {"q": "Completa: Entra ___, que plou.", "o": ["dins", "fora", "lluny"], "e": "A l'interior: dins."},
      {"q": "Completa: Aquell llibre està ___, lluny de nosaltres.", "o": ["allí", "ací", "ahí"], "e": "Lluny de qui parla i de qui escolta: allí."},
      {"q": "Completa: Deixa-ho ___, al teu costat.", "o": ["ahí", "ací", "allí"], "e": "Prop de qui escolta: ahí."},
      {"q": "Completa: L'ascensor puja ___.", "o": ["amunt", "avall", "dins"], "e": "Cap a dalt: amunt."},
      {"q": "Completa: La pilota ha rodolat carrer ___.", "o": ["avall", "amunt", "dins"], "e": "Cap a baix: avall."},
      {"q": "Completa: Estic ___ cansat: he corregut deu quilòmetres.", "o": ["molt", "poc", "gens"], "e": "En gran quantitat: molt."},
      {"q": "Completa: Menja ___, que estàs molt prim.", "o": ["més", "menys", "gens"], "e": "Una quantitat major: més."},
      {"q": "Completa: La pel·lícula no m'ha agradat ___.", "o": ["gens", "sempre", "ja"], "e": "En frases negatives, gens = en cap grau."},
      {"q": "Completa: Canta molt ___: té una veu preciosa.", "o": ["bé", "mal", "poc"], "e": "De manera bona: bé."},
      {"q": "Completa: Hui estic ___: tinc febre.", "o": ["malament", "bé", "prou"], "e": "De manera dolenta: malament."},
      {"q": "Completa: Parla ___, que el xiquet dorm.", "o": ["baix", "alt", "fort"], "e": "Amb poca veu: baix."},
      {"q": "Completa: — Vens al cine? — ___, i tant!", "o": ["Sí", "No", "Tampoc"], "e": "Afirmació: sí."},
      {"q": "Completa: — A mi m'agrada el te. — A mi ___.", "o": ["també", "tampoc", "ni"], "e": "Coincidència en una frase afirmativa: també."},
      {"q": "Completa: ___ llig la pregunta i després respon.", "o": ["Primer", "Després", "Finalment"], "e": "La primera acció: primer."},
      {"q": "Escriu el contrari de «lluny».", "a": ["prop"], "e": "Lluny ↔ prop."},
      {"q": "Escriu el contrari de «amunt».", "a": ["avall"], "e": "Amunt ↔ avall."}
    ]
  },
  {
    "id": "e7ee9121-8467-4534-9ec5-1f8b491794f2", "offset": 11,
    "exercises": [
      {"q": "Completa: Tinc un germà ___ una germana.", "o": ["i", "o", "ni"], "e": "Per a sumar elements: i."},
      {"q": "Completa: Vols anar al cine ___ al teatre?", "o": ["o", "i", "ni"], "e": "Per a triar entre dues coses: o."},
      {"q": "Completa: No tinc gana ___ set.", "o": ["ni", "o", "però"], "e": "Per a sumar elements negatius: ni."},
      {"q": "Completa: Ni jo ___ tu tenim cotxe.", "o": ["ni", "o", "i"], "e": "Ni... ni...: cap dels dos."},
      {"q": "Completa: O vens ara ___ me'n vaig sense tu.", "o": ["o", "i", "ni"], "e": "O... o...: una de les dues opcions."},
      {"q": "Completa: És car, ___ és molt bo.", "o": ["però", "sinó", "perquè"], "e": "Per a oposar una idea: però."},
      {"q": "Completa: No vull aigua, ___ suc de taronja.", "o": ["sinó", "però", "o"], "e": "Després d'una negació, per a corregir: sinó."},
      {"q": "Completa: No he anat a classe ___ estava malalt.", "o": ["perquè", "però", "si"], "e": "Per a expressar la causa: perquè."},
      {"q": "Completa: ___ estava cansada, se'n va anar a dormir.", "o": ["Com que", "Però", "Sinó"], "e": "Causa a l'inici de la frase: com que."},
      {"q": "Completa: — Per què estudies valencià? — ___ vull treballar a València.", "o": ["Perquè", "Però", "Com"], "e": "Resposta a «per què?»: perquè."},
      {"q": "Completa: Fa sol; ___, anirem a la platja.", "o": ["per tant", "però", "sinó"], "e": "Per a expressar una conseqüència: per tant."},
      {"q": "Completa: ___ vols, et puc ajudar.", "o": ["Si", "Sinó", "Quan"], "e": "Per a expressar una condició: si."},
      {"q": "Completa: ___ era xicotet, vivia a Morella.", "o": ["Quan", "Si", "Perquè"], "e": "Per a expressar el temps: quan."},
      {"q": "Completa: Vine ___ pugues.", "o": ["quan", "perquè", "però"], "e": "Temps: quan."},
      {"q": "Completa: Marta diu ___ vindrà demà.", "o": ["que", "què", "qui"], "e": "La conjunció que introduïx el que es diu."},
      {"q": "Completa: No sé ___ vindrà o no.", "o": ["si", "que", "quan"], "e": "Pregunta indirecta de sí o no: si."},
      {"q": "Completa: He vingut ___ parlar amb tu.", "o": ["per a", "per", "perquè"], "e": "Finalitat davant d'infinitiu: per a."},
      {"q": "Completa: M'agrada ___ el futbol ___ el bàsquet.", "o": ["tant / com", "tan / com", "molt / que"], "e": "Comparació d'igualtat amb noms: tant... com..."},
      {"q": "Completa: M'agrada llegir ___ escoltar música.", "o": ["i", "ni", "sinó"], "e": "Per a sumar accions: i."},
      {"q": "Quina frase és correcta?", "o": ["No menge ni carn ni peix.", "No menge o carn o peix.", "No menge i carn i peix."], "e": "Per a negar dos elements: ni... ni..."},
      {"q": "Quina d'estes conjuncions expressa causa?", "o": ["perquè", "però", "o"], "e": "Perquè introduïx la causa."},
      {"q": "Quina d'estes conjuncions expressa una alternativa?", "o": ["o", "i", "perquè"], "e": "O presenta opcions."},
      {"q": "Escriu la conjunció: Tinc un gos ___ un gat.", "a": ["i"], "e": "Per a sumar: i."},
      {"q": "Escriu la conjunció: M'agrada, ___ és massa car.", "a": ["però"], "e": "Per a oposar: però."}
    ]
  },
  {
    "id": "e971fb5a-f24b-4b65-bdf4-6f85d3b084c7", "offset": 14,
    "exercises": [
      {"q": "Present: Nosaltres ___ (viure) a Sagunt.", "o": ["vivim", "vivem", "viuem"], "e": "Viure: visc, vius, viu, vivim, viviu, viuen."},
      {"q": "Present: Ells ___ (llegir) el periòdic cada matí.", "o": ["lligen", "leigen", "llegen"], "e": "Llegir: llig, lliges, llig, llegim, llegiu, lligen."},
      {"q": "Present: Jo ___ (preferir) el te.", "o": ["preferisc", "prefiro", "preferixc"], "e": "Preferir és incoatiu: jo preferisc."},
      {"q": "Present: Vosaltres ___ (anar) a classe cada dia.", "o": ["aneu", "van", "anem"], "e": "Anar: vaig, vas, va, anem, aneu, van."},
      {"q": "Present del verb anar: Jo ___ a la feina amb bici.", "o": ["vaig", "vac", "anc"], "e": "Anar és irregular: jo vaig."},
      {"q": "Present del verb poder: Jo no ___ vindre demà.", "o": ["puc", "podo", "pot"], "e": "Poder: puc, pots, pot, podem, podeu, poden."},
      {"q": "Present del verb voler: Jo ___ un café, per favor.", "o": ["vull", "vol", "volc"], "e": "Voler: vull, vols, vol, volem, voleu, volen."},
      {"q": "Present del verb saber: Jo no ___ nadar.", "o": ["sé", "sap", "sabo"], "e": "Saber: sé, saps, sap, sabem, sabeu, saben."},
      {"q": "Present del verb estar: Jo ___ cansada.", "o": ["estic", "esto", "està"], "e": "Estar: estic, estàs, està, estem, esteu, estan."},
      {"q": "Passat perifràstic: Dissabte passat ___ (sopar, nosaltres) fora.", "o": ["vam sopar", "sopem", "sopàvem"], "e": "Passat perifràstic: anar (present) + infinitiu: vam sopar."},
      {"q": "Passat perifràstic: L'any passat ___ (viatjar, ells) a Itàlia.", "o": ["van viatjar", "viatgen", "viatjaran"], "e": "Van viatjar: acció acabada en el passat."},
      {"q": "Imperfet: Quan era xicotet, ___ (jugar, jo) al carrer.", "o": ["jugava", "jugue", "jugaré"], "e": "L'imperfet expressa costums del passat: jugava."},
      {"q": "Passat perfet: Encara no ___ (acabar, jo) els deures.", "o": ["he acabat", "vaig acabar", "acabaré"], "e": "Amb «encara no» s'usa el perfet: he acabat."},
      {"q": "Futur: L'any que ve ___ (estudiar, jo) anglés.", "o": ["estudiaré", "estudie", "estudiava"], "e": "Futur: infinitiu + -é: estudiaré."},
      {"q": "Futur: Demà ___ (ploure).", "o": ["plourà", "plou", "ha plogut"], "e": "Futur de ploure: plourà."},
      {"q": "Imperatiu: ___ (tancar, tu) la porta, per favor!", "o": ["Tanca", "Tanques", "Tancar"], "e": "Imperatiu de tu: tanca."},
      {"q": "Imperatiu: ___ (vindre, tu) ací!", "o": ["Vine", "Vens", "Vinc"], "e": "Imperatiu irregular de vindre: vine."},
      {"q": "Completa amb haver-hi: Ahir ___ molta gent a la festa.", "o": ["hi havia", "hi ha", "hi haurà"], "e": "En passat: hi havia."},
      {"q": "Quina forma és correcta per a expressar obligació?", "o": ["He d'estudiar més.", "Tinc que estudiar més.", "Hi ha que estudiar més."], "e": "L'obligació s'expressa amb haver de + infinitiu. «Tindre que» és un castellanisme."},
      {"q": "Escriu el present del verb tindre: Nosaltres ___ un gos.", "a": ["tenim"], "e": "Tindre: tinc, tens, té, tenim, teniu, tenen."},
      {"q": "Escriu el present del verb anar: Ells ___ al cine.", "a": ["van"], "e": "Anar: vaig, vas, va, anem, aneu, van."}
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
