#!/usr/bin/env bash
# Prepara RVC (Applio) en speech-lab/tts/rvc/ per a donar timbre de personatge a la veu de Matxa:
# entorn .venv-rvc (separat de .venv-voz: Applio fixa versions pròpies de torch i numpy),
# codi d'Applio i models preentrenats (RMVPE, ContentVec, HiFi-GAN; ~1,8 GB).
# És idempotent: el que ja està fet no es torna a fer.
set -euo pipefail

LAB=$(cd "$(dirname "$0")/.." && pwd)
VENV=$LAB/.venv-rvc
APPLIO=$LAB/tts/rvc/Applio
VERSIO=3.6.6

if [[ ! -d $APPLIO ]]; then
  echo "[setup:rvc] clonant Applio $VERSIO"
  mkdir -p "$(dirname "$APPLIO")"
  git clone -q --depth 1 --branch "$VERSIO" https://github.com/IAHispano/Applio.git "$APPLIO"
fi

if [[ ! -x $VENV/bin/python ]]; then
  echo "[setup:rvc] creant $VENV"
  python3.12 -m venv "$VENV"
  "$VENV/bin/pip" install -q --upgrade pip
fi
if ! "$VENV/bin/python" -c "import torch" 2>/dev/null; then
  # Applio demana cu128, però el driver 535 només arriba a CUDA 12.2: cu126 sí que hi funciona.
  echo "[setup:rvc] instal·lant torch (CUDA 12.6)"
  "$VENV/bin/pip" install -q torch==2.11.0 torchaudio==2.11.0 --index-url https://download.pytorch.org/whl/cu126
fi
if ! "$VENV/bin/python" -c "import faiss, onnxruntime, torchcrepe" 2>/dev/null; then
  echo "[setup:rvc] instal·lant dependències d'Applio (sense la interfície gradio)"
  REQ=$(mktemp)
  # Les línies de Windows es lleven, però onnxruntime (marcat «!= win32») sí que cal en Linux.
  grep -vE '^(torch|torchaudio)==|sys_platform == "win32"' "$APPLIO/requirements-engine.txt" > "$REQ"
  "$VENV/bin/pip" install -q -r "$REQ" python-ffmpeg
  rm -f "$REQ"
fi

if [[ ! -f $APPLIO/rvc/models/predictors/rmvpe.pt ]]; then
  echo "[setup:rvc] baixant models preentrenats"
  (cd "$APPLIO" && "$VENV/bin/python" core.py prerequisites --pretraineds-hifigan --models --no-exe)
fi
"$VENV/bin/python" -c "import torch; assert torch.cuda.is_available(), 'CUDA no disponible'"
echo "[setup:rvc] llest"
