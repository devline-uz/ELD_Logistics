/**
 * Ekran/nav/breadcrumb nomi `regulation_profile` ga bog'liq almashinuvi
 * (F122/F125, D27, D32).
 *
 * Backendda profil **yettita** (`us_fmcsa|generic|canada|texas|california|alaska|hawaii`),
 * lekin dizayn faqat ikkita nom variantini beradi: `us_fmcsa` uchun alohida
 * (masalan "IFTA Report" / "FMCSA Report"), qolgan oltitasi uchun "generic"
 * nom (masalan "Distance by Region" / "Regulator Export"). Bu yordamchi
 * bitta i18n kalitning ikkita pastki kaliti orasida tanlaydi.
 *
 * Umumiy qatlamda (`src/lib`) — `features/reports` ham, navigatsiya/breadcrumb
 * (`app/nav-config.ts`, `components/layout/*`) ham shu yerdan import qiladi,
 * shuning uchun `features/*` ga bog'liqlik yo'q (qatlam qoidasi buzilmaydi,
 * D32). Reports ekranlari ham to'g'ridan-to'g'ri shu fayldan import qiladi —
 * takroriy re-export qatlami yo'q (Bosqich 6.11 ko'rigi).
 *
 * Foydalanish: `useProfileLabel('reports.distanceByRegion.screenName')` →
 * `t('reports.distanceByRegion.screenName.us_fmcsa')` yoki `...generic`.
 */
import { useTranslation } from 'react-i18next';

import { useCompanyStore } from '@/store/company-store';

export type ProfileLabelBucket = 'us_fmcsa' | 'generic';

/**
 * Backend `regulation_profile` qiymatini ikkita nomlash bucketidan biriga moslaydi.
 * `us_fmcsa` — maxsus; boshqa har qanday qiymat (jumladan noma'lum/bo'sh) — `generic`.
 */
export function resolveProfileLabelBucket(
  regulationProfile: string | undefined,
): ProfileLabelBucket {
  return regulationProfile === 'us_fmcsa' ? 'us_fmcsa' : 'generic';
}

/** Joriy kompaniyaning nomlash bucketi (`GET /company` → company-store). */
export function useProfileLabelBucket(): ProfileLabelBucket {
  const regulationProfile = useCompanyStore((state) => state.company.regulationProfile);
  return resolveProfileLabelBucket(regulationProfile);
}

/**
 * `baseKey.us_fmcsa` yoki `baseKey.generic` i18n kalitini joriy kompaniya
 * `regulation_profile` iga qarab qaytaradi.
 */
export function useProfileLabel(baseKey: string): string {
  const { t } = useTranslation();
  const bucket = useProfileLabelBucket();
  return t(`${baseKey}.${bucket}`);
}
