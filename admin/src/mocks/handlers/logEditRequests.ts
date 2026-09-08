/**
 * Log Edit Requests — MSW handler'lari (3.1, fe-testing §MSW). Taklif → tasdiq
 * modeli (F100) — admin logni bevosita tahrirlamaydi.
 */
import { http, HttpResponse } from 'msw';

import type { ListResponse, LogEditRequest } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function logEditRequestFixture(overrides: Partial<LogEditRequest> = {}): LogEditRequest {
  return {
    id: 'log-edit-1',
    daily_log_id: 'daily-log-1',
    driver_id: 'driver-1',
    driver_name: 'John Doe',
    log_date: '2026-09-06',
    source: 'admin_edit',
    status: 'pending',
    requested_by: 'admin-1',
    timezone: 'America/Chicago',
    changes: [
      {
        status: 'ON',
        from: '2026-09-06T13:00:00Z',
        to: '2026-09-06T15:00:00Z',
        note: 'Loading at the dock, forgot to switch',
      },
    ],
    created_at: '2026-09-06T18:00:00Z',
    ...overrides,
  };
}

/** `GET /log-edit-requests` — muvaffaqiyatli. */
export const logEditRequestsListHandler = http.get(url('/log-edit-requests'), () =>
  HttpResponse.json({
    data: [logEditRequestFixture()],
    meta: listMeta(),
  } satisfies ListResponse<LogEditRequest>),
);

/** `GET /log-edit-requests` — bo'sh natija. */
export const logEditRequestsListEmptyHandler = http.get(url('/log-edit-requests'), () =>
  HttpResponse.json({
    data: [],
    meta: listMeta({ total: 0 }),
  } satisfies ListResponse<LogEditRequest>),
);

/** `POST /log-edit-requests` — muvaffaqiyatli taklif (`pending`). */
export const logEditRequestProposeHandler = http.post(url('/log-edit-requests'), () =>
  HttpResponse.json({ data: logEditRequestFixture({ id: 'log-edit-new' }) }, { status: 201 }),
);

/** `POST /log-edit-requests` — `409 DR_IMMUTABLE` (Q17.1). */
export const logEditRequestProposeImmutableHandler = http.post(url('/log-edit-requests'), () =>
  jsonError('DR_IMMUTABLE', 'Automatically recorded DR cannot be shortened', 409),
);

/** `POST /log-edit-requests/{id}/approve` — muvaffaqiyatli. */
export const logEditRequestApproveHandler = http.post(
  url('/log-edit-requests/:id/approve'),
  ({ params }) =>
    HttpResponse.json({
      data: logEditRequestFixture({ id: params.id as string, status: 'approved' }),
    }),
);

/** `POST /log-edit-requests/{id}/approve` — `403` (o'z taklifini o'zi tasdiqlash, F103). */
export const logEditRequestApproveForbiddenHandler = http.post(
  url('/log-edit-requests/:id/approve'),
  () => jsonError('FORBIDDEN', 'Cannot approve your own request', 403),
);

/** `POST /log-edit-requests/{id}/reject` — muvaffaqiyatli (`reason` majburiy). */
export const logEditRequestRejectHandler = http.post(
  url('/log-edit-requests/:id/reject'),
  ({ params }) =>
    HttpResponse.json({
      data: logEditRequestFixture({ id: params.id as string, status: 'rejected' }),
    }),
);

/** `POST /log-edit-requests/{id}/reject` — `422` (`reason` yo'q/qisqa). */
export const logEditRequestRejectValidationErrorHandler = http.post(
  url('/log-edit-requests/:id/reject'),
  () =>
    jsonError('VALIDATION_ERROR', 'validation failed', 422, [
      { field: 'reason', message: 'required' },
    ]),
);
