#!/usr/bin/env python3
"""Síntesi local amb Matxa (checkpoint base o fine-tunes de tts/runs/) per al laboratori.

Protocol NDJSON per stdio, com whisper_batch.py:

  node → python (una línia JSON per petició):
    {"ckpt": "/…/checkpoint_epoch=629.ckpt", "spk": 7, "text": "Bon dia",
     "out": "/tmp/xxx.wav", "temperatura": 0.667, "velocitat": 1.0, "passos": 32}

  python → node (una línia JSON per resposta):
    {"compute_ms": 160.2, "audio_secs": 1.6, "cached": true}
    {"error": "…"}

Corre en .venv-voz (torch + Matcha). El vocoder es carrega en arrancar; cada
checkpoint, la primera vegada que es demana, i se'n guarden MAX_MODELS en GPU
(el menys usat recentment ix). Els logs van a stderr; per stdout només ixen
respostes JSON.
"""
from __future__ import annotations

import json
import logging
import sys
import time
from collections import OrderedDict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))
import matxa_entorn as mx  # noqa: E402  (abans de qualsevol import de matcha)

log = logging.getLogger("matxa")
MAX_MODELS = 3


def main() -> None:
    logging.basicConfig(level=logging.INFO, stream=sys.stderr, format="[matxa] %(message)s")
    # Matcha i Lightning escriuen per stdout en carregar: tot el que no siga
    # resposta va a stderr perquè Node no ho prenga per una línia JSON.
    respostes = sys.stdout
    sys.stdout = sys.stderr

    import numpy as np
    import soundfile as sf
    import torch

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    vocoder = mx.carrega_vocoder(device)
    models: OrderedDict[str, object] = OrderedDict()
    log.info("vocoder carregat en %s", device)
    print("[matxa] llest", flush=True, file=sys.stderr)

    def model(ckpt: str) -> tuple[object, bool]:
        if ckpt in models:
            models.move_to_end(ckpt)
            return models[ckpt], True
        if not Path(ckpt).is_file():
            raise FileNotFoundError(f"no trobe el checkpoint {ckpt}")
        t = time.time()
        models[ckpt] = mx.carrega_model(Path(ckpt), device)
        log.info("carregat %s en %.1f s", ckpt, time.time() - t)
        while len(models) > MAX_MODELS:
            vell, _ = models.popitem(last=False)
            log.info("descarregat %s", vell)
            torch.cuda.empty_cache()
        return models[ckpt], False

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            req = json.loads(line)
            m, cached = model(req["ckpt"])
            if device.type == "cuda":
                torch.cuda.synchronize()
            t = time.time()
            ona = mx.sintetitza(m, vocoder, req["text"], int(req["spk"]), device,
                                passos=int(req.get("passos", 32)),
                                temperatura=float(req.get("temperatura", 0.667)),
                                velocitat=float(req.get("velocitat", 1.0)))
            if device.type == "cuda":
                torch.cuda.synchronize()
            ms = (time.time() - t) * 1000
            x = ona.float().clamp(-1, 1).numpy()
            sf.write(req["out"], (x * 32767).astype(np.int16), 22050, subtype="PCM_16")
            answer = {"compute_ms": round(ms, 1), "audio_secs": round(len(x) / 22050, 2), "cached": cached}
        except Exception as exc:  # noqa: BLE001  (qualsevol error torna a Node, el sidecar segueix viu)
            log.warning("error: %s", exc)
            answer = {"error": str(exc)}
        print(json.dumps(answer, ensure_ascii=False), flush=True, file=respostes)


if __name__ == "__main__":
    main()
