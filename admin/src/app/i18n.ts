/**
 * i18n sozlamasi (fe-design-system §9).
 *
 * MVP — faqat `en`. Til aniqlash (`i18next-browser-languagedetector`) ataylab
 * ulanmagan: boshqa til qo'shilganda CR bilan kiritiladi. Kalit tuzilishi:
 * `<modul>.<ekran>.<element>`; barcha backend `enum` qiymatlari `enums.*` da.
 */

import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

import en from '@/locales/en.json';

export const defaultNS = 'translation';

export const resources = {
  en: { translation: en },
} as const;

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
