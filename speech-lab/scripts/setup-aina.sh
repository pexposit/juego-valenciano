#!/usr/bin/env bash
# Prepara el reconeixedor per lots: faster-whisper (GPU) + model català d'Aina.
# És idempotent: si ja està tot fet no torna a descarregar res.
#
# Ús: bash speech-lab/scripts/setup-aina.sh  (des de l'arrel del repositori)
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="${AINA_VENV_DIR:-$LAB_DIR/.venv}"
MODEL_ID="${AINA_MODEL_ID:-projecte-aina/faster-whisper-large-v3-ca-3catparla}"
MODEL_DIR="${AINA_MODEL_PATH:-$LAB_DIR/models/faster-whisper-large-v3-ca-3catparla}"
# Memòria cau: si el model ja s'ha descarregat a /tmp s'aprofita.
CACHE_DIR="/tmp/faster-whisper-large-v3-ca-3catparla"

echo "[setup:aina] laboratori: $LAB_DIR"
echo "[setup:aina] model: $MODEL_ID"

# ── 1. faster-whisper al mateix venv que Vosk ──────────────────────────────
if [[ ! -x "$VENV_DIR/bin/python" ]]; then
  echo "[setup:aina] no trobe el venv a $VENV_DIR; executa primer npm run setup:speech" >&2
  exit 1
fi

echo "[setup:aina] instal·lant faster-whisper"
"$VENV_DIR/bin/pip" install -q --disable-pip-version-check faster-whisper

# ctranslate2 amb CUDA només cal si hi ha GPU; si falla, la versió CPU ja hi és.
if command -v nvidia-smi >/dev/null 2>&1; then
  echo "[setup:aina] GPU detectada: provant ctranslate2 amb CUDA"
  "$VENV_DIR/bin/pip" install -q --disable-pip-version-check "ctranslate2[cuda]" \
    || echo "[setup:aina] AVÍS: sense CUDA; faster-whisper caurà a CPU (més lent)"
fi

# ── 2. Model català d'Aina (snapshot de Hugging Face) ──────────────────────
# Hugging Face guarda el snapshot amb enllaços simbòlics als blobs: -f no els
# veu, -e sí. I no movem res: el snapshot JA és a MODEL_DIR (el move anterior
# el va deixar allà abans de fallar la comprovació).
if [[ -e "$MODEL_DIR/model.bin" ]]; then
  echo "[setup:aina] model ja present: $MODEL_DIR"
elif [[ -e "$CACHE_DIR/model.bin" ]]; then
  echo "[setup:aina] reaprofite el model de la memòria cau: $CACHE_DIR"
  mkdir -p "$(dirname "$MODEL_DIR")"
  mv "$CACHE_DIR" "$MODEL_DIR"
else
  echo "[setup:aina] descarregant el model (~3 GB, pot tardar uns minuts)"
  mkdir -p "$(dirname "$MODEL_DIR")"
  AINA_CACHE="$CACHE_DIR" "$VENV_DIR/bin/python" - "$MODEL_ID" "$MODEL_DIR" <<'EOF'
import os
import shutil
import sys
from huggingface_hub import snapshot_download

model_id, dest = sys.argv[1], sys.argv[2]
tmp = os.environ.get("AINA_CACHE", dest + ".tmp")
snapshot = snapshot_download(repo_id=model_id)
os.makedirs(os.path.dirname(dest), exist_ok=True)
if os.path.isdir(dest):
    shutil.rmtree(dest)
shutil.move(snapshot, tmp)
os.rename(tmp, dest)
print(f"[setup:aina] model a {dest}")
EOF
fi

if [[ ! -e "$MODEL_DIR/model.bin" ]]; then
  echo "[setup:aina] AVÍS: no trobe model.bin a $MODEL_DIR." >&2
  exit 1
fi

"$VENV_DIR/bin/python" -c "import faster_whisper; print('[setup:aina] faster-whisper a punt')"
echo "[setup:aina] llest. El sidecar el carrega en la primera transcripció."
