# speech-lab · Laboratorio de voz en valenciano

Módulo **independiente** de ParlaVal para investigar la voz: reconocimiento en
tiempo real, transcripción, síntesis con voces de personajes, detección de la
variante (valenciano / central) y una llamada conversacional con los agentes
del juego. No toca `frontend/`, `backend/` ni `shared/`: el juego funciona igual
mientras aquí se experimenta.

Todo corre en local (`http://localhost:3100`) salvo dos servicios de la UJI: el
TTS remoto matxa-tts (el mismo que el juego) y la API fonética del detector de
variante, accesible solo desde la intranet o con VPN.

## Funcionalidades

| Funcionalidad | Dónde | Motor | Guía |
|---|---|---|---|
| **Reconocimiento en directo** con parciales, métricas y vocabulario restringido | página: «Micròfon» | Vosk small-ca (sidecar Python) | [reconeixement-de-veu.md](docs/reconeixement-de-veu.md) |
| **Transcripción de ficheros** y comparador Aina vs Vosk | página: «Transcripció de fitxers», `POST /api/transcribe` | faster-whisper `large-v3-ca-3catparla` (Aina) | [reconeixement-de-veu.md](docs/reconeixement-de-veu.md#página-transcripción-de-fitxers-fase-b) |
| **Bench WER** de los motores | `npm run wer:speech` | Vosk y Aina | [reconeixement-de-veu.md](docs/reconeixement-de-veu.md#bench-wer-fase-4-cerrada-con-voz-sintética) |
| **Generación de audio** con cualquier voz: Matxa base, fine-tunes, voces de personajes (RVC) y voces derivadas | página: «Generació d'àudio», `POST /api/tts` | Matxa (local o remoto) + RVC (Applio) | [abajo](#generación-de-audio) y [veus-personatges.md](docs/veus-personatges.md) |
| **Entrenar voces de personajes** a partir de vídeos (Doraemon, Nobita, narrador, narradora, Heidi…) | `scripts/` | Demucs, ECAPA, Whisper, Applio, Matxa | [veus-personatges.md](docs/veus-personatges.md) |
| **Detector de variante** valenciano / central | página: «Detector de variant», `POST /api/variant`, `npm run variant` | API PhoneticXeus (UJI) + modelo logístico | [detector-variant.md](docs/detector-variant.md) |
| **Modo llamada**: conversación a manos libres con un personaje del juego | página: botón «📞 Trucar» | Vosk + API del juego + TTS | [mode-trucada.md](docs/mode-trucada.md) |

## Arranque

Desde la raíz del repositorio:

```bash
npm run setup:speech   # .venv + Vosk + modelo catalán (43 MB) + muestras a 16 kHz
npm run setup:aina     # faster-whisper + modelo de Aina (~3 GB, usa la GPU si hay)
npm run dev:speech     # laboratorio en http://localhost:3100
npm run test:speech    # tests (vitest, sin arrancar Python)
npm run smoke:speech   # prueba de humo de la tubería completa, sin micrófono
npm run wer:speech     # bench WER: cada bench/samples/*.wav contra su .txt
```

Solo para la síntesis local y las voces de personajes (necesitan GPU NVIDIA):

```bash
bash speech-lab/scripts/setup-matxa.sh   # .venv-voz: Matxa, espeak-ng ca-va, Demucs, SpeechBrain
bash speech-lab/scripts/setup-rvc.sh     # .venv-rvc: Applio (RVC)
```

Los modelos de voz entrenados (personajes RVC y fine-tunes de Matxa) no están
en git: están en un repositorio **privado** de Hugging Face. Con acceso y la
sesión iniciada (`speech-lab/.venv/bin/hf auth login`):

```bash
npm run models:speech                    # todos (~2,5 GB, solo baja lo que cambia)
npm run models:speech -- doraemon heidi  # solo algunos
```

Cómo pedir acceso y cómo publicar un modelo nuevo: [docs/veus-personatges.md](docs/veus-personatges.md#compartir-los-modelos-con-el-equipo).

Requisitos: Node 22, `python3` con `venv` y, opcionalmente, `ffmpeg`. El
micrófono necesita `localhost` o HTTPS. Sin terminal interactiva (`tsx watch`
muere con `EBADF`): `npm run build -w speech-lab && node speech-lab/dist/index.js`.

## La página

`http://localhost:3100`, JavaScript sin build (`public/index.html`, `public/lab.js`
y un `AudioWorklet`):

1. **Micròfon**: «Escoltar» envía PCM16 a 16 kHz por WebSocket y muestra el
   texto en vivo; «Fi del torn» cierra el turno. Campo de **vocabulario
   restringido** (una frase por línea): cuatro veces menos cómputo y
   transcripción exacta si la frase está en la lista. Los filtros de voz del
   navegador van desactivados porque empeoran el reconocimiento.
2. **Nivell d'entrada, Transcripció, Mètriques, Registre**: nivel del
   micrófono, texto final, latencias (primer parcial, final, RTF) y log.
3. **Transcripció de fitxers**: sube cualquier audio (el navegador lo pasa a
   16 kHz), segmentos clicables y comparación lado a lado Aina / Vosk.
4. **Generació d'àudio**: ver abajo.
5. **Detector de variant**: graba, sube un fichero o prueba los ejemplos;
   veredicto, probabilidad y qué ha pesado. Opciones de texto leído y de
   acumular varias grabaciones de la misma persona.
6. **📞 Trucar**: elige escenario y nivel y habla con el personaje sin pulsar
   nada; se le puede interrumpir mientras habla.

## Generación de audio

Se elige un modelo del catálogo (`GET /api/tts/models`, leído del disco en cada
petición: un entrenamiento nuevo aparece sin reiniciar), el checkpoint si hay
varios y sus parámetros. Cada generación queda en un historial con sus tiempos
para comparar de oído.

| Id del modelo | Qué es | Parámetros |
|---|---|---|
| `remot:<voz>` | matxa-tts de la UJI (gina, lluc) | — |
| `matxa:base:<spk>` | Matxa multiaccent local; locutores valencianos gina (7) y lluc (6) | temperatura, duración |
| `matxa:<run>:<spk>` | fine-tunes de `tts/runs/` (`narrador-v1`, `doraemon-v1`, `veus-v1`) | checkpoint, temperatura, duración |
| `rvc:<nombre>` | Matxa base + timbre del personaje con RVC (`doraemon`, `nobita`, `narrador`, `narradora`, `heidi`) | tono (semitonos), peso del índice |
| `veu:<nombre>` | gina transformada por DSP (`narradora`, `nena`; experimento) | tono, formantes |

Los modelos locales viven en dos sidecars que arrancan con la primera petición
(~12 s) y luego tardan ~0,2 s por frase cada uno; ocupan ~2 GB de GPU, así que
no caben junto a un entrenamiento en la GPU de 6 GB.

Desde la terminal: `scripts/parla.sh <personaje> "text"` → WAV en `tts/rvc/eixida/`.

La recomendación tras medir inteligibilidad (WER de Whisper) y parecido: para
personajes con poco material, **Matxa + RVC**; el fine-tune de Matxa solo
compensa con mucho audio limpio (el narrador del audiolibro). Detalle y cifras
en [docs/veus-personatges.md](docs/veus-personatges.md).

## API HTTP

| Método y ruta | Para qué |
|---|---|
| `GET /health` | estado de los motores y de la configuración |
| `WS /ws/transcribe` | reconocimiento en streaming (protocolo de vosk-server) |
| `POST /api/transcribe` | WAV PCM16 mono 16 kHz → texto, segmentos, palabras y, con `?reference=`, WER |
| `GET /api/tts/models` | catálogo de voces |
| `POST /api/tts` | `{text, voice?, model?, checkpoint?, temperature?, speed?, pitch?, indexRate?, formant?}` → WAV |
| `POST /api/variant` | WAV → veredicto valenciano / central (`?ref=`, `?session=`, `?reset=1`) |
| `GET /api/variant/health` | si la API fonética de la UJI responde |

Formato de cada una en las guías de [docs/](docs/).

## Configuración

`speech-lab/.env` (copia de `.env.example`). Todas tienen valor por defecto:

| Variable | Por defecto | Para qué |
|---|---|---|
| `SPEECH_LAB_PORT` | `3100` | puerto del laboratorio |
| `SPEECH_PROVIDER` | `vosk` | motor de streaming |
| `VOSK_PYTHON`, `VOSK_MODEL_PATH`, `VOSK_SAMPLE_RATE`, `VOSK_SIDECAR_PORT` | `.venv/bin/python`, `models/vosk-model-small-ca-0.4`, `16000`, `2700` | sidecar de Vosk |
| `BATCH_PROVIDER` | `aina` | motor de transcripción por lotes |
| `AINA_PYTHON`, `AINA_MODEL_ID`, `AINA_MODEL_PATH` | `.venv/bin/python`, modelo `3catparla` | sidecar de Whisper |
| `AINA_DEVICE`, `AINA_COMPUTE_TYPE` | `auto`, `float16` | forzar CPU o el tipo en GPU |
| `TTS_PROVIDER`, `MATXA_TTS_URL`, `MATXA_TTS_VOICE(S)` | `matxa`, servidor UJI, `gina` | TTS remoto (mismas variables que el backend) |
| `MATXA_PYTHON`, `MATXA_BASE_CKPT`, `MATXA_RUNS_DIR` | `.venv-voz`, checkpoint 629, `tts/runs` | Matxa local |
| `RVC_PYTHON`, `APPLIO_DIR` | `.venv-rvc`, `tts/rvc/Applio` | RVC |
| `PHONETIC_API_URL`, `PHONETIC_API_TIMEOUT_MS` | `http://deeplab.lsi.uji.es:8899`, `120000` | API fonética del detector |
| `VARIANT_SESSION_TTL_MS`, `VARIANT_MAX_SESSIONS`, `VARIANT_MAX_SECONDS` | `1800000`, `200`, `180` | sesiones y límites de `/api/variant` |

## Estructura

```
speech-lab/
├── README.md
├── docs/
│   ├── reconeixement-de-veu.md        # Vosk, Aina, protocolo, mediciones, bench WER
│   ├── veus-personatges.md            # canalización de voces, modelos, carpetas, copia de seguridad
│   ├── detector-variant.md            # método, precisión, límites, API y CLI
│   ├── mode-trucada.md                # llamada conversacional y su validación
│   └── estat-de-lart-veu-conversacional.md
├── src/                               # servidor (TypeScript)
│   ├── index.ts                       # HTTP + WebSocket + estáticos
│   ├── config.ts                      # variables de entorno
│   ├── metrics.ts                     # latencias y RTF
│   ├── streaming/                     # STT en streaming (Vosk)
│   ├── batch/                         # STT por lotes (Aina, Vosk)
│   ├── tts/                           # TTS remoto y local (Matxa, RVC, veus derivades)
│   ├── variant/                       # detector de variante
│   └── bench/                         # smoke, WER y CLI del detector
├── sidecar/                           # procesos Python que habla el servidor
│   ├── vosk_stream.py                 # Vosk por WebSocket
│   ├── whisper_batch.py               # faster-whisper por NDJSON
│   ├── matxa_local.py                 # Matxa local por NDJSON
│   └── rvc_convert.py                 # conversión RVC por NDJSON
├── public/                            # la página (index.html, lab.js, worklet/, samples/)
├── bench/samples/                     # audios de prueba + su texto de referencia
├── scripts/
│   ├── setup-{vosk,aina,matxa,rvc}.sh # instalación de cada entorno
│   ├── convert-samples.sh             # muestras a 16 kHz
│   ├── separa-personatges.py          # vídeos → voz agrupada por hablante
│   ├── extrau-personatge.py           # un hablante sin tramos dudosos
│   ├── segmenta-veu.py                # clips de 2–12 s + transcripción
│   ├── revisa-clips.py                # web para revisar los textos a mano
│   ├── entrena-rvc.sh                 # entrena un RVC
│   ├── prepara-matxa.py, finetune-matxa.py   # fine-tune de Matxa
│   ├── sintetitza-matxa.py, matxa_entorn.py  # síntesis desde la terminal
│   ├── parla.sh                       # texto → voz de personaje (Matxa + RVC)
│   ├── entrena-narradora-heidi.sh     # ejemplo de canalización desatendida
│   ├── rvc-personatges.json           # voz base, tono e índice de cada personaje
│   └── veus.json                      # voces derivadas por DSP
│
│   (fuera de git: pesan mucho o tienen derechos)
├── models/                            # Vosk y Aina descargados
├── tts/                               # Matxa, espeak-ng, Applio, entrenamientos (ver tts/README.md)
│   ├── runs/<run>/                    # fine-tunes de Matxa
│   ├── rvc/Applio/logs/<nombre>/      # modelos RVC
│   └── logs/, rvc/logs/               # logs de entrenamientos
├── audios/                            # audio original descargado
├── voz-dataset/                       # Demucs, hablantes, clips y logs/
└── .venv/, .venv-voz/, .venv-rvc/     # entornos de Python
```

## Estado y siguientes pasos

Hecho: reconocimiento en streaming, transcripción por lotes y bench WER (con
voz sintética), generación de audio con todos los modelos, voces de cinco
personajes, detector de variante y modo llamada. La integración en el juego
(fase 5) se implementó y se revirtió por decisión del propietario.

Pendiente:

- **WER con voz humana valenciana**: es la medida que de verdad decide entre
  Vosk y Aina; con voz sintética Vosk gana, pero Aina tira al catalán central.
- **Vocabulario desde los escenarios** del juego (leído por `/api/scenarios`):
  el vocabulario restringido es la mejora más grande medida.
- **Streaming de calidad** (Whisper por trozos o NeMo) y TTS troceado por frases.
- **Más voces**: `rvc:parlant04` (grupo 04 de Heidi, voz grave, sobre lluc) en
  preparación.

## Qué no hace

No modifica el juego, no escribe en Supabase, no aplica XP ni toca el agente.
El modo llamada solo **consume** la API del juego en modo demo. Es un
laboratorio: sin autenticación ni pensado para producción.

Licencias: los modelos de Matxa y el vocoder son de Projecte AINA (uso no
comercial, ver [tts/README.md](tts/README.md)); las voces de personajes salen de
doblajes y vídeos con derechos y no se publican.
