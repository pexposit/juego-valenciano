#!/usr/bin/env python3
"""Transcripció per lots amb faster-whisper (model català d'Aina).

Protocol NDJSON per stdio (sense cap port: el procés és fill del servidor
Node i mor amb ell):

  node → python (una línia JSON per petició):
    {"wav_path": "/tmp/xxx.wav", "language": "ca",
     "task": "transcribe", "word_timestamps": false}

  python → node (una línia JSON per resposta):
    {"text": "bon dia…", "language": "ca",
     "segments": [{"start": 0.0, "end": 2.5, "text": "bon dia"}],
     "words": [{"word": "bon", "start": 0.0, "end": 0.4, "probability": 0.9}],
     "compute_ms": 320.5, "audio_secs": 2.59}
    {"error": "no trobe el fitxer"}

El model es carrega una sola vegada (en la primera petició) i es comparteix
entre peticions. GPU si hi és (float16), si no CPU (int8). Els logs van a
stderr; per stdout només ixen respostes JSON.
"""
from __future__ import annotations

import argparse
import json
import logging
import os
import sys
import time

log = logging.getLogger("whisper")

MODEL = None  # type: ignore[assignment]


def pick_device() -> tuple[str, str]:
    """cuda+float16 si hi ha GPU lliure; si no, cpu+int8. Sense suposicions.

    La GPU pot estar ocupada per un altre procés (o sense permisos en un
    contenidor): en eixe cas ctranslate2 no falla al comptar dispositius,
    falla al carregar el model. Per això `load_model` reintenta en CPU.
    """
    try:
        import ctranslate2

        if ctranslate2.get_cuda_device_count() > 0:
            return "cuda", "float16"
    except Exception:  # noqa: BLE001 - si no ho podem saber, anem a CPU
        pass
    return "cpu", "int8"


def load_model(model_path: str, model_id: str):  # noqa: ANN001, ANN202
    """Carrega des de la ruta local; si no hi és, descarrega de Hugging Face.

    Si la GPU falla (ocupada, sense permisos…), cau a CPU automàticament:
    el laboratori ha de funcionar sempre, encara que més lent.
    """
    from faster_whisper import WhisperModel

    device, compute = pick_device()
    source = model_path if os.path.exists(os.path.join(model_path, "model.bin")) else model_id
    started = time.perf_counter()
    try:
        model = WhisperModel(source, device=device, compute_type=compute)
    except Exception as exc:  # noqa: BLE001 - qualsevol error de GPU → CPU
        if device == "cuda":
            log.warning("GPU no disponible (%s): caem a CPU", exc)
            device, compute = "cpu", "int8"
            model = WhisperModel(source, device=device, compute_type=compute)
        else:
            raise
    log.info(
        "model %s carregat en %d ms (device=%s compute=%s)",
        source,
        (time.perf_counter() - started) * 1000,
        device,
        compute,
    )
    # Ho recordem per al log de cada transcripció (WER amb context de device).
    model._lab_device = device  # noqa: SLF001 - només metadada per al log
    return model


def transcribe(model, request: dict) -> dict:  # noqa: ANN001, ANN202
    """Una petició NDJSON → un dict de resposta (sense llançar mai)."""
    wav_path = request.get("wav_path")
    if not isinstance(wav_path, str) or not os.path.isfile(wav_path):
        return {"error": f"no trobe el fitxer: {wav_path}"}

    language = request.get("language") or "ca"
    task = request.get("task") or "transcribe"
    if task not in ("transcribe", "translate"):
        return {"error": f"tasca desconeguda: {task}"}
    word_timestamps = bool(request.get("word_timestamps", False))

    started = time.perf_counter()
    try:
        segments_iter, info = model.transcribe(
            wav_path,
            language=language,
            task=task,
            word_timestamps=word_timestamps,
        )
        # faster-whisper retorna un generador: cal consumir-lo per tindre el text.
        out_segments = []
        out_words = []
        for seg in segments_iter:
            out_segments.append(
                {"start": round(seg.start, 2), "end": round(seg.end, 2), "text": seg.text.strip()}
            )
            if word_timestamps and seg.words:
                for word in seg.words:
                    out_words.append(
                        {
                            "word": word.word.strip(),
                            "start": round(word.start, 2),
                            "end": round(word.end, 2),
                            "probability": round(word.probability, 3),
                        }
                    )
        compute_ms = (time.perf_counter() - started) * 1000
        return {
            "text": " ".join(s["text"] for s in out_segments).strip(),
            "language": getattr(info, "language", language),
            "segments": out_segments,
            "words": out_words,
            "compute_ms": round(compute_ms, 1),
            "audio_secs": round(getattr(info, "duration", 0.0), 2),
        }
    except Exception as exc:  # noqa: BLE001 - volem informar el client de qualsevol error
        log.warning("transcripció fallida (%s): %s", wav_path, exc)
        return {"error": f"no hem pogut transcriure l'àudio: {exc}"}


def main() -> None:
    parser = argparse.ArgumentParser(description="Sidecar de lots faster-whisper per a ParlaVal")
    parser.add_argument("--model", default=os.environ.get("AINA_MODEL_PATH", "model"))
    parser.add_argument("--model-id", default=os.environ.get(
        "AINA_MODEL_ID", "projecte-aina/faster-whisper-large-v3-ca-3catparla"))
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO, stream=sys.stderr, format="[whisper] %(message)s")

    global MODEL
    MODEL = load_model(args.model, args.model_id)
    # Senyal de llest per stderr (stdout és només per a respostes).
    print("[whisper] llest", flush=True, file=sys.stderr)

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            request = json.loads(line)
        except json.JSONDecodeError:
            print(json.dumps({"error": "petició no vàlida (cal JSON)"}), flush=True)
            continue
        print(json.dumps(transcribe(MODEL, request), ensure_ascii=False), flush=True)


if __name__ == "__main__":
    main()
