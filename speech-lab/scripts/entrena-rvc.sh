#!/usr/bin/env bash
# Entrena un model RVC (Applio) amb els clips revisats d'un personatge.
#
# Matxa amb poques dades dona una veu sorollosa; RVC només aprén el timbre i
# s'aplica damunt d'una veu de Matxa neta (gina), que posa el valencià i la
# prosòdia. Els clips són els de voz-dataset/clips-<nom>/metadata.csv (els
# descartats en la revisió no hi són), a 22,05 kHz: per això el model és de
# 32 kHz, que ja cobrix tota l'amplada de banda que tenen.
#
#   scripts/entrena-rvc.sh doraemon [èpoques]
#   REPRENDRE=1 scripts/entrena-rvc.sh doraemon     # continua des de l'últim G_/D_*.pth
#
# Eixida: tts/rvc/Applio/logs/<nom>/ (pesos <nom>_<època>e_*.pth cada 50 èpoques i índex .index).
# --save-every-weights NO es passa: en core.py és un flag amb default True i passar-lo el desactiva.
# Requisits: .venv-rvc i Applio en tts/rvc/Applio (scripts/setup-rvc.sh).
set -euo pipefail

NOM=${1:?nom del personatge (voz-dataset/clips-<nom>)}
EPOQUES=${2:-300}
LAB=$(cd "$(dirname "$0")/.." && pwd)
APPLIO=$LAB/tts/rvc/Applio
PY=$LAB/.venv-rvc/bin/python
DADES=$LAB/tts/rvc/dades/$NOM
CLIPS=$LAB/voz-dataset/clips-$NOM
REPRENDRE=${REPRENDRE:-0}
# En 6 GB, la mostra d'àudio que Applio genera cada 50 èpoques no troba lloc si la memoria està fragmentada.
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

# core.py ix amb codi 0 encara que un pas falle: cada pas es comprova pel que deixa en disc.
falla() { echo "[rvc:$NOM] ha fallat: $1" >&2; exit 1; }
LOGS=$APPLIO/logs/$NOM

if [[ $REPRENDRE != 1 ]]; then
  rm -rf "$DADES"
  mkdir -p "$DADES"
  while IFS='|' read -r id _; do
    [[ -n $id ]] && cp "$CLIPS/wavs/$id.wav" "$DADES/"
  done < "$CLIPS/metadata.csv"
  echo "[rvc:$NOM] $(ls "$DADES" | wc -l) clips"

  cd "$APPLIO"
  rm -rf "$LOGS"
  "$PY" core.py preprocess --model-name "$NOM" --dataset-path "$DADES" --sample-rate 32000 \
    --cpu-cores "$(nproc)" --cut-preprocess Automatic --normalization-mode post
  [[ -n $(ls -A "$LOGS/sliced_audios" 2>/dev/null) ]] || falla preprocess
  "$PY" core.py extract --model-name "$NOM" --f0-method rmvpe --sample-rate 32000 \
    --embedder-model contentvec --gpu 0 --cpu-cores "$(nproc)"
  [[ -f $LOGS/config.json && -d $LOGS/extracted ]] || falla extract
else
  compgen -G "$LOGS/G_*.pth" > /dev/null || falla "no hi ha cap checkpoint per a reprendre"
  cd "$APPLIO"
  echo "[rvc:$NOM] reprenent des de $(ls -v "$LOGS"/G_*.pth | tail -1 | xargs basename)"
fi
"$PY" core.py train --model-name "$NOM" --sample-rate 32000 --vocoder HiFi-GAN \
  --total-epoch "$EPOQUES" --save-every-epoch 50 --batch-size 8 --gpu 0 --pretrained
compgen -G "$LOGS/${NOM}_*e_*.pth" > /dev/null || falla train
"$PY" core.py index --model-name "$NOM" --index-algorithm Auto
compgen -G "$LOGS/*.index" > /dev/null || falla index
echo "[rvc:$NOM] fet: $LOGS"
