#!/usr/bin/env python3
"""Separa per personatge la veu dels capítols de dibuixos ja passats per Demucs.

Entrada: `voz-dataset/separat/htdemucs/<capítol>/vocals.wav` dels capítols que
casen amb `--patro` (per defecte, Doraemon). Passos:

  1. Trams de parla pels silencis de la veu separada. En un diàleg els
     personatges s'alternen amb pauses curtes, així que es talla en silencis
     més breus que en segmenta-veu.py i els trams llargs es parteixen.
  2. Empremta de veu ECAPA (SpeechBrain, entrenada amb VoxCeleb) de cada tram.
  3. Agrupament aglomeratiu per distància cosinus amb tots els capítols junts:
     els actors de doblatge són els mateixos en tots.

Eixida en `voz-dataset/personatges/`:

  trams.tsv                capitol, inici, final, parlant, similitud amb el centre del grup
  resum.tsv                per parlant: minuts, trams i capítols on ix
  parlant_NN/mostra.wav    els trams més representatius, per a escoltar i posar-li nom
  parlant_NN/<capitol>.wav tots els seus trams del capítol separats per silencis,
                           mono 16 bits 22,05 kHz: és l'entrada de segmenta-veu.py
                           (--entrada voz-dataset/personatges/parlant_NN)
  embeddings.npz           caché de les empremtes (esborrar per a refer-les)

Els grups que no arriben a `--min-grup` segons van a `parlant_00` (resta).
El número de cada grup va per durada total: el 01 és qui més parla.

  .venv-voz/bin/python scripts/separa-personatges.py
  .venv-voz/bin/python scripts/separa-personatges.py --llindar 0.55   # més grups
"""
from __future__ import annotations

import argparse
import logging
import shutil
import sys
import wave
from pathlib import Path

import numpy as np

log = logging.getLogger("personatges")

LAB = Path(__file__).resolve().parent.parent
SR_EMB, SR_EIXIDA = 16000, 22050
TRAMA = 0.01
SIL_MIN = 0.15     # pausa mínima entre dos intervencions
SIL_INTERN = 0.06  # pausa on es pot partir un tram llarg
MIN_TRAM, MAX_TRAM = 1.2, 8.0
# El llindar de silenci va relatiu al nivell de parla de cada capítol: la mescla
# dels dibuixos no té el mateix volum en tots i Demucs deixa restes d'efectes.
MARGE_DB = 32.0
PAD = 0.08
SEPARACIO = 0.8    # silenci entre trams en els WAV de cada parlant (> SIL_FRASE de segmenta)
NIVELL_DB = -20.0  # nivell de parla dels WAV d'eixida (segmenta talla a -45 dBFS)
N_MOSTRA = 12


def carrega(path: Path) -> tuple[np.ndarray, int]:
    import soundfile as sf
    x, sr = sf.read(str(path), dtype="float32", always_2d=True)
    return x.mean(1), sr


def remostreja(x: np.ndarray, sr: int, nou: int) -> np.ndarray:
    import torch
    import torchaudio.functional as F
    return F.resample(torch.from_numpy(x), sr, nou).numpy()


def db_trames(x: np.ndarray, sr: int) -> np.ndarray:
    n = int(TRAMA * sr)
    t = x[: len(x) // n * n].reshape(-1, n)
    return 20 * np.log10(np.sqrt((t**2).mean(1)) + 1e-9)


def trams_parla(x: np.ndarray, sr: int) -> list[tuple[float, float]]:
    """Trams de [MIN_TRAM, MAX_TRAM] s entre silencis; els llargs es parteixen per la pausa més llarga."""
    db = db_trames(x, sr)
    llindar = np.percentile(db, 95) - MARGE_DB
    mut = db < llindar

    def pauses(i0: int, i1: int, minim: float) -> list[tuple[int, int]]:
        out, ini = [], None
        for i in range(i0, i1 + 1):
            m = i < i1 and mut[i]
            if m and ini is None:
                ini = i
            elif not m and ini is not None:
                if (i - ini) * TRAMA >= minim and ini > i0 and i < i1:
                    out.append((ini, i))
                ini = None
        return out

    def parteix(a: int, b: int) -> list[tuple[int, int]]:
        if (b - a) * TRAMA <= MAX_TRAM:
            return [(a, b)]
        ps = pauses(a, b, SIL_INTERN)
        if not ps:
            return [(a, b)]  # sense cap pausa: es queda sencer i el filtre de durada el descarta
        p0, p1 = max(ps, key=lambda p: p[1] - p[0])
        return parteix(a, p0) + parteix(p1, b)

    # Trams de parla = el que queda entre pauses de SIL_MIN.
    limits = [(0, 0), *pauses(0, len(mut), SIL_MIN), (len(mut), len(mut))]
    out = []
    for (_, a), (b, _) in zip(limits, limits[1:]):
        while a < b and mut[a]:
            a += 1
        while b > a and mut[b - 1]:
            b -= 1
        for s, e in parteix(a, b):
            if MIN_TRAM <= (e - s) * TRAMA <= MAX_TRAM:
                out.append((s * TRAMA, e * TRAMA))
    return out


def empremtes(capitols: dict[str, tuple[np.ndarray, int]], trams: list[tuple[str, float, float]],
              cache: Path) -> np.ndarray:
    clau = np.array([f"{c}|{s:.2f}|{e:.2f}" for c, s, e in trams])
    if cache.exists():
        g = np.load(cache)
        if g["clau"].shape == clau.shape and (g["clau"] == clau).all():
            return g["emb"]
    import torch
    from speechbrain.inference.speaker import EncoderClassifier
    enc = EncoderClassifier.from_hparams(source="speechbrain/spkrec-ecapa-voxceleb",
                                         savedir=str(LAB / "models" / "spkrec-ecapa-voxceleb"),
                                         run_opts={"device": "cpu"})
    a16 = {c: remostreja(x, sr, SR_EMB) for c, (x, sr) in capitols.items()}
    embs = []
    with torch.no_grad():
        for k, (c, s, e) in enumerate(trams):
            seg = torch.from_numpy(a16[c][int(s * SR_EMB): int(e * SR_EMB)]).unsqueeze(0)
            embs.append(enc.encode_batch(seg).squeeze().numpy())
            if k % 200 == 0:
                log.info("  empremtes %d/%d", k, len(trams))
    emb = np.stack(embs)
    emb /= np.linalg.norm(emb, axis=1, keepdims=True)
    np.savez(cache, clau=clau, emb=emb)
    return emb


def escriu_wav(path: Path, x: np.ndarray, sr: int) -> None:
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes((np.clip(x, -1, 1) * 32767).astype(np.int16).tobytes())


def ajunta(trossos: list[np.ndarray], sr: int) -> np.ndarray:
    """Trams separats per silenci, amb fos curt i el nivell de parla a NIVELL_DB."""
    f = int(0.01 * sr)
    sil = np.zeros(int(SEPARACIO * sr), dtype=np.float32)
    out = [sil]
    for t in trossos:
        t = t.copy()
        t[:f] *= np.linspace(0, 1, f)
        t[-f:] *= np.linspace(1, 0, f)
        out += [t, sil]
    x = np.concatenate(out)
    parla = np.percentile(db_trames(x, sr), 95)
    x *= 10 ** ((NIVELL_DB - parla) / 20)
    pic = np.abs(x).max()
    return x * (0.97 / pic) if pic > 0.97 else x


def main() -> None:
    base = LAB / "voz-dataset"
    ap = argparse.ArgumentParser()
    ap.add_argument("--entrada", type=Path, default=base / "separat" / "htdemucs")
    ap.add_argument("--patro", default="*Doraemon*", help="capítols de --entrada a processar")
    ap.add_argument("--eixida", type=Path, default=base / "personatges")
    ap.add_argument("--llindar", type=float, default=0.65,
                    help="distància cosinus màxima dins d'un grup (més baix → més grups)")
    ap.add_argument("--min-grup", type=float, default=30.0, help="segons mínims per a ser un parlant")
    args = ap.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(name)s: %(message)s", stream=sys.stderr)

    from sklearn.cluster import AgglomerativeClustering

    capitols, trams = {}, []
    for d in sorted(args.entrada.glob(args.patro)):
        wav = d / "vocals.wav"
        if not wav.exists():
            continue
        x, sr = carrega(wav)
        capitols[d.name] = (x, sr)
        ts = trams_parla(x, sr)
        trams += [(d.name, s, e) for s, e in ts]
        log.info("%s: %d trams, %.1f min de parla", d.name, len(ts), sum(e - s for s, e in ts) / 60)
    if not trams:
        sys.exit(f"cap vocals.wav en {args.entrada}/{args.patro}")

    args.eixida.mkdir(parents=True, exist_ok=True)
    emb = empremtes(capitols, trams, args.eixida / "embeddings.npz")
    etiq = AgglomerativeClustering(n_clusters=None, distance_threshold=args.llindar,
                                   metric="cosine", linkage="average").fit_predict(emb)
    dur = np.array([e - s for _, s, e in trams])

    # Renumera per durada total; els grups menuts van a 0 (resta).
    totals = sorted(((dur[etiq == g].sum(), g) for g in set(etiq)), reverse=True)
    nou = {g: (n if t >= args.min_grup else 0) for n, (t, g) in enumerate(totals, 1)}
    parlant = np.array([nou[g] for g in etiq])
    sim = np.zeros(len(trams))
    for p in set(parlant):
        m = parlant == p
        centre = emb[m].mean(0)
        sim[m] = emb[m] @ (centre / np.linalg.norm(centre))

    for d in args.eixida.glob("parlant_*"):
        shutil.rmtree(d)
    curt = {c: c.split(" - ")[-1] if c.startswith("Doraemon") else c.split(" - ")[0]
            for c in capitols}
    with open(args.eixida / "trams.tsv", "w", encoding="utf-8") as fh:
        fh.write("capitol\tinici\tfinal\tparlant\tsimilitud\n")
        for (c, s, e), p, si in zip(trams, parlant, sim):
            fh.write(f"{curt[c]}\t{s:.2f}\t{e:.2f}\t{p:02d}\t{si:.3f}\n")

    a22 = {c: remostreja(x, sr, SR_EIXIDA) for c, (x, sr) in capitols.items()}

    def tros(k: int) -> np.ndarray:
        c, s, e = trams[k]
        return a22[c][max(0, int((s - PAD) * SR_EIXIDA)): int((e + PAD) * SR_EIXIDA)]

    with open(args.eixida / "resum.tsv", "w", encoding="utf-8") as fh:
        fh.write("parlant\tminuts\ttrams\tcapitols\n")
        for p in sorted(set(parlant), key=lambda p: (p == 0, p)):
            idx = np.flatnonzero(parlant == p)
            dir_p = args.eixida / f"parlant_{p:02d}"
            dir_p.mkdir()
            # Mostra: els més pròxims al centre, en ordre de capítol i temps.
            millors = sorted(idx[np.argsort(-sim[idx])][:N_MOSTRA], key=lambda k: trams[k][:2])
            escriu_wav(dir_p / "mostra.wav", ajunta([tros(k) for k in millors], SR_EIXIDA), SR_EIXIDA)
            caps = sorted({trams[k][0] for k in idx})
            for c in caps:
                ks = [k for k in idx if trams[k][0] == c]
                escriu_wav(dir_p / f"{curt[c]}.wav", ajunta([tros(k) for k in ks], SR_EIXIDA),
                           SR_EIXIDA)
            fh.write(f"{p:02d}\t{dur[idx].sum() / 60:.1f}\t{len(idx)}\t{len(caps)}\n")
            log.info("parlant_%02d: %5.1f min, %4d trams, %d capítols", p, dur[idx].sum() / 60,
                     len(idx), len(caps))


if __name__ == "__main__":
    main()
