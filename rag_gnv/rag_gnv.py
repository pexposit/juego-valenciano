"""RAG sobre la Gramàtica Normativa Valenciana (GNV).

Estructura padre/hijo:
  - PADRE: una sección de la gramàtica (partida solo si supera PARENT_MAX), con su ruta de
    encabezados ("Pronunciació > Les vocals > La distribució de la e i la o obertes").
  - HIJO: trozo pequeño de un padre; es lo que se indexa (vectores + BM25).
La búsqueda saca candidatos con vectores + BM25 (fusión RRF), un reranker (cross-encoder) los
reordena y se devuelven los padres de los mejores hijos.
"""
import hashlib
import json
import math
import os
import re
import unicodedata
from collections import Counter
from pathlib import Path

from langchain_chroma import Chroma
from langchain_core.documents import Document
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

BASE_DIR = Path(__file__).parent
# La GNV és la mateixa que fa servir la resta de l'app (assets-src/avl/gnv.txt).
SOURCE_FILE = Path(os.environ.get("RAG_GNV_SOURCE", BASE_DIR.parent / "assets-src" / "avl" / "gnv.txt"))
INDEX_DIR = Path(os.environ.get("RAG_GNV_INDEX_DIR", BASE_DIR / "index_gnv"))
EMBEDDING_MODEL = "BAAI/bge-m3"
RERANKER_MODEL = "BAAI/bge-reranker-v2-m3"


def _default_device() -> str:
    try:
        import torch
        return "cuda" if torch.cuda.is_available() else "cpu"
    except ImportError:
        return "cpu"


# en fp16 (~1,1 GB) cabe junto a bge-m3 en una GPU de 4 GB; con "cpu" va muy lento
RERANKER_DEVICE = os.environ.get("RAG_GNV_DEVICE") or _default_device()
RERANK_POOL = 50        # hijos candidatos (tras la fusión vectores + BM25) que pasan por el reranker
CANDIDATES_PER_SEARCH = 30  # hijos que aporta cada búsqueda (vectores y BM25) antes de fusionar
RRF_K = 60
UMBRAL_RESPALDO = 0.05  # calibrar.py: no pierde ninguna respuesta buena y rechaza 21/28 preguntas ajenas
MENSAJE_SIN_RESPALDO = "No ho trobe a la Gramàtica Normativa Valenciana."

PARENT_MAX = 3000       # una sección más larga se parte en varios padres
PARENT_OVERLAP = 200
CHILD_SIZE = 500
CHILD_OVERLAP = 50
MIN_PARENT_CHARS = 80   # secciones con menos texto (p. ej. solo un encabezado) se descartan

_SEPARATORS = ["\n\n", "\n", ". ", "; ", " ", ""]
_HEADING = re.compile(r"^(#{1,6})\s+(.*\S)\s*$")
_NUMBER = re.compile(r"^(\d+(?:\.\d+)*)\.?\s+(.*)$")


# ---------------------------------------------------------------------------
# 1. Parseo del Markdown en secciones con jerarquía normalizada
# ---------------------------------------------------------------------------
def _clean_title(title: str) -> str:
    title = title.replace("*", "").strip()
    return title.capitalize() if title.isupper() else title


def parse_sections(markdown: str) -> list[dict]:
    """Divide el texto en secciones. El nivel jerárquico sale de la numeración del título
    (1. -> 1, 1.2. -> 2, 1.2.1.3. -> 4), no del número de '#', que en el original es incoherente.
    Los títulos sin número (ORTOLOGIA, ORTOGRAFIA...) son nivel 0. El índice inicial queda
    descartado solo porque sus encabezados no tienen texto debajo."""
    sections: list[dict] = []
    stack: dict[int, str] = {}
    current = {"num": "", "path": [], "lines": []}

    def flush():
        body = "\n".join(current["lines"]).strip()
        if len(body) >= MIN_PARENT_CHARS:
            sections.append({"num": current["num"], "path": list(current["path"]), "body": body})

    for line in markdown.splitlines():
        m = _HEADING.match(line)
        if not m:
            current["lines"].append(line)
            continue
        flush()
        raw = m.group(2).strip()
        n = _NUMBER.match(raw)
        if n:
            num, title, level = n.group(1), _clean_title(n.group(2)), n.group(1).count(".") + 1
        else:
            num, title, level = "", _clean_title(raw), 0
        for lv in [lv for lv in stack if lv >= level]:
            del stack[lv]
        stack[level] = f"{num}. {title}" if num else title
        current = {"num": num, "path": [stack[lv] for lv in sorted(stack)], "lines": []}
    flush()
    return sections


# ---------------------------------------------------------------------------
# 2. Padres e hijos
# ---------------------------------------------------------------------------
def plain(text: str) -> str:
    """Quita el énfasis Markdown (conv**e**ni -> conveni) para que no rompa los términos."""
    return re.sub(r"\*+", "", text)


def build_chunks(markdown: str) -> tuple[dict[str, dict], list[Document]]:
    parent_splitter = RecursiveCharacterTextSplitter(
        chunk_size=PARENT_MAX, chunk_overlap=PARENT_OVERLAP, separators=_SEPARATORS
    )
    child_splitter = RecursiveCharacterTextSplitter(
        chunk_size=CHILD_SIZE, chunk_overlap=CHILD_OVERLAP, separators=_SEPARATORS
    )
    parents: dict[str, dict] = {}
    children: list[Document] = []
    for sec in parse_sections(markdown):
        breadcrumb = " > ".join(sec["path"])
        pieces = parent_splitter.split_text(sec["body"])
        for p_idx, piece in enumerate(pieces):
            pid = f"p{len(parents):05d}"
            parents[pid] = {"id": pid, "num": sec["num"], "ruta": breadcrumb, "text": piece}
            for c_idx, child in enumerate(child_splitter.split_text(piece)):
                children.append(Document(
                    # la ruta se antepone para que el hijo "sepa" de qué parte de la gramàtica es
                    page_content=f"{breadcrumb}\n{plain(child)}",
                    metadata={"parent_id": pid, "num": sec["num"], "child_id": f"{pid}c{c_idx:03d}"},
                ))
    return parents, children


# ---------------------------------------------------------------------------
# 3. BM25 mínimo (sin dependencias extra)
# ---------------------------------------------------------------------------
def _tokens(text: str) -> list[str]:
    text = unicodedata.normalize("NFD", text.lower())
    text = "".join(c for c in text if unicodedata.category(c) != "Mn")  # oberta/obèrta -> igual
    text = text.replace("·", "")
    return re.findall(r"\w+", text)


class BM25:
    def __init__(self, docs: list[str], k1: float = 1.5, b: float = 0.75):
        self.k1, self.b = k1, b
        self.tf = [Counter(_tokens(d)) for d in docs]
        self.len = [sum(t.values()) for t in self.tf]
        self.avg = sum(self.len) / max(len(docs), 1)
        df = Counter(w for t in self.tf for w in t)
        n = len(docs)
        self.idf = {w: math.log(1 + (n - f + 0.5) / (f + 0.5)) for w, f in df.items()}

    def top(self, query: str, k: int) -> list[int]:
        q = [w for w in _tokens(query) if w in self.idf]
        scores = []
        for i, tf in enumerate(self.tf):
            s = 0.0
            for w in q:
                f = tf.get(w, 0)
                if f:
                    s += self.idf[w] * f * (self.k1 + 1) / (
                        f + self.k1 * (1 - self.b + self.b * self.len[i] / self.avg))
            scores.append(s)
        order = sorted(range(len(scores)), key=scores.__getitem__, reverse=True)
        return [i for i in order[:k] if scores[i] > 0]


# ---------------------------------------------------------------------------
# 4. Retriever híbrido con recuperación del padre
# ---------------------------------------------------------------------------
class GNVRetriever:
    def __init__(self, vectorstore: Chroma, parents: dict[str, dict], children: list[Document]):
        self.vectorstore = vectorstore
        self.parents = parents
        self.children = children
        self.bm25 = BM25([c.page_content for c in children])
        self._cross_encoder = None  # se carga la primera vez que se usa el reranker

    def search_children(self, query: str, k: int = CANDIDATES_PER_SEARCH) -> list[Document]:
        """Fusión RRF de la búsqueda vectorial y la léxica (BM25) sobre los hijos."""
        vec = self.vectorstore.similarity_search(query, k=k)
        lex = [self.children[i] for i in self.bm25.top(query, k)]
        score: dict[str, float] = {}
        by_id: dict[str, Document] = {}
        for ranking in (vec, lex):
            for rank, doc in enumerate(ranking):
                cid = doc.metadata["child_id"]
                by_id[cid] = doc
                score[cid] = score.get(cid, 0.0) + 1.0 / (RRF_K + rank)
        return [by_id[c] for c in sorted(score, key=score.get, reverse=True)]

    def _reranker(self):
        if self._cross_encoder is None:
            from sentence_transformers import CrossEncoder
            self._cross_encoder = CrossEncoder(
                RERANKER_MODEL, max_length=512, device=RERANKER_DEVICE,
                model_kwargs={"torch_dtype": "float16" if RERANKER_DEVICE == "cuda" else "float32"},
            )
        return self._cross_encoder

    def rerank(self, query: str, children: list[Document]) -> list[tuple[Document, float]]:
        """Reordena los hijos con un cross-encoder, que lee pregunta y fragmento a la vez.
        Devuelve (hijo, puntuación) de mayor a menor; la puntuación va de 0 a 1."""
        scores = self._reranker().predict(
            [(query, c.page_content) for c in children], batch_size=8)
        order = sorted(range(len(children)), key=lambda i: scores[i], reverse=True)
        return [(children[i], float(scores[i])) for i in order]

    def invoke(self, query: str, k: int = 4) -> list[Document]:
        """Devuelve hasta k PADRES distintos, ordenados por su mejor hijo tras el reranker."""
        candidates = self.rerank(query, self.search_children(query)[:RERANK_POOL])
        best_child: dict[str, tuple[Document, float]] = {}  # padre -> (su mejor hijo, puntuación)
        for child, score in candidates:
            pid = child.metadata["parent_id"]
            if pid not in best_child:
                best_child[pid] = (child, score)
            if len(best_child) == k:
                break
        out = []
        for pid, (child, score) in best_child.items():
            p = self.parents[pid]
            out.append(Document(
                page_content=p["text"],
                metadata={"parent_id": pid, "num": p["num"], "ruta": p["ruta"],
                          "hijo": child.page_content, "score": score},
            ))
        return out

    def consultar(self, query: str, k: int = 4, umbral: float | None = None) -> dict:
        """Búsqueda con negativa y citas.

        Si la mejor puntuación del reranker no llega al umbral, no devuelve contexto: es mejor
        decir que no se ha encontrado que dar al LLM (o al usuario) un fragmento dudoso.
        Cada fuente lleva su sección, su ruta y el texto original, para poder comprobarla."""
        umbral = UMBRAL_RESPALDO if umbral is None else umbral
        docs = self.invoke(query, k=k)
        mejor = docs[0].metadata["score"] if docs else 0.0
        if mejor < umbral:
            return {"hay_respaldo": False, "mejor_puntuacion": mejor, "mensaje": MENSAJE_SIN_RESPALDO,
                    "fuentes": []}
        return {
            "hay_respaldo": True,
            "mejor_puntuacion": mejor,
            "mensaje": "",
            "fuentes": [{"seccion": d.metadata["num"], "ruta": d.metadata["ruta"],
                         "puntuacion": d.metadata["score"], "texto": d.page_content} for d in docs],
        }


def etiqueta_fuente(fuente: dict) -> str:
    """Cita legible de una fuente: 'GNV § 1.2.1.3 · Ortologia > ... > La distribució de la e...'."""
    seccion = f"§ {fuente['seccion']}" if fuente["seccion"] else "(sense numeració)"
    return f"GNV {seccion} · {fuente['ruta']}"


def formatear(resultado: dict) -> str:
    """Respuesta para mostrar al usuario: o la negativa, o las fuentes citadas con su texto original."""
    if not resultado["hay_respaldo"]:
        return resultado["mensaje"]
    bloques = []
    for i, f in enumerate(resultado["fuentes"], 1):
        bloques.append(f"[{i}] {etiqueta_fuente(f)}  (puntuació {f['puntuacion']:.2f})\n{f['texto'].strip()}")
    return "\n\n".join(bloques)


def contexto_para_llm(resultado: dict) -> str:
    """Contexto numerado y con sección para pasar a un LLM, que debe citar esas etiquetas.
    Vacío si no hay respaldo: en ese caso no se llama al LLM y se responde con la negativa."""
    if not resultado["hay_respaldo"]:
        return ""
    return "\n\n".join(f"<font id=\"{i}\" seccio=\"{f['seccion']}\" ruta=\"{f['ruta']}\">\n{f['texto'].strip()}\n</font>"
                        for i, f in enumerate(resultado["fuentes"], 1))


# ---------------------------------------------------------------------------
# 5. Construcción / carga del índice persistente
# ---------------------------------------------------------------------------
def load_retriever(force_rebuild: bool = False, verbose: bool = True) -> GNVRetriever:
    log = print if verbose else (lambda *a, **k: None)
    markdown = SOURCE_FILE.read_text(encoding="utf-8")
    signature = hashlib.sha256(
        (markdown + EMBEDDING_MODEL + repr((PARENT_MAX, PARENT_OVERLAP, CHILD_SIZE, CHILD_OVERLAP))).encode()
    ).hexdigest()

    parents_file = INDEX_DIR / "parents.json"
    children_file = INDEX_DIR / "children.json"
    sig_file = INDEX_DIR / "signature.txt"
    up_to_date = sig_file.exists() and sig_file.read_text() == signature

    log("⌛ Cargando modelo de embeddings...")
    embeddings = HuggingFaceEmbeddings(
        model_name=EMBEDDING_MODEL, encode_kwargs={"normalize_embeddings": True}
    )
    vectorstore = Chroma(
        collection_name="gnv_children",
        embedding_function=embeddings,
        persist_directory=str(INDEX_DIR / "chroma"),
        collection_metadata={"hnsw:space": "cosine"},
    )

    if up_to_date and not force_rebuild:
        log("♻️ Índice existente y actualizado: se carga de disco.")
        parents = json.loads(parents_file.read_text(encoding="utf-8"))
        children = [Document(**d) for d in json.loads(children_file.read_text(encoding="utf-8"))]
        return GNVRetriever(vectorstore, parents, children)

    log("✂️ Troceando por secciones (padres) y fragmentos (hijos)...")
    parents, children = build_chunks(markdown)
    log(f"   {len(parents)} padres, {len(children)} hijos")

    log("💾 Indexando hijos en Chroma (puede tardar unos minutos)...")
    vectorstore.reset_collection()
    for i in range(0, len(children), 128):
        batch = children[i:i + 128]
        vectorstore.add_documents(batch, ids=[d.metadata["child_id"] for d in batch])

    INDEX_DIR.mkdir(exist_ok=True)
    parents_file.write_text(json.dumps(parents, ensure_ascii=False), encoding="utf-8")
    children_file.write_text(
        json.dumps([{"page_content": d.page_content, "metadata": d.metadata} for d in children],
                   ensure_ascii=False), encoding="utf-8")
    sig_file.write_text(signature)
    log("✅ Indexación completada y guardada en disco.")
    return GNVRetriever(vectorstore, parents, children)
