/**
 * Company — MSW handler'lari (Bosqich 8.1, fe-testing §MSW). Har endpoint
 * uchun muvaffaqiyat + xato varianti.
 */
import { http, HttpResponse } from 'msw';

import type { Company, CompanyHistoryEntry, ListResponse } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function companyFixture(overrides: Partial<Company> = {}): Company {
  return {
    id: '3f7c2d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f',
    name: 'Onebook Logistics LLC',
    address: '1200 Industrial Rd, Dallas, TX 75207',
    home_terminal_address: '1200 Industrial Rd, Dallas, TX 75207',
    email: 'ops@onebook.example',
    phone: '+15125550143',
    registration_no: '3928471',
    timezone: 'America/Chicago',
    region: 'US',
    unit_system: 'imperial',
    regulation_profile: 'us_fmcsa',
    plan: 'fleet_50',
    subscription_status: 'active',
    subscription_end_at: '2026-12-31T23:59:59Z',
    settings: {
      distance_regions_set: 'us_states',
      fuel_types: ['diesel', 'petrol', 'cng', 'lpg', 'electric', 'hybrid'],
      quick_notes: ['PTI', 'Hook', 'Pickup', 'Drop-off', 'Delivery'],
    },
    created_at: '2026-01-14T09:30:00Z',
    updated_at: '2026-09-06T05:12:00Z',
    ...overrides,
  };
}

export function companyHistoryEntryFixture(
  overrides: Partial<CompanyHistoryEntry> = {},
): CompanyHistoryEntry {
  return {
    id: '2d4f6a8c-1e3b-4d5f-9a7c-8b6d4e2f0a1c',
    table_name: 'companies',
    record_id: '3f7c2d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f',
    action: 'update',
    field: 'timezone',
    old_value: 'America/Chicago',
    new_value: 'America/Denver',
    edited_by: '6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f',
    edited_by_name: 'Jane Doe',
    ts: '2026-09-06T05:12:00Z',
    ...overrides,
  };
}

/** `GET /company` — muvaffaqiyatli. */
export const companyGetHandler = http.get(url('/company'), () =>
  HttpResponse.json({ data: companyFixture() }),
);

/** `GET /company` — `403` (ruxsat yo'q). */
export const companyGetErrorHandler = http.get(url('/company'), () =>
  jsonError('FORBIDDEN', 'company.read required', 403),
);

/** `PATCH /company` — muvaffaqiyatli. */
export const companyUpdateHandler = http.patch(url('/company'), () =>
  HttpResponse.json({ data: companyFixture({ timezone: 'America/Denver' }) }),
);

/** `PATCH /company` — `unit_system: metric` ga o'zgargan (F145 reformat testlari uchun). */
export const companyUpdateMetricHandler = http.patch(url('/company'), () =>
  HttpResponse.json({ data: companyFixture({ unit_system: 'metric' }) }),
);

/** `PATCH /company` — `422` (masalan `name` juda qisqa). */
export const companyUpdateErrorHandler = http.patch(url('/company'), () =>
  jsonError('VALIDATION_ERROR', 'name must be at least 2 characters', 422, [
    { field: 'name', message: 'too short' },
  ]),
);

/** `GET /company/history` — muvaffaqiyatli. */
export const companyHistoryListHandler = http.get(url('/company/history'), () =>
  HttpResponse.json({
    data: [companyHistoryEntryFixture()],
    meta: listMeta(),
  } satisfies ListResponse<CompanyHistoryEntry>),
);

/** `GET /company/history` — bo'sh natija. */
export const companyHistoryListEmptyHandler = http.get(url('/company/history'), () =>
  HttpResponse.json({
    data: [],
    meta: listMeta({ total: 0 }),
  } satisfies ListResponse<CompanyHistoryEntry>),
);

/** `GET /company/history` — `422` (noto'g'ri `from`/`to`). */
export const companyHistoryListErrorHandler = http.get(url('/company/history'), () =>
  jsonError('VALIDATION_ERROR', 'invalid from/to range', 422),
);
