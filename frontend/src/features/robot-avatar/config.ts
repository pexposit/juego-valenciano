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
  modelUrl: '/avatar-robot/robot.glb',
  fallbackUrl: '/avatar-robot/robot.png',
  // Versions del robot amb roba de l'escenari (GLB + imatge mentre carrega);
  // la resta d'escenaris usen `modelUrl` i `fallbackUrl`. Font: assets-src/robot-avatar/.
  scenarioOutfits: {
    n0_fruiteria: { // Josep, fruiter (adults, Nivell 0): el mateix personatge que el mercat de l'A2
      modelUrl: '/avatar-robot/robot-mercat.glb',
      fallbackUrl: '/avatar-robot/robot-mercat.webp',
    },
    mercat: { // barret de palla, davantal i taronja
      modelUrl: '/avatar-robot/robot-mercat.glb',
      fallbackUrl: '/avatar-robot/robot-mercat.webp',
    },
    farmacia: { // bata blanca, creu verda, ulleres i caixa de medicaments
      modelUrl: '/avatar-robot/robot-farmacia.glb',
      fallbackUrl: '/avatar-robot/robot-farmacia.webp',
    },
    forn: { // gorro de forner, davantal de pitet i barra de pa
      modelUrl: '/avatar-robot/robot-forn.glb',
      fallbackUrl: '/avatar-robot/robot-forn.webp',
    },
    oficina: { // americana blava, camisa, mocador de butxaca, targeta i tassa de café
      modelUrl: '/avatar-robot/robot-oficina.glb',
      fallbackUrl: '/avatar-robot/robot-oficina.webp',
    },
    a2_identificacio: { // festa d'aniversari de Núria: americana granat, pestanyes, perles i copa de cava
      modelUrl: '/avatar-robot/robot-a2_identificacio.glb',
      fallbackUrl: '/avatar-robot/robot-a2_identificacio.webp',
    },
    a2_casa: { // Xavi, nou company de pis: dessuadora oberta, gorra i claus del pis
      modelUrl: '/avatar-robot/robot-a2_casa.glb',
      fallbackUrl: '/avatar-robot/robot-a2_casa.webp',
    },
    b1_salut: { // Marc, company de pis (B1, salut): el mateix personatge que el company de pis de l'A2 (Xavi)
      modelUrl: '/avatar-robot/robot-a2_casa.glb',
      fallbackUrl: '/avatar-robot/robot-a2_casa.webp',
    },
    a2_activitats: { // Toni, amic del gimnàs: samarreta de tirants, pantaló curt, cinta, tovallola i pesa
      modelUrl: '/avatar-robot/robot-a2_activitats.glb',
      fallbackUrl: '/avatar-robot/robot-a2_activitats.webp',
    },
    a2_menjar: { // Empar, propietària del restaurant: armilla, brusa, fular, pestanyes, arracades i la carta
      modelUrl: '/avatar-robot/robot-a2_menjar.glb',
      fallbackUrl: '/avatar-robot/robot-a2_menjar.webp',
    },
    a2_servicis: { // Lídia, dependenta dels grans magatzems: rebeca, cinta mètrica, placa i pestanyes
      modelUrl: '/avatar-robot/robot-a2_servicis.glb',
      fallbackUrl: '/avatar-robot/robot-a2_servicis.webp',
    },
    a2_faena: { // Sílvia, antiga companya de l'institut: jaqueta texana, top de ratlles, ulleres de sol, bossa i mòbil
      modelUrl: '/avatar-robot/robot-a2_faena.glb',
      fallbackUrl: '/avatar-robot/robot-a2_faena.webp',
    },
    a2_clima: { // Liam, amic irlandés: impermeable verd, jersei de punt, gorra plana de tweed i paraigua
      modelUrl: '/avatar-robot/robot-a2_clima.glb',
      fallbackUrl: '/avatar-robot/robot-a2_clima.webp',
    },
    b1_treball: { // Sergi, responsable de recursos humans (B1, el treball): el mateix personatge que el recepcionista de l'hotel de l'A2 (Jordi)
      modelUrl: '/avatar-robot/robot-a2_viatges.glb',
      fallbackUrl: '/avatar-robot/robot-a2_viatges.webp',
    },
    a2_viatges: { // Jordi, recepcionista de l'hotel: uniforme amb ribets daurats, llacet, placa i clau de l'habitació
      modelUrl: '/avatar-robot/robot-a2_viatges.glb',
      fallbackUrl: '/avatar-robot/robot-a2_viatges.webp',
    },
    ajuntament: { // Amparo, funcionària d'atenció ciutadana: americana petroli, brusa, ulleres, collaret i carpeta
      modelUrl: '/avatar-robot/robot-ajuntament.glb',
      fallbackUrl: '/avatar-robot/robot-ajuntament.webp',
    },
    b1_administracio: { // Teresa, tècnica de l'Oficina d'Atenció Ciutadana (B1): el mateix personatge que la funcionària de l'ajuntament (Amparo)
      modelUrl: '/avatar-robot/robot-ajuntament.glb',
      fallbackUrl: '/avatar-robot/robot-ajuntament.webp',
    },
    n0_ajuntament: { // Rosa, funcionària (adults, Nivell 0): el mateix personatge que l'ajuntament del B1
      modelUrl: '/avatar-robot/robot-ajuntament.glb',
      fallbackUrl: '/avatar-robot/robot-ajuntament.webp',
    },
    bar: { // Maria, cambrera: polo taronja, davantal negre, llibreta, drap, pestanyes i safata amb café i suc
      modelUrl: '/avatar-robot/robot-bar.glb',
      fallbackUrl: '/avatar-robot/robot-bar.webp',
    },
    n0_taller: { // Toni, mecànic (adults, Nivell 0): el mateix personatge que el taller del B1
      modelUrl: '/avatar-robot/robot-taller.glb',
      fallbackUrl: '/avatar-robot/robot-taller.webp',
    },
    taller: { // mecànic en cap: granota de treball, gorra, pegat amb el nom, tornavís, drap i clau fixa
      modelUrl: '/avatar-robot/robot-taller.glb',
      fallbackUrl: '/avatar-robot/robot-taller.webp',
    },
    turisme: { // Laura, guia turística: armilla de guia, visera, pestanyes, placa, plànol i banderí
      modelUrl: '/avatar-robot/robot-turisme.glb',
      fallbackUrl: '/avatar-robot/robot-turisme.webp',
    },
    b1_persones: { // Elena, companya del curs de cuina: jersei, davantal roig, mocador al cap, pestanyes i batedora
      modelUrl: '/avatar-robot/robot-b1_persones.glb',
      fallbackUrl: '/avatar-robot/robot-b1_persones.webp',
    },
    b1_relacions: { // Pau, el teu cosí: sobrecamisa de pana, gorro de llana i globus daurat «50» (noces d'or dels avis)
      modelUrl: '/avatar-robot/robot-b1_relacions.glb',
      fallbackUrl: '/avatar-robot/robot-b1_relacions.webp',
    },
    b1_vida_quotidiana: { // Amparo, atenció al client d'Electrodomèstics Túria: auriculars amb micròfon, polo, pestanyes i cafetera
      modelUrl: '/avatar-robot/robot-b1_vida_quotidiana.glb',
      fallbackUrl: '/avatar-robot/robot-b1_vida_quotidiana.webp',
    },
    b1_llocs: { // Joan, agent immobiliari: americana camel, camisa de coll obert, rellotge i claus amb clauer de caseta
      modelUrl: '/avatar-robot/robot-b1_llocs.glb',
      fallbackUrl: '/avatar-robot/robot-b1_llocs.webp',
    },
    b1_viatges: { // Neus, agent de viatges: americana blau cel, fular de seda, placa amb avió, pestanyes i bola del món
      modelUrl: '/avatar-robot/robot-b1_viatges.glb',
      fallbackUrl: '/avatar-robot/robot-b1_viatges.webp',
    },
    b1_oci_esport: { // Andreu, amic esportista: jaqueta de xandall amb franges, rellotge esportiu i el diari obert
      modelUrl: '/avatar-robot/robot-b1_oci_esport.glb',
      fallbackUrl: '/avatar-robot/robot-b1_oci_esport.webp',
    },
    b1_territori: { // Hannah, estudiant d'Erasmus: jersei mostassa, motxilla, pestanyes i mapa per a la presentació
      modelUrl: '/avatar-robot/robot-b1_territori.glb',
      fallbackUrl: '/avatar-robot/robot-b1_territori.webp',
    },
    b1_cultura: { // Àlex, locutor de ràdio: auriculars d'estudi, jaqueta bomber i micròfon de mà
      modelUrl: '/avatar-robot/robot-b1_cultura.glb',
      fallbackUrl: '/avatar-robot/robot-b1_cultura.webp',
    },
    b1_natura_clima: { // Pilar, guia del Parc Natural del Montgó: camisa de guarda, barret d'excursió, prismàtics i bastó
      modelUrl: '/avatar-robot/robot-b1_natura_clima.glb',
      fallbackUrl: '/avatar-robot/robot-b1_natura_clima.webp',
    },
    colegi: { // Marta, mestra: rebeca corall, brusa de coll rodó, ulleres amb cadeneta, pestanyes, llibres i poma
      modelUrl: '/avatar-robot/robot-colegi.glb',
      fallbackUrl: '/avatar-robot/robot-colegi.webp',
    },
    n0_pocio: { // Merlí, el mag (xiquets): barret punxegut, barba, túnica amb estrelles, poció i vareta màgica
      modelUrl: '/avatar-robot/robot-n0_pocio.glb',
      fallbackUrl: '/avatar-robot/robot-n0_pocio.webp',
    },
    n0_zoo: { // Carme, la cuidadora del zoo (xiquets): peto verd amb petjada, barret de pescador, plàtan i galleda amb peixos
      modelUrl: '/avatar-robot/robot-n0_zoo.glb',
      fallbackUrl: '/avatar-robot/robot-n0_zoo.webp',
    },
    n0_pati: { // Laia, xiqueta de la classe (xiquets): samarreta rosa, faldilla texana i pilota de futbol
      modelUrl: '/avatar-robot/robot-n0_pati.glb',
      fallbackUrl: '/avatar-robot/robot-n0_pati.webp',
    },
    n0_biblioteca: { // Pau, el bibliotecari (xiquets): armilla de punt amb rombes, ulleres daurades, llapis a l'orella i conte
      modelUrl: '/avatar-robot/robot-n0_biblioteca.glb',
      fallbackUrl: '/avatar-robot/robot-n0_biblioteca.webp',
    },
    b2_gent: { // Carme, presidenta de l'associació cultural: brusa amb floretes, collaret de boles, pestanyes i carpeta amb la llista
      modelUrl: '/avatar-robot/robot-b2_gent.glb',
      fallbackUrl: '/avatar-robot/robot-b2_gent.webp',
    },
    b2_estudis_treball: { // Ferran, director de RRHH (entrevista de feina): reutilitza la roba de l'oficina
      modelUrl: '/avatar-robot/robot-oficina.glb',
      fallbackUrl: '/avatar-robot/robot-oficina.webp',
    },
    b2_viatges: { // Núria, coordinadora de l'oficina de turisme de Morella: roba de guia amb el fullet de la ruta dels Ports
      modelUrl: '/avatar-robot/robot-b2_viatges.glb',
      fallbackUrl: '/avatar-robot/robot-b2_viatges.webp',
    },
    b2_menjar_salut: { // Toni, entrenador personal i dietista al gimnàs: reutilitza la roba de Toni del gimnàs
      modelUrl: '/avatar-robot/robot-a2_activitats.glb',
      fallbackUrl: '/avatar-robot/robot-a2_activitats.webp',
    },
    b2_cultura_espectacles: { // Marta, locutora de «Platea»: la roba de locutor de ràdio amb pestanyes
      modelUrl: '/avatar-robot/robot-b2_cultura_espectacles.glb',
      fallbackUrl: '/avatar-robot/robot-b2_cultura_espectacles.webp',
    },
    b2_mitjans: { // Pau, redactor en cap del diari digital: roba d'oficina amb una tauleta amb el diari
      modelUrl: '/avatar-robot/robot-b2_mitjans.glb',
      fallbackUrl: '/avatar-robot/robot-b2_mitjans.webp',
    },
    b2_politica_societat: { // Empar, regidora de participació ciutadana: reutilitza la roba de l'ajuntament
      modelUrl: '/avatar-robot/robot-ajuntament.glb',
      fallbackUrl: '/avatar-robot/robot-ajuntament.webp',
    },
    b2_actualitat: { // Héctor, divulgador científic: americana de tweed, samarreta amb un planeta i model d'àtom
      modelUrl: '/avatar-robot/robot-b2_actualitat.glb',
      fallbackUrl: '/avatar-robot/robot-b2_actualitat.webp',
    },
    b2_cultura_llengua: { // la tia Pepeta, contadora de rondalles: vestit de floretes, toquilla, monyo i ventall
      modelUrl: '/avatar-robot/robot-b2_cultura_llengua.glb',
      fallbackUrl: '/avatar-robot/robot-b2_cultura_llengua.webp',
    },
    // --- C1: roba pròpia (variants i nova) ---
    c1_relacions: { // Neus, la cosina (noces d'or dels avis): la roba del cosí Pau amb pestanyes, sense el globus
      modelUrl: '/avatar-robot/robot-c1_relacions.glb',
      fallbackUrl: '/avatar-robot/robot-c1_relacions.webp',
    },
    c1_casa: { // Vicent, arquitecte tècnic: americana camel amb plànols enrotllats
      modelUrl: '/avatar-robot/robot-c1_casa.glb',
      fallbackUrl: '/avatar-robot/robot-c1_casa.webp',
    },
    c1_temps_lliure: { // Jordi, coordinador d'activitats: la roba d'agent de viatges, sense pestanyes ni bola del món
      modelUrl: '/avatar-robot/robot-c1_temps_lliure.glb',
      fallbackUrl: '/avatar-robot/robot-c1_temps_lliure.webp',
    },
    c1_ensenyanca: { // Karim, pare nouvingut: jersei verd, camisa, rellotge i la motxilla escolar dels fills
      modelUrl: '/avatar-robot/robot-c1_ensenyanca.glb',
      fallbackUrl: '/avatar-robot/robot-c1_ensenyanca.webp',
    },
    c1_comerc: { // Rafel, antiquari del rastre: barret de feltre, armilla de tweed, riñonera i la làmpada de llautó
      modelUrl: '/avatar-robot/robot-c1_comerc.glb',
      fallbackUrl: '/avatar-robot/robot-c1_comerc.webp',
    },
    c1_medi_clima: { // Pilar, tècnica de protecció civil de l'Ajuntament: uniforme amb bandes reflectants, emblema i walkie-talkie
      modelUrl: '/avatar-robot/robot-c1_medi_clima.glb',
      fallbackUrl: '/avatar-robot/robot-c1_medi_clima.webp',
    },
    // --- C1: reutilitzen la roba d'un altre escenari ---
    c1_treball: { // Sílvia, delegada de personal: roba de Sílvia (a2_faena)
      modelUrl: '/avatar-robot/robot-a2_faena.glb',
      fallbackUrl: '/avatar-robot/robot-a2_faena.webp',
    },
    c1_alimentacio: { // Empar, xef del restaurant: roba d'Empar (a2_menjar)
      modelUrl: '/avatar-robot/robot-a2_menjar.glb',
      fallbackUrl: '/avatar-robot/robot-a2_menjar.webp',
    },
    c1_mitjans: { // Laia, directora del diari digital i del programa de ràdio: roba de locutora (b2_cultura_espectacles)
      modelUrl: '/avatar-robot/robot-b2_cultura_espectacles.glb',
      fallbackUrl: '/avatar-robot/robot-b2_cultura_espectacles.webp',
    },
    c1_salut: { // Marc, infermer: bata de la farmàcia (farmacia)
      modelUrl: '/avatar-robot/robot-farmacia.glb',
      fallbackUrl: '/avatar-robot/robot-farmacia.webp',
    },
    c1_cultura: { // Teresa, directora de la casa de cultura: roba de presidenta d'associació (b2_gent)
      modelUrl: '/avatar-robot/robot-b2_gent.glb',
      fallbackUrl: '/avatar-robot/robot-b2_gent.webp',
    },
    c1_economia: { // Sergi, tècnic de desenvolupament local: roba d'oficina (oficina)
      modelUrl: '/avatar-robot/robot-oficina.glb',
      fallbackUrl: '/avatar-robot/robot-oficina.webp',
    },
    c1_sociocultural: { // Marina, presidenta d'una associació intercultural: roba de presidenta d'associació (b2_gent)
      modelUrl: '/avatar-robot/robot-b2_gent.glb',
      fallbackUrl: '/avatar-robot/robot-b2_gent.webp',
    },
  } as Record<string, { modelUrl: string; fallbackUrl: string }>,
} as const;

export type RobotPlace = keyof typeof ROBOT_AVATAR.places;

export const isRobotAvatarEnabled = (place: RobotPlace) => ROBOT_AVATAR.enabled && ROBOT_AVATAR.places[place];

export const robotAssets = (scenario?: string) =>
  (scenario && ROBOT_AVATAR.scenarioOutfits[scenario]) ||
  { modelUrl: ROBOT_AVATAR.modelUrl, fallbackUrl: ROBOT_AVATAR.fallbackUrl };
