/**
 * Xabarlar ro'yxatidagi sana ajratgichlari — `Today` / `Yesterday` /
 * hafta kuni (F130, fe-screens §10 — 3 harfli qisqartma `formatWeekday`
 * orqali). Kompaniya Home Terminal zonasida hisoblanadi (F193) — brauzer
 * zonasi ishlatilmaydi.
 */
import { differenceInCalendarDays } from 'date-fns';
import { toZonedTime } from 'date-fns-tz';

export type DateGroupKind = 'today' | 'yesterday' | 'weekday' | 'older';

/** ISO qatorni kompaniya zonasidagi kalendar kuniga aylantiradi va bugungi kunga solishtiradi. */
export function resolveDateGroupKind(
  value: string | undefined,
  timezone: string,
  now: Date = new Date(),
): DateGroupKind {
  if (!value) return 'older';

  const zonedNow = toZonedTime(now, timezone);
  const zonedValue = toZonedTime(value, timezone);
  const diff = differenceInCalendarDays(zonedNow, zonedValue);

  if (diff <= 0) return 'today';
  if (diff === 1) return 'yesterday';
  if (diff < 7) return 'weekday';
  return 'older';
}
