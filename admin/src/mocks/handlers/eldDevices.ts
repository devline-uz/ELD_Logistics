/**
 * ELD Devices — MSW handler'lari (2.1, fe-testing §MSW). Har endpoint uchun
 * muvaffaqiyat + xato varianti.
 */
import { http, HttpResponse } from 'msw';

import type { EldDevice, ListResponse } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function eldDeviceFixture(overrides: Partial<EldDevice> = {}): EldDevice {
  return {
    id: 'eld-1',
    serial: 'ELD-000123',
    vendor: 'Geotab',
    model: 'GO9',
    firmware: '4.12.1',
    connection_type: 'cellular',
    status: 'active',
    sim_present: true,
    malfunction_codes: [],
    last_seen_at: '2026-09-06T05:12:00Z',
    created_at: '2026-01-14T09:00:00Z',
    ...overrides,
  };
}

/** `GET /eld-devices` — muvaffaqiyatli. */
export const eldDevicesListHandler = http.get(url('/eld-devices'), () =>
  HttpResponse.json({
    data: [eldDeviceFixture()],
    meta: listMeta(),
  } satisfies ListResponse<EldDevice>),
);

/** `GET /eld-devices` — bo'sh natija. */
export const eldDevicesListEmptyHandler = http.get(url('/eld-devices'), () =>
  HttpResponse.json({ data: [], meta: listMeta({ total: 0 }) } satisfies ListResponse<EldDevice>),
);

/** `GET /eld-devices` — `422`. */
export const eldDevicesListErrorHandler = http.get(url('/eld-devices'), () =>
  jsonError('VALIDATION_ERROR', 'per_page must be 10, 25 or 50', 422),
);

/** `GET /eld-devices/{id}` — muvaffaqiyatli. */
export const eldDeviceGetHandler = http.get(url('/eld-devices/:id'), ({ params }) =>
  HttpResponse.json({ data: eldDeviceFixture({ id: params.id as string }) }),
);

/** `GET /eld-devices/{id}` — cross-tenant → `404`. */
export const eldDeviceGetNotFoundHandler = http.get(url('/eld-devices/:id'), () =>
  jsonError('NOT_FOUND', 'ELD device not found', 404),
);

/** `POST /eld-devices` — muvaffaqiyatli (`201`). */
export const eldDeviceCreateHandler = http.post(url('/eld-devices'), () =>
  HttpResponse.json({ data: eldDeviceFixture({ id: 'eld-new' }) }, { status: 201 }),
);

/** `POST /eld-devices` — `409` (`serial` band yoki nofaol unit). */
export const eldDeviceCreateConflictHandler = http.post(url('/eld-devices'), () =>
  jsonError('CONFLICT', 'serial already in use', 409),
);

/** `PATCH /eld-devices/{id}` — muvaffaqiyatli. */
export const eldDeviceUpdateHandler = http.patch(url('/eld-devices/:id'), ({ params }) =>
  HttpResponse.json({ data: eldDeviceFixture({ id: params.id as string }) }),
);

/** `PATCH /eld-devices/{id}` — `404`. */
export const eldDeviceUpdateNotFoundHandler = http.patch(url('/eld-devices/:id'), () =>
  jsonError('NOT_FOUND', 'ELD device not found', 404),
);

/** `DELETE /eld-devices/{id}` — muvaffaqiyatli (`204`). */
export const eldDeviceDeleteHandler = http.delete(
  url('/eld-devices/:id'),
  () => new HttpResponse(null, { status: 204 }),
);

/** `DELETE /eld-devices/{id}` — `409 RESOURCE_IN_USE`. */
export const eldDeviceDeleteConflictHandler = http.delete(url('/eld-devices/:id'), () =>
  jsonError('CONFLICT', 'ELD device is in use', 409),
);

/** `POST /eld-devices/{id}/assign-unit` — muvaffaqiyatli. */
export const eldDeviceAssignUnitHandler = http.post(
  url('/eld-devices/:id/assign-unit'),
  ({ params }) =>
    HttpResponse.json({
      data: eldDeviceFixture({ id: params.id as string }),
    }),
);

/** `POST /eld-devices/{id}/assign-unit` — `409 ALREADY_ASSIGNED` / `INVALID_STATE`. */
export const eldDeviceAssignUnitConflictHandler = http.post(
  url('/eld-devices/:id/assign-unit'),
  () => jsonError('CONFLICT', 'Unit already has an active device', 409),
);

/** Bazaviy to'plam — ro'yxat + CRUD muvaffaqiyat holatlari. */
export const eldDevicesBaseHandlers = [
  eldDevicesListHandler,
  eldDeviceGetHandler,
  eldDeviceCreateHandler,
  eldDeviceUpdateHandler,
  eldDeviceDeleteHandler,
];
