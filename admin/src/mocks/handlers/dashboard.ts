/**
 * Dashboard — MSW handler'lari (Bosqich 7, fe-testing §MSW). Har endpoint
 * uchun muvaffaqiyat + xato varianti.
 */
import { http, HttpResponse } from 'msw';

import type { DashboardSummary } from '@/api/types';

import { jsonError, url } from './shared';

export function dashboardSummaryFixture(
  overrides: Partial<DashboardSummary> = {},
): DashboardSummary {
  return {
    generated_at: '2026-09-06T18:05:00Z',
    timezone: 'America/Chicago',
    day: { from: '2026-09-06T05:00:00Z', to: '2026-09-07T05:00:00Z' },
    week: { from: '2026-08-31T05:00:00Z', to: '2026-09-07T05:00:00Z' },
    kpi: {
      active_units: 38,
      active_drivers: 44,
      drivers_on_duty: 21,
      violations: 4,
      uncertified_logs: 6,
      unassigned_driving: 3,
      disconnected_eld: 2,
      malfunction_eld: 1,
      pending_log_edits: 2,
    },
    status: { on: 9, dr: 12, sb: 5, off: 18 },
    routes: [
      {
        id: '6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f',
        sequence: 1,
        driver_id: '1f9d7c2a-4c66-4c2f-9d2f-9a0b7d1e2f34',
        driver_name: 'John Doe',
        unit_id: '2b7c8d9e-1122-3344-5566-778899aabbcc',
        unit_number: '1021',
        origin: 'Dallas, TX',
        destination: 'Oklahoma City, OK',
        status: 'in_progress',
        created_at: '2026-09-06T11:00:00Z',
        started_at: '2026-09-06T13:05:00Z',
      },
    ],
    ...overrides,
  };
}

/** `GET /dashboard/summary` — muvaffaqiyatli. */
export const dashboardSummaryHandler = http.get(url('/dashboard/summary'), () =>
  HttpResponse.json({ data: dashboardSummaryFixture() }),
);

/** `GET /dashboard/summary` — bo'sh (yangi kompaniya, marshrutsiz kun). */
export const dashboardSummaryEmptyHandler = http.get(url('/dashboard/summary'), () =>
  HttpResponse.json({
    data: dashboardSummaryFixture({
      routes: [],
      kpi: {
        active_units: 0,
        active_drivers: 0,
        drivers_on_duty: 0,
        violations: 0,
        uncertified_logs: 0,
        unassigned_driving: 0,
        disconnected_eld: 0,
        malfunction_eld: 0,
        pending_log_edits: 0,
      },
      status: { on: 0, dr: 0, sb: 0, off: 0 },
    }),
  }),
);

/** `GET /dashboard/summary` — `429`. */
export const dashboardSummaryErrorHandler = http.get(url('/dashboard/summary'), () =>
  jsonError('RATE_LIMITED', 'too many requests', 429),
);

/** Bazaviy to'plam — dev/e2e mock rejimi uchun. */
export const dashboardBaseHandlers = [dashboardSummaryHandler];
