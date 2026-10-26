# RAG de la Gramàtica Normativa Valenciana

Servici que usa el tutor («el professor») per a respondre els dubtes de normativa amb la GNV de l'AVL
(`assets-src/avl/gnv.txt`). Ve de `pruebaRag/` i en conserva la lògica:

- **Pare/fill**: cada secció de la gramàtica és un pare (partit si passa de 3000 caràcters); els fills
  (500 caràcters, amb la ruta d'encapçalaments davant) són el que s'indexa.
- **Recerca híbrida**: vectors (`text-embedding-3-small` d'OpenAI, Chroma) + BM25, fusionats amb RRF.
- **Reranker**: reordena els 50 millors fills i es tornen els pares. Per defecte és **Jev** (API de TypeSafe): una
  pregunta `noul` («este fragment respon la consulta?») per fill, totes en una crida (~300 ms). Si Jev falla, es fa
  servir el local, `BAAI/bge-reranker-v2-m3`, que només es carrega llavors.
- **Negativa**: no es retorna cap font si la millor puntuació no arriba al llindar del reranker (`UMBRALES`: 0,05
  el local, calibrat amb `calibrar.py` de `pruebaRag/`; 0,1 Jev) o, amb Jev, si la pregunta de control de la mateixa
  crida diu que la consulta no és de normativa. Amb 20 preguntes de la GNV i 15 alienes, Jev les classifica totes bé;
  el local en deixa passar 2 d'alienes.

## Com el fa servir el tutor

`backend/src/services/agent.ts`: en el xat del professor (no en el Nivell 0) el LLM decidix si el missatge
és un dubte de normativa. Si ho és, escriu la consulta reescrita amb terminologia gramatical (com en
`pruebaRag/reescrituras.py`), el backend crida `POST /consultar` i el LLM respon amb les fonts:
`reply_text` (resposta breu) i `gnv` = la regla oficial (cita «GNV § … · ruta», que posa el servidor, no
el LLM), el contingut en breu i una explicació fàcil. El xat ho mostra en una targeta davall de la resposta.
Si el servici no respon, el tutor contesta igual, sense targeta.

## Arrancar

```bash
python3.12 -m venv .venv && .venv/bin/pip install -r requirements.txt   # o el venv de pruebaRag
.venv/bin/python servidor.py        # http://127.0.0.1:8010
```

Si no hi ha `index_gnv/` o ha canviat el model d'embeddings,
indexa la GNV amb l'API d'OpenAI (uns segons i uns cèntims). Les claus són les de `backend/.env`:
`OPENAI_API_KEY` (embeddings; si l'API no respon en una consulta, la recerca continua només amb BM25) i
`TYPESAFE_API_KEY` (Jev). El reranker local (~2 GB de descàrrega) només es carrega si és el triat o si Jev falla;
va en GPU si n'hi ha (fp16, ~1,1 GB) i en CPU funciona però va lent.

Variables: `RAG_GNV_PORT` (8010), `RAG_GNV_HOST` (127.0.0.1), `RAG_GNV_DEVICE` (`cuda`/`cpu`),
`RAG_GNV_SOURCE`, `RAG_GNV_INDEX_DIR`, `RAG_GNV_EMBEDDING_MODEL` (`text-embedding-3-small`),
`RAG_GNV_RERANKER` (`jev` si hi ha `TYPESAFE_API_KEY`; si no, `local`), `RAG_GNV_JEV_MODEL` (`jev-latest`). En el backend: `RAG_GNV_URL` (http://localhost:8010),
`RAG_GNV_ENABLED=false` per a desactivar-lo, `RAG_GNV_TIMEOUT_MS` (20000) i el mínim perquè el tutor
proposa un exercici: `TUTOR_EXERCISE_MIN_SCORE` (0,1, local) i `TUTOR_EXERCISE_MIN_SCORE_JEV` (0,5).

Prova: `curl -X POST localhost:8010/consultar -H 'Content-Type: application/json' -d '{"consulta":"accentuació diacrítica de què i que"}'`
