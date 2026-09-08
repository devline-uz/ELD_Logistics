/**
 * Sana, vaqt, davomiylik va nisbiy vaqt formatlash — yagona manba (fe-design-system §10,
 * TZ §12.2 F192–F195).
 *
 * Qoidalar:
 * - Backend hamma narsani **ISO 8601 UTC** da qaytaradi (`IsoDateTime` / `IsoDate`,
 *   `src/api/types.ts`). Ko'rsatish har doim **kompaniya Home Terminal timezone**
 *   ida (`GET /me` → `company.timezone`, F193) — brauzer TZ da EMAS.
 * - Format `regulation_profile` ga bog'liq: `us_fmcsa` — AQSh uslubi
 *   (`MM/DD/YYYY`, 12 soatlik vaqt), qolgan barcha profillar (`generic`,
 *   `canada`, `texas`, `california`, `alaska`, `hawaii`) — `generic` uslubga
 *   tushiriladi (`DD/MM/YYYY`, 24 soatlik) — skill §10: «dizayndagi 6 xil
 *   variant shu 2 taga qisqartirilgan».
 * - Sana yo'q / yaroqsiz bo'lsa — bo'sh satr emas, **`N/A`** (§16).
 * - Komponentlar `date-fns`ni bevosita chaqirmaydi — faqat shu fayl orqali
 *   (F195, ESLint bilan cheklanadi).
 *
 * Timezone konvertatsiyasi `date-fns-tz` orqali, formatlash naqshlari
 * `date-fns/format` token'lari bilan yoziladi (skill §12: «Intl bilan
 * date-fns birgalikda»).
 */
import { formatInTimeZone } from 'date-fns-tz';
import { formatDistanceStrict, isValid, parseISO } from 'date-fns';

import type { IsoDateTime } from '@/api/types';
import { getCompanyContext } from '@/store/company-store';

/** Backenddan keladigan xom `regulation_profile` qiymatlari (TZ §1, schema.d.ts). */
export type RegulationProfile =
  'us_fmcsa' | 'generic' | 'canada' | 'texas' | 'california' | 'alaska' | 'hawaii';

/** Formatlash uchun qisqartirilgan profil — faqat shu ikkisi naqshni farqlaydi. */
export type DateFormatProfile = 'generic' | 'us_fmcsa';

/**
 * Bo'sh/yaroqsiz qiymat o'rniga ko'rsatiladigan matn (§16: `N/A`, `na` emas).
 *
 * **Loyiha bo'yicha yagona idioma (TD9):**
 * - React komponent yoki hook ichida — `t('common.na')` (i18n orqali);
 * - `t()` ga kirish imkoni yo'q sof funksiyalarda (`lib/*`, jadval ustunlari
 *   uchun formatlagichlar, modul tashqarisidagi helper'lar) — shu `NA`
 *   konstantasi.
 *
 * Kodda `'N/A'` literalini yozish taqiqlanadi — yuqoridagi ikki variantdan
 * biri ishlatiladi.
 */
export const NA = 'N/A';

/** `formatDate`/`formatTime`/... uchun umumiy ixtiyoriy sozlamalar. */
export interface DateFormatOptions {
  /** IANA zona nomi. Berilmasa — kompaniya store'idagi `timezone`. */
  timezone?: string;
  /**
   * Xom `regulation_profile`. Berilmasa — kompaniya store'idagi qiymat.
   * `string` — backend kelajakda yangi profil qo'shishi mumkin (F192);
   * `resolveDateFormatProfile` noma'lum qiymatlarni `generic` ga tushiradi.
   */
  regulationProfile?: string;
}

/** `IsoDateTime`/`IsoDate` ikkalasi ham `string` alias'i — bitta nom yetarli. */
type NullableIso = IsoDateTime | Date | null | undefined;

/**
 * 6 xil `regulation_profile` qiymatini formatlash uchun 2 taga qisqartiradi
 * (skill §10 / TZ F192). Faqat `us_fmcsa` AQSh naqshini oladi.
 */
export function resolveDateFormatProfile(profile: string | undefined): DateFormatProfile {
  return profile === 'us_fmcsa' ? 'us_fmcsa' : 'generic';
}

function resolveTimezone(options?: DateFormatOptions): string {
  return options?.timezone ?? getCompanyContext().timezone;
}

function resolveProfile(options?: DateFormatOptions): DateFormatProfile {
  return resolveDateFormatProfile(
    options?.regulationProfile ?? getCompanyContext().regulationProfile,
  );
}

/** Faqat sana (vaqtsiz) ISO qatori — `YYYY-MM-DD`. */
const DATE_ONLY_RE = /^\d{4}-\d{2}-\d{2}$/;

/**
 * `IsoDateTime | IsoDate | Date` ni `Date` obyektiga aylantiradi; yaroqsiz
 * bo'lsa `null`. Vaqtsiz `IsoDate` (`YYYY-MM-DD`) **UTC yarim tunga**
 * bog'lanadi — `parseISO` uni brauzer/test muhiti mahalliy zonasida talqin
 * qilib qo'ymasligi uchun (aks holda TZ ga qarab bir kun siljib ketadi).
 */
function toDate(value: NullableIso): Date | null {
  if (value === null || value === undefined || value === '') {
    return null;
  }
  if (value instanceof Date) {
    return isValid(value) ? value : null;
  }
  const date = DATE_ONLY_RE.test(value) ? parseISO(`${value}T00:00:00Z`) : parseISO(value);
  return isValid(date) ? date : null;
}

/** Sana naqshi: `generic` → `dd/MM/yyyy`, `us_fmcsa` → `MM/dd/yyyy`. */
function datePattern(profile: DateFormatProfile): string {
  return profile === 'us_fmcsa' ? 'MM/dd/yyyy' : 'dd/MM/yyyy';
}

/** Vaqt naqshi: `generic` → 24 soat, `us_fmcsa` → 12 soat + AM/PM. */
function timePattern(profile: DateFormatProfile): string {
  return profile === 'us_fmcsa' ? 'hh:mm a' : 'HH:mm';
}

/** Sana — masalan `17/12/2025` (generic) yoki `12/17/2025` (us_fmcsa). */
export function formatDate(value: NullableIso, options?: DateFormatOptions): string {
  const date = toDate(value);
  if (!date) return NA;
  return formatInTimeZone(date, resolveTimezone(options), datePattern(resolveProfile(options)));
}

/** Vaqt — masalan `14:05` (generic) yoki `02:05 PM` (us_fmcsa). */
export function formatTime(value: NullableIso, options?: DateFormatOptions): string {
  const date = toDate(value);
  if (!date) return NA;
  return formatInTimeZone(date, resolveTimezone(options), timePattern(resolveProfile(options)));
}

/** Sana + vaqt — masalan `17/12/2025 14:05` yoki `12/17/2025 02:05 PM`. */
export function formatDateTime(value: NullableIso, options?: DateFormatOptions): string {
  const date = toDate(value);
  if (!date) return NA;
  const profile = resolveProfile(options);
  return formatInTimeZone(
    date,
    resolveTimezone(options),
    `${datePattern(profile)} ${timePattern(profile)}`,
  );
}

/** Hafta kunining 3 harfli qisqartmasi — masalan `Fri` (§16 talabi). */
export function formatWeekday(value: NullableIso, options?: DateFormatOptions): string {
  const date = toDate(value);
  if (!date) return NA;
  return formatInTimeZone(date, resolveTimezone(options), 'EEE');
}

/** Sana + hafta kuni — masalan `Fri, 17/12/2025` yoki `Fri, 12/17/2025`. */
export function formatDateWithWeekday(value: NullableIso, options?: DateFormatOptions): string {
  const date = toDate(value);
  if (!date) return NA;
  const profile = resolveProfile(options);
  return formatInTimeZone(date, resolveTimezone(options), `EEE, ${datePattern(profile)}`);
}

/** Kompaniya zonasining qisqartmasi — masalan `CST` (jadval hujayrasi tooltip'i uchun, F194). */
export function formatTimezoneAbbreviation(
  value: NullableIso,
  options?: DateFormatOptions,
): string {
  const date = toDate(value);
  if (!date) return NA;
  return formatInTimeZone(date, resolveTimezone(options), 'zzz');
}

/** Sana oralig'i — masalan `17/12/2025 – 20/12/2025`. Bir tomon yo'q bo'lsa `N/A` shu tomonda. */
export function formatDateRange(
  start: NullableIso,
  end: NullableIso,
  options?: DateFormatOptions,
): string {
  return `${formatDate(start, options)} – ${formatDate(end, options)}`;
}

/** `formatDuration` uchun kiritilgan qiymat birligi. */
export type DurationUnit = 'minutes' | 'seconds';

export interface DurationFormatOptions {
  /** Kiritilgan `value` birligi (default `minutes`). */
  unit?: DurationUnit;
  /** `true` bo'lsa soniya ham chiqadi: `HH:MM:SS`. */
  withSeconds?: boolean;
}

/**
 * Davomiylik — `HH:MM` (yoki `withSeconds: true` bo'lsa `HH:MM:SS`), HOS
 * hisoblagichlari uchun (F192, F195). Soat qismi 24 dan oshsa ham
 * qisqartirilmaydi (masalan `30:15` — 30 soat 15 daqiqa). Manfiy qiymat `-`
 * belgisi bilan ko'rsatiladi. `null`/`undefined`/`NaN` — `N/A`.
 */
export function formatDuration(
  value: number | null | undefined,
  options?: DurationFormatOptions,
): string {
  if (value === null || value === undefined || Number.isNaN(value) || !Number.isFinite(value)) {
    return NA;
  }

  const unit = options?.unit ?? 'minutes';
  const withSeconds = options?.withSeconds ?? unit === 'seconds';
  const totalSeconds = Math.round(unit === 'seconds' ? value : value * 60);

  const sign = totalSeconds < 0 ? '-' : '';
  const abs = Math.abs(totalSeconds);

  const hours = Math.floor(abs / 3600);
  const minutes = Math.floor((abs % 3600) / 60);
  const seconds = abs % 60;

  const pad = (n: number): string => String(n).padStart(2, '0');

  return withSeconds
    ? `${sign}${pad(hours)}:${pad(minutes)}:${pad(seconds)}`
    : `${sign}${pad(hours)}:${pad(minutes + (seconds >= 30 ? 1 : 0))}`;
}

/** `formatRelative` bu chegaradan uzoq bo'lsa mutlaq sana+vaqtga tushadi (F192). */
export const RELATIVE_THRESHOLD_MS = 24 * 60 * 60 * 1000;

/**
 * Nisbiy vaqt — masalan `2 hours ago` (< 24 soat), aks holda mutlaq
 * `formatDateTime` ga tushadi (F192 jadvali). `now` testlarda deterministik
 * qilish uchun ixtiyoriy beriladi (default `Date.now()`).
 */
export function formatRelative(
  value: NullableIso,
  options?: DateFormatOptions & { now?: Date },
): string {
  const date = toDate(value);
  if (!date) return NA;

  const now = options?.now ?? new Date();
  const diffMs = Math.abs(now.getTime() - date.getTime());

  if (diffMs >= RELATIVE_THRESHOLD_MS) {
    return formatDateTime(value, options);
  }

  if (diffMs < 1000) {
    return 'just now';
  }

  const suffix = date.getTime() <= now.getTime() ? 'ago' : 'from now';
  return `${formatDistanceStrict(date, now, { roundingMethod: 'round' })} ${suffix}`;
}

/* ------------------------------------------------------------------ *
 * Koordinatalar
 * ------------------------------------------------------------------ */

/**
 * `first_name` + `last_name` → ko'rsatish uchun bitta ism. Ikkalasi ham bo'sh
 * bo'lsa `fallback` (standart — `N/A`, §16). Ism birlashtirish bir necha
 * ekranda takrorlanmasligi uchun yagona manba shu funksiya.
 */
export function formatPersonName(
  person: { first_name?: string | null; last_name?: string | null } | null | undefined,
  fallback: string = NA,
): string {
  const name = `${person?.first_name ?? ''} ${person?.last_name ?? ''}`.trim();
  return name || fallback;
}

/** Bitta koordinata — 7 xonali o'nlik (§16 format qoidasi, F101). */
export function formatCoordinate(value: number | null | undefined): string {
  return typeof value === 'number' && Number.isFinite(value) ? value.toFixed(7) : NA;
}

/**
 * Koordinata juftligi — `31.5200000, 74.3500000` (F101: `toFixed(7)`, vergul
 * ajratgich). Ikkalasidan biri yo'q bo'lsa — `N/A` (§16).
 */
export function formatCoordinatePair(
  lat: number | null | undefined,
  lng: number | null | undefined,
): string {
  if (
    typeof lat !== 'number' ||
    typeof lng !== 'number' ||
    !Number.isFinite(lat) ||
    !Number.isFinite(lng)
  ) {
    return NA;
  }
  return `${lat.toFixed(7)}, ${lng.toFixed(7)}`;
}

/**
 * Mahalliy kalendar sanasini `YYYY-MM-DD` qatoriga aylantiradi — API `date=`
 * parametri uchun. `toISOString().slice(0,10)` **ishlatilmaydi**: u UTC ga
 * o'tkazadi va manfiy ofsetli zonada (masalan `America/Chicago`) bir kunga
 * xato beradi.
 */
export function toDateParam(date: Date): string {
  if (!isValid(date)) return NA;
  const pad = (n: number): string => String(n).padStart(2, '0');
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
}
