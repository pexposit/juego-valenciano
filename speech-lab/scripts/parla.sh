#!/usr/bin/env bash
# Text en valencià → veu d'un personatge: Matxa (model base) + conversió RVC.
#
# Matxa posa la pronunciació i la prosòdia amb una veu neta (el locutor «base»
# del personatge en scripts/rvc-personatges.json: gina per defecte, lluc per a
# veus d'home) i el model RVC del personatge (scripts/entrena-rvc.sh) li canvia
# el timbre. El to es mou fins al del personatge amb TO (semitons), per defecte
# el del mateix fitxer, que és el que fa servir el laboratori.
#
#   scripts/parla.sh doraemon "Hola Nobita, què fas?"            # → tts/rvc/eixida/doraemon_<hora>.wav
#   scripts/parla.sh nobita "Doraemon, ajuda'm!" eixida.wav
#   scripts/parla.sh narrador "Era una nit freda d'hivern."
#   TO=4 INDEX=0.5 PTH=.../doraemon_200e_5800s.pth scripts/parla.sh doraemon "..."
set -euo pipefail

NOM=${1:?personatge (doraemon, nobita...)}
TEXT=${2:?text a dir}
LAB=$(cd "$(dirname "$0")/.." && pwd)
EIXIDA=$(realpath -m "${3:-$LAB/tts/rvc/eixida/${NOM}_$(date +%H%M%S).wav}")
LOGS=$LAB/tts/rvc/Applio/logs/$NOM
# Locutor de partida i to del personatge respecte d'ell (12·log2(f0 personatge / f0 locutor)).
personatge() {
  "$LAB/.venv-voz/bin/python" -c 'import json, sys; print(json.load(open(sys.argv[1])).get(sys.argv[2], {}).get(sys.argv[3], sys.argv[4]))' \
    "$LAB/scripts/rvc-personatges.json" "$NOM" "$1" "$2"
}
BASE=$(personatge base 7)
TO=${TO:-$(personatge to 0)}
INDEX=${INDEX:-$(personatge index 0.6)}
# Per defecte, els pesos de l'última època guardada.
PTH=${PTH:-$(ls -v "$LOGS"/"${NOM}"_*e_*.pth 2>/dev/null | tail -1 || true)}
IDX=$(ls "$LOGS"/*.index 2>/dev/null | head -1 || true)
[[ -f $PTH ]] || { echo "no hi ha model RVC per a $NOM: scripts/entrena-rvc.sh $NOM" >&2; exit 1; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$(dirname "$EIXIDA")"
"$LAB/.venv-voz/bin/python" "$LAB/scripts/sintetitza-matxa.py" --spk "$BASE" --text "$TEXT" --eixida "$TMP" > /dev/null
cd "$LAB/tts/rvc/Applio"
"$LAB/.venv-rvc/bin/python" core.py infer --input-path "$TMP/frase_01_spk$BASE.wav" --output-path "$EIXIDA" \
  --pth-path "$PTH" --index-path "$IDX" --pitch "$TO" --index-rate "$INDEX" --protect 0.33 \
  --f0-method rmvpe --embedder-model contentvec --export-format WAV > "$TMP/rvc.log" 2>&1 \
  || { cat "$TMP/rvc.log" >&2; exit 1; }
[[ -f $EIXIDA ]] || { cat "$TMP/rvc.log" >&2; exit 1; }
echo "$EIXIDA"
