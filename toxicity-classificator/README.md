# Classificador de toxicitat de ParlaVal

Servei intern per a aplicar el filtre als missatges nous del xat amb el model públic de Hugging Face [`parlaval/laya-toxicity`](https://huggingface.co/parlaval/laya-toxicity). El backend envia cada missatge a este servei de manera asíncrona. El resultat només s'escriu al log: no bloqueja el missatge ni canvia la resposta del xat.

## Lògica del filtre

- Aplica les regles de contingut sexual, la llista d'insults forts i, només per al mode infantil, la llista de vulgarismes. Inclou les excepcions per a consultes de vocabulari.
- Normalitza accents, majúscules i grafies disfressades abans d'aplicar les llistes.
- Puntua el missatge complet i cada frase. En majúscules quasi totals, passa el text a minúscules abans de puntuar-lo.
- Tria `infantil` per als perfils amb `age_group=child`; per als perfils adults i el mode demo usa `adult`.
- Llindars del missatge: `Nucli > 0.50` per a adults; `max(Nucli, Vulgar) > 0.30` per a xiquets. Llindars de frase: `0.97` i `0.90`, respectivament.
- Quan el filtre detecta toxicitat, el backend comença el log amb `missatge_toxic=True` i afig el mode, els llindars emprats, les puntuacions de `Nucli`/`Vulgar`, `p_model` i els tipus de motiu. No registra el missatge ni les paraules detectades.

El model és públic, així que no cal configurar cap token de Hugging Face.

## Executar amb Docker Compose

En el desplegament complet, `docker compose up -d --build` construeix este servei, descarrega el model en el primer inici i conserva la caché al volum `toxicity_model_cache`. El backend espera que el classificador estiga preparat abans d'iniciar-se. La primera descàrrega ocupa aproximadament 678 MB; després, el model es carrega des de la caché persistent.

## Executar localment

1. Des de l'arrel del projecte, crea l'entorn virtual dins del mòdul i instal·la PyTorch CPU i les dependències:

   ```powershell
   npm run setup:toxicity
   ```

2. Inicia el servei:

   ```powershell
   .\toxicity-classificator\.venv\Scripts\python.exe -m uvicorn server:app --app-dir toxicity-classificator --host 127.0.0.1 --port 8001
   ```

3. Mantín el backend amb `TOXICITY_CLASSIFICATOR_URL=http://localhost:8001` (és el valor per defecte; també apareix en `backend/.env.example`).

La primera arrencada descarrega el model de Hugging Face a `toxicity-classificator/.cache/huggingface`; les arrencades següents reutilitzen la caché.
