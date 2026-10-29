import { describe, expect, it } from 'vitest';
import { detectNonValencian } from './languageGuard.js';

const valencian = (text: string) => detectNonValencian(text).valencian;

describe('detectNonValencian', () => {
  it('accepta respostes en valencià de tots els nivells', () => {
    expect(valencian('Hola! Soc la Maria. Què vols prendre?')).toBe(true);
    expect(valencian("Molt bé! Ara digues-me quin color t'agrada més.")).toBe(true);
    expect(valencian("D'acord, t'ho pose en una bossa. Són tres euros, per favor.")).toBe(true);
    expect(valencian('No sé què em vols dir. Pots repetir?')).toBe(true);
    expect(valencian("L'accent diacrític distingix paraules que s'escriuen igual: «és» (verb) i «es» (pronom).")).toBe(true);
    expect(valencian('Bon dia! Com estàs? Vols fer-lo ara o després?')).toBe(true);
    expect(valencian('Sí!')).toBe(true);
    expect(valencian('')).toBe(true);
  });

  it('no compta les paraules citades en una altra llengua', () => {
    expect(valencian('No es diu «bueno», es diu «bé». I no és «pero», és «però».')).toBe(true);
    expect(valencian('En anglés es diu "thank you very much", i en valencià «moltes gràcies».')).toBe(true);
    expect(valencian('La paraula *gat* en àrab és «قط».')).toBe(true);
    expect(valencian("Quan dius 'muy bien y tú' en valencià és «molt bé, i tu?».")).toBe(true);
  });

  it('detecta respostes en castellà', () => {
    expect(detectNonValencian('¡Hola! ¿Qué quieres tomar hoy?')).toMatchObject({ valencian: false, language: 'es' });
    expect(detectNonValencian('Muy bien, y tú, ¿cómo estás?')).toMatchObject({ valencian: false, language: 'es' });
    expect(valencian('Claro, te lo pongo en una bolsa. Son tres euros, por favor.')).toBe(false);
  });

  it('detecta les altres llengües llatines', () => {
    expect(detectNonValencian('Hello! What would you like to drink today?')).toMatchObject({ valencian: false, language: 'en' });
    expect(detectNonValencian("Bonjour ! Qu'est-ce que vous voulez boire ? C'est très bien.")).toMatchObject({ valencian: false, language: 'fr' });
    expect(detectNonValencian('Ciao! Che cosa vuoi bere? Molto bene, grazie.')).toMatchObject({ valencian: false, language: 'it' });
    expect(detectNonValencian('Bună ziua! Ce vrei să bei? Mulțumesc foarte mult.')).toMatchObject({ valencian: false, language: 'ro' });
  });

  it('detecta els alfabets no llatins (àrab, ucraïnés, xinés)', () => {
    expect(detectNonValencian('مرحبا! ماذا تريد أن تشرب؟').reasons).toContain('alfabet_no_llati');
    expect(valencian('Привіт! Що ти хочеш випити?')).toBe(false);
    expect(valencian('你好！你想喝什么？')).toBe(false);
  });

  it('accepta el valencià amb alguna paraula estrangera solta', () => {
    expect(valencian('Molt bé! En castellà diries bien, però en valencià diem bé.')).toBe(true);
  });
});
