/**
 * Lliçó de frases habituals amb pictogrames
 * =========================================
 * Frases bàsiques en valencià per a xiquets, il·lustrades amb els pictogrames d'ARASAAC
 * (https://arasaac.org, llicència CC BY-NC-SA; vegeu pictograms.ts): cada frase es veu com
 * una fila de dibuixos (un per paraula) amb el seu text, i la Taronjeta les diu en veu alta.
 * Només es mostren les frases: no hi ha jocs.
 *
 * Com lessons.ts, és només dades: les frases es registren amb p() en carregar el mòdul i els
 * scripts en generen l'àudio i les traduccions.
 */
import { p, sentences, type Lesson } from './lessonKit';
import { pictogramUrl } from './pictograms';

const img = pictogramUrl;

const FRASES_PICTOGRAMES: Lesson = {
  id: 'frases-pictogrames', title: 'Frases amb pictogrames', summary: 'Les frases de cada dia, amb dibuixos.', emoji: '🖼️', color: '#DDEBFF',
  say: p('Frases amb pictogrames!'), category: 'pictogrames',
  pages: [
    sentences('Per a saludar i dir adéu, diem:', [
      ['Hola!', [['hola', img('hola')]]],
      ['Bon dia!', [['bon dia', img('bon dia')]]],
      ['Bona nit!', [['bona nit', img('bona nit')]]],
      ['Adéu!', [['adéu', img('adéu')]]],
    ]),
    sentences('Quan necessitem alguna cosa, diem:', [
      ['Tinc fam.', [['tinc fam', img('fam')]]],
      ['Tinc set.', [['tinc set', img('set')]]],
      ['Vull menjar.', [['vull', img('voler')], ['menjar', img('menjar')]]],
      ['Vull aigua.', [['vull', img('voler')], ['aigua', img('aigua')]]],
    ]),
    sentences('Per a dir com estem, diem:', [
      ['Estic content.', [['estic', img('jo')], ['content', img('content')]]],
      ['Estic trist.', [['estic', img('jo')], ['trist', img('trist')]]],
    ]),
    sentences('Per a dir el que volem fer, diem:', [
      ['Vull jugar.', [['vull', img('voler')], ['jugar', img('jugar')]]],
      ['Vull dormir.', [['vull', img('voler')], ['dormir', img('dormir')]]],
      ['Vull llegir.', [['vull', img('voler')], ['llegir', img('llegir')]]],
      ['Vull pintar.', [['vull', img('voler')], ['pintar', img('pintar')]]],
      ['Vull cantar.', [['vull', img('voler')], ['cantar', img('cantar')]]],
    ]),
    sentences('Per a dir on anem i què ens agrada, diem:', [
      ["Vaig a l'escola.", [['vaig', img('anar')], ["a l'escola", img('escola')]]],
      ['Vaig a casa.', [['vaig', img('anar')], ['a casa', img('casa')]]],
      ["M'agrada la pilota.", [["m'agrada", img('agradar')], ['la pilota', img('pilota')]]],
    ]),
    sentences('I no ens oblidem de les paraules màgiques!', [
      ['Per favor.', [['per favor', img('si us plau')]]],
      ['Gràcies!', [['gràcies', img('gràcies')]]],
      ["Ajuda'm, per favor.", [["ajuda'm", img('ajudar')], ['per favor', img('si us plau')]]],
    ]),
  ],
};

export const PICTOGRAM_LESSONS: Lesson[] = [FRASES_PICTOGRAMES];
