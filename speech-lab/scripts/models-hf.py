#!/usr/bin/env python3
"""Puja i descarrega els models de veu entrenats d'un repositori PRIVAT de Hugging Face.

Els models (RVC de cada personatge i fine-tunes de Matxa) no poden anar a GitHub:
el repositori del joc és públic i les veus són de doblatges i vídeos amb drets.
Van a un repositori de models privat de Hugging Face amb les mateixes rutes que
dins de speech-lab/, així que la descàrrega cau on el laboratori els busca.
Què es comparteix ho diu scripts/models.json.

  .venv/bin/python scripts/models-hf.py descarrega              # tots els models
  .venv/bin/python scripts/models-hf.py descarrega doraemon heidi veus-v1
  .venv/bin/python scripts/models-hf.py puja                    # només qui els entrena

Cal haver iniciat sessió (`.venv/bin/hf auth login`, o HF_TOKEN) amb un compte
que tinga accés al repositori: lectura per a descarregar, escriptura per a pujar.
La descàrrega és incremental: tornar-la a executar només baixa el que ha canviat.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

from huggingface_hub import CommitOperationAdd, HfApi, snapshot_download
from huggingface_hub.errors import GatedRepoError, HfHubHTTPError, RepositoryNotFoundError

LAB = Path(__file__).resolve().parent.parent
MANIFEST = LAB / "scripts" / "models.json"
SUMES = "SHA256SUMS"

LLEGEIX = """# Models de veu de speech-lab (ús intern)

Models entrenats del laboratori de veu de ParlaVal: RVC de cada personatge
(Applio) i fine-tunes de Matxa. **Repositori privat**: les veus són de doblatges i
vídeos amb drets i no es poden publicar ni redistribuir fora del projecte.

Les rutes són les de `speech-lab/`. Per a descarregar-los, des del repositori del joc:

```bash
npm run models:speech        # o: cd speech-lab && .venv/bin/python scripts/models-hf.py descarrega
```

Comprovació d'integritat: `sha256sum -c SHA256SUMS` des de `speech-lab/`.
"""


def falla(missatge: str) -> None:
    print(f"[models] {missatge}", file=sys.stderr)
    sys.exit(1)


def manifest() -> dict:
    return json.loads(MANIFEST.read_text(encoding="utf-8"))


def fitxers(m: dict, noms: list[str]) -> list[str]:
    """Rutes relatives a speech-lab/ dels models triats (tots si `noms` és buit)."""
    desconeguts = set(noms) - set(m["rvc"]) - set(m["matxa"])
    if desconeguts:
        falla(f"no hi ha cap model que es diga {', '.join(sorted(desconeguts))} en {MANIFEST.name}")
    rutes = []
    for nom, pth in m["rvc"].items():
        if not noms or nom in noms:
            d = f"tts/rvc/Applio/logs/{nom}"
            rutes += [f"{d}/{pth}", f"{d}/{nom}.index", f"{d}/config.json", f"{d}/model_info.json"]
    for run, ckpts in m["matxa"].items():
        if not noms or run in noms:
            rutes += [f"tts/runs/{run}/checkpoints/{c}" for c in ckpts] + [f"tts/runs/{run}/veus.json"]
    return rutes


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for bloc in iter(lambda: f.read(1 << 20), b""):
            h.update(bloc)
    return h.hexdigest()


def puja(m: dict) -> None:
    api = HfApi()
    rutes = fitxers(m, [])
    falten = [r for r in rutes if not (LAB / r).is_file()]
    if falten:
        falla("falten fitxers en local:\n  " + "\n  ".join(falten))
    try:
        api.create_repo(m["repo"], repo_type="model", private=True, exist_ok=True)
        # Si el repositori ja existia, create_repo no el fa privat: es comprova abans de pujar res.
        if not api.model_info(m["repo"]).private:
            falla(f"{m['repo']} és PÚBLIC: fes-lo privat en la seua configuració abans de pujar")
    except HfHubHTTPError as e:
        falla(f"no puc crear ni llegir {m['repo']} (el token ha de tindre permís d'escriptura): {e}")
    print(f"[models] calculant sumes de {len(rutes)} fitxers")
    sumes = "".join(f"{sha256(LAB / r)}  {r}\n" for r in rutes)
    # Un sol commit amb la llista exacta; Hugging Face no torna a pujar els fitxers que ja té.
    operacions = [CommitOperationAdd(path_in_repo=r, path_or_fileobj=str(LAB / r)) for r in rutes]
    operacions += [CommitOperationAdd(path_in_repo=SUMES, path_or_fileobj=sumes.encode()),
                   CommitOperationAdd(path_in_repo="README.md", path_or_fileobj=LLEGEIX.encode())]
    print(f"[models] pujant a {m['repo']}")
    api.create_commit(repo_id=m["repo"], operations=operacions, commit_message="models de veu")
    print(f"[models] fet: https://huggingface.co/{m['repo']} (privat)")


def descarrega(m: dict, noms: list[str]) -> None:
    rutes = fitxers(m, noms)
    print(f"[models] descarregant {len(rutes)} fitxers de {m['repo']}")
    sense_acces = (f"no tens accés a {m['repo']}. Demana que et convidin al repositori, crea un token de "
                   "lectura en https://huggingface.co/settings/tokens i fes `.venv/bin/hf auth login`")
    try:
        snapshot_download(m["repo"], repo_type="model", local_dir=LAB, allow_patterns=rutes + [SUMES])
    except (RepositoryNotFoundError, GatedRepoError):
        falla(sense_acces)
    except HfHubHTTPError as e:
        falla(f"error de Hugging Face: {e}")
    # Amb un token invàlid, snapshot_download no sempre falla: torna sense haver baixat res.
    falten = [r for r in rutes + [SUMES] if not (LAB / r).is_file()]
    if falten:
        falla(sense_acces if SUMES in falten else "no s'han baixat: " + ", ".join(falten))
    sumes = dict(reversed(l.split("  ", 1)) for l in (LAB / SUMES).read_text().splitlines() if l)
    dolents = [r for r in rutes if r in sumes and sha256(LAB / r) != sumes[r]]
    if dolents:
        falla("suma incorrecta (torna a descarregar): " + ", ".join(dolents))
    print("[models] fet; arranca el laboratori (npm run dev:speech) i ixen en «Generació d'àudio»")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="ordre", required=True)
    sub.add_parser("puja", help="puja els models de models.json al repositori privat")
    d = sub.add_parser("descarrega", help="descarrega els models (tots o els indicats)")
    d.add_argument("noms", nargs="*", help="personatges RVC o runs de Matxa (per defecte, tots)")
    args = ap.parse_args()
    m = manifest()
    if args.ordre == "puja":
        puja(m)
    else:
        descarrega(m, args.noms)


if __name__ == "__main__":
    main()
