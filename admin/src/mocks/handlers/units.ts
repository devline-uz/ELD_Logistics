/**
 * Units — MSW handler'lari (2.1, fe-testing §MSW). Har endpoint uchun
 * muvaffaqiyat + xato varianti; ro'yxat `{data, meta}` konverti.
 */
import { http, HttpResponse } from 'msw';

import type {
  ImportResult,
  ListResponse,
  Unit,
  UnitAssignment,
  UnitDiagnostics,
  UnitHistoryEntry,
} from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function unitFixture(overrides: Partial<Unit> = {}): Unit {
  return {
    id: 'unit-1',
    unit_number: '1021',
    make: 'Freightliner',
    model: 'Cascadia',
    year: 2021,
    license_plate: 'AA123BB',
    plate_region: 'TX',
    vin: '1FUJGLDR9CLBP8834',
    fuel_type: 'diesel',
    status: 'active',
    out_of_service: false,
    eld_device_serial: 'ELD-000123',
    sleeper_berth: true,
    created_at: '2026-01-14T09:00:00Z',
    ...overrides,
  };
}

/** `GET /units` — muvaffaqiyatli, bitta yozuv bilan. */
export const unitsListHandler = http.get(url('/units'), () =>
  HttpResponse.json({ data: [unitFixture()], meta: listMeta() } satisfies ListResponse<Unit>),
);

/** `GET /units` — bo'sh natija (filtr mos kelmaganda). */
export const unitsListEmptyHandler = http.get(url('/units'), () =>
  HttpResponse.json({
    data: [],
    meta: listMeta({ total: 0 }),
  } satisfies ListResponse<Unit>),
);

/** `GET /units` — `422` (masalan noto'g'ri `per_page`). */
export const unitsListErrorHandler = http.get(url('/units'), () =>
  jsonError('VALIDATION_ERROR', 'per_page must be 10, 25 or 50', 422),
);

/** `GET /units/{id}` — muvaffaqiyatli. */
export const unitGetHandler = http.get(url('/units/:id'), ({ params }) =>
  HttpResponse.json({ data: unitFixture({ id: params.id as string }) }),
);

/** `GET /units/{id}` — cross-tenant/mavjud bo'lmagan → `404` (403 emas). */
export const unitGetNotFoundHandler = http.get(url('/units/:id'), () =>
  jsonError('NOT_FOUND', 'Unit not found', 404),
);

/** `POST /units` — muvaffaqiyatli yaratish. */
export const unitCreateHandler = http.post(url('/units'), () =>
  HttpResponse.json({ data: unitFixture({ id: 'unit-new' }) }, { status: 201 }),
);

/** `POST /units` — `422` (majburiy maydon yo'q). */
export const unitCreateValidationErrorHandler = http.post(url('/units'), () =>
  jsonError('VALIDATION_ERROR', 'validation failed', 422, [
    { field: 'unit_number', message: 'required' },
  ]),
);

/** `POST /units` — `409` (`unit_number`/`vin` band). */
export const unitCreateConflictHandler = http.post(url('/units'), () =>
  jsonError('CONFLICT', 'unit_number already in use', 409),
);

/** `PATCH /units/{id}` — muvaffaqiyatli. */
export const unitUpdateHandler = http.patch(url('/units/:id'), ({ params }) =>
  HttpResponse.json({ data: unitFixture({ id: params.id as string }) }),
);

/** `PATCH /units/{id}` — `404`. */
export const unitUpdateNotFoundHandler = http.patch(url('/units/:id'), () =>
  jsonError('NOT_FOUND', 'Unit not found', 404),
);

/** `DELETE /units/{id}` — muvaffaqiyatli (`204`). */
export const unitDeleteHandler = http.delete(
  url('/units/:id'),
  () => new HttpResponse(null, { status: 204 }),
);

/** `DELETE /units/{id}` — `409 RESOURCE_IN_USE`. */
export const unitDeleteConflictHandler = http.delete(url('/units/:id'), () =>
  jsonError('CONFLICT', 'Unit is referenced by open logs', 409),
);

/** `POST /units/{id}/activate` — muvaffaqiyatli. */
export const unitActivateHandler = http.post(url('/units/:id/activate'), ({ params }) =>
  HttpResponse.json({
    data: unitFixture({ id: params.id as string, status: 'active' }),
  }),
);

/** `POST /units/{id}/deactivate` — muvaffaqiyatli. */
export const unitDeactivateHandler = http.post(url('/units/:id/deactivate'), ({ params }) =>
  HttpResponse.json({
    data: unitFixture({ id: params.id as string, status: 'inactive' }),
  }),
);

/** `POST /units/{id}/activate|deactivate` — `404`. */
export const unitActivateNotFoundHandler = http.post(url('/units/:id/activate'), () =>
  jsonError('NOT_FOUND', 'Unit not found', 404),
);

/** `POST /units/{id}/assign-driver` — muvaffaqiyatli (`201`). */
export const unitAssignDriverHandler = http.post(url('/units/:id/assign-driver'), () =>
  HttpResponse.json(
    {
      data: {
        id: 'assignment-1',
        unit_id: 'unit-1',
        driver_id: 'driver-1',
        driver_name: 'John Doe',
        role: 'primary',
        assigned_at: '2026-09-01T06:00:00Z',
      } satisfies UnitAssignment,
    },
    { status: 201 },
  ),
);

/** `POST /units/{id}/assign-driver` — `409` (nofaol unit/driver). */
export const unitAssignDriverConflictHandler = http.post(url('/units/:id/assign-driver'), () =>
  jsonError('CONFLICT', 'Unit is inactive', 409),
);

/** `GET /units/{id}/diagnostics` — muvaffaqiyatli. */
export const unitDiagnosticsHandler = http.get(url('/units/:id/diagnostics'), () =>
  HttpResponse.json({
    data: {
      device_id: 'eld-1',
      device_serial: 'ELD-000123',
      device_vendor: 'Geotab',
      device_model: 'GO9',
      device_firmware: '4.12.1',
      device_status: 'active',
      connection_type: 'cellular',
      connection_state: 'online',
      sim_present: true,
      last_seen_at: '2026-09-06T05:12:00Z',
      malfunction_codes: [],
    } satisfies UnitDiagnostics,
  }),
);

/** `GET /units/{id}/diagnostics` — `404`. */
export const unitDiagnosticsNotFoundHandler = http.get(url('/units/:id/diagnostics'), () =>
  jsonError('NOT_FOUND', 'Unit not found', 404),
);

/** `GET /units/{id}/history` — muvaffaqiyatli. */
export const unitHistoryHandler = http.get(url('/units/:id/history'), () =>
  HttpResponse.json({
    data: [
      {
        id: 'hist-1',
        kind: 'audit',
        action: 'update',
        field: 'status',
        old_value: '"inactive"',
        new_value: '"active"',
        actor_id: 'user-1',
        actor_name: 'Jane Admin',
        at: '2026-09-06T05:12:00Z',
      },
    ] satisfies UnitHistoryEntry[],
    meta: listMeta(),
  } satisfies ListResponse<UnitHistoryEntry>),
);

/** `GET /units/{id}/history` — `404`. */
export const unitHistoryNotFoundHandler = http.get(url('/units/:id/history'), () =>
  jsonError('NOT_FOUND', 'Unit not found', 404),
);

/** `GET /units/export` — muvaffaqiyatli (CSV blob). */
export const unitsExportHandler = http.get(
  url('/units/export'),
  () =>
    new HttpResponse('unit_number,make,model\n1021,Freightliner,Cascadia\n', {
      status: 200,
      headers: { 'Content-Type': 'text/csv' },
    }),
);

/** `GET /units/export` — `403` (`units.export` yo'q). */
export const unitsExportForbiddenHandler = http.get(url('/units/export'), () =>
  jsonError('FORBIDDEN', 'Missing permission units.export', 403),
);

/** `GET /units/import-template` — muvaffaqiyatli (CSV blob). */
export const unitsImportTemplateHandler = http.get(
  url('/units/import-template'),
  () =>
    new HttpResponse(
      'unit_number,make,model,year,plate,plate_region,vin,fuel_type,sleeper_berth\n',
      {
        status: 200,
        headers: { 'Content-Type': 'text/csv' },
      },
    ),
);

/** `POST /units/import` — muvaffaqiyatli (hech qanday qator xatosiz). */
export const unitsImportHandler = http.post(url('/units/import'), () =>
  HttpResponse.json({
    data: { imported: 3, total: 3, errors: [] } satisfies ImportResult,
  }),
);

/**
 * `POST /units/import` — `422` all-or-nothing (F83, D-f9). `errors[]`
 * `client.ts`ning `errorMiddleware`si orqali `ApiError.payload`da saqlanadi
 * va `useUnitsImport` uni `ImportResult` sifatida qaytaradi (bu javobda bir
 * qator xato ko'rsatilgan, real hollarda hammasi ro'yxatlanadi).
 */
export const unitsImportValidationErrorHandler = http.post(url('/units/import'), () =>
  HttpResponse.json(
    {
      data: {
        imported: 0,
        total: 3,
        errors: [
          { row: 2, field: 'unit_number', message: 'required' },
          { row: 3, field: 'vin', message: 'must be 17 characters' },
        ],
      } satisfies ImportResult,
    },
    { status: 422 },
  ),
);

/** Bazaviy to'plam — ro'yxat + CRUD muvaffaqiyat holatlari. */
export const unitsBaseHandlers = [
  unitsListHandler,
  unitGetHandler,
  unitCreateHandler,
  unitUpdateHandler,
  unitDeleteHandler,
];
