/**
 * Violations — MSW handler'lari (3.1, fe-testing §MSW). `Delete` yo'q (F105).
 */
import { http, HttpResponse } from 'msw';

import type { ListResponse, Violation } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function violationFixture(overrides: Partial<Violation> = {}): Violation {
  return {
    id: 'violation-1',
    driver_id: 'driver-1',
    driver_name: 'John Doe',
    unit_id: 'unit-1',
    daily_log_id: 'daily-log-1',
    log_date: '2026-09-06',
    type: 'drive_limit',
    severity: 'violation',
    occurred_at: '2026-09-06T20:00:00Z',
    created_at: '2026-09-06T20:00:01Z',
    policy_version_id: 'policy-v1',
    details: { limit_min: 660, remaining_min: 0, note: 'driving beyond the 11 hour limit' },
    ...overrides,
  };
}

/** `GET /violations` — muvaffaqiyatli. */
export const violationsListHandler = http.get(url('/violations'), () =>
  HttpResponse.json({
    data: [violationFixture()],
    meta: listMeta(),
  } satisfies ListResponse<Violation>),
);

/** `GET /violations` — bo'sh natija. */
export const violationsListEmptyHandler = http.get(url('/violations'), () =>
  HttpResponse.json({ data: [], meta: listMeta({ total: 0 }) } satisfies ListResponse<Violation>),
);

/** `GET /violations` — `422` (noto'g'ri filtr). */
export const violationsListErrorHandler = http.get(url('/violations'), () =>
  jsonError('VALIDATION_ERROR', 'invalid type filter', 422),
);

/** `GET /violations/{id}` — muvaffaqiyatli. */
export const violationGetHandler = http.get(url('/violations/:id'), ({ params }) =>
  HttpResponse.json({ data: violationFixture({ id: params.id as string }) }),
);

/** `GET /violations/{id}` — `404`. */
export const violationGetNotFoundHandler = http.get(url('/violations/:id'), () =>
  jsonError('NOT_FOUND', 'Violation not found', 404),
);
