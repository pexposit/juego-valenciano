# Imatge del RAG de la Gramàtica Normativa Valenciana (HTTP, port 8010). El context de build és l'arrel del monorepo
# (vegeu .dockerignore): fa falta la GNV, assets-src/avl/gnv.txt, de la qual es genera l'índex.
FROM python:3.12-slim
WORKDIR /app/rag_gnv
ENV PYTHONUNBUFFERED=1 PYTHONUTF8=1 PIP_NO_CACHE_DIR=1 \
    RAG_GNV_HOST=0.0.0.0 RAG_GNV_PORT=8010 RAG_GNV_DEVICE=cpu

# torch només CPU (uns 200 MB en lloc de ~2 GB amb CUDA): en un servidor sense GPU el reranker local és només el
# respatller de Jev (TYPESAFE_API_KEY).
COPY rag_gnv/requirements.txt .
RUN pip install --extra-index-url https://download.pytorch.org/whl/cpu -r requirements.txt

COPY rag_gnv/rag_gnv.py rag_gnv/servidor.py ./
COPY assets-src/avl/gnv.txt /app/assets-src/avl/gnv.txt

# L'índex (Chroma + JSON, ~31 MB) es genera sol en el primer arranc amb OPENAI_API_KEY (embeddings) i es guarda en un
# volum: no es torna a generar mentre no canvie la GNV. El model del reranker local, si es fa servir, es descarrega
# a la caché de Hugging Face (també en un volum).
RUN useradd --create-home app \
 && mkdir -p /app/rag_gnv/index_gnv /home/app/.cache/huggingface \
 && chown -R app:app /app /home/app
USER app
EXPOSE 8010
# El primer arranc indexa la GNV (uns segons i uns cèntims d'OpenAI): temps de gràcia ampli.
HEALTHCHECK --interval=30s --timeout=5s --start-period=180s --retries=3 \
  CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8010/salut', timeout=4).status == 200 else 1)"
CMD ["python", "servidor.py"]
