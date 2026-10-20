"""Servici HTTP del RAG de la Gramàtica Normativa Valenciana (GNV).

Només l'usa el backend (el tutor), igual que el classificador: no té autenticació.
  GET  /salut      -> {"ok": true} quan els models ja estan carregats
  POST /ordenar    {"consulta": "...", "textos": ["...", ...]}
                   -> {"puntuaciones": [0..1, ...]}: lo bien que responde cada texto a la consulta (reranker);
                      el backend lo usa para elegir, entre los ejercicios de una actividad, el que trata de la pregunta
  POST /consultar  {"consulta": "...", "k": 4}
                   -> el resultat de GNVRetriever.consultar(): hay_respaldo, mejor_puntuacion,
                      mensaje i fuentes [{seccion, ruta, etiqueta, puntuacion, texto}]

Ús:  python servidor.py            (port RAG_GNV_PORT, per defecte 8010)
Els models (bge-m3 i el reranker) es carreguen en arrancar, perquè la primera pregunta no tarde.
"""
import json
import os
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

from rag_gnv import etiqueta_fuente, load_retriever

PORT = int(os.environ.get("RAG_GNV_PORT", "8010"))
HOST = os.environ.get("RAG_GNV_HOST", "127.0.0.1")
MAX_CONSULTA = 500
MAX_K = 6
MAX_TEXTOS = 120      # textos por petición de /ordenar
MAX_TEXTO = 700       # caracteres de cada uno

retriever = load_retriever()
retriever._reranker()  # es carrega ara i no en la primera consulta
# Els models comparteixen GPU: les consultes es fan d'una en una.
lock = threading.Lock()


class Handler(BaseHTTPRequestHandler):
    def _json(self, status: int, payload: dict):
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/salut":
            return self._json(200, {"ok": True})
        self._json(404, {"error": "No existix"})

    def _ordenar(self):
        try:
            length = int(self.headers.get("Content-Length") or 0)
            data = json.loads(self.rfile.read(min(length, 200_000)) or b"{}")
            consulta = str(data.get("consulta", "")).strip()[:MAX_CONSULTA]
            textos = [str(t)[:MAX_TEXTO] for t in list(data.get("textos", []))[:MAX_TEXTOS]]
        except (ValueError, TypeError):
            return self._json(400, {"error": "Petició invàlida"})
        if not consulta or not textos:
            return self._json(400, {"error": "Falta la consulta o els textos"})
        with lock:
            scores = retriever._reranker().predict([(consulta, t) for t in textos], batch_size=16)
        self._json(200, {"puntuaciones": [float(x) for x in scores]})

    def do_POST(self):
        if self.path == "/ordenar":
            return self._ordenar()
        if self.path != "/consultar":
            return self._json(404, {"error": "No existix"})
        try:
            length = int(self.headers.get("Content-Length") or 0)
            data = json.loads(self.rfile.read(min(length, 10_000)) or b"{}")
            consulta = str(data.get("consulta", "")).strip()[:MAX_CONSULTA]
            k = max(1, min(int(data.get("k", 4)), MAX_K))
        except (ValueError, TypeError):
            return self._json(400, {"error": "Petició invàlida"})
        if not consulta:
            return self._json(400, {"error": "Falta la consulta"})
        with lock:
            resultado = retriever.consultar(consulta, k=k)
        for fuente in resultado["fuentes"]:
            fuente["etiqueta"] = etiqueta_fuente(fuente)
        self._json(200, resultado)

    def log_message(self, fmt, *args):
        print(f"[rag_gnv] {self.address_string()} {fmt % args}", flush=True)


if __name__ == "__main__":
    print(f"✅ RAG de la GNV escoltant en http://{HOST}:{PORT}", flush=True)
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
