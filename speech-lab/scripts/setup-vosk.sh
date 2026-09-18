#!/usr/bin/env bash
# Prepara el laboratori de veu: entorn virtual de Python amb Vosk i el model català.
# És idempotent: si ja està tot fet no torna a descarregar res.
#
# Ús: npm run setup:speech  (des de l'arrel del repositori)
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="${VOSK_VENV_DIR:-$LAB_DIR/.venv}"
MODEL_NAME="vosk-model-small-ca-0.4"
MODEL_DIR="${VOSK_MODEL_PATH:-$LAB_DIR/models/$MODEL_NAME}"
MODEL_URL="https://alphacephei.com/vosk/models/$MODEL_NAME.zip"
# Memòria cau: si el model ja s'ha descarregat a /tmp s'aprofita i no es torna a baixar.
CACHE_DIR="/tmp/$MODEL_NAME"
CACHE_ZIP="/tmp/$MODEL_NAME.zip"

echo "[setup] laboratori: $LAB_DIR"

# ── 1. Entorn virtual amb Vosk ─────────────────────────────────────────────
if [[ -x "$VENV_DIR/bin/python" ]]; then
  echo "[setup] entorn virtual ja existent: $VENV_DIR"
else
  echo "[setup] creant l'entorn virtual a $VENV_DIR"
  python3 -m venv "$VENV_DIR"
fi

# vosk porta la llibreria nativa en el wheel (no compila res); websockets és el
# servidor que parla amb el proveïdor de TypeScript.
echo "[setup] instal·lant vosk i websockets"
"$VENV_DIR/bin/pip" install -q --disable-pip-version-check --upgrade pip
"$VENV_DIR/bin/pip" install -q --disable-pip-version-check vosk websockets

# ── 2. Model català (l'únic que publica Vosk per al català) ────────────────
if [[ -d "$MODEL_DIR" ]]; then
  echo "[setup] model ja present: $MODEL_DIR"
elif [[ -d "$CACHE_DIR" ]]; then
  echo "[setup] reaprofite el model de la memòria cau: $CACHE_DIR"
  mkdir -p "$(dirname "$MODEL_DIR")"
  mv "$CACHE_DIR" "$MODEL_DIR"
else
  echo "[setup] descarregant el model català (~43 MB): $MODEL_URL"
  mkdir -p "$(dirname "$MODEL_DIR")"
  curl -fL --retry 3 -o "$CACHE_ZIP" "$MODEL_URL"
  unzip -q -o "$CACHE_ZIP" -d "$(dirname "$MODEL_DIR")"
  rm -f "$CACHE_ZIP"
fi

if [[ ! -d "$MODEL_DIR" ]]; then
  echo "[setup] AVÍS: no trobe el model a $MODEL_DIR." >&2
  echo "        Revisa VOSK_MODEL_PATH o descomprimeix el zip manualment." >&2
  exit 1
fi

# ── 3. Àudios de prova a 16 kHz (opcional: només si hi ha ffmpeg) ──────────
bash "$LAB_DIR/scripts/convert-samples.sh"

"$VENV_DIR/bin/python" -c "import vosk; print('[setup] vosk a punt:', vosk.__file__)"
echo "[setup] llest. Arranca el laboratori amb: npm run dev:speech"
