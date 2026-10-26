# Gramàtiques normatives de l'AVL i temaris dels Quaderns JQCV

Els fitxers `gvb.html`, `gnv.html` i les versions de text són còpies locals de les fonts normatives de l'AVL,
descarregades l'1 d'octubre de 2026. Són la referència per a les regles gramaticals de les lliçons fixes
(«Aprendre lliçó») de morfosintaxi i de fonètica, elocució i ortografia. Els Quaderns de nivell de la JQCV
no són una font normativa: els apartats 3.2 delimiten el temari, el nivell i l'àrea de cada activitat de llengua;
els objectius de les altres àrees delimiten les destreses que s'hi practiquen. La correcció lingüística es verifica
amb l'AVL (GVB/GNV i DNV, segons el cas). L'app no consulta l'AVL en temps real: el contingut de cada lliçó està en
`resources.metadata.lesson` (migracions `20261001160000_llicons_morfosintaxi_b1.sql` i
`20261001180000_llicons_fonetica_b1.sql`; en el B2, `20261013150000_llicons_morfosintaxi_b2.sql` i
`20261013140000_llicons_fonetica_b2.sql`; en el C1, `20261014180000_llicons_morfosintaxi_c1.sql` i
`20261014170000_llicons_fonetica_c1.sql`; en el C2, `20261027130000_llicons_morfosintaxi_c2.sql` i
`20261026120000_llicons_fonetica_c2.sql` (l'abast de cada contingut està descrit en les seues migracions de pràctica). Els exercicis que contradeien l'AVL es corregixen en
`20261001170000_correccio_exercicis_avl.sql` i `20261001190000_correccio_exercicis_fonetica_avl.sql`.

| Fitxer | Contingut | Font |
| --- | --- | --- |
| `gvb.html` | *Gramàtica valenciana bàsica* sencera (HTML original) | Gramàtic-On de l'AVL, `getContent.jsp?key=GVB` amb la sessió en GVB |
| `gnv.html` | *Gramàtica normativa valenciana* sencera (HTML original) | Gramàtic-On de l'AVL, `getContent.jsp?key=GNV` amb la sessió en GNV |
| `gvb.txt`, `gnv.txt` | Les mateixes gramàtiques en text pla, amb els números d'apartat (`#`, `##`, `###`), exemples (`>`), observacions (`[OBS]`) i taules (`|`) | Generats a partir dels HTML |
| `quadern_b1_morfosintaxi.txt` | Apartat 3.2.2 Morfosintaxi del Quadern de nivell B1 (2024) |
| `quadern_b1_fonetica.txt` | Apartat 3.2.1 Fonètica, elocució i ortografia del Quadern de nivell B1 (2024) | [JQCV](https://jqcv.gva.es/va/nivell-b1) |
| `quadern_b1_lexic.txt` | Apartat 3.2.3 Lèxic i semàntica del Quadern de nivell B1 (2024) | [JQCV](https://jqcv.gva.es/va/nivell-b1) |
| `quadern_b2_fonetica.txt`, `quadern_b2_morfosintaxi.txt`, `quadern_b2_lexic.txt` | Apartats 3.2.1, 3.2.2 i 3.2.3 del Quadern de nivell B2. Un resum dels del B1 i del B2 és en les rúbriques de `backend/src/services/examWritingEvaluator.ts` («elements del nivell») | JQCV |
| `quadern_c1_fonetica.txt`, `quadern_c1_morfosintaxi.txt`, `quadern_c1_lexic.txt` | Apartats 3.2.1, 3.2.2 i 3.2.3 del Quadern de nivell C1 | JQCV |
| `quadern_c2_fonetica.txt`, `quadern_c2_morfosintaxi.txt`, `quadern_c2_lexic.txt` | Apartats 3.2.1, 3.2.2 i 3.2.3 del Quadern de nivell C2 definitiu; font original: `C2 Quadern de nivell_JQCV (COACV) (DEFINITIU).pdf` | JQCV |

Enllaç públic a una fitxa: `https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=<clau>`.
