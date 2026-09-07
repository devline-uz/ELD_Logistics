/**
 * HOS (hos-summary) — MSW handler'lari (3.1, fe-testing §MSW).
 */
import { http, HttpResponse } from 'msw';

import type { HosSummary } from '@/api/types';

import { jsonError, url } from './shared';

export function hosSummaryFixture(overrides: Partial<HosSummary> = {}): HosSummary {
  return {
    driver_id: 'driver-1',
    date: '2026-09-07',
    timezone: 'America/Chicago',
    policy_version_id: 'policy-v1',
    evaluated_at: '2026-09-07T12:00:00Z',
    counters: {
      break_left_min: 480,
      drive_left_min: 300,
      shift_left_min: 540,
      cycle_left_min: 2400,
    },
    totals: { off_min: 480, sb_min: 0, drive_min: 360, on_min: 60 },
    recap: [{ date: '2026-09-08', available_min: 600, on_duty_min: 60, gained_next_min: 60 }],
    violations: [],
    ...overrides,
  };
}

/** `GET /drivers/{id}/hos-summary` — muvaffaqiyatli. */
export const hosSummaryHandler = http.get(url('/drivers/:id/hos-summary'), ({ params }) =>
  HttpResponse.json({ data: hosSummaryFixture({ driver_id: params.id as string }) }),
);

/** `GET /drivers/{id}/hos-summary` — `404` (haydovchi topilmadi/cross-tenant). */
export const hosSummaryNotFoundHandler = http.get(url('/drivers/:id/hos-summary'), () =>
  jsonError('NOT_FOUND', 'Driver not found', 404),
);

/** `GET /drivers/{id}/hos-summary` — `422` (noto'g'ri `date`). */
export const hosSummaryValidationErrorHandler = http.get(url('/drivers/:id/hos-summary'), () =>
  jsonError('VALIDATION_ERROR', 'date must be YYYY-MM-DD', 422),
);
