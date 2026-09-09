/**
 * Super Admin — `/companies*` MSW handler'lari (9.15, §7.14, fe-testing §MSW).
 */
import { http, HttpResponse } from 'msw';

import type { AdminCompany, AdminCompanyCreated, ListResponse } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function adminCompanyFixture(overrides: Partial<AdminCompany> = {}): AdminCompany {
  return {
    id: 'company-1',
    name: 'Onebook Logistics LLC',
    address: '1200 Industrial Rd, Dallas, TX 75207',
    home_terminal_address: '1200 Industrial Rd, Dallas, TX 75207',
    email: 'ops@onebook.example',
    phone: '+15125550143',
    plan: 'fleet_50',
    region: 'US',
    registration_no: '3928471',
    regulation_profile: 'us_fmcsa',
    subscription_status: 'active',
    subscription_end_at: '2026-12-31T23:59:59Z',
    timezone: 'America/Chicago',
    unit_system: 'imperial',
    created_at: '2026-01-14T09:30:00Z',
    updated_at: '2026-09-06T05:12:00Z',
    ...overrides,
  };
}

/** `GET /companies` — muvaffaqiyatli. */
export const adminCompaniesListHandler = http.get(url('/companies'), () =>
  HttpResponse.json({
    data: [adminCompanyFixture()],
    meta: listMeta(),
  } satisfies ListResponse<AdminCompany>),
);

/** `GET /companies` — bo'sh natija (filtr mos kelmadi). */
export const adminCompaniesListEmptyHandler = http.get(url('/companies'), () =>
  HttpResponse.json({
    data: [],
    meta: listMeta({ total: 0 }),
  } satisfies ListResponse<AdminCompany>),
);

/** `GET /companies` — `403` (super_admin bayrog'i yo'q). */
export const adminCompaniesListForbiddenHandler = http.get(url('/companies'), () =>
  jsonError('FORBIDDEN', 'super_admin required', 403),
);

/** `POST /companies` — `201`. */
export const adminCompanyCreateHandler = http.post(url('/companies'), () =>
  HttpResponse.json(
    {
      data: {
        company: adminCompanyFixture({ id: 'company-new', name: 'Northside Freight Co' }),
        administrator_user_id: 'user-new-admin',
        administrator_role_id: 'role-new-admin',
        invitation_channel: 'email',
        invitation_expires_at: '2026-09-12T05:12:00Z',
        roles_created: 8,
      } satisfies AdminCompanyCreated,
    },
    { status: 201 },
  ),
);

/** `POST /companies` — `409` (nom band). */
export const adminCompanyCreateConflictHandler = http.post(url('/companies'), () =>
  jsonError('UNIQUE_VIOLATION', 'a company with this name already exists', 409),
);

/** `POST /companies` — `422` (masalan `administrator.email` yo'q). */
export const adminCompanyCreateValidationHandler = http.post(url('/companies'), () =>
  jsonError('VALIDATION_ERROR', 'administrator.email is required', 422, [
    { field: 'administrator.email', message: 'required' },
  ]),
);

/** `PATCH /companies/{id}` — muvaffaqiyatli. */
export const adminCompanyUpdateHandler = http.patch(url('/companies/:id'), ({ params }) =>
  HttpResponse.json({
    data: adminCompanyFixture({ id: params.id as string, name: 'Updated Company Name' }),
  }),
);

/** `PATCH /companies/{id}` — `404` (mavjud bo'lmagan yoki soft-deleted). */
export const adminCompanyUpdateNotFoundHandler = http.patch(url('/companies/:id'), () =>
  jsonError('NOT_FOUND', 'company not found', 404),
);

/** `PATCH /companies/{id}/subscription` — muvaffaqiyatli. */
export const adminCompanySubscriptionUpdateHandler = http.patch(
  url('/companies/:id/subscription'),
  ({ params }) =>
    HttpResponse.json({
      data: adminCompanyFixture({
        id: params.id as string,
        subscription_status: 'grace',
        subscription_end_at: '2026-10-01T23:59:59Z',
      }),
    }),
);

/** `PATCH /companies/{id}/subscription` — `404`. */
export const adminCompanySubscriptionUpdateNotFoundHandler = http.patch(
  url('/companies/:id/subscription'),
  () => jsonError('NOT_FOUND', 'company not found', 404),
);
