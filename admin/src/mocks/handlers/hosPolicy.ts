/**
 * HOS Policy — MSW handler'lari (Bosqich 8.1, fe-testing §MSW). Versiyalar
 * tarixi `GET /company/history` ustida (`hosPolicy.ts` izohiga qarang), shu
 * sababli bu faylda ham o'sha yo'l uchun handler bor — `companyHistory*`
 * handler'laridan mustaqil (parametrga qarab tanlanadi, MSW yo'l darajasida
 * farqlamaydi).
 */
import { http, HttpResponse } from 'msw';

import type { CompanyHistoryEntry, HosPolicy, ListResponse } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function hosPolicyFixture(overrides: Partial<HosPolicy> = {}): HosPolicy {
  return {
    id: '5b2e8f10-7c3d-4a1b-9e6f-2c3d4e5f6a7b',
    effective_from: '2026-10-01T00:00:00Z',
    created_by: '6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f',
    created_at: '2026-09-06T05:12:00Z',
    policy: {
      drive_limit_min: 660,
      shift_window_min: 840,
      break_required_after_drive_min: 480,
      break_duration_min: 30,
      break_qualifying_statuses: ['OFF', 'SB', 'ON'],
      daily_rest_min: 600,
      cycle_limit_min: 4200,
      cycle_days: 8,
      cycle_restart_min: 2040,
      sleeper_berth_available: true,
      sleeper_split_enabled: true,
      allow_pc: true,
      allow_ym: true,
      ym_max_speed_kmh: 32,
      motion_threshold_kmh: 8,
      short_haul_exception: false,
      adverse_conditions_extension_min: 120,
      warning_thresholds: { drive: 30, shift: 60, cycle: 120, break: 30 },
    },
    ...overrides,
  };
}

export function hosPolicyHistoryEntryFixture(
  overrides: Partial<CompanyHistoryEntry> = {},
): CompanyHistoryEntry {
  return {
    id: '2d4f6a8c-1e3b-4d5f-9a7c-8b6d4e2f0a1c',
    table_name: 'hos_policy_versions',
    record_id: '5b2e8f10-7c3d-4a1b-9e6f-2c3d4e5f6a7b',
    action: 'hos_policy_change',
    field: 'drive_limit_min',
    old_value: '660',
    new_value: '600',
    edited_by: '6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f',
    edited_by_name: 'Jane Doe',
    ts: '2026-09-06T05:12:00Z',
    ...overrides,
  };
}

/** `GET /company/hos-policy` — muvaffaqiyatli. */
export const hosPolicyGetHandler = http.get(url('/company/hos-policy'), () =>
  HttpResponse.json({ data: hosPolicyFixture() }),
);

/** `GET /company/hos-policy` — `403`. */
export const hosPolicyGetErrorHandler = http.get(url('/company/hos-policy'), () =>
  jsonError('FORBIDDEN', 'hos_policy.read required', 403),
);

/** `POST /company/hos-policy` — `201`, yangi versiya. */
export const hosPolicyPublishHandler = http.post(url('/company/hos-policy'), () =>
  HttpResponse.json(
    { data: hosPolicyFixture({ id: 'new-version', effective_from: '2026-11-01T00:00:00Z' }) },
    { status: 201 },
  ),
);

/** `POST /company/hos-policy` — `422` (masalan `effective_from` o'tmishda). */
export const hosPolicyPublishErrorHandler = http.post(url('/company/hos-policy'), () =>
  jsonError('VALIDATION_ERROR', 'effective_from must not be in the past', 422, [
    { field: 'effective_from', message: 'must not be in the past' },
  ]),
);

/** `GET /company/history?action=hos_policy_change` — muvaffaqiyatli. */
export const hosPolicyVersionsHandler = http.get(url('/company/history'), () =>
  HttpResponse.json({
    data: [hosPolicyHistoryEntryFixture()],
    meta: listMeta(),
  } satisfies ListResponse<CompanyHistoryEntry>),
);

/** `GET /company/history?action=hos_policy_change` — bo'sh (versiya o'zgarmagan). */
export const hosPolicyVersionsEmptyHandler = http.get(url('/company/history'), () =>
  HttpResponse.json({
    data: [],
    meta: listMeta({ total: 0 }),
  } satisfies ListResponse<CompanyHistoryEntry>),
);
