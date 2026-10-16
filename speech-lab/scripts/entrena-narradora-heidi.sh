#!/usr/bin/env bash
# Entrena sense intervenció les veus de la narradora (La contacontes Yolanda) i
# de Heidi: espera que acabe segmenta-veu.py, després RVC de cada una i, al
# final, un fine-tune de Matxa amb les dues (narradora en el locutor 7, gina;
# Heidi en el 3, elia). Els textos de Whisper no es revisen a mà.
#
#   setsid nohup systemd-inhibit --what=sleep:idle bash scripts/entrena-narradora-heidi.sh &
#
# Progrés en voz-dataset/pipeline-veus.log; cada pas té el seu log (tts/rvc/entrena-*.log,
# tts/veus-v1.log). Si un pas falla, s'apunta i se segueix amb el següent.
set -uo pipefail

LAB=$(cd "$(dirname "$0")/.." && pwd)
cd "$LAB"
LOG=$LAB/voz-dataset/pipeline-veus.log
log() { echo "[$(date '+%d/%m %H:%M')] $*" | tee -a "$LOG"; }

log "inici: espere que acabe la segmentació"
while pgrep -f "scripts/segmenta-veu.py" > /dev/null; do sleep 30; done

# Si la segmentació va fallar (p. ex. sense memòria de GPU), es torna a provar: les transcripcions estan en caché.
for nom in narradora heidi; do
  entrada=voz-dataset/personatges-$nom/$nom
  if [[ ! -s voz-dataset/clips-$nom/metadata.csv ]]; then
    log "falten els clips de $nom: torne a segmentar"
    .venv/bin/python scripts/segmenta-veu.py --entrada "$entrada" --eixida "voz-dataset/clips-$nom" \
      > "voz-dataset/segmenta-$nom.log" 2>&1 || log "segmentació de $nom ha fallat"
  fi
  log "$nom: $(wc -l < "voz-dataset/clips-$nom/metadata.csv" 2>/dev/null || echo 0) clips"
done

for nom in narradora heidi; do
  log "RVC $nom: comença (100 èpoques)"
  if CADA=25 scripts/entrena-rvc.sh "$nom" 100 > "tts/rvc/entrena-$nom.log" 2>&1; then
    log "RVC $nom: fet"
  else
    log "RVC $nom: ha fallat (tts/rvc/entrena-$nom.log)"
  fi
done

log "Matxa: prepara els filelists"
if .venv-voz/bin/python scripts/prepara-matxa.py --eixida voz-dataset/matxa-veus \
     --font voz-dataset/clips-narradora:7 --font voz-dataset/clips-heidi:3 >> "$LOG" 2>&1; then
  log "Matxa: fine-tune veus-v1 comença (300 èpoques)"
  if .venv-voz/bin/python scripts/finetune-matxa.py --nom veus-v1 --dades voz-dataset/matxa-veus \
       --spk 7 --spk 3 > tts/veus-v1.log 2>&1; then
    log "Matxa: fet"
  else
    log "Matxa: ha fallat (tts/veus-v1.log)"
  fi
  # El laboratori nomena els locutors del fine-tune amb este fitxer.
  [[ -d tts/runs/veus-v1 ]] && echo '{ "veus": { "7": "Narradora", "3": "Heidi" }, "recomanat": "last.ckpt" }' \
    > tts/runs/veus-v1/veus.json
else
  log "Matxa: prepara-matxa ha fallat"
fi
log "final"
