/**
 * Inspection logs — MSW handler'lari (Bosqich 8.11, fe-testing §MSW).
 */
import { http, HttpResponse } from 'msw';

import type {
  DailyLogDetail,
  InspectionReport,
  InspectionReportEnvelope,
  InspectionTransferResult,
  MessageEnvelope,
} from '@/api/types';

import { jsonError, url } from './shared';

export function dailyLogDetailFixture(overrides: Partial<DailyLogDetail> = {}): DailyLogDetail {
  return {
    id: '4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0',
    driver_id: 'driver-1',
    driver_name: 'Ali Karimov',
    log_date: '2026-09-06',
    timezone: 'America/Chicago',
    distance_m: 412000,
    certification_status: 'certified',
    signed_at: '2026-09-06T23:50:00Z',
    ready: true,
    unit_ids: ['6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f'],
    events: [],
    violations: [],
    updated_at: '2026-09-06T23:50:01Z',
    ...overrides,
  };
}

export function inspectionReportFixture(
  overrides: Partial<InspectionReport> = {},
): InspectionReport {
  return {
    driver_id: 'driver-1',
    driver_name: 'Ali Karimov',
    carrier_name: 'ONEBOOK Logistics',
    home_terminal_address: '1200 Industrial Rd, Dallas, TX',
    regulation_profile: 'generic',
    timezone: 'America/Chicago',
    from: '2026-08-30',
    to: '2026-09-06',
    generated_at: '2026-09-06T18:00:00Z',
    days: [dailyLogDetailFixture()],
    ...overrides,
  };
}

/** `GET /inspection/logs` — muvaffaqiyatli. */
export const inspectionLogsHandler = http.get(url('/inspection/logs'), () =>
  HttpResponse.json({ data: inspectionReportFixture() } satisfies InspectionReportEnvelope),
);

/** `GET /inspection/logs` — kunlar bo'sh (haydovchi tanlangan, oynada log yo'q). */
export const inspectionLogsEmptyHandler = http.get(url('/inspection/logs'), () =>
  HttpResponse.json({
    data: inspectionReportFixture({ days: [] }),
  } satisfies InspectionReportEnvelope),
);

/** `GET /inspection/logs` — `403` (`inspection.view` yo'q). */
export const inspectionLogsErrorHandler = http.get(url('/inspection/logs'), () =>
  jsonError('FORBIDDEN', 'inspection.view required', 403),
);

/** `POST /inspection/email` — `202 Accepted`. */
export const inspectionEmailSendHandler = http.post(url('/inspection/email'), () =>
  HttpResponse.json({ data: { message: 'Report queued for delivery' } } satisfies MessageEnvelope, {
    status: 202,
  }),
);

/** `POST /inspection/email` — `422` (noto'g'ri email). */
export const inspectionEmailSendErrorHandler = http.post(url('/inspection/email'), () =>
  jsonError('VALIDATION_ERROR', 'invalid email', 422, [
    { field: 'email', message: 'must be a valid email address' },
  ]),
);

/** `POST /inspection/transfer` — muvaffaqiyatli. */
export const inspectionTransferHandler = http.post(url('/inspection/transfer'), () =>
  HttpResponse.json({
    data: {
      file_key: 'companies/6f1a/inspection/2026/09/eld-output.zip',
      format: 'csv_pdf_zip',
      generated_at: '2026-09-06T18:00:00Z',
      regulation_profile: 'generic',
      size_bytes: 48213,
    } satisfies InspectionTransferResult,
  }),
);
