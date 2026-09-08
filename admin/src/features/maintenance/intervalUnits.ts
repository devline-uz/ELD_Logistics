/**
 * Maintenance interval birliklari — kiritish/ko'rsatish konvertatsiyasi (5.8,
 * fe-design-system §11, TZ §12 F196–F198).
 *
 * **Muammo.** Backend `interval_unit` ni `km | mi | days | engine_hours`
 * enum'i sifatida saqlaydi — ya'ni masofa qiymati SI (metr) da emas, **o'zi
 * yozilgan birlikda** turadi. Ayni paytda TZ §12 barcha konvertatsiya
 * frontendda bo'lishini va foydalanuvchi o'z tizimida (metric/imperial)
 * ishlashini talab qiladi. Ikkalasini birlashtiruvchi yagona qoida shu faylda:
 *
 * - **Kiritishda** (`toApiInterval`): foydalanuvchi qiymatni o'z tizimida
 *   kiritadi; API'ga o'sha qiymat + mos `interval_unit` (`metric → km`,
 *   `imperial → mi`) yuboriladi. Qiymat aynan saqlanadi — yo'qotish yo'q.
 * - **Ko'rsatishda** (`toUserDistanceValue` / `formatIntervalValue`): saqlangan
 *   qiymat avval `parseDistance` bilan **SI (metr)** ga keltiriladi, so'ng
 *   `formatDistance`/`convertDistance` bilan foydalanuvchi tizimiga o'tkaziladi.
 *   Shu sababli `km` da saqlangan reja `imperial` foydalanuvchiga `mi` da
 *   ko'rinadi va aksincha.
 *
 * Natijada konvertatsiya **ikki tomonlama to'g'ri**: birlik tizimi o'zgarmasa
 * kiritilgan qiymat qayta ochilganda bit-ma-bit o'zgarmaydi (`km↔metric`,
 * `mi↔imperial` — `parseDistance` va `convertDistance` bir-birining teskarisi).
 *
 * `days` va `engine_hours` — birlik tizimiga bog'liq emas, konvertatsiya
 * qilinmaydi.
 */
import { convertDistance, formatDistance, parseDistance, type UnitSystem } from '@/lib/units';
import { NA } from '@/lib/format';

/** Backend `interval_unit` enum'i (`swagger.json`). */
export type IntervalUnit = 'km' | 'mi' | 'days' | 'engine_hours';

/** Formadagi tanlov: masofa birligi foydalanuvchi tizimidan kelib chiqadi. */
export type IntervalUnitChoice = 'distance' | 'days' | 'engine_hours';

export const INTERVAL_UNIT_CHOICES: readonly IntervalUnitChoice[] = [
  'distance',
  'days',
  'engine_hours',
];

/** Masofa birligimi? */
export function isDistanceUnit(unit: IntervalUnit | undefined): unit is 'km' | 'mi' {
  return unit === 'km' || unit === 'mi';
}

/** `km → metric`, `mi → imperial` — saqlangan qiymat qaysi tizimda yozilgani. */
export function unitSystemOf(unit: 'km' | 'mi'): UnitSystem {
  return unit === 'mi' ? 'imperial' : 'metric';
}

/** Foydalanuvchi tizimi uchun yoziladigan masofa birligi. */
export function distanceUnitFor(unitSystem: UnitSystem): 'km' | 'mi' {
  return unitSystem === 'imperial' ? 'mi' : 'km';
}

/** Input yonida **doim** ko'rinadigan birlik yorlig'i (fe-design-system §11). */
export function intervalUnitLabel(
  choice: IntervalUnitChoice,
  unitSystem: UnitSystem,
): IntervalUnit {
  if (choice === 'distance') return distanceUnitFor(unitSystem);
  return choice;
}

/** Saqlangan `interval_unit` → forma tanlovi. */
export function choiceOf(unit: IntervalUnit | undefined): IntervalUnitChoice {
  if (isDistanceUnit(unit)) return 'distance';
  return unit === 'engine_hours' ? 'engine_hours' : 'days';
}

/**
 * Saqlangan qiymatni foydalanuvchi tizimidagi songa aylantiradi (formada
 * ko'rsatish uchun). Masofa: `parseDistance` (saqlangan birlik) →
 * `convertDistance` (foydalanuvchi tizimi). Qolgan birliklar o'zgarmaydi.
 *
 * Yaxlitlash — 3 xonagacha: konvertatsiyada paydo bo'ladigan suzuvchi nuqta
 * dumini (`15000.000000000002`) kesadi, lekin bir xil tizimda qiymatni
 * o'zgartirmaydi.
 */
export function toUserIntervalValue(
  value: number | null | undefined,
  storedUnit: IntervalUnit | undefined,
  unitSystem: UnitSystem,
): number | null {
  if (typeof value !== 'number' || !Number.isFinite(value)) return null;
  if (!isDistanceUnit(storedUnit)) return value;

  const meters = parseDistance(value, unitSystemOf(storedUnit));
  if (meters === null) return null;
  return Math.round(convertDistance(meters, unitSystem) * 1000) / 1000;
}

/**
 * Formadagi qiymatni API konvertiga aylantiradi (F198). Masofada foydalanuvchi
 * tizimiga mos `interval_unit` yoziladi — shuning uchun qiymat o'zgarmaydi.
 */
export function toApiInterval(
  value: number,
  choice: IntervalUnitChoice,
  unitSystem: UnitSystem,
): { interval_value: number; interval_unit: IntervalUnit } {
  return { interval_value: value, interval_unit: intervalUnitLabel(choice, unitSystem) };
}

/**
 * Ko'rsatish uchun matn — masofada `formatDistance` (yorliq bilan: `25,000.0 km`),
 * `days`/`engine_hours` uchun i18n ko'plik kaliti orqali chaqiruvchi formatlaydi.
 * `null`/`undefined` → `N/A`.
 */
export function formatIntervalDistance(
  value: number | null | undefined,
  storedUnit: 'km' | 'mi',
  unitSystem: UnitSystem,
): string {
  if (typeof value !== 'number' || !Number.isFinite(value)) return NA;
  return formatDistance(parseDistance(value, unitSystemOf(storedUnit)), unitSystem);
}
