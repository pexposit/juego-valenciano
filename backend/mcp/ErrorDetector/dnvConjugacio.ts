import * as cheerio from 'cheerio';
import type { Element } from 'domhandler';

export interface ConjugacioResult {
  existeix: boolean;
  // mode -> temps -> formes (6 persones; en l'imperatiu la 1a és buida)
  modes?: Record<string, Record<string, string[]>>;
  observacions?: string[];
  url: string;
}

const AVL_BASE = 'https://www.avl.gva.es';
const USER_AGENT =
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

/**
 * Obté la conjugació d'un verb del DNV. El lexicval no té URL directa per a la
 * conjugació: el botó "Conjugació" fa un postback AJAX de PrimeFaces, així que
 * el reproduïm amb el ViewState i la sessió (jsessionid a l'action del formulari).
 */
export async function consultarConjugacio(verb: string): Promise<ConjugacioResult> {
  const termeClean = verb.trim().toLowerCase();
  const searchUrl = `${AVL_BASE}/lexicval/?paraula=${encodeURIComponent(termeClean)}`;

  try {
    // 1. Carreguem l'entrada per obtindre la sessió i el ViewState
    const response = await fetch(searchUrl, {
      method: 'GET',
      headers: {
        'User-Agent': USER_AGENT,
        'Accept-Language': 'ca,es;q=0.9,en;q=0.8',
      },
    });

    // Un error de l'AVL no vol dir que el verb no existisca: es propaga (la ferramenta torna isError i no es guarda).
    if (!response.ok) throw new Error(`El DNV ha respost ${response.status}`);

    const html = await response.text();
    const $ = cheerio.load(html);

    const viewState = $('input[name="javax.faces.ViewState"]').first().val();
    const action = $('form#DnvWeb').attr('action');
    // L'id del botó el genera JSF (ara "j_idt103"), el busquem per l'etiqueta
    const botoId = html.match(
      /SelectBooleanButton","widget_(\w+)",\{[^}]*offLabel:"Conjugació"/
    )?.[1];

    // Sense botó de conjugació: no és un verb o la paraula no existix
    if (typeof viewState !== 'string' || !action || !botoId) {
      return { existeix: false, url: searchUrl };
    }

    // 2. Reproduïm el clic al botó "Conjugació"
    const body = new URLSearchParams({
      'javax.faces.partial.ajax': 'true',
      'javax.faces.source': botoId,
      'javax.faces.partial.execute': botoId,
      'javax.faces.partial.render': 'contenido',
      'javax.faces.behavior.event': 'change',
      'javax.faces.partial.event': 'change',
      DnvWeb: 'DnvWeb',
      [`${botoId}_input`]: 'on',
      'javax.faces.ViewState': viewState,
    });

    const ajaxResponse = await fetch(new URL(action, AVL_BASE), {
      method: 'POST',
      headers: {
        'User-Agent': USER_AGENT,
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'Faces-Request': 'partial/ajax',
        'X-Requested-With': 'XMLHttpRequest',
      },
      body,
    });

    if (!ajaxResponse.ok) throw new Error(`El DNV ha respost ${ajaxResponse.status}`);

    const xml = await ajaxResponse.text();
    const contingut = xml.match(
      /<update id="contenido"><!\[CDATA\[([\s\S]*?)\]\]><\/update>/
    )?.[1];

    if (!contingut) {
      return { existeix: false, url: searchUrl };
    }

    // 3. Parsegem la taula: files amb td.modo (capçalera) i files de cel·les amb
    // span.tiempo (nom del temps) seguit de span.forma (una per persona)
    const $c = cheerio.load(contingut);
    const neteja = (text: string) => text.replace(/\s+/g, ' ').trim();
    const modes: Record<string, Record<string, string[]>> = {};
    let modesColumnes: string[] = [];

    $c('table.conj tr').each((_i: number, tr: Element) => {
      const capcaleres = $c(tr).find('td.modo');
      if (capcaleres.length > 0) {
        modesColumnes = capcaleres.map((_j: number, td: Element) => neteja($c(td).text())).get();
        return;
      }

      $c(tr)
        .children('td')
        .each((j: number, td: Element) => {
          // Una sola capçalera (colspan) s'aplica a totes les columnes
          const mode = modesColumnes[j] ?? modesColumnes[0];
          if (!mode) return;
          modes[mode] ??= {};

          // Participi i imperatiu no porten span.tiempo
          let temps = 'formes';
          $c(td)
            .find('span.tiempo, span.forma')
            .each((_k: number, span: Element) => {
              const text = neteja($c(span).text());
              if ($c(span).hasClass('tiempo')) {
                temps = text;
              } else {
                (modes[mode][temps] ??= []).push(text);
              }
            });
        });
    });

    const observacions = $c('li')
      .map((_i: number, li: Element) => neteja($c(li).text()))
      .get()
      .filter((text: string) => text.length > 0);

    if (Object.keys(modes).length === 0) {
      return { existeix: false, url: searchUrl };
    }

    return {
      existeix: true,
      modes,
      observacions,
      url: searchUrl,
    };
  } catch (error: unknown) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    console.error(`[dnvClient] Error consultant la conjugació de "${verb}":`, errorMsg);
    throw new Error(`No s'ha pogut consultar la conjugació al DNV: ${errorMsg}`);
  }
}
