/**
 * `DutyGrid` uchun vaqt/koordinata hisob-kitoblari.
 *
 * Koordinata tizimi: har bir vaqt nuqtasi "kun boshidan o'tgan daqiqa"ga
 * aylantiriladi (`minutesFromDayStart`) — bu **epoch farqi** orqali
 * hisoblanadi, ya'ni haydovchining mahalliy soat qiymatlarini o'qishga
 * hojat yo'q. Shu tufayli DST (yoz vaqtiga o'tish) kuni — 23 yoki 25
 * soatlik sutka — avtomatik to'g'ri ishlaydi: `dayBounds.totalMinutes`
 * 1380/1440/1500 bo'lishi mumkin, va barcha segmentlar shu haqiqiy
 * uzunlikka nisbatan `GRID_LAYOUT.dayWidth` ga normallashtiriladi.
 */
import { formatInTimeZone, fromZonedTime } from 'date-fns-tz';
import { parseISO } from 'date-fns';

import { DUTY_STATUS_ROWS, GRID_LAYOUT } from './constants';
import type { DutyEventMarker, DutySegment, DutyStatusCode } from './types';

export interface DayBounds {
  /** Kompaniya sutkasining boshlanishi, UTC instant. */
  startUtc: Date;
  /** Keyingi kunning boshlanishi, UTC instant (chegara — shu daqiqa kirmaydi). */
  endUtc: Date;
  /** Haqiqiy sutka uzunligi daqiqada (DST kunlari 1380/1500 bo'lishi mumkin). */
  totalMinutes: number;
}

/** `YYYY-MM-DD` satriga `days` kun qo'shadi — sof kalendar arifmetikasi, TZ shifti yo'q. */
export function addCalendarDays(ymd: string, days: number): string {
  const parts = ymd.split('-').map(Number);
  const year = parts[0] ?? 1970;
  const month = parts[1] ?? 1;
  const day = parts[2] ?? 1;
  const date = new Date(Date.UTC(year, month - 1, day));
  date.setUTCDate(date.getUTCDate() + days);
  const y = date.getUTCFullYear();
  const m = String(date.getUTCMonth() + 1).padStart(2, '0');
  const d = String(date.getUTCDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

/**
 * Berilgan kalendar kuni (`date`) va kompaniya zonasi (`timezone`) uchun
 * sutka chegaralarini hisoblaydi. `fromZonedTime` shu zonadagi devor-vaqtini
 * UTC instant'ga aylantiradi — DST siljishi avtomatik hisobga olinadi.
 */
export function computeDayBounds(date: string, timezone: string): DayBounds {
  const startUtc = fromZonedTime(`${date}T00:00:00`, timezone);
  const nextDate = addCalendarDays(date, 1);
  const endUtc = fromZonedTime(`${nextDate}T00:00:00`, timezone);
  const totalMinutes = Math.max(1, Math.round((endUtc.getTime() - startUtc.getTime()) / 60000));
  return { startUtc, endUtc, totalMinutes };
}

/** ISO instant'ning `bounds.startUtc` dan necha daqiqa o'tganini qaytaradi (manfiy/ortiq bo'lishi mumkin). */
export function minutesFromDayStart(iso: string, bounds: DayBounds): number {
  const parsed = parseISO(iso);
  return (parsed.getTime() - bounds.startUtc.getTime()) / 60000;
}

export interface ClippedSegment {
  segment: DutySegment;
  /** Sutka ichidagi boshlanish daqiqasi, `[0, bounds.totalMinutes]` oralig'ida. */
  startMin: number;
  endMin: number;
}

/**
 * Segmentni kun chegarasiga kesadi (yarim tunni kesib o'tuvchi segment —
 * boshlanishi oldingi kunda yoki tugashi keyingi kunda bo'lishi mumkin).
 * Kesilgandan keyin davomiyligi 0 yoki manfiy bo'lsa — `null` (chizilmaydi).
 */
export function clipSegmentToDay(segment: DutySegment, bounds: DayBounds): ClippedSegment | null {
  const rawStart = minutesFromDayStart(segment.startTime, bounds);
  const rawEnd = minutesFromDayStart(segment.endTime, bounds);
  const startMin = Math.max(0, rawStart);
  const endMin = Math.min(bounds.totalMinutes, rawEnd);
  if (!(endMin > startMin)) return null;
  return { segment, startMin, endMin };
}

/** Kun ichidagi barcha segmentlarni kesib, vaqt bo'yicha tartiblab qaytaradi. */
export function clipSegmentsToDay(segments: DutySegment[], bounds: DayBounds): ClippedSegment[] {
  return segments
    .map((segment) => clipSegmentToDay(segment, bounds))
    .filter((s): s is ClippedSegment => s !== null)
    .sort((a, b) => a.startMin - b.startMin);
}

export interface PositionedEvent {
  event: DutyEventMarker;
  /** Sutka ichidagi daqiqa; chegaradan tashqari bo'lsa `null` (ko'rsatilmaydi). */
  minute: number | null;
  /** Bir xil vaqtga to'g'ri kelgan markerlar orasidagi tartib raqami (vizual stagger uchun). */
  clusterIndex: number;
}

/**
 * Hodisalarni kun ichidagi pozitsiyaga joylaydi. Sutkadan tashqari
 * hodisalar (masalan qo'shni kunga tegishli) chiqarib tashlanadi.
 * Bir-biriga juda yaqin (≤ `clusterWindowMin`) hodisalar `clusterIndex`
 * bilan belgilanadi — render vaqtida ustma-ust tushmasligi uchun.
 */
export function positionEvents(
  events: DutyEventMarker[],
  bounds: DayBounds,
  clusterWindowMin = 6,
): PositionedEvent[] {
  const withMinutes = events
    .map((event) => ({ event, minute: minutesFromDayStart(event.time, bounds) }))
    .filter((e) => e.minute >= 0 && e.minute <= bounds.totalMinutes)
    .sort((a, b) => a.minute - b.minute);

  const result: PositionedEvent[] = [];
  let clusterStart: number | null = null;
  let clusterIndex = 0;

  for (const { event, minute } of withMinutes) {
    if (clusterStart === null || minute - clusterStart > clusterWindowMin) {
      clusterStart = minute;
      clusterIndex = 0;
    } else {
      clusterIndex += 1;
    }
    result.push({ event, minute, clusterIndex });
  }

  return result;
}

/** Kun-daqiqasini SVG `viewBox` x-koordinatasiga aylantiradi. */
export function xForMinute(minute: number, bounds: DayBounds): number {
  const fraction = bounds.totalMinutes > 0 ? minute / bounds.totalMinutes : 0;
  return GRID_LAYOUT.labelColWidth + fraction * GRID_LAYOUT.dayWidth;
}

/** Status qatorining markaziy y-koordinatasi (0 = OFF, 1 = SB, 2 = DR, 3 = ON). */
export function yForRow(rowIndex: number): number {
  return GRID_LAYOUT.headerHeight + rowIndex * GRID_LAYOUT.rowHeight + GRID_LAYOUT.rowHeight / 2;
}

/** `DutyStatusCode` → qator indeksi (`DUTY_STATUS_ROWS` tartibida). */
export function rowIndexForStatus(status: DutyStatusCode): number {
  const index = DUTY_STATUS_ROWS.indexOf(status);
  return index === -1 ? 0 : index;
}

/**
 * Klassik "paper log" bog'lovchi chizig'i — qatorlar orasida duty-status
 * o'zgarganda vertikal sakraydi, bir xil status davomida gorizontal
 * yuradi. Bo'sh ro'yxat uchun bo'sh satr qaytaradi (hech narsa chizilmaydi).
 */
export function buildStaircasePath(clipped: ClippedSegment[], bounds: DayBounds): string {
  if (clipped.length === 0) return '';
  const parts: string[] = [];
  clipped.forEach(({ segment, startMin, endMin }, index) => {
    const x1 = xForMinute(startMin, bounds);
    const x2 = xForMinute(endMin, bounds);
    const y = yForRow(rowIndexForStatus(segment.status));
    if (index === 0) {
      parts.push(`M ${x1} ${y}`);
    } else {
      parts.push(`L ${x1} ${y}`);
    }
    parts.push(`L ${x2} ${y}`);
  });
  return parts.join(' ');
}

/** Har status uchun kesilgan segmentlar bo'yicha jami davomiylik (daqiqada). */
export function computeRowTotals(clipped: ClippedSegment[]): Record<DutyStatusCode, number> {
  const totals: Record<DutyStatusCode, number> = { OFF: 0, SB: 0, DR: 0, ON: 0 };
  for (const { segment, startMin, endMin } of clipped) {
    totals[segment.status] += endMin - startMin;
  }
  return totals;
}

export interface HourTick {
  hour: number;
  x: number;
}

/**
 * 0..24 soat uchun x-koordinatalarni hisoblaydi. DST kuni bo'lsa
 * (masalan bahorgi siljishda 2:00 mavjud bo'lmaydi) `fromZonedTime` eng
 * yaqin haqiqiy instantga tushiradi — vizual jihatdan chiziq shu soat
 * atrofida siqiladi/cho'ziladi, lekin funksiya hech qachon `NaN`
 * qaytarmaydi.
 */
export function computeHourTicks(date: string, timezone: string, bounds: DayBounds): HourTick[] {
  const ticks: HourTick[] = [];
  for (let hour = 0; hour <= 24; hour += 1) {
    let minute: number;
    if (hour === 24) {
      minute = bounds.totalMinutes;
    } else {
      const wallTime = `${date}T${String(hour).padStart(2, '0')}:00:00`;
      const instant = fromZonedTime(wallTime, timezone);
      minute = (instant.getTime() - bounds.startUtc.getTime()) / 60000;
    }
    ticks.push({ hour, x: xForMinute(minute, bounds) });
  }
  return ticks;
}

/**
 * Tooltip uchun soat:daqiqa:soniya — TZ §7.4.3: «vaqt (`HH:mm:ss`)» aniq
 * shu formatda talab qilingan (regulation-profile ga bog'liq emas, shuning
 * uchun `lib/format.ts`ning 12/24-soat mantiqiga tayanmaydi).
 */
export function formatClockTime(iso: string, timezone: string): string {
  return formatInTimeZone(parseISO(iso), timezone, 'HH:mm:ss');
}

/** Bo'sh/undefined qiymatlarni chetlab, class nomlarini birlashtiradi. */
export function cx(...values: Array<string | false | null | undefined>): string {
  return values.filter(Boolean).join(' ');
}
