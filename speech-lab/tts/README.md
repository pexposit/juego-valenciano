# tts/ — Matxa per a la clonació de veu

Material de tercers que fa servir la canalització de `scripts/*-matxa.py`. Tot es
pot refer amb `scripts/setup-matxa.sh`; ací es versiona per comoditat.

Ús exclusiu de laboratori, **no comercial**.

## Què hi ha

| Ruta | Origen | Llicència |
|---|---|---|
| `models/matxa-tts-cat-multiaccent/` | [projecte-aina/matxa-tts-cat-multiaccent](https://huggingface.co/projecte-aina/matxa-tts-cat-multiaccent) (checkpoint `epoch=629` i config) | GPL-3.0; les veus de LaFrescat són per a ús no comercial i de recerca (vegeu el README del model) |
| `models/alvocat-vocos-22khz/` | [projecte-aina/alvocat-vocos-22khz](https://huggingface.co/projecte-aina/alvocat-vocos-22khz) | [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) |
| `espeak-ng/` | Compilat de [projecte-aina/espeak-ng](https://github.com/projecte-aina/espeak-ng), commit `7d3266e2430a7529766b18901d26db34b6963c83` (veus `ca-va`, `ca-ba`, `ca-nw`) | GPL-3.0; el codi font és al repositori indicat |
| `*.log` | Logs de la compilació d'espeak i del fine-tune `narrador-v1` | — |

Els models són de Projecte AINA / Language Technologies Unit del Barcelona
Supercomputing Center (langtech@bsc.es). L'ús comercial de les veus requereix
llicència dels seus autors.

## Què no hi ha

- `Matcha-TTS-dev-cat/`: clon de [langtech-bsc/Matcha-TTS](https://github.com/langtech-bsc/Matcha-TTS) (branca `dev-cat`, commit `55497a8`) amb dos pedaços que aplica `setup-matxa.sh`.
- `espeak-ng-src/`: clon del codi font d'espeak.
- `runs/` i `proves/`: checkpoints, mostres i tensorboard del fine-tune. Contenen la veu del narrador de l'audiollibre i no es publiquen.

## espeak-ng compilat

Els scripts el troben sols (`scripts/matxa_entorn.py`). Per a fer-lo servir a mà:

```bash
E=speech-lab/tts/espeak-ng
ESPEAK_DATA_PATH=$E/share/espeak-ng-data LD_LIBRARY_PATH=$E/lib $E/bin/espeak-ng -q --ipa -v ca-va "Bon dia"
```

Està compilat per a Linux x86-64 amb prefix absolut; en una altra màquina pot
caldre recompilar-lo amb `setup-matxa.sh`.
