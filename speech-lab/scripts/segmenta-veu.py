#!/usr/bin/env python3
"""Talla els capítols nets en clips de 2–12 s i els transcriu (format LJSpeech).

Entrada: WAV mono 22,05 kHz de `voz-dataset/limpio/` (veu ja separada amb Demucs
i normalitzada). Eixida en `voz-dataset/clips/`:

  wavs/<capitol>_<nnnn>.wav   un clip per frase o tros de frase
  metadata.csv                id|text  (el que llig el fine-tune de Matxa)
  revisio.tsv                 per clip: formes estàndard sospitoses, acord amb la
                              transcripció del capítol sencer, confiança, text;
                              primer els que tenen sospitoses, després per acord
  paraules_<capitol>.json     caché de la transcripció (esborrar per a refer-la)

Els talls es fan pels silencis acústics de la veu separada (primer els de final
de frase i, si el tros passa de 12 s, el silenci intern més llarg); cada clip
es transcriu tot sol (el text ix de l'àudio exacte del clip). La transcripció
del capítol sencer, repartida pels temps de les paraules, només servix de control:
on no coincidixen hi ha un error d'una de les dues i cal escoltar. Whisper tendix a normalitzar el valencià cap a l'estàndard
(«seua» → «seva», «huit» → «vuit»...): per això cada clip es transcriu amb un
prompt en valencià normatiu (AVL), les grafies RACV del narrador es passen a AVL
i les formes estàndard que queden es marquen en revisio.tsv. Cal revisar el text
a mà abans d'entrenar.

  .venv/bin/python scripts/segmenta-veu.py
"""
from __future__ import annotations

import argparse
import difflib
import json
import logging
import os
import re
import sys
import wave
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "sidecar"))
from whisper_batch import ensure_cuda_libraries_visible, load_model  # noqa: E402

log = logging.getLogger("segmenta")

MIN_DUR, MAX_DUR = 2.0, 12.0
# La veu separada té les pauses a -60/-75 dBFS i la parla a -15/-25: el llindar
# de silenci queda lluny de tots dos.
LLINDAR_DB = -45.0
TRAMA = 0.01
SIL_MIN = 0.20     # silenci més curt que considerem punt de tall possible
SIL_FRASE = 0.60   # silencis a partir dels quals sempre tallem (final de frase)
PAD_ABANS, PAD_DESPRES = 0.12, 0.20
FADE = 0.01
# Whisper imita l'estil del prompt: un text curt en valencià normatiu (AVL) amb
# les formes que el model català tendix a canviar per les de l'estàndard.
PROMPT_VAL = ("Este rei i la seua gent van eixir hui de matí. Huit xiquets van vore com "
              "comença la marxa cap a la seua terra, i qualsevol persona sap que esta és la meua.")
# Forma estàndard → valenciana. El text base (sense prompt) només es canvia on
# la transcripció amb prompt té, en la mateixa posició, la forma valenciana.
ESTANDARD_A_VAL = {"seva": "seua", "seves": "seues", "meva": "meua", "meves": "meues",
                   "teva": "teua", "teves": "teues", "vuit": "huit", "veure": "vore",
                   "avui": "hui", "sortir": "eixir", "aquest": "este", "aquesta": "esta",
                   "aquests": "estos", "aquestes": "estes"}
# Formes estàndard que un narrador valencià quasi mai diu: el clip s'ha d'escoltar.
FORMES_ESTANDARD = set(ESTANDARD_A_VAL) | {"surt", "surten", "noi", "noia", "nen", "nena",
                                           "petit", "petita"}
# Grafies RACV → AVL (el narrador llig un text en Normes del Puig). Només les que
# sonen igual: «ensomi» o «escomença» es queden, perquè el text ha de dir el que
# se sent en l'àudio.
GRAFIES_AVL = {"cualsevol": "qualsevol", "cuant": "quant", "cuan": "quan", "cuants": "quants",
               "cuanta": "quanta", "cuantes": "quantes", "marcha": "marxa", "pròlec": "pròleg"}
RE_GRAFIES = re.compile(r"\b(" + "|".join(GRAFIES_AVL) + r")\b", re.IGNORECASE)
RE_COLETILLA = re.compile(r"[\s,.]*((moltes )?gràcies( a tots)?( per (veure|vore)[- ]?'?ns)?|bona nit"
                          r"|fins demà|subtítols.*)[.!]*\s*$", re.IGNORECASE)
MAX_DIST = 0.6   # s: paraula més lluny que açò de qualsevol tram → es descarta


def llig_wav(path: Path) -> tuple[np.ndarray, int]:
    with wave.open(str(path)) as w:
        assert w.getnchannels() == 1 and w.getsampwidth() == 2, f"{path}: cal mono 16 bits"
        return np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16), w.getframerate()


def escriu_wav(path: Path, x: np.ndarray, sr: int) -> None:
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(x.astype(np.int16).tobytes())


def paraules(model, wav: Path, cache: Path) -> list[dict]:  # noqa: ANN001
    """Paraules amb temps de faster-whisper; es guarden en JSON per a no retranscriure."""
    if cache.exists():
        return json.loads(cache.read_text(encoding="utf-8"))
    segments, _ = model.transcribe(
        str(wav), language="ca", beam_size=5, word_timestamps=True,
        # Sense context previ: en àudios llargs evita bucles i al·lucinacions.
        condition_on_previous_text=False, vad_filter=True,
    )
    out = []
    for seg in segments:
        for k, w in enumerate(seg.words or []):
            # Es guarda l'espai inicial de cada paraula («d» + «'aragó» van juntes),
            # però la primera d'un segment no en porta i quedaria enganxada a l'anterior.
            text = w.word if k or w.word.startswith(" ") else " " + w.word
            out.append({"w": text, "s": w.start, "e": w.end, "p": w.probability})
        log.info("  %6.1f s  %s", seg.end, seg.text.strip()[:70])
    cache.write_text(json.dumps(out, ensure_ascii=False), encoding="utf-8")
    return out


def paraules_clip(model, wav: Path, cache: dict, prompt: str | None) -> list[dict]:  # noqa: ANN001
    """Paraules d'un clip transcrit tot sol, amb caché."""
    if wav.stem not in cache:
        segments, _ = model.transcribe(str(wav), language="ca", beam_size=5, word_timestamps=True,
                                       condition_on_previous_text=False, initial_prompt=prompt)
        cache[wav.stem] = [{"w": w.word, "s": w.start, "e": w.end, "p": w.probability}
                           for seg in segments for w in seg.words or []]
    return cache[wav.stem]


def text_clip(ws: list[dict], fi_veu: float) -> tuple[str, list[float], list[str]]:
    """Text del clip sense el que whisper s'inventa en el silenci del final.

    El model d'Aina (entrenat amb 3CatParla) tendix a omplir el farciment final
    amb comiats de la tele («Gràcies.», «Gràcies per veure'ns», «Bona nit») o
    repeticions («pam pam»), sobretot amb prompt: es lleva tota paraula que
    comença després del final de la veu i les coletilles conegudes. Torna també
    el que s'ha llevat, per a revisar-ho.
    """
    bones, llevades = [], []
    for w in ws:
        # Els clítics («-ho», «'l») van amb la paraula d'abans: mai es lleven sols.
        clitic = w["w"].lstrip().startswith(("-", "'")) and bones and not llevades
        (llevades if w["s"] > fi_veu and not clitic else bones).append(w)
    text = " ".join("".join(w["w"] for w in bones).split())
    net = RE_COLETILLA.sub("", text).strip()
    if net != text:
        llevades.append({"w": text[len(net):]})
    extra = [" ".join(w["w"].split()) for w in llevades if w["w"].strip()]
    return avl(net), [w["p"] for w in bones] or [0.0], extra


def avl(text: str) -> str:
    """Passa a ortografia AVL les grafies de les Normes del Puig que copia whisper."""
    def canvia(m: re.Match) -> str:
        nova = GRAFIES_AVL[m.group(0).lower()]
        return nova.capitalize() if m.group(0)[0].isupper() else nova
    return RE_GRAFIES.sub(canvia, text)


def parts(token: str) -> list[str]:
    """Trossos d'una paraula en minúscules i sense puntuació («trenta-vuit» → trenta, vuit)."""
    return re.findall(r"[\wàèéíòóúïüç·]+", token.lower())


def valencianitza(base: str, val: str) -> tuple[str, list[str]]:
    """Posa en `base` les formes valencianes que `val` té en la mateixa posició.

    Només es canvien parelles d'ESTANDARD_A_VAL: el prompt fa que whisper
    s'invente frases, així que de la transcripció amb prompt no n'entra cap
    altra paraula.
    """
    b, v = base.split(), val.split()
    sm = difflib.SequenceMatcher(None, [parts(t) and " ".join(parts(t)) for t in b],
                                 [parts(t) and " ".join(parts(t)) for t in v], autojunk=False)
    canvis = []
    for op, i1, i2, j1, j2 in sm.get_opcodes():
        if op != "replace" or i2 - i1 != j2 - j1:
            continue
        for i, j in zip(range(i1, i2), range(j1, j2)):
            pb, pv = parts(b[i]), parts(v[j])
            if len(pb) != len(pv) or not any(x != y for x, y in zip(pb, pv)):
                continue
            if all(x == y or ESTANDARD_A_VAL.get(x) == y for x, y in zip(pb, pv)):
                nou = b[i]
                for x, y in zip(pb, pv):
                    if x != y:
                        nou = re.sub(rf"\b{x}\b", lambda m, y=y: y.capitalize() if m.group(0)[0].isupper()
                                     else y, nou, flags=re.IGNORECASE)
                canvis.append(f"{b[i]}→{nou}")
                b[i] = nou
    return " ".join(b), canvis


def sospitoses(text: str) -> list[str]:
    return [w for w in normal(text) if w in FORMES_ESTANDARD]


def normal(text: str) -> list[str]:
    return re.sub(r"[^\w' ]", " ", text.lower()).split()


def silencis(audio: np.ndarray, sr: int) -> list[tuple[float, float]]:
    """Trams per davall de LLINDAR_DB d'almenys SIL_MIN segons."""
    n = int(TRAMA * sr)
    x = audio[: len(audio) // n * n].astype(np.float32).reshape(-1, n) / 32768
    mut = 20 * np.log10(np.sqrt((x**2).mean(1)) + 1e-9) < LLINDAR_DB
    out, ini = [], None
    for i, m in enumerate(np.append(mut, False)):
        if m and ini is None:
            ini = i
        elif not m and ini is not None:
            if (i - ini) * TRAMA >= SIL_MIN:
                out.append((ini * TRAMA, i * TRAMA))
            ini = None
    return out


def trossos(sils: list[tuple[float, float]], total: float) -> list[tuple[float, float, float, float]]:
    """Trams de parla de [MIN_DUR, MAX_DUR] tallats pels silencis més llargs.

    Torna (inici amb farciment, final amb farciment, inici de veu, final de veu).
    """
    sils = [(0.0, 0.0), *sils, (total, total)]

    def parteix(i: int, j: int) -> list[tuple[int, int]]:
        # Tros de parla entre el silenci i i el j (índexs en `sils`).
        if sils[j][0] - sils[i][1] <= MAX_DUR or j - i < 2:
            return [(i, j)]
        k = max(range(i + 1, j), key=lambda k: sils[k][1] - sils[k][0])
        return parteix(i, k) + parteix(k, j)

    llargs = [0] + [k for k, (a, b) in enumerate(sils) if 0 < k < len(sils) - 1
                    and b - a >= SIL_FRASE] + [len(sils) - 1]
    parts = [p for a, b in zip(llargs, llargs[1:]) for p in parteix(a, b)]
    # Els trossos massa curts s'ajunten amb el veí de silenci més curt si hi caben.
    fusio = True
    while fusio:
        fusio = False
        for n, (i, j) in enumerate(parts):
            if sils[j][0] - sils[i][1] >= MIN_DUR:
                continue
            cands = []
            if n > 0 and sils[j][0] - sils[parts[n - 1][0]][1] <= MAX_DUR:
                cands.append((sils[i][1] - sils[i][0], n - 1))
            if n + 1 < len(parts) and sils[parts[n + 1][1]][0] - sils[i][1] <= MAX_DUR:
                cands.append((sils[j][1] - sils[j][0], n))
            if cands:
                m = min(cands)[1]
                parts[m:m + 2] = [(parts[m][0], parts[m + 1][1])]
                fusio = True
                break
    out = []
    for i, j in parts:
        s, e = sils[i][1], sils[j][0]
        if MIN_DUR <= e - s <= MAX_DUR:
            ps = max(s - PAD_ABANS, (sils[i][0] + s) / 2)
            pe = min(e + PAD_DESPRES, (e + sils[j][1]) / 2)
            out.append((ps, pe, s, e))
    return out


class LazyModel:
    """Només carrega whisper si alguna transcripció no està en caché."""

    def __init__(self, path: str, model_id: str) -> None:
        self.args, self.model = (path, model_id), None

    def transcribe(self, *a, **kw):  # noqa: ANN002, ANN003, ANN201
        if self.model is None:
            self.model = load_model(*self.args)
        return self.model.transcribe(*a, **kw)


def main() -> None:
    base = Path(__file__).resolve().parent.parent / "voz-dataset"
    ap = argparse.ArgumentParser()
    ap.add_argument("--entrada", type=Path, default=base / "limpio")
    ap.add_argument("--eixida", type=Path, default=base / "clips")
    ap.add_argument("--model", default=os.environ.get(
        "AINA_MODEL_PATH", "models/faster-whisper-large-v3-ca-3catparla"))
    ap.add_argument("--model-id", default="projecte-aina/faster-whisper-large-v3-ca-3catparla")
    args = ap.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(name)s: %(message)s", stream=sys.stderr)
    ensure_cuda_libraries_visible()

    model = LazyModel(args.model, args.model_id)
    wavs_dir = args.eixida / "wavs"
    if wavs_dir.exists():
        for old in wavs_dir.glob("*.wav"):
            old.unlink()
    wavs_dir.mkdir(parents=True, exist_ok=True)
    meta, revisio, total = [], [], 0.0
    # Caché de les transcripcions per clip: els talls són deterministes, així que
    # només cal refer-la si canvia el prompt o els paràmetres del tall.
    cache_path = args.eixida / "paraules_clips.json"
    cache_base, cache_val = {}, {}
    if cache_path.exists():
        guardat = json.loads(cache_path.read_text(encoding="utf-8"))
        cache_base = guardat.get("base", {})
        if guardat.get("prompt") == PROMPT_VAL:
            cache_val = guardat["val"]

    for wav in sorted(args.entrada.glob("*.wav")):
        log.info("transcriu %s", wav.name)
        audio, sr = llig_wav(wav)
        ws = paraules(model, wav, args.eixida / f"paraules_{wav.stem}.json")
        trams = trossos(silencis(audio, sr), len(audio) / sr)
        # Els temps de whisper són aproximats: cada paraula va al tram més pròxim
        # (si no, les dels extrems cauen al silenci i es perden). Les que queden
        # lluny de tot tram són de trossos descartats.
        per_tram: list[list[dict]] = [[] for _ in trams]
        for w in ws:
            mig = (w["s"] + w["e"]) / 2
            dist, t = min((max(vs - mig, mig - ve, 0.0), t) for t, (_, _, vs, ve) in enumerate(trams))
            if dist <= MAX_DIST:
                per_tram[t].append(w)
        n = 0
        for (s, e, vs, ve), c in zip(trams, per_tram):
            if not c:
                continue  # soroll o respiració sense cap paraula
            n += 1
            x = audio[int(s * sr): int(e * sr)].astype(np.float32)
            f = int(FADE * sr)
            x[:f] *= np.linspace(0, 1, f)
            x[-f:] *= np.linspace(1, 0, f)
            cid = f"{wav.stem}_{n:04d}"
            escriu_wav(wavs_dir / f"{cid}.wav", x, sr)
            clip_wav = wavs_dir / f"{cid}.wav"
            text, probs, extra = text_clip(paraules_clip(model, clip_wav, cache_base, None), ve - s)
            if not text:
                continue
            val, _, _ = text_clip(paraules_clip(model, clip_wav, cache_val, PROMPT_VAL), ve - s)
            text, canvis = valencianitza(text, val)
            llarg = " ".join("".join(w["w"] for w in c).split())
            acord = difflib.SequenceMatcher(None, normal(text), normal(llarg)).ratio()
            meta.append(f"{cid}|{text}")
            sosp = sospitoses(text)
            if extra:
                sosp.append("llevat:" + " ".join(extra))
            revisio.append((-len(sosp), acord, float(np.mean(probs)), min(probs), e - s, cid,
                            ",".join(sosp), " ".join(canvis), text, llarg))
            total += e - s
        log.info("%s: %d clips", wav.name, n)

    cache_path.write_text(json.dumps({"base": cache_base, "prompt": PROMPT_VAL, "val": cache_val},
                                     ensure_ascii=False), encoding="utf-8")
    (args.eixida / "metadata.csv").write_text("\n".join(meta) + "\n", encoding="utf-8")
    with open(args.eixida / "revisio.tsv", "w", encoding="utf-8") as fh:
        fh.write("id\tdurada\tsospitoses\tcanvis_val\tacord\tconf_mitjana\tconf_min\ttext\ttext_llarg\n")
        for _, acord, mean, mn, dur, cid, sosp, canvis, text, llarg in sorted(revisio):
            fh.write(f"{cid}\t{dur:.2f}\t{sosp}\t{canvis}\t{acord:.3f}\t{mean:.3f}\t{mn:.3f}"
                     f"\t{text}\t{llarg}\n")
    log.info("fet: %d clips, %.1f min en %s", len(meta), total / 60, args.eixida)


if __name__ == "__main__":
    main()
