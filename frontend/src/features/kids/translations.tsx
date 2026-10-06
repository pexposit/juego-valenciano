import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import { phraseText } from './sound';

/**
 * Subtítols del Nivell 0 en la llengua materna: davall del text en valencià es veu la
 * traducció de les consignes i explicacions (el vocabulari que s'aprén no es tradueix).
 * Només si el perfil té la llengua materna activada. Cada llengua és un JSON propi
 * (i18n/<llengua>.json, el genera backend/scripts/generate-kids-translations.ts) que
 * es carrega només quan cal.
 */

type Entry = { ca: string; t: string };
const FILES = import.meta.glob<Record<string, Entry>>('./i18n/*.json', { import: 'default' });

type Translate = (key: string) => string | undefined;
const TranslationContext = createContext<{ translate: Translate; lang: string | null }>({ translate: () => undefined, lang: null });

export function KidsTranslationProvider({ lang, children }: { lang: string | null; children: ReactNode }) {
  const [entries, setEntries] = useState<Record<string, Entry>>({});

  useEffect(() => {
    setEntries({});
    const load = lang ? FILES[`./i18n/${lang}.json`] : undefined;
    if (!load) return;
    let cancelled = false;
    load()
      .then(data => { if (!cancelled) setEntries(data); })
      .catch(error => console.error('Error carregant les traduccions:', error));
    return () => { cancelled = true; };
  }, [lang]);

  // Si la frase en valencià ha canviat des que es va traduir, no es mostra la traducció antiga.
  const translate: Translate = key => {
    const entry = entries[key];
    return entry && entry.ca === phraseText(key) ? entry.t : undefined;
  };
  return <TranslationContext.Provider value={{ translate, lang }}>{children}</TranslationContext.Provider>;
}

/** La llengua materna dels subtítols, o null si no estan activats. */
export const useKidsTranslationLang = () => useContext(TranslationContext).lang;

/** Torna la traducció d'una frase (per clau d'àudio), o undefined. */
export const useKidsTranslation = () => useContext(TranslationContext).translate;

/** El text en la llengua materna, en lletra més xicoteta i d'un altre color, davall del valencià. */
export function Translation({ text, className = '' }: { text?: string; className?: string }) {
  const { lang } = useContext(TranslationContext);
  if (!text) return null;
  return <span className={`kid-translation ${className}`} lang={lang ?? undefined}>{text}</span>;
}
