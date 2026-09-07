/**
 * Logs — MSW handler'lari (3.1, fe-testing §MSW). Har endpoint uchun
 * muvaffaqiyat + xato varianti; ro'yxat `{data, meta}` konverti.
 */
import { http, HttpResponse } from 'msw';

import type { DailyLogDetail, DailyLogSummary, ListResponse, LiveUnit } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function liveUnitFixture(overrides: Partial<LiveUnit> = {}): LiveUnit {
  return {
    unit_id: 'unit-1',
    unit_number: '1021',
    driver: { id: 'driver-1', first_name: 'John', last_name: 'Doe' },
    duty_status: 'DR',
    online_status: 'online',
    out_of_service: false,
    lat: 32.7767,
    lng: -96.797,
    speed_kmh: 88,
    odometer_m: 145_320_000,
    last_seen_at: '2026-09-07T12:00:00Z',
    ...overrides,
  };
}

export function dailyLogSummaryFixture(overrides: Partial<DailyLogSummary> = {}): DailyLogSummary {
  return {
    id: 'daily-log-1',
    driver_id: 'driver-1',
    driver_name: 'John Doe',
    unit_ids: ['unit-1'],
    log_date: '2026-09-06',
    distance_m: 482_000,
    totals: { off_min: 480, sb_min: 120, drive_min: 600, on_min: 240 },
    certification_status: 'certified',
    ready: true,
    signed_at: '2026-09-06T22:00:00Z',
    timezone: 'America/Chicago',
    updated_at: '2026-09-06T22:00:00Z',
    ...overrides,
  };
}

export function dailyLogDetailFixture(overrides: Partial<DailyLogDetail> = {}): DailyLogDetail {
  return {
    ...dailyLogSummaryFixture(),
    events: [
      {
        id: 'event-1',
        status: 'DR',
        event_time: '2026-09-06T13:00:00Z',
        origin: 'auto',
        locked: true,
        unit_id: 'unit-1',
        unit_number: '1021',
      },
    ],
    form: {
      driver_name: 'John Doe',
      distance_m: 482_000,
      units: [{ id: 'unit-1', unit_number: '1021' }],
      trailers: [],
      shipping_docs: [],
    },
    violations: [],
    ...overrides,
  };
}

/** `GET /tracking/live` — muvaffaqiyatli. */
export const trackingLiveHandler = http.get(url('/tracking/live'), () =>
  HttpResponse.json({
    data: [liveUnitFixture()],
    meta: listMeta(),
  } satisfies ListResponse<LiveUnit>),
);

/** `GET /tracking/live` — `403` (`tracking.view_live` yo'q). */
export const trackingLiveForbiddenHandler = http.get(url('/tracking/live'), () =>
  jsonError('FORBIDDEN', 'Missing permission tracking.view_live', 403),
);

/** `GET /drivers/{id}/daily-logs` — muvaffaqiyatli. */
export const driverDailyLogsHandler = http.get(url('/drivers/:id/daily-logs'), ({ params }) =>
  HttpResponse.json({
    data: [dailyLogSummaryFixture({ driver_id: params.id as string })],
    meta: listMeta(),
  } satisfies ListResponse<DailyLogSummary>),
);

/** `GET /drivers/{id}/daily-logs` — cross-tenant → `404`. */
export const driverDailyLogsNotFoundHandler = http.get(url('/drivers/:id/daily-logs'), () =>
  jsonError('NOT_FOUND', 'Driver not found', 404),
);

/** `GET /daily-logs/{id}` — muvaffaqiyatli. */
export const dailyLogGetHandler = http.get(url('/daily-logs/:id'), ({ params }) =>
  HttpResponse.json({ data: dailyLogDetailFixture({ id: params.id as string }) }),
);

/** `GET /daily-logs/{id}` — `404`. */
export const dailyLogGetNotFoundHandler = http.get(url('/daily-logs/:id'), () =>
  jsonError('NOT_FOUND', 'Daily log not found', 404),
);

/** `POST /daily-logs/{id}/certify` — muvaffaqiyatli. */
export const dailyLogCertifyHandler = http.post(url('/daily-logs/:id/certify'), ({ params }) =>
  HttpResponse.json({
    data: dailyLogDetailFixture({ id: params.id as string, certification_status: 'certified' }),
  }),
);

/** `POST /daily-logs/{id}/certify` — `409 LOG_NOT_READY` (imzo manbai yo'q). */
export const dailyLogCertifyNotReadyHandler = http.post(url('/daily-logs/:id/certify'), () =>
  jsonError('LOG_NOT_READY', 'No signature source available', 409),
);

/** `POST /daily-logs/{id}/events` — muvaffaqiyatli (haydovchining o'z tuzatishi). */
export const dailyLogAddEventHandler = http.post(url('/daily-logs/:id/events'), ({ params }) =>
  HttpResponse.json({ data: dailyLogDetailFixture({ id: params.id as string }) }),
);

/** `POST /daily-logs/{id}/events` — `409 DR_IMMUTABLE`. */
export const dailyLogAddEventImmutableHandler = http.post(url('/daily-logs/:id/events'), () =>
  jsonError('DR_IMMUTABLE', 'Automatically recorded DR cannot be shortened', 409),
);

/** `GET /daily-logs/{id}/pdf` — muvaffaqiyatli (PDF blob). */
export const dailyLogPdfHandler = http.get(
  url('/daily-logs/:id/pdf'),
  () =>
    new HttpResponse(new Blob([new Uint8Array([0x25, 0x50, 0x44, 0x46])]), {
      status: 200,
      headers: { 'Content-Type': 'application/pdf' },
    }),
);

/** `GET /daily-logs/{id}/pdf` — `403` (`logs.export` yo'q). */
export const dailyLogPdfForbiddenHandler = http.get(url('/daily-logs/:id/pdf'), () =>
  jsonError('FORBIDDEN', 'Missing permission logs.export', 403),
);
