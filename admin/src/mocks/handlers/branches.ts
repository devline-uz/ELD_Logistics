/**
 * Branches — MSW handler'lari (bosqich 2 ko'rigi B1, kengaytirildi bosqich
 * 8.1: Settings › Branches CRUD, fe-testing §MSW).
 */
import { http, HttpResponse } from 'msw';

import type { Branch, ListResponse } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function branchFixture(overrides: Partial<Branch> = {}): Branch {
  return {
    id: 'branch-1',
    name: 'Dallas Terminal',
    address: '1200 Industrial Rd, Dallas, TX 75207',
    timezone: 'America/Chicago',
    created_at: '2026-01-14T09:30:00Z',
    updated_at: '2026-09-06T05:12:00Z',
    ...overrides,
  };
}

/** `GET /company/branches` — muvaffaqiyatli. */
export const branchesListHandler = http.get(url('/company/branches'), () =>
  HttpResponse.json({
    data: [branchFixture()],
    meta: listMeta(),
  } satisfies ListResponse<Branch>),
);

/** `GET /company/branches` — bo'sh natija (`scope=branch` yoki yangi kompaniya). */
export const branchesListEmptyHandler = http.get(url('/company/branches'), () =>
  HttpResponse.json({ data: [], meta: listMeta({ total: 0 }) } satisfies ListResponse<Branch>),
);

/** `POST /company/branches` — `201`. */
export const branchCreateHandler = http.post(url('/company/branches'), () =>
  HttpResponse.json(
    { data: branchFixture({ id: 'branch-new', name: 'Houston Terminal' }) },
    { status: 201 },
  ),
);

/** `POST /company/branches` — `422` (masalan `name` yo'q). */
export const branchCreateErrorHandler = http.post(url('/company/branches'), () =>
  jsonError('VALIDATION_ERROR', 'name is required', 422, [{ field: 'name', message: 'required' }]),
);

/** `PATCH /company/branches/{id}` — muvaffaqiyatli. */
export const branchUpdateHandler = http.patch(url('/company/branches/:id'), ({ params }) =>
  HttpResponse.json({ data: branchFixture({ id: params.id as string, name: 'Updated Terminal' }) }),
);

/** `PATCH /company/branches/{id}` — `404` (boshqa tenant filiali). */
export const branchUpdateNotFoundHandler = http.patch(url('/company/branches/:id'), () =>
  jsonError('NOT_FOUND', 'branch not found', 404),
);

/** `DELETE /company/branches/{id}` — `204`. */
export const branchDeleteHandler = http.delete(
  url('/company/branches/:id'),
  () => new HttpResponse(null, { status: 204 }),
);

/** `DELETE /company/branches/{id}` — `409` (filialda foydalanuvchi bor). */
export const branchDeleteInUseHandler = http.delete(url('/company/branches/:id'), () =>
  jsonError('RESOURCE_IN_USE', 'branch has assigned users', 409),
);
