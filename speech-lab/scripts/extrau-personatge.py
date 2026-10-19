#!/usr/bin/env python3
"""Extrau la veu d'un personatge identificat amb separa-personatges.py, sense els trams dubtosos.

Dos personatges amb veus pròximes (en el doblatge valencià de Doraemon, Doraemon
i Nobita són dues actrius) es barregen un poc en l'agrupament. Es queden només
els trams que s'assemblen al centre del seu grup almenys `--marge` més que al
centre de qualsevol altre parlant.

Entrada: `voz-dataset/personatges/` (trams.tsv i embeddings.npz) i els vocals.wav
de Demucs. Eixida en `voz-dataset/personatges/<nom>/`:

  <capitol>.wav   trams del personatge separats per silencis, mono 22,05 kHz:
                  entrada de segmenta-veu.py (--entrada voz-dataset/personatges/<nom>)
  trams.tsv       trams triats i descartats, amb la similitud i el marge

  .venv-voz/bin/python scripts/extrau-personatge.py --parlant 1 --nom doraemon
  .venv-voz/bin/python scripts/extrau-personatge.py --parlant 2 --nom nobita
"""
from __future__ import annotations

import argparse
import csv
import re
import shutil
import sys
import unicodedata
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
sp = __import__("separa-personatges")


def slug(nom: str) -> str:
    """«L'equipatge per a renyir» → «lequipatge_per_a_renyir»: sense espais ni apòstrofs en els id dels clips."""
    s = unicodedata.normalize("NFKD", nom).encode("ascii", "ignore").decode().lower()
    return re.sub(r"[^a-z0-9]+", "_", s.replace("'", "")).strip("_")


def main() -> None:
    base = sp.LAB / "voz-dataset" / "personatges"
    ap = argparse.ArgumentParser()
    ap.add_argument("--parlant", type=int, required=True, help="número del grup (parlant_NN)")
    ap.add_argument("--nom", required=True, help="carpeta d'eixida dins de --personatges")
    ap.add_argument("--marge", type=float, default=0.10,
                    help="similitud mínima amb el seu centre per damunt de la de qualsevol altre")
    ap.add_argument("--personatges", type=Path, default=base)
    ap.add_argument("--separat", type=Path, default=sp.LAB / "voz-dataset" / "separat" / "htdemucs")
    args = ap.parse_args()

    g = np.load(args.personatges / "embeddings.npz")
    emb, clau = g["emb"], g["clau"]
    with open(args.personatges / "trams.tsv", encoding="utf-8") as fh:
        files = list(csv.DictReader(fh, delimiter="\t"))
    if len(files) != len(clau):
        sys.exit("trams.tsv i embeddings.npz no casen: torna a passar separa-personatges.py")
    parlant = np.array([int(f["parlant"]) for f in files])
    if not (parlant == args.parlant).any():
        sys.exit(f"no hi ha cap tram del parlant {args.parlant:02d}")

    centres = {}
    for p in set(parlant) - {0}:
        c = emb[parlant == p].mean(0)
        centres[p] = c / np.linalg.norm(c)
    idx = np.flatnonzero(parlant == args.parlant)
    propi = emb[idx] @ centres[args.parlant]
    altre = np.max([emb[idx] @ c for p, c in centres.items() if p != args.parlant], axis=0)
    marge = propi - altre
    tria = marge >= args.marge

    eixida = args.personatges / args.nom
    if eixida.exists():
        shutil.rmtree(eixida)
    eixida.mkdir(parents=True)
    # En clau va el nom sencer de la carpeta de Demucs; en trams.tsv, el títol curt.
    trams = [(clau[k].split("|")[0], float(files[k]["inici"]), float(files[k]["final"])) for k in idx]
    curt = {clau[k].split("|")[0]: slug(files[k]["capitol"]) for k in idx}
    with open(eixida / "trams.tsv", "w", encoding="utf-8") as fh:
        fh.write("capitol\tinici\tfinal\tsimilitud\tmarge\ttriat\n")
        for (c, s, e), pr, m, t in zip(trams, propi, marge, tria):
            fh.write(f"{curt[c]}\t{s:.2f}\t{e:.2f}\t{pr:.3f}\t{m:.3f}\t{int(t)}\n")

    total = 0.0
    for cap in sorted({c for c, _, _ in trams}):
        ks = [k for k, (c, _, _) in enumerate(trams) if c == cap and tria[k]]
        if not ks:
            continue
        x, sr = sp.carrega(args.separat / cap / "vocals.wav")
        x = sp.remostreja(x, sr, sp.SR_EIXIDA)
        trossos = [x[max(0, int((trams[k][1] - sp.PAD) * sp.SR_EIXIDA)): int((trams[k][2] + sp.PAD) * sp.SR_EIXIDA)]
                   for k in ks]
        sp.escriu_wav(eixida / f"{curt[cap]}.wav", sp.ajunta(trossos, sp.SR_EIXIDA), sp.SR_EIXIDA)
        dur = sum(trams[k][2] - trams[k][1] for k in ks)
        total += dur
        print(f"{curt[cap]}: {len(ks)} trams, {dur / 60:.1f} min")
    print(f"{args.nom}: {tria.sum()} de {len(idx)} trams, {total / 60:.1f} min → {eixida}")


if __name__ == "__main__":
    main()
