# Gramàtiques de l'AVL i Quadern B1 (fonts de les lliçons)

Còpia local, descarregada una sola vegada l'1 d'octubre de 2026, de les fonts amb què
s'han redactat les lliçons fixes («Aprendre lliçó») del B1 de Morfosintaxi i de Fonètica,
elocució i ortografia. L'app no consulta l'AVL: el contingut de cada lliçó està en
`resources.metadata.lesson` (migracions `20261001160000_llicons_morfosintaxi_b1.sql` i
`20261001180000_llicons_fonetica_b1.sql`). Els exercicis que contradeien l'AVL es corregixen en
`20261001170000_correccio_exercicis_avl.sql` i `20261001190000_correccio_exercicis_fonetica_avl.sql`.

| Fitxer | Contingut | Font |
| --- | --- | --- |
| `gvb.html` | *Gramàtica valenciana bàsica* sencera (HTML original) | Gramàtic-On de l'AVL, `getContent.jsp?key=GVB` amb la sessió en GVB |
| `gnv.html` | *Gramàtica normativa valenciana* sencera (HTML original) | Gramàtic-On de l'AVL, `getContent.jsp?key=GNV` amb la sessió en GNV |
| `gvb.txt`, `gnv.txt` | Les mateixes gramàtiques en text pla, amb els números d'apartat (`#`, `##`, `###`), exemples (`>`), observacions (`[OBS]`) i taules (`|`) | Generats a partir dels HTML |
| `quadern_b1_morfosintaxi.txt` | Apartat 3.2.2 Morfosintaxi del Quadern de nivell B1 (2024) |
| `quadern_b1_fonetica.txt` | Apartat 3.2.1 Fonètica, elocució i ortografia del Quadern de nivell B1 (2024) | [JQCV](https://jqcv.gva.es/va/nivell-b1) |

Enllaç públic a una fitxa: `https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=<clau>`.
