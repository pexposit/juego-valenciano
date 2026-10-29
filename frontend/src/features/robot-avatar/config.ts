import { asset } from '../../lib/basePath';
/**
 * [robot-avatar] Configuració del mòdul de l'avatar robot 3D.
 *
 * Per a desactivar-lo sense tocar codi:
 *   - tot el mòdul:   VITE_ROBOT_AVATAR=off   (fitxer .env del frontend)
 *   - només un lloc:  posa `false` en `places` ací baix.
 * Amb el mòdul desactivat, l'aplicació torna a mostrar els avatars originals
 * (professor SVG al Dashboard i personatges il·lustrats al Chat).
 */
export const ROBOT_AVATAR = {
  enabled: import.meta.env.VITE_ROBOT_AVATAR !== 'off',
  places: {
    dashboard: true, // substituïx /images/avatar_professor.svg
    chat: true, // substituïx els personatges de SceneArt (mercat, bar, oficina...)
  },
  modelUrl: asset('/avatar-robot/robot.glb'),
  fallbackUrl: asset('/avatar-robot/robot.png'),
  // Versions del robot amb roba de l'escenari (GLB + imatge mentre carrega);
  // la resta d'escenaris usen `modelUrl` i `fallbackUrl`. Font: assets-src/robot-avatar/.
  scenarioOutfits: {
    n0_fruiteria: { // Josep, fruiter (adults, Nivell 0): el mateix personatge que el mercat de l'A2
      modelUrl: asset('/avatar-robot/robot-mercat.glb'),
      fallbackUrl: asset('/avatar-robot/robot-mercat.webp'),
    },
    mercat: { // barret de palla, davantal i taronja
      modelUrl: asset('/avatar-robot/robot-mercat.glb'),
      fallbackUrl: asset('/avatar-robot/robot-mercat.webp'),
    },
    farmacia: { // bata blanca, creu verda, ulleres i caixa de medicaments
      modelUrl: asset('/avatar-robot/robot-farmacia.glb'),
      fallbackUrl: asset('/avatar-robot/robot-farmacia.webp'),
    },
    forn: { // gorro de forner, davantal de pitet i barra de pa
      modelUrl: asset('/avatar-robot/robot-forn.glb'),
      fallbackUrl: asset('/avatar-robot/robot-forn.webp'),
    },
    oficina: { // americana blava, camisa, mocador de butxaca, targeta i tassa de café
      modelUrl: asset('/avatar-robot/robot-oficina.glb'),
      fallbackUrl: asset('/avatar-robot/robot-oficina.webp'),
    },
    a2_identificacio: { // festa d'aniversari de Núria: americana granat, pestanyes, perles i copa de cava
      modelUrl: asset('/avatar-robot/robot-a2_identificacio.glb'),
      fallbackUrl: asset('/avatar-robot/robot-a2_identificacio.webp'),
    },
    a2_casa: { // Xavi, nou company de pis: dessuadora oberta, gorra i claus del pis
      modelUrl: asset('/avatar-robot/robot-a2_casa.glb'),
      fallbackUrl: asset('/avatar-robot/robot-a2_casa.webp'),
    },
    b1_salut: { // Marc, company de pis (B1, salut): el mateix personatge que el company de pis de l'A2 (Xavi)
      modelUrl: asset('/avatar-robot/robot-a2_casa.glb'),
      fallbackUrl: asset('/avatar-robot/robot-a2_casa.webp'),
    },
    a2_activitats: { // Toni, amic del gimnàs: samarreta de tirants, pantaló curt, cinta, tovallola i pesa
      modelUrl: asset('/avatar-robot/robot-a2_activitats.glb'),
      fallbackUrl: asset('/avatar-robot/robot-a2_activitats.webp'),
    },
    a2_menjar: { // Empar, propietària del restaurant: armilla, brusa, fular, pestanyes, arracades i la carta
      modelUrl: asset('/avatar-robot/robot-a2_menjar.glb'),
      fallbackUrl: asset('/avatar-robot/robot-a2_menjar.webp'),
    },
    a2_servicis: { // Lídia, dependenta dels grans magatzems: rebeca, cinta mètrica, placa i pestanyes
      modelUrl: asset('/avatar-robot/robot-a2_servicis.glb'),
      fallbackUrl: asset('/avatar-robot/robot-a2_servicis.webp'),
    },
    a2_faena: { // Sílvia, antiga companya de l'institut: jaqueta texana, top de ratlles, ulleres de sol, bossa i mòbil
      modelUrl: asset('/avatar-robot/robot-a2_faena.glb'),
      fallbackUrl: asset('/avatar-robot/robot-a2_faena.webp'),
    },
    a2_clima: { // Liam, amic irlandés: impermeable verd, jersei de punt, gorra plana de tweed i paraigua
      modelUrl: asset('/avatar-robot/robot-a2_clima.glb'),
      fallbackUrl: asset('/avatar-robot/robot-a2_clima.webp'),
    },
    b1_treball: { // Sergi, responsable de recursos humans (B1, el treball): el mateix personatge que el recepcionista de l'hotel de l'A2 (Jordi)
      modelUrl: asset('/avatar-robot/robot-a2_viatges.glb'),
      fallbackUrl: asset('/avatar-robot/robot-a2_viatges.webp'),
    },
    a2_viatges: { // Jordi, recepcionista de l'hotel: uniforme amb ribets daurats, llacet, placa i clau de l'habitació
      modelUrl: asset('/avatar-robot/robot-a2_viatges.glb'),
      fallbackUrl: asset('/avatar-robot/robot-a2_viatges.webp'),
    },
    ajuntament: { // Amparo, funcionària d'atenció ciutadana: americana petroli, brusa, ulleres, collaret i carpeta
      modelUrl: asset('/avatar-robot/robot-ajuntament.glb'),
      fallbackUrl: asset('/avatar-robot/robot-ajuntament.webp'),
    },
    b1_administracio: { // Teresa, tècnica de l'Oficina d'Atenció Ciutadana (B1): el mateix personatge que la funcionària de l'ajuntament (Amparo)
      modelUrl: asset('/avatar-robot/robot-ajuntament.glb'),
      fallbackUrl: asset('/avatar-robot/robot-ajuntament.webp'),
    },
    n0_ajuntament: { // Rosa, funcionària (adults, Nivell 0): el mateix personatge que l'ajuntament del B1
      modelUrl: asset('/avatar-robot/robot-ajuntament.glb'),
      fallbackUrl: asset('/avatar-robot/robot-ajuntament.webp'),
    },
    bar: { // Maria, cambrera: polo taronja, davantal negre, llibreta, drap, pestanyes i safata amb café i suc
      modelUrl: asset('/avatar-robot/robot-bar.glb'),
      fallbackUrl: asset('/avatar-robot/robot-bar.webp'),
    },
    n0_taller: { // Toni, mecànic (adults, Nivell 0): el mateix personatge que el taller del B1
      modelUrl: asset('/avatar-robot/robot-taller.glb'),
      fallbackUrl: asset('/avatar-robot/robot-taller.webp'),
    },
    taller: { // mecànic en cap: granota de treball, gorra, pegat amb el nom, tornavís, drap i clau fixa
      modelUrl: asset('/avatar-robot/robot-taller.glb'),
      fallbackUrl: asset('/avatar-robot/robot-taller.webp'),
    },
    turisme: { // Laura, guia turística: armilla de guia, visera, pestanyes, placa, plànol i banderí
      modelUrl: asset('/avatar-robot/robot-turisme.glb'),
      fallbackUrl: asset('/avatar-robot/robot-turisme.webp'),
    },
    b1_persones: { // Elena, companya del curs de cuina: jersei, davantal roig, mocador al cap, pestanyes i batedora
      modelUrl: asset('/avatar-robot/robot-b1_persones.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b1_persones.webp'),
    },
    b1_relacions: { // Pau, el teu cosí: sobrecamisa de pana, gorro de llana i globus daurat «50» (noces d'or dels avis)
      modelUrl: asset('/avatar-robot/robot-b1_relacions.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b1_relacions.webp'),
    },
    b1_vida_quotidiana: { // Amparo, atenció al client d'Electrodomèstics Túria: auriculars amb micròfon, polo, pestanyes i cafetera
      modelUrl: asset('/avatar-robot/robot-b1_vida_quotidiana.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b1_vida_quotidiana.webp'),
    },
    b1_llocs: { // Joan, agent immobiliari: americana camel, camisa de coll obert, rellotge i claus amb clauer de caseta
      modelUrl: asset('/avatar-robot/robot-b1_llocs.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b1_llocs.webp'),
    },
    b1_viatges: { // Neus, agent de viatges: americana blau cel, fular de seda, placa amb avió, pestanyes i bola del món
      modelUrl: asset('/avatar-robot/robot-b1_viatges.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b1_viatges.webp'),
    },
    b1_oci_esport: { // Andreu, amic esportista: jaqueta de xandall amb franges, rellotge esportiu i el diari obert
      modelUrl: asset('/avatar-robot/robot-b1_oci_esport.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b1_oci_esport.webp'),
    },
    b1_territori: { // Hannah, estudiant d'Erasmus: jersei mostassa, motxilla, pestanyes i mapa per a la presentació
      modelUrl: asset('/avatar-robot/robot-b1_territori.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b1_territori.webp'),
    },
    b1_cultura: { // Àlex, locutor de ràdio: auriculars d'estudi, jaqueta bomber i micròfon de mà
      modelUrl: asset('/avatar-robot/robot-b1_cultura.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b1_cultura.webp'),
    },
    b1_natura_clima: { // Pilar, guia del Parc Natural del Montgó: camisa de guarda, barret d'excursió, prismàtics i bastó
      modelUrl: asset('/avatar-robot/robot-b1_natura_clima.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b1_natura_clima.webp'),
    },
    colegi: { // Marta, mestra: rebeca corall, brusa de coll rodó, ulleres amb cadeneta, pestanyes, llibres i poma
      modelUrl: asset('/avatar-robot/robot-colegi.glb'),
      fallbackUrl: asset('/avatar-robot/robot-colegi.webp'),
    },
    n0_pocio: { // Merlí, el mag (xiquets): barret punxegut, barba, túnica amb estrelles, poció i vareta màgica
      modelUrl: asset('/avatar-robot/robot-n0_pocio.glb'),
      fallbackUrl: asset('/avatar-robot/robot-n0_pocio.webp'),
    },
    n0_zoo: { // Carme, la cuidadora del zoo (xiquets): peto verd amb petjada, barret de pescador, plàtan i galleda amb peixos
      modelUrl: asset('/avatar-robot/robot-n0_zoo.glb'),
      fallbackUrl: asset('/avatar-robot/robot-n0_zoo.webp'),
    },
    n0_pati: { // Laia, xiqueta de la classe (xiquets): samarreta rosa, faldilla texana i pilota de futbol
      modelUrl: asset('/avatar-robot/robot-n0_pati.glb'),
      fallbackUrl: asset('/avatar-robot/robot-n0_pati.webp'),
    },
    n0_biblioteca: { // Pau, el bibliotecari (xiquets): armilla de punt amb rombes, ulleres daurades, llapis a l'orella i conte
      modelUrl: asset('/avatar-robot/robot-n0_biblioteca.glb'),
      fallbackUrl: asset('/avatar-robot/robot-n0_biblioteca.webp'),
    },
    b2_gent: { // Carme, presidenta de l'associació cultural: brusa amb floretes, collaret de boles, pestanyes i carpeta amb la llista
      modelUrl: asset('/avatar-robot/robot-b2_gent.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b2_gent.webp'),
    },
    b2_estudis_treball: { // Ferran, director de RRHH (entrevista de feina): reutilitza la roba de l'oficina
      modelUrl: asset('/avatar-robot/robot-oficina.glb'),
      fallbackUrl: asset('/avatar-robot/robot-oficina.webp'),
    },
    b2_viatges: { // Núria, coordinadora de l'oficina de turisme de Morella: roba de guia amb el fullet de la ruta dels Ports
      modelUrl: asset('/avatar-robot/robot-b2_viatges.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b2_viatges.webp'),
    },
    b2_menjar_salut: { // Toni, entrenador personal i dietista al gimnàs: reutilitza la roba de Toni del gimnàs
      modelUrl: asset('/avatar-robot/robot-a2_activitats.glb'),
      fallbackUrl: asset('/avatar-robot/robot-a2_activitats.webp'),
    },
    b2_cultura_espectacles: { // Marta, locutora de «Platea»: la roba de locutor de ràdio amb pestanyes
      modelUrl: asset('/avatar-robot/robot-b2_cultura_espectacles.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b2_cultura_espectacles.webp'),
    },
    b2_mitjans: { // Pau, redactor en cap del diari digital: roba d'oficina amb una tauleta amb el diari
      modelUrl: asset('/avatar-robot/robot-b2_mitjans.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b2_mitjans.webp'),
    },
    b2_politica_societat: { // Empar, regidora de participació ciutadana: reutilitza la roba de l'ajuntament
      modelUrl: asset('/avatar-robot/robot-ajuntament.glb'),
      fallbackUrl: asset('/avatar-robot/robot-ajuntament.webp'),
    },
    b2_actualitat: { // Héctor, divulgador científic: americana de tweed, samarreta amb un planeta i model d'àtom
      modelUrl: asset('/avatar-robot/robot-b2_actualitat.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b2_actualitat.webp'),
    },
    b2_cultura_llengua: { // la tia Pepeta, contadora de rondalles: vestit de floretes, toquilla, monyo i ventall
      modelUrl: asset('/avatar-robot/robot-b2_cultura_llengua.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b2_cultura_llengua.webp'),
    },
    // --- C1: roba pròpia (variants i nova) ---
    c1_relacions: { // Neus, la cosina (noces d'or dels avis): la roba del cosí Pau amb pestanyes, sense el globus
      modelUrl: asset('/avatar-robot/robot-c1_relacions.glb'),
      fallbackUrl: asset('/avatar-robot/robot-c1_relacions.webp'),
    },
    c1_casa: { // Vicent, arquitecte tècnic: americana camel amb plànols enrotllats
      modelUrl: asset('/avatar-robot/robot-c1_casa.glb'),
      fallbackUrl: asset('/avatar-robot/robot-c1_casa.webp'),
    },
    c1_temps_lliure: { // Jordi, coordinador d'activitats: la roba d'agent de viatges, sense pestanyes ni bola del món
      modelUrl: asset('/avatar-robot/robot-c1_temps_lliure.glb'),
      fallbackUrl: asset('/avatar-robot/robot-c1_temps_lliure.webp'),
    },
    c1_ensenyanca: { // Karim, pare nouvingut: jersei verd, camisa, rellotge i la motxilla escolar dels fills
      modelUrl: asset('/avatar-robot/robot-c1_ensenyanca.glb'),
      fallbackUrl: asset('/avatar-robot/robot-c1_ensenyanca.webp'),
    },
    c1_comerc: { // Rafel, antiquari del rastre: barret de feltre, armilla de tweed, riñonera i la làmpada de llautó
      modelUrl: asset('/avatar-robot/robot-c1_comerc.glb'),
      fallbackUrl: asset('/avatar-robot/robot-c1_comerc.webp'),
    },
    c1_medi_clima: { // Pilar, tècnica de protecció civil de l'Ajuntament: uniforme amb bandes reflectants, emblema i walkie-talkie
      modelUrl: asset('/avatar-robot/robot-c1_medi_clima.glb'),
      fallbackUrl: asset('/avatar-robot/robot-c1_medi_clima.webp'),
    },
    // --- C1: reutilitzen la roba d'un altre escenari ---
    c1_treball: { // Sílvia, delegada de personal: roba de Sílvia (a2_faena)
      modelUrl: asset('/avatar-robot/robot-a2_faena.glb'),
      fallbackUrl: asset('/avatar-robot/robot-a2_faena.webp'),
    },
    c1_alimentacio: { // Empar, xef del restaurant: roba d'Empar (a2_menjar)
      modelUrl: asset('/avatar-robot/robot-a2_menjar.glb'),
      fallbackUrl: asset('/avatar-robot/robot-a2_menjar.webp'),
    },
    c1_mitjans: { // Laia, directora del diari digital i del programa de ràdio: roba de locutora (b2_cultura_espectacles)
      modelUrl: asset('/avatar-robot/robot-b2_cultura_espectacles.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b2_cultura_espectacles.webp'),
    },
    c1_salut: { // Marc, infermer: bata de la farmàcia (farmacia)
      modelUrl: asset('/avatar-robot/robot-farmacia.glb'),
      fallbackUrl: asset('/avatar-robot/robot-farmacia.webp'),
    },
    c1_cultura: { // Teresa, directora de la casa de cultura: roba de presidenta d'associació (b2_gent)
      modelUrl: asset('/avatar-robot/robot-b2_gent.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b2_gent.webp'),
    },
    c1_economia: { // Sergi, tècnic de desenvolupament local: roba d'oficina (oficina)
      modelUrl: asset('/avatar-robot/robot-oficina.glb'),
      fallbackUrl: asset('/avatar-robot/robot-oficina.webp'),
    },
    c1_sociocultural: { // Marina, presidenta d'una associació intercultural: roba de presidenta d'associació (b2_gent)
      modelUrl: asset('/avatar-robot/robot-b2_gent.glb'),
      fallbackUrl: asset('/avatar-robot/robot-b2_gent.webp'),
    },
    // --- C2 ---
    c2_relacions: { // Ernest, amic de tota la vida i professor de música: americana de llana, coll alt i un tallat
      modelUrl: '/avatar-robot/robot-c2_relacions.glb',
      fallbackUrl: '/avatar-robot/robot-c2_relacions.webp',
    },
    c2_casa: { // Remei, propietària d'un mas: rebeca, monyo, pestanyes i la clau antiga del mas
      modelUrl: '/avatar-robot/robot-c2_casa.glb',
      fallbackUrl: '/avatar-robot/robot-c2_casa.webp',
    },
    c2_treball: { // Andreu, director de recursos humans: vestit antracita, corbata i carpeta de pell
      modelUrl: '/avatar-robot/robot-c2_treball.glb',
      fallbackUrl: '/avatar-robot/robot-c2_treball.webp',
    },
    c2_alimentacio: { // Mar, cap de cuina d'un càtering: jaqueta de xef negra, mocador al cap, pestanyes i cullerot
      modelUrl: '/avatar-robot/robot-c2_alimentacio.glb',
      fallbackUrl: '/avatar-robot/robot-c2_alimentacio.webp',
    },
    c2_temps_lliure: { // Toni, president dels hostalers: barret panamà, americana de lli i ulleres de sol
      modelUrl: '/avatar-robot/robot-c2_temps_lliure.glb',
      fallbackUrl: '/avatar-robot/robot-c2_temps_lliure.webp',
    },
    c2_mitjans: { // Noelia, periodista de verificació: jaqueta de pell, auriculars al coll, pestanyes i lupa
      modelUrl: '/avatar-robot/robot-c2_mitjans.glb',
      fallbackUrl: '/avatar-robot/robot-c2_mitjans.webp',
    },
    c2_salut: { // Amparo, treballadora social sanitària: la roba d'Amparo (ajuntament) amb la targeta de l'hospital
      modelUrl: '/avatar-robot/robot-c2_salut.glb',
      fallbackUrl: '/avatar-robot/robot-c2_salut.webp',
    },
    c2_cultura: { // Octavi, comissari d'exposicions: americana de vellut, coll alt, ulleres de carei i catàleg
      modelUrl: '/avatar-robot/robot-c2_cultura.glb',
      fallbackUrl: '/avatar-robot/robot-c2_cultura.webp',
    },
    c2_comerc: { // Rebeca, cap d'atenció al client: americana negra, fular maragda, pestanyes i el tiquet de compra
      modelUrl: '/avatar-robot/robot-c2_comerc.glb',
      fallbackUrl: '/avatar-robot/robot-c2_comerc.webp',
    },
    c2_ensenyanca: { // Joaquim, director de l'institut: jersei de coll de pic, corbata, ulleres i matràs
      modelUrl: '/avatar-robot/robot-c2_ensenyanca.glb',
      fallbackUrl: '/avatar-robot/robot-c2_ensenyanca.webp',
    },
    c2_economia: { // Isabel, assessora de banca: americana carmesí, collaret d'or, pestanyes i tauleta amb un gràfic
      modelUrl: '/avatar-robot/robot-c2_economia.glb',
      fallbackUrl: '/avatar-robot/robot-c2_economia.webp',
    },
    c2_medi_clima: { // Ferran, enginyer de renovables: forro polar amb el logo d'un sol i maqueta de placa solar
      modelUrl: '/avatar-robot/robot-c2_medi_clima.glb',
      fallbackUrl: '/avatar-robot/robot-c2_medi_clima.webp',
    },
    c2_politica: { // Carme, exdiputada: americana gris, brusa lila, fermall, perles, pestanyes i llibre de memòries
      modelUrl: '/avatar-robot/robot-c2_politica.glb',
      fallbackUrl: '/avatar-robot/robot-c2_politica.webp',
    },
    c2_llengua: { // Xavier, professor i intèrpret de llengua de signes: roba llisa negra, rellotge i manual
      modelUrl: '/avatar-robot/robot-c2_llengua.glb',
      fallbackUrl: '/avatar-robot/robot-c2_llengua.webp',
    },
  } as Record<string, { modelUrl: string; fallbackUrl: string }>,
} as const;

export type RobotPlace = keyof typeof ROBOT_AVATAR.places;

export const isRobotAvatarEnabled = (place: RobotPlace) => ROBOT_AVATAR.enabled && ROBOT_AVATAR.places[place];

export const robotAssets = (scenario?: string) =>
  (scenario && ROBOT_AVATAR.scenarioOutfits[scenario]) ||
  { modelUrl: ROBOT_AVATAR.modelUrl, fallbackUrl: ROBOT_AVATAR.fallbackUrl };
