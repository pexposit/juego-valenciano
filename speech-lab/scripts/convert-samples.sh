#!/usr/bin/env bash
# Converteix els WAV del repositori a 16 kHz mono PCM16, el format que espera Vosk.
# Els fitxers originals són 22050 Hz pcm_s24le, així que cal resamplar i baixar a 16 bits.
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "$LAB_DIR/.." && pwd)"
OUT_DIR="$LAB_DIR/bench/samples"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "[samples] ffmpeg no està instal·lat; salte la conversió d'àudios de prova"
  exit 0
fi

mkdir -p "$OUT_DIR"

convert() {
  local src="$1" dst="$OUT_DIR/$2"
  if [[ ! -f "$src" ]]; then
    echo "[samples] no trobe $src; salte"
    return 0
  fi
  ffmpeg -v error -y -i "$src" -ar 16000 -ac 1 -acodec pcm_s16le "$dst"
  echo "[samples] $dst"
}

convert "$REPO_DIR/frontend/public/audio/salutacio-gina.wav" "salutacio-gina-16k.wav"
convert "$REPO_DIR/frontend/public/audio/salutacio-lluc.wav" "salutacio-lluc-16k.wav"
convert "$REPO_DIR/audio-bon-dia.wav" "bon-dia-16k.wav"
