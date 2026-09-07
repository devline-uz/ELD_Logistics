/**
 * `data/**` va `form/**` (1.9–1.13, 1.15) komponentlari uchun alohida i18n
 * bo'lagi (namespace) — xuddi `components/ui/i18n.ts` dagi naqsh bilan bir xil.
 *
 * Umumiy `src/locales/en.json` va `src/app/i18n.ts` bu agent tomonidan
 * tahrirlanmaydi (fayl egaligi) — shu sabab bo'lak o'z resursini shu yerda
 * `i18next` instansiyasiga qo'shadi (`addResourceBundle`). Bosh sessiya
 * xohlasa buni keyinchalik markaziy joyga ko'chirishi mumkin.
 */
import { useTranslation } from 'react-i18next';

import i18n from '@/app/i18n';
import uiData from '@/locales/en/ui-data.json';

export const UI_DATA_NS = 'ui-data';

if (!i18n.hasResourceBundle('en', UI_DATA_NS)) {
  i18n.addResourceBundle('en', UI_DATA_NS, uiData, true, true);
}

export function useUiDataTranslation() {
  return useTranslation(UI_DATA_NS);
}
