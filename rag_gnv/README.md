# RAG de la Gramàtica Normativa Valenciana

Servici que usa el tutor («el professor») per a respondre els dubtes de normativa amb la GNV de l'AVL
(`assets-src/avl/gnv.txt`). Ve de `pruebaRag/` i en conserva la lògica:

- **Pare/fill**: cada secció de la gramàtica és un pare (partit si passa de 3000 caràcters); els fills
  (500 caràcters, amb la ruta d'encapçalaments davant) són el que s'indexa.
- **Recerca híbrida**: vectors (`text-embedding-3-small` d'OpenAI, Chroma) + BM25, fusionats amb RRF.
- **Reranker**: `BAAI/bge-reranker-v2-m3` reordena els 50 millors fills i es tornen els pares.
- **Negativa**: si la millor puntuació no arriba a `UMBRAL_RESPALDO` (0,05, calibrat amb `calibrar.py`
  de `pruebaRag/`), no es retorna cap font.

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

La primera vegada descarrega el reranker (~2 GB) i, si no hi ha `index_gnv/` o ha canviat el model d'embeddings,
indexa la GNV amb l'API d'OpenAI (uns segons i uns cèntims). La clau és la `OPENAI_API_KEY` de `backend/.env`;
si l'API no respon en una consulta, la recerca continua només amb BM25.
El reranker va en GPU si n'hi ha (fp16, ~1,1 GB); en CPU funciona però va lent.

Variables: `RAG_GNV_PORT` (8010), `RAG_GNV_HOST` (127.0.0.1), `RAG_GNV_DEVICE` (`cuda`/`cpu`),
`RAG_GNV_SOURCE`, `RAG_GNV_INDEX_DIR`, `RAG_GNV_EMBEDDING_MODEL` (`text-embedding-3-small`). En el backend: `RAG_GNV_URL` (http://localhost:8010),
`RAG_GNV_ENABLED=false` per a desactivar-lo i `RAG_GNV_TIMEOUT_MS` (20000).

Prova: `curl -X POST localhost:8010/consultar -H 'Content-Type: application/json' -d '{"consulta":"accentuació diacrítica de què i que"}'`
