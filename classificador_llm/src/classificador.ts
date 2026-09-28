/**
 * Prototip de classificador de nivell de valencià amb l'API d'OpenAI (Mòdul 3)
 * ============================================================================
 * Assigna a un text un nivell (A1, A2, B1, B2, C1, C2) seguint els criteris de la JQCV.
 *
 * El prompt té tres parts:
 * 1. Instruccions i criteris d'avaluació.
 * 2. Descripció de cada nivell, resumida dels Quaderns de nivell (nivells.ts).
 * 3. Exemples de cada nivell: els fitxers .txt de la carpeta exemples/<NIVELL>/.
 *    Per a afegir o canviar exemples, només cal editar eixos fitxers.
 *
 * La resposta és un JSON amb el grup, el nivell exacte, la confiança i una justificació:
 *     {"grup": "Mitjà", "nivell": "B1", "confianca": "mitjana", "nivells_dubte": ["B1", "B2"],
 *      "justificacio": "..."}
 * Grup: "Bàsic" (A1, A2), "Mitjà" (B1, B2) o "Superior" (C1, C2). Es deduïx del nivell.
 * Confiança: "alta" (un sol nivell), "mitjana" (dubta amb un nivell del costat) o "baixa"
 * (dubta entre més de dos). Si dubta, "nivells_dubte" diu entre quins nivells; si no, és buit.
 *
 * Configuració (fitxer .env en la carpeta classificador_llm/):
 *     OPENAI_API_KEY=sk-...
 *     OPENAI_MODEL=gpt-6-luna        (opcional)
 */

import { existsSync, readdirSync, readFileSync } from "node:fs";
import { join, resolve } from "node:path";

import OpenAI from "openai";

import { GRUPS, NIVELLS, contextNivellText, type Grup, type Nivell } from "./nivells.js";

// Carpeta arrel del classificador (src/ o dist/ estan un nivell per davall)
export const CARPETA = resolve(import.meta.dirname, "..");
const CARPETA_EXEMPLES = join(CARPETA, "exemples");
export const MODEL_PER_DEFECTE = "gpt-6-luna";

const INSTRUCCIONS = `\
Ets un avaluador expert en els certificats de coneixements de valencià de la Junta \
Qualificadora de Coneixements de Valencià (JQCV), que seguixen el Marc europeu comú de \
referència per a les llengües (MCER).

La teua tasca és assignar a cada text el nivell (A1, A2, B1, B2, C1 o C2) que cal tindre \
per a comprendre'l, és a dir, el nivell d'examen de la JQCV en què podria aparéixer.

Criteris:
1. Jutja la llengua del text: lèxic (freqüència, especialització, fraseologia), \
morfosintaxi (temps verbals, subordinació, pronoms), discurs (connectors, cohesió) i \
registre (formalitat, abstracció, ironia, sentits implícits).
2. La temàtica orienta, però no decidix: un tema quotidià es pot tractar amb una llengua \
de C1, i un tema científic es pot divulgar a nivell B1.
3. La longitud no és un criteri: els exemples llargs estan retallats ("[...]").
4. Compara el text amb la descripció de cada nivell i amb els exemples, i tria el nivell \
que encaixe millor.
5. Indica la confiança:
   - "alta": el text encaixa clarament en un sol nivell. "nivells_dubte" és buit.
   - "mitjana": dubtes entre el nivell triat i un nivell del costat (per exemple, B1 i \
B2). "nivells_dubte" conté els dos nivells.
   - "baixa": dubtes entre més de dos nivells. "nivells_dubte" conté tots els nivells \
entre els quals dubtes, inclòs el triat.
6. Escriu la justificació en valencià, breu, citant paraules o estructures del text. Si \
dubtes, explica per què.`;

// La justificació va primer perquè el model raone abans de decidir el nivell
const ESQUEMA_RESPOSTA = {
  type: "object",
  properties: {
    justificacio: { type: "string" },
    nivell: { type: "string", enum: NIVELLS },
    confianca: { type: "string", enum: ["alta", "mitjana", "baixa"] },
    nivells_dubte: { type: "array", items: { type: "string", enum: NIVELLS } },
  },
  required: ["justificacio", "nivell", "confianca", "nivells_dubte"],
  additionalProperties: false,
};

export type Confianca = "alta" | "mitjana" | "baixa";

export interface Resultat {
  grup: Grup;
  nivell: Nivell;
  confianca: Confianca;
  nivells_dubte: Nivell[];
  justificacio: string;
}

/** Llig un fitxer de text en UTF-8 amb salts de línia normalitzats (Windows usa \r\n). */
export function llegixText(fitxer: string): string {
  return readFileSync(fitxer, "utf-8").replace(/\r\n?/g, "\n").trim();
}

/** Llig exemples/<NIVELL>/*.txt i torna una llista de [nivell, text]. */
export function carregaExemples(): [Nivell, string][] {
  const exemples: [Nivell, string][] = [];
  for (const nivell of NIVELLS) {
    const carpeta = join(CARPETA_EXEMPLES, nivell);
    if (!existsSync(carpeta)) continue;
    for (const fitxer of readdirSync(carpeta).filter((f) => f.endsWith(".txt")).sort()) {
      exemples.push([nivell, llegixText(join(carpeta, fitxer))]);
    }
  }
  return exemples;
}

export function construixPrompt(): string {
  const parts = [INSTRUCCIONS, "", "## Descripció dels nivells (Quaderns de nivell de la JQCV)", ""];
  for (const nivell of NIVELLS) parts.push(contextNivellText(nivell), "");
  parts.push("## Exemples de textos de cada nivell", "");
  for (const [nivell, text] of carregaExemples()) {
    parts.push(`<exemple nivell="${nivell}">`, text, "</exemple>", "");
  }
  return parts.join("\n").trim();
}

/** Carrega OPENAI_API_KEY / OPENAI_MODEL del fitxer .env, si existix. */
export function carregaEnv(): void {
  const fitxer = join(CARPETA, ".env");
  if (existsSync(fitxer)) process.loadEnvFile(fitxer);
}

export class ClassificadorNivell {
  readonly model: string;
  readonly prompt: string;
  private client: OpenAI;

  constructor(model?: string) {
    carregaEnv();
    if (!process.env.OPENAI_API_KEY) {
      throw new Error("Falta OPENAI_API_KEY. Crea el fitxer .env (vegeu .env.example).");
    }
    this.model = model || process.env.OPENAI_MODEL || MODEL_PER_DEFECTE;
    this.client = new OpenAI();
    this.prompt = construixPrompt();
  }

  async classificar(text: string): Promise<Resultat> {
    const parametres = {
      model: this.model,
      messages: [
        { role: "system" as const, content: this.prompt },
        { role: "user" as const, content: `Classifica el text següent:\n\n<text>\n${text.trim()}\n</text>` },
      ],
      response_format: {
        type: "json_schema" as const,
        json_schema: { name: "nivell", strict: true, schema: ESQUEMA_RESPOSTA },
      },
    };

    // temperature=0 fa la classificació repetible, però els models de raonament
    // (o1, o3, gpt-5...) no l'accepten: si el model la rebutja, es torna a provar sense
    let resposta;
    try {
      resposta = await this.client.chat.completions.create({ ...parametres, temperature: 0 });
    } catch (e) {
      if (!(e instanceof OpenAI.BadRequestError) || !String(e.message).includes("temperature")) throw e;
      resposta = await this.client.chat.completions.create(parametres);
    }
    const r = JSON.parse(resposta.choices[0].message.content ?? "{}") as Omit<Resultat, "grup">;

    // Coherència entre confiança i nivells de dubte: buit si és alta; si no, ha
    // d'incloure el nivell triat, sense repetits i en orde (A1 → C2)
    let dubte: Nivell[] = [];
    if (r.confianca !== "alta") {
      dubte = [...new Set([...r.nivells_dubte, r.nivell])].sort(
        (a, b) => NIVELLS.indexOf(a) - NIVELLS.indexOf(b),
      );
    }
    return {
      grup: GRUPS[r.nivell],
      nivell: r.nivell,
      confianca: r.confianca,
      nivells_dubte: dubte,
      justificacio: r.justificacio,
    };
  }
}
