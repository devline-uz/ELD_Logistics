/**
 * `ui/**` komponentlari uchun alohida i18n bo'lagi (namespace).
 *
 * Umumiy `src/locales/en.json` va `src/app/i18n.ts` bu agent tomonidan
 * tahrirlanmaydi (fayl egaligi) — shu sabab bo'lak o'z resursini shu yerda
 * `i18next` instansiyasiga qo'shadi (`addResourceBundle`). Bosh sessiya
 * xohlasa buni keyinchalik markaziy joyga ko'chirishi mumkin.
 */
import { useTranslation } from 'react-i18next';

import i18n from '@/app/i18n';
import uiForm from '@/locales/en/ui-form.json';

export const UI_FORM_NS = 'ui-form';

if (!i18n.hasResourceBundle('en', UI_FORM_NS)) {
  i18n.addResourceBundle('en', UI_FORM_NS, uiForm, true, true);
}

export function useUiFormTranslation() {
  return useTranslation(UI_FORM_NS);
}
