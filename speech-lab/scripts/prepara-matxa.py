#!/usr/bin/env python3
"""Filelists de Matxa a partir del dataset de clips (voz-dataset/clips/metadata.csv).

Com en LaFrescat, el text va ja fonemitzat (espeak `ca-va`) i l'entrenament
usa `basic_cleaners`: espeak no corre en cada època i els fonemes són els
mateixos que va vore el model original. Format de cada línia:

  /ruta/absoluta/clip.wav|6|fonemes IPA

Eixida en `voz-dataset/matxa/`: train.txt, val.txt i fonemes.tsv (id, text,
fonemes: per a revisar com pronunciarà espeak cada frase).

  .venv-voz/bin/python scripts/prepara-matxa.py
"""
from __future__ import annotations

import argparse
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import matxa_entorn as mx  # noqa: E402  (abans de qualsevol import de matcha)


def main() -> None:
    base = mx.LAB / "voz-dataset"
    ap = argparse.ArgumentParser()
    ap.add_argument("--clips", type=Path, default=base / "clips")
    ap.add_argument("--eixida", type=Path, default=base / "matxa")
    ap.add_argument("--spk", type=int, default=mx.SPK_LLUC)
    ap.add_argument("--val", type=int, default=20, help="clips de validació")
    args = ap.parse_args()

    from matcha.text import _symbol_to_id
    from matcha.text.cleaners import basic_cleaners

    files, desconeguts = [], {}
    for linia in (args.clips / "metadata.csv").read_text(encoding="utf-8").splitlines():
        if not linia.strip():
            continue
        cid, text = linia.split("|", 1)
        wav = (args.clips / "wavs" / f"{cid}.wav").resolve()
        if not wav.exists():
            sys.exit(f"falta {wav}")
        fon = mx.fonemitza(text.strip())
        # text_to_sequence peta amb KeyError davant d'un símbol fora del vocabulari:
        # millor saber-ho ara que a mitja època.
        for ch in basic_cleaners(fon):
            if ch not in _symbol_to_id:
                desconeguts.setdefault(ch, []).append(cid)
        files.append((cid, wav, text.strip(), fon))
    if desconeguts:
        for ch, ids in desconeguts.items():
            print(f"símbol fora del vocabulari {ch!r} (U+{ord(ch):04X}) en {len(ids)} clips: {ids[:5]}")
        sys.exit(1)

    # Validació repartida entre capítols i sempre la mateixa (llavor fixa).
    rng = random.Random(1234)
    val = set(rng.sample(range(len(files)), args.val))
    args.eixida.mkdir(parents=True, exist_ok=True)
    for nom, sel in (("train", lambda i: i not in val), ("val", lambda i: i in val)):
        linies = [f"{wav}|{args.spk}|{fon}" for i, (_, wav, _, fon) in enumerate(files) if sel(i)]
        (args.eixida / f"{nom}.txt").write_text("\n".join(linies) + "\n", encoding="utf-8")
    with open(args.eixida / "fonemes.tsv", "w", encoding="utf-8") as fh:
        fh.write("id\ttext\tfonemes\n")
        for cid, _, text, fon in files:
            fh.write(f"{cid}\t{text}\t{fon}\n")
    print(f"{len(files) - len(val)} train, {len(val)} val → {args.eixida}")


if __name__ == "__main__":
    main()
