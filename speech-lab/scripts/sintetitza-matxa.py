#!/usr/bin/env python3
"""Sintetitza frases de prova amb un checkpoint de Matxa (per a escoltar el fine-tune).

  .venv-voz/bin/python scripts/sintetitza-matxa.py                      # lluc original
  .venv-voz/bin/python scripts/sintetitza-matxa.py --ckpt tts/runs/.../last.ckpt

Els WAV ixen en `--eixida` (per defecte `tts/proves/<nom del checkpoint>/`).
"""
from __future__ import annotations

import argparse
import sys
import wave
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import matxa_entorn as mx  # noqa: E402  (abans de qualsevol import de matcha)

# Frases que no ixen en l'audiollibre, amb les formes valencianes que ens importen.
FRASES = [
    "Bon dia! Hui començarem la partida al mercat de Russafa.",
    "La seua germana té huit xiquets i viu prop de la mar.",
    "Si vols eixir del laberint, has de trobar la clau que obri la porta vella.",
    "Este any les falles han sigut més boniques que mai, no trobes?",
    "Molt bé! Has encertat tres preguntes de quatre. Continuem?",
]


def escriu(path: Path, ona, sr: int = 22050) -> None:  # noqa: ANN001
    import numpy as np

    x = (ona.clamp(-1, 1).numpy() * 32767).astype(np.int16)
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(x.tobytes())


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--ckpt", type=Path, default=mx.CKPT_BASE)
    ap.add_argument("--spk", type=int, default=mx.SPK_LLUC)
    ap.add_argument("--eixida", type=Path)
    ap.add_argument("--text", action="append", help="frase a sintetitzar (es pot repetir)")
    ap.add_argument("--passos", type=int, default=32, help="passos de l'ODE (més = més qualitat)")
    ap.add_argument("--temperatura", type=float, default=0.667)
    ap.add_argument("--velocitat", type=float, default=1.0, help="length_scale: <1 més ràpid")
    args = ap.parse_args()

    import torch

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    nom = args.ckpt.parent.parent.name + "_" + args.ckpt.stem if "runs" in args.ckpt.parts else args.ckpt.stem
    eixida = args.eixida or mx.TTS / "proves" / nom
    eixida.mkdir(parents=True, exist_ok=True)
    model = mx.carrega_model(args.ckpt, device)
    voc = mx.carrega_vocoder(device)
    for i, text in enumerate(args.text or FRASES, 1):
        ona = mx.sintetitza(model, voc, text, args.spk, device, passos=args.passos,
                            temperatura=args.temperatura, velocitat=args.velocitat)
        escriu(eixida / f"frase_{i:02d}_spk{args.spk}.wav", ona)
        print(f"{i:02d} {len(ona) / 22050:4.1f} s  {mx.fonemitza(text)}")
    print("fet:", eixida)


if __name__ == "__main__":
    main()
