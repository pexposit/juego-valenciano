# Detector de variant (valenciano / central)

Dice si la **pronunciación** de un audio suena valenciana o central (catalán
oriental). Usa la API fonética **PhoneticXeus** de la UJI
(`http://deeplab.lsi.uji.es:8899`, `POST /transcribe`), que **solo es accesible
desde la intranet de la UJI** (o con su VPN). El código está en
`src/variant/` (port en TypeScript del prototipo en Python, con paridad
numérica comprobada sobre los 330 clips del corpus de investigación) y se usa
desde tres sitios:

- **Página** (`http://localhost:3100`, sección «Detector de variant»): grabar
  con el micrófono (un `getUserMedia` + `MediaRecorder` propio, sin filtros y
  sin tocar el micrófono en streaming), subir un fichero o probar los dos
  ejemplos **sintéticos** (espeak-ng `ca` y `ca-va`, 15 s; solo sirven para
  ver el circuito). Campo opcional «Text llegit», casilla «Acumular» para
  juntar varias grabaciones de la misma persona y botón «Reinicia». Muestra el
  veredicto, la barra de probabilidad, qué variables han pesado (en palabras
  llanas) y cada segmento con su transcripción.
- **HTTP**: `POST /api/variant` (abajo).
- **Terminal**: `npm run variant -- a.wav b.wav` (abajo).

## Método

Por cada segmento de 3–15 s de voz (cortado por energía en
`src/variant/segment.ts`) se hacen **tres llamadas**:

1. `?include_text=true&align=true&top_k=5`: fonemas reconocidos con sus
   alternativas y probabilidades, más el texto de Whisper.
2. `?align=true&g2p_language=ca&reference_text=…`: alineación con la
   fonetización **central** del texto.
3. `?align=true&g2p_language=ca-va&variants=false&reference_text=…`: lo mismo
   con la fonetización **valenciana**.

El texto es el conocido (si la persona lee una frase dada) o el de Whisper,
limpio (sin puntuación ni bucles de repetición). En las posiciones donde las
dos fonetizaciones difieren —sobre todo las vocales átonas: `ə` central frente
a `a`/`e` valencianas, y `u` frente a `o`— se mide qué ha oído la API
(log-cociente de probabilidades a posteriori, menos una línea base de vocales
estables) y los formantes F1/F2 por LPC. Se descarta el segmento si la API no
responde 200, si hay menos de 15 fonemas, si no hay texto o si el texto no casa
con el audio (PER valenciano > 0,7). La evidencia de **todos los segmentos se
junta antes de puntuar** y un modelo logístico da `pValencia` con siete
variables:

| Variable | Qué mide |
|---|---|
| `norm_ae` | vocales átonas a/e abiertas (no reducidas a `ə`) |
| `norm_o_u` | o átona que no se cierra en u |
| `f1_ae` | F1 de la a átona frente a la e átona |
| `f2_ea` | F2 de la e átona frente a la a átona |
| `f1_a_rel` | apertura de la a átona frente a la a tónica |
| `d_per` | qué fonetización encaja mejor (PER central − PER valenciano) |
| `lex` | palabras marcadoras (`este`, `hui`, `eixir`… frente a `aquest`, `avui`, `sortir`…), suma sin límite (igual que en el entrenamiento); solo en habla libre |

Hay dos juegos de pesos: `with_lex` (habla libre) y `no_lex` (texto conocido:
leer una frase dada no dice nada del léxico de quien habla). Veredicto
`indeterminat` si no hay ningún segmento útil, si hay menos de 6 vocales a/e
átonas medidas o si 0,35 < p < 0,65. El veredicto **describe la pronunciación
del audio, nunca a la persona**.

## Precisión (investigación, validación dejando fuera un hablante cada vez)

Habla real continua (doblaje y audiolibro valencianos, FestCat y LaFrescat
centrales y valencianos), modelo final (`with_lex`):

| Voz por decisión | AUC | Acierto (umbral 0,5) | Acierto sin la franja dudosa | Cobertura |
|---|---|---|---|---|
| ~5 s (1 clip) | 0,87 | 80 % | 86 % | 79 % |
| ~10 s (2 clips) | 0,95 | 89 % | 91 % | 92 % |
| ~21 s (4 clips) | 0,97 | 89 % | 93–94 % | 91 % |

Sin léxico (`no_lex`) el acierto con ~21 s baja a ~88–91 %. Fuera de dominio
**no sirve**: listas de palabras sueltas (Lingua Libre) quedan al azar (≈50 %)
y la voz sintética de Matxa (`lluc`/`gina`) sale casi siempre central aunque
el locutor sea valenciano (recall valenciano 10 %).

## Límites

- Necesita **10–20 s de habla seguida**; con 5 s es orientativo. La página y
  la API lo avisan (`notes`).
- No vale para **palabras sueltas** ni para **voces sintéticas**. Los ejemplos
  de espeak de la página solo prueban el circuito: el espeak central no reduce
  bastante las vocales y su veredicto central lo deciden sobre todo las
  palabras (sin léxico, `--model no_lex`, sale valenciano).
- Es **binario**: el balear y el noroccidental no entran (saldrán como una de
  las dos).
- **No se ha validado con audio de micrófono del navegador** (códec Opus/AAC,
  filtros): el corpus era audio limpio.
- Whisper transcribe el valenciano con ortografía central (`meva`, `seva`): en
  habla libre la variable léxica puede empujar hacia central a un hablante
  valenciano. Con texto conocido no se usa.

## Peculiaridades de la API

- El fonetizador espeak del servidor **no es seguro entre hilos**: dos
  peticiones con `align` a la vez se corrompen las referencias en silencio.
  Todas las peticiones del proceso pasan por **una sola cola**
  (`serial()` en `src/variant/phoneticApi.ts`).
- El fichero subido tiene que llevar extensión aceptada (`.wav`, `.webm`,
  `.m4a`, `.mp3`, `.ogg`, `.flac`); con el nombre por defecto de `FormData`
  (`blob`) la API lo rechaza.
- Segmentos de 3–15 s: la alineación tiene coste más que lineal, la GPU se
  queda sin memoria hacia los 100 s y Whisper alucina con audios largos.
- La referencia G2P no lleva acentos de intensidad y conserva la puntuación:
  el texto se limpia antes.
- Un reintento (tras 1 s) ante un 500 o un `alignment_error`; un tiempo
  agotado no se reintenta.

## `POST /api/variant`

Cuerpo: WAV PCM16 (mono o estéreo, **de 8 a 96 kHz**: se remuestrea a
16 kHz con un sinc enventanado; máx. 25 MB y `VARIANT_MAX_SECONDS`, 180 s).
Si el cliente cierra la conexión, se dejan de enviar segmentos a la API; si
la API deja de responder a media grabación, `notes` dice cuántos trozos se
han analizado. Parámetros:

- `ref=…` — texto leído. La grabación va **entera** como un solo segmento y
  se usa el modelo `no_lex`. Con más de 20 s se trata como habla libre y se
  avisa en `notes`.
- `session=<id>` — junta la evidencia con las peticiones anteriores de la
  misma sesión (en memoria; caduca a los 30 min sin uso, máx. 200 sesiones).
- `reset=1` — vacía la sesión antes de analizar; sin cuerpo, solo la reinicia.

```json
{"verdict":"valencia","label":"Pronunciació valenciana","pValencia":1,"model":"with_lex",
 "reason":null,"reasonText":null,"features":{"norm_ae":-0.13,"…":"…"},
 "contributions":[{"feature":"f1_ae","text":"F1 de la a àtona…","value":0.69,"contribution":5.02,"towards":"valencia"}],
 "segments":[{"startS":0,"endS":14.9,"text":"…","usable":true,"reason":null,"reasonText":null,"positions":66,"nAe":30,"ms":1788}],
 "totals":{"audioSeconds":15.09,"sampleRate":22050,"speechSeconds":14.9,"usableSegments":1,"nAe":30},
 "texts":["…"],"usedReference":false,"session":null,"notes":[],
 "timings":{"resampleMs":144,"analysisMs":1783,"totalMs":1931}}
```

`reason` (si `indeterminat`): `sense-veu-utilitzable`, `poca-evidencia` o
`zona-dubtosa`. Motivos de descarte de un segmento: `error-api`,
`pocs-fonemes`, `sense-text`, `sense-alineacio`, `referencia-dubtosa`,
`paraules-desquadrades`. Si la API fonética no responde, **502** con un
`hint` («només és accessible des de la intranet de la UJI»): antes de analizar
se hace un ping de 5 s a su `/health` para no esperar 2 minutos por llamada
fuera de la intranet. `GET /api/variant/health` hace ese ping (200 / 502) y
`/health` incluye `phoneticApi` (la URL, sin ping). Cada petición deja una
línea en el log:

```
[variant] àudio=15.09s (22050 Hz) segments=1/1 model=with_lex p=1.000 veredicte=valencia n_ae=30 paret=1931ms
```

## CLI

```bash
cd speech-lab
npm run variant -- veu-1.wav veu-2.wav             # una persona: se junta todo
npm run variant -- *.wav --per-file                # cada fichero por separado
npm run variant -- frase.wav --ref "Esta vesprada eixirem a sopar."
npm run variant -- … --model no_lex                # fuerza un modelo
npm run variant -- … --json                        # salida JSON
```

Imprime el veredicto, `p(valencià)`, las contribuciones ordenadas por peso
(+ hacia valenciano, − hacia central) y cada segmento. Sale con código 2 si la
API no es accesible.

Verificado (14/10/2026, contra la API real): los ejemplos espeak de 15 s dan
`central` (p = 0,05) y `valencia` (p ≈ 1,00), también subiendo el WAV original
de 22 050 Hz; una grabación con micrófono falso de Chromium (Opus →
`fileToWav16k`) del ejemplo valenciano da `valencia`; cada segmento de ~15 s
tarda ~1,8 s.
