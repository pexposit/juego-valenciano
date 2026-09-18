#!/usr/bin/env python3
"""Pont Vosk ↔ WebSocket per al laboratori de veu en temps real.

Protocol (el mateix que vosk-server, per poder canviar de proveïdor sense tocar
el client):

  client → servidor
    {"config": {"sample_rate": 16000, "phrase_list": ["bon dia"], "words": false}}
    <frames binaris PCM16 mono little-endian>
    {"eof": 1}     → resultat final i tancament de la connexió
    {"reset": 1}   → descarta l'estat del reconeixedor i continua

  servidor → client
    {"partial": "bon dia com"}
    {"text": "bon dia com et puc ajudar hui"}
    {"error": "..."}

El model es carrega una sola vegada i es comparteix entre connexions: cada
connexió té el seu propi KaldiRecognizer. La decodificació s'executa en un
pool de fils perquè no bloqueja el bucle d'esdeveniments.
"""
from __future__ import annotations

import argparse
import asyncio
import concurrent.futures
import json
import logging
import math
import os
import sys
import time
from typing import Any

from vosk import KaldiRecognizer, Model, SetLogLevel

# Els registres dins de la llibreria nativa embruten els logs del laboratori.
SetLogLevel(-1)

log = logging.getLogger("vosk")

DEFAULT_SAMPLE_RATE = 16000
POOL: concurrent.futures.ThreadPoolExecutor | None = None
MODEL: Model | None = None

# Endpointing per energia: un cop detectada parla, si l'energia baixa del
# llindar de silenci durant este temps, tanquem el torn sol (resultat final i
# reconeixedor nou per al següent). Sense això, en decodificació lliure i amb
# soroll de fons el final de Vosk pot trigar molts segons… o mai arribar,
# i en el mode trucada tot depende d'eixe final.
ENDPOINT_SILENCE_MS = 900.0
SPEECH_DBFS = -45.0


class EndpointState:
    """Estat del detector de fi de torn d'una connexió."""

    def __init__(self) -> None:
        self.reset()

    def reset(self) -> None:
        self.speech_seen = False
        self.silence_ms = 0.0


def rms_dbfs(data: bytes) -> float:
    """Nivell RMS d'un fragment PCM16 mono little-endian, en dBFS."""
    count = len(data) // 2
    if count == 0:
        return -120.0
    sum_squares = 0.0
    for i in range(0, count * 2, 2):
        sample = int.from_bytes(data[i : i + 2], "little", signed=True)
        sum_squares += float(sample) * float(sample)
    rms = (sum_squares / count) ** 0.5 / 32768.0
    return 20.0 * math.log10(max(rms, 1e-9))


def feed_audio(recognizer: KaldiRecognizer, data: bytes) -> tuple[str, float, bool, bool]:
    """Processa un fragment.

    Retorna (resposta JSON, ms de còmput, torn finalitzat per Vosk, text no buit).
    """
    started = time.perf_counter()
    if recognizer.AcceptWaveform(data):
        # El detector intern de Vosk ha decidit que el torn ha acabat.
        response = recognizer.Result()
        finalized = True
    else:
        response = recognizer.PartialResult()
        finalized = False
    compute_ms = (time.perf_counter() - started) * 1000
    try:
        has_text = bool(json.loads(response).get("text", "").strip())
    except json.JSONDecodeError:
        has_text = False
    return response, compute_ms, finalized, has_text


def finish_stream(recognizer: KaldiRecognizer) -> str:
    """Resultat final: es demana en acabar el torn (`eof`) o en resetejar."""
    return recognizer.FinalResult()


def with_compute_time(response: str, compute_ms: float) -> str:
    """
    Injeta el temps de còmput del motor dins del JSON de resposta.

    Sense esta dada, el client només pot mesurar el temps de tornada, que quan
    s'envia àudio més ràpid que la parla inclou tota la cua acumulada i fa
    semblar el motor molt més lent del que és.
    """
    try:
        payload = json.loads(response)
    except json.JSONDecodeError:
        return response
    payload["compute_ms"] = round(compute_ms, 1)
    return json.dumps(payload, ensure_ascii=False)


def build_recognizer(sample_rate: float, phrase_list: list[str] | None, words: bool) -> KaldiRecognizer:
    assert MODEL is not None
    if phrase_list:
        # La gramàtica restringida és molt més ràpida i precisa, però descarta
        # qualsevol paraula que no estiga a la llista: cal enviar-la normalitzada.
        recognizer = KaldiRecognizer(MODEL, sample_rate, json.dumps(phrase_list, ensure_ascii=False))
    else:
        recognizer = KaldiRecognizer(MODEL, sample_rate)
    recognizer.SetWords(words)
    return recognizer

async def handle(websocket: Any, *_legacy_args: Any) -> None:
    """Atén una connexió: configuració, àudio binari i resultats en streaming."""
    assert POOL is not None
    loop = asyncio.get_running_loop()
    recognizer: KaldiRecognizer | None = None
    sample_rate = float(DEFAULT_SAMPLE_RATE)
    phrase_list: list[str] | None = None
    words = False
    peer = getattr(websocket, "remote_address", None)
    endpoint = EndpointState()
    log.info("connexió des de %s", peer)

    try:
        async for message in websocket:
            if isinstance(message, str):
                try:
                    payload = json.loads(message)
                except json.JSONDecodeError:
                    await websocket.send(json.dumps({"error": "Missatge de control no vàlid"}))
                    continue

                if "config" in payload:
                    conf = payload["config"] or {}
                    if "sample_rate" in conf:
                        sample_rate = float(conf["sample_rate"])
                    if "phrase_list" in conf:
                        phrase_list = [str(p) for p in conf["phrase_list"]]
                    if "words" in conf:
                        words = bool(conf["words"])
                    recognizer = build_recognizer(sample_rate, phrase_list, words)
                    log.info(
                        "configuració: sample_rate=%s frases=%s words=%s",
                        sample_rate,
                        len(phrase_list) if phrase_list else 0,
                        words,
                    )
                    continue

                if "eof" in payload or "reset" in payload:
                    if recognizer is None:
                        recognizer = build_recognizer(sample_rate, phrase_list, words)
                    started = time.perf_counter()
                    final = await loop.run_in_executor(POOL, finish_stream, recognizer)
                    compute_ms = (time.perf_counter() - started) * 1000
                    await websocket.send(with_compute_time(final, compute_ms))
                    if "eof" in payload:
                        break
                    recognizer = build_recognizer(sample_rate, phrase_list, words)
                    continue

                await websocket.send(json.dumps({"error": "Missatge de control desconegut"}))
                continue

            # Àudio: PCM16 mono little-endian al sample_rate configurat.
            if recognizer is None:
                recognizer = build_recognizer(sample_rate, phrase_list, words)

            level = rms_dbfs(message)
            response, compute_ms, finalized, has_text = await loop.run_in_executor(
                POOL, feed_audio, recognizer, message,
            )
            await websocket.send(with_compute_time(response, compute_ms))

            # ── Endpointing per energia ──────────────────────────────────────
            # Vosk amb soroll de fons pot tardar molt (o no arribar mai) a
            # decidir el final del torn. Complementem el seu detector amb
            # energia: un cop hi ha hagut parla, un silenci sostingut tanca
            # el torn, envia el resultat final i deixa el reconeixedor net.
            chunk_ms = len(message) / 2 / sample_rate * 1000.0
            if has_text or level >= SPEECH_DBFS or finalized:
                endpoint.speech_seen = True
                endpoint.silence_ms = 0.0
            elif endpoint.speech_seen:
                endpoint.silence_ms += chunk_ms

            if finalized:
                endpoint.reset()

            if endpoint.speech_seen and endpoint.silence_ms >= ENDPOINT_SILENCE_MS:
                started = time.perf_counter()
                final = await loop.run_in_executor(POOL, finish_stream, recognizer)
                compute_ms = (time.perf_counter() - started) * 1000
                try:
                    final_text = str(json.loads(final).get("text", "")).strip()
                except json.JSONDecodeError:
                    final_text = ""
                if final_text:
                    await websocket.send(with_compute_time(final, compute_ms))
                    log.info("torn tancat per silenci: \"%s\"", final_text)
                recognizer = build_recognizer(sample_rate, phrase_list, words)
                endpoint.reset()
    except Exception as exc:  # noqa: BLE001 - volem informar el client de qualsevol error
        log.warning("sessió interrompuda (%s): %s", peer, exc)
    finally:
        log.info("connexió tancada (%s)", peer)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Servidor WebSocket de Vosk per a ParlaVal")
    parser.add_argument("--model", default=os.environ.get("VOSK_MODEL_PATH", "model"), help="ruta del model")
    parser.add_argument("--host", default=os.environ.get("VOSK_SIDECAR_HOST", "127.0.0.1"))
    parser.add_argument("--port", type=int, default=int(os.environ.get("VOSK_SIDECAR_PORT", "2700")))
    parser.add_argument("--sample-rate", type=float, default=float(os.environ.get("VOSK_SAMPLE_RATE", "16000")))
    return parser.parse_args()


async def main() -> None:
    global MODEL, POOL, DEFAULT_SAMPLE_RATE

    args = parse_args()
    DEFAULT_SAMPLE_RATE = args.sample_rate

    logging.basicConfig(level=logging.INFO, stream=sys.stderr, format="[vosk] %(message)s")
    # Els registres de handshake de `websockets` embruten el log del laboratori.
    logging.getLogger("websockets").setLevel(logging.WARNING)

    if not os.path.isdir(args.model):
        log.error("no trobe el model a %s (executa: npm run setup:speech)", args.model)
        sys.exit(2)

    started = time.perf_counter()
    MODEL = Model(args.model)
    log.info("model carregat en %d ms (%s)", (time.perf_counter() - started) * 1000, args.model)

    POOL = concurrent.futures.ThreadPoolExecutor(os.cpu_count() or 1)

    import websockets  # import tardà: així els errors del model ixen abans

    async with websockets.serve(handle, args.host, args.port, max_size=2 ** 22):
        log.info("escoltant a ws://%s:%d (sample_rate=%s)", args.host, args.port, DEFAULT_SAMPLE_RATE)
        print("[vosk] llest", flush=True)
        await asyncio.Future()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
