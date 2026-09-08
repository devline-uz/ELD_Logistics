/**
 * Reports — MSW handler'lari (Bosqich 6.1, fe-testing §MSW). Har endpoint uchun
 * muvaffaqiyat + xato varianti; export job uchun holat o'zgarishini simulyatsiya
 * qiladigan handler (`queued → running → done`, fe-api §9).
 */
import { http, HttpResponse } from 'msw';

import type {
  ActivityRow,
  DistanceByRegionMeta,
  ExportJob,
  ListResponse,
  RegionDistanceRow,
  UncertifiedLog,
} from '@/api/types';

import { jsonError, listMeta, url } from './shared';

/* ------------------------------------------------------------------ *
 * Activity Report (7.8.1)
 * ------------------------------------------------------------------ */

export function activityRowFixture(overrides: Partial<ActivityRow> = {}): ActivityRow {
  return {
    subject_id: 'unit-1',
    subject_type: 'units',
    name: '1021',
    start_odometer_m: 128_430_000,
    end_odometer_m: 129_180_000,
    odometer_change_m: 750_000,
    has_data: true,
    ...overrides,
  };
}

/** `GET /reports/activity` — muvaffaqiyatli. */
export const reportsActivityHandler = http.get(url('/reports/activity'), () =>
  HttpResponse.json({
    data: [activityRowFixture()],
    meta: listMeta(),
  } satisfies ListResponse<ActivityRow>),
);

/** `GET /reports/activity` — `422` (masalan majburiy `from/to` yo'q). */
export const reportsActivityErrorHandler = http.get(url('/reports/activity'), () =>
  jsonError('VALIDATION_ERROR', 'from and to are required', 422, [
    { field: 'from', message: 'required' },
  ]),
);

/* ------------------------------------------------------------------ *
 * Distance by Region / IFTA (7.8.2)
 * ------------------------------------------------------------------ */

export function regionDistanceRowFixture(
  overrides: Partial<RegionDistanceRow> = {},
): RegionDistanceRow {
  return {
    region_code: 'US-IL',
    region_name: 'Illinois',
    country: 'US',
    distance_m: 412_345,
    unit_id: 'unit-1',
    unit_number: '1021',
    ...overrides,
  };
}

export function distanceByRegionMetaFixture(
  overrides: Partial<DistanceByRegionMeta> = {},
): DistanceByRegionMeta {
  return {
    quarter: 3,
    year: 2026,
    from: '2026-07-01',
    to: '2026-09-30',
    mode: 'regions_and_units',
    total_distance_m: 9_184_320,
    ...overrides,
  };
}

/** `GET /reports/distance-by-region` — muvaffaqiyatli. */
export const reportsDistanceByRegionHandler = http.get(url('/reports/distance-by-region'), () =>
  HttpResponse.json({
    data: [regionDistanceRowFixture()],
    meta: distanceByRegionMetaFixture(),
  }),
);

/** `GET /reports/distance-by-region` — `422` (majburiy `quarter/year` yo'q). */
export const reportsDistanceByRegionErrorHandler = http.get(
  url('/reports/distance-by-region'),
  () =>
    jsonError('VALIDATION_ERROR', 'quarter and year are required', 422, [
      { field: 'quarter', message: 'required' },
    ]),
);

/* ------------------------------------------------------------------ *
 * Uncertified Logs (7.8.5)
 * ------------------------------------------------------------------ */

export function uncertifiedLogFixture(overrides: Partial<UncertifiedLog> = {}): UncertifiedLog {
  return {
    daily_log_id: 'log-1',
    driver_id: 'driver-1',
    driver_name: 'Ali Karimov',
    log_date: '2026-08-20',
    certification_status: 'uncertified',
    days_overdue: 3,
    ...overrides,
  };
}

/** `GET /reports/uncertified-logs` — muvaffaqiyatli. */
export const reportsUncertifiedLogsHandler = http.get(url('/reports/uncertified-logs'), () =>
  HttpResponse.json({
    data: [uncertifiedLogFixture()],
    meta: listMeta(),
  } satisfies ListResponse<UncertifiedLog>),
);

/** `GET /reports/uncertified-logs` — `422`. */
export const reportsUncertifiedLogsErrorHandler = http.get(url('/reports/uncertified-logs'), () =>
  jsonError('VALIDATION_ERROR', 'invalid driver_id', 422),
);

/* ------------------------------------------------------------------ *
 * Export Jobs (7.8.3 / 7.8.7, fe-api §9)
 * ------------------------------------------------------------------ */

export function exportJobFixture(overrides: Partial<ExportJob> = {}): ExportJob {
  return {
    id: 'job-1',
    type: 'distance_by_region',
    format: 'xlsx',
    status: 'queued',
    requested_by: 'user-1',
    created_at: '2026-09-06T05:12:00Z',
    ...overrides,
  };
}

/** `GET /reports/export-jobs` — muvaffaqiyatli, `mine=true` bo'yicha bitta yozuv. */
export const exportJobsListHandler = http.get(url('/reports/export-jobs'), () =>
  HttpResponse.json({
    data: [exportJobFixture()],
    meta: listMeta(),
  } satisfies ListResponse<ExportJob>),
);

/** `GET /reports/export-jobs` — `422`. */
export const exportJobsListErrorHandler = http.get(url('/reports/export-jobs'), () =>
  jsonError('VALIDATION_ERROR', 'unsupported type', 422),
);

/** `POST /reports/export-jobs` — `202 {id, status:"queued"}` (fe-api §9). */
export const exportJobCreateHandler = http.post(url('/reports/export-jobs'), () =>
  HttpResponse.json(
    { data: exportJobFixture({ id: 'job-new', status: 'queued' }) },
    { status: 202 },
  ),
);

/** `POST /reports/export-jobs` — `422` (masalan noto'g'ri `format`). */
export const exportJobCreateErrorHandler = http.post(url('/reports/export-jobs'), () =>
  jsonError('VALIDATION_ERROR', 'format is not allowed for this type', 422, [
    { field: 'format', message: 'invalid' },
  ]),
);

/**
 * `POST /reports/export-jobs` — `501 FEATURE_DISABLED` (F127): `regulator` turi
 * FMCSA profillarida (masalan `us_fmcsa`) FMCSA fayl/web-service tayyor bo'lguncha
 * shu xato bilan javob beradi.
 */
export const exportJobCreateFeatureDisabledHandler = http.post(url('/reports/export-jobs'), () =>
  jsonError('FEATURE_DISABLED', 'FMCSA export is not available yet', 501),
);

/** `GET /reports/export-jobs/{id}` — bitta so'rovda `done` (statik holat). */
export const exportJobDoneHandler = http.get(url('/reports/export-jobs/:id'), ({ params }) =>
  HttpResponse.json({
    data: exportJobFixture({
      id: params.id as string,
      status: 'done',
      started_at: '2026-09-06T05:12:03Z',
      finished_at: '2026-09-06T05:12:31Z',
      download_url: 'https://storage.example.com/onebook/job-1.xlsx',
      expires_at: '2026-09-07T05:12:31Z',
      file_name: 'distance-by-region-2026-Q3.xlsx',
      file_size_b: 20_480,
    }),
  }),
);

/** `GET /reports/export-jobs/{id}` — bitta so'rovda `failed`. */
export const exportJobFailedHandler = http.get(url('/reports/export-jobs/:id'), ({ params }) =>
  HttpResponse.json({
    data: exportJobFixture({
      id: params.id as string,
      status: 'failed',
      started_at: '2026-09-06T05:12:03Z',
      finished_at: '2026-09-06T05:12:09Z',
      error: 'the map provider is unavailable',
    }),
  }),
);

/** `GET /reports/export-jobs/{id}` — `done`, lekin `expires_at` o'tib ketgan (Q75). */
export const exportJobDoneExpiredHandler = http.get(url('/reports/export-jobs/:id'), ({ params }) =>
  HttpResponse.json({
    data: exportJobFixture({
      id: params.id as string,
      status: 'done',
      started_at: '2026-09-04T05:12:03Z',
      finished_at: '2026-09-04T05:12:31Z',
      download_url: 'https://storage.example.com/onebook/job-1.xlsx',
      expires_at: '2026-09-05T05:12:31Z',
    }),
  }),
);

/** `GET /reports/export-jobs/{id}` — `404` (boshqa kompaniyaning job'i, fe-api §1). */
export const exportJobNotFoundHandler = http.get(url('/reports/export-jobs/:id'), () =>
  jsonError('NOT_FOUND', 'export job not found', 404),
);

/**
 * `GET /reports/export-jobs/{id}` — pollingni sinash uchun holat o'zgarishini
 * simulyatsiya qiladi: 1-chaqiruv `queued`, 2-chaqiruv `running`, 3-chaqiruv va undan
 * keyingisi `done` (`download_url` bilan). Har `server.use(...)` chaqiruvi yangi hisoblagich
 * bilan boshlanishi uchun har testda alohida yaratiladi.
 */
export function createExportJobProgressionHandler() {
  let callCount = 0;
  return http.get(url('/reports/export-jobs/:id'), ({ params }) => {
    callCount += 1;
    const id = params.id as string;
    if (callCount === 1) {
      return HttpResponse.json({ data: exportJobFixture({ id, status: 'queued' }) });
    }
    if (callCount === 2) {
      return HttpResponse.json({
        data: exportJobFixture({ id, status: 'running', started_at: '2026-09-06T05:12:03Z' }),
      });
    }
    return HttpResponse.json({
      data: exportJobFixture({
        id,
        status: 'done',
        started_at: '2026-09-06T05:12:03Z',
        finished_at: '2026-09-06T05:12:31Z',
        download_url: 'https://storage.example.com/onebook/job-1.xlsx',
        expires_at: '2026-09-07T05:12:31Z',
      }),
    });
  });
}
