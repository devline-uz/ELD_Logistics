/**
 * i18n sozlamasi (fe-design-system §9).
 *
 * MVP — faqat `en`. Til aniqlash (`i18next-browser-languagedetector`) ataylab
 * ulanmagan: boshqa til qo'shilganda CR bilan kiritiladi. Kalit tuzilishi:
 * `<modul>.<ekran>.<element>`; barcha backend `enum` qiymatlari `enums.*` da.
 *
 * Resurslar ikki manbadan chuqur birlashtiriladi (parallel ishlaydigan
 * agentlar bitta faylga yozmasligi uchun):
 *   1. `src/locales/en.json` — umumiy baza (`common.*`, `errors.*`, `nav.*`, `enums.*`);
 *   2. `src/locales/en/<modul>.json` — modul fragmentlari, avtomatik yuklanadi.
 * Bitta to'liq kalit ikkala manbada bo'lsa — dev'da `console.warn`.
 */

import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

import en from '@/locales/en.json';

export const defaultNS = 'translation';

/** Rekursiv i18n resurs daraxti (barg — matn). */
export interface LocaleResource {
  [key: string]: string | LocaleResource;
}

export interface MergeLocaleResult {
  /** Chuqur birlashtirilgan resurs daraxti. */
  resources: LocaleResource;
  /** Ikki manbada takrorlangan to'liq kalitlar: `"<manba>: <kalit>"`. */
  conflicts: string[];
}

const isPlainObject = (value: unknown): value is LocaleResource =>
  typeof value === 'object' && value !== null && !Array.isArray(value);

function mergeInto(
  target: LocaleResource,
  source: LocaleResource,
  origin: string,
  prefix: string,
  conflicts: string[],
): void {
  for (const [key, value] of Object.entries(source)) {
    const path = prefix ? `${prefix}.${key}` : key;
    const existing = target[key];

    if (isPlainObject(value) && isPlainObject(existing)) {
      const next: LocaleResource = { ...existing };
      target[key] = next;
      mergeInto(next, value, origin, path, conflicts);
      continue;
    }

    if (existing !== undefined) {
      conflicts.push(`${origin}: ${path}`);
    }
    target[key] = isPlainObject(value) ? { ...value } : value;
  }
}

/**
 * Bazani modul fragmentlari bilan chuqur birlashtiradi. Sof funksiya:
 * kirish obyektlari o'zgartirilmaydi, to'qnashuvlar ro'yxati qaytariladi.
 */
export function mergeLocaleResources(
  base: LocaleResource,
  modules: Readonly<Record<string, LocaleResource>>,
): MergeLocaleResult {
  const resources: LocaleResource = {};
  const conflicts: string[] = [];

  mergeInto(resources, base, 'base', '', conflicts);
  for (const name of Object.keys(modules).sort()) {
    mergeInto(resources, modules[name] as LocaleResource, name, '', conflicts);
  }

  return { resources, conflicts };
}

/** `src/locales/en/*.json` — papka bo'sh bo'lsa bo'sh obyekt qaytadi. */
const moduleFiles = import.meta.glob<{ default: LocaleResource }>('../locales/en/*.json', {
  eager: true,
});

const moduleResources: Record<string, LocaleResource> = Object.fromEntries(
  Object.entries(moduleFiles).map(([path, mod]) => [path, mod.default]),
);

const { resources: enResources, conflicts } = mergeLocaleResources(
  en as unknown as LocaleResource,
  moduleResources,
);

if (import.meta.env.DEV && conflicts.length > 0) {
  console.warn(`[i18n] duplicate keys between en.json and en/*.json:\n${conflicts.join('\n')}`);
}

/** Birlashtirilgan `en` daraxti — qamrov testlari shu manbadan foydalanadi. */
export { enResources };

export const resources = {
  en: { translation: enResources },
};

if (!i18n.isInitialized) {
  void i18n.use(initReactI18next).init({
    resources,
    lng: 'en',
    fallbackLng: 'en',
    defaultNS,
    interpolation: { escapeValue: false },
    returnNull: false,
    // Kalit topilmasa dev'da darhol ko'rinadi; CI (`i18n:extract`) ham tekshiradi.
    saveMissing: false,
    parseMissingKeyHandler: (key) => key,
  });
}

export default i18n;
