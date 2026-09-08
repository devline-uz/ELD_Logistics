/**
 * HOS Policy — soat:daqiqa ↔ daqiqa konvertatsiyasi (8.4, F146,
 * `docs/tz/07-13-settings-admin.md` §7.13.3).
 *
 * Backendga barcha vaqt parametrlari **daqiqada** yuboriladi
 * (`HosPolicyDoc.*_min`), lekin UI'da `soat:daqiqa` ko'rinishida kiritiladi.
 * Bu yerdagi funksiyalar sof (side-effect'siz) — `DurationField` va
 * `HosPolicyForm` ular ustida quriladi.
 *
 * **Muhim**: HOS parametrlari (masalan `cycle_limit_min` — 8 kunlik sikl,
 * 4200 daqiqa = 70 soat) 24 soatdan oshishi mumkin — soat qismi hech qachon
 * kesilmaydi (`lib/format.ts`dagi `formatDuration` bilan bir xil naqsh).
 */

export interface HmValue {
  hours: number;
  minutes: number;
}

function safeNonNegativeInt(value: number): number {
  return Number.isFinite(value) && value > 0 ? Math.trunc(value) : 0;
}

/** Daqiqalarni `{hours, minutes}` ga aylantiradi. Manfiy/NaN qiymat `0` ga tushadi. */
export function minutesToHm(totalMinutes: number): HmValue {
  const safe = safeNonNegativeInt(totalMinutes);
  return { hours: Math.floor(safe / 60), minutes: safe % 60 };
}

/**
 * `{hours, minutes}` ni daqiqaga aylantiradi. `minutes` 59 dan katta kiritilsa
 * (masalan qo'lda formaga yozilsa) ortiqchasi soatga ko'chiriladi — hech qanday
 * qiymat "yo'qolmaydi".
 */
export function hmToMinutes(value: HmValue): number {
  const hours = safeNonNegativeInt(value.hours);
  const rawMinutes = safeNonNegativeInt(value.minutes);
  const carry = Math.floor(rawMinutes / 60);
  const minutes = rawMinutes % 60;
  return (hours + carry) * 60 + minutes;
}

/** `HH:MM` ko'rinishida chiqaradi, soat qismi 2 xonadan kam bo'lmaydi (`70:00`). */
export function formatHm(totalMinutes: number): string {
  const { hours, minutes } = minutesToHm(totalMinutes);
  return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;
}
