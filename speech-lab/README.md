# speech-lab · Laboratorio de voz en tiempo real

Módulo **independiente** para investigar e implementar reconocimiento de voz en
tiempo real para ParlaVal. No toca `frontend/` ni `backend/`: el juego sigue
funcionando igual con su flujo *push-to-talk* mientras aquí se investiga.

Estado: **fases 0–2 completadas** (andamiaje, sidecar de Vosk y página de pruebas
en vivo) más el **modo llamada** (prototipo conversacional dentro del propio
laboratorio, ver abajo). Las fases 3–5 están descritas al final.

## Arranque

```bash
npm run setup:speech   # venv de Python + vosk + websockets + modelo catalán (43 MB) + muestras a 16 kHz
npm run dev:speech     # laboratorio en http://localhost:3100
npm run smoke:speech   # prueba de humo de la tubería completa, sin micrófono
npm run test:speech    # tests del protocolo y de las métricas
```

Requisitos: `python3` con `venv` (el paquete `vosk` viene en un *wheel* de 7 MB,
no compila nada) y, opcionalmente, `ffmpeg` para reconvertir las muestras del
repositorio a 16 kHz. Todo es local: **no hay claves ni servicios externos**.

El micrófono necesita `localhost` o HTTPS; el laboratorio escucha en `localhost`.

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

### Opciones (`speech-lab/.env`, copia de `.env.example`)

| Variable | Por defecto | Para qué |
|---|---|---|
| `SPEECH_LAB_PORT` | `3100` | Puerto del laboratorio (HTTP + WebSocket) |
| `SPEECH_PROVIDER` | `vosk` | Motor del registro `src/streaming/registry.ts` |
| `VOSK_SAMPLE_RATE` | `16000` | Frecuencia que espera el modelo |
| `VOSK_PYTHON` | `.venv/bin/python` | Intérprete del sidecar |
| `VOSK_MODEL_PATH` | `models/vosk-model-small-ca-0.4` | Modelo (admite ruta absoluta) |
| `VOSK_SIDECAR_PORT` | `2700` | Puerto interno, solo `127.0.0.1` |

### Estructura

```
speech-lab/
├── sidecar/vosk_stream.py      # puente Vosk ↔ WebSocket (modelo y endpointing)
├── src/
│   ├── index.ts                # servidor HTTP + /ws/transcribe + cierre limpio
│   ├── config.ts               # entorno con valores por defecto (patrón voice.ts)
│   ├── metrics.ts              # latencias, cómputo y RTF por sesión
│   ├── streaming/
│   │   ├── types.ts            # StreamingStt / StreamingSttSession
│   │   └── registry.ts         # motor activo (una instancia por proveedor)
│   │   ├── voskProtocol.ts     # protocolo del sidecar, aislado y testeable
│   │   └── voskSidecar.ts      # arranque del sidecar, FIFO de latencias, errores
│   └── bench/
│       ├── smoke.ts            # prueba de humo por WebSocket
│       └── wav.ts              # lector WAV PCM16 (sin dependencias)
├── public/                     # página de pruebas (index.html, lab.js, worklet/)
├── scripts/                    # setup-vosk.sh, convert-samples.sh
└── bench/samples/              # WAV a 16 kHz (generados, ignorados por git)
```

## Siguientes pasos

- **Fase 3 — gramática desde los escenarios.** Derivar el `phrase_list` de
  `backend/src/scenarios/*.ts` (objetivos y vocabulario) con normalización
  (minúsculas, sin puntuación, sin duplicados) y medir A/B con y sin gramática.
  La evidencia actual (RTF 0,017 frente a 0,066) hace de esto la línea con más
  recorrido.
- **Fase 4 — bench de WER con voz humana.** Grabar frases de los escenarios,
  guardar el *ground truth* en `src/bench/samples/*.txt` y calcular WER por
  motor. Es la única forma de decidir con datos si el modelo «small» basta o si
  hace falta comparar contra otro motor.
## Modo llamada: conversación completa sin tocar el juego

El laboratorio tiene, además del banco de pruebas, un prototipo de **llamada
conversacional** que demuestra el circuito completo de voz en tiempo real
consumiendo la API existente del juego — pero **sin modificar ninguna línea de
`frontend/`, `backend/` ni `shared/`**:

```
micrófono → Vosk en streaming (texto en vivo mientras hablas)
   → al detectarse el final de la frase, POST /api/turn (modo demo, texto ya transcrito)
      → agente (OpenAI) responde
   → POST /api/tts → la respuesta suena con la voz del escenario (gina/lluc)
   → el micrófono se reabre solo: conversación continua a manos libres
```

- Se activa en la página del laboratorio (`http://localhost:3100`) con el botón
  **«Trucar»**, eligiendo escenario y nivel. Botón «Penjar» para colgar.
- Es **solo lectura de la API del juego** (las mismas llamadas que hace el
  frontend: `createSession` + `sendTurn` + `/api/tts` en modo demo, sin token).
  No escribe en Supabase, no aplica XP real ni altera el flujo del juego.
- El historial del agente se lleva en memoria dentro del laboratorio, igual que
  hace `App.tsx`, para que el personaje recuerde la conversación.
- Limitaciones conscientes de un prototipo: el modo demo no persiste sesiones,
  no hay *barge-in* (el micrófono se reabre cuando termina el audio de la
  respuesta) y el endpointing es el de Vosk (pausa ≈ fin de frase).
- Verificado e2e: dos turnos seguidos sobre «El Mercat» — el agente contesta y
  recuerda «dos quilos de taronges» del turno anterior; audio WAV válido
  reproducido; página sin errores de JS.

### Fase 5 — integración en el juego (⏸ pendiente de decisión)

La integración directa en el juego se implementó y **se revertió** por decisión
del propietario (el módulo debe vivir aparte). El trabajo está guardado en
`/tmp/fase5-integracion/` (proxy `backend/src/routes/streaming.ts` +
`frontend/src/lib/voiceStream.ts` + cambios en `VoiceInput.tsx`) y fue
verificado punta a punta (texto exacto vía el proxy, RTF ≈ 0,07). Si se quiere
integrar más adelante, se puede restaurar desde ahí o reimplementarla usando el
modo llamada como referencia del circuito; antes conviene cerrar la fase 4
(WER con voz humana) para decidir motor.

- **Fase 6 — recerca de motors conversacionals.** Taula de projectes i models
  de parla en català/valencià, amb implicacions per al laboratori:
  `docs/estat-de-lart-veu-conversacional.md`.

## Mode trucada: validació del *endpointing* (tests automatitzats)

El mode trucada depén d'una sola cosa: que el tancament del torn funcione sense
que ningú polse res. Validat amb un arnés que envia PCM16 per WebSocket **sense
enviar mai `{eof: 1}`** (la sortida de l'arnés és a `/tmp/call_detect_test.mjs`):

| Test | Escenari | Resultat |
|---|---|---|
| 1 | Parla → 1,5 s de silenci, sense `eof` | ✅ final sol `"bon dia com et puc ajudar hui"` → agent respon sobre el mercat → TTS WAV vàlid (351–530 KB) |
| 2 | 6 s de silenci pur | ✅ cap final (sense falsos positius) |
| 3 | Dos torns consecutius en la mateixa connexió amb **frases diferents** | ✅ torn 1 `"bon dia com et puc ajudar hui"`, torn 2 `"perdona on està l ajuntament no el troba per enlloc"` — el reconeixedor es reinicia bé entre torns |

Nota de depuració: una versió anterior de l'arnés informava el torn 2 amb el
text del torn 1 — era un error del test (cercava el primer final de la
sessió, no el nou), no del motor. Amb el cursor arreglat, el *endpointing* per
energia i el *reset* del reconeixedor es comporten com cal.

## Qué NO hace este módulo

No modifica `frontend/`, `backend/` ni `shared/` (la integración de la fase 5
se revertió: `git status` solo muestra `speech-lab/` y el `package.json` de la
raíz), no escribe en Supabase, no aplica XP ni toca el agente conversacional.
El modo llamada únicamente **consume** la API HTTP ya existente en modo demo,
igual que haría cualquier cliente de prueba.



```
[speech] provider=vosk partials=8 finals=1 first_partial=150ms final=299ms audio=2.59s rtf=0.066
```
