/**
 * Drivers — MSW handler'lari (2.1, fe-testing §MSW). Har endpoint uchun
 * muvaffaqiyat + xato varianti; `license_no` hech qachon ochiq qaytmaydi
 * (`license_no_masked` — faqat `/license` reveal orqali ochiladi, F87).
 */
import { http, HttpResponse } from 'msw';

import type {
  CoDriver,
  Driver,
  DriverActivity,
  DriverLicense,
  DriverResetPasswordResult,
  ImportResult,
  ListResponse,
} from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function driverFixture(overrides: Partial<Driver> = {}): Driver {
  return {
    id: 'driver-1',
    first_name: 'John',
    last_name: 'Doe',
    username: 'jdoe',
    email: 'john.doe@example.com',
    license_no_masked: '****-4821',
    status: 'active',
    activated_on: '2026-01-14T09:00:00Z',
    created_at: '2026-01-14T08:59:00Z',
    app_version: '2.4.1',
    ...overrides,
  };
}

/** `GET /drivers` — muvaffaqiyatli. */
export const driversListHandler = http.get(url('/drivers'), () =>
  HttpResponse.json({ data: [driverFixture()], meta: listMeta() } satisfies ListResponse<Driver>),
);

/** `GET /drivers` — bo'sh natija. */
export const driversListEmptyHandler = http.get(url('/drivers'), () =>
  HttpResponse.json({ data: [], meta: listMeta({ total: 0 }) } satisfies ListResponse<Driver>),
);

/** `GET /drivers` — `422`. */
export const driversListErrorHandler = http.get(url('/drivers'), () =>
  jsonError('VALIDATION_ERROR', 'per_page must be 10, 25 or 50', 422),
);

/** `GET /drivers/{id}` — muvaffaqiyatli. */
export const driverGetHandler = http.get(url('/drivers/:id'), ({ params }) =>
  HttpResponse.json({ data: driverFixture({ id: params.id as string }) }),
);

/** `GET /drivers/{id}` — cross-tenant → `404`. */
export const driverGetNotFoundHandler = http.get(url('/drivers/:id'), () =>
  jsonError('NOT_FOUND', 'Driver not found', 404),
);

/** `POST /drivers` — muvaffaqiyatli (parol maydoni yo'q, invitation yuboriladi). */
export const driverCreateHandler = http.post(url('/drivers'), () =>
  HttpResponse.json(
    { data: driverFixture({ id: 'driver-new', status: 'invited' }) },
    { status: 201 },
  ),
);

/** `POST /drivers` — `422`. */
export const driverCreateValidationErrorHandler = http.post(url('/drivers'), () =>
  jsonError('VALIDATION_ERROR', 'validation failed', 422, [
    { field: 'license_no', message: 'required' },
  ]),
);

/** `POST /drivers` — `409` (username/email band, yoki nofaol co-driver holati). */
export const driverCreateConflictHandler = http.post(url('/drivers'), () =>
  jsonError('CONFLICT', 'username already in use', 409),
);

/** `PATCH /drivers/{id}` — muvaffaqiyatli. */
export const driverUpdateHandler = http.patch(url('/drivers/:id'), ({ params }) =>
  HttpResponse.json({ data: driverFixture({ id: params.id as string }) }),
);

/** `PATCH /drivers/{id}` — `404`. */
export const driverUpdateNotFoundHandler = http.patch(url('/drivers/:id'), () =>
  jsonError('NOT_FOUND', 'Driver not found', 404),
);

/** `DELETE /drivers/{id}` — muvaffaqiyatli (`204`). */
export const driverDeleteHandler = http.delete(
  url('/drivers/:id'),
  () => new HttpResponse(null, { status: 204 }),
);

/** `DELETE /drivers/{id}` — `409 RESOURCE_IN_USE`. */
export const driverDeleteConflictHandler = http.delete(url('/drivers/:id'), () =>
  jsonError('CONFLICT', 'Driver has open logs', 409),
);

/** `POST /drivers/{id}/activate` — muvaffaqiyatli. */
export const driverActivateHandler = http.post(url('/drivers/:id/activate'), ({ params }) =>
  HttpResponse.json({ data: driverFixture({ id: params.id as string, status: 'active' }) }),
);

/** `POST /drivers/{id}/deactivate` — muvaffaqiyatli. */
export const driverDeactivateHandler = http.post(url('/drivers/:id/deactivate'), ({ params }) =>
  HttpResponse.json({ data: driverFixture({ id: params.id as string, status: 'inactive' }) }),
);

/** `POST /drivers/{id}/activate|deactivate` — `404`. */
export const driverActivateNotFoundHandler = http.post(url('/drivers/:id/activate'), () =>
  jsonError('NOT_FOUND', 'Driver not found', 404),
);

/**
 * `POST /drivers/{id}/reset-password` — ✅ `Send password reset` (F7.3.4):
 * parol emas, invitation havolasi qayta yuboriladi.
 */
export const driverResetPasswordHandler = http.post(url('/drivers/:id/reset-password'), () =>
  HttpResponse.json({
    data: {
      driver_id: 'driver-1',
      channel: 'email',
      expires_at: '2026-09-09T18:22:00Z',
    } satisfies DriverResetPasswordResult,
  }),
);

/** `POST /drivers/{id}/reset-password` — `403 ACCOUNT_INACTIVE`. */
export const driverResetPasswordInactiveHandler = http.post(
  url('/drivers/:id/reset-password'),
  () => jsonError('FORBIDDEN', 'Driver account is inactive', 403),
);

/**
 * `GET /drivers/{id}/license` (`drivers.license.view`, F87) — 30 soniyalik
 * "Reveal" natijasi.
 */
export const driverLicenseRevealHandler = http.get(url('/drivers/:id/license'), ({ params }) =>
  HttpResponse.json({
    data: {
      driver_id: params.id as string,
      license_no: 'TX-9930-4821',
      license_region: 'TX',
    } satisfies DriverLicense,
  }),
);

/** `GET /drivers/{id}/license` — `403` (`drivers.license.view` yo'q). */
export const driverLicenseRevealForbiddenHandler = http.get(url('/drivers/:id/license'), () =>
  jsonError('FORBIDDEN', 'Missing permission drivers.license.view', 403),
);

/** `GET /drivers/{id}/activities` — muvaffaqiyatli. */
export const driverActivitiesHandler = http.get(url('/drivers/:id/activities'), () =>
  HttpResponse.json({
    data: [
      {
        id: 'act-1',
        action: 'update',
        field: 'status',
        old_value: '"inactive"',
        new_value: '"active"',
        actor_id: 'user-1',
        occurred_at: '2026-09-05T18:22:00Z',
      },
    ] satisfies DriverActivity[],
    meta: listMeta(),
  } satisfies ListResponse<DriverActivity>),
);

/** `GET /drivers/{id}/co-drivers` — muvaffaqiyatli. */
export const driverCoDriversHandler = http.get(url('/drivers/:id/co-drivers'), () =>
  HttpResponse.json({
    data: [
      {
        driver_id: 'driver-2',
        first_name: 'Maria',
        last_name: 'Lopez',
        username: 'maria.lopez',
        status: 'active',
        pair_id: 'pair-1',
        paired_at: '2026-03-02T10:15:00Z',
      },
    ] satisfies CoDriver[],
    meta: listMeta(),
  } satisfies ListResponse<CoDriver>),
);

/** `GET /drivers/{id}/co-drivers` — bo'sh (juftlik yo'q). */
export const driverCoDriversEmptyHandler = http.get(url('/drivers/:id/co-drivers'), () =>
  HttpResponse.json({ data: [], meta: listMeta({ total: 0 }) } satisfies ListResponse<CoDriver>),
);

/** `POST /drivers/{id}/co-drivers` — muvaffaqiyatli (`201`). */
export const driverCoDriverLinkHandler = http.post(url('/drivers/:id/co-drivers'), () =>
  HttpResponse.json(
    { data: [{ driver_id: 'driver-2', status: 'active' }] satisfies CoDriver[] },
    { status: 201 },
  ),
);

/** `POST /drivers/{id}/co-drivers` — `409` (allaqachon bog'langan). */
export const driverCoDriverLinkConflictHandler = http.post(url('/drivers/:id/co-drivers'), () =>
  jsonError('CONFLICT', 'Co-driver already linked', 409),
);

/** `DELETE /drivers/{id}/co-drivers/{co_driver_id}` — muvaffaqiyatli (`204`). */
export const driverCoDriverUnlinkHandler = http.delete(
  url('/drivers/:id/co-drivers/:coDriverId'),
  () => new HttpResponse(null, { status: 204 }),
);

/** `DELETE /drivers/{id}/co-drivers/{co_driver_id}` — `404`. */
export const driverCoDriverUnlinkNotFoundHandler = http.delete(
  url('/drivers/:id/co-drivers/:coDriverId'),
  () => jsonError('NOT_FOUND', 'Co-driver pair not found', 404),
);

/** `GET /drivers/export` — muvaffaqiyatli (CSV blob, `license_no` maskalangan). */
export const driversExportHandler = http.get(
  url('/drivers/export'),
  () =>
    new HttpResponse('first_name,last_name,license_no\nJohn,Doe,****-4821\n', {
      status: 200,
      headers: { 'Content-Type': 'text/csv' },
    }),
);

/** `GET /drivers/import-template` — muvaffaqiyatli (CSV blob). */
export const driversImportTemplateHandler = http.get(
  url('/drivers/import-template'),
  () =>
    new HttpResponse(
      'first_name,last_name,username,phone,email,license_no,license_region,home_terminal\n',
      {
        status: 200,
        headers: { 'Content-Type': 'text/csv' },
      },
    ),
);

/** `POST /drivers/import` — muvaffaqiyatli. */
export const driversImportHandler = http.post(url('/drivers/import'), () =>
  HttpResponse.json({ data: { imported: 2, total: 2, errors: [] } satisfies ImportResult }),
);

/** `POST /drivers/import` — `422` all-or-nothing (F83, xuddi units kabi CR eslatmasi). */
export const driversImportValidationErrorHandler = http.post(url('/drivers/import'), () =>
  HttpResponse.json(
    {
      data: {
        imported: 0,
        total: 2,
        errors: [{ row: 1, field: 'username', message: 'must be 4-32 characters of [a-z0-9._]' }],
      } satisfies ImportResult,
    },
    { status: 422 },
  ),
);

/** Bazaviy to'plam — ro'yxat + CRUD muvaffaqiyat holatlari. */
export const driversBaseHandlers = [
  driversListHandler,
  driverGetHandler,
  driverCreateHandler,
  driverUpdateHandler,
  driverDeleteHandler,
];
