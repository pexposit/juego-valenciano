#!/usr/bin/env bash
# Prepara la clonació de veu amb Matxa (Matcha-TTS de BSC) en speech-lab/tts/:
# entorn .venv-voz (torch CUDA + Demucs + Matcha), espeak-ng de projecte-aina
# (veu valenciana «ca-va»), codi de la branca dev-cat i models de Hugging Face.
# És idempotent: el que ja està fet no es torna a fer.
#
# Llicència: matxa-tts-cat-multiaccent és GPL-3.0 i les veus de LaFrescat són
# només per a ús no comercial i de recerca (ús de laboratori).
#
# Ús: bash speech-lab/scripts/setup-matxa.sh  (des de l'arrel del repositori)
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="$LAB_DIR/.venv-voz"
TTS="$LAB_DIR/tts"
ESPEAK="$TTS/espeak-ng"
MATCHA="$TTS/Matcha-TTS-dev-cat"
mkdir -p "$TTS"

# ── 1. Entorn Python (separat del .venv de Vosk/whisper) ───────────────────
if [[ ! -x "$VENV/bin/python" ]]; then
  echo "[setup:matxa] creant $VENV"
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install -q --upgrade pip
fi
if ! "$VENV/bin/python" -c "import torch" 2>/dev/null; then
  echo "[setup:matxa] instal·lant torch (CUDA 12.1) i Demucs"
  "$VENV/bin/pip" install -q torch torchaudio --index-url https://download.pytorch.org/whl/cu121
  "$VENV/bin/pip" install -q demucs soundfile
fi

# ── 2. espeak-ng de projecte-aina (té ca-va, ca-ba i ca-nw) ───────────────
if [[ ! -x "$ESPEAK/bin/espeak-ng" ]]; then
  echo "[setup:matxa] compilant espeak-ng de projecte-aina en $ESPEAK"
  [[ -d "$TTS/espeak-ng-src" ]] || git clone -q --depth 1 https://github.com/projecte-aina/espeak-ng.git "$TTS/espeak-ng-src"
  (cd "$TTS/espeak-ng-src" && ./autogen.sh && ./configure --prefix="$ESPEAK" --with-speechplayer=no \
    --with-mbrola=no && make -j"$(nproc)" && make install) > "$TTS/espeak-build.log" 2>&1
fi

# ── 3. Matcha-TTS (branca dev-cat, la del model multiaccent) ──────────────
if [[ ! -d "$MATCHA" ]]; then
  echo "[setup:matxa] clonant Matcha-TTS dev-cat"
  git clone -q -b dev-cat https://github.com/langtech-bsc/Matcha-TTS.git "$MATCHA"
fi
# Dos pedaços locals perquè funcione amb Python 3.12 i matplotlib actual:
#  - piper_phonemize no té wheel per a 3.12 i només l'usen els cleaners anglesos;
#  - FigureCanvas.tostring_rgb ja no existix (l'usa per als mels de tensorboard).
sed -i 's/^import piper_phonemize$/try:\n    import piper_phonemize  # només per a english_cleaners_piper; sense wheel per a Python 3.12\nexcept ImportError:\n    piper_phonemize = None/' \
  "$MATCHA/matcha/text/cleaners.py"
"$VENV/bin/python" - "$MATCHA/matcha/utils/utils.py" <<'EOF'
import sys
from pathlib import Path
p = Path(sys.argv[1]); s = p.read_text()
vell = '''    data = np.fromstring(fig.canvas.tostring_rgb(), dtype=np.uint8, sep="")
    data = data.reshape(fig.canvas.get_width_height()[::-1] + (3,))
    return data'''
nou = '''    # matplotlib >= 3.10 ja no té tostring_rgb: es passa per buffer_rgba.
    data = np.asarray(fig.canvas.buffer_rgba())[..., :3].copy()
    return data'''
if vell in s:
    p.write_text(s.replace(vell, nou))
EOF
if ! "$VENV/bin/python" -c "import matcha" 2>/dev/null; then
  echo "[setup:matxa] instal·lant dependències de Matcha"
  # Les del requirements.txt menys notebooks, demos i piper_phonemize.
  "$VENV/bin/pip" install -q "lightning>=2.0.0" torchmetrics hydra-core==1.3.2 hydra-colorlog==1.2.0 \
    rootutils rich phonemizer tensorboard librosa Cython "numpy==1.*" einops inflect Unidecode scipy \
    matplotlib pandas conformer==0.3.2 diffusers==0.25.0 omegaconf huggingface-hub==0.25.2 pyyaml \
    encodec==0.1.1 gdown wget
  "$VENV/bin/pip" install -q -e "$MATCHA" --no-deps --no-build-isolation
fi

# ── 4. Models: Matxa multiaccent (checkpoint entrenable) i vocoder alVoCat ─
"$VENV/bin/python" - "$TTS/models" <<'EOF'
import sys
from huggingface_hub import hf_hub_download, snapshot_download
dest = sys.argv[1]
for f in ("checkpoint_epoch=629.ckpt", "config.yaml"):
    hf_hub_download("projecte-aina/matxa-tts-cat-multiaccent", f, local_dir=f"{dest}/matxa-tts-cat-multiaccent")
snapshot_download("projecte-aina/alvocat-vocos-22khz", local_dir=f"{dest}/alvocat-vocos-22khz")
EOF

echo "[setup:matxa] fet. Prova: $VENV/bin/python $LAB_DIR/scripts/sintetitza-matxa.py"
