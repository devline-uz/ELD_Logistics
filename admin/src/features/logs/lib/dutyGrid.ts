/**
 * `DailyLogDetail.events[]` → `DutyGrid` props (`segments`/`events`), 7.4.3(a).
 *
 * `DutyGrid` o'zi domenni bilmaydi (`components/logs/types.ts`) — bu fayl
 * xom `LogEvent[]` ro'yxatini grid tushunadigan segment/marker shakliga
 * o'giradi.
 *
 * **Ma'lum bo'shliq.** TZ Q15 grid ustidagi markerlarni faqat
 * `pti · fuel · certify · malfunction` deb belgilaydi, lekin backend
 * `LogEvent.event_type` enumida (`schema.d.ts`) `pti`/`fuel` turlari umuman
 * yo'q — faqat `certification`/`malfunction` mos keladi. `docs/tz/
 * 16-17-registry-open-questions.md`ga qayd etilgan; shu sabab bu yerda
 * faqat shu ikkisi xaritalanadi.
 */
import type { DailyLogDetail } from '@/api/types';
import type { DutyEventMarker, DutySegment } from '@/components/logs/types';

/** Duty-status hodisalarini vaqt bo'yicha tartiblab, segmentlarga aylantiradi. */
export function buildDutySegments(events: DailyLogDetail['events'] = []): DutySegment[] {
  const dutyEvents = (events ?? [])
    .filter((event) => event.event_type === 'duty_status' && event.status && event.event_time)
    .slice()
    .sort((a, b) => (a.event_time ?? '').localeCompare(b.event_time ?? ''));

  const segments: DutySegment[] = [];
  for (let i = 0; i < dutyEvents.length; i += 1) {
    const current = dutyEvents[i]!;
    const next = dutyEvents[i + 1];
    const startTime = current.event_time as string;
    // Oxirgi segment kunning oxirigacha (24:00, `DutyGrid` o'zi kunlik
    // chegaraga qisqartiradi) — shuning uchun `endTime` sifatida keyingi
    // hodisa yoki (bo'lmasa) shu kunning oxiri UTC bo'yicha taxminiy beriladi.
    const endTime = next?.event_time ?? startTime;
    segments.push({
      status: current.status as DutySegment['status'],
      special: (current.special as DutySegment['special']) ?? 'none',
      startTime,
      endTime,
      note: current.notes,
      locationText: current.location_text,
    });
  }
  return segments;
}

const MARKER_TYPE_BY_EVENT_TYPE: Partial<
  Record<NonNullable<DailyLogDetail['events']>[number]['event_type'] & string, DutyEventMarker['type']>
> = {
  certification: 'certify',
  malfunction: 'malfunction',
};

/** Grid ustidagi hodisa markerlari — faqat backendda mos keladigan turlar (yuqoridagi izoh). */
export function buildDutyEventMarkers(events: DailyLogDetail['events'] = []): DutyEventMarker[] {
  return (events ?? [])
    .filter((event) => event.event_type && event.event_type in MARKER_TYPE_BY_EVENT_TYPE)
    .map((event) => ({
      type: MARKER_TYPE_BY_EVENT_TYPE[event.event_type as keyof typeof MARKER_TYPE_BY_EVENT_TYPE]!,
      time: event.event_time as string,
      note: event.notes,
    }));
}
