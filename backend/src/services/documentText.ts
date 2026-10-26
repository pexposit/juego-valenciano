import { unzipSync, strFromU8 } from 'fflate';
import { extractText, getDocumentProxy } from 'unpdf';
import { TEACHER_DOCUMENT_EXTENSIONS, TEACHER_DOCUMENT_MAX_BYTES, TEACHER_DOCUMENT_MAX_STORED_CHARS } from '@parlaval/shared';

/**
 * Text d'un document que la docent adjunta (examen o temari): PDF, Word (.docx), text pla o Markdown.
 * Es fa en memòria: el fitxer no es guarda. Els errors són `DocumentError`, amb un missatge per a la docent.
 */

/** El text extret d'un document (`truncated`: passava del màxim que es conserva i s'ha retallat). */
export type ExtractedDocument = { name: string; text: string; chars: number; truncated: boolean };

export class DocumentError extends Error {}

// Màxim del text XML d'un .docx ja descomprimit (el text útil és una fracció; les imatges no es descomprimixen).
const MAX_DOCX_XML_BYTES = 60 * 1024 * 1024;

const ENTITIES: Record<string, string> = { amp: '&', lt: '<', gt: '>', quot: '"', apos: "'" };
const decodeEntities = (xml: string) =>
  xml.replace(/&(#x[0-9a-f]+|#\d+|[a-z]+);/gi, (match, code: string) => {
    if (code[0] === '#') {
      const point = code[1].toLowerCase() === 'x' ? parseInt(code.slice(2), 16) : parseInt(code.slice(1), 10);
      return Number.isFinite(point) && point > 0 && point <= 0x10ffff ? String.fromCodePoint(point) : '';
    }
    return ENTITIES[code.toLowerCase()] ?? match;
  });

/** Text de les paraules d'un .docx: cada paràgraf, una línia. */
export function docxToText(data: Uint8Array): string {
  let files: Record<string, Uint8Array>;
  try {
    // Només es descomprimix el cos del document (no imatges ni la resta).
    // (i es rebutja si, descomprimit, pesa massa: un .docx pot ser una bomba de compressió.)
    files = unzipSync(data, { filter: file => file.name === 'word/document.xml' && file.originalSize <= MAX_DOCX_XML_BYTES });
  } catch {
    throw new DocumentError("No s'ha pogut obrir el document de Word. Comprova que és un fitxer .docx.");
  }
  const xml = files['word/document.xml'];
  if (!xml) throw new DocumentError("No s'ha pogut llegir el contingut del document de Word.");
  return decodeEntities(
    strFromU8(xml)
      .replace(/<w:tab\s*\/>/g, '\t')
      .replace(/<w:(br|cr)\b[^>]*\/>/g, '\n')
      .replace(/<\/w:p>/g, '\n')
      .replace(/<[^>]+>/g, ''),
  );
}

async function pdfToText(data: Uint8Array): Promise<string> {
  try {
    // pdf.js rebutja el `Buffer` de Node (és el que arriba des del base64) i, a més, pot buidar la memòria que rep:
    // se li passa una còpia com a Uint8Array pla.
    const pdf = await getDocumentProxy(new Uint8Array(data));
    const { text } = await extractText(pdf, { mergePages: true });
    return text;
  } catch (error) {
    const reason = error instanceof Error ? `${error.name}: ${error.message}` : String(error);
    console.warn(`[documents] No s'ha pogut llegir el PDF: ${reason}`);
    if (/password/i.test(reason)) {
      throw new DocumentError('El PDF està protegit amb contrasenya. Lleva-li la protecció i torna a adjuntar-lo.');
    }
    throw new DocumentError("No s'ha pogut llegir el PDF. Comprova que no està danyat.");
  }
}

const extensionOf = (name: string) => name.toLowerCase().match(/\.[a-z0-9]+$/)?.[0] ?? '';

// Línies sense espais sobrants ni salts de línia repetits.
const tidy = (text: string) =>
  text.replace(/\r\n?/g, '\n').replace(/\u0000/g, '').replace(/[ \t]+\n/g, '\n').replace(/\n{3,}/g, '\n\n').replace(/[ \t]{2,}/g, ' ').trim();

export async function extractDocument(name: string, data: Uint8Array, maxChars = TEACHER_DOCUMENT_MAX_STORED_CHARS): Promise<ExtractedDocument> {
  const extension = extensionOf(name);
  if (!(TEACHER_DOCUMENT_EXTENSIONS as readonly string[]).includes(extension)) {
    throw new DocumentError(`Només es poden adjuntar documents ${TEACHER_DOCUMENT_EXTENSIONS.join(', ')}.`);
  }
  if (data.byteLength === 0) throw new DocumentError('El document està buit.');
  if (data.byteLength > TEACHER_DOCUMENT_MAX_BYTES) {
    throw new DocumentError(`El document pesa massa (màxim ${TEACHER_DOCUMENT_MAX_BYTES / 1024 / 1024} MB).`);
  }

  const raw = extension === '.pdf' ? await pdfToText(data) : extension === '.docx' ? docxToText(data) : new TextDecoder('utf-8').decode(data);
  const text = tidy(raw);
  if (text.length < 20) {
    throw new DocumentError(
      extension === '.pdf'
        ? "No he trobat text en el PDF. Si és un escàner (una imatge), no el puc llegir: prova amb una versió amb text o en Word."
        : 'No he trobat text en el document.',
    );
  }
  const truncated = text.length > maxChars;
  return { name, text: truncated ? text.slice(0, maxChars) : text, chars: Math.min(text.length, maxChars), truncated };
}
