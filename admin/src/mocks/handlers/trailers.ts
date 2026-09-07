/**
 * Trailers — MSW handler'lari (2.1, fe-testing §MSW). Sodda CRUD (🎨).
 */
import { http, HttpResponse } from 'msw';

import type { ListResponse, Trailer } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function trailerFixture(overrides: Partial<Trailer> = {}): Trailer {
  return {
    id: 'trailer-1',
    number: 'TR-4410',
    notes: 'Reefer',
    created_at: '2026-01-14T09:00:00Z',
    updated_at: '2026-09-06T05:12:00Z',
    ...overrides,
  };
}

/** `GET /trailers` — muvaffaqiyatli. */
export const trailersListHandler = http.get(url('/trailers'), () =>
  HttpResponse.json({ data: [trailerFixture()], meta: listMeta() } satisfies ListResponse<Trailer>),
);

/** `GET /trailers` — bo'sh natija. */
export const trailersListEmptyHandler = http.get(url('/trailers'), () =>
  HttpResponse.json({ data: [], meta: listMeta({ total: 0 }) } satisfies ListResponse<Trailer>),
);

/** `GET /trailers` — `422`. */
export const trailersListErrorHandler = http.get(url('/trailers'), () =>
  jsonError('VALIDATION_ERROR', 'per_page must be 10, 25 or 50', 422),
);

/** `GET /trailers/{id}` — muvaffaqiyatli. */
export const trailerGetHandler = http.get(url('/trailers/:id'), ({ params }) =>
  HttpResponse.json({ data: trailerFixture({ id: params.id as string }) }),
);

/** `GET /trailers/{id}` — cross-tenant → `404`. */
export const trailerGetNotFoundHandler = http.get(url('/trailers/:id'), () =>
  jsonError('NOT_FOUND', 'Trailer not found', 404),
);

/** `POST /trailers` — muvaffaqiyatli (`201`). */
export const trailerCreateHandler = http.post(url('/trailers'), () =>
  HttpResponse.json({ data: trailerFixture({ id: 'trailer-new' }) }, { status: 201 }),
);

/** `POST /trailers` — `409` (`number` band). */
export const trailerCreateConflictHandler = http.post(url('/trailers'), () =>
  jsonError('CONFLICT', 'number already in use', 409),
);

/** `PATCH /trailers/{id}` — muvaffaqiyatli. */
export const trailerUpdateHandler = http.patch(url('/trailers/:id'), ({ params }) =>
  HttpResponse.json({ data: trailerFixture({ id: params.id as string }) }),
);

/** `PATCH /trailers/{id}` — `404`. */
export const trailerUpdateNotFoundHandler = http.patch(url('/trailers/:id'), () =>
  jsonError('NOT_FOUND', 'Trailer not found', 404),
);

/** `DELETE /trailers/{id}` — muvaffaqiyatli (`204`). */
export const trailerDeleteHandler = http.delete(
  url('/trailers/:id'),
  () => new HttpResponse(null, { status: 204 }),
);

/** `DELETE /trailers/{id}` — `409 RESOURCE_IN_USE`. */
export const trailerDeleteConflictHandler = http.delete(url('/trailers/:id'), () =>
  jsonError('CONFLICT', 'Trailer is referenced by open trips', 409),
);

/** Bazaviy to'plam — ro'yxat + CRUD muvaffaqiyat holatlari. */
export const trailersBaseHandlers = [
  trailersListHandler,
  trailerGetHandler,
  trailerCreateHandler,
  trailerUpdateHandler,
  trailerDeleteHandler,
];
