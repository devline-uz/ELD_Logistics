/**
 * SI ↔ imperial birlik konvertatsiyasi va formatlash — yagona manba
 * (fe-design-system §11, TZ §12.3 F196–F200).
 *
 * Backend **hech qanday konvertatsiya qilmaydi** — hamma narsani SI da
 * qaytaradi: masofa metrda (`odometer_m`, `distance_m`), tezlik km/h da
 * (backendning "metrik" asosiy birligi), harorat Celsius da, hajm litrda,
 * og'irlik kg da. Barcha konvertatsiya shu faylda, ikki tomonlama:
 * - `format*` — ko'rsatish uchun (SI → tanlangan tizim, yorliq bilan);
 * - `parse*` — kiritish uchun (tanlangan tizimdagi qiymat → SI, API'ga
 *   yuborishdan oldin, F198).
 *
 * Yaxlitlash (F197): masofa 1 xona, tezlik 0 xona, harorat 0 xona. Hajm va
 * og'irlik uchun TZ aniq son bermagan — mos ravishda masofa va tezlikka
 * o'xshatib 1 xona / 0 xona qabul qilindi (izoh: hisobotda qayd etilgan
 * ochiq qaror).
 */

/** `GET /me` → `company.unit_system`. */
export type UnitSystem = 'metric' | 'imperial';

/** Masofa: metr / mil formulasi (F196 jadvali). */
const METERS_PER_MILE = 1609.344;
/** Tezlik: km/h / mph formulasi. */
const KMH_PER_MPH = 1.609344;
/** Hajm: litr / gallon (US) formulasi. */
const LITERS_PER_GALLON = 3.785411784;
/** Og'irlik: kg / funt formulasi. */
const LB_PER_KG = 2.20462262;

type Num = number | null | undefined;

function isValidNumber(value: Num): value is number {
  return typeof value === 'number' && Number.isFinite(value);
}

function round(value: number, decimals: number): number {
  const factor = 10 ** decimals;
  return Math.round(value * factor) / factor;
}

function formatNumber(value: number, decimals: number): string {
  return value.toLocaleString('en-US', {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  });
}

/* ------------------------------------------------------------------ *
 * Masofa (backend: metr)
 * ------------------------------------------------------------------ */

/** Metrni tanlangan tizimga mos songa aylantiradi (yaxlitlashsiz, ichki foydalanish uchun). */
export function convertDistance(meters: number, unitSystem: UnitSystem): number {
  return unitSystem === 'imperial' ? meters / METERS_PER_MILE : meters / 1000;
}

/** Masofa — masalan `120.5 mi` yoki `193.9 km`. `null`/`undefined`/`NaN` → `N/A`. */
export function formatDistance(meters: Num, unitSystem: UnitSystem = 'metric'): string {
  if (!isValidNumber(meters)) return 'N/A';
  const value = round(convertDistance(meters, unitSystem), 1);
  const label = unitSystem === 'imperial' ? 'mi' : 'km';
  return `${formatNumber(value, 1)} ${label}`;
}

/**
 * Kiritilgan masofani (foydalanuvchi tizimida) SI'ga (metr) aylantiradi —
 * API'ga yuborishdan oldin (F198). Yaroqsiz kirish → `null`.
 */
export function parseDistance(value: Num, unitSystem: UnitSystem = 'metric'): number | null {
  if (!isValidNumber(value)) return null;
  return unitSystem === 'imperial' ? value * METERS_PER_MILE : value * 1000;
}

/* ------------------------------------------------------------------ *
 * Tezlik (backend: km/h)
 * ------------------------------------------------------------------ */

export function convertSpeed(kmh: number, unitSystem: UnitSystem): number {
  return unitSystem === 'imperial' ? kmh / KMH_PER_MPH : kmh;
}

/** Tezlik — masalan `62 mph` yoki `100 km/h`. */
export function formatSpeed(kmh: Num, unitSystem: UnitSystem = 'metric'): string {
  if (!isValidNumber(kmh)) return 'N/A';
  const value = round(convertSpeed(kmh, unitSystem), 0);
  const label = unitSystem === 'imperial' ? 'mph' : 'km/h';
  return `${formatNumber(value, 0)} ${label}`;
}

/** Kiritilgan tezlikni SI'ga (km/h) aylantiradi. */
export function parseSpeed(value: Num, unitSystem: UnitSystem = 'metric'): number | null {
  if (!isValidNumber(value)) return null;
  return unitSystem === 'imperial' ? value * KMH_PER_MPH : value;
}

/* ------------------------------------------------------------------ *
 * Harorat (backend: Celsius)
 * ------------------------------------------------------------------ */

export function convertTemperature(celsius: number, unitSystem: UnitSystem): number {
  return unitSystem === 'imperial' ? (celsius * 9) / 5 + 32 : celsius;
}

/** Harorat — masalan `98 °F` yoki `37 °C`. */
export function formatTemperature(celsius: Num, unitSystem: UnitSystem = 'metric'): string {
  if (!isValidNumber(celsius)) return 'N/A';
  const value = round(convertTemperature(celsius, unitSystem), 0);
  const label = unitSystem === 'imperial' ? '°F' : '°C';
  return `${formatNumber(value, 0)} ${label}`;
}

/** Kiritilgan haroratni SI'ga (Celsius) aylantiradi. */
export function parseTemperature(value: Num, unitSystem: UnitSystem = 'metric'): number | null {
  if (!isValidNumber(value)) return null;
  return unitSystem === 'imperial' ? ((value - 32) * 5) / 9 : value;
}

/* ------------------------------------------------------------------ *
 * Hajm — yoqilg'i (backend: litr)
 * ------------------------------------------------------------------ */

export function convertVolume(liters: number, unitSystem: UnitSystem): number {
  return unitSystem === 'imperial' ? liters / LITERS_PER_GALLON : liters;
}

/** Hajm — masalan `52.8 gal` yoki `200.0 L`. */
export function formatVolume(liters: Num, unitSystem: UnitSystem = 'metric'): string {
  if (!isValidNumber(liters)) return 'N/A';
  const value = round(convertVolume(liters, unitSystem), 1);
  const label = unitSystem === 'imperial' ? 'gal' : 'L';
  return `${formatNumber(value, 1)} ${label}`;
}

/** Kiritilgan hajmni SI'ga (litr) aylantiradi. */
export function parseVolume(value: Num, unitSystem: UnitSystem = 'metric'): number | null {
  if (!isValidNumber(value)) return null;
  return unitSystem === 'imperial' ? value * LITERS_PER_GALLON : value;
}

/* ------------------------------------------------------------------ *
 * Og'irlik (backend: kg)
 * ------------------------------------------------------------------ */

export function convertWeight(kg: number, unitSystem: UnitSystem): number {
  return unitSystem === 'imperial' ? kg * LB_PER_KG : kg;
}

/** Og'irlik — masalan `4409 lb` yoki `2000 kg`. */
export function formatWeight(kg: Num, unitSystem: UnitSystem = 'metric'): string {
  if (!isValidNumber(kg)) return 'N/A';
  const value = round(convertWeight(kg, unitSystem), 0);
  const label = unitSystem === 'imperial' ? 'lb' : 'kg';
  return `${formatNumber(value, 0)} ${label}`;
}

/** Kiritilgan og'irlikni SI'ga (kg) aylantiradi. */
export function parseWeight(value: Num, unitSystem: UnitSystem = 'metric'): number | null {
  if (!isValidNumber(value)) return null;
  return unitSystem === 'imperial' ? value / LB_PER_KG : value;
}
