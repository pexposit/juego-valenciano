# Clasificador de nivel de valenciano

Servicio web que recibe un texto en valenciano y devuelve su nivel (A1–C2) según los criterios de la JQCV, usando la API de OpenAI. Dentro de ParlaVal funciona como un servicio independiente al que llama el backend.

```
Navegador ──► backend (api, :3001) ──► clasificador (:8000) ──► OpenAI
              requireAuth + rateLimit
```

El clasificador **no tiene autenticación** y cada petición gasta crédito de OpenAI. Por eso nunca se expone a Internet: solo le llama el backend.

## API

| Método | Ruta | Descripción |
|---|---|---|
| `GET` | `/salut` | Comprueba que está en marcha: `{"estat":"ok","model":"..."}` |
| `POST` | `/classificar` | Cuerpo `{"text":"..."}` (máx. 20000 caracteres). Devuelve `grup`, `nivell`, `confianca`, `nivells_dubte`, `justificacio` |
| `GET` | `/docs` | Documentación interactiva (Swagger) para probarlo desde el navegador |

Ejemplo de respuesta:

```json
{
  "grup": "Mitjà",
  "nivell": "B1",
  "confianca": "mitjana",
  "nivells_dubte": ["B1", "B2"],
  "justificacio": "..."
}
```

`grup` se corresponde con los niveles del juego: `Bàsic` → `principiant`, `Mitjà` → `intermedi`, `Superior` → `avancat`.

## Contenido de la carpeta

```
classificador_llm/
├── src/
│   ├── servei.ts          servidor Express (endpoints)
│   ├── classificador.ts   construcción del prompt y llamada a OpenAI
│   └── nivells.ts         descripción de cada nivel (Quaderns de la JQCV)
├── exemples/<NIVELL>/     textos de ejemplo que van dentro del prompt (obligatorios)
├── package.json
├── package-lock.json      obligatorio: el Dockerfile usa `npm ci`
├── tsconfig.json
├── Dockerfile
├── .dockerignore
└── .env.example
```

- **`exemples/` es obligatoria.** El prompt se construye con estos textos al arrancar. Si falta la carpeta, el servicio arranca igual, pero clasifica peor.
---

## Puesta en marcha en desarrollo (primera vez)

En desarrollo, el juego funciona así:

| Parte | Dónde corre | Cómo se arranca |
|---|---|---|
| Supabase (BD, auth, API) | Docker (contenedores `supabase_...`) | `supabase start` |
| Backend y frontend | Tu máquina, con Node | `npm run dev` en `juego-valenciano/` |
| **Clasificador** | **Docker (contenedor `classificador-llm`)** | **`docker run` (esta guía)** |

El `docker-compose.yml` de la raíz de `juego-valenciano/` **no se usa en desarrollo**: sirve para desplegar en un servidor (ver [Despliegue en servidor](#despliegue-en-servidor-docker-composeyml-de-la-raíz)). Si lo ejecutas sin el `.env` de despliegue, falla con errores como `required variable SERVICE_ROLE_KEY is missing a value`.

### Requisitos

- Docker Desktop en marcha.
- Una clave de la API de OpenAI.

No hace falta instalar Node ni ejecutar `npm install` para el contenedor: la imagen instala sus propias dependencias.

### 1. Crear el `.env`

En esta carpeta (`juego-valenciano/classificador_llm/`), copia `.env.example` como `.env` y rellénalo:

```
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4.1-mini
```

- **Nunca subas `.env` al repositorio.** Está en `.gitignore` y en `.dockerignore`.

### 2. Construir la imagen

En esta carpeta:

```
docker build -t classificador-llm .
```

### 3. Arrancar el contenedor

```
docker run -d --name classificador-llm --env-file .env -p 8000:8000 --restart unless-stopped classificador-llm
```

| Opción | Significado |
|---|---|
| `-d` | En segundo plano |
| `--name classificador-llm` | Nombre del contenedor (en Docker Desktop aparece así) |
| `--env-file .env` | Pasa la clave al contenedor. La clave no se guarda en la imagen |
| `-p 8000:8000` | Puerto de tu máquina : puerto del contenedor. Lo hace accesible en `localhost:8000` |
| `--restart unless-stopped` | Arranca solo al abrir Docker Desktop, salvo que lo pares a mano |

### 4. Comprobar que funciona

- `docker ps`: `classificador-llm` debe aparecer con `0.0.0.0:8000->8000/tcp`.
- http://localhost:8000/salut: debe responder `{"estat":"ok","model":"..."}`.
- http://localhost:8000/docs: prueba `POST /classificar` con un texto.
- Si algo falla: `docker logs classificador-llm`. Si todo va bien, debe aparecer `Classificador en marxa en http://localhost:8000 (model ...)`.

### 5. Conectar el backend

En `juego-valenciano/backend/.env`:

```
CLASSIFICADOR_URL=http://localhost:8000
```

Después reinicia `npm run dev` (Ctrl+C y vuelve a lanzarlo) para que el backend lea la variable.

---

## Uso diario

Al empezar a trabajar:

1. **Abre Docker Desktop.** Supabase y `classificador-llm` arrancan solos.
2. **Ejecuta `npm run dev`** en `juego-valenciano/`.


| Quiero... | Orden |
|---|---|
| Parar el clasificador | `docker stop classificador-llm` |
| Volver a arrancarlo | `docker start classificador-llm` |
| Ver sus logs | `docker logs classificador-llm` |
| Aplicar un cambio del `.env` | `docker rm -f classificador-llm` y repetir el paso 3 (sin build) |
| Aplicar un cambio de código o de `exemples/` | `docker build -t classificador-llm .`, después `docker rm -f classificador-llm` y repetir el paso 3 |


### Quitar los errores del editor (opcional)

VS Code marca `Cannot find module 'openai'` en `src/` si esta carpeta no tiene `node_modules`. Para solucionarlo, en esta carpeta:

```
npm install
```

---

## Problemas frecuentes

| Síntoma | Causa | Solución |
|---|---|---|
| `Bind for 0.0.0.0:8000 failed: port is already allocated` | Otro contenedor usa el puerto 8000 | Mira quién es con `docker ps --filter "publish=8000"` y bórralo con `docker rm -f <nombre>`. También puedes usar otro puerto: `-p 8001:8000` y `CLASSIFICADOR_URL=http://localhost:8001` |
| `Conflict. The container name "/classificador-llm" is already in use` | Queda un contenedor anterior (incluso uno que falló al arrancar) | `docker rm -f classificador-llm` y repite el paso 3 |
| El contenedor se reinicia sin parar; en los logs aparece `Falta OPENAI_API_KEY` | El `.env` no tiene la clave | Rellénala, `docker rm -f classificador-llm` y repite el paso 3 |
| `/classificar` responde 502 | Error de OpenAI: clave inválida, sin crédito o modelo inexistente | Mira `docker logs classificador-llm` y revisa `OPENAI_MODEL` |


---

## Despliegue en servidor (`docker-compose.yml` de la raíz)

En producción, el clasificador arranca con el resto del juego con `docker compose up -d --build` desde `juego-valenciano/`, siguiendo el `DEPLOY.md`. En el compose:

```yaml
  api:
    environment:
      CLASSIFICADOR_URL: http://classificador:8000
    depends_on:
      classificador:
        condition: service_started

  classificador:
    build: ./classificador_llm
    env_file: classificador_llm/.env
    environment:
      PORT: 8000
    restart: unless-stopped
```

- **Sin `ports` ni ruta en Caddy.** Solo es accesible desde la red interna de compose, así que desde Internet nadie puede llamarlo directamente.
- **`classificador` es el nombre del servicio**, y funciona como nombre de host dentro de la red de compose. No choca con `web:8000` (la entrada interna de Caddy a Supabase), porque cada contenedor tiene sus propios puertos.
- **Con `condition: service_started`, el juego arranca aunque el clasificador falle.** Solo fallan las peticiones de nivel. Si usas `service_healthy`, `api` no arranca hasta que `/salut` responda.
- **`classificador_llm/.env` tiene que existir en el servidor** antes del `docker compose up`.
