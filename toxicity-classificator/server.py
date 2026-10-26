"""Servei intern que classifica missatges amb el model Laya de Hugging Face."""

from __future__ import annotations

import json
import os
import threading
from contextlib import asynccontextmanager
from pathlib import Path

# En local, conserva la descarga de Hugging Face dins del mòdul. Docker pot
# substituir este directori per un volum persistent amb HF_HOME.
MODULE_DIR = Path(__file__).resolve().parent
os.environ.setdefault("HF_HOME", str(MODULE_DIR / ".cache" / "huggingface"))

import laya
from filtro_xatbot import Filtre
from fastapi import FastAPI, HTTPException
from huggingface_hub import hf_hub_download
from pydantic import BaseModel, Field
from starlette.concurrency import run_in_threadpool
from typing import Literal


MODEL_ID = os.getenv("TOXICITY_MODEL_ID", "parlaval/laya-toxicity")
MODEL_REVISION = os.getenv(
    "TOXICITY_MODEL_REVISION", "bc35c319e78e40454c8f34bacc986882841e4488"
)
DEVICE = os.getenv("TOXICITY_DEVICE", "cpu")

_agent = None
_questions: dict | None = None
_filter: Filtre | None = None
_inference_lock = threading.RLock()


@asynccontextmanager
async def lifespan(_: FastAPI):
    global _agent, _questions, _filter
    _agent = laya.load(MODEL_ID, device=DEVICE, revision=MODEL_REVISION)
    questions_path = hf_hub_download(
        repo_id=MODEL_ID,
        filename="questions.json",
        revision=MODEL_REVISION,
    )
    with Path(questions_path).open(encoding="utf-8") as questions_file:
        _questions = json.load(questions_file)
    if not {"Nucli", "Vulgar"}.issubset(_questions):
        raise RuntimeError(f"El model {MODEL_ID} no conté les etiquetes Nucli i Vulgar")

    # Reutilitza la lògica completa de ToXClassificator. El predictor s'injecta
    # ací perquè l'agent Laya es carregue una vegada des de Hugging Face.
    _filter = Filtre(puntuador=lambda text: _raw_scores([text])[0], calibrar=False)
    _filter.dos = True
    _filter.puntua = lambda text: _raw_scores([text])[0]
    _filter.puntua_lot = _raw_scores
    yield


app = FastAPI(title="ParlaVal toxicity classifier", lifespan=lifespan)


class ClassifyRequest(BaseModel):
    text: str = Field(min_length=1, max_length=20_000)
    mode: Literal["adult", "infantil"] = "adult"


class ClassifyResponse(BaseModel):
    toxic: bool
    mode: Literal["adult", "infantil"]
    reasons: list[str]
    p_model: float
    probabilities: dict[str, float]
    message_threshold: float
    phrase_threshold: float


@app.get("/health")
def health() -> dict[str, bool]:
    return {"ok": _agent is not None and _questions is not None}


def _raw_scores(texts: list[str]) -> list[tuple[float, float]]:
    if _agent is None or _questions is None:
        raise RuntimeError("El model encara no està carregat")
    with _inference_lock:
        predictions = _agent.predict_batch(texts, _questions)
    return [
        (float(item["answers"]["Nucli"]["noul"]), float(item["answers"]["Vulgar"]["noul"]))
        for item in predictions
    ]


def _predict(text: str, mode: Literal["adult", "infantil"]) -> ClassifyResponse:
    if _filter is None:
        raise RuntimeError("El filtre encara no està carregat")

    # Filtre.comprova conserva resultats interns de l'últim missatge; protegim
    # tant eixe estat com la inferència quan arriben peticions simultànies.
    with _inference_lock:
        result = _filter.comprova(text, mode)
        raw = _filter._ult or (0.0, 0.0)
        reasons = []
        for reason, detail in result["motius"]:
            if reason == "model":
                reasons.append(f"model:{float(detail):.2f}")
            elif reason == "sexual":
                reasons.append(f"sexual:{detail}")
            else:
                # No registrem el mot concret que ha fet saltar la llista.
                reasons.append(reason)
    return ClassifyResponse(
        toxic=bool(result["bloquejat"]),
        mode=mode,
        reasons=reasons,
        p_model=float(result["p_model"]),
        probabilities={"Nucli": raw[0], "Vulgar": raw[1]},
        message_threshold=float(_filter.umbral[mode]),
        phrase_threshold=float(_filter.llindar_frase[mode]),
    )


@app.post("/classify", response_model=ClassifyResponse)
async def classify(request: ClassifyRequest) -> ClassifyResponse:
    try:
        return await run_in_threadpool(_predict, request.text, request.mode)
    except RuntimeError as error:
        raise HTTPException(status_code=503, detail="El classificador no està preparat") from error
