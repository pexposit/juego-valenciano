/**
 * Context de cada nivell per al classificador LLM (Mòdul 3: Avaluació de textos)
 * ==============================================================================
 * Resum dels «Quaderns de nivell» de la JQCV (versió 2024). De cada quadern s'agafa el
 * que servix per a jutjar la DIFICULTAT D'UN TEXT ESCRIT:
 *
 * - descriptor: descriptor global del nivell (apartat 1), resumit.
 * - comprensio_escrita: quins textos pot comprendre (objectius de comprensió escrita).
 * - expressio_escrita: quins textos pot produir (per a quan el text és d'un aprenent).
 * - linguistic: continguts lingüístics del nivell (morfosintaxi, lèxic, cohesió).
 * - frontera: pistes per a distingir-lo del nivell anterior. NO és text del quadern:
 *   és una síntesi pròpia a partir de les diferències entre quaderns consecutius.
 *
 * Les parts de comprensió oral i d'expressió oral, i els continguts de fonètica,
 * no s'inclouen perquè no es poden observar en un text escrit.
 */

export const NIVELLS = ["A1", "A2", "B1", "B2", "C1", "C2"] as const;
export type Nivell = (typeof NIVELLS)[number];

export type Grup = "Bàsic" | "Mitjà" | "Superior";

/** Grups de nivells: Bàsic (A1, A2), Mitjà (B1, B2) i Superior (C1, C2) */
export const GRUPS: Record<Nivell, Grup> = {
  A1: "Bàsic",
  A2: "Bàsic",
  B1: "Mitjà",
  B2: "Mitjà",
  C1: "Superior",
  C2: "Superior",
};

interface ContextNivell {
  nom: string;
  descriptor: string;
  comprensio_escrita: string[];
  expressio_escrita: string[];
  linguistic: string[];
  frontera: string;
}

export const CONTEXT_NIVELLS: Record<Nivell, ContextNivell> = {
  "A1": {
    "nom": "Usuari bàsic",
    "descriptor": "Domini bàsic per a atendre les necessitats comunicatives més elementals en situacions quotidianes: expressions quotidianes i familiars i frases molt senzilles; presentar-se, preguntar i respondre sobre detalls personals (a on viu, la gent que coneix, les coses que té).",
    "comprensio_escrita": [
      "Textos molt senzills i quotidians, si pot tornar a llegir-los.",
      "Textos dialogats senzills; missatges breus (una postal, un missatge de mòbil).",
      "Textos informatius molt senzills i descripcions breus, sovint amb suport visual.",
      "Indicacions escrites breus (com anar d'un lloc a un altre), rètols i cartells."
    ],
    "expressio_escrita": [
      "Frases soltes i senzilles sobre si mateix i altres persones.",
      "Omplir formularis; postals breus de felicitació."
    ],
    "linguistic": [
      "Present d'indicatiu (i algun imperfet o futur) de verbs freqüents: ser, fer, tindre, voler, poder, viure, vindre...",
      "Connectors mínims: i, o, però, perquè. Oracions simples, poques subordinades.",
      "Determinants i pronoms bàsics (article, demostratius, possessius, jo/tu/ell).",
      "Numerals de 0 a 20, hores, dies, mesos.",
      "Lèxic molt bàsic: família, professions, països, transport, menjar, roba, casa, temps lliure, esports."
    ],
    "frontera": "Enunciats d'una o dos línies, independents entre ells, amb vocabulari de supervivència i sense cohesió entre frases."
  },
  "A2": {
    "nom": "Usuari bàsic avançat",
    "descriptor": "Domini bàsic avançat per a satisfer les necessitats de comunicació elementals: frases i expressions habituals sobre temes d'importància immediata (informació personal i familiar, compres, geografia local, ocupació); intercanvis simples i directes; explicar de manera senzilla l'experiència pròpia i l'entorn immediat.",
    "comprensio_escrita": [
      "Textos breus i senzills sobre l'entorn immediat amb vocabulari molt freqüent.",
      "Notícies breus de premsa (informació bàsica); textos argumentatius senzills (identificar-ne la tesi).",
      "Textos instructius breus; textos descriptius d'objectes, llocs i persones.",
      "Documents quotidians: prospectes, menús, anuncis, horaris; cartes i correus habituals (sol·licituds, confirmacions, comandes)."
    ],
    "expressio_escrita": [
      "Textos senzills (una història, una descripció) amb connectors bàsics.",
      "Cartes o correus molt senzills per a disculpar-se, excusar-se o agrair."
    ],
    "linguistic": [
      "Indicatiu complet de verbs regulars: present, passat perifràstic (va fer), perfet, plusquamperfet, futur; condicional simple; imperatiu.",
      "Relatius bàsics (que, a on); pronoms febles de CD i CI (el, la, li, -lo...).",
      "Connectors bàsics de coordinació i subordinació (causals, temporals, condicionals, finals). Adverbis d'orde: primer, després, finalment.",
      "Lèxic de l'àmbit personal i de l'entorn: vivenda, menjar, roba, cos, viatges, festes, malalties, oratge."
    ],
    "frontera": "Respecte d'A1: ja hi ha textos continus (un paràgraf o diversos) que narren o descriuen fets quotidians amb passats i connectors bàsics. Temes concrets i pròxims; frases curtes o de subordinació simple."
  },
  "B1": {
    "nom": "Usuari independent",
    "descriptor": "Usuari independent per a les situacions socials de la vida quotidiana: comprendre les idees principals d'informació clara sobre temes generals; discurs coherent sobre temes familiars o d'interés personal, fets, experiències i projectes; donar raons i explicacions breus de les opinions.",
    "comprensio_escrita": [
      "Textos clars sobre temes generals i quotidians o del seu interés.",
      "Cartes, fullets i documents oficials curts (localitzar informació rellevant).",
      "Textos instructius senzills (indicacions, instruccions d'aparells).",
      "Punts essencials d'articles de premsa sobre temes coneguts."
    ],
    "expressio_escrita": [
      "Textos coherents per a transmetre o demanar informació general.",
      "Narrar històries; descriure esdeveniments, viatges, experiències, sentiments.",
      "Cartes i correus en un context informal o de formalitat no massa alta."
    ],
    "linguistic": [
      "Present i imperfet de subjuntiu, condicional; perífrasis d'obligació i probabilitat (haver de, deure, caldre + infinitiu).",
      "Combinació de dos pronoms febles (CI + CD). Distinció res/gens/cap.",
      "Connectors adversatius i concessius (encara que, tot i que, sinó), consecutius (doncs, per tant), temporals (mentres, sempre que) i condicionals (en cas que).",
      "Lèxic usual: treball, habitatge, trànsit, natura, oratge, esports, cultura (música, cine, teatre), diners, tecnologia; locucions i frases fetes usuals.",
      "Cohesió bàsica: connectors freqüents i mecanismes anafòrics generals."
    ],
    "frontera": "Respecte d'A2: textos informatius o divulgatius de premsa general (el temps, ofertes d'oci, ressenyes breus, anuncis de vivenda) amb opinions i valoracions, subjuntiu i connectors concessius. El contingut continua sent concret i de la vida quotidiana; l'argumentació és simple i explícita."
  },
  "B2": {
    "nom": "Usuari independent avançat",
    "descriptor": "Usuari independent avançat, amb recursos suficients per a expressar-se de manera prou precisa, fluida i correcta: comprendre les idees principals de textos complexos sobre temes concrets i abstractes; elaborar textos clars i detallats sobre una àmplia gamma de temes; exposar un punt de vista amb avantatges i inconvenients.",
    "comprensio_escrita": [
      "Textos de gèneres diversos sobre temes generals i d'especialització.",
      "Idees principals i secundàries de textos complexos, concrets i abstractes.",
      "Textos argumentatius; literatura contemporània; textos formals de l'Administració; textos especialitzats (amb diccionari); textos humorístics."
    ],
    "expressio_escrita": [
      "Redaccions, informes, articles i cartes d'opinió amb arguments a favor i en contra; ressenyes i crítiques culturals; resums de fonts diverses.",
      "Discurs clar i ben estructurat amb mecanismes de cohesió de l'escrit formal."
    ],
    "linguistic": [
      "Repertori ample que permet algunes frases complexes; pronoms febles sols i en combinacions binàries (anar-se'n, tornar-se'n).",
      "Relatius complexos (el qual, la qual cosa, cosa que); relatives explicatives i especificatives.",
      "Connectors de registre estàndard: en canvi, per contra, no obstant això, no sols... sinó, ja que, com que.",
      "Lèxic general dels àmbits docent, professional, administratiu, salut, tecnologia; polisèmia, metàfora i metonímia; frases fetes freqüents; alternatives genuïnes als barbarismes."
    ],
    "frontera": "Respecte de B1: textos més llargs i densos (ressenyes crítiques, articles d'opinió, divulgació, textos professionals o administratius) amb temes abstractes o especialitzats, lèxic menys freqüent, frases subordinades encadenades i arguments contrastats. Encara hi predomina l'estàndard neutre, amb poca ironia o sentit implícit."
  },
  "C1": {
    "nom": "Usuari experimentat",
    "descriptor": "Usuari experimentat de la varietat estàndard en situacions formals o mitjanament formals: comprendre textos extensos, clars i detallats sobre temes complexos; reconéixer registres diferents; ús controlat d'estructures organitzatives i mecanismes de cohesió.",
    "comprensio_escrita": [
      "Textos llargs i complexos: distingir idees principals i secundàries i reconéixer sentits implícits.",
      "Literatura (poesia, conte, novel·la, teatre) i diferències d'estil.",
      "Textos argumentatius i d'opinió complexos, argumentació abstracta; textos socials i professionals amb actituds de l'autor implícites.",
      "Llegir entre línies; captar l'humor, la ironia i els equívocs."
    ],
    "expressio_escrita": [
      "Textos clars, precisos i ben estructurats de diferents gèneres sobre temes complexos, amb estil personal i adequats al lector.",
      "Argumentacions elaborades amb justificacions, exemples i conclusions."
    ],
    "linguistic": [
      "Correcció normativa elevada; morfologia verbal formal (verbs purs i incoatius, formes velaritzades i no velaritzades, participis irregulars).",
      "Ús precís de connectors i de per què/perquè/per a què; perífrasis diverses.",
      "Lèxic variat, ric i precís; fraseologia genuïna (frases fetes, locucions, refranys); lèxic d'especialitat (ciència, economia, comunicació, cultura).",
      "Cohesió complexa: substitucions, pressuposicions, sobreentesos, inferències, ironia."
    ],
    "frontera": "Respecte de B2: assajos i articles d'opinió o de divulgació científica i cultural llargs, amb tesi elaborada, referències culturals, cultismes, fraseologia, incisos i subordinació complexa, i sentits implícits (ironia, posicionament de l'autor). El registre és formal i estàndard."
  },
  "C2": {
    "nom": "Usuari experimentat avançat",
    "descriptor": "Usuari experimentat avançat: espontaneïtat, flexibilitat, complexitat, fluïdesa i correcció; comprendre qualsevol text de qualsevol àmbit i registre, també en condicions no òptimes; distingir matisos subtils de significat.",
    "comprensio_escrita": [
      "Qualsevol forma de llenguatge escrit, inclosos materials de gran exigència acadèmica i cognitiva, abstractes i estructuralment complexos o rics en expressions col·loquials.",
      "Textos en varietats geogràfiques, socials i funcionals diverses.",
      "Expressions idiomàtiques, fins i tot les menys generals.",
      "Pressuposicions, sobreentesos, to (ironia, sarcasme), ambigüitats, dobles sentits, el·lipsis."
    ],
    "expressio_escrita": [
      "Textos complexos d'estil apropiat i eficaç: articles, crítiques, projectes d'investigació, textos de formalitat alta, discursos.",
      "Reformular textos per a qualsevol destinatari, gènere o registre."
    ],
    "linguistic": [
      "Domini exhaustiu de totes les estructures, inclosos els usos normativament problemàtics i les construccions excepcionals o molt formals.",
      "Lèxic cult comú i especialitzat; neologismes, calcs, cultismes, arcaismes; metàfores lexicalitzades; connotació i canvis de registre intencionats.",
      "Reformulacions i nominalitzacions pròpies del discurs acadèmic i periodístic.",
      "Semàntica pragmàtica: pressuposicions, inferències, ironia, usos figurats (metàfora, metonímia, sinècdoque)."
    ],
    "frontera": "Respecte de C1: textos assagístics, filosòfics o acadèmics d'alta densitat conceptual (referències a autors i corrents de pensament, abstracció sostinguda), lèxic cult i poc freqüent, nominalitzacions, sintaxi molt elaborada, jocs de registre, ironia i sentits no explícits que exigixen una lectura experta."
  }
};

/** Torna la descripció d'un nivell formatada per a incloure-la en el prompt. */
export function contextNivellText(nivell: Nivell): string {
  const c = CONTEXT_NIVELLS[nivell];
  const etiqueta = nivell === NIVELLS[0] ? "Trets distintius" : "Com distingir-lo del nivell anterior";
  return [
    `### ${nivell} — ${c.nom}`,
    `Descriptor global: ${c.descriptor}`,
    "Textos que pot comprendre:",
    ...c.comprensio_escrita.map((x) => `- ${x}`),
    "Textos que pot escriure:",
    ...c.expressio_escrita.map((x) => `- ${x}`),
    "Continguts lingüístics propis del nivell:",
    ...c.linguistic.map((x) => `- ${x}`),
    `${etiqueta}: ${c.frontera}`,
  ].join("\n");
}
