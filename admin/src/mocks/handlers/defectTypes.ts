/**
 * Defect Types — MSW handler'lari (5.1, fe-testing §MSW). Har endpoint uchun
 * muvaffaqiyat + xato varianti; ro'yxat `{data, meta}` konverti.
 */
import { http, HttpResponse } from 'msw';

import type { DefectType } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function defectTypeFixture(overrides: Partial<DefectType> = {}): DefectType {
  return {
    id: 'defect-type-1',
    category: 'truck',
    name: 'Brakes (Service)',
    is_critical: true,
    is_active: true,
    is_system: true,
    sort_order: 8,
    created_at: '2026-01-01T00:00:00Z',
    updated_at: '2026-01-01T00:00:00Z',
    ...overrides,
  };
}

/** `GET /defect-types` — muvaffaqiyatli. */
export const defectTypesListHandler = http.get(url('/defect-types'), () =>
  HttpResponse.json({ data: [defectTypeFixture()], meta: listMeta() }),
);

/** `GET /defect-types` — bo'sh natija. */
export const defectTypesListEmptyHandler = http.get(url('/defect-types'), () =>
  HttpResponse.json({ data: [], meta: listMeta({ total: 0 }) }),
);

/** `GET /defect-types` — `422`. */
export const defectTypesListErrorHandler = http.get(url('/defect-types'), () =>
  jsonError('VALIDATION_ERROR', 'invalid category filter', 422),
);

/** `POST /defect-types` — muvaffaqiyatli yaratish. */
export const defectTypeCreateHandler = http.post(url('/defect-types'), () =>
  HttpResponse.json(
    { data: defectTypeFixture({ id: 'defect-type-new', is_system: false }) },
    { status: 201 },
  ),
);

/** `POST /defect-types` — `409` (`name` band). */
export const defectTypeCreateConflictHandler = http.post(url('/defect-types'), () =>
  jsonError('UNIQUE_VIOLATION', 'name already exists in this category', 409),
);

/** `PATCH /defect-types/{id}` — muvaffaqiyatli. */
export const defectTypeUpdateHandler = http.patch(url('/defect-types/:id'), ({ params }) =>
  HttpResponse.json({ data: defectTypeFixture({ id: params.id as string, is_system: false }) }),
);

/** `PATCH /defect-types/{id}` — `409` (standart band tahrirlanmoqchi). */
export const defectTypeUpdateSystemLockedHandler = http.patch(url('/defect-types/:id'), () =>
  jsonError('DEFECT_TYPE_SYSTEM_LOCKED', 'System defect types are read only', 409),
);

/** Bazaviy to'plam — ro'yxat + CRUD muvaffaqiyat holatlari. */
export const defectTypesBaseHandlers = [
  defectTypesListHandler,
  defectTypeCreateHandler,
  defectTypeUpdateHandler,
];
