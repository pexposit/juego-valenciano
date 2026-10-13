#!/usr/bin/env python3
"""Conversió de veu RVC (Applio) per al laboratori: dona el timbre d'un personatge a un WAV.

Protocol NDJSON per stdio, com whisper_batch.py:

  node → python (una línia JSON per petició):
    {"input": "/tmp/matxa.wav", "output": "/tmp/rvc.wav",
     "pth": "/…/logs/doraemon/doraemon_300e_8700s.pth", "index": "/…/doraemon.index",
     "pitch": 5, "index_rate": 0.6, "protect": 0.33}

  python → node (una línia JSON per resposta):
    {"compute_ms": 250.3}
    {"error": "…"}

Corre en .venv-rvc (Applio fixa versions de torch incompatibles amb Matcha) i
amb el directori de treball en tts/rvc/Applio, d'on Applio llig els models
preentrenats (RMVPE, ContentVec). VoiceConverter reaprofita el model mentre
es demana el mateix .pth: canviar de personatge el recarrega (~1 s).
"""
from __future__ import annotations

import json
import logging
import os
import sys
import time

log = logging.getLogger("rvc")


def main() -> None:
    logging.basicConfig(level=logging.INFO, stream=sys.stderr, format="[rvc] %(message)s")
    respostes = sys.stdout
    sys.stdout = sys.stderr  # Applio escriu el progrés per stdout
    sys.path.insert(0, os.getcwd())

    import torch
    from rvc.infer.infer import VoiceConverter

    vc = VoiceConverter()
    print("[rvc] llest", flush=True, file=sys.stderr)

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            req = json.loads(line)
            for clau in ("input", "pth"):
                if not os.path.isfile(req[clau]):
                    raise FileNotFoundError(f"no trobe {req[clau]}")
            if torch.cuda.is_available():
                torch.cuda.synchronize()
            t = time.time()
            vc.convert_audio(
                audio_input_path=req["input"], audio_output_path=req["output"],
                model_path=req["pth"], index_path=req.get("index") or "",
                pitch=int(req.get("pitch", 0)), index_rate=float(req.get("index_rate", 0.6)),
                protect=float(req.get("protect", 0.33)), f0_method="rmvpe",
                embedder_model="contentvec", export_format="WAV",
            )
            if torch.cuda.is_available():
                torch.cuda.synchronize()
            if not os.path.isfile(req["output"]):
                raise RuntimeError("Applio no ha escrit l'eixida (mira el registre [rvc])")
            answer = {"compute_ms": round((time.time() - t) * 1000, 1)}
        except Exception as exc:  # noqa: BLE001
            log.warning("error: %s", exc)
            answer = {"error": str(exc)}
        print(json.dumps(answer, ensure_ascii=False), flush=True, file=respostes)


if __name__ == "__main__":
    main()
