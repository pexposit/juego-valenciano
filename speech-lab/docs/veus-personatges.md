# Voces de personajes: guía completa

Cómo se fabrican, dónde están y cómo se recuperan las voces valencianas de
personajes del laboratorio (Doraemon, Nobita, narrador, narradora, Heidi...).
Cómo se usan desde la página: [README](../README.md#generación-de-audio). Aquí, el
procedimiento paso a paso, el mapa de carpetas y los resultados medidos.

## Idea general

Dos maneras de conseguir la voz de un personaje, las dos sobre Matxa
(TTS valenciano de Projecte AINA, modelo multiaccent):

| Método | Qué aprende | Cuándo sirve |
|---|---|---|
| **Matxa + RVC** (recomendado) | Matxa base habla con una voz limpia (gina, spk 7, o lluc, spk 6) y RVC (Applio) le cambia solo el timbre | Con poco material (5–30 min). Se entiende mejor en todas las pruebas |
| Fine-tune de Matxa | Matxa aprende la voz entera | Solo con mucho material limpio (el narrador del audiolibro, ~400 clips). Con voces de dibujos sale robótico |

**Qué es RVC.** *Retrieval-based Voice Conversion*: un modelo que no lee texto,
sino que convierte un audio hablado a la voz de otra persona. Extrae lo que se
dice sin el timbre (ContentVec) y el tono (RMVPE), y un generador HiFi-GAN lo
vuelve a decir con el timbre aprendido. El `.index` guarda rasgos de los clips
reales; con «Índex» > 0 el resultado se acerca más a ellos, pero a veces se
entiende peor (narrador y narradora usan 0). En Applio, entrenar un personaje es
`scripts/entrena-rvc.sh`; usarlo, `scripts/parla.sh` o el laboratorio.

Por eso RVC tiene **prioridad**: el catálogo del laboratorio pone los
personajes RVC los primeros y la página elige uno por defecto. Los fine-tunes de
Matxa quedan para comparar.

Regla práctica: voz femenina o infantil → base gina (7); voz masculina o
grave → base lluc (6). El tono se ajusta con `to` (semitonos):
`12·log2(f0 del personaje / f0 de la voz base)`.

## Canalización paso a paso

```
audios/<fuente>/*.wav                    capítulos originales (YouTube), no versionados
   │  Demucs (htdemucs)
   ▼
voz-dataset/separat*/htdemucs/<cap>/vocals.wav     voz sin música
   │  scripts/separa-personatges.py      agrupa por hablante (ECAPA)
   ▼
voz-dataset/personatges*/parlant_NN/     un grupo por voz; resum.tsv dice minutos
   │  scripts/extrau-personatge.py       (opcional) quita los tramos dudosos
   ▼
voz-dataset/personatges*/<nom>/          voz limpia de un personaje
   │  scripts/segmenta-veu.py            clips de 2–12 s + transcripción Whisper
   ▼
voz-dataset/clips-<nom>/                 wavs/ + metadata.csv
   │                                  ╲
   │  scripts/entrena-rvc.sh <nom>     ╲ scripts/prepara-matxa.py + finetune-matxa.py
   ▼                                    ▼
tts/rvc/Applio/logs/<nom>/           tts/runs/<run>/checkpoints/
   │
   ▼  scripts/rvc-personatges.json (base, to, index)
laboratorio: «Generació d'àudio» → rvc:<nom>      ·  terminal: scripts/parla.sh <nom> "text"
```

### Ejemplo: personaje nuevo a partir de un grupo de hablante

```bash
cd speech-lab
# 1. Clips transcritos (usa la GPU; ~3 min por capítulo)
.venv/bin/python scripts/segmenta-veu.py \
  --entrada voz-dataset/personatges-heidi/parlant_04 --eixida voz-dataset/clips-parlant04
# 2. Alta en scripts/rvc-personatges.json, p. ej. "parlant04": { "base": 6, "to": 0 }
# 3. Entrenamiento RVC sin que el portátil se suspenda (pierde CUDA al hibernar)
systemd-inhibit --what=sleep:idle scripts/entrena-rvc.sh parlant04 200
# 4. Prueba
scripts/parla.sh parlant04 "Bon dia, com estàs?"
```

El laboratorio lee el catálogo del disco: el modelo aparece en
«Generació d'àudio» sin reiniciar.

## Modelos actuales

| Modelo | Fuente | Base | Tono | Estado |
|---|---|---|---|---|
| `rvc:doraemon` | Doraemon (6 capítulos, ~8 min) | gina | +5 | 300 épocas |
| `rvc:nobita` | Doraemon (~5 min) | gina | +6 | 300 épocas; se entiende algo peor |
| `rvc:narrador` | audiolibro (`voz-dataset/clips`) | lluc | −6 | 100 épocas; para el narrador va mejor el fine-tune `narrador-v1` |
| `rvc:narradora` | «La contacontes Yolanda» (54 min) | gina | +3 | 100 épocas, índice 0 |
| `rvc:heidi` | Heidi ep. 1–15 (31 min) | gina | +9 | 100 épocas |
| `rvc:parlant04` | Heidi, grupo 04 (~20 min, voz grave, f0 ≈ 121 Hz; parece el narrador de la serie) | lluc | por medir | en preparación (2026-10-16) |
| `matxa:narrador-v1:6` | audiolibro | — | — | fine-tune, recomendado `last.ckpt` |
| `matxa:doraemon-v1:7/3` | Doraemon / Nobita | — | — | fine-tune, robótico (descartado) |
| `matxa:veus-v1:7/3` | narradora / Heidi | — | — | fine-tune, recomendado `epoch=0199.ckpt` |

## Mapa de carpetas

| Ruta | Qué es | ¿Git? | ¿Se puede regenerar? |
|---|---|---|---|
| `scripts/` | toda la canalización | sí | — |
| `scripts/rvc-personatges.json` | base, tono, índice y clips de cada RVC | sí | — |
| `scripts/veus.json` | voces derivadas de gina por DSP (experimento) | sí | — |
| `tts/models/` | Matxa multiaccent y vocoder (Aina) | sí (LFS) | `setup-matxa.sh` |
| `tts/Matcha-TTS-dev-cat/`, `tts/espeak-ng-src/` | clones de código | no | `setup-matxa.sh` |
| `tts/rvc/Applio/` | Applio y sus modelos preentrenados | no | `setup-rvc.sh` |
| `tts/rvc/Applio/logs/<nom>/<nom>_<N>e_*.pth` + `.index` | **modelo RVC entrenado** | no | solo reentrenando (horas) |
| `tts/rvc/Applio/logs/<nom>/G_*.pth`, `D_*.pth` | estado del entrenamiento (1,2 GB); borrado en los modelos terminados | no | solo hacen falta para `REPRENDRE=1` |
| `tts/rvc/dades/<nom>/` | copia de los clips para Applio | no | la rehace `entrena-rvc.sh` |
| `tts/rvc/eixida/` | frases generadas con `parla.sh` | no | sí |
| `tts/rvc/export/doraemon-rvc.zip` | paquete de Doraemon para compartir | no | — |
| `tts/runs/<run>/checkpoints/` | **fine-tunes de Matxa** (250 MB cada uno; quedan el recomendado y `last.ckpt`) | no | solo reentrenando |
| `audios/` | vídeos/audio original descargado | no | volver a descargar |
| `voz-dataset/separat*/` | salida de Demucs (`vocals.wav`; `no_vocals.wav` borrado) | no | Demucs (lento) |
| `voz-dataset/personatges*/` | voz agrupada por hablante | no | `separa-personatges.py` |
| `voz-dataset/clips*/` | **clips transcritos** (entrada de todo entrenamiento) | no | `segmenta-veu.py` (lento) |
| `voz-dataset/logs/`, `tts/logs/`, `tts/rvc/logs/` | logs de cada paso (segmentación, Demucs, entrenamientos) | solo los de `tts/logs/` del narrador y espeak | — |
| `.venv`, `.venv-voz`, `.venv-rvc` | entornos de Python (16 GB) | no | scripts `setup-*.sh` |

Los datos (`audios/`, `voz-dataset/`, modelos entrenados) no van a GitHub:
pesan decenas de GB y contienen voces con derechos (doblaje, YouTube).

## Compartir los modelos con el equipo

El repositorio del juego en GitHub es **público** y las voces salen de doblajes y
vídeos con derechos, así que los modelos no pueden ir a git, ni a LFS ni a
Releases. Están en el repositorio **privado** de Hugging Face
[`parlaval/speech-lab-veus`](https://huggingface.co/parlaval/speech-lab-veus),
con las mismas rutas que en `speech-lab/`. Qué se comparte lo dice
[`scripts/models.json`](../scripts/models.json): el último `.pth`, el `.index` y la
configuración de cada RVC, y el checkpoint recomendado de cada fine-tune.

**Para un compañero (una vez):**

1. Aceptar la invitación a la organización `parlaval` de Hugging Face. Un
   administrador la envía al correo desde *Settings* → *Members* → *Invite
   members*, con rol **read** (o **write** si va a subir modelos). Si no tiene
   cuenta, la crea con ese mismo correo.
2. Iniciar sesión: `speech-lab/.venv/bin/hf auth login` (el `.venv` lo crea
   `npm run setup:speech`). Si inicia sesión desde el navegador, elegir «Grant
   … access to selected organizations» y marcar `parlaval`. Si usa un token de
   <https://huggingface.co/settings/tokens>, que sea de **lectura** o
   *fine-grained* con acceso a `parlaval`. Una variable `HF_TOKEN` en el entorno
   tiene prioridad sobre la sesión: si es de otra cuenta, hay que quitarla.
3. Instalar los entornos de síntesis: `setup-matxa.sh` y `setup-rvc.sh`.
4. Descargar: `npm run models:speech`. Comprueba las sumas SHA-256 y, si se
   vuelve a ejecutar, solo baja lo que haya cambiado.

**Para publicar un modelo nuevo o reentrenado** (necesita un token con permiso
de escritura):

1. Poner el nombre del `.pth` final (o del checkpoint de Matxa) en
   `scripts/models.json` y, si es un personaje nuevo, su entrada en
   `rvc-personatges.json`.
2. `cd speech-lab && .venv/bin/python scripts/models-hf.py puja`. Antes de subir
   comprueba que el repositorio es privado. Solo se suben los ficheros nuevos.
3. Hacer commit de los dos JSON y push, para que el resto sepa que hay un modelo
   nuevo.

## Copia de seguridad

Copia del 2026-10-16 en el USB «PHILIPS UFD»,
`speech-lab-backup-2026-10-16/` (2,8 GB):

| Archivo | Contenido |
|---|---|
| `rvc-models.tar` | último `.pth`, `.index`, `config.json` y `model_info.json` de doraemon, nobita, narrador, narradora y heidi + `rvc-personatges.json` y `veus.json` |
| `matxa-recomanats.tar` | checkpoint recomendado de cada fine-tune (`doraemon-v1` 0399, `narrador-v1` last, `veus-v1` 0199) y sus `veus.json` |
| `clips.tar` | `voz-dataset/clips*` (wavs + metadata.csv) de los cinco personajes |

Restaurar (desde `speech-lab/`; los tar guardan rutas relativas):

```bash
B="/media/revitalia/PHILIPS UFD/speech-lab-backup-2026-10-16"
tar -xf "$B/rvc-models.tar"; tar -xf "$B/matxa-recomanats.tar"; tar -xf "$B/clips.tar"
```

Con eso y los entornos (`setup-matxa.sh`, `setup-rvc.sh`) el laboratorio vuelve
a tener todas las voces. El código está en GitHub, rama `experimentos-voz`.

## Espacio en disco

El disco del portátil (699 GB) está casi lleno y ya se llenó una vez durante un
fine-tune. El 2026-10-16 se liberaron 15 GB (de 13 a 28 GB libres) borrando:

- `G_*.pth` y `D_*.pth` de los RVC terminados (6,2 GB): ya no se pueden
  reanudar con `REPRENDRE=1`, solo reentrenar.
- Los checkpoints de `tts/runs/` que no eran el recomendado ni `last.ckpt`
  (6,5 GB).
- `no_vocals.wav` de Demucs (2,4 GB), `tts/rvc/dades/` y la carpeta repetida
  `tts/rvc/export/doraemon-rvc/` (queda el `.zip`).

Después de cada entrenamiento nuevo se puede repetir: borrar sus `G_`/`D_` y
sus checkpoints intermedios cuando ya se haya elegido el bueno.

## Problemas conocidos

- **CUDA desaparece tras suspender** el portátil (driver 535): reiniciar.
  Entrenar siempre con `systemd-inhibit`. `entrena-rvc.sh` se para si no hay
  CUDA en lugar de entrenar en CPU.
- **6 GB de GPU**: no lanzar a la vez Demucs/Whisper y un entrenamiento (OOM).
  `entrena-rvc.sh` pone `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True`.
- **Applio**: `--save-every-weights` invierte su efecto si se pasa; `core.py`
  sale con código 0 aunque falle, por eso el script comprueba cada paso en disco.
- **Whisper normaliza el valenciano** («seua» → «seva»): `segmenta-veu.py` usa
  un prompt AVL y marca las formas sospechosas en `revisio.tsv`. Para RVC el
  texto da igual (solo usa el audio); para el fine-tune de Matxa sí importa.

## Resultados medidos

### Narradora y Heidi entrenadas (`scripts/entrena-narradora-heidi.sh`)

Dos voces femeninas valencianas entrenadas con material real, con la misma
canalización que el narrador y Doraemon (Demucs → `separa-personatges.py` →
`extrau-personatge.py` → `segmenta-veu.py`), sin revisar a mano los textos de
Whisper. El script encadena RVC y fine-tune sin intervención.

| Voz | Fuente (`audios/`) | Voz útil | Clips |
|---|---|---|---|
| Narradora | `narradora/`: 16 cuentos de «La contacontes Yolanda» (YouTube) | 54 min | 854 |
| Heidi | `heidi/`: episodios 1–15 de Heidi en valenciano (YouTube) | 31 min | 416 |

La narradora se eligió entre 17 candidatas midiendo f0 (mujer), música de fondo
(Demucs) y el detector de variant (solo dos salían valencianas, y esta era la
única con material suficiente). Heidi es el grupo 01 de
`voz-dataset/personatges-heidi/` (confirmado de oído).

Modelos: `rvc:narradora` y `rvc:heidi` (gina + RVC, 100 épocas, tono +3 y +9
semitonos en `rvc-personatges.json`) y `matxa:veus-v1:7` / `matxa:veus-v1:3`
(fine-tune de Matxa con las dos voces, narradora en el locutor 7 y Heidi en el 3).
Medido con 6 frases (WER de Whisper Aina; semejanza ECAPA con 40 clips reales;
gina sin convertir da 0,23 / 0,13):

| Configuración | WER | Semejanza | p(valencià) |
|---|---|---|---|
| **Narradora RVC 100e, índice 0** (por defecto) | **8,7 %** | 0,73 | 72 % |
| Narradora RVC 100e, índice 0,6 | 14,1 % | 0,73 | — |
| Narradora fine-tune epoch 199 (recomendado) | 14,1 % | 0,76 | 100 % |
| **Heidi RVC 100e, índice 0,6** (por defecto) | **16,3 %** | 0,78 | 99 % |
| Heidi RVC 50e, índice 0 | 12,0 % | 0,76 | — |
| Heidi fine-tune epoch 199 (recomendado) | 30,4 % | 0,79 | 91 % |

Como con los personajes de Doraemon, RVC se entiende mejor; el fine-tune de la
narradora (54 min) queda cerca, el de Heidi (31 min, voz de dibujos) no. Con 6
frases, 2 puntos de WER son una palabra: hay que decidir de oído.

### Veus derivades: narradora y nena (`scripts/veus.json`)

Dos voces femeninas **valencianas** sin entrenar nada: parten de gina (spk 7,
la locutora valenciana de LaFrescat) y, como todo Matxa local, se fonetizan
con espeak `ca-va` (`catalan_valencia_cleaners`), no con el catalán central.
Cada entrada fija locutor, temperatura y duración de Matxa y, si hace falta,
tono (semitonos) y formantes, que el sidecar de Matxa desplaza después de
sintetizar con `stftpitchshift` (en `.venv-voz`, lo instala `setup-matxa.sh`):

| Voz | Matxa | Desplazamiento | Resultado medido |
|---|---|---|---|
| `veu:narradora` | gina, temperatura 0,5, duración 1,12 (más pausada y estable) | ninguno | f0 ≈ 218 Hz, timbre de gina; p(valencià) = 80 % |
| `veu:nena` | gina, temperatura 0,7, duración 0,92 (más viva) | +5 st, formantes ×1,2 | f0 ≈ 300 Hz, envolvente ×1,18; p(valencià) = 70 % |

Por qué así: el fine-tune `narrador-v1` con el locutor de gina sale con voz de
hombre (f0 ≈ 85 Hz: el fine-tune solo aprendió al narrador) y no hay clips de
una narradora ni de una niña para entrenar un RVC. Subir solo el tono suena a
gina acelerada; una niña tiene además el tracto vocal más corto, de ahí los
formantes. Whisper (Aina) transcribe las dos voces sin errores en las frases
de prueba; con +4 st y formantes ×1,15 confundía «mare» con «vale». El
p(valencià) es del detector de variant (`npm run variant`) sobre ~11 s de
texto conocido. Con clips reales de una narradora o una niña valencianas se
puede entrenar un RVC (`scripts/entrena-rvc.sh`) y añadirlo a
`rvc-personatges.json` con `base: 7`.
