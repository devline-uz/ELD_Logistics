/**
 * Branches — MSW handler'lari (bosqich 2 ko'rigi B1, fe-testing §MSW).
 */
import { http, HttpResponse } from 'msw';

import type { Branch, ListResponse } from '@/api/types';

import { listMeta, url } from './shared';

export function branchFixture(overrides: Partial<Branch> = {}): Branch {
  return {
    id: 'branch-1',
    name: 'Dallas Terminal',
    address: '1200 Industrial Rd, Dallas, TX 75207',
    timezone: 'America/Chicago',
    created_at: '2026-01-14T09:30:00Z',
    updated_at: '2026-09-06T05:12:00Z',
    ...overrides,
  };
}

/** `GET /company/branches` — muvaffaqiyatli. */
export const branchesListHandler = http.get(url('/company/branches'), () =>
  HttpResponse.json({
    data: [branchFixture()],
    meta: listMeta(),
  } satisfies ListResponse<Branch>),
);

/** `GET /company/branches` — bo'sh natija (`scope=branch` yoki yangi kompaniya). */
export const branchesListEmptyHandler = http.get(url('/company/branches'), () =>
  HttpResponse.json({ data: [], meta: listMeta({ total: 0 }) } satisfies ListResponse<Branch>),
);
