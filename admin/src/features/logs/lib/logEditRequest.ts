/**
 * Log view — "Insert/Edit Duty Status" paneli uchun yordamchi funksiyalar
 * (7.4.3(b), F100, Q17.1).
 *
 * `DailyLogDetail.events[]` — xom, vaqt bo'yicha tartiblanmagan bo'lishi
 * mumkin bo'lgan ro'yxat. Bu yerda faqat `duty_status` turidagi hodisalar
 * "segment"ga aylantiriladi (boshlanish → keyingi hodisa boshlanishi) —
 * `SendEditRequestPanel` va Voqealar jadvali (`LogEventsTable`) shu
 * segmentlardan asl `status`/`origin`/oraliqni bilib oladi.
 */
import type { DailyLogDetail } from '@/api/types';

type LogEvent = NonNullable<DailyLogDetail['events']>[number];

export interface EditableDutySegment {
  /** Segmentni boshlagan xom hodisa — `origin`/`id`/`special` shundan olinadi. */
  event: LogEvent;
  startTime: string;
  endTime: string;
}

/** Duty-status hodisalarini vaqt bo'yicha tartiblab, segmentlarga ajratadi. */
export function buildEditableDutySegments(events: LogEvent[] = []): EditableDutySegment[] {
  const dutyEvents = (events ?? [])
    .filter((event) => event.event_type === 'duty_status' && event.status && event.event_time)
    .slice()
    .sort((a, b) => (a.event_time ?? '').localeCompare(b.event_time ?? ''));

  return dutyEvents.map((event, index) => ({
    event,
    startTime: event.event_time as string,
    endTime: dutyEvents[index + 1]?.event_time ?? (event.event_time as string),
  }));
}

/**
 * **Q17.1 [MUST]**: avtomatik (ELD) yozib olingan DR intervalini qisqartirish
 * yoki boshqa statusga o'zgartirish mumkin emas. Bu funksiya UI darajasidagi
 * tekshiruv — backend (`409 DR_IMMUTABLE`) yakuniy hakam bo'lib qoladi.
 */
export function isImmutableAutoDriving(segment: EditableDutySegment): boolean {
  return segment.event.origin === 'auto' && segment.event.status === 'DR';
}

/**
 * Yangi taklif qilingan oraliq asl (avtomatik DR) segmentni "qisqartiradimi"
 * — ya'ni yangi oraliq asl oraliqni to'liq qamrab olmasa `true`.
 */
export function shrinksOriginalInterval(
  segment: EditableDutySegment,
  next: { from: string; to: string },
): boolean {
  const originalStart = new Date(segment.startTime).getTime();
  const originalEnd = new Date(segment.endTime).getTime();
  const nextStart = new Date(next.from).getTime();
  const nextEnd = new Date(next.to).getTime();
  if ([originalStart, originalEnd, nextStart, nextEnd].some((value) => Number.isNaN(value))) {
    return false;
  }
  return nextStart > originalStart || nextEnd < originalEnd;
}

/**
 * Faqat `duty_status` hodisalari tahrir uchun taklif qilinishi mumkin —
 * `intermediate`/`power_*`/`malfunction`/... hodisalarida Action menyusi
 * umuman ko'rinmaydi (7.4.3(b)).
 */
export function isEventEditable(event: LogEvent): boolean {
  return event.event_type === 'duty_status';
}

/** Panel'dagi status/special tugmalari — 7.4.3(b) roʻyxati. */
export const DUTY_EDIT_BUTTONS = [
  { status: 'OFF', special: 'none' },
  { status: 'SB', special: 'none' },
  { status: 'DR', special: 'none' },
  { status: 'ON', special: 'none' },
  { status: 'ON', special: 'ym' },
  { status: 'OFF', special: 'pc' },
] as const;

export type DutyEditButton = (typeof DUTY_EDIT_BUTTONS)[number];
