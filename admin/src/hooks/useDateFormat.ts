/**
 * `lib/format.ts` ni kompaniya `timezone` va `regulation_profile` iga bog'laydi
 * (F193/F192).
 *
 * Komponentlar `lib/format.ts` ni bevosita chaqirish o'rniga shu hook orqali
 * ishlatadi — `timezone`/`regulationProfile` ni har joyda qo'lda uzatish
 * shart emas.
 */
import { useMemo } from 'react';

import {
  formatDate,
  formatDateRange,
  formatDateTime,
  formatDateWithWeekday,
  formatDuration,
  formatRelative,
  formatTime,
  formatTimezoneAbbreviation,
  formatWeekday,
  type DurationFormatOptions,
} from '@/lib/format';
import { useCompanyStore } from '@/store/company-store';

type Iso = string | Date | null | undefined;

export interface UseDateFormatResult {
  timezone: string;
  regulationProfile: string;
  formatDate: (value: Iso) => string;
  formatTime: (value: Iso) => string;
  formatDateTime: (value: Iso) => string;
  formatWeekday: (value: Iso) => string;
  formatDateWithWeekday: (value: Iso) => string;
  formatTimezoneAbbreviation: (value: Iso) => string;
  formatDateRange: (start: Iso, end: Iso) => string;
  formatDuration: (value: number | null | undefined, options?: DurationFormatOptions) => string;
  formatRelative: (value: Iso, now?: Date) => string;
}

/** Company store'dagi `timezone` + `regulation_profile` ga bog'langan format funksiyalari. */
export function useDateFormat(): UseDateFormatResult {
  const timezone = useCompanyStore((state) => state.company.timezone);
  const regulationProfile = useCompanyStore((state) => state.company.regulationProfile);

  return useMemo(() => {
    const options = { timezone, regulationProfile };
    return {
      timezone,
      regulationProfile,
      formatDate: (value) => formatDate(value, options),
      formatTime: (value) => formatTime(value, options),
      formatDateTime: (value) => formatDateTime(value, options),
      formatWeekday: (value) => formatWeekday(value, options),
      formatDateWithWeekday: (value) => formatDateWithWeekday(value, options),
      formatTimezoneAbbreviation: (value) => formatTimezoneAbbreviation(value, options),
      formatDateRange: (start, end) => formatDateRange(start, end, options),
      formatDuration: (value, durationOptions) => formatDuration(value, durationOptions),
      formatRelative: (value, now) => formatRelative(value, { ...options, now }),
    };
  }, [timezone, regulationProfile]);
}
