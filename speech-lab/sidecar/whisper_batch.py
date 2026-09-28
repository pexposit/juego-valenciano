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
import ctypes
import glob
import json
import logging
import os
import site
import sys
import time

log = logging.getLogger("whisper")

MODEL = None  # type: ignore[assignment]

# Llibreries que CTranslate2 carrega dinàmicament quan treballa en GPU. No venen
# amb el paquet: les posa `pip install nvidia-cublas-cu12 nvidia-cudnn-cu12`.
CUDA_SONAMES = ("libcublas.so.12", "libcublasLt.so.12", "libcudnn.so.9")
# Tipus de còmput per orde de preferència en GPU: el large-v3 en float16 demana
# ~3 GB de VRAM; si no n'hi ha prou, int8_float16 en gasta la meitat.
GPU_COMPUTE_TYPES = ("float16", "int8_float16")


class GpuFailed(RuntimeError):
    """La GPU ha fallat en plena transcripció: cal recarregar el model en CPU."""


def cuda_library_dirs() -> list[str]:
    """Directoris amb les llibreries CUDA dels wheels `nvidia-*` instal·lats amb pip."""
    roots: list[str] = []
    try:
        roots.extend(site.getsitepackages())
        roots.append(site.getusersitepackages())
    except Exception:  # noqa: BLE001 - sense `site` simplement no hi ha wheels
        pass
    dirs: list[str] = []
    for root in roots:
        dirs.extend(sorted(glob.glob(os.path.join(root, "nvidia", "*", "lib"))))
    return [d for d in dirs if os.path.isdir(d)]


def ensure_cuda_libraries_visible() -> None:
    """Fa que el carregador dinàmic trobe les llibreries CUDA dels wheels `nvidia-*`.

    El carregador només llegix `LD_LIBRARY_PATH` a l'arrencada, així que afegir-lo
    després no servix: si cal, ens reexecutem una sola volta (la marca d'entorn ho
    garantix). Sense açò CTranslate2 troba el driver, carrega el model en GPU,
    reserva VRAM i falla en la primera transcripció amb «Library libcublas.so.12
    is not found or cannot be loaded».
    """
    if os.environ.get("PARLAVAL_CUDA_PATHS") == "1":
        return
    if os.environ.get("AINA_DEVICE", "auto").strip().lower() == "cpu":
        return  # forçat a CPU: no cal tocar el carregador ni reexecutar res
    dirs = cuda_library_dirs()
    current = [p for p in os.environ.get("LD_LIBRARY_PATH", "").split(os.pathsep) if p]
    missing = [d for d in dirs if d not in current]
    if not missing:
        return
    os.environ["LD_LIBRARY_PATH"] = os.pathsep.join(dirs + current)
    os.environ["PARLAVAL_CUDA_PATHS"] = "1"
    log.info("afegix %d directoris de CUDA al carregador i reexecuta el procés", len(missing))
    os.execve(sys.executable, [sys.executable, *sys.argv], os.environ)


def cuda_libraries_loadable() -> tuple[bool, str]:
    """Comprova que les llibreries CUDA es poden carregar de veritat, no només el driver.

    Carregar-les nosaltres (amb RTLD_GLOBAL) també les deixa registrades per al
    `dlopen` que farà CTranslate2 després.
    """
    absent: list[str] = []
    for soname in CUDA_SONAMES:
        try:
            ctypes.CDLL(soname, mode=ctypes.RTLD_GLOBAL)
        except OSError:
            absent.append(soname)
    return (not absent, ", ".join(absent))


def device_attempts(force_cpu: bool = False) -> list[tuple[str, str]]:
    """Orde d'intents de càrrega: GPU (float16 → int8_float16) i, al final, CPU.

    `AINA_DEVICE=cpu` força CPU (útil per a comparar temps) i `AINA_COMPUTE_TYPE`
    fixa el tipus de còmput en GPU. La comprovació de les llibreries evita
    l'error «Library libcublas.so.12 is not found»: si falten, ni mirem la GPU.
    """
    if force_cpu or os.environ.get("AINA_DEVICE", "auto").strip().lower() == "cpu":
        return [("cpu", "int8")]
    loadable, absent = cuda_libraries_loadable()
    if not loadable:
        log.warning("falten llibreries CUDA (%s): anem per CPU (vegeu scripts/setup-aina.sh)", absent)
        return [("cpu", "int8")]
    forced = os.environ.get("AINA_COMPUTE_TYPE", "").strip()
    computes = (forced,) if forced else GPU_COMPUTE_TYPES
    return [("cuda", compute) for compute in computes] + [("cpu", "int8")]


def load_model(model_path: str, model_id: str, force_cpu: bool = False):  # noqa: ANN001, ANN202
    """Carrega des de la ruta local; si no hi és, descarrega de Hugging Face.

    Prova els intents en orde (GPU float16 → GPU int8_float16 → CPU int8) i es
    queda amb el primer que funcione: el large-v3 en float16 demana ~3 GB de
    VRAM i en un portàtil amb altra faena a la GPU no sempre n'hi ha. El
    laboratori ha de funcionar sempre, encara que siga més lent.
    """
    from faster_whisper import WhisperModel

    source = model_path if os.path.exists(os.path.join(model_path, "model.bin")) else model_id
    failures: list[str] = []
    for device, compute in device_attempts(force_cpu):
        started = time.perf_counter()
        try:
            model = WhisperModel(source, device=device, compute_type=compute)
        except Exception as exc:  # noqa: BLE001 - provem el següent intent
            failures.append(f"{device}/{compute}: {exc}")
            log.warning("càrrega fallida en %s/%s (%s)", device, compute, exc)
            continue
        log.info(
            "model %s carregat en %d ms (device=%s compute=%s)",
            source,
            (time.perf_counter() - started) * 1000,
            device,
            compute,
        )
        if failures:
            log.info("intents descartats abans: %s", " | ".join(failures))
        # Ho recordem per al log de cada transcripció (WER amb context de device).
        model._lab_device = device  # noqa: SLF001 - només metadada per al log
        return model
    raise RuntimeError("no hem pogut carregar el model — " + " | ".join(failures))


def looks_like_gpu_error(exc: Exception) -> bool:
    """Errors de CUDA que només apareixen al primer càlcul (llibreries, VRAM, context)."""
    text = str(exc).lower()
    return any(token in text for token in ("cublas", "cudnn", "cuda", "gpu", "out of memory"))


def transcribe(model, request: dict) -> dict:  # noqa: ANN001, ANN202
    """Una petició NDJSON → un dict de resposta.

    Els errors tornen com a `{error: …}`; l'única excepció és `GpuFailed`, que
    puja a `main` perquè recarregue el model en CPU (la GPU ha caigut a mig vol).
    """
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
        # La GPU pot fallar amb el model ja carregat (VRAM que desapareix, context
        # perdut, llibreries que no es troben al primer càlcul): això no és un
        # error de l'àudio, és del dispositiu, i es resol recarregant en CPU.
        if looks_like_gpu_error(exc) and getattr(model, "_lab_device", "cpu") == "cuda":
            raise GpuFailed(str(exc)) from exc
        log.warning("transcripció fallida (%s): %s", wav_path, exc)
        return {"error": f"no hem pogut transcriure l'àudio: {exc}"}


def main() -> None:
    parser = argparse.ArgumentParser(description="Sidecar de lots faster-whisper per a ParlaVal")
    parser.add_argument("--model", default=os.environ.get("AINA_MODEL_PATH", "model"))
    parser.add_argument("--model-id", default=os.environ.get(
        "AINA_MODEL_ID", "projecte-aina/faster-whisper-large-v3-ca-3catparla"))
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO, stream=sys.stderr, format="[whisper] %(message)s")

    # Abans de tocar cap cosa de CUDA: que el carregador trobe libcublas/libcudnn
    # dels wheels nvidia-* (pot reexecutar el procés una sola volta).
    ensure_cuda_libraries_visible()

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
        try:
            answer = transcribe(MODEL, request)
        except GpuFailed as exc:
            # Recarreguem en CPU una sola volta i reintentem la mateixa petició:
            # el laboratori no es pot quedar penjat per la GPU.
            log.warning("GPU no utilisable en plena transcripció (%s): recarregue en CPU", exc)
            MODEL = load_model(args.model, args.model_id, force_cpu=True)
            answer = transcribe(MODEL, request)
        print(json.dumps(answer, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    main()
