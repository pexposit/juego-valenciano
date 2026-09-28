/**
 * Servici web (API REST) del classificador de nivell de valencià (Mòdul 3)
 * ========================================================================
 * Exposa el classificador per HTTP perquè el puguen usar altres mòduls del projecte.
 *
 * Endpoints:
 *     GET  /salut        → {"estat": "ok", "model": "..."}  (per a comprovar que està en marxa)
 *     POST /classificar  → cos: {"text": "..."}
 *                          resposta: {"grup", "nivell", "confianca", "nivells_dubte", "justificacio"}
 *     GET  /docs         → documentació interactiva (Swagger), per a provar-lo des del navegador
 *
 * Execució local (sense Docker):
 *     npm start
 */

import express, { type NextFunction, type Request, type Response } from "express";
import OpenAI from "openai";
import swaggerUi from "swagger-ui-express";

import { ClassificadorNivell } from "./classificador.js";
import { NIVELLS } from "./nivells.js";

const PORT = Number(process.env.PORT ?? 8000);
const MAX_CARACTERS = 20000;

const classificador = new ClassificadorNivell();
const app = express();
app.use(express.json({ limit: "1mb" }));

app.get("/salut", (_req, res) => {
  res.json({ estat: "ok", model: classificador.model });
});

app.post("/classificar", async (req: Request, res: Response) => {
  const text = req.body?.text;
  if (typeof text !== "string" || !text.trim()) {
    return res.status(422).json({ detail: 'Cal un camp "text" amb el text a classificar.' });
  }
  if (text.length > MAX_CARACTERS) {
    return res.status(422).json({ detail: `El text no pot passar de ${MAX_CARACTERS} caràcters.` });
  }
  try {
    res.json(await classificador.classificar(text));
  } catch (e) {
    if (e instanceof OpenAI.APIError) {
      console.error(`Error de l'API d'OpenAI: ${e.message}`);
      return res.status(502).json({ detail: `Error de l'API d'OpenAI: ${e.message}` });
    }
    throw e;
  }
});

// Documentació OpenAPI per a /docs
const openapi = {
  openapi: "3.0.3",
  info: {
    title: "Classificador de nivell de valencià",
    version: "1.0.0",
    description: "Classifica textos en valencià en Bàsic/Mitjà/Superior i A1–C2 (criteris JQCV).",
  },
  paths: {
    "/salut": {
      get: { summary: "Comprova que el servici està en marxa", responses: { "200": { description: "OK" } } },
    },
    "/classificar": {
      post: {
        summary: "Classifica un text",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                required: ["text"],
                properties: { text: { type: "string", maxLength: MAX_CARACTERS } },
              },
              example: { text: "Hola, em dic Anna. Visc a Castelló amb la meua família." },
            },
          },
        },
        responses: {
          "200": {
            description: "Resultat de la classificació",
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  properties: {
                    grup: { type: "string", enum: ["Bàsic", "Mitjà", "Superior"] },
                    nivell: { type: "string", enum: NIVELLS },
                    confianca: { type: "string", enum: ["alta", "mitjana", "baixa"] },
                    nivells_dubte: { type: "array", items: { type: "string", enum: NIVELLS } },
                    justificacio: { type: "string" },
                  },
                },
              },
            },
          },
          "422": { description: "Text buit o massa llarg" },
          "502": { description: "Error de l'API d'OpenAI" },
        },
      },
    },
  },
};
app.use("/docs", swaggerUi.serve, swaggerUi.setup(openapi));

// Errors inesperats (i JSON mal format en el cos de la petició)
app.use((err: Error & { status?: number }, _req: Request, res: Response, _next: NextFunction) => {
  if (err.status === 400) return res.status(400).json({ detail: "El cos de la petició no és un JSON vàlid." });
  console.error(err);
  res.status(500).json({ detail: "Error intern del servici." });
});

app.listen(PORT, () => {
  console.log(`Classificador en marxa en http://localhost:${PORT} (model ${classificador.model})`);
});
