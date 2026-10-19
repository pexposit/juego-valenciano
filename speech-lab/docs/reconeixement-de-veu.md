# Reconocimiento de voz: Vosk en streaming y Aina por lotes

Detalle técnico del reconocimiento de voz del laboratorio. Resumen y arranque en el [README](../README.md).

## Arquitectura

```
navegador (public/index.html + lab.js + AudioWorklet)
  │  PCM16 mono 16 kHz por WebSocket  (/ws/transcribe)
  ▼
servidor del laboratorio (src/index.ts, Express no: http + ws)
  │  interfaz StreamingStt  ← mismo patrón que backend/src/services/voice.ts
  ▼
provider Vosk (src/streaming/voskSidecar.ts)
  │  WebSocket interno 127.0.0.1:2700
  ▼
sidecar Python (sidecar/vosk_stream.py) → model català vosk-model-small-ca-0.4
```

Por qué un sidecar de Python y no los *bindings* de npm: el paquete `vosk` de
npm depende de `ffi-napi@4.0.3`, que no tiene binario precompilado para Node 22 y
falla al compilar (comprobado en esta máquina: `node-gyp` no encuentra las
cabeceras). El *wheel* de Python son 7 MB, no compila nada y carga el modelo en
~300 ms. El proveedor de TypeScript aísla ese detalle: cambiar de motor solo
afecta a `src/streaming/`.

### Protocolo

El mismo que `vosk-server`, para que sustituir el motor no obligue a tocar al
cliente:

```
cliente → laboratorio
  {"config": {"sample_rate": 16000, "phrase_list": ["bon dia"], "words": false}}
  <frames binarios PCM16 mono little-endian>
  {"eof": 1}          → resultado final y cierre del turno

laboratorio → cliente
  {"type": "ready", "provider": "vosk", "sampleRate": 16000}
  {"type": "partial", "text": "bon dia com", "atMs": 150, "latencyMs": 24}
  {"type": "final",   "text": "bon dia com et puc ajudar hui", "atMs": 299, "latencyMs": 23}
  {"type": "metrics", "partials": 8, "finals": 1, "firstPartialMs": 150, "finalMs": 299,
                      "audioMs": 2589, "computeMs": 171, "rtf": 0.066}
  {"type": "error", "message": "…"}   // mensajes en valenciano, como el resto del repo
```

El sidecar añade `compute_ms` a cada respuesta: es el tiempo **real de cómputo
del motor**. Sin ese dato, el cliente solo puede medir el tiempo de ida y vuelta,
que cuando se envía audio más rápido que el habla incluye toda la cola acumulada
y hace parecer el motor 10 veces más lento (ver «Errores corregidos»).

El estado se resume en una línea con el mismo estilo que el backend
(`[turn] stt=…ms agente=…ms`):

```
[speech] provider=vosk partials=8 finals=1 first_partial=150ms final=299ms audio=2.59s rtf=0.066
```

## Mediciones (esta máquina, Node 22, 16 kHz mono)

Audio de prueba: `salutacio-gina-16k.wav` (2,59 s, «Bon dia! Com et puc ajudar
hui?», convertido del WAV del repositorio a 16 kHz PCM16).

| Prueba | Primer parcial con texto | Cómputo por fragmento | Cómputo total | RTF | Texto |
|---|---|---|---|---|---|
| Vocabulario libre (`smoke`) | ~1,0 s de audio | 12–45 ms | 171 ms | **0,066** | `bon dia com et puc ajudar hui` |
| Vocabulario libre a tiempo real (`--pace`) | 1.053 ms | 15–45 ms | 189 ms | **0,073** | idéntico |
| Gramática restringida, 3 frases (`--phrases`) | 11 ms | 0–8 ms | 43 ms | **0,017** | idéntico |
| Voz masculina (`salutacio-lluc-16k.wav`) | 1.045 ms | 12–47 ms | 163 ms | **0,063** | idéntico |

Otras cifras: carga del modelo **~300 ms** (una sola vez por proceso), coste de
`AcceptWaveform` por fragmento de 256 ms **≤ 47 ms**, y RTF estable muy por
debajo de 1 (el motor va ~15× más rápido que el habla).

### Hallazgos que condicionan el diseño

1. **La gramática restringida es la palanca más potente** (`phrase_list` →
   `KaldiRecognizer(model, rate, json)`): el RTF baja de 0,066 a **0,017** (4×
   menos cómputo) y la transcripción sale exacta. Esto conecta directamente con
   los objetivos y el vocabulario de `backend/src/scenarios/*.ts`. Requisito:
   enviar las frases **normalizadas y sin puntuación**, porque el motor descarta
   en silencio las palabras que no están en la lista (aviso real observado:
   `Ignoring word missing in vocabulary: 'dia,'`).
2. **El primer parcial con texto aparece alrededor del primer segundo de audio**
   y no antes: es comportamiento propio de Vosk (mantiene contexto antes de
   emitir resultados). Lo que sí controlamos es el cómputo por fragmento
   (12–45 ms), que es la latencia real añadida.
3. **El fin de turno lo marca el propio motor**: cuando Vosk detecta una pausa
   devuelve `{"text": …}` (endpointing). No hace falta un VAD externo para el
   caso limpio. Por eso el cliente **envía todo el audio, silencio incluido**:
   si se filtrase el silencio, el motor nunca detectaría el corte.
4. Los resultados sin texto (silencio inicial) se descartan en el proveedor: si
   se reenviaran, cortarían el turno antes de que el usuario empiece a hablar.

### Errores encontrados y corregidos durante la validación

- **No llegaba el resultado final** (`finals=0`, texto vacío). El sidecar
  comparaba la cadena literal `'{"eof": 1}'` con espacios, pero el cliente envía
  `{"eof":1}`; caía en un `assert` y moría con `AssertionError` de mensaje vacío
  (de ahí el `sessió interrompuda (…):` sin texto en el log). Ahora se parsea el
  JSON en lugar de comparar cadenas.
- **RTF falso de 0,8** que parecía indicar que el motor iba a velocidad real. Era
  el tiempo de ida y vuelta con toda la cola acumulada. Corregido midiendo el
  cómputo en el origen (`compute_ms`) y usándolo cuando está disponible.
- `tsx watch` sin terminal interactiva (stdin cerrado) muere con `EBADF` y puede
  dejar procesos huérfanos. En entornos no interactivos:
  `npm run build -w speech-lab && node dist/index.js`. El laboratorio mata el
  sidecar con `SIGINT`/`SIGTERM` para no dejar Python suelto.

El laboratorio ya no es «solo Vosk»: el servidor expone tres familias detrás
de tres registros (`src/streaming/`, `src/batch/`, `src/tts/`), cada una con
su sidecar y su protocolo testeado sin arrancar Python.

| Familia | Proveedor | Motor | Uso |
|---|---|---|---|
| Streaming STT | `vosk` | Vosk small-ca + sidecar WS (`sidecar/vosk_stream.py`) | micrófono en vivo, parciales |
| Batch STT | `aina` | faster-whisper `large-v3-ca-3catparla` + sidecar NDJSON (`sidecar/whisper_batch.py`) | transcripción automática, bench WER |
| Batch STT | `vosk-batch` | mismo Vosk small-ca, por WebSocket interno (`src/batch/voskBatch.ts`) | comparador A/B de la página |
| TTS | `matxa` | matxa-tts remoto (UJI, el mismo que el juego) | síntesis `POST /api/tts` |

Endpoints nuevos (además de `/ws/transcribe` y `/health`, que ahora lista
también `batchProvider`, `batchModel` y `ttsProvider`):

- `POST /api/transcribe` — cuerpo: WAV PCM16 mono 16 kHz (máx. 25 MB).
  Responde `{provider, model, text, segments[], words[], computeMs,
  audioSecs, wallMs}` y, con `?reference=…`, añade `{wer}` calculado en el
  servidor. Parámetros: `?provider=aina`, `?language=ca`, `?words=1`.
- `POST /api/tts` — cuerpo JSON `{text, voice?}` (máx. 2000 chars).
  Responde el WAV con cabeceras `x-tts-voice` y `x-tts-first-byte-ms`.
  Con `model` (id de `/api/tts/models`) genera con ese modelo; admite también
  `checkpoint`, `temperature`, `speed` (length_scale), `pitch`, `indexRate` y
  `formant` (solo veus derivades, 0,7–1,5), y
  responde con `x-tts-model`, `x-tts-checkpoint`, `x-tts-total-ms`,
  `x-tts-matxa-ms`, `x-tts-rvc-ms`, `x-tts-audio-secs` y `x-tts-cached`.
- `GET /api/tts/models` — catálogo leído del disco en cada petición (un
  entrenamiento nuevo aparece sin reiniciar): `remot:<voz>` (matxa-tts UJI),
  `matxa:base:<spk>` (Matxa multiaccent local), `matxa:<run>:<spk>` (fine-tunes
  de `tts/runs/`, con `veus.json` opcional para nombrar locutores y elegir el
  checkpoint recomendado), `veu:<nombre>` (veus derivades de
  `scripts/veus.json`, ver [veus-personatges.md](veus-personatges.md)) y `rvc:<nombre>` (Matxa base + RVC de
  `tts/rvc/Applio/logs/`; voz de partida —`base`, gina por defecto, lluc para
  voces de hombre—, tono, peso del `.index` y carpeta de clips en
  `scripts/rvc-personatges.json`).

### Página: transcripción de fitxers (fase B)

La página (`http://localhost:3100`, sección «Transcripció de fitxers») usa
esos endpoints sin nada nuevo en el servidor:

- **Transcriure**: eliges un audio (mp3, ogg, webm, wav…), el navegador lo
  convierte a 16 kHz mono con `OfflineAudioContext`, lo envía a
  `POST /api/transcribe?provider=…&words=1` y muestra el texto + segmentos
  clicables (▶ salta el reproductor a cada segmento) + métricas (cómput, RTF).
- **Comparar Aina vs Vosk**: el mismo WAV por los dos motores en paralelo,
  tabla lado a lado con texto y cómputo. Equivale a `npm run wer:speech`
  pero con tu propio audio y sin terminal.
- Verificado sin navegador con el smoke extendido:
  `npm run smoke -- --api-transcribe [--provider aina|vosk-batch]` y
  `npm run smoke -- --api-tts [--voice gina]`.

### Bench WER (fase 4, cerrada con voz sintética)

Cada `bench/samples/*.wav` con su `.txt` de referencia se pasa por cada
motor (`npm run wer:speech`). Resultado con las muestras TTS actuales
(23/9/2026; CPU, faster-whisper int8; Vosk RTF 0,061):

| Muestra | Vosk small-ca | Aina large-v3-ca |
|---|---|---|
| `salutacio-gina-16k.wav` («…ajudar hui?») | **WER 0%** (exacta, 18 ms) | WER 28,6% (`et→em`, `hui→avui`, 5,8 s) |
| `salutacio-lluc-16k.wav` (igual) | **WER 0%** (exacta, 20 ms) | WER 14,3% (`hui→avui`, 5,9 s) |
| `bon-dia-16k.wav` («Bon dia») | WER 250% (igual que Aina: alucina la salutación) | WER 250% (al·lucina la salutació sencera, 6,0 s) |

Lectura honesta: con voz sintética limpia **Vosk small sigue ganando en
catalán oriental estricto**, y el large-v3-ca tiende al oriental (`avui`,
`em`). El bench queda montado para repetirlo con **voz humana valenciana**,
que es la medida que de verdad decide el motor (ver «Estado y siguientes pasos» en el [README](../README.md#estado-y-siguientes-pasos)).

Notas de la puesta a punto:

- `scripts/setup-aina.sh` instala `faster-whisper` en el mismo `.venv` y
  descarga el snapshot de Hugging Face a `models/`.
- **GPU (opcional, pero muy recomendada):** ctranslate2 de PyPI **no trae las
  librerías CUDA ni declara extra `cuda`** (comprobado en 4.8.2: no hay
  `Provides-Extra`), así que el script instala `nvidia-cublas-cu12` +
  `nvidia-cudnn-cu12` cuando ve `nvidia-smi`. El sidecar añade esos directorios
  al `LD_LIBRARY_PATH` y **se re-ejecuta una vez** (el cargador dinámico solo
  lee esa variable al arrancar). Sin ese paso CTranslate2 encuentra el driver,
  reserva 3 GB de VRAM y falla en la primera transcripción con «Library
  libcublas.so.12 is not found or cannot be loaded» — justo el error que veía
  la página al cargar un ejemplo.
- El sidecar prueba GPU `float16` → GPU `int8_float16` → CPU `int8` y **cae al
  siguiente intento solo** si uno falla (VRAM escasa, GPU ocupada por otro
  programa, permisos…). Si la GPU se rompe a mitad de una transcripción,
  recarga el modelo en CPU y reintenta la petición. `AINA_DEVICE=cpu` fuerza
  CPU y `AINA_COMPUTE_TYPE=…` fija el tipo en GPU.
- Medido en esta máquina (RTX 3060 Laptop, large-v3-ca): 2,7 s de carga y
  **0,7 s de cómputo** para 2,1 s de audio en GPU `float16`, frente a 7,4 s de
  carga y 5,9 s de cómputo en CPU `int8` (≈8×).
- El sidecar de lots habla NDJSON por stdio (sin puerto): una línea por
  petición, una por respuesta, en orden; el servidor encúa las peticiones.
- Sin secretos nuevos: el TTS `matxa` usa las mismas `MATXA_TTS_*` que el
  backend (ver `speech-lab/.env.example`).

## La página de pruebas

`http://localhost:3100` (JS vanilla y `AudioWorklet`, sin build ni Tailwind para
mantener el módulo ligero):

1. **Escoltar** — pide el micrófono, abre un `AudioContext` a 16 kHz y envía
   PCM16 en fragmentos de 128 ms. `echoCancellation`, `noiseSuppression` y
   `autoGainControl` van **desactivados**: los filtros de voz del navegador
   están pensados para llamadas y degradan el reconocimiento.
2. **Fi del torn** — envía `{"eof": 1}`, recibe el resultado final y las
   métricas, y el servidor cierra la sesión. La página se reconecta sola para el
   siguiente turno.
3. **Vocabulario restringido** — una frase por línea; se aplica al pulsar
   «Escoltar». Es el campo que usa la gramática restringida del punto 1 de los
   hallazgos.

Si el navegador no respeta los 16 kHz del `AudioContext`, el hilo principal
resamplea por interpolación lineal y lo avisa en la interfaz.

## Limitaciones conocidas

- **Solo existe el modelo catalán «small»**: `vosk-model-small-ca-0.4` (42 MB,
  Apache-2.0) es el único publicado para catalán; no hay versión grande. La
  precisión con voz sintética limpia es buena (transcripción exacta), pero con
  voz humana y acento valenciano hay que medir WER antes de dar nada por bueno:
  en una prueba intermedia apareció `una` donde luego llegó `hui`.
- **Páginas de pruebas sin validar con micrófono real**: este entorno no tiene
  navegador, así que `public/index.html` está probada por la tubería equivalente
  (`smoke`) y por el servidor de estáticos, pero **la captura de micrófono queda
  como prueba manual** (`npm run dev:speech` → abrir la página → «Escoltar»).
- Los WAV del repositorio son 22050 Hz `pcm_s24le`: hay que reconvertirlos con
  `scripts/convert-samples.sh` (lo hace el *setup* si hay `ffmpeg`).
- El laboratorio no está pensado para producción: sin autenticación, sin límites
  de tamaño y con reconexión automática del cliente.
