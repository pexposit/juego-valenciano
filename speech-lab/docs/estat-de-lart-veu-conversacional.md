# Recerca: parla conversacional (tipus trucada) en català/valencià

> Data: 17/9/2026. Fonts principals: API de Hugging Face (JSON) i dominis
> directes. Els cercadors generals van donar captcha durant la investigació;
> les conclusions sobre **models** estan verificades, les de **projectes
> institucionals** provenen de referències indirectes (les seues webs no
> responien el dia de la consulta).

## Conclusió

**No existeix (encara) un model parla-a-parla tipus «trucada» en
català/valencià llest per a usar.** Els projectes conversacionals catalans són
o assistents institucionals tancats, o *pipelines* per peces — igual que el que
ja té el joc (STT → agent LLM → TTS). No hi ha cap equivalent català d'un
GPT-4o-realtime o Moshi. Les peces, però, són de bona qualitat i una (l'ASR
d'Aina) és **nativament streaming**, just el forat que Vosk deixa.

## Projectes conversacionals (assistents de veu complets)

| Projecte | Què és | Utilitat per a ParlaVal |
|---|---|---|
| **Voca (UJI)** | Assistent de veu en valencià del grup de parla de la UJI — el mateix grup que serveix el TTS matxa. El projecte més semblant a una trucada conversacional en valencià. | Web no verificada el dia de la consulta (`vocaproject.uji.es` caigut). **Contacte directe més prometedor** per saber com resolen el STT streaming. |
| **Bunyol / Generalitat** | Assistent de veu institucional valencià (via Llamacat/AVIVA). | Tancat, no reutilitzable com a model; referència d'UX conversacional. |
| **OpenVoiceOS** | Framework obert d'assistent de veu (tipus Alexa) amb TTS català via plugins. | Demostra que el *pipeline* per peces locals és l'estàndard de l'ecosistema. |

## Models de veu catalans reutilitzables (Hugging Face, verificat)

| Model | Tipus | Relevància |
|---|---|---|
| `projecte-aina/faster-whisper-large-v3-ca-3catparla` | ASR, CTranslate2, Apache-2.0 | Millor candidat per substituir el `whisper-1` d'UJI en local, amb streaming *chunked* factible |
| ASR **NeMo Conformer-Transducer** (projecte-aina) | STT **streaming natiu** | El reemplaç natural de Vosk amb qualitat molt superior; cal GPU/NeMo (o ONNX) |
| `projecte-aina/alvocat-vocos-22khz` | Vocoder TTS (ONNX) | Ecosistema TTS català local actiu |
| `BSC-LT/speech-salamandra-es-en` | **Model parla-a-parla** (SLM d'àudio sobre salamandra-7b) | Únic *speech LLM* de l'ecosistema — per ara **es→en, sense català**. Quan arribe a `ca`, canviaria tot |
| **matxa-tts** (DeepLab UJI) | TTS | Ja l'usem — és el TTS català de referència |
| **FLOR / FLOR-1.3B-Instructed** (projecte-aina) | LLM català | Agent 100% local possible però molt inferior al GPT actual; només com a experiment |

## Enllaços

- `https://huggingface.co/projecte-aina` — organització amb tots els ASR/TTS
- `https://huggingface.co/BSC-LT` — BSC, inclòs `speech-salamandra`
- `https://commonvoice.mozilla.org/ca/` — dataset de veu catalana (ground truth gratuït per al bench WER, fase 4)

## Implicacions per al laboratori

1. **Curt termini (sense GPU):** mantindre el *pipeline* actual (Vosk streaming
   + agent + matxa TTS). No hi ha alternativa gratuïta amb millor latència en
   català.
2. **Mitjà termini (amb GPU):** proveïdor nou `aina-chunked` per a
   `StreamingStt`: `faster-whisper-large-v3-ca-3catparla` troceat a 2–5 s amb
   transcripcions parcials. La interfície ja ho suporta (`registry.ts`).
3. **Fase 4 (bench WER):** pas previ obligatori; Common Voice en català
   subministra el *ground truth*.
