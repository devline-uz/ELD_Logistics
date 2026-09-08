/**
 * Unidentified Driving (Unassigned Driving) — MSW handler'lari (3.1,
 * fe-testing §MSW). `assign` uchun haqiqiy URL oddiy (`/unidentified-events/
 * :id/assign`) — MSW route'i swagger konvertatsiya nuqsonidan (`unidentified.
 * ts` izohi) ta'sirlanmaydi, faqat `openapi-fetch` klient tipi buzilgan edi.
 */
import { http, HttpResponse } from 'msw';

import type { LogEditRequest, TrackingUnidentifiedEvent, UnidentifiedEvent } from '@/api/types';
import type { ListResponse } from '@/api/types';

import { logEditRequestFixture } from './logEditRequests';
import { jsonError, listMeta, url } from './shared';

export function unidentifiedEventFixture(
  overrides: Partial<TrackingUnidentifiedEvent> = {},
): TrackingUnidentifiedEvent {
  return {
    id: 'unidentified-1',
    unit_id: 'unit-1',
    unit_number: '1021',
    start_at: '2026-09-06T05:00:00Z',
    end_at: '2026-09-06T05:40:00Z',
    distance_m: 12_000,
    status: 'pending',
    pending_days: 1,
    created_at: '2026-09-06T05:41:00Z',
    ...overrides,
  };
}

/** `GET /unidentified-events` — muvaffaqiyatli. */
export const unidentifiedEventsListHandler = http.get(url('/unidentified-events'), () =>
  HttpResponse.json({
    data: [unidentifiedEventFixture()],
    meta: listMeta(),
  } satisfies ListResponse<TrackingUnidentifiedEvent>),
);

/** `GET /unidentified-events` — bo'sh natija. */
export const unidentifiedEventsListEmptyHandler = http.get(url('/unidentified-events'), () =>
  HttpResponse.json({
    data: [],
    meta: listMeta({ total: 0 }),
  } satisfies ListResponse<TrackingUnidentifiedEvent>),
);

/**
 * `GET /unidentified-events` — `403`. Faqat `logs.read`ga ega (`assign_
 * unidentified`siz) foydalanuvchi uchun **backend baribir ruxsat beradi**
 * (OR-mantiq istisnosi) — bu handler faqat ikkala ruxsat ham yo'q holatni
 * simulyatsiya qiladi.
 */
export const unidentifiedEventsListForbiddenHandler = http.get(url('/unidentified-events'), () =>
  jsonError('FORBIDDEN', 'Missing permission logs.assign_unidentified or logs.read', 403),
);

/** `POST /unidentified-events/{id}/assign` — muvaffaqiyatli (log-edit-request yaratiladi). */
export const unidentifiedAssignHandler = http.post(
  url('/unidentified-events/:id/assign'),
  ({ params }) =>
    HttpResponse.json(
      {
        data: logEditRequestFixture({
          id: 'log-edit-from-unidentified',
          source: 'unidentified_assign',
          unidentified_event_id: params.id as string,
        }),
      } satisfies { data: LogEditRequest },
      { status: 201 },
    ),
);

/** `POST /unidentified-events/{id}/assign` — `409 ALREADY_ASSIGNED`. */
export const unidentifiedAssignConflictHandler = http.post(
  url('/unidentified-events/:id/assign'),
  () => jsonError('ALREADY_ASSIGNED', 'Block already proposed to another driver', 409),
);

/** `POST /unidentified-events/{id}/annotate` — muvaffaqiyatli. */
export const unidentifiedAnnotateHandler = http.post(
  url('/unidentified-events/:id/annotate'),
  ({ params }) =>
    HttpResponse.json({
      data: { id: params.id as string, status: 'annotated' } satisfies Partial<UnidentifiedEvent>,
    }),
);

/** `POST /unidentified-events/{id}/annotate` — `422` (`annotation` yo'q). */
export const unidentifiedAnnotateValidationErrorHandler = http.post(
  url('/unidentified-events/:id/annotate'),
  () =>
    jsonError('VALIDATION_ERROR', 'validation failed', 422, [
      { field: 'annotation', message: 'required' },
    ]),
);

/** `POST /unidentified-events/{id}/claim` — muvaffaqiyatli. */
export const unidentifiedClaimHandler = http.post(
  url('/unidentified-events/:id/claim'),
  ({ params }) =>
    HttpResponse.json({
      data: { id: params.id as string, status: 'assigned' } satisfies Partial<UnidentifiedEvent>,
    }),
);

/** `POST /unidentified-events/{id}/claim` — `409 ALREADY_ASSIGNED`. */
export const unidentifiedClaimConflictHandler = http.post(
  url('/unidentified-events/:id/claim'),
  () => jsonError('ALREADY_ASSIGNED', 'Block already proposed to another driver', 409),
);
