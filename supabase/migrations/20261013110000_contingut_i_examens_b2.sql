-- Migració agrupada: 20261013110000_contingut_i_examens_b2
-- Conté, per ordre, les 10 migracions originals següents:
--   20261013110000_practice_fonetica_b2
--   20261013120000_practice_morfosintaxi_b2
--   20261013130000_practice_lexic_b2
--   20261013140000_llicons_fonetica_b2
--   20261013150000_llicons_morfosintaxi_b2
--   20261013160000_practice_skills_b2
--   20261013170000_exam_b2_oct2025
--   20261013180000_exam_b2_oct2024
--   20261013190000_exam_b2_oct2023
--   20261013200000_exam_b2_oct2022

-- ============================================================
-- Origen: 20261013110000_practice_fonetica_b2.sql
-- ============================================================
-- Fonètica, elocució i ortografia del B2 (Quadern B2 de la JQCV, 3.2.1). Un contingut de la
-- categoria fonetica_ortografia per a cada apartat del temari: elocució i fonètica sintàctica;
-- alfabet i grafies; síl·laba, diftong, hiat i triftong; vocals (a/e, o/u, em-/en-/es-/eix- i
-- alternances verbals); accentuació (homòfons, parònims i els quinze diacrítics); dièresi, guionet
-- i apostrofació; oclusives i labiodentals; alveolars (s sorda i sonora, c/ç, -ança/-ença,
-- -esa/-essa, gentilicis en -és); alveolars (x, cc, derivats en -s-/-ss-, -sc-); palatals;
-- laterals, nasals, ròtiques i h; majúscules i minúscules; i signes de puntuació.
-- Són recursos del nivell B2 (resources.difficulty) amb exercicis B2. Tornar a aplicar el fitxer
-- no duplica res.

CREATE TEMP TABLE practice_catalog AS
SELECT * FROM jsonb_to_recordset($data$[
  {
    "id": "09b7be43-f83f-571e-9498-785bf09dda31", "type": "b2_fon_elocucio", "sort_order": 1,
    "title": "Elocució i fonètica sintàctica", "name": "Elisions, emmudiments, vocals àtones i tòniques, grups consonàntics i sons finals",
    "content": "Vocals en contacte entre paraules (elisió, fusió i sinalefa) i altres fenòmens de fonètica sintàctica, emmudiments, articulació clara de les vocals àtones i tòniques, de les consonants i dels grups consonàntics, i sons consonàntics finals propis (juny, coll) (3.2.1).", "icon": "🗣️", "color": "#B2EBF2",
    "exercises": [
      {"q": "En la lectura en veu alta de «Esta obra és meua», com s'articula de manera natural la seqüència «esta obra»?", "o": ["[es-to-bra]: la -a àtona final s'elidix davant de la o", "[es-ta-o-bra], amb una pausa entre les dues paraules", "[es-ta-bra]: es perd la o d'«obra»"], "e": "Quan dues vocals entren en contacte entre paraules, la vocal àtona final de la primera sol elidir-se: est(a)_obra."},
      {"q": "En «mitja hora», quina vocal s'elidix normalment en la parla?", "o": ["la -a final de «mitja»", "la o d'«hora»", "cap, perquè la h separa les dues vocals"], "e": "La h és muda i no impedix el contacte vocàlic: mitj(a)_hora [mi-tjo-ra]."},
      {"q": "Com s'anomena la pèrdua d'una vocal quan entra en contacte amb la vocal inicial de la paraula següent?", "o": ["elisió", "sinalefa", "geminació"], "e": "Elisió: una de les dues vocals desapareix en la pronunciació, com en quinz(e)_anys o est(a)_obra."},
      {"q": "Com s'anomena el fenomen pel qual dues vocals de paraules diferents es pronuncien en una sola síl·laba sense que se'n perda cap?", "o": ["sinalefa", "elisió", "dièresi"], "e": "En la sinalefa les dues vocals es mantenen però s'agrupen en una sola síl·laba; en l'elisió, en canvi, una de les vocals desapareix."},
      {"q": "Quan es reflectix per escrit, amb apòstrof, l'elisió d'una vocal?", "o": ["Bàsicament en l'article, la preposició «de» i els pronoms febles: l'home, d'aigua, m'ha dit", "Sempre que dues vocals es troben en contacte", "Mai: l'elisió només és oral"], "e": "En la parla s'elidixen moltes vocals (quinz(e) anys, un(a) amiga), però per escrit només s'apostrofen l'article, «de» i els pronoms febles."},
      {"q": "Quina d'estes expressions presenta en la parla una elisió que NO es reflectix en l'escriptura?", "o": ["una amiga", "l'amiga", "d'Alacant"], "e": "En «una amiga» la -a final s'elidix en la pronunciació [u-na-mi-ga], però s'escriu sencera. En «l'amiga» i «d'Alacant» l'elisió s'indica amb apòstrof."},
      {"q": "En la parla, quina d'estes frases presenta una elisió vocàlica entre paraules?", "o": ["Ho farem este any.", "Ho farem este mes.", "Ho farem demà."], "e": "Est(e)_any: la -e àtona final s'elidix davant de la vocal inicial d'«any». En les altres frases no hi ha dues vocals en contacte."},
      {"q": "En «Va arribar ahir», com s'articula «va arribar»?", "o": ["Les dues a es fonen en una sola: [va-rri-bar]", "S'afig una consonant entre les dues a", "Es fa una pausa entre «va» i «arribar»"], "e": "Quan es troben dues vocals iguals, es fonen en una sola: v(a)_arribar."},
      {"q": "En «dos amics», com sona la s final de «dos»?", "o": ["sonora [z], perquè va davant de vocal: [do-za-mics]", "sorda [s], igual que en «dos llibres»", "no es pronuncia"], "e": "Fonètica sintàctica: la -s final es fa sonora quan la paraula següent comença per vocal: dos_amics, els_ulls, tres_anys."},
      {"q": "En quina d'estes expressions la s final de la primera paraula sona sonora [z]?", "o": ["els homes", "els llibres", "dos pans"], "e": "La h és muda: «els homes» es pronuncia [el-zo-mes]. Davant de consonant sorda, com en «dos pans», la s és sorda."},
      {"q": "En «un pa» o «un bou», com s'articula normalment la n?", "o": ["com una m: [um-pa], [um-bou]", "com una ny", "no es pronuncia gens"], "e": "Davant de p, b i m, la n s'assimila a la consonant bilabial següent i sona [m]: un_pa, un_bou."},
      {"q": "En quina paraula la p no es pronuncia en una dicció normal?", "o": ["prompte", "rapte", "capçal"], "e": "En el grup mpt la p s'emmudix: prompte, compte, assumpte. En «rapte» i «capçal» sí que sona."},
      {"q": "En «assumpte», quina consonant s'emmudix?", "o": ["la p", "la m", "la t"], "e": "Assumpte es pronuncia [a-sum-te]: la p no sona, però s'escriu, com en «prompte» o «compte»."},
      {"q": "En quina parella de paraules s'emmudix la consonant final en totes dues?", "o": ["llamp / tomb", "cap / club", "llop / àrab"], "e": "Després de m, la p i la b finals no es pronuncien: llamp [llam], tomb [tom]. En «cap», «club», «llop» o «àrab» la consonant final sona [p]."},
      {"q": "En «comptable» i «descomptar», la p...", "o": ["no es pronuncia, com en «compte»", "es pronuncia sempre", "es pronuncia [b]"], "e": "Els derivats de «compte» mantenen l'emmudiment: comptar, comptable, descomptar [des-kon-tar]."},
      {"q": "En «ahir» i «prohibir», com s'ha de pronunciar la h?", "o": ["No es pronuncia: [a-ír], [pro-i-bir]", "Sona aspirada", "Sona com una g suau"], "e": "La h és muda en valencià, tant a principi de paraula com entre vocals: home, ahir, vehicle, prohibir."},
      {"q": "Quantes vocals tòniques diferents distingix el valencià estàndard?", "o": ["set", "cinc", "huit"], "e": "a, e oberta, e tancada, i, o oberta, o tancada i u. En posició àtona en distingix cinc: a, e, i, o, u."},
      {"q": "En posició àtona, el valencià estàndard distingix...", "o": ["cinc vocals: a, e, i, o, u", "només tres vocals", "set vocals, igual que en posició tònica"], "e": "Les vocals àtones són a, e, i, o, u: cal pronunciar-les clarament i distingir, per exemple, la a i la e àtones (pare / para)."},
      {"q": "Com s'ha de pronunciar la -a àtona final de «casa» o «taula» en l'estàndard oral?", "o": ["com una [a] clara", "com una o oberta", "com una e oberta"], "e": "Encara que en alguns parlars la -a final s'obri o es tanque, el model estàndard demana una [a] ben articulada: ca-sa, tau-la."},
      {"q": "Quina parella de paraules es distingix només per la vocal àtona final?", "o": ["pare / para", "pare / mare", "pare / pares"], "e": "Pare (el progenitor) i para (del verb parar) només es diferencien per la vocal àtona final: cal articular clarament [e] i [a]."},
      {"q": "En «perquè» i «també», les vocals tòniques són...", "o": ["una e oberta (è) i una e tancada (é)", "dues e tancades", "dues e obertes"], "e": "L'accent greu indica e oberta (perquè, què) i l'agut, e tancada (també, només)."},
      {"q": "Quina d'estes paraules té una e tònica oberta?", "o": ["època", "anglés", "café"], "e": "È-po-ca porta accent greu: e oberta. Anglés i café tenen e tancada, marcada amb accent agut."},
      {"q": "Quina d'estes paraules té una e tònica tancada?", "o": ["conéixer", "mèrit", "cèntim"], "e": "Conéixer porta é (tancada) en valencià; mèrit i cèntim tenen è (oberta)."},
      {"q": "Quina d'estes paraules té una o tònica oberta?", "o": ["mòbil", "cançó", "lliçó"], "e": "Mò-bil: o oberta, marcada amb accent greu. Les paraules agudes en -ó (cançó, lliçó, camió) tenen o tancada."},
      {"q": "Com sona la x d'«exacte»?", "o": ["[gz], sonora", "[ks], sorda", "[ʃ], com en «caixa»"], "e": "Ex- seguit de vocal sona [gz]: exacte, exemple, exercici, examen."},
      {"q": "Com sona la x d'«excursió»?", "o": ["[ks], sorda", "[gz], sonora", "[ʃ], com en «caixa»"], "e": "Ex- seguit de consonant sona [ks]: excursió, explicar, extern."},
      {"q": "Com s'articula «pròxim»?", "o": ["[prò-ksim], amb [ks]", "[prò-sim], amb una s simple", "[prò-ʃim], com en «caixa»"], "e": "La x de pròxim, taxi o fax sona [ks]: no s'ha de reduir a [s]."},
      {"q": "En «accident», com sona el grup cc?", "o": ["[ks]: ac-ci-dent", "[s], com una sola c", "[k], com una sola k"], "e": "Davant de e, i, el grup cc es pronuncia [ks]: accent, accident, lecció."},
      {"q": "Com s'articula correctament «excel·lent»?", "o": ["[ek-sel-lent], amb [ks] i una l geminada", "[e-se-lent], sense [k] i amb una l simple", "[ek-se-llent], amb una ll palatal"], "e": "Cal articular el grup [ks] de la x i les dues l de la l·l, repartides entre dues síl·labes: ex-cel-lent."},
      {"q": "Quina és la pronunciació estàndard d'«arbre»?", "o": ["[ar-bre], articulant les dues r", "[a-bre]", "[ar-be]"], "e": "Cal pronunciar tots els sons dels grups consonàntics: ar-bre, so-bre, pro-pi. La pèrdua de r és col·loquial."},
      {"q": "En «poble», «moble» o «sable», com s'articula el grup bl?", "o": ["dins de la mateixa síl·laba, sense afegir-hi cap vocal: po-ble", "afegint una vocal entre la b i la l: po-be-le", "reduint-lo a una l: po-le"], "e": "Els grups de consonant + l o r (bl, pl, cl, br, tr, cr...) formen síl·laba amb la vocal següent: po-ble, so-bre, re-tre."},
      {"q": "Com s'articula el dígraf tz de «dotze»?", "o": ["com una africada sonora [dz]", "com una s sorda [s]", "com una t i una s separades per una pausa"], "e": "Tz sona [dz] africada sonora: dot-ze, tret-ze, organitzar."},
      {"q": "En quina paraula hi ha una africada palatal sorda [tʃ]?", "o": ["cotxe", "metge", "platja"], "e": "Tx representa el so sord [tʃ] (cotxe, fitxa); tg i tj representen el sonor [dʒ] (metge, platja)."},
      {"q": "Com s'ha d'articular la consonant final de «juny»?", "o": ["com una nasal palatal, igual que la ny de «canya»", "com una n simple: [jun]", "com una i: [jui]"], "e": "La ny final es pronuncia palatal: juny, any, lluny, puny. No s'ha de reduir a [n] ni a [i]."},
      {"q": "Com s'ha d'articular la consonant final de «coll»?", "o": ["com una lateral palatal, igual que la ll de «llet»", "com una l simple: [col]", "com una i: [coi]"], "e": "La ll final és palatal: coll, vell, ull. «Coll» (part del cos) i «col» (verdura) es distingixen precisament per este so."},
      {"q": "Quina parella de paraules es distingix només per la consonant final palatal / no palatal?", "o": ["fill / fil", "fill / filla", "fil / fins"], "e": "Fill (descendent) i fil (de cosir): ll final palatal enfront de l. Altres parelles: coll / col, pell / pel, tall / tal."},
      {"q": "Quina d'estes paraules acaba en el so de la ny?", "o": ["lluny", "llum", "lluna"], "e": "Lluny acaba en ny palatal; llum acaba en m, i lluna, en vocal."},
      {"q": "«Ell s'ha fet mal al ___ i no pot girar el cap.» Quina paraula, amb ll final, cal dir i escriure?", "o": ["coll", "col", "colla"], "e": "Coll és la part del cos que unix el cap amb el tronc; col és una verdura i colla, un grup de persones."},
      {"q": "Com sona el final de «maig» o «roig»?", "o": ["[tʃ], com el tx de «cotxe»", "[g], com la g de «gat»", "[ʒ], com la j de «jove»"], "e": "El dígraf ig a final de paraula sona [tʃ]: maig, roig, mig, lleig."},
      {"q": "En «Hui fa molt de fred», com sona la d final de «fred»?", "o": ["sorda, com una [t]", "sonora, com la d de «dau»", "no sona mai"], "e": "Les oclusives finals es pronuncien sordes: fred [fret], àrab [à-rap]."},
      {"q": "Com sona la consonant final de «feliç», «braç» o «dolç»?", "o": ["[s] sorda", "[k]", "[ts]"], "e": "La ç final sona com una s sorda: feliç, braç, dolç."},
      {"q": "Escriu la consonant que s'escriu però no es pronuncia en «prompte».", "a": ["p"], "e": "Prompte [pron-te]: la p del grup mpt s'emmudix."},
      {"q": "Escriu la lletra que no es pronuncia mai en «ahir».", "a": ["h"], "e": "La h és muda: ahir [a-ír]."},
      {"q": "Escriu la paraula que es distingix de «fil» només per la consonant final palatal i que vol dir 'descendent directe'.", "a": ["fill"], "e": "Fill: ll final palatal."},
      {"q": "Escriu en xifra quantes vocals àtones distingix el valencià estàndard.", "a": ["5", "cinc"], "e": "Cinc: a, e, i, o, u."}
    ]
  },
  {
    "id": "aaf89354-182f-5e69-b28c-ccb108d3a312", "type": "b2_fon_alfabet", "sort_order": 2,
    "title": "Alfabet i grafies", "name": "Ç, l·l i ü, dígrafs, geminacions i grups consonàntics",
    "content": "Ús de les lletres modificades (ç, l·l, ü) i simples, dels dígrafs (rr, ss, ll, ny, qu, gu, ig, ix, tx, tg, tj, tz) i de les geminacions (mm, nn, l·l), i diferència entre dígraf, grup consonàntic i geminació (3.2.1).", "icon": "🔤", "color": "#FFE0B2",
    "exercises": [
      {"q": "Davant de quines vocals s'escriu la ç?", "o": ["a, o, u", "e, i", "davant de qualsevol vocal"], "e": "La ç s'escriu davant de a, o, u (plaça, forçós, açò) i a final de paraula; davant de e, i s'escriu c."},
      {"q": "Quina d'estes formes està MAL escrita?", "o": ["caçes", "caces", "caçador"], "e": "Davant de e, i, la ç es convertix en c: caçar → caces, cace. En «caçador» va davant de a i es manté."},
      {"q": "«Vull que tu ___ la reunió a les deu.» (començar)", "o": ["comences", "començes", "comenzes"], "e": "Començar → comences, comence: davant de e la ç passa a c."},
      {"q": "Quin és el plural de «feliç»?", "o": ["feliços", "felices", "felissos"], "e": "Feliç → feliços: la ç es manté davant de o."},
      {"q": "Quin és el diminutiu correcte de «plaça»?", "o": ["placeta", "plaçeta", "plasseta"], "e": "Plaça → placeta: davant de e, c i no ç."},
      {"q": "Quina sèrie de paraules acabades en ç està ben escrita?", "o": ["dolç, calç, braç", "dols, cals, bras", "dolc, calc, brac"], "e": "La ç també apareix a final de paraula: dolç, calç, braç, feliç."},
      {"q": "Quina paraula s'escriu amb l·l?", "o": ["intel·ligent", "inteligent", "intelligent"], "e": "Intel·ligent, intel·lectual: l·l, amb punt volat."},
      {"q": "Quina sèrie de cultismes amb l·l està ben escrita?", "o": ["col·laborar, il·lustre, satèl·lit", "col·laborar, ilustre, satèl·lit", "colaborar, il·lustre, satèlit"], "e": "Col·laborar, il·lustre i satèl·lit porten l·l."},
      {"q": "Quina d'estes paraules s'escriu amb una sola l (i no amb l·l)?", "o": ["molècula", "cèl·lula", "pel·lícula"], "e": "Molècula porta una l simple; cèl·lula i pel·lícula, l·l."},
      {"q": "Quina és la forma correcta del nom derivat d'«instal·lar»?", "o": ["instal·lació", "instalació", "instal·lacció"], "e": "Instal·lar, instal·lació: l·l."},
      {"q": "Quina és la forma correcta de l'adjectiu derivat de «cristall»?", "o": ["cristal·lí", "cristallí", "cristalí"], "e": "Cristall s'escriu amb ll, però els cultismes derivats porten l·l: cristal·lí, cristal·litzar."},
      {"q": "On pot aparéixer la l·l dins d'una paraula?", "o": ["Només entre vocals", "També a principi de paraula", "També a final de paraula"], "e": "La l·l sempre va entre vocals: al·lusió, mil·lenni, tranquil·la."},
      {"q": "Quin és el plural de «llengua»?", "o": ["llengües", "llengues", "llenguas"], "e": "Davant de e, i, cal dièresi perquè la u sone: llengua → llengües (igual que aigua → aigües)."},
      {"q": "Per què «qüestió» porta dièresi?", "o": ["Perquè la u es pronuncia davant de e", "Perquè hi ha hiat entre la u i la e", "Perquè és una paraula aguda"], "e": "La dièresi sobre la u de qü i gü indica que la u sona: qüestió, freqüent, pingüí."},
      {"q": "Quin és el femení plural d'«antic»?", "o": ["antigues", "antiques", "antigas"], "e": "Antic → antiga → antigues: davant de e, el so [g] s'escriu gu."},
      {"q": "«Vol que jo ___ la porta.» (tocar)", "o": ["toque", "toce", "toqüe"], "e": "Tocar → toque: davant de e, el so [k] s'escriu qu (sense dièresi, perquè la u no sona)."},
      {"q": "«Espera que jo ___ el sopar.» (pagar)", "o": ["pague", "page", "pagüe"], "e": "Pagar → pague: davant de e, el so [g] s'escriu gu."},
      {"q": "Quin és el femení de «lleig»?", "o": ["lletja", "lleja", "lleiga"], "e": "El dígraf -ig final alterna amb tj davant de a: lleig → lletja, mig → mitja."},
      {"q": "Quin és el femení de «roig»?", "o": ["roja", "rotja", "roiga"], "e": "Roig → roja, boig → boja; en canvi, lleig → lletja, mig → mitja."},
      {"q": "Quina sèrie amb els dígrafs tj i tg està ben escrita?", "o": ["platja, mitjó, rellotge", "platja, mitjó, rellotje", "platge, mitjó, rellotge"], "e": "Tj davant de a, o, u (platja, mitjó); tg davant de e, i (rellotge, metge)."},
      {"q": "Quin és el femení de «metge»?", "o": ["metgessa", "metja", "metgesa"], "e": "Metge → metgessa: tg davant de e i ss entre vocals."},
      {"q": "«Nosaltres ___ molt a l'estiu.» (viatjar)", "o": ["viatgem", "viatjem", "viagem"], "e": "Davant de e, i, tj es convertix en tg: viatjar → viatgem, viatgeu."},
      {"q": "Quina sèrie de verbs amb el so [dʒ] està ben escrita?", "o": ["menjar, viatjar, desitjar", "metjar, viatjar, desitjar", "menjar, viajar, desitjar"], "e": "Menjar s'escriu amb j (darrere de n); viatjar i desitjar, amb tj entre vocals."},
      {"q": "Quina d'estes paraules NO porta el dígraf tz?", "o": ["quinze", "setze", "dotze"], "e": "Quinze i catorze porten z sola (darrere de consonant); onze, dotze, tretze i setze, tz."},
      {"q": "Quin verb està ben escrit?", "o": ["analitzar", "analisar", "analizar"], "e": "El sufix verbal és -itzar: analitzar, organitzar, utilitzar."},
      {"q": "Quina sèrie amb el dígraf tx està ben escrita?", "o": ["cotxe, fitxa, butxaca", "cotxe, fitxa, buxaca", "coxe, fitxa, butxaca"], "e": "Entre vocals, el so [tʃ] s'escriu tx: cotxe, fitxa, butxaca."},
      {"q": "Quina paraula està ben escrita (so [tʃ] darrere de consonant)?", "o": ["planxa", "plantxa", "planixa"], "e": "Darrere de consonant s'escriu x (no tx ni ix): planxa, panxa, marxa."},
      {"q": "Quina paraula està ben escrita (so [ʃ] darrere de vocal)?", "o": ["baixar", "baxar", "batxar"], "e": "Darrere de vocal, el so [ʃ] s'escriu normalment ix: baixar, caixa, peix."},
      {"q": "Quina forma amb el dígraf ny està ben escrita?", "o": ["companyia", "compania", "compañia"], "e": "El so nasal palatal s'escriu amb el dígraf ny: companyia, senyor, canya."},
      {"q": "Quina d'estes paraules porta ll (palatal) i no l·l?", "o": ["bellesa", "excel·lència", "al·lusió"], "e": "Bellesa (de bell) porta ll; excel·lència i al·lusió porten l·l."},
      {"q": "Quina sèrie amb s sorda entre vocals està ben escrita?", "o": ["professor, possible, passeig", "profesor, posible, paseig", "professor, posible, passeig"], "e": "Entre vocals, el so [s] sord s'escriu ss: professor, possible, passeig."},
      {"q": "Quina és la forma correcta (r forta darrere de n)?", "o": ["honrat", "honrrat", "onrrat"], "e": "Darrere de n, l o s, la r sona forta però s'escriu simple: honrat, Enric, Israel."},
      {"q": "Quina paraula té una geminació (dues consonants iguals que es pronuncien totes dues)?", "o": ["connectar", "carrer", "massa"], "e": "Con-nec-tar: les dues n sonen. En «carrer» i «massa», rr i ss són dígrafs que representen un sol so."},
      {"q": "Quina és la forma correcta del substantiu derivat d'«immigrar»?", "o": ["immigració", "imigració", "inmigració"], "e": "Prefix in- + migració → immigració: davant de m, el prefix s'escriu im- i resulta mm."},
      {"q": "Quina és la forma correcta de l'adjectiu contrari de «mòbil»?", "o": ["immòbil", "inmòbil", "imòbil"], "e": "Im- + mòbil: immòbil, amb geminació de m."},
      {"q": "Quina és la forma correcta del verb que vol dir 'emocionar, impressionar'?", "o": ["commoure", "comoure", "conmoure"], "e": "Com- + moure: commoure, commoció, amb mm."},
      {"q": "Quina diferència hi ha entre la rr de «carro» i la nn d'«innat»?", "o": ["rr és un dígraf (un sol so); nn és una geminació (dos sons)", "Totes dues són dígrafs", "Totes dues són geminacions"], "e": "Un dígraf són dues lletres per a un sol so (carro); en la geminació es pronuncien dos sons iguals (in-nat)."},
      {"q": "Quina d'estes paraules conté alhora un grup consonàntic i un dígraf?", "o": ["estrella", "carro", "pare"], "e": "Estrella: str és un grup de consonants que sonen totes, i ll és un dígraf."},
      {"q": "Quantes lletres i quants sons té «guerra»?", "o": ["6 lletres i 4 sons", "6 lletres i 5 sons", "6 lletres i 6 sons"], "e": "Gu i rr són dígrafs: gu-e-rr-a, 4 sons."},
      {"q": "Quantes lletres i quants sons té «metge»?", "o": ["5 lletres i 4 sons", "5 lletres i 5 sons", "4 lletres i 4 sons"], "e": "Tg és un dígraf amb un sol so: m-e-tg-e."},
      {"q": "Quantes lletres i quants sons té «senyor»?", "o": ["6 lletres i 5 sons", "6 lletres i 6 sons", "5 lletres i 5 sons"], "e": "Ny és un dígraf: s-e-ny-o-r."},
      {"q": "Escriu el femení de «mig».", "a": ["mitja"], "e": "Mig → mitja."},
      {"q": "Escriu el plural de «llengua».", "a": ["llengües"], "e": "Llengües, amb dièresi."},
      {"q": "Escriu correctament la paraula: «inmigrant».", "a": ["immigrant"], "e": "Immigrant: mm."},
      {"q": "Escriu la forma de «viatjar» per a «nosaltres» en present d'indicatiu.", "a": ["viatgem"], "e": "Viatgem: tj → tg davant de e."}
    ]
  },
  {
    "id": "45d2ad5c-c9be-5ec6-abb9-af0a19b6e80b", "type": "b2_fon_sillaba", "sort_order": 3,
    "title": "Síl·laba, diftong, hiat i triftong", "name": "Diftongs i hiats, separació sil·làbica amb dígrafs, triftongs i imperfets com feia",
    "content": "Ortografia i pronunciació de diftongs i hiats, separació en síl·labes de paraules amb dígrafs (car-ro, ca-llar, ca-nya), triftongs i pronunciació normativa de l'imperfet d'indicatiu (feia, reies) (3.2.1).", "icon": "🔊", "color": "#C5CAE9",
    "exercises": [
      {"q": "Quina d'estes paraules té hiat i no diftong?", "o": ["piano", "aire", "quatre"], "e": "Fora dels grups gu i qu, una i o una u seguides de vocal formen hiat: pi-a-no. Aire té el diftong decreixent ai; quatre, el creixent ua."},
      {"q": "Quantes síl·labes té «diari»?", "o": ["3: di-a-ri", "2: dia-ri", "4: di-a-r-i"], "e": "I + vocal forma hiat: di-a-ri."},
      {"q": "Com se separa «suau»?", "o": ["su-au", "suau", "sua-u"], "e": "Hi ha hiat entre la u i la a, i després el diftong decreixent au: su-au."},
      {"q": "Com se separa «juliol»?", "o": ["ju-li-ol", "ju-liol", "jul-iol"], "e": "La i seguida de o forma hiat: ju-li-ol (3 síl·labes)."},
      {"q": "Com se separa «quotidià»?", "o": ["quo-ti-di-à", "qu-o-ti-dià", "quo-ti-dià"], "e": "Quo fa diftong creixent (qu + o), però i + à forma hiat: quo-ti-di-à."},
      {"q": "Com se separa «pingüí»?", "o": ["pin-güí", "pin-gü-í", "ping-üí"], "e": "Gü + vocal forma diftong creixent: pin-güí."},
      {"q": "Com se separa «lingüística»?", "o": ["lin-güís-ti-ca", "lin-gü-ís-ti-ca", "ling-üís-ti-ca"], "e": "Güi forma diftong creixent; la dièresi indica que la u sona: lin-güís-ti-ca."},
      {"q": "Com se separa «cooperar»?", "o": ["co-o-pe-rar", "coo-pe-rar", "co-op-e-rar"], "e": "Dues vocals iguals seguides formen hiat: co-o-pe-rar."},
      {"q": "Quina d'estes paraules té un diftong creixent?", "o": ["qüestió", "piano", "suau"], "e": "Qüe: la u forma diftong creixent amb la e. Els diftongs creixents només es donen darrere de g o q (qua, quo, gua, güe, qüe...)."},
      {"q": "Com se separa «ciutat»?", "o": ["ciu-tat", "ci-u-tat", "ciut-at"], "e": "Iu és un diftong decreixent: ciu-tat."},
      {"q": "Com se separa «cauen»?", "o": ["ca-uen", "cau-en", "ca-u-en"], "e": "La u entre vocals fa de consonant i va amb la vocal següent: ca-uen, cre-uen."},
      {"q": "Com se separa «iogurt»?", "o": ["io-gurt", "i-o-gurt", "iog-urt"], "e": "A principi de paraula, la i seguida de vocal fa de consonant: io-gurt, ia-ia."},
      {"q": "Quina forma és correcta?", "o": ["heroïna", "heroina", "heroína"], "e": "He-ro-ï-na: la dièresi marca el hiat i evita que oi es llija com a diftong."},
      {"q": "Quina és la forma correcta de l'imperfet d'«agrair» (ell...)?", "o": ["agraïa", "agraia", "agraíà"], "e": "A-gra-ï-a: la dièresi indica que la i és vocal i forma síl·laba pròpia."},
      {"q": "Per què «traduir» no porta dièresi però «traduïa» sí?", "o": ["Perquè en l'infinitiu, el gerundi, el futur i el condicional no s'escriu dièresi encara que hi haja hiat", "Perquè «traduir» té diftong i «traduïa» té hiat", "Perquè «traduïa» és una paraula aguda"], "e": "En els verbs en -uir no es posa dièresi en l'infinitiu (traduir), el gerundi (traduint), el futur (traduiré) ni el condicional (traduiria)."},
      {"q": "Quina forma del gerundi de «construir» està ben escrita?", "o": ["construint", "construïnt", "construínt"], "e": "En el gerundi no es posa dièresi: construint, traduint, agraint."},
      {"q": "Quantes síl·labes té «Lluís»?", "o": ["2: Llu-ís", "1: Lluís", "3: Ll-u-ís"], "e": "L'accent sobre la i marca hiat: Llu-ís. En canvi, «Lluïsa» porta dièresi: Llu-ï-sa."},
      {"q": "Quina separació és correcta?", "o": ["car-ro, ca-llar, ca-nya", "ca-rro, cal-lar, can-ya", "car-ro, cal-lar, ca-nya"], "e": "La rr se separa (car-ro), però la ll i la ny no se separen mai (ca-llar, ca-nya)."},
      {"q": "Com se separa «arreglar»?", "o": ["ar-re-glar", "a-rre-glar", "arr-e-glar"], "e": "La rr es reparteix entre dues síl·labes; el grup gl va amb la vocal següent: ar-re-glar."},
      {"q": "Com se separa «rellotge»?", "o": ["re-llot-ge", "rel-lot-ge", "re-llo-tge"], "e": "La ll no se separa; el dígraf tg sí: re-llot-ge."},
      {"q": "Com se separa «ensenyar»?", "o": ["en-se-nyar", "en-sen-yar", "ens-e-nyar"], "e": "La ny no se separa: en-se-nyar."},
      {"q": "Com se separa «esquerra»?", "o": ["es-quer-ra", "esq-uer-ra", "es-que-rra"], "e": "Qu no se separa; rr sí: es-quer-ra."},
      {"q": "Com se separa «professor»?", "o": ["pro-fes-sor", "pro-fe-ssor", "prof-es-sor"], "e": "La ss es reparteix entre dues síl·labes: pro-fes-sor."},
      {"q": "Com se separa «intel·ligent»?", "o": ["in-tel-li-gent", "in-te-l·li-gent", "int-el-li-gent"], "e": "La l·l se separa i el punt volat desapareix: in-tel-li-gent."},
      {"q": "Com se separa «desitjar»?", "o": ["de-sit-jar", "de-si-tjar", "des-it-jar"], "e": "El dígraf tj se separa: de-sit-jar."},
      {"q": "Com se separa «organitzar»?", "o": ["or-ga-nit-zar", "or-ga-ni-tzar", "org-a-nit-zar"], "e": "El dígraf tz se separa: or-ga-nit-zar."},
      {"q": "Com se separa «paella»?", "o": ["pa-e-lla", "pae-lla", "pa-el-la"], "e": "Entre a i e hi ha hiat, i la ll no se separa: pa-e-lla."},
      {"q": "Com se separa «llengua»?", "o": ["llen-gua", "llen-gu-a", "lleng-ua"], "e": "Gu + a forma diftong creixent i no se separa: llen-gua."},
      {"q": "Quina d'estes separacions és INCORRECTA?", "o": ["me-tge", "fet-ge", "jut-ge"], "e": "El dígraf tg es reparteix entre dues síl·labes: met-ge, fet-ge, jut-ge."},
      {"q": "Què és un triftong?", "o": ["Una vocal entre dues semivocals dins d'una mateixa síl·laba", "Tres vocals en síl·labes diferents", "Tres consonants seguides"], "e": "En un triftong, una vocal va precedida i seguida d'una semivocal en la mateixa síl·laba: guai-tar, Pa-ra-guai."},
      {"q": "Quina d'estes paraules conté un triftong?", "o": ["guaitar", "teatre", "aigua"], "e": "Guai-tar: u + a + i en una sola síl·laba. Aigua té dos diftongs en síl·labes diferents (ai-gua); teatre té hiat."},
      {"q": "Com se separa «Paraguai»?", "o": ["Pa-ra-guai", "Pa-ra-gua-i", "Pa-ra-gu-ai"], "e": "Uai forma un triftong i no se separa: Pa-ra-guai."},
      {"q": "Quantes síl·labes té «Uruguai»?", "o": ["3: U-ru-guai", "4: U-ru-gua-i", "5: U-ru-gu-a-i"], "e": "U-ru-guai: el triftong uai forma una sola síl·laba."},
      {"q": "Quantes síl·labes té «adeqüeu» (del verb adequar)?", "o": ["3: a-de-qüeu", "4: a-de-qü-eu", "5: a-de-qü-e-u"], "e": "Ueu és un triftong: a-de-qüeu. La dièresi indica que la u sona."},
      {"q": "Com se separa «guaita»?", "o": ["guai-ta", "gu-ai-ta", "gua-i-ta"], "e": "Guai-ta: triftong uai en una sola síl·laba."},
      {"q": "Quina és la pronunciació normativa de «feia»?", "o": ["[fe-ia], pronunciant la i", "[fe-a], sense la i", "[fi-a]"], "e": "L'imperfet de fer, riure, creure, veure, traure, caure... es pronuncia mantenint la i: fe-ia, re-ia, cre-ia. Les reduccions [fea] o [fia] són col·loquials."},
      {"q": "«Quan te contava el conte, sempre te ___.» (riure, imperfet)", "o": ["reies", "ries", "reïes"], "e": "Riure: jo reia, tu reies, ell reia. La i és consonant entre vocals: re-ies."},
      {"q": "Quantes síl·labes té «creia»?", "o": ["2: cre-ia", "3: cre-i-a", "1: creia"], "e": "La i entre vocals fa de consonant i va amb la vocal següent: cre-ia, fe-ia, ve-ia."},
      {"q": "«Quan era xicotet, sempre ___ de la bici.» (caure)", "o": ["queia", "caïa", "quea"], "e": "Caure: queia, queies, queia (que-ia). Cal pronunciar i escriure la i."},
      {"q": "Quina és la forma de l'imperfet d'indicatiu de «traure» (ella...)?", "o": ["treia", "traïa", "trea"], "e": "Traure: treia, treies, treia (tre-ia)."},
      {"q": "Quina forma de l'imperfet de «dur» és correcta (ell...)?", "o": ["duia", "dua", "duïa"], "e": "Dur: duia, duies, duia (du-ia). La i entre vocals és consonant i no porta dièresi."},
      {"q": "Separa en síl·labes «rellotge» (amb guionets).", "a": ["re-llot-ge"], "e": "Re-llot-ge."},
      {"q": "Separa en síl·labes «Paraguai» (amb guionets).", "a": ["pa-ra-guai"], "e": "Pa-ra-guai: triftong."},
      {"q": "Separa en síl·labes «feien» (amb guionets).", "a": ["fe-ien"], "e": "Fe-ien: la i entre vocals va amb la síl·laba següent."},
      {"q": "Separa en síl·labes «intel·ligent» (amb guionets).", "a": ["in-tel-li-gent"], "e": "In-tel-li-gent."}
    ]
  },
  {
    "id": "b004d5f9-8e24-551b-955f-8357e5c18b0b", "type": "b2_fon_vocals", "sort_order": 4,
    "title": "Vocals: a/e, o/u i alternances", "name": "Confusions a/e i o/u, la e inicial (em-, en-, es-, eix-) i alternances vocàliques en els verbs",
    "content": "Confusió de vocals a/e (avaria, afaitar) i o/u (cobert, Joan, Josep), la e de les paraules usuals començades per em-, en-, es-, eix- i les alternances e/i, o/u en els verbs irregulars (llig/llegim, ixes/eixim, puc/pot, vullga/volia) (3.2.1).", "icon": "🅰️", "color": "#FFCCBC",
    "exercises": [
      {"q": "«El cotxe va patir una ___ en l'autopista i el vam haver de dur al taller.»", "o": ["avaria", "averia", "avería"], "e": "Avaria s'escriu amb a en la segona síl·laba (i avariar, avariat)."},
      {"q": "«El meu avi s'___ cada matí abans d'eixir de casa.»", "o": ["afaita", "afeita", "afeta"], "e": "Afaitar: jo m'afaite, ell s'afaita."},
      {"q": "Quina sèrie de la família d'«afaitar» està ben escrita?", "o": ["afaitar, afaitada, afaitadora", "afeitar, afeitada, afeitadora", "afaitar, afeitada, afaitadora"], "e": "Tota la família de paraules manté la a: afaitar, afaitada, afaitadora."},
      {"q": "Quina forma és correcta per a dir 'cosa extraordinària, prodigi'?", "o": ["meravella", "maravilla", "meravilla"], "e": "Meravella (i meravellós, meravellar-se) s'escriu amb e en la primera síl·laba."},
      {"q": "Quina forma és correcta per a dir 'fill del germà o de la germana'?", "o": ["nebot", "nabot", "nebod"], "e": "Nebot (i neboda) s'escriu amb e."},
      {"q": "Quina forma és correcta per al nom d'este peix salat?", "o": ["bacallà", "bacallá", "bacellà"], "e": "Bacallà: a en totes les síl·labes i accent greu en la a final."},
      {"q": "Quina forma és correcta per al nom d'esta hortalissa?", "o": ["espàrrec", "espàrrac", "espárrec"], "e": "Espàrrec: la vocal àtona final és e."},
      {"q": "Quina forma és correcta per a dir 'part per on s'agafa una ferramenta'?", "o": ["mànec", "mànic", "mànag"], "e": "Mànec (d'una ferramenta o d'un ganivet)."},
      {"q": "Quina forma és correcta per al nom d'esta planta tèxtil?", "o": ["cànem", "cànam", "càneme"], "e": "Cànem: planta tèxtil i el teixit que se'n fa."},
      {"q": "«La sala estava ___ de gent i no cabia ningú més.» (cobrir)", "o": ["coberta", "cuberta", "cobierta"], "e": "Cobrir → cobert, coberta: s'escriu amb o, igual que descobert o coberts (de taula)."},
      {"q": "Quina sèrie de la família de «cobrir» està ben escrita?", "o": ["cobert, descobert, coberta", "cubert, descubert, cuberta", "cobert, descubert, coberta"], "e": "Tota la família de cobrir s'escriu amb o: cobert, descobert, coberta, cobertor."},
      {"q": "Quin és el femení de «Joan»?", "o": ["Joana", "Juana", "Jouana"], "e": "Joan, Joana: s'escriuen amb o encara que la o àtona sovint sone [u]."},
      {"q": "Quina frase està ben escrita?", "o": ["Josep i Joan són cosins.", "Jusep i Joan són cosins.", "Josep i Juan són cosins."], "e": "Els noms valencians Josep i Joan s'escriuen amb o."},
      {"q": "Quina forma és correcta per a dir 'elevació gran del terreny'?", "o": ["muntanya", "montanya", "muntaña"], "e": "Muntanya s'escriu amb u, a diferència del castellà «montaña»."},
      {"q": "Quina forma és correcta per a dir 'fer allò que s'ha promés o manat'?", "o": ["complir", "cumplir", "cumplir-se"], "e": "Complir (i compliment) s'escriu amb o."},
      {"q": "«Durant la reunió van ___ problemes inesperats.»", "o": ["sorgir", "surgir", "sorguir"], "e": "Sorgir s'escriu amb o en la primera síl·laba."},
      {"q": "Quina forma és correcta per a dir 'cansar-se d'una cosa que no interessa'?", "o": ["avorrir-se", "aburrir-se", "avurrir-se"], "e": "Avorrir-se (i avorrit, avorriment): amb o."},
      {"q": "Quina sèrie de paraules amb o àtona està ben escrita?", "o": ["conill, botifarra, rovell", "cunill, botifarra, rovell", "conill, butifarra, ruvell"], "e": "Conill, botifarra i rovell s'escriuen amb o en la primera síl·laba."},
      {"q": "Quina forma és correcta per a dir 'publicació periòdica oficial'?", "o": ["butlletí", "botlletí", "butletí"], "e": "Butlletí s'escriu amb u i amb el grup tll."},
      {"q": "Quina sèrie de paraules començades per em-, en- i es- està ben escrita?", "o": ["embastar, entendre, estendre", "ambastar, entendre, astendre", "embastar, antendre, estendre"], "e": "Les paraules usuals començades per em-, en- i es- s'escriuen amb e: embastar, entendre, estendre."},
      {"q": "«Abans de cosir la vora, la modista va ___ els pantalons amb punts llargs.»", "o": ["embastar", "ambastar", "imbastar"], "e": "Embastar: cosir provisionalment amb punts llargs."},
      {"q": "«No ___ res del que m'has explicat.» (entendre)", "o": ["entenc", "antenc", "intenc"], "e": "Entendre (jo entenc, ell entén): en- inicial amb e."},
      {"q": "«Quan acabe la rentadora, ___ la roba al terrat.» (estendre)", "o": ["estendré", "astendré", "estenderé"], "e": "Estendre: futur estendré. Comença per es-, amb e."},
      {"q": "«Si no t'___ bé els cabells, et refredaràs.» (eixugar)", "o": ["eixugues", "aixugues", "ixugues"], "e": "Eixugar: eix- inicial amb e (eixugue, eixugues)."},
      {"q": "Quina sèrie de paraules començades per em- i en- està ben escrita?", "o": ["embolicar, enganxar, ensenyar", "ambolicar, enganxar, ensenyar", "embolicar, anganxar, ansenyar"], "e": "Em- i en- inicials s'escriuen amb e: embolicar, enganxar, ensenyar, enfonsar."},
      {"q": "Quina sèrie de paraules començades per eix- està ben escrita?", "o": ["eixam, eixamplar, eixut", "aixam, eixamplar, eixut", "eixam, aixamplar, aixut"], "e": "Eix- inicial: eixam, eixamplar, eixut, eixida."},
      {"q": "Quina d'estes paraules comença per a, i no per e, en valencià?", "o": ["ampolla", "embolic", "enrere"], "e": "Algunes paraules comencen per am- o an-: ampolla, ample, ambaixada. Embolic i enrere comencen per e."},
      {"q": "Quina forma és correcta per a dir 'objecte on ens mirem'?", "o": ["espill", "aspill", "ispill"], "e": "Espill: les paraules començades per es- s'escriuen amb e (espill, escala, esquena)."},
      {"q": "«Jo ___ el diari, però vosaltres no el ___ mai.» (llegir)", "o": ["llig / llegiu", "lleg / lligiu", "llig / lligiu"], "e": "Alternança e/i: amb l'accent sobre la radical, i (llig, lliges, lligen); en posició àtona, e (llegim, llegiu)."},
      {"q": "Quina forma de «llegir» és correcta?", "o": ["nosaltres llegim", "nosaltres lligim", "nosaltres lligem"], "e": "Llegim: la radical és àtona i apareix la e."},
      {"q": "«Tu sempre ___ tard de la faena, però nosaltres ___ a les cinc.» (eixir)", "o": ["ixes / eixim", "eixes / ixim", "ixes / ixim"], "e": "Eixir: isc, ixes, ix, ixen (radical tònica, i); eixim, eixiu (radical àtona, e)."},
      {"q": "Quina és la forma de l'imperatiu d'«eixir» per a «tu»?", "o": ["ix", "eix", "eixi"], "e": "Ix d'ací! L'imperatiu de tu coincidix amb la 3a persona del present: ell ix."},
      {"q": "Quina forma d'«eixir» és correcta?", "o": ["ells ixen", "ells eixen", "ells ixin"], "e": "Ixen: la radical és tònica i apareix la i (ix, ixes, ixen)."},
      {"q": "«Jo no ___ vindre, però ella sí que ___.» (poder)", "o": ["puc / pot", "poc / put", "pot / puc"], "e": "Poder: jo puc, tu pots, ell pot. Alternança u/o."},
      {"q": "«Espere que ___ vindre a la festa.» (poder, tu)", "o": ["pugues", "pogues", "podes"], "e": "Subjuntiu de poder: puga, pugues, puga, puguem."},
      {"q": "«Quan era jove, ___ ser metge, però ara no ho ___ de cap manera.» (voler, jo)", "o": ["volia / vull", "vullia / vull", "volia / vol"], "e": "Voler: imperfet volia (o àtona); present jo vull (u)."},
      {"q": "«Ho faré tant si ell ho ___ com si no.» (voler, subjuntiu)", "o": ["vullga", "volga", "vulga"], "e": "Subjuntiu de voler: vullga, vullgues, vullga."},
      {"q": "«Ma tia ___ tota la roba de la família, però nosaltres no ___ mai.» (cosir)", "o": ["cus / cosim", "cos / cusim", "cus / cusim"], "e": "Cosir: jo cus, ell cus, ells cusen; nosaltres cosim, vosaltres cosiu."},
      {"q": "Quina forma de «tossir» és correcta?", "o": ["ell tus", "ell tos", "ell tossix"], "e": "Tossir: jo tus, ell tus, ells tussen; nosaltres tossim."},
      {"q": "Quina forma d'«escopir» és correcta?", "o": ["ell escup", "ell escop", "ell escupix"], "e": "Escopir: jo escup, ell escup; nosaltres escopim."},
      {"q": "Quin d'estos verbs NO presenta alternança vocàlica o/u?", "o": ["fugir (fuig, fugim)", "collir (cull, collim)", "cosir (cus, cosim)"], "e": "Fugir manté la u en tota la conjugació; collir i cosir alternen u (tònica) / o (àtona)."},
      {"q": "Escriu correctament el verb: «___ la roba al sol» (eixugar o aixugar).", "a": ["eixugar"], "e": "Eixugar, amb eix-."},
      {"q": "Escriu la forma de «llegir» per a «nosaltres» en present d'indicatiu.", "a": ["llegim"], "e": "Llegim: e en posició àtona."},
      {"q": "Escriu la forma d'«eixir» per a «tu» en present d'indicatiu.", "a": ["ixes"], "e": "Ixes: i en posició tònica."},
      {"q": "Escriu correctament la paraula que vol dir 'fallada o desperfecte d'una màquina' (averia o avaria).", "a": ["avaria"], "e": "Avaria."}
    ]
  },
  {
    "id": "e4add91b-d25b-525c-9f87-6c121452c753", "type": "b2_fon_accentuacio", "sort_order": 5,
    "title": "Accentuació: homòfons, parònims i diacrítics", "name": "Homòfons i parònims (patí/pati, mitjà/mitja, mà/ma/m'ha) i els quinze accents diacrítics",
    "content": "Accentuació d'homòfons i parònims del vocabulari general segons les regles d'agudes, planes i esdrúixoles, i ús dels quinze accents diacrítics vigents (bé, déu, és, mà, més, món, pèl, què, sé, sí, sòl, són, té, ús, vós) (3.2.1).", "icon": "✒️", "color": "#F8BBD0",
    "exercises": [
      {"q": "Completa: «Ella sempre ___ lleva molt d'hora: ___ una persona molt disciplinada.»", "o": ["es ... és", "és ... es", "és ... és"], "e": "És (verb ser) porta accent diacrític; es (pronom feble) no: «es lleva», «és disciplinada»."},
      {"q": "Completa: «Ho ha explicat tan ___ que tots ho hem entés a la primera.»", "o": ["bé", "be", "bè"], "e": "Bé (adverbi; també nom: «el bé comú») porta accent diacrític; be (corder, nom de la lletra b) no."},
      {"q": "Completa: «En el ramat hi havia un ___ negre que no volia seguir el pastor.»", "o": ["be", "bé", "bè"], "e": "Be (l'animal, el corder) no porta accent; bé (adverbi o nom: «fer el bé») sí."},
      {"q": "Completa: «Neptú era el ___ romà del mar.»", "o": ["déu", "deu", "dèu"], "e": "Déu (divinitat; Déu, amb majúscula, en el monoteisme) porta accent diacrític; deu (numeral o verb deure) no."},
      {"q": "Completa: «Encara em ___ els diners del sopar de dissabte.»", "o": ["deu", "déu", "dèu"], "e": "Deu, del verb deure (o el numeral 10), no porta accent; déu (divinitat) sí."},
      {"q": "Completa: «Dona'm la ___, que creuarem el carrer.»", "o": ["mà", "ma", "m'ha"], "e": "Mà (part del cos) porta accent diacrític; ma és el possessiu àton («ma mare») i m'ha és pronom + verb haver."},
      {"q": "Completa: «___ germana ___ regalat un rellotge.»", "o": ["Ma ... m'ha", "Mà ... m'ha", "Ma ... ma"], "e": "Ma (possessiu: ma germana) sense accent; m'ha (em + ha: pronom i verb haver) amb apòstrof. Mà, amb accent, és la part del cos."},
      {"q": "Completa: «El ___ que ve tindrem ___ temps lliure.»", "o": ["mes ... més", "més ... mes", "més ... més"], "e": "Mes (part de l'any) no porta accent; més (quantitat, comparació) sí."},
      {"q": "Completa: «___ pare ha viatjat per tot el ___.»", "o": ["Mon ... món", "Món ... mon", "Món ... món"], "e": "Mon (possessiu àton: mon pare) no porta accent; món (el planeta, la gent) sí."},
      {"q": "Completa: «No té ni un ___ de ximple; ha vingut ___ camí més curt.»", "o": ["pèl ... pel", "pel ... pèl", "pèl ... pèl"], "e": "Pèl (cabell, borrissol) porta accent obert; pel és la contracció de per + el."},
      {"q": "Completa: «No sé ___ vols dir amb això.»", "o": ["què", "que", "qué"], "e": "Què tònic (interrogatiu, directe o indirecte) porta accent obert; que àton (conjunció o relatiu) no."},
      {"q": "Completa: «Este és el llibre de ___ et vaig parlar.»", "o": ["què", "que", "qué"], "e": "Darrere de preposició, el relatiu és tònic i s'escriu què: de què, amb què, en què."},
      {"q": "Completa: «Diu ___ vindrà demà a primera hora.»", "o": ["que", "què", "qué"], "e": "Conjunció àtona que introduïx una subordinada: no porta accent."},
      {"q": "Completa: «—___ no has vingut a la reunió? —___ estava malalt.»", "o": ["Per què ... Perquè", "Perquè ... Per què", "Per què ... Per què"], "e": "Per què (preposició + interrogatiu tònic) pregunta la causa; perquè (conjunció) la respon."},
      {"q": "Completa: «Jo no ___ conduir, però mon germà ___ compra un cotxe nou.»", "o": ["sé ... se", "se ... sé", "sé ... sé"], "e": "Sé (verb saber) porta accent diacrític; se (pronom feble) no: «se compra»."},
      {"q": "Completa: «___ plou, no eixirem; però ell ha dit que ___, que vindrà igualment.»", "o": ["Si ... sí", "Sí ... si", "Si ... si"], "e": "Si (conjunció condicional) no porta accent; sí (adverbi d'afirmació) sí."},
      {"q": "Completa: «El ___ d'esta comarca és molt fèrtil i el regadiu dona bones collites.»", "o": ["sòl", "sol", "sól"], "e": "Sòl (terra, superfície on es trepitja) porta accent obert; sol (l'astre, «sense companyia», la nota musical) no."},
      {"q": "Completa: «Ha vingut ___, sense els amics.»", "o": ["sol", "sòl", "sól"], "e": "Sol (adjectiu: sense companyia) no porta accent; sòl (terra, paviment) sí."},
      {"q": "Completa: «Ja ___ les dotze i tinc molta ___.»", "o": ["són ... son", "son ... són", "són ... són"], "e": "Són (verb ser) porta accent diacrític; son (ganes de dormir; possessiu: son pare) no."},
      {"q": "Completa: «Ell ___ un examen demà; ja ___ l'he dit.»", "o": ["té ... te", "te ... té", "té ... té"], "e": "Té (verb tindre/tenir) porta accent diacrític; te (pronom feble) no."},
      {"q": "Completa: «Este diccionari és d'___ diari a la redacció.»", "o": ["ús", "us", "üs"], "e": "Ús (acció d'usar) porta accent diacrític; us (pronom feble: us ho dic) no."},
      {"q": "Quina frase té els diacrítics ben posats?", "o": ["Us agrairé que feu un bon ús de la sala.", "Ús agrairé que feu un bon us de la sala.", "Us agrairé que feu un bon us de la sala."], "e": "Us (pronom feble) sense accent; ús (nom) amb accent."},
      {"q": "Completa: «Senyor alcalde, ___ ja ho sabíeu?»", "o": ["vós", "vos", "vòs"], "e": "Vós (pronom personal tònic de respecte) porta accent diacrític; vos (pronom feble) no."},
      {"q": "Completa: «Demà ___ ho portaré tot a casa.»", "o": ["vos", "vós", "vòs"], "e": "Vos és pronom feble (davant del verb) i no porta accent; vós és el pronom tònic de respecte."},
      {"q": "Segons la normativa vigent, quina d'estes paraules porta accent diacrític?", "o": ["pèl (cabell)", "dona (del verb donar)", "net (fill del fill)"], "e": "Només hi ha quinze diacrítics: bé, déu, és, mà, més, món, pèl, què, sé, sí, sòl, són, té, ús, vós. «Dona» i «net» ja no en porten."},
      {"q": "Completa: «Ella sempre ___ la raó als altres.» (donar)", "o": ["dona", "dóna", "dòna"], "e": "La normativa vigent ha suprimit l'accent de «dóna»: ella dona, igual que el nom «dona»."},
      {"q": "Completa: «Al mercat ___ fruita fresca cada dia.» (vendre, ells)", "o": ["venen", "vénen", "vènen"], "e": "Venen (de vendre o de venir) ja no porta accent diacrític."},
      {"q": "Completa: «El gos rosegava un ___ al jardí.»", "o": ["os", "ós", "òs"], "e": "Os, tant la part de l'esquelet com l'animal, s'escriu sense accent: ja no és un diacrític."},
      {"q": "Completa: «El meu ___ ja té cinc anys.» (fill del meu fill)", "o": ["net", "nét", "nèt"], "e": "Net (fill del fill; també 'que no està brut') s'escriu sense accent d'ençà de la normativa vigent."},
      {"q": "Completa: «Vosaltres sempre ___ el que voleu.» (fer)", "o": ["feu", "féu", "fèu"], "e": "Feu no porta accent: l'antic diacrític de «féu» s'ha suprimit."},
      {"q": "Quina sèrie està escrita segons la normativa vigent?", "o": ["dona, venen, os, net, sec, molt", "dóna, vénen, ós, nét, séc, mòlt", "dona, vénen, os, nét, sec, molt"], "e": "Estes paraules han perdut l'accent diacrític antic: dona, venen, os, net, sec (de seure), molt (de moldre), vens, adeu."},
      {"q": "Completa: «Els alumnes juguen al ___ durant l'esplai.»", "o": ["pati", "patí", "pàti"], "e": "Pati (espai obert d'un edifici) és pla acabat en vocal: sense accent. Patí (calçat amb rodes o fulla) és agut acabat en vocal: amb accent."},
      {"q": "Completa: «Per a patinar necessite un ___ nou: el vell té una roda trencada.»", "o": ["patí", "pati", "pàti"], "e": "Pa-TÍ: paraula aguda acabada en vocal, porta accent. No s'ha de confondre amb pati (PA-ti)."},
      {"q": "Completa: «La televisió és un ___ de comunicació de masses.»", "o": ["mitjà", "mitja", "mítja"], "e": "Mitjà (agut: instrument, recurs; adjectiu 'del mig') porta accent. Mitja (pla) és 'meitat' o la peça de roba."},
      {"q": "Completa: «Arribaré a les cinc i ___.»", "o": ["mitja", "mitjà", "mitjá"], "e": "Mitja (MI-tja, plana acabada en vocal): sense accent. Mitjà, aguda, és un altre mot."},
      {"q": "Completa: «Hem estudiat els castells de l'Edat ___.»", "o": ["Mitjana", "Mitjà", "Mitja"], "e": "El femení de l'adjectiu mitjà és mitjana: Edat Mitjana, classe mitjana. Mitja és un altre mot (meitat; peça de roba)."},
      {"q": "Completa: «La ___ de l'empresa m'ha enviat el contracte.» (persona)", "o": ["secretària", "secretaria", "secretária"], "e": "Secretària (persona) porta accent; secretaria (oficina: «la secretaria del centre») és plana acabada en vocal i no en porta."},
      {"q": "Completa: «Ella ___ els seus poemes en una revista ___.»", "o": ["publica ... pública", "pública ... publica", "pública ... pública"], "e": "Publica (verb, plana acabada en vocal) sense accent; pública (adjectiu, esdrúixola) amb accent."},
      {"q": "Completa: «L'atleta ___ entrenant-se cada dia; és una activitat ___.»", "o": ["continua ... contínua", "contínua ... continua", "contínua ... contínua"], "e": "Continua (verb, con-ti-NU-a) és plana acabada en vocal; contínua (adjectiu, con-TÍ-nu-a) porta accent."},
      {"q": "Completa: «Demà la soprano ___ en el Palau de la Música.»", "o": ["cantarà", "cantara", "càntara"], "e": "Cantarà (futur) és aguda acabada en vocal i porta accent; cantara (imperfet de subjuntiu: «si cantara») és plana i no en porta."},
      {"q": "Escriu el nom que significa 'cabell, borrissol' (homòfon de «pel»).", "a": ["pèl"], "e": "Pèl porta accent diacrític obert per a distingir-lo de pel (per + el)."},
      {"q": "Escriu el nom, amb l'accent que calga, en «Fes un bon ___ del diccionari».", "a": ["ús"], "e": "Ús (acció d'usar) porta accent diacrític; us (pronom feble) no."},
      {"q": "Escriu el verb ser (ells) en «Ja ___ les deu».", "a": ["són"], "e": "Són (verb ser) porta accent diacrític; son (ganes de dormir, possessiu) no."},
      {"q": "Escriu el verb saber (jo) en «No ___ on he deixat les claus».", "a": ["sé"], "e": "Sé (verb saber) porta accent diacrític; se (pronom feble) no."},
      {"q": "Escriu el femení de l'adjectiu «mitjà» (la classe ___).", "a": ["mitjana"], "e": "Mitjà / mitjana; mitja és un altre mot (meitat, peça de roba)."}
    ]
  },
  {
    "id": "3efdb0cc-f803-5b84-a0bc-c3836f6a8d7d", "type": "b2_fon_dieresi_guionet", "sort_order": 6,
    "title": "Dièresi, guionet i apostrofació", "name": "Dièresi en güe/güi/qüe/qüi, en hiats i en verbs en -air, -eir, -uir; guionet en numerals i pronoms; apostrofació",
    "content": "Normes generals de la dièresi (grups güe, güi, qüe, qüi; hiats; verbs de la tercera conjugació en -air, -eir, -oir, -uir i excepcions), del guionet (numerals, verb i pronom, compostos) i de l'apostrofació de l'article, de la preposició de i dels pronoms febles (3.2.1).", "icon": "🔗", "color": "#D1C4E9",
    "exercises": [
      {"q": "Quina forma és correcta?", "o": ["llengües", "llengues", "llengúes"], "e": "Güe: la dièresi indica que la u es pronuncia (llengua → llengües). Sense dièresi, «gue» sonaria com en «guerra»."},
      {"q": "Quina forma és correcta?", "o": ["qüestió", "questió", "qüèstió"], "e": "Qüe: la u sona i cal dièresi: qüestió, qüestionari."},
      {"q": "Completa: «La ___ dels autobusos és poc ___.»", "o": ["freqüència ... freqüent", "frequència ... frequent", "freqüència ... frequent"], "e": "En freqüent i freqüència la u es pronuncia davant de e: cal dièresi en totes dues."},
      {"q": "En quina d'estes paraules NO s'ha de posar dièresi?", "o": ["guerra", "pingüí", "aigües"], "e": "En guerra la u no sona (gue = [ge]). En pingüí i aigües la u es pronuncia i porta dièresi."},
      {"q": "Quina forma és correcta?", "o": ["lingüística", "linguística", "lingüistica"], "e": "Lin-güís-ti-ca: dièresi en güi perquè la u sona, i accent en la í perquè és esdrúixola."},
      {"q": "Completa: «La meua ___ m'ha regat les plantes.» (femení de veí)", "o": ["veïna", "veina", "veína"], "e": "Ve-ï-na: la i tònica fa hiat, però la paraula és plana acabada en vocal i no porta accent; per això la dièresi marca l'hiat."},
      {"q": "Quin és el plural de «veí»?", "o": ["veïns", "veins", "veíns"], "e": "Ve-ïns: aguda acabada en -ins, no porta accent; la dièresi marca l'hiat."},
      {"q": "Quina forma és correcta?", "o": ["heroïna", "heroína", "heroina"], "e": "He-ro-ï-na: hiat en una plana acabada en vocal; es marca amb dièresi."},
      {"q": "Quina parella és correcta?", "o": ["país / països", "paìs / paísos", "país / paísos"], "e": "L'accent preval sobre la dièresi: país porta accent (aguda acabada en vocal + s). En el plural, pa-ï-sos és plana i cal dièresi."},
      {"q": "Quina forma és correcta?", "o": ["Raül", "Raul", "Raúl"], "e": "Ra-ül: aguda acabada en -l, no pot portar accent; la dièresi marca l'hiat."},
      {"q": "Quina forma és correcta?", "o": ["altruisme", "altruïsme", "altruísme"], "e": "No es posa dièresi en els sufixos -isme i -ista: altruisme, egoisme, egoista."},
      {"q": "Quina forma és correcta?", "o": ["coincidir", "coïncidir", "coíncidir"], "e": "Darrere de prefix (co-, re-, anti-, contra-...) no es posa dièresi: coincidir, coincidència."},
      {"q": "Completa: «La directora vol ___ el claustre demà.»", "o": ["reunir", "reünir", "reunír"], "e": "Re- és un prefix: no es posa dièresi (reunir, reunió). A més, és un infinitiu."},
      {"q": "Quina forma és correcta?", "o": ["antiinflamatori", "antiïnflamatori", "anti-ïnflamatori"], "e": "Darrere del prefix anti- no es posa dièresi i el prefix s'escriu junt: antiinflamatori."},
      {"q": "Completa: «Abans, ell ___ textos llatins cada dia.» (traduir, imperfet)", "o": ["traduïa", "traduia", "traduía"], "e": "Tra-du-ï-a: hiat en l'imperfet; es marca amb dièresi (traduïa, construïa, agraïa)."},
      {"q": "Completa: «Demà ___ la carta al francés.» (traduir, jo)", "o": ["traduiré", "traduïré", "tradüiré"], "e": "El futur, el condicional, l'infinitiu i el gerundi dels verbs en -air, -eir, -oir, -uir no porten dièresi: traduiré, traduiria."},
      {"q": "Completa: «Estic ___ un article de premsa.» (traduir, gerundi)", "o": ["traduint", "traduïnt", "traduínt"], "e": "El gerundi no porta dièresi: traduint, construint, agraint."},
      {"q": "Completa: «Ja hem ___ el llibre.» (traduir, participi)", "o": ["traduït", "traduit", "traduìt"], "e": "Tra-du-ït: el participi porta dièresi (traduït, traduïda), a diferència de l'infinitiu i el gerundi."},
      {"q": "Completa: «Ella sempre ___ les normes del centre.» (obeir)", "o": ["obeïx", "obeix", "obeíx"], "e": "O-be-ïx: aguda acabada en -x, sense accent; la dièresi marca l'hiat (obeïx, traduïx, construïx)."},
      {"q": "Completa: «Vos ___ molt la vostra ajuda.» (agrair, nosaltres)", "o": ["agraïm", "agraim", "agraím"], "e": "A-gra-ïm: aguda acabada en -m, sense accent; cal dièresi."},
      {"q": "Quina sèrie de formes de «construir» és correcta?", "o": ["construir, construint, construiré, construïa", "construïr, construïnt, construiré, construïa", "construir, construint, construïré, construia"], "e": "Infinitiu, gerundi, futur i condicional sense dièresi; imperfet, participi i formes amb hiat, amb dièresi: construïa, construït."},
      {"q": "Completa: «Jo ___ el poema l'any passat.» (traduir, passat simple)", "o": ["traduí", "traduï", "tradüí"], "e": "Tra-du-Í: aguda acabada en vocal, porta accent. L'accent preval sobre la dièresi."},
      {"q": "Com s'escriu 45?", "o": ["quaranta-cinc", "quarantacinc", "quaranta i cinc"], "e": "Entre desenes i unitats es posa guionet: quaranta-cinc, setanta-huit."},
      {"q": "Completa amb lletres: «Té ___ anys.» (21)", "o": ["vint-i-un", "vint i un", "vintiun"], "e": "Desenes i unitats unides per -i- amb guionets: vint-i-un, vint-i-tres."},
      {"q": "Completa amb lletres: «Hi havia ___ persones.» (300)", "o": ["tres-centes", "trescentes", "tres centes"], "e": "Unitats i centenes van unides amb guionet: tres-centes, dos-cents."},
      {"q": "Com s'escriu 1999?", "o": ["mil nou-cents noranta-nou", "mil-nou-cents-noranta-nou", "mil noucents noranta nou"], "e": "Guionet entre unitats i desenes i entre unitats i centenes; mil, cents i desenes se separen amb espai."},
      {"q": "Com s'escriu 568?", "o": ["cinc-cents seixanta-huit", "cinc cents seixanta huit", "cinc-cents-seixanta-huit"], "e": "Cinc-cents (guionet), seixanta-huit (guionet); entre centena i desena, espai."},
      {"q": "Completa: «Este llibre, ___ ara mateix.» (donar, imperatiu tu + a mi + el)", "o": ["dona-me'l", "dona'm-el", "dona-me-el"], "e": "Pronoms darrere del verb: guionet entre el verb i el primer pronom i apòstrof quan cal: dona-me'l, porta-me'ls."},
      {"q": "Completa: «Has d'___ abans que es faça fosc.» (anar + te + en)", "o": ["anar-te'n", "anar't-en", "anar-te-n"], "e": "Anar-te'n: guionet entre verb i pronom; en s'apostrofa darrere de te."},
      {"q": "Quina frase és correcta?", "o": ["Porta-li-ho demà.", "Portali-ho demà.", "Porta li ho demà."], "e": "Els pronoms febles darrere del verb s'unixen amb guionets: porta-li-ho, dir-li-ho."},
      {"q": "Completa: «Gastes massa diners ___.» (comprar + els, gerundi)", "o": ["comprant-los", "comprant'ls", "comprantlos"], "e": "Darrere de verb acabat en consonant, el pronom pren la forma plena amb guionet: comprant-los."},
      {"q": "Completa: «Les pomes, ___ ara!» (menjar, vosaltres + les)", "o": ["mengeu-les", "mengeu'les", "mengeu les"], "e": "Imperatiu + pronom feble: guionet (mengeu-les, digueu-ho)."},
      {"q": "Quina forma és correcta?", "o": ["nord-est", "nordest", "nord est"], "e": "Els compostos de punts cardinals porten guionet: nord-est, sud-oest, nord-americà."},
      {"q": "Quina forma és correcta?", "o": ["la universitat", "l'universitat", "la'universitat"], "e": "L'article la no s'apostrofa davant de i o u àtones, amb h o sense: la universitat, la humanitat, la història."},
      {"q": "Quina forma és correcta?", "o": ["l'illa", "la illa", "lo illa"], "e": "Davant de i tònica, l'article la sí que s'apostrofa: l'illa, l'Índia."},
      {"q": "Quina forma és correcta?", "o": ["el iogurt", "l'iogurt", "l iogurt"], "e": "Davant de i o u semiconsonants (iogurt, iode, hiena) l'article no s'apostrofa: el iogurt."},
      {"q": "Quina forma és correcta?", "o": ["la asimetria", "l'asimetria", "le asimetria"], "e": "L'article la no s'apostrofa davant de mots que comencen per a- privativa: la asimetria, la anormalitat."},
      {"q": "Completa: «Vull un got ___.»", "o": ["d'aigua", "de aigua", "d' aigua"], "e": "La preposició de s'apostrofa davant de vocal o h: d'aigua, d'home."},
      {"q": "Quina frase és correcta?", "o": ["M'agrada molt la música clàssica.", "Em agrada molt la música clàssica.", "Me agrada molt la música clàssica."], "e": "Davant de verb que comença per vocal, el pronom em s'apostrofa: m'agrada, t'estime, s'ha."},
      {"q": "Completa: «___ a casa, per favor.» (portar, imperatiu tu + ens)", "o": ["Porta'ns", "Porta-ens", "Portans"], "e": "Darrere de verb acabat en vocal, ens pren la forma reduïda 'ns: porta'ns, compra'ns."},
      {"q": "Escriu la 1a persona del plural del present d'indicatiu de «conduir» (nosaltres ___).", "a": ["conduïm"], "e": "Con-du-ïm: hiat marcat amb dièresi."},
      {"q": "Escriu en lletres el número 76.", "a": ["setanta-sis"], "e": "Desenes i unitats amb guionet: setanta-sis."},
      {"q": "Escriu l'infinitiu «menjar» seguit del pronom «les».", "a": ["menjar-les"], "e": "Darrere de verb acabat en consonant, forma plena amb guionet: menjar-les."},
      {"q": "Escriu el participi femení singular de «construir».", "a": ["construïda"], "e": "Cons-tru-ï-da: el participi porta dièresi."},
      {"q": "Escriu apostrofat: de + Elx.", "a": ["d'Elx"], "e": "La preposició de s'apostrofa davant de vocal: d'Elx, d'Alacant."}
    ]
  },
  {
    "id": "7c00e278-71c1-5f5b-862b-8719fca43633", "type": "b2_fon_oclusives", "sort_order": 7,
    "title": "Oclusives i labiodentals", "name": "Gerundis en -t, -itud/-etud, ab-, ob-, sub-, cap-, alternances b/p i v/u, mb i nv, oclusives finals",
    "content": "Gerundis acabats en -t, mots en -etud i -itud, grups ab-, ob-, sub- i cap-, alternança de b amb p (sap/saber) i de v amb u (neu/nevar), b darrere de m i v darrere de n, i oclusives finals en la flexió (3.2.1).", "icon": "🅱️", "color": "#C8E6C9",
    "exercises": [
      {"q": "Completa: «Va eixir ___ de casa perquè feia tard.» (córrer, gerundi)", "o": ["corrent", "corrend", "corrén"], "e": "Tots els gerundis acaben en -nt: corrent, cantant, venint."},
      {"q": "Quin és el gerundi de «dir»?", "o": ["dient", "diguent", "dicent"], "e": "Dir → dient. Recorda: els gerundis acaben sempre en -t."},
      {"q": "Completa: «Estàvem ___ la faena quan va sonar el telèfon.» (fer)", "o": ["fent", "fend", "fen"], "e": "Fer → fent. La t final s'escriu sempre, encara que en la parla a vegades no sone."},
      {"q": "Com acaben tots els gerundis en valencià?", "o": ["en -nt", "en -nd", "en -ndo"], "e": "Cantant, perdent, dormint: la terminació del gerundi és -nt."},
      {"q": "Completa: «Necessite un poc de ___ per a concentrar-me.»", "o": ["solitud", "solitut", "solitude"], "e": "Els mots en -itud i -etud s'escriuen amb d: solitud, actitud, inquietud."},
      {"q": "Quina forma és correcta?", "o": ["inquietud", "inquietut", "inquietudt"], "e": "Terminació -etud amb d: inquietud, quietud."},
      {"q": "Completa: «La ___ de València és d'uns 39 graus nord.»", "o": ["latitud", "latitut", "latitude"], "e": "Latitud, longitud, altitud, magnitud: -itud amb d."},
      {"q": "Quina parella està ben escrita?", "o": ["plenitud / virtut", "plenitut / virtud", "plenitud / virtud"], "e": "Les terminacions -itud i -etud van amb d (plenitud), però virtut, joventut i salut acaben en -tut, amb t."},
      {"q": "Quina forma és correcta?", "o": ["absurd", "apsurd", "asurd"], "e": "Prefix ab- amb b: absurd, absència, abstracte."},
      {"q": "Quina forma és correcta?", "o": ["obtindre", "optindre", "otindre"], "e": "Prefix ob- amb b: obtindre, objecte, obvi, observar."},
      {"q": "Quina forma és correcta?", "o": ["objecte", "opjecte", "ojecte"], "e": "Ob- amb b: objecte, objectiu."},
      {"q": "Quina forma és correcta?", "o": ["subratllar", "supratllar", "subraiar"], "e": "Prefix sub- amb b: subratllar, subjecte, submarí."},
      {"q": "Quina forma és correcta?", "o": ["subterrani", "supterrani", "subterràneo"], "e": "Sub- amb b: subterrani, subsòl, subdirector."},
      {"q": "Quina forma és correcta?", "o": ["capgirar", "cabgirar", "capjirar"], "e": "Compostos amb cap- s'escriuen amb p: capgirar, capficar-se, capgròs."},
      {"q": "Quina forma és correcta?", "o": ["capvespre", "cabvespre", "capbespre"], "e": "Cap + vespre: capvespre, amb p i v."},
      {"q": "Completa: «Ella ___ parlar xinés i japonés.» (saber)", "o": ["sap", "sab", "saap"], "e": "Alternança b/p: saber → sap. A final de paraula s'escriu p."},
      {"q": "Quina forma és correcta? (tossut, que té el cap gros)", "o": ["cabut", "caput", "capút"], "e": "Cap → cabut, cabota: quan la consonant queda entre vocals, apareix la b."},
      {"q": "Quin és el femení de «llop»?", "o": ["lloba", "llopa", "llova"], "e": "Llop / lloba: p final, b en el femení. «Llova» és incorrecte."},
      {"q": "Completa: «Ell ___ molts correus cada dia.» (rebre)", "o": ["rep", "reb", "rebe"], "e": "Rebre → rep: p a final de mot; b davant de vocal (rebem, rebut)."},
      {"q": "Quina parella està ben escrita?", "o": ["cub / cúbic", "cup / cúbic", "cup / cúpic"], "e": "Uns pocs mots acaben en -b: cub, tub, club, àrab, esnob."},
      {"q": "Quin és el femení de «tip» (fart)?", "o": ["tipa", "tiba", "tippa"], "e": "Tip / tipa: en este cas el femení manté la p."},
      {"q": "Completa: «Ha caigut molta ___ i continua ___.»", "o": ["neu ... nevant", "neu ... neuant", "neb ... nevant"], "e": "Alternança u/v: neu → nevar, nevada, nevant."},
      {"q": "Quin és el femení de «blau»?", "o": ["blava", "blaua", "blaba"], "e": "Blau / blava: la u final alterna amb v."},
      {"q": "Completa: «Abans ___ molta aigua.» (beure, ell, imperfet)", "o": ["bevia", "beuia", "bebia"], "e": "Beure → bevia, bevent: u alterna amb v. «Bebia» és un castellanisme gràfic."},
      {"q": "Completa: «Quan era jove, ___ a Gandia.» (viure, jo, imperfet)", "o": ["vivia", "viuia", "vibia"], "e": "Viure → vivia, vivint: la u passa a v."},
      {"q": "Completa: «Tota la setmana ___ sense parar.» (ploure, imperfet)", "o": ["plovia", "plouia", "plobia"], "e": "Ploure → plovia: alternança u/v (com moure → movia)."},
      {"q": "Quin és el femení de «nou» (no vell)?", "o": ["nova", "noua", "noba"], "e": "Nou / nova, novetat: u alterna amb v."},
      {"q": "Quina forma és correcta?", "o": ["ambició", "anbició", "amvició"], "e": "Davant de b s'escriu m: ambició, ambulància, combat."},
      {"q": "Quina forma és correcta?", "o": ["embolic", "envolic", "emvolic"], "e": "Embolic, embolicar: m + b. Compte amb la confusió amb «envoltar» (n + v)."},
      {"q": "Completa: «Viu en un antic ___ de monges.»", "o": ["convent", "combent", "conbent"], "e": "Davant de v s'escriu n: convent, conversa, enveja."},
      {"q": "Completa: «Edison va patentar molts ___.»", "o": ["invents", "imbents", "invens"], "e": "Invent, inventar: n + v."},
      {"q": "Completa: «Té ___ de la teua sort.»", "o": ["enveja", "embeja", "envexa"], "e": "Enveja, envejós: n + v."},
      {"q": "Quina paraula és una excepció, amb m davant de v?", "o": ["tramvia", "enviar", "conversa"], "e": "Davant de v s'escriu n, llevat de pocs casos com tramvia o circumval·lació."},
      {"q": "Quin és el femení de «verd»?", "o": ["verda", "verta", "vert"], "e": "Verd / verda: la d del femení es manté en el masculí."},
      {"q": "Quin és el masculí de «sorda»?", "o": ["sord", "sort", "sor"], "e": "Sord / sorda (sort és un altre mot: 'fortuna')."},
      {"q": "Quin és el femení plural de «amic»?", "o": ["amigues", "amiges", "amicues"], "e": "Amic / amiga / amigues: c final, g entre vocals i gu davant de e."},
      {"q": "Quin és el femení de «groc»?", "o": ["groga", "groca", "groja"], "e": "Groc / groga."},
      {"q": "Quin és el masculí de «neboda»?", "o": ["nebot", "nebod", "nebó"], "e": "Nebot / neboda: t final, d entre vocals."},
      {"q": "Quina parella està ben escrita?", "o": ["sec / seca", "seg / seca", "sec / sega"], "e": "Sec / seca: el femení conserva el so [k], per tant la c final."},
      {"q": "Quina forma és correcta?", "o": ["càstig", "càstic", "castic"], "e": "Càstig amb g perquè el derivat és castigar."},
      {"q": "Escriu el gerundi de «tindre».", "a": ["tenint"], "e": "Tindre/tenir → tenint, amb -t final."},
      {"q": "Escriu el masculí de «cega».", "a": ["cec"], "e": "Cec / cega: c final, g en el femení."},
      {"q": "Escriu el femení de «fred».", "a": ["freda"], "e": "Fred / freda: la d es manté."},
      {"q": "Escriu el nom acabat en -itud derivat de l'adjectiu «exacte».", "a": ["exactitud"], "e": "Exactitud, amb d final."},
      {"q": "Escriu el femení de «nebot».", "a": ["neboda"], "e": "Nebot / neboda: t final, d entre vocals."}
    ]
  },
  {
    "id": "40ba848e-85ef-5b0a-9562-da9721195d28", "type": "b2_fon_alveolars_s", "sort_order": 8,
    "title": "Alveolars: s sorda i sonora, c/ç", "name": "Sons [s] i [z], parelles mínimes, alternança c/ç, -ança/-ença, -esa/-essa i gentilicis en -és",
    "content": "Els sons alveolars fricatius sord [s] i sonor [z] i les seues grafies, discriminació de parelles (rosa/rossa, casar/caçar), alternança c/ç en la flexió, mots en -ança i -ença, mots en -esa i -essa i flexió dels gentilicis en -és (3.2.1).", "icon": "🐝", "color": "#FFE0B2",
    "exercises": [
      {"q": "Completa: «Té els cabells ___, com son pare.» (de color clar)", "o": ["rossos", "rosos", "rozos"], "e": "Ros / rossa / rossos: so sord [s] entre vocals, s'escriu ss. Rosa [z], amb s simple, és la flor."},
      {"q": "Completa: «Al jardí hi ha una ___ roja.»", "o": ["rosa", "rossa", "roza"], "e": "Rosa (flor): s sonora [z] entre vocals, una sola s."},
      {"q": "Completa: «Es van ___ a l'estiu en una ermita.»", "o": ["casar", "caçar", "cassar"], "e": "Casar (contraure matrimoni), amb s sonora [z]; caçar (perseguir animals), amb ç sorda [s]."},
      {"q": "Completa: «Els dissabtes van a ___ conills.»", "o": ["caçar", "casar", "cassar"], "e": "Caçar, amb ç: so sord [s]."},
      {"q": "Completa: «Vaig ___ per davant de ta casa i no et vaig vore.»", "o": ["passar", "posar", "pasar"], "e": "Passar (anar per un lloc), amb ss sorda; posar (col·locar) té s sonora [z]."},
      {"q": "Completa: «Em fa mal el ___ de tant recolzar-me.»", "o": ["colze", "colse", "cols"], "e": "Darrere de consonant, el so sonor [z] s'escriu z: colze, onze, esmorzar, bronze."},
      {"q": "Quina forma és correcta?", "o": ["esmorzar", "esmorsar", "esmorçar"], "e": "Esmorzar: so sonor [z] darrere de r, s'escriu z."},
      {"q": "En quina paraula hi ha una s sonora [z]?", "o": ["casa", "cassola", "pensar"], "e": "S entre vocals sona [z] (casa). Ss (cassola) i s darrere de consonant (pensar) són sordes."},
      {"q": "En quina paraula hi ha un so sord [s]?", "o": ["passeig", "cosí", "pesar"], "e": "Ss entre vocals: [s] sord (passeig). En cosí i pesar la s simple és sonora."},
      {"q": "Completa: «El meu ___ viu a Elx.» (fill de la tia)", "o": ["cosí", "cossí", "cozí"], "e": "Cosí, amb s sonora [z] entre vocals."},
      {"q": "Quina forma és correcta?", "o": ["zero", "sero", "cero"], "e": "A principi de paraula, el so sonor [z] s'escriu z: zero, zona, zebra."},
      {"q": "Quina grafia representa el so sonor [z] entre vocals?", "o": ["s", "ss", "ç"], "e": "Entre vocals: s = [z] (casa); ss, c (davant e, i) i ç (davant a, o, u) = [s]."},
      {"q": "Quina forma és correcta?", "o": ["realitzar", "realisar", "realiçar"], "e": "Els verbs en -itzar s'escriuen amb tz: realitzar, utilitzar, analitzar."},
      {"q": "Quina forma és correcta?", "o": ["organitzar", "organisar", "organizar"], "e": "-itzar: organitzar, organització."},
      {"q": "Quin és el plural de «pinça»?", "o": ["pinces", "pinçes", "pinses"], "e": "Davant de e i i s'escriu c, no ç: pinça → pinces."},
      {"q": "Quin és el plural de «braç»?", "o": ["braços", "brassos", "braçes"], "e": "Davant de o es manté la ç: braç → braços."},
      {"q": "Quin és el femení de «dolç»?", "o": ["dolça", "dolsa", "dolca"], "e": "Dolç / dolça / dolços / dolces: ç davant a, o, u i final; c davant e, i."},
      {"q": "Completa: «L'equip local ha ___ per dos gols a u.» (véncer, participi)", "o": ["vençut", "vencut", "venssut"], "e": "Véncer → vençut: davant de u cal ç per a mantindre el so [s]."},
      {"q": "Quina forma de l'infinitiu és correcta?", "o": ["véncer", "vençer", "vènçer"], "e": "Davant de e s'escriu c: véncer, convéncer (amb é tancada en valencià)."},
      {"q": "Completa: «Que no ___ la porta, per favor!» (forçar, nosaltres)", "o": ["forcem", "forçem", "forssem"], "e": "Forçar → forcem: davant de e la ç passa a c."},
      {"q": "Completa: «Demà ___ les classes.» (començar, nosaltres)", "o": ["comencem", "començem", "comensem"], "e": "Començar → comencem, comence: c davant e."},
      {"q": "Completa: «Que ___ la pilota més fort!» (llançar, ells)", "o": ["llancen", "llançen", "llansen"], "e": "Llançar → llancen: davant de e, c."},
      {"q": "Completa: «___ la iaia abans d'anar-vos-en!» (abraçar, vosaltres)", "o": ["Abraceu", "Abraçeu", "Abrasseu"], "e": "Abraçar → abraceu: c davant de e."},
      {"q": "Quina parella és correcta?", "o": ["plaça / places", "plaça / plaçes", "plasa / places"], "e": "Plaça, places: ç davant a; c davant e."},
      {"q": "Quina forma és correcta?", "o": ["esperança", "esperansa", "esperanza"], "e": "Els mots en -ança s'escriuen amb ç: esperança, confiança, venjança."},
      {"q": "Quina forma és correcta?", "o": ["aparença", "aparensa", "aparenza"], "e": "Terminació -ença amb ç: aparença, creença, naixença."},
      {"q": "Completa: «Tinc molta ___ en tu.»", "o": ["confiança", "confiansa", "confianza"], "e": "-ança amb ç: confiança."},
      {"q": "Quina d'estes paraules s'escriu correctament amb s (i no amb ç)?", "o": ["dansa", "esperansa", "semblansa"], "e": "Uns pocs mots acaben en -ansa: dansa, pansa, mansa. Però esperança i semblança, amb ç."},
      {"q": "Quina forma és correcta?", "o": ["creença", "creensa", "creenza"], "e": "-ença amb ç: creença, coneixença."},
      {"q": "Quina forma és correcta?", "o": ["bellesa", "bellessa", "belleza"], "e": "Els noms abstractes derivats d'adjectius acaben en -esa: bellesa, tristesa, riquesa."},
      {"q": "Quina forma és correcta?", "o": ["timidesa", "timidessa", "timideza"], "e": "Tímid → timidesa: -esa, amb s sonora."},
      {"q": "Completa: «La ___ de Dénia va visitar el palau.»", "o": ["marquesa", "marquessa", "marqueza"], "e": "Marqués → marquesa: els noms en -és fan el femení en -esa."},
      {"q": "Completa: «L'___ ha inaugurat el parc nou.»", "o": ["alcaldessa", "alcaldesa", "alcaldeça"], "e": "Els femenins de càrrecs i professions que no acaben en -és fan -essa: alcaldessa, jutgessa, abadessa."},
      {"q": "Completa: «La ___ m'ha receptat un xarop.»", "o": ["metgessa", "metgesa", "metjessa"], "e": "Metge → metgessa: -essa amb ss sorda."},
      {"q": "Quina forma és correcta? (dona del comte)", "o": ["comtessa", "comtesa", "condesa"], "e": "Comte → comtessa; vescomte → vescomtessa."},
      {"q": "Quina sèrie està ben escrita?", "o": ["tristesa, riquesa, duquessa, princesa", "tristessa, riquessa, duquesa, princessa", "tristesa, riquesa, duquesa, princessa"], "e": "Abstractes en -esa (tristesa); femenins de títols en -essa (duquessa), amb l'excepció de princesa."},
      {"q": "Quin és el femení plural de «xinés»?", "o": ["xineses", "xinesses", "xinesas"], "e": "Xinés, xinesa, xinesos, xineses: els gentilicis en -és fan la flexió amb s sonora."},
      {"q": "Quin és el masculí plural de «xinés»?", "o": ["xinesos", "xinessos", "xinesses"], "e": "Xinés → xinesos: s sonora [z] entre vocals."},
      {"q": "Completa: «Tinc dos amics ___.» (d'Anglaterra)", "o": ["anglesos", "anglessos", "anglesses"], "e": "Anglés, anglesa, anglesos, angleses."},
      {"q": "Quin és el femení de «portugués»?", "o": ["portuguesa", "portuguessa", "portugueça"], "e": "Gentilicis en -és: femení en -esa (portuguesa, francesa, japonesa)."},
      {"q": "Escriu el femení de «francés».", "a": ["francesa"], "e": "Francés → francesa: s sonora."},
      {"q": "Escriu el plural de «força».", "a": ["forces"], "e": "Davant de e, c: forces."},
      {"q": "Escriu el participi masculí singular de «convéncer».", "a": ["convençut"], "e": "Convéncer → convençut: ç davant de u."},
      {"q": "Escriu el femení de «jutge» (professió).", "a": ["jutgessa"], "e": "Jutge → jutgessa: -essa."},
      {"q": "Escriu en lletres el número 15.", "a": ["quinze"], "e": "Quinze, amb z: so sonor darrere de n."}
    ]
  },
  {
    "id": "7c1b8d02-5fa7-554e-bb04-ab8c70d11942", "type": "b2_fon_alveolars_x", "sort_order": 9,
    "title": "Alveolars: x, cc, derivats en -s- i -ss-, grup sc", "name": "Sons [ks] i [gz] (x, cc), derivats de mots aguts en vocal + s i grafia -sc-",
    "content": "Representació dels sons [ks] i [gz] amb x i cc (taxa, examen, acció), escriptura dels derivats de mots aguts acabats en vocal + s (gos/gossa, mes/mesos) i grafia -sc- (piscina, escena, ascens) (3.2.1).", "icon": "🔤", "color": "#B3E5FC",
    "exercises": [
      {"q": "Completa: «L'Ajuntament ha pujat la ___ de fems.»", "o": ["taxa", "tassa", "tacsa"], "e": "Taxa (impost, proporció), amb x [ks]; tassa (recipient per a beure) és un altre mot."},
      {"q": "Completa: «Vols una ___ de café amb llet?»", "o": ["tassa", "taxa", "tasa"], "e": "Tassa (recipient), amb ss; taxa (impost), amb x."},
      {"q": "Quina forma és correcta?", "o": ["examen", "esamen", "egzamen"], "e": "Ex- + vocal es pronuncia [gz] però s'escriu x: examen, exacte, exemple."},
      {"q": "Quina forma és correcta?", "o": ["exèrcit", "egzèrcit", "esèrcit"], "e": "Exèrcit: x amb so [gz]."},
      {"q": "Quina forma és correcta?", "o": ["exacte", "egzacte", "exàcte"], "e": "Exacte, exactitud: x [gz]; és plana acabada en vocal, sense accent."},
      {"q": "Com sona la x d'«exemple»?", "o": ["[gz], sonora", "[ks], sorda", "[ʃ], com en «caixa»"], "e": "Ex- seguit de vocal: [gz] (exemple, exigir, èxit)."},
      {"q": "Com sona la x de «taxi»?", "o": ["[ks]", "[gz]", "[ʃ]"], "e": "Entre vocals, en mots com taxi, fixar, tòxic o màxim, la x sona [ks]."},
      {"q": "Quina forma és correcta?", "o": ["èxit", "ègzit", "ècsit"], "e": "Èxit: x amb so [gz]; és plana acabada en -t i porta accent obert."},
      {"q": "Quina forma és correcta?", "o": ["acció", "axió", "accsió"], "e": "El so [ks] davant de i s'escriu cc en molts mots: acció, lecció, direcció."},
      {"q": "Quina d'estes paraules s'escriu amb cc?", "o": ["lecció", "reflexió", "atenció"], "e": "Lecció (cast. «lección»), amb cc. Reflexió, amb x; atenció, amb una sola c."},
      {"q": "Quina d'estes paraules s'escriu amb x (i no amb cc)?", "o": ["connexió", "direcció", "elecció"], "e": "Connexió, reflexió, flexió, annexió: x. Direcció i elecció: cc."},
      {"q": "Quina forma és correcta?", "o": ["reflexió", "reflecció", "reflexsió"], "e": "Reflexió (de reflex), amb x."},
      {"q": "Quina forma és correcta?", "o": ["direcció", "direció", "direxió"], "e": "Direcció (de director): cc."},
      {"q": "Quina forma és correcta?", "o": ["accident", "acident", "axident"], "e": "Accident, accés, accent: cc davant de e, i."},
      {"q": "Quina forma és correcta?", "o": ["objecció", "objeció", "objexió"], "e": "Objecció (d'objectar), amb cc, a diferència del castellà «objeción»."},
      {"q": "Quina forma és correcta?", "o": ["excepció", "exepció", "ecsepció"], "e": "Excepció, excel·lent, excés: grup xc."},
      {"q": "Quina forma és correcta?", "o": ["estranger", "extranger", "estrangér"], "e": "Estranger, estrany: amb s, no amb x."},
      {"q": "Quina parella és correcta?", "o": ["estendre / extensió", "extendre / extensió", "estendre / estensió"], "e": "El verb s'escriu amb s (estendre), però el nom amb x (extensió)."},
      {"q": "Quina forma és correcta?", "o": ["explicar", "esplicar", "ecsplicar"], "e": "Explicar, explicació: x."},
      {"q": "Quin és el femení de «gos»?", "o": ["gossa", "gosa", "gòssa"], "e": "Mots aguts acabats en vocal + s: si el derivat sona [s] sord, ss (gos → gossa)."},
      {"q": "Quin és el plural de «pas»?", "o": ["passos", "pasos", "passós"], "e": "Pas → passos: so sord [s], ss."},
      {"q": "Quin és el femení de «calorós»?", "o": ["calorosa", "calorossa", "caloròsa"], "e": "Calorós → calorosa: so sonor [z], s simple."},
      {"q": "Quin és el plural de «mes»?", "o": ["mesos", "messos", "meses"], "e": "Mes → mesos: so sonor [z], s simple."},
      {"q": "Quin és el plural de «procés»?", "o": ["processos", "procesos", "procéssos"], "e": "Procés → processos: so sord, ss (com progrés → progressos)."},
      {"q": "Quin és el femení de «gros»?", "o": ["grossa", "grosa", "gròsa"], "e": "Gros → grossa: [s] sorda."},
      {"q": "Quin és el plural de «pis»?", "o": ["pisos", "pissos", "pises"], "e": "Pis → pisos: [z] sonora."},
      {"q": "Quin és el plural de «interés»?", "o": ["interessos", "interesos", "interéssos"], "e": "Interés → interessos: [s] sorda, ss."},
      {"q": "Quin és el plural de «permís»?", "o": ["permisos", "permissos", "permíssos"], "e": "Permís → permisos: [z] sonora (com avís → avisos)."},
      {"q": "Quin és el plural de «arròs»?", "o": ["arrossos", "arrosos", "arròssos"], "e": "Arròs → arrossos: [s] sorda."},
      {"q": "Quin és el plural de «os» (part de l'esquelet)?", "o": ["ossos", "osos", "òssos"], "e": "Os → ossos: [s] sorda, ss."},
      {"q": "Quin és el femení de «espés»?", "o": ["espessa", "espesa", "espésa"], "e": "Espés → espessa: [s] sorda."},
      {"q": "Quina regla explica «gos/gossa» però «mes/mesos»?", "o": ["Si el derivat sona [s] s'escriu ss; si sona [z], s", "Sempre ss darrere de vocal tònica", "Sempre s en els plurals"], "e": "En els derivats de mots aguts en vocal + s, la pronúncia decidix: [s] → ss, [z] → s."},
      {"q": "Quin és el plural de «nas»?", "o": ["nassos", "nasos", "nàssos"], "e": "Nas → nassos: [s] sorda."},
      {"q": "Quina forma és correcta?", "o": ["piscina", "pissina", "picina"], "e": "Grup -sc- davant de e, i: piscina, escena, ascens."},
      {"q": "Quina forma és correcta?", "o": ["escena", "esena", "excena"], "e": "Escena, escenari: grup sc."},
      {"q": "Completa: «L'___ al cim va durar tres hores.» (pujada)", "o": ["ascens", "ascenç", "assens"], "e": "Ascens, ascensió, descens: grup sc."},
      {"q": "Quina forma és correcta?", "o": ["ascensor", "assensor", "acensor"], "e": "Ascensor, amb sc."},
      {"q": "Quina forma és correcta?", "o": ["disciplina", "disiplina", "dissiplina"], "e": "Disciplina: grup sc."},
      {"q": "Quina forma és correcta?", "o": ["adolescent", "adolecent", "adolessent"], "e": "Adolescent, adolescència: sc."},
      {"q": "Quina forma és correcta?", "o": ["conscient", "concient", "consient"], "e": "Conscient, consciència: sc."},
      {"q": "Escriu el femení de «ros».", "a": ["rossa"], "e": "Ros → rossa: [s] sorda, ss."},
      {"q": "Escriu el plural de «congrés».", "a": ["congressos"], "e": "Congrés → congressos: [s] sorda."},
      {"q": "Escriu el femení de «gris».", "a": ["grisa"], "e": "Gris → grisa: [z] sonora, s simple."},
      {"q": "Escriu el plural de «gas».", "a": ["gasos"], "e": "Gas → gasos: [z] sonora, s simple."},
      {"q": "Escriu el nom acabat en -ció derivat de «fixar».", "a": ["fixació"], "e": "Fixació, amb x [ks], com fixar."}
    ]
  },
  {
    "id": "53f521aa-eeea-5579-ad61-75e6c876df19", "type": "b2_fon_palatals", "sort_order": 10,
    "title": "Palatals: j/tj, g/tg, -tx i -ig", "name": "Flexió amb j/g i tj/tg, derivats de -tx i -ig, x/ix/tx i pronunciació palatal",
    "content": "Alternança j/tj davant de a, o, u i g/tg davant de e, i en la flexió (boja, bojos, platja; boges, platges), derivats de les paraules acabades en -tx i -ig (capritxós, despatxos; rojor, lletja), grafies x/ix/tx i pronunciació palatal sonora de j i g (3.2.1).", "icon": "🌊", "color": "#B3E5FC",
    "exercises": [
      {"q": "Quin és el femení plural de «boig»?", "o": ["boges", "bojes", "botges"], "e": "Boig, boja, bojos, boges: davant de a, o s'escriu j; davant de e, g."},
      {"q": "Completa: «Estos xiquets estan ___ per la música.» (boig, masculí plural)", "o": ["bojos", "bogos", "botjos"], "e": "Davant de o, el so [dʒ] s'escriu amb j: bojos."},
      {"q": "Completa: «Els caps de setmana de juliol els passem a les ___ del nord.»", "o": ["platges", "platjes", "plages"], "e": "Platja → platges: tj davant de a, o, u; tg davant de e, i."},
      {"q": "Quina sèrie de flexió és correcta?", "o": ["platja, platges; mitja, mitges", "platja, platjes; mitja, mitjes", "plaja, plages; mija, miges"], "e": "La grafia s'adapta a la vocal següent: tj + a, tg + e (platja/platges, mitja/mitges)."},
      {"q": "Completa: «Les teulades ___ del poble es veuen des de la muntanya.» (roig)", "o": ["roges", "rojes", "rotges"], "e": "Roig, roja, rojos, roges: g davant de e."},
      {"q": "Completa: «Les cases ___ per fora no sempre ho són per dins.» (lleig, femení plural)", "o": ["lletges", "lletjes", "lleges"], "e": "Lleig, lletja, lletges: el so allargat [ddʒ] s'escriu tj davant de a i tg davant de e."},
      {"q": "Completa: «Les ___ de tardor han omplit l'embassament.»", "o": ["pluges", "plujes", "plutges"], "e": "Pluja → pluges: davant de e, g."},
      {"q": "Completa: «Si ___ (pujar) els preus, comprarem menys.»", "o": ["pugen", "pujen", "putgen"], "e": "En la conjugació també alternen j i g: puja, pugen, pugem."},
      {"q": "Completa: «Nosaltres no ___ (jutjar) ningú per l'aparença.»", "o": ["jutgem", "jutjem", "jugem"], "e": "Jutjar → jutgem: tj davant de a, o, u; tg davant de e, i."},
      {"q": "Completa: «Vull que ___ (assajar, tu) més abans de l'estrena.»", "o": ["assages", "assajes", "assatges"], "e": "Assajar → que tu assages: davant de e, g."},
      {"q": "Completa: «No ___ (trepitjar, vosaltres) la gespa del parc.»", "o": ["trepitgeu", "trepitjeu", "trepigeu"], "e": "Trepitjar → no trepitgeu: tg davant de e."},
      {"q": "Per què «menjar» fa «mengem» i no *«menjem»?", "o": ["Perquè davant de e i i el so [dʒ] s'escriu amb g", "Perquè és un verb irregular", "Perquè la j no pot anar mai entre vocals"], "e": "És un canvi purament gràfic: menjar, menja, mengem, mengeu (com pujar → pugem)."},
      {"q": "Com es diu l'arbre que fa taronges?", "o": ["taronger", "taronjer", "tarongjer"], "e": "Taronja → taronger, tarongina: davant de e i i, g."},
      {"q": "Quina forma és correcta?", "o": ["trajecte", "tragecte", "trajete"], "e": "Excepció a la regla general: j davant de e en trajecte, objecte, projecte, subjecte."},
      {"q": "Quina sèrie només conté paraules ben escrites?", "o": ["jersei, majestat, injecció", "gersei, magestat, ingecció", "jersei, magestat, injecció"], "e": "Algunes paraules s'escriuen amb j davant de e: jersei, majestat, injecció, Jesús, objecte."},
      {"q": "Quina d'estes paraules està mal escrita?", "o": ["jeneral", "gerani", "subjecte"], "e": "La forma correcta és «general»: davant de e normalment g. «Subjecte» és una excepció amb j."},
      {"q": "En valencià estàndard, com es pronuncia la g de «gent» o de «gerro»?", "o": ["com la j de «jove»: palatal sonora [dʒ]", "com la jota castellana [x]", "com la g de «gat» [g]"], "e": "La g davant de e, i i la j representen el mateix so palatal sonor: gent, gerro, jove, juny."},
      {"q": "Quina és la pronunciació estàndard de «juliol»?", "o": ["[dʒu-li-ól], amb so palatal sonor", "[xu-li-ól], amb la jota castellana", "[ju-li-ól], amb so de i"], "e": "La jota castellana [x] no existix en valencià: j i g (davant de e, i) són palatals sonores."},
      {"q": "Quin és el nom de qualitat derivat de «lleig»?", "o": ["lletjor", "llejor", "lleigor"], "e": "Lleig → lletja, lletjor: la -ig final es convertix en tj davant de vocal."},
      {"q": "Quin adjectiu derivat de «roig» vol dir 'que tira a roig'?", "o": ["rogenc", "rojenc", "roigenc"], "e": "Roig → roja, rojor, rogenc: j davant de a, o; g davant de e."},
      {"q": "Quin és el nom derivat de «boig» que significa 'estat o acció de boig'?", "o": ["bogeria", "bojeria", "boigeria"], "e": "Boig → bogeria: davant de e, g."},
      {"q": "Quin verb derivat de «boig» vol dir 'tornar-se boig'?", "o": ["embogir", "embojir", "emboigir"], "e": "Embogir: g davant de i."},
      {"q": "Quin adjectiu deriva de «desig»?", "o": ["desitjós", "desijós", "desigós"], "e": "Desig → desitjar, desitjós: so allargat [ddʒ], escrit tj."},
      {"q": "Quin adjectiu derivat de «mig» significa 'que està al mig'?", "o": ["mitjà", "mijà", "migà"], "e": "Mig → mitja, mitjà, mitjana."},
      {"q": "Quin és el verb derivat d'«assaig»?", "o": ["assajar", "assatjar", "assaigar"], "e": "Assaig → assajar: so simple [dʒ], escrit j."},
      {"q": "Quin adjectiu deriva d'«enuig»?", "o": ["enutjós", "enujós", "enuigós"], "e": "Enuig → enutjar, enutjós: tj."},
      {"q": "Com es diu un bosc de faigs?", "o": ["fageda", "fajeda", "faigeda"], "e": "Faig → fageda: davant de e, g."},
      {"q": "Completa: «L'aigua ___ de la font sense parar.» (verb derivat de «raig»)", "o": ["raja", "ratja", "raiga"], "e": "Raig → rajar: l'aigua raja."},
      {"q": "Per què «lleig» fa «lletja», però «roig» fa «roja»?", "o": ["Perquè en «lletja» el so palatal és allargat [ddʒ] i en «roja» és simple [dʒ]", "Perquè «lletja» és culta i «roja» és popular", "És una qüestió de preferència: totes dues admeten j i tj"], "e": "Els derivats de -ig s'escriuen amb tj/tg si el so és allargat (lletja, mitja, desitjar) i amb j/g si és simple (roja, boja, passejar)."},
      {"q": "Completa: «Els ___ de la tercera planta estan tancats.» (despatx)", "o": ["despatxos", "despatxs", "despaxos"], "e": "Els masculins acabats en -tx fan el plural en -os: despatx → despatxos."},
      {"q": "Quin adjectiu deriva de «capritx»?", "o": ["capritxós", "caprixós", "caprichós"], "e": "Capritx → capritxós, capritxosa: es manté la tx."},
      {"q": "Quin verb deriva d'«esquitx»?", "o": ["esquitxar", "esquixar", "esquitjar"], "e": "Esquitx → esquitxar: es manté la tx del primitiu."},
      {"q": "Quin és el plural de «cartutx»?", "o": ["cartutxos", "cartutxs", "cartuxos"], "e": "Cartutx → cartutxos (com despatx → despatxos)."},
      {"q": "Quin verb deriva de «despatx»?", "o": ["despatxar", "despaxar", "despatjar"], "e": "Despatx → despatxar: tx."},
      {"q": "Quina sèrie està ben escrita?", "o": ["xiquet, panxa, caixa, cotxe", "txiquet, pantxa, caixa, coxe", "xiquet, pantxa, caitxa, cotxe"], "e": "x a començament de paraula i darrere de consonant (xiquet, panxa); ix darrere de vocal (caixa); tx entre vocals (cotxe)."},
      {"q": "Quina forma és correcta?", "o": ["baixar", "baitxar", "bajar"], "e": "Darrere de vocal, el so [ʃ] s'escriu ix: baixar, caixa, peix."},
      {"q": "Completa: «Després d'entrenar, sempre em fique davall de la ___.»", "o": ["dutxa", "duxa", "ducha"], "e": "Entre vocals, el so [tʃ] s'escriu tx: dutxa, cotxe, butxaca."},
      {"q": "Quina d'estes paraules s'escriu amb tx?", "o": ["fletxa", "marxa", "panxa"], "e": "Darrere de consonant s'escriu x (marxa, panxa); entre vocals, tx (fletxa)."},
      {"q": "Completa: «Al mercat venen ___ molt frescos.»", "o": ["peixos", "peixs", "peixes"], "e": "Els masculins en -ix fan el plural en -os: peix → peixos, feix → feixos."},
      {"q": "En quina paraula la x sona [gz]?", "o": ["èxit", "xarxa", "guix"], "e": "Ex- + vocal sona [gz]: èxit, examen, exacte."},
      {"q": "Escriu el femení de «roig».", "a": ["roja"], "e": "Roig → roja: j davant de a."},
      {"q": "Escriu la primera persona del plural del present d'indicatiu de «menjar».", "a": ["mengem"], "e": "Mengem: davant de e, g."},
      {"q": "Escriu el nom derivat de «passeig» que vol dir 'acció de passejar'.", "a": ["passejada"], "e": "Passeig → passejar, passejada."},
      {"q": "Escriu el femení plural de «mig».", "a": ["mitges"], "e": "Mig, mitja, mitjos, mitges."},
      {"q": "Escriu el plural d'«esquitx».", "a": ["esquitxos"], "e": "Esquitx → esquitxos."}
    ]
  },
  {
    "id": "bc84c944-a8c7-5bff-a6e2-b72aa9f12e7c", "type": "b2_fon_laterals_h", "sort_order": 11,
    "title": "Laterals, nasals, ròtiques i la h", "name": "Grafies l·l i tl/tll, la h inicial i intercalada i els homòfons a/ha/ah, em/hem, i/hi",
    "content": "Les grafies l·l (col·legi, pel·lícula, intel·ligent) i tl/tll (ametla, ratlla), la h a començament i en l'interior de paraula (harmonia, hidratar, alcohol, ahir, tothom, prohibir), els homòfons més usuals (a, ha, ah; em, hem; i, hi) i algunes nasals (3.2.1).", "icon": "🌙", "color": "#D1C4E9",
    "exercises": [
      {"q": "Completa: «Demà començarem el curs al ___ nou.»", "o": ["col·legi", "colegi", "collegi"], "e": "Col·legi s'escriu amb l·l, com col·lecció, col·laborar o col·lega."},
      {"q": "Completa: «Ahir vam vore una ___ francesa molt interessant.»", "o": ["pel·lícula", "pelícola", "pellícula"], "e": "Pel·lícula: l geminada, escrita l·l."},
      {"q": "Completa: «És una alumna molt ___ i treballadora.»", "o": ["intel·ligent", "inteligent", "intelligent"], "e": "Intel·ligent, intel·lectual: l·l."},
      {"q": "Quina sèrie només conté paraules ben escrites?", "o": ["excel·lent, il·lusió, col·lecció", "excelent, il·lusió, col·lecció", "excel·lent, ilusió, colecció"], "e": "Moltes paraules que en castellà tenen l simple en valencià porten l·l: excel·lent, il·lusió, col·lecció."},
      {"q": "Completa: «Heu de presentar la ___ abans del 15 de març.»", "o": ["sol·licitud", "solicitud", "sollicitud"], "e": "Sol·licitud, sol·licitar: l·l."},
      {"q": "Com se separa en síl·labes «col·legi»?", "o": ["col-le-gi", "co-l·le-gi", "co-lle-gi"], "e": "La l·l es reparteix entre dues síl·labes: col-le-gi, pel-lí-cu-la."},
      {"q": "Quina d'estes paraules està ben escrita amb una sola l?", "o": ["elegant", "colecció", "ilustre"], "e": "Elegant porta l simple; les altres són col·lecció i il·lustre."},
      {"q": "Completa: «Un poeta ___ va inaugurar el congrés.»", "o": ["il·lustre", "ilustre", "illustre"], "e": "Il·lustre, il·lustrar, il·lustració: l·l."},
      {"q": "Completa: «En el discurs va fer ___ als problemes del barri.»", "o": ["al·lusió", "alusió", "allusió"], "e": "Al·lusió, al·ludir: l·l."},
      {"q": "Completa: «Feu una ___ davall del títol.»", "o": ["ratlla", "ralla", "rat·la"], "e": "Ratlla s'escriu amb tll, com ratllar o bitllet."},
      {"q": "Completa: «He comprat un ___ d'anada i tornada.»", "o": ["bitllet", "billet", "bil·let"], "e": "Bitllet: tll."},
      {"q": "Completa: «Les ajudes s'han publicat en el ___ oficial.»", "o": ["butlletí", "bulletí", "bul·letí"], "e": "Butlletí: tll."},
      {"q": "Quina forma és correcta?", "o": ["espatla", "espal·la", "espala"], "e": "Espatla (també espatlla) s'escriu amb t: el grup tl sona com una l allargada."},
      {"q": "Quina forma és correcta? (ocell xicotet de color terrós)", "o": ["guatla", "gual·la", "guala"], "e": "Guatla (també guatlla): grup tl."},
      {"q": "Completa: «Hem passat tota la nit en ___ al costat del malalt.»", "o": ["vetla", "vel·la", "vella"], "e": "Vetla (també vetlla), vetlar: grup tl. «Vella» és una altra paraula (femení de vell)."},
      {"q": "Com se separa en síl·labes «ametla»?", "o": ["a-met-la", "a-me-tla", "am-et-la"], "e": "La t i la l pertanyen a síl·labes diferents: a-met-la, rat-lla."},
      {"q": "En «ametla» o «guatla», com es pronuncia normalment el grup tl?", "o": ["com una l allargada [l:]", "com una t forta i una l separades per una vocal", "com una ll"], "e": "El grup tl (o tll) se sol pronunciar com una l doble: ametla [amel:a]."},
      {"q": "Quin és el verb derivat de «ratlla»?", "o": ["ratllar", "rat·lar", "ral·lar"], "e": "Ratlla → ratllar, ratllat: es manté el grup tll."},
      {"q": "Completa: «Una bona combinació de colors crea ___.»", "o": ["harmonia", "armonia", "harmónia"], "e": "Harmonia porta h inicial, encara que en castellà no la porte."},
      {"q": "Quina forma és correcta?", "o": ["hedoniste", "edoniste", "hedonizte"], "e": "Hedoniste (o hedonista) porta h inicial, com hedonisme."},
      {"q": "Completa: «A l'estiu cal ___ bé la pell.»", "o": ["hidratar", "idratar", "hidrattar"], "e": "Hidratar: h inicial, com hidrogen o hidràulic."},
      {"q": "Quina forma és correcta?", "o": ["humaniste", "umaniste", "humanizte"], "e": "Humaniste (o humanista) porta h inicial, com humà i humanitat."},
      {"q": "Quina sèrie està ben escrita?", "o": ["hora, hivern, herba", "ora, invern, herba", "hora, ivern, erba"], "e": "Hora, hivern i herba porten h inicial. Atenció a «hivern» (cast. invierno)."},
      {"q": "Completa: «Cada matí ___ la bandera a l'entrada de l'ajuntament.»", "o": ["hissen", "issen", "izen"], "e": "Hissar porta h inicial en valencià."},
      {"q": "Completa: «Per a esmorzar m'he fet un ___ ferrat.»", "o": ["ou", "hou", "huou"], "e": "Ou s'escriu sense h, encara que en castellà la porte (huevo)."},
      {"q": "Quina sèrie està ben escrita?", "o": ["orfe, ermita, os", "horfe, hermita, hos", "orfe, hermita, os"], "e": "Orfe, ermita i os (de l'esquelet) s'escriuen sense h."},
      {"q": "Completa: «Està prohibit vendre ___ als menors.»", "o": ["alcohol", "alcol", "alchol"], "e": "Alcohol porta h intercalada."},
      {"q": "Completa: «___ vaig arribar tard a la reunió.»", "o": ["Ahir", "Air", "Aïr"], "e": "Ahir porta h intercalada."},
      {"q": "Completa: «___ sap que no és veritat.»", "o": ["Tothom", "Totom", "Tot hom"], "e": "Tothom (tot + hom) s'escriu en una sola paraula i amb h."},
      {"q": "Completa: «La nova ordenança ___ aparcar en esta zona.»", "o": ["prohibix", "proibix", "prohibex"], "e": "Prohibir, prohibició, prohibit: h intercalada."},
      {"q": "Quina sèrie està ben escrita?", "o": ["vehicle, inhumà, rehabilitar", "veicle, inumà, reabilitar", "vehicle, inumà, rehabilitar"], "e": "H intercalada: vehicle, inhumà (in- + humà), rehabilitar (re- + habilitar)."},
      {"q": "Completa: «Les entrades s'han ___ en dues hores.»", "o": ["exhaurit", "exaurit", "eshaurit"], "e": "Exhaurir, com exhibir o exhalar, porta h intercalada."},
      {"q": "Completa: «___ arribat tard, però ja som ací.»", "o": ["Hem", "Em", "Ens"], "e": "Hem (verb haver: nosaltres hem arribat) porta h; em és el pronom (em dic, em fa mal)."},
      {"q": "Completa: «___ fa mal el genoll des de dissabte.»", "o": ["Em", "Hem", "M'hem"], "e": "Em és pronom personal, sense h: em fa mal, em dic."},
      {"q": "Completa: «Encara no ___ telefonat ningú.»", "o": ["ha", "a", "ah"], "e": "Ha és el verb haver (ha telefonat); a és preposició; ah és interjecció."},
      {"q": "Completa: «___, ara ho entenc tot!»", "o": ["Ah", "Ha", "A"], "e": "Ah és una interjecció, amb la h al final."},
      {"q": "Completa: «No ___ ha cap motiu per a preocupar-se.»", "o": ["hi", "i", "y"], "e": "Hi és pronom (hi ha, no hi vaig); i és conjunció copulativa."},
      {"q": "Completa: «Necessitem farina ___ sucre per al pastís.»", "o": ["i", "hi", "y"], "e": "La conjunció copulativa és i, sense h."},
      {"q": "Completa: «Ell ___ anat ___ València ___ comprar roba.»", "o": ["ha – a – a", "a – ha – a", "ha – ha – a"], "e": "Ha (verb haver) + anat; a València i a comprar (preposició)."},
      {"q": "Quina sèrie està ben escrita?", "o": ["simfonia, triomf, èmfasi", "sinfonia, trionf, ènfasi", "simfonia, trionf, èmfasi"], "e": "En algunes paraules cultes s'escriu m davant de f: simfonia, triomf, èmfasi, nimfa."},
      {"q": "Escriu correctament: «exibir».", "a": ["exhibir"], "e": "Exhibir: h intercalada."},
      {"q": "Escriu el verb format amb el prefix sub- i «ratllar».", "a": ["subratllar"], "e": "Subratllar: sub- + ratllar (r forta escrita simple)."},
      {"q": "Completa amb a, ha o ah: «Ma germana encara no ___ tornat.»", "a": ["ha"], "e": "Ha tornat: verb haver."},
      {"q": "Completa amb i o hi: «Si vas al mercat, ja no ___ trobaràs maduixes.»", "a": ["hi"], "e": "Hi és pronom adverbial: ja no hi trobaràs."},
      {"q": "Escriu correctament: «colaborar».", "a": ["col·laborar", "col.laborar"], "e": "Col·laborar: l·l."}
    ]
  },
  {
    "id": "d9e70145-c0d1-518e-9349-7657510b0b9c", "type": "b2_fon_majuscules", "sort_order": 12,
    "title": "Majúscules i minúscules", "name": "Funció demarcativa de les majúscules i usos generals en noms propis, festes, institucions i títols",
    "content": "Majúscula o minúscula segons el signe de puntuació anterior (coma, dos punts, punt i coma, parèntesi; punt, interrogació, exclamació) i usos generals en noms propis, institucions, títols d'obres, festivitats, càrrecs, tractaments, dies, mesos, gentilicis i llengües (3.2.1).", "icon": "🔠", "color": "#FFE082",
    "exercises": [
      {"q": "Quina frase està ben escrita?", "o": ["Volíem eixir d'excursió, però al final ens vam quedar a casa.", "Volíem eixir d'excursió, Però al final ens vam quedar a casa.", "volíem eixir d'excursió, però al final ens vam quedar a casa."], "e": "Després de coma, sempre minúscula; a l'inici de la frase, majúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Per al viatge necessites tres coses: passaport, diners i paciència.", "Per al viatge necessites tres coses: Passaport, diners i paciència.", "Per al viatge necessites tres coses: passaport, Diners i Paciència."], "e": "Després dels dos punts que introduïxen una enumeració, minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["No vindrà a la reunió: té febre des d'ahir.", "No vindrà a la reunió: Té febre des d'ahir.", "No vindrà a la reunió: té Febre des d'ahir."], "e": "Després de dos punts que introduïxen una explicació o una causa, minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["L'avi sempre repetia: «Qui matina fa farina», i tenia raó.", "L'avi sempre repetia: «qui matina fa farina», i tenia raó.", "L'avi sempre repetia: «Qui matina fa farina», I tenia raó."], "e": "Després de dos punts que introduïxen una cita textual, majúscula; després de coma, minúscula."},
      {"q": "Després de dos punts que introduïxen una cita textual entre cometes, com comença la cita?", "o": ["Amb majúscula", "Amb minúscula", "Amb majúscula només si és un refrany"], "e": "Va dir: «Demà parlarem.» La cita textual comença amb majúscula, encara que vaja darrere de dos punts."},
      {"q": "Quina frase està ben escrita?", "o": ["Uns volien anar a la platja; altres preferien la muntanya.", "Uns volien anar a la platja; Altres preferien la muntanya.", "uns volien anar a la platja; altres preferien la muntanya."], "e": "Després de punt i coma, minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Va nàixer a Alcoi (una ciutat industrial de l'interior) i després se'n va anar a Lió.", "Va nàixer a Alcoi (Una ciutat industrial de l'interior) i després se'n va anar a Lió.", "Va nàixer a Alcoi (una ciutat industrial de l'interior) I després se'n va anar a Lió."], "e": "Un parèntesi dins de la frase s'obri amb minúscula, i després del parèntesi la frase continua en minúscula."},
      {"q": "Quina és la forma correcta?", "o": ["Ho vam deixar per a l'endemà. (Ningú tenia ganes de continuar.)", "Ho vam deixar per a l'endemà. (ningú tenia ganes de continuar.)", "Ho vam deixar per a l'endemà. (Ningú Tenia ganes de continuar.)"], "e": "Si el parèntesi conté una oració independent després de punt, comença amb majúscula i porta el punt dins."},
      {"q": "Quina frase està ben escrita?", "o": ["On vas tan prompte? Encara no ha eixit el sol.", "On vas tan prompte? encara no ha eixit el sol.", "on vas tan prompte? Encara no ha eixit el sol."], "e": "Quan el signe d'interrogació tanca l'enunciat, la paraula següent va amb majúscula; i l'enunciat també comença amb majúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Quina calor! No hi ha qui isca al carrer.", "Quina calor! no hi ha qui isca al carrer.", "quina calor! No hi ha qui isca al carrer."], "e": "Quan el signe d'exclamació tanca l'enunciat, la paraula següent va amb majúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Si no ho fas tu, qui ho farà?", "Si no ho fas tu, Qui ho farà?", "si no ho fas tu, qui ho farà?"], "e": "Una pregunta pot començar dins de la frase, després de coma: llavors va amb minúscula."},
      {"q": "Quina és la forma correcta en un diàleg?", "o": ["—Que tard que és! —va exclamar la mare.", "—Que tard que és! —Va exclamar la mare.", "—que tard que és! —va exclamar la mare."], "e": "L'incís del narrador amb un verb de dir continua la frase: va amb minúscula encara que vaja darrere de ! o ?."},
      {"q": "Quina és la forma correcta en un diàleg?", "o": ["—Vens o no? —va insistir Jordi.", "—Vens o no? —Va insistir Jordi.", "—vens o no? —va insistir jordi."], "e": "Darrere de ? i del guió, l'incís del narrador (va insistir, va dir) comença en minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Venien pomes, peres, taronges... i tot a bon preu.", "Venien pomes, peres, taronges... I tot a bon preu.", "Venien pomes, peres, Taronges... i tot a bon preu."], "e": "Si després dels punts suspensius la frase continua, s'escriu minúscula."},
      {"q": "Després de punts suspensius, quan s'escriu majúscula?", "o": ["Quan tanquen l'enunciat i comença una oració nova", "Sempre", "Mai"], "e": "Els punts suspensius poden tancar l'enunciat (majúscula després) o deixar-lo en suspens dins de la frase (minúscula)."},
      {"q": "Quina frase està ben escrita?", "o": ["Portarem pa, formatge, fruita, etc., i ho repartirem entre tots.", "Portarem pa, formatge, fruita, etc., I ho repartirem entre tots.", "Portarem pa, formatge, fruita, Etc., i ho repartirem entre tots."], "e": "El punt d'una abreviatura no tanca la frase: si continua, minúscula."},
      {"q": "Quina és la forma correcta?", "o": ["Hi havia pomes, peres, taronges, etc. Tot era molt fresc.", "Hi havia pomes, peres, taronges, etc. tot era molt fresc.", "Hi havia pomes, peres, taronges, etc.. Tot era molt fresc."], "e": "Si l'abreviatura acaba la frase, el seu punt fa també de punt final (no es duplica) i la paraula següent va en majúscula."},
      {"q": "En una carta formal, després de «Benvolguda directora:», com comença el text de la línia següent?", "o": ["Amb majúscula: «Li escric per a...»", "Amb minúscula: «li escric per a...»", "Amb un guió: «—Li escric per a...»"], "e": "Després de la salutació d'una carta, el cos del text comença amb majúscula en una línia nova."},
      {"q": "Quina frase té un error de majúscules?", "o": ["Ho vam intentar dues vegades, Però no ens va eixir bé.", "Ho vam intentar dues vegades. No ens va eixir bé.", "Ho vam intentar dues vegades; no ens va eixir bé."], "e": "Després de coma, minúscula: «..., però no ens va eixir bé»."},
      {"q": "On cal posar majúscula en «tens raó: ens hem equivocat. ara bé, encara hi ha temps»?", "o": ["En «tens» i en «ara»", "En «tens», «ens» i «ara»", "Només en «tens»"], "e": "Inici de text (Tens) i després de punt (Ara). Després de dos punts, minúscula (ens)."},
      {"q": "Després de quins signes s'escriu normalment minúscula?", "o": ["Coma, punt i coma, dos punts i parèntesi d'obertura", "Punt, signe d'interrogació i signe d'exclamació que tanquen l'enunciat", "Punt i dos punts"], "e": "Funció demarcativa: la majúscula marca l'inici d'enunciat; dins de l'enunciat, minúscula."},
      {"q": "Després de quins signes s'escriu majúscula?", "o": ["Punt, i signe d'interrogació o d'exclamació quan tanquen l'enunciat", "Coma i punt i coma", "Qualsevol signe de puntuació"], "e": "La majúscula indica que comença un enunciat nou: després de punt, ? o ! que tanquen la frase."},
      {"q": "Quina frase està ben escrita?", "o": ["La reunió serà el dimecres 15 de febrer.", "La reunió serà el Dimecres 15 de Febrer.", "La reunió serà el dimecres 15 de Febrer."], "e": "Els dies de la setmana i els mesos s'escriuen amb minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Per Sant Joan farem una foguera a la platja.", "Per sant Joan farem una foguera a la platja.", "Per Sant joan farem una foguera a la platja."], "e": "Els noms de festivitats s'escriuen amb majúscula: Sant Joan, Nadal, Pasqua."},
      {"q": "Quina frase està ben escrita?", "o": ["Celebrarem el Cap d'Any amb la família.", "Celebrarem el cap d'any amb la família.", "Celebrarem el Cap d'any amb la família."], "e": "Festivitat: Cap d'Any, amb majúscula en les paraules significatives."},
      {"q": "Quina frase està ben escrita?", "o": ["Per Setmana Santa anirem al poble.", "Per setmana santa anirem al poble.", "Per Setmana santa anirem al poble."], "e": "Setmana Santa és el nom d'una festivitat: majúscula en les dues paraules."},
      {"q": "Quina frase està ben escrita?", "o": ["Els alacantins i els castellonencs parlen valencià.", "Els Alacantins i els Castellonencs parlen Valencià.", "Els alacantins i els castellonencs parlen Valencià."], "e": "Els gentilicis i els noms de llengües s'escriuen amb minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["L'alcalde de Gandia i la directora del museu han inaugurat l'exposició.", "L'Alcalde de Gandia i la Directora del museu han inaugurat l'exposició.", "L'alcalde de gandia i la directora del museu han inaugurat l'exposició."], "e": "Els càrrecs (alcalde, directora, ministra, rei) van amb minúscula; els topònims, amb majúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["La Dra. Ferrer ha parlat amb la senyora Martí.", "La dra. Ferrer ha parlat amb la Senyora Martí.", "La Dra. ferrer ha parlat amb la senyora Martí."], "e": "Els tractaments abreujats van amb majúscula (Dra., Sr.); escrits sencers, amb minúscula (la senyora Martí)."},
      {"q": "Quina és la forma correcta?", "o": ["l'Acadèmia Valenciana de la Llengua", "l'Acadèmia valenciana de la llengua", "l'acadèmia Valenciana de la Llengua"], "e": "En els noms d'institucions, majúscula en totes les paraules significatives."},
      {"q": "Quina frase està ben escrita?", "o": ["L'Estat ha aprovat noves ajudes; el pacient continua en estat greu.", "L'estat ha aprovat noves ajudes; el pacient continua en Estat greu.", "L'Estat ha aprovat noves ajudes; el pacient continua en Estat greu."], "e": "Estat amb majúscula quan designa l'entitat política; amb minúscula quan vol dir 'situació'."},
      {"q": "Com s'escriu el títol d'esta obra de Josep Pla?", "o": ["Estic rellegint «El quadern gris».", "Estic rellegint «El Quadern Gris».", "Estic rellegint «el quadern gris»."], "e": "En els títols d'obres, majúscula només en la primera paraula (i en els noms propis que continguen)."},
      {"q": "Quina frase està ben escrita?", "o": ["Ahir vam vore «La vida és bella» al cineclub.", "Ahir vam vore «La Vida és Bella» al cineclub.", "Ahir vam vore «la vida és bella» al cineclub."], "e": "Títols de pel·lícules: majúscula inicial i la resta en minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Viuen en un poble de la Marina Alta.", "Viuen en un poble de la marina alta.", "Viuen en un poble de la Marina alta."], "e": "Els noms de comarques són noms propis: la Marina Alta, l'Horta Sud, la Vall d'Albaida."},
      {"q": "Quina frase està ben escrita?", "o": ["Estudia a la Universitat Jaume I.", "Estudia a la universitat Jaume I.", "Estudia a la Universitat jaume I."], "e": "Nom propi d'una institució: la Universitat Jaume I."},
      {"q": "Quina frase està ben escrita?", "o": ["Els Reis Mags m'han portat un llibre.", "Els reis mags m'han portat un llibre.", "Els Reis mags m'han portat un llibre."], "e": "Els Reis Mags (i la festa de Reis) s'escriuen amb majúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["L'Ajuntament de Castelló ha convocat noves beques.", "L'ajuntament de castelló ha convocat noves beques.", "L'Ajuntament de castelló ha convocat noves beques."], "e": "Institució amb el nom del municipi: l'Ajuntament de Castelló."},
      {"q": "Quina frase està ben escrita?", "o": ["El president de la Generalitat s'ha reunit amb el Consell.", "El President de la Generalitat s'ha reunit amb el Consell.", "El president de la generalitat s'ha reunit amb el consell."], "e": "Els càrrecs van amb minúscula (president) i les institucions, amb majúscula (la Generalitat, el Consell)."},
      {"q": "Escriu l'abreviatura de «doctor».", "a": ["Dr.", "Dr"], "e": "Dr. (amb majúscula i punt)."},
      {"q": "Escriu la sigla de l'Acadèmia Valenciana de la Llengua.", "a": ["AVL"], "e": "AVL: les sigles s'escriuen en majúscules i sense punts."},
      {"q": "Després de dos punts que introduïxen una cita textual, s'escriu majúscula o minúscula?", "a": ["majúscula"], "e": "Majúscula: Va dir: «Demà parlarem.»"},
      {"q": "Després de punt i coma, s'escriu majúscula o minúscula?", "a": ["minúscula"], "e": "Minúscula: el punt i coma no tanca l'enunciat."},
      {"q": "Escriu el nom del mes 10 tal com aniria dins d'una frase.", "a": ["octubre"], "e": "Octubre, amb minúscula (excepte en el nom de la festa: el 9 d'Octubre)."}
    ]
  },
  {
    "id": "896361ca-1afe-5acb-b10a-aa76351e9287", "type": "b2_fon_puntuacio", "sort_order": 13,
    "title": "Signes de puntuació", "name": "Coma, punt i coma, dos punts, punts suspensius, parèntesis, guió de diàleg i cometes",
    "content": "Usos generals de la coma, el punt i coma, els dos punts i els punts suspensius, els parèntesis, el guió de diàleg amb els incisos del narrador i les cometes en les citacions textuals, amb la seua jerarquia (3.2.1).", "icon": "❗", "color": "#F8BBD0",
    "exercises": [
      {"q": "Quina frase té el vocatiu ben puntuat?", "o": ["Escolta, Vicent, demà no vingues.", "Escolta Vicent, demà no vingues.", "Escolta, Vicent demà no vingues."], "e": "El vocatiu va sempre entre comes (o amb una coma si va al principi o al final)."},
      {"q": "Quina és la salutació ben puntuada?", "o": ["Bon dia, senyores i senyors.", "Bon dia senyores i senyors.", "Bon dia senyores, i senyors."], "e": "Vocatiu: es separa amb coma de la resta de la frase."},
      {"q": "Quina frase està ben puntuada?", "o": ["Els alumnes que han acabat l'examen poden eixir.", "Els alumnes que han acabat l'examen, poden eixir.", "Els alumnes, que han acabat l'examen poden eixir."], "e": "No es posa coma entre el subjecte i el verb, encara que el subjecte siga llarg."},
      {"q": "Quina frase està ben puntuada?", "o": ["Hem comprat pa, llet, ous i fruita.", "Hem comprat pa, llet, ous, i fruita.", "Hem comprat, pa, llet, ous i fruita."], "e": "En una enumeració simple, els elements se separen amb comes, però no davant de la i final."},
      {"q": "Quina frase està ben puntuada?", "o": ["M'agradaria acompanyar-te, però no puc.", "M'agradaria acompanyar-te però, no puc.", "M'agradaria, acompanyar-te però no puc."], "e": "Davant de les conjuncions adversatives (però, sinó, sinó que) es posa coma."},
      {"q": "Quina frase està ben puntuada?", "o": ["La meua germana, que viu a Elx, vindrà demà.", "La meua germana, que viu a Elx vindrà demà.", "La meua germana que viu a Elx, vindrà demà."], "e": "Un incís explicatiu va entre dues comes: s'obri i es tanca."},
      {"q": "Quina diferència hi ha entre «Els alumnes, que estaven cansats, se'n van anar» i «Els alumnes que estaven cansats se'n van anar»?", "o": ["En la primera se'n van anar tots; en la segona, només els que estaven cansats", "En la primera només se'n van anar els cansats; en la segona, tots", "No hi ha cap diferència de sentit"], "e": "La relativa entre comes és explicativa (afecta tots); sense comes és especificativa (restringix)."},
      {"q": "Quina frase està ben puntuada?", "o": ["Si fa bon temps, eixirem a passejar.", "Si fa bon temps eixirem, a passejar.", "Si, fa bon temps, eixirem a passejar."], "e": "Quan la subordinada va davant de la principal, se separa amb coma."},
      {"q": "Quina frase està ben puntuada?", "o": ["El pressupost, per tant, s'haurà de revisar.", "El pressupost per tant, s'haurà de revisar.", "El pressupost, per tant s'haurà de revisar."], "e": "Els connectors intercalats (per tant, però, doncs, a més) van entre comes."},
      {"q": "Quina frase està ben puntuada?", "o": ["Jo prendré café; ella, te.", "Jo prendré café, ella; te.", "Jo, prendré café; ella te."], "e": "La coma pot indicar que s'ha omés un verb ja dit: ella (prendrà) te."},
      {"q": "Quina frase té una coma incorrecta?", "o": ["La directora de l'institut, ha convocat una reunió.", "La directora, molt preocupada, ha convocat una reunió.", "Demà, a les deu, hi haurà una reunió."], "e": "Error: coma entre el subjecte (la directora de l'institut) i el verb."},
      {"q": "Quina frase està ben puntuada?", "o": ["Han confirmat l'assistència tres persones: Anna, la directora; Pere, el secretari; Laia, la tresorera.", "Han confirmat l'assistència tres persones: Anna; la directora, Pere; el secretari, Laia; la tresorera.", "Han confirmat l'assistència tres persones: Anna, la directora, Pere, el secretari, Laia, la tresorera."], "e": "Quan els elements d'una enumeració ja contenen comes, se separen amb punt i coma per a evitar confusions."},
      {"q": "Quina frase està ben puntuada?", "o": ["Havíem preparat l'excursió amb molta antelació i amb tots els detalls; no obstant això, la pluja ens va obligar a suspendre-la.", "Havíem preparat l'excursió amb molta antelació i amb tots els detalls, no obstant això la pluja ens va obligar a suspendre-la.", "Havíem preparat l'excursió amb molta antelació i amb tots els detalls; no obstant, això la pluja ens va obligar a suspendre-la."], "e": "En oracions llargues, davant de connectors com no obstant això, tanmateix o per tant, es posa punt i coma, i coma darrere del connector."},
      {"q": "Quina frase està ben puntuada?", "o": ["Els uns cantaven; els altres ballaven.", "Els uns; cantaven els altres ballaven.", "Els uns cantaven els altres; ballaven."], "e": "El punt i coma pot separar dues oracions independents relacionades pel sentit."},
      {"q": "Quin signe indica una pausa més forta que la coma però més feble que el punt?", "o": ["el punt i coma (;)", "els dos punts (:)", "els punts suspensius (...)"], "e": "El punt i coma marca una pausa intermèdia entre la coma i el punt."},
      {"q": "Quina frase està ben puntuada?", "o": ["Per a la recepta necessitem farina, ous i sucre.", "Per a la recepta necessitem: farina, ous i sucre.", "Per a la recepta: necessitem farina, ous i sucre."], "e": "No es posen dos punts entre el verb i el complement. Sí que caldrien si hi haguera un element anunciador: necessitem tres coses: farina..."},
      {"q": "Quina frase usa els dos punts per a introduir una conseqüència?", "o": ["Ha nevat tota la nit: les carreteres estan tallades.", "Ha nevat: tota la nit les carreteres estan tallades.", "Ha nevat tota: la nit les carreteres estan tallades."], "e": "Els dos punts poden introduir una conseqüència, una causa o una conclusió."},
      {"q": "Quina frase està ben puntuada?", "o": ["La mestra va escriure en la pissarra: «Demà no hi ha classe», i se'n va anar.", "La mestra va escriure en la pissarra; «Demà no hi ha classe», i se'n va anar.", "La mestra va escriure: en la pissarra «Demà no hi ha classe», i se'n va anar."], "e": "Davant d'una citació textual es posen dos punts, i la cita va entre cometes."},
      {"q": "Quina frase usa els dos punts per a introduir una síntesi?", "o": ["Treball, constància i paciència: això és el que cal per a aprendre una llengua.", "Treball: constància i paciència això és el que cal per a aprendre una llengua.", "Treball, constància i paciència. Això: és el que cal per a aprendre una llengua."], "e": "Els dos punts poden tancar una enumeració i introduir-ne la síntesi o el resum."},
      {"q": "Quina frase està ben puntuada?", "o": ["No sé si vindrà...", "No sé si vindrà....", "No sé si vindrà.."], "e": "Els punts suspensius són sempre tres; si tanquen la frase, no s'hi afig el punt final."},
      {"q": "Com s'indica que s'ha suprimit un fragment dins d'una citació textual?", "o": ["Amb punts suspensius entre claudàtors o parèntesis: [...] o (...)", "Amb un guió llarg", "Amb tres punts i coma"], "e": "[...] o (...) indiquen que s'ha omés una part del text citat."},
      {"q": "Quina frase usa els punts suspensius per a crear expectació?", "o": ["Vaig obrir el sobre amb les mans tremoloses i... estava buit.", "Vaig obrir... el sobre amb les mans tremoloses i estava buit.", "Vaig obrir el sobre amb les mans tremoloses i estava buit...."], "e": "Els punts suspensius poden marcar una pausa de suspens abans d'una sorpresa."},
      {"q": "Quina és la forma correcta?", "o": ["Hi havia llibres, revistes, diaris, etc.", "Hi havia llibres, revistes, diaris, etc....", "Hi havia llibres, revistes, diaris... etc."], "e": "No es combinen etc. i punts suspensius: indiquen el mateix (enumeració inacabada)."},
      {"q": "Si un parèntesi conté una oració independent que comença després d'un punt, on va el punt final?", "o": ["Dins del parèntesi: «... (Ningú en va saber el motiu.)»", "Fora del parèntesi: «... (Ningú en va saber el motiu).»", "No en porta"], "e": "Si el parèntesi és una oració independent, el punt va dins; si forma part d'una frase, el punt va fora."},
      {"q": "Quina frase està ben puntuada?", "o": ["Quan arribem a Morella (si arribem), et telefonaré.", "Quan arribem a Morella, (si arribem) et telefonaré.", "Quan arribem a Morella (si arribem,) et telefonaré."], "e": "La coma que exigix la frase va darrere del parèntesi de tancament, no davant del d'obertura."},
      {"q": "Quina frase està ben puntuada?", "o": ["Vicent Andrés Estellés (Burjassot, 1924 - València, 1993) és un dels grans poetes valencians.", "Vicent Andrés Estellés, (Burjassot, 1924 - València, 1993) és un dels grans poetes valencians.", "Vicent Andrés Estellés (Burjassot, 1924 - València, 1993), és un dels grans poetes valencians."], "e": "Els parèntesis tanquen dades complementàries (llocs, dates); no s'hi afig coma entre el subjecte i el verb."},
      {"q": "Quins signes poden marcar un incís dins d'una frase?", "o": ["Les comes, els guions llargs o els parèntesis", "Els dos punts", "El punt i coma"], "e": "L'incís es pot marcar amb comes (més integrat), guions llargs o parèntesis (més desvinculat)."},
      {"q": "Quina és la puntuació correcta del diàleg?", "o": ["—Vine —va dir—, que és tard.", "—Vine, —va dir— que és tard.", "—Vine —va dir, que és tard."], "e": "L'incís del narrador va entre guions llargs; si la frase continua, la coma va darrere del guió de tancament."},
      {"q": "Quina és la puntuació correcta quan l'incís acaba la intervenció?", "o": ["—No ho sé —va respondre Laia.", "—No ho sé —va respondre Laia—.", "—No ho sé, —va respondre Laia."], "e": "Si l'incís del narrador tanca la intervenció, no es posa guió de tancament: només el punt."},
      {"q": "Quina és la puntuació correcta?", "o": ["—Ja ho sé —va dir Pau—. Però no puc fer-hi res.", "—Ja ho sé. —va dir Pau—. Però no puc fer-hi res.", "—Ja ho sé —va dir Pau— Però no puc fer-hi res."], "e": "Si després de l'incís comença una oració nova, el punt va darrere del guió de tancament."},
      {"q": "Quin signe introduïx les intervencions dels personatges en un diàleg?", "o": ["el guió llarg (—)", "el guionet curt (-)", "les cometes simples (‘ ’)"], "e": "El guió de diàleg és el llarg (—), no el guionet de les paraules compostes (-)."},
      {"q": "Com s'escriu el guió que introduïx la intervenció d'un personatge?", "o": ["Enganxat a la primera paraula: «—Bon dia!»", "Amb un espai darrere: «— Bon dia!»", "Amb guionet curt: «-Bon dia!»"], "e": "El guió de diàleg va enganxat a la paraula que el seguix."},
      {"q": "Quina és la puntuació correcta?", "o": ["—On vas? —li va preguntar sa mare.", "—On vas?, —li va preguntar sa mare.", "—On vas —li va preguntar sa mare?"], "e": "El signe d'interrogació va al final de la pregunta, abans de l'incís del narrador."},
      {"q": "Quin és l'ordre de les cometes quan cal citar dins d'una altra cita?", "o": ["« », després “ ” i després ‘ ’", "“ ”, després « » i després ‘ ’", "‘ ’, després “ ” i després « »"], "e": "Jerarquia: cometes baixes « », dins d'elles altes “ ” i, en tercer nivell, simples ‘ ’."},
      {"q": "Quina frase usa bé les cometes?", "o": ["Joan recordava: «El director sempre deia: “Ací no hi ha problemes, sinó reptes”», i somreia.", "Joan recordava: “El director sempre deia: «Ací no hi ha problemes, sinó reptes»”, i somreia.", "Joan recordava: «El director sempre deia: «Ací no hi ha problemes, sinó reptes»», i somreia."], "e": "Per a una cita dins d'una altra cita, s'usen primer les baixes « » i dins les altes “ ”."},
      {"q": "Quina frase està ben puntuada?", "o": ["Em va preguntar: «Vindràs a la festa?», i no vaig saber què respondre.", "Em va preguntar: «Vindràs a la festa»?, i no vaig saber què respondre.", "Em va preguntar: «Vindràs a la festa?, i no vaig saber què respondre»."], "e": "El signe d'interrogació que pertany a la cita va dins de les cometes; la coma de la frase, fora."},
      {"q": "Quina frase usa bé les cometes?", "o": ["El terme «sostenibilitat» apareix vint vegades en l'informe.", "El «terme sostenibilitat» apareix vint vegades en l'informe.", "El terme «sostenibilitat apareix» vint vegades en l'informe."], "e": "Les cometes poden marcar una paraula de la qual es parla (ús metalingüístic)."},
      {"q": "En «El seu “xicotet” error ens va costar tres mil euros», per què va entre cometes «xicotet»?", "o": ["Per a indicar que la paraula s'usa amb ironia", "Perquè és una paraula estrangera", "Perquè és el títol d'una obra"], "e": "Les cometes poden indicar un sentit irònic o especial d'una paraula."},
      {"q": "Quina frase està ben puntuada?", "o": ["«No ho faré», va dir Marta amb fermesa.", "«No ho faré,» va dir Marta amb fermesa.", "«No ho faré». va dir Marta amb fermesa."], "e": "Quan la cita va seguida de l'incís del narrador, la coma va fora de les cometes."},
      {"q": "Escriu el nom del signe que introduïx cada intervenció en un diàleg.", "a": ["guió llarg", "el guió llarg", "guió de diàleg", "el guió de diàleg", "guió"], "e": "El guió llarg (—)."},
      {"q": "Quantes comes cal afegir a «Vicent el meu veí ha comprat un cotxe nou» si «el meu veí» és un incís? (en número)", "a": ["2", "dues"], "e": "Dues: Vicent, el meu veí, ha comprat un cotxe nou."},
      {"q": "Escriu el nom del signe que separa els elements d'una enumeració que ja contenen comes.", "a": ["punt i coma", "el punt i coma"], "e": "El punt i coma (;)."},
      {"q": "Com s'anomenen les cometes « », que són les recomanades en primer nivell?", "a": ["baixes", "cometes baixes", "angulars", "cometes angulars", "llatines", "cometes llatines"], "e": "Cometes baixes o angulars (« »)."},
      {"q": "Completa amb la conjunció que va precedida de coma: «Ho volia, ___ no vaig poder.»", "a": ["però"], "e": "Però: davant de les adversatives es posa coma."}
    ]
  }
]$data$::jsonb) AS t(
  id uuid, type text, sort_order smallint, title text, name text,
  content text, icon text, color text, exercises jsonb
);

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
SELECT id, name, type, 'fonetica_ortografia', content, 'B2', 15, sort_order,
       jsonb_build_object('icon', icon, 'color', color, 'section_name', title)
FROM practice_catalog
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  difficulty = EXCLUDED.difficulty,
  xp_earned = EXCLUDED.xp_earned,
  sort_order = EXCLUDED.sort_order,
  -- Conserva la lliçó fixa («Aprendre lliçó»), si una migració posterior n'hi afig.
  metadata = EXCLUDED.metadata || jsonb_strip_nulls(jsonb_build_object('lesson', resources.metadata -> 'lesson'));

DELETE FROM public.practice_exercises e
USING practice_catalog c
WHERE e.resource_id = c.id AND e.level = 'B2';

INSERT INTO public.practice_exercises (resource_id, level, position, kind, prompt, options, answers, explanation)
SELECT c.id, 'B2', x.ord,
       CASE WHEN x.e ? 'a' THEN 'fill' ELSE 'choice' END,
       x.e->>'q',
       CASE WHEN x.e ? 'o' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'o')) END,
       CASE WHEN x.e ? 'a' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'a')) ELSE ARRAY[x.e->'o'->>0] END,
       x.e->>'e'
FROM practice_catalog c
CROSS JOIN LATERAL jsonb_array_elements(c.exercises) WITH ORDINALITY AS x(e, ord);

DROP TABLE practice_catalog;

-- ============================================================
-- Origen: 20261013120000_practice_morfosintaxi_b2.sql
-- ============================================================
-- Morfosintaxi del B2 (Quadern B2 de la JQCV, 3.2.2). Un contingut de la categoria morfosintaxi
-- per a cada apartat del temari: substantius; adjectius; determinants (article neutre,
-- demostratius, possessius); pronoms personals forts; pronoms febles (formes, col·locació, atribut
-- i circumstancial); combinacions binàries i anar-se'n/tornar-se'n/eixir-se'n; interrogatius i
-- exclamatius; relatius i subordinades de relatiu; numerals; quantitatius i indefinits;
-- preposicions; adverbis d'afirmació i de dubte; conjuncions i connectors; verbs irregulars
-- (velaritzats, canvis vocàlics, imperfet); subjuntiu i ordes en negatiu; ser i estar;
-- perífrasis; i l'infinitiu. Són recursos del nivell B2 amb exercicis B2. Tornar a aplicar el
-- fitxer no duplica res.

CREATE TEMP TABLE practice_catalog AS
SELECT * FROM jsonb_to_recordset($data$[
  {
    "id": "78d5cc0f-24d6-5cbd-af38-993452b3dbe4", "type": "b2_mor_substantius", "sort_order": 1,
    "title": "Substantius: gènere, nombre i significat", "name": "Flexió irregular i invariable, canvis de significat segons el gènere i concordança",
    "content": "La flexió de gènere i nombre irregular i invariable del substantiu, els noms que canvien de significat segons el gènere, els noms de gènere diferent del castellà i la concordança amb l'adjectiu (3.2.2).", "icon": "📚", "color": "#DCEDC8",
    "exercises": [
      {"q": "Quin és el femení de «ase»?", "o": ["somera", "asa", "asessa"], "e": "Alguns noms tenen un radical diferent en masculí i en femení: ase / somera, cavall / egua, bou / vaca."},
      {"q": "Quin és el femení de «cavall»?", "o": ["egua", "cavalla", "cavallera"], "e": "Cavall / egua (o euga): femení amb un radical diferent."},
      {"q": "Quin és el femení de «moltó»?", "o": ["ovella", "moltona", "moltonessa"], "e": "Moltó / ovella: com ase / somera, el femení és una paraula diferent."},
      {"q": "Quin és el femení de «boc»?", "o": ["cabra", "boca", "boga"], "e": "Boc / cabra: radicals diferents per al mascle i la femella."},
      {"q": "Quina parella masculí / femení és correcta?", "o": ["marit / muller", "marit / marida", "marit / maritessa"], "e": "Marit / muller, home / dona, gendre / nora: parelles amb radical diferent."},
      {"q": "Quina d'estes parelles masculí / femení és correcta?", "o": ["gendre / nora", "gendre / gendra", "oncle / oncla"], "e": "Gendre / nora i oncle / tia són parelles irregulars."},
      {"q": "Quin és el femení de «fisioterapeuta»?", "o": ["la fisioterapeuta (invariable)", "la fisioterapeutessa", "la fisioterapeuda"], "e": "Els noms acabats en -a com fisioterapeuta, astronauta o homicida són invariables: el gènere es veu en l'article i en l'adjectiu."},
      {"q": "«___ astronauta valenciana ha tornat de l'estació espacial.»", "o": ["L'", "La", "Lo"], "e": "Astronauta és invariable i femení ací: la + astronauta → l'astronauta. El gènere es veu en l'adjectiu: valenciana."},
      {"q": "Quin és el femení de «colombaire»?", "o": ["la colombaire (invariable)", "la colombairessa", "la colombaira"], "e": "Els noms en -aire són invariables: el colombaire, la colombaire (com el cantaire, la cantaire)."},
      {"q": "«La policia ha detingut ___.»", "o": ["la presumpta homicida", "la presumpta homicidessa", "la presumpta homicidera"], "e": "Homicida és invariable (com suïcida o artista): el presumpte homicida, la presumpta homicida."},
      {"q": "Quin d'estos substantius és invariable quant al gènere?", "o": ["cantant", "alumne", "sogre"], "e": "El cantant / la cantant (com fiscal, policia, guia). En canvi: alumne / alumna, sogre / sogra."},
      {"q": "Quin d'estos substantius té una forma específica per al femení?", "o": ["psiquiatre", "guia", "fiscal"], "e": "Psiquiatre / psiquiatra (com arquitecte / arquitecta). Guia i fiscal són invariables: la guia, la fiscal."},
      {"q": "Quin és el femení de «primer ministre»?", "o": ["primera ministra", "primera ministre", "primer ministra"], "e": "Quan un càrrec té substantiu i adjectiu, tots dos van en femení: primera ministra, traductora jurada."},
      {"q": "Quin és el plural de «virus»?", "o": ["els virus", "els virusos", "els viruses"], "e": "Els masculins plans o esdrúixols acabats en -s són invariables: el virus / els virus, l'atles / els atles."},
      {"q": "Quin és el plural de «la càries»?", "o": ["les càries", "les càrieses", "les càriesos"], "e": "Els femenins acabats en -s són invariables: la càries / les càries, la pelvis / les pelvis."},
      {"q": "Quin és el plural de «un comptagotes»?", "o": ["uns comptagotes", "uns comptagoteses", "uns comptagota"], "e": "Els compostos que ja tenen el segon element en plural són invariables: un comptagotes / uns comptagotes, un llepafils / uns llepafils."},
      {"q": "Quin d'estos substantius és invariable en nombre?", "o": ["el fons", "el pis", "el gas"], "e": "Alguns aguts en -s són invariables: el fons / els fons, el temps / els temps. En canvi: pisos, gasos."},
      {"q": "«Hem comprat ___ de peu per al saló.»", "o": ["un llum", "una llum", "un llumí"], "e": "El llum és l'aparell que fa llum; la llum és la claredat."},
      {"q": "«___ del sol entrava per la finestra.»", "o": ["La llum", "El llum", "L'llum"], "e": "La llum (claredat) és femení; el llum és l'aparell (un llum de peu)."},
      {"q": "«El metge li va prendre ___ i el tenia accelerat.»", "o": ["el pols", "la pols", "les pols"], "e": "El pols: batec de les artèries. La pols: partícules diminutes."},
      {"q": "«Passa el drap, que ___ s'acumula damunt dels mobles.»", "o": ["la pols", "el pols", "lo pols"], "e": "La pols (partícules) és femení; el pols (batec) és masculí."},
      {"q": "«Necessite ___ i un martell per a penjar el quadre.»", "o": ["un clau", "una clau", "un claus"], "e": "El clau és per a clavar; la clau és per a obrir i tancar."},
      {"q": "Quin significat té «terra» quan s'usa en masculí (el terra)?", "o": ["sòl, paviment", "planeta on vivim", "país d'origen"], "e": "En el sentit de sòl o paviment s'usa en masculí (fregar el terra); amb els altres significats és femení: la Terra, la terra natal."},
      {"q": "«Ja hem arribat a ___ de l'any.»", "o": ["la fi", "el fi", "lo fi"], "e": "La fi: acabament, final. El fi: objectiu, finalitat."},
      {"q": "«___ últim del projecte és reduir la contaminació.»", "o": ["El fi", "La fi", "Lo fi"], "e": "El fi vol dir 'objectiu, finalitat'; la fi és 'l'acabament'."},
      {"q": "Quina d'estes frases és correcta?", "o": ["Tinc molta son i me'n vaig a dormir.", "Tinc molt son i me'n vaig a dormir.", "Tinc molts sons i me'n vaig a dormir."], "e": "La son (ganes de dormir) és femení; el son és l'acte de dormir."},
      {"q": "«Després de l'accident, el pacient va entrar en ___ profund.»", "o": ["un coma", "una coma", "uns coma"], "e": "El coma: estat patològic. La coma: signe de puntuació."},
      {"q": "«En esta frase falta ___ abans de «però».»", "o": ["una coma", "un coma", "un comà"], "e": "La coma (signe de puntuació) és femení; el coma (estat patològic) és masculí."},
      {"q": "«El director del diari ha escrit ___ molt crític amb el govern.»", "o": ["un editorial", "una editorial", "uns editorial"], "e": "Un editorial: article de fons. Una editorial: empresa que publica llibres."},
      {"q": "Quina parella relaciona bé gènere i significat?", "o": ["la salut: 'estat de l'organisme' / el salut: 'salutació'", "la salut: 'salutació' / el salut: 'estat de l'organisme'", "la pudor: 'vergonya' / el pudor: 'mala olor'"], "e": "La salut / el salut; la pudor ('mala olor') / el pudor ('vergonya')."},
      {"q": "Quina d'estes parelles relaciona bé gènere i significat?", "o": ["la part: 'porció' / el part: 'acció de parir'", "la part: 'acció de parir' / el part: 'porció'", "la còlera: 'epidèmia' / el còlera: 'irritació'"], "e": "La part / el part; el còlera ('epidèmia') / la còlera ('irritació')."},
      {"q": "«Els resultats de ___ són normals.»", "o": ["l'anàlisi clínica", "l'anàlisi clínic", "el anàlisi clínic"], "e": "Anàlisi és femení en valencià (una anàlisi), i l'adjectiu concorda: anàlisi clínica, anàlisis clíniques."},
      {"q": "«Tinc ___ sobre la data de l'examen.»", "o": ["un dubte", "una dubte", "una dupte"], "e": "Dubte és masculí: un dubte, el dubte (en castellà, la duda)."},
      {"q": "«___ de davant se m'ha trencat.»", "o": ["Una dent", "Un dent", "Uns dents"], "e": "Dent és femení en valencià: la dent, les dents (en castellà, el diente)."},
      {"q": "«___ estaven boníssimes: flam i fruita.»", "o": ["Les postres", "Els postres", "El postre"], "e": "Postres és un nom femení i plural: les postres."},
      {"q": "«És ___ molt antic d'este poble.»", "o": ["un costum", "una costum", "una costuma"], "e": "Costum és masculí: el costum, els costums (en castellà, la costumbre)."},
      {"q": "Segons la normativa de l'AVL, quina sèrie conté només substantius masculins?", "o": ["el dubte, el costum, el senyal", "la dent, la suor, la remor", "l'anàlisi, la síndrome, la marató"], "e": "Són masculins el dubte, el costum, el senyal, el deute, el marge, l'avantatge. Són femenins la dent, la suor, l'anàlisi, la síndrome, la marató."},
      {"q": "Segons la normativa de l'AVL, quina sèrie conté només substantius femenins?", "o": ["la calor, la suor, l'olor", "el dubte, el deute, el marge", "el llegum, el compte, l'avantatge"], "e": "Són femenins la calor, la suor, l'olor, la remor, la síndrome; són masculins el llegum, el compte i l'avantatge."},
      {"q": "«De la cuina ve ___.»", "o": ["una olor molt forta", "un olor molt fort", "uns olors molt forts"], "e": "Olor és femení en valencià: una olor, l'olor agradable (en castellà, el olor)."},
      {"q": "«Li han fet una transfusió perquè havia perdut ___.»", "o": ["molta sang", "molt sang", "molts sangs"], "e": "Sang és femení: la sang, molta sang, una anàlisi de sang."},
      {"q": "«La beca l'ha guanyada ___.»", "o": ["una estudiant tenaç", "un estudiant tenaça", "una estudianta tenaça"], "e": "Estudiant i tenaç són invariables en gènere: el gènere només es veu en el determinant (una estudiant tenaç)."},
      {"q": "Escriu el femení de «ase».", "a": ["somera"], "e": "Ase / somera."},
      {"q": "Escriu el femení de «moltó».", "a": ["ovella"], "e": "Moltó / ovella."},
      {"q": "Escriu l'article definit plural: «___ anàlisis».", "a": ["les"], "e": "Les anàlisis: anàlisi és femení."},
      {"q": "Escriu el plural de «virus».", "a": ["virus", "els virus"], "e": "Els virus: invariable."}
    ]
  },
  {
    "id": "14688f8d-b484-5c11-8211-10fd7f858c9b", "type": "b2_mor_adjectius", "sort_order": 2,
    "title": "Adjectius: -aç, -iç, -oç, -leg/-loga i concordança", "name": "Adjectius en -aç, -iç, -oç, alternança -leg/-loga, adjectius invariables i concordança",
    "content": "La flexió dels adjectius acabats en -aç, -iç i -oç, l'alternança -leg/-loga, els adjectius d'una i dues terminacions, els plurals en -os i la concordança de l'adjectiu amb un o més noms (3.2.2).", "icon": "🎨", "color": "#FFF9C4",
    "exercises": [
      {"q": "Quin és el plural masculí de «capaç»?", "o": ["capaços", "capaces", "capaçs"], "e": "Els adjectius en -ç fan el plural masculí en -os: capaç → capaços."},
      {"q": "Quin és el plural femení de «capaç»?", "o": ["capaces", "capaços", "capaçes"], "e": "Femení plural en -es, i la ç passa a c davant de e: capaces."},
      {"q": "«Són unes jugadores molt ___.» (audaç)", "o": ["audaces", "audaços", "audaçes"], "e": "Audaç: una sola forma en singular (un jugador audaç, una jugadora audaç); plural audaços / audaces."},
      {"q": "«Tenim uns veïns molt ___.» (feliç)", "o": ["feliços", "felices", "feliçs"], "e": "Feliç → feliços (masculí plural) / felices (femení plural)."},
      {"q": "«Han passat unes vacances molt ___.» (feliç)", "o": ["felices", "feliços", "feliçes"], "e": "Femení plural: felices (ç → c davant de e)."},
      {"q": "«En la reserva hi ha uns animals molt ___.» (feroç)", "o": ["feroços", "feroces", "feroçs"], "e": "Feroç → feroços / feroces."},
      {"q": "«El govern ha pres unes mesures ___.» (eficaç)", "o": ["eficaces", "eficaços", "eficaçes"], "e": "Eficaç → eficaços / eficaces."},
      {"q": "«És una xiqueta molt ___: ja llig amb tres anys.» (precoç)", "o": ["precoç", "precoça", "precossa"], "e": "Els adjectius en -ç són invariables en singular: un xiquet precoç, una xiqueta precoç."},
      {"q": "«Els corredors més ___ ja han arribat.» (veloç)", "o": ["veloços", "veloces", "veloçs"], "e": "Veloç → veloços / veloces."},
      {"q": "«La investigadora és molt ___.» (perspicaç)", "o": ["perspicaç", "perspicaça", "perspicassa"], "e": "Perspicaç té una sola forma en singular per als dos gèneres."},
      {"q": "Quina sèrie de formes de «tenaç» és correcta?", "o": ["tenaç, tenaços, tenaces", "tenaç, tenaçes, tenaços", "tenaç, tenaça, tenaçes"], "e": "Tenaç (m. i f.), tenaços (m. pl.), tenaces (f. pl.). Igual: vivaç, voraç, sagaç."},
      {"q": "Quin és el femení de «psicòleg»?", "o": ["psicòloga", "psicòlega", "psicologa"], "e": "Els acabats en -òleg fan el femení en -òloga: psicòleg / psicòloga."},
      {"q": "Quin és el plural de «psicòloga»?", "o": ["psicòlogues", "psicòlogas", "psicòloges"], "e": "-ga → -gues: psicòlogues (la u manté el so de g)."},
      {"q": "Quin és el plural de «biòleg»?", "o": ["biòlegs", "biòlogs", "biòlecs"], "e": "Biòleg → biòlegs (m. pl.); biòloga → biòlogues (f. pl.)."},
      {"q": "«___ va dirigir l'excavació del jaciment.»", "o": ["L'arqueòloga", "L'arqueòlega", "La arqueòleg"], "e": "Arqueòleg / arqueòloga."},
      {"q": "Quin és el femení de «filòleg»?", "o": ["filòloga", "filòlega", "filòlogue"], "e": "Filòleg / filòloga, com geòleg / geòloga."},
      {"q": "«Al congrés hi havia moltes ___.» (ginecòleg)", "o": ["ginecòlogues", "ginecòlegs", "ginecòlogas"], "e": "Ginecòloga → ginecòlogues."},
      {"q": "Quina frase sobre la professió és correcta?", "o": ["Ma germana és sociòloga.", "Ma germana és sociòlega.", "Ma germana és sociòlegues."], "e": "Sociòleg / sociòloga / sociòlegs / sociòlogues."},
      {"q": "Quin d'estos adjectius és invariable en gènere?", "o": ["hipòcrita", "pobre", "ample"], "e": "Els acabats en -a àtona són invariables (pare hipòcrita, mare hipòcrita). En valencià, pobre / pobra i ample / ampla."},
      {"q": "«Viu en una ciutat molt ___.» (cosmopolita)", "o": ["cosmopolita", "cosmopolite", "cosmopolitana"], "e": "Cosmopolita és invariable: ambient cosmopolita, ciutat cosmopolita (com agrícola, nòmada)."},
      {"q": "Quin d'estos adjectius acabats en -e fa el femení en -a?", "o": ["exacte", "salvatge", "enorme"], "e": "Exacte / exacta (com apte / apta, digne / digna). Salvatge i enorme són invariables."},
      {"q": "«Necessitem una resposta ___.» (exacte)", "o": ["exacta", "exacte", "exacti"], "e": "Exacte fa el femení en -a: una xifra exacta."},
      {"q": "«Quina bèstia més ___!» (salvatge)", "o": ["salvatge", "salvatja", "salvatga"], "e": "Salvatge és invariable: animal salvatge, bèstia salvatge."},
      {"q": "«M'ha servit una sopa ben ___.» (calent)", "o": ["calenta", "calent", "calenda"], "e": "La majoria d'adjectius en -ent són invariables, però alguns tenen femení: calent / calenta, valent / valenta."},
      {"q": "«Ha obtingut una qualificació ___.» (excel·lent)", "o": ["excel·lent", "excel·lenta", "excel·lents"], "e": "Els adjectius en -ent, -ant, -al, -ar, -or solen ser invariables: resultat excel·lent, qualificació excel·lent."},
      {"q": "«Ha comés una falta ___.» (greu)", "o": ["greu", "greva", "greua"], "e": "Greu, breu, suau, gran són invariables: delicte greu, falta greu."},
      {"q": "Quin és el plural masculí de «gris»?", "o": ["grisos", "griss", "grissos"], "e": "Els adjectius acabats en -s fan el plural masculí en -os: gris → grisos."},
      {"q": "Quin és el plural masculí de «escàs»?", "o": ["escassos", "escasos", "escàssos"], "e": "Quan la s sona sorda, es duplica: escàs → escassos (escassa, escasses)."},
      {"q": "«Adjuntem els documents ___.» (annex)", "o": ["annexos", "annexs", "annexes"], "e": "Els acabats en -x fan el plural masculí en -os: annex → annexos, fix → fixos, baix → baixos."},
      {"q": "Quin és el plural masculí de «gros»?", "o": ["grossos", "grosos", "grossus"], "e": "Gros → grossos: s sorda duplicada, com en el femení grossa."},
      {"q": "Quina forma és un plural correcte de «boig»?", "o": ["bojos", "boijos", "botjos"], "e": "Els acabats en -ig poden fer el plural en -os (canviant ig per j o tj: bojos, lletjos) o en -s (boigs)."},
      {"q": "Quina parella recull els plurals masculins admesos de «roig»?", "o": ["rojos o roigs", "rojos o roijos", "roigs o rotjos"], "e": "Els adjectius en -ig, -sc, -st i -xt admeten -os o -s: rojos o roigs, foscos o foscs."},
      {"q": "Quin és el plural masculí de «lleig» amb la terminació -os?", "o": ["lletjos", "llejos", "lleijos"], "e": "Lleig → lletjos (amb tj, com el femení lletja)."},
      {"q": "«Porta un capell i un abric ___.» (verd)", "o": ["verds", "verd", "verdes"], "e": "Un adjectiu posposat a dos noms singulars del mateix gènere va en plural i en eixe gènere."},
      {"q": "«S'ha comprat una camisa i una jaqueta ___.» (blau)", "o": ["blaves", "blaus", "blava"], "e": "Dos noms femenins → adjectiu en femení plural: blaves."},
      {"q": "«Hem restaurat un aparador i una taula ___.» (rústic)", "o": ["rústics", "rústiques", "rústica"], "e": "Si els noms són de gènere diferent, l'adjectiu posposat va en masculí plural."},
      {"q": "«Després de la caiguda té la cama i el braç ___.» (trencat)", "o": ["trencats", "trencades", "trencada"], "e": "Femení + masculí → masculí plural: la cama i el braç trencats."},
      {"q": "«Es va demanar la ___ discreció i respecte.» (necessari, anteposat)", "o": ["necessària", "necessaris", "necessàries"], "e": "Un adjectiu anteposat a diversos noms concorda amb el primer: la necessària discreció i respecte."},
      {"q": "«Totes duien unes bruses ___.» (taronja)", "o": ["taronja", "taronges", "taronjes"], "e": "Un nom usat com a adjectiu sol quedar invariable: bruses taronja, hores punta, paraules clau."},
      {"q": "«Li han fet unes anàlisis ___.» (clínic)", "o": ["clíniques", "clínics", "clínicas"], "e": "Anàlisi és femení: anàlisis clíniques (c → qu davant de e)."},
      {"q": "Escriu el plural femení de «feliç».", "a": ["felices"], "e": "Felices."},
      {"q": "Escriu el femení de «cardiòleg».", "a": ["cardiòloga"], "e": "Cardiòloga."},
      {"q": "Escriu el plural masculí de «espés».", "a": ["espessos"], "e": "Espessos."},
      {"q": "Escriu el femení de «valent».", "a": ["valenta"], "e": "Valenta."},
      {"q": "Escriu l'adjectiu «capaç» concordat: «Són unes dones molt ___.»", "a": ["capaces"], "e": "Capaces."}
    ]
  },
  {
    "id": "d2e0eec5-75b3-5bf9-84da-9865a2e627f1", "type": "b2_mor_determinants", "sort_order": 3,
    "title": "Determinants: article neutre, demostratius i possessius", "name": "Article amb valor neutre i alternatives, sistema binari i ternari dels demostratius i possessius tònics i àtons",
    "content": "L'anomenat article neutre i les construccions alternatives en registre formal, el sistema ternari i binari dels demostratius (determinants, pronoms i adverbis) i les formes tòniques i àtones dels possessius (3.2.2).", "icon": "👉", "color": "#B3E5FC",
    "exercises": [
      {"q": "Segons l'AVL, en quins contextos és acceptable l'article «lo» amb valor neutre?", "o": ["En usos espontanis orals, o quan es transcriuen literalment, si no són calcs del castellà", "En qualsevol registre, també en el formal", "Només en textos administratius"], "e": "En els registres formals s'evita «lo» i es recorre a recursos genuïns: el que, allò que, el cas és que, la part millor..."},
      {"q": "Completa en registre formal: «Açò és precisament ___ anava buscant.»", "o": ["el que", "lo que", "lo qual"], "e": "Lo que → el que (o allò que)."},
      {"q": "Completa en registre formal: «Et vas perdre ___ de la pel·lícula.»", "o": ["la part millor", "lo millor", "lo més millor"], "e": "Lo millor → la part millor. «Lo millor» només és propi de l'ús oral espontani."},
      {"q": "Completa en registre formal: «___ és que no vaig anar perquè no vaig voler.»", "o": ["El cas", "Lo cert", "Lo que"], "e": "Lo cert és que → el cas és que (o la veritat és que)."},
      {"q": "Quina opció és adequada en registre formal?", "o": ["Cal ensenyar-li a diferenciar el que està bé del que està malament.", "Cal ensenyar-li a diferenciar lo bo de lo roín.", "Cal ensenyar-li a diferenciar lo bo del roín."], "e": "Amb adjectius substantivats, en registre formal: el que està bé, la bondat, la bellesa... en lloc de lo bo, lo bell."},
      {"q": "Completa en registre formal: «___ de la loteria és un escàndol.»", "o": ["L'assumpte", "Lo", "Lo que"], "e": "Lo de → l'assumpte de, la qüestió de, la història de."},
      {"q": "Completa en registre formal: «Ho faré ___.»", "o": ["tan ràpid com puga", "lo més ràpid possible", "lo més ràpid que puga"], "e": "Lo més ràpid possible → tan ràpid com puga."},
      {"q": "Completa en registre formal: «Vine ___.»", "o": ["com més prompte millor", "lo més prompte possible", "lo antes possible"], "e": "Alternatives: com més prompte millor, tan prompte com pugues, al més prompte possible."},
      {"q": "Quina exclamació és correcta?", "o": ["No saps com treballen de bé!", "No saps lo bé que treballen!", "No saps lo bé treballen!"], "e": "«Lo» amb valor intensiu en exclamatives no és acceptable en cap context: com treballen de bé, que bé que treballen."},
      {"q": "«___ bonic que és, i no para de plorar!»", "o": ["Tan", "Amb lo", "Lo"], "e": "Amb lo bonic que és → tan bonic que (o com) és."},
      {"q": "«Va callar de sobte, ___ és molt significatiu.»", "o": ["la qual cosa", "lo qual", "lo que"], "e": "Lo qual és un calc: la qual cosa, cosa que."},
      {"q": "«___, et toca substituir-lo a tu.»", "o": ["Per tant", "Per lo tant", "Per lo que"], "e": "Per lo tant → per tant."},
      {"q": "«___ ha donat una explicació.»", "o": ["Almenys", "Per lo menys", "A lo menys"], "e": "Per lo menys → almenys."},
      {"q": "«___ vindrà en el tren de les deu.»", "o": ["Potser", "A lo millor", "Lo millor"], "e": "A lo millor → potser, tal vegada o a la millor."},
      {"q": "«___ a les seues declaracions, no tenim res a dir.»", "o": ["Pel que fa", "En lo referent", "En lo que fa"], "e": "En lo referent a → pel que fa a, quant a, respecte a."},
      {"q": "«El tema encara no està ___ madur.»", "o": ["prou", "lo suficientment", "lo bastant"], "e": "Lo suficientment és un calc: prou madur."},
      {"q": "Quants graus de proximitat distingix el sistema demostratiu valencià?", "o": ["Tres: este, eixe, aquell", "Dos: este, aquell", "Quatre: este, eixe, aquell, allí"], "e": "El valencià manté el sistema ternari: primer grau (prop de qui parla), segon grau (prop de qui escolta) i tercer grau (lluny de tots dos)."},
      {"q": "En el sistema binari, propi de la major part dels parlars no valencians, quin demostratiu indica proximitat tant a l'emissor com al receptor?", "o": ["aquest", "aqueix", "aquell"], "e": "En el sistema binari només hi ha aquest (prop) i aquell (lluny)."},
      {"q": "Quina és la forma reforçada de «eixes»?", "o": ["aqueixes", "aquestes", "aquelles"], "e": "Eixe, eixa, eixos, eixes = aqueix, aqueixa, aqueixos, aqueixes."},
      {"q": "Quina variant formal admet el demostratiu «aquests»?", "o": ["aquestos", "aquestes", "aquets"], "e": "Aquests té la variant aquestos. Aquestes és el femení plural."},
      {"q": "«Què és ___ que portes al cap?»", "o": ["això", "açò", "allò"], "e": "Pronoms neutres: açò (prop de qui parla), això (prop de qui escolta), allò (lluny)."},
      {"q": "«Vine, mira ___ que m'acabe de trobar a la butxaca.»", "o": ["açò", "això", "allò"], "e": "Açò: primer grau, prop de qui parla."},
      {"q": "«Porta'm ___ que hi ha en la taula del fons del passadís.»", "o": ["allò", "açò", "això"], "e": "Allò: tercer grau, lluny de l'emissor i del receptor."},
      {"q": "«Què fas ___?» (el lloc on està l'interlocutor)", "o": ["ahí", "ací", "allí"], "e": "Adverbis demostratius: ací (prop de qui parla), ahí (prop de qui escolta), allí / allà (lluny)."},
      {"q": "«Hem quedat ___ mateix, al meu costat.»", "o": ["ací", "ahí", "allí"], "e": "Ací: primer grau, prop de qui parla."},
      {"q": "«Pensàvem passar la nit ___, en aquell poble de la serra.»", "o": ["allí", "ací", "ahí"], "e": "Allí / allà: lloc llunyà de l'emissor i del receptor."},
      {"q": "Quin adverbi s'usa en alguns parlars valencians i en la resta del domini amb el mateix valor que «ací»?", "o": ["aquí", "ahí", "allà"], "e": "Aquí equival a ací en els parlars més septentrionals i meridionals i en la resta del domini lingüístic."},
      {"q": "«Vaig llegir el diari i la revista, però només ___ arreplegava la notícia.» (la revista)", "o": ["esta", "aquella", "eixa"], "e": "El demostratiu de primer grau es referix a l'antecedent més pròxim en el discurs (la revista)."},
      {"q": "«___ pare treballa a Castelló.» (possessiu àton, primera persona)", "o": ["Mon", "Ma", "El mon"], "e": "Possessius àtons: mon, ma, mos, mes. No porten mai article."},
      {"q": "«Hem dinat a casa de ___ tia.» (possessiu àton, segona persona)", "o": ["ta", "ton", "la ta"], "e": "Ton (m.), ta (f.), tos (m. pl.), tes (f. pl.)."},
      {"q": "«___ germans viuen a Alcoi.» (possessiu àton, tercera persona)", "o": ["Sos", "Sons", "Ses"], "e": "Son, sa, sos, ses: sos germans, ses germanes."},
      {"q": "«He vist ___ cosines a la festa.» (possessiu àton, primera persona)", "o": ["mes", "mos", "mies"], "e": "Mes cosines (f. pl.); mos cosins (m. pl.)."},
      {"q": "«___ casa és molt antiga.» (possessiu àton, primera persona)", "o": ["Ma", "Mon", "Mi"], "e": "Els àtons s'usen amb noms de parentiu i amb el nom casa: ma casa, ta casa."},
      {"q": "«En ___ vida havia vist una cosa igual.» (ell)", "o": ["sa", "son", "la sa"], "e": "Expressió negativa amb possessiu àton: en ma vida, en sa vida (= mai)."},
      {"q": "Quines formes femenines del possessiu de primera persona són normatives?", "o": ["meua i meva", "meua i mia", "només mia"], "e": "En valencià, meua; en altres parlars, meva. Totes dues són normatives. Mia no ho és."},
      {"q": "«És un amic ___ de la infància.»", "o": ["meu", "el meu", "mi"], "e": "Amb l'article indefinit o sense article, el possessiu tònic va posposat: un amic meu, és amic meu."},
      {"q": "Quina expressió equival a «darrere de tu»?", "o": ["darrere teu", "darrere el teu", "darrere tua"], "e": "En algunes locucions el possessiu alterna amb el pronom fort: darrere de tu / darrere teu, prop de nosaltres / prop nostre."},
      {"q": "Quina expressió equival a «prop de nosaltres»?", "o": ["prop nostre", "prop la nostra", "prop de nostre"], "e": "Prop de nosaltres = prop nostre."},
      {"q": "Quin possessiu s'usa en escrits molt formals per a la tercera persona amb diversos posseïdors?", "o": ["llur", "son", "sa"], "e": "Llur, llurs: «Llur proposta» = la proposta d'ells. En l'ús general: el seu, la seua."},
      {"q": "Per què en «Renta't les mans» no cal posar el possessiu?", "o": ["Perquè la possessió es deduïx del context i el possessiu seria superflu", "Perquè l'imperatiu no admet possessius", "Perquè «mans» és un nom plural"], "e": "L'article tot sol pot tindre valor possessiu: Renta't les mans, He portat el cotxe al taller."},
      {"q": "Escriu la forma reforçada de «eixos».", "a": ["aqueixos"], "e": "Aqueixos."},
      {"q": "Escriu el possessiu àton masculí plural de segona persona: «___ cosins».", "a": ["tos"], "e": "Tos cosins."},
      {"q": "Escriu l'adverbi demostratiu de segon grau (prop de qui escolta).", "a": ["ahí"], "e": "Ahí."},
      {"q": "Escriu la forma adequada en registre formal de «per lo tant».", "a": ["per tant"], "e": "Per tant."},
      {"q": "Escriu el pronom demostratiu neutre de tercer grau.", "a": ["allò"], "e": "Allò."}
    ]
  },
  {
    "id": "9ec0739e-4993-500c-a3fb-705d5a3bbf1e", "type": "b2_mor_pronoms_forts", "sort_order": 4,
    "title": "Pronoms personals forts", "name": "Jo i mi, pronoms darrere de preposició, el reflexiu si i les formes de cortesia",
    "content": "Les formes dels pronoms personals forts, l'oposició jo / mi darrere de preposició, el pronom reflexiu si i les formes de tractament vosté, vostés i vós (3.2.2).", "icon": "🙋", "color": "#F8BBD0",
    "exercises": [
      {"q": "«Este regal és per a ___.»", "o": ["mi", "jo", "me"], "e": "Darrere de preposició s'usa mi: per a mi, amb mi, sense mi, contra mi."},
      {"q": "«No pots anar-te'n sense ___.»", "o": ["mi", "jo", "me"], "e": "Sense mi."},
      {"q": "«Han votat tots contra ___.»", "o": ["mi", "jo", "me"], "e": "Contra mi."},
      {"q": "«Isabel em va avisar a ___.»", "o": ["mi", "jo", "me"], "e": "A mi: complement duplicat amb valor emfàtic."},
      {"q": "«Per ___ no patiu, que estic bé.»", "o": ["mi", "jo", "me"], "e": "Per mi."},
      {"q": "«___ sí que voldria una explicació més detallada.»", "o": ["Jo", "Mi", "Me"], "e": "Jo és la forma de subjecte."},
      {"q": "«Qui ho ha proposat? —Ho he proposat ___.»", "o": ["jo", "mi", "me"], "e": "Subjecte posposat: ho he proposat jo."},
      {"q": "«La protesta anava contra ella i ___.»", "o": ["jo", "me", "m'"], "e": "Quan la preposició regix més d'un element coordinat, s'usa jo: contra ella i jo."},
      {"q": "«La protesta anava contra ella i contra ___.»", "o": ["mi", "jo", "me"], "e": "Si es repetix la preposició davant del pronom, s'usa mi: contra ella i contra mi."},
      {"q": "«Entre tu i ___ podem acabar el treball.»", "o": ["jo", "me", "em"], "e": "Entre tu i jo: elements coordinats regits per una sola preposició."},
      {"q": "«Van votar tots, excepte ___.»", "o": ["jo", "me", "em"], "e": "Amb excepte, menys, segons, malgrat s'usa jo: excepte jo, menys jo."},
      {"q": "«Segons ___, caldria revisar el document.»", "o": ["jo", "me", "em"], "e": "Segons jo (però és més natural: al meu parer)."},
      {"q": "«Ho van fer sense ___ dir-li res.»", "o": ["jo", "mi", "me"], "e": "Ací el pronom és subjecte de l'infinitiu (sense dir-li jo res), per això és jo."},
      {"q": "«Es va dirigir a ___ amb molt de respecte.»", "o": ["mi", "jo", "me"], "e": "A mi."},
      {"q": "Quin és el pronom fort de tercera persona específicament reflexiu?", "o": ["si", "ell", "se"], "e": "Si: Parlava de si mateix. Se és un pronom feble."},
      {"q": "«Carles parlava malament de ___ mateix.»", "o": ["si", "sí", "se"], "e": "Si (sense accent) és el pronom reflexiu fort; sí és l'adverbi d'afirmació."},
      {"q": "«La notícia el va posar fora de ___.»", "o": ["si", "sí", "se"], "e": "Expressió fixa sense mateix: fora de si."},
      {"q": "«Es va pegar un colp al cap i va tardar mitja hora a tornar en ___.»", "o": ["si", "sí", "ell"], "e": "Tornar en si: expressió fixa."},
      {"q": "«Només pensaven en ___ mateixos.»", "o": ["si", "sí", "se"], "e": "Si pot ser singular o plural: en si mateixos (o en ells mateixos)."},
      {"q": "«Ha fet un dibuix de ___ mateixa.» (ella)", "o": ["si", "sí", "se"], "e": "De si mateixa (o d'ella mateixa)."},
      {"q": "«Vaig fer un dibuix de ___ mateix.» (jo)", "o": ["mi", "si", "jo"], "e": "En primera i segona persona no hi ha forma reflexiva específica: de mi mateix, de tu mateix."},
      {"q": "Una dona diu: «Jo ___ ho arreglaré.»", "o": ["mateixa", "mateix", "mateixos"], "e": "Els modificadors concorden amb el sexe de qui parla: jo mateixa, jo sola."},
      {"q": "«Bon dia, senyora. Què desitja ___?»", "o": ["vosté", "vosaltres", "tu"], "e": "Vosté és la forma de cortesia i concorda amb el verb en tercera persona."},
      {"q": "Amb quina persona verbal concorda el pronom «vosté»?", "o": ["tercera persona del singular", "segona persona del singular", "segona persona del plural"], "e": "Vosté designa l'interlocutor però concorda en tercera persona: Què desitja vosté?"},
      {"q": "«A vosté, què ___ pareix?»", "o": ["li", "et", "vos"], "e": "Vosté és antecedent de pronoms febles de tercera persona: A vosté, què li pareix?"},
      {"q": "«Senyors, ja ___ poden passar.»", "o": ["vostés", "vosaltres", "vós"], "e": "Vostés + verb en tercera persona del plural: vostés poden."},
      {"q": "«Vostés ___ molt amables.»", "o": ["són", "sou", "som"], "e": "Vostés concorda en tercera persona del plural."},
      {"q": "En la fórmula «Vós direu», amb quina persona concorda el verb?", "o": ["segona persona del plural", "segona persona del singular", "tercera persona del singular"], "e": "Vós es referix a una sola persona però concorda amb el verb en plural: vós direu, vós sabeu."},
      {"q": "«Tinc un encàrrec per a ___, senyor Garcia.»", "o": ["vosté", "li", "el"], "e": "Darrere de preposició, pronom fort: per a vosté. Li i el són febles."},
      {"q": "Quina és la forma estàndard del pronom fort de primera persona del plural?", "o": ["nosaltres", "nosotros", "nos altres"], "e": "Nosaltres, vosaltres (en una sola paraula)."},
      {"q": "«Ens han convidat a ___ també.»", "o": ["nosaltres", "nos", "ens"], "e": "Darrere de preposició, pronom fort: a nosaltres."},
      {"q": "«Hem lluitat molt per ___.» (segona persona del plural)", "o": ["vosaltres", "vos", "us"], "e": "Per vosaltres. Vos i us són pronoms febles."},
      {"q": "«Vaig amb ___ al concert.» (segona persona del singular)", "o": ["tu", "te", "ti"], "e": "Darrere de preposició, tu: amb tu, per a tu, sense tu. «Ti» és un castellanisme."},
      {"q": "«A ___, qui t'ha demanat l'opinió?»", "o": ["tu", "te", "et"], "e": "A tu: pronom fort duplicat per al contrast."},
      {"q": "En «M'han avisat a mi», quin valor aporta el pronom fort «a mi»?", "o": ["contrastiu o emfàtic", "reflexiu", "de cortesia"], "e": "El pronom feble sol és l'opció no marcada; afegir el fort subratlla: a mi i no a una altra persona."},
      {"q": "Per a referir-se a una cosa, quina opció recomana la normativa?", "o": ["Ja he vist la foto i no vull que me'n parles.", "Ja he vist la foto i no vull que em parles d'ella.", "Ja he vist la foto i no vull que em parles d'ell."], "e": "Per a coses, en lloc del pronom fort darrere de preposició, es preferixen els febles en i hi: me'n parles."},
      {"q": "«El motor pot funcionar ___ sol.»", "o": ["ell", "si", "li"], "e": "El pronom fort referit a coses és normal si va modificat per sol: ell sol, ella sola."},
      {"q": "Escriu el pronom fort: «Este paquet és per a ___.» (primera persona)", "a": ["mi"], "e": "Per a mi."},
      {"q": "Escriu el pronom fort: «Entre tu i ___ ho farem.»", "a": ["jo"], "e": "Entre tu i jo."},
      {"q": "Escriu el pronom reflexiu fort: «Parla molt de ___ mateixa.»", "a": ["si"], "e": "De si mateixa."},
      {"q": "Escriu el pronom fort de cortesia de segona persona del plural.", "a": ["vostés"], "e": "Vostés."},
      {"q": "Escriu el pronom fort: «Han vingut tots, menys ___.» (primera persona)", "a": ["jo"], "e": "Menys jo."}
    ]
  },
  {
    "id": "3e748b6c-a081-57e8-abd5-5fc2914785c4", "type": "b2_mor_pronoms_febles", "sort_order": 5,
    "title": "Pronoms febles: formes, col·locació, atribut i circumstancial", "name": "Formes plenes, reforçades, elidides i reduïdes, apòstrof i guionet, atribut i complements circumstancials",
    "content": "La morfologia i la col·locació dels pronoms febles (formes plenes, reforçades, elidides i reduïdes, apostrofació i guionet, també en combinacions binàries) i l'ús dels pronoms en funció d'atribut i de complement circumstancial (3.2.2).", "icon": "🧩", "color": "#E1BEE7",
    "exercises": [
      {"q": "En «mira'm», quina forma té el pronom?", "o": ["reduïda", "elidida", "reforçada"], "e": "Forma reduïda: darrere de verb acabat en vocal ('m, 't, 'l, 'n, 'ns, 'ls)."},
      {"q": "En «m'escolta», quina forma té el pronom?", "o": ["elidida", "reduïda", "plena"], "e": "Forma elidida: davant de verb començat per vocal o h (m', t', l', s', n')."},
      {"q": "En «em mira», quina forma té el pronom?", "o": ["reforçada", "plena", "reduïda"], "e": "Forma reforçada: davant de verb començat per consonant (em, et, el, es, en, ens, els)."},
      {"q": "En «donar-me», quina forma té el pronom?", "o": ["plena", "reforçada", "elidida"], "e": "Forma plena: darrere de verb acabat en consonant o en diftong decreixent (donar-me, doneu-me)."},
      {"q": "«Doneu___ la mà.» (a mi)", "o": ["-me", "'m", "-em"], "e": "Darrere de verb acabat en diftong decreixent (doneu), forma plena: doneu-me."},
      {"q": "«Rebeu___ amb molta cortesia.» (els clients)", "o": ["-los", "'ls", "-els"], "e": "Rebeu acaba en diftong decreixent: forma plena, rebeu-los."},
      {"q": "«No vull perdre___ el concert.» (reflexiu, jo)", "o": ["'m", "-me", "-em"], "e": "Perdre acaba en vocal: forma reduïda, perdre'm."},
      {"q": "«Compra___ tres.» (pomes)", "o": ["'n", "-ne", "-en"], "e": "Darrere de vocal, forma reduïda: compra'n. Darrere de consonant, plena: comprar-ne."},
      {"q": "«Vull comprar___ tres.» (pomes)", "o": ["-ne", "'n", "-en"], "e": "Darrere de consonant, forma plena: comprar-ne."},
      {"q": "«No ___ ignora mai, a la seua germana.»", "o": ["la", "l'", "li"], "e": "El pronom la no s'apostrofa davant de i o u àtones: la ignora, la utilitza."},
      {"q": "«La bandera, ___ hissen cada matí.»", "o": ["l'", "la", "li"], "e": "Davant de i tònica sí que s'apostrofa: l'hissen (com l'odia, l'admira)."},
      {"q": "«Esta eina, ___ utilitza tothom.»", "o": ["la", "l'", "li"], "e": "U àtona: la utilitza (no s'apostrofa)."},
      {"q": "«Encara no ___ sap res del resultat.»", "o": ["se", "s'", "'s"], "e": "Davant de verb començat per s se sol usar la forma plena se: no se sap res, se celebrarà."},
      {"q": "«Volem escriure___ prompte.» (a vosaltres)", "o": ["-vos", "'vos", "-os"], "e": "Escriure-vos (o escriure-us). El pronom vos posposat va amb guionet."},
      {"q": "«Ja ___ ha anat.» (anar-se'n)", "o": ["se n'", "se'n", "s'en"], "e": "En les combinacions, l'apòstrof es col·loca tan a la dreta com siga possible: se n'ha anat."},
      {"q": "«No ___ he portat encara.» (el llibre, a ell)", "o": ["li l'", "li'l", "li el"], "e": "Li + el davant de vocal: li l'he portat (davant de consonant, li'l vaig portar)."},
      {"q": "«Quan ___ diràs?» (a mi, això)", "o": ["m'ho", "me ho", "em ho"], "e": "Em, et, es van en forma elidida davant de ho i hi: m'ho, t'ho, s'ho."},
      {"q": "«___ van regalar per Nadal.» (a mi, la bicicleta)", "o": ["Me la", "Em la", "M'la"], "e": "En primer lloc d'una combinació anteposada, em, et, es adopten la forma plena: me la, te'n, se'l."},
      {"q": "«___ portaran demà.» (a nosaltres, els llibres)", "o": ["Ens els", "Ens'ls", "Nos els"], "e": "Si el primer pronom acaba en -s, el segon pren la forma reforçada: ens els, els els."},
      {"q": "«Emportem___ ja!» (els paraigües)", "o": ["-nos-els", "'ns-els", "-nos'ls"], "e": "Emportem acaba en consonant: -nos, i el segon, darrere de -s, en forma reforçada: emportem-nos-els."},
      {"q": "«Dona___!» (la carta, a ella)", "o": ["-li-la", "-la-li", "'l-la"], "e": "L'orde és fix: li davant de la. Posposats van units amb guionets: dona-li-la."},
      {"q": "«És metgessa? —Sí que ___ és.»", "o": ["ho", "la", "l'"], "e": "L'atribut de ser, estar, semblar i paréixer se substituïx per ho."},
      {"q": "«Estan cansades? —No, no ___ estan.»", "o": ["ho", "les", "en"], "e": "Atribut d'estar → ho, siga quin siga el gènere o el nombre: no ho estan."},
      {"q": "«És estranger, però no ___ sembla.»", "o": ["ho", "el", "ne"], "e": "Atribut de semblar → ho."},
      {"q": "«És el nou director? —Sí, sí que ___ és.»", "o": ["ho", "l'", "el"], "e": "També l'atribut determinat es pronominalitza amb ho: sí que ho és."},
      {"q": "«Aquella camisa és de cotó? —Sí que ___ és.»", "o": ["ho", "en", "hi"], "e": "Atribut (de cotó) → ho."},
      {"q": "«Que en sereu molts, de convidats? —No, només ___ serem tres.»", "o": ["en", "ho", "hi"], "e": "Quan l'atribut és un nom quantificat i indeterminat (tres convidats), es pot usar en."},
      {"q": "«De dependenta, ja fa temps que no ___ fa.»", "o": ["en", "ho", "la"], "e": "En pronominalitza el predicatiu de fer de: no en fa."},
      {"q": "«S'ha comprat un ordinador i ___ està molt content.»", "o": ["n'", "hi", "l'"], "e": "El complement introduït per de d'un adjectiu atribut se substituïx per en: n'està content (de l'ordinador)."},
      {"q": "«Vas a la plaça? —Sí, ara ___ vaig.»", "o": ["hi", "en", "la"], "e": "Hi substituïx el complement de lloc o de destinació: hi vaig."},
      {"q": "«Vas a la plaça o ___ vens?»", "o": ["en", "hi", "ho"], "e": "En substituïx el complement d'origen o procedència (de la plaça): en vens."},
      {"q": "«Han viatjat a Egipte i ___ han tornat molt satisfets.»", "o": ["n'", "hi", "l'"], "e": "Tornar d'un lloc → en: n'han tornat (d'Egipte)."},
      {"q": "«Fa temps vivien a Ador, però no sé si encara ___ viuen.»", "o": ["hi", "en", "la"], "e": "Viure en un lloc → hi viuen."},
      {"q": "«Quan jo arribava a l'oficina, Jaume ___ eixia.»", "o": ["n'", "hi", "l'"], "e": "Eixir d'un lloc → en: n'eixia (de l'oficina)."},
      {"q": "«Jo estudie en la biblioteca, però Carme no ___ estudia mai.»", "o": ["hi", "en", "la"], "e": "Hi també substituïx complements de lloc no seleccionats pel verb: no hi estudia."},
      {"q": "«Sempre ___ parla, tranquil·lament.»", "o": ["hi", "ho", "en"], "e": "Hi pot pronominalitzar complements circumstancials de manera: sempre hi parla (tranquil·lament)."},
      {"q": "«M'he quedat sense tinta i no ___ puc escriure, amb l'estilogràfica.»", "o": ["hi", "en", "la"], "e": "Hi també substituïx complements instrumentals: no hi puc escriure."},
      {"q": "«Em va confessar que amb ell ja no ___ podia viure.»", "o": ["hi", "en", "li"], "e": "Complement de companyia → hi: no hi podia viure (amb ell)."},
      {"q": "«Va arribar cansat? —Sí que ___ va arribar.»", "o": ["hi", "ho", "en"], "e": "El complement predicatiu (cansat) es pronominalitza amb hi."},
      {"q": "«Em parlava com un boig, i li vaig dir que no m'___ parlara mai més.»", "o": ["hi", "ho", "en"], "e": "Hi = com un boig (complement de manera o predicatiu): que no m'hi parlara."},
      {"q": "Escriu el pronom: «Vas al mercat? —Sí, ___ vaig.»", "a": ["hi"], "e": "Hi vaig."},
      {"q": "Escriu el pronom: «És advocada? —Sí que ___ és.»", "a": ["ho"], "e": "Ho és."},
      {"q": "Escriu el pronom: «Tornes de l'escola? —Sí, ara ___ torne.»", "a": ["en"], "e": "En torne (de l'escola): complement d'origen."},
      {"q": "Escriu «compra + en» amb el pronom ben escrit.", "a": ["compra'n"], "e": "Compra'n."},
      {"q": "Escriu «rebeu + los» amb el pronom ben escrit.", "a": ["rebeu-los"], "e": "Rebeu-los: forma plena darrere de diftong decreixent."}
    ]
  },
  {
    "id": "1db249e1-ad16-5b7f-82e7-788a62a34555", "type": "b2_mor_combinacions", "sort_order": 6,
    "title": "Combinacions de pronoms febles i anar-se'n", "name": "Combinacions binàries de pronoms febles i conjugació d'anar-se'n, tornar-se'n i eixir-se'n",
    "content": "Les combinacions binàries de pronoms febles (reflexiu + CD, reflexiu + atribut, CI + circumstancial, CD + circumstancial i CI + CD) i la conjugació pronominal dels verbs anar-se'n, tornar-se'n i eixir-se'n (3.2.2).", "icon": "🔗", "color": "#FFE0B2",
    "exercises": [
      {"q": "«Es menja el pastís.» → «___ menja.»", "o": ["Se'l", "S'el", "Es el"], "e": "Reflexiu + CD: es + el → se'l."},
      {"q": "«S'ha begut tot això.» → «___ ha begut tot.»", "o": ["S'ho", "Se ho", "Es ho"], "e": "Es + ho → s'ho."},
      {"q": "«Es posa les ulleres.» → «___ posa.»", "o": ["Se les", "Es les", "Se'ls"], "e": "Es + les → se les (les ulleres, femení plural)."},
      {"q": "«S'ha comprat la moto.» → «___ ha comprada.»", "o": ["Se l'", "Se la", "S'la"], "e": "Es + la davant de vocal: se l'ha comprada."},
      {"q": "«S'ha menjat tres pomes.» → «___ ha menjat tres.»", "o": ["Se n'", "Se'n", "S'en"], "e": "Es + en davant de vocal: se n'ha menjat tres."},
      {"q": "«Diuen que amb els anys es tornaria més prudent, però no ___ ha tornat.»", "o": ["s'hi", "s'ho", "se'n"], "e": "Reflexiu + atribut d'un verb quasicopulatiu: es + hi → s'hi ha tornat."},
      {"q": "«Pere s'ha fet com una bacona. —Sí que ___ ha fet, sí.»", "o": ["s'hi", "s'ho", "se l'"], "e": "Fer-se (com una bacona): l'atribut es pronominalitza amb hi → s'hi ha fet."},
      {"q": "«Encara no s'ha fet sòcia del club, però prompte ___ farà.»", "o": ["se'n", "s'hi", "s'ho"], "e": "Amb fer-se 'passar a formar part', l'atribut es pronominalitza amb en: se'n farà."},
      {"q": "«Es troba bé? —No, no ___ troba.»", "o": ["s'hi", "se'n", "s'ho"], "e": "Trobar-se bé: es + hi → no s'hi troba."},
      {"q": "«Li han posat una tireta al genoll.» → «___ han posat una tireta.»", "o": ["Li hi", "L'hi", "Li n'"], "e": "CI + circumstancial de lloc: li + hi → li hi."},
      {"q": "«Ens posaran una antena al terrat.» → «___ posaran una antena.»", "o": ["Ens hi", "Ens n'", "Nos hi"], "e": "Ens + hi → ens hi."},
      {"q": "«M'han portat el dinar a l'oficina.» → «___ han portat el dinar.»", "o": ["M'hi", "Me hi", "Em hi"], "e": "Em + hi → m'hi (forma elidida davant de hi)."},
      {"q": "«Li han tret una espina del dit.» → «___ han tret una espina.»", "o": ["Li n'", "Li'n", "L'en"], "e": "CI + circumstancial d'origen (del dit = en): davant de vocal, li n'."},
      {"q": "«Els vam enviar els paquets a l'hotel.» → «___ vam enviar els paquets.»", "o": ["Els hi", "Els'hi", "Les hi"], "e": "CI plural (els) + lloc (hi) → els hi."},
      {"q": "«Porta el xiquet a l'escola.» → «Porta___!»", "o": ["-l'hi", "'l-hi", "-lo-hi"], "e": "CD + circumstancial: el + hi posposats a un verb acabat en vocal → porta-l'hi."},
      {"q": "«Posa la carn al congelador.» → «Posa___!»", "o": ["-la-hi", "-l'hi", "-hi-la"], "e": "La + hi posposats → posa-la-hi."},
      {"q": "«Deixa els llibres a la taula.» → «Deixa___!»", "o": ["'ls-hi", "-los-hi", "-els-hi"], "e": "Els + hi darrere de verb acabat en vocal → deixa'ls-hi."},
      {"q": "«Vaig trobar Marta al mercat.» → «___ vaig trobar.»", "o": ["La hi", "L'hi", "Li hi"], "e": "La (CD, Marta) + hi (lloc) → la hi vaig trobar."},
      {"q": "«Traurem el cotxe del garatge.» → «___ traurem.»", "o": ["L'en", "El n'", "Lo'n"], "e": "CD + circumstancial d'origen: el + en davant de consonant → l'en traurem."},
      {"q": "«Ha tret la paella del forn.» → «___ ha treta.»", "o": ["La n'", "L'en", "La'n"], "e": "La + en davant de vocal → la n'ha treta."},
      {"q": "«Va traure les claus de la bossa.» → «___ va traure.»", "o": ["Les en", "Les n'", "Les'n"], "e": "Les + en davant de consonant → les en va traure."},
      {"q": "«Li he dit la veritat.» → «___ he dita.»", "o": ["Li l'", "Li la", "Li'l"], "e": "CI + CD: li + la davant de vocal → li l'he dita."},
      {"q": "«Li done els llibres.» → «___ done.»", "o": ["Li'ls", "Li els", "Els li"], "e": "Li + els → li'ls (en altres parlars, els hi)."},
      {"q": "«Explicaré això a la directora.» → «___ explicaré.»", "o": ["Li ho", "L'hi ho", "Ho li"], "e": "Li + ho → li ho."},
      {"q": "«Dona el llibre a Joan.» → «Dona___!»", "o": ["-li'l", "-l'li", "-lo-li"], "e": "Li + el posposats → dona-li'l (en altres parlars, dona-l'hi)."},
      {"q": "«Li vaig regalar dos llibres.» → «___ vaig regalar dos.»", "o": ["Li'n", "Li en", "Li ne"], "e": "Li + en davant de consonant → li'n."},
      {"q": "«Els vam tornar els diners.» → «___ vam tornar.»", "o": ["Els els", "Els'ls", "Les els"], "e": "CI plural + CD plural: els els (el segon en forma reforçada)."},
      {"q": "«Envia el catàleg als clients.» → «Envia___!»", "o": ["'ls-el", "-los-el", "-el-los"], "e": "Els + el darrere de verb acabat en vocal → envia'ls-el."},
      {"q": "«Digues això als teus pares.» → «Digues___.»", "o": ["-los-ho", "'ls-ho", "-ho-los"], "e": "Els + ho darrere de verb acabat en consonant → digues-los-ho."},
      {"q": "«Porta'm la cadira.» → «Porta___!»", "o": ["-me-la", "'m-la", "-la-me"], "e": "Em + la posposats → porta-me-la."},
      {"q": "Anar-se'n, present, nosaltres: «Demà ___.»", "o": ["ens n'anem", "se n'anem", "ens anem-ne"], "e": "Ens n'anem. «Se n'anem» és col·loquial i no és adequat en registres formals."},
      {"q": "Anar-se'n, present, vosaltres: «Ja ___?»", "o": ["vos n'aneu", "se n'aneu", "vos aneu-ne"], "e": "Vos n'aneu (o us n'aneu). «Se n'aneu» és col·loquial."},
      {"q": "Anar-se'n, imperatiu, nosaltres:", "o": ["anem-nos-en", "anem-se'n", "anem-nos'n"], "e": "Anem + nos + en: anem-nos-en."},
      {"q": "Anar-se'n, imperatiu, vosaltres: «___ d'esta casa ara mateix!»", "o": ["Aneu-vos-en", "Aneu-se'n", "Aneu-vos'n"], "e": "Aneu-vos-en. «Aneu-se'n» només és propi de registres col·loquials."},
      {"q": "Anar-se'n, imperatiu, vosté: «___ d'ací, per favor.»", "o": ["Vaja-se'n", "Vaja's-en", "Se'n vaja"], "e": "En l'imperatiu els pronoms es posposen: vaja-se'n, vagen-se'n."},
      {"q": "Anar-se'n, perfet, ella: «Maria ja ___.»", "o": ["se n'ha anat", "se'n ha anat", "s'ha anat-ne"], "e": "Se n'ha anat: davant de vocal, l'apòstrof va tan a la dreta com és possible."},
      {"q": "Anar-se'n, passat perifràstic, nosaltres: «Ahir ___ a les nou.»", "o": ["ens en vam anar", "se'n vam anar", "ens n'en vam anar"], "e": "Davant de consonant, ens + en: ens en vam anar (o ens n'anàrem)."},
      {"q": "Tornar-se'n, present, ell: «Després de les vacances, ___ al poble.»", "o": ["se'n torna", "s'en torna", "se torna'n"], "e": "Tornar-se'n: me'n torne, te'n tornes, se'n torna."},
      {"q": "Tornar-se'n, imperatiu, tu: «___ a casa!»", "o": ["Torna-te'n", "Torna't-en", "Torna-te-ne"], "e": "Torna + te + en → torna-te'n."},
      {"q": "Eixir-se'n (vessar): «Vigila la llet, que ___!»", "o": ["se n'ix", "se'n ix", "s'en ix"], "e": "Es + en davant de vocal: se n'ix."},
      {"q": "Escriu el futur d'anar-se'n per a nosaltres: «Demà ___.»", "a": ["ens n'anirem"], "e": "Ens n'anirem."},
      {"q": "Escriu l'imperatiu d'anar-se'n per a vosaltres.", "a": ["aneu-vos-en"], "e": "Aneu-vos-en."},
      {"q": "Escriu els pronoms: «Es menja la poma.» → «___ menja.»", "a": ["se la"], "e": "Se la menja."},
      {"q": "Escriu els pronoms: «Explica això al teu germà.» → «Explica-___.»", "a": ["li-ho", "-li-ho"], "e": "Explica-li-ho."},
      {"q": "Escriu els pronoms: «Ha portat els xiquets al parc.» → «___ ha portats.»", "a": ["els hi"], "e": "Els hi ha portats (els = els xiquets, hi = al parc)."}
    ]
  },
  {
    "id": "ce84835e-48fa-5f35-8314-b475e3844637", "type": "b2_mor_interrogatius", "sort_order": 7,
    "title": "Interrogatius i exclamatius", "name": "Quin, qui, què, com, on/a on, quan, quant i per què; exclamatives",
    "content": "Els pronoms i adverbis interrogatius i exclamatius (quin/quina/quins/quines, qui, què, com, a on, quan, quant i per què), la distinció entre per què i perquè, què i que, i les exclamatives amb quin, que i com (3.2.2).", "icon": "❓", "color": "#B3E5FC",
    "exercises": [
      {"q": "«___ de les dues propostes t'agrada més?»", "o": ["Quina", "Què", "Qui"], "e": "Quin/quina servix per a triar entre elements d'un conjunt: quina de les dues, quin dels tres."},
      {"q": "«___ són els requisits per a matricular-se?»", "o": ["Quins", "Què", "Quals"], "e": "Interrogatiu d'identificació: quins/quines. «Quals» no és interrogatiu en valencià (és una interferència del castellà «cuáles»)."},
      {"q": "«___ cançons tocarà el grup en el concert?»", "o": ["Quines", "Què", "Quals"], "e": "Davant de nom s'usa quin/quina/quins/quines: quines cançons. «Què cançons» és col·loquial i no és estàndard."},
      {"q": "«En ___ any es va fundar la Universitat de València?»", "o": ["quin", "què", "qual"], "e": "Quin + nom: en quin any, de quin color, a quina hora."},
      {"q": "«No sé ___ autobús he d'agafar per a anar a l'hospital.»", "o": ["quin", "què", "qual"], "e": "També en les interrogatives indirectes: no sé quin autobús, no sé quina opció."},
      {"q": "Quina pregunta és correcta?", "o": ["A quina hora comença la reunió?", "A què hora comença la reunió?", "A les quina hora comença la reunió?"], "e": "Hora és un nom femení: a quina hora? «Què hora» és un error freqüent."},
      {"q": "«___ ha guanyat el premi literari d'enguany?» (persona)", "o": ["Qui", "Què", "Que"], "e": "Qui pregunta per persones; què, per coses."},
      {"q": "«A ___ has enviat el correu?»", "o": ["qui", "què", "que"], "e": "Qui pot anar darrere de preposició: a qui, amb qui, de qui, per qui."},
      {"q": "«Amb ___ parlaves per telèfon quan he entrat?»", "o": ["qui", "què", "que"], "e": "Amb qui: companyia (persona). Amb què: instrument (cosa)."},
      {"q": "«Per ___ vas votar en les últimes eleccions?» (candidat)", "o": ["qui", "què", "que"], "e": "Per qui: la pregunta es referix a una persona."},
      {"q": "«___ vols dir exactament amb això?»", "o": ["Què", "Que", "Qué"], "e": "L'interrogatiu tònic què porta accent obert (è); mai «qué»."},
      {"q": "«De ___ parleu tan seriosament?»", "o": ["què", "que", "qué"], "e": "Darrere de preposició, l'interrogatiu és tònic: de què, amb què, per a què."},
      {"q": "«Encara no entenc ___ vols que faça.»", "o": ["què", "que", "qué"], "e": "En les interrogatives indirectes el pronom també és tònic i porta accent: no entenc què vols."},
      {"q": "En quina frase hi ha la conjunció «que» (àtona) i no l'interrogatiu «què»?", "o": ["Diu que arribarà tard.", "No sé què dir-te.", "Pregunta-li de què es tracta."], "e": "La conjunció que introduïx una completiva i no porta accent; què interrogatiu (directe o indirecte) sí."},
      {"q": "Quina frase està ben escrita?", "o": ["Em va preguntar què volia.", "Em va preguntar que volia.", "Em va preguntar qué volia."], "e": "Interrogativa indirecta: em va preguntar què volia (què tònic, amb accent obert)."},
      {"q": "«___ s'escriu el teu cognom: amb b o amb v?»", "o": ["Com", "Què", "Quin"], "e": "Com pregunta per la manera."},
      {"q": "«___ t'ha anat l'entrevista de treball?»", "o": ["Com", "Què", "Quant"], "e": "Com: manera o resultat d'una acció."},
      {"q": "«No sé ___ ho has fet per a acabar tan prompte.»", "o": ["com", "què", "quant"], "e": "Com, també en interrogatives indirectes: no sé com ho has fet."},
      {"q": "«___ has deixat les claus del cotxe?» «Damunt de la taula.»", "o": ["On (o a on)", "Com", "Que"], "e": "Per a preguntar pel lloc s'usa on o a on (totes dues formes són correctes)."},
      {"q": "Quina parella d'interrogatius de lloc és correcta?", "o": ["on / a on", "ón / a ón", "aon / on"], "e": "On i a on són correctes; no porten accent i a on s'escriu separat."},
      {"q": "«D'___ véns tan cansat?»", "o": ["on", "ón", "a on"], "e": "De + on → d'on (origen). On no porta accent."},
      {"q": "«Des de ___ coneixes la directora?»", "o": ["quan", "quant", "quin"], "e": "Quan pregunta pel temps: des de quan, fins quan, per a quan."},
      {"q": "«Fins ___ estarà obert el termini de matrícula?»", "o": ["quan", "quant", "quins"], "e": "Fins quan: límit temporal. No s'ha de confondre amb quant (quantitat)."},
      {"q": "«___ alumnes s'han presentat a l'examen?»", "o": ["Quants", "Quant", "Quans"], "e": "Quant varia en gènere i nombre: quant, quanta, quants, quantes."},
      {"q": "«___ farina necessites per al pastís?»", "o": ["Quanta", "Quants", "Quantes"], "e": "Farina és femení singular: quanta farina (també quant de farina)."},
      {"q": "«___ vegades t'ho he de repetir?»", "o": ["Quantes", "Quantas", "Quants"], "e": "Vegada és femení plural: quantes vegades."},
      {"q": "«A ___ estem hui?» (data)", "o": ["quants", "quant", "quan"], "e": "Per a preguntar el dia del mes: a quants estem?"},
      {"q": "Quina és la pregunta correcta per a demanar el preu?", "o": ["Quant costa?", "Quan costa?", "Quànt costa?"], "e": "Quant (amb t, sense accent) pregunta per una quantitat o un preu; quan, pel temps."},
      {"q": "«M'agradaria saber ___ has canviat d'opinió.»", "o": ["per què", "perquè", "per que"], "e": "Interrogativa indirecta de causa: per què (separat i amb accent)."},
      {"q": "«No he vingut a classe ___ tenia febra.»", "o": ["perquè", "per què", "per que"], "e": "Perquè (junt, sense separar) és conjunció causal: introduïx la resposta o la causa."},
      {"q": "«T'ho explique ___ ho entengues bé.» (finalitat)", "o": ["perquè", "per què", "per a què"], "e": "Perquè + subjuntiu també expressa finalitat: perquè ho entengues (= per tal que)."},
      {"q": "«Ningú no en coneix el ___.» (la raó, el motiu)", "o": ["perquè", "per què", "porqué"], "e": "El perquè és un substantiu (el motiu): s'escriu junt i porta article."},
      {"q": "Quina parella pregunta-resposta està ben escrita?", "o": ["Per què ho preguntes? Perquè m'interessa.", "Perquè ho preguntes? Per què m'interessa.", "Per què ho preguntes? Per què m'interessa."], "e": "Pregunta: per què (separat). Resposta causal: perquè (junt)."},
      {"q": "«___ fred que fa hui!»", "o": ["Quin", "Què", "Qué"], "e": "Exclamatives amb nom: quin/quina + nom: quin fred!, quina calor!"},
      {"q": "«___ bonic és este paisatge!»", "o": ["Que", "Què", "Qué"], "e": "Davant d'adjectiu o adverbi, l'exclamatiu és que, sense accent: que bonic!, que bé!"},
      {"q": "«___ plou! No es pot eixir al carrer.»", "o": ["Com", "Quin", "Qui"], "e": "Com + verb expressa intensitat en exclamatives: com plou!, com corre!"},
      {"q": "«___ sort has tingut!»", "o": ["Quina", "Què", "Que"], "e": "Quina + nom femení: quina sort!, quina vergonya!"},
      {"q": "Quina frase exclamativa està ben escrita?", "o": ["Que tard que és!", "Què tard que és!", "¡Que tard que és!"], "e": "Que exclamatiu davant d'adverbi no porta accent; i el signe d'exclamació només es posa al final."},
      {"q": "«___ llibres que té ta tia a casa!» (quantitat)", "o": ["Quants", "Quant", "Quantes"], "e": "Exclamativa de quantitat: quants + nom masculí plural."},
      {"q": "Escriu l'interrogatiu: «___ de les tres opcions has triat?»", "a": ["quina"], "e": "Quina de les tres: per a triar entre elements d'un conjunt."},
      {"q": "Escriu l'interrogatiu: «De ___ tracta la conferència?»", "a": ["què"], "e": "De què: pronom tònic darrere de preposició, amb accent obert."},
      {"q": "Completa l'exclamativa: «___ bé que canta!»", "a": ["que"], "e": "Que + adverbi: que bé!, sense accent."},
      {"q": "Escriu l'interrogatiu: «___ de temps falta per a l'estrena?»", "a": ["quant"], "e": "Quant de temps: quantitat de temps."},
      {"q": "Escriu l'interrogatiu de causa: «No sé ___ ha dimitit el director.»", "a": ["per què"], "e": "Interrogativa indirecta de causa: per què, separat i amb accent."}
    ]
  },
  {
    "id": "d923e9ac-9070-5606-8e88-42183fa33825", "type": "b2_mor_relatius", "sort_order": 8,
    "title": "Pronoms relatius i subordinades de relatiu", "name": "Que, què, el qual, on i qui; relatius neutres; relatives substantives, adjectives (especificatives i explicatives) i adverbials",
    "content": "Els pronoms relatius que, què, el qual, a on i qui, els relatius neutres (cosa que, la qual cosa, fet que, amb la qual cosa) i els usos segons la classe de subordinada de relatiu: substantives, adjectives especificatives i explicatives, i adverbials (3.2.2).", "icon": "🔗", "color": "#D1C4E9",
    "exercises": [
      {"q": "«L'ordinador ___ m'he comprat és molt compacte.»", "o": ["que", "què", "el qual"], "e": "En les relatives especificatives sense preposició s'usa que (àton). «El qual» sense preposició no pot introduir especificatives."},
      {"q": "«La casa en ___ visc té més de cent anys.»", "o": ["què", "que", "qual"], "e": "Darrere de preposició, per a coses, s'usa el relatiu tònic què (en què, de què) o el qual amb article (en la qual)."},
      {"q": "«El tema de ___ parlàvem ahir ha eixit en l'examen.»", "o": ["què", "que", "qui"], "e": "De què (o del qual): relatiu darrere de preposició referit a una cosa."},
      {"q": "Quina opció NO és correcta per a completar «La ciutat ___ visc és molt tranquil·la»?", "o": ["que", "on", "en què"], "e": "Cal la preposició o l'adverbi relatiu: on (a on), en què, en la qual. «La ciutat que visc» és incorrecte."},
      {"q": "«L'empresa per a la ___ treballe ha obert una seu a Castelló.»", "o": ["qual", "que", "quals"], "e": "Per a la qual: el relatiu compost concorda amb l'antecedent (l'empresa, femení singular)."},
      {"q": "«Els documents dels ___ et vaig parlar estan damunt de la taula.»", "o": ["quals", "qual", "que"], "e": "Dels quals: concorda en plural amb «els documents»."},
      {"q": "«La persona amb ___ vaig parlar m'ho va explicar tot.»", "o": ["qui", "què", "que"], "e": "Darrere de preposició, per a persones: qui (o el qual/la qual): amb qui, amb la qual."},
      {"q": "«El professor a ___ vaig preguntar no ho sabia.»", "o": ["qui", "que", "què"], "e": "A qui (o al qual): complement indirecte de persona en una relativa."},
      {"q": "Quina frase és correcta? (complement indirecte de persona)", "o": ["La xica a qui vaig donar el llibre és ma cosina.", "La xica que li vaig donar el llibre és ma cosina.", "La xica que vaig donar-li el llibre és ma cosina."], "e": "Cal evitar el «que» + pronom redundant: a qui (o a la qual) vaig donar."},
      {"q": "Quina frase és correcta? (relatiu amb preposició)", "o": ["El veí amb qui vaig sopar viu al tercer.", "El veí que vaig sopar amb ell viu al tercer.", "El veí que amb ell vaig sopar viu al tercer."], "e": "La preposició va davant del relatiu: amb qui (o amb el qual), no «que... amb ell»."},
      {"q": "Quina frase és correcta? (relatiu possessiu)", "o": ["Tinc un amic el pare del qual és pilot.", "Tinc un amic que el seu pare és pilot.", "Tinc un amic qual pare és pilot."], "e": "Per a expressar possessió: el pare del qual (o el pare de qui). «Que el seu» és un error freqüent."},
      {"q": "Quina frase és correcta? (relatiu de lloc)", "o": ["El poble on vaig nàixer és xicotet.", "El poble que hi vaig nàixer és xicotet.", "El poble que vaig nàixer en ell és xicotet."], "e": "Lloc: on, a on, en què o en el qual. Cal evitar «que» + pronom (hi, en ell)."},
      {"q": "«La pel·lícula ___ vam vore ahir era avorrida.»", "o": ["que", "què", "la qual"], "e": "Complement directe en una especificativa: que. «La qual» sense preposició no s'usa en especificatives."},
      {"q": "Quina frase és correcta? (subjecte d'una especificativa)", "o": ["L'home que ens va atendre era molt amable.", "L'home el qual ens va atendre era molt amable.", "L'home qui ens va atendre era molt amable."], "e": "Subjecte d'una especificativa: que. Qui només va sense preposició en relatives sense antecedent (Qui ho sàpia, que ho diga)."},
      {"q": "«La meua germana, ___ viu a Elx, vindrà demà.»", "o": ["que (o la qual)", "la que", "cosa que"], "e": "En les explicatives (entre comes) el subjecte pot ser que o el qual/la qual."},
      {"q": "«Va aprovar totes les assignatures, ___ va alegrar molt els pares.»", "o": ["cosa que", "lo qual", "que"], "e": "Si l'antecedent és tota una oració, s'usa un relatiu neutre: cosa que, la qual cosa. «Lo qual» és un castellanisme."},
      {"q": "«No ha vingut a la reunió, ___ demostra que no li interessa.»", "o": ["la qual cosa", "lo que", "el qual"], "e": "La qual cosa (o cosa que) reprén tota l'oració anterior."},
      {"q": "«Ha plogut tota la setmana, ___ s'ha ajornat la cursa.»", "o": ["amb la qual cosa", "amb lo qual", "amb que"], "e": "Amb la qual cosa: relatiu neutre amb valor consecutiu."},
      {"q": "«Va dimitir sense donar explicacions, ___ va sorprendre tothom.»", "o": ["fet que", "lo que", "qual"], "e": "Fet que (o cosa que) reprén un fet expressat per l'oració anterior."},
      {"q": "Quina expressió NO pot substituir «cosa que» en «Ha arribat tard, cosa que ha molestat el cap»?", "o": ["lo qual", "la qual cosa", "fet que"], "e": "Cosa que, la qual cosa i fet que són correctes; «lo qual» no és normatiu."},
      {"q": "«___ vullguen vindre, que ho diguen.»", "o": ["Els qui", "Els quals", "Quins"], "e": "Relativa substantiva (sense antecedent): els qui o els que. «Els quals» necessita antecedent."},
      {"q": "«___ diu no té cap sentit.»", "o": ["El que", "El qual", "Què"], "e": "Relativa substantiva neutra: el que (o allò que) diu."},
      {"q": "«___ estiga interessat, que passe per secretaria.»", "o": ["Qui", "Què", "El qual"], "e": "Qui sense antecedent equival a «la persona que»: Qui estiga interessat..."},
      {"q": "«No m'agrada gens ___ has fet.»", "o": ["el que", "el qual", "que"], "e": "Relativa substantiva de complement: el que (o allò que) has fet."},
      {"q": "Quina classe de subordinada és «Qui no treballe» en «Qui no treballe no cobrarà»?", "o": ["Substantiva (relativa sense antecedent)", "Adjectiva explicativa", "Adverbial de lloc"], "e": "Les relatives sense antecedent (qui, el que, els qui) funcionen com un nom: ací, de subjecte."},
      {"q": "«Els alumnes que han llegit el llibre han superat la prova.» Què vol dir?", "o": ["Només han superat la prova els alumnes que havien llegit el llibre.", "Tots els alumnes havien llegit el llibre i tots han superat la prova.", "Cap alumne no ha llegit el llibre."], "e": "Especificativa (sense comes): restringix l'antecedent; només alguns alumnes."},
      {"q": "«Els alumnes, que han llegit el llibre, han superat la prova.» Què vol dir?", "o": ["Tots els alumnes havien llegit el llibre i tots han superat la prova.", "Només han superat la prova els que havien llegit el llibre.", "Alguns alumnes no han llegit el llibre."], "e": "Explicativa (entre comes): afig una informació sobre tot l'antecedent, sense restringir-lo."},
      {"q": "Quina relativa és explicativa i, per tant, va entre comes?", "o": ["El Micalet, que és el campanar de la catedral de València, es veu des de lluny.", "El llibre que em vas deixar és molt bo.", "Les persones que fumen han d'eixir a la terrassa."], "e": "Si l'antecedent ja està identificat (un nom propi, per exemple), la relativa és explicativa i va entre comes."},
      {"q": "Quina oració conté una relativa especificativa?", "o": ["Les pomes que estaven podrides les vam llançar.", "Mon pare, que és mestre, m'ajuda amb els deures.", "València, on vaig estudiar, és una ciutat acollidora."], "e": "L'especificativa no va entre comes i delimita l'antecedent: només les pomes podrides."},
      {"q": "Quina frase conté una relativa adjectiva?", "o": ["L'ordinador que m'he comprat és compacte.", "Diu que vindrà demà.", "Qui avisa no és traïdor."], "e": "Adjectiva: té antecedent (l'ordinador). «Diu que vindrà» és una completiva (que conjunció) i «Qui avisa» és una relativa substantiva."},
      {"q": "«He anat ___ m'havies dit, però no hi havia ningú.»", "o": ["a on", "que", "què"], "e": "Relativa adverbial de lloc sense antecedent: on o a on m'havies dit."},
      {"q": "«Ho farem ___ tu vulgues.» (manera)", "o": ["com", "què", "que"], "e": "Relativa adverbial de manera: com tu vulgues."},
      {"q": "«Telefona'm ___ arribes a casa.» (temps)", "o": ["quan", "quant", "que"], "e": "Relativa adverbial de temps: quan arribes."},
      {"q": "Quina classe de subordinada és «on vulgues» en «Seu on vulgues»?", "o": ["Adverbial de lloc", "Adjectiva especificativa", "Substantiva de complement directe"], "e": "On sense antecedent introduïx una relativa adverbial de lloc."},
      {"q": "«Este és el motiu per ___ no vaig vindre.»", "o": ["què", "que", "qui"], "e": "Darrere de preposició, per a coses: per què (o pel qual)."},
      {"q": "«L'amiga de ___ t'he parlat arriba demà.»", "o": ["qui", "que", "què"], "e": "Persona darrere de preposició: de qui (o de la qual)."},
      {"q": "Quina és la manera correcta d'expressar la possessió amb un relatiu?", "o": ["És un problema la solució del qual és complicada.", "És un problema que la seua solució és complicada.", "És un problema cuya solució és complicada."], "e": "La possessió en una relativa s'expressa amb del qual / de la qual: la solució del qual."},
      {"q": "«Hi havia una tanca darrere de la ___ s'amagava el gos.»", "o": ["qual", "que", "quals"], "e": "Darrere de preposicions compostes o llargues (darrere de, a causa de) es preferix el qual / la qual."},
      {"q": "«Has llegit la carta ___ et vaig enviar?»", "o": ["que", "què", "la qual"], "e": "Complement directe sense preposició en especificativa: que."},
      {"q": "Completa amb un relatiu d'una paraula: «La casa en ___ visc és antiga.»", "a": ["què"], "e": "En què: relatiu tònic darrere de preposició referit a cosa."},
      {"q": "Completa amb un relatiu d'una paraula: «El company amb ___ treballe és de Gandia.»", "a": ["qui"], "e": "Amb qui: persona darrere de preposició."},
      {"q": "Completa el relatiu neutre: «Va suspendre, ___ que no esperava ningú.»", "a": ["cosa"], "e": "Cosa que reprén tota l'oració anterior."},
      {"q": "Corregix la frase: «La dona que li vaig vendre el cotxe.»", "a": ["la dona a qui vaig vendre el cotxe", "la dona a la qual vaig vendre el cotxe"], "e": "Cal evitar «que li»: a qui (o a la qual) vaig vendre el cotxe."},
      {"q": "Completa (lloc): «El poble ___ vaig nàixer és xicotet.»", "a": ["on", "a on", "en què", "en el qual"], "e": "On, a on, en què o en el qual: totes són correctes; «que» sol no."}
    ]
  },
  {
    "id": "44001ca7-b8f7-5904-9f8d-3cde81657269", "type": "b2_mor_numerals", "sort_order": 9,
    "title": "Numerals: ordinals, partitius i abreviatures", "name": "Ordinals, partitius, abreviatures d'ordinals i perífrasis equivalents",
    "content": "Els numerals ordinals i partitius (mig, terç, quart, una quinta part), les abreviatures dels ordinals (1r, 2a, 3r, 4t, 5é, 1rs, 1es...) i les perífrasis equivalents (la que fa dotze) (3.2.2).", "icon": "🔢", "color": "#FFE0B2",
    "exercises": [
      {"q": "Quin és l'ordinal masculí de «set»?", "o": ["seté (o sèptim)", "sèptimo", "setené"], "e": "Set → seté (o sèptim); femení setena (o sèptima)."},
      {"q": "Quin és l'ordinal masculí de «huit»?", "o": ["huité (o octau)", "octavo", "huitené"], "e": "Huit → huité (o vuité, octau); femení huitena (o octava)."},
      {"q": "Quin és l'ordinal masculí de «nou»?", "o": ["nové", "noné", "noveno"], "e": "Nou → nové; femení novena."},
      {"q": "Quin és l'ordinal masculí de «onze»?", "o": ["onzé", "onceno", "onzeno"], "e": "A partir de cinc, l'ordinal es forma amb -é: onzé, dotzé, tretzé; femení onzena."},
      {"q": "Quin és el femení de l'ordinal «dotzé»?", "o": ["dotzena", "dotzea", "dotzéna"], "e": "Els ordinals en -é fan el femení en -ena: dotzena, quinzena, vintena."},
      {"q": "Quin és el femení de l'ordinal «quint»?", "o": ["quinta", "quinzena", "cinquea"], "e": "Quint / quinta (sinònims de cinqué / cinquena). Quinzena és l'ordinal de quinze."},
      {"q": "Quin és el plural masculí de «cinqué»?", "o": ["cinquens", "cinqués", "cinquéns"], "e": "Els ordinals en -é fan el plural en -ens: cinquens, sisens, desens."},
      {"q": "Quin és el plural de «sisena»?", "o": ["sisenes", "sisenas", "siseses"], "e": "Femení plural en -es: sisenes, cinquenes."},
      {"q": "«La seua filla va quedar ___ en la classificació.» (9a)", "o": ["novena", "nona", "nou"], "e": "9a = novena."},
      {"q": "«Este any celebrem el ___ aniversari de l'associació.» (25é)", "o": ["vint-i-cinqué", "vint-i-cinc-é", "vintecinqué"], "e": "Els ordinals compostos mantenen els guionets del cardinal: vint-i-cinqué, trenta-dosé."},
      {"q": "«És el ___ capítol del llibre.» (12é)", "o": ["dotzé", "doceavo", "dotzau"], "e": "12é = dotzé. «Doceavo» és castellà."},
      {"q": "Quin és l'ordinal masculí de «vint-i-u»?", "o": ["vint-i-uné", "vint-i-primer", "vint-i-unté"], "e": "Vint-i-u → vint-i-uné (femení vint-i-unena)."},
      {"q": "Quina expressió equival a «la casa dotzena»?", "o": ["la casa que fa dotze", "les dotze cases", "la dotzena part de la casa"], "e": "Perífrasi d'ordinal: la que fa dotze = la dotzena."},
      {"q": "Quina expressió equival a «el vint-i-cinqué»?", "o": ["el que fa vint-i-cinc", "el de vint-i-cinc parts", "els vint-i-cinc"], "e": "En la llengua parlada, per als ordinals alts és habitual la perífrasi «el que fa + cardinal»."},
      {"q": "«Era el corredor ___ trenta en la llista.» (perífrasi d'ordinal)", "o": ["que feia", "que era de", "de"], "e": "El que fa / el que feia + cardinal: el que feia trenta = el trenté."},
      {"q": "Com es diu 1/3?", "o": ["un terç", "un tercer", "un tercio"], "e": "1/3 = un terç (o la tercera part). Tercer és l'ordinal."},
      {"q": "Com es diu 3/4?", "o": ["tres quarts", "tres quartes", "tres quatres"], "e": "Els partitius concorden en nombre: un quart, tres quarts."},
      {"q": "Com es diu «la cinquena part» d'una altra manera?", "o": ["una quinta part", "una cinca part", "una quinzena part"], "e": "1/5: la cinquena part, una quinta part o un cinqué. Quinzena correspon a 15."},
      {"q": "Com es diu 2/5?", "o": ["dos cinquens", "dos cinqués", "dues cinc"], "e": "A partir de 1/5, el partitiu coincidix amb l'ordinal: un cinqué, dos cinquens."},
      {"q": "«Una ___ part dels beneficis serà per a l'ONG.» (1/5)", "o": ["quinta", "quinzena", "cinca"], "e": "Una quinta part (o una cinquena part)."},
      {"q": "Com es diu 1/10?", "o": ["un desé (o una desena part)", "un dècimo", "un deu"], "e": "1/10 = un desé o la desena part. «Dècimo» és castellà."},
      {"q": "Com es diu 1/100?", "o": ["un centèsim", "un centavo", "un centenar"], "e": "1/100 = un centèsim (la centèsima part). Un centenar són cent unitats."},
      {"q": "Com es diu 1/1000?", "o": ["un mil·lèsim", "un milèsim", "un miler"], "e": "1/1000 = un mil·lèsim, amb ela geminada. Un miler són mil unitats."},
      {"q": "«Compra ___ dotzena d'ous.»", "o": ["mitja", "mig", "mija"], "e": "Mig concorda: mig quilo, mitja dotzena, mitja hora."},
      {"q": "«Ens queden dos quilos i ___ de taronges.»", "o": ["mig", "mitja", "mitad"], "e": "Quilo és masculí: dos quilos i mig."},
      {"q": "«___ de la classe ha aprovat l'examen.» (1/2)", "o": ["La meitat", "La mitja", "El mig"], "e": "1/2 d'un conjunt: la meitat."},
      {"q": "«Han venut ___ parts de les entrades.» (2/3)", "o": ["dues terceres", "dos terceres", "dues terces"], "e": "Part és femení: dues terceres parts (o dos terços)."},
      {"q": "«Un ___ de la població viu a la capital.» (1/4)", "o": ["quart", "quarter", "quarta"], "e": "1/4 = un quart (o la quarta part)."},
      {"q": "Quina és l'abreviatura de «primer»?", "o": ["1r", "1º", "1er"], "e": "Abreviatura: xifra + l'última lletra del mot (o les últimes): 1r, 2n, 3r, 4t."},
      {"q": "Quina és l'abreviatura de «segona»?", "o": ["2a", "2na", "2da"], "e": "En femení singular: 1a, 2a, 3a, 4a, 5a..."},
      {"q": "Quina és l'abreviatura de «tercer»?", "o": ["3r", "3er", "3º"], "e": "Tercer → 3r."},
      {"q": "Quina és l'abreviatura de «quart»?", "o": ["4t", "4rt", "4º"], "e": "Quart → 4t."},
      {"q": "Quina és l'abreviatura de «cinqué»?", "o": ["5é", "5t", "5º"], "e": "A partir de cinc, en masculí singular: 5é, 6é, 8é, 10é."},
      {"q": "Quina és l'abreviatura de «sisena»?", "o": ["6a", "6na", "6é"], "e": "Femení singular: 6a (sisena)."},
      {"q": "Quina és l'abreviatura de «primers»?", "o": ["1rs", "1os", "1ers"], "e": "Masculí plural: 1rs, 2ns, 3rs, 4ts."},
      {"q": "Quina és l'abreviatura de «primeres»?", "o": ["1es", "1as", "1res"], "e": "Femení plural: 1es, 2es, 3es, 4es."},
      {"q": "Quina és l'abreviatura de «segons» (ordinal plural)?", "o": ["2ns", "2os", "2s"], "e": "Segons → 2ns."},
      {"q": "Com es llig «Va quedar en 8é lloc»?", "o": ["huité (o octau)", "huit", "huitena"], "e": "8é és masculí: huité lloc."},
      {"q": "Quina és l'abreviatura de «vint-i-huitena»?", "o": ["28a", "28é", "28na"], "e": "Femení: 28a."},
      {"q": "Escriu l'abreviatura de «quarta».", "a": ["4a"], "e": "Quarta → 4a."},
      {"q": "Escriu l'abreviatura de «tercers».", "a": ["3rs"], "e": "Tercers → 3rs."},
      {"q": "Escriu en lletres l'ordinal femení de 10.", "a": ["desena", "dècima"], "e": "Desena (o dècima)."},
      {"q": "Escriu en lletres la fracció 1/3.", "a": ["un terç", "la tercera part", "una tercera part"], "e": "Un terç (o la tercera part)."},
      {"q": "Escriu en lletres l'ordinal masculí de 12.", "a": ["dotzé", "dotzè"], "e": "Dotzé."}
    ]
  },
  {
    "id": "320c635d-e99c-5832-8629-c9a534bd31db", "type": "b2_mor_quantitatius", "sort_order": 10,
    "title": "Quantitatius i indefinits", "name": "Quantitatius variables i invariables, locucions de quantitat, indefinits i res/gens/cap",
    "content": "Els quantitatius variables i invariables (quant, prou, massa, força), les locucions de quantitat més freqüents (bona cosa de, un grapat de, un muntó de, un fum de), els indefinits (diversos, qualsevol, tal, tothom, alguna cosa) i la distinció entre res, gens i cap/ningun (3.2.2).", "icon": "⚖️", "color": "#C8E6C9",
    "exercises": [
      {"q": "Quin grup conté només quantitatius invariables?", "o": ["massa, prou, força, més", "molt, poc, tant", "quant, bastant, massa"], "e": "Massa, prou, força, més i menys no varien. Molt, poc, tant, quant i bastant sí: molta, pocs, tantes, quantes, bastants."},
      {"q": "«Hi havia ___ persones esperant a la porta.» (excés)", "o": ["massa", "masses", "massa de"], "e": "Massa és invariable: massa persones, massa soroll."},
      {"q": "«Ja tenim ___ cadires per a tots els convidats.»", "o": ["prou", "prous", "proues"], "e": "Prou és invariable: prou cadires, prou temps."},
      {"q": "«Hui hi ha ___ gent a la platja.» (bastant)", "o": ["força", "forces", "forçes"], "e": "Força com a quantitatiu és invariable: força gent, força problemes."},
      {"q": "«Hem rebut ___ queixes este mes.»", "o": ["bastants", "bastantes", "bastanta"], "e": "Bastant varia en nombre (bastant, bastants), però no en gènere: bastants queixes."},
      {"q": "«No tenia ___ ganes d'eixir aquella nit.»", "o": ["gaires", "gaira", "gaires de"], "e": "Gaire (gaires en plural) s'usa en frases negatives i interrogatives: no tenia gaires ganes."},
      {"q": "«No saps ___ m'alegre de vore't!»", "o": ["quant", "quan", "quànt"], "e": "Quant com a adverbi de quantitat: quant m'alegre! No porta accent."},
      {"q": "«Este any tenim ___ treball com l'any passat.»", "o": ["tant", "tan", "tanta"], "e": "Tant davant de nom (concorda: tant treball, tanta feina). Tan va davant d'adjectiu o adverbi: tan alt."},
      {"q": "«Hi havia ___ gent que no cabíem a la sala.»", "o": ["tanta", "tan", "tantes"], "e": "Tant concorda amb el nom: tanta gent (femení singular)."},
      {"q": "Què significa «prou» en «Ja n'hi ha prou de crits!»?", "o": ["suficient, que no n'hi ha d'haver més", "molt", "poc"], "e": "Prou: suficient. Ja n'hi ha prou! expressa que cal acabar."},
      {"q": "«Ja n'hi ha ___, d'aigua, per a tots?»", "o": ["prou", "prous", "pro"], "e": "Prou, invariable: n'hi ha prou."},
      {"q": "«A la manifestació hi havia ___ gent.» (molta)", "o": ["bona cosa de", "bona cosa", "una bona cosa"], "e": "Bona cosa de + nom: gran quantitat (bona cosa de gent, bona cosa de diners)."},
      {"q": "«Este tipus de música no m'agrada ___.»", "o": ["gens ni mica", "gens ni poc", "res ni mica"], "e": "Gens ni mica (o gens ni miqueta) reforça la negació: gens de cap manera."},
      {"q": "«Tinc ___ de coses per fer abans de les vacances.»", "o": ["un muntó", "un montó", "un montón"], "e": "Un muntó de: una gran quantitat."},
      {"q": "«M'ha regalat ___ d'ametles del seu camp.»", "o": ["un grapat", "un grapó", "una grapaeta"], "e": "Un grapat: la quantitat que cap en una mà; per extensió, uns quants."},
      {"q": "«Aquella nit hi havia ___ de mosquits.»", "o": ["un fum", "un fumat", "un humo"], "e": "Un fum de: una gran quantitat."},
      {"q": "Què significa «un fum de gent»?", "o": ["molta gent", "poca gent", "gent que fuma"], "e": "Un fum de: molts, una gran quantitat."},
      {"q": "«No queda ___ de sal al saler.»", "o": ["gens ni miqueta", "res ni miqueta", "cap ni miqueta"], "e": "Gens ni miqueta de: reforç de gens amb noms no comptables."},
      {"q": "Quina locució NO indica una gran quantitat?", "o": ["un pessic de", "un muntó de", "un fum de", "bona cosa de"], "e": "Un pessic: molt poca quantitat (un pessic de sal). Les altres indiquen molta quantitat."},
      {"q": "«Han vingut ___ persones a preguntar per tu.»", "o": ["diverses", "diversos", "diversas"], "e": "Diversos varia en gènere: diversos llibres, diverses persones."},
      {"q": "Quin és el plural de «qualsevol»?", "o": ["qualssevol", "qualsevols", "quals sevol"], "e": "Qualsevol fa el plural en el primer element: qualssevol."},
      {"q": "«Pots triar ___ dia de la setmana.»", "o": ["qualsevol", "cualsevol", "qualssevol"], "e": "Qualsevol (singular) davant de nom singular: qualsevol dia."},
      {"q": "«Tothom ___ content amb el resultat.»", "o": ["està", "estan", "estem"], "e": "Tothom va sempre amb el verb en singular."},
      {"q": "Quina frase és correcta? (concordança amb tothom)", "o": ["Tothom sap la resposta.", "Tothom saben la resposta.", "Tot el món saben la resposta."], "e": "Tothom + verb en singular: tothom sap, tothom ha vingut."},
      {"q": "«___ ha de portar el seu dinar a l'excursió.» (cada persona)", "o": ["Cadascú", "Cada", "Qualssevol"], "e": "Cadascú és pronom: cadascú porta el seu. Cada només va davant de nom."},
      {"q": "«He conegut ___ persones molt interessants en el congrés.» (diverses)", "o": ["diferents", "diferentes", "diferent"], "e": "Diferents, davant de nom plural, pot equivaldre a diversos: diferents persones."},
      {"q": "«Si passa ___, avisa'm de seguida.»", "o": ["alguna cosa", "algo", "alguna"], "e": "Alguna cosa (o quelcom): «algo» és un castellanisme."},
      {"q": "«En ___ cas, caldria repetir la prova.»", "o": ["tal", "tals", "tan"], "e": "Tal varia en nombre: tal cas, tals casos."},
      {"q": "«___ explicacions no em convencen gens.»", "o": ["Tals", "Tal", "Tales"], "e": "Davant de nom plural: tals explicacions. «Tales» és castellà."},
      {"q": "«No conec ___ en este poble.» (cap persona)", "o": ["ningú", "res", "gens"], "e": "Ningú: cap persona. Res: cap cosa. Gens: cap quantitat."},
      {"q": "«No vol ___ per a sopar.»", "o": ["res", "gens", "cap"], "e": "Res: cap cosa (pronom). No vol res."},
      {"q": "«No queda ___ de vi en l'ampolla.»", "o": ["gens", "res", "cap"], "e": "Gens + de + nom no comptable: no queda gens de vi."},
      {"q": "«No tinc ___ objecció a fer.»", "o": ["cap (o ninguna)", "res", "gens"], "e": "Cap o ningun/ninguna davant de nom comptable: no tinc cap objecció (o ninguna objecció)."},
      {"q": "«Vols ___ de la botiga?» (alguna cosa)", "o": ["res", "gens", "ningun"], "e": "En les preguntes, res té valor positiu (alguna cosa): vols res?"},
      {"q": "«Tens ___ germà?» (en una pregunta, algun)", "o": ["cap", "gens", "res"], "e": "En les preguntes, cap equival a algun: tens cap germà?"},
      {"q": "«Queda ___ de llet a la nevera?»", "o": ["gens", "cap", "ningú"], "e": "En les preguntes, gens equival a una mica: queda gens de llet?"},
      {"q": "«No tinc ___ de fam.»", "o": ["gens", "cap", "res"], "e": "Fam és un nom no comptable: gens de fam."},
      {"q": "Quina frase és correcta? (nom comptable en frase negativa)", "o": ["No hi ha cap problema.", "No hi ha gens problema.", "No hi ha res problema."], "e": "Davant de nom comptable s'usa cap (o ningun): no hi ha cap problema (o ningun problema)."},
      {"q": "Quina afirmació sobre «cap» i «ningun/ninguna» és correcta?", "o": ["Totes dues formes són correctes: «No tinc cap llibre» i «No tinc ningun llibre».", "Només «cap» és normativa.", "Només «ningun» és normativa."], "e": "L'AVL admet tant cap com ningun/ninguna davant de nom."},
      {"q": "Escriu el plural de «qualsevol».", "a": ["qualssevol"], "e": "Qualssevol."},
      {"q": "Completa: «No he menjat ___ de pa.» (quantitat no comptable)", "a": ["gens"], "e": "Gens de pa."},
      {"q": "Completa: «No ha dit ___ en tota la reunió.» (cap cosa)", "a": ["res"], "e": "No ha dit res."},
      {"q": "Completa amb un quantitatiu invariable d'excés: «Hi havia ___ persones: no cabíem a la sala.»", "a": ["massa"], "e": "Massa persones."},
      {"q": "Completa la locució: «No m'agrada gens ni ___.»", "a": ["mica", "miqueta"], "e": "Gens ni mica (o gens ni miqueta)."}
    ]
  },
  {
    "id": "9a92c7a4-ade0-5b70-8df9-06f4148cd1e0", "type": "b2_mor_preposicions", "sort_order": 11,
    "title": "Preposicions", "name": "Amb/en i a/en, preposicions de temps, sense, per i per a, i caiguda de la preposició davant de que",
    "content": "Els usos habituals de amb/en i a/en, les preposicions amb parts del dia, mesos, estacions i festes, sense, per i per a davant de sintagma nominal, i la caiguda de la preposició davant de la conjunció que (3.2.2).", "icon": "🧭", "color": "#FFCDD2",
    "exercises": [
      {"q": "«Treballa ___ Alcoi, però viu ___ Cocentaina.»", "o": ["a ... a", "en ... en", "en ... a"], "e": "Davant de noms de lloc (topònims) s'usa a: a Alcoi, a Cocentaina."},
      {"q": "Quina frase és correcta? (topònim)", "o": ["Estudia a Barcelona.", "Estudia en Barcelona.", "Estudia de Barcelona."], "e": "Topònims: a, tant per a situació com per a direcció (estudia a Barcelona, va a Barcelona)."},
      {"q": "«Pense molt ___ tu.»", "o": ["en", "amb", "a"], "e": "Pensar en algú o en alguna cosa. «Pensar amb» és incorrecte."},
      {"q": "«Confie ___ la teua discreció.»", "o": ["en", "amb", "a"], "e": "Confiar en algú o en alguna cosa."},
      {"q": "«S'ha casat ___ un company de feina.»", "o": ["amb", "en", "a"], "e": "Amb indica companyia o relació: casar-se amb algú."},
      {"q": "«Talla el pa ___ el ganivet gran.»", "o": ["amb", "en", "a"], "e": "Amb: instrument."},
      {"q": "«Hem vingut ___ autobús des de Xàtiva.»", "o": ["en (o amb)", "a", "per a"], "e": "Amb els mitjans de transport s'admet en i amb: en autobús, amb autobús. Però a peu, a cavall."},
      {"q": "«L'examen s'ha d'escriure ___ bolígraf blau.»", "o": ["amb", "a", "de"], "e": "Amb: instrument (amb bolígraf, amb llapis)."},
      {"q": "«___ aquell moment va sonar el telèfon.»", "o": ["En", "Amb", "Per a"], "e": "En: situació temporal (en aquell moment, en este moment)."},
      {"q": "«Acabaré l'informe ___ dos dies.» (temps que necessite)", "o": ["en", "a", "amb"], "e": "En + durada: el temps que es necessita per a fer una cosa (en dos dies, en una hora)."},
      {"q": "«La reunió començarà ___ les nou.»", "o": ["a", "en", "per a"], "e": "Hora puntual: a les nou, a la una."},
      {"q": "«Ens veurem ___ Nadal.»", "o": ["per", "en el", "de"], "e": "Amb les festes, per: per Nadal, per Pasqua, per Sant Joan, per Falles."},
      {"q": "«Sempre anem al poble ___ Pasqua.»", "o": ["per", "de", "en la"], "e": "Per Pasqua: les festes porten la preposició per."},
      {"q": "«___ Sant Joan anem a la platja a fer fogueres.»", "o": ["Per", "En", "De"], "e": "Per Sant Joan."},
      {"q": "«Les classes comencen ___ setembre.»", "o": ["al (o en)", "de", "per a"], "e": "Amb els mesos: al setembre o en setembre (també el mes de setembre)."},
      {"q": "«Les Falles se celebren ___ març.»", "o": ["al (o en)", "a", "de"], "e": "Al març o en març."},
      {"q": "«___ l'estiu fa molta calor a València.»", "o": ["A", "De", "Per a"], "e": "Amb les estacions: a l'estiu, a la primavera, a la tardor, a l'hivern."},
      {"q": "«Treballa ___ nit, en un hospital.»", "o": ["de", "a", "per a"], "e": "De nit, de dia, de matí: locucions de temps."},
      {"q": "«M'alce ___ matí per a anar a córrer.»", "o": ["de", "a", "per a"], "e": "De matí: a primera hora, prompte."},
      {"q": "«Quedem ___ vesprada per a estudiar?»", "o": ["a la", "de la", "en"], "e": "Parts del dia: a la vesprada, al matí, a la nit."},
      {"q": "Quina frase és correcta? (dies de la setmana)", "o": ["Vindré dilluns.", "Vindré en dilluns.", "Vindré al dilluns."], "e": "Els dies de la setmana van sense preposició: vindré dilluns; els dilluns tanquen."},
      {"q": "«Vaig nàixer ___ 15 de març de 1990.»", "o": ["el", "en el", "al"], "e": "Les dates van amb l'article, sense preposició: el 15 de març."},
      {"q": "«Han comprat material ___ l'escola.» (destinatari)", "o": ["per a", "per", "a"], "e": "Per a: destinatari o finalitat."},
      {"q": "«El lladre va entrar ___ la finestra.» (lloc de pas)", "o": ["per", "per a", "a"], "e": "Per: lloc per on es passa."},
      {"q": "«L'acord va ser signat ___ tots els grups.» (agent)", "o": ["per", "per a", "de per"], "e": "Per introduïx l'agent de la passiva."},
      {"q": "«Ho ha fet ___ amor als fills.» (causa)", "o": ["per", "per a", "a"], "e": "Per: causa o motiu."},
      {"q": "«Necessite l'informe ___ dimarts.» (termini)", "o": ["per a", "per", "a"], "e": "Per a: termini (per a dimarts, per a la setmana que ve)."},
      {"q": "«Li han donat cent euros ___ el cotxe vell.» (preu, canvi)", "o": ["per", "per a", "a"], "e": "Per: preu, canvi o intercanvi."},
      {"q": "«Passejàvem ___ la platja quan es va fer de nit.»", "o": ["per", "per a", "a per"], "e": "Per: lloc per on es passa o es fa un moviment sense direcció concreta."},
      {"q": "«M'agrada el café ___ sucre.»", "o": ["sense", "sin", "sense de"], "e": "Sense + sintagma nominal, sense cap altra preposició: sense sucre."},
      {"q": "«No sé què faria ___ la teua ajuda.»", "o": ["sense", "sense de", "sin"], "e": "Sense la teua ajuda."},
      {"q": "«Va eixir ___ paraigua i es va banyar.»", "o": ["sense", "sin", "sense de"], "e": "Sense paraigua."},
      {"q": "Quina frase és correcta? (preposició davant de que)", "o": ["Estic segur que vindrà.", "Estic segur de que vindrà.", "Estic segur de què vindrà."], "e": "La preposició de cau davant de la conjunció que: segur que."},
      {"q": "«M'alegre ___ hages aprovat.»", "o": ["que", "de que", "de què"], "e": "Alegrar-se de: la preposició cau davant de que (m'alegre que...)."},
      {"q": "«Tinc ganes ___ arribe l'estiu.»", "o": ["que", "de que", "de què"], "e": "Tindre ganes de + que → tinc ganes que."},
      {"q": "«El fet ___ no hages vingut m'ha decebut.»", "o": ["que", "de que", "de què"], "e": "El fet que: sense de."},
      {"q": "«Es queixa ___ ningú l'escolta.»", "o": ["que", "de que", "de què"], "e": "Queixar-se de: es queixa que..."},
      {"q": "«Abans ___ arribe el tren, compra els bitllets.»", "o": ["que", "de que", "de què"], "e": "Abans de + infinitiu, però abans que + oració amb verb conjugat."},
      {"q": "Quina afirmació sobre la preposició «de» davant de la conjunció «que» és correcta?", "o": ["Cau («Estic convençut que...»), però es manté davant d'infinitiu («Estic convençut d'haver-ho fet»).", "Es manté sempre: «Estic convençut de que...».", "Només cau en el registre col·loquial."], "e": "Davant de la conjunció que, la preposició de cau; davant d'infinitiu o de nom, es manté."},
      {"q": "Escriu la preposició: «Ens veurem ___ Pasqua.»", "a": ["per"], "e": "Per Pasqua."},
      {"q": "Escriu la preposició: «Estes flors són ___ la professora.» (destinatari)", "a": ["per a"], "e": "Per a la professora."},
      {"q": "Corregix la frase: «Estic convençut de que guanyarem.»", "a": ["estic convençut que guanyarem"], "e": "La preposició de cau davant de que."},
      {"q": "Escriu la preposició: «Talla-ho ___ les tisores.» (instrument)", "a": ["amb"], "e": "Amb les tisores."}
    ]
  },
  {
    "id": "297f5671-57a5-5046-aef1-f37db3b69443", "type": "b2_mor_adverbis", "sort_order": 12,
    "title": "Adverbis d'afirmació i de dubte", "name": "Sí, també, tampoc, fins i tot, prou, potser i altres adverbis i locucions",
    "content": "Els adverbis i locucions adverbials d'afirmació (sí, també, fins i tot, inclús, prou, i tant, per descomptat) i de dubte (potser, tal vegada, probablement), amb la coordinació d'adverbis en -ment (3.2.2).", "icon": "✅", "color": "#F0F4C3",
    "exercises": [
      {"q": "«Ara ___ que ho entenc!» (èmfasi)", "o": ["sí", "si", "sí de"], "e": "Sí que reforça una afirmació: ara sí que ho entenc. Sí adverbi porta accent."},
      {"q": "«Ell ___ ho sap, no com nosaltres.» (afirmació enfàtica)", "o": ["sí que", "si que", "sí qué"], "e": "Sí que: afirmació reforçada."},
      {"q": "Quina frase és correcta per a sumar dues negacions?", "o": ["Ell no hi anirà, i jo tampoc.", "Ell no hi anirà, i jo també no.", "Ell no hi anirà, i jo també."], "e": "Per a sumar una negació s'usa tampoc, no «també no»."},
      {"q": "«A mi m'agrada el teatre, i a ella ___.»", "o": ["també", "tampoc", "tan bé"], "e": "També suma una afirmació; tampoc, una negació."},
      {"q": "«No m'agraden les ciutats grans; a ma germana ___.»", "o": ["tampoc", "també no", "també"], "e": "Negació + negació: tampoc."},
      {"q": "Quina d'estes respostes és correcta?", "o": ["Tampoc no ho sé.", "També no ho sé.", "Tampoc sí ho sé."], "e": "Tampoc (o tampoc no): «també no» és incorrecte."},
      {"q": "«Han vingut tots, ___ el director.»", "o": ["fins i tot (o inclús)", "fins tot", "inclusiu"], "e": "Fins i tot o inclús: inclusió d'un element inesperat."},
      {"q": "«___ els experts s'equivoquen de vegades.»", "o": ["Fins i tot", "Hasta", "Fins a"], "e": "Fins i tot (o inclús). «Hasta» és castellà; «fins a» indica límit."},
      {"q": "Quina parella té el mateix significat?", "o": ["fins i tot / inclús", "també / tampoc", "potser / segur"], "e": "Fins i tot i inclús són sinònims."},
      {"q": "Quina afirmació sobre «inclús» és correcta?", "o": ["És correcta i equival a «fins i tot».", "És un castellanisme i cal evitar-la.", "Només es pot usar al final de la frase."], "e": "Inclús és un adverbi normatiu, sinònim de fins i tot."},
      {"q": "«—Has acabat el treball? —___! Fa dies.»", "o": ["I tant", "I tan", "Hi tant"], "e": "I tant!: afirmació enfàtica."},
      {"q": "«—Ens ajudaràs a pintar? —___ que sí!»", "o": ["Clar", "Claro", "Clara"], "e": "Clar que sí, és clar que sí. «Claro» és castellà."},
      {"q": "Quina d'estes expressions és una locució d'afirmació?", "o": ["per descomptat", "de cap manera", "en absolut"], "e": "Per descomptat: sí, sens dubte. De cap manera i en absolut són de negació."},
      {"q": "«—Vindràs dissabte a la paella? —___!» (sí, és clar, col·loquial)", "o": ["Prou", "Massa", "Gaire"], "e": "En valencià, prou pot ser un adverbi d'afirmació: «Prou!» = sí, és clar."},
      {"q": "«És ___ intel·ligent per a entendre-ho.» (suficientment)", "o": ["prou", "prous", "suficient de"], "e": "Prou també és adverbi de quantitat: prou intel·ligent (invariable)."},
      {"q": "«La teua proposta és, ___, la millor.»", "o": ["certament", "certamente", "ciertament"], "e": "Certament: afirmació (és cert)."},
      {"q": "«—Vas ser tu qui va trucar? —___, vaig ser jo.»", "o": ["Efectivament", "Efectivamente", "Efectivamènt"], "e": "Efectivament (o en efecte): confirma el que s'ha dit."},
      {"q": "«—No has fet els deures, oi? —___ sí, els he fet tots!»", "o": ["Doncs", "Pues", "Pos"], "e": "Doncs sí: afirmació que contradiu una suposició. «Pues» i «pos» no són normatius."},
      {"q": "«Sens ___, és el millor jugador de l'equip.»", "o": ["dubte", "dupte", "duda"], "e": "Sens dubte: afirmació segura."},
      {"q": "Quin adverbi expressa una afirmació segura?", "o": ["evidentment", "potser", "tal vegada"], "e": "Evidentment afirma; potser i tal vegada expressen dubte."},
      {"q": "«___ estic equivocat, però crec que no és així.»", "o": ["Potser", "Pot ser", "Pot-ser"], "e": "Potser (adverbi, en una paraula): dubte o possibilitat."},
      {"q": "En «Pot ser que ploga demà», per què «pot ser» s'escriu separat?", "o": ["Perquè és el verb poder + el verb ser, seguit de «que» + subjuntiu.", "Perquè és un adverbi de dubte.", "Perquè va al principi de la frase."], "e": "Pot ser que + subjuntiu és una construcció verbal (poder + ser); potser, junt, és l'adverbi."},
      {"q": "Quina frase amb un adverbi de dubte és correcta?", "o": ["Potser vindrà demà.", "Pot ser vindrà demà.", "Pot-ser vindrà demà."], "e": "Potser (adverbi, en una paraula i sense guionet) + verb; o bé pot ser que + subjuntiu (pot ser que vinga)."},
      {"q": "Amb l'adverbi «potser», quin mode verbal es pot usar?", "o": ["Tant l'indicatiu com el subjuntiu: «Potser ve» / «Potser vinga».", "Només el subjuntiu.", "Només l'indicatiu."], "e": "Potser admet indicatiu i subjuntiu: potser vindrà, potser vinga."},
      {"q": "Quina diferència hi ha entre «potser» i «pot ser»?", "o": ["Potser és un adverbi; pot ser és verb + verb i va seguit de «que».", "Són dues grafies de la mateixa paraula.", "Pot ser és l'adverbi i potser, el verb."], "e": "Potser vindrà (adverbi) / pot ser que vinga (verb)."},
      {"q": "«___ arribaran a temps, si no hi ha trànsit.»", "o": ["Probablement", "Probablemente", "Probable"], "e": "Probablement: dubte amb força probabilitat."},
      {"q": "«Hui no ha vingut; ___ està malalt.»", "o": ["segurament", "seguramente", "segurment"], "e": "Segurament: probablement, possiblement."},
      {"q": "«___ siga millor esperar uns dies.»", "o": ["Tal vegada", "Tal vegades", "Tal vez"], "e": "Tal vegada (o tal volta): potser."},
      {"q": "Quina d'estes expressions NO expressa dubte?", "o": ["i tant", "potser", "tal vegada", "probablement"], "e": "I tant expressa afirmació; les altres, dubte o possibilitat."},
      {"q": "«___ ens tornem a vore algun dia.»", "o": ["Potser", "Quizás", "A lo millor"], "e": "Potser (o tal vegada). «Quizás» i «a lo millor» no són normatius."},
      {"q": "Quina és la forma de coordinar dos adverbis en -ment evitant la repetició?", "o": ["ràpida i eficaçment", "ràpid i eficaçment", "ràpidament i eficaç"], "e": "Quan es coordinen adverbis en -ment, el primer pot perdre el sufix però manté la forma femenina: ràpida i eficaçment."},
      {"q": "«Ho va explicar ___.» (clar i concís)", "o": ["clara i concisament", "clar i concisament", "clarament i concisa"], "e": "Clara i concisament: el primer adjectiu en femení, sense -ment."},
      {"q": "Quin és l'adverbi en -ment de «feliç»?", "o": ["feliçment", "felisment", "feliçament"], "e": "Feliç → feliçment (adjectiu d'una terminació + -ment)."},
      {"q": "Quin és l'adverbi en -ment de «cortés»?", "o": ["cortesament", "cortésment", "cortesment"], "e": "Els adverbis en -ment es formen sobre el femení: cortesa → cortesament."},
      {"q": "Quin és l'adverbi en -ment de «fàcil»?", "o": ["fàcilment", "facilment", "fàcilament"], "e": "Fàcil → fàcilment: conserva l'accent de l'adjectiu."},
      {"q": "Quin és l'adverbi en -ment de «lent»?", "o": ["lentament", "lentment", "lentíssim"], "e": "Sobre el femení: lenta → lentament."},
      {"q": "Escriu l'adverbi en -ment derivat de «ràpid».", "a": ["ràpidament"], "e": "Ràpida → ràpidament."},
      {"q": "Completa: «A mi no em convenç, i a ell ___.»", "a": ["tampoc", "tampoc no"], "e": "Tampoc: suma d'una negació."},
      {"q": "Escriu en una paraula l'adverbi: «Pot ser que arribe tard» = «___ arribarà tard».", "a": ["potser"], "e": "Potser."},
      {"q": "Completa la locució: «Han vingut tots, fins ___ el director.»", "a": ["i tot"], "e": "Fins i tot."},
      {"q": "Completa amb la forma correcta: «Parla ___ i lentament.» (suau)", "a": ["suau"], "e": "Suau i lentament: el primer adjectiu (d'una terminació) no porta -ment."}
    ]
  },
  {
    "id": "14d209f8-8c3b-556c-9f52-f9fdf3f86c63", "type": "b2_mor_connectors", "sort_order": 13,
    "title": "Conjuncions i connectors", "name": "Adversatius, concessius, distributius, causals i «que» expletiu",
    "content": "Connectors adversatius i concessius (en canvi, per contra, no obstant això, tanmateix, si bé, tot i que), distributius (així com, no sols... sinó també, ara... ara), causals (a causa de, per culpa de, com que, ja que, atés que) i la conjunció que a l'inici d'interrogatives i exclamatives (3.2.2).", "icon": "🔗", "color": "#F0F4C3",
    "exercises": [
      {"q": "«La seua germana és molt extravertida; ell, ___, és molt tímid.»", "o": ["en canvi", "sinó", "ja que"], "e": "En canvi (o per contra) contraposa dues informacions: ell, en canvi, és tímid."},
      {"q": "«Les vendes han baixat este trimestre; ___, els beneficis han augmentat.»", "o": ["per contra", "per tant", "ja que"], "e": "Per contra = en canvi: introduïx una informació oposada a l'anterior. Per tant és consecutiu."},
      {"q": "«El projecte era molt interessant; ___, no va obtindre finançament.»", "o": ["no obstant això", "per tant", "així com"], "e": "No obstant això (o això no obstant, tanmateix): oposició a allò que s'esperava."},
      {"q": "«Les proves eren concloents. ___, el jurat el va absoldre.»", "o": ["Això no obstant", "Atés que", "Així com"], "e": "Això no obstant = no obstant això: connector adversatiu, propi del registre formal."},
      {"q": "«___ les dificultats, el projecte va eixir avant.»", "o": ["No obstant", "No obstant això", "Per contra"], "e": "Davant d'un nom, no obstant funciona com a preposició (= malgrat): no obstant les dificultats. No obstant això introduïx una oració: «No obstant això, va eixir avant»."},
      {"q": "«Tenia tots els mitjans per a guanyar; ___, va perdre.»", "o": ["tanmateix", "doncs", "com que"], "e": "Tanmateix: adversatiu (= no obstant això). Doncs és consecutiu i com que és causal."},
      {"q": "«M'agradaria ajudar-te, ___ ara mateix no tinc temps.»", "o": ["però", "sinó", "si bé que"], "e": "Però: oposició entre dues oracions. Sinó només s'usa després d'una negació (no A, sinó B)."},
      {"q": "Quina d'estes oracions conté un connector adversatiu?", "o": ["Volia vindre; tanmateix, no va poder.", "Volia vindre; per tant, va vindre.", "Volia vindre, ja que li agrada la festa."], "e": "Tanmateix és adversatiu; per tant és consecutiu i ja que és causal."},
      {"q": "«No sols no m'ha ajudat, ___ que a més m'ha posat entrebancs.»", "o": ["sinó", "si no", "però"], "e": "No sols... sinó que + oració. Sinó (junt) corregix o amplia una negació; si no (separat) és condicional."},
      {"q": "«___ m'ho demanes amb educació, no t'ho deixaré.» (condició negativa)", "o": ["Si no", "Sinó", "Si bé"], "e": "Si no (separat) = si + no: condició negativa. Sinó (junt) és adversatiu."},
      {"q": "«No fa res ___ queixar-se tot el dia.»", "o": ["sinó", "si no", "que no"], "e": "No... sinó = només: «No fa res sinó queixar-se» (no fa res més que queixar-se)."},
      {"q": "«___ és car, el material és de primera qualitat.»", "o": ["Si bé", "Sinó", "Per culpa que"], "e": "Si bé + indicatiu: concessiva (= encara que, tot i que)."},
      {"q": "«___ ser molt jove, ja dirigix l'empresa.»", "o": ["Tot i", "Malgrat de", "Encara"], "e": "Tot i + infinitiu: concessiva (tot i ser jove). També «malgrat ser jove», però mai *malgrat de."},
      {"q": "«___ que no li agrada, ho fa cada dia.»", "o": ["Malgrat", "Sinó", "Com"], "e": "Malgrat que (o tot i que, encara que) + oració: concessiva."},
      {"q": "«Per molt que ___, no el convenceràs.» (insistir, tu)", "o": ["insistisques", "insistixes", "insistiràs"], "e": "Per molt (o per més) que exigix subjuntiu: per molt que insistisques."},
      {"q": "Quina frase és correcta?", "o": ["Tot i que estava cansada, va continuar.", "Tot i estava cansada, va continuar.", "Tot que estava cansada, va continuar."], "e": "Tot i que + verb conjugat; tot i + infinitiu (tot i estar cansada)."},
      {"q": "«Hi assistiran els alumnes, ___ els professors i les famílies.» (i també)", "o": ["així com", "així que", "com que"], "e": "Així com = i també (afig elements). Així que és consecutiu; com que és causal."},
      {"q": "«No sols parla anglés, ___ també alemany.»", "o": ["sinó", "si no", "però"], "e": "No sols (o no solament)... sinó també: suma dos elements remarcant el segon."},
      {"q": "«No solament ha aprovat, ___ ha tret la millor nota de la classe.»", "o": ["sinó que", "si no que", "sinó"], "e": "Davant d'una oració amb verb conjugat: no solament... sinó que."},
      {"q": "Quina frase és correcta?", "o": ["No sols és intel·ligent, sinó que també és treballador.", "No sols és intel·ligent, si no que també és treballador.", "No sols és intel·ligent, però també és treballador."], "e": "La correlació és no sols... sinó (que) també, amb sinó junt."},
      {"q": "«___ plora, ___ riu: no hi ha qui l'entenga.»", "o": ["Ara... ara", "Sinó... sinó", "Com que... com que"], "e": "Connectors distributius: ara... ara, ja... ja, bé... bé, o... o."},
      {"q": "«Pots pagar ___ amb targeta, ___ en efectiu.»", "o": ["bé... bé", "sinó... sinó", "ja que... ja que"], "e": "Bé... bé (o o bé... o bé): distributiu que presenta alternatives."},
      {"q": "«Hi van anar ___ el pare ___ la mare.»", "o": ["tant... com", "tan... com", "tant... que"], "e": "Tant... com: suma dos elements («tant el pare com la mare»). Tan... com compara adjectius o adverbis (tan alt com)."},
      {"q": "«El tren va arribar tard ___ la boira.»", "o": ["a causa de", "a causa", "degut a que"], "e": "A causa de (o per culpa de) + nom. L'AVL recomana «a causa de» en lloc de «degut a» amb valor causal."},
      {"q": "Quina és la forma recomanada per l'AVL en «L'acte s'ha ajornat ___ el mal temps»?", "o": ["a causa de", "degut a", "en raó a"], "e": "Per a introduir una causa: a causa de, per culpa de, per raó de. «Degut a» causal no és recomanable."},
      {"q": "«___ la teua distracció, hem perdut el tren.» (to de retret)", "o": ["Per culpa de", "Gràcies a", "Ja que"], "e": "Per culpa de: causa amb valor negatiu. Gràcies a: causa amb valor positiu."},
      {"q": "«___ no tenia diners, no va poder pagar l'entrada.»", "o": ["Com que", "Com", "Doncs"], "e": "A l'inici de la frase, la causal s'introduïx amb «com que». *«Com no tenia...» és un calc del castellà."},
      {"q": "«No va poder pagar l'entrada, ___ no tenia diners.»", "o": ["ja que", "com que", "doncs que"], "e": "Quan la causa va darrere: ja que, perquè, atés que. «Com que» només va a l'inici."},
      {"q": "«___ el termini ha vençut, no s'admetran més sol·licituds.» (registre formal)", "o": ["Atés que", "Degut a que", "Per culpa que"], "e": "Atés que (= ja que, vist que) és adequat en registre formal."},
      {"q": "«Ho farem així, ___ ho establix la normativa.» (registre culte)", "o": ["puix que", "pues que", "doncs que"], "e": "Puix que = ja que (registre culte). «Doncs» no és causal sinó consecutiu."},
      {"q": "«No entenc ___ no m'ho has dit abans.» (interrogativa indirecta)", "o": ["per què", "perquè", "per a què"], "e": "Interrogativa (directa o indirecta) de causa: per què, separat i amb accent. Perquè (junt) introduïx la causa o la finalitat."},
      {"q": "Quin d'estos connectors NO és causal?", "o": ["per tant", "ja que", "atés que", "puix que"], "e": "Per tant és consecutiu; ja que, atés que i puix que són causals."},
      {"q": "«___ vindràs a sopar esta nit?» (pregunta de resposta sí o no)", "o": ["Que", "Què", "Quin"], "e": "A l'inici de les interrogatives totals es pot posar la conjunció «que», sense accent: Que vindràs? «Què» és el pronom interrogatiu."},
      {"q": "«___ vols per a sopar?»", "o": ["Què", "Que", "Quin"], "e": "Ací pregunta per una cosa: pronom interrogatiu «què», amb accent."},
      {"q": "Quina pregunta comença amb la conjunció «que» expletiva (i no amb el pronom «què»)?", "o": ["Que tens fam?", "Què tens a la bossa?", "De què parleu?"], "e": "En «Que tens fam?» la conjunció només reforça la pregunta: es pot llevar (Tens fam?). En les altres, «què» és pronom i porta accent."},
      {"q": "En «Que no saps que hui és festa?», el primer «que» és...", "o": ["una conjunció expletiva que reforça la pregunta", "un pronom interrogatiu", "un pronom relatiu"], "e": "Que expletiu: encapçala una interrogativa total i no aporta significat (= No saps que hui és festa?)."},
      {"q": "«___ bonic que és este paisatge!»", "o": ["Que", "Què", "Quin"], "e": "En exclamatives davant d'adjectiu o adverbi: que (sense accent). Que bonic!, Que bé! Davant de nom: quin (Quin paisatge!)."},
      {"q": "Quina és correcta?", "o": ["Que bé que ho has fet!", "Què bé que ho has fet!", "Qué bé que ho has fet!"], "e": "El «que» exclamatiu no porta accent: Que bé!, Que tard!"},
      {"q": "Escriu el connector adversatiu d'una sola paraula (comença per t-): «Ho va intentar moltes vegades; ___, no ho va aconseguir.»", "a": ["tanmateix"], "e": "Tanmateix = no obstant això."},
      {"q": "Completa amb «sinó» o «si no»: «No és meu, ___ del meu germà.»", "a": ["sinó"], "e": "Sinó: corregix la negació anterior."},
      {"q": "Completa amb «sinó» o «si no»: «___ te'n vas ara, perdràs l'autobús.»", "a": ["si no"], "e": "Si no: condició negativa."},
      {"q": "Escriu el connector causal de dues paraules que pot anar a l'inici: «___ ja era tard, vam agafar un taxi.»", "a": ["com que", "ja que", "atés que"], "e": "Com que (o ja que, atés que) + indicatiu."},
      {"q": "Completa amb dues paraules: «No sols canta bé, ___ també balla.»", "a": ["sinó que"], "e": "Davant d'oració: no sols... sinó que també."}
    ]
  },
  {
    "id": "2dd066c3-744e-516b-821b-7162438da4ad", "type": "b2_mor_verbs_irregulars", "sort_order": 14,
    "title": "Verbs irregulars: velaritzats, canvis vocàlics i imperfet", "name": "Córrer i derivats, verbs en -ndre, -ure i -ldre, collir, bullir, tossir i l'imperfet",
    "content": "Verbs irregulars velaritzats més habituals (córrer i derivats, verbs en -ndre, vocal + -ure i -ldre), verbs amb canvis vocàlics (collir, bollir, tossir, cosir, escopir, eixir) i l'imperfet d'indicatiu regular i irregular (veia, queia, réieu) (3.2.2).", "icon": "🧩", "color": "#FFE0B2",
    "exercises": [
      {"q": "«La notícia ___ ràpidament pel poble.» (córrer, passat simple)", "o": ["corregué", "corré", "corrí"], "e": "Passat simple de córrer: correguí, corregueres, corregué, correguérem, correguéreu, corregueren."},
      {"q": "«No vull que ___ per la carretera amb la bici.» (córrer, subjuntiu, tu)", "o": ["córregues", "corres", "correguis"], "e": "Present de subjuntiu: córrega, córregues, córrega, correguem, corregueu, córreguen."},
      {"q": "«Cada matí ___ cinc quilòmetres.» (recórrer, present, jo)", "o": ["recórrec", "recorro", "recorre"], "e": "Recórrer es conjuga com córrer: recórrec, recorres, recorre..."},
      {"q": "Quin és el participi de «recórrer»?", "o": ["recorregut", "recorrut", "recorrit"], "e": "Recorregut (com corregut, socorregut, ocorregut)."},
      {"q": "«Els bombers han ___ els ferits de l'accident.» (socórrer)", "o": ["socorregut", "socorrit", "socorrut"], "e": "Socórrer → socorregut."},
      {"q": "«Què ha ___? Hi ha molta gent al carrer.» (ocórrer)", "o": ["ocorregut", "ocorrit", "ocurrit"], "e": "Ocórrer → ocorregut."},
      {"q": "«Jo sempre ___ el café sense sucre.» (prendre, present)", "o": ["prenc", "prendo", "prenet"], "e": "Prendre: prenc, prens, pren, prenem, preneu, prenen."},
      {"q": "«Qui m'ha ___ el bolígraf?» (prendre)", "o": ["pres", "prengut", "prendit"], "e": "Participi de prendre: pres, presa, presos, preses."},
      {"q": "«Jo no ___ res del que diu.» (entendre, present)", "o": ["entenc", "entendo", "entenet"], "e": "Entendre: entenc, entens, entén, entenem, enteneu, entenen."},
      {"q": "«Hem ___ la llar perquè fa fred.» (encendre)", "o": ["encés", "encengut", "encendit"], "e": "Encendre → encés / encesa."},
      {"q": "Quin és el participi de «vendre»?", "o": ["venut", "vendut", "vendit"], "e": "Vendre → venut (venc, vens, ven...)."},
      {"q": "«Jo sempre ___ els meus drets.» (defendre, present)", "o": ["defenc", "defendo", "defens"], "e": "Defendre: defenc, defens, defén... (defens és la forma de tu)."},
      {"q": "Quin és el participi de «respondre»?", "o": ["respost", "respongut", "responit"], "e": "Respondre → respost / resposta."},
      {"q": "«La neu s'ha ___ amb el sol.» (fondre)", "o": ["fos", "fongut", "fondit"], "e": "Fondre → fos / fosa (fonc, fons, fon...)."},
      {"q": "«Les gallines han ___ molts ous esta setmana.» (pondre)", "o": ["post", "pongut", "pondit"], "e": "Pondre → post / posta."},
      {"q": "«Jo no ___ alcohol.» (beure, present)", "o": ["bec", "beu", "bebo"], "e": "Beure: bec, beus, beu, bevem, beveu, beuen. Participi: begut."},
      {"q": "«Jo ___ a Alacant des de fa anys.» (viure, present)", "o": ["visc", "viu", "vivo"], "e": "Viure: visc, vius, viu, vivim, viviu, viuen."},
      {"q": "Quin és el participi de «viure»?", "o": ["viscut", "vivit", "viut"], "e": "Viure → viscut."},
      {"q": "«Espere que m'___ prompte.» (escriure, subjuntiu, tu)", "o": ["escrigues", "escrius", "escrivis"], "e": "Subjuntiu d'escriure: escriga, escrigues, escriga..."},
      {"q": "«Hem ___ molt amb la pel·lícula.» (riure)", "o": ["rigut", "riut", "rist"], "e": "Riure: ric, rius, riu... Participi: rigut."},
      {"q": "«Jo et ___ cinquanta euros.» (deure, present)", "o": ["dec", "deuc", "debo"], "e": "Deure: dec, deus, deu, devem, deveu, deuen. Participi: degut."},
      {"q": "«Jo sempre ___ en la mateixa trampa.» (caure, present)", "o": ["caic", "cac", "caigo"], "e": "Caure: caic, caus, cau, caiem, caieu, cauen. Participi: caigut."},
      {"q": "«Ha ___ tota la nit.» (ploure)", "o": ["plogut", "plovut", "plougut"], "e": "Ploure → plogut (subjuntiu: ploga)."},
      {"q": "«No et ___ d'ací fins que torne.» (moure, subjuntiu, tu)", "o": ["mogues", "mous", "movis"], "e": "Moure: moc, mous, mou... Subjuntiu: moga, mogues. Participi: mogut."},
      {"q": "«Quant ___ estes sabates?» (valdre, present)", "o": ["valen", "valguen", "valdren"], "e": "Valdre: valc, vals, val, valem, valeu, valen. Participi: valgut."},
      {"q": "«Jo sempre ___ els problemes a temps.» (resoldre, present)", "o": ["resolc", "resolo", "resol"], "e": "Resoldre: resolc, resols, resol... (resol és la 3a persona). Participi: resolt."},
      {"q": "Quin és el participi de «absoldre»?", "o": ["absolt", "absolgut", "absoldit"], "e": "Absoldre → absolt (com resoldre → resolt, moldre → molt)."},
      {"q": "«Jo ___ les taronges de l'arbre.» (collir, present)", "o": ["cull", "coll", "collisc"], "e": "Collir: cull, culls, cull, collim, colliu, cullen. La o tònica es fa u."},
      {"q": "«L'aigua ja ___: tira la pasta.» (bollir o bullir, present)", "o": ["bull", "boll", "bullix"], "e": "Bollir / bullir: bull, bulls, bull, bollim (bullim), bolliu (bulliu), bullen."},
      {"q": "«Els xiquets ___ tota la nit.» (tossir, present)", "o": ["tussen", "tossen", "tossixen"], "e": "Tossir: tus, tusses, tus, tossim, tossiu, tussen."},
      {"q": "«Jo mateixa ___ els botons de la camisa.» (cosir, present)", "o": ["cus", "cosc", "cosisc"], "e": "Cosir: cus, cuses, cus, cosim, cosiu, cusen."},
      {"q": "«Este xiquet ___ quan s'enfada.» (escopir, present)", "o": ["escup", "escop", "escopa"], "e": "Escopir: escup, escups, escup, escopim, escopiu, escupen."},
      {"q": "«Jo ___ de casa a les huit.» (eixir, present)", "o": ["isc", "eixo", "eixc"], "e": "Eixir: isc, ixes, ix, eixim, eixiu, ixen."},
      {"q": "«De xicotet, ___ els dibuixos animats cada vesprada.» (veure o vore, imperfet, jo)", "o": ["veia", "vea", "voria"], "e": "Imperfet de veure/vore: veia, veies, veia, véiem, véieu, veien."},
      {"q": "«Vosaltres ___ massa la televisió.» (veure o vore, imperfet)", "o": ["véieu", "veieu", "veíeu"], "e": "Véieu porta accent: és una paraula esdrúixola (vé-ieu)."},
      {"q": "«Quan érem xicotets, ___ sovint de la bicicleta.» (caure, imperfet, nosaltres)", "o": ["quèiem", "caíem", "caiem"], "e": "Imperfet de caure: queia, queies, queia, quèiem, quèieu, queien. «Caiem» és present."},
      {"q": "«De què ___ tant, en la classe?» (riure, imperfet, vosaltres)", "o": ["réieu", "reieu", "rieu"], "e": "Imperfet de riure: reia, reies, reia, réiem, réieu, reien. «Rieu» és present."},
      {"q": "«Cada dia ___ el gos a passejar.» (dur, imperfet, ell)", "o": ["duia", "dua", "durïa"], "e": "Imperfet de dur: duia, duies, duia, dúiem, dúieu, duien."},
      {"q": "«Abans jo ___ la brossa cada nit.» (traure, imperfet)", "o": ["treia", "trauria", "trea"], "e": "Imperfet de traure: treia, treies, treia... (trauria és condicional)."},
      {"q": "«Vosaltres sempre ___ els primers en les carreres.» (córrer, imperfet)", "o": ["corríeu", "correieu", "corrieu"], "e": "Imperfet regular de la 2a conjugació: corria, corries, corria, corríem, corríeu, corrien."},
      {"q": "Escriu el participi de «prendre».", "a": ["pres"], "e": "Pres / presa."},
      {"q": "Escriu la primera persona del present de «viure»: jo ___.", "a": ["visc"], "e": "Visc."},
      {"q": "Escriu l'imperfet de «riure» per a «vosaltres».", "a": ["réieu", "rèieu"], "e": "Réieu."},
      {"q": "Escriu la primera persona del present de «collir»: jo ___.", "a": ["cull"], "e": "Cull."},
      {"q": "Escriu el participi de «resoldre».", "a": ["resolt"], "e": "Resolt."}
    ]
  },
  {
    "id": "9831f57a-9672-5b7f-860c-6d8d7adfbde7", "type": "b2_mor_subjuntiu", "sort_order": 15,
    "title": "Subjuntiu i ordes en negatiu", "name": "Usos del subjuntiu, correlació de temps i imperatiu negatiu",
    "content": "Usos del subjuntiu en subordinades de desig, dubte, finalitat, temps futur, concessió i relatives; la correlació de temps i l'imperfet de subjuntiu (-ra/-ss); i les ordes en negatiu (no + subjuntiu) amb pronoms (3.2.2).", "icon": "📜", "color": "#E1BEE7",
    "exercises": [
      {"q": "«Desitge que ___ molta sort en la nova faena.» (tindre, tu)", "o": ["tingues", "tens", "tindràs"], "e": "Verbs de desig (desitjar, esperar, voler) + que + subjuntiu."},
      {"q": "«Tant de bo ___ ací ara mateix!» (ser, tu: desig que no es complix)", "o": ["fores (o fosses)", "eres", "seràs"], "e": "Tant de bo + imperfet de subjuntiu: desig difícil o impossible."},
      {"q": "«Que et ___ bé l'entrevista!» (anar)", "o": ["vaja", "va", "vages"], "e": "Que + subjuntiu expressa desig: que et vaja bé (el subjecte és «l'entrevista»)."},
      {"q": "«Volia que tu ___ amb nosaltres.» (vindre)", "o": ["vingueres (o vinguesses)", "vingues", "vindries"], "e": "Verb principal en passat → imperfet de subjuntiu (correlació de temps)."},
      {"q": "«Dubte que ___ a temps.» (arribar, ells)", "o": ["arriben", "arribaran", "arribaven"], "e": "Dubtar que + subjuntiu."},
      {"q": "«És probable que demà ___.» (ploure)", "o": ["ploga", "plourà", "plou"], "e": "És probable / és possible que + subjuntiu."},
      {"q": "«M'alegra que ___ vingut.» (haver, tu)", "o": ["hages", "has", "hauràs"], "e": "Sentiments i valoracions + que + subjuntiu: m'alegra que hages vingut."},
      {"q": "«És important que els alumnes ___ puntuals.» (ser)", "o": ["siguen", "són", "seran"], "e": "És important / necessari que + subjuntiu."},
      {"q": "«És necessari que vostés ho ___ abans de divendres.» (entregar)", "o": ["entreguen", "entregaran", "entregarien"], "e": "És necessari que + present de subjuntiu."},
      {"q": "«T'ho repetisc perquè no ho ___.» (oblidar, tu: finalitat)", "o": ["oblides", "oblidaràs", "oblidaves"], "e": "Perquè de finalitat + subjuntiu (= per a que no ho oblides)."},
      {"q": "«Hem obert les finestres a fi que ___ l'aire.» (circular)", "o": ["circule", "circula", "circularà"], "e": "A fi que, perquè (finalitat) + subjuntiu."},
      {"q": "«Ho van fer sense que ningú se n'___.» (adonar)", "o": ["adonara (o adonés)", "adona", "adonarà"], "e": "Sense que + subjuntiu; amb el verb principal en passat, imperfet de subjuntiu."},
      {"q": "«Ha vingut sense que ningú l'___.» (convidar)", "o": ["haja convidat", "ha convidat", "havia convidat"], "e": "Sense que + subjuntiu: haja convidat (perfet de subjuntiu)."},
      {"q": "«Quan ___ a Barcelona, crideu-me.» (arribar, vosaltres)", "o": ["arribeu", "arribareu", "arribàveu"], "e": "Quan + acció futura → present de subjuntiu (mai futur): quan arribeu."},
      {"q": "«T'ho explicaré quan ___ temps.» (tindre, jo)", "o": ["tinga", "tindré", "tinc"], "e": "Quan + futur → subjuntiu: quan tinga temps."},
      {"q": "«Tan prompte com ___ els resultats, t'avisaré.» (saber, jo)", "o": ["sàpia", "sabré", "sé"], "e": "Temporals de futur (tan prompte com, quan, així que) + subjuntiu."},
      {"q": "«Abans que ___ fosc, tornarem a casa.» (fer-se)", "o": ["es faça", "es fa", "es farà"], "e": "Abans que (no) + subjuntiu."},
      {"q": "«Per més diners que ___, no serà feliç.» (guanyar, ell)", "o": ["guanye", "guanya", "guanyarà"], "e": "Per més / per molt que + subjuntiu."},
      {"q": "«Encara que me'l ___ regalar, no l'acceptaria.» (voler, ells: hipòtesi)", "o": ["volgueren (o volguessen)", "volen", "voldrien"], "e": "Concessiva hipotètica amb condicional en la principal: imperfet de subjuntiu."},
      {"q": "«Necessitem algú que ___ parlar xinés.» (saber)", "o": ["sàpia", "sap", "sabrà"], "e": "Relativa amb antecedent desconegut o hipotètic → subjuntiu."},
      {"q": "«No hi ha ningú que ho ___ fer millor que ella.» (poder)", "o": ["puga", "pot", "podrà"], "e": "Antecedent negat (ningú, res) → subjuntiu en la relativa."},
      {"q": "«Em va demanar que l'___ amb la mudança.» (ajudar, jo)", "o": ["ajudara (o ajudés)", "ajude", "ajudaré"], "e": "Principal en passat → imperfet de subjuntiu (-ra o -ss)."},
      {"q": "«Li vaig dir que no ___ la porta a ningú.» (obrir, ell)", "o": ["obrira (o obrís)", "obri", "obrirà"], "e": "Correlació: «vaig dir que» + imperfet de subjuntiu."},
      {"q": "«Quan era xicotet, mon pare volia que ___ medicina.» (estudiar, jo)", "o": ["estudiara (o estudiés)", "estudie", "estudiaré"], "e": "Volia que + imperfet de subjuntiu."},
      {"q": "Quina és la forma d'imperfet de subjuntiu de «cantar» per a «nosaltres»?", "o": ["cantàrem (o cantéssem)", "cantàvem", "cantaríem"], "e": "Imperfet de subjuntiu: cantara/cantés, cantares/cantesses, cantara/cantés, cantàrem/cantéssem, cantàreu/cantésseu, cantaren/cantessen."},
      {"q": "«Si ___, vindria a la festa.» (poder, jo)", "o": ["poguera (o pogués)", "podria", "podia"], "e": "Si condicional + imperfet de subjuntiu; mai condicional després de si."},
      {"q": "«Parla com si ho ___ tot.» (saber, ell)", "o": ["sabera (o sabés)", "sap", "sabria"], "e": "Com si + imperfet de subjuntiu."},
      {"q": "«No ___ la porta, que fa fred.» (obrir, tu)", "o": ["obres", "obri", "obris"], "e": "Orde negativa: no + present de subjuntiu (obra, obres, obra...): no obres."},
      {"q": "«No ___, que és perillós!» (fer + ho, tu)", "o": ["ho faces", "ho fas", "fes-ho"], "e": "En negatiu, subjuntiu i pronoms davant del verb: no ho faces."},
      {"q": "«No ___ encara, que no hem acabat.» (vindre, vosaltres)", "o": ["vingueu", "veniu", "vindreu"], "e": "Imperatiu afirmatiu: veniu; negatiu: no vingueu."},
      {"q": "«No ___, que encara és prompte.» (anar-se'n, tu)", "o": ["te'n vages", "te'n vas", "ves-te'n"], "e": "Ves-te'n (afirmatiu) → no te'n vages (negatiu)."},
      {"q": "«No ___ tan alt, per favor.» (parlar, vosté)", "o": ["parle", "parla", "parles"], "e": "Amb vosté s'usa la 3a persona del subjuntiu: no parle."},
      {"q": "«No ___ res a ningú, per favor.» (dir, vosté)", "o": ["diga", "digues", "diu"], "e": "Vosté: no diga; tu: no digues."},
      {"q": "Quina és correcta?", "o": ["No et preocupes.", "No preocupa't.", "No preocupes-te."], "e": "En les ordes negatives els pronoms van davant del verb: no et preocupes, no us preocupeu."},
      {"q": "Quina és l'orde negativa de «Dona-me-la»?", "o": ["No me la dones.", "No dona-me-la.", "No dones-me-la."], "e": "Afirmatiu: dona-me-la (pronoms darrere amb guionet); negatiu: no me la dones."},
      {"q": "Quina és l'orde negativa de «Digues-li-ho»?", "o": ["No li ho digues.", "No digues-li-ho.", "No li ho dius."], "e": "No + pronoms + subjuntiu: no li ho digues."},
      {"q": "Quina és l'orde negativa de «Compreu-lo»?", "o": ["No el compreu.", "No compreu-lo.", "No el compràreu."], "e": "No el compreu: pronom davant i subjuntiu."},
      {"q": "Quina és l'orde negativa de «córrer» per a «vosaltres»?", "o": ["No corregueu.", "No correu.", "No córrer."], "e": "No + subjuntiu: no corregueu. *No córrer és un infinitiu amb valor d'imperatiu, incorrecte."},
      {"q": "Quina frase conté un error?", "o": ["No toca això, que crema.", "No toques això, que crema.", "Toca-ho, si vols: no crema."], "e": "L'imperatiu negatiu no usa la forma afirmativa: no toques (subjuntiu), no *no toca."},
      {"q": "Escriu l'orde negativa de «Fes-ho» (tu).", "a": ["no ho faces"], "e": "No ho faces."},
      {"q": "Escriu l'orde negativa de «Veniu» (vosaltres).", "a": ["no vingueu"], "e": "No vingueu."},
      {"q": "Escriu l'orde negativa de «Ves-te'n» (tu).", "a": ["no te'n vages"], "e": "No te'n vages."},
      {"q": "Escriu el verb: «Quan ___ (vindre, tu), parlarem.»", "a": ["vingues"], "e": "Quan + futur → present de subjuntiu: vingues."},
      {"q": "Escriu l'imperfet de subjuntiu acabat en -ra de «tindre» per a «jo»: «Si ___ diners, me'l compraria.»", "a": ["tinguera"], "e": "Tinguera (o tingués)."}
    ]
  },
  {
    "id": "32e2e064-6112-53e2-84df-9560afcfe207", "type": "b2_mor_ser_estar", "sort_order": 16,
    "title": "Ser i estar", "name": "Valor atributiu i locatiu, estats, canvis de significat, passiva i estar + gerundi",
    "content": "Els verbs ser i estar amb valor atributiu (qualitats, classificació, estats i adjectius que canvien de significat) i locatiu (persones, objectes i esdeveniments), la passiva amb ser i estar + gerundi (3.2.2).", "icon": "⚖️", "color": "#B3E5FC",
    "exercises": [
      {"q": "«La meua cosina ___ arquitecta.» (professió)", "o": ["és", "està", "hi ha"], "e": "Professió, classificació: ser."},
      {"q": "«Esta taula ___ de roure.» (material)", "o": ["és", "està", "té"], "e": "Material: ser de."},
      {"q": "«Estos llibres ___ de la biblioteca: torna'ls.» (possessió)", "o": ["són", "estan", "tenen"], "e": "Possessió o pertinença: ser de."},
      {"q": "«Els meus avis ___ de Morella.» (origen)", "o": ["són", "estan", "tenen"], "e": "Origen: ser de."},
      {"q": "«El meu germà ___ alt i ros.» (descripció física)", "o": ["és", "està", "té"], "e": "Característiques permanents: ser."},
      {"q": "«Hui ___ dimecres.»", "o": ["és", "està", "hi ha"], "e": "Amb els dies i les dates: ser (hui és dimecres)."},
      {"q": "«Ja ___ de nit; encén el llum.»", "o": ["és", "està", "fa"], "e": "És de nit, és de dia: ser."},
      {"q": "«___ les deu i encara no ha arribat.»", "o": ["Són", "Estan", "Fan"], "e": "L'hora: són les deu, és la una."},
      {"q": "«Este cotxe ___ de segona mà.»", "o": ["és", "està", "té"], "e": "Classificació: és de segona mà."},
      {"q": "«___ important que vingues a la reunió.»", "o": ["És", "Està", "Fa"], "e": "Expressions impersonals de valoració: és important, és necessari, és possible."},
      {"q": "Quina frase és incorrecta?", "o": ["El meu oncle està metge.", "El meu oncle és metge.", "El meu oncle està malalt."], "e": "La professió s'expressa amb ser: és metge. Estar expressa estats: està malalt."},
      {"q": "«Hui no he vingut perquè ___ constipada.»", "o": ["estic", "tinc", "hi ha"], "e": "Estats físics transitoris: estar (estic constipada, està cansat)."},
      {"q": "«Després de la marató, ___ molt cansats.»", "o": ["estàvem", "teníem", "fèiem"], "e": "Estar cansat: sentir cansament."},
      {"q": "«La seua germana ___ molt contenta amb el resultat.»", "o": ["està", "té", "fa"], "e": "Estar content: estat d'ànim."},
      {"q": "«___ d'acord amb tu en tot.»", "o": ["Estic", "Tinc", "Faig"], "e": "Estar d'acord."},
      {"q": "«Este estiu ___ de vacances a Menorca.»", "o": ["estarem", "tindrem", "farem"], "e": "Estar de vacances (també estar de viatge, de dol, de pas)."},
      {"q": "«Hui el cel ___ ennuvolat.»", "o": ["està", "fa", "té"], "e": "Estat del cel en un moment: està ennuvolat."},
      {"q": "«___ fred hui: abriga't.»", "o": ["Fa", "Està", "És"], "e": "Per al temps atmosfèric: fer (fa fred, fa calor, fa sol)."},
      {"q": "«Ja ___ llest? Eixim en cinc minuts.» (preparat)", "o": ["estàs", "eres", "tens"], "e": "Estar llest = estar preparat. Ser llest = ser intel·ligent."},
      {"q": "«Eixa xiqueta ___ molt llesta: ho entén tot de seguida.»", "o": ["és", "està", "té"], "e": "Ser llest = ser intel·ligent, espavilat."},
      {"q": "«Este treball tan repetitiu ___ molt cansat.» (que cansa)", "o": ["és", "està", "té"], "e": "Ser cansat = que produïx cansament; estar cansat = sentir-lo."},
      {"q": "«Mon pare ___ callat tot el sopar.» (no va parlar)", "o": ["va estar", "va ser", "va tindre"], "e": "Estar callat: no parlar en un moment determinat. Ser callat: ser de poques paraules."},
      {"q": "«La seua germana ___ molt callada: quasi mai parla.» (manera de ser)", "o": ["és", "està", "té"], "e": "Ser callat: característica del caràcter."},
      {"q": "«Ja ___ bo del refredat?» (recuperat)", "o": ["estàs", "eres", "tens"], "e": "Estar bo = estar sa, recuperat. Ser bo = ser bona persona o de bona qualitat."},
      {"q": "«A les sis del matí ja ___ despert.» (no dormia)", "o": ["estava", "tenia", "feia"], "e": "Estar despert = no dormir."},
      {"q": "Quina frase és correcta?", "o": ["La reunió és a la sala 3.", "La reunió està a la sala 3.", "La reunió hi ha a la sala 3."], "e": "Per a localitzar esdeveniments (reunions, concerts, festes) s'usa ser."},
      {"q": "«La conferència de demà ___ a l'auditori.»", "o": ["serà", "estarà", "farà"], "e": "Esdeveniment → ser: la conferència serà a l'auditori."},
      {"q": "«Les claus ___ damunt de la taula.» (objecte)", "o": ["són (o estan)", "hi ha", "fan"], "e": "Per a localitzar persones i objectes, l'AVL admet ser i estar."},
      {"q": "«Ara no ___ a casa: torna més tard.» (persona)", "o": ["és (o està)", "hi ha", "té"], "e": "Persones: ser o estar locatius (no és a casa / no està a casa)."},
      {"q": "Quina afirmació sobre els usos locatius és correcta?", "o": ["Per a persones i objectes s'usen ser i estar; per a esdeveniments, ser.", "Per a persones només es pot usar estar.", "Per a esdeveniments s'usa estar."], "e": "Ser i estar són tots dos locatius; amb esdeveniments, ser."},
      {"q": "«En este barri ___ tres farmàcies.» (existència)", "o": ["hi ha", "estan", "són"], "e": "Per a l'existència, haver-hi: hi ha tres farmàcies."},
      {"q": "Sobre «El gat és mort» i «El gat està mort», quina afirmació és correcta?", "o": ["Totes dues són correctes.", "Només és correcta la primera.", "Només és correcta la segona."], "e": "Amb l'adjectiu mort, l'AVL admet ser i estar."},
      {"q": "«Este pont ___ construït pels romans.»", "o": ["va ser", "va estar", "es va ser"], "e": "La passiva es forma amb ser + participi: va ser construït."},
      {"q": "«Els guanyadors ___ anunciats demà en la gala.»", "o": ["seran", "estaran", "s'estaran"], "e": "Passiva amb ser: seran anunciats (acció)."},
      {"q": "«La sentència ___ dictada pel jutge ahir.»", "o": ["va ser", "va estar", "es va estar"], "e": "Passiva d'acció: ser + participi."},
      {"q": "Quina frase expressa un estat resultant (i no una acció)?", "o": ["La botiga està tancada des de dilluns.", "La botiga va ser tancada per la policia.", "La policia va tancar la botiga."], "e": "Estar + participi: estat resultant. Ser + participi: passiva d'acció."},
      {"q": "«Quan m'has telefonat, ___ dutxant-me.»", "o": ["estava", "era", "tenia"], "e": "Estar + gerundi: acció en curs."},
      {"q": "«Fa dues hores que ___ esperant l'autobús.»", "o": ["estem", "som", "tenim"], "e": "Estar + gerundi: estem esperant."},
      {"q": "Completa amb ser o estar en present: «La festa ___ a la plaça Major.»", "a": ["és"], "e": "Esdeveniment → ser."},
      {"q": "Completa amb estar en present: «Ara mateix ___ treballant.» (jo)", "a": ["estic"], "e": "Estar + gerundi: estic treballant."},
      {"q": "Completa amb el passat perifràstic de ser: «El museu ___ inaugurat l'any passat.»", "a": ["va ser"], "e": "Passiva: va ser inaugurat."},
      {"q": "Completa amb ser o estar en present: «Este rellotge ___ d'or.»", "a": ["és"], "e": "Material → ser."}
    ]
  },
  {
    "id": "7f783a55-21b5-594a-acd3-22411d9fd744", "type": "b2_mor_perifrasis", "sort_order": 17,
    "title": "Perífrasis verbals", "name": "Incoatives, probabilitat, realització recent, aproximació i obligació",
    "content": "Perífrasis verbals incoatives (posar-se a, començar a, estar a punt de), de probabilitat (deure + infinitiu), de realització recent (acabar de), d'aproximació (vindre a) i d'obligació (haver de, caldre) (3.2.2).", "icon": "🔄", "color": "#DCEDC8",
    "exercises": [
      {"q": "«Quan va sentir la notícia, ___ a plorar.»", "o": ["es va posar", "va posar", "es va posar de"], "e": "Posar-se a + infinitiu: inici sobtat d'una acció."},
      {"q": "«De sobte, el gos es posà ___ lladrar.»", "o": ["a", "de", "per"], "e": "Posar-se a + infinitiu."},
      {"q": "«Quan se'n va anar la llum, ___ a llegir amb una espelma.»", "o": ["ens vam posar", "vam posar", "ens vam posar de"], "e": "Posar-se a: ens vam posar a llegir."},
      {"q": "«Ha ___ a nevar a la muntanya.»", "o": ["començat", "acabat", "deixat"], "e": "Començar a + infinitiu: inici d'una acció."},
      {"q": "«Començarem ___ la lectura de l'acta i després votarem.» (primera acció d'una sèrie)", "o": ["per", "a", "de"], "e": "Començar per: primer pas d'una sèrie. Començar a + infinitiu: inici d'una acció."},
      {"q": "«Corre, que el tren ___ eixir!»", "o": ["està a punt d'", "està prop a", "està en punt d'"], "e": "Estar a punt de + infinitiu: acció imminent."},
      {"q": "«Estàvem ___ de sopar quan va sonar el timbre.»", "o": ["a punt", "en punt", "al punt"], "e": "Estar a punt de."},
      {"q": "«La meua tia està ___ jubilar-se.»", "o": ["a punt de", "a punt a", "prop a"], "e": "Estar a punt de + infinitiu."},
      {"q": "Quina frase expressa l'inici d'una acció?", "o": ["Es va posar a cantar.", "Acaba de cantar.", "Deu cantar molt bé."], "e": "Posar-se a: incoativa. Acabar de: realització recent. Deure: probabilitat."},
      {"q": "«No contesta el telèfon: ___ haver eixit.»", "o": ["deu", "té que", "acaba"], "e": "Deure + infinitiu: probabilitat (deu haver eixit = probablement ha eixit)."},
      {"q": "«___ ser les cinc, perquè ja ix la gent de l'escola.»", "o": ["Deuen", "Tenen que", "Solen"], "e": "Deuen ser les cinc = probablement són les cinc."},
      {"q": "«Fa una calor horrible: ___ fer quaranta graus.»", "o": ["deu", "té que", "està a punt"], "e": "Deure + infinitiu: suposició."},
      {"q": "«Ahir ___ estar molt cansat, perquè se'n va anar prompte.» (probabilitat en el passat)", "o": ["devia", "tenia que", "anava a"], "e": "Deure en imperfet: probabilitat referida al passat (devia estar cansat)."},
      {"q": "«Les claus ___ estar al cotxe: mira-ho.»", "o": ["deuen", "tenen que", "hi ha que"], "e": "Deure + infinitiu concorda amb el subjecte: les claus deuen estar..."},
      {"q": "En «Deu tindre uns cinquanta anys», la perífrasi expressa...", "o": ["probabilitat o suposició", "obligació", "acció acabada fa poc"], "e": "Deure + infinitiu sol expressar probabilitat."},
      {"q": "Quina frase expressa probabilitat?", "o": ["Deuen ser germans: s'assemblen molt.", "Han de ser puntuals sempre.", "Cal ser puntuals."], "e": "Deure + infinitiu: suposició. Haver de i caldre: obligació."},
      {"q": "«___ d'arribar del viatge i ja tornes a eixir?»", "o": ["Acabes", "Comences", "Deus"], "e": "Acabar de + infinitiu: acció que ha passat fa molt poc."},
      {"q": "«La pel·lícula ___ començar: encara pots entrar.»", "o": ["acaba de", "acaba", "està acabant de"], "e": "Acaba de començar = ha començat fa un moment."},
      {"q": "Quina és la manera correcta d'expressar una acció feta fa un moment?", "o": ["Acabe de dinar.", "Acabe dinar.", "Acabe a dinar."], "e": "Acabar de + infinitiu."},
      {"q": "«Quan vaig arribar a l'estació, el tren ___ eixir.»", "o": ["acabava d'", "acabe d'", "acabaria d'"], "e": "En passat: acabava de + infinitiu."},
      {"q": "«Un sopar en este restaurant ___ costar uns trenta euros.»", "o": ["ve a", "acaba de", "té que"], "e": "Vindre a + infinitiu: aproximació (ve a costar = costa aproximadament)."},
      {"q": "«El que diu ___ ser el mateix que vam dir nosaltres.»", "o": ["ve a", "té que", "acaba a"], "e": "Vindre a + infinitiu: equivalència aproximada."},
      {"q": "«Les dos propostes ___ dir el mateix.»", "o": ["venen a", "acaben a", "tenen que"], "e": "Venen a dir = diuen més o menys."},
      {"q": "En «La reforma vindrà a costar uns deu mil euros», la perífrasi expressa...", "o": ["aproximació", "obligació", "inici d'una acció"], "e": "Vindre a + infinitiu: aproximació."},
      {"q": "«Demà ___ alçar-nos a les sis.»", "o": ["hem d'", "tenim que", "hi ha que"], "e": "Obligació personal: haver de + infinitiu. *Tindre que és un castellanisme."},
      {"q": "Quina frase és correcta?", "o": ["Haurem d'esperar una hora.", "Tindrem que esperar una hora.", "Haurem que esperar una hora."], "e": "Haver de + infinitiu: haurem d'esperar."},
      {"q": "«Per a entrar a la piscina ___ portar casquet.»", "o": ["cal", "s'ha que", "hi ha que"], "e": "Obligació impersonal: cal + infinitiu (o s'ha de). *Hi ha que és un castellanisme."},
      {"q": "Com es corregix «Hi ha que reciclar més»?", "o": ["Cal reciclar més.", "Hi ha de reciclar més.", "Té que reciclar-se més."], "e": "Cal reciclar (o s'ha de reciclar)."},
      {"q": "«No ___ fumar en l'interior de l'edifici.» (prohibició)", "o": ["s'ha de", "cal de", "hi ha que"], "e": "No s'ha de: prohibició impersonal."},
      {"q": "«No ___ que ens ho expliques: ja ho sabem.» (no és necessari)", "o": ["cal", "has", "tens"], "e": "No cal que + subjuntiu: no és necessari."},
      {"q": "Quina frase expressa obligació i no probabilitat?", "o": ["Has d'entregar el treball divendres.", "Deu ser divendres.", "Deuen haver arribat."], "e": "Haver de: obligació. Deure + infinitiu: ací, probabilitat."},
      {"q": "Quina construcció és un calc del castellà?", "o": ["tindre que + infinitiu", "haver de + infinitiu", "caldre + infinitiu"], "e": "Cal evitar «tindre que»: haver de, caldre."},
      {"q": "En un registre formal, quina és la manera recomanada d'anunciar un fet futur?", "o": ["Demà el president inaugurarà l'exposició.", "Demà el president va a inaugurar l'exposició.", "Demà el president té que inaugurar l'exposició."], "e": "Per al futur, el futur simple. Cal evitar «anar a + infinitiu» amb valor de futur."},
      {"q": "«Els dissabtes ___ dinar a casa dels avis.» (costum)", "o": ["solem", "venim", "acabem"], "e": "Soler + infinitiu: acció habitual."},
      {"q": "«Ha ___ a fer el mateix error.» (repetició)", "o": ["tornat", "deixat", "acabat"], "e": "Tornar a + infinitiu: repetició."},
      {"q": "Corregix la frase: «Tens que vindre.»", "a": ["has de vindre", "has de venir"], "e": "Haver de + infinitiu: has de vindre."},
      {"q": "Escriu la forma de probabilitat: «Fa una hora que ha eixit: ja ___ haver arribat.» (deure, ell)", "a": ["deu"], "e": "Deu haver arribat."},
      {"q": "Escriu el verb que falta: «___ de rebre la teua carta.» (realització recent, jo, present)", "a": ["acabe"], "e": "Acabe de rebre."},
      {"q": "Escriu la preposició: «Es va posar ___ riure.»", "a": ["a"], "e": "Posar-se a."},
      {"q": "Escriu el verb d'aproximació: «El viatge ___ a costar uns cent euros.» (vindre, present)", "a": ["ve"], "e": "Ve a costar."}
    ]
  },
  {
    "id": "df42221a-a0fa-56c9-988d-8833d56583b3", "type": "b2_mor_infinitiu", "sort_order": 18,
    "title": "Formes no personals del verb: l'infinitiu", "name": "Infinitiu amb valor d'imperatiu, infinitiu substantivat, gerundi i participi",
    "content": "Les formes no personals del verb: usos de l'infinitiu (construccions incorrectes amb valor d'imperatiu com *No passar, presència o absència d'article davant d'infinitiu substantivat, infinitius tindre/tenir, vindre/venir, vore/veure), el gerundi i el participi (3.2.2).", "icon": "🪧", "color": "#FFCCBC",
    "exercises": [
      {"q": "Quin rètol és correcte?", "o": ["No passeu", "No passar", "No passant"], "e": "L'infinitiu no pot fer d'imperatiu: no passeu (o no s'hi pot passar, prohibit passar)."},
      {"q": "Quin rètol és correcte?", "o": ["Prohibit fumar", "No fumar", "No fumant"], "e": "*No fumar és incorrecte; correcte: prohibit fumar, no fumeu, no es pot fumar."},
      {"q": "Quina indicació és correcta en una porta?", "o": ["Tanqueu la porta, per favor.", "Tancar la porta, per favor.", "Tancant la porta, per favor."], "e": "Per a donar ordes, imperatiu (tanqueu) i no infinitiu."},
      {"q": "Quina és la forma correcta en un cartell d'una piscina?", "o": ["No us capbusseu.", "No capbussar-se.", "No capbussant-se."], "e": "No + subjuntiu: no us capbusseu."},
      {"q": "Com s'ha de corregir el rètol «No trepitjar la gespa»?", "o": ["No trepitgeu la gespa.", "No trepitjant la gespa.", "No trepitjar-se la gespa."], "e": "No + subjuntiu: no trepitgeu (j → g davant de e)."},
      {"q": "Quina d'estes formes NO és adequada en un rètol?", "o": ["No aparcar", "No aparqueu", "Prohibit aparcar", "No s'hi pot aparcar"], "e": "*No aparcar: infinitiu amb valor d'imperatiu, incorrecte."},
      {"q": "Un professor diu a la classe: «___ el llibre per la pàgina 20.»", "o": ["Obriu", "Obrir", "Obrint"], "e": "Orde: imperatiu (obriu)."},
      {"q": "En un cartell de teatre: «___ el mòbil durant la funció.»", "o": ["Apagueu", "Apagar", "Apagant"], "e": "Imperatiu: apagueu el mòbil."},
      {"q": "Quina és una alternativa impersonal correcta a *«No passar»?", "o": ["No s'hi pot passar", "No passar-hi", "No passant"], "e": "Construccions correctes: no s'hi pot passar, prohibit passar, no passeu."},
      {"q": "«___ perjudica greument la salut.»", "o": ["Fumar", "El fumar", "Al fumar"], "e": "Quan l'infinitiu fa de subjecte, normalment va sense article: fumar perjudica la salut."},
      {"q": "«M'agrada ___ abans de dormir.»", "o": ["llegir", "el llegir", "de llegir"], "e": "Infinitiu subjecte de agradar, sense article: m'agrada llegir."},
      {"q": "Quina frase és més adequada?", "o": ["Caminar cada dia és saludable.", "El caminar cada dia és saludable.", "Al caminar cada dia és saludable."], "e": "Infinitiu amb complements com a subjecte: sense article."},
      {"q": "«___ seu riure contagiós omplia la sala.»", "o": ["El", "Al", "Lo"], "e": "Quan l'infinitiu porta un possessiu o un adjectiu funciona com un nom i porta article: el seu riure."},
      {"q": "Quan l'infinitiu porta un possessiu o un adjectiu («el seu caminar elegant»)...", "o": ["porta article, com un nom", "no pot portar article", "porta l'article «lo»"], "e": "Infinitiu substantivat amb determinants o adjectius: amb article."},
      {"q": "Quin d'estos infinitius s'ha lexicalitzat com a nom i té plural?", "o": ["el poder (els poders)", "el llegir (els llegirs)", "el córrer (els córrers)"], "e": "Alguns infinitius són ja noms: el poder, el deure, el sopar, l'ésser."},
      {"q": "«___ arribar a casa, em vaig adonar que no tenia les claus.»", "o": ["En", "Al", "A l'"], "e": "Temporal de simultaneïtat: en + infinitiu. *Al + infinitiu és un castellanisme."},
      {"q": "Quina és correcta?", "o": ["En eixir de classe, vam anar al bar.", "A l'eixir de classe, vam anar al bar.", "Al eixir de classe, vam anar al bar."], "e": "En + infinitiu: en eixir, en arribar."},
      {"q": "«Abans ___ eixir, apaga el llum.»", "o": ["d'", "del", "a"], "e": "Abans de + infinitiu (sense article)."},
      {"q": "«Has de ___ hui mateix.» (dir + li + ho)", "o": ["dir-li-ho", "dir-l'ho", "dir-lo-li"], "e": "Darrere de l'infinitiu, els pronoms van amb guionet: dir-li-ho."},
      {"q": "Quina frase usa correctament el gerundi?", "o": ["Va entrar cantant.", "Va caure, trencant-se el braç.", "Es va examinar dilluns, aprovant dimecres."], "e": "El gerundi expressa simultaneïtat o manera; el gerundi de posterioritat és incorrecte."},
      {"q": "Com es corregix «L'avió es va estavellar, morint tots els passatgers»?", "o": ["L'avió es va estavellar i van morir tots els passatgers.", "L'avió es va estavellar, havent mort tots els passatgers.", "L'avió es va estavellar, morint-se tots els passatgers."], "e": "Acció posterior → oració coordinada, no gerundi."},
      {"q": "Quin és el gerundi de «dir»?", "o": ["dient", "diguent", "dint"], "e": "Dir → dient."},
      {"q": "Quin és el gerundi de «riure»?", "o": ["rient", "riguent", "riuent"], "e": "Riure → rient (com creure → creient)."},
      {"q": "Quin és el gerundi de «viure»?", "o": ["vivint", "visquent", "viuent"], "e": "Viure → vivint (com escriure → escrivint)."},
      {"q": "Quin és el gerundi de «creure»?", "o": ["creient", "creguent", "creent"], "e": "Creure → creient."},
      {"q": "«Les cartes, ja les he ___.» (escriure, forma concordada)", "o": ["escrites", "escrivides", "escriutes"], "e": "Participi d'escriure: escrit, escrita, escrits, escrites."},
      {"q": "«La porta, l'he ___ jo.» (obrir, forma concordada)", "o": ["oberta", "obrida", "oberts"], "e": "Obrir → obert, oberta."},
      {"q": "«Les maletes, les ha ___ ell sol.» (fer, forma concordada)", "o": ["fetes", "feites", "fets"], "e": "Fer → fet, feta, fets, fetes."},
      {"q": "«Les mesures ___ pel govern no han funcionat.» (prendre)", "o": ["preses", "prengudes", "presses"], "e": "Prendre → pres, presa, presos, preses."},
      {"q": "En «Les fotos, les he vistes», per què el participi és femení plural?", "o": ["Concorda amb el pronom «les», complement directe.", "Concorda amb el subjecte «jo».", "Perquè el verb haver sempre concorda."], "e": "El participi pot concordar amb els pronoms de CD de 3a persona (la, les): les he vistes."},
      {"q": "Quina parella d'infinitius és correcta?", "o": ["tindre / tenir", "tindre / tener", "tinder / tenir"], "e": "L'AVL admet tindre i tenir."},
      {"q": "Quin infinitiu és correcte?", "o": ["vindre (o venir)", "vinder", "vindrer"], "e": "Vindre i venir són formes correctes."},
      {"q": "Quina forma d'infinitiu és correcta?", "o": ["vore (o veure)", "voure", "vorer"], "e": "Vore i veure: totes dues correctes."},
      {"q": "Quin infinitiu és correcte?", "o": ["mantindre (o mantenir)", "mantener", "mantindrer"], "e": "Els derivats segueixen el model: mantindre/mantenir, obtindre/obtenir."},
      {"q": "Quin infinitiu és correcte?", "o": ["entretindre (o entretenir)", "entretener", "entretinder"], "e": "Entretindre / entretenir."},
      {"q": "Quin infinitiu és correcte?", "o": ["traure (o treure)", "trauer", "traer"], "e": "Traure / treure."},
      {"q": "Com s'escriu l'infinitiu?", "o": ["córrer", "correr", "corrér"], "e": "Córrer: plana acabada en -r, porta accent."},
      {"q": "Corregix el rètol «No fumar» amb un imperatiu negatiu per a vosaltres.", "a": ["no fumeu"], "e": "No fumeu."},
      {"q": "Escriu el gerundi de «fer».", "a": ["fent"], "e": "Fent."},
      {"q": "Escriu la preposició: «___ arribar, ens vam abraçar.» (temporal)", "a": ["en"], "e": "En arribar."},
      {"q": "Escriu el participi femení singular de «obrir».", "a": ["oberta"], "e": "Oberta."},
      {"q": "Escriu l'altra forma correcta de l'infinitiu «vindre».", "a": ["venir"], "e": "Venir."}
    ]
  }
]$data$::jsonb) AS t(
  id uuid, type text, sort_order smallint, title text, name text,
  content text, icon text, color text, exercises jsonb
);

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
SELECT id, name, type, 'morfosintaxi', content, 'B2', 15, sort_order,
       jsonb_build_object('icon', icon, 'color', color, 'section_name', title)
FROM practice_catalog
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  difficulty = EXCLUDED.difficulty,
  xp_earned = EXCLUDED.xp_earned,
  sort_order = EXCLUDED.sort_order,
  -- Conserva la lliçó fixa («Aprendre lliçó»), si una migració posterior n'hi afig.
  metadata = EXCLUDED.metadata || jsonb_strip_nulls(jsonb_build_object('lesson', resources.metadata -> 'lesson'));

DELETE FROM public.practice_exercises e
USING practice_catalog c
WHERE e.resource_id = c.id AND e.level = 'B2';

INSERT INTO public.practice_exercises (resource_id, level, position, kind, prompt, options, answers, explanation)
SELECT c.id, 'B2', x.ord,
       CASE WHEN x.e ? 'a' THEN 'fill' ELSE 'choice' END,
       x.e->>'q',
       CASE WHEN x.e ? 'o' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'o')) END,
       CASE WHEN x.e ? 'a' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'a')) ELSE ARRAY[x.e->'o'->>0] END,
       x.e->>'e'
FROM practice_catalog c
CROSS JOIN LATERAL jsonb_array_elements(c.exercises) WITH ORDINALITY AS x(e, ord);

DROP TABLE practice_catalog;

-- ============================================================
-- Origen: 20261013130000_practice_lexic_b2.sql
-- ============================================================
-- Lèxic i semàntica del B2 (Quadern B2 de la JQCV, 3.2.3). Un contingut de la categoria
-- lexic_semantica per a cada apartat del temari: el vocabulari general (àmbits docent i
-- professional; documents formals; menjar, dieta, restauració, salut i esport; tecnologia i
-- ciències de la naturalesa; contes, rondalles i cançons tradicionals; llengües i gentilicis;
-- descripció espacial, física i de personalitat), la formació del lèxic (derivació i composició),
-- les locucions i frases fetes, la precisió lèxica (polisèmia i homonímia, barbarismes;
-- comparació, metàfora i metonímia) i les relacions semàntiques (sinonímia i antonímia, relacions
-- lexicosemàntiques textuals). Són recursos del nivell B2 amb exercicis B2. Tornar a aplicar el
-- fitxer no duplica res.

CREATE TEMP TABLE practice_catalog AS
SELECT * FROM jsonb_to_recordset($data$[
  {
    "id": "bd6f8d16-ac23-5b2b-a82d-d0502f722302", "type": "b2_lex_docent_professional", "sort_order": 1,
    "title": "Àmbits docent i professional", "name": "Centres i etapes educatives, avaluació i titulacions; contractes, nòmina, jornada i carrera professional",
    "content": "El lèxic del sistema educatiu (etapes, centres, matrícula, avaluació, titulacions i beques) i del món laboral (contractes, nòmina, plantilla, jornada, oposicions, currículum, entrevista, excedència, jubilació i treball autònom) (3.2.3).", "icon": "🎓", "color": "#C5CAE9",
    "exercises": [
      {"q": "L'etapa educativa obligatòria que va dels 12 als 16 anys és...", "o": ["l'educació secundària obligatòria (ESO)", "l'educació primària", "el batxillerat"], "e": "L'ESO (12-16 anys) ve després de la primària (6-12). El batxillerat i la formació professional són postobligatoris."},
      {"q": "L'etapa per als xiquets de 0 a 6 anys, que no és obligatòria, és...", "o": ["l'educació infantil", "l'educació primària", "l'educació especial"], "e": "L'educació infantil té dos cicles: de 0 a 3 i de 3 a 6 anys."},
      {"q": "Un centre de titularitat privada però finançat amb diners públics és un centre...", "o": ["concertat", "públic", "privat"], "e": "Concertat: privat amb concert econòmic amb l'Administració. Públic: de titularitat pública; privat: sense finançament públic."},
      {"q": "Els estudis pràctics orientats a una professió, organitzats en cicles formatius, són...", "o": ["la formació professional (FP)", "el doctorat", "el batxillerat"], "e": "La formació professional (cicles de grau bàsic, mitjà i superior) prepara per a un ofici."},
      {"q": "Els estudis universitaris que, en general, duren quatre anys són...", "o": ["el grau", "el màster", "el doctorat"], "e": "El grau és el primer títol universitari; després poden vindre el màster i el doctorat (tesi doctoral)."},
      {"q": "Inscriure's oficialment en un curs, pagant les taxes, és...", "o": ["matricular-se", "convalidar", "examinar-se"], "e": "Matricular-se: fer la matrícula. El termini de matrícula és el període per a fer-la."},
      {"q": "Fer que unes assignatures aprovades en uns estudis tinguen validesa en uns altres és...", "o": ["convalidar-les", "suspendre-les", "recuperar-les"], "e": "Convalidar: reconéixer oficialment uns estudis ja fets. Una convalidació."},
      {"q": "Quin és un sinònim d'«assignatura»?", "o": ["matèria", "lliçó", "carrera"], "e": "Assignatura o matèria: cada disciplina d'un pla d'estudis. Una lliçó és una part del temari."},
      {"q": "Com es diu en passat que no has aprovat l'examen?", "o": ["He suspés l'examen de química.", "He suspendit l'examen de química.", "He suspengut l'examen de química."], "e": "El participi de «suspendre» és «suspés, suspesa» (com «encés», «defés»)."},
      {"q": "En el sistema de qualificacions, un 9 és un...", "o": ["excel·lent", "notable", "suficient"], "e": "Insuficient (0-4), suficient (5), bé (6), notable (7-8) i excel·lent (9-10)."},
      {"q": "L'avaluació que es fa al llarg del curs, tenint en compte el treball diari, és...", "o": ["l'avaluació contínua", "l'avaluació final", "la prova d'accés"], "e": "Avaluació contínua: valora el procés. L'avaluació final es fa al final d'un període."},
      {"q": "La prova que es fa per a aprovar una matèria suspesa és...", "o": ["la recuperació", "la convalidació", "la preinscripció"], "e": "La recuperació (recuperar una matèria). La preinscripció és la sol·licitud de plaça prèvia a la matrícula."},
      {"q": "El document que recull totes les qualificacions d'un estudiant al llarg dels estudis és...", "o": ["l'expedient acadèmic", "el currículum vitae", "el full de matrícula"], "e": "L'expedient acadèmic. La nota mitjana de l'expedient es té en compte per a les beques."},
      {"q": "El document oficial que acredita que has acabat uns estudis és...", "o": ["el títol", "el butlletí de notes", "el carnet d'estudiant"], "e": "El títol (titulació). Un graduat, un llicenciat o un tècnic superior tenen un títol."},
      {"q": "Una ajuda econòmica que rep un estudiant per a pagar els estudis és...", "o": ["una beca", "una nòmina", "una quota"], "e": "Una beca (becari, becària). Es demana amb una sol·licitud dins del termini."},
      {"q": "El professor responsable d'un grup, que en fa el seguiment i es reunix amb les famílies, és...", "o": ["el tutor (o la tutora)", "el conserge", "l'inspector"], "e": "El tutor fa les tutories. L'inspector d'educació supervisa els centres."},
      {"q": "La reunió de tot el professorat d'un centre educatiu és...", "o": ["el claustre", "el consell escolar", "la junta de veïns"], "e": "El claustre (de professors). En el consell escolar també hi ha famílies, alumnat i personal no docent."},
      {"q": "Quina paraula NO pertany a l'àmbit educatiu?", "o": ["la cotització", "el claustre", "la tutoria", "l'avaluació"], "e": "La cotització (a la Seguretat Social) és del món laboral; les altres són del món docent."},
      {"q": "El període en què un estudiant treballa en una empresa per a aprendre l'ofici són...", "o": ["les pràctiques", "les oposicions", "les vacances"], "e": "Fer pràctiques (en empresa). En l'FP es fan pràctiques obligatòries."},
      {"q": "Com s'anomena la superfície on el professor escriu amb guix o retolador?", "o": ["la pissarra", "la pizarra", "la pisarra"], "e": "La pissarra, amb ss. «Pizarra» és castellà."},
      {"q": "Un contracte que no té data de finalització és...", "o": ["indefinit", "temporal", "de pràctiques"], "e": "Indefinit: sense data de fi. Temporal: per a un període determinat."},
      {"q": "El document que rep el treballador cada mes amb el detall del sou i dels descomptes és...", "o": ["la nòmina", "la factura", "el pressupost"], "e": "La nòmina. La factura la fa qui ven un producte o servici."},
      {"q": "La quantitat que cobra realment el treballador, una vegada descomptats els impostos i les cotitzacions, és el sou...", "o": ["net", "brut", "base"], "e": "Sou net: el que es cobra. Sou brut: abans de les retencions."},
      {"q": "El conjunt de treballadors d'una empresa és...", "o": ["la plantilla", "la nòmina", "la patronal"], "e": "La plantilla. La patronal és l'organització dels empresaris."},
      {"q": "Treballar de matí i de vesprada, amb una pausa per a dinar, és fer jornada...", "o": ["partida", "intensiva", "reduïda"], "e": "Jornada partida. La intensiva es fa seguida (per exemple, de 8 a 15 h); la reduïda té menys hores."},
      {"q": "Les proves selectives per a obtindre una plaça de funcionari són...", "o": ["les oposicions", "les pràctiques", "les entrevistes de treball"], "e": "Les oposicions (opositar, opositor). Qui les aprova obté una plaça en propietat."},
      {"q": "Una persona que ocupa temporalment una plaça pública de la qual no és titular és...", "o": ["interina", "jubilada", "autònoma"], "e": "Un funcionari interí ocupa la plaça de manera provisional."},
      {"q": "El document on resumixes la teua formació i la teua experiència per a buscar feina és...", "o": ["el currículum (vitae)", "la carta de recomanació", "l'expedient de regulació"], "e": "El currículum vitae (CV). S'acompanya sovint d'una carta de presentació."},
      {"q": "La conversa en què l'empresa coneix el candidat per a un lloc de treball és...", "o": ["l'entrevista de treball", "la reunió de claustre", "la vaga"], "e": "L'entrevista (de treball): l'entrevistador fa preguntes a l'aspirant."},
      {"q": "Deixar temporalment la feina, sense sou, però amb dret a tornar-hi, és demanar...", "o": ["una excedència", "la jubilació", "l'acomiadament"], "e": "Una excedència (per cura de fills, per estudis...). El treballador està en excedència."},
      {"q": "Deixar de treballar definitivament per raó d'edat és...", "o": ["jubilar-se", "acomiadar-se", "donar-se d'alta"], "e": "Jubilar-se: la jubilació. La persona jubilada cobra una pensió."},
      {"q": "Una persona que treballa pel seu compte, sense ser assalariada, és...", "o": ["autònoma", "interina", "becària"], "e": "Treballador autònom: paga la seua quota i no depén d'un empresari."},
      {"q": "Quina és la forma genuïna per a dir que l'empresa fa fora un treballador?", "o": ["acomiadar", "despedir", "desacomodar"], "e": "Acomiadar: l'acomiadament. «Despedir» és un castellanisme."},
      {"q": "Quina expressió és correcta?", "o": ["cobrar la prestació d'atur", "cobrar el paro", "cobrar la parada"], "e": "La situació de qui no té feina és l'atur (estar a l'atur, persona aturada). «Paro» és castellà."},
      {"q": "Deixar de treballar col·lectivament com a protesta és fer...", "o": ["vaga", "pont", "festa"], "e": "Fer vaga (vaguista). Els sindicats convoquen les vagues."},
      {"q": "Quan un treballador no pot treballar perquè està malalt, està de...", "o": ["baixa", "vacances", "excedència"], "e": "Estar de baixa (per malaltia). Quan es recupera li donen l'alta."},
      {"q": "La llista de persones aspirants a cobrir llocs de treball quan es necessiten és...", "o": ["la borsa de treball", "la plantilla", "la nòmina"], "e": "La borsa de treball (o d'ocupació)."},
      {"q": "Passar a ocupar un càrrec superior dins de l'empresa és...", "o": ["un ascens", "un trasllat", "una baixa"], "e": "Un ascens (ascendir, promocionar). Un trasllat és un canvi de lloc de treball."},
      {"q": "Treballar des de casa amb l'ordinador, sense anar a l'oficina, és...", "o": ["el teletreball", "la jornada partida", "l'excedència"], "e": "El teletreball (teletreballar)."},
      {"q": "Quina paraula NO pertany a l'àmbit laboral?", "o": ["la matrícula", "la nòmina", "el contracte", "la plantilla"], "e": "La matrícula és de l'àmbit educatiu."},
      {"q": "Escriu el nom del document mensual que detalla el sou d'un treballador.", "a": ["nòmina", "la nòmina"], "e": "La nòmina."},
      {"q": "Escriu el verb genuí per a 'despedir' (un treballador).", "a": ["acomiadar"], "e": "Acomiadar (l'acomiadament)."},
      {"q": "Escriu el nom de l'ajuda econòmica que rep un estudiant.", "a": ["beca", "una beca", "la beca"], "e": "Una beca."},
      {"q": "Escriu el nom de les proves per a obtindre una plaça de funcionari.", "a": ["oposicions", "les oposicions"], "e": "Les oposicions."},
      {"q": "Escriu el participi masculí de «suspendre» (He ___ l'examen).", "a": ["suspés"], "e": "Suspés, suspesa."}
    ]
  },
  {
    "id": "d33fc15e-939b-5d60-bd47-c795639495d3", "type": "b2_lex_documents_formals", "sort_order": 2,
    "title": "Documents formals", "name": "Cartes, correus electrònics, instàncies i documents administratius",
    "content": "Les fórmules de salutació i de comiat, les parts d'una instància (EXPOSE / SOL·LICITE) i el lèxic bàsic dels documents administratius i dels correus formals: sol·licitant, annex, adjunt, assumpte, termini, registre, al·legació, certificat... (3.2.3).", "icon": "✉️", "color": "#FFE0B2",
    "exercises": [
      {"q": "Quina salutació és adequada per a començar una carta formal adreçada a un home?", "o": ["Benvolgut senyor:", "Hola, tio:", "Estimat colega,"], "e": "Benvolgut senyor / Benvolguda senyora: fórmula formal. «Hola» i «estimat colega» són de registre familiar."},
      {"q": "Com s'escriu la salutació d'una carta formal adreçada a una dona?", "o": ["Benvolguda senyora:", "Ben volguda senyora:", "Benvolgüda senyora:"], "e": "«Benvolgut, benvolguda» s'escriu junt i sense dièresi."},
      {"q": "Quin comiat és adequat per a una carta formal?", "o": ["Atentament,", "Atentamente,", "Molts records,"], "e": "Atentament (o Cordialment, Salutacions cordials). «Atentamente» és castellà; «Molts records» és informal."},
      {"q": "Quin comiat és correcte?", "o": ["Cordialment,", "Cordialmente,", "Un cordial saludo,"], "e": "Cordialment o Salutacions cordials. Les altres formes són castellanes."},
      {"q": "Completa: «___ de la vostra resposta, us saludem atentament.»", "o": ["A l'espera", "Al esperar", "Esperant-se"], "e": "A l'espera de (o En espera de) la vostra resposta."},
      {"q": "Completa: «Us ___ per endavant l'atenció que dispenseu a esta sol·licitud.»", "o": ["agraïsc", "agradesc", "agradec"], "e": "Agrair: jo agraïsc (o agraisc). «Agradec» és un calc de «agradezco»."},
      {"q": "Quina expressió és la genuïna?", "o": ["al més prompte possible", "a la major brevetat", "lo antes possible"], "e": "Al més prompte possible, com més prompte millor. «A la major brevetat» és un calc del castellà."},
      {"q": "En una instància, l'apartat on la persona explica els fets i els motius de la petició es titula...", "o": ["EXPOSE", "SOL·LICITE", "SIGNATURA"], "e": "EXPOSE (o EXPOSA): els fets. Després, SOL·LICITE: la petició concreta."},
      {"q": "En una instància, l'apartat on es concreta la petició es titula...", "o": ["SOL·LICITE", "EXPOSE", "ANNEX"], "e": "SOL·LICITE (o SOL·LICITA): què es demana exactament."},
      {"q": "Com s'escriu el nom de l'escrit amb què es demana una cosa a l'Administració?", "o": ["sol·licitud", "solicitud", "sol·licitut"], "e": "Sol·licitud, amb ela geminada i acabada en -d (sol·licitar)."},
      {"q": "La persona que presenta una sol·licitud és...", "o": ["el sol·licitant", "el destinatari", "el funcionari"], "e": "El sol·licitant (o la persona interessada)."},
      {"q": "En un procediment administratiu, la persona afectada pel tràmit s'anomena...", "o": ["la persona interessada", "el remitent", "el ponent"], "e": "La persona interessada (l'interessat, la interessada)."},
      {"q": "La persona que envia una carta és...", "o": ["el remitent", "el destinatari", "el carter"], "e": "El remitent l'envia; el destinatari la rep."},
      {"q": "Un document que s'afig al final d'un altre per a completar-lo és...", "o": ["un annex", "un assumpte", "un encapçalament"], "e": "Un annex (els annexos). «Vegeu l'annex I.»"},
      {"q": "En un correu electrònic, el fitxer que s'envia juntament amb el missatge és...", "o": ["un fitxer adjunt", "l'assumpte", "el destinatari"], "e": "Un fitxer (o arxiu) adjunt. «Us adjunte el certificat.»"},
      {"q": "La línia d'un correu electrònic que resumix el tema en poques paraules és...", "o": ["l'assumpte", "la signatura", "la salutació"], "e": "L'assumpte. Ha de ser breu i clar."},
      {"q": "Com s'escriu el tema d'un correu electrònic?", "o": ["assumpte", "asumpte", "assumte"], "e": "Assumpte, amb ss i amb p."},
      {"q": "El període de temps fixat per a fer un tràmit és...", "o": ["el termini", "el plaç", "el plaço"], "e": "El termini (de presentació, de matrícula...). «Plaç» és un castellanisme."},
      {"q": "El servici on queda constància oficial, amb data i número, de l'entrada d'un document en una administració és...", "o": ["el registre d'entrada", "el padró municipal", "l'arxiu històric"], "e": "El registre d'entrada: el document rep un número i una data."},
      {"q": "Un imprés formal per a fer una petició a l'Administració és...", "o": ["una instància", "una factura", "un rebut"], "e": "Una instància (o sol·licitud). Té dades personals, EXPOSE i SOL·LICITE."},
      {"q": "Com s'anomena un full amb espais en blanc per a emplenar?", "o": ["un imprés", "un impreso", "una impressa"], "e": "Un imprés (impresos): un full imprés per a emplenar."},
      {"q": "Un escrit en què l'interessat presenta arguments per a defendre els seus drets dins d'un procediment és...", "o": ["una al·legació", "un certificat", "un annex"], "e": "Una al·legació (al·legar). Es presenten dins d'un termini."},
      {"q": "Com s'escriu l'escrit de defensa que presenta l'interessat en un procediment?", "o": ["al·legació", "alegació", "al·legasió"], "e": "Al·legació, amb ela geminada (al·legar)."},
      {"q": "El document en què una autoritat fa constar un fet (l'empadronament, unes notes...) és...", "o": ["un certificat", "una al·legació", "una instància"], "e": "Un certificat (certificar). Ex.: certificat d'empadronament."},
      {"q": "El document en què una persona manifesta, sota la seua responsabilitat, que complix els requisits exigits és...", "o": ["una declaració responsable", "un certificat mèdic", "una fe d'errades"], "e": "La declaració responsable substituïx, de vegades, la presentació de documents."},
      {"q": "El nom i la rúbrica que la persona posa al final d'un document és...", "o": ["la signatura", "l'encapçalament", "l'assumpte"], "e": "La signatura (signar). També hi ha la signatura electrònica."},
      {"q": "La part superior d'una carta, amb les dades del remitent, és...", "o": ["l'encapçalament", "la signatura", "el peu de pàgina"], "e": "L'encapçalament (encapçalar)."},
      {"q": "Un document que prova que s'ha fet un pagament o un tràmit és...", "o": ["un justificant", "una al·legació", "un annex"], "e": "Un justificant (de pagament, d'assistència...)."},
      {"q": "Fer seguir a un expedient tots els passos necessaris fins a resoldre'l és...", "o": ["tramitar-lo", "trametre'l", "tramar-lo"], "e": "Tramitar: fer el tràmit. Trametre és enviar."},
      {"q": "«Us ___ adjunta la documentació requerida.» Quin verb vol dir 'enviar'?", "o": ["trametem", "tramitem", "tramem"], "e": "Trametre: enviar. «Us trametem la documentació.»"},
      {"q": "Quina data està ben escrita en un document formal?", "o": ["València, 3 de febrer de 2026", "València, a 3 de Febrer del 2026", "València, 3 Febrer, 2026"], "e": "Lloc, dia, «de», mes en minúscula, «de» i any."},
      {"q": "Quina és l'abreviatura correcta de «senyora»?", "o": ["Sra.", "Sñra.", "Snra."], "e": "Sr. (senyor), Sra. (senyora), Srs. (senyors)."},
      {"q": "Quina és l'abreviatura correcta de «número»?", "o": ["núm.", "nro.", "nmr."], "e": "Núm. (o n.): número."},
      {"q": "El document que recull el que s'ha tractat i acordat en una reunió és...", "o": ["l'acta", "l'ordre del dia", "la convocatòria"], "e": "L'acta. L'ordre del dia és la llista de temes que es tractaran."},
      {"q": "La llista de temes que es tractaran en una reunió és...", "o": ["l'ordre del dia", "l'acta", "el pressupost"], "e": "L'ordre del dia (masculí: «l'ordre del dia»)."},
      {"q": "Un text publicat per a corregir els errors d'un document anterior és...", "o": ["una fe d'errades", "una al·legació", "una declaració responsable"], "e": "Una fe d'errades: corregix errades d'un text publicat."},
      {"q": "Un escrit amb què l'interessat impugna una resolució de l'Administració és...", "o": ["un recurs", "un rebut", "un saluda"], "e": "Interposar (o presentar) un recurs contra una resolució."},
      {"q": "Tornar a enviar a una altra persona un correu que hem rebut és...", "o": ["reenviar-lo", "respondre'l", "adjuntar-lo"], "e": "Reenviar. Respondre és contestar al remitent."},
      {"q": "Quina fórmula és adequada per a acabar un correu formal?", "o": ["Quede a la vostra disposició per a qualsevol aclariment.", "Quede a la seua disposició per a qualsevol aclaració de dubtes, vale?", "Me quede a la vostra disposició pa lo que siga."], "e": "Quedar (o restar) a la vostra disposició. Les altres tenen col·loquialismes i castellanismes («vale», «pa lo que»)."},
      {"q": "Escriu el comiat formal que comença per «Atent-».", "a": ["atentament"], "e": "Atentament."},
      {"q": "Escriu el títol de l'apartat d'una instància on es fa la petició concreta.", "a": ["sol·licite", "sol·licita"], "e": "SOL·LICITE (o SOL·LICITA)."},
      {"q": "Escriu la paraula genuïna per al castellanisme «plaç».", "a": ["termini", "el termini"], "e": "Termini."},
      {"q": "Escriu el nom del document que s'afig al final d'un altre per a completar-lo.", "a": ["annex", "un annex", "l'annex"], "e": "Un annex."}
    ]
  },
  {
    "id": "fb52a47a-d259-579a-9d90-ac9a513374c1", "type": "b2_lex_menjar_salut_esport", "sort_order": 3,
    "title": "Menjar, dieta, restauració, salut i esport", "name": "Aliments i cuina, la carta del restaurant, la dieta, la salut i els esports",
    "content": "Aliments, tècniques de cuina, la carta i el servici del restaurant, la dieta equilibrada i els nutrients, les malalties i els símptomes, les especialitats mèdiques, els medicaments, els esports, les instal·lacions i les accions esportives (3.2.3).", "icon": "🥗", "color": "#C8E6C9",
    "exercises": [
      {"q": "Quina és la forma genuïna per a 'zanahoria'?", "o": ["safanòria", "zanahòria", "çanòria"], "e": "Safanòria (o pastanaga)."},
      {"q": "Quina és la forma genuïna per a 'judías verdes'?", "o": ["bajoques", "judies verdes", "xudies"], "e": "Les bajoques (o fesols tendres)."},
      {"q": "Quin d'estos aliments NO és un llegum?", "o": ["la carxofa", "els cigrons", "les llentilles", "els fesols"], "e": "La carxofa és una hortalissa. Cigrons, llentilles i fesols són llegums."},
      {"q": "Coure un aliment submergit en oli molt calent és...", "o": ["fregir-lo", "bullir-lo", "rostir-lo"], "e": "Fregir (fregit). Rostir és coure al forn o al foc sense líquid."},
      {"q": "Fregir a poc a poc ceba, tomaca, all... per a fer la base d'un plat és...", "o": ["sofregir", "arrebossar", "escaldar"], "e": "Sofregir: fer el sofregit."},
      {"q": "Cobrir un aliment amb ou batut i farina o pa ratllat abans de fregir-lo és...", "o": ["arrebossar-lo", "gratinar-lo", "estofar-lo"], "e": "Arrebossar (arrebossat). Gratinar és torrar-ne la superfície al forn."},
      {"q": "Coure un aliment damunt d'una làmina metàl·lica calenta, amb molt poc oli, és fer-lo...", "o": ["a la planxa", "al vapor", "en estofat"], "e": "A la planxa. Al vapor: amb el vapor de l'aigua bullent."},
      {"q": "Traure l'aigua a la pasta després de bullir-la és...", "o": ["escórrer-la", "remenar-la", "pelar-la"], "e": "Escórrer (amb un escorredor). Remenar és moure amb una cullera."},
      {"q": "Una carn feta per fora però encara crua per dins està...", "o": ["poc feta", "molt feta", "arrebossada"], "e": "Poc feta, al punt o molt feta."},
      {"q": "Al restaurant, els plats lleugers que es prenen abans del primer són...", "o": ["els entrants", "les postres", "els coberts"], "e": "Els entrants. Després vénen el primer plat, el segon i les postres."},
      {"q": "Quina frase és correcta sobre el plat dolç que es pren al final del menjar?", "o": ["Les postres eren boníssimes.", "Els postres eren boníssims.", "El postre era boníssim."], "e": "«Postres» és femení i plural: les postres."},
      {"q": "Què demanes al cambrer per a pagar quan has acabat de menjar?", "o": ["el compte", "la cuenta", "el càlcul"], "e": "El compte. «Cambrer, el compte, per favor.»"},
      {"q": "La forquilla, el ganivet i la cullera són...", "o": ["els coberts", "les tovalles", "la vaixella"], "e": "Els coberts. Les tovalles cobrixen la taula; la vaixella són els plats, gots..."},
      {"q": "Com s'anomena el cobert que té pues i servix per a punxar el menjar?", "o": ["la forquilla", "el tenedor", "el cullerot"], "e": "La forquilla. «Tenedor» és castellà; el cullerot és una cullera gran per a servir."},
      {"q": "Un menú de preu fix, amb primer, segon i postres, que oferix el restaurant els dies feiners és...", "o": ["el menú del dia", "la carta de vins", "el bufet lliure"], "e": "El menú del dia. Menjar a la carta és triar plats solts."},
      {"q": "Els nutrients que donen energia i abunden en el pa, l'arròs i la pasta són...", "o": ["els hidrats de carboni", "les proteïnes", "les vitamines"], "e": "Els hidrats de carboni (o glúcids)."},
      {"q": "La carn, el peix, els ous i els llegums són rics en...", "o": ["proteïnes", "fibra", "sucres"], "e": "Proteïnes: formen i reparen els teixits."},
      {"q": "La fruita, la verdura i els cereals integrals són rics en...", "o": ["fibra", "colesterol", "greixos saturats"], "e": "Fibra: ajuda a la digestió."},
      {"q": "Una dieta equilibrada és la que...", "o": ["inclou aliments variats en les proporcions adequades", "elimina tots els greixos", "es basa sobretot en carn"], "e": "Dieta equilibrada: variada, amb tots els nutrients i en la quantitat adequada."},
      {"q": "Seguir una dieta per a perdre pes és...", "o": ["fer règim", "fer dejú", "fer sobretaula"], "e": "Fer règim (o dieta) per a aprimar-se."},
      {"q": "Una persona que no pot menjar gluten és...", "o": ["celíaca", "diabètica", "vegana"], "e": "Celíaca: té intolerància al gluten. Diabètica: té diabetis."},
      {"q": "Una persona que no menja cap producte d'origen animal (ni ous, ni llet, ni mel) és...", "o": ["vegana", "vegetariana", "celíaca"], "e": "Vegana. Un vegetarià no menja carn ni peix, però pot menjar ous i làctics."},
      {"q": "Quina és la forma genuïna per a 'fiebre'?", "o": ["febra", "fiebre", "fèbrega"], "e": "Febra (tindre febra, febrós)."},
      {"q": "Quina frase és correcta per a expressar un dolor de cap?", "o": ["Tinc mal de cap.", "Tinc dolor de cabeça.", "Tinc mal de cabeça."], "e": "Mal de cap (o dolor de cap). «Cabeça» no és valencià."},
      {"q": "Expulsar l'aire de manera brusca i sorollosa per la gola és...", "o": ["tossir", "esternudar", "vomitar"], "e": "Tossir (la tos). Esternudar: expulsar aire pel nas (l'esternut)."},
      {"q": "Una inflamació lleu de les vies respiratòries, amb mocs i esternuts, és...", "o": ["un refredat (o constipat)", "una fractura", "una cremada"], "e": "Un refredat o constipat (refredar-se, constipar-se)."},
      {"q": "Una lesió dels lligaments del turmell per un mal gest és...", "o": ["un esquinç", "una fractura", "una cremada"], "e": "Un esquinç (o torçada). La fractura és el trencament d'un os."},
      {"q": "La taca fosca que ix a la pell després d'un colp és...", "o": ["un blau (o morat)", "una pigua", "una arruga"], "e": "Un blau o un morat."},
      {"q": "El metge especialista en les malalties dels xiquets és...", "o": ["el pediatre", "el geriatre", "el dermatòleg"], "e": "Pediatre (xiquets), geriatre (gent gran), dermatòleg (pell)."},
      {"q": "Si tens un problema del cor, et visita...", "o": ["el cardiòleg", "l'oftalmòleg", "el traumatòleg"], "e": "Cardiòleg (cor), oftalmòleg (ulls), traumatòleg (ossos i lesions)."},
      {"q": "El metge que t'atén habitualment en el centre de salut és el metge...", "o": ["de capçalera (o de família)", "cirurgià plàstic", "forense"], "e": "Metge de capçalera o de família. El metge forense actua en casos judicials."},
      {"q": "El paper on el metge indica el medicament que has de prendre és...", "o": ["la recepta", "la receta", "el prospecte"], "e": "La recepta (receptar). El prospecte és el full d'instruccions que hi ha dins de la capsa."},
      {"q": "Un medicament per a calmar el dolor és...", "o": ["un analgèsic", "un antibiòtic", "un laxant"], "e": "Analgèsic (calmant). L'antibiòtic combat les infeccions bacterianes."},
      {"q": "Un medicament líquid i espés que es pren a cullerades, per exemple per a la tos, és...", "o": ["un xarop", "una pomada", "un supositori"], "e": "Un xarop. La pomada s'aplica damunt la pell."},
      {"q": "Córrer, saltar i llançar són les proves de...", "o": ["l'atletisme", "la natació", "la gimnàstica rítmica"], "e": "L'atletisme: curses, salts i llançaments."},
      {"q": "Els estils crol, braça, esquena i papallona són de...", "o": ["la natació", "l'atletisme", "el ciclisme"], "e": "La natació (nadar, nadador)."},
      {"q": "L'esport tradicional valencià en què es colpeja la pilota amb la mà, com l'escala i corda o el raspall, és...", "o": ["la pilota valenciana", "el pàdel", "l'handbol"], "e": "La pilota valenciana: escala i corda, raspall, galotxa, frontó..."},
      {"q": "L'espai d'una instal·lació esportiva on els jugadors es canvien de roba i es dutxen són...", "o": ["els vestidors", "les graderies", "les taquilles"], "e": "Els vestidors. El públic seu a les graderies."},
      {"q": "Colpejar la pilota amb el peu, en futbol, és...", "o": ["xutar", "botar", "llançar a cistella"], "e": "Xutar (un xut). En bàsquet es bota la pilota i es llança a cistella."},
      {"q": "Quan dos equips acaben el partit amb el mateix resultat, diem que...", "o": ["empaten", "desempaten", "guanyen"], "e": "Empatar (un empat)."},
      {"q": "Fer exercicis suaus abans d'un esforç físic per a evitar lesions és...", "o": ["escalfar", "lesionar-se", "desqualificar"], "e": "Escalfar (l'escalfament). Al final, es fan estiraments."},
      {"q": "Escriu el verb: coure un aliment en oli bullent.", "a": ["fregir"], "e": "Fregir."},
      {"q": "Escriu la forma genuïna de 'fiebre'.", "a": ["febra", "la febra"], "e": "Febra."},
      {"q": "Escriu el nom del medicament que combat les infeccions bacterianes.", "a": ["antibiòtic", "un antibiòtic", "l'antibiòtic"], "e": "Un antibiòtic."},
      {"q": "Escriu el nom de l'especialista en les malalties de la pell.", "a": ["dermatòleg", "dermatòloga", "el dermatòleg", "la dermatòloga"], "e": "El dermatòleg (la dermatòloga)."}
    ]
  },
  {
    "id": "6225300a-a6f1-510a-99e9-8a9214b7a631", "type": "b2_lex_tecnologia_ciencies", "sort_order": 4,
    "title": "Tecnologia i ciències de la naturalesa", "name": "Informàtica, internet i xarxes; biologia, geologia, ecologia, física, química i astronomia",
    "content": "El lèxic de la informàtica, internet, els mòbils i les xarxes, i el de les ciències de la naturalesa: éssers vius i ecosistemes, roques i relleu, medi ambient i energia, matèria i forces, i l'univers (3.2.3).", "icon": "🔬", "color": "#B3E5FC",
    "exercises": [
      {"q": "Com s'escriu la paraula secreta per a accedir a un compte?", "o": ["contrasenya", "contraseña", "contrasènia"], "e": "Contrasenya: la paraula secreta per a accedir a un compte."},
      {"q": "Quin és un sinònim de «fitxer» en informàtica?", "o": ["arxiu", "carpeta", "escriptori"], "e": "Fitxer o arxiu. Una carpeta agrupa fitxers."},
      {"q": "La pàgina o el programa que busca informació a internet a partir de paraules clau és...", "o": ["el cercador", "el navegador", "el servidor"], "e": "El cercador. El navegador és el programa per a obrir pàgines web."},
      {"q": "El conjunt de programes d'un ordinador és el programari; el conjunt de components físics és...", "o": ["el maquinari", "el teclat", "el núvol"], "e": "Maquinari (components físics) i programari (programes)."},
      {"q": "L'aparell que distribuïx la connexió a internet a tots els dispositius de casa és...", "o": ["l'encaminador (o router)", "el ratolí", "l'altaveu"], "e": "L'encaminador (router). Pot donar connexió per cable o sense fil."},
      {"q": "Com s'escriu l'enllaç d'un aparell amb una xarxa?", "o": ["connexió", "conexió", "connecsió"], "e": "Connexió (connectar), amb nn i x."},
      {"q": "Una connexió a internet sense cables és una connexió...", "o": ["sense fil", "per cable", "analògica"], "e": "Sense fil (wifi)."},
      {"q": "El sistema de seguretat que protegix una xarxa de les connexions no autoritzades és...", "o": ["el tallafoc", "el navegador", "el cercador"], "e": "El tallafoc (o tallafocs)."},
      {"q": "Guardar els fitxers en servidors d'internet per a accedir-hi des de qualsevol dispositiu és guardar-los...", "o": ["al núvol", "a l'escriptori", "a la paperera"], "e": "Al núvol: emmagatzematge en línia."},
      {"q": "Com s'escriu el verb 'posar un programa en l'ordinador'?", "o": ["instal·lar", "instalar", "instal·llar"], "e": "Instal·lar (instal·lació), amb ela geminada."},
      {"q": "Eliminar un fitxer és...", "o": ["esborrar-lo (o suprimir-lo)", "borrar-lo", "desar-lo"], "e": "Esborrar o suprimir. «Borrar» és un castellanisme."},
      {"q": "Un dispositiu portàtil amb pantalla tàctil, més gran que un mòbil, és...", "o": ["una tauleta", "un servidor", "un encaminador"], "e": "Una tauleta (tàctil)."},
      {"q": "Com s'anomena la peça que mou el cursor per la pantalla?", "o": ["el ratolí", "el ratón", "la rata"], "e": "El ratolí: mou el cursor per la pantalla."},
      {"q": "Endollar el mòbil per a omplir la bateria és...", "o": ["carregar-lo", "descarregar-lo", "formatar-lo"], "e": "Carregar (el carregador). Descarregar un fitxer és copiar-lo d'internet."},
      {"q": "Codificar unes dades perquè només les puga llegir qui té la clau és...", "o": ["xifrar-les", "comprimir-les", "imprimir-les"], "e": "Xifrar (o encriptar). Comprimir és reduir la mida d'un fitxer."},
      {"q": "Quan no tens connexió a internet, estàs...", "o": ["fora de línia", "en línia", "en directe"], "e": "Fora de línia (desconnectat). En línia: connectat."},
      {"q": "Comprovar la identitat amb la contrasenya i, a més, amb un codi que rebs al mòbil és...", "o": ["la verificació en dos passos", "la còpia de seguretat", "la descàrrega"], "e": "La verificació (o autenticació) en dos passos fa el compte més segur."},
      {"q": "Un conjunt d'individus semblants que es poden reproduir entre si i tindre descendència fèrtil és...", "o": ["una espècie", "un ecosistema", "un hàbitat"], "e": "Una espècie (no «espècia», que és un condiment)."},
      {"q": "El conjunt dels éssers vius d'un lloc i del medi físic on viuen és...", "o": ["un ecosistema", "una espècie", "un òrgan"], "e": "Un ecosistema: una llacuna, un bosc, un riu..."},
      {"q": "Les plantes fabriquen el seu aliment amb la llum del sol gràcies a la...", "o": ["fotosíntesi", "fotosintesi", "photosíntesi"], "e": "Fotosíntesi (esdrúixola: s'accentua). Necessita llum, aigua i diòxid de carboni."},
      {"q": "Com s'escriu la unitat bàsica dels éssers vius?", "o": ["cèl·lula", "célula", "cèlula"], "e": "Cèl·lula: la unitat bàsica dels éssers vius."},
      {"q": "Un animal que no té columna vertebral és...", "o": ["invertebrat", "mamífer", "rèptil"], "e": "Invertebrat (insectes, mol·luscs...). Mamífers i rèptils són vertebrats."},
      {"q": "Quin d'estos animals és un amfibi?", "o": ["la granota", "la sargantana", "el dofí"], "e": "La granota és un amfibi; la sargantana, un rèptil; el dofí, un mamífer."},
      {"q": "Un animal que s'alimenta només de plantes és...", "o": ["herbívor", "carnívor", "omnívor"], "e": "Herbívor (plantes), carnívor (carn), omnívor (de tot)."},
      {"q": "El material (arena, fang, grava...) que s'acumula al fons d'un riu o del mar és...", "o": ["el sediment", "el magma", "el mineral"], "e": "El sediment. Amb el temps pot formar roques sedimentàries."},
      {"q": "La roca fosa que hi ha a l'interior de la Terra i ix pels volcans és...", "o": ["el magma", "el sediment", "el fòssil"], "e": "El magma; quan ix a la superfície s'anomena lava."},
      {"q": "La resta d'un ésser viu antic conservada en una roca és...", "o": ["un fòssil", "un sediment", "un cristall"], "e": "Un fòssil (fossilitzar-se)."},
      {"q": "El desgast del relleu per l'acció de l'aigua, del vent o del gel és...", "o": ["l'erosió", "la sedimentació", "l'evaporació"], "e": "L'erosió (erosionar)."},
      {"q": "La varietat d'espècies d'éssers vius d'un lloc és...", "o": ["la biodiversitat", "la contaminació", "la desertització"], "e": "La biodiversitat. La seua pèrdua amenaça els ecosistemes."},
      {"q": "Quina d'estes fonts d'energia NO és renovable?", "o": ["el petroli", "el sol", "el vent", "l'aigua dels rius"], "e": "El petroli és un combustible fòssil: s'esgota. Solar, eòlica i hidràulica són renovables."},
      {"q": "L'energia que s'obté del vent és...", "o": ["eòlica", "solar", "geotèrmica"], "e": "Eòlica (aerogeneradors). Geotèrmica: de la calor interna de la Terra."},
      {"q": "L'augment de la temperatura del planeta per l'acumulació de gasos a l'atmosfera és...", "o": ["l'escalfament global", "l'erosió", "la fotosíntesi"], "e": "L'escalfament global, causat per l'efecte d'hivernacle."},
      {"q": "La força que fa caure els cossos cap a la Terra és...", "o": ["la gravetat", "la fricció", "l'electricitat"], "e": "La gravetat (o gravitació)."},
      {"q": "La temperatura a la qual un líquid es convertix en gas és el punt...", "o": ["d'ebullició", "de fusió", "de congelació"], "e": "Punt d'ebullició (bullir). Punt de fusió: de sòlid a líquid."},
      {"q": "La partícula més xicoteta d'un element químic que en conserva les propietats és...", "o": ["l'àtom", "la molècula", "la cèl·lula"], "e": "L'àtom. Una molècula és un conjunt d'àtoms units."},
      {"q": "Com s'escriu el gas que respirem?", "o": ["l'oxigen", "l'oxígen", "l'oxígeno"], "e": "Oxigen, sense accent (paraula plana acabada en -en), com «hidrogen»."},
      {"q": "Una mescla homogènia d'una substància dissolta en una altra és...", "o": ["una dissolució", "una reacció", "una fusió"], "e": "Una dissolució (dissoldre): el solut es dissol en el dissolvent."},
      {"q": "La Lluna és ___ de la Terra.", "o": ["un satèl·lit", "un planeta", "un estel"], "e": "Un satèl·lit (natural). Es manté en òrbita al voltant de la Terra."},
      {"q": "El camí que seguix un planeta al voltant del Sol és...", "o": ["l'òrbita", "l'eix", "l'atmosfera"], "e": "L'òrbita. L'eix és la línia imaginària al voltant de la qual gira."},
      {"q": "Un conjunt enorme d'estels, pols i gas, com la Via Làctia, és...", "o": ["una galàxia", "una constel·lació", "un satèl·lit"], "e": "Una galàxia. Una constel·lació és un grup d'estels que, vistos des de la Terra, formen una figura."},
      {"q": "Quan la Lluna s'interposa entre el Sol i la Terra, hi ha...", "o": ["un eclipsi solar", "un eclipsi lunar", "un equinocci"], "e": "Eclipsi solar. En l'eclipsi lunar, la Terra s'interposa entre el Sol i la Lluna."},
      {"q": "Escriu la forma genuïna de 'contraseña'.", "a": ["contrasenya", "la contrasenya"], "e": "Contrasenya."},
      {"q": "Escriu el nom del procés pel qual les plantes fabriquen aliment amb la llum.", "a": ["fotosíntesi", "la fotosíntesi"], "e": "La fotosíntesi."},
      {"q": "Escriu el nom de la resta d'un ésser viu antic conservada en una roca.", "a": ["fòssil", "un fòssil"], "e": "Un fòssil."},
      {"q": "Escriu el nom genuí del conjunt de components físics d'un ordinador (contrari de «programari»).", "a": ["maquinari", "el maquinari"], "e": "El maquinari."}
    ]
  },
  {
    "id": "040ac9b4-5dab-5992-9d02-04e896cec5ab", "type": "b2_lex_contes_rondalles", "sort_order": 5,
    "title": "Contes, rondalles i cançons tradicionals", "name": "Fórmules, personatges, objectes màgics, encanteris i cançons i jocs populars",
    "content": "Les fórmules d'inici i de final dels contes, els personatges i els éssers fantàstics, els objectes màgics i els encanteris, les rondalles valencianes d'Enric Valor i les cançons i els jocs populars (3.2.3).", "icon": "📜", "color": "#F8BBD0",
    "exercises": [
      {"q": "Quina és una fórmula tradicional per a començar una rondalla?", "o": ["Açò era i no era...", "I conte contat, conte acabat.", "Atentament,"], "e": "Açò era i no era, Una vegada era, Temps era temps... són fórmules d'inici."},
      {"q": "Quina fórmula NO s'usa per a començar un conte?", "o": ["I vet ací un gat, i vet ací un gos, este conte ja s'ha fos.", "Una vegada era...", "Açò era i no era...", "Temps era temps..."], "e": "«I vet ací un gat, i vet ací un gos...» és una fórmula de final."},
      {"q": "Completa la fórmula final: «I conte contat, ___.»", "o": ["conte acabat", "conte comptat", "conte tancat"], "e": "I conte contat, conte acabat."},
      {"q": "«I van ser feliços i van menjar anissos.» Esta frase és...", "o": ["una fórmula de final de conte", "una fórmula d'inici de conte", "una cançó de bressol"], "e": "És una fórmula de tancament: els personatges acaben feliços."},
      {"q": "Una narració popular de tradició oral, amb elements fantàstics, transmesa de generació en generació, és...", "o": ["una rondalla", "una crònica", "un assaig"], "e": "Una rondalla (rondallaire: qui les conta)."},
      {"q": "Una narració breu, protagonitzada per animals, que acaba amb una ensenyança és...", "o": ["una faula", "una llegenda", "una endevinalla"], "e": "Una faula (les faules d'Isop, de La Fontaine)."},
      {"q": "L'ensenyança que es trau al final d'una faula és...", "o": ["la moralitat", "la moraleja", "la moraleta"], "e": "La moralitat (o moral). «Moraleja» és castellà."},
      {"q": "Una narració tradicional sobre fets meravellosos lligats a un lloc o a un personatge real és...", "o": ["una llegenda", "una faula", "una cançó de bressol"], "e": "Una llegenda: la llegenda del drac de Sant Jordi, de la Cova Tallada..."},
      {"q": "Qui va recollir i reelaborar les «Rondalles valencianes»?", "o": ["Enric Valor", "Antoni M. Alcover", "Joanot Martorell"], "e": "Enric Valor (Castalla, 1911-2000). Alcover va recollir les rondalles mallorquines."},
      {"q": "Quina d'estes obres és una rondalla d'Enric Valor?", "o": ["L'envejós de Tibi", "Tirant lo Blanc", "Curial e Güelfa"], "e": "L'envejós de Tibi, Esclafamuntanyes, El gegant del Romaní... són rondalles de Valor. Les altres són novel·les medievals."},
      {"q": "En les rondalles, l'animal astut que sovint enganya els altres és...", "o": ["la rabosa", "l'ovella", "el bou"], "e": "La rabosa (o guineu), símbol d'astúcia."},
      {"q": "Una dona amb poders màgics, sovint dolenta, que vola en una granera és...", "o": ["una bruixa", "una fada", "una princesa"], "e": "Una bruixa (bruixeria, embruixar)."},
      {"q": "Un ésser fantàstic femení i bondadós, amb una vareta màgica, és...", "o": ["una fada", "una bruixa", "una geganta"], "e": "Una fada (la fada padrina de la Ventafocs)."},
      {"q": "Quina és la forma genuïna per a 'hada'?", "o": ["fada", "hada", "fata"], "e": "Fada."},
      {"q": "Un ésser fantàstic xicotet i entremaliat, que fa malifetes a les cases, és...", "o": ["un follet", "un gegant", "un drac"], "e": "Un follet (o donyet)."},
      {"q": "Un personatge d'una altura enorme és...", "o": ["un gegant", "un nan", "un follet"], "e": "Un gegant (una geganta). El contrari és un nan."},
      {"q": "Un gegant que menja persones és...", "o": ["un ogre", "un pastor", "un follet"], "e": "Un ogre (com en el conte del Polzet)."},
      {"q": "Un animal fabulós, semblant a una serp gegant, amb ales i que trau foc per la boca, és...", "o": ["un drac", "un unicorn", "un llop"], "e": "Un drac (com el de Sant Jordi)."},
      {"q": "Quin personatge NO és un ésser fantàstic?", "o": ["el llaurador", "el follet", "la fada", "el drac"], "e": "El llaurador (qui treballa la terra) és un personatge real, com el pastor, el rei o la princesa."},
      {"q": "La persona que guarda el ramat d'ovelles, molt present en les rondalles, és...", "o": ["el pastor", "el moliner", "el ferrer"], "e": "El pastor. El moliner treballa al molí i el ferrer forja el ferro."},
      {"q": "La filla del rei és...", "o": ["la princesa", "la reina", "la duquessa"], "e": "La princesa (i el príncep). La reina és l'esposa del rei o la sobirana."},
      {"q": "La nova dona del pare de la Ventafocs, que la maltracta, és la seua...", "o": ["madrastra", "padrina", "sogra"], "e": "La madrastra (i el padrastre)."},
      {"q": "En la Blancaneu, la reina pregunta a l'___ màgic qui és la més bella.", "o": ["espill", "espejo", "rellotge"], "e": "L'espill (o el mirall). «Espejo» és castellà."},
      {"q": "Com s'anomena el bastonet que usen les fades per a fer màgia?", "o": ["vareta màgica", "varita màgica", "barita màgica"], "e": "Vareta màgica: la de les fades i els mags."},
      {"q": "Les monedes d'or amagades en una cova són...", "o": ["un tresor", "un tesoro", "un tesor"], "e": "Un tresor (atresorar)."},
      {"q": "Unes paraules o un acte màgic que produïxen un efecte sobrenatural són...", "o": ["un encanteri (o encantament)", "una endevinalla", "una corranda"], "e": "Un encanteri o encantament (encantar, encisar)."},
      {"q": "Quin és un sinònim d'«encanteri»?", "o": ["sortilegi", "endevinalla", "rondalla"], "e": "Sortilegi, encantament, encís."},
      {"q": "Un príncep convertit en granota per un encanteri està...", "o": ["encantat (o embruixat)", "enamorat", "desencantat"], "e": "Encantat o embruixat. Quan es trenca l'encanteri, queda desencantat."},
      {"q": "Un joc de paraules en què cal descobrir una cosa a partir d'una descripció enigmàtica és...", "o": ["una endevinalla", "una rondalla", "una cançó de bressol"], "e": "Una endevinalla (endevinar). «Què és, què és...?»"},
      {"q": "Una cançó suau que es canta per a adormir els nadons és...", "o": ["una cançó de bressol", "una albada", "un himne"], "e": "Una cançó de bressol (o nana). L'albada és un cant valencià d'alba."},
      {"q": "La cançó tradicional «Vou-veri-vou» és...", "o": ["una cançó de bressol", "una cançó de treball", "una cançó de Nadal"], "e": "«Vou-veri-vou» és una cançó de bressol valenciana."},
      {"q": "Completa la cançó popular: «Plou i fa sol, les bruixes ___...»", "o": ["es pentinen", "ballen", "es banyen"], "e": "«Plou i fa sol, les bruixes es pentinen...»"},
      {"q": "El joc en què un xiquet compta amb els ulls tancats mentre els altres s'amaguen és...", "o": ["a fet i amagar", "la xarranca", "les birles"], "e": "A fet i amagar (o a amagar)."},
      {"q": "El joc de saltar a peu coix sobre unes caselles dibuixades a terra és...", "o": ["el sambori (o la xarranca)", "el mocador", "la corda"], "e": "El sambori o la xarranca."},
      {"q": "Una cançó que acompanya un joc de xiquets, com les de corro o de saltar a corda, és...", "o": ["una cançó de joc", "una cançó de bressol", "una cançó de treball"], "e": "Les cançons de joc acompanyen el joc (fer rotllo, saltar a corda...)."},
      {"q": "Un personatge que no té por de res, com en «Joan-sense-por», és...", "o": ["valent (o agosarat)", "poruc", "covard"], "e": "Valent, agosarat. El contrari és poruc o covard."},
      {"q": "L'edifici fortificat on viuen els reis en molts contes és...", "o": ["el castell", "el mas", "la barraca"], "e": "El castell (o el palau)."},
      {"q": "El personatge dolent que s'oposa a l'heroi en un conte és...", "o": ["l'antagonista", "el protagonista", "el narrador"], "e": "L'antagonista (o el malvat). El protagonista és el personatge principal."},
      {"q": "Completa la fórmula final: «I conte contat, conte ___.»", "a": ["acabat"], "e": "I conte contat, conte acabat."},
      {"q": "Escriu el nom de l'ésser fantàstic xicotet i entremaliat que fa malifetes a les cases.", "a": ["follet", "un follet", "el follet"], "e": "Un follet."},
      {"q": "Escriu el cognom de l'autor de les «Rondalles valencianes» (Enric ___).", "a": ["valor"], "e": "Enric Valor."},
      {"q": "Escriu la forma genuïna de 'hada'.", "a": ["fada", "una fada", "la fada"], "e": "Fada."},
      {"q": "Escriu la forma genuïna de 'tesoro'.", "a": ["tresor", "un tresor", "el tresor"], "e": "Tresor."}
    ]
  },
  {
    "id": "eb5e0d44-b092-5364-9223-c3384219fc03", "type": "b2_lex_llengues_gentilicis", "sort_order": 6,
    "title": "Llengües i gentilicis", "name": "Noms de llengües i gentilicis de països, continents, comunitats i ciutats valencianes",
    "content": "Els noms de les llengües més usuals i els gentilicis de països, continents, comunitats autònomes i ciutats valencianes, amb els femenins i els plurals, els gentilicis invariables i irregulars i l'ús de la minúscula (3.2.3).", "icon": "🌍", "color": "#DCEDC8",
    "exercises": [
      {"q": "La paraula que indica l'origen geogràfic d'una persona (alcoià, francés...) és...", "o": ["un gentilici", "un topònim", "un patronímic"], "e": "Un gentilici. El nom propi d'un lloc (Alcoi, França) és un topònim."},
      {"q": "Quina frase és correcta sobre els idiomes que parla una persona?", "o": ["Parla anglés, francés i alemany.", "Parla Anglés, Francés i Alemany.", "Parla inglés, francés i alemany."], "e": "Els noms de llengües i els gentilicis s'escriuen en minúscula. «Inglés» és castellà."},
      {"q": "Quina expressió està ben escrita?", "o": ["Els valencians i les valencianes", "Els Valencians i les Valencianes", "Els valencians i les Valencianes"], "e": "Els gentilicis van en minúscula."},
      {"q": "Quina és la forma genuïna per al gentilici d'Alemanya?", "o": ["alemany", "alemà", "alemán"], "e": "Alemany, alemanya (d'Alemanya)."},
      {"q": "Quina frase és correcta sobre la llengua d'Itàlia?", "o": ["L'italià és una llengua romànica.", "L'Italià és una llengua romànica.", "Italià és una llengua romànica."], "e": "Llengua en minúscula i amb article quan fa de subjecte."},
      {"q": "Una persona d'Alacant és...", "o": ["alacantina", "alacantesa", "alacantenca"], "e": "Alacantí, alacantina."},
      {"q": "Una persona de Castelló de la Plana és...", "o": ["castellonenca", "castellonesa", "castellonina"], "e": "Castellonenc, castellonenca; plural: castellonencs."},
      {"q": "Quin és el plural de «castellonenc»?", "o": ["castellonencs", "castellonencos", "castellonenques"], "e": "Castellonencs (com «blancs»). «Castellonenques» és el plural femení."},
      {"q": "Una persona d'Elx és...", "o": ["elxana", "elxenca", "elxiana"], "e": "Elxà, elxana; plural: elxans, elxanes."},
      {"q": "Una persona d'Alcoi és...", "o": ["alcoiana", "alcoienca", "alcoiesa"], "e": "Alcoià, alcoiana."},
      {"q": "Una persona de Xàtiva és...", "o": ["xativina", "xativesa", "xativiana"], "e": "Xativí, xativina."},
      {"q": "Una persona de Gandia és...", "o": ["gandiana", "gandiesa", "gandienca"], "e": "Gandià, gandiana."},
      {"q": "Una persona d'Oriola és...", "o": ["oriolana", "oriolesa", "oriolenca"], "e": "Oriolà, oriolana."},
      {"q": "Com s'escriu el gentilici de Vila-real?", "o": ["vila-realenc", "vilarealenc", "vila-realense"], "e": "Vila-realenc, vila-realenca: amb guionet, com el topònim."},
      {"q": "Una persona de Sagunt és...", "o": ["sagunter (o saguntí)", "saguntés", "saguntenc"], "e": "Sagunter o saguntí, saguntina."},
      {"q": "Una persona de Dénia és...", "o": ["dianenca", "deniana", "denienca"], "e": "Dianenc, dianenca (de Dénia)."},
      {"q": "Una persona d'Alzira és...", "o": ["alzirenya", "alzirana", "alziresa"], "e": "Alzireny, alzirenya."},
      {"q": "Una persona d'Ontinyent és...", "o": ["ontinyentina", "ontinyentenca", "ontinyentesa"], "e": "Ontinyentí, ontinyentina."},
      {"q": "Una persona de Morella és...", "o": ["morellana", "morellenca", "morellesa"], "e": "Morellà, morellana."},
      {"q": "Quin és el plural masculí de «francés»?", "o": ["francesos", "francés", "franceses"], "e": "Francés, francesos; francesa, franceses (masculí en -os, com «anglesos», «xinesos»)."},
      {"q": "Quin és el femení de «suís»?", "o": ["suïssa", "suisa", "suïsa"], "e": "Suís, suïssa, suïssos, suïsses (dièresi i doble s)."},
      {"q": "Quin és el femení de «grec»?", "o": ["grega", "greca", "grequa"], "e": "Grec, grega, grecs, gregues."},
      {"q": "Quin és el femení de «rus»?", "o": ["russa", "rusa", "rússia"], "e": "Rus, russa, russos, russes."},
      {"q": "Quin és el femení de «suec»?", "o": ["sueca", "suega", "sueda"], "e": "Suec, sueca, suecs, sueques (de Suècia)."},
      {"q": "Quin és el femení de «turc»?", "o": ["turca", "turga", "turquesa"], "e": "Turc, turca, turcs, turques."},
      {"q": "Quin és el femení d'«andalús»?", "o": ["andalusa", "andaluza", "andalussa"], "e": "Andalús, andalusa, andalusos, andaluses."},
      {"q": "Quin és el femení d'«europeu»?", "o": ["europea", "europeua", "europeia"], "e": "Europeu, europea (com «hebreu, hebrea»)."},
      {"q": "Quin gentilici és invariable en gènere?", "o": ["belga", "francés", "suec"], "e": "Belga és igual en masculí i femení: un belga, una belga."},
      {"q": "Una persona del Marroc és...", "o": ["marroquina", "marroquesa", "marroquiana"], "e": "Marroquí, marroquina, marroquins."},
      {"q": "Una persona de Galícia és...", "o": ["gallega", "galaica", "gallenca"], "e": "Gallec, gallega; la llengua és el gallec."},
      {"q": "Una persona de Madrid és...", "o": ["madrilenya", "madrilesa", "madrilena"], "e": "Madrileny, madrilenya."},
      {"q": "Una persona d'Aragó és...", "o": ["aragonesa", "aragonenca", "aragoniana"], "e": "Aragonés, aragonesa."},
      {"q": "Una persona d'Àsia és...", "o": ["asiàtica", "asiana", "asiàtiga"], "e": "Asiàtic, asiàtica. D'Àfrica: africà; d'Amèrica: americà."},
      {"q": "Una persona dels Estats Units és...", "o": ["nord-americana (o estatunidenca)", "nordamericana", "estadounidenca"], "e": "Nord-americà, amb guionet, o estatunidenc."},
      {"q": "La llengua oficial del Brasil és...", "o": ["el portugués", "el brasiler", "l'espanyol"], "e": "El portugués."},
      {"q": "La llengua dels Països Baixos és...", "o": ["el neerlandés", "el danés", "el suec"], "e": "El neerlandés (o holandés)."},
      {"q": "Quina llengua s'escriu amb l'alfabet ciríl·lic?", "o": ["el rus", "el grec", "l'àrab"], "e": "El rus. El grec té alfabet propi i l'àrab s'escriu de dreta a esquerra."},
      {"q": "Quina llengua NO és romànica?", "o": ["l'alemany", "el romanés", "el portugués", "l'occità"], "e": "L'alemany és una llengua germànica."},
      {"q": "Una persona de la Xina és...", "o": ["xinesa", "xina", "xinenca"], "e": "Xinés, xinesa; la llengua és el xinés."},
      {"q": "Una persona del Japó és...", "o": ["japonesa", "japona", "japonenca"], "e": "Japonés, japonesa; la llengua és el japonés."},
      {"q": "Escriu el gentilici masculí d'Elx.", "a": ["elxà"], "e": "Elxà, elxana."},
      {"q": "Escriu el femení de «suís».", "a": ["suïssa"], "e": "Suïssa."},
      {"q": "Escriu el gentilici masculí d'Alcoi.", "a": ["alcoià"], "e": "Alcoià, alcoiana."},
      {"q": "Escriu el plural masculí d'«anglés».", "a": ["anglesos"], "e": "Anglesos (anglesa, angleses)."},
      {"q": "Escriu el nom de la llengua de Grècia.", "a": ["grec", "el grec"], "e": "El grec."}
    ]
  },
  {
    "id": "3eb807b1-071b-5601-8135-24dd362b8ca6", "type": "b2_lex_descripcio", "sort_order": 7,
    "title": "Descripció espacial, física i de personalitat", "name": "Situació a l'espai, aspecte físic i caràcter",
    "content": "El lèxic per a situar en l'espai (posicions, orientació i formes), per a descriure l'aspecte físic (complexió, faccions, cabell i pell) i la personalitat, amb els adjectius de caràcter i els seus antònims (3.2.3).", "icon": "🧭", "color": "#FFF9C4",
    "exercises": [
      {"q": "El contrari de «davant» és...", "o": ["darrere", "davall", "damunt"], "e": "Davant / darrere. Damunt / davall."},
      {"q": "«El gat dorm ___ del llit»: a la part de sota.", "o": ["davall", "damunt", "enfront"], "e": "Davall (o baix de): a sota. El contrari és damunt (o dalt de)."},
      {"q": "Quina és la forma genuïna per a dir 'a la part de sota de la taula'?", "o": ["davall de la taula", "debajo de la taula", "en baixo de la taula"], "e": "Davall de (o baix de) la taula."},
      {"q": "«Les claus estan ___ de la taula»: a la part de dalt.", "o": ["damunt", "davall", "darrere"], "e": "Damunt (o dalt de)."},
      {"q": "«La farmàcia està ___ del banc, a l'altra vora del carrer, cara a cara.»", "o": ["enfront", "darrere", "dins"], "e": "Enfront de (o davant per davant de)."},
      {"q": "Quin és un sinònim de «a la vora de»?", "o": ["prop de", "lluny de", "dins de"], "e": "A la vora de, prop de, al costat de."},
      {"q": "La part més allunyada de l'entrada d'una sala és...", "o": ["el fons", "la vora", "el llindar"], "e": "Al fons (de la sala, del passadís)."},
      {"q": "El punt on es troben dos carrers, o l'angle exterior de dues parets, és...", "o": ["el cantó (o la cantonada)", "el racó", "el fons"], "e": "El cantó o la cantonada. «Al cantó del carrer.»"},
      {"q": "L'angle interior que formen dues parets és...", "o": ["el racó", "el cantó", "el sostre"], "e": "El racó (arraconar)."},
      {"q": "Quin és el contrari de «a mà dreta»?", "o": ["a mà esquerra", "a mà alçada", "a mà salvada"], "e": "A mà dreta / a mà esquerra. «A mà alçada» és dibuixar sense regle."},
      {"q": "«Es va asseure ___ dels dos germans»: al mig.", "o": ["enmig", "darrere", "a la vora"], "e": "Enmig de: al centre, entre dos o més."},
      {"q": "Dues línies que no es tallen mai són...", "o": ["paral·leles", "perpendiculars", "obliqües"], "e": "Paral·leles. Perpendiculars: es tallen en angle recte."},
      {"q": "Com s'escriu l'adjectiu de dues línies que no es tallen mai?", "o": ["paral·lel", "paralel", "paral·lell"], "e": "Paral·lel, amb ela geminada al mig i una sola ela al final."},
      {"q": "Com s'escriu el contrari de «vertical»?", "o": ["horitzontal", "horizontal", "horitsontal"], "e": "Horitzontal (horitzó). El contrari és vertical."},
      {"q": "La torre de Pisa no està vertical: està...", "o": ["inclinada", "horitzontal", "paral·lela"], "e": "Inclinada (inclinar-se)."},
      {"q": "La constitució física general d'una persona (forta, prima, robusta...) és la...", "o": ["complexió", "complicació", "composició"], "e": "La complexió: de complexió robusta, menuda..."},
      {"q": "Una persona forta, ampla d'esquena i robusta és...", "o": ["cepada", "escanyolida", "esvelta"], "e": "Cepat, cepada: robust. Escanyolit: massa prim."},
      {"q": "El contrari de «prim» és...", "o": ["gras (o gros)", "esvelt", "baix"], "e": "Prim / gras (o gros). Una persona grassoneta és un poc grossa."},
      {"q": "Els trets de la cara (els ulls, el nas, la boca...) són les...", "o": ["faccions", "fraccions", "galtes"], "e": "Les faccions: faccions fines, marcades..."},
      {"q": "Els ossos sortints de la cara, davall dels ulls, són...", "o": ["els pòmuls", "les galtes", "les temples"], "e": "Els pòmuls. Les galtes són les parts carnoses dels costats de la cara."},
      {"q": "Els pèls corbats que tenim damunt dels ulls són...", "o": ["les celles", "les pestanyes", "les parpelles"], "e": "Les celles. Les pestanyes són a la vora de les parpelles."},
      {"q": "Les parts carnoses de la cara, a banda i banda del nas, són...", "o": ["les galtes", "les celles", "els pòmuls"], "e": "Les galtes (galtes rosades)."},
      {"q": "Les taquetes marrons xicotetes de la pell són...", "o": ["pigues", "arrugues", "celles"], "e": "Les pigues (pigat). Les arrugues són els plecs de la pell."},
      {"q": "Un home sense cabell és...", "o": ["calb", "barbut", "pèl-roig"], "e": "Calb (calvície). Barbut: amb barba."},
      {"q": "Com s'escriu l'adjectiu de qui té el cabell roig?", "o": ["pèl-roig", "pelroig", "pel roig"], "e": "Pèl-roig, pèl-roja: amb guionet i accent."},
      {"q": "Un cabell amb ones suaus, ni llis ni arrissat, és...", "o": ["ondulat", "arrissat", "llis"], "e": "Ondulat. Llis (sense ones) i arrissat (amb rínxols)."},
      {"q": "Una persona que no canvia d'opinió encara que no tinga raó és...", "o": ["tossuda", "dòcil", "flexible"], "e": "Tossut (o caparrut, testarut)."},
      {"q": "Quina és la forma genuïna per a 'cabezota'?", "o": ["tossut", "cabezota", "cabeçota"], "e": "Tossut (o caparrut)."},
      {"q": "Una persona que defuig la faena i no té ganes de fer res és...", "o": ["gandula", "feinera", "generosa"], "e": "Gandul o ganduler. El contrari: feiner, treballador."},
      {"q": "Quina és la forma genuïna per a 'tacaño'?", "o": ["gasiu", "tacaño", "tacanyo"], "e": "Gasiu (o avar, garrepa). El contrari és generós."},
      {"q": "Una persona que parla molt és...", "o": ["xerraire", "callada", "tímida"], "e": "Xerraire (o parlador). El contrari: callat."},
      {"q": "Una persona que sempre es queixa i protesta per tot és...", "o": ["rondinaire", "riallera", "xerraire"], "e": "Rondinaire (rondinar)."},
      {"q": "El contrari d'«humil» és...", "o": ["orgullós (o arrogant)", "senzill", "modest"], "e": "Humil / orgullós, arrogant. Senzill i modest són sinònims d'humil."},
      {"q": "El contrari d'«extravertit» és...", "o": ["introvertit", "xerraire", "empàtic"], "e": "Extravertit / introvertit. Una persona tímida sol ser introvertida."},
      {"q": "Una persona que es posa en el lloc dels altres i en comprén els sentiments és...", "o": ["empàtica", "egoista", "gasiva"], "e": "Empàtica (l'empatia)."},
      {"q": "Un xiquet viu, alegre i espavilat és...", "o": ["eixerit", "esquerp", "babau"], "e": "Eixerit. Esquerp: poc sociable. Babau: ingenu i curt."},
      {"q": "Una persona poc sociable, que defuig el tracte amb la gent, és...", "o": ["esquerpa", "afable", "trempada"], "e": "Esquerp, esquerpa. Afable i trempat són el contrari."},
      {"q": "Quina parella NO és d'antònims?", "o": ["tossut – caparrut", "generós – gasiu", "humil – orgullós", "tímid – extravertit"], "e": "Tossut i caparrut són sinònims."},
      {"q": "Quin adjectiu NO és positiu?", "o": ["rondinaire", "amable", "generós", "empàtic"], "e": "Rondinaire és negatiu; els altres són qualitats."},
      {"q": "Una persona que no es fia de ningú és...", "o": ["malfiada", "confiada", "ingènua"], "e": "Malfiat, malfiada (desconfiat). El contrari: confiat."},
      {"q": "Escriu el contrari de «generós».", "a": ["gasiu", "avar", "garrepa", "tacany"], "e": "Gasiu (o avar, garrepa)."},
      {"q": "Escriu el contrari de «davant».", "a": ["darrere", "detràs"], "e": "Darrere (o detràs)."},
      {"q": "Escriu el nom de l'angle interior que formen dues parets.", "a": ["racó", "el racó"], "e": "El racó."},
      {"q": "Escriu l'adjectiu masculí que descriu un home sense cabell.", "a": ["calb"], "e": "Calb."}
    ]
  },
  {
    "id": "bb6b2f9f-5b16-5a56-ad64-5bee11386669", "type": "b2_lex_derivacio", "sort_order": 8,
    "title": "Formació del lèxic: derivació", "name": "Prefixació i sufixació, canvis de categoria, d'ortografia i d'accent, i flexió dels derivats",
    "content": "La derivació per prefixos i sufixos, els canvis de categoria gramatical que provoca, les alternances ortogràfiques i d'accent de la base i la flexió de la paraula resultant (3.2.3).", "icon": "🌱", "color": "#DCEDC8",
    "exercises": [
      {"q": "La derivació forma paraules noves afegint a una base...", "o": ["un afix: un prefix o un sufix", "una altra paraula sencera", "només les marques de gènere i de nombre"], "e": "Derivació: base + afix (des-fer, fust-er). La composició unix dues paraules (gratacel) i la flexió només canvia el gènere, el nombre, la persona..."},
      {"q": "Per quin procediment s'ha format «deslligar»?", "o": ["Prefixació: des- + lligar", "Sufixació: deslli- + -gar", "Flexió verbal de «lligar»"], "e": "Des- és un prefix: s'anteposa a la base i, com la majoria de prefixos, no canvia la categoria (lligar i deslligar són verbs)."},
      {"q": "Quina d'estes paraules està formada per sufixació?", "o": ["fusteria", "reobrir", "contraatac"], "e": "Fust(a) + -eria. Reobrir (re-) i contraatac (contra-) són prefixats."},
      {"q": "«Rellegir», «reobrir» i «refer»: quin valor aporta el prefix re-?", "o": ["Repetició: tornar a fer l'acció", "Negació o acció contrària", "Posició inferior"], "e": "Re- indica repetició: rellegir és 'tornar a llegir'. La negació l'aporten des- o in-."},
      {"q": "«Subterrani», «subsol», «subdirector»: el prefix sub- significa...", "o": ["davall de, o de rang inferior", "per damunt, o en excés", "en contra de"], "e": "Sub- 'davall, inferior': subsol, subtítol, subdirector. El contrari és sobre- o super-."},
      {"q": "Quin prefix expressa excés o posició superior, com en «sobrecarregar» o «sobrevalorar»?", "o": ["sobre-", "sub-", "pre-"], "e": "Sobre- 'damunt, en excés': sobrecarregar, sobrevalorar, sobrealimentar."},
      {"q": "«Contraatac», «contracultura», «contradir»: el prefix contra- indica...", "o": ["oposició", "companyia", "anterioritat"], "e": "Contra- 'en oposició a': contradir és dir el contrari del que diu un altre."},
      {"q": "Quina d'estes paraules NO porta el prefix anti-?", "o": ["antic", "antiboira", "antisocial"], "e": "Antic és una paraula simple. Antiboira i antisocial porten anti- 'contra': un llum antiboira, una conducta antisocial."},
      {"q": "Una persona que abans era ministra i ara ja no ho és és...", "o": ["l'exministra", "la preministra", "la coministra"], "e": "Ex- 'que ha deixat de ser': exministra, expresident, exalumne (soldat a la paraula)."},
      {"q": "Quina sèrie relaciona bé cada prefix amb el seu significat?", "o": ["co- 'amb' (coautor), inter- 'entre' (internacional), pre- 'abans' (preavís)", "co- 'contra' (coautor), inter- 'dins' (internacional), pre- 'després' (preavís)", "co- 'sense' (coautor), inter- 'fora' (internacional), pre- 'massa' (preavís)"], "e": "Co- 'conjuntament' (coautor, coeducar), inter- 'entre' (intercanviar), pre- 'anterioritat' (prehistòria, predir)."},
      {"q": "Quina sèrie de noms derivats és correcta?", "o": ["construcció, confiança, noblesa, ecologisme", "construïment, confiació, noblança, ecologitat", "construïtat, confiament, noblitat, ecologància"], "e": "V → N: construir > construcció (-ció), confiar > confiança (-ança). Adj → N: noble > noblesa (-esa). N → N: ecologia > ecologisme (-isme, doctrina; -ista, qui la seguix)."},
      {"q": "En quina paraula el sufix -ment forma un nom i no un adverbi?", "o": ["coneixement", "clarament", "suaument"], "e": "Coneixement (V → N), com pagament o naixement. Clarament i suaument són adverbis (Adj → Adv)."},
      {"q": "«Nedar» > «nedador»: quin canvi de categoria fa el sufix -dor?", "o": ["De verb a nom o adjectiu d'agent", "De nom a verb", "D'adjectiu a adverbi"], "e": "-dor/-dora designa qui fa l'acció: nedar > nedador, vendre > venedor."},
      {"q": "Quina sèrie d'adjectius derivats és correcta?", "o": ["perillós, llegible, bancari, musical", "perillable, llegiós, bancal, musicari", "perillari, llegidor, banquer, musicós"], "e": "N → Adj: perill > perillós (-ós), banc > bancari (-ari), música > musical (-al). V → Adj: llegir > llegible (-ble, possibilitat)."},
      {"q": "Quina sèrie de verbs derivats és correcta?", "o": ["purificar, pedalejar, modernitzar", "purejar, pedalitzar, modernificar", "puritzar, pedalificar, modernejar"], "e": "-ificar (pur > purificar), -ejar (pedal > pedalejar, groc > groguejar) i -itzar (modern > modernitzar) formen verbs a partir de noms o adjectius."},
      {"q": "Quin adverbi deriva de «boig»?", "o": ["bojament", "boigament", "bogement"], "e": "El sufix -ment s'afig al femení de l'adjectiu: boja > bojament, lenta > lentament (Adj → Adv)."},
      {"q": "Quin parell mostra que un prefix, normalment, NO canvia la categoria?", "o": ["fer > desfer (verb > verb)", "feliç > felicitat (adjectiu > nom)", "ràpid > ràpidament (adjectiu > adverbi)"], "e": "Els sufixos determinen la categoria; els prefixos solen aportar només un matís (des- 'acció contrària')."},
      {"q": "Qui ven peix en una parada del mercat?", "o": ["el peixater", "el peixista", "el peixador"], "e": "Peix + -ater: peixater, peixatera (com sabata > sabater amb -er). La botiga és la peixateria."},
      {"q": "Un «homenàs» és...", "o": ["un home molt gran i corpulent", "un home menut", "un home molt vell"], "e": "-às/-assa és augmentatiu: homenàs, manassa, cotxàs. El diminutiu és -et/-eta: homenet."},
      {"q": "Quina sèrie conté només diminutius?", "o": ["caseta, gatet, carreró", "manassa, homenàs, cotxàs", "fusteria, peixateria, sabateria"], "e": "-et/-eta és el diminutiu per excel·lència; -ó/-ona també ho és (carrer > carreró). -às/-assa és augmentatiu i -eria forma noms de botiga o ofici."},
      {"q": "Feliç + -itat dona...", "o": ["felicitat", "feliçitat", "felissitat"], "e": "Davant de e, i, la ç passa a c: feliç > felicitat, capaç > capacitat, dolç > dolcesa."},
      {"q": "Quin és el nom derivat de «boig» amb el sufix -eria?", "o": ["bogeria", "boigeria", "bojeria"], "e": "La terminació -ig passa a g davant de e, i: boig > bogeria, roig > rogenc; i a j davant de a, o: boja, rojor."},
      {"q": "Quin és el femení de «gos»?", "o": ["gossa", "gosa", "goça"], "e": "La s sorda entre vocals s'escriu ss: gos > gossa, gros > grossa, nas > nassut."},
      {"q": "Quin adjectiu en -enc vol dir 'que tira a groc'?", "o": ["groguenc", "grocenc", "grogenc"], "e": "La c final passa a gu davant de e, i: groc > groguenc, groguejar; amic > amiguet."},
      {"q": "Quin és el verb derivat de «passeig»?", "o": ["passejar", "passeigar", "passeixar"], "e": "La terminació -ig passa a j davant de a, o: passeig > passejar, boig > boja."},
      {"q": "Quin derivat de «ric» està ben escrit?", "o": ["riquesa", "ricesa", "riqesa"], "e": "Davant de e, i, la c sona [s]; per a mantindre el so [k] s'escriu qu: ric > riquesa, sec > sequera."},
      {"q": "Quines formes resulten d'unir re- + fer i re- + emprendre?", "o": ["refer, reemprendre", "re-fer, re-emprendre", "reffer, remprendre"], "e": "Els prefixos s'escriuen soldats a la base: refer, reemprendre, reescriure (es mantenen les dues e)."},
      {"q": "Quines formes resulten d'unir des- + fer i in- + possible?", "o": ["desfer, impossible", "dessfer, inpossible", "des-fer, in-possible"], "e": "Des- es solda sense canvis (desfer, desobeir); in- es convertix en im- davant de p, b, m: impossible, imbatible, immòbil."},
      {"q": "En derivar «música» > «musical», què passa amb l'accent?", "o": ["La síl·laba tònica passa al sufix i la u perd l'accent gràfic", "La u continua sent tònica: «músical»", "Es manté l'accent gràfic i se n'afig un altre"], "e": "Molts sufixos són tònics i desplacen l'accent: música > musical, útil > utilitzar."},
      {"q": "Quin verb es relaciona amb «càrrec»?", "o": ["carregar", "càrregar", "carrecar"], "e": "En el verb, la síl·laba tònica és la terminació -ar: carregar (i la c passa a g)."},
      {"q": "Quina forma derivada de «telèfon» està ben escrita?", "o": ["telefonar", "telèfonar", "telefónar"], "e": "La tònica passa a -ar i desapareix l'accent: telèfon > telefonar, telefonista."},
      {"q": "Quin derivat de «àtom» està ben accentuat?", "o": ["atòmic", "àtomic", "atomíc"], "e": "Amb el sufix àton -ic la tònica és la síl·laba anterior: àtom > atòmic (amb o oberta)."},
      {"q": "Quin adverbi en -ment està ben escrit?", "o": ["fàcilment", "facilment", "facílment"], "e": "Els adverbis en -ment conserven l'accent gràfic de l'adjectiu: fàcil > fàcilment, ràpid > ràpidament."},
      {"q": "«Història» > «historiador»: per què el derivat no porta accent?", "o": ["Perquè la síl·laba tònica ha passat al sufix -dor", "Perquè els noms d'ofici no porten mai accent", "Perquè és una paraula composta"], "e": "El sufix -dor és tònic: historiador és aguda acabada en r i no s'accentua."},
      {"q": "Quin és el plural de «construcció»?", "o": ["construccions", "construcciós", "construcciones"], "e": "Els noms en -ció fan el plural en -cions: construcció > construccions."},
      {"q": "Quina forma femenina és correcta?", "o": ["la taxista", "la taxistessa", "la taxistera"], "e": "El sufix -ista serveix per als dos gèneres: el taxista, la taxista (en masculí també s'admet taxiste). Plural: taxistes."},
      {"q": "Quin és el femení plural de «bancari»?", "o": ["bancàries", "bancaries", "bancàrias"], "e": "-ari, -ària, -aris, -àries: les dades bancàries."},
      {"q": "Quin és el plural masculí de «capaç»?", "o": ["capaços", "capaçs", "capacs"], "e": "Els adjectius en -ç fan el plural en -ços: capaç > capaços, feliç > feliços."},
      {"q": "Quin és el femení plural de «groguenc»?", "o": ["groguenques", "groguencas", "grogenques"], "e": "-enc, -enca, -encs, -enques: fulles groguenques (c > qu davant de e)."},
      {"q": "Quin adjectiu derivat té la mateixa forma en masculí i en femení?", "o": ["amable", "perillós", "treballador"], "e": "Els adjectius en -ble i en -al són invariables en gènere: un home amable, una dona amable."},
      {"q": "Escriu el nom derivat de «boig» amb el sufix -eria.", "a": ["bogeria"], "e": "Boig > bogeria: -ig passa a g davant de e."},
      {"q": "Escriu l'adjectiu contrari de «legal» format amb el prefix in-.", "a": ["il·legal", "il.legal"], "e": "In- es convertix en il- davant de l: il·legal, il·lògic."},
      {"q": "Escriu el contrari de «real» format amb el prefix in-.", "a": ["irreal"], "e": "In- es convertix en ir- davant de r: irreal, irresponsable."},
      {"q": "Escriu el verb derivat de «telèfon».", "a": ["telefonar"], "e": "La tònica passa a la terminació i desapareix l'accent: telefonar."},
      {"q": "Escriu el plural de «homenàs».", "a": ["homenassos"], "e": "-às fa el plural -assos: homenàs > homenassos (com nas > nassos)."}
    ]
  },
  {
    "id": "93d1e2a5-5431-5bcb-833d-91f1fdbdcbe7", "type": "b2_lex_composicio", "sort_order": 9,
    "title": "Formació del lèxic: composició", "name": "Compostos soldats, amb guionet, sintagmàtics i cultes; ortografia i plural",
    "content": "La composició com a procediment de creació lèxica i les classes de compostos: soldats, amb guionet, sintagmàtics i cultes, amb la grafia i el plural que els correspon (3.2.3).", "icon": "🧱", "color": "#FFE0B2",
    "exercises": [
      {"q": "La composició consistix a...", "o": ["unir dues o més paraules o arrels per a formar-ne una de nova", "afegir un prefix o un sufix a una paraula", "canviar el gènere o el nombre d'una paraula"], "e": "Compost: gira + sol > gira-sol; ull + de + poll > ull de poll. Si s'afig un afix, és derivació (forner)."},
      {"q": "Quina d'estes paraules és composta?", "o": ["gratacel", "fusteria", "desfer"], "e": "Gratacel = grata + cel. Fusteria (sufix -eria) i desfer (prefix des-) són derivades."},
      {"q": "Quina d'estes paraules NO és composta?", "o": ["fornera", "rodamon", "aiguardent"], "e": "Fornera és derivada (forn + -era). Rodamon (roda + món) i aiguardent (aigua + ardent) són compostos."},
      {"q": "«Rodamon» està format per...", "o": ["verb + nom (roda + món)", "nom + adjectiu", "prefix + nom"], "e": "Rodamon: persona que roda pel món. En soldar-se, món perd l'accent diacrític: rodamon."},
      {"q": "«Aiguardent» està format per...", "o": ["nom + adjectiu (aigua + ardent)", "verb + nom", "adjectiu + adjectiu"], "e": "Aiguardent: beguda alcohòlica, literalment 'aigua ardent'. S'escriu soldat."},
      {"q": "«Agredolç» està format per...", "o": ["adjectiu + adjectiu (agre + dolç)", "nom + nom", "verb + adjectiu"], "e": "Compost coordinant d'adjectius: agredolç, sordmut ('sord i mut alhora')."},
      {"q": "Un «parallamps» és...", "o": ["un aparell que para els llamps", "un tipus de llamp", "una persona que té por dels llamps"], "e": "En els compostos verb + nom, el nom és com el complement directe del verb: para (els) llamps, torca (les) mans."},
      {"q": "Quin gènere tenen normalment els compostos de verb + nom com «rentaplats» o «paraigua»?", "o": ["masculí: el rentaplats, el paraigua", "femení: la rentaplats, la paraigua", "depén del nom: la paraigua, perquè aigua és femení"], "e": "Els compostos verb + nom solen ser masculins: el paraigua, el gratacel, el trencaclosques."},
      {"q": "Com s'escriu el compost de «grata» + «cel» (edifici molt alt)?", "o": ["gratacel", "grata-cel", "grata cel"], "e": "Gratacel s'escriu soldat: la c inicial del segon element no altera la lectura."},
      {"q": "Quina grafia és correcta per a 'persona que va pel món sense residència fixa'?", "o": ["rodamon", "roda-món", "rodamón"], "e": "Rodamon, soldat i sense accent: les paraules amb accent diacrític el perden quan es fusionen (rodamon, adeu, repel)."},
      {"q": "Com s'escriu el compost de «escura» + «dents»?", "o": ["escuradents", "escura-dents", "escura dents"], "e": "Escuradents s'escriu soldat: el segon element comença per d i no hi ha cap problema de lectura."},
      {"q": "Com s'escriu el nom del joc de peces que cal encaixar?", "o": ["trencaclosques", "trenca-closques", "trenca closques"], "e": "Trencaclosques, soldat, com rentaplats, llevataps o salvavides."},
      {"q": "Quina grafia és correcta del compost de «mal» + «de» + «cap» quan vol dir 'preocupació'?", "o": ["maldecap", "mal-de-cap", "mal de-cap"], "e": "Maldecap (soldat) és una preocupació: «Este fill em dona molts maldecaps». En canvi, el mal de cap (separat) és el dolor físic."},
      {"q": "Com s'escriu el nom de l'ofici de qui neteja xemeneies?", "o": ["escura-xemeneies", "escuraxemeneies", "escura xemeneies"], "e": "Porten guionet els compostos en què el primer element acaba en vocal i el segon comença per r, s o x: escura-xemeneies, para-sol, gira-sol."},
      {"q": "Com s'escriu l'objecte que ens protegix del sol a la platja?", "o": ["para-sol", "parasol", "para sol"], "e": "Para-sol: si s'escrivira soldat, la s quedaria entre vocals i es llegiria sonora."},
      {"q": "Com s'escriu el nom de la planta de flors grogues que es giren cap al sol?", "o": ["gira-sol", "girasol", "gira sol"], "e": "Gira-sol, amb guionet: vocal final + s inicial."},
      {"q": "Com s'escriu el nom de la peça del cotxe que esmorteïx els xocs?", "o": ["para-xocs", "paraxocs", "para xocs"], "e": "Para-xocs, amb guionet: el segon element comença per x i el primer acaba en vocal."},
      {"q": "Per què «para-sol» porta guionet i «paraigua» no?", "o": ["Perquè, soldat, «parasol» es llegiria amb s sonora", "Perquè «sol» és un nom propi", "Perquè «para-sol» és femení"], "e": "El guionet evita una lectura incorrecta quan el segon element comença per r, s o x. Paraigua no té este problema."},
      {"q": "Com s'escriu el punt cardinal situat entre el nord i l'est?", "o": ["nord-est", "nordest", "nord est"], "e": "Porten guionet els compostos en què el primer element és un punt cardinal: nord-est, sud-oest, nord-oest, sud-est."},
      {"q": "Quina grafia de l'adjectiu és correcta?", "o": ["nord-americà", "nordamericà", "nord americà"], "e": "Nord-americà, sud-americà: el primer element és un punt cardinal."},
      {"q": "Com s'escriu el número 23 en lletres?", "o": ["vint-i-tres", "vint i tres", "vintitres"], "e": "Els numerals porten guionet entre desenes i unitats: vint-i-tres, trenta-dos, setanta-huit."},
      {"q": "Com s'escriu el número 200 en lletres?", "o": ["dos-cents", "doscents", "dos cents"], "e": "També porten guionet les centenes: dos-cents, tres-centes, huit-cents."},
      {"q": "Quin compost està MAL escrit?", "o": ["renta-plats", "para-sol", "sud-est"], "e": "S'escriu rentaplats, soldat: la p inicial no altera la lectura. Para-sol i sud-est sí que porten guionet."},
      {"q": "Quina sèrie està ben escrita?", "o": ["gira-sol, gratacel, sud-est", "girasol, grata-cel, sudest", "gira-sol, grata-cel, sud est"], "e": "Gira-sol (vocal + s), gratacel (soldat) i sud-est (punt cardinal)."},
      {"q": "Quin d'estos és un compost sintagmàtic (paraules separades amb un significat unitari)?", "o": ["ull de poll", "gratacel", "para-sol"], "e": "Els compostos sintagmàtics tenen forma de sintagma: ull de poll, tauleta de nit, màquina d'escriure."},
      {"q": "Què és un «ull de poll»?", "o": ["una durícia dolorosa en un dit del peu", "un ou de gallina menut", "una finestra redona"], "e": "Ull de poll: compost sintagmàtic amb un significat que no és la suma dels seus elements."},
      {"q": "En quina frase hi ha un compost sintagmàtic?", "o": ["Este cap de setmana anirem a la muntanya.", "El cap li fa mal des d'ahir.", "Ha pintat una taula de fusta."], "e": "Cap de setmana és un compost fixat. «Taula de fusta» és un sintagma lliure: podem dir «taula de fusta i ferro»."},
      {"q": "Quin és el plural de «cap de setmana»?", "o": ["caps de setmana", "cap de setmanes", "caps de setmanes"], "e": "En els compostos sintagmàtics de nom + de + nom, el plural el pren el primer nom: caps de setmana, tauletes de nit."},
      {"q": "Quin és el plural de «mal de cap» (dolor)?", "o": ["mals de cap", "mal de caps", "mals de caps"], "e": "Mal de cap > mals de cap. No s'ha de confondre amb maldecap > maldecaps ('preocupacions')."},
      {"q": "Què vol dir «lluna de mel»?", "o": ["el viatge dels nuvis després de casar-se", "unes postres fetes amb mel", "una fase de la lluna"], "e": "Compost sintagmàtic lexicalitzat: el significat no és la suma de lluna + mel."},
      {"q": "Què significa l'element culte hidro- (hidroelèctric, hidroteràpia)?", "o": ["aigua", "terra", "llum"], "e": "Hidro- 'aigua': hidroavió, hidroteràpia."},
      {"q": "Què significa l'element culte -logia (biologia, geologia)?", "o": ["estudi, ciència", "por", "escriptura"], "e": "-logia 'estudi': geologia és l'estudi de la Terra. La por és -fòbia i l'escriptura, -grafia."},
      {"q": "Què significa -fon en «telèfon», «micròfon» i «megàfon»?", "o": ["so, veu", "llum", "lluny"], "e": "-fon 'so': el micròfon capta sons menuts i el megàfon els fa grans."},
      {"q": "Què significa bio- en «biologia» i «biografia»?", "o": ["vida", "llibre", "terra"], "e": "Bio- 'vida': la biografia és l'escrit sobre la vida d'algú."},
      {"q": "Què significa tele- en «telescopi» i «telecontrol»?", "o": ["lluny, a distància", "imatge", "veure"], "e": "Tele- 'a distància'. També funciona com a forma de «televisió»: telenotícies."},
      {"q": "Què significa auto- en «autobiografia» i «autoestima»?", "o": ["un mateix, per si mateix", "cotxe", "nou"], "e": "Auto- 'per si mateix': l'autobiografia és la biografia escrita per la mateixa persona."},
      {"q": "Què significa -cràcia en «democràcia» i «aristocràcia»?", "o": ["poder, govern", "ciutat", "poble"], "e": "-cràcia 'poder': democràcia és el poder (-cràcia) del poble (demo-)."},
      {"q": "Quin és el plural de «paraigua»?", "o": ["paraigües", "paraiguas", "paraiguës"], "e": "El plural dels compostos soldats es marca al final: paraigua > paraigües (gu > gü davant de e)."},
      {"q": "Quin és el plural de «gira-sol»?", "o": ["gira-sols", "gires-sols", "gira-sol (invariable)"], "e": "Compostos soldats o amb guionet: el plural el porta el segon element (gira-sols, cama-roges, altaveus)."},
      {"q": "Quin és el plural de «escuradents»?", "o": ["escuradents (invariable)", "escuradentses", "escuradentes"], "e": "Els compostos que ja acaben en -s són invariables: un escuradents, dos escuradents; un rentaplats, dos rentaplats."},
      {"q": "Escriu en lletres el número 32.", "a": ["trenta-dos"], "e": "Guionet entre desenes i unitats: trenta-dos."},
      {"q": "Escriu el punt cardinal situat entre el nord i l'oest.", "a": ["nord-oest", "el nord-oest"], "e": "Nord-oest, amb guionet, com tots els compostos de punt cardinal."},
      {"q": "Escriu el plural de «paraigua».", "a": ["paraigües"], "e": "Paraigua > paraigües, amb dièresi."},
      {"q": "Escriu el plural de «tauleta de nit».", "a": ["tauletes de nit"], "e": "En els compostos sintagmàtics el plural el pren el primer nom: tauletes de nit."},
      {"q": "Escriu el compost culte acabat en -logia que designa la ciència que estudia els éssers vius.", "a": ["biologia", "la biologia"], "e": "Bio- 'vida' + -logia 'estudi'."}
    ]
  },
  {
    "id": "9b274632-821b-5d84-9e4d-f97cfc546f12", "type": "b2_lex_locucions", "sort_order": 10,
    "title": "Locucions i frases fetes", "name": "Significat i ús de locucions genuïnes i alternatives als calcs",
    "content": "Locucions i frases fetes d'ús freqüent en valencià: què volen dir, com es completen i quines formes genuïnes cal usar en lloc de calcs del castellà (3.2.3).", "icon": "💬", "color": "#F8BBD0",
    "exercises": [
      {"q": "«Ahir va ploure a bots i barrals.» Què vol dir?", "o": ["Que va ploure moltíssim", "Que va ploure a estones", "Que només va plovisquejar"], "e": "Ploure a bots i barrals: ploure molt fort i en abundància."},
      {"q": "«Tinc la mosca darrere l'orella.» Què vol dir?", "o": ["Que sospite alguna cosa", "Que estic molt content", "Que no sent bé"], "e": "Tindre la mosca darrere l'orella: estar amb recel, sospitar que passa alguna cosa."},
      {"q": "«El fill de la veïna és més llarg que un dia sense pa.» Com és?", "o": ["Molt alt", "Molt avorrit", "Molt menjador"], "e": "Ser més llarg que un dia sense pa: ser molt alt (o fer-se molt llarg)."},
      {"q": "«Se'n va anar la llum i vam eixir de la cova a les palpentes.» Com vam eixir?", "o": ["Tocant amb les mans per a orientar-nos, sense vore-hi", "Corrent a tota velocitat", "Cridant per a demanar ajuda"], "e": "A les palpentes (o a la palpa, a palp): ajudant-se de les mans en lloc dels ulls."},
      {"q": "«No té remei: sempre ho fa tot a correcuita.» Com ho fa?", "o": ["De pressa, precipitadament", "Amb molta calma", "Amb molta cura"], "e": "A correcuita (o amb presses i corruixes): precipitadament, ràpidament."},
      {"q": "«Obriu les finestres de bat a bat.» Com s'han d'obrir?", "o": ["Del tot", "Una miqueta", "A poc a poc"], "e": "De bat a bat: completament obert. També en sentit figurat: obrir el cor de bat a bat."},
      {"q": "«Sempre parla a la babalà i després se'n penedix.» Com parla?", "o": ["Sense pensar el que diu", "Molt a poc a poc", "En veu molt baixa"], "e": "A la babalà: irreflexivament, sense posar-hi l'atenció necessària."},
      {"q": "«Li vaig preguntar pels diners que em devia i es va fer el suec.» Què va fer?", "o": ["Fer veure que no entenia", "Enfadar-se molt", "Tornar-me'ls de seguida"], "e": "Fer-se el suec: fer-se el desentés, fingir que no s'entén una cosa."},
      {"q": "«Esta setmana vaig de bòlit: no tinc temps de res.» Com estic?", "o": ["Molt enfeinat i atrafegat", "Molt avorrit", "De vacances"], "e": "Anar de bòlit: anar molt atrafegat, sense parar."},
      {"q": "«Ja és hora de posar fil a l'agulla.» Què vol dir?", "o": ["Començar una faena", "Cosir un botó", "Deixar una cosa per a després"], "e": "Posar fil a l'agulla: començar a fer allò que s'ha de fer."},
      {"q": "«En la boda van tirar la casa per la finestra.» Què van fer?", "o": ["Gastar molt, sense mirar prim", "Barallar-se", "Mudar-se de casa"], "e": "Tirar la casa per la finestra: gastar molts diners en una celebració."},
      {"q": "«Per voler ajudar tothom, s'ha ficat en un embolic.» Què li ha passat?", "o": ["S'ha posat en una situació complicada", "S'ha amagat", "Ha guanyat molts diners"], "e": "Ficar-se en un embolic: posar-se en un problema o una situació difícil."},
      {"q": "«A final de mes no tinc ni un clau.» Què vol dir?", "o": ["Que no tinc gens de diners", "Que no tinc eines", "Que no tinc faena"], "e": "No tindre ni un clau: estar sense diners."},
      {"q": "«Es passa el dia criticant a tort i a dret.» Com critica?", "o": ["Sense mirar si té raó i sense reflexionar", "Només quan té raó", "Amb molta prudència"], "e": "A tort i a dret: sense mirar si és amb raó o sense, sense reflexió."},
      {"q": "«El teatre estava de gom a gom.» Com estava?", "o": ["Completament ple", "Mig buit", "Tancat"], "e": "De gom a gom (o a gom): completament ple."},
      {"q": "«Mentre tots treballàvem, ell estava amb les mans plegades.» Què feia?", "o": ["No feia res", "Ajudava els altres", "Resava"], "e": "Estar amb les mans plegades: no fer res, estar inactiu."},
      {"q": "«Quan va vore la nota es va quedar de pedra.» Com es va quedar?", "o": ["Molt sorprés, paralitzat", "Molt tranquil", "Molt cansat"], "e": "Quedar-se de pedra: quedar-se parat per la sorpresa."},
      {"q": "«Deixa de fer el préssec, que tothom ens mira.» Què li demanen?", "o": ["Que deixe de fer el ximple", "Que deixe de menjar fruita", "Que deixe de treballar"], "e": "Fer el préssec: fer el ximple, fer el ridícul."},
      {"q": "«Hui la meitat de la classe ha fet campana.» Què han fet?", "o": ["No anar a classe sense justificació", "Tocar les campanes", "Fer molt de soroll"], "e": "Fer campana: faltar a classe sense permís."},
      {"q": "«Este cotxe m'ha costat un ull de la cara.» Què vol dir?", "o": ["Que ha sigut molt car", "Que ha sigut un regal", "Que m'ha fet mal als ulls"], "e": "Costar un ull de la cara: ser molt car."},
      {"q": "«Han ordenat l'habitació en un tres i no res.» Com ho han fet?", "o": ["En un moment, molt de pressa", "En tres dies", "Molt malament"], "e": "En un tres i no res (o en un alé, en un arrap): en un instant."},
      {"q": "«Ací qui talla el bacallà és la iaia.» Què vol dir?", "o": ["Que és qui mana", "Que és qui cuina", "Que és qui compra"], "e": "Tallar el bacallà: ser qui mana o qui pren les decisions."},
      {"q": "«Ha fet mans i mànegues per a aconseguir la beca.» Què ha fet?", "o": ["Tot el que ha pogut", "Res de res", "Trampes"], "e": "Fer mans i mànegues: fer tot el possible per a aconseguir una cosa."},
      {"q": "«No té pèls a la llengua.» Com és?", "o": ["Diu les coses clares, sense embuts", "Parla molt poc", "Parla molt mal el valencià"], "e": "No tindre pèls a la llengua: dir el que pensa sense callar res."},
      {"q": "«En tota la reunió no va dir ni ase ni bèstia.» Què va fer?", "o": ["No va dir res", "Va insultar tothom", "Va parlar d'animals"], "e": "No dir ni ase ni bèstia: no dir res, callar."},
      {"q": "«Va eixir de la festa a la francesa.» Com se'n va anar?", "o": ["Sense acomiadar-se", "Molt elegant", "Parlant francés"], "e": "Anar-se'n a la francesa: anar-se'n sense dir adéu."},
      {"q": "«Després de l'accident, ara li furten la cartera: plou sobre banyat.» Què vol dir?", "o": ["Que una desgràcia s'afig a una altra", "Que fa mal temps", "Que la cosa millora"], "e": "Ploure sobre banyat: arribar un mal damunt d'un altre."},
      {"q": "«No m'escoltes: sempre estàs en els núvols.» Com està?", "o": ["Distret", "Enfadat", "Molt content"], "e": "Estar en els núvols: estar distret, absent."},
      {"q": "«T'ho he explicat fil per randa.» Com t'ho he explicat?", "o": ["Amb tots els detalls", "Molt per damunt", "Per escrit"], "e": "Fil per randa (o fil per agulla, amb pèls i senyals): detalladament."},
      {"q": "Completa la frase feta: «Ploure a bots i ___»", "o": ["barrals", "barrils", "bassals"], "e": "Ploure a bots i barrals: ploure moltíssim."},
      {"q": "Completa la frase feta: «Tirar la casa per ___»", "o": ["la finestra", "la porta", "el balcó"], "e": "Tirar la casa per la finestra: gastar sense mesura."},
      {"q": "Quina frase feta vol dir 'fer veure que no s'entén una cosa'?", "o": ["fer-se el suec", "fer el préssec", "fer campana"], "e": "Fer-se el suec: fer-se el desentés. Fer el préssec és fer el ximple."},
      {"q": "Quina expressió vol dir 'molt ple'?", "o": ["de gom a gom", "de bat a bat", "a tort i a dret"], "e": "De gom a gom: ple del tot. De bat a bat: obert del tot."},
      {"q": "Quina és la forma genuïna de «meter la pata»?", "o": ["ficar la pota", "ficar la pata", "posar la pata"], "e": "Ficar la pota: equivocar-se, fer una cosa inoportuna. *Pata és un castellanisme."},
      {"q": "Quina és la forma genuïna de «tomar el pelo»?", "o": ["prendre el pèl", "tomar el pèl", "agarrar el pèl"], "e": "Prendre el pèl a algú: burlar-se'n. *Tomar és un castellanisme."},
      {"q": "Quina és la forma genuïna de «dar la lata»?", "o": ["donar la llanda", "donar la lata", "fer la lata"], "e": "Donar la llanda: molestar, importunar algú amb insistència."},
      {"q": "Quina frase és correcta?", "o": ["No me n'havia adonat.", "No m'havia donat compte.", "No m'havia dat compte."], "e": "*Donar-se compte és un calc de «darse cuenta»: la forma genuïna és adonar-se (d'una cosa)."},
      {"q": "Quina és la forma genuïna de «estar hasta las narices»?", "o": ["estar fins al capdamunt", "estar fins a les narices", "estar fins al nariu"], "e": "Estar fins al capdamunt: estar molt cansat o fart d'una situació."},
      {"q": "Quina frase és correcta en un registre formal?", "o": ["Quant a la reunió, encara no sabem la data.", "En quant a la reunió, encara no sabem la data.", "En cuant a la reunió, encara no sabem la data."], "e": "La locució és quant a (o pel que fa a, respecte a). *En quant a és un calc."},
      {"q": "Quina és la forma genuïna de «tomar el sol»?", "o": ["prendre el sol", "tomar el sol", "tomar-se el sol"], "e": "Prendre el sol. *Tomar és un castellanisme."},
      {"q": "Completa la frase feta: «El pavelló estava ple de ___ a ___.»", "a": ["gom a gom"], "e": "De gom a gom: completament ple."},
      {"q": "Completa: «Ha vingut el sol i hem obert les finestres de ___ a ___.»", "a": ["bat a bat"], "e": "De bat a bat: completament obert."},
      {"q": "Completa la frase feta: «Tinc la ___ darrere l'orella.»", "a": ["mosca"], "e": "Tindre la mosca darrere l'orella: sospitar."},
      {"q": "Completa la frase feta: «A final de mes no tinc ni un ___.»", "a": ["clau"], "e": "No tindre ni un clau: no tindre diners."},
      {"q": "Completa amb la forma genuïna: «No ens vam ___ de l'error fins a l'endemà.»", "a": ["adonar"], "e": "Adonar-se d'una cosa; no *donar-se compte."}
    ]
  },
  {
    "id": "2ae111ee-e340-5bfb-9349-c69770426432", "type": "b2_lex_polisemia", "sort_order": 11,
    "title": "Polisèmia i homonímia", "name": "Paraules amb diversos significats, homògrafs, homòfons i parònims",
    "content": "La polisèmia i l'homonímia dins de la precisió lèxica: paraules amb més d'un significat, homògrafs i homòfons, accent diacrític, parònims i desambiguació pel context (3.2.3).", "icon": "🔀", "color": "#D1C4E9",
    "exercises": [
      {"q": "Una paraula polisèmica és una paraula que...", "o": ["té diversos significats relacionats entre si", "s'escriu igual que una altra d'origen diferent", "té el mateix significat que una altra"], "e": "Polisèmia: una sola paraula amb diversos sentits emparentats. Coll: part del cos, part de l'ampolla, pas entre muntanyes."},
      {"q": "Dues paraules homònimes són...", "o": ["paraules diferents, sense relació de significat, que s'escriuen o es pronuncien igual", "paraules de significat contrari", "paraules de la mateixa família lèxica"], "e": "Homonímia: coincidència formal casual. Sou (salari) i sou (del verb ser) no tenen res a vore."},
      {"q": "Quina diferència hi ha entre homògrafs i homòfons?", "o": ["Els homògrafs s'escriuen igual; els homòfons sonen igual, encara que es puguen escriure diferent", "No hi ha cap diferència", "Els homòfons s'escriuen igual però sonen sempre diferent"], "e": "Homògrafs: deu (número) / deu (verb). Homòfons: compte / comte, que sonen igual i s'escriuen diferent."},
      {"q": "Quina parella és un cas de polisèmia i no d'homonímia?", "o": ["coll (del cos) i coll (de l'ampolla)", "sou (salari) i sou (verb ser)", "llima (fruita) i llima (eina)"], "e": "El coll de l'ampolla rep el nom per semblança amb el coll del cos: és la mateixa paraula amb un sentit ampliat."},
      {"q": "En quina frase «fulla» NO vol dir 'part d'una planta'?", "o": ["La fulla del ganivet està rovellada.", "A la tardor cauen les fulles.", "Les fulles de la parra fan ombra."], "e": "La fulla del ganivet és la part que talla: un altre sentit de la mateixa paraula."},
      {"q": "«He tret diners del banc.» Quin significat té «banc» en esta frase?", "o": ["entitat financera", "seient llarg", "grup de peixos"], "e": "Banc: seient, entitat financera, banc de peixos, banc de sang... El context desfà l'ambigüitat."},
      {"q": "En «un banc de sardines», «banc» vol dir...", "o": ["un grup nombrós de peixos que naden junts", "un seient per a pescadors", "una entitat que guarda diners"], "e": "Banc de peixos: conjunt de peixos que es desplacen junts."},
      {"q": "En quina frase «coll» vol dir 'pas estret entre muntanyes'?", "o": ["Vam creuar el coll amb la bicicleta.", "Porta una bufanda al coll.", "El coll de la camisa està brut."], "e": "El coll d'una muntanya és el pas més baix entre dos cims."},
      {"q": "En «el cap del departament», «cap» significa...", "o": ["la persona que mana", "la part superior del cos", "l'extrem d'una corda"], "e": "Cap: part del cos, persona que dirigix, extrem (el cap del carrer), punta de terra que entra en la mar (el cap de la Nau)."},
      {"q": "En quina frase «cap» és un determinant i no un nom?", "o": ["No hi ha cap cadira lliure.", "Em fa mal el cap.", "Hem arribat al cap del carrer."], "e": "Cap determinant ('ningun, ninguna') no té relació de significat amb el cap del cos."},
      {"q": "«Escriu amb una ploma estilogràfica.» Què és ací la «ploma»?", "o": ["Un instrument per a escriure amb tinta", "La peça que cobrix el cos dels ocells", "Un objecte molt lleuger"], "e": "La ploma d'escriure rep el nom de les plomes d'ocell que s'usaven antigament."},
      {"q": "En quina frase «ratolí» té el significat informàtic?", "o": ["Fes clic amb el botó dret del ratolí.", "El gat ha caçat un ratolí.", "Hi ha un ratolí davall del rebost."], "e": "El ratolí de l'ordinador s'anomena així per la semblança amb l'animal."},
      {"q": "Quin d'estos significats NO té la paraula «xarxa»?", "o": ["moble per a guardar la roba", "teixit de malles per a pescar", "conjunt de línies, carreteres o ordinadors connectats"], "e": "Xarxa: ormeig de pesca, xarxa de carreteres, xarxa informàtica, xarxes socials."},
      {"q": "«Per a canviar la roda necessites el gat.» Què és ací un «gat»?", "o": ["Un aparell per a alçar el cotxe", "Un animal domèstic", "Una clau per a descargolar"], "e": "Gat: animal i també aparell per a alçar pesos (gat hidràulic)."},
      {"q": "En «viu en la tercera planta», «planta» significa...", "o": ["pis d'un edifici", "vegetal", "part de baix del peu"], "e": "Planta: vegetal, pis d'un edifici, planta del peu, fàbrica (planta industrial)."},
      {"q": "Quina frase usa «estació» amb el sentit de 'part de l'any'?", "o": ["La primavera és l'estació que més m'agrada.", "El tren arriba a l'estació a les huit.", "Han obert una estació de servei."], "e": "Estació: període de l'any, parada de tren o autobús, establiment (estació de servei)."},
      {"q": "En quina frase «llengua» vol dir 'idioma'?", "o": ["Parla tres llengües estrangeres.", "M'he mossegat la llengua.", "El metge m'ha mirat la llengua."], "e": "Llengua: òrgan de la boca i sistema de comunicació d'una comunitat."},
      {"q": "En quina frase «taula» NO designa un moble?", "o": ["Estudia la taula del set per a l'examen.", "Para la taula, que anem a dinar.", "Hem comprat una taula de fusta."], "e": "La taula de multiplicar és un quadre de dades: un altre sentit de taula."},
      {"q": "«El pianista ha tocat una peça de Bach» i «Al motor li falta una peça»: «peça» és...", "o": ["una paraula polisèmica: 'obra musical' i 'element d'un conjunt'", "dos homònims d'origen diferent", "un barbarisme"], "e": "Peça té diversos sentits relacionats: part d'un conjunt, obra artística, peça de roba..."},
      {"q": "«S'ha acabat la pila del rellotge.» Què és ací la «pila»?", "o": ["Un generador elèctric menut", "Un munt de coses posades una damunt de l'altra", "Un recipient d'aigua"], "e": "El context (el rellotge) indica que es tracta de la bateria."},
      {"q": "Quina diferència hi ha entre «la llum» i «el llum»?", "o": ["La llum és la claredat; el llum és l'aparell que fa llum", "Són sinònims totals", "El llum és la claredat; la llum, l'aparell"], "e": "El gènere distingix els dos sentits: la llum del sol / encén el llum de la tauleta."},
      {"q": "«Hem comprat ___ nou per al menjador: una làmpada de peu.»", "o": ["un llum", "una llum", "uns llum"], "e": "L'aparell és masculí: el llum, un llum."},
      {"q": "«Ho ha fet amb un fi molt clar» i «la fi de la pel·lícula»: què significa cada «fi»?", "o": ["El fi: finalitat; la fi: final", "El fi: final; la fi: finalitat", "Tots dos signifiquen 'final'"], "e": "El fi és el propòsit (amb el fi de...); la fi és l'acabament (la fi del món). El gènere distingix els dos sentits."},
      {"q": "En quina frase «deu» és un nom que vol dir 'font natural d'aigua'?", "o": ["A la muntanya hi ha una deu d'aigua fresca.", "Ma germana em deu diners.", "Tinc deu anys."], "e": "Deu: numeral (amb e oberta), forma del verb deure i nom 'font' (amb e tancada). Són homògrafs."},
      {"q": "«Em deu deu euros»: què és cada «deu»?", "o": ["El primer és el verb deure; el segon, un numeral", "Tots dos són numerals", "El primer és un numeral; el segon, el verb deure"], "e": "Homògrafs: deu (verb, e tancada) i deu (numeral, e oberta)."},
      {"q": "Quina frase porta bé l'accent diacrític?", "o": ["Ma mare m'ha donat la mà.", "Mà mare m'ha donat la ma.", "Ma mare m'ha donat la ma."], "e": "Mà (part del cos) porta accent diacrític; ma (possessiu: ma mare) no."},
      {"q": "«Hem vist un ___ bru a la muntanya» (l'animal). Quina grafia recomana la normativa actual?", "o": ["os", "òs", "hos"], "e": "L'AVL ja no exigix accent diacrític: os (animal, o tancada) i os (de l'esquelet, o oberta) s'escriuen igual. Són homògrafs, no homòfons."},
      {"q": "«El meu ___ ja té tres anys» (el fill del meu fill). Quina grafia és la normativa actual?", "o": ["net", "nèt", "neto"], "e": "Net (fill del fill, e tancada) i net (no brut, e oberta) s'escriuen igual: la normativa actual no hi posa accent diacrític."},
      {"q": "«Vosaltres sou molt treballadors i cobreu un bon sou»: quina relació hi ha entre els dos «sou»?", "o": ["Són homònims: un és el verb ser i l'altre, el salari", "És una paraula polisèmica", "Són sinònims"], "e": "Sou (verb) i sou (salari) s'escriuen i es pronuncien igual sense cap relació de significat."},
      {"q": "Completa: «Els xiquets tenen ___ perquè ja ___ les onze.»", "o": ["son / són", "són / son", "són / són"], "e": "Son (ganes de dormir) no porta accent; són (verb ser) porta accent diacrític."},
      {"q": "Completa: «La meua veïna ___ un ___ verd cada vesprada.»", "o": ["pren / te", "pren / té", "té / té"], "e": "Te (la infusió) no porta accent; té, amb accent, és la forma del verb tindre."},
      {"q": "Completa: «No ___ si ___ n'ha anat ja.»", "o": ["sé / se", "se / sé", "sé / sé"], "e": "Sé (verb saber) porta accent diacrític; se (pronom) no."},
      {"q": "En «Ma germana dona classes d'anglés», «dona» és...", "o": ["el verb donar, que s'escriu sense accent", "el nom dona (persona de sexe femení)", "un error: cal escriure «dóna»"], "e": "Dona (nom) i dona (verb donar) són homògrafs: la normativa actual no posa accent en el verb."},
      {"q": "«El cor de l'església canta» i «El cor bombeja la sang»: quina relació hi ha?", "o": ["Són homònims: tenen orígens diferents", "És un cas de polisèmia", "Són antònims"], "e": "Cor (òrgan) ve del llatí cor; cor (grup de cantants) ve del llatí chorus. Coincidixen per casualitat."},
      {"q": "«Llima» pot ser una fruita o una eina per a polir. Estes dues paraules són...", "o": ["homònimes, d'origen diferent", "antònimes", "parònimes"], "e": "La llima fruita i la llima eina tenen etimologies diferents: són homònims."},
      {"q": "Quina frase usa bé «actitud»?", "o": ["Té una actitud molt positiva davant els problemes.", "Té una actitud especial per a la música.", "Demà farem les proves d'actitud física."], "e": "Actitud: manera de comportar-se. Aptitud: capacitat per a fer una cosa (aptitud per a la música)."},
      {"q": "Completa: «Les seues paraules van tindre un gran ___ en el públic.»", "o": ["efecte", "afecte", "afectat"], "e": "Efecte: resultat, impressió. Afecte: estima. Són parònims."},
      {"q": "Completa: «Ves amb ___, que el ___ ens contarà un ___.»", "o": ["compte / comte / conte", "comte / compte / conte", "conte / comte / compte"], "e": "Compte (atenció), comte (títol nobiliari) i conte (narració). Compte i comte sonen igual: són homòfons."},
      {"q": "Quina frase usa bé «pressa» o «presa»?", "o": ["Vaig amb pressa perquè perdré el tren.", "Vaig amb presa perquè perdré el tren.", "Vaig amb preça perquè perdré el tren."], "e": "Pressa: urgència. Presa: acció de prendre, animal caçat o mur d'un pantà."},
      {"q": "Qui no respecta una llei la...", "o": ["infringix", "infligix", "afligix"], "e": "Infringir: no complir una norma. Infligir: imposar un càstig o causar un dany."},
      {"q": "Escriu el possessiu homòfon de «mà»: «___ germana viu a Gandia.»", "a": ["ma"], "e": "Ma (possessiu) sense accent; mà (part del cos) amb accent diacrític."},
      {"q": "Escriu la paraula homòfona de «comte» que vol dir 'atenció, cura'.", "a": ["compte"], "e": "Compte i comte sonen igual però s'escriuen diferent."},
      {"q": "Escriu l'article adequat: «Apaga ___ llum de la tauleta» (l'aparell).", "a": ["el"], "e": "El llum: l'aparell. La llum: la claredat."},
      {"q": "Escriu la forma del verb ser amb accent diacrític: «Estes cases ___ molt antigues.»", "a": ["són"], "e": "Són (verb) porta accent per a distingir-lo de son (ganes de dormir, possessiu)."},
      {"q": "Escriu el parònim de «actitud» que vol dir 'capacitat per a fer una cosa'.", "a": ["aptitud"], "e": "Aptitud: capacitat. Actitud: manera de comportar-se."}
    ]
  },
  {
    "id": "ceab52d7-4e08-5f72-a04d-68c9405eb712", "type": "b2_lex_barbarismes", "sort_order": 12,
    "title": "Barbarismes i alternatives genuïnes", "name": "Castellanismes i anglicismes freqüents i les formes correctes",
    "content": "Alternatives genuïnes als barbarismes més freqüents (castellanismes lèxics, connectors i anglicismes), sense confondre'ls amb paraules correctes que s'hi assemblen (3.2.3).", "icon": "🚫", "color": "#FFCDD2",
    "exercises": [
      {"q": "Quina interjecció és correcta per a tancar un tema?", "o": ["Bé, ja ho acabarem demà.", "Bueno, ja ho acabarem demà.", "Buenu, ja ho acabarem demà."], "e": "*Bueno és un castellanisme: com a interjecció diem bé (o bo, doncs bé)."},
      {"q": "Quina frase és correcta per a dir que un menjar té bon gust?", "o": ["Este arròs està molt bo.", "Este arròs està molt bueno.", "Este arròs està molt bon."], "e": "Bo (bona) és l'adjectiu; bon només va davant del nom (un bon arròs). *Bueno és un castellanisme."},
      {"q": "Quina resposta és correcta?", "o": ["—Quedem a les sis? —D'acord.", "—Quedem a les sis? —Vale.", "—Quedem a les sis? —Bale."], "e": "*Vale és un castellanisme: diem d'acord, entesos, conforme."},
      {"q": "«No m'ho havia dit ningú; ___ vaig pensar que era una broma.»", "o": ["aleshores", "entonces", "entons"], "e": "*Entonces és un castellanisme: aleshores, llavors, en aquell moment."},
      {"q": "«Dius que tens fred? ___ tanca la finestra.»", "o": ["Doncs", "Pues", "Pos"], "e": "*Pues és un castellanisme: doncs."},
      {"q": "«Ha estudiat molt; ___, no ha aprovat.»", "o": ["no obstant això", "sin embargo", "sinembargo"], "e": "*Sin embargo → no obstant això, tanmateix, però, així i tot."},
      {"q": "«És un treball molt complet i, ___, està molt ben escrit.»", "o": ["a més", "ademés", "amés"], "e": "*Ademés → a més (o a més a més)."},
      {"q": "«___ vindrà demà, però no n'estic segura.»", "o": ["Potser", "A lo millor", "A lo mejor"], "e": "*A lo millor és un calc; la forma genuïna és potser (o tal vegada)."},
      {"q": "«Primer dinarem i ___ anirem al cine.»", "o": ["després", "luego", "despuès"], "e": "*Luego → després, més tard. Després s'escriu amb accent tancat."},
      {"q": "«Ha d'eixir ___ les set, que el tren ix a les set i quart.»", "o": ["abans de", "antes de", "abants de"], "e": "*Antes → abans (de)."},
      {"q": "«No m'ha telefonat ___ per a felicitar-me.»", "o": ["ni tan sols", "ni siquiera", "ni sisquera"], "e": "*Ni siquiera → ni tan sols, ni així."},
      {"q": "«Necessitarem ___ tres hores per a acabar.»", "o": ["almenys", "por lo menys", "per lo menys"], "e": "*Por lo menys / *per lo menys → almenys, pel cap baix, si més no."},
      {"q": "«—Vindràs a la festa? —___!»", "o": ["Per descomptat", "Desde luego", "Des de luego"], "e": "*Desde luego → per descomptat, i tant, és clar."},
      {"q": "«Viu a València ___ 2010.»", "o": ["des de", "desde", "dende"], "e": "La preposició és des de, en dues paraules: des de 2010, des de casa."},
      {"q": "«Treballe de dilluns ___ divendres.»", "o": ["a", "hasta", "asta"], "e": "*Hasta → fins (a) o a: de dilluns a divendres, fins a les set."},
      {"q": "Quina frase evita el neutre «lo»?", "o": ["Això de la reunió no m'agrada gens.", "Lo de la reunió no m'agrada gens.", "Lu de la reunió no m'agrada gens."], "e": "L'article neutre *lo no és normatiu: això de, allò de, el que."},
      {"q": "Quina perífrasi d'obligació és correcta?", "o": ["Hem de presentar el treball demà.", "Tenim que presentar el treball demà.", "Hi ha que presentar el treball demà."], "e": "*Tindre que i *haver-hi que no són normatius: haver de, caldre, ser necessari."},
      {"q": "Quina pregunta és correcta?", "o": ["T'has assabentat de la notícia?", "T'has enterat de la notícia?", "T'has entrat de la notícia?"], "e": "*Enterar-se → assabentar-se, adonar-se'n."},
      {"q": "«Encara no m'he ___ de la notícia del tancament.»", "o": ["assabentat", "enterat", "enteirat"], "e": "*Enterar-se → assabentar-se: m'he assabentat de la notícia."},
      {"q": "«No arribe a ___ el pot de la lleixa de dalt.»", "o": ["abastar", "alcanzar", "alcantzar"], "e": "Abastar: arribar a agafar una cosa allunyada. També es pot dir arribar a."},
      {"q": "«Has d'___ este formulari amb les teues dades.»", "o": ["emplenar", "rellenar", "rellenyar"], "e": "*Rellenar → emplenar, omplir."},
      {"q": "«La rentadora s'ha ___ i no centrifuga.»", "o": ["espatllat", "estropejat", "estropiat"], "e": "*Estropejar → espatllar, fer malbé."},
      {"q": "«El vol s'ha ___ dues hores per la boira.»", "o": ["endarrerit", "retrassat", "retrasat"], "e": "*Retrassar → endarrerir, retardar."},
      {"q": "«—___, que el terra rellisca!»", "o": ["Compte", "Cuidado", "Cuidao"], "e": "*Cuidado! → compte!, alerta!, ves amb compte."},
      {"q": "Com es diu la persona que dirigix la teua faena?", "o": ["La meua cap m'ha donat el dia lliure.", "La meua jefa m'ha donat el dia lliure.", "La meua gefa m'ha donat el dia lliure."], "e": "*Jefe → cap, director, encarregat."},
      {"q": "En un formulari: «Nom i ___».", "o": ["cognoms", "apellidos", "apellits"], "e": "*Apellido → cognom."},
      {"q": "On tirem les cartes per a enviar-les?", "o": ["a la bústia", "al buzó", "al busó"], "e": "*Buzón → bústia."},
      {"q": "«Demà és el meu ___: faig trenta anys.»", "o": ["aniversari", "cumpleanys", "complianys"], "e": "*Cumpleaños → aniversari."},
      {"q": "«Esta carta necessita un ___ per a enviar-la.»", "o": ["segell", "sello", "selló"], "e": "*Sello → segell."},
      {"q": "«Els veïns es queixen del ___ que fa la discoteca.»", "o": ["soroll", "ruido", "ruïdo"], "e": "*Ruido → soroll, brogit, rebombori."},
      {"q": "«La inauguració del museu ha sigut tot un ___.»", "o": ["esdeveniment", "aconteixement", "acontecement"], "e": "*Acontecimiento → esdeveniment, succés, fet."},
      {"q": "Quina d'estes paraules NO és un barbarisme?", "o": ["buscar", "antes", "enterar-se"], "e": "Buscar és plenament correcte (també cercar). *Antes i *enterar-se són castellanismes: abans, assabentar-se."},
      {"q": "Quina d'estes paraules és correcta i NO s'ha de substituir?", "o": ["sobretot", "ademés", "desde"], "e": "Sobretot ('principalment') és un adverbi compost normatiu. *Ademés → a més; *desde → des de."},
      {"q": "En quina frase hi ha un barbarisme?", "o": ["Ademés, no tinc temps.", "Lleva't la jaqueta, que fa calor.", "Busca les claus al calaix."], "e": "Llevar ('traure') i buscar són formes correctes. *Ademés → a més."},
      {"q": "Quina expressió és correcta?", "o": ["un animal salvatge", "un animal salvaje", "un animal salvage"], "e": "Salvatge és la forma correcta (amb tg)."},
      {"q": "«T'envie l'___ de la pàgina web.»", "o": ["enllaç", "link", "linc"], "e": "Link → enllaç."},
      {"q": "Quina frase és més adequada en un text formal?", "o": ["Envia-m'ho per correu electrònic.", "Envia-m'ho per email.", "Envia-m'ho per mail."], "e": "En lloc de l'anglicisme, diem correu electrònic (o, simplement, correu)."},
      {"q": "«Per a entrar al compte has d'escriure la ___.»", "o": ["contrasenya", "password", "pasword"], "e": "Password → contrasenya."},
      {"q": "«Pots fer la matrícula ___, sense moure't de casa.»", "o": ["en línia", "online", "on line"], "e": "Online → en línia."},
      {"q": "«El meu ___ preferit és fer fotografies.»", "o": ["afició", "hobby", "jobi"], "e": "Hobby → afició, passatemps."},
      {"q": "Escriu la forma genuïna de «*enterar-se».", "a": ["assabentar-se", "assabentar-se'n"], "e": "Assabentar-se d'una cosa."},
      {"q": "Escriu correctament la preposició: «Treballa ací ___ fa tres anys.»", "a": ["des de"], "e": "Des de, en dues paraules. *Desde és un castellanisme."},
      {"q": "Escriu la forma genuïna de l'anglicisme «link».", "a": ["enllaç"], "e": "Enllaç: l'adreça que porta a una altra pàgina."},
      {"q": "Escriu la forma genuïna de «*ademés».", "a": ["a més", "a més a més"], "e": "A més o a més a més."},
      {"q": "Escriu la forma genuïna de «*apellido».", "a": ["cognom"], "e": "Cognom: nom de família."}
    ]
  },
  {
    "id": "5009b5ea-fb18-56db-b59b-111f420ec4ac", "type": "b2_lex_metafora", "sort_order": 13,
    "title": "Comparació, metàfora i metonímia", "name": "Mecanismes de creació lèxica: semblança, contigüitat i comparacions fixades",
    "content": "La comparació, la metàfora i la metonímia com a mecanismes de creació lèxica: metàfores lexicalitzades, metonímies de lloc, autor o contingut, comparacions fixades i adjectius d'ús figurat (3.2.3).", "icon": "🎭", "color": "#B3E5FC",
    "exercises": [
      {"q": "Què és una metàfora?", "o": ["Anomenar una realitat amb el nom d'una altra per una semblança entre totes dues", "Anomenar una realitat amb el nom d'una altra amb què té una relació de proximitat (lloc, autor, contingut...)", "Comparar dues realitats amb «com» o «més... que»"], "e": "Metàfora: semblança. La cama de la taula s'assembla a una cama; el ratolí de l'ordinador, a l'animal."},
      {"q": "Què és una metonímia?", "o": ["Anomenar una realitat amb el nom d'una altra amb què té una relació de proximitat o de causa", "Anomenar una realitat amb el nom d'una altra que s'hi assembla", "Dir el contrari del que es pensa"], "e": "Metonímia: contigüitat. Beure's un got (el recipient pel contingut), llegir Ausiàs March (l'autor per l'obra)."},
      {"q": "Quina diferència hi ha entre «Té els ulls com dos estels» i «Té dos estels a la cara»?", "o": ["La primera és una comparació (amb «com»); la segona, una metàfora", "Totes dues són metonímies", "La primera és una metàfora; la segona, una comparació"], "e": "La comparació explicita la relació amb un nexe (com, més... que); la metàfora la identifica directament."},
      {"q": "«La cama de la taula»: quin mecanisme hi ha?", "o": ["metàfora", "metonímia", "comparació"], "e": "El suport de la taula s'anomena cama (o pota) per semblança amb la cama d'una persona o un animal."},
      {"q": "Per què es diu «coll» a la part estreta de dalt d'una ampolla?", "o": ["Per semblança amb el coll del cos (metàfora)", "Perquè està al costat del tap (metonímia)", "Perquè és un derivat de «collir»"], "e": "Metàfora lexicalitzada: la forma recorda la del coll humà."},
      {"q": "«El peu de la muntanya» és...", "o": ["la part de baix de la muntanya", "un camí per a pujar-hi", "el cim"], "e": "Metàfora: la muntanya es veu com un cos, amb peu, falda i cim."},
      {"q": "Per què diem «ratolí» a l'aparell de l'ordinador?", "o": ["Per la semblança de forma amb l'animal (metàfora)", "Perquè el va inventar una persona que es deia així (metonímia)", "Perquè fa soroll com un ratolí (comparació)"], "e": "El cos menut i el cable, com una cua, recorden un ratolí."},
      {"q": "Quina d'estes expressions conté una metàfora lexicalitzada?", "o": ["la boca del metro", "la porta del metro", "el bitllet del metro"], "e": "L'entrada del metro s'anomena boca per semblança amb la boca del cos."},
      {"q": "«L'ull de l'agulla» és...", "o": ["el forat per on passa el fil", "la punta de l'agulla", "una malaltia de l'ull"], "e": "Metàfora: el forat de l'agulla recorda un ull."},
      {"q": "Quina d'estes expressions NO és una metàfora?", "o": ["beure's un got", "les dents de la serra", "la falda de la muntanya"], "e": "Beure's un got és una metonímia (el recipient pel contingut). Les altres es basen en una semblança."},
      {"q": "«Ser un llop de mar» vol dir...", "o": ["ser un mariner amb molta experiència", "ser una persona cruel", "tindre por del mar"], "e": "Metàfora lexicalitzada que aplica a una persona les qualitats d'un animal."},
      {"q": "«És una estrella del cine.» Quin mecanisme hi ha en «estrella»?", "o": ["metàfora: una persona famosa que brilla com un astre", "metonímia: el lloc per la persona", "comparació"], "e": "La persona famosa s'identifica amb un astre que brilla."},
      {"q": "«Ens va caure damunt una pluja de crítiques.» Què vol dir «pluja»?", "o": ["una gran quantitat (metàfora)", "aigua que cau del cel", "una tempesta real"], "e": "Metàfora de quantitat: pluja de crítiques, mar de dubtes, allau de gent."},
      {"q": "«M'he begut un got sencer.» Quin mecanisme hi ha?", "o": ["metonímia: el continent pel contingut", "metàfora: semblança de forma", "comparació"], "e": "No ens bevem el got, sinó el que conté: és una metonímia."},
      {"q": "«Estic llegint Ausiàs March.» Quin mecanisme hi ha?", "o": ["metonímia: l'autor per l'obra", "metàfora", "comparació"], "e": "Llegim els poemes d'Ausiàs March: l'autor designa la seua obra."},
      {"q": "«Per a celebrar-ho vam obrir un xampany.» Quin mecanisme hi ha?", "o": ["metonímia: el lloc d'origen pel producte", "metàfora", "sinonímia"], "e": "El nom de la regió (Xampanya) designa el vi que s'hi produïx, com un rioja o un priorat."},
      {"q": "Quina d'estes expressions és una metonímia de lloc d'origen pel producte?", "o": ["un rioja", "la cama de la taula", "més fort que un roure"], "e": "Un rioja és un vi de la Rioja: el lloc designa el producte."},
      {"q": "«La Moncloa ha anunciat noves mesures.» Qui les ha anunciades?", "o": ["El Govern d'Espanya (el lloc per la institució)", "Un palau buit", "Un periodista que es diu Moncloa"], "e": "Metonímia: la seu designa la institució, com la Casa Blanca o el Palau de la Generalitat."},
      {"q": "«La fàbrica necessita més mans.» Què vol dir «mans»?", "o": ["treballadors (la part pel tot)", "guants", "màquines"], "e": "Metonímia (sinècdoque): una part del cos designa la persona que treballa."},
      {"q": "«El violí primer ha arribat tard a l'assaig.» Qui ha arribat tard?", "o": ["El músic que toca el primer violí", "Un violí nou", "L'estoig del violí"], "e": "Metonímia: l'instrument designa qui el toca."},
      {"q": "«Al museu tenen un Sorolla.» Què tenen?", "o": ["un quadre pintat per Sorolla", "una foto de Sorolla", "un descendent de Sorolla"], "e": "Metonímia: el nom del pintor designa l'obra."},
      {"q": "«Tot el poble va eixir al carrer per a protestar.» Què vol dir «poble»?", "o": ["els habitants del poble (el lloc pels habitants)", "les cases del poble", "el carrer major"], "e": "Metonímia: el lloc designa les persones que hi viuen."},
      {"q": "«La corona ha inaugurat l'exposició.» Qui l'ha inaugurada?", "o": ["el rei o la reina (el símbol per qui el representa)", "una joia exposada", "un grup de músics"], "e": "Metonímia: la corona, símbol de la monarquia, designa el monarca."},
      {"q": "«La nadadora ha guanyat l'or en els cent metres.» Què ha guanyat?", "o": ["la medalla d'or (la matèria per l'objecte)", "un lingot d'or", "diners"], "e": "Metonímia: el material designa l'objecte fet amb ell."},
      {"q": "Quina d'estes frases conté una metonímia?", "o": ["Sempre escolta Mozart mentre estudia.", "Té un cor de pedra.", "Eixe xiquet és un llamp."], "e": "Escoltar Mozart: l'autor per l'obra. Les altres dues són metàfores (duresa, rapidesa)."},
      {"q": "Completa la comparació: «Està més content que un ___.»", "o": ["gínjol", "roure", "tronc"], "e": "Més content que un gínjol: molt alegre."},
      {"q": "Completa la comparació: «És fort com un ___.»", "o": ["roure", "gínjol", "tronc"], "e": "Fort com un roure (o més fort que un roure): molt fort i robust."},
      {"q": "«Està més content que un gínjol.» Com està?", "o": ["molt alegre", "molt cansat", "molt tranquil"], "e": "Comparació fixada d'ús molt freqüent."},
      {"q": "Quin mecanisme hi ha en «És més llarg que un dia sense pa»?", "o": ["una comparació fixada (amb «més... que»)", "una metonímia", "una metàfora sense nexe"], "e": "La comparació explicita els dos termes amb un nexe: més... que."},
      {"q": "«Aquell refrany és més vell que anar a peu.» Què vol dir?", "o": ["que és molt antic", "que és molt lent", "que no l'entén ningú"], "e": "Més vell que anar a peu: antiquíssim."},
      {"q": "«És lleig com un pecat.» Què vol dir?", "o": ["que és molt lleig", "que és molt dolent", "que és molt religiós"], "e": "Comparació fixada d'intensificació."},
      {"q": "Quina d'estes expressions NO és una comparació?", "o": ["Eixe xic és un ase.", "És més fort que un roure.", "Dorm com un tronc."], "e": "«És un ase» és una metàfora: no hi ha nexe comparatiu."},
      {"q": "«És una persona molt freda.» Què vol dir «freda»?", "o": ["que mostra poc afecte o emoció", "que té la temperatura del cos baixa", "que sempre té calor"], "e": "Ús metafòric: del sentit físic (temperatura) al psicològic (afecte)."},
      {"q": "En quina frase l'adjectiu «fred» té el sentit literal?", "o": ["L'aigua del riu està molt freda.", "Ens va fer una acollida molt freda.", "És una persona molt freda."], "e": "Només en la primera parla de temperatura; en les altres, de falta d'afecte."},
      {"q": "«Té una veu molt dolça.» Quin ús té l'adjectiu «dolça»?", "o": ["metafòric: agradable i suau", "literal: amb gust de sucre", "metonímic: el lloc per la veu"], "e": "Apliquem a un so una qualitat del gust: és un ús figurat."},
      {"q": "«Li va llançar una mirada glacial.» Com era la mirada?", "o": ["molt freda i hostil", "molt brillant", "molt trista"], "e": "Glacial ('de gel') s'usa metafòricament per a una actitud molt freda."},
      {"q": "«Té un cor de pedra.» Com és?", "o": ["insensible, sense compassió", "molt valent", "molt sa"], "e": "Metàfora: la duresa de la pedra s'aplica als sentiments."},
      {"q": "En «un paisatge tranquil», l'adjectiu atribuïx al paisatge una qualitat pròpia de...", "o": ["les persones (ús figurat)", "els colors", "els sons"], "e": "Tranquil descriu primer un estat d'ànim; aplicat a un lloc, és un ús figurat."},
      {"q": "Completa la comparació fixada: «Anit vaig dormir com un ___.»", "a": ["tronc", "soc"], "e": "Dormir com un tronc (o com un soc): dormir profundament."},
      {"q": "Escriu la part del cos que dona nom, per metàfora, a cada suport d'una taula: «la ___ de la taula».", "a": ["cama", "pota"], "e": "La cama o la pota de la taula."},
      {"q": "Quin mecanisme hi ha en «M'he menjat un plat de macarrons» → «M'he menjat un plat»: metàfora o metonímia?", "a": ["metonímia"], "e": "El recipient designa el contingut."},
      {"q": "Quin mecanisme hi ha en «el coll de l'ampolla»: metàfora o metonímia?", "a": ["metàfora"], "e": "Semblança de forma amb el coll del cos."},
      {"q": "Escriu el nom de l'animal que, per metàfora, designa l'aparell amb què movem el cursor de l'ordinador.", "a": ["ratolí", "el ratolí"], "e": "Ratolí: metàfora per semblança de forma."}
    ]
  },
  {
    "id": "41d8f8d5-19bf-5f21-a05a-fffc50741dca", "type": "b2_lex_sinonims_antonims", "sort_order": 14,
    "title": "Sinonímia i antonímia", "name": "Sinònims totals, parcials i de registre; antònims graduals, complementaris, recíprocs i per prefixació",
    "content": "La sinonímia i l'antonímia del llenguatge general: sinònims segons el context i el registre, i les classes d'antònims, inclosos els formats amb prefixos (3.2.3).", "icon": "⚖️", "color": "#C5CAE9",
    "exercises": [
      {"q": "Dos sinònims totals són paraules que...", "o": ["signifiquen el mateix i es poden intercanviar en tots els contextos", "tenen significats contraris", "s'escriuen igual i signifiquen coses diferents"], "e": "Els sinònims totals són escassos; la majoria són parcials i depenen del context o del registre."},
      {"q": "Quina parella és de sinònims pràcticament totals?", "o": ["cotxe / automòbil", "vell / antic", "fort / intens"], "e": "Cotxe i automòbil designen el mateix en quasi tots els contextos. Vell i antic, fort i intens, només en alguns."},
      {"q": "En quina frase «fort» es pot substituir per «intens»?", "o": ["Hui bufa un vent molt fort.", "És un home molt fort: alça cent quilos.", "Esta taula és molt forta: no es trencarà."], "e": "Sinonímia parcial: un vent fort o intens; però un home fort és robust i una taula forta, resistent."},
      {"q": "Quin sinònim de «fort» és el més adequat en «Té un argument molt fort»?", "o": ["sòlid", "musculós", "cridaner"], "e": "Un argument fort és un argument sòlid, convincent. Musculós només s'aplica a un cos."},
      {"q": "En «Ha deixat la faena per a cuidar sa mare», quin sinònim de «deixar» és adequat?", "o": ["abandonar", "prestar", "permetre"], "e": "Deixar és polisèmic: abandonar (deixar la faena), prestar (deixar un llibre), permetre (deixar fer)."},
      {"q": "En «Em deixes el llapis un moment?», «deixar» equival a...", "o": ["prestar", "abandonar", "oblidar"], "e": "Deixar una cosa a algú: prestar-la."},
      {"q": "Quin és un sinònim de «esbrinar»?", "o": ["indagar", "enganyar", "oblidar"], "e": "Esbrinar: descobrir una cosa investigant-la. Sinònims: indagar, investigar, descobrir."},
      {"q": "Quin és un sinònim de «enyorar»?", "o": ["trobar a faltar", "odiar", "oblidar"], "e": "Enyorar algú o alguna cosa: trobar-ne a faltar la presència."},
      {"q": "Quin és un sinònim de «enutjat»?", "o": ["enfadat", "content", "esgotat"], "e": "Enutjat, enfadat, empipat, molest."},
      {"q": "Quin és un sinònim de «gandul»?", "o": ["mandrós", "feiner", "generós"], "e": "Gandul i mandrós: que no té ganes de treballar."},
      {"q": "Quina parella NO és de sinònims?", "o": ["prompte / tard", "començar / iniciar", "acabar / finalitzar"], "e": "Prompte i tard són antònims."},
      {"q": "Quina expressió és la més formal per a dir que una persona ha mort?", "o": ["ha traspassat", "l'ha dinyada", "ha estirat la pota"], "e": "Traspassar és formal; dinyar-la i estirar la pota són col·loquials."},
      {"q": "Quin és un sinònim col·loquial de «diners»?", "o": ["calers", "capital", "pressupost"], "e": "Calers és col·loquial. Capital i pressupost són tècnics i no equivalen exactament a diners."},
      {"q": "En un document administratiu, quin sinònim de «casa» és adequat?", "o": ["domicili", "caseta", "cau"], "e": "Domicili és el terme formal: canvi de domicili."},
      {"q": "Quin és el sinònim culte de «cara»?", "o": ["rostre", "careta", "front"], "e": "Rostre pertany a un registre més culte; cara és l'habitual."},
      {"q": "En un text formal, com es pot dir «el pare i la mare»?", "o": ["els progenitors", "els padrins", "els avis"], "e": "Progenitors és el terme formal o tècnic."},
      {"q": "Quina frase té un registre col·loquial?", "o": ["Va tocar el dos sense dir res.", "Se'n va anar sense dir res.", "Va abandonar la sala sense dir res."], "e": "Tocar el dos ('anar-se'n') és col·loquial; abandonar la sala és més formal."},
      {"q": "«Calent / fred» són antònims graduals perquè...", "o": ["hi ha graus intermedis (tebi, fresc...)", "un exclou totalment l'altre sense punt mitjà", "un implica necessàriament l'altre"], "e": "Antònims graduals: admeten graus (més calent, molt fred) i termes intermedis."},
      {"q": "«Viu / mort» són antònims...", "o": ["complementaris: si no és viu, és mort", "graduals", "recíprocs"], "e": "Antònims complementaris: l'afirmació d'un implica la negació de l'altre, sense terme mitjà."},
      {"q": "«Comprar / vendre» són antònims...", "o": ["recíprocs: si jo et venc una cosa, tu me la compres", "graduals", "complementaris"], "e": "Antònims recíprocs: expressen la mateixa relació des de dos punts de vista."},
      {"q": "Quina parella és d'antònims recíprocs?", "o": ["mestre / alumne", "alt / baix", "aprovat / suspés"], "e": "Si algú és mestre, ha de tindre alumnes: un terme implica l'altre."},
      {"q": "Quina parella és d'antònims graduals?", "o": ["gran / xicotet", "present / absent", "donar / rebre"], "e": "Gran i xicotet admeten graus: mitjà, molt gran, una mica xicotet."},
      {"q": "Quina parella és d'antònims complementaris?", "o": ["aprovat / suspés", "calent / fred", "pare / fill"], "e": "Un examen o està aprovat o està suspés: no hi ha punt intermedi."},
      {"q": "Quina parella d'antònims NO admet graus intermedis?", "o": ["encés / apagat", "calent / fred", "car / barat"], "e": "Un llum està encés o apagat: són complementaris."},
      {"q": "«Donar / rebre» són antònims...", "o": ["recíprocs", "graduals", "complementaris"], "e": "Si jo et done una cosa, tu la reps: és la mateixa acció vista des dels dos participants."},
      {"q": "Quin és l'antònim de «possible» format amb prefix?", "o": ["impossible", "inpossible", "despossible"], "e": "In- es convertix en im- davant de p: impossible."},
      {"q": "Quin és l'antònim de «lligar»?", "o": ["deslligar", "inlligar", "antilligar"], "e": "Des- indica l'acció contrària: lligar / deslligar, fer / desfer."},
      {"q": "Quin és l'antònim de «fer» (una maleta, un nus)?", "o": ["desfer", "refer", "satisfer"], "e": "Desfer: fer l'acció contrària. Refer és tornar a fer."},
      {"q": "Quin és l'antònim de «regular» (adjectiu)?", "o": ["irregular", "inregular", "iregular"], "e": "In- es convertix en ir- davant de r: irregular, irreal, irresponsable."},
      {"q": "Quin és l'antònim de «lògic»?", "o": ["il·lògic", "inlògic", "ilògic"], "e": "In- es convertix en il- davant de l: il·lògic, il·legal."},
      {"q": "Quin és l'antònim de «típic» format amb el prefix a-?", "o": ["atípic", "intípic", "destípic"], "e": "A- (an- davant de vocal) indica negació: atípic, apolític, anormal."},
      {"q": "Quin és l'antònim de «connectar»?", "o": ["desconnectar", "inconnectar", "disconnectar"], "e": "Des- + connectar: desconnectar."},
      {"q": "Quin és l'antònim de «ordenat»?", "o": ["desordenat", "inordenat", "antiordenat"], "e": "Des- + ordenat: una habitació desordenada."},
      {"q": "Quin és l'antònim de «abundant»?", "o": ["escàs", "ampli", "copiós"], "e": "Abundant / escàs. Copiós és sinònim d'abundant."},
      {"q": "Quin és l'antònim de «avançar»?", "o": ["retrocedir", "progressar", "accelerar"], "e": "Avançar / retrocedir (o recular)."},
      {"q": "Quin és l'antònim de «dur» en «un pa dur»?", "o": ["tou", "fort", "sec"], "e": "Pa dur / pa tou."},
      {"q": "En «un vi sec», quin és l'antònim adequat de «sec»?", "o": ["dolç", "humit", "mullat"], "e": "L'antònim depén del context: un vi sec / un vi dolç; la roba seca / la roba mullada."},
      {"q": "En «la roba ja està seca», quin és l'antònim adequat de «sec»?", "o": ["mullat", "dolç", "suau"], "e": "Roba seca / roba mullada (o humida)."},
      {"q": "Quin és l'antònim de «aprovar» un examen?", "o": ["suspendre", "repetir", "estudiar"], "e": "Aprovar / suspendre són antònims complementaris."},
      {"q": "Escriu l'antònim recíproc de «comprar».", "a": ["vendre"], "e": "Comprar / vendre: antònims recíprocs."},
      {"q": "Escriu l'antònim de «cobrir» format amb el prefix des-.", "a": ["descobrir"], "e": "Des- + cobrir: descobrir."},
      {"q": "Escriu l'antònim de «responsable» format amb prefix.", "a": ["irresponsable"], "e": "In- > ir- davant de r: irresponsable."},
      {"q": "Escriu l'antònim de «tou» en «un llit tou».", "a": ["dur"], "e": "Llit tou / llit dur."},
      {"q": "Escriu un sinònim de «començar» acabat en -ar.", "a": ["iniciar", "principiar", "encetar"], "e": "Iniciar (més formal), principiar, encetar."}
    ]
  },
  {
    "id": "b2313894-3796-58e9-9c5f-0db9e828bf3d", "type": "b2_lex_relacions_textuals", "sort_order": 15,
    "title": "Relacions lexicosemàntiques textuals", "name": "Hiperonímia, camps semàntics, famílies lèxiques, part i tot, i cohesió lèxica",
    "content": "Les relacions lexicosemàntiques bàsiques en els textos: hiperònims i hipònims, camps semàntics i famílies lèxiques, relacions de part i tot, i els mecanismes de cohesió lèxica per a evitar repeticions (3.2.3).", "icon": "🕸️", "color": "#B2DFDB",
    "exercises": [
      {"q": "Què és un hiperònim?", "o": ["Una paraula de significat general que inclou altres més concretes (moble → cadira)", "Una paraula de significat contrari", "Una part d'un tot"], "e": "L'hiperònim inclou els hipònims: moble és hiperònim de cadira, taula i armari."},
      {"q": "Quin és l'hiperònim de «martell, tornavís i alicates»?", "o": ["eines", "mobles", "estris de cuina"], "e": "Martell, tornavís i alicates són hipònims d'eina (cohipònims entre si)."},
      {"q": "Quin és l'hiperònim de «violí, flauta i piano»?", "o": ["instruments musicals", "orquestres", "cançons"], "e": "Són tipus d'instruments musicals."},
      {"q": "Quin és l'hiperònim de «granís, boira i neu»?", "o": ["fenòmens meteorològics", "estacions de l'any", "paisatges"], "e": "Granís, boira i neu són fenòmens meteorològics."},
      {"q": "Quin és l'hiperònim de «passaport, DNI i carnet de conduir»?", "o": ["documents", "llibres", "títols universitaris"], "e": "Tots són documents d'identificació o d'acreditació."},
      {"q": "Quina paraula és hipònim de «moble»?", "o": ["armari", "casa", "fusta"], "e": "Un armari és un tipus de moble. La fusta és el material i la casa, el lloc."},
      {"q": "Quina paraula és hipònim de «hortalissa»?", "o": ["carxofa", "poma", "arròs"], "e": "La carxofa és una hortalissa; la poma és una fruita i l'arròs, un cereal."},
      {"q": "Quin d'estos animals NO és un hipònim de «au»?", "o": ["ratpenat", "merla", "falcó"], "e": "El ratpenat vola, però és un mamífer."},
      {"q": "«Sardina, lluç i tonyina» són cohipònims de...", "o": ["peix", "marisc", "mar"], "e": "Cohipònims: paraules que compartixen el mateix hiperònim."},
      {"q": "Quina sèrie va del més general al més específic?", "o": ["ésser viu → animal → mamífer → gos", "gos → mamífer → animal → ésser viu", "animal → gos → mamífer → ésser viu"], "e": "Cada terme és hiperònim del següent."},
      {"q": "Què és una família lèxica?", "o": ["El conjunt de paraules que compartixen la mateixa arrel (terra, enterrar, terrestre)", "El conjunt de paraules d'un mateix tema (escola, pissarra, mestre)", "Un grup de paraules amb el mateix significat"], "e": "Família lèxica: mateixa arrel. Camp semàntic: mateix àmbit de significat."},
      {"q": "Què és un camp semàntic?", "o": ["El conjunt de paraules relacionades pel significat dins d'un mateix àmbit", "El conjunt de paraules que tenen la mateixa arrel", "El conjunt de paraules que rimen"], "e": "Metge, infermera, ambulància i recepta formen part del camp semàntic de la sanitat."},
      {"q": "Quina paraula NO és de la família lèxica de «terra»?", "o": ["terrible", "enterrar", "terrestre"], "e": "Terrible ve de terror, no de terra. Enterrar, terrestre, terratrémol i soterrani sí que en són."},
      {"q": "Quina paraula NO és de la família lèxica de «mar»?", "o": ["marró", "mariner", "marítim"], "e": "Marró no té relació amb mar. Mariner, marítim, marí o submarí sí."},
      {"q": "Quina paraula NO és de la família lèxica de «llum»?", "o": ["lluny", "il·luminar", "lluminós"], "e": "Lluny no té relació amb llum. Il·luminar, lluminós i enllumenat sí."},
      {"q": "Quina paraula NO pertany al camp semàntic de l'escola?", "o": ["aixada", "pissarra", "matrícula"], "e": "L'aixada és una eina del camp."},
      {"q": "«Metge, infermera, ambulància, recepta» formen...", "o": ["un camp semàntic (la sanitat)", "una família lèxica", "una sèrie de sinònims"], "e": "Són paraules d'un mateix àmbit però amb arrels diferents."},
      {"q": "«Pa, panet, panera, empanada» formen...", "o": ["una família lèxica", "un camp semàntic", "una sèrie d'antònims"], "e": "Totes compartixen l'arrel pa(n)-."},
      {"q": "La relació entre «roda» i «cotxe» és de...", "o": ["part / tot (meronímia)", "hiponímia", "sinonímia"], "e": "La roda és una part del cotxe: roda és merònim de cotxe i cotxe, holònim de roda."},
      {"q": "Quina parella expressa una relació de part / tot?", "o": ["pàgina / llibre", "poma / fruita", "gos / animal"], "e": "La pàgina és part del llibre. Poma / fruita i gos / animal són relacions d'hiponímia."},
      {"q": "«Dit» és un merònim de...", "o": ["mà", "ungla", "anell"], "e": "El dit és part de la mà; l'ungla és part del dit."},
      {"q": "«Arbre» és l'holònim (el tot) de...", "o": ["branca, arrel i fulla", "pi, olivera i taronger", "bosc, prat i muntanya"], "e": "Branca, arrel i fulla són parts de l'arbre. Pi, olivera i taronger són hipònims d'arbre."},
      {"q": "Quin mecanisme de cohesió hi ha en «Va comprar un cotxe de segona mà. Les rodes ja estaven gastades»?", "o": ["Meronímia: les rodes són part del cotxe", "Sinonímia", "Repetició"], "e": "Les rodes es poden presentar com a informació coneguda perquè formen part del cotxe."},
      {"q": "«Joanot Martorell va escriure el Tirant lo Blanc. ___ va morir abans que l'obra s'imprimira.»", "o": ["L'autor valencià", "El llibre", "La novel·la"], "e": "Una expressió equivalent reprén el referent sense repetir el nom."},
      {"q": "«El president va visitar ahir la fàbrica. ___ va anunciar noves ajudes per al sector.»", "o": ["El cap de l'executiu", "L'empresa", "El treballador"], "e": "Substitució per una expressió equivalent: el president → el cap de l'executiu."},
      {"q": "«La Lluna tarda unes quatre setmanes a fer una volta a la Terra. ___ sempre ens mostra la mateixa cara.»", "o": ["El nostre satèl·lit", "El planeta roig", "L'astre rei"], "e": "El nostre satèl·lit = la Lluna. El planeta roig és Mart i l'astre rei, el Sol."},
      {"q": "«Ma tia s'ha comprat un gos. ___ es diu Nero i és molt jugador.»", "o": ["L'animal", "La bèstia salvatge", "El gat"], "e": "Hiperònim: animal reprén gos sense repetir-lo."},
      {"q": "«Va comprar pomes, peres i plàtans, i va guardar ___ al frigorífic.»", "o": ["la fruita", "les verdures", "els congelats"], "e": "Un hiperònim recull tots els elements enumerats."},
      {"q": "«Ens van demanar que tancàrem la porta, però no ___ vam fer.»", "o": ["ho", "la", "el"], "e": "El pronom neutre ho reprén tota l'acció anterior (tancar la porta)."},
      {"q": "«Ha suspés tres assignatures. ___ preocupa molt els seus pares.»", "o": ["Això", "Aquell", "Esta"], "e": "El demostratiu neutre això reprén tot el contingut de la frase anterior."},
      {"q": "«Han augmentat els accidents en esta carretera. ___ ha obligat a posar-hi més radars.»", "o": ["Este fet", "Esta carretera", "Este radar"], "e": "Les proformes el fet, la qüestió, l'assumpte resumixen una idea anterior."},
      {"q": "En un registre col·loquial: «Ahir vam discutir amb el veí. Al final, ___ va acabar bé.»", "o": ["la cosa", "la persona", "el veí"], "e": "La cosa és una proforma col·loquial que reprén la situació (la discussió)."},
      {"q": "«El metge va examinar el malalt. Després, ___ li va receptar un antibiòtic.»", "o": ["el doctor", "el pacient", "l'hospital"], "e": "Sinonímia: el metge → el doctor."},
      {"q": "«Els alumnes van presentar el treball. ___ el van defendre molt bé davant del tribunal.»", "o": ["Els estudiants", "Els professors", "Els treballs"], "e": "Sinonímia: alumnes → estudiants."},
      {"q": "Quin mecanisme de cohesió hi ha en «He llegit una novel·la de Rodoreda. El llibre m'ha agradat molt»?", "o": ["Hiperonímia: llibre és més general que novel·la", "Antonímia", "Meronímia"], "e": "Novel·la és un tipus de llibre: el text la reprén amb un hiperònim."},
      {"q": "Quina és la millor manera d'evitar la repetició en «Els bombers van arribar de seguida. Els bombers van apagar el foc en una hora»?", "o": ["Els bombers van arribar de seguida i van apagar el foc en una hora.", "Els bombers van arribar de seguida. Ells els van apagar el foc en una hora.", "Van arribar de seguida. Els bombers el van apagar-lo en una hora."], "e": "El subjecte compartit pot quedar implícit en la segona oració coordinada."},
      {"q": "«Mart és conegut com ___, pel color de la superfície.»", "o": ["el planeta roig", "l'astre rei", "el nostre satèl·lit"], "e": "Expressió equivalent per a referir-se a Mart en un text."},
      {"q": "«El Sol és una estrella mitjana. ___ ens proporciona llum i calor.»", "o": ["L'astre rei", "El planeta blau", "El satèl·lit"], "e": "L'astre rei és una expressió equivalent per a referir-se al Sol."},
      {"q": "Quin hiperònim reprén millor «la pomera, el taronger i l'olivera» en un text?", "o": ["els arbres", "les fruites", "els boscos"], "e": "Pomera, taronger i olivera són arbres; les fruites són pomes, taronges i olives."},
      {"q": "Escriu l'hiperònim de «cadira, armari i taula».", "a": ["mobles", "moble", "els mobles"], "e": "Moble: hiperònim de cadira, armari, taula..."},
      {"q": "Escriu el pronom neutre que falta: «Volia anar a la festa, però no ___ vaig poder fer.»", "a": ["ho"], "e": "Ho reprén l'acció d'anar a la festa."},
      {"q": "Escriu el tot del qual «branca» és una part.", "a": ["arbre", "l'arbre"], "e": "Branca és merònim d'arbre."},
      {"q": "Escriu un nom de la família lèxica de «mar» que designe la persona que treballa en un vaixell.", "a": ["mariner", "marinera"], "e": "Mar → mariner."},
      {"q": "Escriu l'hiperònim de «rosa, clavell i gesmil».", "a": ["flors", "flor", "les flors"], "e": "Rosa, clavell i gesmil són flors."}
    ]
  }
]$data$::jsonb) AS t(
  id uuid, type text, sort_order smallint, title text, name text,
  content text, icon text, color text, exercises jsonb
);

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
SELECT id, name, type, 'lexic_semantica', content, 'B2', 15, sort_order,
       jsonb_build_object('icon', icon, 'color', color, 'section_name', title)
FROM practice_catalog
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  difficulty = EXCLUDED.difficulty,
  xp_earned = EXCLUDED.xp_earned,
  sort_order = EXCLUDED.sort_order,
  -- Conserva la lliçó fixa («Aprendre lliçó»), si una migració posterior n'hi afig.
  metadata = EXCLUDED.metadata || jsonb_strip_nulls(jsonb_build_object('lesson', resources.metadata -> 'lesson'));

DELETE FROM public.practice_exercises e
USING practice_catalog c
WHERE e.resource_id = c.id AND e.level = 'B2';

INSERT INTO public.practice_exercises (resource_id, level, position, kind, prompt, options, answers, explanation)
SELECT c.id, 'B2', x.ord,
       CASE WHEN x.e ? 'a' THEN 'fill' ELSE 'choice' END,
       x.e->>'q',
       CASE WHEN x.e ? 'o' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'o')) END,
       CASE WHEN x.e ? 'a' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'a')) ELSE ARRAY[x.e->'o'->>0] END,
       x.e->>'e'
FROM practice_catalog c
CROSS JOIN LATERAL jsonb_array_elements(c.exercises) WITH ORDINALITY AS x(e, ord);

DROP TABLE practice_catalog;

-- ============================================================
-- Origen: 20261013140000_llicons_fonetica_b2.sql
-- ============================================================
-- Lliçons fixes de Fonètica, elocució i ortografia del B2 (botó «Aprendre lliçó»).
-- Com les del B1 (20261001180000), cada lliçó és una adaptació didàctica de nivell B2
-- redactada a partir de:
--   - l'abast de cada contingut del B2 (Quadern B2 de la JQCV, 3.2.1), descrit en
--     20261013110000_practice_fonetica_b2.sql;
--   - les regles d'Ortologia i Ortografia de la GVB i la GNV de l'AVL, descarregades
--     una sola vegada en assets-src/avl/ (gvb.html i gnv.html).
-- El contingut es guarda en metadata.lesson (mateix format que en el B1). La migració de
-- continguts (20261013110000) conserva metadata.lesson si es torna a aplicar.
-- Tornar a aplicar este fitxer no canvia res més.

UPDATE public.resources r SET
  metadata = coalesce(r.metadata, '{}'::jsonb) || jsonb_build_object('lesson', l.lesson)
FROM jsonb_to_recordset($data$[
  {"type": "b2_fon_elocucio", "lesson": {"intro": "Aprendràs com s'enllacen les paraules en la parla, quan les consonants finals sonen sordes o sonores, quines lletres no es pronuncien i com s'articulen amb claredat les vocals i els grups consonàntics de l'estàndard.", "blocks": [{"title": "Vocals en contacte: una síl·laba o elisió", "text": "Entre paraules, dos vocals en contacte es poden pronunciar **en una sola síl·laba** sense perdre'n cap (*no ho sé*, *espera un moment*) o amb **elisió** d'una d'elles: sobretot si són iguals (*una aigua*, *no oblides*) o si la primera és una *-a* o *-e* àtones (*mitja hora*, *este home*). La *h* és muda i no impedix el contacte. Per escrit, l'elisió **només** es marca amb apòstrof en l'article, la preposició *de* i alguns pronoms febles.", "table": {"head": ["escrius", "pronuncies"], "rows": [["*mitja hora*", "[miʤɔ́ɾa]"], ["*este home*", "[estɔ́me]"], ["*una escala*", "[unaskála]"], ["*no ho sé*", "[nów sé]"]]}, "examples": ["Escrius *una amiga*, però *l'amiga* i *d'aigua*."]}, {"title": "Consonants finals: sordes o sonores", "text": "En final de paraula, *b/p*, *d/t*, *g/c* sonen **sordes** davant de pausa, de vocal o de consonant sorda: *fred* [fɾét], *club animat* [klúp]. Les fricatives i africades (*s*, *ç*, *-ix*, *ig*, *tx*) són sordes davant de pausa, però **sonores davant de vocal** o de consonant sonora: *pes atòmic* [péz], *roig encés* [rɔ́ʤ]. La *-t* de *-nt* es manté davant de vocal: *sant Antoni*, *vint hòmens*.", "table": {"head": ["context", "exemple", "so final"], "rows": [["pausa", "*braç*, *roig*", "[s], [ʧ]"], ["vocal", "*braç esquerre*, *despatx obert*", "[z], [ʤ]"], ["consonant sonora", "*club d'amics*, *peix blau*", "[b], [ʒ]"], ["consonant sorda", "*sac ple*, *peix cru*", "[k], [ʃ]"]]}}, {"title": "Lletres que no sonen", "text": "La *h* és **muda** (*ahir*, *harmonia*). La *p* de *mp* en síl·laba medial no sona: *compte*, *prompte*, *símptoma*. Tampoc sonen la primera consonant de *ps-*, *gn-*, *pn-* inicials (*psiquiatre*, *gnom*, *pneumàtic*) ni la primera *n* de *nn* (*connectar*). L'emmudiment de *mp/mb*, *nt/nd*, *lt/ld* finals (*camp*, *rumb*, *molt*) és **acceptable** on és propi, i més general en plural: *camps*, *fonts*.", "watch": [{"wrong": "*quant és* pronunciat [kwànés]", "right": "*quant és* [kwánt és], amb la *t*"}]}, {"title": "Set vocals tòniques, cinc àtones", "text": "En posició tònica el valencià té **set vocals**, amb *e* i *o* obertes i tancades que distingixen paraules (*set* número / *set* de beure; *dona* / *dona* del verb). En posició àtona en té **cinc** (*a*, *e*, *i*, *o*, *u*), que cal articular clarament: *pare* no és *para*. Atenció: *què*, *perquè*, *València*, *època* i *sèrie* porten accent greu però es pronuncien amb *e* **tancada**.", "table": {"head": ["no recomanable", "pronunciació estàndard"], "rows": [["*deixar* [diʃáɾ]", "amb *e*"], ["*juliol* [ʤoliɔ́l]", "amb *u*"], ["*paciència* [pasɛ́nsia]", "amb la *i*"]]}, "examples": ["Són **acceptables** on són propis *pilota* [pilɔ́tɔ], *cosir* [kuzíɾ] o *caixa* [káʃa]."]}, {"title": "La x i els grups consonàntics", "text": "La *x* sona [ks] entre vocals i davant de consonant sorda (*màxim*, *explosió*), però [gz] en *ex-* inicial seguit de vocal o *h*: *examen*, *exacte*, *exhortar*. El dígraf *tz* sona [dz]: *dotze*, no [dóʤe]. La *l·l* i la *tll* es pronuncien **simples** (*il·lusió*, *bitllet*); la geminada és pròpia de registres molt formals. En *arbre* i *marbre* la primera *r* es pot pronunciar o no.", "watch": [{"wrong": "*exacte* pronunciat [eksákte]", "right": "*exacte*, amb [gz]"}, {"wrong": "*problema* pronunciat [pobléma]", "right": "*problema*, amb la *r*"}]}, {"title": "Palatals finals: coll, juny, roig", "text": "La *ny* representa [ɲ] **en totes les posicions**, també al final: *juny*, *lluny*, *codony*. La *ll* final és lateral palatal: pronunciar-la com una *i* (*coll* [kɔ́j]) **no és recomanable**. Així distingim *fill* / *fil*, *coll* / *col*. Els finals *ig* i *tx* sonen [ʧ]: *maig*, *roig*, *despatx*.", "examples": ["S'ha fet mal al **coll** i no pot girar el cap.", "Viu molt **lluny** i ve cada **juny**."]}], "remember": ["Entre paraules les vocals es fusionen o s'elidixen, però l'apòstrof només va en *l'*, *d'* i pronoms.", "Consonants finals: sordes davant de pausa; *s*, *ç*, *ig*, *tx*, sonores davant de vocal.", "*H* muda; la *p* de *compte* i *prompte* no sona.", "Set vocals tòniques i cinc àtones; *què* i *perquè* tenen *e* tancada.", "*Exacte* [gz], *dotze* [dz], *coll* amb *ll*, mai [j]."], "sources": [{"gram": "GVB", "section": "3.1", "title": "Vocals en contacte", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=vocals_en_contacte"}, {"gram": "GVB", "section": "10.1", "title": "Introducció", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=apostrofacio"}, {"gram": "GNV", "section": "1.2.1.2", "title": "Criteris generals de pronunciació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=vocals_toniques"}, {"gram": "GNV", "section": "1.2.1.3", "title": "La distribució de la e i la o obertes", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=1_2_1_3"}, {"gram": "GNV", "section": "1.2.2.3", "title": "Criteris particulars de pronunciació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=vocals_atones"}, {"gram": "GNV", "section": "1.3.2.1", "title": "Les consonants oclusives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=1_3_2_1"}, {"gram": "GNV", "section": "1.3.2.3", "title": "Les consonants sibilants alveolars", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=1_3_2_3"}, {"gram": "GNV", "section": "1.3.2.5", "title": "Les consonants laterals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=consonants_laterals"}, {"gram": "GNV", "section": "1.3.2.6", "title": "Les consonants ròtiques", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=consonants_rotiques"}, {"gram": "GNV", "section": "1.3.2.7", "title": "Les consonants nasals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=1_3_2_7"}, {"gram": "GNV", "section": "1.4.1", "title": "Vocals en contacte", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=vocals_en_contacte"}, {"gram": "GNV", "section": "1.4.2.1", "title": "Les consonants oclusives en posició final", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=consonants_oclusives_posicio_final"}, {"gram": "GNV", "section": "1.4.2.2", "title": "Les consonants fricatives i africades en posició final", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=1_4_2_2"}, {"gram": "GNV", "section": "4.8", "title": "La representació del grup fònic [ks]", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_grup_fonic_ks"}, {"gram": "GNV", "section": "4.12", "title": "Les grafies m, n, mp, tm i tn", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=grafies_m_n_mp_tm_tn"}, {"gram": "GNV", "section": "4.13", "title": "La grafia ny", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=grafia_ny"}, {"gram": "GNV", "section": "4.17", "title": "La grafia h", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=grafia_h"}]}},
  {"type": "b2_fon_alfabet", "lesson": {"intro": "Aprendràs a mantindre el so quan una paraula canvia de forma (*caçar*/*caces*, *pagar*/*pague*, *viatjar*/*viatgem*), a triar entre *x*, *tx*, *ig*, *z* i *tz*, i a distingir dígrafs de lletres compostes.", "blocks": [{"title": "La ç i la c: el mateix so", "text": "El so [s] s'escriu ***ç*** davant de *a*, *o*, *u* i **en final de paraula**, i ***c*** davant de *e*, *i*. Per això, quan una paraula canvia de forma, la *ç* i la *c* **alternen** per a mantindre el so.", "table": {"head": ["amb ç", "amb c"], "rows": [["*caçar*, *caçador*", "*caces*, *cace*"], ["*començar*", "*comences*, *comence*"], ["*plaça*", "*placeta*"], ["*feliç*, *feliços*", "*felicitat*"]]}, "watch": [{"wrong": "Vull que comenzes ara.", "right": "Vull que comences ara."}]}, {"title": "c/qu, g/gu i la ü", "text": "Davant de *e*, *i*, el so [k] s'escriu ***qu*** i el so [g], ***gu***: la *u* no sona i forma un **dígraf**. Si la *u* sí que sona davant de *e*, *i*, porta **dièresi**: *qüestió*, *llengües*. Davant d'un diftong creixent s'escriu *q*: *quota*, *qualsevol*.", "table": {"head": ["base", "forma amb e, i"], "rows": [["*tocar*", "*toque*, *toques*"], ["*pagar*", "*pague*, *pagues*"], ["*antiga*", "*antigues*"], ["*llengua*, *aigua*", "*llengües*, *aigües*"]]}}, {"title": "El so [ʤ]: j/g, tj/tg i ig", "text": "S'escriu ***j*** davant de *a*, *o*, *u* i ***g*** davant de *e*, *i*. Entre vocals, ***tj*** i ***tg*** seguixen la mateixa regla: *platja*, *mitjó* / *rellotge*, *metge*. Per això *viatjar* fa *viatgem*. En final de paraula, el so [ʧ] s'escriu *ig* o *tx* **segons els derivats**: *roig* (*roja*), *lleig* (*lletja*), *desig* (*desitjar*), *despatx* (*despatxar*).", "examples": ["Nosaltres **viatgem** molt i **mengem** fora.", "Un vestit **roig** i una camisa **roja**.", "Un dia **lleig** i una nit **lletja**."], "watch": [{"wrong": "Ell és metje a la platge.", "right": "Ell és metge a la platja."}]}, {"title": "x, tx, z i tz", "text": "El so [ʧ] s'escriu ***x*** a principi de paraula i darrere de consonant (*xiquet*, *planxa*, *marxa*), i ***tx*** entre vocals (*cotxe*, *butxaca*). El so [ʃ] s'escriu **sempre *x***: *caixa*, *baixar*, *peix*. El dígraf ***tz*** apareix en *onze*, *dotze*, *tretze*, *setze* i en el sufix ***-itzar*** (*analitzar*); en canvi, *quinze* i *catorze* porten *z*.", "watch": [{"wrong": "plantxa, coxe, analizar", "right": "planxa, cotxe, analitzar"}]}, {"title": "Dígrafs i lletres compostes", "text": "Un **dígraf** són dos lletres per a **un sol so**: *rr*, *ss*, *ll*, *ny*, *gu*, *qu*, *ig*, *tg*, *tj*, *tx*, *tz*. Per això *guerra* té 6 lletres i 4 sons. Les **lletres compostes** *mm*, *nn*, *l·l*, *tl*, *tll*, *tm*, *tn* representen **dos consonants**, encara que sovint es pronuncien simples (*connectar*, *il·lusió*). L'*ig* només és dígraf darrere de vocal que no siga *i*: en *mig* i *desig*, la que sona és la *g*.", "examples": ["*Estrella*: *str* és un grup de consonants, i *ll*, un dígraf."]}, {"title": "mm, nn i l·l en l'escriptura", "text": "Davant de *m*, el prefix *in-* passa a *im-*, i *com-* es manté: ***immigrant***, ***immòbil***, ***commoure***. La ***l·l*** apareix en **cultismes**: *col·laborar*, *il·lustre*, *intel·ligent*, *instal·lació*, *satèl·lit*. Però moltes paraules porten *l* simple (*molècula*) o el dígraf *ll* (*bellesa*).", "watch": [{"wrong": "inmigrant, comoure", "right": "immigrant, commoure"}, {"wrong": "colaborar, inteligent", "right": "col·laborar, intel·ligent"}]}], "remember": ["*Ç* davant de *a*, *o*, *u* i a final; *c* davant de *e*, *i*: *caçar*, *caces*.", "*Tocar* → *toque*; *pagar* → *pague*; *llengua* → *llengües*.", "*Tj* davant de *a*, *o*, *u*; *tg* davant de *e*, *i*: *viatjar*, *viatgem*.", "[ʧ]: *x* inicial i darrere de consonant, *tx* entre vocals; [ʃ]: sempre *x*.", "Dígraf: un so (*guerra*); lletra composta: dos consonants (*immòbil*, *col·legi*)."], "sources": [{"gram": "GVB", "section": "4.2", "title": "Dígrafs i lletres compostes", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=digrafs_lletres_compostes"}, {"gram": "GVB", "section": "4.3", "title": "Lletres modificades", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=lletres_modificades"}, {"gram": "GVB", "section": "6.15", "title": "Les grafies z i s", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=representacio_so_z"}, {"gram": "GVB", "section": "6.17", "title": "Les grafies l, l·l i tl", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_l_l_l_i_tl"}, {"gram": "GVB", "section": "6.19", "title": "Les grafies m, n i mp", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_m_n_mp_tm_tn"}, {"gram": "GVB", "section": "8.1", "title": "Usos de la dièresi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=usos_dieresi"}, {"gram": "GNV", "section": "1.3.2.7", "title": "Les consonants nasals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=1_3_2_7"}, {"gram": "GNV", "section": "2.2", "title": "Dígrafs i lletres compostes", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=digrafs_lletres_compostes"}, {"gram": "GNV", "section": "4.1", "title": "La representació dels sons [g] i [k]", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_so_g"}, {"gram": "GNV", "section": "4.2.3", "title": "Les grafies c i ç", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_so_s"}, {"gram": "GNV", "section": "4.4", "title": "La grafia tz", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=4_4"}, {"gram": "GNV", "section": "4.5", "title": "La representació del so [ʤ]: les grafies g, j, tg i tj", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_so_dz"}, {"gram": "GNV", "section": "4.6", "title": "La representació del so [ʧ]: les grafies x, tx, ig i g", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_so_ts"}, {"gram": "GNV", "section": "4.7", "title": "La representació del so [ʃ]: la grafia x", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_so_s_x"}, {"gram": "GNV", "section": "37.3", "title": "Alternances formals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=alternances_formals"}]}},
  {"type": "b2_fon_sillaba", "lesson": {"intro": "Aprendràs a identificar triftongs, diftongs creixents i hiats, a separar paraules amb dígrafs i lletres compostes, a posar o estalviar la dièresi i a pronunciar bé imperfets com *feia* o *reies*.", "blocks": [{"title": "Diftong, triftong i hiat", "text": "En un **triftong**, una vocal va precedida i seguida d'una semivocal **en la mateixa síl·laba**: *guai-tar*, *cre-ieu*, *Pa-ra-guai*, *a-de-qüeu*. Fora d'eixos casos, una *i* o una *u* àtones seguides de vocal solen formar **hiat**: *pi-a-no*, *di-a-ri*, *ju-li-ol*, *su-au*, *cli-ent*. Amb vocals iguals també hi ha hiat: *co-o-pe-rar*.", "examples": ["En final de paraula, *història* o *gràcia* es pronuncien amb **diftong** (*his-tò-ria*); el hiat és propi de registres molt formals."]}, {"title": "Els diftongs creixents", "text": "La semivocal va **davant** de la vocal. Es forma darrere de *g* i *q* (*gua-nyar*, *qua-tre*, *quo-ta*, *qües-ti-ó*, *lin-güís-ti-ca*) i també quan la *i* o la *u* van **a principi de paraula** o **entre vocals**: *io-gurt*, *hie-na*, *bo-ia*, *cre-ua*, *ca-uen*. Per això la *i* o la *u* intervocàliques van amb la síl·laba següent.", "table": {"head": ["paraula", "separació"], "rows": [["*iogurt*", "*io-gurt*"], ["*cauen*", "*ca-uen*"], ["*llengua*", "*llen-gua*"], ["*quotidià*", "*quo-ti-di-à*"]]}}, {"title": "Separar síl·labes amb dígrafs", "text": "**Se separen** *rr*, *ss*, *sc*, *l·l* (sense punt volat), *tj*, *tg*, *tx*, *tl*, *tll*, *tm*, *tn*, *tz*, *mm* i *nn*. **No se separen mai** *gu*, *qu*, *ny*, *ll* ni *ig*. També se separen els constituents de compostos i prefixats (*in-expert*, *des-encolar*, *vos-altres*) i, en final de línia, no s'ha de deixar **cap lletra sola**.", "table": {"head": ["se separen", "no se separen"], "rows": [["*ar-re-glar*, *pro-fes-sor*", "*es-quer-ra*, *pa-quet*"], ["*in-tel-li-gent*", "*re-llot-ge*"], ["*de-sit-jar*, *or-ga-nit-zar*", "*en-se-nyar*"], ["*fet-ge*, *jut-ge*", "*ba-teig*"]]}, "watch": [{"wrong": "me-tge, ca-rro, can-ya", "right": "met-ge, car-ro, ca-nya"}]}, {"title": "Dièresi: quan sí i quan no", "text": "La dièresi marca que la *i* o la *u* **no fan diftong** amb la vocal anterior (*he-ro-ï-na*) i que la *i* entre vocals és vocal (*a-gra-ï-a*, *tra-du-ï-en*). **No** s'escriu en l'**infinitiu, gerundi, futur i condicional** dels verbs en vocal + *ir* (*traduir*, *construint*, *agrairé*), ni si la paraula ja porta **accent** (*Lluís*/*Lluïsa*, *agraíem*/*agraïen*), ni en *-isme*, *-ista* o darrere de prefix (*egoisme*, *reunió*).", "watch": [{"wrong": "construïnt, heroina", "right": "construint, heroïna"}]}, {"title": "Imperfets forts: feia, reia, duia", "text": "*Fer* té un imperfet amb l'accent en el radical i una ***i* consonàntica**: *feia*, *feies*, *feia*, *féiem*, *féieu*, *feien* (*fe-ia*). Igual fan *caure*, *creure*, *dir*, *dur*, *jaure*, *riure*, *seure* i *traure*. En la parla són habituals *fea*, *vea* o *ria*, i en alguns parlars *caïa*; no són incorrectes on són vives, però **en registres formals** cal usar les formes amb *i* consonàntica.", "table": {"head": ["verb", "imperfet formal"], "rows": [["*riure*", "*reia*, *reies*"], ["*caure*", "*queia*, *queies*"], ["*traure*", "*treia*, *treies*"], ["*dur*", "*duia*, *duies*"]]}}], "remember": ["Triftong: una vocal entre dos semivocals en una síl·laba (*Pa-ra-guai*).", "*I*, *u* inicials o entre vocals fan diftong creixent: *io-gurt*, *ca-uen*.", "Se separen *rr*, *ss*, *l·l*, *tg*, *tj*, *tx*, *tz*; mai *gu*, *qu*, *ny*, *ll*, *ig*.", "Sense dièresi en infinitiu, gerundi, futur i condicional: *traduir*, *construint*.", "En registre formal: *feia*, *reies*, *queia*, *treia* (*fe-ia*)."], "sources": [{"gram": "GVB", "section": "1.2.3.1", "title": "Pronunciacions recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grups_vocalics"}, {"gram": "GVB", "section": "8.2", "title": "Estalvi en l'ús de la dièresi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=estalvi_dieresi"}, {"gram": "GNV", "section": "1.2.3", "title": "Els grups vocàlics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=1_2_3"}, {"gram": "GNV", "section": "3.1.2", "title": "Normes de separació sil·làbica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=3_1_2"}, {"gram": "GNV", "section": "3.2.1", "title": "Conceptes bàsics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=3_2_1"}, {"gram": "GNV", "section": "3.2.2", "title": "Classificació dels diftongs", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=classificacio_diftongs"}, {"gram": "GNV", "section": "5.2", "title": "La dièresi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=5_2"}, {"gram": "GNV", "section": "30.2.4.1", "title": "Verbs amb imperfets forts", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=30_2_4_1"}]}},
  {"type": "b2_fon_vocals", "lesson": {"intro": "Aprendràs a escriure bé les vocals àtones que es pronuncien d'una altra manera (*avaria*, *Joan*, *complir*, *entendre*) i a dominar les alternances vocàliques dels verbs (*llig*/*llegim*, *ix*/*eixim*, *puc*/*podem*).", "blocks": [{"title": "L'escriptura no seguix la pronúncia", "text": "En general, cada vocal àtona s'escriu com sona, però hi ha **desajustos**. Algunes paraules porten *a* encara que sovint sonen [e], i altres porten *e* encara que sonen [a]. Si tens dubtes, **la forma escrita no canvia** amb la pronúncia del teu parlar.", "table": {"head": ["s'escriuen amb a", "s'escriuen amb e"], "rows": [["*avaria*, *afaitar*", "*assemblea*, *sergent*"], ["*ambaixada*, *assassí*", "*monestir*, *vernís*"], ["*avaluar*, *rancor*", "*enyorar*, *ebenista*"]]}, "watch": [{"wrong": "El cotxe té una averia.", "right": "El cotxe té una avaria."}, {"wrong": "El meu avi s'afeita.", "right": "El meu avi s'afaita."}]}, {"title": "o o u?", "text": "*Joan* i *Josep* s'escriuen amb *o*, però en l'estàndard es pronuncien amb [u]. També porten *o*, encara que sovint sonen [u], *cobert*, *obert*, *collir*, *cosir*, *tossir*, *complir*, *sofrir*, *polir*, *capítol* o *rigorós*. Al revés, porten ***u*** *muntar*, *suportar*, *suborn*, *sufocar*, *turment* i *bufetada*.", "watch": [{"wrong": "Juan, cumplir, cubert", "right": "Joan, complir, cobert"}, {"wrong": "soportar, montar", "right": "suportar, muntar"}]}, {"title": "La e inicial: em-, en-, es-", "text": "Les paraules patrimonials començades per *em-*, *en-*, *es-* s'escriuen **sempre amb *e***, encara que es pronuncien amb [e] o amb [a], i les dos pronúncies són pròpies de l'estàndard: *enveja*, *embrutar*, *espenta*, *entendre*. També la *e* pretònica de *gegant*, *sencer*, *llençol* o *terròs* pot sonar [a], però s'escriu *e*.", "examples": ["No **entenc** res del que m'has explicat.", "Ha **embrutat** el **llençol** **sencer**."]}, {"title": "Alternances i/e i u/o en la tercera conjugació", "text": "Uns quants verbs prenen ***i*** o ***u*** quan la vocal del radical és **tònica**, i ***e*** o ***o*** quan és **àtona**. És una alternança **sistemàtica**: *llig*, *lliges*, *lligen*, però *llegim*, *llegiu*, *llegir*.", "table": {"head": ["verb", "tònica (i, u)", "àtona (e, o)"], "rows": [["*llegir*", "*llig*, *lligen*", "*llegim*, *llegiu*"], ["*eixir*", "*ix*, *ixes*, *ixen*", "*eixim*, *eixiu*"], ["*afegir*, *vestir*", "*afig*, *vist*", "*afegim*, *vestim*"], ["*cosir*, *collir*", "*cus*, *cull*", "*cosim*, *collim*"], ["*tossir*, *escopir*", "*tus*, *escup*", "*tossim*, *escopim*"], ["*sortir*", "*surt*", "*sortim*"]]}, "watch": [{"wrong": "nosaltres lligim", "right": "nosaltres llegim"}, {"wrong": "tu eixes tard", "right": "tu ixes tard"}]}, {"title": "Poder, voler i altres de la segona", "text": "En la segona conjugació, les alternances **varien de verb a verb**: *poder* (*puc*, *pot* / *podem*), *voler* (*vull* / *volem*, *volia*), *tindre* (*tinc* / *tens*), *vindre* (*vinc* / *vens*), *saber* (*sé* / *saps*). En el subjuntiu, *poder* i *voler* mantenen la *u*: *pugues*, *vullga*.", "examples": ["Jo no **puc** vindre, però ella sí que **pot**.", "Vine quan **pugues**.", "Qui no **vullga** pols, que no vaja a l'era."]}], "remember": ["*Avaria*, *afaitar*, *ambaixada*: amb *a*; *assemblea*, *sergent*: amb *e*.", "*Joan*, *Josep*, *cobert*, *complir*: amb *o*; *muntar*, *suportar*: amb *u*.", "*Em-*, *en-*, *es-* inicials, sempre amb *e*: *entendre*, *espenta*.", "Tercera conjugació: tònica *i*/*u*, àtona *e*/*o*: *llig*/*llegim*, *cus*/*cosim*.", "*Puc*/*podem*, *vull*/*volem*; subjuntiu *pugues*, *vullga*."], "sources": [{"gram": "GVB", "section": "1.2.2.1", "title": "Pronunciacions recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=vocals_atones"}, {"gram": "GVB", "section": "1.2.2.2", "title": "Pronunciacions acceptables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=vocals_atones"}, {"gram": "GVB", "section": "6.2", "title": "Les grafies a i e", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_a_e"}, {"gram": "GVB", "section": "6.3", "title": "Les grafies o i u", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_o_u"}, {"gram": "GNV", "section": "1.2.2.3", "title": "Criteris particulars de pronunciació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=vocals_atones"}, {"gram": "GNV", "section": "30.2.1", "title": "Verbs amb alternances vocàliques en el radical", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}]}},
  {"type": "b2_fon_accentuacio", "lesson": {"intro": "Aprendràs els quinze accents diacrítics amb tots els seus significats, a triar entre *què* i *que* o *per què* i *perquè*, i a distingir parònims com *patí* i *pati* aplicant les regles generals.", "blocks": [{"title": "Els quinze diacrítics", "text": "L'accent diacrític distingix **paraules monosíl·labes d'ús freqüent** que s'escriuen igual. La llista és **tancada**: *bé*, *déu*, *és*, *mà*, *més*, *món*, *pèl*, *què*, *sé*, *sí*, *sòl*, *són*, *té*, *ús* i *vós*. Fixa't en els que menys s'usen:", "table": {"head": ["amb accent", "sense accent"], "rows": [["*déu* (divinitat)", "*deu* (numeral; verb *deure*; font)"], ["*sòl* (pis, terra)", "*sol* (astre; sense companyia; nota; verb *soldre*)"], ["*són* (verb *ser*)", "*son* (ganes de dormir; possessiu: *son pare*)"], ["*ús* (acció d'usar)", "*us* (pronom feble)"], ["*vós* (pronom fort)", "*vos* (pronom feble)"], ["*pèl* (filament de la pell)", "*pel* (*per* + *el*)"]]}, "examples": ["Els grecs tenien molts **déus**; ell encara em **deu** diners.", "És un **sòl** molt rocós, però ha vingut **sol**.", "Beneïda sou **vós**; demà **vos** ho portaré."]}, {"title": "Quina de les dos porta l'accent?", "text": "Hi ha dos criteris. Si una paraula és **tònica** i l'altra **àtona**, s'accentua la tònica: *mà*/*ma*, *món*/*mon*, *sé*/*se*, *té*/*te*, *vós*/*vos*. Si les dos són tòniques però el timbre canvia, s'accentua la de **vocal tancada**: *bé*/*be*, *déu*/*deu*, *són*/*son*. I recorda que una mateixa forma pot tindre **molts valors**: *bé* és adverbi, nom (*fer el bé*, *els béns*) i conjunció (*ara bé*).", "examples": ["**Ma** germana **m'ha** agafat de la **mà**.", "El ramat porta un **be** negre; ho has fet molt **bé**.", "Tot pareix correcte; ara **bé**, cal revisar-ho."]}, {"title": "*Què* o *que*; *per què* o *perquè*", "text": "***Què*** és **tònic**: interrogatiu (directe o indirecte) i relatiu **darrere de preposició** (*de què*, *amb què*, *en què*). ***Que*** és **àton**: conjunció, relatiu sense preposició i exclamatiu (*Que estrany!*). ***Per què*** (preposició + interrogatiu) pregunta la causa; ***perquè*** és la conjunció que la respon.", "examples": ["No sé **què** vols dir.", "La casa **de què** et vaig parlar està en venda.", "Diu **que** vindrà demà.", "—**Per què** no has vingut? —**Perquè** estava malalt."], "watch": [{"wrong": "Este és el llibre de que et vaig parlar.", "right": "Este és el llibre de què et vaig parlar."}]}, {"title": "Fora de la llista, sense accent", "text": "**Cap altra paraula** porta accent diacrític: *dona* (nom i verb *donar*) o *os* s'escriuen sense accent. Els diacrítics **mantenen** l'accent en un compost **amb guionet** (*mà-llarg*, *pèl-roig*, *més-dient*), però el **perden** si el compost s'escriu junt: *rodamon*, *repel*, *subsol*, *adeu*. Només en contextos aïllats com rètols o títols es pot mantindre un accent perdut per a evitar malentesos.", "examples": ["Ella sempre **dona** la raó als altres.", "El gos rosegava un **os**.", "Un gat **pèl-roig** passejava pel **subsol**."], "watch": [{"wrong": "Ella sempre dóna la raó.", "right": "Ella sempre dona la raó."}]}, {"title": "Parònims: les regles generals decidixen", "text": "Moltes parelles no són diacrítiques: es distingixen perquè l'accent recau en **síl·labes diferents**, i les regles d'agudes, planes i esdrúixoles fan la resta. El femení de *mitjà* és *mitjana* (els acabats en vocal tònica afigen *-na*) i el de *secretari* és *secretària* (passa a esdrúixola).", "table": {"head": ["amb accent", "sense accent"], "rows": [["*patí* (aguda: calçat amb rodes)", "*pati* (plana: espai obert)"], ["*mitjà* (aguda: recurs; del mig)", "*mitja* (plana: meitat; peça de roba)"], ["*secretària* (persona)", "*secretaria* (oficina)"], ["*pública* (adjectiu, esdrúixola)", "*publica* (verb, plana)"], ["*contínua* (adjectiu)", "*continua* (verb)"], ["*cantarà* (futur)", "*cantara* (imperfet de subjuntiu)"]]}, "examples": ["La televisió és un **mitjà** de comunicació; arribaré a les cinc i **mitja**.", "Hem estudiat l'Edat **Mitjana**."]}], "remember": ["Només quinze diacrítics: *bé*, *déu*, *és*, *mà*, *més*, *món*, *pèl*, *què*, *sé*, *sí*, *sòl*, *són*, *té*, *ús*, *vós*.", "Tònica contra àtona, s'accentua la tònica; dos tòniques, la de vocal tancada.", "*Què* tònic: interrogatiu i relatiu amb preposició (*de què*).", "Fora de la llista, sense accent: *dona*, *os*, *rodamon*.", "*Patí*/*pati*, *mitjà*/*mitja*: ho decidixen les regles generals."], "sources": [{"gram": "GVB", "section": "7.2", "title": "Regles generals d'accentuació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=regles_generals_accentuacio"}, {"gram": "GVB", "section": "7.7", "title": "L'accentuació diacrítica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=accentuacio_diacritica"}, {"gram": "GVB", "section": "7.8", "title": "L'accentuació de paraules compostes", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=7_8"}, {"gram": "GVB", "section": "16.2.2", "title": "El femení dels masculins acabats en vocal", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=femeni_a_partir_masculins_acabats_en_vocal"}, {"gram": "GVB", "section": "18.1.2", "title": "Els adjectius variables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adjectius_variables"}, {"gram": "GVB", "section": "41.4.4", "title": "Les conjuncions causals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_causals"}, {"gram": "GNV", "section": "1.2.1.2", "title": "Criteris generals de pronunciació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=vocals_toniques"}, {"gram": "GNV", "section": "5.1.1", "title": "Regles generals d'accentuació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=5_1_1"}, {"gram": "GNV", "section": "5.1.3", "title": "L'accentuació diacrítica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=5_1_3"}, {"gram": "GNV", "section": "37.5.1", "title": "Nominalització", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=nominalitzacio"}]}},
  {"type": "b2_fon_dieresi_guionet", "lesson": {"intro": "Aprendràs quan cal la dièresi i quan s'estalvia (també en els verbs com *traduir*), com s'unixen amb guionet els pronoms, els numerals i els compostos, i els casos en què no s'apostrofa.", "blocks": [{"title": "Dièresi: la *u* que sona i l'hiat", "text": "La dièresi indica que la *u* de *gue*, *gui*, *que*, *qui* **es pronuncia** (*llengües*, *lingüística*, *freqüent*) i que la *i* o la *u* **no fa diftong** amb la vocal anterior (*veïna*, *heroïna*, *Raül*). L'hiat es manté en els **derivats** (*veïnat*, *raïmet*) i apareix en derivats cultes en *-itat*, *-itzar*, encara que la paraula primitiva tinga diftong: *laic* → *laïcisme*, *heroi* → *heroïcitat*.", "examples": ["La **freqüència** dels autobusos és poc **freqüent**.", "La meua **veïna** coneix tot el **veïnat**."]}, {"title": "Quan no es posa dièresi", "text": "Hi ha hiat, però la dièresi **s'estalvia** en estos casos. Atenció a les **excepcions**: *lluïsme* i *proïsme* (ací *-isme* no és sufix) i *reüll*.", "table": {"head": ["cas", "exemples"], "rows": [["la paraula ja porta accent", "*país* (però *països*), *Lluís* (però *Lluïsa*)"], ["sufixos *-isme*, *-ista*", "*altruisme*, *egoisme*, *europeista*"], ["darrere de prefix", "*reunió*, *coincidència*, *antiinflamatori*"], ["terminacions cultes *-um*, *-us*", "*aquàrium*, *Màrius*"], ["*h* entre vocal i *i*", "*ahir*, *vehicle*"]]}}, {"title": "Verbs com *traduir*, *agrair*, *obeir*", "text": "En els verbs de la tercera conjugació en vocal + *ir*, l'**infinitiu**, el **gerundi**, el **futur** i el **condicional** van **sense dièresi**. La resta de formes amb hiat la porten: imperfet, participi i formes com *traduïm* o *obeïx*. I si la forma ha de dur **accent**, l'accent **preval**: *traduí*, *agraíem*.", "table": {"head": ["sense dièresi", "amb dièresi", "amb accent"], "rows": [["*traduir*, *traduint*", "*traduïa*, *traduït*, *traduïda*", "*traduí*"], ["*agrairé*, *agrairia*", "*agraïa*, *agraïm*, *agraïen*", "*agraíem*"], ["*construir*, *construint*", "*construïa*, *construït*, *construïx*", "*construí*"]]}, "watch": [{"wrong": "Demà traduïré la carta i després la construïré.", "right": "Demà traduiré la carta i després la construiré."}]}, {"title": "Guionet amb pronoms i numerals", "text": "Els pronoms **darrere del verb** s'unixen amb guionet o apòstrof: forma **plena** darrere de consonant o diftong (*menjar-les*, *comprant-los*, *mengeu-les*) i **reduïda** darrere de vocal (*porta'ns*). En les combinacions, l'apòstrof va **tan a la dreta com siga possible**: *dona-me'l*, *anar-te'n*. En els **numerals**, guionet entre desenes i unitats i entre unitats i centenes; la resta, amb espai.", "examples": ["Este llibre, **dona-me'l** ara; i la nota, **porta-li-ho** demà.", "Va nàixer el **mil nou-cents noranta-nou**."], "watch": [{"wrong": "Has d'anar't-en abans que es faça fosc.", "right": "Has d'anar-te'n abans que es faça fosc."}]}, {"title": "Guionet en els compostos", "text": "Porten guionet els compostos amb **punt cardinal** (*nord-est*, *sud-americà*), els **reduplicatius** (*ping-pong*, *xino-xano*), els que tenen el segon element en *r-*, *s-*, *x-* (*gira-sol*), el primer amb accent (*pèl-roig*), els de **direcció** (*el trajecte València-Alacant*) i el *no* lexicalitzat (*pacte de no-agressió*). Els **prefixos** van junts (*exministre*, *vicepresident*), però separats davant d'una locució o d'una sigla: *ex alt càrrec*, *ex URSS*.", "examples": ["Cal la **no proliferació** de fongs (*no* davant de nom, sense guionet)."]}, {"title": "Quan no s'apostrofa", "text": "*El*, *la* i *de* s'apostrofen davant de vocal o *h*: *l'illa*, *d'aigua*, *d'Elx*. Però *la* **no** s'apostrofa davant de *i* o *u* **àtones** (*la universitat*, *la història*), i cap d'ells davant de *i*, *u* **semivocals** (*el iogurt*, *la hiena*, *de hui*). Tampoc en *la una*, *la ira*, *la host* ni davant del nom de les lletres: *la a*, *la efe*. Els pronoms seguixen la mateixa regla: *m'agrada*, *s'ha*, però *la utilitza*.", "watch": [{"wrong": "L'universitat ha comprat l'iogurt.", "right": "La universitat ha comprat el iogurt."}]}], "remember": ["Dièresi quan la *u* sona (*qüestió*) o quan hi ha hiat sense accent (*veïna*, *Raül*).", "Sense dièresi: amb accent, *-isme*/*-ista*, prefixos, i infinitiu, gerundi, futur i condicional (*traduir*, *traduiré*).", "Pronoms posposats: *menjar-les*, *porta'ns*, *dona-me'l*, *anar-te'n*.", "Numerals: *nou-cents noranta-nou*; prefixos junts: *exministre*.", "*La* davant de *i*, *u* àtones, sense apòstrof: *la universitat*."], "sources": [{"gram": "GVB", "section": "8.1", "title": "Usos de la dièresi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=usos_dieresi"}, {"gram": "GVB", "section": "8.2", "title": "Estalvi en l'ús de la dièresi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=estalvi_dieresi"}, {"gram": "GVB", "section": "9.1", "title": "Usos del guionet", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=usos_guionet"}, {"gram": "GVB", "section": "9.2", "title": "Casos sense guionet", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=compostos_sense_guionet"}, {"gram": "GVB", "section": "10.2", "title": "L'apostrofació de l'article definit", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=apostrofacio_article_definit"}, {"gram": "GVB", "section": "10.5", "title": "L'Apostrofació davant de i o u no vocàliques", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=apostrofacio_i_u_consonantiques"}, {"gram": "GVB", "section": "10.14", "title": "L'apostrofació dels pronoms febles", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=apostrofacio_pronoms_febles"}, {"gram": "GVB", "section": "26.3.2", "title": "Formes plenes, reforçades, reduïdes i elidides", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=formes_plenes_elidides"}, {"gram": "GVB", "section": "26.4.2", "title": "La forma dels pronoms febles", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=forma_pronoms_febles"}, {"gram": "GNV", "section": "5.2", "title": "La dièresi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=5_2"}, {"gram": "GNV", "section": "5.3", "title": "El guionet", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=5_3"}, {"gram": "GNV", "section": "5.4", "title": "L'apòstrof", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=5_4"}, {"gram": "GNV", "section": "18.3.2", "title": "La forma dels numerals cardinals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=numerals_cardinals"}]}},
  {"type": "b2_fon_oclusives", "lesson": {"intro": "Aprendràs a escriure els gerundis en *-nt* i els mots en *-itud*, els grups *ab-*, *ob-*, *sub-* i *cap-*, les alternances *b*/*p* i *u*/*v*, la *m* davant de *b* i la *n* davant de *v*, i com sonen les oclusives finals.", "blocks": [{"title": "Gerundis sempre en *-nt*", "text": "Tots els gerundis acaben en ***-nt***: *cantant*, *batent*, *servint*, *sentint*. La *t* s'escriu **sempre**, i davant de vocal s'ha de pronunciar (*sant Antoni*, *vint hòmens*). **No** és normatiu cap gerundi amb increment velar: *dient*, *venint*, *vivint*, *bevent*.", "examples": ["Va eixir **corrent** de casa perquè feia tard.", "Estàvem **fent** la faena i **tenint** cura dels xiquets."], "watch": [{"wrong": "Ho va dir diguent que no vindria.", "right": "Ho va dir dient que no vindria."}]}, {"title": "*-t* o *-d* a final de paraula", "text": "Darrere de vocal, en paraula aguda, s'escriu generalment ***-t***: *blat*, *humit*, *nebot*, *pelut*. Però porten ***-d*** uns pocs mots (*fred*, *sud*, *fluid*) i tots els **femenins cultes en *-etud* i *-itud***. Darrere de consonant o en paraula plana, mira la família: *verd* (*verdós*), *àrid* (*aridesa*), *crèdit* (*creditor*).", "table": {"head": ["*-etud*, *-itud* (amb *d*)", "generalment amb *t*"], "rows": [["*quietud*, *inquietud*", "*blat*, *llet*"], ["*multitud*, *solitud*", "*humit*, *pelut*"], ["*latitud*, *exactitud*", "*nebot* (*neboda*)"]]}}, {"title": "*ab-*, *ob-*, *sub-* i *cap-*", "text": "A principi de paraula, les síl·labes ***ab-***, ***ob-***, ***sub-*** (i *abs-*, *obs-*, *subs-*) s'escriuen amb ***b***: *absurd*, *objecte*, *obtindre*, *subratllar*, *substantiu*; excepte *apte*, *optar*, *òptica*, *òptim*. En canvi, ***cap-*** va amb ***p***: *capçal*, *captiu*, *capgirar*; excepte *cabdal*, *cabdell*, *cabdill*. Dins de paraula, davant de *c*, *s*, *n*, *t* va *p* (*egipci*, *repte*), però *dissabte*, *dubte*, *sobte*.", "examples": ["Era un **objectiu** **absurd**: ningú no va **obtindre** res.", "Al **capvespre** va **subratllar** els punts clau."]}, {"title": "Alternances *b*/*p* i *u*/*v*", "text": "La família t'ho diu: s'escriu ***b*** si alterna amb *p* (*cap* → *cabut*, *sap* → *saber*), i ***v*** si alterna amb *u* (*blau* → *blava*, *escriure* → *escriviu*). Així es formen els imperfets i gerundis de verbs com *beure*, *ploure*, *viure*. A final d'aguda darrere de vocal va *-p* (*grup*, *xop*), però *club*, *tub*, *esnob*; i compte amb *cup* (recipient del vi) i *cub* (hexaedre).", "table": {"head": ["forma amb *p* o *u*", "forma amb *b* o *v*"], "rows": [["*ell rep*", "*nosaltres rebem*"], ["*llop*", "*lloba*"], ["*neu*", "*nevar*, *nevant*"], ["*nou*", "*nova*"], ["*beure*, *beu*", "*bevia*, *bevent*"], ["*ploure*, *plou*", "*plovia*"]]}, "watch": [{"wrong": "Abans bebia molta aigua i vivia a Gandia.", "right": "Abans bevia molta aigua i vivia a Gandia."}]}, {"title": "*mb* i *nv*", "text": "Darrere de ***m*** s'escriu ***b***: *embotit*, *tomba*, *ambició*, *embolic*. Darrere de ***n*** s'escriu ***v***: *convent*, *canviar*, *invent*, *enveja*. Només uns pocs prefixats, compostos o cultismes mantenen *m* davant de *v*: *tramvia*, *circumveí*, *triumvir*.", "examples": ["Té **enveja** del **convent** nou.", "Quin **embolic**: el **tramvia** no ha arribat!"], "watch": [{"wrong": "Edison va patentar molts imbents.", "right": "Edison va patentar molts invents."}]}, {"title": "Com sonen les oclusives finals", "text": "A final de paraula, *b*, *d*, *g* sonen [p], [t], [k] davant de **pausa**, de **vocal** o de **consonant sorda**: *club animat* [p], *fred polar* [t]. Davant de **consonant sonora** sonen sonores: *club d'amics* [b], *sac blanc* [g]. Per això l'escriptura **no es pot guiar per l'orella**: busca el femení o un derivat (*sec*, *seca*; *càstig*, *castigar*).", "examples": ["El seu **nebot** és **sord**: ho sap tota la **família**."]}], "remember": ["Gerundis en *-nt*: *dient*, *venint*, *bevent*; mai *diguent*.", "*-etud*, *-itud* amb *d*: *inquietud*, *solitud*, *latitud*.", "*ab-*, *ob-*, *sub-* amb *b*; *cap-* amb *p*.", "*b* si alterna amb *p* (*sap*/*saber*); *v* si alterna amb *u* (*neu*/*nevar*).", "*m* + *b* i *n* + *v*: *embolic*, *invent*; excepció *tramvia*."], "sources": [{"gram": "GVB", "section": "3.2.1", "title": "Les consonants b/p, d/t i g/c", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_oclusives_posicio_final"}, {"gram": "GVB", "section": "3.2.2", "title": "El grup ‑nt", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=3_2_2"}, {"gram": "GVB", "section": "6.5", "title": "Les grafies g i c", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_g_c"}, {"gram": "GVB", "section": "6.7", "title": "Les grafies b i p", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_b_p"}, {"gram": "GVB", "section": "6.8", "title": "Les grafies d i t", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_d_t"}, {"gram": "GVB", "section": "6.19", "title": "Les grafies m, n i mp", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_m_n_mp_tm_tn"}, {"gram": "GVB", "section": "6.24", "title": "Les grafies b i v", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_b_v"}, {"gram": "GVB", "section": "16.2.1", "title": "El femení dels masculins acabats en consonant", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=femeni_a_partir_masculins_acabats_en_consonant"}, {"gram": "GNV", "section": "1.4.2.1", "title": "Les consonants oclusives en posició final", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=consonants_oclusives_posicio_final"}, {"gram": "GNV", "section": "4.9", "title": "Les grafies b i p", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=4_9"}, {"gram": "GNV", "section": "4.10", "title": "Les grafies b i v", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=grafies_b_v"}, {"gram": "GNV", "section": "4.11", "title": "Les grafies d i t", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=grafies_d_t"}, {"gram": "GNV", "section": "29.4", "title": "Models de les conjugacions regulars", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=29_4"}, {"gram": "GNV", "section": "30.2.2", "title": "Verbs amb alternances consonàntiques al final del radical", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}, {"gram": "GNV", "section": "30.2.3", "title": "Tendència a la generalització de formes velaritzades", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}]}},
  {"type": "b2_fon_alveolars_s", "lesson": {"intro": "Aprendràs a distingir i escriure la *s* sorda [s] i la sonora [z] (*rossa*/*rosa*, *caçar*/*casar*), a usar *z* i *tz*, a alternar *ç* i *c* en la flexió i a triar entre *-esa*, *-essa* i els gentilicis en *-és*.", "blocks": [{"title": "Qui sona [s] i qui sona [z]", "text": "La posició decidix la grafia. **Entre vocals**, la *s* simple sona **sonora** [z] (*casa*, *cosí*) i la sorda [s] s'escriu ***ss***, ***c*** o ***ç*** (*passar*, *places*, *plaça*). A principi de paraula o al costat d'una consonant, la [s] s'escriu *s* (*salut*, *pensar*) i la [z] s'escriu ***z*** (*zero*, *colze*, *onze*, *bronze*).", "table": {"head": ["posició", "so sord [s]", "so sonor [z]"], "rows": [["inicial", "*salut*, *ceba*", "*zero*, *zona*"], ["entre vocals", "*passar*, *places*, *braços*", "*casa*, *cosí*, *pesar*"], ["amb consonant", "*pensar*, *ansa*", "*colze*, *bronze*, *pinzell*"]]}}, {"title": "Parelles que cal no confondre", "text": "Canviar el so canvia la paraula. Per això en l'estàndard **no és recomanable** ensordir la [z] (*posar*, *zero*, *onze* dits amb [s]) ni sonoritzar la [s] (*comissió*, *impressió*, *consell*, *funció* dits amb [z]).", "table": {"head": ["amb [z]", "amb [s]"], "rows": [["*rosa* (flor)", "*rossa*, *rossos* (de cabells clars)"], ["*casar* (contraure matrimoni)", "*caçar* (animals)"], ["*posar* (col·locar)", "*passar* (anar per un lloc)"]]}, "examples": ["Al jardí hi ha una **rosa** blanca; la xiqueta és **rossa**.", "Es van **casar** a l'estiu; els dissabtes van a **caçar**."]}, {"title": "Excepcions, *tz* i *-itzar*", "text": "Hi ha *s* simple que sona [s] entre vocals després d'un **prefix** o en un **compost** (*asimetria*, *antisocial*, *contrasenya*, *para-sol*), i *s* sonora darrere de consonant en els derivats de *fons*, *dins* i *trans* (*enfonsar*, *endinsar*, *transatlàntic*). ***tz*** representa [dz] en *dotze*, *tretze*, *setze* (sense palatalitzar), i [z] en els verbs en ***-itzar*** i derivats.", "examples": ["Cal **organitzar** la **realització** del projecte.", "Ens vam veure a les **dotze** i **tretze** minuts."], "watch": [{"wrong": "Hem de realisar i organizar la festa.", "right": "Hem de realitzar i organitzar la festa."}]}, {"title": "*ç* i *c* en la flexió", "text": "Ja saps que va ***ç*** davant de *a*, *o*, *u* i a final, i ***c*** davant de *e*, *i*. Aplica-ho quan **conjugues**: el radical canvia de lletra però no de so.", "table": {"head": ["amb *ç*", "amb *c*"], "rows": [["*començar*, *comença*", "*comencem*, *comence*"], ["*forçar*, *llançar*", "*forcem*, *llancen*"], ["*abraçar*", "*abraceu*"], ["*vençut*, *convençut*", "*véncer*, *convéncer*"], ["*dolç*, *dolça*, *dolços*", "*dolces*"]]}, "watch": [{"wrong": "Demà començem les classes.", "right": "Demà comencem les classes."}]}, {"title": "*-esa*, *-essa*, *-ança* i gentilicis", "text": "***-esa*** (amb [z]) forma noms de **qualitat** a partir d'adjectius: *bellesa*, *tristesa*, *pobresa*, *vellesa*. ***-essa*** (amb [s]) forma alguns **femenins**: *alcaldessa*, *comtessa*, *sastressa*, *tigressa*, *jutgessa*; però *princesa*. Els gentilicis en ***-és*** fan *-esa*, *-esos*, *-eses* i **no dupliquen** la *s*, perquè sona sonora; *ros* i *gros*, que la tenen sorda, sí: *rossa*, *grossa*. De verbs es fan noms en ***-nça***: *assegurança*, *naixença*.", "table": {"head": ["masculí", "femení", "plural m.", "plural f."], "rows": [["*francés*", "*francesa*", "*francesos*", "*franceses*"], ["*ros*", "*rossa*", "*rossos*", "*rosses*"], ["*gros*", "*grossa*", "*grossos*", "*grosses*"]]}, "watch": [{"wrong": "L'alcaldesa i la marquessa han inaugurat el parc.", "right": "L'alcaldessa i la marquesa han inaugurat el parc."}]}], "remember": ["Entre vocals: *s* = [z] (*casa*); *ss*, *c*, *ç* = [s] (*passar*, *places*).", "[z] a l'inici o darrere de consonant: *z* (*zero*, *colze*, *onze*).", "*-itzar* amb *tz*: *realitzar*, *organitzar*.", "*ç* passa a *c* davant de *e*, *i*: *començar*, *comencem*.", "*-esa* per a qualitats i gentilicis (*bellesa*, *francesa*); *-essa* per a *alcaldessa*, *comtessa*."], "sources": [{"gram": "GVB", "section": "2.3.1", "title": "Pronunciacions recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_sibilants_alveolars"}, {"gram": "GVB", "section": "2.3.2", "title": "Pronunciacions no recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_sibilants_alveolars"}, {"gram": "GVB", "section": "6.13", "title": "Les grafies s i ss", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=representacio_so_s"}, {"gram": "GVB", "section": "6.14", "title": "Les grafies ç i c", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_c_c"}, {"gram": "GVB", "section": "6.15", "title": "Les grafies z i s", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=representacio_so_z"}, {"gram": "GVB", "section": "6.16", "title": "La grafia tz", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafia_tz"}, {"gram": "GVB", "section": "16.4", "title": "El gènere com a marca semàntica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=16_4"}, {"gram": "GVB", "section": "18.1.2", "title": "Els adjectius variables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adjectius_variables"}, {"gram": "GVB", "section": "18.2.1", "title": "La formació del plural", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=nombre_adjectius_formacio_plurals"}, {"gram": "GNV", "section": "1.3.2.3", "title": "Les consonants sibilants alveolars", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=1_3_2_3"}, {"gram": "GNV", "section": "4.2", "title": "La representació del so [s]: les grafies s, ss, c i ç", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_so_s"}, {"gram": "GNV", "section": "4.3", "title": "La representació del so [z]: les grafies s i z", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=4_3"}, {"gram": "GNV", "section": "4.4", "title": "La grafia tz", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=4_4"}, {"gram": "GNV", "section": "10.2.3", "title": "Altres casos", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=10_2_3"}, {"gram": "GNV", "section": "13.2.1", "title": "La formació del femení a partir de masculins acabats en consonant", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=adjectius_femeni_a_partir_masculins_acabats_en_consonant"}, {"gram": "GNV", "section": "37.5.1", "title": "Nominalització", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=nominalitzacio"}, {"gram": "GNV", "section": "38.3", "title": "La composició sintagmàtica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=38_3"}]}},
  {"type": "b2_fon_alveolars_x", "lesson": {"intro": "Aprendràs en quines posicions la *x* representa [ks] o [gz], quan cal escriure *cc*, com decidir entre *s* i *ss* en els derivats dels mots acabats en *-s* i com s'escriu el grup *sc*.", "blocks": [{"title": "La *x* que sona [ks]", "text": "El grup [ks] s'escriu ***x*** en tres posicions: **entre vocals** (*fixar*, *màxim*, *taxi*), **entre vocal i consonant sorda** (*explosió*, *extens*, *explicar*, *excepció*) i **a final de paraula** darrere de vocal (*annex*, *apèndix*). Darrere de consonant només en uns pocs casos: *esfinx*, *larinx*, *linx*. Compte amb els parònims: *taxa* (impost) i *tassa* (recipient).", "examples": ["L'Ajuntament ha pujat la **taxa** de fems.", "Vols una **tassa** de café?", "Cal **fixar** el document en l'**annex**."]}, {"title": "La *x* que sona [gz]", "text": "En els grups inicials ***ex-*** i ***inex-*** seguits de **vocal**, de ***h*** o de **consonant sonora**, la *x* representa el grup **sonor** [gz]: *examen*, *exagerar*, *exhortar*, *exdiputat*, *inexorable*. No és recomanable pronunciar-la sorda ([ks]) ni com [ʤ] (*executar*, *exercici*). En alguns territoris també és acceptable la pronunciació [ejʃ]: *exemple*, *exèrcit*.", "table": {"head": ["context", "exemples", "so"], "rows": [["*x* entre vocals", "*taxi*, *tòxic*, *màxim*", "[ks]"], ["*ex-* + consonant sorda", "*explicar*, *excepció*, *extens*", "[ks]"], ["*ex-* / *inex-* + vocal o *h*", "*examen*, *èxit*, *exhortar*, *inexorable*", "[gz]"], ["*ex-* + consonant sonora", "*exdiputat*", "[gz]"]]}, "watch": [{"wrong": "Demà tinc un «eksamen» d'«edjercici» pràctic.", "right": "Demà tinc un *examen* [gz] d'*exercici* [gz] pràctic."}]}, {"title": "*cc*: una *c* davant de *c*", "text": "En interior de paraula, el so de final de síl·laba s'escriu ***c*** (no *g*) **davant de *c*, *t*, *s***: *acció*, *actriu*, *dacsa*. Per això el [ks] davant de *e*, *i* s'escriu ***cc*** en paraules com *acció*, *lecció*, *direcció*, *elecció*, *accident*, *objecció*. Però el [ks] entre vocals s'escriu ***x***: *reflexió*, *connexió*, *fixació* (com *fixar*).", "examples": ["La **direcció** ha convocat una **elecció**.", "Ha presentat una **objecció** a la **lecció**.", "Després de la **reflexió**, ha fet la **fixació** de preus."]}, {"title": "*s* o *ss* en els derivats", "text": "Els mots acabats en **vocal + *s*** fan el femení i el plural segons la pronúncia: si la *s* passa a sonar **sorda** [s] entre vocals, es **duplica**; si sona **sonora** [z], es queda **simple**. La regla val per a substantius i adjectius i també per a molts derivats: *gros* → *grossa*, *grossor*.", "table": {"head": ["sona [s]: *ss*", "sona [z]: *s*"], "rows": [["*gos* → *gossa*", "*gas* → *gasos*"], ["*fracàs* → *fracassos*", "*avís* → *avisos*"], ["*interés* → *interessos*", "*mes* → *mesos*"], ["*espés* → *espessa*", "*francés* → *francesa*"], ["*ros* → *rossa*", "*gris* → *grisa*"], ["*tros* → *trossos*", "*poderós* → *poderosa*"]]}, "watch": [{"wrong": "Hem fet molts progresos en els procesos.", "right": "Hem fet molts *progressos* en els *processos*."}]}, {"title": "El grup *sc* i altres casos d'*ss*", "text": "En la pronunciació més corrent, el grup ***sc*** davant de *e*, *i* sona [s]: *piscina*, *ascensor*, *ascens*, *escena*, *disciplina*. A més, s'escriu ***ss*** darrere de consonant quan un prefix acabat en *s* (*trans-*, *sots-*) s'unix a una arrel amb *s*: *transsexual*, *sotssecretari*. Però amb altres prefixos la *s* inicial de l'arrel es queda **simple**, encara que vaja entre vocals: *asimetria*, *antisocial*, *contrasenya*, *dinosaure*, *para-sol*.", "examples": ["L'**ascensor** porta directament a la **piscina**.", "El **sotssecretari** ha aprovat la **contrasenya** nova."]}], "remember": ["*x* = [ks] entre vocals, davant de consonant sorda i a final: *taxi*, *explicar*, *annex*.", "*ex-*/*inex-* + vocal, *h* o consonant sonora = [gz]: *examen*, *exhortar*.", "Davant de *c*, *t*, *s* s'escriu *c*: *acció*, *direcció*, *actriu*.", "Derivat amb [s] sorda, *ss* (*gossa*, *interessos*); amb [z], *s* (*mesos*, *grisa*).", "*sc* sona [s]: *piscina*, *ascensor*, *escena*."], "sources": [{"gram": "GVB", "section": "2.3.2", "title": "Pronunciacions no recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_sibilants_alveolars"}, {"gram": "GVB", "section": "6.5", "title": "Les grafies g i c", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_g_c"}, {"gram": "GVB", "section": "6.12", "title": "Les grafies x, tx i ig", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=representacio_so_ts"}, {"gram": "GVB", "section": "6.13", "title": "Les grafies s i ss", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=representacio_so_s"}, {"gram": "GVB", "section": "16.2.1", "title": "El femení dels masculins acabats en consonant", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=femeni_a_partir_masculins_acabats_en_consonant"}, {"gram": "GVB", "section": "17.2", "title": "La formació del plural", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=formacio_plural"}, {"gram": "GVB", "section": "18.1.2", "title": "Els adjectius variables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adjectius_variables"}, {"gram": "GNV", "section": "1.3.2.3", "title": "Les consonants sibilants alveolars", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=1_3_2_3"}, {"gram": "GNV", "section": "1.3.2.4", "title": "Les consonants sibilants palatals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=consonants_sibilants_palatals"}, {"gram": "GNV", "section": "4.1", "title": "La representació dels sons [g] i [k]", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_so_g"}, {"gram": "GNV", "section": "4.2", "title": "La representació del so [s]: les grafies s, ss, c i ç", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_so_s"}, {"gram": "GNV", "section": "4.8", "title": "La representació del grup fònic [ks]", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_grup_fonic_ks"}, {"gram": "GNV", "section": "10.2.1", "title": "La formació del femení a partir de masculins acabats en consonant", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=10_2_1"}, {"gram": "GNV", "section": "11.2", "title": "La formació del plural", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=formacio_plural"}, {"gram": "GNV", "section": "13.2.1", "title": "La formació del femení a partir de masculins acabats en consonant", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=adjectius_femeni_a_partir_masculins_acabats_en_consonant"}, {"gram": "GNV", "section": "37.3", "title": "Alternances formals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=alternances_formals"}]}},
  {"type": "b2_fon_palatals", "lesson": {"intro": "Aprendràs a mantindre el so palatal en tota la flexió i la derivació (*boig*, *boges*, *bogeria*; *desig*, *desitjós*), a fer el plural dels mots en *-ig*, *-tx* i *-ix* i a pronunciar bé les palatals sonores.", "blocks": [{"title": "Un so, dos grafies: la flexió", "text": "Quan un mot canvia de terminació, el so [ʤ] no canvia, però la lletra **sí**: ***j*/*tj*** davant de *a*, *o*, *u* i ***g*/*tg*** davant de *e*, *i*. En els verbs no és una irregularitat de veritat: és **l'ortografia regular**, com *trencar* → *trenquem*.", "table": {"head": ["davant de *a*, *o*", "davant de *e*, *i*"], "rows": [["*roja*, *rojos*", "*roges*"], ["*lletja*, *lletjos*", "*lletges*"], ["*pluja*, *taronja*", "*pluges*, *taronger*"], ["*penjar*, *penja*", "*pengem*, *pengeu*"], ["*jutjar*, *jutja*", "*jutgem*, *jutgeu*"]]}, "watch": [{"wrong": "Nosaltres no jutjem ningú.", "right": "Nosaltres no *jutgem* ningú."}]}, {"title": "Mots en *-ig*: *j* o *tj*?", "text": "El dígraf ***ig*** apareix darrere de vocal tònica que no és *i* (*boig*, *roig*, *fuig*); darrere de *i* s'escriu només ***g***: *mig*, *desig*. En el femení, el plural i els derivats, *-ig* passa a ***j*/*g*** o a ***tj*/*tg*** segons la paraula: cal aprendre la família.", "table": {"head": ["primitiu", "flexió", "derivats"], "rows": [["*roig*", "*roja*, *rojos*, *roges*", "*rojor*, *rogenc*"], ["*lleig*", "*lletja*, *lletjos*, *lletges*", "*lletjor*, *lletgesa*"], ["*boig*", "*boja*, *bojos*, *boges*", "*bogeria*"], ["*desig*", "*desitjos*", "*desitjar*"], ["*bateig*", "—", "*batejar*"]]}}, {"title": "El plural de *-ig*, *-tx* i *-ix*", "text": "Els substantius en ***-ig*** admeten dos plurals: *desitjos* o *desigs*; alguns adjectius també: *rojos* o *roigs*. Els masculins en ***-tx*** i ***-ix*** fan ***-os***: *despatxos*, *cartutxos*, *peixos*, *dibuixos*. Però *matx* fa *matxs*, els plans *sàndwitx* i *càrritx* fan *sàndwitxs* i *càrritxs*, i *despatx* també admet *despatxs*.", "table": {"head": ["singular", "plural"], "rows": [["*desig*", "*desitjos* o *desigs*"], ["*despatx*", "*despatxos* (o *despatxs*)"], ["*escabetx*", "*escabetxos*"], ["*peix*", "*peixos*"], ["*matx*", "*matxs*"]]}, "examples": ["Els **despatxos** de la tercera planta estan tancats.", "Al mercat venen **peixos** molt frescos."]}, {"title": "Els derivats de *-tx*", "text": "Una paraula acabada en ***-tx*** conserva el ***tx*** en tota la família, perquè entre vocals el so [ʧ] s'escriu sempre *tx*: *despatx* → *despatxar*, *capritx* → *encapritxar*, *cartutx* → *cartutxera*. Darrere de consonant, en canvi, s'escriu ***x***: *marxa*, *panxa*, *anxova*.", "examples": ["Ha **despatxat** la feina abans de dinar.", "S'ha **encapritxat** d'una **motxilla** nova."], "watch": [{"wrong": "capritxo, despaxar", "right": "*capritx*, *despatxar*"}]}, {"title": "Pronunciar bé les palatals", "text": "En l'estàndard, *g*/*j* i *tg*/*tj* sonen [ʤ] **sonora**: *gelat*, *jugar*, *platja*; no és recomanable ensordir-les ([ʧ]). La *j* de ***ja*** i ***jo*** sona com una *i* [j], però la de *projecte*, *objecció* o *subjecte*, no. La pronúncia **geminada** de *tg*/*tj* (*metge* [médʤe]) és acceptable on és pròpia. La *x* de *caixa* és [ʃ], no [s], i davant de *Xàtiva* no s'afig cap vocal.", "watch": [{"wrong": "[ʧ]elat, pro[j]ecte, cui[s]a", "right": "[ʤ]elat, pro[ʤ]ecte, cui[ʃ]a"}]}], "remember": ["*j*/*tj* davant de *a*, *o*, *u*; *g*/*tg* davant de *e*, *i*: *jutja*, *jutgem*.", "*-ig* passa a *j* o *tj* segons la família: *roja*, *lletja*, *desitjar*.", "*desig* fa *desitjos* o *desigs*; *-tx* i *-ix* fan *-os*: *despatxos*, *peixos*.", "*-tx* es manté en els derivats: *capritxós*, *despatxar*.", "*g* i *j* sonen [ʤ] sonora; *ja* i *jo*, amb [j]."], "sources": [{"gram": "GVB", "section": "2.4.1", "title": "Pronunciacions recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_sibilants_palatals"}, {"gram": "GVB", "section": "2.4.2", "title": "Pronunciacions acceptables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=2_4_2"}, {"gram": "GVB", "section": "2.4.3", "title": "Pronunciacions no recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_sibilants_palatals"}, {"gram": "GVB", "section": "6.11", "title": "Les grafies tj i tg", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_tj_tg"}, {"gram": "GVB", "section": "6.12", "title": "Les grafies x, tx i ig", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=representacio_so_ts"}, {"gram": "GVB", "section": "17.2", "title": "La formació del plural", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=formacio_plural"}, {"gram": "GVB", "section": "18.2.1", "title": "La formació del plural", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=nombre_adjectius_formacio_plurals"}, {"gram": "GNV", "section": "1.3.2.4", "title": "Les consonants sibilants palatals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=consonants_sibilants_palatals"}, {"gram": "GNV", "section": "2.2", "title": "Dígrafs i lletres compostes", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=digrafs_lletres_compostes"}, {"gram": "GNV", "section": "4.5", "title": "La representació del so [ʤ]: les grafies g, j, tg i tj", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_so_dz"}, {"gram": "GNV", "section": "4.6", "title": "La representació del so [ʧ]: les grafies x, tx, ig i g", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_so_ts"}, {"gram": "GNV", "section": "4.7", "title": "La representació del so [ʃ]: la grafia x", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_so_s_x"}, {"gram": "GNV", "section": "11.2", "title": "La formació del plural", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=formacio_plural"}, {"gram": "GNV", "section": "13.2.1", "title": "La formació del femení a partir de masculins acabats en consonant", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=adjectius_femeni_a_partir_masculins_acabats_en_consonant"}, {"gram": "GNV", "section": "30.1", "title": "Conceptes generals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=verbs_irregulars"}, {"gram": "GNV", "section": "37.3", "title": "Alternances formals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=alternances_formals"}]}},
  {"type": "b2_fon_laterals_h", "lesson": {"intro": "Aprendràs com es pronuncien i se separen *l·l*, *tl* i *tll*, quan s'escriu *m* o *n* davant de *f* i *v*, on va la *h* intercalada i com distingir *ha*/*a*/*ah*, *hem*/*em* i *hi*/*i*.", "blocks": [{"title": "Com sonen *l·l*, *tl* i *tll*", "text": "La ***l·l*** dels cultismes (*il·lusió*, *col·legi*, *pel·lícula*, *sol·licitar*) es pronuncia com una ***l* simple**; la geminada només és pròpia de registres molt formals. El ***tl*** de paraules patrimonials (*ametla*, *guatla*, *motle*, *vetla*) pot sonar [ll] o [l], però es **preferix la geminada**; en cultismes com *atles* o *atleta* sona [dl]. El ***tll*** (*bitllet*, *butlletí*, *ratlla*) sona normalment com una *ll* simple.", "table": {"head": ["grafia", "exemples", "pronúncia estàndard"], "rows": [["*l·l*", "*il·lusió*, *novel·la*", "[l] (formal: [ll])"], ["*tl* patrimonial", "*ametla*, *vetlar*", "[ll] preferible, o [l]"], ["*tl* culte", "*atles*, *atlàntic*", "[dl]"], ["*tll*", "*bitllet*, *rotllo*", "[ʎ]"]]}}, {"title": "*ametla* o *ametlla*?", "text": "Paraules com *ametla*, *vetlar* o *guatla* es pronuncien en valencià habitualment amb [ll]. En altres parlars de la llengua sonen amb doble *ll* i s'escriuen ***ametlla***, ***vetllar***, ***guatlla***. Compte: *vetla* (acció de vetlar) no és *vella* (femení de *vell*).", "examples": ["Hem passat la nit en **vetla** al costat del malalt.", "He comprat **ametles** i un **bitllet** de tren."]}, {"title": "Separar síl·labes", "text": "Les lletres compostes es **reparteixen** entre dues síl·labes, i la *l·l* **perd el punt volat**: *vil-la*, *col-le-gi*. En canvi, els dígrafs com *ll*, *ny*, *gu* o *qu* **no se separen mai**: *pe-lle-ter*, *pe-nya*.", "table": {"head": ["grafia", "separació"], "rows": [["*l·l*", "*vil-la*, *pel-lí-cu-la*"], ["*tl*", "*vet-la*, *a-met-la*"], ["*tll*", "*rot-llo*, *rat-lla*"], ["*ll* (dígraf)", "*pe-lle-ter*"]]}, "watch": [{"wrong": "co-l·le-gi, a-me-tla", "right": "*col-le-gi*, *a-met-la*"}]}, {"title": "*m* o *n* davant de *f* i *v*", "text": "Davant de *b*, *f*, *m*, *p* s'escriu ***m***: *símbol*, *amfiteatre*, *simfonia*, *èmfasi*, *immigrant*. Però es manté la ***n*** en prefixos i compostos (*enmig*, *benparlat*) i davant de *f* en paraules que comencen per *con-*, *in-* i la majoria de les començades per *en-*: *confessar*, *infinit*, *enfortir*. Davant de *v*, ***n*** (*convent*, *recanvi*), excepte en formes com *tramvia* o *circumval·lació*.", "watch": [{"wrong": "sinfonia, comfessar", "right": "*simfonia*, *confessar*"}]}, {"title": "La *h* i els homòfons", "text": "La ***h*** és normalment muda i s'escriu per etimologia, a l'inici (*harmonia*, *herba*, *hivern*) o **intercalada** (*ahir*, *vehicle*, *prohibit*, *rehabilitació*, *alcohol*, *tothom*). Només sona aspirada en algunes interjeccions. Distingix: ***ha***, ***hem*** (verb *haver*) de *a* (preposició) i *em* (pronom); ***hi*** (pronom: *hi ha*) de *i* (conjunció); ***ah*** és una interjecció.", "examples": ["Ell **ha** anat **a** València **a** comprar roba.", "**Hem** arribat tard i ara **em** fa mal el cap.", "No **hi** ha farina **i** sucre per al pastís.", "**Ah**, ara ho entenc!"]}], "remember": ["*l·l* sona [l]; *tl* patrimonial, millor [ll]; *tll*, [ʎ].", "En la partició, *col-le-gi* (sense punt) i *a-met-la*.", "*m* davant de *f* (*simfonia*), però *confessar*, *infinit*, *enmig*.", "*h* intercalada: *ahir*, *vehicle*, *prohibir*, *tothom*.", "*ha*/*hem* (haver), *hi* (pronom) i *ah* (interjecció) porten *h*."], "sources": [{"gram": "GVB", "section": "2.5.1", "title": "Pronunciacions recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_laterals"}, {"gram": "GVB", "section": "5.1.2", "title": "Normes de separació sil·làbica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=silaba_normes_separacio"}, {"gram": "GVB", "section": "6.17", "title": "Les grafies l, l·l i tl", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_l_l_l_i_tl"}, {"gram": "GVB", "section": "6.18", "title": "Les grafies ll i tll", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_ll_i_tll"}, {"gram": "GVB", "section": "6.19", "title": "Les grafies m, n i mp", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_m_n_mp_tm_tn"}, {"gram": "GVB", "section": "6.23", "title": "La grafia h", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafia_h"}, {"gram": "GVB", "section": "8.2", "title": "Estalvi en l'ús de la dièresi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=estalvi_dieresi"}, {"gram": "GVB", "section": "27.4.2", "title": "El pronom hi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronom_hi"}, {"gram": "GVB", "section": "42.2.1", "title": "Les interjeccions expressives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=42_2_1"}, {"gram": "GNV", "section": "1.3.2.5", "title": "Les consonants laterals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=consonants_laterals"}, {"gram": "GNV", "section": "3.1.2", "title": "Normes de separació sil·làbica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=3_1_2"}, {"gram": "GNV", "section": "4.12", "title": "Les grafies m, n, mp, tm i tn", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=grafies_m_n_mp_tm_tn"}, {"gram": "GNV", "section": "4.14", "title": "Les grafies l, l·l i tl", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=grafies_l_l_l_i_tl"}, {"gram": "GNV", "section": "4.15", "title": "Les grafies ll i tll", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=grafies_ll_i_tll"}, {"gram": "GNV", "section": "4.17", "title": "La grafia h", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=grafia_h"}, {"gram": "GNV", "section": "30.2.2", "title": "Verbs amb alternances consonàntiques al final del radical", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}]}},
  {"type": "b2_fon_majuscules", "lesson": {"intro": "Aprendràs a decidir la majúscula segons el signe que la precedix i a distingir el nom propi del nom genèric en institucions, càrrecs, tractaments, festes, títols i topònims.", "blocks": [{"title": "El signe d'abans decidix", "text": "Majúscula després de **punt** i de ***?*** o ***!*** que **tanquen** la frase. Si el *?* o el *!* no la tanquen (van amb coma o la frase continua), **minúscula**: *Ell és, com t'ho diria?, original*. Amb **punts suspensius**: majúscula si tanquen l'enunciat i minúscula si només suspenen el discurs. Després de **coma** i de **punt i coma**, sempre minúscula.", "examples": ["Saps què et dic? **Que** ja està bé.", "La seua situació és, ai!, molt precària.", "No ho veig clar... **De** totes maneres, ja en parlarem."]}, {"title": "Dos punts i parèntesis", "text": "Després de **dos punts**, minúscula (enumeracions, explicacions, causes), excepte si introduïxen una **cita textual** o l'objecte d'un document administratiu (*SOL·LICITE: Que...*). El text d'un **parèntesi** va amb majúscula si el parèntesi va **després de punt**, i amb minúscula si s'obri dins de la frase. Si una abreviatura com *etc.* tanca la frase, el seu punt fa de punt final.", "examples": ["Ja t'ho he dit: **no** et vull tornar a veure.", "Joan va dir: «**Adeu**. No sé quan podré tornar».", "Ha sigut un èxit. (**Per** a més informació, consulteu la web.)"], "watch": [{"wrong": "Hi havia pomes, peres, etc.. Tot era fresc.", "right": "Hi havia pomes, peres, etc. Tot era fresc."}]}, {"title": "Institucions: nom propi o genèric?", "text": "Les paraules del nom d'una **institució** o entitat van amb majúscula, i també la **menció abreujada** (*treballa en la Conselleria*). Però van en **minúscula** si s'usen en **plural** o en sentit **genèric** (*cada ajuntament*), i les denominacions **correferents** (*el consistori*, *l'executiu*). En les institucions públiques i religioses, majúscula **només el substantiu**: *l'Estat espanyol*, *l'Església catòlica*.", "table": {"head": ["majúscula", "minúscula"], "rows": [["*l'Ajuntament de Gandia*", "*és responsabilitat de cada ajuntament*"], ["*fa classes en la Universitat*", "*no ha estudiat en cap universitat*"], ["*els òrgans de l'Estat*", "*l'estat de Califòrnia*, *en estat greu*"], ["*l'Ajuntament*", "*el consistori*"]]}}, {"title": "Càrrecs, tractaments i *sant*", "text": "Els **càrrecs** i títols nobiliaris van en **minúscula**, amb nom o sense (*el rei Felip*, *l'alcalde d'Elx*). Els **tractaments** sencers també (*la senyora Jacinta*, *mossén Alcover*), però les **abreviatures**, amb majúscula (*Sr.*, *Dra.*), i les **formes protocol·làries**, també (*el Molt Honorable Senyor President*). *Sant* va amb majúscula quan forma part d'un topònim, una església o una **festa**: *Santa Pola*, *el dia de Santa Cecília*.", "examples": ["La **Dra.** Ferrer ha parlat amb la **senyora** Martí.", "El **president** de la Generalitat s'ha reunit amb el Consell.", "Per **Sant Joan** farem una foguera; **santa** Rosa és una santa."]}, {"title": "Títols, documents i assignatures", "text": "En el títol d'un **llibre**, una **pel·lícula** o una obra d'art, només la **primera paraula** (i els noms propis): *El mut de la campana*. Les **publicacions periòdiques**, en canvi, porten majúscula en tots els substantius i adjectius: *Revista d'Estudis Fallers*. Els documents legals **singulars** també (*el Codi Penal*), però les lleis **regulars** només en la primera: *la Llei d'ús i ensenyament del valencià*. Les **assignatures** i titulacions van amb majúscula; la disciplina genèrica, no.", "table": {"head": ["majúscula", "minúscula"], "rows": [["*fa classes de Física*", "*és un expert en química nuclear*"], ["*la Constitució Espanyola*", "*la nova llei del tabac*"]]}}, {"title": "Topònims i majúscules amb accent", "text": "En els topònims valencians, els **articles i preposicions** van en minúscula (*l'Eliana*, *la Font d'en Carròs*), però en els no adaptats, no: *La Spezia*. El **genèric** geogràfic va en minúscula (*el carrer Ample*, *la serra de Mariola*), tret que forme part del nom (*la Vall d'Albaida*). Recorda que la majúscula **conserva l'accent** i la dièresi (*Òscar*, *ALTA TRAÏCIÓ*), que en un dígraf només va en majúscula la **primera lletra** (*Lluïsa*) i que en un compost aglutinat, només la del primer formant (*Vila-real*)."}], "remember": ["*?*, *!* i *...* que no tanquen la frase: minúscula darrere.", "Dos punts: minúscula, excepte cites i documents (*SOL·LICITE: Que...*).", "Nom concret, majúscula (*la Universitat*); genèric o plural, minúscula (*cada ajuntament*).", "Càrrecs i tractaments sencers en minúscula; abreviatures i fórmules protocol·làries, en majúscula.", "Llibres, només la primera paraula; diaris i revistes, totes les paraules significatives."], "sources": [{"gram": "GVB", "section": "12.7", "title": "Després de dos punts", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_dos_punts"}, {"gram": "GVB", "section": "12.8", "title": "Després de parèntesi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=12_8"}, {"gram": "GVB", "section": "12.11", "title": "Formes de tractament", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_formes_tractament"}, {"gram": "GVB", "section": "12.16", "title": "Noms d'institucions, organismes i empreses", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_empreses"}, {"gram": "GVB", "section": "12.17", "title": "Denominacions correferents", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=12_17"}, {"gram": "GVB", "section": "12.19", "title": "Noms d'institucions públiques i religioses", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=12_19"}, {"gram": "GVB", "section": "12.29", "title": "Titulacions oficials", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=12_29"}, {"gram": "GVB", "section": "12.30", "title": "Títols de llibres, pel·lícules i publicacions", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_titols_llibres"}, {"gram": "GVB", "section": "12.32", "title": "Títols de documents oficials", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=12_32"}, {"gram": "GNV", "section": "6.1.1", "title": "Consideracions generals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=6_1_1"}, {"gram": "GNV", "section": "6.1.2", "title": "La funció demarcativa", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=6_1_2"}, {"gram": "GNV", "section": "6.1.3", "title": "La funció distintiva", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=majuscules_funcio_distintiva"}, {"gram": "GNV", "section": "7.2", "title": "Contacte entre signes de puntuació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=7_2"}]}},
  {"type": "b2_fon_puntuacio", "lesson": {"intro": "Aprendràs a posar (i a no posar) la coma, a puntuar els diàlegs amb el guió, a encaixar unes cometes dins d'altres i a combinar els signes quan coincidixen.", "blocks": [{"title": "La coma que canvia el sentit", "text": "El **vocatiu** sempre va separat amb coma: *Mira, Jaume, no pense repetir-t'ho*. Els **incisos explicatius** van entre dues comes, que s'obrin i es tanquen. Amb les relatives, la coma **canvia el significat**: la **explicativa** (amb comes) parla de tots; l'**especificativa** (sense comes) restringix.", "examples": ["Els espectadors, que estaven cansats, se'n van anar. (= tots)", "Els espectadors que estaven cansats se'n van anar. (= només els cansats)"]}, {"title": "Comes obligatòries, opcionals i prohibides", "text": "Posa coma quan la **subordinada temporal o condicional va davant** (*Si no t'agrada, ...*), per a aïllar connectors com *per tant* o *no obstant això* i per a marcar el **verb elidit**. Si les oracions són curtes, pot ometre's; si la subordinada va darrere, no cal. **Mai** entre el **subjecte i el verb**, ni entre el **verb i els complements**, encara que siguen llargs.", "examples": ["Quan arribàrem al teatre, la representació ja havia començat.", "Ja havien començat a dinar quan arribàrem.", "No sabem, per tant, com va poder fugir.", "Jo prendré café; ella, te."], "watch": [{"wrong": "Els representants dels sindicats, van manifestar la seua oposició.", "right": "Els representants dels sindicats van manifestar la seua oposició."}]}, {"title": "Punt i coma i dos punts en textos llargs", "text": "El **punt i coma** separa grups que ja porten comes (davant de l'últim, si va amb *i*, coma) i va davant de connectors com *no obstant això* o *tanmateix* en oracions llargues. Els **dos punts** introduïxen una enumeració, una cita, una **causa**, una **conseqüència** o una **conclusió**. Mai entre una **preposició** i el seu nom.", "examples": ["Hi assistiren la directora, Sra. Melià; el secretari, Sr. Martí, i el vocal, Sr. Grau.", "L'informe és negatiu; no obstant això, es pot revisar l'expedient.", "Ha nevat tota la nit: les carreteres estan tallades."], "watch": [{"wrong": "L'obra ha sigut dirigida per: Carles Mira.", "right": "L'obra ha sigut dirigida per Carles Mira."}]}, {"title": "El guió en el diàleg", "text": "El **guió** (—) marca l'inici de cada intervenció i emmarca les paraules del **narrador**. Si el narrador **interromp** el personatge, el seu comentari va entre **dos guions** i la puntuació de la frase va darrere del de tancament. Si el comentari acaba la intervenció, el model de la GVB no tanca el guió (davant de punt, el de tancament pot ometre's).", "table": {"head": ["cas", "exemple"], "rows": [["el narrador tanca", "*—Torna prompte —va dir Júlia.*"], ["el narrador interromp i seguix oració nova", "*—Ja ho sé —va dir Pau—. Però no puc fer-hi res.*"], ["el narrador interromp la frase", "*—Vine —va dir—, que és tard.*"], ["pregunta + narrador", "*—On vas? —li va preguntar sa mare.*"]]}}, {"title": "Cometes dins de cometes", "text": "Les cometes dobles poden ser **baixes** (« ») o **altes** (“ ”). Si dins d'una cita n'hi ha una altra, usa les **altes dins de les baixes**, o les **simples** (‘ ’) dins de les altes. Les cometes també marquen els títols de **capítols**, **articles** i **conferències**, i les simples, el **significat** d'una paraula. Les paraules de les quals es parla (ús metalingüístic) s'escriuen en **cursiva**.", "examples": ["Joan recordava: «El director deia: “Ací no hi ha problemes, sinó reptes”».", "És un fragment de l'article «Tribus urbanes».", "La paraula *segur* significa ‘exempt de risc’."]}, {"title": "Quan els signes coincidixen", "text": "Darrere de ***?***, ***!*** i ***...*** no es posa mai **punt**, però sí coma o punt i coma. La **coma** que exigix la frase va **darrere** del parèntesi o de les cometes de tancament. El **punt** va **fora** si el parèntesi o la cita s'han obert dins de la frase, i **dins** si el parèntesi comença després de punt.", "examples": ["Em va preguntar: «Vindràs a la festa?», i no vaig saber què dir.", "Quan arribem a Morella (si arribem), et telefonaré.", "El cicle serà al juliol. (Per a més informació, consulteu la web.)"], "watch": [{"wrong": "Quan vindràs?. No sé si vindrà....", "right": "Quan vindràs? No sé si vindrà..."}]}], "remember": ["Relativa amb comes = tots; sense comes = només alguns.", "Mai coma entre subjecte i verb ni entre verb i complement.", "Narrador que interromp: entre dos guions, i la puntuació darrere del segon.", "Cometes: « » → “ ” → ‘ ’.", "Ni *?.*, ni *!.*, ni *....*: la coma o el punt, segons la frase, darrere del parèntesi o les cometes."], "sources": [{"gram": "GVB", "section": "13.2.8", "title": "Usos metalingüístics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=13_2_8"}, {"gram": "GVB", "section": "15.3.1", "title": "Usos de la coma", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=coma"}, {"gram": "GVB", "section": "15.3.3", "title": "Usos incorrectes de la coma", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=15_3_3"}, {"gram": "GVB", "section": "15.4", "title": "El punt i coma", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=punt_i_coma"}, {"gram": "GVB", "section": "15.6.1", "title": "Usos dels dos punts", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=dos_punts"}, {"gram": "GVB", "section": "15.6.3", "title": "Ús incorrecte dels dos punts", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=dos_punts"}, {"gram": "GVB", "section": "15.10", "title": "Els guions", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=guions"}, {"gram": "GVB", "section": "15.11.2", "title": "Combinació dels parèntesis amb altres signes de puntuació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=combinacio_parentesis_altres_signes"}, {"gram": "GVB", "section": "15.13.1", "title": "Usos de les cometes", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=cometes"}, {"gram": "GVB", "section": "15.13.2", "title": "Combinació de les cometes amb altres signes de puntuació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=15_13_2"}, {"gram": "GNV", "section": "7.2", "title": "Contacte entre signes de puntuació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=7_2"}, {"gram": "GNV", "section": "7.3.1", "title": "La coma", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=7_3_1"}, {"gram": "GNV", "section": "7.5.1", "title": "Els guions", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=7_5_1"}, {"gram": "GNV", "section": "7.5.4", "title": "Les cometes", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=7_5_4"}]}}
]$data$::jsonb) AS l(type text, lesson jsonb)
WHERE r.category = 'fonetica_ortografia' AND r.difficulty = 'B2' AND r.type = l.type;

-- ============================================================
-- Origen: 20261013150000_llicons_morfosintaxi_b2.sql
-- ============================================================
-- Lliçons fixes de la Morfosintaxi del B2 (botó «Aprendre lliçó»).
-- Com les del B1 (20261001160000), cada lliçó és una adaptació didàctica de nivell B2
-- redactada a partir de:
--   - l'abast de cada contingut del B2 (Quadern B2 de la JQCV, 3.2.2), descrit en
--     20261013120000_practice_morfosintaxi_b2.sql;
--   - les regles de la Gramàtica valenciana bàsica (GVB) i de la Gramàtica normativa
--     valenciana (GNV) de l'AVL, descarregades una sola vegada en assets-src/avl/.
-- El contingut es guarda en metadata.lesson (mateix format que en el B1). La migració de
-- continguts (20261013120000) conserva metadata.lesson si es torna a aplicar.
-- Tornar a aplicar este fitxer no canvia res més.

UPDATE public.resources r SET
  metadata = coalesce(r.metadata, '{}'::jsonb) || jsonb_build_object('lesson', l.lesson)
FROM jsonb_to_recordset($data$[
  {"type": "b2_mor_substantius", "lesson": {"intro": "Aprendràs els femenins irregulars i invariables, els noms que canvien de significat segons el gènere, els que tenen un gènere diferent del castellà i els plurals que no varien.", "blocks": [{"title": "Femenins amb una altra paraula", "text": "Alguns noms **no formen el femení amb una terminació**: el femení és una **paraula diferent**. En altres casos és al revés: el **masculí** es forma a partir del femení amb ***-ot*** (*bruixa* → *bruixot*). Per als animals que tenen un sol nom (**epicens**) s'afig *mascle* o *femella*: *el rossinyol femella*.", "table": {"head": ["masculí", "femení"], "rows": [["*ase*", "*somera*"], ["*cavall*", "*egua*"], ["*moltó*", "*ovella*"], ["*bou*", "*vaca*"], ["*marit*", "*muller*"], ["*gendre*", "*nora*"], ["*abellot*", "*abella*"]]}}, {"title": "Invariables i professions", "text": "Noms com *cantant*, *fiscal*, *policia*, *guia* o *artista* tenen **una sola forma**: el gènere es veu en l'**article i l'adjectiu**. Moltes professions han creat un **femení regular**: *arquitecta*, *psiquiatra*, *fotògrafa*, *fustera*. Si el càrrec té **nom i adjectiu**, **tots dos** canvien de gènere.", "examples": ["**La** guia **alacantina** era molt simpàtica.", "**La primera ministra** ha presentat el pressupost.", "Ha signat el document **una traductora jurada**."], "watch": [{"wrong": "la primera ministre", "right": "la primera ministra"}, {"wrong": "la psiquiatre", "right": "la psiquiatra"}]}, {"title": "El gènere canvia el significat", "text": "Hi ha parelles de noms **iguals en la forma** que volen dir **coses diferents** segons que siguen masculins o femenins. L'article és el que t'indica quin significat tenen.", "table": {"head": ["masculí", "femení"], "rows": [["*el clau*: per a clavar", "*la clau*: per a obrir"], ["*el coma*: estat patològic", "*la coma*: signe de puntuació"], ["*el fi*: objectiu", "*la fi*: acabament"], ["*el pols*: batec", "*la pols*: partícules"], ["*el son*: acte de dormir", "*la son*: ganes de dormir"], ["*el pudor*: vergonya", "*la pudor*: mala olor"], ["*un editorial*: article", "*una editorial*: empresa"]]}}, {"title": "Compte amb el gènere", "text": "Segons la normativa, són **masculins** *el dubte*, *el costum*, *el senyal*, *el deute*, *el marge*, *el compte*, *el llegum* i *un avantatge*. En canvi, són **femenins** *la dent*, *la calor*, *la suor*, *la remor*, *una olor*, *una anàlisi*, *la síndrome* i *una marató*. L'adjectiu **concorda** amb este gènere.", "examples": ["Tinc **un dubte** sobre la data de l'examen.", "De la cuina ve **una olor** molt forta.", "Els resultats de **l'anàlisi clínica** són normals."], "watch": [{"wrong": "una dubte", "right": "un dubte"}, {"wrong": "el anàlisi clínic", "right": "l'anàlisi clínica"}, {"wrong": "un olor molt fort", "right": "una olor molt forta"}]}, {"title": "Plurals que no canvien", "text": "Són **invariables** en nombre: els **femenins** en *-s* (*la càries*, *les càries*), els **masculins plans o esdrúixols** en *-s* (*el virus*, *els virus*), alguns **aguts** (*el fons*, *el temps*, *l'ens*) i els **compostos** amb el segon element en plural (*un comptagotes*, *uns comptagotes*). En els compostos separats de **dos noms** només varia el **primer**.", "examples": ["Han detectat **dos virus** nous.", "Compra **uns comptagotes** a la farmàcia.", "A les **hores punta** passen **camions cisterna**.", "Han vingut dos **guàrdies civils**."], "watch": [{"wrong": "els virusos", "right": "els virus"}, {"wrong": "les hores puntes", "right": "les hores punta"}]}], "remember": ["*Ase*/*somera*, *moltó*/*ovella*, *gendre*/*nora*: el femení és una altra paraula.", "*La guia*, *la fiscal*, *la cantant*: el gènere es veu en l'article i l'adjectiu.", "*El fi* (objectiu) / *la fi* (final); *el pols* (batec) / *la pols* (partícules).", "Masculins: *el dubte*, *el costum*, *el senyal*. Femenins: *la dent*, *l'anàlisi*, *l'olor*.", "*El virus*, *els virus*; *un comptagotes*, *uns comptagotes*."], "sources": [{"gram": "GVB", "section": "16.1", "title": "Introducció", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=substantius_formacio_femeni"}, {"gram": "GVB", "section": "16.2.3", "title": "Altres casos", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=altres_casos_formacio_femeni"}, {"gram": "GVB", "section": "16.4", "title": "El gènere com a marca semàntica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=16_4"}, {"gram": "GVB", "section": "16.5", "title": "Vacil·lacions en el gènere d'alguns substantius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=16_5"}, {"gram": "GVB", "section": "16.7", "title": "La marca de gènere en les professions", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=16_7"}, {"gram": "GVB", "section": "17.3", "title": "Substantius invariables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=substantius_invariables"}, {"gram": "GVB", "section": "17.6", "title": "La flexió de nombre en les paraules compostes", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=17_6"}, {"gram": "GNV", "section": "10.2.2", "title": "La formació del femení a partir de masculins acabats en vocal", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=10_2_2"}, {"gram": "GNV", "section": "10.2.3", "title": "Altres casos", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=10_2_3"}, {"gram": "GNV", "section": "10.3.1", "title": "El gènere com a marca semàntica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=10_3_1"}, {"gram": "GNV", "section": "10.3.2", "title": "Observacions sobre el gènere d'alguns substantius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=10_3_2"}, {"gram": "GNV", "section": "10.3.3", "title": "La marca de gènere en les professions", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=10_3_3"}, {"gram": "GNV", "section": "11.3", "title": "Substantius invariables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=substantius_invariables"}, {"gram": "GNV", "section": "11.7", "title": "La flexió de nombre en les paraules compostes", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=11_7"}]}},
  {"type": "b2_mor_adjectius", "lesson": {"intro": "Aprendràs a flexionar els adjectius en *-ç* i els noms en *-òleg*, a distingir els adjectius d'una i de dos terminacions, a fer els plurals en *-os* i a concordar l'adjectiu amb més d'un nom.", "blocks": [{"title": "Adjectius en *-aç*, *-iç* i *-oç*", "text": "Els adjectius acabats en ***-ç*** tenen **una sola forma en singular** per als dos gèneres, però **dos en plural**: ***-os*** per al masculí i ***-es*** per al femení. Davant de *e* la *ç* passa a ***c***.", "table": {"head": ["singular", "plural m.", "plural f."], "rows": [["*audaç*", "*audaços*", "*audaces*"], ["*feliç*", "*feliços*", "*felices*"], ["*feroç*", "*feroços*", "*feroces*"], ["*vivaç*", "*vivaços*", "*vivaces*"]]}, "examples": ["És una xiqueta molt **precoç**.", "El govern ha pres unes mesures **eficaces**."], "watch": [{"wrong": "unes vacances feliçes", "right": "unes vacances felices"}, {"wrong": "una investigadora perspicaça", "right": "una investigadora perspicaç"}]}, {"title": "*-òleg*, *-òloga*", "text": "Les paraules acabades en ***-òleg*** fan el femení en ***-òloga***. En plural, el masculí afig *-s* (*biòlegs*) i el femení canvia *-ga* per ***-gues*** (*biòlogues*), com *llarga*, *llargues*.", "table": {"head": ["masculí", "femení", "plural f."], "rows": [["*biòleg*", "*biòloga*", "*biòlogues*"], ["*arqueòleg*", "*arqueòloga*", "*arqueòlogues*"], ["*filòleg*", "*filòloga*", "*filòlogues*"]]}, "watch": [{"wrong": "Ma germana és sociòlega.", "right": "Ma germana és sociòloga."}]}, {"title": "Una terminació o dos?", "text": "Són **invariables** en gènere els acabats en ***-a* àtona** (*hipòcrita*, *cosmopolita*, *agrícola*), la majoria en ***-e*** (*salvatge*, *enorme*) i els acabats en *-al*, *-el*, *-il*, *-ant*, *-ent*, *-ar*, *-erior* (*excel·lent*, *inferior*), a més de *breu*, *greu*, *gran* o *suau*. Però tenen femení *pobre* → ***pobra***, *ample* → *ampla* i tots els acabats en ***-cte*, *-pte* i *-gne*** (*exacta*, *apta*, *digna*), i també *calenta*, *valenta*, *lluenta*.", "examples": ["Viu en una ciutat molt **cosmopolita**.", "Necessitem una resposta **exacta**.", "Ha obtingut una qualificació **excel·lent**."], "watch": [{"wrong": "una falta greva", "right": "una falta greu"}, {"wrong": "una sopa calent", "right": "una sopa calenta"}]}, {"title": "Plurals en *-os*", "text": "Els masculins acabats en ***-s*** o ***-x*** fan el plural en ***-os***: *gris* → *grisos*, *annex* → *annexos*. Si la *s* sona **sorda**, es **duplica**, com en el femení: *escàs* → *escassos*, *gros* → *grossos*. Els acabats en ***-ig*, *-sc*, *-st*, *-xt*** admeten **dos plurals**; amb *-os*, *-ig* passa a *j* o *tj*.", "table": {"head": ["singular", "plural en -os", "plural en -s"], "rows": [["*roig*", "*rojos*", "*roigs*"], ["*boig*", "*bojos*", "*boigs*"], ["*lleig*", "*lletjos*", "*lleigs*"], ["*fosc*", "*foscos*", "*foscs*"], ["*trist*", "*tristos*", "*trists*"]]}}, {"title": "Un adjectiu per a dos noms", "text": "Si l'adjectiu va **darrere** de dos noms, va en **plural**: en **femení** si tots dos són femenins i en **masculí** si n'hi ha de cada gènere. Si va **davant**, concorda **amb el primer**. Un **nom usat com a adjectiu** sol quedar **invariable**.", "examples": ["Una camisa i una jaqueta **blaves**.", "Té la cama i el braç **trencats**.", "Cal **la necessària** discreció i respecte.", "Duien unes bruses **taronja**."], "watch": [{"wrong": "un aparador i una taula rústiques", "right": "un aparador i una taula rústics"}]}], "remember": ["*Feliç*: *feliços* (m.), *felices* (f.); en singular, una sola forma.", "*-òleg* → *-òloga* → *-òlogues*.", "*Pobra*, *ampla*, *exacta*, *calenta*; però *salvatge*, *greu*, *excel·lent* no canvien.", "*Escàs* → *escassos*; *roig* → *rojos* o *roigs*.", "Darrere de noms de gènere diferent, masculí plural; davant, concorda amb el primer."], "sources": [{"gram": "GVB", "section": "18.1.2", "title": "Els adjectius variables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adjectius_variables"}, {"gram": "GVB", "section": "18.1.3", "title": "Els adjectius invariables respecte al gènere", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adjectius_invariables"}, {"gram": "GVB", "section": "18.2.1", "title": "La formació del plural", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=nombre_adjectius_formacio_plurals"}, {"gram": "GVB", "section": "18.3", "title": "La concordança de l'adjectiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=concordanca_adjectiu"}, {"gram": "GNV", "section": "10.2.1", "title": "La formació del femení a partir de masculins acabats en consonant", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=10_2_1"}, {"gram": "GNV", "section": "12.3", "title": "La concordança de l'adjectiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=12_3"}, {"gram": "GNV", "section": "13.3", "title": "Els adjectius invariables respecte al gènere", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=adjectius_invariables"}, {"gram": "GNV", "section": "14.2", "title": "La formació del plural", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=14_2"}]}},
  {"type": "b2_mor_determinants", "lesson": {"intro": "Aprendràs a substituir el *lo* neutre en registre formal, a usar els tres graus dels demostratius en l'espai i en el discurs i a triar entre possessius tònics i àtons.", "blocks": [{"title": "El *lo* neutre en registre formal", "text": "*Lo* neutre només és acceptable en usos **orals espontanis** (o quan es transcriuen) i sempre que **no siga un calc** del castellà. En els **registres formals** s'evita i es recorre a l'article ***el***, a *allò que* o a un **nom concret**.", "table": {"head": ["amb *lo*", "registre formal"], "rows": [["*lo que anava buscant*", "*el que* (*allò que*) *anava buscant*"], ["*lo millor de la pel·lícula*", "*la part millor de la pel·lícula*"], ["*Lo cert és que...*", "*El cas* (*la veritat*) *és que...*"], ["*lo bo i lo roín*", "*el que està bé i el que està malament*"], ["*Lo de la loteria...*", "*L'assumpte de la loteria...*"]]}}, {"title": "*Lo* que cal evitar sempre", "text": "El *lo* **intensiu** de les exclamatives **no és acceptable en cap context**: usa *que*, *com* o *tan*. També s'han de substituir els **modismes calcats** amb *lo*.", "examples": ["**No saps com** treballen **de bé**!", "**Tan bonic que** és, i no para de plorar!", "Ho faré **tan ràpid com** puga. Vine **com més prompte millor**."], "watch": [{"wrong": "lo qual és molt significatiu", "right": "la qual cosa (o cosa que) és molt significativa"}, {"wrong": "per lo tant / per lo menys", "right": "per tant / almenys"}, {"wrong": "en lo referent a", "right": "pel que fa a (respecte a, quant a)"}, {"wrong": "lo suficientment madur", "right": "prou madur"}]}, {"title": "Tres graus de proximitat", "text": "El valencià manté el **sistema ternari**: **1r grau**, prop de qui parla; **2n grau**, prop de qui escolta; **3r grau**, lluny de tots dos. La majoria de parlars no valencians tenen un sistema **binari**: *aquest* (prop) i *aquell* (lluny). *Aquests* té la variant ***aquestos***, i en alguns parlars *aquí* equival a *ací*.", "table": {"head": ["grau", "determinant", "neutre", "adverbi"], "rows": [["1r", "*este* / *aquest*", "*açò*", "*ací*"], ["2n", "*eixe* / *aqueix*", "*això*", "*ahí*"], ["3r", "*aquell*", "*allò*", "*allí*, *allà*"]]}, "examples": ["Vine, mira **açò** que m'acabe de trobar.", "Què fas **ahí**?", "Porta'm **allò** que hi ha damunt de la taula."]}, {"title": "Demostratius en el discurs i en el temps", "text": "En un text, el de **1r grau** remet a l'antecedent **més pròxim** i el de **3r grau**, al **més llunyà**. Amb noms de temps, el **1r grau** inclou el moment present o pròxim; el **2n** i el **3r** remeten a períodes **llunyans**. Per a l'any, s'usa *enguany*.", "examples": ["Vaig llegir el diari i la revista, però només **esta** arreplegava la notícia.", "**Este** estiu fa molta calor.", "**Aquell** estiu vam anar a Agres. **Enguany** hi tornarem."]}, {"title": "Possessius tònics i àtons", "text": "Els **àtons** (*mon*, *ta*, *sos*, *ses*...) van **sense article** i només amb **noms de parentiu**, amb *casa* i en *en ma vida*. El **tònic** es **posposa** amb l'**indefinit** o sense article; en algunes locucions alterna amb *de* + pronom. *Llur* és arcaic, de registres molt formals. Si la possessió ja és clara, n'hi ha prou amb l'**article**.", "examples": ["**Sos** germans viuen a Alcoi i **ses** cosines, a Elx.", "És **un amic meu** de la infància.", "Anava **darrere seu**. Viu **prop nostre**.", "**Renta't les mans**."], "watch": [{"wrong": "la ma tia", "right": "ma tia (o la meua tia)"}, {"wrong": "la mia casa", "right": "la meua (o meva) casa"}]}], "remember": ["En registre formal, *el que*, *la part millor*, *el cas és que* en lloc de *lo*.", "*Lo bé que...*, *lo qual*, *per lo tant*: mai. Millor *com... de bé*, *la qual cosa*, *per tant*.", "*Este/açò/ací*, *eixe/això/ahí*, *aquell/allò/allí*.", "*Mon*, *ta*, *sos*: sense article i amb parentiu o *casa*.", "*Un amic meu*, *darrere seu*, *prop nostre*."], "sources": [{"gram": "GVB", "section": "19.5", "title": "L'anomenat article neutre", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=19_5"}, {"gram": "GVB", "section": "19.5.1", "title": "Usos amb funció substantivadora", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=article_neutre_substantivador"}, {"gram": "GVB", "section": "19.5.2", "title": "Altres usos", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=19_5_2"}, {"gram": "GVB", "section": "20.2.1", "title": "Els determinants demostratius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=determinants_demostratius"}, {"gram": "GVB", "section": "20.2.2", "title": "Els pronoms neutres demostratius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronoms_neutres_demostratius"}, {"gram": "GVB", "section": "21.2.2", "title": "Posició dels possessius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=posicio_possessius"}, {"gram": "GVB", "section": "21.2.3", "title": "Alternança dels possessius i els pronoms personals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=21_2_3"}, {"gram": "GVB", "section": "21.3", "title": "Els possessius àtons", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=possessius_atons"}, {"gram": "GNV", "section": "15.5", "title": "L'article neutre", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=15_5"}, {"gram": "GNV", "section": "16.2", "title": "Les classes de demostratius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=16_2"}, {"gram": "GNV", "section": "16.3.1", "title": "Caracterització general", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=16_3_1"}, {"gram": "GNV", "section": "16.3.2", "title": "Aspectes formals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=16_3_2"}, {"gram": "GNV", "section": "16.3.3", "title": "Usos díctics i anafòrics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=16_3_3"}, {"gram": "GNV", "section": "16.4", "title": "Els pronoms neutres demostratius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=16_4"}, {"gram": "GNV", "section": "16.5.2", "title": "Aspectes formals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=16_5_2"}, {"gram": "GNV", "section": "17.2.1", "title": "La forma dels possessius tònics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=17_2_1"}, {"gram": "GNV", "section": "17.2.2", "title": "Aspectes sintàctics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=17_2_2"}, {"gram": "GNV", "section": "17.3", "title": "Els possessius àtons", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=17_3"}]}},
  {"type": "b2_mor_pronoms_forts", "lesson": {"intro": "Aprendràs quan el pronom fort aporta èmfasi, els casos difícils de *jo* i *mi*, l'ús del reflexiu *si*, les formes de cortesia *vosté*, *vostés* i *vós* i com evitar el pronom fort referit a coses.", "blocks": [{"title": "Feble o fort: el valor de l'èmfasi", "text": "El pronom **feble** sol (o el subjecte **el·líptic**) és l'opció **no marcada**. Si hi afegim el pronom **fort** (amb *a* quan és complement), donem un valor **contrastiu o emfàtic**: ‘a mi i no a un altre’. Els modificadors concorden amb el **sexe** de qui parla: *jo mateixa*, *jo sola*.", "examples": ["**M'**han avisat. → **M'**han avisat **a mi**.", "A **tu**, qui **t'**ha demanat l'opinió?", "No he parlat amb ningú. → **Jo** no he parlat amb ningú."]}, {"title": "*Jo* o *mi*: casos difícils", "text": "*Mi* va **darrere de preposició** i *jo* és **subjecte**. Però s'usa ***jo*** si una sola preposició regix **dos elements coordinats**, amb *excepte*, *menys*, *llevat de*, *segons* o *malgrat* (usos poc habituals: millor *al meu parer*), i quan el pronom és **subjecte d'un infinitiu**.", "examples": ["La protesta anava contra ella i **jo**. / ...contra ella i contra **mi**.", "Entre tu i **jo** podem acabar el treball.", "Van votar tots **menys jo**.", "Ho van fer sense **jo** dir-li res."], "watch": [{"wrong": "Actuaren contra jo.", "right": "Actuaren contra mi."}]}, {"title": "El reflexiu *si*", "text": "En **3a persona** hi ha un pronom fort **reflexiu**: ***si*** (sense accent), singular o plural, que sol anar amb ***mateix***. També es pot usar *ell*, *ella*... En **1a i 2a** no hi ha forma específica: *de mi mateix*, *de tu mateixa*. Algunes expressions fixes no porten *mateix*.", "examples": ["Carles parlava malament de **si mateix**.", "Ha fet un dibuix **de si mateixa** (o **d'ella mateixa**).", "La notícia el va posar **fora de si**.", "Va tardar mitja hora a **tornar en si**."], "watch": [{"wrong": "Només pensen en sí mateixos.", "right": "Només pensen en si mateixos."}]}, {"title": "*Vosté*, *vostés* i *vós*", "text": "***Vosté*** i ***vostés*** són formes de **cortesia**: es dirigixen a l'interlocutor, però el verb i els febles van en **3a persona**. ***Vós*** es referix a **una persona**, però el verb va en **2a del plural**; hui té un ús restringit (*Vós direu*). En textos administratius i instruccions s'usa molt la **2a del plural** sense pronom.", "table": {"head": ["pronom", "verb", "exemple"], "rows": [["*vosté*", "3a sing.", "*Què desitja vosté?*"], ["*vostés*", "3a pl.", "*Vostés són molt amables.*"], ["*vós*", "2a pl.", "*Vós direu.*"]]}, "examples": ["A **vosté**, què **li** pareix?", "Senyors, ja **poden** passar."]}, {"title": "Pronoms forts referits a coses", "text": "Per a **coses** no uses el pronom fort de complement directe o indirecte: hi ha els **febles**. Darrere de preposició, preferix ***en***, ***hi***, un **demostratiu** o un **relatiu**. El fort és normal com a **reflexiu** o amb *sol*, *a soles* o *mateix*.", "examples": ["Ja he vist la foto i no vull que **me'n** parles.", "Han promés inversions i tots **hi** confien.", "El motor pot funcionar **ell sol**."], "watch": [{"wrong": "No vull que em parles d'ella (la foto).", "right": "No vull que me'n parles."}, {"wrong": "Va presentar un escrit. En ell es plantegen...", "right": "Va presentar un escrit. En este escrit es plantegen..."}]}], "remember": ["Feble sol: neutre. Feble + fort: èmfasi (*m'han avisat a mi*).", "*Per a mi*, però *entre tu i jo*, *menys jo*.", "*Si* és el reflexiu de 3a: *de si mateix*, *fora de si*.", "*Vosté* + 3a persona; *vós* + 2a del plural.", "Per a coses, *en* i *hi*: *me'n parles*, *hi confien*."], "sources": [{"gram": "GVB", "section": "25.3.1", "title": "L'oposició entre jo i mi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=oposicio_jo_mi"}, {"gram": "GVB", "section": "25.3.2", "title": "Les formes de cortesia", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=formes_cortesia"}, {"gram": "GVB", "section": "25.3.3", "title": "Els pronoms reflexius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=25_3_3"}, {"gram": "GVB", "section": "25.3.4", "title": "Els pronoms de tercera persona referits a coses", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=25_3_4"}, {"gram": "GNV", "section": "21.1", "title": "Caracterització general: els pronoms forts i els febles", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=21_1"}, {"gram": "GNV", "section": "21.2", "title": "La forma dels pronoms personals forts", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=21_2"}, {"gram": "GNV", "section": "21.3.1", "title": "L'oposició entre jo i mi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=21_3_1"}, {"gram": "GNV", "section": "21.3.2", "title": "Les formes de cortesia", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=21_3_2"}, {"gram": "GNV", "section": "21.3.3", "title": "Els pronoms reflexius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=21_3_3"}, {"gram": "GNV", "section": "21.3.4", "title": "Els pronoms de tercera persona referits a coses", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=21_3_4"}]}},
  {"type": "b2_mor_pronoms_febles", "lesson": {"intro": "Aprendràs a triar la forma plena, reduïda, reforçada o elidida dels pronoms febles, a escriure'ls bé quan en van dos i a substituir l'atribut i els complements circumstancials amb *ho*, *en* i *hi*.", "blocks": [{"title": "Quatre formes per a cada pronom", "text": "La forma depén de la **posició** i del **so del verb**. **Plena**: darrere de verb acabat en **consonant o diftong decreixent** (*doneu-me*). **Reduïda**: darrere de **vocal** (*dona'm*). **Reforçada**: davant de **consonant** (*em dona*). **Elidida**: davant de **vocal o *h*** (*m'escolta*).", "table": {"head": ["plena", "reduïda", "reforçada", "elidida"], "rows": [["*mirar-me*", "*mira'm*", "*em mira*", "*m'escolta*"], ["*comprar-ne*", "*compra'n*", "*en compra*", "*n'adquirix*"], ["*mirar-lo*", "*mira'l*", "*el mira*", "*l'escolta*"], ["*rebeu-los*", "*mira'ls*", "*els mira*", "*els escolta*"], ["*mirar-nos*", "*mira'ns*", "*ens mira*", "*ens escolta*"]]}, "watch": [{"wrong": "Doneu'm la mà.", "right": "Doneu-me la mà."}, {"wrong": "No vull perdre-me el concert.", "right": "No vull perdre'm el concert."}]}, {"title": "Casos especials d'apòstrof", "text": "***La*** **no s'apostrofa** davant de *i* o *u* **àtones** (*la ignora*, *la utilitza*), però sí davant de tòniques (*l'hissen*, *l'usa*). Davant de verb que comença per *s* se sol usar ***se***: *no se sap*. ***Vos*** pot alternar amb *us* (*escriure-vos* o *escriure-us*). *Les*, *li*, *ho* i *hi* **no canvien mai**.", "examples": ["A la seua germana, no **la** ignora mai.", "La bandera, **l'**hissen cada matí.", "Encara no **se** sap res del resultat.", "Volem escriure-**vos** prompte."]}, {"title": "Dos pronoms junts", "text": "L'**apòstrof** va **tan a la dreta com es puga**. *Em*, *et*, *es* prenen la **forma plena** quan van **primers** davant del verb (*me la*), però s'**elidixen** davant de *ho* i *hi* (*m'ho*). Si el primer acaba en ***-s***, el segon va en **forma reforçada**. Darrere del verb, **guionets**.", "examples": ["Ja **se n'**ha anat. / Ja **se'n** va anar.", "No **li l'**he portat. / **Li'l** portaré demà.", "**Me la** van regalar. Quan **m'ho** diràs?", "**Ens els** portaran demà. / Emportem-**nos-els**!", "Dona-**li-la**!"], "watch": [{"wrong": "Ja s'en ha anat.", "right": "Ja se n'ha anat."}, {"wrong": "Em la van regalar.", "right": "Me la van regalar."}]}, {"title": "L'atribut: *ho*, *en* i *hi*", "text": "L'**atribut** de *ser*, *estar*, *semblar* i *paréixer* es substituïx per ***ho***, siga quin siga el gènere i el nombre, també si és **determinat**. Amb ***en***: un atribut **quantificat i indeterminat** amb *ser*, el **complement amb *de*** d'un adjectiu atribut i *fer de*. El **predicatiu** sol anar amb ***hi***.", "examples": ["Estan cansades? —No, no **ho** estan.", "És el nou director? —Sí que **ho** és.", "Que en sereu molts? —Només **en** serem tres.", "S'ha comprat un ordinador i **n'**està molt content.", "Va arribar cansat? —Sí que **hi** va arribar."], "watch": [{"wrong": "És metgessa? —Sí que la és.", "right": "És metgessa? —Sí que ho és."}]}, {"title": "Complements circumstancials: *hi* i *en*", "text": "***Hi*** substituïx el **lloc** on s'està o on es va, fins i tot si no el demana el verb, i, en registre formal, també la **manera**, l'**instrument** i la **companyia**. ***En*** substituïx l'**origen**: d'on es ve, s'ix o es torna.", "table": {"head": ["complement", "pronom", "exemple"], "rows": [["lloc / destinació", "*hi*", "*Vas a la plaça? Ara hi vaig.*"], ["origen", "*en*", "*Vens de la plaça? Ara en vinc.*"], ["manera", "*hi*", "*Sempre hi parla, tranquil·lament.*"], ["instrument", "*hi*", "*Sense tinta no hi puc escriure.*"], ["companyia", "*hi*", "*Amb ell ja no hi podia viure.*"]]}, "examples": ["Fa temps vivien a Ador, però no sé si encara **hi** viuen.", "Quan jo arribava a l'oficina, Jaume **n'**eixia."]}], "remember": ["Plena darrere de consonant o diftong (*rebeu-los*); reduïda darrere de vocal (*compra'n*).", "*La ignora*, *la utilitza*: *la* no s'apostrofa davant de *i*, *u* àtones.", "Apòstrof a la dreta: *se n'ha anat*; primer pronom en *-s*: *ens els*.", "Atribut amb *ho*: *sí que ho és*, *no ho està*.", "*Hi*: lloc, manera, instrument i companyia; *en*: origen."], "sources": [{"gram": "GVB", "section": "26.3.2", "title": "Formes plenes, reforçades, reduïdes i elidides", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=formes_plenes_elidides"}, {"gram": "GVB", "section": "26.4.2", "title": "La forma dels pronoms febles", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=forma_pronoms_febles"}, {"gram": "GVB", "section": "27.3", "title": "El pronom neutre", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronom_neutre"}, {"gram": "GVB", "section": "27.4.1", "title": "El pronom ne", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronom_ne"}, {"gram": "GVB", "section": "27.4.2", "title": "El pronom hi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronom_hi"}, {"gram": "GNV", "section": "22.3.2", "title": "Formes plenes, reforçades, reduïdes i elidides", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=22_3_2"}, {"gram": "GNV", "section": "22.4.2", "title": "La forma dels pronoms febles", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=22_4_2"}, {"gram": "GNV", "section": "23.3", "title": "El pronom neutre", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=23_3"}, {"gram": "GNV", "section": "23.4.1", "title": "El pronom ne", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=23_4_1"}, {"gram": "GNV", "section": "23.4.2", "title": "El pronom hi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=23_4_2"}]}},
  {"type": "b2_mor_combinacions", "lesson": {"intro": "Aprendràs a combinar dos pronoms febles quan un és reflexiu, *hi* o *en*, a escriure'ls bé davant i darrere del verb i a conjugar *anar-se'n*, *tornar-se'n* i *eixir-se'n*.", "blocks": [{"title": "Reflexiu + complement directe", "text": "L'**orde és fix**: el reflexiu *es* va sempre **primer** i, en primer lloc d'una combinació davant del verb, pren la forma plena ***se***. Davant de *ho* i *hi*, en canvi, s'elidix: *s'ho*, *s'hi*. L'**apòstrof va tan a la dreta com siga possible**: *se n'ha menjat*, no *se'n ha menjat*.", "table": {"head": ["es +", "davant de consonant", "davant de vocal"], "rows": [["*el*", "*se'l* menja", "*se l'*ha menjat"], ["*la*", "*se la* menja", "*se l'*ha comprada"], ["*les*", "*se les* posa", "*se les* ha posades"], ["*ho*", "*s'ho* beu", "*s'ho* ha begut"], ["*en*", "*se'n* menja tres", "*se n'*ha menjat tres"]]}, "watch": [{"wrong": "S'el menja.", "right": "Se'l menja."}, {"wrong": "Se'n ha menjat tres.", "right": "Se n'ha menjat tres."}]}, {"title": "Reflexiu + atribut: *s'hi* i *se'n*", "text": "L'**atribut** dels verbs quasicopulatius de canvi o d'estat (*tornar-se*, *fer-se*, *trobar-se*...) es pronominalitza amb ***hi***: *es* + *hi* → ***s'hi***. Excepció: amb ***fer-se*** quan vol dir **'passar a formar part'**, l'atribut es pronominalitza amb ***en***: ***se'n***.", "examples": ["Deien que es faria més prudent, però no **s'hi** ha tornat.", "—Pere s'ha fet com una bacona. —Sí que **s'hi** ha fet, sí.", "Encara no s'ha fet sòcia del club, però prompte **se'n** farà."]}, {"title": "Complement indirecte + *hi* o *en*", "text": "El pronom de **complement indirecte** va davant de ***hi*** (lloc) o ***en*** (origen, partitiu). *Em* i *et* passen a *m'hi*, *t'hi*; amb *en*, *me'n*, *te'n*. ***Els hi*** és correcte quan *els* és el CI plural i *hi* un lloc.", "examples": ["Li han posat una tireta al genoll. → **Li hi** han posat una tireta.", "Ens posaran una antena al terrat. → **Ens hi** posaran una antena.", "Li han tret una espina del dit. → **Li n'**han tret una.", "Els vam enviar els paquets a l'hotel. → **Els hi** vam enviar els paquets."]}, {"title": "Complement directe + *hi* o *en*", "text": "El **complement directe** va davant de *hi* o *en*. Compte amb *el* + *en*: davant de consonant fa ***l'en*** (mai *le*) i davant de vocal ***el n'***. Darrere del verb s'unixen amb guionets o apòstrofs.", "table": {"head": ["CD +", "davant del verb", "darrere del verb"], "rows": [["*el* + *hi*", "*l'hi* trobaré", "porta-*l'hi*"], ["*la* + *hi*", "*la hi* vaig trobar", "posa-*la-hi*"], ["*els* + *hi*", "*els hi* ha portats", "deixa'*ls-hi*"], ["*el* + *en*", "*l'en* traurem / *el n'*ha tret", "traure-*l'en*"], ["*la* + *en*", "*la'n* traurà / *la n'*ha treta", "traure-*la'n*"], ["*les* + *en*", "*les en* va traure / *les n'*ha tretes", "traure-*les-en*"]]}}, {"title": "Indirecte + directe: *li'l*, *els els*", "text": "Primer el **CI** i després el **CD**: *li'l*, *li l'*, *li la*, *li ho*, *li'n*. Si el primer pronom acaba en ***-s***, el segon pren la **forma reforçada**: ***els els***, *ens el*, *digues-los-ho*. En els parlars valencians més septentrionals *li* fa *hi* darrere del CD (*l'hi*, *la hi*), però en la resta dels parlars valencians, *li'l*, *li la*.", "examples": ["Li he dit la veritat. → **Li l'**he dita.", "Dona el llibre a Joan. → Dona-**li'l**!", "Els vam tornar els diners. → **Els els** vam tornar.", "Envia el catàleg als clients. → Envia'**ls-el**!"], "watch": [{"wrong": "Ho li explicaré.", "right": "Li ho explicaré."}]}, {"title": "*Anar-se'n*, *tornar-se'n*, *eixir-se'n*", "text": "Estos verbs porten ***en*** fix i el pronom reflexiu canvia amb la persona. En **registres formals** es diu ***ens n'anem*** i ***aneu-vos-en***; *se n'anem* o *aneu-se'n* només són acceptables en registres poc formals. En l'imperatiu els pronoms van **darrere**.", "table": {"head": ["persona", "present", "imperatiu"], "rows": [["jo", "*me'n vaig*", "—"], ["tu", "*te'n vas*", "*ves-te'n*"], ["ell, ella, vosté", "*se'n va*", "*vaja-se'n*"], ["nosaltres", "*ens n'anem*", "*anem-nos-en*"], ["vosaltres", "*vos* (*us*) *n'aneu*", "*aneu-vos-en*"], ["ells, elles, vostés", "*se'n van*", "*vagen-se'n*"]]}, "examples": ["Ahir **ens en** vam anar a les nou.", "Maria ja **se n'**ha anat.", "**Torna-te'n** a casa!", "Vigila la llet, que **se n'**ix!"]}], "remember": ["Orde fix: reflexiu, CI, CD, *en*, *hi*.", "*Es*, *em*, *et* en primer lloc fan *se*, *me*, *te*; davant de *ho* i *hi*, *s'*, *m'*, *t'*.", "L'apòstrof, tan a la dreta com es puga: *se n'ha anat*, *li l'he dit*.", "Darrere d'un pronom en *-s*, forma reforçada: *els els*, *ens en*.", "Formal: *ens n'anem*, *aneu-vos-en*; no *se n'anem*."], "sources": [{"gram": "GVB", "section": "10.14", "title": "L'apostrofació dels pronoms febles", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=apostrofacio_pronoms_febles"}, {"gram": "GVB", "section": "26.3.2", "title": "Formes plenes, reforçades, reduïdes i elidides", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=formes_plenes_elidides"}, {"gram": "GVB", "section": "26.4.1", "title": "L'orde dels pronoms febles", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=orde_pronoms_febles"}, {"gram": "GVB", "section": "26.4.2", "title": "La forma dels pronoms febles", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=forma_pronoms_febles"}, {"gram": "GVB", "section": "27.4.1", "title": "El pronom ne", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronom_ne"}, {"gram": "GVB", "section": "27.4.2", "title": "El pronom hi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronom_hi"}, {"gram": "GNV", "section": "22.4.1", "title": "L'orde dels pronoms febles", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=22_4_1"}, {"gram": "GNV", "section": "22.4.2", "title": "La forma dels pronoms febles", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=22_4_2"}, {"gram": "GNV", "section": "23.4.1", "title": "El pronom ne", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=23_4_1"}, {"gram": "GNV", "section": "23.4.2", "title": "El pronom hi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=23_4_2"}, {"gram": "GNV", "section": "33.2.1", "title": "Predicacions no verbals primàries", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=predicacions_no_verbals_primaries"}]}},
  {"type": "b2_mor_interrogatius", "lesson": {"intro": "Aprendràs a triar entre *quin*, *què* i *qui*, a fer preguntes indirectes, a distingir *per què*, *perquè* i *el perquè* i a construir exclamacions amb *quin*, *que*, *quant* i *com*.", "blocks": [{"title": "*Quin* per a triar i identificar", "text": "***Quin*** (*quina*, *quins*, *quines*) **acompanya un nom** i pregunta per la **identitat** d'un o diversos elements d'un **conjunt conegut**. *Què* és un **pronom**: va sol, sense nom darrere. Per això diem *quina hora*, *en quin any*, *quins requisits*, i també *quina de les dues*.", "examples": ["**Quina** de les dues propostes t'agrada més?", "**En quin** any es va fundar la universitat?", "**Quins** són els requisits per a matricular-se?", "Saps **per quin** carrer he d'entrar?"], "watch": [{"wrong": "A què hora comença la reunió?", "right": "A quina hora comença la reunió?"}]}, {"title": "*Qui*, *què* i *que*", "text": "***Qui*** pregunta per **persones** i ***què***, per **coses**; tots dos poden anar darrere de preposició: *a qui*, *amb qui*, *per qui*, *de què*, *per a què*. *Què* tònic porta **accent greu** (encara que es pronuncie amb *e* tancada). ***Que*** sense accent és la conjunció, el relatiu sense preposició i l'exclamatiu.", "table": {"head": ["forma", "valor", "exemple"], "rows": [["*què*", "interrogatiu", "*De què* parleu?"], ["*què*", "relatiu amb preposició", "La casa *de què* et vaig parlar."], ["*que*", "conjunció", "Diu *que* arribarà tard."], ["*que*", "exclamatiu", "*Que* estrany!"]]}, "examples": ["**Amb qui** parlaves per telèfon?", "**Per qui** vas votar?", "**Què** vols dir exactament amb això?"]}, {"title": "Preguntes indirectes", "text": "La pregunta pot anar **dins d'una altra oració**, com a complement directe d'un verb (*saber*, *preguntar*, *entendre*...). Els interrogatius hi mantenen la forma i l'**accent**: *no sé què*, *pregunta-li quan*. Si la pregunta és de sí o no, s'introduïx amb ***si***.", "examples": ["Encara no entenc **què** vols que faça.", "No sé **quin** autobús he d'agafar.", "M'han preguntat **quantes** maletes duc.", "No sé **si** podré contestar-te."], "watch": [{"wrong": "Em va preguntar que volia.", "right": "Em va preguntar què volia."}]}, {"title": "*On*, *com*, *quan*, *quant*", "text": "Estos interrogatius fan de **circumstancials** i poden portar preposició: ***on*** o ***a on***, *d'on*, *per on*; ***com***; *des de quan*, *fins quan*. ***Quant*** davant de nom concorda (*quanta*, *quants*, *quantes*) i davant de **masculí singular** porta *de*: *quant de temps*. Amb un verb queda fix: *Quant costa?*", "examples": ["**D'on** véns tan cansat?", "**Des de quan** coneixes la directora?", "**Quantes** vegades t'ho he de repetir?", "**A com** van les peres hui?"]}, {"title": "*Per què*, *perquè*, *el perquè*", "text": "***Per què*** (separat, amb accent) pregunta la **causa**, també en preguntes indirectes. ***Perquè*** (junt) és la conjunció **causal** i també la **final** dels registres formals, amb subjuntiu. ***El perquè***, amb article, és un nom: 'el motiu'.", "examples": ["**Per què** ho preguntes? —**Perquè** m'interessa.", "M'agradaria saber **per què** has canviat d'opinió.", "T'ho explique **perquè** ho entengues bé.", "Ningú no en coneix **el perquè**."]}, {"title": "Exclamacions", "text": "***Quin*** + nom destaca una **qualitat**; ***quant*** + nom, una **quantitat**; ***que*** va davant d'**adjectiu o adverbi**; ***com*** + verb pondera el que es fa. Darrere sol vindre un *que* àton opcional. **No** uses *que* davant d'un nom. El signe *¡* inicial és opcional.", "examples": ["**Quina** sort has tingut!", "**Quants** llibres (que) té ta tia!", "**Que** bonic (que) és este paisatge!", "**Com** plou!"], "watch": [{"wrong": "Que fred que fa!", "right": "Quin fred que fa!"}]}], "remember": ["*Quin* + nom (triar, identificar); *què*, pronom sol.", "*Què* tònic porta accent, també en preguntes indirectes.", "*Quant de* només davant de masculí singular: *quant de temps*.", "*Per què* pregunta; *perquè* respon o indica finalitat; *el perquè* és un nom.", "Exclamació: *quin fred!*, *que bonic!*, mai *que* + nom."], "sources": [{"gram": "GVB", "section": "7.7", "title": "L'accentuació diacrítica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=accentuacio_diacritica"}, {"gram": "GVB", "section": "29.2", "title": "Qui", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=interrogatiu_qui"}, {"gram": "GVB", "section": "29.3", "title": "Què", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=interrogatiu_que_accentuat"}, {"gram": "GVB", "section": "29.4", "title": "Quin", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=interrogatiu_quin"}, {"gram": "GVB", "section": "29.5", "title": "Quant", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=interrogatiu_quant"}, {"gram": "GVB", "section": "29.6", "title": "Adverbis interrogatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=interrogatiu_quan"}, {"gram": "GVB", "section": "29.7", "title": "Formes i usos dels exclamatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=exclamatius"}, {"gram": "GVB", "section": "41.4.4", "title": "Les conjuncions causals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_causals"}, {"gram": "GVB", "section": "41.4.5", "title": "Les conjuncions finals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_finals"}, {"gram": "GNV", "section": "7.4", "title": "Els signes d'entonació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=7_4"}, {"gram": "GNV", "section": "15.2", "title": "L'article definit", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=15_2"}, {"gram": "GNV", "section": "25.2.3", "title": "Els interrogatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=25_2_3"}, {"gram": "GNV", "section": "25.3", "title": "Altres tipus d'interrogatives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=25_3"}, {"gram": "GNV", "section": "25.4", "title": "Els exclamatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=exclamatius"}]}},
  {"type": "b2_mor_relatius", "lesson": {"intro": "Aprendràs a triar el relatiu adequat (*que*, *què*, *qui*, *el qual*, *on*...) segons el tipus de relativa i la preposició, a expressar la possessió amb *del qual* i a reprendre una oració amb *cosa que* o *la qual cosa*.", "blocks": [{"title": "Tres classes de relatives", "text": "Les relatives **adjectives** tenen antecedent. Poden ser **especificatives**, que **restringixen** l'antecedent (sense comes), o **explicatives**, que hi afigen informació (**entre comes**). Les **substantives** no tenen antecedent i fan de nom; les **adverbials** fan de circumstancial de lloc, temps o manera.", "table": {"head": ["classe", "exemple"], "rows": [["adjectiva especificativa", "Els xiquets *que no van jugar* han protestat."], ["adjectiva explicativa", "Els xiquets, *que no van jugar*, han protestat."], ["substantiva", "*Qui no treballe* no cobrarà."], ["adverbial", "Seu *on vulgues*."]]}}, {"title": "Sense preposició: *que*", "text": "Sense preposició, el relatiu habitual és ***que***, per a persones i coses. En les **explicatives** pot alternar amb ***el qual***, però **no** amb *qui*. En les **especificatives** no es pot usar *el qual*.", "examples": ["La pel·lícula **que** vam vore ahir era avorrida.", "La meua germana, **que** (o **la qual**) viu a Elx, vindrà demà."], "watch": [{"wrong": "L'home el qual ens va atendre era amable.", "right": "L'home que ens va atendre era amable."}, {"wrong": "Aquell polític, qui no té escrúpols, firmarà.", "right": "Aquell polític, que (o el qual) no té escrúpols, firmarà."}]}, {"title": "Amb preposició: *què*, *qui*, *el qual*", "text": "Darrere de preposició, ***què*** (amb accent) per a coses, ***qui*** per a persones i ***el qual*** per a totes dues; *el qual* concorda amb l'antecedent: *la qual*, *els quals*, *les quals*. *Què* i *qui* només van amb *a*, *de*, *en*, *amb* i, menys sovint, *per*; amb preposicions tòniques o compostes, *el qual*. **No** uses *el que* amb antecedent.", "examples": ["El tema **de què** (o **del qual**) parlàvem ha eixit en l'examen.", "La persona **amb qui** vaig parlar m'ho va explicar tot.", "Hi havia una tanca **darrere de la qual** s'amagava el gos."], "watch": [{"wrong": "La ciutat en la que visc és tranquil·la.", "right": "La ciutat en què (en la qual, on) visc és tranquil·la."}]}, {"title": "Possessió i construccions formals", "text": "La **possessió** s'expressa amb ***del qual*** (*de la qual*...) darrere del nom posseït. En registres formals, el relatiu fa ell sol la funció: **no** el combines amb un pronom feble o un possessiu que repetixen l'antecedent.", "table": {"head": ["formal", "no formal"], "rows": [["Tinc un amic el pare *del qual* és pilot.", "Tinc un amic *que el seu* pare és pilot."], ["La dona *a qui* vaig vendre el cotxe.", "La dona *que li* vaig vendre el cotxe."], ["El poble *on* vaig nàixer.", "El poble *que hi* vaig nàixer."]]}}, {"title": "Sense antecedent i relatius neutres", "text": "Sense antecedent, ***qui*** (o *el qui*, *els qui*, *els que*) es referix a persones i ***el que*** o ***allò que***, a coses. Per a reprendre **tota una oració** usa ***cosa que***, ***la qual cosa*** o ***fet que***; amb preposició, *amb la qual cosa*.", "examples": ["**Qui** estiga interessat, que passe per secretaria.", "No m'agrada gens **el que** has fet.", "Va aprovar-ho tot, **cosa que** va alegrar els pares.", "Ha plogut tota la setmana, **amb la qual cosa** s'ha ajornat la cursa."]}, {"title": "*On*, *quan*, *com*", "text": "***On*** indica lloc, amb antecedent o sense; *a on* també és correcte, però en registres formals es preferix *on*. Si el lloc és **metafòric**, millor *en què* o *en el qual*. ***Quan*** va **sense antecedent**; amb antecedent, *el dia que* o *en què*. ***Com*** expressa manera; amb antecedent, només darrere de *manera* o *forma*.", "examples": ["He anat **on** m'havies dit.", "Hi ha llengües **en què** el subjecte va al final.", "Telefona'm **quan** arribes. / Vine **el dia que** pugues.", "Ho farem **com** tu vulgues."]}], "remember": ["Especificativa sense comes; explicativa entre comes.", "*El qual* sense preposició, només en explicatives.", "Amb preposició: *què* (coses), *qui* (persones), *el qual* (tot); mai *en la que*.", "Possessió: *el pare del qual*, no *que el seu pare*.", "Una oració sencera es reprén amb *cosa que* o *la qual cosa*."], "sources": [{"gram": "GVB", "section": "28.2", "title": "Les oracions relatives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=28_2"}, {"gram": "GVB", "section": "28.3.1", "title": "Que", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=28_3_1"}, {"gram": "GVB", "section": "28.3.2", "title": "Què", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=28_3_2"}, {"gram": "GVB", "section": "28.3.3", "title": "Qual", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=28_3_3"}, {"gram": "GVB", "section": "28.3.4", "title": "Qui", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=28_3_4"}, {"gram": "GVB", "section": "28.4.1", "title": "Quan", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=28_4_1"}, {"gram": "GVB", "section": "28.4.2", "title": "On", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=28_4_2"}, {"gram": "GVB", "section": "28.4.3", "title": "Com", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=28_4_3"}, {"gram": "GNV", "section": "24.1", "title": "Caracterització general", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=24_1"}, {"gram": "GNV", "section": "24.2", "title": "Formes i usos dels relatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=24_2"}, {"gram": "GNV", "section": "24.3.1", "title": "Relatives explicatives amb antecedent repetit", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=24_3_1"}, {"gram": "GNV", "section": "24.3.2", "title": "Els relatius que, qui, què i article + qual", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=24_3_2"}, {"gram": "GNV", "section": "24.3.3", "title": "Els relatius adverbials", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=24_3_3"}, {"gram": "GNV", "section": "24.3.4", "title": "Les construccions de relatiu analítiques", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=24_3_4"}]}},
  {"type": "b2_mor_numerals", "lesson": {"intro": "Aprendràs a formar i abreviar tots els ordinals, a usar les formes cultes i les perífrasis com *el que fa dotze*, i a expressar fraccions amb els partitius.", "blocks": [{"title": "Ordinals en *-é* / *-ena*", "text": "A partir del 5, l'ordinal es forma afegint al cardinal ***-é*** (masculí) i ***-ena*** (femení); en plural fan ***-ens*** i ***-enes***. Els compostos porten **guionet** com el cardinal: *vint-i-cinqué*, *quaranta-cinquena*. En valencià s'escriuen amb accent agut (*cinqué*), però també és admissible *cinquè*.", "table": {"head": ["núm.", "masculí", "femení", "plural m.", "plural f."], "rows": [["7", "*seté*", "*setena*", "*setens*", "*setenes*"], ["8", "*huité* (*vuité*)", "*huitena*", "*huitens*", "*huitenes*"], ["9", "*nové*", "*novena*", "*novens*", "*novenes*"], ["12", "*dotzé*", "*dotzena*", "*dotzens*", "*dotzenes*"], ["21", "*vint-i-uné*", "*vint-i-unena*", "*vint-i-unens*", "*vint-i-unenes*"], ["100", "*centé*", "*centena*", "*centens*", "*centenes*"]]}}, {"title": "Formes cultes", "text": "Al costat de les formes en *-é*, hi ha ordinals de **base llatina**. **Totes dues sèries són acceptables**: *seté* o *sèptim*, *desena* o *dècima*. Algunes formes cultes també funcionen com a noms: *una octava* (estrofa), *una quinta* (interval musical).", "table": {"head": ["núm.", "masculí", "femení"], "rows": [["5", "*quint*", "*quinta*"], ["6", "*sext* (pl. *sextos*)", "*sexta*"], ["7", "*sèptim*", "*sèptima*"], ["8", "*octau*", "*octava*"], ["10", "*dècim*", "*dècima*"], ["20", "*vigèsim*", "*vigèsima*"]]}, "examples": ["La seua filla va quedar **novena** en la classificació.", "Celebrem el **vint-i-cinqué** aniversari de l'associació."]}, {"title": "Usos i perífrasis", "text": "*Primer* i *segon* **sempre concorden**: *la segona porta*. A partir del 4t, en la llengua col·loquial és habitual ***el que fa*** + cardinal o el cardinal sol. Per als **dies del mes** s'usen els cardinals; per al dia 1, *l'u* (o *el primer*). Amb noms propis, les xifres romanes superiors a deu es lligen com a cardinals.", "examples": ["La casa **que fa dotze** (= la dotzena).", "Era el corredor **que feia trenta** en la llista.", "**L'u** de març; **el vint-i-cinc** d'abril.", "Joan Pau II (**segon**), però Joan XXIII (**vint-i-tres**)."], "watch": [{"wrong": "la segon porta", "right": "la segona porta"}]}, {"title": "Abreviatures", "text": "S'escriu la xifra i l'**última lletra** del nom; en plural, les **dos últimes**. Pot anar seguida de punt (*1r.*) o amb la lletra volada, però la forma més habitual és la lletra al costat de la xifra.", "table": {"head": ["", "masc. sing.", "fem. sing.", "masc. pl.", "fem. pl."], "rows": [["1", "*1r*", "*1a*", "*1rs*", "*1es*"], ["2", "*2n*", "*2a*", "*2ns*", "*2es*"], ["3", "*3r*", "*3a*", "*3rs*", "*3es*"], ["4", "*4t*", "*4a*", "*4ts*", "*4es*"], ["5", "*5é*", "*5a*", "*5ns*", "*5es*"], ["28", "*28é*", "*28a*", "*28ns*", "*28es*"]]}, "watch": [{"wrong": "1º, 1er", "right": "1r"}, {"wrong": "2da", "right": "2a"}]}, {"title": "Partitius: les fraccions", "text": "Els partitius tenen la **forma dels ordinals**, excepte ***mig*** (*mitja*, *mitjos*, *mitges*) i ***terç*** (*terça*, *terços*, *terces*). Sovint es reforcen amb ***part***: *una quarta part*, *una tercera part*. Per a 1/2 d'un conjunt, ***la meitat*** (o *la mitat*). Amb *-èsim* es formen *centèsim* (1/100) i *mil·lèsim* (1/1000).", "table": {"head": ["fracció", "partitiu", "amb part"], "rows": [["1/3", "*un terç*", "*una tercera part*"], ["3/4", "*tres quarts*", "*tres quartes parts*"], ["1/5", "*un cinqué*", "*una cinquena* (*quinta*) *part*"], ["2/5", "*dos cinquens*", "*dues cinquenes parts*"], ["1/10", "*un desé*", "*una desena part*"]]}, "examples": ["**La meitat** de la classe ha aprovat.", "Compra **mitja** dotzena d'ous i dos quilos i **mig** de taronges."]}], "remember": ["Del 5 en avant: *-é*, *-ena*, *-ens*, *-enes*: *dotzé*, *dotzena*.", "Formes cultes també correctes: *sèptim*, *octau*, *dècima*.", "*La segona*, mai *la segon*; col·loquialment, *el que fa dotze*.", "Abreviatura: última lletra (*1r*, *4t*, *5é*); en plural, les dos últimes (*1rs*, *1es*).", "Fraccions: *mig*, *terç* i, després, la forma de l'ordinal: *un quart*, *dos cinquens*."], "sources": [{"gram": "GVB", "section": "14.2.12", "title": "Abreviatures numèriques", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=14_2_12"}, {"gram": "GVB", "section": "22.3.1", "title": "Caracterització general", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=numerals_ordinals"}, {"gram": "GVB", "section": "22.3.2", "title": "Aspectes formals i sintàctics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=numerals_ordinals"}, {"gram": "GVB", "section": "22.4", "title": "Els numerals partitius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=numerals_partitius"}, {"gram": "GNV", "section": "5.1.2", "title": "Observacions sobre l'accentuació de les ee", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=5_1_2"}, {"gram": "GNV", "section": "6.3.1", "title": "Les abreviatures", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=6_3_1"}, {"gram": "GNV", "section": "18.4.1", "title": "Caracterització general", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=18_4_1"}, {"gram": "GNV", "section": "18.4.2", "title": "Aspectes formals i sintàctics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=numerals_ordinals"}, {"gram": "GNV", "section": "18.5", "title": "Els numerals partitius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=18_5"}, {"gram": "GNV", "section": "37.5.2", "title": "Adjectivació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=37_5_2"}]}},
  {"type": "b2_mor_quantitatius", "lesson": {"intro": "Aprendràs a concordar els quantitatius i a saber quan porten *de*, a distingir *bastant*, *prou*, *força* i *gaire*, a usar indefinits com *qualsevol*, *tal* o *cadascú* i el valor de *res*, *cap* i *gens* en les preguntes.", "blocks": [{"title": "Variables i invariables", "text": "Davant d'un nom, ***molt***, ***poc***, ***tant*** i ***quant*** concorden en gènere i nombre; ***bastant*** i ***gaire*** només en **nombre**; ***massa***, ***força***, ***prou***, *més*, *menys* i ***gens*** no varien mai.", "table": {"head": ["flexió", "formes", "exemple"], "rows": [["completa", "*molt*, *poc*, *tant*, *quant*", "*tanta* gent, *quantes* vegades"], ["només nombre", "*bastant(s)*, *gaire(s)*", "*bastants* queixes, no *gaires* ganes"], ["cap", "*massa*, *força*, *prou*, *més*, *menys*, *gens*", "*massa* persones, *prou* cadires"]]}, "watch": [{"wrong": "bastantes queixes", "right": "bastants queixes"}]}, {"title": "Amb *de* o sense *de*", "text": "***Gens*** porta sempre *de*. *Molt*, *poc*, *bastant*, *prou*, *quant* i *tant* porten *de* **només** davant de **masculí singular**. *Massa*, *gaire*, *més* i *menys* no en porten mai. Davant d'adjectiu o adverbi, *tant* es reduïx a ***tan***.", "table": {"head": ["quantitatiu", "masc. sing.", "altres casos"], "rows": [["*gens*", "*gens de* pa", "*gens de* farina"], ["*molt*, *tant*...", "*tant de* treball", "*tanta* gent, *tants* diners"], ["*massa*, *gaire*...", "*massa* soroll", "*massa* persones"]]}, "examples": ["Hi havia **tanta** gent que no cabíem.", "Este any tenim **tant de** treball com l'any passat.", "El teu fill s'ha fet **tan** alt com tu."]}, {"title": "*Bastant*, *prou*, *força*, *gaire*", "text": "***Bastant*** és 'una quantitat relativament gran'; ***prou***, 'suficient', però també s'accepta *prou* amb els dos valors, d'acord amb l'ús majoritari en valencià. ***Força*** ('molt') només s'usa en frases afirmatives i és viu en algunes comarques. ***Gaire*** val per *molt* en negatives, preguntes i condicionals, on en valencià s'ha generalitzat *molt*.", "examples": ["Tenen **bastants** diners, però no **prou** per al ritme de vida que porten.", "Hui hi ha **força** gent a la platja.", "No tenia **gaires** ganes (o **moltes** ganes) d'eixir."]}, {"title": "Locucions de quantitat", "text": "Les locucions donen **vivacitat** i són més pròpies dels registres poc formals. Davant d'un nom acaben en ***de***.", "table": {"head": ["valor", "locucions"], "rows": [["molt", "*bona cosa de*, *un fum de*, *un grapat de*, *un muntó de*, *un munt de*, *una pila de*"], ["poc", "*una miqueta* (*mica*) *de*, *un raig de*, *un pessic de*"], ["gens", "*gens ni miqueta* (*mica*) *de*, *ni gota de*"]]}, "examples": ["A la manifestació hi havia **bona cosa de** gent.", "Afig **un pessic de** sal al caldo."]}, {"title": "Indefinits: *qualsevol*, *tal*, *cadascú*", "text": "***Qualsevol*** fa el plural ***qualssevol***, una diferència només gràfica. ***Tal*** fa *tals*. ***Diversos*** fa *diverses*, i *diferents* davant d'un nom plural també val per 'diversos'. ***Cada*** va davant d'un nom; el pronom genèric és ***cadascú*** (sense *-n*); *cadascun* recupera un nom ja dit.", "examples": ["Deixa'm tres bolígrafs **qualssevol**.", "**Tals** explicacions no em convencen gens.", "**Cadascú** ha de portar el seu dinar."]}, {"title": "*Res*, *cap*, *ningú* i *gens* en preguntes", "text": "En frases negatives, ***res*** és 'cap cosa', ***ningú*** 'cap persona', ***cap*** va amb noms **comptables** i ***gens*** amb **no comptables**. En **preguntes i condicionals** tenen valor **positiu**: *alguna cosa*, *algú*, *algun*, *una mica*. Al costat de *cap* hi ha *ningun* (*ninguna*), però *cap* és el més usat en registres formals.", "examples": ["Vols **res** de la botiga? ('alguna cosa')", "Queda **gens** de llet? ('una mica')", "No tinc **cap** (o **ninguna**) objecció."], "watch": [{"wrong": "No hi ha gens problema.", "right": "No hi ha cap problema."}]}], "remember": ["*Bastant* i *gaire* varien només en nombre; *massa*, *prou*, *força* i *gens*, mai.", "*De* només davant de masculí singular: *tant de treball*, però *tanta gent*.", "*Gens de* sempre; *massa*, *gaire*, *més* i *menys*, sense *de*.", "Plural de *qualsevol*: *qualssevol*; de *tal*: *tals*.", "En preguntes, *res*, *cap* i *gens* valen 'alguna cosa', 'algun', 'una mica'."], "sources": [{"gram": "GVB", "section": "23.2", "title": "Variació morfològica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=aspectes_formals_sintactics"}, {"gram": "GVB", "section": "23.3", "title": "Aspectes formals i sintàctics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=quantitatius"}, {"gram": "GVB", "section": "23.4.7", "title": "Prou", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=quantitatiu_prou"}, {"gram": "GVB", "section": "23.4.8", "title": "Força", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=23_4_8"}, {"gram": "GVB", "section": "23.5", "title": "Locucions quantitatives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=locucions_quantitatives"}, {"gram": "GVB", "section": "24.2.6", "title": "Qualsevol", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinit_qualsevol"}, {"gram": "GVB", "section": "24.2.13", "title": "Tal", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinit_tal"}, {"gram": "GVB", "section": "24.2.14", "title": "Cap", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinits_negatius"}, {"gram": "GVB", "section": "24.3.6", "title": "Res", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinit_res"}, {"gram": "GNV", "section": "19.2.1", "title": "Els indefinits universals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=19_2_1"}, {"gram": "GNV", "section": "19.2.2", "title": "Els indefinits existencials", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=19_2_2"}, {"gram": "GNV", "section": "19.2.3", "title": "Els indefinits negatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=indefinits_negatius"}, {"gram": "GNV", "section": "19.3", "title": "Els pronoms indefinits", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=19_3"}, {"gram": "GNV", "section": "20.2", "title": "Aspectes formals i sintàctics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=20_2"}, {"gram": "GNV", "section": "20.3", "title": "Els quantitatius no comparatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=20_3"}, {"gram": "GNV", "section": "20.4", "title": "Els quantitatius comparatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=quantitatius_mes_menys_tant"}]}},
  {"type": "b2_mor_preposicions", "lesson": {"intro": "Aprendràs a triar entre *a* i *en* en els complements de lloc i de temps, a usar bé *amb*, *per*, *per a* i *sense* davant d'un nom, i a fer caure la preposició davant de la conjunció *que*.", "blocks": [{"title": "*A* o *en* per a dir on", "text": "Amb **noms propis de lloc** s'usa sempre *a*, tant per a la destinació com per a la localització. Davant de l'**article definit** valen *a* i *en* (*a* és normal amb parts del cos i llocs molt definits). Davant de **noms sense determinant**, d'indefinits, demostratius i relatius, s'usa *en*.", "table": {"head": ["davant de", "preposició", "exemple"], "rows": [["nom propi de lloc", "*a*", "*Va nàixer a Morella però viu a Benicarló.*"], ["article definit", "*a* o *en*", "*Espera'm a la porta.* / *Mira en l'armari.*"], ["nom sense determinant", "*en*", "*Viuen en cases diferents.*"], ["demostratiu, indefinit...", "*en*", "*En este carrer no es pot dormir.*"]]}, "watch": [{"wrong": "Estudia en Barcelona.", "right": "Estudia a Barcelona."}]}, {"title": "Hores, parts del dia, mesos i estacions", "text": "Amb un **moment puntual** i article definit s'usa *a*: una hora, una part del dia, un mes o una estació. Sense article, els mesos i les estacions també admeten *en*. Amb sintagmes indefinits i durades s'usa *en*: és el temps que necessites per a fer una cosa. Amb ***de*** tens *de nit*, *de matí*, *de vesprada* o *d'estiu*.", "table": {"head": ["expressió", "exemple"], "rows": [["*a* + hora", "*Hem quedat a les onze de la nit.*"], ["*a* + part del dia", "*Arribarem a la vesprada.*"], ["*a* + mes o estació", "*Ja descansaré a l'agost.* / *Ací, a la primavera, ja fa calor.*"], ["*en* + mes o estació sense article", "*Començaré a treballar en setembre.*"], ["*en* + indefinit o durada", "*Ho acabarem en un moment.*"], ["*de* + part del dia", "*Està obert de matí i de vesprada.*"]]}}, {"title": "Festes, dies i dates", "text": "Amb les **festes** s'usa *per*: és el temps al voltant d'un moment. Els **dies de la setmana** no porten preposició: sense article si indiquen immediatesa i amb article si indiquen freqüència. Les **dates** porten l'article definit, sense cap preposició.", "examples": ["**Per** Sant Joan es fan fogueres.", "Tornem a casa **dissabte**. / **Els dimarts** va al gimnàs.", "Va nàixer **el** 22 d'octubre de 1959."], "watch": [{"wrong": "Vindré en dilluns.", "right": "Vindré dilluns."}]}, {"title": "*Amb*, *en* i les preposicions dels verbs", "text": "*Amb* introduïx l'**instrument**, la **companyia** i les relacions entre persones: *casar-se amb*, *parlar amb*. Amb els **mitjans de transport** pots usar *en* o *amb*. Molts verbs exigixen una preposició fixa: *pensar en*, *confiar en*, *interessar-se per*.", "examples": ["Talla el paper **amb** aquelles tisores.", "Vam anar a Alacant **en** cotxe (o **amb** cotxe).", "**Pense en** tu. **Confia en** la nostra ajuda."], "watch": [{"wrong": "Pense molt amb tu.", "right": "Pense molt en tu."}]}, {"title": "*Per*, *per a* i *sense* davant de nom", "text": "Davant d'un sintagma nominal, ***per a*** marca el **benefactiu** i la **destinació**. ***Per*** introduïx la **causa**, l'**agent** de la passiva, la **ruta** d'un moviment i el **temps** aproximat. ***Sense*** és el contrari d'*amb* i va directament davant del nom; s'usa sol si el complement s'entén.", "table": {"head": ["forma", "valor", "exemple"], "rows": [["*per a*", "benefactiu", "*La iaia ha fet una coca per a tu.*"], ["*per a*", "destinació", "*L'avió ix per a Londres.*"], ["*per*", "causa", "*Han tancat per reformes.*"], ["*per*", "agent", "*Va ser ratificada per tots els assistents.*"], ["*per*", "ruta", "*Ha eixit per la porta de darrere.*"], ["*sense*", "absència", "*Sempre va sense amics.*"]]}, "watch": [{"wrong": "Un café sense de sucre.", "right": "Un café sense sucre."}]}, {"title": "La preposició cau davant de *que*", "text": "Les preposicions *a*, *de*, *en* i *amb* **s'elidixen davant de la conjunció *que***, però **es mantenen** davant d'un nom o d'un infinitiu. Afecta verbs (*alegrar-se de*, *confiar en*), noms (*el fet de*, *la idea de*), *abans de*, *després de* i locucions.", "table": {"head": ["amb preposició", "davant de *que*"], "rows": [["*Estem segurs de vosaltres.*", "*Estem segurs que faran un bon paper.*"], ["*S'alegra de la teua sort.*", "*S'alegra que tingues tanta sort.*"], ["*El fet de tindre problemes...*", "*El fet que tinga problemes...*"], ["*Avisa'm abans d'anar-te'n.*", "*Avisa'm abans que te'n vages.*"]]}, "watch": [{"wrong": "Estic convençut de que guanyarem.", "right": "Estic convençut que guanyarem."}]}], "remember": ["Topònims sempre amb *a*: *viu a Cocentaina*.", "Hora, part del dia, mes o estació amb article: *a*; durada: *en dos dies*.", "Festes amb *per* (*per Pasqua*); dies i dates sense preposició (*dilluns*, *el 15 de març*).", "*Per a*: destinatari i destinació. *Per*: causa, agent i ruta.", "*De que* no: *segur que*, *el fet que*, *abans que*."], "sources": [{"gram": "GVB", "section": "19.2.5", "title": "L'ús de l'article definit davant dels dies de la setmana", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=19_2_5"}, {"gram": "GVB", "section": "19.2.6", "title": "L'ús de l'article definit davant dels anys", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=19_2_6"}, {"gram": "GVB", "section": "30.4", "title": "En", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=30_4"}, {"gram": "GVB", "section": "30.5", "title": "De", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=preposicio_de"}, {"gram": "GVB", "section": "30.7", "title": "Per", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=preposicio_per"}, {"gram": "GVB", "section": "31.15", "title": "Sense", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=31_15"}, {"gram": "GVB", "section": "33.2", "title": "L'elisió de preposicions àtones", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=elisio_preposicions"}, {"gram": "GNV", "section": "26.3", "title": "Usos i funcions de les preposicions febles", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=26_3"}, {"gram": "GNV", "section": "26.3.1.1", "title": "Els complements de lloc", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=complements_lloc"}, {"gram": "GNV", "section": "26.3.1.2", "title": "Els complements de temps", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=26_3"}, {"gram": "GNV", "section": "26.3.2", "title": "La preposició amb", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=preposicio_amb"}, {"gram": "GNV", "section": "26.3.4", "title": "Les preposicions per i per a", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=preposicio_per"}, {"gram": "GNV", "section": "26.3.5", "title": "L'elisió i el canvi de preposicions àtones", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=elisio_canvi_preposicions"}, {"gram": "GNV", "section": "26.5.4", "title": "La preposició sense", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=preposicio_sense"}]}},
  {"type": "b2_mor_adverbis", "lesson": {"intro": "Aprendràs a afirmar amb més o menys seguretat, a incloure un element inesperat amb *fins i tot* o *inclús*, a expressar dubte amb *potser* o *tal vegada* i a coordinar adverbis en *-ment*.", "blocks": [{"title": "*Sí que*, *també* i *tampoc*", "text": "*Sí* només s'usa en les **respostes**: sol o davant d'una oració amb *que*, per a reforçar l'afirmació. *També* suma una idea **afirmativa**; ***tampoc*** suma una idea **negativa** i funciona com *mai* o *ningú*: si va darrere del verb demana *no*, i si va davant el *no* és opcional.", "examples": ["—Ha enviat Joan la carta? —**Sí que** l'ha enviada.", "A mi m'agrada el teatre, i a ella **també**.", "Jo no ho sabia **tampoc**. / Jo **tampoc** (no) ho sabia."], "watch": [{"wrong": "Ell no hi anirà, i jo també no.", "right": "Ell no hi anirà, i jo tampoc."}]}, {"title": "*Fins i tot*, *inclús* i *fins*", "text": "Per a presentar un element **inesperat** o excepcional usa ***fins i tot***, ***inclús*** o simplement ***fins*** (sense *a*). També pots posar *i tot* darrere de l'element. En registres molt formals hi ha *àdhuc*. No ho confongues amb ***prou***, que indica una quantitat **suficient** i no varia: *prou divertida*.", "examples": ["Tots li reconeixen els mèrits, **fins i tot** els seus adversaris.", "Tenen gats, gossos i **inclús** rates.", "**Fins** els més desinformats ho sabien.", "Van acudir a la festa fins els companys d'institut **i tot**."]}, {"title": "Afirmar amb seguretat", "text": "Per a mostrar **assentiment** davant del que diu algú tens *clar*, *és clar (que sí)*, *i tant*, *per descomptat* o *tu diràs*. Per a assegurar el que dius, *sens dubte* i *certament*. Per a **confirmar** el que s'ha dit, *efectivament* o *en efecte*.", "examples": ["**Clar que** puc deixar-te la bici!", "—Em pots deixar un llibre? —**Per descomptat**, home!", "La cultura és, **sens dubte**, un element essencial de la societat.", "Fins fa poc, **en efecte**, la seua autoritat era incontestable."]}, {"title": "Expressar dubte", "text": "Els adverbis modals indiquen el **grau de certesa**: *possiblement*, *probablement*, *segurament*, *aparentment* i ***potser***, que és una paraula composta i s'escriu **junta**. També tens *tal vegada*, *tal volta* i *qui sap*. El mode tradicional darrere d'estos adverbis és l'**indicatiu**; el subjuntiu convé evitar-lo en els registres formals.", "examples": ["No patisques tant, que **potser** ni se'n recorden.", "**Segurament** tindran en compte el que hem dit.", "**Tal vegada** tenien raó ells!", "**Possiblement** arribaran demà."], "watch": [{"wrong": "A lo millor ve en el tren de les deu.", "right": "Potser (o tal vegada) vindrà en el tren de les deu."}]}, {"title": "Adverbis en *-ment* coordinats", "text": "L'adverbi es forma sobre el **femení** de l'adjectiu (*cortesa* → *cortesament*) o sobre la forma única (*veloç* → *veloçment*). Quan en coordines dos, la gramàtica de l'AVL permet **elidir *-ment* del segon**, però hui es **preferix mantindre'l en tots dos**.", "table": {"head": ["adjectiu", "adverbi"], "rows": [["*ràpid*, *ràpida*", "*ràpidament*"], ["*trist*, *trista*", "*tristament*"], ["*alegre*", "*alegrement*"], ["*veloç*", "*veloçment*"]]}, "examples": ["Caminava **tranquil·lament i lentament**.", "Caminava **tranquil·lament i lenta**.", "Va gestionar el departament **hàbilment i eficaçment**."]}], "remember": ["*Sí que* reforça l'afirmació; *tampoc*, no *també no*, suma una negació.", "*Fins i tot* = *inclús* = *fins*: element inesperat.", "Assentiment: *és clar que sí*, *i tant*, *per descomptat*.", "*Potser* va junt; amb *potser* i *tal vegada*, millor l'indicatiu.", "*-ment* coordinats: es pot llevar del segon, però millor mantindre'l en tots dos."], "sources": [{"gram": "GVB", "section": "19.5.2", "title": "Altres usos", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=19_5_2"}, {"gram": "GVB", "section": "34.2", "title": "Adverbis derivats d'adjectius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adverbis_derivats_adjectius"}, {"gram": "GVB", "section": "37.2.5", "title": "Prou", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adverbi_prou"}, {"gram": "GVB", "section": "37.4.2", "title": "Fins", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=37_4_2"}, {"gram": "GVB", "section": "38.1", "title": "Els adverbis modals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adverbis_modals"}, {"gram": "GVB", "section": "38.2.1", "title": "Sí", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adverbi_si"}, {"gram": "GVB", "section": "38.2.4", "title": "Les paraules negatives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=usos_paraules_negatives"}, {"gram": "GVB", "section": "38.3", "title": "Els adverbis textuals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=38_3"}, {"gram": "GVB", "section": "42.2.3", "title": "Les interjeccions fàtiques", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=interjeccions_fatiques"}, {"gram": "GNV", "section": "27.3.2", "title": "Precisions sobre els adverbis de manera", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=adverbis_manera"}, {"gram": "GNV", "section": "27.6", "title": "Els adverbis quantitatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=27_6"}, {"gram": "GNV", "section": "27.7.1", "title": "Els adverbis modals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=27_7_1"}, {"gram": "GNV", "section": "27.7.2", "title": "Els adverbis d'afirmació i de negació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=adverbis_afirmacio_negacio"}, {"gram": "GNV", "section": "28.5", "title": "Precisions sobre l'ús de l'indicatiu i el subjuntiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=precisions_us_indicatiu_subjuntiu"}, {"gram": "GNV", "section": "35.2", "title": "Les classes d'interjeccions", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=35_2"}]}},
  {"type": "b2_mor_connectors", "lesson": {"intro": "Aprendràs a contrastar idees amb *tanmateix* o *en canvi*, a sumar-les i distribuir-les amb *no sols... sinó*, a matisar obstacles i causes amb els connectors formals i a usar el *que* que encapçala preguntes i exclamacions.", "blocks": [{"title": "Contrast: *però*, *mentre que* i els adverbis connectius", "text": "*Però* i *mentre que* (o *mentres que*) **oposen** dos elements dins de la mateixa oració. Per a contrastar amb el que s'ha dit **abans**, tens adverbis connectius: ***tanmateix***, ***no obstant això*** (o *això no obstant*), *així i tot*, *amb tot*, *en canvi* i *altrament* ('si no'). A diferència de les conjuncions, poden anar **en diverses posicions**.", "examples": ["Este hivern ha plogut prou; **no obstant això**, encara hi ha sequera.", "A mi m'agrada quedar-me a casa; a ella, **en canvi**, li agrada més estar amb els amics.", "No ha estudiat gens i, **tanmateix**, ha aprovat totes les assignatures."], "watch": [{"wrong": "Joana treballa moltes hores, mentre jo em limite a complir l'horari.", "right": "Joana treballa moltes hores, mentre que jo em limite a complir l'horari."}]}, {"title": "*Sinó*, *sinó que* i *si no*", "text": "***Sinó*** té valor **substitutiu**: afirma del segon element el que es nega del primer. Si darrere ve una oració amb verb conjugat, ***sinó que***. Amb la correlació ***no sols*** (o *no solament*) ***... sinó (també)*** sumes dos elements i remarques el segon. No ho confongues amb ***si no***, separat: és la condicional *si* + la negació *no*.", "examples": ["No dic que calles **sinó que** parles més baixet.", "**No solament** el va amenaçar, **sinó que** va complir l'amenaça.", "**Si no** arribes a temps, avisa'm."], "watch": [{"wrong": "No sols el va ajudar, si no que el va acompanyar a casa.", "right": "No sols el va ajudar, sinó que el va acompanyar a casa."}]}, {"title": "Distribuir i alternar", "text": "Algunes construccions **paral·leles** reparteixen o alternen els elements: *o... o*, *o bé... o bé*, *bé... bé*, *ara... ara*, *adés... adés*, *ja... ja*, *siga... siga* i *ni... ni*. Per a sumar dos elements amb el mateix pes, ***tant... com*** o, en un registre més formal, ***així... com***.", "examples": ["**Ara** plora, **ara** riu: té un caràcter molt inestable.", "Ha de reforçar l'empresa, **bé** ampliant el patrimoni, **bé** facilitant la fusió.", "Es van oposar a la llei **així** burgesos **com** nobles."]}, {"title": "Obstacles: les concessives", "text": "A més d'*encara que* i *tot i que*, en registres cuidats tens ***si bé***, *per bé que*, *bé que*, *a pesar que*, *malgrat que*, *ni que*, *mal que* i ***per més que***, que porta **subjuntiu**. Recorda que les **conjuncions** van amb verb conjugat, i les **preposicions** amb un nom o un infinitiu: *malgrat* o *a pesar de* + nom.", "table": {"head": ["connector", "seguit de", "exemple"], "rows": [["*si bé*", "verb conjugat", "*Si bé les normes s'han de complir, hi ha una certa permissivitat.*"], ["*tot i que*", "verb conjugat", "*Tot i que tenia febra, va anar a la reunió.*"], ["*per més que*", "subjuntiu", "*Per més que m'insistisques, no te l'he de tornar.*"], ["*malgrat*, *a pesar de*", "nom", "*Malgrat totes les dificultats, ha aconseguit el seu objectiu.*"]]}}, {"title": "Causes: conjuncions i locucions", "text": "Davant d'una **oració**, a més de *perquè*, usa *ja que*, ***com que***, *vist que*, *atés que*, *donat que* o ***puix que***. Davant d'un **nom**, les locucions preposicionals ***a causa de***, *per causa de*, *per raó de*, ***per culpa de*** (responsabilitat) o ***gràcies a*** (agraïment). Si queda forçat *a causa que*, passa-ho a un nom.", "examples": ["**Com que** no li feien cas, se'n va anar.", "**Atés que** ha arribat Ferran, podem començar.", "El concert es va suspendre **a causa del** mal oratge."], "watch": [{"wrong": "Es va negar tot a causa que va caure molta pluja.", "right": "Es va negar tot a causa de la gran ploguda que va caure."}]}, {"title": "El *que* de preguntes i exclamacions", "text": "Una pregunta de resposta *sí* o *no* pot començar amb la conjunció **expletiva** ***que***, **sense accent**: si la lleves, la pregunta no canvia. En canvi, ***què*** és el pronom interrogatiu i pregunta per una cosa. En les exclamacions, ***que*** sense accent va davant d'un **adjectiu o adverbi**; davant d'un nom, *quin* o *quant*.", "examples": ["**Que** et fa mal la panxa? / **Que** no teniu escola ara?", "**Que** pesat que és el teu amic! **Que** bé que parla!", "**Quina** calor més insuportable!"], "watch": [{"wrong": "Que calor que fa!", "right": "Quina calor que fa!"}]}], "remember": ["*Tanmateix*, *no obstant això* i *en canvi* contrasten amb el que s'ha dit abans.", "*Sinó* (junt) substituïx el que s'ha negat; *si no* (separat) és condicional.", "*No sols... sinó que* + verb conjugat; *tant... com* suma dos elements.", "*Per més que* + subjuntiu; *malgrat* i *a pesar de* + nom.", "*Que* sense accent: expletiu en preguntes de sí o no i exclamatiu davant d'adjectiu o adverbi."], "sources": [{"gram": "GVB", "section": "31.10", "title": "Malgrat", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=preposicio_malgrat"}, {"gram": "GVB", "section": "32.4", "title": "A causa de", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=locucio_preposicional_a_causa_de"}, {"gram": "GVB", "section": "38.3", "title": "Els adverbis textuals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=38_3"}, {"gram": "GVB", "section": "41.3.3", "title": "Les conjuncions distributives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=41_3_3"}, {"gram": "GVB", "section": "41.4.3", "title": "Les conjuncions concessives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_concessives"}, {"gram": "GNV", "section": "25.2.1", "title": "Les interrogatives totals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=interrogatives_totals"}, {"gram": "GNV", "section": "25.4", "title": "Els exclamatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=exclamatius"}, {"gram": "GNV", "section": "26.3.5", "title": "L'elisió i el canvi de preposicions àtones", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=elisio_canvi_preposicions"}, {"gram": "GNV", "section": "26.6", "title": "Les locucions preposicionals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=26_6"}, {"gram": "GNV", "section": "34.3", "title": "Les conjuncions i altres classes de paraules", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=34_3"}, {"gram": "GNV", "section": "34.4.3", "title": "Les conjuncions distributives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=34_4_3"}, {"gram": "GNV", "section": "34.4.4", "title": "Les conjuncions adversatives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=conjuncions_adversatives"}, {"gram": "GNV", "section": "34.5.2", "title": "Les conjuncions condicionals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=conjuncions_condicionals"}, {"gram": "GNV", "section": "34.5.3", "title": "Les conjuncions concessives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=34_5_3"}, {"gram": "GNV", "section": "34.5.4", "title": "Les conjuncions causals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=34_5_4"}]}},
  {"type": "b2_mor_verbs_irregulars", "lesson": {"intro": "Aprendràs on apareix la *g* dels verbs velaritzats, els participis forts dels verbs en *-ndre*, *-ldre* i *-ure*, l'alternança vocàlica de *collir*, *cosir* o *eixir* i els imperfets forts com *feia*, *duia* o *reia*.", "blocks": [{"title": "Velaritzats: on va la *g*", "text": "Els verbs com ***beure*** porten velar (*-c* a final de paraula, *-g-* davant de vocal) només en **sis llocs**: *jo* del present, tot el present de subjuntiu, l'imperatiu de les persones 3, 4 i 6, el passat simple, l'imperfet de subjuntiu i el participi. La resta de formes són sense velar: *beus*, *bevem*, *bevia*, *bevent*. Seguixen este model *deure*, *ploure*, *moure*, *conéixer* i també *córrer* i derivats: *recorregué*, *recorregut*, *ocorregut*, *que ocórrega*.", "table": {"head": ["forma", "amb velar", "sense velar"], "rows": [["present", "*bec*", "*beus*, *beu*, *bevem*, *beveu*, *beuen*"], ["subjuntiu", "*bega*, *begues*, *beguem*...", "—"], ["passat simple", "*beguí*, *begueres*, *begué*...", "—"], ["participi", "*begut*", "—"], ["imperfet i gerundi", "—", "*bevia*, *bevent*"]]}, "watch": [{"wrong": "Nosaltres beguem aigua del pou.", "right": "Nosaltres bevem aigua del pou. (*beguem* és subjuntiu)"}, {"wrong": "Estava diguent la veritat.", "right": "Estava dient la veritat."}]}, {"title": "*Viure* i *eixir*: el grup *-sc-*", "text": "*Créixer*, *nàixer*, *meréixer* i ***viure*** fan la velar amb el grup ***-sc-*** en els mateixos llocs que *beure*: *visc*, *visca*, *viscut*. Encara que es pronuncie sovint amb palatal (*vixc*, *vixcut*), en l'estàndard s'han generalitzat les formes amb ***s***. ***Eixir*** també fa *isc*, *isca*, però el participi és regular: *eixit*.", "examples": ["Sempre ha **viscut** en el poble.", "Jo **isc** de casa a les huit.", "Espere que **cresca** sa i fort."]}, {"title": "Participis forts: *-ndre*, *-ldre* i *-ure*", "text": "Tots els verbs en ***-ndre*** fan el participi en ***-s***, **excepte** *vendre* (*venut*) i *pondre* (*post*). Els acabats en ***-ldre*** el fan en ***-t***, però *doldre* i *oldre* fan *dolgut* i *olgut*. *Respondre* fa *respost*, i *riure*, *rist* o *rigut*. Els derivats de *tindre* tenen participi regular.", "table": {"head": ["model", "exemples"], "rows": [["*-ndre* → *-s*", "*prendre*: *pres*; *encendre*: *encés*; *comprendre*: *comprés*; *fondre*: *fos*"], ["*-ldre* → *-t*", "*moldre*: *molt*; *resoldre*: *resolt*; *absoldre*: *absolt*"], ["en *-st*", "*pondre*: *post*; *respondre*: *respost*; *veure*: *vist*"], ["en *-t*", "*escriure*: *escrit*; *dur*: *dut*; *traure*: *tret*"], ["regulars", "*vendre*: *venut*; *mantindre*: *mantingut*"]]}, "watch": [{"wrong": "La policia l'ha detés.", "right": "La policia l'ha detingut."}]}, {"title": "*Collir*, *cosir*, *tossir*: *u* tònica, *o* àtona", "text": "Uns quants verbs purs de la tercera conjugació canvien la vocal del radical: ***u*** quan és **tònica** i ***o*** quan és **àtona**. Passa amb *bollir*, *collir*, *cosir*, *engolir*, *escopir*, *sortir* i *tossir*. Amb *i*/*e* van *eixir*, *llegir*, *afegir* o *vestir*. En l'estàndard, millor el model **sense velar**: *cus*, no *cusc*.", "table": {"head": ["infinitiu", "tònica", "àtona"], "rows": [["*collir*", "*cull*, *culls*, *cullen*", "*collim*, *colliu*, *collia*"], ["*cosir*", "*cus*, *cuses*, *cusen*", "*cosim*, *cosiu*, *cosia*"], ["*tossir*", "*tus*, *tusses*, *tussen*", "*tossim*, *tossiu*"], ["*escopir*", "*escup*, *escupen*", "*escopim*, *escopiu*"], ["*bollir*", "*bull*, *bullen*", "*bollim*, *bolliu*"], ["*eixir*", "*ix*, *ixes*, *ixen*", "*eixim*, *eixiu*"]]}}, {"title": "Imperfets forts: *feia*, *duia*, *reia*", "text": "En l'imperfet regular de la segona conjugació l'accent cau en la *i*: *corria*, *corríem*, *corríeu*. Però ***fer*** i un grup de verbs fan un **imperfet fort**, amb l'accent en el radical i una *i* consonàntica: *caure*, *creure*, *dir*, *dur*, *jaure*, *riure*, *seure* i *traure*. Les persones 4 i 5 són esdrúixoles i porten accent: *féiem* (o *fèiem*). Formes com *fea*, *dia* o *ria* són vives en la parla, però en els registres formals convenen les formes fortes.", "table": {"head": ["verb", "imperfet"], "rows": [["*fer*", "*feia*, *feies*, *feia*, *féiem*, *féieu*, *feien*"], ["*dir*", "*deia*, *deies*, *deien*"], ["*dur*", "*duia*, *duies*, *duien*"], ["*creure*", "*creia*, *creies*, *creien*"], ["*riure*", "*reia*, *reies*, *reien*"], ["*traure*", "*treia*, *treies*, *treien*"]]}, "examples": ["Cada dia **duia** el gos a passejar.", "Em **deia** moltes mentides i al principi me les **creia**."]}, {"title": "*Caiem*, *veiem*: la *i* del present", "text": "*Caure*, *creure*, *jaure*, *seure*, *traure* i *veure* porten també una *i* consonàntica en les persones 4 i 5 del present i en el gerundi: *caiem*, *caieu*, *caient*. També són correctes sense *i* (*caem*, *caent*), però **no** les formes amb velar o palatal com *caiguem* o *vegent*.", "watch": [{"wrong": "Ara vegem la pel·lícula.", "right": "Ara veiem la pel·lícula."}]}], "remember": ["Velar només en: *jo* del present, subjuntiu, imperatiu 3-4-6, passat simple, imperfet de subjuntiu i participi.", "*Bevem*, *bevent* i *dient*: mai *beguem* en indicatiu ni gerundis en *-guent*.", "*-ndre* → *pres*, *encés*, *fos* (però *venut*, *post*); *-ldre* → *resolt*, *absolt*.", "*Cull*, *cus*, *tus*, *ix* quan la vocal és tònica; *collim*, *cosim*, *tossim*, *eixim* quan és àtona.", "Imperfets forts: *feia*, *deia*, *duia*, *reia*, *treia*; 4 i 5 amb accent: *féiem*."], "sources": [{"gram": "GVB", "section": "7.4", "title": "Observacions sobre l'accentuació de la vocal e", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=accent_grafic"}, {"gram": "GNV", "section": "29.5", "title": "Precisions sobre el polimorfisme verbal", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=polimorfisme_verbal"}, {"gram": "GNV", "section": "30.1", "title": "Conceptes generals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=verbs_irregulars"}, {"gram": "GNV", "section": "30.2.1", "title": "Verbs amb alternances vocàliques en el radical", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}, {"gram": "GNV", "section": "30.2.2", "title": "Verbs amb alternances consonàntiques al final del radical", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}, {"gram": "GNV", "section": "30.2.3", "title": "Tendència a la generalització de formes velaritzades", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}, {"gram": "GNV", "section": "30.2.4.1", "title": "Verbs amb imperfets forts", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=30_2_4_1"}, {"gram": "GNV", "section": "30.2.4.2", "title": "Verbs amb i consonàntica en formes del present d'indicatiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=30_2_4_2"}, {"gram": "GNV", "section": "30.2.4.4", "title": "Els participis forts", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=participis_forts"}]}},
  {"type": "b2_mor_subjuntiu", "lesson": {"intro": "Aprendràs a encadenar bé els temps del subjuntiu, a usar l'imperfet en *-ra* o en *-s*, a construir finals, concessives, temporals i condicionals, i a donar ordes en negatiu amb pronoms.", "blocks": [{"title": "La correlació de temps", "text": "El temps de la subordinada depén del de la principal. Si la principal està en **present o futur**, va el **present de subjuntiu** (o el perfet, *haja cantat*, si l'acció ja ha passat). Si la principal està en **passat o condicional**, va l'**imperfet de subjuntiu**.", "table": {"head": ["principal", "subordinada", "exemple"], "rows": [["present", "present de subjuntiu", "Vol que demà **arribem** puntuals."], ["present", "perfet de subjuntiu", "Espere que t'ho **hages passat** molt bé."], ["passat", "imperfet de subjuntiu", "Volia que **tornàrem** l'endemà."], ["condicional", "imperfet de subjuntiu", "Ja m'agradaria que **pensara** igual que nosaltres."]]}, "examples": ["És possible que se n'**hagen anat** ja."]}, {"title": "L'imperfet de subjuntiu: *-ra* o *-s*", "text": "L'imperfet de subjuntiu té **dos sèries correctes**: les formes en ***-ra***, pròpies de la major part del valencià, i les formes en ***-s***, del valencià septentrional i amb molta tradició escrita. En la primera conjugació, la forma en *-s* pot dur *a* o *e*: *cantàs* o *cantés*. *Fer*, *ser* i *veure* tenen formes fortes: *fera*, *fora*, *vera*.", "table": {"head": ["verb", "en -ra", "en -s"], "rows": [["*cantar*", "*cantara*, *cantàrem*", "*cantés* (o *cantàs*), *cantéssem*"], ["*batre*", "*batera*, *batérem*", "*batés*, *batéssem*"], ["*sentir*", "*sentira*, *sentírem*", "*sentís*, *sentíssem*"], ["*haver*", "*haguera cantat*", "*hagués cantat*"]]}, "examples": ["Si **fora** veritat, no s'hauria excusat tant."]}, {"title": "Finalitat, concessió i manera", "text": "Les **finals** (*perquè*, *a fi que*, *per tal que*) van sempre en subjuntiu; en registre formal, *perquè* i no *per a que*. Les **concessives** (*encara que*, *per més que*, *ni que*, *mal que*) i les modals ***sense que*** i ***com si*** també poden dur subjuntiu. Amb *com si* va l'imperfet o el plusquamperfet.", "examples": ["Has de parpellejar **per tal que** el col·liri es **distribuïsca** per tot l'ull.", "**Per més que** m'**insistisques**, no te l'he de tornar.", "Ho farem **sense que** ens **ajude** ningú.", "Digues-li-ho **com si** no **haguera passat** res."], "watch": [{"wrong": "Aniré a parlar amb ell per a que m'explique què ha passat. (formal)", "right": "Aniré a parlar amb ell perquè m'explique què ha passat."}]}, {"title": "Temporals de futur i condicionals", "text": "Amb *quan*, *així que*, *tan prompte com* o *tan bon punt* referits al **futur**, hui el més habitual és el **present de subjuntiu**, però el **futur** és l'ús més tradicional i també és correcte. En les condicionals **irreals**, *si* + **imperfet de subjuntiu** i condicional en la principal; en les irreals de passat, *si* + *haguera* + participi.", "table": {"head": ["condicional", "exemple"], "rows": [["real", "Si ho **aprove** tot, me n'aniré d'acampada."], ["irreal", "Si ho **aprovara** tot, me n'aniria d'acampada."], ["irreal de passat", "Si ho **haguera aprovat** tot, me n'hauria anat d'acampada."]]}, "examples": ["**Quan acabem** (o *acabarem*) la faena, ja farem un viatge.", "**Així que arribe** Conxa, ens n'anirem."]}, {"title": "Ordes en negatiu amb pronoms", "text": "En negatiu **no s'usa l'imperatiu**, sinó ***no* + present de subjuntiu**, i els pronoms passen **davant del verb**. Amb *vosté* i *vostés* van les formes de tercera persona. Per a donar una orde a algú que no és davant, *que* + subjuntiu.", "table": {"head": ["afirmatiu", "negatiu"], "rows": [["*Fes-ho.*", "*No ho faces.*"], ["*Ves-te'n.*", "*No te'n vages.*"], ["*Dona-me-la.*", "*No me la dones.*"], ["*Veniu.*", "*No vingueu.*"], ["*Parle* (vosté) *fluix.*", "*No parle* (vosté) *tan fort.*"]]}, "examples": ["**Que vinguen** ja, que es fa tard."], "watch": [{"wrong": "No preocupa't.", "right": "No et preocupes."}, {"wrong": "No toca això, que crema.", "right": "No toques això, que crema."}]}], "remember": ["Principal en present: present de subjuntiu; en passat o condicional: imperfet de subjuntiu.", "Imperfet de subjuntiu: *cantara* o *cantés*; totes dues sèries són correctes.", "Finals amb *perquè* + subjuntiu; *per a que*, només en contextos poc formals.", "*Quan arribes* és el més habitual, però *quan arribaràs* també és correcte.", "Orde negativa: *no* + pronoms + subjuntiu: *no te'n vages*, *no ho faces*."], "sources": [{"gram": "GVB", "section": "26.3.1", "title": "Pronoms anteposats i posposats al verb", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronoms_anteposats_i_posposats"}, {"gram": "GVB", "section": "41.4.1", "title": "Les conjuncions completives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_completives"}, {"gram": "GVB", "section": "41.4.3", "title": "Les conjuncions concessives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_concessives"}, {"gram": "GVB", "section": "41.4.5", "title": "Les conjuncions finals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_finals"}, {"gram": "GVB", "section": "41.4.7", "title": "Les conjuncions temporals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_temporals"}, {"gram": "GVB", "section": "41.4.8", "title": "Les conjuncions modals i comparatives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=41_4_8"}, {"gram": "GNV", "section": "28.3", "title": "El mode", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=categoria_mode"}, {"gram": "GNV", "section": "28.4.2", "title": "Els temps verbals de subjuntiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=subjuntiu"}, {"gram": "GNV", "section": "28.5", "title": "Precisions sobre l'ús de l'indicatiu i el subjuntiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=precisions_us_indicatiu_subjuntiu"}, {"gram": "GNV", "section": "29.5", "title": "Precisions sobre el polimorfisme verbal", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=polimorfisme_verbal"}, {"gram": "GNV", "section": "30.2.4.3", "title": "Verbs amb passat simple i imperfet de subjuntiu forts", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}, {"gram": "GNV", "section": "34.5.2", "title": "Les conjuncions condicionals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=conjuncions_condicionals"}, {"gram": "GNV", "section": "34.5.5", "title": "Les conjuncions finals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=34_5_5"}, {"gram": "GNV", "section": "34.5.7", "title": "Les conjuncions temporals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=conjuncions_temporals"}]}},
  {"type": "b2_mor_ser_estar", "lesson": {"intro": "Aprendràs a triar entre *ser* i *estar* segons si l'atribut és una propietat o un estat, a localitzar persones, coses i actes en registre formal, i a usar la passiva amb *ser*.", "blocks": [{"title": "Propietats: sempre *ser*", "text": "Quan l'atribut indica una **propietat** (origen, matèria, classe, caràcter, professió...), el verb és ***ser***, siga quina siga la forma de l'atribut. A més, ***estar* no admet mai un atribut nominal**: no pots dir *està un bon home* ni *està metge*.", "examples": ["Pau **és** valencià. Maria **és de** Castelló.", "La Terra **és** redona.", "Este café **és sense** cafeïna.", "El teu mòbil **és** molt menut."], "watch": [{"wrong": "El meu oncle està metge.", "right": "El meu oncle és metge."}]}, {"title": "Estats transitoris: persones", "text": "Si el subjecte és una **persona** (o un animal) i l'atribut indica un **estat transitori**, l'ús general és ***estar***: amb adjectius, participis, sintagmes amb preposició o adverbis. L'**estat civil** s'ha vist tradicionalment com una propietat (*és casat*, *és viuda*), però hui també es troba amb *estar*.", "examples": ["El mestre **està** malalt.", "La mare **està** gitada.", "Els xiquets **estan** en perill.", "Carme ja **està** bé.", "Pere **és** casat (o *està casat*)."]}, {"title": "Estats transitoris: coses", "text": "Si el subjecte és una **cosa**, amb un **adjectiu** l'ús més genuí és *ser*, però *estar* cada vegada s'estén més: tots dos són possibles. En canvi, amb **participis**, preposicions i adverbis, l'ús més estés és ***estar***.", "table": {"head": ["atribut", "persona", "cosa"], "rows": [["propietat", "Pau **és** valencià.", "La Terra **és** redona."], ["estat: adjectiu", "El mestre **està** malalt.", "La llet **és** (o **està**) calenta."], ["estat: participi, preposició, adverbi", "Carme ja **està** bé.", "La casa **està** tancada."]]}, "examples": ["El camp **és** (o **està**) ple de brossa.", "El pis que et vols comprar **està** molt bé."]}, {"title": "On és? *Ser*, *estar* i *haver-hi*", "text": "Per a localitzar una persona, una cosa o un acte **sense remarcar la durada**, en registre formal va ***ser***; si remarques que **hi roman**, ***estar***. En valencià col·loquial *estar* tendix a ocupar el lloc de *ser*, ús que **convé evitar**. Per a presentar una cosa nova en el discurs, ***hi ha***.", "table": {"head": ["", "sense durada", "amb durada"], "rows": [["persona", "Quan he aplegat, el teu fill **era** al carrer.", "El teu fill **està** tot el dia al carrer."], ["cosa", "El llapis que busques **és** al calaix.", "El llapis **ha estat** sempre al calaix."]]}, "examples": ["La conferència **serà** en l'Ajuntament a les huit."], "watch": [{"wrong": "Al baül està una de les figures més boniques que tinc.", "right": "Al baül hi ha una de les figures més boniques que tinc."}]}, {"title": "La passiva i *estar* + gerundi", "text": "La **passiva** es forma amb ***ser* + participi**: és natural en passat o futur i estranya en present o imperfet. En la llengua general es preferix la passiva pronominal. ***Estar* + participi**, en canvi, expressa l'**estat** resultant. *Estar* + gerundi remarca la **durada**: si no la vols remarcar, usa el temps simple.", "examples": ["El dictamen **va ser presentat** ahir pels ponents.", "El gratacel **serà construït** per una empresa valenciana.", "Ahir **es va presentar** el dictamen.", "**Estan estudiant** des de fa quatre hores."], "watch": [{"wrong": "—Què fas? —Estic preparant el sopar. (sense remarcar durada)", "right": "—Què fas? —Prepare el sopar."}]}], "remember": ["Propietat: *ser*. *Estar* no porta mai un nom d'atribut: *és metge*.", "Persona en un estat transitori: *estar malalt*, *estar gitada*.", "Cosa amb adjectiu: *és* o *està calenta*; amb participi: *està tancada*.", "Localitzar sense durada: *ser*; amb durada: *estar*; presentar: *hi ha*.", "Passiva: *ser* + participi (*va ser presentat*); estat: *estar* + participi."], "sources": [{"gram": "GVB", "section": "40.3.4", "title": "Estar + gerundi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=perifrasi_estar_gerundi"}, {"gram": "GNV", "section": "31.4", "title": "Les perífrasis aspectuals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=perifrasis_aspectuals"}, {"gram": "GNV", "section": "32.1", "title": "Conceptes generals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=predicacio_verbal_i_complements"}, {"gram": "GNV", "section": "32.2", "title": "El complement directe i la transitivitat", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=objecte_directe"}, {"gram": "GNV", "section": "33.2.1", "title": "Predicacions no verbals primàries", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=predicacions_no_verbals_primaries"}, {"gram": "GNV", "section": "33.3.1", "title": "Usos atributius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=33_3_1"}, {"gram": "GNV", "section": "33.3.2", "title": "Usos locatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=usos_locatius"}]}},
  {"type": "b2_mor_perifrasis", "lesson": {"intro": "Aprendràs a expressar l'inici sobtat d'una acció, la imminència, la probabilitat en present i en passat, l'aproximació i l'hàbit, i els matisos de l'obligació.", "blocks": [{"title": "Començar: *començar a*, *posar-se a*...", "text": "*Començar a* + infinitiu marca l'**inici** d'una acció. Amb el mateix valor tens ***posar-se a*** (verb pronominal: *es posa*, *ens vam posar*) i, per a un **inici brusc**, *arrancar a*, *trencar* (o *rompre*) *a* i *esclafir* (o *esclatar*) *a*. Totes porten la preposició ***a***.", "examples": ["Va **començar a** ploure quan havíem d'eixir.", "Convé que **et poses a** estudiar de seguida!", "**Arrancà a** córrer i no parà fins que arribà a casa.", "Quan li ho vaig dir, va **rompre a** plorar.", "Li vaig fer un gest i va **esclafir a** riure."], "watch": [{"wrong": "Quan va sentir la notícia, va posar a plorar.", "right": "Quan va sentir la notícia, es va posar a plorar."}]}, {"title": "A punt de passar: *estar a punt de*", "text": "Per a una acció **imminent**, usa ***estar a punt de*** + infinitiu. *Anar a* + infinitiu és correcte sobretot en **imperfet**, per a una acció que s'anava a fer i no es va fer, o quan *anar* és moviment. Però **no té valor de futur**: per al futur, usa el **futur simple**.", "examples": ["Calleu, que **està a punt de** començar l'obra.", "**Anàvem a** eixir de casa quan hem sentit el telèfon.", "Espera, que han tocat a la porta i **vaig a** veure qui és."], "watch": [{"wrong": "La comissió es va a reunir per a resoldre els conflictes.", "right": "La comissió es reunirà per a resoldre els conflictes."}, {"wrong": "Ara vos vaig a dir el que em va passar ahir.", "right": "Ara vos diré el que em va passar ahir."}]}, {"title": "Probabilitat en present i en passat", "text": "Ja saps que ***deure* + infinitiu** expressa una suposició. Per a suposar sobre una cosa **ja acabada**, usa *deure haver* + participi; per a suposar sobre el **passat**, *devia* + infinitiu o el passat simple *degué* (amb *deure* no hi ha passat perifràstic). També fan suposicions el futur i el condicional, sobretot amb *ser*, *estar* i *tindre*.", "table": {"head": ["suposició sobre...", "exemple"], "rows": [["el present", "Ara **deuen estar** sopant."], ["una cosa acabada", "Ja **deuen haver arribat**."], ["el passat", "Em va dir que la casa **devia tindre** sis metres d'amplària."], ["un fet passat puntual", "Li ho **degué dir** ell."], ["el present (futur)", "No les molesteu, que ja **estaran** dormint."]]}}, {"title": "Aproximació, hàbit i acció recent", "text": "***Vindre a*** + infinitiu dona un valor **aproximat**, sovint per a resumir una argumentació. ***Soler*** (o *soldre*) i *acostumar a* + infinitiu indiquen **hàbit**. *Acabar de*, a més de l'acció recent, en negatiu **suavitza** la negació.", "examples": ["Això **ve a ser** una espècie de procés selectiu.", "Al final, tots **venen a dir** el mateix.", "Els diumenges **sol dinar** fora de casa.", "**Acostuma a** passejar totes les vesprades.", "El nou sistema no m'**acaba de** convéncer."]}, {"title": "Obligació: més enllà d'*haver de*", "text": "A més d'***haver de*** (*he* o *haig de*), l'obligació s'expressa amb la construcció impersonal ***cal*** (+ infinitiu o *que* + subjuntiu) i amb ***és necessari que***. *Tindre de* és correcte, però poc usat. **No són acceptables** *hi ha que* ni *tindre que*. *Haver de* també pot fer una deducció: *Han de tindre la música molt forta*.", "examples": ["**Cal que** ens comuniqueu el resultat tan prompte com siga possible.", "**És necessari que** assistisques a la reunió.", "**Haig de** dir-te una cosa."], "watch": [{"wrong": "Tens que vindre.", "right": "Has de vindre."}, {"wrong": "Hi ha que reciclar més.", "right": "Cal reciclar més."}]}], "remember": ["Inici: *començar a*, *posar-se a*, *rompre a*... sempre amb *a*.", "Imminència: *estar a punt de*. *Anar a* no fa de futur: *es reunirà*.", "Suposició: *deu estar*, *deu haver arribat*, *devia tindre*, *degué dir*.", "*Vindre a*: aproximació (*ve a costar*); *soler*: hàbit.", "Obligació: *haver de*, *cal*, *és necessari que*; mai *tindre que* ni *hi ha que*."], "sources": [{"gram": "GVB", "section": "40.2.1", "title": "Acabar de + infinitiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=perifrasi_acabar_de_infinitiu"}, {"gram": "GVB", "section": "40.2.2", "title": "Acostumar a + infinitiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=40_2_2"}, {"gram": "GVB", "section": "40.2.3", "title": "Anar a + infinitiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=40_2_3"}, {"gram": "GVB", "section": "40.2.5", "title": "Començar a + infinitiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=perifrasi_comencar_a_infinitiu"}, {"gram": "GVB", "section": "40.2.7", "title": "Deure + infinitiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=perifrasi_deure_infinitiu"}, {"gram": "GVB", "section": "40.2.9", "title": "Haver de + infinitiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=perifrasi_haver_de_infinitiu"}, {"gram": "GVB", "section": "40.2.11", "title": "Vindre a + infinitiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=40_2_11"}, {"gram": "GNV", "section": "28.4.1", "title": "Els temps verbals d'indicatiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=indicatiu"}, {"gram": "GNV", "section": "30.2.2", "title": "Verbs amb alternances consonàntiques al final del radical", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}, {"gram": "GNV", "section": "31.3", "title": "Les perífrasis modals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=perifrasis_modals"}, {"gram": "GNV", "section": "31.4", "title": "Les perífrasis aspectuals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=perifrasis_aspectuals"}]}},
  {"type": "b2_mor_infinitiu", "lesson": {"intro": "Aprendràs a evitar l'infinitiu en ordes i rètols, a decidir quan l'infinitiu porta article, a distingir *en* i *al* + infinitiu, i a usar bé el gerundi i els participis forts.", "blocks": [{"title": "Ordes i rètols: mai l'infinitiu sol", "text": "Per a donar ordes o prohibir **no s'usa l'infinitiu tot sol**: usa l'**imperatiu**, *no* + subjuntiu o *prohibit* (o *es prohibix*) + infinitiu. Sí que és correcte *a* + infinitiu en ordes enèrgiques. Tampoc no s'ha d'usar l'infinitiu com a verb principal per a **recapitular** un discurs.", "examples": ["**Tanqueu** bé la porta després d'eixir.", "**Prohibit fumar.** **Es prohibix** fumar.", "**No trepitgeu** la gespa.", "**A dormir**, que ja és tardíssim!"], "watch": [{"wrong": "No fumar.", "right": "Prohibit fumar. / No fumeu."}, {"wrong": "Per a concloure, dir que estem molt satisfets.", "right": "Per a concloure, hem de dir que estem molt satisfets."}]}, {"title": "L'infinitiu com a nom: amb article o sense?", "text": "Quan l'infinitiu fa de subjecte o de complement, va **sense article**. Convé evitar *el* + infinitiu amb complements verbals: usa l'infinitiu sol, *el fet de* o un nom. Només porten article els infinitius **substantivats** de veritat, que admeten plural i adjectius: *un dinar molt bo*, *els sopars*.", "examples": ["**Saber** això m'alegra molt.", "**Menjar** massa és perjudicial.", "**El fet de conéixer** bé diferents llengües l'ha ajudat.", "**El dinar** de Nadal. **El saber** no ocupa lloc."], "watch": [{"wrong": "El conéixer bé diferents llengües l'ha ajudat.", "right": "Conéixer bé diferents llengües l'ha ajudat."}]}, {"title": "*En* + infinitiu o *al* + infinitiu", "text": "Totes dues construccions equivalen a *quan* i són genuïnes. ***En*** + infinitiu té valor **puntual**: l'acció passa just abans de la principal. ***Al*** (o *a l'*) + infinitiu té valor **duratiu**: la principal passa mentre dura l'acció. Els pronoms van darrere de l'infinitiu, amb guionet.", "table": {"head": ["construcció", "valor", "exemple"], "rows": [["*en* + infinitiu", "just abans", "**En arribar** el pare, avisa'm."], ["*en* + infinitiu", "just abans", "**En fer-se** de dia anirem a l'hort."], ["*al* + infinitiu", "mentre", "**Al passar** per la plaça ens va saludar."], ["*a l'* + infinitiu", "mentre", "**A l'anar** passaren per Vila-real."]]}}, {"title": "El gerundi: simultaneïtat, no conseqüència", "text": "El gerundi expressa una acció **simultània** o la manera. És **incorrecte** usar-lo per a una acció **posterior** o una conseqüència, i tampoc no pot fer d'adjectiu darrere d'un nom. Cap gerundi correcte no porta *-guent* ni *-quent*: *dient*, *venint*, *vivint*, *bevent*; *creure* fa *creient* (o *creent*).", "examples": ["Se'n va anar **cridant**.", "**Preparant** el sopar em vaig recordar del que t'havia promés."], "watch": [{"wrong": "Va caure trencant-se la cama.", "right": "Va caure i es va trencar la cama."}, {"wrong": "El Govern ha aprovat un decret regulant els estudis.", "right": "El Govern ha aprovat un decret que regula els estudis."}, {"wrong": "diguent, visquent", "right": "dient, vivint"}]}, {"title": "Participis forts i concordança", "text": "Molts verbs fan un **participi fort**: en *-s* (els acabats en *-ndre* i *-metre*), en *-t*, en *-st* o en *-ert*. Els derivats de *tindre* fan el participi regular: *mantingut*, no *mantés*. En els temps compostos, el participi **sol concordar** amb els pronoms *la* i *les*.", "table": {"head": ["verb", "participi"], "rows": [["*prendre*", "*pres*, *presa*, *presos*, *preses*"], ["*escriure*", "*escrit*, *escrita*, *escrits*, *escrites*"], ["*fer*", "*fet*, *feta*, *fets*, *fetes*"], ["*veure* (o *vore*)", "*vist*, *vista*, *vistos* (o *vists*), *vistes*"], ["*obrir*", "*obert*, *oberta*, *oberts*, *obertes*"]]}, "examples": ["—Has vist la meua germana? —No, encara no l'he **vista**.", "Jo no me les he **menjades**, les taronges."]}], "remember": ["Ordes: imperatiu o *no* + subjuntiu; mai *No fumar*, sinó *Prohibit fumar*.", "Infinitiu subjecte sense article: *Menjar massa és perjudicial*.", "*En arribar*: just abans; *al passar*: mentre. Totes dues són correctes.", "Gerundi = simultaneïtat; mai conseqüència. *Dient*, no *diguent*.", "Participis forts: *pres*, *escrit*, *fet*, *vist*, *obert*; *l'he vista*."], "sources": [{"gram": "GVB", "section": "19.2.7", "title": "L'ús de l'article definit davant d'infinitius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=19_2_7"}, {"gram": "GVB", "section": "26.3.1", "title": "Pronoms anteposats i posposats al verb", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronoms_anteposats_i_posposats"}, {"gram": "GVB", "section": "27.2.2", "title": "Els pronoms no reflexius de tercera persona", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronoms_personals_febles_no_reflexius_tercera_persona"}, {"gram": "GVB", "section": "30.3", "title": "A", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=preposicions_atones"}, {"gram": "GVB", "section": "30.4", "title": "En", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=30_4"}, {"gram": "GNV", "section": "26.3.1.3", "title": "La construcció «en o al + infinitiu»", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=26_3"}, {"gram": "GNV", "section": "28.6.1", "title": "Caracterització general", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=28_6_1"}, {"gram": "GNV", "section": "28.6.2", "title": "Precisions sobre l'ús de les formes no personals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=28_6_2"}, {"gram": "GNV", "section": "30.1", "title": "Conceptes generals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=verbs_irregulars"}, {"gram": "GNV", "section": "30.2.3", "title": "Tendència a la generalització de formes velaritzades", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}, {"gram": "GNV", "section": "30.2.4.2", "title": "Verbs amb i consonàntica en formes del present d'indicatiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=30_2_4_2"}, {"gram": "GNV", "section": "30.2.4.4", "title": "Els participis forts", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=participis_forts"}]}}
]$data$::jsonb) AS l(type text, lesson jsonb)
WHERE r.category = 'morfosintaxi' AND r.difficulty = 'B2' AND r.type = l.type;

-- ============================================================
-- Origen: 20261013160000_practice_skills_b2.sql
-- ============================================================
-- Àrees de destreses del Quadern B2 de la JQCV (2. Objectius per àrees):
-- Comprensió oral, Comprensió escrita, Expressió i interacció escrites i
-- Expressió i interacció orals, amb el mateix format que les del B1
-- (20261002120000). Són recursos del nivell B2 (resources.difficulty) amb contingut B2:
--   * Comprensió oral: converses entre parlants natius, gestions i transaccions,
--     entrevistes i documentals, ficció i entreteniment (ironia, humor, emocions),
--     debats i conferències, amb registres i varietats geogràfiques.
--     Els àudios es generen amb el TTS (backend/scripts/generate-practice-audio.ts)
--     a /audio/practice/<type>-b2-<posició>.wav.
--   * Comprensió escrita: premsa, textos argumentatius, literaris contemporanis,
--     de l'Administració, especialitzats i humorístics.
--   * Expressió escrita: redaccions que avalua el LLM (del B1 amunt, amb la rúbrica
--     del B1); el resum i els apunts porten el text o l'àudio de referència.
--   * Expressió oral: xats amb un personatge; el system_prompt es compon amb el del
--     personatge, unes pautes comunes del B2 i els objectius.
-- Tornar a aplicar el fitxer no duplica res: es reescriu el contingut B2.

DO $do$
DECLARE
  catalog jsonb := $data$[
  {"id": "3c13e6a0-cfb1-5dc1-a526-f8abd20e08e7", "category": "comprensio_oral", "type": "b2_co_converses", "sort_order": 1, "title": "Converses entre nadius", "name": "Herències, notícies i sobreentesos", "content": "Entén tota la informació d'una conversa entre parlants natius a ritme normal, amb sobreentesos, ironia i canvis de registre.", "icon": "🗣️", "color": "#B2EBF2", "blocks": [{"passage": {"media": "audio", "title": "La casa del poble", "lines": [{"speaker": "Amparo", "voice": "gina", "text": "Xavier, t'ha telefonat el notari? Diu que l'agència de Dénia ha fet una oferta per la casa de l'àvia i que necessita una resposta abans de final de mes."}, {"speaker": "Xavier", "voice": "lluc", "text": "Sí, m'ha cridat esta vesprada. Cent quaranta mil euros. I abans que m'ho digues: sí, ja sé que és més del que esperàvem."}, {"speaker": "Amparo", "voice": "gina", "text": "Més del que esperàvem? És quasi el doble del que ens va dir el taxador fa dos anys. Jo no sé què hi ha per pensar."}, {"speaker": "Xavier", "voice": "lluc", "text": "Doncs hi ha molt per pensar, Amparo. Eixa casa no és només un número. Allí passàvem tots els estius, allí l'avi ens va ensenyar a nadar al riu. A mi em fa pena que acabe convertida en un apartament turístic amb una piscina blava i quatre gandules."}, {"speaker": "Amparo", "voice": "gina", "text": "Ah, clar, la pena. I la pena paga la teulada? Perquè l'hivern passat vam haver de pagar entre els dos mil huit-cents euros per les goteres, i l'arquitecte ja ens va avisar que d'ací a poc caldrà refer tota la coberta. Això sí, la pena la tindrem ben conservada."}, {"speaker": "Xavier", "voice": "lluc", "text": "No cal que sigues sarcàstica. Jo només dic que hi ha altres opcions. Podríem llogar-la uns mesos a l'any, o fins i tot arreglar-la a poc a poc i anar-hi els caps de setmana."}, {"speaker": "Amparo", "voice": "gina", "text": "Anar-hi els caps de setmana. Tu, que en els últims tres anys hi has anat, a vore, dues vegades? I una era per a ensenyar-la al taxador."}, {"speaker": "Xavier", "voice": "lluc", "text": "Bé, d'acord, ho reconec. Però ara és diferent: Laura i jo estem pensant seriosament a deixar València. Amb el teletreball, ella podria fer la faena des de qualsevol lloc, i jo, si em donen el trasllat a l'institut de Pego, estaria a vint minuts."}, {"speaker": "Amparo", "voice": "gina", "text": "Espera, espera. Això és nou. Des de quan?"}, {"speaker": "Xavier", "voice": "lluc", "text": "Des de fa unes setmanes. No t'ho havia dit perquè encara no és segur. El trasllat no es resol fins al juliol."}, {"speaker": "Amparo", "voice": "gina", "text": "I l'oferta caduca a final de mes. Quina casualitat més oportuna."}, {"speaker": "Xavier", "voice": "lluc", "text": "No és cap casualitat, no m'ho he inventat ara per a convéncer-te. Mira, fem una cosa: demana-li al notari si podem allargar el termini fins a l'agost. Si no em donen el trasllat, venem i no en parlem més."}, {"speaker": "Amparo", "voice": "gina", "text": "I si te'l donen?"}, {"speaker": "Xavier", "voice": "lluc", "text": "Llavors et compre la teua meitat pel mateix preu que oferix l'agència. Ho hauria de pagar amb una hipoteca, però ho pagaria."}, {"speaker": "Amparo", "voice": "gina", "text": "Setanta mil euros. Tu saps el que dius? Bé, d'acord. Li ho preguntaré demà. Però si l'agència diu que no espera, no penses que renunciaré a eixos diners per una vesprada al riu."}]}, "exercises": [{"q": "Per què han de prendre una decisió prompte els dos germans?", "o": ["L'oferta de compra de la casa caduca a final de mes", "El notari vol jubilar-se a final de mes", "L'arquitecte ha de començar les obres a l'agost"], "e": "El notari necessita «una resposta abans de final de mes»."}, {"q": "Què pensa Amparo, d'entrada, de l'oferta de l'agència?", "o": ["Que és tan bona que no cal pensar-s'ho", "Que és massa baixa per a una casa així", "Que caldria demanar una altra taxació"], "e": "«És quasi el doble del que ens va dir el taxador [...]. Jo no sé què hi ha per pensar.»"}, {"q": "Què vol dir Amparo amb «la pena la tindrem ben conservada»?", "o": ["Que els sentiments no paguen les reparacions de la casa", "Que la casa està en millor estat del que pareix", "Que ella també sent molta nostàlgia per la casa"], "e": "És un comentari sarcàstic: la nostàlgia de Xavier no resol el problema de la teulada."}, {"q": "Segons l'arquitecte, què caldrà fer en la casa d'ací a poc?", "o": ["Refer tota la coberta", "Arreglar la piscina", "Reparar les goteres de l'hivern"], "e": "«D'ací a poc caldrà refer tota la coberta.» Les goteres ja es van pagar l'hivern passat."}, {"q": "Per què recorda Amparo quantes vegades ha anat Xavier a la casa?", "o": ["Per a mostrar que la proposta d'anar-hi els caps de setmana és poc creïble", "Per a retraure-li que no l'ajudà a ensenyar la casa al taxador", "Per a demostrar que ella hi ha anat moltes més vegades"], "e": "Xavier hi ha anat dues vegades en tres anys; el seu pla de passar-hi els caps de setmana no convenç."}, {"q": "Quina informació nova aporta Xavier a la conversa?", "o": ["Que potser se'n va a viure a prop del poble amb Laura", "Que Laura ha perdut la faena a València", "Que ja li han concedit el trasllat a Pego"], "e": "Pensen a deixar València i ell ha demanat el trasllat a Pego, però «encara no és segur»."}, {"q": "Amb quina actitud diu Amparo «Quina casualitat més oportuna»?", "o": ["Sospita que Xavier s'inventa excuses per a guanyar temps", "Se n'alegra perquè així no caldrà vendre la casa", "Li sap greu que el trasllat tarde tant a resoldre's"], "e": "Xavier ho entén així i respon: «No m'ho he inventat ara per a convéncer-te.»"}, {"q": "A què arriben al final?", "o": ["A demanar més temps i, si hi ha trasllat, Xavier comprarà la part d'Amparo", "A vendre la casa ara i comprar-ne una altra a Pego", "A llogar la casa uns mesos a l'any fins a l'agost"], "e": "Amparo preguntarà si es pot allargar el termini; si a Xavier li donen el trasllat, li comprarà la meitat."}]}, {"passage": {"media": "audio", "title": "Després del sopar", "lines": [{"speaker": "Clara", "voice": "gina", "text": "Bé, ara que ja estem a soles, ja pots dir-ho. Què t'ha paregut el sopar?"}, {"speaker": "Pau", "voice": "lluc", "text": "El sopar, boníssim. L'arròs al forn de Toni és dels millors que he menjat mai. Ara, la notícia de les postres encara l'estic pairant."}, {"speaker": "Clara", "voice": "gina", "text": "Jo també. Deixar una plaça fixa al banc després de quinze anys per a obrir una llibreria a Xàtiva. Ell ho contava tan content, i Mireia, mentrestant, no obria la boca."}, {"speaker": "Pau", "voice": "lluc", "text": "T'hi has fixat, tu també? Cada vegada que Toni parlava del local, ella mirava el plat. I quan ha dit que ho pagarien amb els estalvis de casa, s'ha alçat a portar més aigua, i ningú n'havia demanat."}, {"speaker": "Clara", "voice": "gina", "text": "Jo crec que ella no ho veu gens clar, però no ha volgut dir res davant de nosaltres. Ja saps com és: abans morta que discutir en públic."}, {"speaker": "Pau", "voice": "lluc", "text": "I tu, què en penses? Sincerament."}, {"speaker": "Clara", "voice": "gina", "text": "Sincerament? Que és valent, i que és un poc inconscient. Una llibreria, hui en dia, en una ciutat on n'han tancat dues en cinc anys. Ara, si algú ho pot fer funcionar, és ell: coneix mig poble, organitza les presentacions de llibres de la Casa de Cultura i té una paciència infinita."}, {"speaker": "Pau", "voice": "lluc", "text": "A mi el que em preocupa és que ho ha plantejat com si ja estiguera decidit. No ens ha preguntat què ens pareixia; ens ho ha comunicat."}, {"speaker": "Clara", "voice": "gina", "text": "Home, tampoc no ens havia de demanar permís. Però sí, potser esperava que l'aplaudírem i ja està. I tu, tan diplomàtic, li has dit: que interessant. Que interessant! Pareixia que parlares del temps."}, {"speaker": "Pau", "voice": "lluc", "text": "Què volies que li diguera, que estava boig? Espera, que em crida el meu cap. A estes hores?"}, {"speaker": "Pau", "voice": "lluc", "text": "Bona nit, senyor Ferrer. No, no em molesta gens, diga'm. Sí, l'informe està enllestit; l'hi enviaré a primera hora perquè el puga revisar abans de la reunió amb la consellera. Entesos. No es preocupe, que no hi haurà cap problema. Bona nit."}, {"speaker": "Clara", "voice": "gina", "text": "Senyor Ferrer! Quina formalitat de sobte. I a mi em parles com si fóra un company del bar."}, {"speaker": "Pau", "voice": "lluc", "text": "És el meu cap, Clara, i té seixanta-dos anys. Bé, on érem? Ah, sí, Toni. Mira, jo crec que demà hauries de telefonar a Mireia. A tu t'ho contarà."}, {"speaker": "Clara", "voice": "gina", "text": "Ja ho havia pensat. Però no li preguntaré directament per la llibreria; la convidaré a esmorzar i ja eixirà el tema tot sol."}]}, "exercises": [{"q": "Quina notícia ha donat Toni durant el sopar?", "o": ["Que deixarà el banc per a obrir una llibreria a Xàtiva", "Que l'han acomiadat del banc després de quinze anys", "Que organitzarà les presentacions de la Casa de Cultura"], "e": "«Deixar una plaça fixa al banc després de quinze anys per a obrir una llibreria a Xàtiva.»"}, {"q": "Què deduïxen Clara i Pau de l'actitud de Mireia?", "o": ["Que no està d'acord amb el projecte, però no ho ha volgut dir", "Que està tan il·lusionada com Toni amb la llibreria", "Que no sabia res del projecte fins a eixa nit"], "e": "Mirava el plat, s'ha alçat quan es parlava dels estalvis i «no ho veu gens clar, però no ha volgut dir res»."}, {"q": "Per què s'alça Mireia a portar aigua, segons Pau?", "o": ["Per a evitar la conversa sobre els estalvis", "Perquè els convidats li n'havien demanat", "Perquè l'arròs al forn era massa salat"], "e": "S'alça quan Toni parla dels estalvis «i ningú n'havia demanat»: és una manera de fugir del tema."}, {"q": "Quina dada fa pensar a Clara que el projecte és arriscat?", "o": ["A la ciutat han tancat dues llibreries en cinc anys", "Toni no té cap experiència amb el món dels llibres", "El local que han triat és massa car"], "e": "«En una ciutat on n'han tancat dues en cinc anys.»"}, {"q": "Què és el que més molesta a Pau de la manera d'actuar de Toni?", "o": ["Que els ha presentat la decisió com un fet consumat", "Que no els haja convidat abans a vore el local", "Que haja demanat diners als amics per a la llibreria"], "e": "«No ens ha preguntat què ens pareixia; ens ho ha comunicat.»"}, {"q": "Què retrau Clara a Pau quan repetix «Que interessant!»?", "o": ["Que la seua reacció ha sigut freda i evasiva", "Que s'ha mostrat massa entusiasta amb Toni", "Que ha criticat Toni davant de Mireia"], "e": "Amb ironia diu que «pareixia que parlares del temps»: Pau no s'ha mullat."}, {"q": "Com canvia la manera de parlar de Pau en la telefonada?", "o": ["Passa a un registre formal i tracta el cap de vostè", "Parla amb el cap amb la mateixa confiança que amb Clara", "Respon de manera seca perquè la telefonada el molesta"], "e": "Usa «senyor Ferrer», «diga'm», «no es preocupe»; Clara ho comenta: «Quina formalitat de sobte.»"}, {"q": "Com pensa Clara parlar amb Mireia?", "o": ["De manera indirecta, convidant-la a esmorzar", "Preguntant-li obertament per la llibreria", "Per telèfon, junt amb Pau, eixa mateixa nit"], "e": "«No li preguntaré directament per la llibreria; la convidaré a esmorzar.»"}]}]},
  {"id": "c71e50c7-ad9c-5439-97fe-c3ca2c44a3b1", "category": "comprensio_oral", "type": "b2_co_gestions", "sort_order": 2, "title": "Gestions i reclamacions", "name": "Tràmits per telèfon i negociacions en persona", "content": "Entén els detalls d'una gestió telefònica amb una administració i d'una reclamació en persona, i seguix com es negocia un acord.", "icon": "🏛️", "color": "#FFE0B2", "blocks": [{"passage": {"media": "audio", "title": "Una telefonada a l'Ajuntament", "lines": [{"speaker": "Empar", "voice": "gina", "text": "Oficina d'Atenció Ciutadana de l'Ajuntament d'Alcoi, l'atén Empar. En què puc ajudar-lo?"}, {"speaker": "Rafel", "voice": "lluc", "text": "Bon dia. Mire, el mes passat vaig instal·lar plaques solars a la teulada de casa i un veí em va dir que l'Ajuntament fa una bonificació en l'IBI. Volia saber com s'ha de sol·licitar."}, {"speaker": "Empar", "voice": "gina", "text": "Sí, efectivament. L'ordenança fiscal preveu una bonificació del cinquanta per cent de la quota de l'impost durant tres anys per a les instal·lacions d'autoconsum. Ara bé, l'he d'avisar que hi ha uns quants requisits. Per a començar, la instal·lació ha de tindre presentada la declaració responsable d'obres."}, {"speaker": "Rafel", "voice": "lluc", "text": "Això ho va fer l'empresa instal·ladora, crec. Almenys em van dir que se n'encarregaven ells de tot el paperam."}, {"speaker": "Empar", "voice": "gina", "text": "Convé que ho comprove, perquè és el primer que es revisa. També ha d'aportar el certificat de la instal·lació, registrat en Indústria, i la factura on conste el cost. I un detall important: la sol·licitud s'ha de presentar dins dels sis mesos següents a la instal·lació; si no, perd el dret a la bonificació."}, {"speaker": "Rafel", "voice": "lluc", "text": "Sis mesos des de quan? Des que la van muntar o des que va començar a funcionar? Perquè la van posar a l'agost, però no la van connectar fins al setembre, per un problema amb la distribuïdora."}, {"speaker": "Empar", "voice": "gina", "text": "Compta la data del certificat d'instal·lació, que normalment coincidix amb la posada en marxa. Si vosté el té del setembre, li queda temps de sobra fins al març."}, {"speaker": "Rafel", "voice": "lluc", "text": "Perfecte. I es pot fer per internet o he de passar per l'oficina? És que treballe a València i només podria vindre algun divendres de vesprada."}, {"speaker": "Empar", "voice": "gina", "text": "Es pot fer per la seu electrònica amb certificat digital o amb la clau permanent. Si no en té, pot vindre amb cita prèvia, però els divendres de vesprada l'oficina està tancada. Obrim de dilluns a divendres de huit a tres, i els dijous també de cinc a set."}, {"speaker": "Rafel", "voice": "lluc", "text": "Doncs ja veig que hauré de traure'm el certificat digital d'una vegada, que fa dos anys que dic que ho faré. Una última cosa: la bonificació se m'aplicarà en el rebut d'enguany?"}, {"speaker": "Empar", "voice": "gina", "text": "No. Si la concedixen, s'aplicarà a partir del rebut de l'any que ve. I tinga en compte que el termini per a resoldre és de tres mesos; si passat eixe temps no ha rebut cap resposta, li recomane que telefone per a saber com va l'expedient."}, {"speaker": "Rafel", "voice": "lluc", "text": "Molt bé. Moltes gràcies, ho ha explicat tot molt clar."}, {"speaker": "Empar", "voice": "gina", "text": "De res, a vosté. Que tinga un bon dia."}]}, "exercises": [{"q": "Per què telefona Rafel a l'Ajuntament?", "o": ["Per a saber com es demana una bonificació de l'IBI", "Per a sol·licitar una llicència per a instal·lar plaques", "Per a reclamar un error en el rebut de l'IBI"], "e": "Vol «saber com s'ha de sol·licitar» la bonificació per les plaques solars."}, {"q": "En què consistix la bonificació?", "o": ["En un descompte del cinquanta per cent de l'impost durant tres anys", "En un descompte del trenta per cent de l'impost durant cinc anys", "En una ajuda que cobrix la meitat del cost de les plaques"], "e": "«Una bonificació del cinquanta per cent de la quota de l'impost durant tres anys.»"}, {"q": "Què li aconsella Empar que comprove?", "o": ["Que l'empresa va presentar la declaració responsable d'obres", "Que la distribuïdora ja ha connectat la instal·lació", "Que el seu veí també ha demanat la bonificació"], "e": "Rafel creu que ho va fer l'empresa, i Empar respon: «Convé que ho comprove.»"}, {"q": "Des de quina data es compten els sis mesos del termini?", "o": ["Des de la data del certificat d'instal·lació", "Des del dia que van muntar les plaques", "Des del dia que va telefonar a l'Ajuntament"], "e": "«Compta la data del certificat d'instal·lació, que normalment coincidix amb la posada en marxa.»"}, {"q": "Per què Rafel no podrà fer el tràmit en persona com pensava?", "o": ["Perquè els divendres de vesprada l'oficina està tancada", "Perquè l'oficina no atén sense certificat digital", "Perquè els dijous de vesprada no hi ha cites lliures"], "e": "Ell només podria anar «algun divendres de vesprada», i eixe horari l'oficina està tancada."}, {"q": "Què podem deduir del comentari de Rafel sobre el certificat digital?", "o": ["Que fa temps que ajorna un tràmit que sap que necessita", "Que ja el té, però no sap com s'utilitza", "Que pensa que el certificat no li servirà de res"], "e": "«Fa dos anys que dic que ho faré»: reconeix amb un poc d'humor que ho ha anat deixant."}, {"q": "Quan notarà Rafel la bonificació, si li concedixen la bonificació?", "o": ["En el rebut de l'any que ve", "En el rebut d'enguany", "D'ací a tres mesos"], "e": "«S'aplicarà a partir del rebut de l'any que ve.» Els tres mesos són el termini per a resoldre."}, {"q": "Com és el registre de la conversa?", "o": ["Formal i cortés, amb tractament de vostè", "Col·loquial, amb tractament de tu", "Formal per part de Rafel, però informal per part d'Empar"], "e": "Tots dos es tracten de vostè: «l'atén», «mire», «tinga en compte», «que tinga un bon dia»."}]}, {"passage": {"media": "audio", "title": "Una reclamació a la botiga", "lines": [{"speaker": "Sílvia", "voice": "gina", "text": "Bon dia. Voldria parlar amb l'encarregat, per favor."}, {"speaker": "Joan", "voice": "lluc", "text": "Jo mateix. Em dic Joan Llorca. Vosté dirà."}, {"speaker": "Sílvia", "voice": "gina", "text": "Mire, fa dues setmanes que em van portar el sofà que vaig comprar ací a primers de mes, i hi ha dos problemes. El primer, que el color no és el que vaig triar: jo vaig demanar gris perla i m'han portat un gris marengo, que és pràcticament negre. I el segon, que una de les potes va arribar trencada. Ací tinc la comanda i les fotos."}, {"speaker": "Joan", "voice": "lluc", "text": "A vore. Sí, en la comanda posa gris perla, té raó. Quant a la pota, ho va fer constar en l'albarà de lliurament quan el van descarregar?"}, {"speaker": "Sílvia", "voice": "gina", "text": "No, perquè els repartidors tenien pressa i el van deixar embolicat. Vaig vore la pota l'endemà, quan el vaig desembolicar. Però ho vaig notificar per correu electrònic eixe mateix dia, i ningú no m'ha contestat. Per això he vingut."}, {"speaker": "Joan", "voice": "lluc", "text": "Entenc. Li demane disculpes pel correu; estes setmanes anem un poc saturats. El que li puc oferir és canviar-li el sofà per un del color correcte, però el fabricant tarda unes sis setmanes a servir-lo."}, {"speaker": "Sílvia", "voice": "gina", "text": "Sis setmanes? Fantàstic. Tindré visites per Nadal i s'hauran d'asseure a terra, que és molt acollidor. No, mire, això no em val."}, {"speaker": "Joan", "voice": "lluc", "text": "Comprenc que no és l'ideal. Hi ha una altra possibilitat: tenim en exposició el mateix model en gris perla. Està en perfecte estat, però ha estat a la botiga tres mesos. L'hi podríem portar esta mateixa setmana."}, {"speaker": "Sílvia", "voice": "gina", "text": "Un sofà d'exposició, on s'ha assegut mig Gandia, al mateix preu que un de nou? No sé si m'acaba de convéncer."}, {"speaker": "Joan", "voice": "lluc", "text": "No, al mateix preu no. Li podria tornar un quinze per cent."}, {"speaker": "Sílvia", "voice": "gina", "text": "Un quinze? Tenint en compte que l'error és vostre i que porte dues setmanes esperant una resposta, jo diria que un vint-i-cinc seria més just. I que els repartidors s'enduguen el sofà equivocat sense cap cost, és clar."}, {"speaker": "Joan", "voice": "lluc", "text": "El vint-i-cinc no està en la meua mà; això ho hauria d'autoritzar la gerència. El que sí que puc fer és un vint per cent, el transport gratuït i la retirada de l'altre. I a més li allargue la garantia un any."}, {"speaker": "Sílvia", "voice": "gina", "text": "Vint per cent, transport, retirada i un any més de garantia. D'acord, accepte. Però ho vull per escrit, per favor. De paraules ja en tinc moltes; de correus contestats, cap."}, {"speaker": "Joan", "voice": "lluc", "text": "Ara mateix l'hi prepare i l'hi signe."}]}, "exercises": [{"q": "Per què reclama Sílvia?", "o": ["El sofà és d'un altre color i té una pota trencada", "El sofà no ha arribat després de dues setmanes", "Li han cobrat un sofà més car del que va triar"], "e": "Va demanar gris perla, li n'han portat un gris marengo i «una de les potes va arribar trencada»."}, {"q": "Per què li pregunta Joan per l'albarà de lliurament?", "o": ["Per a saber si el desperfecte es va anotar en rebre el sofà", "Per a comprovar quin color havia demanat Sílvia", "Per a saber quin dia exacte li van portar el sofà"], "e": "«Ho va fer constar en l'albarà de lliurament quan el van descarregar?»"}, {"q": "Què va fer Sílvia quan va descobrir la pota trencada?", "o": ["Ho va comunicar per correu electrònic el mateix dia", "Va telefonar als repartidors perquè tornaren", "Va anar a la botiga l'endemà a queixar-se"], "e": "«Ho vaig notificar per correu electrònic eixe mateix dia, i ningú no m'ha contestat.»"}, {"q": "Amb quina intenció diu Sílvia «que és molt acollidor»?", "o": ["Rebutja amb sarcasme esperar sis setmanes el sofà nou", "Accepta de bon grat esperar fins després de Nadal", "Explica que els seus convidats preferixen seure a terra"], "e": "És ironia: sense sofà, les visites de Nadal hauran de seure a terra. Tot seguit diu: «Això no em val.»"}, {"q": "Per què no la convenç d'entrada el sofà d'exposició?", "o": ["Perquè ha sigut usat i pensa que l'hi cobrarien com a nou", "Perquè no és del mateix model que el que va comprar", "Perquè no el podrien portar fins després de Nadal"], "e": "«Un sofà d'exposició, on s'ha assegut mig Gandia, al mateix preu que un de nou?»"}, {"q": "Quins arguments usa Sílvia per a demanar un descompte més alt?", "o": ["L'error de la botiga i les dues setmanes sense resposta", "Que és una clienta habitual de la botiga", "Que en una altra botiga el sofà era més barat"], "e": "«Tenint en compte que l'error és vostre i que porte dues setmanes esperant una resposta.»"}, {"q": "Com acaba la negociació?", "o": ["Amb un vint per cent, transport i retirada gratuïts i més garantia", "Amb un vint-i-cinc per cent autoritzat per la gerència", "Amb un quinze per cent i el sofà nou d'ací a sis setmanes"], "e": "Joan oferix «un vint per cent, el transport gratuït i la retirada» i un any més de garantia; Sílvia accepta."}, {"q": "Per què vol Sílvia l'acord per escrit?", "o": ["Perquè ja no es fia de les promeses de la botiga", "Perquè ho exigix la gerència de l'empresa", "Perquè vol presentar una queixa a consum"], "e": "«De paraules ja en tinc moltes; de correus contestats, cap»: desconfia després de l'experiència."}]}]},
  {"id": "12f1926d-c1d0-5909-bda7-97f93f01307f", "category": "comprensio_oral", "type": "b2_co_mitjans", "sort_order": 3, "title": "Ràdio i televisió", "name": "Entrevistes en directe i documentals", "content": "Entén les idees principals i secundàries d'una entrevista en directe i d'un documental, i en percep l'humor, el to i el punt de vista.", "icon": "📻", "color": "#FFCDD2", "blocks": [{"passage": {"media": "audio", "title": "Entrevista en directe: la sal de l'Albufera", "lines": [{"speaker": "Neus", "voice": "gina", "text": "Són les deu i cinc i continuem en directe. Tenim amb nosaltres Andreu Sendra, president d'una cooperativa arrossera de Sueca, que ha vingut a l'estudi en plena sega. Bon dia, Andreu, i gràcies per escapar-te."}, {"speaker": "Andreu", "voice": "lluc", "text": "Bon dia, Neus. Bé, escapar-me. Diguem que la meua dona s'ha quedat amb la recol·lectora i m'ha dit que, si tarde més d'una hora, ja no cal que torne."}, {"speaker": "Neus", "voice": "gina", "text": "Doncs anirem al gra, mai millor dit. Este estiu s'ha parlat molt de la salinitat de l'Albufera. Què està passant exactament?"}, {"speaker": "Andreu", "voice": "lluc", "text": "El problema és que arriba menys aigua dolça del Xúquer, per la sequera i perquè cada vegada se'n destina més a altres usos. Quan l'aigua dolça no fa prou pressió, l'aigua del mar entra per les goles i salinitza els camps més pròxims a la costa. I l'arròs és una planta molt agraïda, però té un límit: amb massa sal, la planta creix, però el gra no s'ompli."}, {"speaker": "Neus", "voice": "gina", "text": "I això, quant afecta la collita?"}, {"speaker": "Andreu", "voice": "lluc", "text": "Enguany, en algunes parcel·les pròximes a la gola, hem perdut fins a un trenta per cent. En la mitjana de la cooperativa, un dotze. Dit així pareix poc, però per a una família que viu de deu hanegades, és la diferència entre arribar a final d'any o no arribar-hi."}, {"speaker": "Neus", "voice": "gina", "text": "Hi ha qui diu que el sector arrosser també en té part de responsabilitat, que gasta molta aigua."}, {"speaker": "Andreu", "voice": "lluc", "text": "Home, és una pregunta que ja esperava, i li agraïsc que me la faça. Mire, l'arròs no consumix l'aigua com un camp de tarongers: l'aigua passa pels camps i torna al llac. Sense eixa aigua, l'Albufera seria un bassal. Ara, també li dic que nosaltres hem de canviar coses, i ho estem fent: hem reduït molt els fitosanitaris i estem provant varietats més resistents a la sal."}, {"speaker": "Neus", "voice": "gina", "text": "I funcionen?"}, {"speaker": "Andreu", "voice": "lluc", "text": "Algunes, sí. El problema és que el consumidor és molt fidel a les varietats de sempre, i quan veu un nom nou en el paquet, desconfia. Així que, a més de llauradors, ara també hem de fer de publicistes."}, {"speaker": "Neus", "voice": "gina", "text": "Ens queden pocs minuts. Què li demanaríeu a l'Administració?"}, {"speaker": "Andreu", "voice": "lluc", "text": "Una cosa molt senzilla d'explicar i molt difícil de fer: que garantisquen un cabal mínim per a l'Albufera tots els anys, no només quan plou. Perquè quan la sal ja ha entrat, ja és tard."}, {"speaker": "Neus", "voice": "gina", "text": "Andreu Sendra, moltes gràcies, i saluda la recol·lectora de part nostra."}, {"speaker": "Andreu", "voice": "lluc", "text": "Ho faré. Bé, saludaré la meua dona, que és qui la porta."}]}, "exercises": [{"q": "En quines circumstàncies es fa l'entrevista?", "o": ["En directe, en plena època de sega de l'arròs", "Gravada, després d'acabar la collita", "Per telèfon, des dels camps de la cooperativa"], "e": "«Continuem en directe [...] ha vingut a l'estudi en plena sega.»"}, {"q": "Què revela el comentari d'Andreu sobre la seua dona?", "o": ["Amb humor, que és un moment de molta faena al camp", "Que la seua dona està en contra que faça l'entrevista", "Que ell no sap conduir la recol·lectora"], "e": "És una broma: si tarda més d'una hora, «ja no cal que torne», perquè la sega no pot esperar."}, {"q": "Per què diu la locutora «anirem al gra, mai millor dit»?", "o": ["Perquè fa un joc de paraules amb el gra d'arròs", "Perquè vol canviar de tema ràpidament", "Perquè l'entrevistat no contesta les preguntes"], "e": "«Anar al gra» vol dir anar a l'essencial, i l'entrevistat és un productor d'arròs."}, {"q": "Quina és la causa principal de la salinització, segons Andreu?", "o": ["Arriba menys aigua dolça i entra aigua del mar per les goles", "Els llauradors usen massa fitosanitaris als camps", "Les varietats d'arròs actuals retenen massa sal"], "e": "Arriba menys aigua del Xúquer i «l'aigua del mar entra per les goles»."}, {"q": "Per què insistix Andreu que un dotze per cent no és poca cosa?", "o": ["Perquè per a les explotacions xicotetes pot ser decisiu", "Perquè és la pèrdua més alta de la història de la cooperativa", "Perquè afecta sobretot les parcel·les més grans"], "e": "Per a una família amb deu hanegades «és la diferència entre arribar a final d'any o no arribar-hi»."}, {"q": "Com reacciona Andreu a la crítica sobre el consum d'aigua?", "o": ["La rebat amb arguments, però admet que el sector ha de canviar", "La rebutja de manera molesta i no hi vol entrar", "Hi dona la raó i proposa reduir els camps d'arròs"], "e": "Explica que l'aigua torna al llac, però reconeix: «Nosaltres hem de canviar coses, i ho estem fent.»"}, {"q": "Quin problema tenen les varietats resistents a la sal?", "o": ["Al consumidor li costa acceptar noms nous", "Totes donen menys gra que les tradicionals", "Encara no estan autoritzades per a vendre's"], "e": "El consumidor és fidel a les de sempre i, quan veu un nom nou, «desconfia»."}, {"q": "Què demana Andreu a l'Administració?", "o": ["Un cabal mínim garantit per a l'Albufera cada any", "Ajudes per a les famílies que han perdut la collita", "Campanyes publicitàries per a les varietats noves"], "e": "«Que garantisquen un cabal mínim per a l'Albufera tots els anys, no només quan plou.»"}]}, {"passage": {"media": "audio", "title": "Documental: els murs de pedra en sec", "lines": [{"speaker": "Narrador", "voice": "lluc", "text": "A Vilafranca, en la comarca dels Ports, hi ha més quilòmetres de murs de pedra en sec que de carreteres. Les parets que dividixen els camps, les cabanes on els pastors s'arreceraven de les tempestes i els marges que sostenen les terrasses de cultiu van ser alçats pedra a pedra, sense cap tipus de morter. Una tècnica que la UNESCO va declarar patrimoni immaterial de la humanitat l'any 2018."}, {"speaker": "Remei", "voice": "gina", "text": "Mon pare deia que una paret ben feta no necessita ciment, necessita paciència. Cada pedra té el seu lloc, i el que fa el margenador és trobar-lo. Si una pedra no t'encaixa, no la forces: la deixes a terra, que ja trobarà el seu moment."}, {"speaker": "Narrador", "voice": "lluc", "text": "Remei Monfort té huitanta-un anys i és una de les últimes persones del poble que va aprendre l'ofici de xiqueta. En aquell temps, construir i reparar marges era una faena de tota la família, sobretot a l'hivern, quan el camp no demanava tanta atenció."}, {"speaker": "Remei", "voice": "gina", "text": "Les dones també en féiem, eh? Això no ho conta mai ningú. Els hòmens alçaven les pedres grosses, i nosaltres omplíem per dins, que és el que fa que la paret aguante. Però clar, la foto sempre se la feien ells."}, {"speaker": "Narrador", "voice": "lluc", "text": "Amb l'èxode rural dels anys seixanta, molts masos van quedar abandonats, i amb ells els murs que els envoltaven. Una paret de pedra en sec pot durar segles si es manté; si no, n'hi ha prou amb unes quantes pluges fortes perquè s'esfondre."}, {"speaker": "Remei", "voice": "gina", "text": "Quan veig una paret caiguda, em fa més pena que una casa en ruïnes. Una casa la fa una família; una paret, de vegades, l'han feta quatre generacions."}, {"speaker": "Narrador", "voice": "lluc", "text": "Però els murs fan molt més que delimitar propietats. Retenen la terra, frenen l'erosió i regulen el pas de l'aigua quan plou de manera torrencial, cosa cada vegada més freqüent. A més, són el refugi de sargantanes, insectes i plantes que difícilment viurien en cap altre lloc. Per això, en els últims anys, diversos ajuntaments de la comarca han organitzat cursos per a formar nous margenadors."}, {"speaker": "Remei", "voice": "gina", "text": "L'any passat vaig participar en un d'eixos cursos, de mestra, això sí. Hi havia una xica de vint-i-cinc anys que tenia més traça que molts hòmens que he conegut. Li ho vaig dir, i es va posar roja com una tomaca."}, {"speaker": "Narrador", "voice": "lluc", "text": "Potser la pedra en sec no tornarà a ser l'ofici que era. Però, mentre hi haja algú disposat a escoltar les pedres, el paisatge dels Ports continuarà sostenint-se tot sol."}]}, "exercises": [{"q": "Què caracteritza la tècnica de la pedra en sec?", "o": ["Les pedres es col·loquen sense cap tipus de morter", "Les pedres s'unixen amb una mescla de terra i calç", "Només s'usa per a construir cabanes de pastors"], "e": "Els murs «van ser alçats pedra a pedra, sense cap tipus de morter»."}, {"q": "Què volia dir el pare de Remei amb la seua frase sobre el ciment?", "o": ["Que l'ofici requerix paciència per a trobar el lloc de cada pedra", "Que el ciment fa les parets menys resistents", "Que les pedres que no encaixen s'han de llançar"], "e": "«Una paret ben feta no necessita ciment, necessita paciència. Cada pedra té el seu lloc.»"}, {"q": "Per què construir marges era sobretot una faena d'hivern?", "o": ["Perquè llavors el camp demanava menys atenció", "Perquè la pluja ablania la terra dels marges", "Perquè a l'estiu els pastors eren a la muntanya"], "e": "Era faena «sobretot a l'hivern, quan el camp no demanava tanta atenció»."}, {"q": "Quina crítica fa Remei sobre el paper de les dones?", "o": ["Que la seua faena era essencial però ningú no la reconeixia", "Que no les deixaven participar en la construcció dels murs", "Que només s'encarregaven de les pedres més grosses"], "e": "Elles omplien la paret, «que és el que fa que la paret aguante», però «la foto sempre se la feien ells»."}, {"q": "Segons el documental, per què es van deteriorar molts murs?", "o": ["Perquè l'èxode rural va deixar els masos abandonats", "Perquè les pluges torrencials són cada vegada més fortes", "Perquè la tècnica es va substituir pel ciment"], "e": "«Amb l'èxode rural dels anys seixanta, molts masos van quedar abandonats, i amb ells els murs.»"}, {"q": "Per què li fa més pena a Remei una paret caiguda que una casa en ruïnes?", "o": ["Perquè una paret pot ser el treball de diverses generacions", "Perquè les parets són més difícils de trobar que les cases", "Perquè la seua família no va tindre mai casa pròpia"], "e": "«Una casa la fa una família; una paret, de vegades, l'han feta quatre generacions.»"}, {"q": "Quina funció dels murs NO es menciona en el documental?", "o": ["Protegir els cultius de les gelades", "Frenar l'erosió del sòl", "Servir de refugi a animals i plantes"], "e": "Es parla de retenir la terra, frenar l'erosió, regular l'aigua i fer de refugi, però no de les gelades."}, {"q": "Què deixa entendre Remei amb l'anècdota de la xica del curs?", "o": ["Que les dones poden ser tan bones o millors margenadores que els hòmens", "Que els joves aprenen l'ofici més ràpidament que els vells", "Que la xica no tenia prou experiència per a fer marges"], "e": "Diu amb orgull i un punt d'ironia que tenia «més traça que molts hòmens que he conegut»."}]}]},
  {"id": "cf2a2ff7-4d5f-5d5e-810b-0a54156841ca", "category": "comprensio_oral", "type": "b2_co_ficcio", "sort_order": 4, "title": "Sèries i entreteniment", "name": "Ironia, humor i emocions en la ficció", "content": "Seguix escenes de sèries i n'inferix la ironia, el sarcasme, les emocions i les intencions que els personatges no expressen directament.", "icon": "🎭", "color": "#D1C4E9", "blocks": [{"passage": {"media": "audio", "title": "Sèrie: la casa intel·ligent", "lines": [{"speaker": "Empar", "voice": "gina", "text": "Ferran, una pregunta tonta. Per què estic sopant a les fosques un dimarts qualsevol?"}, {"speaker": "Ferran", "voice": "lluc", "text": "No és a les fosques, és llum ambiental. L'assistent l'ha posada en mode relax perquè detecta que estàs estressada."}, {"speaker": "Empar", "voice": "gina", "text": "Que detecta que estic estressada. Mira, en això té tota la raó. Fa vint minuts que intente encendre el llum de la cuina i l'única cosa que he aconseguit és que sone música de relaxació a tot volum."}, {"speaker": "Ferran", "voice": "lluc", "text": "Perquè no li parles bé. Has de dir «casa, encén la cuina», amb calma i vocalitzant. Si li crides com abans, normal que no t'entenga."}, {"speaker": "Empar", "voice": "gina", "text": "Ah, clar, la culpa és meua. Jo, que he viscut quaranta anys encenent llums amb un dit, ara he de fer un curs d'oratòria per a vore on deixe les claus."}, {"speaker": "Ferran", "voice": "lluc", "text": "Empar, no sigues exagerada. Reconec que el primer dia sempre hi ha algun detallet que cal ajustar, però d'ací a una setmana no sabràs viure sense ell. Pensa-ho: la calefacció s'encén sola abans que arribem, la persiana s'alça amb el sol i la nevera m'avisa quan falta llet."}, {"speaker": "Empar", "voice": "gina", "text": "Meravellós. I quan pensaves dir-me que la persiana del nostre dormitori s'ha alçat a les sis del matí perquè, segons l'aplicació, a Xàtiva ja havia eixit el sol?"}, {"speaker": "Ferran", "voice": "lluc", "text": "Bé, això és perquè la ubicació estava mal configurada. Ja ho he arreglat. Crec."}, {"speaker": "Empar", "voice": "gina", "text": "Creus. Doncs mira, tinc una notícia. La meua mare ve demà a dinar. Setanta-nou anys, sorda com una tàpia i amb molt poca paciència. Si la porta no se li obri a la primera, se'n torna a Alzira i no la veiem fins a Nadal."}, {"speaker": "Ferran", "voice": "lluc", "text": "La porta! No havia pensat en la teua mare. Bé, li done una clau normal i ja està."}, {"speaker": "Empar", "voice": "gina", "text": "Una clau normal. Quin invent més revolucionari. Potser podríem tornar a posar també interruptors a les parets, que eren tan pràctics."}, {"speaker": "Ferran", "voice": "lluc", "text": "D'acord, d'acord, ho he entés. Si demà a la nit no funciona tot perfectament, ho desinstal·le tot i tornem a l'edat de pedra. Tracte fet?"}, {"speaker": "Empar", "voice": "gina", "text": "Tracte fet. I ara, si no és molèstia, demana-li a la teua casa intel·ligent que pare la música, per favor. Porte mitja hora escoltant ocells i cascades i ja comence a tindre ganes d'anar al bany."}]}, "exercises": [{"q": "Què vol dir Empar quan afirma que l'assistent «en això té tota la raó»?", "o": ["Ironitza: està estressada precisament per culpa de l'assistent", "Reconeix que està estressada per culpa de la seua faena", "Elogia de veritat la precisió de l'aparell nou"], "e": "És una ironia: l'estrés que té l'ha provocat el mateix assistent, que no li encén el llum."}, {"q": "Segons Ferran, per què l'assistent no entén Empar?", "o": ["Perquè no li parla amb calma ni vocalitzant", "Perquè té l'idioma mal configurat", "Perquè l'aparell té un defecte de fàbrica"], "e": "Ferran li diu que ha de parlar «amb calma i vocalitzant», no cridant."}, {"q": "Per què es va alçar la persiana del dormitori a les sis del matí?", "o": ["La ubicació de l'aplicació estava mal configurada", "Ferran l'havia programada per a alçar-se prompte", "Empar havia donat l'ordre sense voler"], "e": "L'aplicació creia que estaven a Xàtiva: «la ubicació estava mal configurada»."}, {"q": "Què revela l'intercanvi «Ja ho he arreglat. Crec.» / «Creus.»?", "o": ["Ferran no n'està segur i Empar en desconfia", "Ferran està convençut i Empar el creu", "Ferran fa broma i Empar no l'entén"], "e": "L'afegit «Crec» mostra inseguretat, i Empar el repetix per a subratllar-la amb sarcasme."}, {"q": "Per què a Empar li preocupa especialment la visita de sa mare?", "o": ["Si no pot obrir la porta, se n'anirà ofesa", "Sa mare no suporta la música de relaxació", "Sa mare vol quedar-se a dormir una setmana"], "e": "«Si la porta no se li obri a la primera, se'n torna a Alzira.»"}, {"q": "Quin to té el comentari «Quin invent més revolucionari»?", "o": ["Sarcàstic: es burla que la solució siga tornar a la clau", "Admiratiu: li sembla una idea molt original", "Neutre: simplement accepta la proposta de Ferran"], "e": "Diu el contrari del que pensa: la clau és el sistema de tota la vida."}, {"q": "Quina d'estes funcions de la casa NO esmenta Ferran?", "o": ["La rentadora que posa la bugada sola", "La calefacció que s'encén sola", "La nevera que avisa quan falta llet"], "e": "Ferran parla de la calefacció, la persiana i la nevera, però no de cap rentadora."}, {"q": "Com acaba la discussió?", "o": ["Amb un pacte: si demà falla, ho desinstal·larà tot", "Amb Empar enfadada i sense parlar a Ferran", "Amb Ferran convencent Empar dels avantatges"], "e": "«Si demà a la nit no funciona tot perfectament, ho desinstal·le tot. Tracte fet?»"}]}, {"passage": {"media": "audio", "title": "Sèrie: la casa del pare", "lines": [{"speaker": "Neus", "voice": "gina", "text": "Ja està. L'última caixa de la cuina. Mai no hauria dit que en una casa tan xicoteta cabrien tants plats."}, {"speaker": "Andreu", "voice": "lluc", "text": "El pare no llançava res. Mira, encara hi ha el calendari de l'any que va morir la mare. Dotze anys penjat darrere de la porta."}, {"speaker": "Neus", "voice": "gina", "text": "Ho sé. Cada vegada que pujava a vore'l, me'l trobava ahí. Clar que tu això no ho podies saber, perquè des de Barcelona es veu molt malament."}, {"speaker": "Andreu", "voice": "lluc", "text": "Neus, no comencem. Ja n'hem parlat mil vegades. Jo venia quan podia."}, {"speaker": "Neus", "voice": "gina", "text": "Sí, per Sant Antoni i per Nadal, com els turistes. Bé, deixem-ho. Què diu l'home eixe de l'agència?"}, {"speaker": "Andreu", "voice": "lluc", "text": "M'ha escrit esta vesprada. Llig: «Benvolgut senyor, li comunique que el meu client manté l'oferta presentada i resta a l'espera de la seua resposta abans del dia quinze del mes en curs.» Vol dir que, si diem que sí, la setmana que ve signem."}, {"speaker": "Neus", "voice": "gina", "text": "I la convertiran en apartaments turístics, com totes les del carrer. D'ací a dos anys, en este carrer no hi haurà ni una finestra amb llum a l'hivern."}, {"speaker": "Andreu", "voice": "lluc", "text": "I què vols que fem? Que la tanquem i la deixem caure? Tu vius a Castelló, jo a Barcelona. Ningú no pujarà a Morella cada cap de setmana a obrir finestres."}, {"speaker": "Neus", "voice": "gina", "text": "No ho sé, Andreu. Només sé que quan entre ací encara fa olor de pare. Espera, què és això? Hi ha un quadern davall del calaix."}, {"speaker": "Andreu", "voice": "lluc", "text": "A vore. És la lletra del pare. Són receptes. «Coca de tomaca de la iaia», «Flaons per a quan vinga Andreu»."}, {"speaker": "Neus", "voice": "gina", "text": "Per a quan vinga Andreu. Mira, ací n'hi ha una altra: «Per a Neus, que sempre se'n menja tres». Mira que era detallista, el pare."}, {"speaker": "Andreu", "voice": "lluc", "text": "Els feia cada vegada que jo pujava. I jo pensava que era casualitat."}, {"speaker": "Neus", "voice": "gina", "text": "Casualitat, diu. Si es passava la setmana preguntant-me si vindries."}, {"speaker": "Andreu", "voice": "lluc", "text": "Saps què? Li diré a l'agència que necessitem més temps. No dic que no la venguem, eh. Però no la setmana que ve."}, {"speaker": "Neus", "voice": "gina", "text": "Gràcies. I el quadern me'l quede jo, que tu no saps ni bullir aigua."}, {"speaker": "Andreu", "voice": "lluc", "text": "D'acord, però els flaons me'ls faràs tu. Pel que diu ací, són meus."}]}, "exercises": [{"q": "Què insinua Neus amb «des de Barcelona es veu molt malament»?", "o": ["Retrau a Andreu que visitava poc el pare", "Es queixa que des de Barcelona no hi ha cobertura", "Diu que Andreu no s'adona de res per cansament"], "e": "És un retret indirecte: Andreu no veia com estava el pare perquè no hi anava."}, {"q": "Com és la relació entre els germans al principi de l'escena?", "o": ["Tensa: Neus guarda ressentiment cap a Andreu", "Cordial: col·laboren sense cap retret", "Distant: gairebé no es parlen"], "e": "Els retrets («com els turistes») i el «no comencem» d'Andreu mostren un conflicte antic."}, {"q": "Com és el registre del missatge que llig Andreu?", "o": ["Formal i administratiu, molt diferent de la conversa", "Col·loquial i pròxim, com el dels germans", "Humorístic, amb jocs de paraules"], "e": "«Benvolgut senyor, li comunique... del mes en curs»: fórmules pròpies d'un escrit formal."}, {"q": "Què tem Neus si venen la casa?", "o": ["Que el carrer es quede sense veïns a l'hivern", "Que l'agència no els pague el preu acordat", "Que Andreu se'n quede tots els diners"], "e": "«No hi haurà ni una finestra amb llum a l'hivern»: tot seran apartaments turístics."}, {"q": "Quin argument dona Andreu a favor de vendre?", "o": ["Cap dels dos pot cuidar la casa perquè viuen lluny", "La casa té problemes greus d'estructura", "Necessita els diners per a comprar un pis"], "e": "«Tu vius a Castelló, jo a Barcelona. Ningú no pujarà a Morella cada cap de setmana.»"}, {"q": "Què descobrix Andreu gràcies al quadern?", "o": ["Que el pare feia els flaons expressament per a ell", "Que el pare volia vendre la casa", "Que la recepta de la coca era de sa mare"], "e": "«Els feia cada vegada que jo pujava. I jo pensava que era casualitat.»"}, {"q": "Què decidix Andreu al final?", "o": ["Demanar més temps, sense descartar la venda", "Rebutjar l'oferta i quedar-se la casa", "Signar la venda la setmana que ve"], "e": "«No dic que no la venguem, eh. Però no la setmana que ve.»"}, {"q": "Quin to té l'última part de la conversa?", "o": ["Afectuós i burleta: la tensió s'ha relaxat", "Fred i distant: continuen enfadats", "Trist i desesperat: no troben cap eixida"], "e": "Neus fa broma («no saps ni bullir aigua») i Andreu li segueix el joc amb els flaons."}]}]},
  {"id": "39c8223e-30a7-5f06-b134-cf343087d42a", "category": "comprensio_oral", "type": "b2_co_debat", "sort_order": 5, "title": "Debats i tertúlies", "name": "Intel·ligència artificial a les aules", "content": "Seguix una tertúlia amb arguments complexos, distingix els punts de vista i la intenció de cada participant i reconeix trets d'una varietat geogràfica.", "icon": "💬", "color": "#C8E6C9", "blocks": [{"passage": {"media": "audio", "title": "Tertúlia: intel·ligència artificial a les aules", "lines": [{"speaker": "Ramon", "voice": "lluc", "text": "Bon dia. Hui, en la nostra tertúlia, ens preguntem si la intel·ligència artificial ha de tindre lloc a les aules o si cal prohibir-la, com ja han fet alguns centres. Tenim amb nosaltres Vicenta Sorlí, professora de filosofia en un institut de Vinaròs, i Sergi Albert, investigador en tecnologia educativa a la Universitat d'Alacant. Vicenta, comencem per vosté."}, {"speaker": "Vicenta", "voice": "gina", "text": "Gràcies, Ramon. Mire, jo no soc tecnòfoba, però lo que veig cada dia a classe em preocupa. Los alumnes m'entreguen treballs impecables, sense cap falta, i quan els pregunte què volen dir amb una frase, no ho saben. El problema no és que facen trampa; és que estan perdent l'hàbit d'equivocar-se, i sense equivocar-se no s'aprén a pensar."}, {"speaker": "Sergi", "voice": "lluc", "text": "Entenc la preocupació, però crec que confonem la ferramenta amb l'ús que en fem. Quan van aparéixer les calculadores, també es va dir que els xiquets no sabrien sumar. El que va canviar, en realitat, va ser el tipus d'exercicis. Si demanem treballs que una màquina pot fer en deu segons, potser el problema és l'exercici, no la màquina."}, {"speaker": "Vicenta", "voice": "gina", "text": "Això sona molt bé en un congrés, però a la pràctica jo tinc trenta alumnes per classe i quatre hores setmanals. No puc fer exàmens orals individuals a tothom cada trimestre."}, {"speaker": "Sergi", "voice": "lluc", "text": "No dic que siga fàcil, i reconec que sense més recursos és impossible. Però prohibir-la té un efecte pervers: els alumnes amb més mitjans a casa la continuaran usant, i bé, i els altres no aprendran a fer-ho. La prohibició, paradoxalment, augmentaria la desigualtat."}, {"speaker": "Ramon", "voice": "lluc", "text": "Una dada, abans de continuar: segons una enquesta recent entre famílies valencianes, sis de cada deu estan a favor de limitar-ne l'ús, però només dos de cada deu volen una prohibició total."}, {"speaker": "Vicenta", "voice": "gina", "text": "És que jo tampoc no demane prohibir-la del tot. Demane que primer aprenguen a escriure i a raonar sense ajuda, i després, quan ja tinguen criteri, que la usen. Lo mateix que fem amb lo cotxe: primer l'autoescola, després la carretera."}, {"speaker": "Sergi", "voice": "lluc", "text": "Doncs mira, en això coincidim més del que semblava. La qüestió és decidir en quin moment comença eixa carretera. I jo sospite que, si esperem al batxillerat, arribarem tard."}, {"speaker": "Ramon", "voice": "lluc", "text": "Ho deixem ací, amb la pregunta oberta. Gràcies a tots dos."}]}, "exercises": [{"q": "Quina és la qüestió central de la tertúlia?", "o": ["Si la intel·ligència artificial ha de tindre lloc a les aules", "Si cal reduir les hores de filosofia a l'institut", "Com s'han d'organitzar els exàmens orals"], "e": "«Ens preguntem si la intel·ligència artificial ha de tindre lloc a les aules o si cal prohibir-la.»"}, {"q": "Segons Vicenta, quin és el problema de fons?", "o": ["Els alumnes perden l'hàbit d'equivocar-se i de pensar", "Els alumnes fan trampa constantment als exàmens", "Els treballs dels alumnes tenen massa faltes"], "e": "«El problema no és que facen trampa; és que estan perdent l'hàbit d'equivocar-se.»"}, {"q": "Per què Sergi parla de les calculadores?", "o": ["Per a mostrar que les noves eines obliguen a canviar els exercicis", "Per a demostrar que els xiquets ja no saben sumar", "Per a proposar que es prohibisquen a primària"], "e": "«El que va canviar, en realitat, va ser el tipus d'exercicis.»"}, {"q": "Amb quina intenció diu Vicenta «Això sona molt bé en un congrés»?", "o": ["Critica que la proposta de Sergi és teòrica i poc realista", "Elogia sincerament la proposta de Sergi", "Proposa organitzar un congrés sobre el tema"], "e": "Contraposa el congrés a «la pràctica»: trenta alumnes i quatre hores setmanals."}, {"q": "Quin efecte negatiu de la prohibició assenyala Sergi?", "o": ["Augmentaria la desigualtat entre els alumnes", "Faria que els docents treballaren més hores", "Reduiria les notes de tots els alumnes"], "e": "Els alumnes amb més mitjans la continuarien usant: «la prohibició augmentaria la desigualtat»."}, {"q": "Què mostra la dada de l'enquesta que aporta Ramon?", "o": ["La majoria vol limitar-ne l'ús, però pocs volen prohibir-la", "La majoria de famílies vol una prohibició total", "Les famílies no tenen cap opinió sobre el tema"], "e": "Sis de cada deu volen limitar-la; només dos de cada deu, prohibir-la del tot."}, {"q": "Com evolucionen les posicions al final del debat?", "o": ["S'acosten: discrepen sobretot en el moment d'introduir-la", "S'allunyen: cadascú defén una postura extrema", "No canvien: Vicenta continua volent prohibir-la"], "e": "«En això coincidim més del que semblava. La qüestió és decidir en quin moment comença eixa carretera.»"}, {"q": "Quin tret de la parla de Vicenta indica que és del nord del territori?", "o": ["Usa l'article «lo» i «los» en compte de «el» i «els»", "Usa el verb «vore» en compte de «veure»", "Usa el pronom «mos» en compte de «ens»"], "e": "«Lo que veig», «los alumnes», «lo cotxe»: l'article lo és propi de les comarques septentrionals."}]}]},
  {"id": "6a6068f7-d8a0-539a-894e-0d539626f038", "category": "comprensio_oral", "type": "b2_co_conferencia", "sort_order": 6, "title": "Conferències i presentacions", "name": "L'aigua com a bé comú", "content": "Seguix una conferència acadèmica amb conceptes complexos i n'identifica la tesi, els arguments, els matisos i l'estructura.", "icon": "🎓", "color": "#FFF9C4", "blocks": [{"passage": {"media": "audio", "title": "Conferència: l'aigua com a bé comú", "lines": [{"speaker": "Ponent", "voice": "gina", "text": "Bon dia a tots i gràcies a l'organització per convidar-me. Comence amb una paradoxa. Durant segles, les comunitats de regants de l'horta han repartit un recurs escàs, l'aigua, entre milers d'usuaris, sense que s'esgotara i sense que ningú en traguera un benefici desproporcionat. Segons la teoria econòmica clàssica, això no hauria de passar. Quan un recurs és de tots, diu la teoria, cadascú intenta traure'n el màxim abans que se l'enduguen els altres, i el resultat final és la destrucció del recurs. És el que es coneix com la tragèdia dels béns comuns."}, {"speaker": "Ponent", "voice": "gina", "text": "Com s'explica, doncs, que l'horta haja sobreviscut? La meua hipòtesi, i la del nostre grup de recerca, és que la clau no està en la tecnologia, sinó en la governança. Les comunitats de regants combinen tres elements. En primer lloc, regles adaptades al territori: no es repartix igual en un any de sequera que en un any plujós. En segon lloc, vigilància mútua: els mateixos regants controlen que ningú no obriga la comporta fora del seu torn. I, en tercer lloc, mecanismes ràpids i barats per a resoldre conflictes, amb jutges que són els mateixos llauradors."}, {"speaker": "Ponent", "voice": "gina", "text": "Ara bé, no vull idealitzar el passat. Estes institucions també han sigut tancades, poc obertes a les dones i, de vegades, molt jeràrquiques. El que defenc no és que hàgem de copiar-les, sinó que en podem extraure principis útils davant del canvi climàtic, quan haurem de gestionar sequeres més llargues i pluges més intenses. Les solucions purament tecnològiques, com les grans dessaladores, són necessàries, però si no van acompanyades de regles que la comunitat considere justes, generen conflictes i, a la llarga, fracassen."}, {"speaker": "Assistent", "voice": "lluc", "text": "Gràcies per l'exposició. Una pregunta: vosté creu que este model és aplicable en ciutats grans, on els usuaris no es coneixen entre ells?"}, {"speaker": "Ponent", "voice": "gina", "text": "És una pregunta molt pertinent, i la resposta honesta és que no ho sabem del tot. La vigilància mútua funciona quan hi ha confiança i relacions directes, i això en una gran ciutat és difícil. Però hi ha experiències interessants de gestió de barri, amb consells d'usuaris que decidixen sobre l'aigua dels parcs, per exemple. Potser l'escala adequada no és la ciutat sencera, sinó el barri."}]}, "exercises": [{"q": "Quina paradoxa planteja la ponent al principi?", "o": ["L'horta ha compartit l'aigua durant segles sense esgotar-la", "L'horta té molta aigua però els llauradors no la volen", "La tecnologia moderna ha empitjorat el reg de l'horta"], "e": "Segons la teoria clàssica, un recurs comú s'hauria d'haver destruït, però a l'horta no ha passat."}, {"q": "Què és la «tragèdia dels béns comuns»?", "o": ["La destrucció d'un recurs compartit perquè cadascú en trau el màxim", "La pèrdua de terres de cultiu a causa de les sequeres", "El conflicte entre llauradors pels torns de reg"], "e": "«Cadascú intenta traure'n el màxim [...] i el resultat final és la destrucció del recurs.»"}, {"q": "On situa la ponent la clau de la supervivència de l'horta?", "o": ["En la governança, no en la tecnologia", "En la tecnologia de les séquies antigues", "En l'abundància d'aigua del territori"], "e": "«La clau no està en la tecnologia, sinó en la governança.»"}, {"q": "Quin d'estos elements NO forma part dels tres que descriu?", "o": ["Les subvencions públiques per a modernitzar els canals", "Les regles adaptades a cada any i al territori", "La vigilància mútua entre els mateixos regants"], "e": "Els tres elements són regles adaptades, vigilància mútua i resolució ràpida de conflictes."}, {"q": "Per què diu la ponent «no vull idealitzar el passat»?", "o": ["Per a reconéixer els defectes d'estes institucions i matisar la tesi", "Per a defendre que cal copiar-les tal com eren", "Per a demostrar que no funcionaven gens bé"], "e": "Admet que eren tancades, poc obertes a les dones i jeràrquiques, però en salva els principis."}, {"q": "Quina postura té sobre les grans dessaladores?", "o": ["Són necessàries, però fracassen sense regles justes", "Són inútils i caldria eliminar-les totes", "Són la solució definitiva al canvi climàtic"], "e": "«Són necessàries, però si no van acompanyades de regles que la comunitat considere justes [...] fracassen.»"}, {"q": "Com respon la ponent a la pregunta de l'assistent?", "o": ["Admet que no ho sap del tot i proposa el barri com a escala", "Assegura que el model funciona igual en qualsevol ciutat", "Rebutja la pregunta perquè no té relació amb el tema"], "e": "«La resposta honesta és que no ho sabem del tot. [...] Potser l'escala adequada [...] és el barri.»"}, {"q": "Com està estructurada la conferència?", "o": ["Paradoxa, hipòtesi amb tres elements, límits i aplicació al present", "Història de l'horta, dades de producció i conclusió", "Problema, causes i tres consells per a la vida diària"], "e": "Comença amb una paradoxa, explica la hipòtesi, matisa els límits i l'aplica al canvi climàtic."}]}]},
  {"id": "dab6f0fe-d5f4-5746-adf5-0cd1b1f0670e", "category": "comprensio_escrita", "type": "b2_ce_premsa", "sort_order": 1, "title": "Premsa", "name": "Reportatges i cròniques", "content": "Capta les idees principals i secundàries, els detalls i els matisos de reportatges i cròniques de premsa complexos.", "icon": "📰", "color": "#B3E5FC", "blocks": [{"passage": {"media": "text", "title": "Sal en els arrossars: l'Albufera es defén de la mar", "lines": [{"text": "A les set del matí, quan la boira encara s'arrapa als camps del Palmar, Vicent Ferrandis ja ha clavat la vara de mesurar en l'aigua de la seua parcel·la. No busca la profunditat, sinó un número que fa tres estius que li furta la son: la conductivitat, és a dir, la quantitat de sal dissolta. «Si passa de quatre, l'arròs pateix; si passa de sis, ja pots acomiadar-te de la collita», explica mentre mostra la pantalla del mesurador portàtil. Hui marca 5,2."}, {"text": "El fenomen té un nom tècnic, intrusió salina, i una explicació que els científics repetixen amb paciència. Quan els rius i les séquies porten poca aigua dolça, la pressió que exercix sobre el subsòl disminuïx i l'aigua de la mar, més densa, avança terra endins per davall de la superfície, com una falca invisible. La pujada del nivell de la mar i els temporals cada vegada més freqüents agreugen un procés que, fins fa unes dècades, només es detectava en les parcel·les més pròximes a la costa."}, {"text": "Segons les dades que un equip universitari ha recopilat durant cinc anys, la superfície afectada per nivells de sal preocupants s'ha duplicat des de 2019 i ja s'acosta a una cinquena part dels arrossars del parc natural. La investigadora que coordina l'estudi, Amparo Soler, evita, tanmateix, el to apocalíptic: «No és una sentència, és un avís. L'Albufera ha sobreviscut a canvis molt grans perquè sempre ha tingut qui la gestionara. La pregunta és si sabrem adaptar eixa gestió a un clima diferent.»"}, {"text": "Les solucions que es plantegen no satisfan tothom. Una part dels llauradors reclama que es garantisca un cabal mínim d'aigua dolça durant tot l'any, encara que això supose retallar dotacions a altres usos. Uns altres, sobretot els més jóvens, han començat a experimentar amb varietats més tolerants a la sal, tot i que reconeixen que el rendiment és menor i que el mercat, de moment, paga millor l'arròs de sempre. I no falta qui proposa deixar inundades de manera permanent algunes parcel·les marginals per a convertir-les en zones humides naturals, una idea que els ecologistes aplaudixen i que molts agricultors consideren una rendició."}, {"text": "Ferrandis escolta totes les propostes amb una paciència que sembla heretada. El seu besavi ja cultivava estos mateixos camps, i ell no té pressa per a donar-se per vençut. «Ací sempre hem viscut negociant amb l'aigua», diu mentre recull la vara. «Abans discutíem amb els veïns de la séquia; ara ens toca discutir amb la mar, que no entén de torns.» Somriu, però no fa broma."}]}, "exercises": [{"q": "Quin és el tema central del reportatge?", "o": ["L'avanç de la sal en els arrossars i les possibles respostes", "La pèrdua de les tradicions agrícoles entre els jóvens", "La contaminació de l'Albufera per les aigües industrials"], "e": "El text explica la intrusió salina, en dona dades i recull les solucions que es debaten."}, {"q": "Què mesura Vicent Ferrandis cada matí?", "o": ["La quantitat de sal dissolta en l'aigua", "La profunditat de l'aigua de la parcel·la", "La temperatura de l'aigua a primera hora"], "e": "«No busca la profunditat, sinó [...] la conductivitat, és a dir, la quantitat de sal dissolta.»"}, {"q": "Segons el text, per què avança l'aigua de la mar?", "o": ["Perquè arriba menys aigua dolça i baixa la pressió sobre el subsòl", "Perquè els temporals trenquen les motes que protegixen els camps", "Perquè els llauradors bomben aigua de la mar per a regar"], "e": "Quan arriba poca aigua dolça, la pressió disminuïx i la mar avança per davall de la superfície."}, {"q": "En el text, l'aigua salada avança «com una falca invisible». Què és ací una falca?", "o": ["Una peça en forma de tascó que penetra i s'obri pas", "Una barrera que frena el pas de l'aigua salada", "Un corrent superficial d'aigua dolça i freda"], "e": "La sal entra per davall, com un tascó que s'introduïx entre la terra i l'aigua dolça."}, {"q": "Quina actitud mostra la investigadora Amparo Soler?", "o": ["Prudent: reconeix el problema però hi veu marge per a actuar", "Alarmista: considera que l'Albufera ja està condemnada", "Escèptica: dubta que les dades de l'estudi siguen fiables"], "e": "«No és una sentència, és un avís.» La clau és adaptar la gestió."}, {"q": "Per què les varietats tolerants a la sal encara no s'han generalitzat?", "o": ["Rendixen menys i el mercat paga millor l'arròs tradicional", "Són més cares de sembrar i necessiten més aigua", "Els ecologistes s'oposen a introduir-les en el parc"], "e": "«El rendiment és menor i [...] el mercat, de moment, paga millor l'arròs de sempre.»"}, {"q": "Quina proposta consideren molts agricultors una rendició?", "o": ["Deixar algunes parcel·les inundades com a zones humides", "Cultivar varietats d'arròs més tolerants a la sal", "Garantir un cabal mínim d'aigua dolça tot l'any"], "e": "La idea d'inundar parcel·les marginals «els ecologistes aplaudixen i [...] molts agricultors consideren una rendició»."}, {"q": "Què suggerix la frase final «Somriu, però no fa broma»?", "o": ["Que darrere del to lleuger hi ha una preocupació seriosa", "Que Ferrandis no entén la gravetat del problema", "Que la conversa amb el periodista l'ha molestat"], "e": "La comparació amb la mar és enginyosa, però expressa una inquietud real."}]}, {"passage": {"media": "text", "title": "Crònica d'una assemblea: el poble que vol fabricar la seua llum", "lines": [{"text": "La sala de la cooperativa de Beniatjar no s'omplia així des de la festa del centenari. Dijous passat, a les huit de la vesprada, més de cent veïns, en un poble que en té poc més de dos-cents, es van asseure en cadires plegables, en bancs de fusta i fins i tot en caixes de taronges per a decidir una qüestió que, sobre el paper, semblava tècnica: si el poble s'havia de convertir en una comunitat energètica local."}, {"text": "La proposta, impulsada per l'Ajuntament i per una associació de veïns jóvens, consistix a cobrir la teulada de la vella cooperativa i la de l'escola amb plaques solars i repartir l'electricitat entre les cases que s'hi adherisquen. Segons l'enginyera que va presentar el projecte, Laia Ortolà, cada família podria estalviar entre un trenta i un quaranta per cent en la factura, i el poble deixaria de dependre completament de les grans companyies. El finançament procediria, en bona part, de fons públics, però cada participant hauria d'aportar una quota inicial de dos-cents euros."}, {"text": "Les primeres intervencions van ser d'entusiasme. Una mestra jubilada va recordar que la cooperativa ja havia sigut, en els anys cinquanta, un exemple del que el poble podia fer quan s'unia; un jove que havia tornat de Barcelona per a teletreballar va dir que era «la primera vegada que veia el futur passar per ací en compte de passar de llarg»."}, {"text": "Però l'ambient es va enterbolir quan va demanar la paraula Remigi Climent, un llaurador de setanta-huit anys conegut per no mossegar-se la llengua. No va qüestionar les plaques, sinó la lletra menuda: qui s'encarregaria del manteniment?, què passaria si d'ací a deu anys ningú no volia fer-se'n càrrec?, i, sobretot, per què havien de pagar el mateix els que viuen tot l'any al poble i els que només hi pugen a l'agost? La sala, que fins aleshores aplaudia cada intervenció, es va quedar en silenci. Algú, des del fons, va murmurar que el Remigi sempre hi trobava objeccions; uns altres, però, assentien amb el cap."}, {"text": "L'enginyera va admetre que algunes preguntes encara no tenien resposta i es va comprometre a portar, abans de la votació definitiva, un model de gestió i una proposta de quotes diferenciades. L'alcaldessa, conscient que un projecte comunitari sense consens naixeria coix, va ajornar la decisió fins al mes que ve. A l'eixida, mentre els veïns plegaven les cadires, el mateix Remigi resumia la nit amb una ironia que va fer riure fins i tot els més entusiastes: «Jo no tinc res contra el sol; el que vull saber és qui pujarà a la teulada quan jo ja no puga.»"}]}, "exercises": [{"q": "Per què el cronista compara l'assistència amb la de la festa del centenari?", "o": ["Per a subratllar l'expectació excepcional que havia despertat la reunió", "Per a indicar que la reunió es va fer el mateix dia de la festa", "Per a criticar que la sala era massa xicoteta per a l'acte"], "e": "La sala «no s'omplia així» des d'aquella festa: hi havia la meitat del poble."}, {"q": "En què consistix el projecte presentat?", "o": ["Posar plaques en dos edificis públics i repartir l'energia entre els adherits", "Vendre l'electricitat del poble a una gran companyia elèctrica", "Obligar totes les cases del poble a instal·lar plaques a la teulada"], "e": "Plaques a la cooperativa i a l'escola, i electricitat repartida «entre les cases que s'hi adherisquen»."}, {"q": "Què vol dir el jove quan parla del futur que sol «passar de llarg»?", "o": ["Que el progrés sol ignorar els pobles xicotets", "Que ell pensa tornar prompte a viure a Barcelona", "Que als veïns no els interessa el futur del poble"], "e": "Celebra que, per una vegada, una innovació arribe al poble en compte d'oblidar-lo."}, {"q": "Quines objeccions planteja Remigi Climent?", "o": ["La gestió a llarg termini i un repartiment just de les quotes", "L'eficiència real de les plaques solars en un poble d'interior", "La possibilitat que l'Ajuntament es quedara els diners"], "e": "Pregunta pel manteniment, pel futur del projecte i per la quota igual per a residents i estiuejants."}, {"q": "Com reacciona la sala a la intervenció de Remigi?", "o": ["Es dividix entre qui el critica i qui li dona la raó", "L'aplaudix de manera unànime i entusiasta", "Exigix que es vote immediatament el projecte"], "e": "Algú murmura que sempre hi troba objeccions; «uns altres, però, assentien amb el cap»."}, {"q": "Què vol dir que un projecte sense consens «naixeria coix»?", "o": ["Que tindria un defecte d'origen que en dificultaria el funcionament", "Que tardaria molt de temps a posar-se en marxa", "Que acabaria costant més diners dels previstos"], "e": "Sentit figurat: començaria amb una debilitat que el llastraria."}, {"q": "Què revela la frase final de Remigi?", "o": ["Que no s'oposa a l'energia solar, sinó que el preocupa la continuïtat", "Que rebutja de manera radical la comunitat energètica", "Que vol encarregar-se ell mateix del manteniment de les plaques"], "e": "«No tinc res contra el sol; el que vull saber és qui pujarà a la teulada.»"}, {"q": "Quin tipus de text és i com s'organitza?", "o": ["Una crònica que narra la reunió en ordre cronològic", "Un article d'opinió que defén la comunitat energètica", "Una entrevista a l'enginyera que presenta el projecte"], "e": "Relata l'assemblea des de l'inici fins a l'eixida, amb les intervencions per ordre."}]}]},
  {"id": "38ea53a9-1b96-5f63-bf9c-6e0833f31e67", "category": "comprensio_escrita", "type": "b2_ce_argumentatius", "sort_order": 2, "title": "Textos argumentatius", "name": "Articles d'opinió i assajos", "content": "Identifica la tesi, els arguments, els contraarguments i el to, també irònic, d'articles d'opinió i assajos breus.", "icon": "⚖️", "color": "#FFCCBC", "blocks": [{"passage": {"media": "text", "title": "Opinió: «El grup de famílies no dorm mai»", "lines": [{"text": "Confesse que vaig entrar en el grup de missatgeria de les famílies de 3r B amb la il·lusió d'un alumne el primer dia de curs. Pensava que serviria per a saber quan era l'excursió o si calia portar un tros de cartolina. Tres anys i catorze mil missatges després, puc afirmar amb coneixement de causa que el grup ha esdevingut moltes coses (tribunal, mercat de segona mà, consultori mèdic, oficina d'objectes perduts), però rarament allò per a què va nàixer."}, {"text": "No m'entenguen malament: no soc un nostàlgic de la circular en paper que arribava arrugada al fons de la motxilla. La comunicació immediata entre famílies té avantatges evidents, i qualsevol que haja buscat a les deu de la nit qui s'ha emportat per error la jaqueta del seu fill ho sap. El problema no és l'eina, sinó l'ús que en fem o, més ben dit, l'absència de qualsevol norma sobre com usar-la."}, {"text": "Perquè el grup no té horari. Un dissabte a les set del matí algú pregunta pels deures de matemàtiques; a mitjanit, una altra persona ens recorda que demà és el dia de la fruita. Cada missatge, per trivial que siga, genera una cascada de respostes («gràcies!», «a mi també m'havia passat», un polze amunt) que convertix una informació de deu segons en mitja hora de notificacions. Hi ha estudis que alerten que esta connexió permanent augmenta l'ansietat dels pares; jo no necessite cap estudi: n'hi ha prou de mirar la cara de qualsevol mare quan el mòbil vibra per enèsima vegada en un sopar."}, {"text": "Hi haurà qui diga que la solució és senzilla: qui no vulga llegir, que silencie el grup. És un argument raonable, però ingenu. Silenciar el grup és arriscar-se a no saber que l'excursió s'ha avançat un dia o que la tutora està de baixa, perquè, en la pràctica, el grup ha acabat substituint els canals oficials del centre. Qui se'n desconnecta no guanya tranquil·litat: perd informació."}, {"text": "Per això propose una cosa tan poc revolucionària com un reglament. Un horari raonable, posem per cas de huit del matí a nou de la nit; la prohibició expressa de convertir el grup en un fòrum de queixes contra el professorat, que per a això hi ha les tutories; i, sobretot, el compromís del centre de no delegar en un xat informal la informació que té l'obligació de comunicar per les vies oficials. Res d'açò requerix grans inversions, només una mica de sentit comú compartit."}, {"text": "Mentre escric estes línies, el mòbil m'avisa de vint-i-tres missatges nous. Els he mirat: algú ha trobat una carmanyola blava. Ningú no sap de qui és, però tots li hem donat les gràcies."}]}, "exercises": [{"q": "Quina és la tesi de l'autor?", "o": ["Els grups de famílies són útils, però necessiten unes normes d'ús", "Els grups de famílies s'haurien de prohibir en tots els centres", "La comunicació en paper era més eficaç que la digital"], "e": "«El problema no és l'eina, sinó l'ús que en fem», i acaba proposant un reglament."}, {"q": "Quina funció té l'enumeració «tribunal, mercat de segona mà, consultori mèdic...»?", "o": ["Mostrar amb humor com el grup s'ha desviat de la seua finalitat", "Descriure els serveis oficials que oferix el centre escolar", "Demostrar que el grup és molt més útil del que sembla"], "e": "L'autor diu que el grup és tot això «però rarament allò per a què va nàixer»."}, {"q": "Quina funció té l'expressió «més ben dit» en el segon paràgraf?", "o": ["Introduïx una reformulació que precisa la idea anterior", "Introduïx la conclusió final de l'article", "Introduïx un exemple concret de mal ús"], "e": "Passa de «l'ús que en fem» a una idea més precisa: la falta de normes."}, {"q": "Per què diu l'autor que no necessita «cap estudi»?", "o": ["Contraposa l'experiència quotidiana a les dades per a reforçar l'argument", "Considera que els estudis sobre l'ansietat són falsos", "Admet que no té cap prova del que defén en l'article"], "e": "No nega els estudis: diu que la realitat diària ja confirma el que afirmen."}, {"q": "Com rebat l'autor la idea de silenciar el grup?", "o": ["Com que el grup ha substituït els canals oficials, silenciar-lo fa perdre informació", "Silenciar el grup és tècnicament impossible en la majoria de mòbils", "Silenciar el grup seria una falta de respecte cap a les altres famílies"], "e": "«Qui se'n desconnecta no guanya tranquil·litat: perd informació.»"}, {"q": "Quina de les propostes afecta directament el centre educatiu?", "o": ["Que no delegue en el xat la informació que ha de comunicar oficialment", "Que cree un grup oficial gestionat per la direcció del centre", "Que prohibisca a les famílies l'ús del mòbil a l'escola"], "e": "Demana «el compromís del centre de no delegar en un xat informal» la informació oficial."}, {"q": "Quin to té el paràgraf final?", "o": ["Irònic: l'anècdota confirma la trivialitat que l'autor critica", "Nostàlgic: l'autor enyora els primers dies del grup", "Indignat: l'autor anuncia que abandonarà el grup"], "e": "Vint-i-tres missatges per una carmanyola de ningú: exemple humorístic del problema."}]}, {"passage": {"media": "text", "title": "Assaig: «Elogi de l'avorriment»", "lines": [{"text": "Hi ha experiències que hem desterrat de la vida quotidiana sense adonar-nos-en. L'avorriment n'és una. Fa només unes dècades, esperar l'autobús, fer cua a la consulta del metge o passar una vesprada d'agost a casa dels avis eren ocasions inevitables de no fer res. Hui, qualsevol buit, per breu que siga, s'ompli automàticament amb una pantalla. Sostinc que esta victòria aparent sobre l'avorriment és, en realitat, una pèrdua, i que val la pena recuperar-lo, almenys en dosis moderades."}, {"text": "El primer argument és de caràcter creatiu. Quan la ment no rep estímuls externs, no s'atura: divaga, associa records, imagina situacions. Diversos experiments de psicologia han mostrat que, després d'una tasca monòtona, les persones tendixen a proposar solucions més originals a problemes oberts. L'avorriment, doncs, no seria un estat buit, sinó una mena de guaret: la terra que sembla improductiva està, de fet, recuperant els nutrients per a la collita següent."}, {"text": "El segon argument té relació amb l'autonomia. Qui no ha aprés a estar a soles amb els seus pensaments depén constantment dels altres, o de les màquines, per a sentir-se bé. Els xiquets que s'avorrixen de tant en tant aprenen a inventar jocs, a observar el que els envolta, a suportar l'espera. Privar-los sistemàticament d'eixa experiència, amb la bona intenció d'entretindre'ls, pot fer-los més fràgils davant de la frustració."}, {"text": "Cal reconéixer, tanmateix, que l'avorriment no té mala fama sense motiu. Hi ha un avorriment que no és fecund, sinó corrosiu: el de qui passa hores en una faena sense sentit o el de qui viu aïllat contra la seua voluntat. Idealitzar eixe malestar seria una frivolitat, i fins i tot una crueltat. A més, hi ha qui argumenta, amb raó, que les pantalles també poden ser una font de coneixement i que no tot entreteniment és evasió."}, {"text": "Accepte les dues objeccions, però no invaliden la tesi: la matisen. No defenc l'avorriment imposat ni crònic, sinó el dret a l'interval, eixos minuts sense programar en què la ment pot respirar. I no propose renunciar a la tecnologia, sinó deixar d'usar-la com un analgèsic que s'aplica abans que aparega el dolor."}, {"text": "Potser l'exercici més revolucionari que podem fer hui és tan senzill com deixar el mòbil a la butxaca la pròxima vegada que esperem l'autobús. No hi guanyarem res de mesurable. O potser sí: uns minuts de temps veritablement nostre."}]}, "exercises": [{"q": "Quina és la tesi de l'assaig?", "o": ["Convé recuperar moments d'avorriment en dosis moderades", "Cal eliminar les pantalles de la vida quotidiana", "L'avorriment és una experiència que cal evitar als xiquets"], "e": "«Sostinc que esta victòria aparent sobre l'avorriment és [...] una pèrdua, i que val la pena recuperar-lo.»"}, {"q": "Què significa «guaret» en el segon paràgraf?", "o": ["Terra que es deixa sense sembrar perquè es regenere", "Terra que es cultiva diverses vegades a l'any", "Terra abandonada per sempre perquè és estèril"], "e": "El mateix text ho aclarix: sembla improductiva però recupera nutrients."}, {"q": "Què vol mostrar l'autor amb la comparació del guaret?", "o": ["Que l'avorriment, aparentment improductiu, prepara la ment per a crear", "Que l'avorriment és més habitual en la vida al camp", "Que per a ser creatiu cal treballar sense descans"], "e": "L'avorriment «no seria un estat buit», sinó un temps de preparació."}, {"q": "Quin és el segon argument de l'autor?", "o": ["Saber estar sense estímuls fa les persones més autònomes", "Els xiquets que s'avorrixen obtenen millors notes", "Els pares no haurien d'entretindre mai els seus fills"], "e": "Qui no sap estar a soles «depén constantment dels altres»; l'avorriment ensenya a suportar l'espera."}, {"q": "Quin tipus d'avorriment no defén l'autor?", "o": ["L'imposat o crònic, com el d'una faena sense sentit", "El d'esperar l'autobús o fer una cua", "El dels xiquets les vesprades d'estiu"], "e": "Parla d'un avorriment «corrosiu» que seria cruel idealitzar."}, {"q": "Com respon l'autor a les objeccions?", "o": ["Les accepta, però diu que matisen la tesi, no l'anul·len", "Les rebutja perquè no es basen en cap estudi", "Hi dona la raó i abandona la seua postura inicial"], "e": "«Accepte les dues objeccions, però no invaliden la tesi: la matisen.»"}, {"q": "Què vol dir usar la tecnologia «com un analgèsic que s'aplica abans que aparega el dolor»?", "o": ["Omplir qualsevol buit amb una pantalla abans de sentir-lo", "Fer servir la tecnologia per a curar problemes de salut", "Usar el mòbil només quan estem malalts o cansats"], "e": "Critica que evitem l'avorriment de manera preventiva i automàtica."}, {"q": "Com s'estructura el text?", "o": ["Tesi, dos arguments, objeccions, resposta i conclusió", "Pregunta inicial, entrevista i resum de les respostes", "Anècdota personal, dades estadístiques i proposta de llei"], "e": "Estructura clàssica de l'assaig argumentatiu, amb contraarguments."}]}]},
  {"id": "3d4e97d8-0c02-5b76-92ab-701ee48c4ffe", "category": "comprensio_escrita", "type": "b2_ce_literaris", "sort_order": 3, "title": "Textos literaris", "name": "Narrativa i prosa poètica", "content": "Interpreta el sentit figurat, el punt de vista i el to de textos literaris contemporanis.", "icon": "📖", "color": "#D1C4E9", "blocks": [{"passage": {"media": "text", "title": "La casa del carrer de la Font", "lines": [{"text": "La clau encara pesava el mateix. Això va ser el primer que vaig pensar quan la vaig traure de la bossa, davant de la porta verda que algú, segurament el meu oncle, havia repintat sense gaire traça. Feia dotze anys que no tornava a Vilafranca, i m'havia preparat per a trobar-ho tot més xicotet, com diuen que passa amb els llocs de la infància. No va ser així. El carrer era igual d'estret, la costera igual de pronunciada, i jo, als quaranta-tres anys, em vaig tornar a sentir com una xiqueta que arriba tard a sopar."}, {"text": "Dins, la casa feia olor de tancat i de llenya vella. L'agent immobiliari m'esperava a les onze, i jo havia vingut a les nou amb la intenció de fer una última volta, ràpida i eficaç, com qui revisa una maleta abans d'eixir de l'hotel. Però la casa tenia altres plans. A la cuina, la taula de marbre conservava encara la taca circular que deixava la cassola de l'àvia; al rebedor, el penjador sostenia un abric que ningú no s'havia atrevit a donar. Cada objecte era una porta, i jo no tenia temps d'obrir-les totes."}, {"text": "Vaig pujar a la cambra de dalt, on dormíem els cosins a l'estiu. Allí, en un calaix de la calaixera, vaig trobar una llibreta de tapes de cartó amb la lletra menuda i inclinada de l'àvia Pilar. No eren receptes, com vaig suposar al principi, sinó comptes: quilos de creïlles, jornals, deutes pagats i deutes perdonats. Entre dues pàgines, plegat en quatre, hi havia un paper amb el meu nom escrit amb llapis: «Per a l'Elena, quan torne». Em vaig asseure al llit, que va gemegar com sempre, i el vaig obrir amb unes mans que no semblaven les meues."}, {"text": "Només hi havia tres línies: «Les cases no es venen, filla. Es deixen anar, com els fills. Però abans, obri totes les finestres.» No vaig plorar; no en aquell moment. Vaig obrir les finestres, una per una, i la llum de març va entrar a la casa amb la desimboltura de qui torna al seu lloc."}, {"text": "Quan l'agent va tocar el timbre, puntual, jo encara estava asseguda al llit. Vaig baixar, li vaig obrir la porta i li vaig dir que ho sentia, que havia fet el viatge en va. Ell va mirar les finestres obertes, després em va mirar a mi, i no em va preguntar res. Potser ja estava acostumat que les cases canviaren d'opinió."}]}, "exercises": [{"q": "Des de quin punt de vista es narra la història?", "o": ["Una narradora protagonista en primera persona", "Un narrador extern que ho sap tot", "L'àvia, que conta la història des del passat"], "e": "«Vaig pensar», «vaig trobar»: Elena narra el que viu."}, {"q": "Què suggerix la primera frase, «La clau encara pesava el mateix»?", "o": ["Que el vincle emocional amb la casa continua intacte", "Que la clau era massa gran per a la porta", "Que la narradora havia perdut la clau durant anys"], "e": "El pes físic de la clau evoca un pes afectiu que el temps no ha canviat."}, {"q": "Què esperava trobar la narradora en tornar al poble?", "o": ["Que tot li semblaria més xicotet que en el record", "Que la casa estaria en ruïnes i abandonada", "Que el seu oncle l'estaria esperant a la porta"], "e": "«M'havia preparat per a trobar-ho tot més xicotet [...]. No va ser així.»"}, {"q": "Què vol dir que «la casa tenia altres plans»?", "o": ["Que els records li impedixen fer una visita ràpida", "Que la casa estava ocupada per altres persones", "Que la casa necessitava unes obres urgents"], "e": "Personificació: cada objecte la reté i desperta records («Cada objecte era una porta»)."}, {"q": "Què contenia la llibreta de l'àvia?", "o": ["Els comptes domèstics i els deutes de la família", "Les receptes de cuina de tota la vida", "Cartes d'amor de quan era jove"], "e": "«No eren receptes, com vaig suposar al principi, sinó comptes.»"}, {"q": "Quin sentit té el missatge de l'àvia?", "o": ["Que deixar una casa demana un comiat, no només una venda", "Que la néta havia de tornar a viure a Vilafranca per sempre", "Que la casa s'havia de repartir entre tots els cosins"], "e": "«Les cases no es venen [...]. Es deixen anar [...]. Però abans, obri totes les finestres.»"}, {"q": "Què decidix finalment la narradora?", "o": ["No vendre la casa, almenys de moment", "Vendre la casa a l'agent aquell mateix matí", "Ajornar la visita de l'agent fins a l'endemà"], "e": "Li diu a l'agent «que havia fet el viatge en va»."}, {"q": "Quin to té l'última frase?", "o": ["Irònic i tendre: atribuïx a la casa la decisió que ha pres ella", "Amarg: retreu a l'agent la seua indiferència", "Burleta: es riu de la puntualitat de l'agent"], "e": "Personifica la casa per a parlar, amb un somriure, del seu propi canvi."}]}, {"passage": {"media": "text", "title": "La mar de gener (poema en prosa)", "lines": [{"text": "La mar de gener no espera ningú. Ha tornat a ser seua des que l'últim para-sol va plegar les ales a finals de setembre, i ara s'estén davant de Dénia amb l'orgull tranquil dels propietaris que han recuperat la casa després d'uns llogaters sorollosos. No hi ha tovalloles, ni crits, ni gelats que es desfan. Només una platja ampla, despullada, on el vent escriu i esborra la mateixa frase cada matí."}, {"text": "Jo hi vaig a les set, quan la llum encara dubta. Camine per la vora amb les mans a les butxaques i els ulls a terra, perquè l'hivern és l'estació de les troballes humils: un tros de vidre polit per les ones fins a semblar un caramel, una sabatilla de xiquet que ningú no reclamarà, una branca blanquíssima que fa anys era arbre en algun barranc de l'interior. La mar no llança res; retorna. Té una memòria llarga i una paciència de pedra."}, {"text": "A l'agost, la mar és un espectacle; al gener, una conversa. Ens parla a poc a poc, sense pressa per convéncer-nos, i diu coses que l'estiu no deixa sentir: que tot el que fem acaba arribant a alguna vora; que la soledat no és un buit, sinó un espai; que hi ha bellesa en allò que ningú no fotografia. Les gavines, úniques testimonis, fan veure que no escolten."}, {"text": "De vegades em creue amb un home vell que passeja un gos encara més vell. Ens saludem amb el cap, com dos membres d'un club secret que no necessita estatuts. No sé el seu nom, ni ell el meu. No ens fa falta. Compartim una cosa més íntima que el nom: haver triat la mar quan ningú no la vol."}, {"text": "Torne a casa amb les sabates plenes d'arena freda i alguna relíquia menuda a la butxaca. Sé que d'ací a uns mesos la platja tornarà a omplir-se de colors i de soroll, i que la mar, generosa o resignada, deixarà fer. Però jo sabré el que m'ha dit en veu baixa, quan érem pocs. I a l'agost, enmig de la multitud, de tant en tant la miraré com es mira un vell amic en una festa massa plena: amb una complicitat que els altres no entenen."}]}, "exercises": [{"q": "Quina característica defineix este text?", "o": ["És prosa amb un llenguatge figurat i rítmic propi de la poesia", "És un text informatiu sobre les platges de Dénia a l'hivern", "És una narració amb un conflicte i un desenllaç clars"], "e": "Abunden les metàfores, les personificacions i les estructures paral·leles."}, {"q": "Què expressa la comparació amb uns propietaris que recuperen la casa?", "o": ["Que la mar, sense turistes, torna a ser ella mateixa", "Que la mar està enfadada amb els banyistes de l'estiu", "Que l'Ajuntament tanca la platja durant l'hivern"], "e": "Els estiuejants són com «llogaters sorollosos»; ara la mar «ha tornat a ser seua»."}, {"q": "Què vol dir «La mar no llança res; retorna»?", "o": ["Que torna a la costa objectes que li han arribat d'altres llocs", "Que a l'hivern la mar no té onades", "Que la mar es queda tot el que hi cau"], "e": "La branca ve d'un barranc de l'interior: la mar torna allò que ha rebut."}, {"q": "Què oposa el text amb «A l'agost, la mar és un espectacle; al gener, una conversa»?", "o": ["L'exhibició de l'estiu i la relació íntima i pausada de l'hivern", "La mar perillosa de l'hivern i la mar tranquil·la de l'estiu", "La bellesa de l'estiu i la lletjor de la platja a l'hivern"], "e": "A l'hivern la mar parla «a poc a poc» i diu el que l'estiu no deixa sentir."}, {"q": "Què significa que «la soledat no és un buit, sinó un espai»?", "o": ["Que estar a soles pot ser una oportunitat i no una mancança", "Que la platja és massa gran per a una sola persona", "Que la veu poètica no suporta estar a soles"], "e": "La soledat es presenta com un lloc on poden passar coses, no com una absència."}, {"q": "Quina relació té la veu poètica amb l'home del gos?", "o": ["Una complicitat silenciosa basada en una mateixa elecció", "Una amistat antiga que ve de la infància", "Una rivalitat per ocupar la platja de matí"], "e": "«Compartim una cosa més íntima que el nom: haver triat la mar quan ningú no la vol.»"}, {"q": "Quin to predomina en el text?", "o": ["Contemplatiu i íntim", "Indignat i reivindicatiu", "Humorístic i burleta"], "e": "La veu observa, reflexiona i descriu amb calma i afecte."}, {"q": "Què anuncia la imatge final del «vell amic en una festa massa plena»?", "o": ["Que mantindrà a l'estiu el vincle privat creat a l'hivern", "Que evitarà anar a la platja durant l'estiu", "Que pensa organitzar una festa a la platja a l'agost"], "e": "Entre la multitud, la mirarà «amb una complicitat que els altres no entenen»."}]}]},
  {"id": "b59e6ecd-f461-5673-9b6e-e7dbe6859292", "category": "comprensio_escrita", "type": "b2_ce_administracio", "sort_order": 4, "title": "Textos administratius", "name": "Convocatòries, resolucions i recursos", "content": "Comprén textos formals de l'Administració pública: requisits, terminis, criteris de valoració i vies de recurs.", "icon": "⚖️", "color": "#CFD8DC", "blocks": [{"passage": {"media": "text", "title": "Bases de les ajudes per a rehabilitar habitatges del nucli antic", "lines": [{"text": "Ajuntament de Xàtiva. Bases reguladores de les ajudes municipals per a la rehabilitació d'habitatges del nucli històric (exercici 2027)."}, {"text": "Base primera. Objecte. Estes bases tenen per objecte regular la concessió, en règim de concurrència competitiva, d'ajudes econòmiques destinades a la rehabilitació d'habitatges situats dins de l'àmbit del nucli històric delimitat en el Pla especial de protecció. Les ajudes pretenen afavorir la conservació del patrimoni arquitectònic i, alhora, fomentar que els immobles desocupats tornen a ser habitats."}, {"text": "Base segona. Persones beneficiàries. Podran sol·licitar les ajudes les persones físiques propietàries o usufructuàries d'un habitatge ubicat en l'àmbit indicat, sempre que l'immoble tinga una antiguitat superior a cinquanta anys. També hi podran optar les persones llogateres, amb l'autorització expressa i per escrit de la propietat. En cap cas no es podran beneficiar de les ajudes les persones que tinguen deutes pendents amb la Hisenda municipal en la data en què finalitze el termini de presentació de sol·licituds."}, {"text": "Base tercera. Actuacions subvencionables. Seran subvencionables les obres de reforç estructural, la reparació de cobertes i façanes, la millora de l'aïllament tèrmic i la substitució de fusteries exteriors. No ho seran, en canvi, les obres de decoració interior ni l'adquisició de mobles o electrodomèstics. Les actuacions no podran haver-se iniciat abans de la publicació d'esta convocatòria."}, {"text": "Base quarta. Quantia. L'ajuda cobrirà fins al 40 % del pressupost subvencionable, amb un màxim de 12.000 euros per habitatge. Este percentatge s'elevarà fins al 60 % quan l'habitatge, una vegada rehabilitat, es destine a residència habitual de la persona sol·licitant o es llogue durant un mínim de cinc anys a un preu que no supere el de referència fixat per l'Ajuntament. El límit màxim de 12.000 euros s'aplicarà en tots els casos."}, {"text": "Base cinquena. Criteris de valoració. Les sol·licituds es puntuaran d'acord amb els criteris següents: estat de conservació de l'immoble (fins a 40 punts), nivell de renda de la unitat familiar (fins a 30 punts) i compromís de destinar l'habitatge a lloguer assequible (fins a 30 punts). En cas d'empat, tindrà prioritat la sol·licitud registrada abans."}, {"text": "Base sisena. Termini i documentació. Les sol·licituds es presentaran preferentment per la seu electrònica de l'Ajuntament en el termini de quaranta-cinc dies naturals comptadors a partir de l'endemà de la publicació de l'extracte d'esta convocatòria en el Butlletí Oficial de la Província. Caldrà adjuntar-hi la memòria tècnica de les obres, el pressupost detallat i la documentació acreditativa de la titularitat. Si la sol·licitud és incompleta, es requerirà la persona interessada perquè l'esmene en un termini de deu dies hàbils; si no ho fa, es considerarà que hi ha desistit."}, {"text": "Base setena. Justificació i pagament. Les obres hauran d'estar acabades en un termini de dotze mesos des de la notificació de la concessió. El pagament es farà una vegada justificada la despesa mitjançant les factures i el certificat final d'obra. L'incompliment de les condicions donarà lloc al reintegrament total o parcial de l'ajuda percebuda."}]}, "exercises": [{"q": "Quina és la doble finalitat d'estes ajudes?", "o": ["Conservar el patrimoni i que els habitatges buits tornen a habitar-se", "Modernitzar l'interior de les cases i abaratir-ne la venda", "Construir habitatges nous de lloguer dins del nucli històric"], "e": "Base primera: «afavorir la conservació del patrimoni» i «que els immobles desocupats tornen a ser habitats»."}, {"q": "Pot demanar l'ajuda una persona que viu de lloguer?", "o": ["Sí, si té l'autorització escrita de la propietat", "No, només la poden demanar les persones propietàries", "Sí, però només si fa cinc anys que hi viu"], "e": "Base segona: les persones llogateres hi poden optar «amb l'autorització expressa i per escrit de la propietat»."}, {"q": "Quina d'estes despeses NO seria subvencionable?", "o": ["Canviar els mobles de la cuina", "Reparar la teulada de la casa", "Substituir les finestres exteriors"], "e": "Base tercera: no ho són «l'adquisició de mobles o electrodomèstics»."}, {"q": "Una família rehabilita la casa per a viure-hi amb un pressupost de 30.000 euros. Quina ajuda màxima pot rebre?", "o": ["12.000 euros", "18.000 euros", "9.000 euros"], "e": "Li correspondria el 60 % (18.000 €), però el límit de 12.000 € «s'aplicarà en tots els casos»."}, {"q": "Què vol dir que les ajudes es concedixen «en règim de concurrència competitiva»?", "o": ["Que les sol·licituds es puntuen i es comparen entre elles", "Que s'atorguen per orde d'arribada fins que s'acaben els diners", "Que només hi poden participar empreses de construcció"], "e": "La base cinquena fixa uns criteris de puntuació; l'orde de registre només desfà els empats."}, {"q": "Què passa si no s'esmena una sol·licitud incompleta en el termini fixat?", "o": ["Es considera que la persona hi renuncia", "Se li concedix una ajuda més reduïda", "El termini s'amplia automàticament"], "e": "Base sisena: «es considerarà que hi ha desistit», és a dir, que ha renunciat a la sol·licitud."}, {"q": "En la base setena, què significa «reintegrament»?", "o": ["Tornar l'import de l'ajuda rebuda", "Repetir les obres que estan mal fetes", "Presentar de nou tota la documentació"], "e": "Si no es complixen les condicions, cal retornar total o parcialment els diners percebuts."}]}, {"passage": {"media": "text", "title": "Notificació de resolució: places d'auxiliar de biblioteca", "lines": [{"text": "Ajuntament de Sueca. Àrea de Recursos Humans. Destinatària: Neus Ferrando Climent. Assumpte: notificació de la resolució d'exclusió definitiva del procés selectiu per a la cobertura de dues places d'auxiliar de biblioteca."}, {"text": "Vos notifique que l'Alcaldia, en data 3 de setembre de 2026, ha dictat la resolució següent, que es reproduïx en la part que vos afecta:"}, {"text": "«Antecedents. Primer. Per mitjà de la Resolució de 12 de juny de 2026 es va aprovar la llista provisional de persones admeses i excloses, en què la senyora Neus Ferrando Climent figurava com a exclosa per no haver acreditat el coneixement de valencià de nivell B2 exigit en la base tercera de la convocatòria. Segon. Dins del termini d'al·legacions, la interessada va presentar un escrit en què exposava que havia superat la prova corresponent en la convocatòria de juny i que el certificat estava pendent d'expedició. Hi adjuntava una captura de pantalla de la llista provisional de persones aptes."}, {"text": "Fonaments de dret. D'acord amb la base tercera, tots els requisits s'han de posseir en la data en què finalitza el termini de presentació d'instàncies, és a dir, el 30 de maig de 2026. Atés que la prova a què fa referència la interessada es va fer el 14 de juny, en una data posterior, l'al·legació no pot ser estimada, independentment del resultat obtingut. Cal afegir, a més, que una llista provisional no té valor acreditatiu."}, {"text": "Resolució. Desestimar l'al·legació presentada i confirmar l'exclusió definitiva de la senyora Neus Ferrando Climent del procés selectiu.»"}, {"text": "Contra esta resolució, que posa fi a la via administrativa, podeu interposar potestativament un recurs de reposició davant del mateix òrgan que l'ha dictada, en el termini d'un mes comptador des de l'endemà de la recepció d'esta notificació. També podeu interposar directament un recurs contenciós administratiu davant dels jutjats d'eixe orde de València, en el termini de dos mesos. Tanmateix, si opteu per la reposició, no podreu interposar el recurs contenciós administratiu fins que no s'haja resolt expressament o no se n'haja produït la desestimació per silenci, que s'entendrà produïda si, transcorregut un mes des de la interposició, no se n'ha notificat la resolució."}, {"text": "Tot això, sense perjuí que pugueu exercir qualsevol altre recurs que considereu procedent. Així mateix, vos informem que l'Ajuntament té previst constituir durant el primer trimestre de 2027 una borsa de treball per a la mateixa categoria, a la qual podreu optar si en compliu els requisits."}, {"text": "Sueca, 8 de setembre de 2026. La cap del Servici de Recursos Humans."}]}, "exercises": [{"q": "Per què va ser exclosa Neus Ferrando del procés?", "o": ["No acreditava el B2 de valencià en la data exigida", "No va presentar la instància dins de termini", "Va suspendre la prova de valencià de juny"], "e": "Figurava com a exclosa «per no haver acreditat el coneixement de valencià de nivell B2»; ella diu que va aprovar la prova."}, {"q": "Quin és l'argument principal de l'Ajuntament per a desestimar l'al·legació?", "o": ["Els requisits s'havien de complir abans del 30 de maig", "La captura de pantalla que va enviar era falsa", "El nivell B2 no és suficient per a estes places"], "e": "«Tots els requisits s'han de posseir en la data en què finalitza el termini de presentació d'instàncies.»"}, {"q": "Què implica l'expressió «independentment del resultat obtingut»?", "o": ["Que encara que haja aprovat, la decisió no canviaria", "Que l'Ajuntament dubta que haja aprovat la prova", "Que el resultat es revisarà en una fase posterior"], "e": "La prova és posterior al 30 de maig; per tant, el resultat no hi influïx."}, {"q": "Quin termini té per a presentar un recurs de reposició?", "o": ["Un mes des de l'endemà de rebre la notificació", "Dos mesos des de la data de la resolució", "Deu dies hàbils des de la publicació de la llista"], "e": "«En el termini d'un mes comptador des de l'endemà de la recepció d'esta notificació.»"}, {"q": "En el text, «potestativament» vol dir…", "o": ["De manera voluntària, no obligatòria", "De manera obligatòria abans d'anar als jutjats", "Per mitjà d'un advocat o una advocada"], "e": "Es pot triar entre la reposició o anar directament al contenciós administratiu."}, {"q": "Si presenta un recurs de reposició i passa un mes sense resposta, què passa?", "o": ["S'entén desestimat i pot anar al contenciós", "S'entén estimat i queda readmesa", "Ha de tornar a presentar el mateix recurs"], "e": "Es produïx la «desestimació per silenci» si, «transcorregut un mes», no se n'ha notificat la resolució."}, {"q": "Pot presentar alhora el recurs de reposició i el contenciós administratiu?", "o": ["No, ha d'esperar que es resolga la reposició", "Sí, és el procediment més recomanable", "Sí, sempre que ho faça dins del primer mes"], "e": "Si opta per la reposició, no pot interposar el contenciós «fins que no s'haja resolt»."}, {"q": "Quina funció té l'últim paràgraf de la notificació?", "o": ["Informar-la d'una possibilitat futura de treball", "Demanar-li disculpes per un error administratiu", "Comunicar-li que ha sigut readmesa provisionalment"], "e": "Anuncia una borsa de treball per a la mateixa categoria en 2027."}]}]},
  {"id": "f8d01552-b646-5a88-9a0d-43b82a477d86", "category": "comprensio_escrita", "type": "b2_ce_especialitzats", "sort_order": 5, "title": "Textos especialitzats", "name": "Divulgació en salut i economia", "content": "Entén textos divulgatius especialitzats i deduïx pel context el significat dels termes tècnics.", "icon": "🔬", "color": "#B3E5FC", "blocks": [{"passage": {"media": "text", "title": "Quan els antibiòtics deixen de funcionar", "lines": [{"text": "Cada hivern, les consultes d'atenció primària s'omplin de pacients amb mal de gola, tos i febre que esperen eixir-ne amb una recepta d'antibiòtics. Molts se'n van decebuts quan la metgessa els explica que no en necessiten. La raó és senzilla, però costa d'acceptar: la gran majoria d'estes infeccions les causen virus, i els antibiòtics només actuen contra els bacteris. Prendre'ls per a un refredat no escurça la malaltia ni n'alleuja els símptomes; en canvi, sí que té conseqüències que van molt més enllà del pacient."}, {"text": "Per a entendre-ho, cal pensar en una població de bacteris com en un conjunt d'individus que no són idèntics. Quan administrem un antibiòtic, la major part moren, però alguns, gràcies a una mutació que ja tenien a l'atzar, sobreviuen. Si eixos supervivents es multipliquen, la generació següent serà majoritàriament resistent. És el que els microbiòlegs anomenen pressió selectiva: el fàrmac no crea la resistència, però afavorix els qui ja la tenien. Com més sovint i amb menys criteri usem els antibiòtics, més oportunitats donem a eixa selecció."}, {"text": "El problema s'agreuja amb els antibiòtics d'ampli espectre, que eliminen una gran varietat d'espècies bacterianes alhora. Són molt útils quan no se sap quin microorganisme causa una infecció greu, però arrasen també la microbiota, és a dir, els bilions de bacteris inofensius o beneficiosos que viuen a l'intestí i a la pell. Eixe buit pot ser ocupat per espècies oportunistes i, a més, els bacteris poden intercanviar-se els gens de resistència, fins i tot entre espècies diferents."}, {"text": "Les dades són preocupants. Segons les estimacions dels organismes sanitaris internacionals, les infeccions per bacteris multiresistents ja causen més d'un milió de morts directes cada any en el món, i la xifra podria créixer de manera notable en les pròximes dècades. Intervencions quirúrgiques que hui considerem rutinàries, com una pròtesi de maluc o una cesària, depenen de la profilaxi antibiòtica, és a dir, de l'administració preventiva del fàrmac abans de l'operació per a evitar infeccions. Sense antibiòtics eficaços, eixes operacions tornarien a ser arriscades."}, {"text": "La solució no depén només dels laboratoris. Desenvolupar un antibiòtic nou costa molts anys i és poc rendible per a la indústria, perquè, precisament per a preservar-ne l'eficàcia, se'n restringix l'ús. Per això, els experts insistixen en mesures que estan al nostre abast: no automedicar-se, no guardar les pastilles sobrants per a una altra ocasió, seguir exactament les pautes prescrites i reduir l'ús d'antibiòtics en la ramaderia, on durant anys s'han emprat per a accelerar el creixement dels animals. Es tracta, en definitiva, de cuidar un recurs compartit que, com l'aigua d'un aqüífer, pot esgotar-se si cadascú en trau tant com vol."}]}, "exercises": [{"q": "Per què és inútil prendre antibiòtics per a un refredat?", "o": ["Perquè el refredat el causen virus", "Perquè la dosi habitual és massa baixa", "Perquè els símptomes desapareixen sols en dos dies"], "e": "«La gran majoria d'estes infeccions les causen virus, i els antibiòtics només actuen contra els bacteris.»"}, {"q": "Segons el context, què és la «pressió selectiva»?", "o": ["L'efecte del fàrmac que afavorix els bacteris ja resistents", "L'efecte del fàrmac que provoca mutacions noves als bacteris", "La pressió que fan els pacients per obtindre una recepta"], "e": "«El fàrmac no crea la resistència, però afavorix els qui ja la tenien.»"}, {"q": "Què vol dir que un antibiòtic és «d'ampli espectre»?", "o": ["Que actua contra molts tipus de bacteris alhora", "Que el seu efecte dura molts dies seguits", "Que servix també contra les infeccions víriques"], "e": "«Eliminen una gran varietat d'espècies bacterianes alhora.»"}, {"q": "Què és la «microbiota», segons el text?", "o": ["Els bacteris que viuen normalment en el nostre cos", "Un grup d'espècies oportunistes i perilloses", "Un tipus d'antibiòtic d'ús intestinal"], "e": "«Els bilions de bacteris inofensius o beneficiosos que viuen a l'intestí i a la pell.»"}, {"q": "Per què l'autor esmenta la pròtesi de maluc i la cesària?", "o": ["Per a mostrar que la medicina actual depén d'antibiòtics eficaços", "Per a criticar l'excés d'operacions que no són necessàries", "Per a explicar com es transmeten els bacteris als hospitals"], "e": "Depenen de la profilaxi antibiòtica; sense antibiòtics eficaços «tornarien a ser arriscades»."}, {"q": "Per què la indústria inverteix poc en antibiòtics nous?", "o": ["Perquè no són rendibles, ja que se'n limita l'ús", "Perquè els bacteris ja han deixat de mutar", "Perquè la llei impedix comercialitzar-ne de nous"], "e": "«És poc rendible per a la indústria, perquè [...] se'n restringix l'ús.»"}, {"q": "Quina d'estes conductes recomanen els experts?", "o": ["No guardar les pastilles sobrants per a una altra vegada", "Prendre antibiòtics als primers símptomes de febre", "Demanar sempre antibiòtics d'ampli espectre"], "e": "Entre les mesures: «no guardar les pastilles sobrants per a una altra ocasió»."}, {"q": "Què pretén transmetre la comparació final amb un aqüífer?", "o": ["Que és un recurs comú que es pot esgotar per l'abús de cadascú", "Que la contaminació de l'aigua augmenta les infeccions", "Que el problema afecta sobretot les zones amb sequera"], "e": "Com l'aigua d'un aqüífer, l'eficàcia dels antibiòtics «pot esgotar-se si cadascú en trau tant com vol»."}]}, {"passage": {"media": "text", "title": "Estalviar no sempre és guanyar", "lines": [{"text": "Imaginem dues amigues, Empar i Rosa, que han estalviat 10.000 euros cadascuna. Empar els deixa en el compte corrent, que no li paga res. Rosa els posa en un depòsit a termini fix que li oferix un 3 % de TAE. Al cap d'un any, Rosa tindrà 10.300 euros i Empar, els mateixos 10.000. Fins ací, la conclusió sembla òbvia. Però si aquell any els preus han pujat un 4 %, cap de les dues no podrà comprar el que comprava abans amb els diners que té."}, {"text": "Este és el primer concepte que cal tindre clar: el poder adquisitiu. Els diners no valen per la xifra que hi ha escrita en el bitllet, sinó per la quantitat de béns i servicis que permeten adquirir. Quan hi ha inflació, és a dir, un augment generalitzat i sostingut dels preus, cada euro compra menys coses. Per això els economistes distingixen entre la rendibilitat nominal d'un producte, el percentatge que anuncia l'entitat, i la rendibilitat real, que resulta de restar-hi la inflació. En l'exemple, Rosa obté un 3 % nominal, però en realitat perd aproximadament un 1 %; Empar en perd un 4 %."}, {"text": "El segon concepte és la TAE, la taxa anual equivalent. Les entitats financeres poden anunciar un tipus d'interés nominal, però la TAE és la xifra que permet comparar ofertes, perquè hi incorpora la freqüència amb què es liquiden els interessos i, en els préstecs, també les comissions. Dos préstecs amb el mateix tipus nominal poden tindre TAE diferents si un dels dos cobra una comissió d'obertura. Desconfiar d'una publicitat que destaca el tipus nominal i amaga la TAE en lletra menuda és, per tant, un bon hàbit."}, {"text": "El tercer és l'interés compost. Quan els interessos generats no es retiren, sinó que s'afigen al capital, l'any següent també produïxen interessos. L'efecte és modest a curt termini, però espectacular a llarg termini: una quantitat invertida al 5 % anual es duplica, aproximadament, en catorze anys. El mateix mecanisme, però, juga en contra de qui deu diners: un deute de targeta de crèdit que no es paga creix de la mateixa manera, i amb tipus molt més alts."}, {"text": "Cap d'estos conceptes no és un secret reservat als especialistes, però sovint es presenten envoltats d'un vocabulari que fa por. Entendre'ls no garantix fer-se ric, i convé recordar que, en general, com més alta és la rendibilitat que s'oferix, més risc s'assumix. El que sí que garantix és poder fer preguntes millors abans de signar res, i adonar-se que deixar els diners quiets no és una opció neutra: també és una decisió, i té conseqüències."}]}, "exercises": [{"q": "Quina és la idea principal del text?", "o": ["Per a decidir sobre l'estalvi cal entendre alguns conceptes econòmics bàsics", "Els depòsits a termini fix sempre són millors que els comptes corrents", "Les entitats financeres enganyen els clients amb la publicitat"], "e": "El text explica el poder adquisitiu, la TAE i l'interés compost per a «poder fer preguntes millors»."}, {"q": "Què il·lustra l'exemple d'Empar i Rosa?", "o": ["Que fins i tot guanyant un 3 % es pot perdre poder adquisitiu", "Que Rosa ha fet una inversió massa arriscada", "Que Empar ha eixit guanyant perquè no ha arriscat res"], "e": "Amb una inflació del 4 %, «cap de les dues no podrà comprar el que comprava abans»."}, {"q": "Què és el «poder adquisitiu»?", "o": ["La quantitat de béns i servicis que es poden comprar amb uns diners", "La quantitat total de diners que hi ha en un compte", "La capacitat que té algú per a demanar un préstec"], "e": "«Els diners no valen per la xifra [...] sinó per la quantitat de béns i servicis que permeten adquirir.»"}, {"q": "Com es calcula la rendibilitat real?", "o": ["Restant la inflació a la rendibilitat nominal", "Sumant les comissions al percentatge anunciat", "Multiplicant el tipus nominal pels anys del depòsit"], "e": "La rendibilitat real «resulta de restar-hi la inflació»."}, {"q": "Per què és útil la TAE?", "o": ["Permet comparar ofertes perquè inclou la liquidació i les comissions", "Sempre és més baixa que el tipus d'interés nominal", "És idèntica en totes les entitats perquè la fixa la llei"], "e": "«Permet comparar ofertes, perquè hi incorpora la freqüència [...] i les comissions.»"}, {"q": "Segons el text, com afecta l'interés compost un deute de targeta que no es paga?", "o": ["El fa créixer cada vegada més de pressa", "El reduïx a poc a poc amb el temps", "No l'afecta, perquè només s'aplica a l'estalvi"], "e": "«Un deute de targeta de crèdit que no es paga creix de la mateixa manera, i amb tipus molt més alts.»"}, {"q": "Quina advertència fa l'autor sobre les rendibilitats altes?", "o": ["Que solen implicar més risc", "Que garantixen guanys segurs a llarg termini", "Que només estan a l'abast dels especialistes"], "e": "«Com més alta és la rendibilitat que s'oferix, més risc s'assumix.»"}, {"q": "Què vol dir l'autor amb «deixar els diners quiets no és una opció neutra»?", "o": ["Que no fer res també té conseqüències econòmiques", "Que cal invertir sempre en productes d'alt risc", "Que els comptes corrents cobren comissions molt altes"], "e": "Amb inflació, no moure els diners també fa perdre poder adquisitiu: «també és una decisió»."}]}]},
  {"id": "816b1a80-b15e-5d30-8bdf-5baeb00aa978", "category": "comprensio_escrita", "type": "b2_ce_humor", "sort_order": 6, "title": "Textos humorístics", "name": "Columnes satíriques i diàlegs còmics", "content": "Capta la ironia, el to i la intenció crítica de textos humorístics.", "icon": "😄", "color": "#FFE0B2", "blocks": [{"passage": {"media": "text", "title": "Vull comprar tomaques (i no sé com fer-ho)", "lines": [{"text": "Dissabte passat vaig cometre la temeritat d'anar al mercat amb la intenció, ingènua i un poc antiquada, de comprar un quilo de tomaques. Ho reconec: m'hi vaig presentar amb diners en la butxaca i una bossa de tela, com qui va a la guerra amb una ballesta."}, {"text": "La parada de sempre continuava allí, però el senyor Tonet ja no hi era. En el seu lloc hi havia un xic molt amable, amb una gorra que deia «Experiència Hortícola», que em va rebre amb una pregunta inquietant: «Teniu l'app?». Jo, que fins a eixe moment pensava que les tomaques només calia tindre-les, vaig confessar que no."}, {"text": "Em va explicar, amb la paciència que es reserva als xiquets i als turistes, que ara les tomaques no es compren, sinó que es «reserven», i que cada una té un codi QR on pots consultar el nom de l'agricultor, les hores de sol que ha rebut i, si pagues la versió prèmium, la música que li posaven mentre maduraven. Vaig preguntar si podia, simplement, tocar-ne una per a veure si estava madura. Em va mirar com si li haguera proposat llepar el taulell."}, {"text": "Vaig baixar l'aplicació. Em va demanar el correu, el telèfon, la data de naixement, permís per a accedir a la meua ubicació i, no sé ben bé per què, als meus contactes. Suposse que per si algun cosí meu també vol tomaques. Després vaig haver de triar una contrasenya amb majúscules, números, un símbol i, si pot ser, una gota de sang. Quan per fi vaig entrar, un missatge molt alegre em va donar la benvinguda a «la comunitat» i em va informar que la primera compra tenia un 10 % de descompte si convidava tres amics. Ja no em queden tres amics a qui puga fer això."}, {"text": "Total, que vint-i-cinc minuts després tenia un quilo de tomaques «reservat» per a recollir-lo dimarts, en una franja horària de 17.15 a 17.30. Vaig mirar el xic, vaig mirar les tomaques, que estaven a mig metre, i les tomaques em van mirar a mi. Juraria que amb pena."}, {"text": "No vull semblar un nostàlgic. Estic segur que tot això té avantatges: la traçabilitat, la sostenibilitat i altres paraules acabades en -itat que ningú no sap ben bé què volen dir un dissabte a les deu del matí. Però em pregunte si, a força de fer-ho tot més fàcil, no ho hem fet tot una mica més difícil."}, {"text": "Dimarts a les 17.15 vaig anar a recollir les tomaques. La parada estava tancada: el sistema havia caigut. Al costat, una iaia venia tomaques del seu hort en una caixa de fusta, a dos euros el quilo, sense app, sense QR i sense comunitat. Li'n vaig comprar dos quilos. Encara no sé quantes hores de sol havien rebut, però estaven boníssimes."}]}, "exercises": [{"q": "Què pretén l'autor quan es compara amb «qui va a la guerra amb una ballesta»?", "o": ["Riure's de com d'antiquat sembla ja pagar en efectiu", "Explicar que el mercat era un lloc perillós", "Avisar que anava disposat a discutir amb el venedor"], "e": "Exagera irònicament: anar amb diners i bossa de tela ara és com dur una arma medieval."}, {"q": "Què suggerix «amb la paciència que es reserva als xiquets i als turistes»?", "o": ["Que el xic el tractava com algú que no entenia res", "Que el xic era molt antipàtic i no l'atenia", "Que l'autor havia anat al mercat de vacances"], "e": "Ironia: el venedor li parla amb condescendència, com a qui desconeix les normes."}, {"q": "Què expressa «em va mirar com si li haguera proposat llepar el taulell»?", "o": ["Que tocar la fruita li semblava una cosa inacceptable", "Que el taulell de la parada estava molt brut", "Que l'autor tenia fam i volia tastar les tomaques"], "e": "La comparació exagera el rebuig del venedor davant d'un gest tradicional."}, {"q": "Per què diu que no li queden «tres amics a qui puga fer això»?", "o": ["Perquè convidar-los a l'app seria fer-los una mala passada", "Perquè s'ha barallat amb tots els amics", "Perquè els seus amics no viuen al poble"], "e": "Presenta la invitació com un càstig, no com un avantatge: és una crítica irònica."}, {"q": "Quin recurs humorístic s'usa en «les tomaques em van mirar a mi. Juraria que amb pena»?", "o": ["La personificació, per a subratllar l'absurd de la situació", "Una descripció literal de l'estat de les tomaques", "Una crítica a la mala qualitat del producte"], "e": "Atribuïx a les tomaques una mirada i un sentiment humans."}, {"q": "Quin to té el comentari sobre les «paraules acabades en -itat»?", "o": ["Burleta cap a un vocabulari de moda que s'usa sense entendre'l", "D'admiració per l'interés per la sostenibilitat", "De queixa per la dificultat de la gramàtica"], "e": "Diu que «ningú no sap ben bé què volen dir»: es burla de l'ús buit d'eixes paraules."}, {"q": "Quina és la tesi de la columna?", "o": ["La tecnologia que promet simplificar pot complicar coses senzilles", "La tecnologia s'hauria de prohibir en els mercats municipals", "Els mercats tradicionals tanquen per falta de clients"], "e": "«A força de fer-ho tot més fàcil, no ho hem fet tot una mica més difícil.»"}, {"q": "Quina funció té l'episodi final de la iaia?", "o": ["Reforçar la crítica: la venda tradicional funciona quan l'app falla", "Mostrar que l'autor ja s'ha acostumat a l'aplicació", "Demostrar que el sistema digital funciona bé al final"], "e": "La parada digital està tancada perquè «el sistema havia caigut» i la iaia li ven les tomaques sense complicacions."}]}, {"passage": {"media": "text", "title": "Reunió extraordinària de l'escala B", "lines": [{"speaker": "Administrador", "text": "Bona vesprada. Comencem la reunió extraordinària convocada per a decidir, en un únic punt de l'orde del dia, el color de la porta del carrer. Recorde que es va pintar fa onze anys i que, segons l'informe tècnic, la pintura s'està desprenent."}, {"speaker": "Vicent", "text": "Abans de començar, vull que conste en acta que no hi estic d'acord."}, {"speaker": "Administrador", "text": "Amb què, senyor Vicent?"}, {"speaker": "Vicent", "text": "Encara no ho sé. Però vull que conste, per si de cas."}, {"speaker": "Amparo", "text": "Molt bé. Com a presidenta, propose el verd, que és un color alegre i combina amb els geranis del primer."}, {"speaker": "Lídia", "text": "Els geranis del primer són de plàstic, Amparo."}, {"speaker": "Amparo", "text": "Per això mateix: duren molt. Com la porta, si la pintem bé."}, {"speaker": "Vicent", "text": "Verd no. El verd porta mala sort. Mon pare ho deia, i mon pare no es va equivocar mai, excepte quan va comprar este pis."}, {"speaker": "Lídia", "text": "Jo crec que hauríem de pensar en la sostenibilitat. Hi ha pintures ecològiques fetes amb pigments naturals. Són el doble de cares, però, a canvi, fan una olor molt agradable."}, {"speaker": "Administrador", "text": "La porta dona al carrer, senyora Lídia. De l'olor en gaudiran sobretot els coloms."}, {"speaker": "Amparo", "text": "Doncs que en gaudisquen. Ells també són veïns, i més constants que alguns que no venen mai a les reunions."}, {"speaker": "Vicent", "text": "Si ho dius per mi, jo vinc a totes. Precisament per a votar en contra."}, {"speaker": "Administrador", "text": "Si em permeten, proposaria una solució de consens: tornar a pintar-la del mateix color marró que té ara."}, {"speaker": "Lídia", "text": "Marró? Això és rendir-se. És acceptar que la vida és marró."}, {"speaker": "Amparo", "text": "A mi el marró em sembla trist, però és veritat que dissimula molt bé la brutícia. I la vida també."}, {"speaker": "Vicent", "text": "Jo vote en contra."}, {"speaker": "Administrador", "text": "Encara no hem votat, senyor Vicent."}, {"speaker": "Vicent", "text": "Ja ho sé, però és per avançar faena."}, {"speaker": "Administrador", "text": "Bé. Atés que són les nou i quart i que no hi ha acord, propose crear una comissió del color, formada per tres veïns, que estudie la qüestió amb calma i presente un informe en la pròxima reunió ordinària."}, {"speaker": "Amparo", "text": "I quan serà eixa reunió?"}, {"speaker": "Administrador", "text": "D'ací a sis mesos."}, {"speaker": "Lídia", "text": "I mentrestant, què fem amb la porta?"}, {"speaker": "Administrador", "text": "Res. Continuarà perdent la pintura, que és l'única cosa en què estem tots d'acord."}, {"speaker": "Vicent", "text": "Que conste en acta que jo, d'això, tampoc no n'estic segur."}]}, "exercises": [{"q": "Per què resulta còmica la primera intervenció de Vicent?", "o": ["Perquè es declara en contra abans de saber de què es tracta", "Perquè interromp l'administrador amb un tema aliè a la reunió", "Perquè proposa un color absurd per a la porta"], "e": "«Encara no ho sé. Però vull que conste, per si de cas.»"}, {"q": "Què fa Amparo quan respon «Per això mateix: duren molt»?", "o": ["Convertix una objecció en un argument a favor, de manera absurda", "Reconeix que s'ha equivocat i retira la proposta", "Proposa substituir els geranis per plantes naturals"], "e": "Lídia retrau que els geranis són de plàstic i Amparo ho presenta com un avantatge."}, {"q": "Què insinua Vicent amb «excepte quan va comprar este pis»?", "o": ["Que viure en eixe edifici no és cap ganga", "Que son pare va comprar el pis molt barat", "Que son pare treballava venent pisos"], "e": "Ironia: l'únic error de son pare va ser comprar un pis en eixa escala."}, {"q": "Amb quina intenció parla l'administrador dels coloms?", "o": ["Mostrar amb ironia que l'argument de l'olor no té sentit", "Proposar una pintura que espante els coloms del carrer", "Defendre la pintura ecològica perquè respecta els animals"], "e": "Si la porta dona al carrer, una pintura que fa bona olor no aprofita els veïns."}, {"q": "Què revela la frase de Vicent «és per avançar faena»?", "o": ["Que vota en contra per sistema, sense escoltar", "Que té pressa perquè ha de tornar a la faena", "Que no ha entés quin era l'orde del dia"], "e": "Vota abans que es faça la votació: la seua oposició és automàtica."}, {"q": "Què satiritza la proposta de crear una «comissió del color»?", "o": ["La tendència a ajornar decisions senzilles amb burocràcia", "L'eficàcia de l'administrador a l'hora de resoldre conflictes", "La complexitat tècnica de pintar una porta"], "e": "Per a triar un color, es crea una comissió que informarà d'ací a sis mesos."}, {"q": "Quina és la ironia de l'última intervenció de l'administrador?", "o": ["L'únic acord és deixar que la porta continue deteriorant-se", "Tots els veïns s'han posat d'acord a pintar-la de marró", "Tots els veïns volen formar part de la comissió"], "e": "«Continuarà perdent la pintura, que és l'única cosa en què estem tots d'acord.»"}]}]},
  {"id": "fb8de9dc-d1fc-516b-97cb-f59f8cf04ae5", "category": "expressio_escrita", "type": "b2_ee_ressenya", "sort_order": 1, "title": "Ressenyes i crítiques", "name": "Cinema, llibres i teatre", "content": "Escriu ressenyes i crítiques culturals elaborades i detallades de pel·lícules, llibres i obres de teatre, amb una valoració ben argumentada.", "icon": "🎭", "color": "#D1C4E9", "exercises": [{"q": "La revista cultural de la teua universitat publica cada mes crítiques de cinema escrites pels lectors. Escriu la ressenya d'una pel·lícula que hages vist recentment (real o imaginada): presenta-la breument sense desvelar-ne el final, analitza'n almenys dos aspectes (guió, interpretació, fotografia, música, ritme...), assenyala'n els punts forts i els febles i conclou amb una valoració argumentada que indique a quin tipus d'espectador la recomanaries i per què.", "w": {"min_words": 200, "max_words": 250}}, {"q": "El blog de lectura de la biblioteca municipal de Gandia convida els usuaris a ressenyar una novel·la que els haja deixat empremta. Escriu-ne la ressenya: situa l'obra (autor, gènere, època i ambientació), resumix-ne l'argument sense revelar-ne el desenllaç, comenta com està construït el personatge principal i com és l'estil de l'autor, i contrasta la teua opinió amb la d'un lector a qui no haja agradat. Acaba amb una recomanació matisada.", "w": {"min_words": 200, "max_words": 250}}, {"q": "Has anat a l'estrena d'una obra de teatre en un teatre de Castelló de la Plana (real o imaginada). Escriu una crítica breu per a la secció de cultura d'un diari digital comarcal: descriu la posada en escena (escenografia, il·luminació, vestuari), valora la interpretació del repartiment i explica si la proposta del director t'ha convençut o no i per què. Usa un registre estàndard i vocabulari propi de l'àmbit teatral.", "w": {"min_words": 150, "max_words": 180}}]},
  {"id": "9b3c7f34-c9ba-5550-848f-619c81f3cfff", "category": "expressio_escrita", "type": "b2_ee_opinio", "sort_order": 2, "title": "Articles d'opinió", "name": "Argumentar a favor i en contra", "content": "Escriu articles d'opinió, redaccions argumentatives i cartes al director que desenvolupen un argument i presenten raons a favor i en contra d'un punt de vista.", "icon": "🗞️", "color": "#FFE0B2", "exercises": [{"q": "L'Ajuntament de la teua ciutat ha anunciat que tancarà al trànsit privat tot el centre històric a partir del curs que ve. Escriu una carta al director d'un diari local en què exposes la teua posició: presenta la mesura, desenvolupa almenys dos arguments que donen suport a la teua postura, reconeix i rebat un argument contrari i acaba amb una proposta concreta. Recorda les fórmules d'encapçalament i de comiat pròpies d'este gènere.", "w": {"min_words": 150, "max_words": 180}}, {"q": "«La setmana laboral de quatre dies hauria de ser obligatòria per a totes les empreses.» Escriu una redacció argumentativa sobre esta afirmació: introduïx el tema, exposa els avantatges i els inconvenients que tindria per als treballadors, per a les empreses i per a la societat, i arriba a una conclusió personal ben fonamentada. Organitza el text en paràgrafs i usa connectors d'oposició i de concessió (no obstant això, si bé, encara que, en canvi, malgrat que...).", "w": {"min_words": 200, "max_words": 250}}, {"q": "La revista de la teua associació de veïns et demana un article d'opinió sobre l'ús de la intel·ligència artificial en els centres educatius: hi ha qui creu que s'hauria de prohibir en les tasques escolars i qui defén que cal ensenyar a usar-la de manera crítica. Escriu l'article amb un títol atractiu, exposa les dues posicions amb objectivitat, pren partit amb arguments i exemples, i tanca'l amb una reflexió que convide els lectors a pensar-hi.", "w": {"min_words": 200, "max_words": 250}}]},
  {"id": "b89ac19f-7def-5f3d-86f8-29d22489c66e", "category": "expressio_escrita", "type": "b2_ee_informe", "sort_order": 3, "title": "Informes", "name": "Analitzar opcions i recomanar", "content": "Redacta informes formals que exposen una situació, comparen els avantatges i els inconvenients de diverses opcions i acaben amb una recomanació justificada.", "icon": "📊", "color": "#C5CAE9", "exercises": [{"q": "Treballes en el departament de recursos humans d'una empresa de logística de Sagunt. La direcció vol saber si convé implantar el teletreball dos dies a la setmana. Redacta un informe adreçat a la gerència amb estes parts: objecte de l'informe, situació actual, avantatges i inconvenients del teletreball (productivitat, costos, conciliació, comunicació interna) i una recomanació final justificada. Usa un registre formal i impersonal.", "w": {"min_words": 200, "max_words": 250}}, {"q": "L'associació de mares i pares d'un institut d'Alcoi ha de decidir com invertirà una subvenció de 6.000 euros. Hi ha tres opcions: renovar la biblioteca, instal·lar ombratges en el pati o finançar un programa d'activitats extraescolars gratuïtes. Com a secretari o secretària de l'associació, redacta un informe per a l'assemblea que compare les tres opcions (cost, nombre de beneficiaris, durada de l'impacte) i acabe amb una proposta raonada.", "w": {"min_words": 200, "max_words": 250}}, {"q": "L'Ajuntament d'un poble de la Marina Alta estudia si cal ampliar el servici d'autobús urbà o crear una xarxa de bicicletes compartides. Com a tècnic o tècnica de mobilitat, redacta un informe breu que expose la situació actual, enumere els avantatges i els inconvenients de cada opció i arribe a una recomanació. Utilitza estructures impersonals i connectors propis dels textos formals (pel que fa a, d'altra banda, per consegüent, en conclusió...).", "w": {"min_words": 150, "max_words": 180}}]},
  {"id": "7a7cd3ac-8fc2-589e-a694-9802715e45f7", "category": "expressio_escrita", "type": "b2_ee_correus", "sort_order": 4, "title": "Correus i converses escrites", "name": "Emocions, notícies i fòrums", "content": "Escriu cartes, correus i missatges personals i semiformals que transmeten emocions i comenten les notícies dels altres, i participa en converses escrites confirmant la comprensió i demanant aclariments.", "icon": "💬", "color": "#F8BBD0", "exercises": [{"q": "Una amiga que viu a Lió t'ha escrit per a contar-te que, després de molts anys d'intents, li han publicat la primera novel·la, però també que s'ha separat de la seua parella. Contesta-li amb un correu: reacciona a les dues notícies amb el to i el grau d'emoció adequats a cadascuna, comenta les opinions que ella et dona sobre el seu futur i conta-li alguna novetat teua que per a tu siga especialment important.", "w": {"min_words": 200, "max_words": 250}}, {"q": "Fa vint anys que vas acabar el batxillerat i estàs organitzant el sopar de retrobament de la promoció. Escriu un correu a una antiga professora que va ser decisiva per a tu: explica-li el motiu del sopar, fes-li saber per què la seua presència t'importa tant (recorda algun moment concret) i convida-la amb un to afectuós però respectuós.", "w": {"min_words": 150, "max_words": 180}}, {"q": "En el fòrum de l'associació excursionista de la qual formes part, un membre ha publicat este missatge: «Dissabte que ve fem la ruta del Penyagolosa. Eixirem prompte, i els qui no tinguen experiència haurien de pensar-s'ho. Porteu el que calga.» Hi ha coses que no t'han quedat clares. Escriu una resposta en què demostres que has entés la proposta, demanes aclariments sobre els aspectes ambigus (hora i lloc d'eixida, dificultat, material necessari...) i animes els membres nous a participar-hi.", "w": {"min_words": 150, "max_words": 180}}, {"q": "En el xat de grup de la teua colla, una amiga proposa organitzar una festa sorpresa per als quaranta anys d'un amic comú, però alguns han contestat amb pressa i les propostes es contradiuen (dates, lloc, pressupost). Escriu un missatge llarg que resumisca el que s'ha dit fins ara per a confirmar que ho has entés, assenyale els punts que no queden clars, faça una proposta concreta i convide les persones que encara no han dit res a donar la seua opinió.", "w": {"min_words": 150, "max_words": 180}}]},
  {"id": "56090579-1a0a-5995-899a-12969bf50931", "category": "expressio_escrita", "type": "b2_ee_resum", "sort_order": 5, "title": "Resumir i contrastar fonts", "name": "Opinions, entrevistes i crítiques", "content": "Resumix i contrasta la informació i els arguments de textos procedents de fonts diferents, i en comenta els punts de vista principals.", "icon": "📰", "color": "#FFF9C4", "blocks": [{"passage": {"media": "text", "title": "Dos articles d'opinió sobre els pisos turístics", "lines": [{"text": "Text A. «Una ciutat per a viure, no per a visitar», de Neus Ferrer, membre d'una associació veïnal del barri del Carme."}, {"text": "Fa deu anys coneixia tots els veïns del meu carrer. Hui, de cada quatre portes, tres són pisos turístics amb panys electrònics i maletes que roden a qualsevol hora de la nit. No tinc res contra els visitants, però una ciutat no pot convertir-se en un parc temàtic. Els lloguers s'han disparat fins al punt que els fills del barri no poden quedar-se a viure-hi, i el comerç de proximitat ha sigut substituït per botigues de records. Les dades municipals ho confirmen: en cinc anys, el barri ha perdut gairebé un quinze per cent de la població empadronada. Per això demane a l'Ajuntament que congele de manera indefinida les noves llicències, que inspeccione els pisos il·legals i que destine els ingressos de la taxa turística a construir habitatge públic. No es tracta de tancar la porta al turisme, sinó de decidir qui té dret a quedar-se a casa."}, {"text": "Text B. «Prohibir no és la solució», de Ferran Llopis, economista i propietari d'un apartament turístic a Benimaclet."}, {"text": "Cada vegada que s'obri el debat sobre l'habitatge, els pisos turístics apareixen com els grans culpables. Ara bé, convé recordar que representen menys del cinc per cent dels habitatges de la ciutat i que molts propietaris som famílies que, gràcies a estos ingressos, podem pagar la hipoteca o completar una pensió escassa. A més, el turisme genera milers de llocs de treball en la neteja, la restauració i el manteniment. No negue que en alguns barris hi ha una concentració excessiva ni que cal actuar contra l'oferta il·legal; tanmateix, una moratòria general castigaria igual els qui complixen les normes i els qui no. La vertadera causa del problema és la falta d'habitatge públic, que fa dècades que no es construïx. Proposaria, en canvi, limitar els pisos turístics per zones, segons la densitat de cada barri, i obligar les plataformes a retirar els anuncis sense llicència."}]}, "exercises": [{"q": "Llig els dos articles i escriu un text per a la secció «Debat» d'una revista universitària en què resumisques la postura de cada autor, contrastes els arguments que utilitzen (en què coincidixen i en què discrepen) i acabes amb una valoració personal sobre quina proposta et sembla més convincent i per què. No copies frases senceres: reformula les idees amb les teues paraules.", "w": {"min_words": 200, "max_words": 250}}]}, {"passage": {"media": "text", "title": "Una novel·la, dues mirades", "lines": [{"text": "Text A. Fragment d'una entrevista a l'escriptora Amparo Vidal, autora de «La casa de les persianes verdes»."}, {"text": "—La seua novel·la transcorre en un poble de la Ribera al llarg de tres generacions. D'on naix la història?"}, {"text": "—De les converses amb la meua àvia. Ella em contava com havia sigut la vida a la fàbrica de conserves, i un dia vaig pensar que eixes veus de dones que ningú no havia escoltat mereixien un llibre. No volia escriure una novel·la històrica, sinó parlar de com la memòria familiar es transmet, i també es deforma, de mares a filles."}, {"text": "—Alguns lectors diuen que el ritme és lent i que l'estructura costa de seguir."}, {"text": "—És deliberat. La vida d'aquelles dones era lenta i repetitiva, i volia que el lector sentira eixe pes. Pel que fa als salts en el temps, la memòria no funciona en línia recta: recordem a batzegades. Entenc que hi haja qui ho trobe feixuc, però no m'interessava fer un llibre de lectura ràpida."}, {"text": "Text B. Crítica de Joan Pastor publicada en el suplement cultural d'un diari."}, {"text": "«La casa de les persianes verdes» és una novel·la ambiciosa que no sempre aconseguix el que es proposa. El retrat de les tres protagonistes és memorable, sobretot el d'Elvira, l'àvia, construïda amb una tendresa que mai no cau en el sentimentalisme. La prosa és rica i precisa, i alguns capítols, com el de la pantanada del huitanta-dos, són d'una força extraordinària. Tanmateix, l'estructura fragmentada, que salta constantment d'una època a una altra, obliga el lector a un esforç que no sempre es veu recompensat, i la segona part s'allarga en descripcions que no fan avançar la història. Amb cent pàgines menys, estaríem davant d'una obra rodona. Malgrat tot, és una lectura recomanable per als qui busquen una literatura pausada i compromesa amb la memòria de les dones."}]}, "exercises": [{"q": "Llig el fragment de l'entrevista i la crítica, i escriu una ressenya breu per al club de lectura de la biblioteca: presenta la novel·la, resumix el que diu l'autora sobre les seues intencions i el que en valora el crític, i contrasta els dos punts de vista sobre el ritme i l'estructura de l'obra. Acaba explicant si, a partir d'esta informació, la proposaries per a la pròxima sessió del club i per què.", "w": {"min_words": 150, "max_words": 180}}]}]},
  {"id": "319ebe24-a6d4-56ad-a5e4-f15d7304582b", "category": "expressio_escrita", "type": "b2_ee_apunts", "sort_order": 6, "title": "Prendre apunts", "name": "Resumir una conferència", "content": "Pren apunts d'una conferència clarament estructurada sobre un tema complex i, a partir d'ells, redacta un resum ben organitzat.", "icon": "📝", "color": "#DCEDC8", "blocks": [{"passage": {"media": "audio", "title": "Conferència: l'Albufera, un ecosistema en perill", "lines": [{"speaker": "Ponent", "voice": "lluc", "text": "Bona vesprada i gràcies per la invitació. En esta conferència vull explicar-vos per què l'Albufera de València, una de les zones humides més valuoses de la Mediterrània, travessa un moment crític. L'exposició tindrà tres parts: primer, els problemes principals que patix el llac; després, les causes d'estos problemes; i, finalment, les solucions que s'estan estudiant."}, {"speaker": "Ponent", "voice": "lluc", "text": "Comencem pels problemes. El primer és la pèrdua de superfície: al llarg dels segles, l'expansió dels arrossars ha reduït el llac a una part xicoteta del que era. El segon és l'eutrofització, és a dir, l'excés de nutrients en l'aigua, que provoca la proliferació d'algues microscòpiques i li dona un color verd intens que impedix el pas de la llum. Com a conseqüència, les plantes aquàtiques del fons han desaparegut gairebé del tot, i amb elles moltes espècies de peixos autòctons."}, {"speaker": "Ponent", "voice": "lluc", "text": "Quines en són les causes? N'hi ha tres de principals. En primer lloc, la reducció de l'aigua que arriba del Xúquer i del Túria, a causa de les sequeres i de l'augment del consum agrícola i urbà. En segon lloc, els abocaments d'aigües residuals mal depurades i dels fertilitzants que arriben dels camps. I, en tercer lloc, el canvi climàtic: l'augment de la temperatura accelera l'evaporació i afavorix el creixement de les algues. Cal remarcar que estes causes no actuen per separat, sinó que es reforcen les unes a les altres."}, {"speaker": "Ponent", "voice": "lluc", "text": "Passem, per a acabar, a les solucions. La primera és garantir un cabal ecològic, és a dir, una quantitat mínima d'aigua que arribe al llac cada any i que estiga fixada per llei. La segona és millorar les depuradores i crear filtres verds: zones humides artificials on les plantes netegen l'aigua de manera natural abans que arribe al llac. I la tercera és fer partícips els llauradors: si s'apliquen menys fertilitzants i es coordinen les inundacions dels arrossars, tots hi guanyem. En resum, l'Albufera no té un únic problema, sinó una suma de problemes, i només una resposta conjunta podrà salvar-la. Moltes gràcies per la vostra atenció."}]}, "exercises": [{"q": "Escolta la conferència i pren apunts seguint-ne l'estructura (problemes, causes i solucions). Després, a partir dels teus apunts, redacta un resum per a la revista de l'associació ecologista de la qual formes part, que explique l'estat de l'Albufera i les propostes del ponent. Organitza el text en paràgrafs i usa connectors que marquen l'ordre de les idees i les relacions de causa i conseqüència.", "w": {"min_words": 150, "max_words": 180}}]}, {"passage": {"media": "audio", "title": "Conferència: les ciutats davant de la calor extrema", "lines": [{"speaker": "Ponent", "voice": "gina", "text": "Bon dia a tothom. Hui parlaré d'un fenomen que tots hem patit en els últims estius: la calor extrema a les ciutats. Primer explicaré què és l'efecte illa de calor; en segon lloc, quins efectes té sobre la salut; i, per últim, presentaré tres estratègies que ja s'apliquen en diverses ciutats europees i que podríem adoptar ací."}, {"speaker": "Ponent", "voice": "gina", "text": "L'efecte illa de calor consistix en el fet que el centre d'una ciutat pot estar fins a cinc o sis graus més calent que els camps dels voltants, sobretot de nit. Per què passa? Perquè l'asfalt i el formigó absorbixen la calor durant el dia i l'alliberen lentament quan es pon el sol; a més, els aparells d'aire condicionat expulsen aire calent al carrer, i la falta d'arbres impedix que l'ambient es refresque. El resultat són les anomenades nits tropicals, en què la temperatura no baixa de vint graus, i, cada vegada més sovint, les nits tòrrides, en què no baixa de vint-i-cinc."}, {"speaker": "Ponent", "voice": "gina", "text": "Les conseqüències per a la salut són greus. Dormir malament diverses nits seguides afecta el cor i el sistema nerviós, i les persones majors, els xiquets i les persones amb malalties cròniques són les més vulnerables. Cal tindre en compte, a més, que no tots els barris patixen igual: els de rendes més baixes solen tindre menys zones verdes, cases pitjor aïllades i menys accés a l'aire condicionat. La calor, per tant, és també una qüestió de desigualtat."}, {"speaker": "Ponent", "voice": "gina", "text": "Quines solucions tenim? La primera és naturalitzar la ciutat: plantar arbres d'ombra, convertir els patis escolars d'asfalt en espais verds i recuperar fonts i làmines d'aigua. La segona és crear una xarxa de refugis climàtics, és a dir, edificis públics, com biblioteques o centres cívics, que obrin en horari ampliat i on qualsevol persona puga refrescar-se gratuïtament. I la tercera és rehabilitar els habitatges amb aïllament tèrmic i para-sols, començant pels barris més vulnerables. Cap d'estes mesures no és suficient per si sola, però combinades poden reduir notablement els danys de la calor sobre la salut. Moltes gràcies."}]}, "exercises": [{"q": "Assistixes a esta conferència en representació de la teua associació de veïns. Pren apunts dels punts que consideres importants i, a partir d'ells, redacta un informe resum per a la junta: explica què és l'efecte illa de calor i per què es produïx, quins col·lectius en patixen més les conseqüències i quines de les estratègies proposades caldria demanar a l'Ajuntament per al vostre barri, amb una justificació de la tria.", "w": {"min_words": 200, "max_words": 250}}]}]},
  {"id": "2bd44698-01f6-5797-8144-57ea10df8a09", "category": "expressio_oral", "type": "b2_eo_exposicio", "sort_order": 1, "title": "Exposició oral", "name": "Defendre un projecte davant del jurat de Beatriu", "content": "Presenta un projecte de manera clara i estructurada, subratlla'n els punts importants i s'aparta del guió per a respondre preguntes inesperades del públic.", "icon": "🎤", "color": "#C8E6C9", "metadata": {"character": "Beatriu, presidenta del jurat d'unes subvencions culturals", "voice": "gina", "initial_prompt": "Bon dia i benvinguda a la fase final de les ajudes Comarques Vives. Disposa d'uns minuts per a exposar el seu projecte davant del jurat. Després li farem preguntes, i l'avise que algunes no les tindrà previstes. Comence quan vulga.", "objectius": ["Presenta el projecte amb una estructura clara i destaca'n els punts forts amb exemples i dades.", "Respon amb fluïdesa a les preguntes inesperades, encara que t'obliguen a apartar-te del guió.", "Defén la viabilitat del projecte davant de les objeccions i reconeix-ne els punts febles sense perdre convicció.", "Mantín un registre formal i adequat a un jurat durant tota l'exposició.", "Tanca l'exposició amb una síntesi convincent del valor del projecte."], "prompt": "Ets Beatriu Sanchis, presidenta del jurat de les ajudes Comarques Vives, que la Diputació convoca per a projectes culturals i socials en pobles de menys de cinc mil habitants. Tens uns cinquanta anys, ets exigent i directa, però justa, i tractes l'aprenent de vosté. Hi ha 40.000 euros per a repartir entre tres projectes i n'hi ha dotze de finalistes. L'aprenent ha de presentar el seu projecte; si no en porta cap de pensat, proposa-li'n un: recuperar l'antic cinema de Benissoda com a espai cultural, un festival de música en masos abandonats de l'Alt Maestrat o una xarxa de biblioteques ambulants a la Vall d'Albaida. Al principi, deixa'l parlar i limita't a assentir o a demanar-li breument que concrete. Després fes-li preguntes que el facen eixir del guió, una per torn: què passarà quan s'acabe la subvenció; per què el poble necessita això i no, per exemple, un consultori mèdic millor; què faria si només li donaren la meitat dels diners; com pensa implicar els veïns més majors, que desconfien de les novetats. Interromp-lo una vegada amb una notícia que l'obligue a improvisar: acabes de saber que un altre finalista presenta un projecte molt semblant en el poble del costat, i li demanes què aporta el seu de diferent. Si alguna resposta és vaga, insistix amb educació («Concrete, per favor», «Això no respon la meua pregunta»). Al final, demana-li que resumisca en tres frases per què el jurat hauria de triar el seu projecte i acomiada't amb una valoració breu i professional."}},
  {"id": "c7e349bb-2409-5d85-9260-3560ec138580", "category": "expressio_oral", "type": "b2_eo_debat", "sort_order": 2, "title": "Debat d'actualitat", "name": "Debatre sobre el turisme amb Andreu", "content": "Argumenta amb convicció una postura sobre un tema d'actualitat, rebat els arguments contraris i matisa les seues opinions.", "icon": "⚖️", "color": "#FFE0B2", "metadata": {"character": "Andreu, empresari hoteler i tertulià d'una ràdio local", "voice": "lluc", "initial_prompt": "Bona vesprada i benvinguts al debat de Ràdio Marina. Hui parlem d'un tema que crema: l'Ajuntament vol limitar els pisos turístics i cobrar una taxa a cada visitant. Jo ho tinc clar: seria tirar-nos pedres a la nostra pròpia teulada. Però abans, vosté què en pensa?", "objectius": ["Exposa la teua postura amb precisió i justifica-la amb arguments i exemples concrets.", "Rebat els arguments d'Andreu sense perdre el to respectuós.", "Matisa la teua opinió quan calga i reconeix allò que consideres raonable de l'altra postura.", "Reacciona amb seguretat a les dades i als casos que Andreu porta al debat.", "Pren el torn de paraula quan convinga i tanca el debat amb una conclusió ferma."], "prompt": "Ets Andreu Miralles, propietari de dos hotels a la Vila Joiosa i tertulià habitual de Ràdio Marina. Tens uns cinquanta-cinc anys, parles amb seguretat, ets hàbil amb la retòrica i t'agrada interrompre un poc. Participes en un debat sobre la proposta municipal de limitar les llicències de pisos turístics en el centre històric i d'implantar una taxa de dos euros per persona i nit. Defén sempre la postura contrària a la de l'aprenent: si està a favor de limitar el turisme, tu defens que el turisme dona de menjar a mitja comarca, que la taxa espantarà les famílies i que el problema de l'habitatge el causen la falta de construcció i la burocràcia; si està en contra, defén tu els límits: els veïns del barri del Fondo ja no poden pagar el lloguer, l'escola ha perdut alumnes i les botigues de tota la vida s'han convertit en tendes de records. Porta arguments propis perquè hi haja de reaccionar: una enquesta diu que el 60 % dels negocis de la platja depenen del turisme estranger; a Altea han posat la taxa i, segons tu, han perdut reserves (o, segons el cas, han recaptat prou per a arreglar el passeig); una veïna de huitanta anys ha hagut de deixar el pis on vivia des de sempre. Rebat cada argument de l'aprenent, demana-li dades o exemples quan generalitze, i posa'l a prova amb preguntes incòmodes («I vosté què li diria a un cambrer que es queda sense faena?»). Si l'aprenent matisa o fa una proposta intermèdia, reconeix-ho, però no canvies de postura del tot. Tracta'l de vosté, amb un to viu però respectuós. Al final, com a moderador improvisat, demana-li una conclusió de trenta segons."}},
  {"id": "7599c5d8-4a21-5136-8aa9-bbd1efce6903", "category": "expressio_oral", "type": "b2_eo_experiencies", "sort_order": 3, "title": "Compartir experiències", "name": "Una notícia important per a Marta, la teua germana", "content": "Comunica una experiència important amb diferents graus d'emoció, en subratlla la importància personal i reacciona a les notícies i opinions de l'altra persona.", "icon": "💬", "color": "#B2EBF2", "metadata": {"character": "Marta, la germana major de l'aprenent", "voice": "gina", "initial_prompt": "Ei, quina cara que portes! Quin missatge més misteriós m'has enviat: que tens una cosa important per a contar-me. Seu, seu, que he fet café. Què ha passat?", "objectius": ["Conta una experiència o una decisió important i explica per què té tanta importància per a tu.", "Expressa diferents graus d'emoció (il·lusió, dubte, por, alleujament, nostàlgia) i matisa-les.", "Respon als dubtes i a les objeccions de Marta i defén la teua decisió.", "Reacciona a les notícies que et conta Marta amb empatia i amb comentaris adequats.", "Tanca la conversa de manera natural, amb un compromís o un pla compartit."], "prompt": "Ets Marta, la germana major de l'aprenent, de trenta-huit anys. Viviu tots dos a València i esteu molt units, encara que ets un poc protectora i sovint dubtes de les decisions arriscades. L'aprenent t'ha dit que té una notícia important. Deixa que l'explique; si no sap què contar, suggerix-li alguna possibilitat (li han oferit una faena a Brussel·les, deixa la faena fixa per a muntar una cooperativa, s'ha quedat la casa dels avis a Morella, ha decidit tornar a estudiar). Reacciona primer amb sorpresa i després amb preguntes que el porten a explicar per què és tan important per a ell: què sent, des de quan ho pensa, què li fa por, què perd i què guanya. Mostra alguna reticència («I la mare, ho sap?», «No és massa arriscat ara?») perquè haja de defendre la decisió amb arguments i emoció. Conta també les teues notícies perquè hi haja de reaccionar: estàs embarassada del segon fill, però no ho has dit encara a ningú; a la faena t'han proposat un ascens que t'obligaria a viatjar molt; i el pare ha tornat a tindre problemes de memòria i estàs preocupada. Alterna moments d'humor, de tendresa i de preocupació. Parla en registre informal i familiar, amb expressions com «xe», «au», «ostres» o «mira que...». Al final, proposa-li un pla per a celebrar-ho o per a parlar-ho amb la família."}},
  {"id": "b38707fc-f3b6-5317-816c-44f3d804b214", "category": "expressio_oral", "type": "b2_eo_reunio", "sort_order": 4, "title": "Reunions formals", "name": "Consell escolar amb la directora Elena", "content": "Intervé en una reunió formal: pren el torn de paraula, presenta i defén propostes, respon a les objeccions i contribuïx a arribar a acords.", "icon": "🏛️", "color": "#D1C4E9", "metadata": {"character": "Elena, directora d'un institut i presidenta del consell escolar", "voice": "gina", "initial_prompt": "Bona vesprada a tots i totes. Comencem la sessió extraordinària del consell escolar. El primer punt de l'ordre del dia és la proposta de prohibir els mòbils en tot el recinte del centre. Té la paraula el representant de les famílies.", "objectius": ["Demana i pren el torn de paraula amb les fórmules adequades d'una reunió formal.", "Presenta una postura o una proposta concreta i argumenta-la amb exemples.", "Respon a les objeccions de la directora i dels altres membres del consell, i matisa la teua proposta si cal.", "Negocia un acord i resumix-lo perquè conste en l'acta.", "Mantín el registre formal durant tota la reunió."], "prompt": "Ets Elena Ferrer, directora de l'IES Les Moreres d'Alzira i presidenta del consell escolar. Tens uns cinquanta anys, ets seriosa, organitzada i molt pendent dels torns de paraula i del temps. L'aprenent hi participa com a representant de les famílies. El primer punt de l'ordre del dia és la proposta de prohibir els mòbils en tot el recinte, també en el pati; el segon, l'organització del viatge de fi de curs, que enguany costa 450 euros per alumne. Condueix la reunió amb fórmules formals («Té la paraula...», «Per al·lusions...», «Passem a votació», «Que conste en acta»). Fes de veu dels altres membres del consell perquè l'aprenent haja de reaccionar: el representant del professorat, Vicent, demana la prohibició total perquè hi ha hagut casos de ciberassetjament gravat en el pati; la representant de l'alumnat, Aina, diu que el mòbil és l'únic mitjà per a avisar les famílies i que prohibir-lo és tractar-los com a xiquets; i l'Ajuntament avisa que no pot pagar taquilles per a guardar-los. En el segon punt, planteja que moltes famílies no poden pagar el viatge i que, si no va tot l'alumnat, el centre es planteja suspendre'l. Demana a l'aprenent propostes concretes (per exemple: mòbils en bosses tancades, zones o horaris permesos, un fons de solidaritat, activitats per a recaptar diners, un destí més pròxim). Si s'allarga massa o parla fora de torn, recorda-li amb educació que ha de demanar la paraula. Al final de cada punt, demana-li que formule l'acord en una frase perquè conste en l'acta, i tanca la sessió."}},
  {"id": "f12474ad-2f82-5f2a-abe8-0eeec1ff0d7e", "category": "expressio_oral", "type": "b2_eo_entrevista", "sort_order": 5, "title": "Entrevistes de treball", "name": "Entrevista de selecció amb Jordi", "content": "Respon en registre formal a les preguntes difícils d'una entrevista de treball, defén la seua candidatura i reacciona a situacions imprevistes.", "icon": "💼", "color": "#FFCDD2", "metadata": {"character": "Jordi, responsable de recursos humans d'una cooperativa", "voice": "lluc", "initial_prompt": "Bon dia, passe i seja, per favor. Em dic Jordi Llorens, el responsable de selecció. Ja he llegit el seu currículum, però m'agradaria que me'l contara vosté: per què creu que és la persona que busquem?", "objectius": ["Presenta la teua trajectòria i relaciona-la amb el lloc de treball de manera convincent.", "Respon a les preguntes difícils o incòmodes amb seguretat, sinceritat i tacte.", "Posa exemples concrets d'experiències per a demostrar les teues capacitats.", "Mantín un registre formal i adequat a una entrevista de treball.", "Fes alguna pregunta pertinent sobre el lloc i acomiada't correctament."], "prompt": "Ets Jordi Llorens, responsable de recursos humans de Terra Viva, una cooperativa agroalimentària de la Ribera que exporta cítrics i productes ecològics i té uns cent cinquanta treballadors. Tens uns quaranta-cinc anys, ets cordial però exigent i, de tant en tant, fas preguntes per a veure com reacciona la persona sota pressió. Tracta l'aprenent de vosté. El lloc que s'oferix és de coordinador o coordinadora de projectes, amb un equip de cinc persones; si l'aprenent prefereix un altre perfil (comunicació, administració, atenció a socis, comercial), adapta-t'hi. Fes les preguntes una per torn i reacciona a les respostes abans de passar a la següent. Inclou-hi preguntes difícils: per què va deixar la seua última faena; per què hi ha un buit de huit mesos en el currículum; quin és el seu pitjor defecte, i que no diga «sóc massa perfeccionista» (la resposta típica); que conte un conflicte amb un company i com el va resoldre; què faria si un membre de l'equip no complira els terminis de manera reiterada. Planteja també una situació imprevista: en mig de l'entrevista, li dius que el lloc implica viatjar a fires internacionals una setmana al mes, cosa que no posava l'oferta, i li demanes si continua interessat. Si una resposta és genèrica, demana-li un exemple concret. Pregunta-li quines expectatives salarials té i, si dona una xifra, digues que està per damunt del que oferiu, perquè haja de negociar. Al final, convida'l a fer preguntes, explica-li els passos següents del procés de selecció i acomiada't formalment."}}
  ]$data$;
  pautes text := E'\n\n' ||
    'Pautes: l''aprenent prepara el nivell B2 (avançat) de la JQCV i practica l''expressió i interacció orals. Parla en valencià general (normativa de l''AVL), amb un registre adaptat a la situació, fluid i natural, i un vocabulari ric i precís propi del B2: usa connectors variats (no obstant això, per contra, és a dir, pel que fa a, tot i que, de manera que), oracions subordinades complexes i alguna frase feta, sempre de manera clara. ' ||
    'Fes torns breus (màxim 3-4 frases) amb una o dues preguntes per torn. Demana-li que argumente, que matise, que done exemples i que reaccione als teus arguments; planteja-li objeccions o preguntes inesperades perquè haja d''improvisar. Si respon amb frases molt curtes, repregunta perquè s''allargue. ' ||
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
    -- Xats: el system_prompt és el del personatge, les pautes del B2 i els objectius.
    m := coalesce(r->'metadata', '{}');
    IF m ? 'prompt' THEN
      m := (m - 'prompt') || jsonb_build_object('system_prompt',
        (m->>'prompt') || pautes ||
        (SELECT string_agg(o, ' | ') FROM jsonb_array_elements_text(m->'objectius') AS o) ||
        ' Quan els haja complit tots, tanca la conversa amb naturalitat i acomiada''t.');
    END IF;

    INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
    VALUES (
      rid, r->>'name', r->>'type', r->>'category', r->>'content', 'B2', 15, (r->>'sort_order')::smallint,
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
      -- Conserva la lliçó fixa («Aprendre lliçó»), si una migració posterior n'hi afig.
      metadata = EXCLUDED.metadata || jsonb_strip_nulls(jsonb_build_object('lesson', resources.metadata -> 'lesson'));

    DELETE FROM public.practice_exercises WHERE resource_id = rid AND level = 'B2';
    DELETE FROM public.practice_passages WHERE resource_id = rid AND level = 'B2';

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
          rid, 'B2', ppos, b->'passage'->>'media', b->'passage'->>'title', b->'passage'->'lines',
          CASE WHEN b->'passage'->>'media' = 'audio' THEN format('/audio/practice/%s-b2-%s.wav', r->>'type', ppos) END
        )
        RETURNING id INTO pid;
      END IF;

      FOR e IN SELECT * FROM jsonb_array_elements(b->'exercises') LOOP
        epos := epos + 1;
        INSERT INTO public.practice_exercises (resource_id, level, position, passage_id, kind, prompt, options, answers, task, explanation)
        VALUES (
          rid, 'B2', epos, pid,
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

-- ============================================================
-- Origen: 20261013170000_exam_b2_oct2025.sql
-- ============================================================
-- Examen interactiu B2 de la JQCV (octubre 2025) com a recurs de category 'examen'.
-- Contingut a metadata.exam, amb les cinc àrees del B2 i la puntuació oficial de la guia de la
-- prova (comprensió oral 8 i 12 punts per encert; comprensió escrita 3,3 i 8,5; estructures 5 i 5;
-- mínim del 40 % en cada àrea i del 50 % en l'oral). Les respostes són les de la plantilla
-- oficial que inclou el quadern. Àudio de comprensió oral a url, convertit a MP3 des de l'oficial
-- (frontend/public/audio/Audio_B2_oct2025.mp3). Font: https://jqcv.gva.es/documents/161863165/165492631/B2+octubre+2025.pdf/526dc3ac-9858-b9c6-3564-270760306faa

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "2d86e7f1-2873-552e-8ab3-46cb4668cd03",
 "name": "Simulacre B2: octubre 2025",
 "type": "jqcv_b2_oct2025",
 "category": "examen",
 "difficulty": "B2",
 "xp_earned": 40,
 "url": "/audio/Audio_B2_oct2025.mp3",
 "content": "Examen oficial B2 de la JQCV (octubre 2025): comprensió oral i escrita i estructures lingüístiques autocorregibles, dos redaccions i pràctica oral.",
 "metadata": {
  "icon": "🌡️",
  "color": "#FFCC80",
  "exam_body": "JQCV",
  "certificate_level": "B2",
  "exam": {
   "level": "B2",
   "session": "Octubre 2025",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492631/B2+octubre+2025.pdf/526dc3ac-9858-b9c6-3564-270760306faa",
   "audio_source_url": "https://jqcv.gva.es/documents/161863165/167041107/NIVELL_B2_48KH_24BITS.wav/5a019c6a-b356-2a5a-369d-01c2b1311c71",
   "pass_rule": "Per a ser APTE cal una puntuació global mínima de 60 sobre 100. Les àrees valen un 20 % (comprensió oral), un 20 % (comprensió escrita), un 15 % (estructures lingüístiques), un 20 % (expressió escrita) i un 25 % (expressió oral), i en cada una cal arribar al mínim: el 40 % en les quatre primeres i el 50 % en l'expressió oral.",
   "areas": [
    {
     "n": 1,
     "title": "Comprensió oral",
     "weight": 20,
     "duration": "20 minuts",
     "audio": true,
     "intro": "A continuació escoltaràs dos àudios. Els escoltaràs dos vegades, amb una pausa d'un minut entre cada audició, perquè assegures les respostes. Només hi ha una resposta correcta per a cada enunciat.",
     "scoring": {
      "points_per_exercise": {
       "1": 8,
       "2": 12
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 1,
       "kind": "choice",
       "instructions": "A continuació escoltaràs una entrevista a Clotilde Leguil, professora del Departament de Psicoanàlisi de la Universitat de París 8. Llig les preguntes i tria l'opció correcta en cada cas. Només hi ha una resposta correcta per a cada pregunta.",
       "questions": [
        {
         "n": 1,
         "prompt": "Què impulsa Clotilde Leguil a reflexionar sobre la paraula tòxic?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "La necessitat d'advertir sobre els efectes físics de les substàncies tòxiques."
          },
          {
           "key": "b",
           "text": "L'observació que el terme ha passat a descriure formes de malestar en l'àmbit relacional."
          },
          {
           "key": "c",
           "text": "La voluntat d'analitzar com els mitjans utilitzen terminologia científica i arguments d'autoritat."
          }
         ]
        },
        {
         "n": 2,
         "prompt": "Segons l'autora, quin és el sentit profund de la metàfora de la fletxa tòxica?",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Representa la crítica social com a recurs per a protegir-se de l'altre."
          },
          {
           "key": "b",
           "text": "Evoca com l'entorn laboral pot generar dany emocional sense voler."
          },
          {
           "key": "c",
           "text": "Expressa com determinats discursos externs ens travessen i generen patiment intern."
          }
         ]
        },
        {
         "n": 3,
         "prompt": "La psicoanalista afirma que la toxicitat...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "pot estar dins de nosaltres sense que ens n'adonem."
          },
          {
           "key": "b",
           "text": "és una sensació de benestar emocional."
          },
          {
           "key": "c",
           "text": "és un maltractament personal a u mateix."
          }
         ]
        },
        {
         "n": 4,
         "prompt": "Per què és tan difícil eixir de la toxicitat?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Perquè és una forma d'evitar-nos problemes."
          },
          {
           "key": "b",
           "text": "Perquè acabem interioritzant-la."
          },
          {
           "key": "c",
           "text": "Perquè no ens adonem que està en el nostre cos."
          }
         ]
        },
        {
         "n": 5,
         "prompt": "Quina proposta fa Clotilde Leguil per a superar la lògica de la toxicitat?",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "Reconnectar amb un desig que transcendix la satisfacció personal immediata."
          },
          {
           "key": "b",
           "text": "Substituir la toxicitat per hàbits saludables i relacions positives amb l'altra persona."
          },
          {
           "key": "c",
           "text": "Trobar límits socials clars per a evitar l'exposició al malestar extern."
          }
         ]
        }
       ]
      },
      {
       "n": 2,
       "kind": "binary",
       "instructions": "Escoltaràs uns consells per a estudiar de manera eficient. Relaciona els enunciats amb els consells i ordena'ls en el mateix orde en què apareixen en l'àudio. Marca «No surt» en els dos enunciats que no corresponen a cap consell i numera la resta de l'1 al 5.",
       "options": [
        {
         "key": "1",
         "text": "1"
        },
        {
         "key": "2",
         "text": "2"
        },
        {
         "key": "3",
         "text": "3"
        },
        {
         "key": "4",
         "text": "4"
        },
        {
         "key": "5",
         "text": "5"
        },
        {
         "key": "x",
         "text": "No surt"
        }
       ],
       "questions": [
        {
         "n": 6,
         "prompt": "No dubtes a sol·licitar ajuda a professionals, amistats o familiars si en algun moment en necessites.",
         "answer": "5"
        },
        {
         "n": 7,
         "prompt": "Alimentar-se diàriament amb proteïnes i hidrats contribuirà a mantindre't despert i cansar-te menys.",
         "answer": "x",
         "scored": false
        },
        {
         "n": 8,
         "prompt": "Té igual que estudies en la biblioteca o en casa, però mantín sempre les condicions adequades d'estudi.",
         "answer": "3"
        },
        {
         "n": 9,
         "prompt": "Assistir a classe et permetrà plantejar preguntes als professors que t'ajudaran a resoldre dubtes.",
         "answer": "1"
        },
        {
         "n": 10,
         "prompt": "Gravar-te per a poder escoltar-te després és una tècnica d'estudi que et pot resultar efectiva.",
         "answer": "4"
        },
        {
         "n": 11,
         "prompt": "Dedicar al dia sempre les mateixes hores d'estudi ens ajudarà a seguir una rutina i facilitarà la concentració.",
         "answer": "x",
         "scored": false
        },
        {
         "n": 12,
         "prompt": "Utilitza ferramentes digitals per a confeccionar un horari amb descansos i respectar-lo rigorosament.",
         "answer": "2"
        }
       ]
      }
     ]
    },
    {
     "n": 2,
     "title": "Comprensió escrita",
     "weight": 20,
     "duration": "2 h 10 min (amb les àrees 3 i 4)",
     "scoring": {
      "points_per_exercise": {
       "3": 3.3,
       "4": 8.5
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 3,
       "kind": "match",
       "instructions": "Llig atentament el text següent i completa'l amb les propostes de la graella. Tin en compte que hi ha tres propostes que no has d'utilitzar.",
       "reading": {
        "title": "El misteri de les llàgrimes: per què plorem quan estem tristos?",
        "paragraphs": [
         "Plorar és una experiència humana per excel·lència. Altres espècies produïxen llàgrimes, però les nostres són les úniques que, segons els científics, emergixen (13) ______ no només per a lubricar i protegir els globus oculars, sinó també per a expressar emocions, com després de patir una ruptura sentimental, en les cerimònies o mentres veem un drama en el cine o en la televisió. Encara que són de les poques coses que ens fan (14) ______ humans, en molts sentits, les llàgrimes emocionals continuen sent un enigma. Una investigació ha revelat que les nostres emocions són encara més complicades del que els neurocientífics creien: no existix una zona en el cervell (15) ______ dels sentiments de tristor o ira, per exemple.",
         "Les causes canvien amb l'edat",
         "Durant els primers anys de la nostra vida, plorem sobretot per experiències pròpies: una rascada en el genoll, una picada d'abella o un gelat que ens ha caigut en terra. Això comença a canviar a (16) ______ que ens fem majors i ens desenvolupem més emocionalment i socialment. Plorem menys com a resposta al dolor (17) ______ i més per les nostres (18) ______ emocionals per altres persones. “El teu món es fa més gran quan hi ha persones que es tornen més importants per a tu”, diu Vingerhoets.",
         "Una de les raons més (19) ______ per a plorar és l'absència o la pèrdua d'un ser estimat, tant si el trobem a faltar quan no estem en casa, com si patim una ruptura amorosa durant l'adolescència o estem passant un (20) ______ per una mort a qualsevol edat. També plorem per les penes dels altres. Estes llàgrimes d'empatia poden produir-se perquè ens imaginem en el (21) ______ d'altres persones, siguen amics, desconeguts o inclús personatges de ficció.",
         "Els beneficis de plorar",
         "Entre els investigadors, (22) ______ el debat més antic és trobar per quin motiu plorar fa que les persones se senten millor. En un dels estudis més importants sobre este tema, es va preguntar a milers de persones de tot el món sobre l'última volta que havien vessat llàgrimes. Més de la mitat van dir que s'havien sentit millor, quasi el 40 % no va notar cap diferència i el 10 % va dir sentir-se pitjor. Plorar, (23) ______ quan s'està a soles, pot servir com una autoteràpia.",
         "En situacions socials, el factor que més influïx en com et sents després de plorar és com reaccionen les persones que et rodegen. Les persones que reben una resposta de suport, com un abraç o la validació dels seus sentiments, tendixen a sentir-se millor, mentres que, si les llàgrimes són rebudes amb ira o burla, les persones són més propenses a sentir-se pitjor. Això té sentit, ja que els experts creuen que el principal (24) ______ de la llàgrima, independentment de l'edat, és comunicar patiment als altres."
        ]
       },
       "options_title": "Propostes",
       "options": [
        {
         "key": "a",
         "text": "mesura"
        },
        {
         "key": "b",
         "text": "físic"
        },
        {
         "key": "c",
         "text": "comuns"
        },
        {
         "key": "d",
         "text": "dol"
        },
        {
         "key": "e",
         "text": "potser"
        },
        {
         "key": "f",
         "text": "espiritual"
        },
        {
         "key": "g",
         "text": "propòsit"
        },
        {
         "key": "h",
         "text": "lloc"
        },
        {
         "key": "i",
         "text": "sobretot"
        },
        {
         "key": "j",
         "text": "sistemàticament"
        },
        {
         "key": "k",
         "text": "distintivament"
        },
        {
         "key": "l",
         "text": "connexions"
        },
        {
         "key": "m",
         "text": "responsable"
        },
        {
         "key": "n",
         "text": "mida"
        },
        {
         "key": "o",
         "text": "comunes"
        }
       ],
       "questions": [
        {
         "n": 13,
         "prompt": "Buit 13",
         "answer": "j"
        },
        {
         "n": 14,
         "prompt": "Buit 14",
         "answer": "k"
        },
        {
         "n": 15,
         "prompt": "Buit 15",
         "answer": "m"
        },
        {
         "n": 16,
         "prompt": "Buit 16",
         "answer": "a"
        },
        {
         "n": 17,
         "prompt": "Buit 17",
         "answer": "b"
        },
        {
         "n": 18,
         "prompt": "Buit 18",
         "answer": "l"
        },
        {
         "n": 19,
         "prompt": "Buit 19",
         "answer": "o"
        },
        {
         "n": 20,
         "prompt": "Buit 20",
         "answer": "d"
        },
        {
         "n": 21,
         "prompt": "Buit 21",
         "answer": "h"
        },
        {
         "n": 22,
         "prompt": "Buit 22",
         "answer": "e"
        },
        {
         "n": 23,
         "prompt": "Buit 23",
         "answer": "i"
        },
        {
         "n": 24,
         "prompt": "Buit 24",
         "answer": "g"
        }
       ]
      },
      {
       "n": 4,
       "kind": "match",
       "instructions": "A continuació es descriuen set aplicacions informàtiques. Relaciona-les amb els enunciats. Hi ha tres enunciats que no corresponen a cap d'elles.",
       "options_title": "Enunciats",
       "options": [
        {
         "key": "a",
         "text": "Esta ferramenta és útil per a fer bons dissenys, però també et pot ajudar a preparar-te per als exàmens."
        },
        {
         "key": "b",
         "text": "Amb esta ferramenta pots crear fòrums i espais de debat per a fomentar la interacció escrita entre l'alumnat."
        },
        {
         "key": "c",
         "text": "És una ferramenta de comunicació ideal per a persones amb trastorns del llenguatge o dificultats de parla."
        },
        {
         "key": "d",
         "text": "Si eres ràpid a l'hora de respondre i encertes, obtindràs més punts i, per tant, la possibilitat de guanyar als companys o amics."
        },
        {
         "key": "e",
         "text": "És una aplicació que permet reforçar continguts escolars, especialment en llengües, a través d'activitats interactives."
        },
        {
         "key": "f",
         "text": "Es tracta d'una ferramenta de càlcul en format web i aplicació que et permetrà interactuar amb alumnes."
        },
        {
         "key": "g",
         "text": "És una ferramenta digital que facilita el seguiment de l'activitat de l'alumnat i la gestió de tasques dins de l'aula."
        },
        {
         "key": "h",
         "text": "Si no tens habilitats tecnològiques, esta ferramenta et permetrà crear ràpidament dissenys visuals en diversos formats."
        },
        {
         "key": "i",
         "text": "És una aplicació sense cost; l'idioma pot ser una barrera, però és fàcil de controlar."
        },
        {
         "key": "j",
         "text": "Amb esta aplicació podràs competir amb els altres a través de preguntes interactives que apareixen en vídeos."
        }
       ],
       "questions": [
        {
         "n": 25,
         "prompt": "Aloud és un programari que servix per a comunicar-se de manera eficaç i desenrotllar el llenguatge, òptim per a aquelles persones que no poden parlar o tenen dificultats en la parla. Augmenta les possibilitats d'interacció i comunicació de qui l'utilitza, tant en persones que ja usen símbols i volen desenrotllar el llenguatge com en aquelles que ja poden utilitzar el text i escriure. Este programa fa possible una interacció cara a cara, com a distància, independentment del nivell de llenguatge, ja que oferix una infinitat d'opcions avançades i vocabularis per a tots els nivells.",
         "answer": "c"
        },
        {
         "n": 26,
         "prompt": "Estapp és una ferramenta de disseny gràfic en línia que oferix als usuaris la possibilitat de crear fàcilment una àmplia varietat de materials visuals de manera intuïtiva i sense necessitat d'habilitats de disseny avançades. Esta aplicació web, també presentada en format App, proporciona plantilles personalitzables i una interfície d'usuari amigable, cosa que la convertix en una opció popular per a aquells que busquen dissenyar gràfics de manera ràpida i eficient. Amb Estapp, els usuaris poden crear una àmplia gamma d'elements visuals, com ara presentacions, cartells, targetes de presentació, publicacions en xarxes socials o fullets, entre altres.",
         "answer": "h"
        },
        {
         "n": 27,
         "prompt": "Ribcloud és una aplicació gratuïta educativa basada en el núvol que facilita la creació de lliçons interactives i la participació activa d'estudiants. Els professionals de l'educació que es creen un compte podran dissenyar presentacions multimèdia que inclouen qüestionaris, enquestes i diverses activitats, i promoure així un aprenentatge col·laboratiu i dinàmic. L'alumnat, en canvi, no necessita crear-se cap perfil i pot accedir al contingut a través d'un codi generat per l'autor del material. Es tracta també d'una ferramenta que només es presenta en anglés, però no es necessiten coneixements amplis de l'idioma ja que és prou intuïtiva.",
         "answer": "i"
        },
        {
         "n": 28,
         "prompt": "Mattex es presenta en format web i aplicació. És un programari de matemàtiques dinàmiques que abasta totes les àrees escolars de les matemàtiques amb enfocament de problemes de matemàtiques, gràfiques de funcions i equacions, combinacions amb geometria interactiva. Permet guardar i compartir els resultats personalitzats de l'alumnat, així com fer-ne un seguiment personalitzat. Entre les seues funcions destaquen la possibilitat de realitzar derivades, integrals, línies corbes amb gràfics, equacions, divisions... Una ferramenta fantàstica per a l'ús diari en l'aula i perquè l'alumnat faça pràctiques en casa amb l'ajuda de la família.",
         "answer": "f"
        },
        {
         "n": 29,
         "prompt": "La ferramenta Sap només es presenta en línia, i és una plataforma interactiva d'aprenentatge basada en jocs que s'ha tornat popular en entorns no només educatius sinó també empresarials. Esta aplicació proporciona una manera lúdica i participativa d'avaluar el coneixement. La característica central de Sap és la creació i realització de qüestionaris, enquestes i avaluacions interactives, coneguts com a “sabers”. Els usuaris, que poden ser estudiants, treballadors o participants en una reunió, responen a les preguntes en temps real utilitzant els seus dispositius mòbils o ordinadors. La puntuació es calcula segons la rapidesa i la precisió de les respostes, fet que crea una experiència competitiva i divertida.",
         "answer": "d"
        },
        {
         "n": 30,
         "prompt": "EnKaixa és una plataforma d'aprenentatge en línia que se centra en la creació i distribució de contingut educatiu interactiu a través de vídeos. Dissenyada principalment per a educadors i estudiants, esta aplicació web permet als docents personalitzar i millorar vídeos educatius amb elements interactius, com ara preguntes, comentaris i notes. Els usuaris d'EnKaixa poden seleccionar vídeos de diverses fonts, com YouTube o la seua pròpia biblioteca de vídeos, i després afegir capes d'interactivitat per a crear experiències d'aprenentatge més efectives. Els elements interactius poden incloure preguntes d'opció múltiple, preguntes obertes, comentaris de veu i anotacions que s'integren directament en el vídeo, i permet la participació mentres es veu el contingut.",
         "answer": "j"
        },
        {
         "n": 31,
         "prompt": "Esquemàtik és una aplicació utilitzada per a la creació de diagrames i esquemes visuals. La seua interfície permet als usuaris dissenyar diagrames de flux, organigrames, mapes mentals, diagrames de xarxes, entre altres. La ferramenta és compatible amb múltiples formats d'arxiu, cosa que facilita l'exportació i l'intercanvi dels diagrames creats. A més, permet la integració amb plataformes d'emmagatzematge en el núvol, facilitant la col·laboració en projectes en equip. Si treballes de forma cooperativa en el teu centre o la teua oficina, et facilitarà la interacció amb els companys. Però també és una bona ferramenta per a utilitzar-la com a tècnica d'estudi.",
         "answer": "a"
        }
       ]
      }
     ]
    },
    {
     "n": 3,
     "title": "Estructures lingüístiques",
     "weight": 15,
     "duration": "2 h 10 min (amb les àrees 2 i 4)",
     "scoring": {
      "points_per_exercise": {
       "5": 5,
       "6": 5
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 5,
       "kind": "choice",
       "instructions": "En el text següent s'han eliminat algunes paraules. Per a cada espai en blanc tens tres opcions de resposta. Només una és correcta. Fixa't en l'exemple (número 0).",
       "reading": {
        "title": "Quan els Reis venien de Ciutat Vella",
        "paragraphs": [
         "Ara fa 60 anys, José Verdú Sanjuan va decidir obrir una jogueteria en el centre de València. Fart d'anar amunt i (0) avall amb el material que comercialitzava, este home originari d'Ibi (l'Alcoià) pensà que havia arribat l'hora d'establir-se en un lloc fix amb un negoci estable, d'aquells que tenen horari i persiana. És així com va nàixer Moñacos, el comerç de joguets més antic de la ciutat de València.",
         "L'establiment que hui perviu és regentat per José Vicente Verdú Barrachina, membre de la tercera generació familiar. Als Verdú els corren joguets per les venes i pareixen estar equipats amb piles alcalines en lloc de músculs. (32) ______ així s'entén la tenacitat (33) ______ mantenen en marxa un negoci que ha patit com pocs les urpes del capitalisme globaliste. En primer (34) ______, a causa de la deslocalització del producte, que va passar de tindre les poblacions d'Ibi i Onil (35) ______ quilòmetre zero a tindre el punt neuràlgic de fabricació en algun racó de l'Orient Llunyà. I en segon lloc, per l'auge de les grans cadenes i el comerç digital.",
         "Siga com siga, (36) ______ València, els Reis no venien de l'Orient, sinó de Ciutat Vella. Allà acudien cada Nadal els pares, les mares, els iaios o les iaies, a comprar els regals que els més menuts (37) ______ entusiasmats el 6 de gener de bon matí. La botiga central de Moñacos era un gran basar. Ubicada al costat del Teatre Olympia i envoltada de comerços tradicionals, el xamfrà de Sant Vicent amb el carrer de les Garrigues era sinònim de diversió. Centenars de milers de valencians quedaren embadalits, en un moment o algun altre, al passar per davant de la tenda.",
         "“Ara resulta impossible competir (38) ______ les grans superfícies i les plataformes de comerç electrònic”, lamenta el propietari. “El volum de negoci no té res a vore amb el d'abans”. Per això tracten de trobar el seu nínxol de mercat en joguets de preu baix, com ara nines i peluixos de 10 o 15 euros. Productes que la gent s'estima més de vore en persona.",
         "Els marges de benefici ja estan molt ajustats. A Moñacos, cada 5 de gener els costa més que (39) ______ els comptes. Hi ha cadenes i grans magatzems que venen els joguets al mateix preu que els adquirixen ells. Una batalla que tenen perduda... “La sort és que molts clients (40) ______ són per costum, (41) ______ venien amb els pares i els iaios”, diu José Vicente. Qui millor que ell per a aconseguir-los aquell joguet que no troben perquè en altres llocs s'ha exhaurit?"
        ]
       },
       "questions": [
        {
         "n": 32,
         "prompt": "Buit 32",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "No més"
          },
          {
           "key": "b",
           "text": "Només"
          },
          {
           "key": "c",
           "text": "Soles"
          }
         ]
        },
        {
         "n": 33,
         "prompt": "Buit 33",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "amb la que"
          },
          {
           "key": "b",
           "text": "amb què"
          },
          {
           "key": "c",
           "text": "amb que"
          }
         ]
        },
        {
         "n": 34,
         "prompt": "Buit 34",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "terme"
          },
          {
           "key": "b",
           "text": "term"
          },
          {
           "key": "c",
           "text": "termini"
          }
         ]
        },
        {
         "n": 35,
         "prompt": "Buit 35",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "com a"
          },
          {
           "key": "b",
           "text": "com"
          },
          {
           "key": "c",
           "text": "com a un"
          }
         ]
        },
        {
         "n": 36,
         "prompt": "Buit 36",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "de"
          },
          {
           "key": "b",
           "text": "a"
          },
          {
           "key": "c",
           "text": "a la"
          }
         ]
        },
        {
         "n": 37,
         "prompt": "Buit 37",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "obririen"
          },
          {
           "key": "b",
           "text": "obriren"
          },
          {
           "key": "c",
           "text": "obriran"
          }
         ]
        },
        {
         "n": 38,
         "prompt": "Buit 38",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "amb"
          },
          {
           "key": "b",
           "text": "en"
          },
          {
           "key": "c",
           "text": "a"
          }
         ]
        },
        {
         "n": 39,
         "prompt": "Buit 39",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "sortiren"
          },
          {
           "key": "b",
           "text": "ixen"
          },
          {
           "key": "c",
           "text": "isquen"
          }
         ]
        },
        {
         "n": 40,
         "prompt": "Buit 40",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "ho"
          },
          {
           "key": "b",
           "text": "en"
          },
          {
           "key": "c",
           "text": "el"
          }
         ]
        },
        {
         "n": 41,
         "prompt": "Buit 41",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "perquè"
          },
          {
           "key": "b",
           "text": "per què"
          },
          {
           "key": "c",
           "text": "per que"
          }
         ]
        }
       ]
      },
      {
       "n": 6,
       "kind": "choice",
       "instructions": "En el text següent s'han eliminat algunes paraules. Per a cada espai en blanc tens tres opcions de resposta. Només una és correcta. Fixa't en l'exemple (número 0).",
       "reading": {
        "title": "Quan els egipcis van deixar de treballar",
        "paragraphs": [
         "Quan volem protestar contra una situació injusta, a sovint decidim no anar a treballar per a reivindicar-nos. Però quan va passar això per primera vegada? Per a conéixer els detalls d'aquell fet (0) insòlit cal que viatgem més de tres mil anys arrere, a l'Antic Egipte.",
         "La primera (42) ______ de la història va tindre lloc durant el regnat del faraó Ramsés III, aproximadament, en l'any 1157 abans de Crist. Vaja, que ha plogut des de llavors!",
         "En el poblat de Set-Ma'at, ―que vol dir ‘el lloc de la veritat’, i que actualment es coneix com a Deir al-Madinah,― vivien cent vint artesans molt qualificats i les seues famílies. S'encarregaven de construir i decorar les tombes magnífiques dels faraons en la Vall dels Reis. Feien la faena en secret i (43) ______ de grans (44) ______ de seguretat per a desanimar la gent a furtar.",
         "Aquella (45) ______ treballava molt bé. De fet, eren els obrers més respectats i ben pagats de tot el país del Nil. Però va arribar una època de moltes (46) ______. Els egipcis van haver de fer front a uns enemics estrangers que volien conquistar sa casa. Van aconseguir derrotar-los, però la victòria els va eixir molt cara. Per si allò no fora prou, les (47) ______ no van ser bones i el preu del menjar va apujar moltíssim.",
         "Els problemes econòmics encara es van fer més grans perquè s'acostava una (48) ______ molt assenyalada: l'any següent se celebraria que feia trenta anys que Ramsés III era el faraó. El Heb Sed era el festival més important de tots, perquè servia per a renovar la força del faraó, i ja podeu imaginar-vos que els egipcis estiraven més el braç que la mànega.",
         "Enmig d'aquella situació tan difícil, els obrers de Set-Ma'at van deixar de rebre els sacs de gra que eren part del seu (49) ______. D'allò tenien molta culpa els oficials que els (50) ______ en nom del faraó, perquè alguns eren molt corruptes. Farts que els prengueren el pèl, els obrers van deixar d'anar a treballar, i així va començar tot!",
         "I com sabem tot això? Gràcies a l'escriba Amennakht, que va explicar els fets (51) ______ en un text que va escriure."
        ]
       },
       "questions": [
        {
         "n": 42,
         "prompt": "Buit 42",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "vaga"
          },
          {
           "key": "b",
           "text": "baga"
          },
          {
           "key": "c",
           "text": "revetla"
          }
         ]
        },
        {
         "n": 43,
         "prompt": "Buit 43",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "remenats"
          },
          {
           "key": "b",
           "text": "rodejats"
          },
          {
           "key": "c",
           "text": "regirats"
          }
         ]
        },
        {
         "n": 44,
         "prompt": "Buit 44",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "mides"
          },
          {
           "key": "b",
           "text": "mesures"
          },
          {
           "key": "c",
           "text": "medides"
          }
         ]
        },
        {
         "n": 45,
         "prompt": "Buit 45",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "quadriga"
          },
          {
           "key": "b",
           "text": "gropa"
          },
          {
           "key": "c",
           "text": "colla"
          }
         ]
        },
        {
         "n": 46,
         "prompt": "Buit 46",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "angoixes"
          },
          {
           "key": "b",
           "text": "fraules"
          },
          {
           "key": "c",
           "text": "angostes"
          }
         ]
        },
        {
         "n": 47,
         "prompt": "Buit 47",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "segades"
          },
          {
           "key": "b",
           "text": "segues"
          },
          {
           "key": "c",
           "text": "collites"
          }
         ]
        },
        {
         "n": 48,
         "prompt": "Buit 48",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "data"
          },
          {
           "key": "b",
           "text": "dada"
          },
          {
           "key": "c",
           "text": "diada"
          }
         ]
        },
        {
         "n": 49,
         "prompt": "Buit 49",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "saler"
          },
          {
           "key": "b",
           "text": "saldo"
          },
          {
           "key": "c",
           "text": "sou"
          }
         ]
        },
        {
         "n": 50,
         "prompt": "Buit 50",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "demanaven"
          },
          {
           "key": "b",
           "text": "manaven"
          },
          {
           "key": "c",
           "text": "encomanaven"
          }
         ]
        },
        {
         "n": 51,
         "prompt": "Buit 51",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "fil per randa"
          },
          {
           "key": "b",
           "text": "a la babalà"
          },
          {
           "key": "c",
           "text": "a tort i a dret"
          }
         ]
        }
       ]
      }
     ]
    },
    {
     "n": 4,
     "title": "Expressió i interacció escrites",
     "weight": 20,
     "duration": "2 h 10 min (amb les àrees 2 i 3)",
     "exercises": [
      {
       "n": 7,
       "kind": "writing",
       "title": "Redacció",
       "instructions": "Tria una de les dos opcions i redacta un text que tinga entre 180 i 220 paraules.",
       "min_words": 180,
       "max_words": 220,
       "choices": [
        {
         "key": "A",
         "text": "Cada vegada més jóvens decidixen compartir la seua vida amb un animal de companyia, com gossos o gats. El gran problema arriba a l'hora de trobar un pis de lloguer a on s'accepten animals, ja que molts propietaris consideren que poden ocasionar molèsties o desperfectes en la vivenda. Tens un animal de companyia i t'està costant trobar un pis per a llogar-lo. Encara que complixes tots els requisits, els propietaris et rebutgen argumentant que tens un gat com a animal de companyia. Per això, decidixes publicar una entrada en el teu blog personal per a denunciar esta problemàtica. En el teu escrit has d'incloure els punts següents:",
         "points": [
          "Explica el teu cas i les dificultats per a trobar pis amb el teu animal de companyia.",
          "Defén el dret a la vivenda de les persones que tenen animals de companyia.",
          "Proposa possibles solucions per a facilitar el lloguer en estos casos."
         ]
        },
        {
         "key": "B",
         "text": "En els últims anys s'ha començat a parlar de l'escriptura terapèutica com una ferramenta que pot potenciar el benestar emocional. L'escriptura es convertix en una activitat reflexiva a través de la qual explorem les nostres emocions, processem els pensaments i fem balanç de les nostres accions. T'has apuntat a un taller d'escriptura, i en la primera sessió t'han demanat que escrigues una carta al teu jo de 12 anys amb tota l'experiència i la saviesa de què hui en dia disposes. En el teu escrit has d'incloure els punts següents:",
         "points": [
          "Hi ha algunes coses que estan mitificades en la vida.",
          "En la vida trobaràs alguns obstacles.",
          "Les coses importants són les que no ho pareixen."
         ]
        }
       ]
      },
      {
       "n": 8,
       "kind": "writing",
       "title": "Entrada de blog",
       "instructions": "A pesar de tindre un clima mediterrani i viure estius calorosos, en els últims anys hem patit onades de calor intenses i amb temperatures extremes que poden posar en risc la salut de les persones. Has consultat la previsió de l'oratge, i has vist que en els pròxims dies vindrà una nova onada de calor. Basant-te en la infografia següent que has trobat en internet, i com que saps que este tema preocupa a moltes persones del teu entorn, decidixes escriure una entrada en el blog del centre social de la teua localitat en què dones diversos consells per a protegir-se i actuar amb responsabilitat durant estos dies. El text ha de tindre entre 120 i 140 paraules.",
       "min_words": 120,
       "max_words": 140,
       "image": "/exams/b2-octubre-2025/e8-onada-calor.jpg",
       "image_text": "Infografia «Que no t'arrossegue l'onada. Protegix-te de la calor» (#onadadecalor; Generalitat Valenciana, Conselleria de Sanitat), amb nou dibuixos. Consells: Fes exercici en les hores menys caloroses; Evita l'exposició directa al sol entre les 12 h i les 17 h; Utilitza cremes protectores adequades; No deixes a ningú en el cotxe, tampoc la teua mascota; Mantín la vivenda fresca i ventilada; Menja abundants ensalades, fruites i verdures; Protegix majors, menors i altres persones vulnerables; Beu aigua abundant si no tens contraindicació mèdica, evita l'alcohol i la cafeïna; Busca llocs frescos i a l'ombra."
      }
     ]
    },
    {
     "n": 5,
     "title": "Expressió i interacció orals",
     "weight": 25,
     "duration": "25 minuts",
     "intro": "Esta àrea té dos parts: un monòleg d'uns tres minuts sobre un tema que tries i un diàleg d'uns quatre minuts amb una altra persona aspirant, en què cal arribar a un acord.",
     "exercises": [
      {
       "n": 9,
       "kind": "oral",
       "instructions": "Has de triar un tema i preparar un monòleg de tres minuts, aproximadament.",
       "proposals": [
        {
         "title": "Monòleg · El silenci en la ciutat",
         "duration": "3 minuts",
         "intro": "Generalment, relacionem el silenci amb la tranquil·litat i el confort, però pareix que les persones que viuen en les ciutats han perdut el dret a tindre silenci: trànsit, obres, música, comerços, turistes… Per això, alguns ajuntaments han començat a crear espais silenciosos per la ciutat per a millorar el benestar de la ciutadania. Explica què et sembla esta mesura i si valores el silenci com una necessitat.",
         "questions": [],
         "images": []
        },
        {
         "title": "Monòleg · Viure en una furgoneta",
         "duration": "3 minuts",
         "intro": "El moviment van life s'ha convertit en una tendència entre els jóvens que volen explorar el món vivint en una furgoneta adaptada, el que es coneix com a càmper. Esta opció, poc habitual fa uns anys, és cada vegada més comuna. Raona si et sentiries còmode vivint pel món en una furgoneta i si el teu estil de vida encaixaria amb esta alternativa.",
         "questions": [],
         "images": []
        }
       ]
      },
      {
       "n": 10,
       "kind": "oral",
       "instructions": "Has de mantindre un diàleg amb un altre o una altra aspirant sobre la situació comunicativa que et proposem. Has de defendre el paper de la persona que et toque i has d'arribar a un acord obligatòriament amb l'altra persona. Has de participar com ho faries en una conversació habitual i les intervencions han de ser equilibrades. La duració de la conversació serà de quatre minuts, aproximadament.",
       "proposals": [
        {
         "title": "Diàleg · Ens apuntem a extraescolars?",
         "duration": "4 minuts",
         "intro": "Hui en dia molts xiquets acaben l'escola o bé a l'hora de dinar o bé a primera hora de la vesprada. En una cultura com la nostra, en què les vesprades s'allarguen molt, queden unes quantes hores perquè els xiquets les disfruten. Quan són adolescents o preadolescents ja tenen deures, però durant el període d'Infantil i els primers anys de Primària no hi ha a penes càrrega de faenes per a fer en casa.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Persona A",
           "text": "Penses que, quan els xiquets són tan menuts, no necessiten tindre tasques programades, i que les vesprades són per a jugar, per a fer activitats no mediades pels adults, com passa en les extraescolars."
          },
          {
           "name": "Persona B",
           "text": "Penses que fer algunes activitats durant la setmana pot ser beneficiós per als xiquets, perquè els poden despertar curiositats, servixen per a socialitzar, per a estimular el moviment i també ajuden a la conciliació familiar."
          }
         ]
        }
       ]
      }
     ]
    }
   ]
  }
 }
}$data$::jsonb)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  url = EXCLUDED.url,
  content = EXCLUDED.content,
  metadata = EXCLUDED.metadata,
  xp_earned = EXCLUDED.xp_earned,
  difficulty = EXCLUDED.difficulty,
  category = EXCLUDED.category;

-- ============================================================
-- Origen: 20261013180000_exam_b2_oct2024.sql
-- ============================================================
-- Examen interactiu B2 de la JQCV (octubre 2024) com a recurs de category 'examen'.
-- Contingut a metadata.exam, amb les cinc àrees del B2 i la puntuació oficial de la guia de la
-- prova (comprensió oral 8 i 12 punts per encert; comprensió escrita 3,3 i 8,5; estructures 5 i 5;
-- mínim del 40 % en cada àrea i del 50 % en l'oral). Les respostes són les de la plantilla
-- oficial que inclou el quadern. Àudio de comprensió oral a url, convertit a MP3 des de l'oficial
-- (frontend/public/audio/Audio_B2_oct2024.mp3). Font: https://jqcv.gva.es/documents/161863165/165492631/B2+octubre+2024.pdf/105b72bf-ffed-fda4-ee6e-d884261ab41c

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "fe2d494d-ca44-52ca-ab7e-83194bac839a",
 "name": "Simulacre B2: octubre 2024",
 "type": "jqcv_b2_oct2024",
 "category": "examen",
 "difficulty": "B2",
 "xp_earned": 40,
 "url": "/audio/Audio_B2_oct2024.mp3",
 "content": "Examen oficial B2 de la JQCV (octubre 2024): comprensió oral i escrita i estructures lingüístiques autocorregibles, dos redaccions i pràctica oral.",
 "metadata": {
  "icon": "🍄",
  "color": "#FFCC80",
  "exam_body": "JQCV",
  "certificate_level": "B2",
  "exam": {
   "level": "B2",
   "session": "Octubre 2024",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492631/B2+octubre+2024.pdf/105b72bf-ffed-fda4-ee6e-d884261ab41c",
   "audio_source_url": "https://jqcv.gva.es/documents/161863165/167041107/B2+octubre+2024.mp3/5a52792f-02bb-2345-4d72-b205f31959ff",
   "pass_rule": "Per a ser APTE cal una puntuació global mínima de 60 sobre 100. Les àrees valen un 20 % (comprensió oral), un 20 % (comprensió escrita), un 15 % (estructures lingüístiques), un 20 % (expressió escrita) i un 25 % (expressió oral), i en cada una cal arribar al mínim: el 40 % en les quatre primeres i el 50 % en l'expressió oral.",
   "areas": [
    {
     "n": 1,
     "title": "Comprensió oral",
     "weight": 20,
     "duration": "20 minuts",
     "audio": true,
     "intro": "A continuació escoltaràs dos àudios. Els escoltaràs dos vegades, amb una pausa d'un minut entre cada audició, perquè assegures les respostes. Només hi ha una resposta correcta per a cada enunciat.",
     "scoring": {
      "points_per_exercise": {
       "1": 8,
       "2": 12
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 1,
       "kind": "choice",
       "instructions": "A continuació escoltaràs una entrevista a María José Mora, directora de Dansa València. Llig les preguntes i tria l'opció correcta en cada cas. Només hi ha una resposta correcta per a cada pregunta.",
       "questions": [
        {
         "n": 1,
         "prompt": "Com es definix María José Mora?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Com una persona que coneix la cultura des de diferents punts de vista."
          },
          {
           "key": "b",
           "text": "Com una persona capaç de treballar en diversos àmbits culturals."
          },
          {
           "key": "c",
           "text": "Una professional d'arts escèniques, directora d'una escola de dansa."
          }
         ]
        },
        {
         "n": 2,
         "prompt": "Per a Mora, la dansa...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "és una expressió artística i humana a través del cos."
          },
          {
           "key": "b",
           "text": "és un art, com agarrar un pinzell per a pintar un quadro."
          },
          {
           "key": "c",
           "text": "és una disciplina específica que requerix un esforç físic."
          }
         ]
        },
        {
         "n": 3,
         "prompt": "Què és Dansa València segons la directora?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Un festival de dansa que se celebra a la Comunitat Valenciana i altres comunitats autònomes."
          },
          {
           "key": "b",
           "text": "Un festival que servix de punt de trobada per a creadors i professionals de la dansa."
          },
          {
           "key": "c",
           "text": "Un festival de la ciutat de València, ja que depén de la Conselleria d'Educació, Universitats i Ocupació."
          }
         ]
        },
        {
         "n": 4,
         "prompt": "Es pot dir que València és a escala estatal un referent de la dansa?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Sí, per circumstàncies que estan relacionades amb la qualitat de vida de València."
          },
          {
           "key": "b",
           "text": "Sí, per diversos motius, encara que queden moltes coses a fer."
          },
          {
           "key": "c",
           "text": "Sí, per haver creat Dansa València des de l'Institut Valencià de Cultura."
          }
         ]
        },
        {
         "n": 5,
         "prompt": "Quina de les propostes següents definix millor l'objectiu d'Impulsa la Dansa?",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Organitzar, únicament, programes d'assaig per a companyies teatrals que permeten formar millor els professionals de la dansa i els facilite una eixida laboral."
          },
          {
           "key": "b",
           "text": "Organitzar residències per a fer proves teatrals perquè puguen provar llums, l'obertura del teló, i com i a on situaran la il·luminació o el so."
          },
          {
           "key": "c",
           "text": "Descentralitzar la creació artística, donar suport a les companyies i proporcionar formació als gestors municipals, facilitant espais adequats per a la creació i l'assaig."
          }
         ]
        }
       ]
      },
      {
       "n": 2,
       "kind": "binary",
       "instructions": "Llig els enunciats i relaciona'ls amb els consells per a collir bolets que escoltaràs en les audicions. Ordena'ls en el mateix orde en què apareixen en l'àudio. Hi ha dos enunciats que no corresponen a cap consell: marca «No surt» en eixos dos i numera la resta de l'1 al 5.",
       "options": [
        {
         "key": "1",
         "text": "1"
        },
        {
         "key": "2",
         "text": "2"
        },
        {
         "key": "3",
         "text": "3"
        },
        {
         "key": "4",
         "text": "4"
        },
        {
         "key": "5",
         "text": "5"
        },
        {
         "key": "x",
         "text": "No surt"
        }
       ],
       "questions": [
        {
         "n": 6,
         "prompt": "No es poden agarrar totes les varietats de bolets encara que siguen comestibles: uns perquè són difícils d'identificar i uns altres perquè són indigestos.",
         "answer": "5"
        },
        {
         "n": 7,
         "prompt": "Cada boletaire no podrà superar els sis quilograms diaris. A més, la comercialització dels bolets recol·lectats està prohibida.",
         "answer": "4"
        },
        {
         "n": 8,
         "prompt": "Les ferramentes principals que necessitem per a recol·lectar bolets són els mapes, ja que ens ajudaran a orientar-nos i, en cas de pèrdua, saber tornar a casa.",
         "answer": "x",
         "scored": false
        },
        {
         "n": 9,
         "prompt": "La recol·lecció no es pot dur mai a terme amb un utensili que no permeta que les espores dels bolets s'escampen. Per això, no utilitzarem bosses de plàstic.",
         "answer": "2"
        },
        {
         "n": 10,
         "prompt": "És important saber el temps que farà, la zona a on recol·lectarem els bolets, vestir-nos amb un equipament adequat i dur menjar i aigua.",
         "answer": "1"
        },
        {
         "n": 11,
         "prompt": "Si som respectuosos amb el medi ambient, afavorirem que tornen a eixir bolets cada temporada, i per tant en podrem recol·lectar tots els anys.",
         "answer": "x",
         "scored": false
        },
        {
         "n": 12,
         "prompt": "No hem d'agarrar els bolets que no sapiem segur que són aptes per al consum. N'hi ha de tòxics, i per tant n'hem de fer una identificació prèvia.",
         "answer": "3"
        }
       ]
      }
     ]
    },
    {
     "n": 2,
     "title": "Comprensió escrita",
     "weight": 20,
     "duration": "2 h 10 min (amb les àrees 3 i 4)",
     "scoring": {
      "points_per_exercise": {
       "3": 3.3,
       "4": 8.5
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 3,
       "kind": "match",
       "instructions": "Llig atentament el text següent i completa'l amb les propostes de la graella. Tin en compte que hi ha tres propostes que no has d'utilitzar.",
       "reading": {
        "title": "Ikebana: la naturalesa com a mestra",
        "paragraphs": [
         "Pot dir-se que, com el paisatgisme, l'ikebana és una forma de creació estètica basada en la composició d'espècies vegetals, inspirada en elles i en les seues formes. És, (13) ______, una disciplina artística. Encara que tradicionalment s'ha traduït per “art floral del Japó”, les flors no en són la matèria (14) ______. Participen també, i en una forma molt rellevant, les branques, les tiges i les fulles, així com les corfes, els fruits, els capolls i, fins i tot, les (15) ______ en alguns tipus de plantes… La denominació ikebana, que significa literalment “mantindre vives les flors”, al·ludix a la tècnica a través de la qual, una vegada tallades les branques, les flors, etc., i feta la disposició en un recipient, la seua vida es prolonga per un temps. Els vegetals continuen vius, tenen l'aparença de continuar vivint, és a dir, transmeten l'essència del que està viu a qui els contempla. Este és el secret del magnetisme dels arranjaments, el gran atractiu que exercixen, especialment quan es poden vore en directe.",
         "A més d'una disciplina artística, és una forma de (16) ______ que comporta un ritu propi, una pràctica (17) ______. Hi confluïxen, per tant, tres elements: a) la naturalesa física de les formes vegetals, b) els principis compositius de les arts plàstiques i c) un cert sentiment de les coses sagrades o de veneració cap a la vida.",
         "Una altra denominació per a este art, (18) ______, és kadō (‘camí de les flors’). L'ikebana suggerix embarcar-se en una aventura en què el camí mateix és allò que oferix el sentit: caminar és la meta. Practicar l'ikebana significa romandre en un camí. La concentració profunda que (19) ______ la realització d'una disposició deté el temps. Aquells que seguixen este camí són capaços d'eixir de la quotidianitat i entrar en un temps diferent, meditatiu, i viure profundament el present. Un camí que s'incorpora a la pròpia vida, indefinidament, i pot dir-se que arriba a formar part d'u mateix. Este és el punt de vista zen.",
         "No hem d'entendre l'ikebana dins del que comunament anomenem decoració. La diferència principal entre un ikebana i un arranjament occidental és que en l'ikebana les branques i les flors no són sostingudes per un recipient en què reposen, (20) ______ se sostenen per si mateixes, es mantenen erectes, (21) ______, com si cresqueren, vives, en el recipient. Es tracta de reproduir l'essencial de les formes vives, la seua saba, la vitalitat de la seua energia.",
         "És un art efímer. Dura pocs dies abans de pansir-se. Expressa la transitorietat dels estats pels quals passa la vida dels sers. En l'ikebana, totes les fases de l'evolució del vegetal són valorades com una cosa substancial: naixement, floració i (22) ______. Presenten el futur, el present i el passat d'una composició (23) ______. Les tres fases del temps han d'estar, simultàniament, en l'arranjament: en forma de capolls o brots tendres, el futur; en forma de flors obertes i fulles (24) ______, el present, i, finalment, en forma de zones deteriorades, una miqueta seques o rosegades per algun xicotet insecte, el passat."
        ]
       },
       "options_title": "Propostes",
       "options": [
        {
         "key": "a",
         "text": "meditació"
        },
        {
         "key": "b",
         "text": "precedix"
        },
        {
         "key": "c",
         "text": "de fet"
        },
        {
         "key": "d",
         "text": "sinó que"
        },
        {
         "key": "e",
         "text": "fermes"
        },
        {
         "key": "f",
         "text": "labors"
        },
        {
         "key": "g",
         "text": "essencial"
        },
        {
         "key": "h",
         "text": "músties"
        },
        {
         "key": "i",
         "text": "viva"
        },
        {
         "key": "j",
         "text": "espiritual"
        },
        {
         "key": "k",
         "text": "per tant"
        },
        {
         "key": "l",
         "text": "desplegades"
        },
        {
         "key": "m",
         "text": "llavors"
        },
        {
         "key": "n",
         "text": "seguix"
        },
        {
         "key": "o",
         "text": "decadència"
        }
       ],
       "questions": [
        {
         "n": 13,
         "prompt": "Buit 13",
         "answer": "k"
        },
        {
         "n": 14,
         "prompt": "Buit 14",
         "answer": "g"
        },
        {
         "n": 15,
         "prompt": "Buit 15",
         "answer": "m"
        },
        {
         "n": 16,
         "prompt": "Buit 16",
         "answer": "a"
        },
        {
         "n": 17,
         "prompt": "Buit 17",
         "answer": "j"
        },
        {
         "n": 18,
         "prompt": "Buit 18",
         "answer": "c"
        },
        {
         "n": 19,
         "prompt": "Buit 19",
         "answer": "b"
        },
        {
         "n": 20,
         "prompt": "Buit 20",
         "answer": "d"
        },
        {
         "n": 21,
         "prompt": "Buit 21",
         "answer": "e"
        },
        {
         "n": 22,
         "prompt": "Buit 22",
         "answer": "o"
        },
        {
         "n": 23,
         "prompt": "Buit 23",
         "answer": "i"
        },
        {
         "n": 24,
         "prompt": "Buit 24",
         "answer": "l"
        }
       ]
      },
      {
       "n": 4,
       "kind": "match",
       "instructions": "A continuació coneixeràs set de les nostres escriptores. Relaciona cada text amb l'enunciat que li correspon. Hi ha tres enunciats que no corresponen a cap d'elles.",
       "options_title": "Enunciats",
       "options": [
        {
         "key": "a",
         "text": "Gràcies a les ferramentes digitals manté un diàleg amb el seu públic sobre el procés d'escriptura."
        },
        {
         "key": "b",
         "text": "Generà una obra epistolar remarcable que documenta la vida i política cortesanes."
        },
        {
         "key": "c",
         "text": "El conflicte bèl·lic suposa un trasbals per a la seua carrera literària i per a les tertúlies."
        },
        {
         "key": "d",
         "text": "Una part de la seua obra va poder escapar de les espurnes i va efectuar el camí de retorn."
        },
        {
         "key": "e",
         "text": "Per a ella, l'ús del valencià era un acte de reafirmació política i nacional."
        },
        {
         "key": "f",
         "text": "Va experimentar una metamorfosi lingüística quan descobrí el seu lloc d'origen."
        },
        {
         "key": "g",
         "text": "Ens han pervingut un centenar de mostres que confirmen, això sí, un domini de la tècnica."
        },
        {
         "key": "h",
         "text": "Hi ha tres eixos geogràfics des dels quals l'escriptora compon la seua obra lírica."
        },
        {
         "key": "i",
         "text": "S'inspira en les obres que ja ha llegit per a reescriure-les com a històries sobrenaturals."
        },
        {
         "key": "j",
         "text": "Subversiva en l'àmbit personal, també fou públicament una activista pels drets de les dones."
        }
       ],
       "questions": [
        {
         "n": 25,
         "prompt": "Només un fragment de poema s'ha conservat d'Amat al Aziz as-Sari- fa al-Husayniyya, el nom complet de la poeta que pertany a un grup de trenta-cinc poetes clàssiques d'Al-Àndalus, de les quals s'han conservat i identificat cent dos poemes, en molts casos poemes breus o només fragments. El rastre de les poetes andalusines es perd en les antologies. [...] Els seus versos seguixen el gènere clàssic oriental de la cassida, la combinació rítmica de síl·labes llargues i breus, en versos que aconseguixen la rima per la repetició de l'última consonant.",
         "answer": "g"
        },
        {
         "n": 26,
         "prompt": "Figura cabdal de la literatura de postguerra, Maria Beneyto va viure la seua infància a Madrid, i el castellà es convertí en la primera llengua que parlà. Als dotze anys tornà a València, i es convertí en poeta de la terra perquè se n'enamorà. «Per a mi, castellanoparlant, escriure en valencià és un acte d'amor a la terra», això escrivia a Joan Fuster, amic i confident, l'any 1951. Sempre fugí de polèmiques sobre les llengües que usava, sempre va defendre l'absoluta «llibertat del poeta».",
         "answer": "f"
        },
        {
         "n": 27,
         "prompt": "Maria Cambrils mai va defugir la confrontació d'idees ni la defensa de la classe obrera, i contribuí a construir un discurs feminista en defensa de la igualtat. Transgressora en la seua vida privada i pública, de formació autodidàctica, va aconseguir reunir una important biblioteca, traduí la pensadora marxista i feminista Alexandra Kollontai, llegia santa Teresa, es manifestà públicament a favor del sufragi femení, en contra de l'estalinisme, a favor de l'amor lliure, de l'escola laica, de la necessària organització de les dones en el si del socialisme, contra el clericalisme que constrenyia les dones, a favor de la democràcia com a marc polític.",
         "answer": "j"
        },
        {
         "n": 28,
         "prompt": "La cort de la reina Maria es convertix en un centre d'influència i un espai per a la promoció, especialment per a les dones. Va saber negociar amb els súbdits i servir els interessos de la Corona mentres el rei estava a Nàpols. Es mostrà partidària de la pau i del pacte. Però dura, justa i ferma. Treballadora incansable, amant dels llibres i de la música. Enèrgica i lleial. La correspondència de Maria de Castella s'inscriu en la producció documental de la Cancelleria de la Corona d'Aragó, i és una de les més belles i completes del segle XV de tota la Península.",
         "answer": "b"
        },
        {
         "n": 29,
         "prompt": "Maria Egual pertany a la noblesa guanyadora de la Batalla d'Almansa. Educada en un ambient refinat, en el si d'una família de la noblesa castellonenca. Poques coses canvien per a ella en acabar la Guerra de Successió. Obri els salons del palau i reprén la tertúlia literària, imitant els salons de París, els de Madame de Rambouillet. Comença a escriure prompte i, després de tota una vida escrivint, mana que cremen els seus manuscrits. Els manuscrits que se salven del foc, una tercera part, acaben en una subhasta de Sotheby's en el 1976. Els adquirix la Biblioteca Nacional.",
         "answer": "d"
        },
        {
         "n": 30,
         "prompt": "A Quart de Poblet l'invadí la passió per escriure i per les històries fantàstiques, una vocació que ha permés a Laura Gallego vendre més de dos milions de llibres. Escriu el que a ella li agradaria llegir, i ha aconseguit connectar amb un públic adolescent, que la seguix en les xarxes. Ha establit una conversació permanent sobre el que escriu i, des de l'espai virtual, explica quins projectes li ronden pel cap, en quines noves històries pensa, ens deixa llegir els llibres que no li han publicat... Compartix amb qui la seguix el procés, i la dificultat, de construir trames i alçar personatges.",
         "answer": "a"
        },
        {
         "n": 31,
         "prompt": "Àngels Gregori és una veu potent que —des d'Oliva, el poble a on va nàixer i al qual se sent estretament vinculada; Barcelona, la ciutat a on treballa, o Manhattan, el barri que visita sempre que pot— usa la poesia per a mirar el món i intentar transformar-lo. Escriu poesia i treballa per a la poesia, impartint classes de literatura comparada i gestionant espais de trobada i de reivindicació. Escriu el que necessita dir sense por; formula preguntes i respon amb la metàfora; s'entrena llegint poesia; treballa per a l'eternitat, lentament, buscant quedar-se només amb la paraula essencial.",
         "answer": "h"
        }
       ]
      }
     ]
    },
    {
     "n": 3,
     "title": "Estructures lingüístiques",
     "weight": 15,
     "duration": "2 h 10 min (amb les àrees 2 i 4)",
     "scoring": {
      "points_per_exercise": {
       "5": 5,
       "6": 5
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 5,
       "kind": "choice",
       "instructions": "En el text següent s'han eliminat algunes paraules. Per a cada espai en blanc tens tres opcions de resposta. Només una és correcta. Fixa't en l'exemple (número 0).",
       "reading": {
        "title": "Aprendre i ensenyar amb TIC",
        "paragraphs": [
         "En l'actualitat la tecnologia digital és d'ús comú en (0) diversos contextos i conforma una cultura de participació (32) ______ es du a terme clarament en les xarxes socials, però també en expressions més creatives. (33) ______, esta participació no forma part del currículum explícit, sinó (34) ______ es denomina currículum ocult. La falta d'incorporació d'activitats digitals, a més d'una qüestió de gestió de les tasques escolars, és també un desaprofitament d'oportunitats d'aprenentatge dels estudiants.",
         "En efecte, si bé la tecnologia de la informació i la comunicació (TIC) (35) ______ molts aspectes de l'activitat diària, també ha canviat la nostra interacció amb l'aprenentatge, i estos canvis en els processos d'ensenyança i aprenentatge no han sigut equivalents. La importància i ubiqüitat de les TIC en el treball, l'educació i la vida quotidiana es reflectixen en la consideració de l'escenari actual d'interacció social de la societat, definida com a «societat de la informació i el coneixement». (36) ______, la tecnologia no s'ha de considerar un afegit, sinó un element transformador de l'educació en el context de la societat de la informació i el coneixement, en què els aprenents, les seues característiques, les formes socials, els ritmes d'aprenentatge, etc., estan canviant, i per tant es fa necessari replantejar què, com i quan s'ensenya, com s'avalua, com s'organitzen i s'estructuren les escoles i com es gestionen els temps i els espais.",
         "(37) ______ redefinir el concepte d'escola innovadora –que fins ara se centrava a promoure l'aprenentatge de les TIC amb l'objectiu de formar els xiquets en l'ús de ferramentes i estratègies per al tractament i la transmissió de la informació–, de manera que se centre (38) ______ l'ús de les tecnologies per a aprendre amb la tecnologia. Per tant, es tracta de convertir les TIC en tecnologies per a l'aprenentatge i el coneixement (TAC), fet que es pot entendre com una visió de les TIC des de l'escola. (39) ______, hauríem de posar les tecnologies al servici d'una millora en els processos d'ensenyança-aprenentatge, d'avaluació i d'organització, així com d'actualització en un context de canvi constant.",
         "En conseqüència, l'objectiu de l'escola hauria de ser un aprenentatge més profund, més comprensiu i més significatiu, i preparar l'alumnat per a ser capaç de crear coneixement: educar per a allò que encara no se sap què serà, preparar els alumnes (40) ______ es puguen enfrontar a reptes que encara no tenen i donar el màxim de recursos i ferramentes perquè, quan (41) ______ troben, puguen crear, inventar, redissenyar, estratègies i recursos per a poder aportar solucions. En definitiva, perquè puguen promoure l'aprenentatge al llarg de la vida en etapes i contextos diversos amb l'ajuda de les TIC."
        ]
       },
       "questions": [
        {
         "n": 32,
         "prompt": "Buit 32",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "la qual"
          },
          {
           "key": "b",
           "text": "que"
          },
          {
           "key": "c",
           "text": "què"
          }
         ]
        },
        {
         "n": 33,
         "prompt": "Buit 33",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "També"
          },
          {
           "key": "b",
           "text": "Per exemple"
          },
          {
           "key": "c",
           "text": "Ara bé"
          }
         ]
        },
        {
         "n": 34,
         "prompt": "Buit 34",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "del qual"
          },
          {
           "key": "b",
           "text": "de què"
          },
          {
           "key": "c",
           "text": "del que"
          }
         ]
        },
        {
         "n": 35,
         "prompt": "Buit 35",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "ha modificat"
          },
          {
           "key": "b",
           "text": "els ha modificat"
          },
          {
           "key": "c",
           "text": "n'ha modificat"
          }
         ]
        },
        {
         "n": 36,
         "prompt": "Buit 36",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Així les coses"
          },
          {
           "key": "b",
           "text": "Per tant"
          },
          {
           "key": "c",
           "text": "A més"
          }
         ]
        },
        {
         "n": 37,
         "prompt": "Buit 37",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Hi ha que"
          },
          {
           "key": "b",
           "text": "Es deu de"
          },
          {
           "key": "c",
           "text": "Cal"
          }
         ]
        },
        {
         "n": 38,
         "prompt": "Buit 38",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "en"
          },
          {
           "key": "b",
           "text": "amb"
          },
          {
           "key": "c",
           "text": "a"
          }
         ]
        },
        {
         "n": 39,
         "prompt": "Buit 39",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "No obstant això,"
          },
          {
           "key": "b",
           "text": "És a dir,"
          },
          {
           "key": "c",
           "text": "Fet i fet,"
          }
         ]
        },
        {
         "n": 40,
         "prompt": "Buit 40",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "per què"
          },
          {
           "key": "b",
           "text": "per a què"
          },
          {
           "key": "c",
           "text": "per tal que"
          }
         ]
        },
        {
         "n": 41,
         "prompt": "Buit 41",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "se'n"
          },
          {
           "key": "b",
           "text": "s'ho"
          },
          {
           "key": "c",
           "text": "s'hi"
          }
         ]
        }
       ]
      },
      {
       "n": 6,
       "kind": "choice",
       "instructions": "En el text següent s'han eliminat algunes paraules. Per a cada espai en blanc tens tres opcions de resposta. Només una és correcta. Fixa't en l'exemple (número 0).",
       "reading": {
        "title": "Cicatriu",
        "paragraphs": [
         "Una vegada més em quede (0) embadalida davant de l'espill, observant-me la cicatriu. Quantes vegades hauré fet ja este gest? Centenars, milers, milions... Cada dia, des de fa set anys, (42) ______ vegades. Últimament, encara amb més freqüència. La (43) ______ és la del meu palmell ben estirat, uns quinze centímetres. Abans no m'importava massa esta marca; de fet, no és tan diferent d'una piga o d'una taca de naixement. Aleshores no era \"la cicatriu\", sinó “una cicatriu” més.",
         "Quan era més menuda m'agradava mostrar-la. I com m'enorgullia de contar la meua aventura en l'hospital! Podia notar l'enveja dels meus amics perquè les seues cicatrius no tenien res a vore amb la meua. Jo havia festejat amb la mort i això em donava un rang superior a la resta. Mai havia tingut complexos per vestir tops que em deixaren el (44) ______ al descobert –i clar, aquella cicatriu que jo ja no veia–, ni tampoc biquini. Adorava que el meu ventre llis tinguera el color del bronze.",
         "Però este estiu, tot això ha canviat. Una vegada i una altra em pregunte si els metges no podien haver-me fet un tall més discret o si la infermera encarregada de cosir-me la pell no podia haver-ho fet amb més (45) ______. Ara m'adone que la gent em mira la panxa només d'amagat, amb certa coentor en les entranyes, i que mai ningú s'atrevirà a passar els dits per este trau si no és per un rampell de (46) ______.",
         "Bé, en realitat tampoc és que haja fet una enquesta a peu de carrer, però vaig palpar el rebuig de Guillem el dia que una colleta vam anar a la platja per a celebrar l'acabament de les classes. El vaig sorprendre observant-me la panxa i, a l'adonar-se que jo el mirava, va evitar tornar a dirigir els ulls a la pell ferida. Li ho vaig llegir en el rostre: li vaig fer (47) ______. I això justament era el que menys volia jo en este món. No sé per quina raó em va evitar la resta del dia. El seu grupet d'amics també, però a mi ells em tenien igual. Guillem, en canvi, no. Ens havíem fet molt amics durant el curs; de fet, pensava que entre els dos hi havia alguna cosa més que una amistat. Per això la seua (48) ______ em va desconcertar tant.",
         "Després ja no ens voríem en tot l'estiu. L'única cosa que ens unia era que havíem compartit l'aula de primer de Batxillerat A. Per què no em va preguntar res? Jo li hauria explicat sense pèls en la llengua què va passar. Vaig sentir com si algú em clavara les mans dins del cap i volguera (49) ______ tot el meu ser a un altre lloc. Vaig experimentar la mateixa sensació de volar que si estiguera en un (50) ______. Després d'un silenci, un buit, una mort. Aquelles hores mai van ser meues. Em vaig lliurar a unes persones que no coneixia de res, amb total confiança i sense por. Només vaig (51) ______ un \"tot anirà bé\" de la mare just abans d'entrar al quiròfan i la promesa del simpàtic cirurgià vestit amb el color de l'esperança."
        ]
       },
       "questions": [
        {
         "n": 42,
         "prompt": "Buit 42",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "incontables"
          },
          {
           "key": "b",
           "text": "incomptables"
          },
          {
           "key": "c",
           "text": "incontestables"
          }
         ]
        },
        {
         "n": 43,
         "prompt": "Buit 43",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "grandària"
          },
          {
           "key": "b",
           "text": "llargària"
          },
          {
           "key": "c",
           "text": "grossària"
          }
         ]
        },
        {
         "n": 44,
         "prompt": "Buit 44",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "melic"
          },
          {
           "key": "b",
           "text": "melit"
          },
          {
           "key": "c",
           "text": "llambrígol"
          }
         ]
        },
        {
         "n": 45,
         "prompt": "Buit 45",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "alerta"
          },
          {
           "key": "b",
           "text": "cuidat"
          },
          {
           "key": "c",
           "text": "cura"
          }
         ]
        },
        {
         "n": 46,
         "prompt": "Buit 46",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "maldat"
          },
          {
           "key": "b",
           "text": "compassió"
          },
          {
           "key": "c",
           "text": "menyspreu"
          }
         ]
        },
        {
         "n": 47,
         "prompt": "Buit 47",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "llàstima"
          },
          {
           "key": "b",
           "text": "nosa"
          },
          {
           "key": "c",
           "text": "por"
          }
         ]
        },
        {
         "n": 48,
         "prompt": "Buit 48",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "aptitud"
          },
          {
           "key": "b",
           "text": "actitud"
          },
          {
           "key": "c",
           "text": "acritud"
          }
         ]
        },
        {
         "n": 49,
         "prompt": "Buit 49",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "emportar-se"
          },
          {
           "key": "b",
           "text": "portar-se"
          },
          {
           "key": "c",
           "text": "dur-se"
          }
         ]
        },
        {
         "n": 50,
         "prompt": "Buit 50",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "somni"
          },
          {
           "key": "b",
           "text": "son"
          },
          {
           "key": "c",
           "text": "sonall"
          }
         ]
        },
        {
         "n": 51,
         "prompt": "Buit 51",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "necessitar"
          },
          {
           "key": "b",
           "text": "precisar"
          },
          {
           "key": "c",
           "text": "haure"
          }
         ]
        }
       ]
      }
     ]
    },
    {
     "n": 4,
     "title": "Expressió i interacció escrites",
     "weight": 20,
     "duration": "2 h 10 min (amb les àrees 2 i 3)",
     "exercises": [
      {
       "n": 7,
       "kind": "writing",
       "title": "Redacció",
       "instructions": "Tria una de les dos opcions i redacta un text que tinga entre 180 i 220 paraules.",
       "min_words": 180,
       "max_words": 220,
       "choices": [
        {
         "key": "A",
         "text": "Recentment s'ha prohibit, amb algunes excepcions, l'ús del telèfon mòbil en els centres educatius no universitaris, no sols durant les classes sinó també en el temps d'esplai o en les activitats extraescolars. Has llegit la notícia en un periòdic, i no pareix que tota la comunitat estiga d'acord amb esta mesura. Com a membre de l'associació de mares, pares i alumnes, decidixes escriure una entrada en el web del centre educatiu del teu poble en què tractes el tema. Has d'incloure-hi els punts següents:",
         "points": [
          "Expressa preocupació per la quantitat d'hores que els menors passen amb els dispositius mòbils.",
          "Explica les oportunitats que la proposta els oferix: més socialització, menys dependència tecnològica, etc.",
          "Valora el canvi que pot suposar l'atenció en classe i el rendiment."
         ]
        },
        {
         "key": "B",
         "text": "Darrere del tancament d'una carnisseria, un forn o un bar s'amaga un drama comú: el despoblament. Es tracta d'una situació que fa que els pobles es queden sense botigues, sense servicis, sense escoles i, finalment, sense gent. Després de vore un anunci en un periòdic, la idea d'anar a viure a un poble et sembla atractiva, i creus que la teua família i tu hi podeu aportar vitalitat. Escriu una carta a l'Ajuntament d'eixa localitat en què tractes el tema. Has d'incloure-hi els punts següents:",
         "points": [
          "Expressa interés per anar a viure a la localitat.",
          "Explica el tipus de negoci que voleu obrir i què aportarà al poble.",
          "Sol·licita que tinguen en compte la vostra proposta."
         ]
        }
       ]
      },
      {
       "n": 8,
       "kind": "writing",
       "title": "Article per al butlletí municipal",
       "instructions": "Els mars i els oceans cobrixen dos terceres parts de la superfície terrestre. Tenen un valor incalculable, perquè són universos plens de vida i resulten essencials per a la formació dels climes. A pesar d'això, els humans els hem convertit en abocadors de deixalles que impedixen la vida dels ecosistemes i trenquen els equilibris mediambientals. Vius en un poble costaner que ha iniciat unes campanyes de conscienciació i implicació ciutadana. Basant-te en la següent infografia que has trobat en internet, decidixes escriure un article per al Butlletí d'Informació Municipal en què expliques quins canvis d'hàbits podrien millorar la situació de les platges. El text ha de tindre entre 120 i 140 paraules.",
       "min_words": 120,
       "max_words": 140,
       "image": "/exams/b2-octubre-2024/e8-platges.jpg",
       "image_text": "Infografia sobre la cura de les platges, en dos blocs. «Prohibicions» (amb un senyal de prohibit): No tireu l'oli pel desaigüe de la pica; No tireu fem en les platges; No utilitzeu productes agrícoles contaminants. «Iniciatives» (amb un senyal de correcte): Reduïu l'ús d'envasos plàstics (maquillatge, medicines, botelles...); Recicleu plàstics i vidres en els contenidors corresponents; Formeu grups de voluntaris per a netejar platges; Exigiu regulacions més estrictes sobre abocaments."
      }
     ]
    },
    {
     "n": 5,
     "title": "Expressió i interacció orals",
     "weight": 25,
     "duration": "25 minuts",
     "intro": "Esta àrea té dos parts: un monòleg d'uns tres minuts sobre un tema que tries i un diàleg d'uns quatre minuts amb una altra persona aspirant, en què cal arribar a un acord.",
     "exercises": [
      {
       "n": 9,
       "kind": "oral",
       "instructions": "Has de triar un tema i preparar un monòleg de tres minuts, aproximadament.",
       "proposals": [
        {
         "title": "Monòleg · Intercanvis de cases vacacionals",
         "duration": "3 minuts",
         "intro": "Un dels models consolidats en període vacacional per a estalviar diners és l'intercanvi de cases. Este model consistix a oferir a una persona o família ta casa mentres tu t'instal·les en la seua durant el mateix període de temps. Explica si coneixies el model, si l'has practicat o no i què et pareix.",
         "questions": [],
         "images": []
        },
        {
         "title": "Monòleg · Tendències informatives",
         "duration": "3 minuts",
         "intro": "No és una novetat que cada vegada veem menys la televisió convencional i llegim menys premsa escrita per a estar informats. Este canvi de tendència es deu a l'esclat i la consolidació de les xarxes socials. No obstant això, hi ha persones que continuen preferint informar-se a través dels mitjans tradicionals. Explica quines són les teues preferències per a informar-te i per què.",
         "questions": [],
         "images": []
        }
       ]
      },
      {
       "n": 10,
       "kind": "oral",
       "instructions": "Has de mantindre un diàleg amb un altre o una altra aspirant sobre la situació comunicativa que et proposem. Has de defendre el paper de la teua persona i has d'arribar a un acord obligatòriament amb l'altra persona. Has de participar com ho faries en una conversació habitual i les intervencions han de ser equilibrades. La duració de la conversació serà de quatre minuts, aproximadament.",
       "proposals": [
        {
         "title": "Diàleg · El viatge de l'estiu",
         "duration": "4 minuts",
         "intro": "El viatge de l'estiu. Cada persona defén una manera diferent de viatjar i heu d'arribar a un acord.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Persona A",
           "text": "Eres una persona amb consciència mediambiental, i per a viatjar t'agraden les distàncies curtes. Vols conéixer els llocs de proximitat, intentes utilitzar mitjans de transport poc contaminants; en definitiva, tractes de fer un turisme el més sostenible possible. Penses que esta és la millor forma de viatjar, ja que es minimitza l'impacte ambiental i resulta més econòmica."
          },
          {
           "name": "Persona B",
           "text": "Eres una persona a qui li atrauen les cultures llunyanes, les formes de vida i els costums diferents dels de la teua cultura. T'agrada viatjar a llocs exòtics, busques noves experiències i diferents de les que et pot oferir el teu país. Penses que esta és la millor forma de viatjar, ja que evites el turisme de masses i el contrast cultural et resulta més enriquidor."
          }
         ]
        }
       ]
      }
     ]
    }
   ]
  }
 }
}$data$::jsonb)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  url = EXCLUDED.url,
  content = EXCLUDED.content,
  metadata = EXCLUDED.metadata,
  xp_earned = EXCLUDED.xp_earned,
  difficulty = EXCLUDED.difficulty,
  category = EXCLUDED.category;

-- ============================================================
-- Origen: 20261013190000_exam_b2_oct2023.sql
-- ============================================================
-- Examen interactiu B2 de la JQCV (octubre 2023) com a recurs de category 'examen'.
-- Contingut a metadata.exam, amb les cinc àrees del B2 i la puntuació oficial de la guia de la
-- prova (comprensió oral 8 i 12 punts per encert; comprensió escrita 3,3 i 8,5; estructures 5 i 5;
-- mínim del 40 % en cada àrea i del 50 % en l'oral). Les respostes són les de la plantilla
-- oficial que inclou el quadern. Àudio de comprensió oral a url, convertit a MP3 des de l'oficial
-- (frontend/public/audio/Audio_B2_oct2023.mp3). Font: https://jqcv.gva.es/documents/161863165/165492631/B2+octubre+2023.pdf/681bf1b8-8a16-bf64-ce56-9ef28fcd24a2

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "2b1b59c2-196c-5bb1-8181-c3ce4cb70200",
 "name": "Simulacre B2: octubre 2023",
 "type": "jqcv_b2_oct2023",
 "category": "examen",
 "difficulty": "B2",
 "xp_earned": 40,
 "url": "/audio/Audio_B2_oct2023.mp3",
 "content": "Examen oficial B2 de la JQCV (octubre 2023): comprensió oral i escrita i estructures lingüístiques autocorregibles, dos redaccions i pràctica oral.",
 "metadata": {
  "icon": "🧮",
  "color": "#B2DFDB",
  "exam_body": "JQCV",
  "certificate_level": "B2",
  "exam": {
   "level": "B2",
   "session": "Octubre 2023",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492631/B2+octubre+2023.pdf/681bf1b8-8a16-bf64-ce56-9ef28fcd24a2",
   "audio_source_url": "https://jqcv.gva.es/documents/161863165/167041107/B2+octubre+2023.mp3/e35ed67c-5732-a52b-5d21-6a4a2f0440d2",
   "pass_rule": "Per a ser APTE cal una puntuació global mínima de 60 sobre 100. Les àrees valen un 20 % (comprensió oral), un 20 % (comprensió escrita), un 15 % (estructures lingüístiques), un 20 % (expressió escrita) i un 25 % (expressió oral), i en cada una cal arribar al mínim: el 40 % en les quatre primeres i el 50 % en l'expressió oral.",
   "areas": [
    {
     "n": 1,
     "title": "Comprensió oral",
     "weight": 20,
     "duration": "20 minuts",
     "audio": true,
     "intro": "Tot seguit escoltaràs dos àudios. Tots els àudios els escoltaràs dos vegades, amb una pausa entre cada audició, perquè assegures les respostes. Només hi ha una resposta correcta per a cada pregunta.",
     "scoring": {
      "points_per_exercise": {
       "1": 8,
       "2": 12
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 1,
       "kind": "choice",
       "instructions": "A continuació escoltaràs una entrevista a Eva Miranda sobre la bellesa de les matemàtiques. Llig les preguntes i tria l'opció correcta en cada cas. Només hi ha una resposta correcta per a cada pregunta.",
       "questions": [
        {
         "n": 1,
         "prompt": "Segons Eva Miranda, podríem dir que les matemàtiques són…",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "un refugi que t'aïlla dels problemes quotidians de la vida real."
          },
          {
           "key": "b",
           "text": "una branca del coneixement que busca la solució de problemes."
          },
          {
           "key": "c",
           "text": "un llenguatge basat en fórmules que seguixen un orde concret."
          }
         ]
        },
        {
         "n": 2,
         "prompt": "Les matemàtiques no agraden o resulten difícils a molta gent perquè…",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "no els veuen una utilitat pràctica més enllà de fer operacions."
          },
          {
           "key": "b",
           "text": "es troben problemes oberts que mai s'acaben de resoldre."
          },
          {
           "key": "c",
           "text": "falta una bona pedagogia que ensenye bé este llenguatge."
          }
         ]
        },
        {
         "n": 3,
         "prompt": "La bellesa de les matemàtiques...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "rau a descobrir allò que és essencial i a bandejar els elements secundaris."
          },
          {
           "key": "b",
           "text": "consistix a poder resoldre els detalls més complexos dels problemes."
          },
          {
           "key": "c",
           "text": "està en la connexió que tenen amb fets quotidians del nostre entorn."
          }
         ]
        },
        {
         "n": 4,
         "prompt": "Segons l'experta, quines aplicacions tenen les matemàtiques?",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "Servixen per a dissenyar sistemes de gestió de la informació."
          },
          {
           "key": "b",
           "text": "S'utilitzen per a configurar els codis ètics en el camp de la medicina."
          },
          {
           "key": "c",
           "text": "Són útils per a millorar l'expressió i la qualitat estètica de les obres d'art."
          }
         ]
        },
        {
         "n": 5,
         "prompt": "Què opina Eva Miranda sobre els sistemes d'intel·ligència artificial?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Que estan sotmesos a un control excessiu dels comités universitaris."
          },
          {
           "key": "b",
           "text": "Que s'han d'aprovar normes que en garantisquen un ús ètic."
          },
          {
           "key": "c",
           "text": "Que són un risc perquè poden controlar el funcionament d'armament."
          }
         ]
        }
       ]
      },
      {
       "n": 2,
       "kind": "binary",
       "instructions": "Llig els enunciats i relaciona'ls amb els consells que escoltaràs en les audicions per a previndre infeccions alimentàries per un ús inadequat dels ous. Tin en compte que hi ha dos enunciats que no corresponen a cap consell: marca «No surt» en eixos dos i numera els altres cinc de l'1 al 5 seguint l'orde en què apareixen en l'àudio.",
       "options": [
        {
         "key": "1",
         "text": "1"
        },
        {
         "key": "2",
         "text": "2"
        },
        {
         "key": "3",
         "text": "3"
        },
        {
         "key": "4",
         "text": "4"
        },
        {
         "key": "5",
         "text": "5"
        },
        {
         "key": "x",
         "text": "No surt"
        }
       ],
       "questions": [
        {
         "n": 6,
         "prompt": "Per a saber si els ous estan frescs, podem submergir-los en aigua i, si suren, no són aptes per al consum.",
         "answer": "5"
        },
        {
         "n": 7,
         "prompt": "Cal mirar la data de caducitat abans de comprar els ous, encara que els podem consumir una setmana després d'esta data.",
         "answer": "x",
         "scored": false
        },
        {
         "n": 8,
         "prompt": "Cal assegurar-nos que quan cuinem tinguem les mans netes i els utensilis de cuina estiguen lliures de brutícia.",
         "answer": "1"
        },
        {
         "n": 9,
         "prompt": "S'aconsella no rentar els ous després de comprar-los, només es poden rentar si a continuació els cuines.",
         "answer": "3"
        },
        {
         "n": 10,
         "prompt": "Cal que les persones delicades de salut o amb alguna afectació mèdica no mengen mai els ous crus.",
         "answer": "x",
         "scored": false
        },
        {
         "n": 11,
         "prompt": "La temperatura a què es guarden els ous ha de ser constant per a evitar la contaminació a través de la closca.",
         "answer": "2"
        },
        {
         "n": 12,
         "prompt": "Els ous s'han de cuinar a una temperatura alta i hem d'evitar que queden crus o poc quallats.",
         "answer": "4"
        }
       ]
      }
     ]
    },
    {
     "n": 2,
     "title": "Comprensió escrita",
     "weight": 20,
     "duration": "2 h 10 min (amb les àrees 3 i 4)",
     "scoring": {
      "points_per_exercise": {
       "3": 3.3,
       "4": 8.5
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 3,
       "kind": "match",
       "instructions": "Llig atentament el text següent i completa'l amb les propostes de la graella. Tin en compte que hi ha tres propostes que no has d'utilitzar.",
       "reading": {
        "title": "Animals salvatges",
        "paragraphs": [
         "Els ecosistemes són sistemes naturals formats per un conjunt d'organismes, pel medi físic on viuen i per les relacions que establixen entre ells i amb el medi. Estes relacions poden ser (13) ______ complexes, i també dinàmiques i adaptables. Per exemple, si un determinat depredador presenta unes preferències de temperatura i lluminositat per a caçar, les seues preses tenen la tendència a readaptar el seu comportament per a limitar al màxim les possibilitats d'una (14) ______ fortuïta. També hi ha animals que alteren el seu comportament per a evitar el contacte amb les persones. En una investigació recent s'ha comprovat que la massiva pressió del turisme fotogràfic a la sabana africana ha fet que molts grups de lleons aprofiten per a caçar al ple migdia, coincidint amb l'estona de dinar de les persones; (15) ______ caçaven en fer-se de dia o a poqueta nit.",
         "En esta mateixa busca, els investigadors van instal·lar càmeres en deu ciutats nord-americanes per a capturar imatges de les incursions que hi fan els animals salvatges que viuen relativament a prop per a buscar menjar o per a refugiar-se, i les han comparades amb el comportament dels que viuen (16) ______ en entorns poc o (17) ______ humanitzats; (18) ______, van examinar depredadors com coiots i linxs, animals que tenen una dieta més flexible, com els ossos rentadors, i també herbívors, com els conills.",
         "Els resultats que han obtingut (19) ______ que els depredadors de mida més gran, com els coiots i les raboses, tenen tendència a (20) ______ el seu cicle biològic diari i esdevindre més nocturns en entorns urbans. D'esta manera, poden buscar restes de menjar entre les deixalles al mateix temps que reduïxen la probabilitat de trobar-se amb les persones, que normalment els fan fora; (21) ______, els conills i els ossos rentadors avancen el seu cicle biològic ja que, a diferència dels carnívors, les persones no els acostumen a (22) ______.",
         "La principal conclusió que els investigadors (23) ______ d'este treball és que, en un ambient cada volta més humanitzat i urbanitzat, quan s'establixen programes de (24) ______, conservació i gestió de la natura s'han de tindre en compte estos canvis de comportament i d'hàbits dels animals, ja que influïxen en la dinàmica global dels ecosistemes i la fan encara més complexa. Segons diuen, el fet de no tindre'ls en compte pot explicar, com a mínim en part, la poca efectivitat de molts d'estos programes i les dificultats de gestió que se'n deriven. Possiblement, també es produïx un efecte similar amb els senglars que passegen al fer-se de nit per molts pobles i ciutats del nostre país."
        ]
       },
       "options_title": "Propostes",
       "options": [
        {
         "key": "a",
         "text": "gens"
        },
        {
         "key": "b",
         "text": "rarament"
        },
        {
         "key": "c",
         "text": "protecció"
        },
        {
         "key": "d",
         "text": "en canvi"
        },
        {
         "key": "e",
         "text": "indiquen"
        },
        {
         "key": "f",
         "text": "molt"
        },
        {
         "key": "g",
         "text": "endarrerir"
        },
        {
         "key": "h",
         "text": "tradicionalment"
        },
        {
         "key": "i",
         "text": "limitació"
        },
        {
         "key": "j",
         "text": "en concret"
        },
        {
         "key": "k",
         "text": "foragitar"
        },
        {
         "key": "l",
         "text": "topada"
        },
        {
         "key": "m",
         "text": "per tant"
        },
        {
         "key": "n",
         "text": "únicament"
        },
        {
         "key": "o",
         "text": "extrauen"
        }
       ],
       "questions": [
        {
         "n": 13,
         "prompt": "Buit 13",
         "answer": "f"
        },
        {
         "n": 14,
         "prompt": "Buit 14",
         "answer": "l"
        },
        {
         "n": 15,
         "prompt": "Buit 15",
         "answer": "h"
        },
        {
         "n": 16,
         "prompt": "Buit 16",
         "answer": "n"
        },
        {
         "n": 17,
         "prompt": "Buit 17",
         "answer": "a"
        },
        {
         "n": 18,
         "prompt": "Buit 18",
         "answer": "j"
        },
        {
         "n": 19,
         "prompt": "Buit 19",
         "answer": "e"
        },
        {
         "n": 20,
         "prompt": "Buit 20",
         "answer": "g"
        },
        {
         "n": 21,
         "prompt": "Buit 21",
         "answer": "d"
        },
        {
         "n": 22,
         "prompt": "Buit 22",
         "answer": "k"
        },
        {
         "n": 23,
         "prompt": "Buit 23",
         "answer": "o"
        },
        {
         "n": 24,
         "prompt": "Buit 24",
         "answer": "c"
        }
       ]
      },
      {
       "n": 4,
       "kind": "match",
       "instructions": "A continuació llegiràs set crítiques de cine. Relaciona cada una amb l'enunciat que li correspon. Hi ha tres enunciats que no corresponen a cap crítica cinematogràfica.",
       "options_title": "Enunciats",
       "options": [
        {
         "key": "a",
         "text": "Un triangle amorós ambientat en un país exòtic que acaba en tragèdia."
        },
        {
         "key": "b",
         "text": "La lluita per recuperar un vincle per damunt de tot acaba en drama."
        },
        {
         "key": "c",
         "text": "La creativitat que desenvolupa un jove per tal de fugir de la seua realitat."
        },
        {
         "key": "d",
         "text": "La protagonista és una dona forta que pren les regnes de la seua vida."
        },
        {
         "key": "e",
         "text": "Una complexa relació entre costures i tradició ambientada en un país exòtic."
        },
        {
         "key": "f",
         "text": "Les dificultats actuals d'una dona marcades per l'atzar del passat."
        },
        {
         "key": "g",
         "text": "Una història autobiogràfica que mostra les dificultats per a arribar a l'èxit."
        },
        {
         "key": "h",
         "text": "Les decisions que pren la protagonista determinaran la seua vida laboral."
        },
        {
         "key": "i",
         "text": "La costa és l'escenari on una dona reviu el fantasma de les decisions passades."
        },
        {
         "key": "j",
         "text": "La força de l'enginy d'un jove per a sobreviure enmig de les dificultats històriques."
        }
       ],
       "questions": [
        {
         "n": 25,
         "prompt": "En El caftà blau, la cineasta Maryam Touzani no fa cap puntada sense fil. Amb escassos ingredients, la directora tix un drama tan delicat com el prim fil d'or amb què Halim, el sastre protagonista, broda les trenes que decoren el vestit tradicional marroquí que dona títol a la pel·lícula. En esta història d'amor entre un matrimoni que regenta una sastreria tradicional a la medina de Salé i el jove aprenent que arriba per a ajudar-los, el drama es construïx, a poc a poc, a partir dels gestos i de les mirades dels protagonistes.",
         "answer": "e"
        },
        {
         "n": 26,
         "prompt": "Este drama té la capacitat d'evocar l'univers social i geogràfic de la classe blanca treballadora del sud-oest dels Estats Units a partir dels espais i d'una banda sonora plena d'èxits country. Trobem la presència d'una protagonista complexa que construïx un equilibri perfecte entre moments d'explosió gestual i d'altres marcats per una immobilitat dolorosa, que expressa una intensa fractura interior. To Leslie és la història d'una dona que es va beure tots els diners que va guanyar a la loteria i que després d'anys de separació intenta, desesperadament, reconnectar amb el seu fill.",
         "answer": "f"
        },
        {
         "n": 27,
         "prompt": "Sola en unes vacacions a la vora del mar, Leda, la protagonista de La filla obscura, s'hi veu consumida per una jove mare i la seua filla, a les quals observa amb deteniment des de la platja. Intrigada per l'atractiva relació que tenen, Leda se sent aclaparada pels seus propis records del terror, per la confusió i per la intensitat de la maternitat primerenca. Un acte impulsiu porta Leda a submergir-se en l'estrany i ominós món de la seua ment, on es veu obligada a enfrontar-se a les decisions poc convencionals que prengué com a mare jove i a les conseqüències d'esta situació.",
         "answer": "i"
        },
        {
         "n": 28,
         "prompt": "Ambientada en una illa remota davant de la costa oest d'Irlanda en 1923, Ànimes en pena d'Inisherin narra la història de dos amics de tota la vida, Pádraic i Colm, que es troben en un carreró sense eixida. Un dia, Colm decidix posar fi a la seua amistat d'una manera sobtada i incomprensible. Un Pádraic atònit s'esforça per a reconstruir la relació que tenien i es nega a acceptar el silenci del seu amic de la infància. Quan Colm planteja a Pádraic un ultimàtum desesperat, els esdeveniments es precipiten i provoquen conseqüències traumàtiques.",
         "answer": "b"
        },
        {
         "n": 29,
         "prompt": "Els Fabelman és un film semiautobiogràfic que narra la infància i joventut del cineasta Steven Spielberg. Ambientada a finals de la dècada de 1950 i principis dels anys 60, un xiquet d'Arizona que es diu Sammy Fabelman, influït per la seua excèntrica mare -artista de professió- i el seu pragmàtic pare -un enginyer informàtic-, descobrix un secret familiar devastador. Este descobriment el porta a voler explorar i llavors és quan s'adona com el poder de les pel·lícules de cine pot ajudar-lo a contar històries i a forjar la seua pròpia identitat.",
         "answer": "c"
        },
        {
         "n": 30,
         "prompt": "Berlín, 1942. Cioma Schönhaus és un jove jueu de 21 anys que s'ha proposat que ningú, ni tan sols les autoritats nazis, li puguen furtar el seu entusiasme per la vida. Per a escapar de la deportació imminent, Cioma utilitza la identitat d'un oficial de la Marina, i d'esta manera descobrix que té un talent ocult per a falsificar no només passaports i documents oficials, sinó també la seua pròpia identitat. El falsificador de passaports és la història d'un supervivent de l'Holocaust i mostra, en tot moment, malgrat que en un segon pla, la guerra i les seues condicions.",
         "answer": "j"
        },
        {
         "n": 31,
         "prompt": "En Tár, la directora d'orquestra mundialment famosa Lydia Tár, interpretada magníficament per la gran Cate Blanchett, està a pocs dies d'afrontar el repte més gran de la seua carrera professional: ha de gravar la simfonia que la pot portar a les altures de la seua ja formidable trajectòria musical. Lydia Tár és una directora famosa que personifica el poder i l'elegància. Ara bé, la seua vida personal i les decisions que pren interferixen progressivament en la seua carrera musical amb unes conseqüències del tot imprevisibles.",
         "answer": "h"
        }
       ]
      }
     ]
    },
    {
     "n": 3,
     "title": "Estructures lingüístiques",
     "weight": 15,
     "duration": "2 h 10 min (amb les àrees 2 i 4)",
     "scoring": {
      "points_per_exercise": {
       "5": 5,
       "6": 5
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 5,
       "kind": "choice",
       "instructions": "En el text següent s'han eliminat algunes paraules. Per a cada espai en blanc tens tres opcions de resposta. Només una és correcta. Fixa't en l'exemple (número 0).",
       "reading": {
        "title": "Regal",
        "paragraphs": [
         "Una estudiant, no recorde si de filologia o de periodisme, va vindre a casa a fer-me una entrevista. Li havien manat fer un treball sobre un escriptor viu i ella, ignore per què, m'havia triat i m'ho havia proposat per correu electrònic. Vam quedar un dissabte (0) a la vesprada, que ella no tenia classe i jo no havia de treballar.",
         "(32) ______ han fet moltes, d'entrevistes, ja no les prepare. Sempre és, però, incòmode rebre algú que no coneixes, (33) ______ no tens confiança. T'has d'arreglar, no pots atendre amb xandall o, com feia sovint Fuster, amb bata, algú que et farà fotografies i qui sap on les penjarà. No vols donar una imatge negligent de tu mateix. Hi ha l'amor propi i, (34) ______ cada dia menys, la vanitat. No sé fins a quin punt és bo, açò últim. Per una part, saber-se insignificant, prescindible i breu fa que restes importància a quasi tot, i això t'estalvia maldecaps; d'altra banda, sense una mica de vanitat és difícil emprendre projectes de gruix, que tensen la vida.",
         "Era bastant més alta que jo, semblava tímida. Després dels convencionalismes de rigor vam seure, vam beure te verd, ella engegà una gravadora (35) ______ deixà damunt del Schopenhauer, i vam iniciar una conversa llarga sobre els meus llibres i sobre tot el que ella, amb un guió manuscrit damunt les cuixes, preguntava. Era intel·ligent, sabia escoltar i ho sabia copsar tot de primeres, no vaig haver de repetir ni d'especificar el que deia. Feia que sí, (36) ______, amb el cap, diria que amb un punt d'admiració.",
         "Al final de l'agradable conversa, quasi monòleg, abans que (37) ______, vaig voler regalar-li algun dels meus llibres. Vaig preguntar (38) ______ li faltava. Ella, cohibida, va dir que no calia, que se'l podia comprar. “Tens este?”, vaig insistir (39) ______ mostrar-li l'últim que havia publicat. “No, este encara no”, feu. Li vaig estampar una elaborada dedicatòria i li'l vaig posar en les mans. Ella l'introduí amb cura, sense obrir-lo, dins la bossa de pell on havia guardat la gravadora i el guió manuscrit.",
         "Quan va eixir al carrer, la vaig observar, sense que ella ho (40) ______, des del balcó. Vaig veure com deixava la bossa de pell damunt d'un cotxe, com s'ajustava el pantaló i s'allisava la camiseta, i com caminava desimbolta. En arribar a l'altura del contenidor blau, el de paper i cartó, va mirar cap als dos costats del carrer, va traure (41) ______ de la bossa el llibre que li havia regalat i el llançà a dins."
        ]
       },
       "questions": [
        {
         "n": 32,
         "prompt": "Buit 32",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "M'"
          },
          {
           "key": "b",
           "text": "M'hi"
          },
          {
           "key": "c",
           "text": "Me'n"
          }
         ],
         "scored": false
        },
        {
         "n": 33,
         "prompt": "Buit 33",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "amb què"
          },
          {
           "key": "b",
           "text": "amb el que"
          },
          {
           "key": "c",
           "text": "amb qui"
          }
         ]
        },
        {
         "n": 34,
         "prompt": "Buit 34",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "tant de bo"
          },
          {
           "key": "b",
           "text": "tot i que"
          },
          {
           "key": "c",
           "text": "com que"
          }
         ]
        },
        {
         "n": 35,
         "prompt": "Buit 35",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "que"
          },
          {
           "key": "b",
           "text": "la qual cosa"
          },
          {
           "key": "c",
           "text": "la qual"
          }
         ]
        },
        {
         "n": 36,
         "prompt": "Buit 36",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "en tant en quan"
          },
          {
           "key": "b",
           "text": "de tan en tan"
          },
          {
           "key": "c",
           "text": "de tant en tant"
          }
         ]
        },
        {
         "n": 37,
         "prompt": "Buit 37",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "s'anara"
          },
          {
           "key": "b",
           "text": "se n'anara"
          },
          {
           "key": "c",
           "text": "s'hi anara"
          }
         ]
        },
        {
         "n": 38,
         "prompt": "Buit 38",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "el què"
          },
          {
           "key": "b",
           "text": "què"
          },
          {
           "key": "c",
           "text": "quin"
          }
         ]
        },
        {
         "n": 39,
         "prompt": "Buit 39",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "a"
          },
          {
           "key": "b",
           "text": "en"
          },
          {
           "key": "c",
           "text": "amb"
          }
         ]
        },
        {
         "n": 40,
         "prompt": "Buit 40",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "sabera"
          },
          {
           "key": "b",
           "text": "sapiguera"
          },
          {
           "key": "c",
           "text": "sapiera"
          }
         ]
        },
        {
         "n": 41,
         "prompt": "Buit 41",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "'n"
          },
          {
           "key": "b",
           "text": "Ø"
          },
          {
           "key": "c",
           "text": "hi"
          }
         ]
        }
       ]
      },
      {
       "n": 6,
       "kind": "choice",
       "instructions": "En el text següent s'han eliminat algunes paraules. Per a cada espai en blanc tens tres opcions de resposta. Només una és correcta. Fixa't en l'exemple (número 0).",
       "reading": {
        "title": "De viatge per la Plana Baixa",
        "paragraphs": [
         "Un viatger que vinguera del nord descobriria, en passar la ciutat de Castelló de la Plana cap a València, una àmplia superfície de terra cultivada amb tarongers, tancada en gran part per la (0) serralada d'Espadà. La part baixa de la comarca de la Plana es caracteritza pel contrast entre el (42) ______ del pla i les discretes rutes que de seguida s'(43) ______ en les àrdues però mesurades costeres muntanyenques. Un territori amb una acusada personalitat que mereix una visita reposada. Proposem començar-la pel municipi de la Vall d'Uixó.",
         "Hi ha muntanyes màgiques on per a assaltar els cels és necessari escalar el (44) ______ més escarpat d'un mateix. Altres vegades, no obstant això, el viatge ha de ser cap a la profunditat, i en eixe cas no sempre cal esperar que esta immersió siga només metafòrica. A la Vall d'Uixó, al sud de la comarca de la Plana Baixa, es pot visitar el riu subterrani navegable més llarg d'Europa.",
         "Al riu s'accedix pel paratge conegut com les coves de Sant Josep, a les portes del parc natural de la serra d'Espadà. A vegades la naturalesa ens satisfà de (45) ______ per excés: riu i serra són dues meravelles que mereixen una visita, extensible fàcilment a altres municipis de la comarca. El conjunt de coves que alberga este curs fluvial es va formar durant el triàsic, fa la barbaritat de 250 milions d'anys. L'origen i el final del riu encara ens resulten desconeguts. Actualment és navegable en la major part dels seus quasi tres quilòmetres d'extensió. La temperatura allí dins, com en un (46) ______ perfecte, ronda sempre els vint graus. Les excavacions arqueològiques realitzades in situ ens (47) ______ que este conjunt de coves va ser habitat des del paleolític superior. Els romans van canalitzar-ne l'aigua fins a la part baixa de la vall, i la van usar per a consum i regadiu i com a força motriu de molins. L'ús del riu interior com a referència turística no comença fins als anys trenta del segle passat. L'Ajuntament de la Vall d'Uixó ha aprofitat les potencialitats del lloc per a organitzar activitats com Singing in the Cave, cicles de suggestius concerts en el ventre petri de la muntanya.",
         "A fora, al visitant l'espera la meravella de la serra d'Espadà. Es tracta d'un dels contraforts més orientals del sistema Ibèric, un espai natural realment prodigiós pels seus nivells de conservació. De les seues sureres es trau suro de gran valor ecològic i, dels seus pins, resina. A més, està poblada per un valuós (48) ______ de plantes endèmiques, de gran interés científic. En el capítol de la fauna, cal esmentar diverses espècies amfíbies, rèptils i ocells (49) ______, així com setze varietats diferents de (50) ______, algunes de les quals en greu perill d'extinció. Al cor del gran bosc d'Espadà s'hi pot accedir per Alfondeguilla, venint de la Vall d'Uixó o, des de Nules i la Vilavella, per un itinerari d'elevació espiritual que inclou Eslida, Artana i Aín. El visitant quedarà (51) ______ davant la postal d'estos pobles."
        ]
       },
       "questions": [
        {
         "n": 42,
         "prompt": "Buit 42",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "verdor"
          },
          {
           "key": "b",
           "text": "verger"
          },
          {
           "key": "c",
           "text": "vertigen"
          }
         ]
        },
        {
         "n": 43,
         "prompt": "Buit 43",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "endinsen"
          },
          {
           "key": "b",
           "text": "endenyen"
          },
          {
           "key": "c",
           "text": "engeguen"
          }
         ]
        },
        {
         "n": 44,
         "prompt": "Buit 44",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "vesant"
          },
          {
           "key": "b",
           "text": "aiguavés"
          },
          {
           "key": "c",
           "text": "vessant"
          }
         ]
        },
        {
         "n": 45,
         "prompt": "Buit 45",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "bens"
          },
          {
           "key": "b",
           "text": "vens"
          },
          {
           "key": "c",
           "text": "béns"
          }
         ]
        },
        {
         "n": 46,
         "prompt": "Buit 46",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "celler"
          },
          {
           "key": "b",
           "text": "desllunat"
          },
          {
           "key": "c",
           "text": "safareig"
          }
         ]
        },
        {
         "n": 47,
         "prompt": "Buit 47",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "rebel·len"
          },
          {
           "key": "b",
           "text": "revelen"
          },
          {
           "key": "c",
           "text": "revetlen"
          }
         ]
        },
        {
         "n": 48,
         "prompt": "Buit 48",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "manoll"
          },
          {
           "key": "b",
           "text": "toll"
          },
          {
           "key": "c",
           "text": "matoll"
          }
         ]
        },
        {
         "n": 49,
         "prompt": "Buit 49",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "rapasos"
          },
          {
           "key": "b",
           "text": "rapassos"
          },
          {
           "key": "c",
           "text": "rapaços"
          }
         ]
        },
        {
         "n": 50,
         "prompt": "Buit 50",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "rata penada"
          },
          {
           "key": "b",
           "text": "rata-penada"
          },
          {
           "key": "c",
           "text": "ratapenada"
          }
         ]
        },
        {
         "n": 51,
         "prompt": "Buit 51",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "abatut"
          },
          {
           "key": "b",
           "text": "corprés"
          },
          {
           "key": "c",
           "text": "corcat"
          }
         ]
        }
       ]
      }
     ]
    },
    {
     "n": 4,
     "title": "Expressió i interacció escrites",
     "weight": 20,
     "duration": "2 h 10 min (amb les àrees 2 i 3)",
     "exercises": [
      {
       "n": 7,
       "kind": "writing",
       "title": "Redacció",
       "instructions": "Tria una de les dos opcions i redacta un text que tinga entre 180 i 220 paraules.",
       "min_words": 180,
       "max_words": 220,
       "choices": [
        {
         "key": "A",
         "text": "El phubbing és un nou concepte que es referix a l'acció d'ignorar les persones que tens al teu voltant i de prestar només atenció al telèfon mòbil. Consistix en una dependència psicològica del telèfon que provoca que es descuiden els vincles personals, les converses cara a cara i l'activitat física. A més suposa un comportament poc cívic. Fa uns dies vas quedar en una cafeteria amb un grup d'amics que feia temps que no veies. La major part del temps se'l van passar mirant el mòbil, fet que t'ha molestat especialment. Pràcticament no vau parlar i vas haver d'anul·lar un compromís per a quedar amb ells. Decidixes escriure'ls un correu electrònic en què tractes este tema. El text ha d'incloure els punts següents:",
         "points": [
          "Expressa indignació per la falta de respecte que van mostrar en la quedada.",
          "Explica de quina manera esta pràctica afecta les relacions personals.",
          "Suggerix alternatives per a pròximes reunions en què el mòbil no siga un problema."
         ]
        },
        {
         "key": "B",
         "text": "Els bons restaurants no solament han d'oferir menjar de qualitat, proporcionar als consumidors bones experiències i oferir un entorn acollidor amb una bona atenció. A més, actualment també és important que tinguen una bona valoració per part dels clients. Treballes en un restaurant i fa uns dies una persona que assegurava ser un youtuber hi va anar a dinar, i va proposar que se'l convidara a canvi de fer una valoració positiva del local. Com que et vas negar ha publicat una ressenya negativa en internet. Decidixes publicar una resposta a la ressenya en què tractes este tema. El text ha d'incloure els punts següents:",
         "points": [
          "Mostra indignació per la situació viscuda en el restaurant i les seues conseqüències.",
          "Explica de quina manera esta pràctica poc ètica afecta els restaurants.",
          "Valora la importància desmesurada que donem a les opinions dels altres consumidors."
         ]
        }
       ]
      },
      {
       "n": 8,
       "kind": "writing",
       "title": "Entrada de blog",
       "instructions": "Un dels pilars de les finances personals és estalviar. Tanmateix, quan es vol iniciar el procés sempre existixen circumstàncies que no permeten que l'estalvi cresca al ritme que t'havies proposat. A partir d'esta infografia, i com que este fet afecta moltes persones que coneixes, decidixes escriure una entrada en el teu blog en què dones algunes recomanacions que ajudaran la gent a estalviar. Explica quins són els consells que et funcionen a tu quan necessites estalviar. El text ha de tindre entre 120 i 140 paraules.",
       "min_words": 120,
       "max_words": 140,
       "image": "/exams/b2-octubre-2023/e8-estalvi.jpg",
       "image_text": "Infografia «Vols estalviar i no saps com fer-ho?» (il·lustració d'una família al costat d'una guardiola i icones de casa, menjar, estudis i salut). «Recomanacions per a elaborar una pla d'estalvi efectiu»: fes un pressupost mensual; demana crèdits de forma responsable; aprofita bé els diners extra; reduïx al mínim les despeses; disminuïx les despeses de la casa."
      }
     ]
    },
    {
     "n": 5,
     "title": "Expressió i interacció orals",
     "weight": 25,
     "duration": "25 minuts",
     "intro": "Esta àrea té dos parts: un monòleg d'uns tres minuts sobre un tema que tries i un diàleg d'uns quatre minuts amb una altra persona aspirant, en què cal arribar a un acord.",
     "exercises": [
      {
       "n": 9,
       "kind": "oral",
       "instructions": "Has de triar un tema i preparar un monòleg de tres minuts, aproximadament.",
       "proposals": [
        {
         "title": "Monòleg · La nomofòbia",
         "duration": "3 minuts",
         "intro": "Cada dia apareixen termes nous relacionats amb les noves tecnologies que ben prompte formen part de les converses diàries. Un d'estos termes és la nomofòbia, això és, l'ansietat o la por irracional de no tindre el mòbil a l'abast i sentir-se desconnectat; ara per ara, s'ha convertit en un trastorn que afecta gran part de la població. Explica quines poden ser les conseqüències socials d'este trastorn i quin sector de la població s'hi pot sentir més afectat.",
         "questions": [],
         "images": []
        },
        {
         "title": "Monòleg · Les amistats rituals",
         "duration": "3 minuts",
         "intro": "Tota la gent té un grup d'amics i amigues que només veu un parell de vegades a l'any. Es tracta d'una cita obligatòria, d'un ritual en forma de dinar o de sopar que s'ha de complir. L'amistat que es té amb este grup és diferent de la que es té amb persones més pròximes, perquè no s'hi busca una relació pregona, només un contacte circumstancial. Explica els beneficis, i també els maldecaps, que pot comportar tindre un grup d'amics i amigues amb qui practicar este tipus de ritual d'amistat.",
         "questions": [],
         "images": []
        }
       ]
      },
      {
       "n": 10,
       "kind": "oral",
       "instructions": "Has de mantindre un diàleg amb un altre o una altra aspirant sobre la situació comunicativa que et proposem. Has de defensar el paper de la teua persona i has d'arribar a un acord obligatòriament amb l'altre o l'altra aspirant. Has de participar com ho faries en una conversa habitual i les intervencions han de ser equilibrades. La duració de la conversa serà de quatre minuts, aproximadament.",
       "proposals": [
        {
         "title": "Diàleg · La telemedicina",
         "duration": "4 minuts",
         "intro": "La telemedicina i les consultes mèdiques a través de mitjans en línia ja són una realitat. L'Organització Mundial de la Salut (OMS) definix la telemedicina com l'aportació de serveis de salut amb l'ús de les noves tecnologies de la comunicació per al diagnòstic, el tractament i la prevenció de malalties o lesions.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Persona A",
           "text": "Penses que els recursos tecnològics optimitzen l'atenció, estalvien temps i costos i augmenten l'accessibilitat."
          },
          {
           "name": "Persona B",
           "text": "Penses que una atenció presencial és més eficaç, a més, no tota la població té accés a les noves tecnologies."
          }
         ]
        }
       ]
      }
     ]
    }
   ]
  }
 }
}$data$::jsonb)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  url = EXCLUDED.url,
  content = EXCLUDED.content,
  metadata = EXCLUDED.metadata,
  xp_earned = EXCLUDED.xp_earned,
  difficulty = EXCLUDED.difficulty,
  category = EXCLUDED.category;

-- ============================================================
-- Origen: 20261013200000_exam_b2_oct2022.sql
-- ============================================================
-- Examen interactiu B2 de la JQCV (octubre 2022) com a recurs de category 'examen'.
-- Contingut a metadata.exam, amb les cinc àrees del B2 i la puntuació oficial de la guia de la
-- prova (comprensió oral 8 i 12 punts per encert; comprensió escrita 3,3 i 8,5; estructures 5 i 5;
-- mínim del 40 % en cada àrea i del 50 % en l'oral). Les respostes són les de la plantilla
-- oficial que inclou el quadern. Àudio de comprensió oral a url, convertit a MP3 des de l'oficial
-- (frontend/public/audio/Audio_B2_oct2022.mp3). Font: https://jqcv.gva.es/documents/161863165/165492631/B2+octubre+2022.pdf/e2335bd4-ddb0-9b5e-e3a2-348375dca6c7

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "bff1bd62-b4b1-54fa-b8d7-563e479b4d4f",
 "name": "Simulacre B2: octubre 2022",
 "type": "jqcv_b2_oct2022",
 "category": "examen",
 "difficulty": "B2",
 "xp_earned": 40,
 "url": "/audio/Audio_B2_oct2022.mp3",
 "content": "Examen oficial B2 de la JQCV (octubre 2022): comprensió oral i escrita i estructures lingüístiques autocorregibles, dos redaccions i pràctica oral.",
 "metadata": {
  "icon": "🔌",
  "color": "#FFE0B2",
  "exam_body": "JQCV",
  "certificate_level": "B2",
  "exam": {
   "level": "B2",
   "session": "Octubre 2022",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492631/B2+octubre+2022.pdf/e2335bd4-ddb0-9b5e-e3a2-348375dca6c7",
   "audio_source_url": "https://jqcv.gva.es/documents/161863165/167041107/B2+octubre+2022.mp3/1ba6ebaf-4480-8ed0-bbbb-ba8862908bc6",
   "pass_rule": "Per a ser APTE cal una puntuació global mínima de 60 sobre 100. Les àrees valen un 20 % (comprensió oral), un 20 % (comprensió escrita), un 15 % (estructures lingüístiques), un 20 % (expressió escrita) i un 25 % (expressió oral), i en cada una cal arribar al mínim: el 40 % en les quatre primeres i el 50 % en l'expressió oral.",
   "areas": [
    {
     "n": 1,
     "title": "Comprensió oral",
     "weight": 20,
     "duration": "20 minuts",
     "audio": true,
     "intro": "Tot seguit escoltaràs dos àudios. Tots els àudios els escoltaràs dues vegades, amb una pausa entre cada audició, perquè assegures les respostes. Només hi ha una resposta correcta per a cada pregunta.",
     "scoring": {
      "points_per_exercise": {
       "1": 8,
       "2": 12
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 1,
       "kind": "choice",
       "instructions": "A continuació escoltaràs una entrevista a Aleix Eixea sobre els neandertals. Llig les preguntes i tria l’opció correcta en cada cas. Només hi ha una resposta correcta per a cada pregunta.",
       "questions": [
        {
         "n": 1,
         "prompt": "La secció de divulgació científica del programa tractarà sobre…",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "l’habitatge i els costums socials dels pobles paleolítics en terres valencianes."
          },
          {
           "key": "b",
           "text": "la troballa d’un jaciment exterior neandertal en una partida del terme d’Asp."
          },
          {
           "key": "c",
           "text": "l’ocupació del territori i el desenvolupament industrial dels pobles del paleolític."
          }
         ]
        },
        {
         "n": 2,
         "prompt": "La persona entrevistada en el programa, l’investigador Aleix Eixea…",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "és expert en migracions humanes i en assentaments prehistòrics."
          },
          {
           "key": "b",
           "text": "lidera l’equip de treball que formen les universitats d’Alacant i de València."
          },
          {
           "key": "c",
           "text": "va ser el primer expert que va catalogar les ferramentes del jaciment."
          }
         ]
        },
        {
         "n": 3,
         "prompt": "Aquest jaciment d’Asp es considera tan important perquè...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "es localitza en un entorn natural on també hi havia altres jaciments."
          },
          {
           "key": "b",
           "text": "proporciona informació nova sobre l’estil de vida a les coves."
          },
          {
           "key": "c",
           "text": "dona dades sobre les tasques que els neandertals feien a l’exterior."
          }
         ]
        },
        {
         "n": 4,
         "prompt": "El treball de camp que fan els investigadors al jaciment...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "es desenvolupa al llarg de tot l’any, excepte als mesos d’estiu."
          },
          {
           "key": "b",
           "text": "consisteix a localitzar-ne la ubicació i extraure’n els materials."
          },
          {
           "key": "c",
           "text": "inclou totes les tasques fins a arribar a la publicació de resultats."
          }
         ]
        },
        {
         "n": 5,
         "prompt": "Es pensa que aquest jaciment era per als neandertals...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "l’indret on passaren una estada durant el seu camí cap a la costa."
          },
          {
           "key": "b",
           "text": "l’hàbitat on van establir la seua residència habitual des del principi."
          },
          {
           "key": "c",
           "text": "un assentament puntual al qual van acudir de manera recurrent."
          }
         ]
        }
       ]
      },
      {
       "n": 2,
       "kind": "binary",
       "instructions": "Llig els enunciats i relaciona’ls amb els consells que escoltaràs en les audicions per a estalviar en el consum d’energia i rebaixar l’import final de la factura de la llum. Tin en compte que hi ha dos enunciats que no corresponen a cap consell: marca «No surt» en eixos dos i numera la resta de l’1 al 5 seguint l’ordre en què apareixen en l’àudio.",
       "options": [
        {
         "key": "1",
         "text": "1"
        },
        {
         "key": "2",
         "text": "2"
        },
        {
         "key": "3",
         "text": "3"
        },
        {
         "key": "4",
         "text": "4"
        },
        {
         "key": "5",
         "text": "5"
        },
        {
         "key": "x",
         "text": "No surt"
        }
       ],
       "questions": [
        {
         "n": 6,
         "prompt": "S’aconsella, sempre que es puga, desconnectar els aparells de casa de la xarxa elèctrica, fins i tot quan estiguen apagats.",
         "answer": "5"
        },
        {
         "n": 7,
         "prompt": "No només hem de programar els electrodomèstics en les hores vall, sinó que també ens hem de fixar en l’eficiència dels aparells.",
         "answer": "3"
        },
        {
         "n": 8,
         "prompt": "Una mesura per a estalviar energia és fer un ús més puntual dels aparells que més consumeixen, com la rentadora i el llavaplats.",
         "answer": "x",
         "scored": false
        },
        {
         "n": 9,
         "prompt": "Si tenim un coneixement acurat de les tarifes podem triar de manera correcta la que més s’ajuste a les nostres necessitats de consum.",
         "answer": "1"
        },
        {
         "n": 10,
         "prompt": "Si es contracta la potència elèctrica més adequada a cada habitatge, l’import total de la factura es pot reduir en un 7 %.",
         "answer": "x",
         "scored": false
        },
        {
         "n": 11,
         "prompt": "Regular de manera adequada la temperatura dels sistemes i aparells de calor implicarà un estalvi econòmic significatiu.",
         "answer": "2"
        },
        {
         "n": 12,
         "prompt": "En els casos en què la instal·lació siga només elèctrica, l’import de la factura serà menor si es revisa la potència contractada.",
         "answer": "4"
        }
       ]
      }
     ]
    },
    {
     "n": 2,
     "title": "Comprensió escrita",
     "weight": 20,
     "duration": "2 h 10 min (amb les àrees 3 i 4)",
     "scoring": {
      "points_per_exercise": {
       "3": 3.3,
       "4": 8.5
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 3,
       "kind": "match",
       "instructions": "Llig atentament el text següent i completa’l amb les propostes de la graella. Tin en compte que hi ha tres propostes que no has d’utilitzar.",
       "reading": {
        "title": "El punt de partida: l'espai públic",
        "paragraphs": [
         "L'espai públic pot ser definit d'una manera tan senzilla com ara el lloc on es troben dos desconeguts. La diferència entre públic i privat està en la quantitat de coneixement que una persona o un grup té sobre els altres. En l'àmbit privat, com ara en una família, normalment coneixem els altres molt bé i de prop, (13) ______ en l'àmbit públic no és així. En l'espai públic, el coneixement incomplet s'adiu amb l'anonimat.",
         "L'espai públic és, (14) ______, un lloc. Tradicionalment, aquest lloc s'havia definit a partir de la seua localització física i, per això, les (15) ______ sobre l'espai públic han estat, també tradicionalment, lligades a les ciutats: l'espai públic s'identificava amb les places, els carrers, els teatres, els cafés, les sales de conferències o les seus governamentals, llocs on gent desconeguda podia trobar-se fàcilment. Hui en dia, les tecnologies de la informació han alterat de manera radical el sentit de lloc: ara l'espai públic el trobem tant al ciberespai com, literalment, al lloc físic.",
         "La qüestió més important sobre l'espai públic és entendre que hi passa. Posar desconeguts en contacte permet un cert tipus d'activitats que no es donen o que no és tan fàcil que es donen en la intimitat de l'esfera (16) ______. En públic, la gent pot accedir a un nou coneixement i (17) ______ així els horitzons de la seua quantitat d'informació. Els mercats depenen d'aquests horitzons d'informació en expansió. En públic, la gent pot parlar i debatre amb altra gent amb qui potser no comparteix punts de vista o interessos. El govern democràtic depén d'aquesta mena d'intercanvis entre desconeguts. L'àmbit públic ofereix a la gent la possibilitat de no estar tan sotmesa a la pressió de la conformitat amb l'entorn, a no haver d'(18) ______ un rol (19) ______ en l'ordre social. L'anonimat i la impersonalitat proporcionen un entorn adequat per al desenvolupament individual. Aquesta possibilitat d'(20) ______ una vida nova entre desconeguts ha empés milers de migrants cap a les ciutats.",
         "Una de les escoles modernes de pensament que han provat d’explicar l’espai públic s’identifica amb els escrits de Hanna Arendt. Aquesta autora pensa en l'espai públic sobretot en termes polítics, tot i que entén la política d'una manera (21) ______. Imagina un àmbit (22) ______ en el qual les persones puguen enraonar i debatre de manera lliure. Per a aconseguir-ho, cal que deixen de banda les seues circumstàncies personals i privades. Aquesta idea és potent: siguen quins siguen els orígens, el gènere, l'estil de vida o la classe, tothom hauria de tindre la mateixa veu com a ciutadans, perquè les (23) ______ privades no tenen cabuda en l'espai públic. Va ser amb aquest projecte tan vigorós que Arendt va desafiar el concepte de nacionalitat o de raça com a base de la ciutadania a l'Alemanya nazi. Hui, a les democràcies occidentals, se la considera la bèstia negra de la política (24) ______."
        ]
       },
       "options_title": "Propostes",
       "options": [
        {
         "key": "a",
         "text": "reduir"
        },
        {
         "key": "b",
         "text": "encetar"
        },
        {
         "key": "c",
         "text": "lluites"
        },
        {
         "key": "d",
         "text": "fix"
        },
        {
         "key": "e",
         "text": "disquisicions"
        },
        {
         "key": "f",
         "text": "àmplia"
        },
        {
         "key": "g",
         "text": "ideal"
        },
        {
         "key": "h",
         "text": "a més"
        },
        {
         "key": "i",
         "text": "circumstàncies"
        },
        {
         "key": "j",
         "text": "no obstant això"
        },
        {
         "key": "k",
         "text": "privada"
        },
        {
         "key": "l",
         "text": "mentre que"
        },
        {
         "key": "m",
         "text": "adoptar"
        },
        {
         "key": "n",
         "text": "identitària"
        },
        {
         "key": "o",
         "text": "expandir"
        }
       ],
       "questions": [
        {
         "n": 13,
         "prompt": "Buit 13",
         "answer": "l"
        },
        {
         "n": 14,
         "prompt": "Buit 14",
         "answer": "h"
        },
        {
         "n": 15,
         "prompt": "Buit 15",
         "answer": "e"
        },
        {
         "n": 16,
         "prompt": "Buit 16",
         "answer": "k"
        },
        {
         "n": 17,
         "prompt": "Buit 17",
         "answer": "o"
        },
        {
         "n": 18,
         "prompt": "Buit 18",
         "answer": "m"
        },
        {
         "n": 19,
         "prompt": "Buit 19",
         "answer": "d"
        },
        {
         "n": 20,
         "prompt": "Buit 20",
         "answer": "b"
        },
        {
         "n": 21,
         "prompt": "Buit 21",
         "answer": "f"
        },
        {
         "n": 22,
         "prompt": "Buit 22",
         "answer": "g"
        },
        {
         "n": 23,
         "prompt": "Buit 23",
         "answer": "i"
        },
        {
         "n": 24,
         "prompt": "Buit 24",
         "answer": "n"
        }
       ]
      },
      {
       "n": 4,
       "kind": "match",
       "instructions": "A continuació llegiràs diverses crítiques musicals. Relaciona-les amb els enunciats. Hi ha tres enunciats que no corresponen a cap crítica musical.",
       "options_title": "Enunciats",
       "options": [
        {
         "key": "a",
         "text": "Un cant a l’evolució cap a la maduresa, un elogi a la senzillesa de cada dia."
        },
        {
         "key": "b",
         "text": "La creativitat sembla inesgotable per a un duet que torna a sorprendre’ns."
        },
        {
         "key": "c",
         "text": "L’artista de trajectòria consolidada s’envolta de col·laboradors excepcionals."
        },
        {
         "key": "d",
         "text": "Un àlbum compromés amb els problemes socials dels nostres dies."
        },
        {
         "key": "e",
         "text": "El trio ens sorprén amb un àlbum en què la melodia es barreja amb tocs de bossa nova."
        },
        {
         "key": "f",
         "text": "El debut discogràfic d’aquesta parella musical suggereix un món de conte."
        },
        {
         "key": "g",
         "text": "Aquest recull de temes molt personals podrien convertir-se en un himne generacional."
        },
        {
         "key": "h",
         "text": "Aquest àlbum recopilatori esdevé imprescindible per als amants d’aquest conjunt mític."
        },
        {
         "key": "i",
         "text": "Un treball artístic fruit de l’estima pel lirisme i d’una preparació excel·lent."
        },
        {
         "key": "j",
         "text": "L’artista crea un còctel de sensacions sense allunyar-se del seu paisatge més immediat."
        }
       ],
       "questions": [
        {
         "n": 25,
         "prompt": "Òscar Peris és un jove cantant valencià que es va donar a conéixer fa dos anys amb el disc Zero per infinit. I no ha passat molt de temps abans de presentar-nos aquest nou treball, amb unes cançons prou elaborades, tant melòdicament com pel que fa al text, i cantades amb una veu nasal ben particular. Acompanyat per l’instrumentista Roger Gascon, Òscar ens ofereix unes cançons que mostren les seues preocupacions, sobretot pel que fa a la situació de la llengua (\"Emergència lingüística\"). Si a \"Un noi de poble\" es fa ressò dels resultats polítics del populisme, a \"Socialisme espiritual\" somnia en un nou sistema que supere els encotillaments actuals.",
         "answer": "d"
        },
        {
         "n": 26,
         "prompt": "Voraigua és un duet format per Muntsa Moral i Paul Perera que s'estrena discogràficament amb aquest àlbum, Meandres, bastit al voltant del tema de l'aigua. Comença amb uns tocs de flamenc, que després es transformen en una mena de cant que crea un clima de llegenda. De vegades, la veu masculina i la femenina es combinen, però el més habitual és que la Muntsa Moral exhibisca en solitari les seues possibilitats vocals, més lligades a la sensibilitat que no a la potència, i que arriben sovint a un gran nivell expressiu, en un bell diàleg amb el piano de Pau Perera. Un àlbum molt suggeridor, que vessa sensibilitat.",
         "answer": "f"
        },
        {
         "n": 27,
         "prompt": "Els últims àlbums d'Enric Hernàez eren Prop la via del tren (2017) i Himnes (2019)... Ara arriba aquest 10 cançons amb els teclats i les guitarres d'Enric, la percussió d'Álvaro Pérez i la guitarra de Mario Maeso. Mario és l’autor de \"Divan\", l'únic tema que no està signat pel cantant, a banda de \"Cara\", un tema compost sobre un text de Mercè Serramalera, que hi posa la veu. Hernàez observa, sent, juxtaposa imatges tot creant ambients i sensacions, i sense fer cap judici, tot i que a \"Les trompetes de Jericó (pregària per la desaparició de Donald Trump)\" mostra una indignació apocalíptica, matisada per un rerefons jazzístic.",
         "answer": "c"
        },
        {
         "n": 28,
         "prompt": "Sequoia és un grup format per Víctor Llonch, Edu Vilardaga i Ramon Pedret. En el seu primer disc, Vint-i-pocs, reflexionen sobre la joventut des de la joventut, i presenten una estètica lligada als referents folk, sense oblidar algunes escapades cap a la música electrònica. A més, escriuen uns textos interessants que volen reproduir sovint les petites coses de la vida quotidiana (en aquest sentit, \"Van ser molts anys\" és una petita joia). Són cançons que fan sentir el pas de l'adolescència a l'edat adulta, de les emocions pures a la seua gestió intel·lectual. Algunes cançons són en anglés, però la major part estan escrites i cantades en català.",
         "answer": "a"
        },
        {
         "n": 29,
         "prompt": "En pocs anys, la jove Gemma Humet s'ha consolidat com una de les nostres veus més interessants, però en aquest últim disc aferma també el seu talent com a autora i compositora. L'àlbum Màtria està plantejat des d'una sensibilitat feminista polièdrica. S'obri amb un breu poema de Maria-Mercè Marçal (\"Damunt un cel de fil\") i es tanca amb un text (\"Mare\") que mira de fer compatibles els lligams teixits per l'amor i els anhels de llibertat. Entre la tendresa i la revolta, elabora un discurs poètic coratjós i estèticament atractiu, gràcies a una veu que posa la tècnica al servei de la comunicació i a unes línies melòdiques encertades.",
         "answer": "i"
        },
        {
         "n": 30,
         "prompt": "En Manel Joseph és un tot terreny incombustible i Postal de la Mediterrània és un dels seus millors treballs i el més unitari, basat en textos de Manuel Dolz i música del saxofonista Pep Torres. Es tracta d'un recorregut tant geogràfic com musical per la Mediterrània en el qual la preciosa cançó \"Mercè\" clava les arrels en la bossa nova. Els textos de Dolz parlen de vides que es troben i se separen, del mar que ens bressola i del dolor que s'hi passeja, de la vida que fa mal, però que ens obliga a estimar-la amb passió.",
         "answer": "j"
        },
        {
         "n": 31,
         "prompt": "Xavier Carles i Xavier Batllés no descansen: pocs mesos després del seu quart àlbum conjunt, arriba Ànima nua, en el qual Xavier Carles s'anima a cantar. Com sempre, la música impecable de Xavier Batllés, que disposa de selectes col·laboradors, cantants i instrumentistes, es posa al servei de la paraula. L'àlbum és una passejada a la recerca de la bellesa, una reivindicació de la llibertat creativa i de les possibilitats del mot i del so. Un dels moments més curiosos del disc és \"Sospirança\", una meditació sobre com haurien de ser els arranjaments de l'anomenada \"cançó d'autor\", i de com la paraula i la música s'han de relacionar mútuament.",
         "answer": "b"
        }
       ]
      }
     ]
    },
    {
     "n": 3,
     "title": "Estructures lingüístiques",
     "weight": 15,
     "duration": "2 h 10 min (amb les àrees 2 i 4)",
     "scoring": {
      "points_per_exercise": {
       "5": 5,
       "6": 5
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 5,
       "kind": "choice",
       "instructions": "En el següent text s’han eliminat algunes paraules. Per a cada espai en blanc tens tres opcions de resposta. Només una és correcta. Fixa’t en l’exemple (número 0).",
       "reading": {
        "title": "Neveres",
        "paragraphs": [
         "La tardor, enguany, ha volgut (0) assemblar-se a les tardors d'abans: càlida alguns dies, però en general fresca i plujosa. Si les previsions no fallen, la dinàmica de l'hivern serà pareguda, és a dir, relativament normal: les temperatures no (32) ______ massa altes i tindríem episodis de precipitacions que, de tant en tant, caurien en forma de neu a l'interior del nostre país. Ara tenim radars, satèl·lits i nombrosos instruments que ens (33) ______ seguir i pronosticar els fenòmens atmosfèrics amb un grau d'encert molt elevat, però el canvi climàtic ens convida a ser prudents i estar a l'expectativa, com ens recorda l'experiència recent de la borrasca Filomena. Siga com siga, la capacitat d'anàlisi i previsió és espectacular si la comparem amb la del món preindustrial.",
         "(34) ______, antigament la gent també aconseguia domesticar els efectes de la meteorologia, probablement sense la voracitat que ens ha dut a la crisi actual. Un dels testimonis més interessants d'això són les nombroses neveres que s'escampen pel nostre territori. La neu sempre s'havia utilitzat per a finalitats terapèutiques i per a conservar i transportar aliments, però les baixes temperatures que es van registrar a Europa durant l'edat moderna (coneguda com la petita edat de gel) (35) ______ encara més els usos de la neu, que es podia emmagatzemar relativament prop de la costa, com demostra el cas de la nevera de la Murta, molt prop d'Alzira. (36) ______, les neveres, caves, clots i pous solen trobar-se una miqueta més retirades, enfilades a les muntanyes (com la cèlebre Cava Arquejada d'Agres) o construïdes en valls i fondalades (com la Cava de Sant Blai de Bocairent). Les més abundants i famoses es troben a les comarques de la Marina, la Vall d'Albaida, el Comtat i l'Alcoià, (37) ______ pot estar àmpliament relacionat amb la indústria del gelat i l'extraordinària aventura comercial dels fundadors d'orxateries (només (38) ______ pensar en les referències als pobles i als cognoms de la zona en el nom de nombrosos establiments: Ibense, Xixonenca, Sirvent, Planelles, etc.). Però, de neveres, (39) ______ en quasi totes les zones de muntanya del nostre territori, des de la Safor fins a les serres del nord, on trobem la nevera dels Regatxols a Ares o la de Castro a Alfondeguilla.",
         "D'aquests pous de gel no tan coneguts, voldria (40) ______ un, el de Tuéjar (Toixa), situat al camí que va des de l'assut homònim fins a la font d'Arquela, ja en terme d'Alpuente (Alpont). Com totes aquestes construccions, sobreïx la part superior de la nevera, una mena de casup de pedra, de planta redona i rematat amb una coberta que té forma de volta. En una de les parets, observem una porta per a accedir al pou pròpiament dit, que sovint té més de set metres de fondo.",
         "Més enllà de constatar que el comerç de la neu s'escampava per tot l'antic Regne de València, la visita a la nevera de Tuéjar ens convida a recórrer un paratge bellíssim, amb cingles imponents, dominats pels voltors, i amb una vegetació exuberant, fruit de l'abundància de rierols, fonts i barrancs. I, encara més, ens convida (41) ______ coneguem millor els Serrans, una comarca en certa mesura oblidada, que reclama el seu lloc en l'imaginari col·lectiu i en la realitat mediambiental, cultural i econòmica dels valencians."
        ]
       },
       "questions": [
        {
         "n": 32,
         "prompt": "Buit 32",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "serien"
          },
          {
           "key": "b",
           "text": "foren"
          },
          {
           "key": "c",
           "text": "sigueren"
          }
         ]
        },
        {
         "n": 33,
         "prompt": "Buit 33",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "permitiran"
          },
          {
           "key": "b",
           "text": "permeteixen"
          },
          {
           "key": "c",
           "text": "permeten"
          }
         ]
        },
        {
         "n": 34,
         "prompt": "Buit 34",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Malauradament"
          },
          {
           "key": "b",
           "text": "Tanmateix"
          },
          {
           "key": "c",
           "text": "Per això"
          }
         ]
        },
        {
         "n": 35,
         "prompt": "Buit 35",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "devien d’estimular"
          },
          {
           "key": "b",
           "text": "devien estimular"
          },
          {
           "key": "c",
           "text": "havien d’estimular"
          }
         ]
        },
        {
         "n": 36,
         "prompt": "Buit 36",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Per descomptat"
          },
          {
           "key": "b",
           "text": "Fet i fet"
          },
          {
           "key": "c",
           "text": "Amb tot"
          }
         ]
        },
        {
         "n": 37,
         "prompt": "Buit 37",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "fet que"
          },
          {
           "key": "b",
           "text": "cosa que"
          },
          {
           "key": "c",
           "text": "la qual cosa"
          }
         ]
        },
        {
         "n": 38,
         "prompt": "Buit 38",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "hi ha que"
          },
          {
           "key": "b",
           "text": "es deu de"
          },
          {
           "key": "c",
           "text": "cal"
          }
         ]
        },
        {
         "n": 39,
         "prompt": "Buit 39",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "hi havia"
          },
          {
           "key": "b",
           "text": "n’hi havia"
          },
          {
           "key": "c",
           "text": "havia"
          }
         ]
        },
        {
         "n": 40,
         "prompt": "Buit 40",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "destacar-hi"
          },
          {
           "key": "b",
           "text": "destacar-ne"
          },
          {
           "key": "c",
           "text": "destacar"
          }
         ]
        },
        {
         "n": 41,
         "prompt": "Buit 41",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "que"
          },
          {
           "key": "b",
           "text": "a què"
          },
          {
           "key": "c",
           "text": "a que"
          }
         ]
        }
       ]
      },
      {
       "n": 6,
       "kind": "choice",
       "instructions": "En el següent text s’han eliminat algunes paraules. Per a cada espai en blanc tens tres opcions de resposta. Només una és correcta. Fixa’t en l’exemple (número 0).",
       "reading": {
        "title": "Vestir a la moda? TikTok sap com fer-ho",
        "paragraphs": [
         "Vestir amb americanes, texans acampanats o faldilles curtes ja no és (0) trencador. En canvi, si ho combines amb una cotilla exterior i unes ballarines que recorden les que (42) ______ Natalie Portman al thriller psicològic El cigne negre, ja és una altra cosa: vas a la moda. Com que l’estil hegemònic popularitzat durant els anys 60, 70 o 80 ja forma part de la nostra indumentària habitual, necessitem elements innovadors que ens deixen sentir que, a part de revisitar les tendències passades, també n’estem generant de noves. Xarxes socials com TikTok o Instagram (43) ______ aquest fenomen i s’encarreguen de popularitzar estils i predir tendències basades tant en l’opinió dels usuaris com en la cultura pop que els envolta: el vestuari de pel·lícules, de sèries, de (44) ______, etc. Només cal que es popularitze una sèrie ambientada en l’època victoriana -com és el cas de The Bridgerton- perquè aquella estètica concreta es torne a posar de moda.",
         "(45) ______ amb noms com regencycore, cottagecore o balletcore, en TikTok trobem ara aquestes tendències en les quals predomina la nostàlgia femenina i la romantització d’èpoques passades, ja siga la dècada dels 70 o l’any 2015. L’experta en tendències i moda juvenil Anna Pompilio ho vincula a la (46) ______ que ens acompanya des de l’inici de la pandèmia: “Aquests dos últims anys han estat plens de precarietat i dubtes, per això veiem com els joves busquen estètiques que els resulten còmodes i els ajuden a escapar de l’ansietat quotidiana”.",
         "TikTok és una eina digital acceleradora del consum que s’ha convertit en el lloc perfecte perquè s’hi generen i hi habiten les tendències. “Com que en aquesta aplicació constantment s’hi promou la novetat, és molt difícil que les modes s’establisquen i s’estabilitzen, perquè el mercat està sempre canviant”, apunta Isa Uribé, consultora de moda i professora de tendències i estilisme. Això provoca una reducció de la durada de les tendències, ara considerades (47) ______, que viuen entre 1 i 5 mesos i muten en funció dels discursos en línia predominants. Aquesta (48) ______ alimenta un consum massiu i molt poc (49) ______ al qual tothom té accés de manera fàcil i ràpida. Tal com apunta Rebecca Jennings, periodista especialitzada en creació de contingut en línia, “les xarxes socials han permés que gent completament desvinculada del sector puga determinar noves modes tot (50) ______ els emissors tradicionals de tendències”. L'accessibilitat i l’algoritme de TikTok desplacen l’hegemonia comunicativa de mitjans com les revistes de moda i obrin la porta a milions de persones que, des de qualsevol lloc, calibren i prediuen aquestes tendències amb la credibilitat que la viralitat del seu contingut els atorga. No obstant això, Jennings també fa referència a l’efecte contrari causat per aquest consum tan fugaç: “La tendència en qüestió s’explota amb tanta intensitat i apareix en tants vídeos que ràpidament se satura. Allò que feia dues setmanes era completament nou ara ja ho hem vist en tots els perfils de TikTok i ja no m’interessa vestir-ho”. D'exemples, podem trobar-ne (51) ______: els anells de plàstic, els tops de ganxet o les bosses peludes."
        ]
       },
       "questions": [
        {
         "n": 42,
         "prompt": "Buit 42",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "lluïa"
          },
          {
           "key": "b",
           "text": "lluía"
          },
          {
           "key": "c",
           "text": "lluia"
          }
         ]
        },
        {
         "n": 43,
         "prompt": "Buit 43",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "ampraren"
          },
          {
           "key": "b",
           "text": "emparen"
          },
          {
           "key": "c",
           "text": "empraren"
          }
         ]
        },
        {
         "n": 44,
         "prompt": "Buit 44",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "pasarel·les"
          },
          {
           "key": "b",
           "text": "passareles"
          },
          {
           "key": "c",
           "text": "passarel·les"
          }
         ]
        },
        {
         "n": 45,
         "prompt": "Buit 45",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Batetjades"
          },
          {
           "key": "b",
           "text": "Batejades"
          },
          {
           "key": "c",
           "text": "Bategades"
          }
         ]
        },
        {
         "n": 46,
         "prompt": "Buit 46",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "incertessa"
          },
          {
           "key": "b",
           "text": "incertea"
          },
          {
           "key": "c",
           "text": "incertesa"
          }
         ]
        },
        {
         "n": 47,
         "prompt": "Buit 47",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "microtendències"
          },
          {
           "key": "b",
           "text": "micro-tendències"
          },
          {
           "key": "c",
           "text": "micro tendències"
          }
         ]
        },
        {
         "n": 48,
         "prompt": "Buit 48",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "efervecència"
          },
          {
           "key": "b",
           "text": "efervessència"
          },
          {
           "key": "c",
           "text": "efervescència"
          }
         ]
        },
        {
         "n": 49,
         "prompt": "Buit 49",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "rentable"
          },
          {
           "key": "b",
           "text": "sostenible"
          },
          {
           "key": "c",
           "text": "rendible"
          }
         ]
        },
        {
         "n": 50,
         "prompt": "Buit 50",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "obviant"
          },
          {
           "key": "b",
           "text": "coneixent"
          },
          {
           "key": "c",
           "text": "obeint"
          }
         ]
        },
        {
         "n": 51,
         "prompt": "Buit 51",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "a bastament"
          },
          {
           "key": "b",
           "text": "a doll"
          },
          {
           "key": "c",
           "text": "a borbollons"
          }
         ]
        }
       ]
      }
     ]
    },
    {
     "n": 4,
     "title": "Expressió i interacció escrites",
     "weight": 20,
     "duration": "2 h 10 min (amb les àrees 2 i 3)",
     "exercises": [
      {
       "n": 7,
       "kind": "writing",
       "title": "Redacció",
       "instructions": "Tria una de les dos opcions i redacta un text que tinga entre 180 i 220 paraules.",
       "min_words": 180,
       "max_words": 220,
       "choices": [
        {
         "key": "A",
         "text": "L'augment exponencial dels costos de producció provoca que moltes empreses facen tots els possibles per a no perdre diners. Un dels mètodes més habituals és oferir menys producte al mateix preu, però sense canviar la grandària de l’envàs original. Has detectat que l’última ampolla de xampú de la teua marca de confiança costa el mateix de sempre, però conté 50 ml menys. Decideixes enviar un correu electrònic al servei d’atenció al client de l’empresa per a fer-los arribar una queixa.",
         "points": [
          "Mostra indignació per la pujada encoberta del preu d’aquest producte.",
          "Explica de quina manera aquesta pràctica afecta l’economia domèstica.",
          "Suggereix alternatives per a una pràctica comercial més transparent."
         ]
        },
        {
         "key": "B",
         "text": "Els museus han experimentat una diversificació en els últims anys per tal de mantindre el nombre de visitants. La funció purament expositiva ha donat lloc a altres usos enfocats a accions més lúdiques i comercials. Pertanys a l’associació Amics dels Museus i t’han encomanat que escrigues un article d’opinió que es publicarà en el web de l’associació, en què reflexiones sobre aquest fenomen.",
         "points": [
          "La digitalització dels fons permet fer visites virtuals sense haver d’eixir de casa.",
          "Els restaurants i les botigues dels museus són el reclam per a visitar-los.",
          "El futur dels museus com a espai polivalent que reuneix cultura i oci."
         ]
        }
       ]
      },
      {
       "n": 8,
       "kind": "writing",
       "title": "Text per a un diari digital",
       "instructions": "El diari digital Al Dia demana la participació dels lectors i de les lectores per a elaborar una secció en què s’expliquen algunes fórmules i estratègies per a aconseguir desconnectar dels elements i de les situacions que ens causen estrés, com les preocupacions laborals o les notícies roïnes sobre l’actualitat. A partir d’aquests dibuixos, envia un text per al diari en què opines sobre aquest fenomen, i explica quines són les alternatives que et funcionen quan vols evadir-te de les preocupacions del dia a dia. El text ha de tindre entre 120 i 140 paraules.",
       "min_words": 120,
       "max_words": 140,
       "image": "/exams/b2-octubre-2022/e8-desconnectar.jpg",
       "image_text": "Dos dibuixos. Primer dibuix (fet a mà): dues persones assegudes d'esquena en un sofà (rètol «Sofà»), amb les cames encongides, mirant una televisió encesa (rètol «Sèries»); a la dreta, una finestra per on es veu l'exterior, assenyalat amb una fletxa i el rètol «Caos». Segon dibuix (il·lustració): un home d'esquena, amb barret i camisa estampada, que alça els braços amb alegria davant d'un paisatge de platja amb palmera, para-sol, núvols, sol i un castell d'arena; al seu costat hi ha una maleta amb rodes, una bossa de viatge, una pilota i un poal amb una pala (vacances, viatge)."
      }
     ]
    },
    {
     "n": 5,
     "title": "Expressió i interacció orals",
     "weight": 25,
     "duration": "25 minuts",
     "intro": "Esta àrea té dos parts: un monòleg d'uns tres minuts sobre un tema que tries i un diàleg d'uns quatre minuts amb una altra persona aspirant, en què cal arribar a un acord.",
     "exercises": [
      {
       "n": 9,
       "kind": "oral",
       "instructions": "Has de triar un tema i preparar un monòleg de tres minuts, aproximadament.",
       "proposals": [
        {
         "title": "Monòleg · La reducció de l’horari laboral",
         "duration": "3 minuts",
         "intro": "La disminució de l’horari de treball és una qüestió que fa temps que està plantejada, però que avança amb dificultat perquè hi ha molts interessos en contra, malgrat que existeix també molta evidència que demostra que pot millorar el benestar dels treballadors i treballadores. Explica quins són els avantatges que tindria una reducció dels horaris laborals i quins problemes podria comportar.",
         "questions": [],
         "images": []
        },
        {
         "title": "Monòleg · Un amic és un tresor?",
         "duration": "3 minuts",
         "intro": "L’amistat és un factor important per al benestar, mentre que la solitud i l’aïllament social s’associen amb un risc més alt de patir trastorns com la depressió o l’ansietat. De la mateixa manera que disposem d’orientacions i recomanacions sobre el nombre d’hores que convé dormir i l’activitat física que hem de fer, aquest també és un tema rellevant per a la salut. Explica quins beneficis aporta el fet de tindre amics i quins problemes ens pot ocasionar no triar-los bé.",
         "questions": [],
         "images": []
        }
       ]
      },
      {
       "n": 10,
       "kind": "oral",
       "instructions": "Has de mantindre un diàleg amb una altra o un altre aspirant sobre la situació comunicativa que et proposem. Has de defensar el paper de la teua persona i has d'arribar a un acord obligatòriament amb l’altra o l’altre aspirant.",
       "proposals": [
        {
         "title": "Diàleg · Visibilitat en les xarxes socials",
         "duration": "4 minuts",
         "intro": "Una persona influenciadora amb més de 30.000 seguidors i seguidores en Instagram proposa al propietari o propietària d’un restaurant un intercanvi: dos menús degustació debades a canvi d’una ressenya amb fotografies sobre el negoci.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Persona A",
           "text": "Eres un influenciador o influenciadora que té més de 30.000 seguidors i seguidores en Instagram. Proposes al propietari o propietària d’un restaurant un intercanvi: que t’oferisca debades dos menús degustació a canvi de publicar ell o ella una ressenya amb fotografies sobre el seu negoci. Penses que la publicació podria donar-li molta visibilitat. A més, consideres que la despesa dels dos menús es podria veure com una inversió en publicitat."
          },
          {
           "name": "Persona B",
           "text": "Tens un restaurant i contacta amb tu una persona que té més de 30.000 seguidors i seguidores en Instagram. Et vol proposar un intercanvi: que li oferisques menjar debades dos menús degustació a canvi de publicar ell o ella una ressenya amb fotografies sobre el teu negoci. Penses que aquest influenciador o influenciadora simplement vol dinar gratis al teu restaurant. A més, consideres que aquesta visibilitat no es traduirà en un increment significatiu de clientela."
          }
         ]
        }
       ]
      }
     ]
    }
   ]
  }
 }
}$data$::jsonb)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  url = EXCLUDED.url,
  content = EXCLUDED.content,
  metadata = EXCLUDED.metadata,
  xp_earned = EXCLUDED.xp_earned,
  difficulty = EXCLUDED.difficulty,
  category = EXCLUDED.category;

