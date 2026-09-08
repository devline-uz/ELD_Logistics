/**
 * `HosSummary.counters` → `HosRingDatum[]` (7.4.3 — HOS bloki, 4 halqa).
 *
 * F98 [MUST]: hech qanday chegara (`11:00`, `14:00`, `70:00`) bu yerda
 * hardcode qilinmaydi. `limitMinutes` doim `null` — backend `HosSummary`
 * javobida siyosat chegarasini alohida raqam sifatida bermaydi (faqat
 * `policy_version_id`), shuning uchun `HosRings` cheklovsiz "noaniq holat"da
 * chiziladi (`docs/tz/16-17-registry-open-questions.md`ga qayd etilgan).
 */
import type { TFunction } from 'i18next';

import type { HosSummary } from '@/api/types';
import type { HosRingDatum } from '@/components/logs/types';

export function buildHosRings(summary: HosSummary | undefined, t: TFunction): HosRingDatum[] {
  const counters = summary?.counters;
  return [
    {
      id: 'break',
      label: t('logs.hos.rings.break'),
      remainingMinutes: counters?.break_left_min ?? null,
      limitMinutes: null,
      tone: 'warning',
    },
    {
      id: 'drive',
      label: t('logs.hos.rings.drive'),
      remainingMinutes: counters?.drive_left_min ?? null,
      limitMinutes: null,
      tone: 'success',
    },
    {
      id: 'shift',
      label: t('logs.hos.rings.shift'),
      remainingMinutes: counters?.shift_left_min ?? null,
      limitMinutes: null,
      tone: 'info',
    },
    {
      id: 'cycle',
      label: t('logs.hos.rings.cycle'),
      remainingMinutes: counters?.cycle_left_min ?? null,
      limitMinutes: null,
      tone: 'primary',
    },
  ];
}
