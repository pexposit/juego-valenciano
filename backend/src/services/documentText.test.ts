import { describe, expect, it } from 'vitest';
import { strToU8, zipSync } from 'fflate';
import { TEACHER_DOCUMENT_MAX_BYTES } from '@parlaval/shared';
import { DocumentError, docxToText, extractDocument } from './documentText.js';

const bytes = (text: string) => new TextEncoder().encode(text);

const docx = (paragraphs: string[]) => zipSync({
  '[Content_Types].xml': strToU8('<Types/>'),
  'word/document.xml': strToU8(
    `<?xml version="1.0"?><w:document><w:body>${paragraphs.map(p => `<w:p><w:r><w:t xml:space="preserve">${p}</w:t></w:r></w:p>`).join('')}</w:body></w:document>`,
  ),
});

const pdf = (text: string) => bytes(`%PDF-1.4
1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj
2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj
3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 400 100]/Contents 4 0 R/Resources<</Font<</F1 5 0 R>>>>>>endobj
4 0 obj<</Length 80>>stream
BT /F1 12 Tf 10 50 Td (${text}) Tj ET
endstream endobj
5 0 obj<</Type/Font/Subtype/Type1/BaseFont/Helvetica>>endobj
trailer<</Root 1 0 R/Size 6>>
%%EOF`);

describe('extractDocument', () => {
  it('llig text pla i Markdown', async () => {
    const result = await extractDocument('temari.md', bytes('# Tema 1\n\nEls pronoms febles   en valencià.\n\n\n\nTema 2'));
    expect(result.text).toBe('# Tema 1\n\nEls pronoms febles en valencià.\n\nTema 2');
    expect(result.truncated).toBe(false);
  });

  it('llig un Word: un paràgraf per línia i entitats decodificades', async () => {
    const result = await extractDocument('examen.docx', docx(['Pregunta 1: «ca» &amp; «sa»', 'Pregunta 2: accents']));
    expect(result.text).toBe('Pregunta 1: «ca» & «sa»\nPregunta 2: accents');
  });

  it('llig un PDF amb text', async () => {
    const result = await extractDocument('examen.pdf', pdf('Pronoms febles del valencia'));
    expect(result.text).toContain('Pronoms febles del valencia');
  });

  it('llig un PDF que arriba com a Buffer de Node (així arriba des del base64 de la ruta)', async () => {
    // pdf.js rebutja el Buffer: regressió d'un PDF real que fallava en pujar-lo.
    const buffer = Buffer.from(Buffer.from(pdf('Pronoms febles del valencia')).toString('base64'), 'base64');
    expect(Buffer.isBuffer(buffer)).toBe(true);
    const result = await extractDocument('examen.pdf', buffer);
    expect(result.text).toContain('Pronoms febles del valencia');
  });

  it('el PDF original no es modifica en llegir-lo', async () => {
    const data = pdf('Pronoms febles del valencia');
    const before = Buffer.from(data).toString('hex');
    await extractDocument('examen.pdf', data);
    expect(Buffer.from(data).toString('hex')).toBe(before);
  });

  it('retalla el text llarg i ho indica', async () => {
    const result = await extractDocument('llarg.txt', bytes('paraula '.repeat(100)), 50);
    expect(result.truncated).toBe(true);
    expect(result.text).toHaveLength(50);
    expect(result.chars).toBe(50);
  });

  it.each([
    ['imatge.png', bytes('x'.repeat(100))],
    ['vell.doc', bytes('x'.repeat(100))],
  ])('rebutja el tipus no admés «%s»', async (name, data) => {
    await expect(extractDocument(name, data)).rejects.toBeInstanceOf(DocumentError);
  });

  it('rebutja un document buit o sense text', async () => {
    await expect(extractDocument('a.txt', new Uint8Array())).rejects.toThrow('buit');
    await expect(extractDocument('a.txt', bytes('  \n  '))).rejects.toThrow('No he trobat text');
    await expect(extractDocument('a.pdf', pdf(''))).rejects.toBeInstanceOf(DocumentError);
  });

  it('rebutja un document massa gran', async () => {
    await expect(extractDocument('gran.txt', new Uint8Array(TEACHER_DOCUMENT_MAX_BYTES + 1))).rejects.toThrow('pesa massa');
  });

  it('rebutja fitxers danyats', async () => {
    await expect(extractDocument('roig.docx', bytes('no sóc un zip'))).rejects.toBeInstanceOf(DocumentError);
    await expect(extractDocument('roig.pdf', bytes('no sóc un pdf'))).rejects.toBeInstanceOf(DocumentError);
  });
});

describe('docxToText', () => {
  it('respecta tabuladors i salts de línia', () => {
    const data = zipSync({ 'word/document.xml': strToU8('<w:p><w:r><w:t>a</w:t><w:tab/><w:t>b</w:t><w:br/><w:t>c</w:t></w:r></w:p>') });
    expect(docxToText(data)).toBe('a\tb\nc\n');
  });
});
