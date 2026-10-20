# Modo llamada (`📞 Trucar`)

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
- La API del juego tiene que ser **alcanzable desde el navegador**: el despliegue
  no publica el puerto 3001 (solo llega Caddy por la red interna de compose). En
  local hace falta el override de pruebas —que ya incluye el puerto—:
  `docker compose -f docker-compose.yml -f docker-compose.local.yml up -d api`.
  Sin eso el navegador falla con «Failed to fetch» y la llamada muestra «No s'ha
  pogut parlar amb l'agent». El CORS no estorba: el backend acepta cualquier
  origen `localhost` con cualquier puerto, así que `http://localhost:3100` pasa.
- Es **solo lectura de la API del juego** (las mismas llamadas que hace el
  frontend: `createSession` + `sendTurn` + `/api/tts` en modo demo, sin token).
  No escribe en Supabase, no aplica XP real ni altera el flujo del juego.
- El historial del agente se lleva en memoria dentro del laboratorio, igual que
  hace `App.tsx`, para que el personaje recuerde la conversación.
- Limitaciones conscientes de un prototipo: el modo demo no persiste sesiones y
  el *endpointing* es el de Vosk (pausa ≈ fin de frase).
- *Barge-in* (interruptor «Permetre interrompre l'agent mentre parla», activo
  por defecto): mientras el personaje habla el micrófono se pausa para no
  devolverle su propia voz, y si le hablas encima (2 bloques seguidos con voz,
  ≈ 256 ms) se corta la frase y se vuelve a escuchar. Requiere cancelación de
  eco: al trucar se activa sola (eco del altavoz + micrófono = el agente se
  interrumpiría a sí mismo).
- Verificado e2e: dos turnos seguidos sobre «El Mercat» — el agente contesta y
  recuerda «dos quilos de taronges» del turno anterior; audio WAV válido
  reproducido; página sin errores de JS.

## Validació del *endpointing* (tests automatitzats)

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

## Fase 5 — integración en el juego (⏸ pendiente de decisión)

La integración directa en el juego se implementó y **se revertió** por decisión
del propietario (el módulo debe vivir aparte). El trabajo está guardado en
`/tmp/fase5-integracion/` (proxy `backend/src/routes/streaming.ts` +
`frontend/src/lib/voiceStream.ts` + cambios en `VoiceInput.tsx`) y fue
verificado punta a punta (texto exacto vía el proxy, RTF ≈ 0,07). Si se quiere
integrar más adelante, se puede restaurar desde ahí o reimplementarla usando el
modo llamada como referencia del circuito; antes conviene cerrar la fase B
(WER con voz humana) para decidir motor.
