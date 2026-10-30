import * as cheerio from 'cheerio';
import type { Element } from 'domhandler';

export interface DnvResult {
  existeix: boolean;
  // L'entrada del DNV és exactament la paraula consultada (o una variant que l'entrada admet). El portal també torna
  // l'entrada més pròxima per a paraules mal escrites («mayúscula» → «majúscula»): en eixe cas `existeix` és cert però
  // `exacta`, no.
  exacta?: boolean;
  lema?: string;
  variants?: string[];
  categoria?: string;
  definicions?: string[];
  url: string;
}

// Formes d'un encapçalament de l'entrada («reconéixer (o reconèixer) [rekonéjʃeɾ]», «perquè1 [peɾké]»): el lema i les
// variants que admet. Sense la fonètica, el número d'homògraf ni les terminacions de flexió («bonic, -a»).
export function formesDelLema(encapcalament: string): { lema: string; variants: string[] } {
  const net = encapcalament.replace(/\s*\[[^\]]*\].*$/, '').replace(/\s*ui-button.*$/, '').trim();
  const lema = net.replace(/\s*\(.*$/, '').replace(/,.*$/, '').replace(/\d+$/, '').trim();
  const variants = [...net.matchAll(/\(o ([^)]+)\)/g)]
    .flatMap(m => m[1].split(/,| o /))
    .map(v => v.replace(/\d+$/, '').trim())
    .filter(v => v && !v.startsWith('-'));
  return { lema, variants };
}

/**
 * Consulta el Diccionari Normatiu Valencià a través del portal lexicval de l'AVL.
 */
export async function consultarDnv(paraula: string): Promise<DnvResult> {
  const termeClean = paraula.trim().toLowerCase();
  const searchUrl = `${process.env.AVL_BASE_URL || 'https://www.avl.gva.es'}/lexicval/?paraula=${encodeURIComponent(termeClean)}`;

  try {
    const response = await fetch(searchUrl, {
      method: 'GET',
      headers: {
        'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
        'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'Accept-Language': 'ca,es;q=0.9,en;q=0.8',
        'Cache-Control': 'no-cache',
      },
    });

    // Un error de l'AVL no vol dir que la paraula no existisca: es propaga (la ferramenta torna isError i no es guarda).
    if (!response.ok) throw new Error(`El DNV ha respost ${response.status}`);

    const html = await response.text();
    const $ = cheerio.load(html);

    // 1. Comprovació de missatge d'error o no coincidència
    const textComplet = $('body').text();
    const noTrobat =
      textComplet.includes("No s'ha trobat cap entrada") ||
      textComplet.includes('No hi ha resultats') ||
      textComplet.includes('sense coincidències');

    // 2. Extracció de la categoria gramatical (ex: "m.", "f.", "v. tr.", "adj.")
    let categoria: string | undefined = $(
      '.categoria, .cat, span.categoria, .abreviatura, abbr'
    )
      .first()
      .text()
      .trim();

    if (!categoria || categoria.length === 0) {
      categoria = undefined;
    }

    // 3. Extracció de les accepcions / definicions
    const definicions: string[] = [];

    // Selectors típics de les accepcions al lexicval
    const nodesDef = $('.definicio, .acepcio, .def, p.acepcio, div.acepcio, li.acepcio');

    if (nodesDef.length > 0) {
      nodesDef.each((_i: number, el: Element) => {
        const text = $(el)
          .text()
          .replace(/\s+/g, ' ')
          .replace(/^[\d\.\s\-\)]+/, '') // Neteja la numeració inicial (ex: "1. ", "2.- ")
          .trim();

        if (text && text.length > 3) {
          definicions.push(text);
        }
      });
    }

    // 4. Verificació d'existència:
    // Comprovem si hi ha elements de lema, transcripció fonètica o definicions trobades
    const teLema = $('.lema, span.lema, strong.lema, .trfonetica').length > 0;
    const existeix = !noTrobat && (teLema || definicions.length > 0);

    // El portal torna l'entrada més pròxima encara que la paraula no hi siga: es compara el lema i les variants
    // que admet amb la paraula consultada.
    const encapcalament = $('.lema, span.lema, strong.lema').first().text().trim();
    const { lema, variants } = encapcalament ? formesDelLema(encapcalament) : { lema: undefined, variants: [] };
    const exacta = lema ? [lema, ...variants].some(forma => forma.toLowerCase() === termeClean) : undefined;

    if (!existeix) {
      return {
        existeix: false,
        url: searchUrl,
      };
    }

    return {
      existeix: true,
      exacta,
      lema,
      variants,
      categoria,
      definicions: definicions.slice(0, 5),
      url: searchUrl,
    };
  } catch (error: unknown) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    console.error(`[dnvClient] Error consultant "${paraula}":`, errorMsg);
    throw new Error(`No s'ha pogut consultar el DNV: ${errorMsg}`);
  }
}
