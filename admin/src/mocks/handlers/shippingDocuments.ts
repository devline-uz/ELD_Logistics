/**
 * Shipping Documents — MSW handler'lari (2.1, fe-testing §MSW). Sodda CRUD (🎨).
 */
import { http, HttpResponse } from 'msw';

import type { ListResponse, ShippingDocument } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function shippingDocumentFixture(
  overrides: Partial<ShippingDocument> = {},
): ShippingDocument {
  return {
    id: 'ship-doc-1',
    number: 'BOL-99127',
    notes: 'Cold chain',
    created_at: '2026-01-14T09:00:00Z',
    updated_at: '2026-09-06T05:12:00Z',
    ...overrides,
  };
}

/** `GET /shipping-documents` — muvaffaqiyatli. */
export const shippingDocumentsListHandler = http.get(url('/shipping-documents'), () =>
  HttpResponse.json({
    data: [shippingDocumentFixture()],
    meta: listMeta(),
  } satisfies ListResponse<ShippingDocument>),
);

/** `GET /shipping-documents` — bo'sh natija. */
export const shippingDocumentsListEmptyHandler = http.get(url('/shipping-documents'), () =>
  HttpResponse.json({
    data: [],
    meta: listMeta({ total: 0 }),
  } satisfies ListResponse<ShippingDocument>),
);

/** `GET /shipping-documents` — `422`. */
export const shippingDocumentsListErrorHandler = http.get(url('/shipping-documents'), () =>
  jsonError('VALIDATION_ERROR', 'per_page must be 10, 25 or 50', 422),
);

/** `GET /shipping-documents/{id}` — muvaffaqiyatli. */
export const shippingDocumentGetHandler = http.get(url('/shipping-documents/:id'), ({ params }) =>
  HttpResponse.json({ data: shippingDocumentFixture({ id: params.id as string }) }),
);

/** `GET /shipping-documents/{id}` — cross-tenant → `404`. */
export const shippingDocumentGetNotFoundHandler = http.get(url('/shipping-documents/:id'), () =>
  jsonError('NOT_FOUND', 'Shipping document not found', 404),
);

/** `POST /shipping-documents` — muvaffaqiyatli (`201`). */
export const shippingDocumentCreateHandler = http.post(url('/shipping-documents'), () =>
  HttpResponse.json({ data: shippingDocumentFixture({ id: 'ship-doc-new' }) }, { status: 201 }),
);

/** `POST /shipping-documents` — `409` (`number` band). */
export const shippingDocumentCreateConflictHandler = http.post(url('/shipping-documents'), () =>
  jsonError('CONFLICT', 'number already in use', 409),
);

/** `PATCH /shipping-documents/{id}` — muvaffaqiyatli. */
export const shippingDocumentUpdateHandler = http.patch(
  url('/shipping-documents/:id'),
  ({ params }) => HttpResponse.json({ data: shippingDocumentFixture({ id: params.id as string }) }),
);

/** `PATCH /shipping-documents/{id}` — `404`. */
export const shippingDocumentUpdateNotFoundHandler = http.patch(
  url('/shipping-documents/:id'),
  () => jsonError('NOT_FOUND', 'Shipping document not found', 404),
);

/** `DELETE /shipping-documents/{id}` — muvaffaqiyatli (`204`). */
export const shippingDocumentDeleteHandler = http.delete(
  url('/shipping-documents/:id'),
  () => new HttpResponse(null, { status: 204 }),
);

/** `DELETE /shipping-documents/{id}` — `409 RESOURCE_IN_USE`. */
export const shippingDocumentDeleteConflictHandler = http.delete(
  url('/shipping-documents/:id'),
  () => jsonError('CONFLICT', 'Shipping document is referenced', 409),
);

/** Bazaviy to'plam — ro'yxat + CRUD muvaffaqiyat holatlari. */
export const shippingDocumentsBaseHandlers = [
  shippingDocumentsListHandler,
  shippingDocumentGetHandler,
  shippingDocumentCreateHandler,
  shippingDocumentUpdateHandler,
  shippingDocumentDeleteHandler,
];
