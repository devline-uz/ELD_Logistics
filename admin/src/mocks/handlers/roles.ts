/**
 * Roles — MSW handler'lari (2.1, fe-testing §MSW). `GET /roles/{id}`
 * swaggerda yo'q — `roles.ts` hooki keshdan o'qiydi.
 */
import { http, HttpResponse } from 'msw';

import type { ListResponse, Role } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function roleFixture(overrides: Partial<Role> = {}): Role {
  return {
    id: 'role-1',
    name: 'Fleet Manager',
    description: 'Fleet and driver management',
    scope: 'company',
    is_system: false,
    permissions: ['units.read', 'units.create', 'drivers.read'],
    created_at: '2026-09-01T10:00:00Z',
    ...overrides,
  };
}

export function systemRoleFixture(overrides: Partial<Role> = {}): Role {
  return roleFixture({
    id: 'role-admin',
    name: 'Administrator',
    is_system: true,
    permissions: ['units.read', 'drivers.read'],
    ...overrides,
  });
}

/** `GET /roles` — muvaffaqiyatli (tizim + kompaniya rollari). */
export const rolesListHandler = http.get(url('/roles'), () =>
  HttpResponse.json({
    data: [systemRoleFixture(), roleFixture()],
    meta: listMeta({ total: 2 }),
  } satisfies ListResponse<Role>),
);

/** `GET /roles` — bo'sh natija. */
export const rolesListEmptyHandler = http.get(url('/roles'), () =>
  HttpResponse.json({ data: [], meta: listMeta({ total: 0 }) } satisfies ListResponse<Role>),
);

/** `GET /roles` — `422`. */
export const rolesListErrorHandler = http.get(url('/roles'), () =>
  jsonError('VALIDATION_ERROR', 'per_page must be 10, 25 or 50', 422),
);

/** `POST /roles` — muvaffaqiyatli (`201`). */
export const roleCreateHandler = http.post(url('/roles'), () =>
  HttpResponse.json({ data: roleFixture({ id: 'role-new' }) }, { status: 201 }),
);

/** `POST /roles` — `422` (noma'lum permission kaliti, F94). */
export const roleCreateValidationErrorHandler = http.post(url('/roles'), () =>
  jsonError('VALIDATION_ERROR', 'unknown permission key', 422, [
    { field: 'permissions', message: 'unknown key "units.frobnicate"' },
  ]),
);

/** `POST /roles` — `409` (rol nomi band). */
export const roleCreateConflictHandler = http.post(url('/roles'), () =>
  jsonError('CONFLICT', 'Role name is taken', 409),
);

/** `PATCH /roles/{id}` — muvaffaqiyatli. */
export const roleUpdateHandler = http.patch(url('/roles/:id'), ({ params }) =>
  HttpResponse.json({ data: roleFixture({ id: params.id as string }) }),
);

/** `PATCH /roles/{id}` — `403 SYSTEM_ROLE_IMMUTABLE` (F92). */
export const roleUpdateSystemImmutableHandler = http.patch(url('/roles/:id'), () =>
  jsonError('FORBIDDEN', 'System role cannot be edited', 403),
);

/** `DELETE /roles/{id}` — muvaffaqiyatli (`204`). */
export const roleDeleteHandler = http.delete(
  url('/roles/:id'),
  () => new HttpResponse(null, { status: 204 }),
);

/** `DELETE /roles/{id}` — `409 ROLE_IN_USE` (F93). */
export const roleDeleteInUseHandler = http.delete(url('/roles/:id'), () =>
  jsonError('CONFLICT', '3 users still use this role. Reassign them first.', 409),
);

/** `DELETE /roles/{id}` — `403 SYSTEM_ROLE_IMMUTABLE` (F92). */
export const roleDeleteSystemImmutableHandler = http.delete(url('/roles/:id'), () =>
  jsonError('FORBIDDEN', 'System role cannot be deleted', 403),
);

/** Bazaviy to'plam — ro'yxat + CRUD muvaffaqiyat holatlari. */
export const rolesBaseHandlers = [
  rolesListHandler,
  roleCreateHandler,
  roleUpdateHandler,
  roleDeleteHandler,
];
