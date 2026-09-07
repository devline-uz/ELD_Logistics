/**
 * Maintenance — MSW handler'lari (5.1, fe-testing §MSW). Har endpoint uchun
 * muvaffaqiyat + xato varianti; ro'yxat `{data, meta}` konverti.
 */
import { http, HttpResponse } from 'msw';

import type { MaintenanceRecord, MaintenanceSchedule, MaintenanceScheduleUnit } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function maintenanceScheduleFixture(
  overrides: Partial<MaintenanceSchedule> = {},
): MaintenanceSchedule {
  return {
    id: 'schedule-1',
    name: 'Engine oil change',
    type: 'oil_change',
    status: 'active',
    interval_unit: 'km',
    interval_value: 25000,
    reminder_before_value: 1000,
    alert_type: 'notification',
    delivery_methods: ['push', 'email'],
    notify_co_driver: true,
    unit_count: 1,
    created_at: '2026-09-06T05:12:00Z',
    updated_at: '2026-09-06T05:12:00Z',
    ...overrides,
  } as MaintenanceSchedule;
}

export function maintenanceScheduleUnitFixture(
  overrides: Partial<MaintenanceScheduleUnit> = {},
): MaintenanceScheduleUnit {
  return {
    id: 'schedule-unit-1',
    schedule_id: 'schedule-1',
    schedule_name: 'Engine oil change',
    schedule_type: 'oil_change',
    unit_id: 'unit-1',
    unit_number: '1021',
    status: 'due',
    interval_unit: 'km',
    interval_value: 25000,
    last_service_value: 103430,
    next_due_value: 128430,
    current_value: 127100,
    remaining: 1330,
    overdue: false,
    reminder_due: false,
    ...overrides,
  } as MaintenanceScheduleUnit;
}

export function maintenanceRecordFixture(
  overrides: Partial<MaintenanceRecord> = {},
): MaintenanceRecord {
  return {
    id: 'record-1',
    schedule_unit_id: 'schedule-unit-1',
    unit_id: 'unit-1',
    unit_number: '1021',
    status: 'completed',
    invoice_no: 'INV-10233',
    vendor: 'Dallas Truck Service',
    cost: 420.5,
    currency: 'USD',
    performed_at: '2026-09-06T15:04:05Z',
    created_at: '2026-09-06T15:04:05Z',
    ...overrides,
  } as MaintenanceRecord;
}

/* ------------------------------------------------------------------ *
 * Schedule tab — `/maintenance-schedules`
 * ------------------------------------------------------------------ */

/** `GET /maintenance-schedules` — muvaffaqiyatli. */
export const maintenanceSchedulesListHandler = http.get(url('/maintenance-schedules'), () =>
  HttpResponse.json({ data: [maintenanceScheduleFixture()], meta: listMeta() }),
);

/** `GET /maintenance-schedules` — `422`. */
export const maintenanceSchedulesListErrorHandler = http.get(
  url('/maintenance-schedules'),
  () => jsonError('VALIDATION_ERROR', 'invalid status filter', 422),
);

/** `GET /maintenance-schedules/{id}` — muvaffaqiyatli. */
export const maintenanceScheduleGetHandler = http.get(
  url('/maintenance-schedules/:id'),
  ({ params }) =>
    HttpResponse.json({ data: maintenanceScheduleFixture({ id: params.id as string }) }),
);

/** `GET /maintenance-schedules/{id}` — `404`. */
export const maintenanceScheduleGetNotFoundHandler = http.get(
  url('/maintenance-schedules/:id'),
  () => jsonError('NOT_FOUND', 'Maintenance schedule not found', 404),
);

/** `POST /maintenance-schedules` — muvaffaqiyatli yaratish. */
export const maintenanceScheduleCreateHandler = http.post(url('/maintenance-schedules'), () =>
  HttpResponse.json(
    { data: maintenanceScheduleFixture({ id: 'schedule-new' }) },
    { status: 201 },
  ),
);

/** `POST /maintenance-schedules` — `422` (majburiy maydon yo'q). */
export const maintenanceScheduleCreateValidationErrorHandler = http.post(
  url('/maintenance-schedules'),
  () =>
    jsonError('VALIDATION_ERROR', 'validation failed', 422, [
      { field: 'name', message: 'required' },
    ]),
);

/** `PATCH /maintenance-schedules/{id}` — muvaffaqiyatli. */
export const maintenanceScheduleUpdateHandler = http.patch(
  url('/maintenance-schedules/:id'),
  ({ params }) =>
    HttpResponse.json({ data: maintenanceScheduleFixture({ id: params.id as string }) }),
);

/** `PATCH /maintenance-schedules/{id}` — `404`. */
export const maintenanceScheduleUpdateNotFoundHandler = http.patch(
  url('/maintenance-schedules/:id'),
  () => jsonError('NOT_FOUND', 'Maintenance schedule not found', 404),
);

/** `DELETE /maintenance-schedules/{id}` — muvaffaqiyatli (`204`). */
export const maintenanceScheduleDeleteHandler = http.delete(
  url('/maintenance-schedules/:id'),
  () => new HttpResponse(null, { status: 204 }),
);

/** `DELETE /maintenance-schedules/{id}` — `404`. */
export const maintenanceScheduleDeleteNotFoundHandler = http.delete(
  url('/maintenance-schedules/:id'),
  () => jsonError('NOT_FOUND', 'Maintenance schedule not found', 404),
);

/* ------------------------------------------------------------------ *
 * Due tab — `/maintenance/due` (+ `/maintenance-schedule-units/{id}`)
 * ------------------------------------------------------------------ */

/** `GET /maintenance/due` — muvaffaqiyatli. */
export const maintenanceDueListHandler = http.get(url('/maintenance/due'), () =>
  HttpResponse.json({ data: [maintenanceScheduleUnitFixture()], meta: listMeta() }),
);

/** `GET /maintenance/due` — bo'sh natija. */
export const maintenanceDueListEmptyHandler = http.get(url('/maintenance/due'), () =>
  HttpResponse.json({ data: [], meta: listMeta({ total: 0 }) }),
);

/** `GET /maintenance/due` — `422`. */
export const maintenanceDueListErrorHandler = http.get(url('/maintenance/due'), () =>
  jsonError('VALIDATION_ERROR', 'invalid status filter', 422),
);

/** `GET /maintenance-schedule-units/{id}` — muvaffaqiyatli. */
export const maintenanceScheduleUnitGetHandler = http.get(
  url('/maintenance-schedule-units/:id'),
  ({ params }) =>
    HttpResponse.json({ data: maintenanceScheduleUnitFixture({ id: params.id as string }) }),
);

/** `GET /maintenance-schedule-units/{id}` — `404`. */
export const maintenanceScheduleUnitGetNotFoundHandler = http.get(
  url('/maintenance-schedule-units/:id'),
  () => jsonError('NOT_FOUND', 'Maintenance schedule unit not found', 404),
);

/** `POST /maintenance-schedule-units/{id}/complete` — muvaffaqiyatli. */
export const maintenanceCompleteHandler = http.post(
  url('/maintenance-schedule-units/:id/complete'),
  ({ params }) =>
    HttpResponse.json({
      data: maintenanceScheduleUnitFixture({
        id: params.id as string,
        status: 'completed',
        last_service_value: 127100,
        next_due_value: 152100,
        remaining: 25000,
        overdue: false,
      }),
    }),
);

/** `POST /maintenance-schedule-units/{id}/complete` — `409` (allaqachon yopilgan). */
export const maintenanceCompleteConflictHandler = http.post(
  url('/maintenance-schedule-units/:id/complete'),
  () => jsonError('MAINTENANCE_INVALID_STATE', 'Row is already completed or cancelled', 409),
);

/** `POST /maintenance-schedule-units/{id}/complete` — `422` (telemetriya yo'q). */
export const maintenanceCompleteNoReadingHandler = http.post(
  url('/maintenance-schedule-units/:id/complete'),
  () => jsonError('MAINTENANCE_NO_READING', 'Unit has never reported telemetry', 422),
);

/** `POST /maintenance-schedule-units/{id}/cancel` — muvaffaqiyatli. */
export const maintenanceCancelHandler = http.post(
  url('/maintenance-schedule-units/:id/cancel'),
  ({ params }) =>
    HttpResponse.json({
      data: maintenanceScheduleUnitFixture({
        id: params.id as string,
        status: 'cancelled',
        cancelled_reason: 'Unit sold',
      }),
    }),
);

/** `POST /maintenance-schedule-units/{id}/cancel` — `409` (allaqachon yopilgan). */
export const maintenanceCancelConflictHandler = http.post(
  url('/maintenance-schedule-units/:id/cancel'),
  () => jsonError('MAINTENANCE_INVALID_STATE', 'Row is already completed or cancelled', 409),
);

/* ------------------------------------------------------------------ *
 * History tab — `/maintenance-records`
 * ------------------------------------------------------------------ */

/** `GET /maintenance-records` — muvaffaqiyatli. */
export const maintenanceRecordsListHandler = http.get(url('/maintenance-records'), () =>
  HttpResponse.json({ data: [maintenanceRecordFixture()], meta: listMeta() }),
);

/** `GET /maintenance-records` — bo'sh natija. */
export const maintenanceRecordsListEmptyHandler = http.get(url('/maintenance-records'), () =>
  HttpResponse.json({ data: [], meta: listMeta({ total: 0 }) }),
);

/** `GET /maintenance-records` — `422`. */
export const maintenanceRecordsListErrorHandler = http.get(url('/maintenance-records'), () =>
  jsonError('VALIDATION_ERROR', 'invalid status filter', 422),
);

/** Bazaviy to'plam — har uch tab + CRUD muvaffaqiyat holatlari. */
export const maintenanceBaseHandlers = [
  maintenanceSchedulesListHandler,
  maintenanceScheduleGetHandler,
  maintenanceScheduleCreateHandler,
  maintenanceScheduleUpdateHandler,
  maintenanceScheduleDeleteHandler,
  maintenanceDueListHandler,
  maintenanceScheduleUnitGetHandler,
  maintenanceRecordsListHandler,
];
