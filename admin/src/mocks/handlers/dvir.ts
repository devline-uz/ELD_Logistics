/**
 * DVIR — MSW handler'lari (5.1, fe-testing §MSW). Har endpoint uchun
 * muvaffaqiyat + xato varianti; ro'yxat `{data, meta}` konverti.
 */
import { http, HttpResponse } from 'msw';

import type { DvirReport } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function dvirReportFixture(overrides: Partial<DvirReport> = {}): DvirReport {
  return {
    id: 'dvir-1',
    unit_id: 'unit-1',
    unit_number: '1021',
    driver: { id: 'driver-1', first_name: 'John', last_name: 'Doe' },
    type: 'pre_trip',
    status: 'submitted_defects_found',
    kind: 'defects_not_fixed',
    has_critical_defect: true,
    out_of_service: true,
    location_text: '3 mi NE of Dallas, TX',
    lat: 32.7767,
    lng: -96.797,
    odometer_m: 128430000,
    performed_at: '2026-09-06T05:12:00Z',
    created_at: '2026-09-06T05:12:00Z',
    driver_signature_key: 'c1/signature/2026/09/06/sig.png',
    defects: [
      {
        category: 'truck',
        defect_type_id: 'defect-type-1',
        name: 'Tires',
        is_critical: true,
        note: 'Left front tyre below tread limit',
        photo_keys: ['c1/dvir_photo/2026/09/06/abc.jpg'],
      },
    ],
    ...overrides,
  };
}

/** `GET /dvir-reports` — muvaffaqiyatli, bitta yozuv bilan. */
export const dvirListHandler = http.get(url('/dvir-reports'), () =>
  HttpResponse.json({ data: [dvirReportFixture()], meta: listMeta() }),
);

/** `GET /dvir-reports` — bo'sh natija. */
export const dvirListEmptyHandler = http.get(url('/dvir-reports'), () =>
  HttpResponse.json({ data: [], meta: listMeta({ total: 0 }) }),
);

/** `GET /dvir-reports` — `422` (noto'g'ri filtr). */
export const dvirListErrorHandler = http.get(url('/dvir-reports'), () =>
  jsonError('VALIDATION_ERROR', 'invalid status filter', 422),
);

/** `GET /dvir-reports/pending-certification` — muvaffaqiyatli. */
export const dvirPendingCertificationHandler = http.get(
  url('/dvir-reports/pending-certification'),
  () =>
    HttpResponse.json({
      data: [dvirReportFixture({ id: 'dvir-2', status: 'repaired', kind: 'defects_fixed' })],
      meta: listMeta(),
    }),
);

/** `GET /dvir-reports/pending-certification` — `403` (ruxsat yo'q). */
export const dvirPendingCertificationForbiddenHandler = http.get(
  url('/dvir-reports/pending-certification'),
  () => jsonError('FORBIDDEN', 'Missing permission dvir.read', 403),
);

/** `GET /dvir-reports/{id}` — muvaffaqiyatli. */
export const dvirGetHandler = http.get(url('/dvir-reports/:id'), ({ params }) =>
  HttpResponse.json({ data: dvirReportFixture({ id: params.id as string }) }),
);

/**
 * `GET /dvir-reports/{id}` — mexanik imzosi mobil ilovada allaqachon olingan
 * hisobot (**D30**): faqat shunda `Record repair` amali ochiladi.
 */
export const dvirGetWithMechanicSignatureHandler = http.get(
  url('/dvir-reports/:id'),
  ({ params }) =>
    HttpResponse.json({
      data: dvirReportFixture({
        id: params.id as string,
        mechanic_signature_key: 'c1/signature/2026/09/06/mech.png',
      }),
    }),
);

/** `GET /dvir-reports/{id}` — cross-tenant/mavjud bo'lmagan → `404` (403 emas). */
export const dvirGetNotFoundHandler = http.get(url('/dvir-reports/:id'), () =>
  jsonError('NOT_FOUND', 'DVIR report not found', 404),
);

/** `POST /dvir-reports/{id}/repair` — muvaffaqiyatli, `repaired` holatiga o'tadi. */
export const dvirRepairHandler = http.post(url('/dvir-reports/:id/repair'), ({ params }) =>
  HttpResponse.json({
    data: dvirReportFixture({
      id: params.id as string,
      status: 'repaired',
      kind: 'defects_fixed',
      mechanic_note: 'Replaced left front tyre',
      mechanic_signature_key: 'c1/signature/2026/09/06/mech.png',
    }),
  }),
);

/** `POST /dvir-reports/{id}/repair` — `409` (noto'g'ri holatdan o'tish). */
export const dvirRepairConflictHandler = http.post(url('/dvir-reports/:id/repair'), () =>
  jsonError('DVIR_INVALID_TRANSITION', 'Report is not in submitted_defects_found', 409),
);

/** `POST /dvir-reports/{id}/certify` — muvaffaqiyatli, `certified` holatiga o'tadi. */
export const dvirCertifyHandler = http.post(url('/dvir-reports/:id/certify'), ({ params }) =>
  HttpResponse.json({
    data: dvirReportFixture({
      id: params.id as string,
      status: 'certified',
      kind: 'defects_fixed',
      out_of_service: false,
      certified_at: '2026-09-07T06:10:00Z',
      certification_signature_key: 'c1/signature/2026/09/07/sig.png',
    }),
  }),
);

/** `POST /dvir-reports/{id}/certify` — `409` (noto'g'ri holatdan o'tish). */
export const dvirCertifyConflictHandler = http.post(url('/dvir-reports/:id/certify'), () =>
  jsonError('DVIR_INVALID_TRANSITION', 'Report is not in repaired', 409),
);

/** `GET /dvir-reports/{id}/pdf` — muvaffaqiyatli (PDF blob). */
export const dvirPdfHandler = http.get(
  url('/dvir-reports/:id/pdf'),
  () =>
    new HttpResponse(new Blob([new Uint8Array([0x25, 0x50, 0x44, 0x46])]), {
      status: 200,
      headers: { 'Content-Type': 'application/pdf' },
    }),
);

/** `GET /dvir-reports/{id}/pdf` — 200, lekin HTML xato sahifasi (TD12). */
export const dvirPdfHtmlHandler = http.get(
  url('/dvir-reports/:id/pdf'),
  () =>
    new HttpResponse(new Blob(['<html>error</html>']), {
      status: 200,
      headers: { 'Content-Type': 'text/html' },
    }),
);

/** `GET /dvir-reports/{id}/pdf` — `502` (Chrome renderer ishlamayapti). */
export const dvirPdfUpstreamErrorHandler = http.get(url('/dvir-reports/:id/pdf'), () =>
  jsonError('UPSTREAM_ERROR', 'PDF renderer unavailable', 502),
);

/** Bazaviy to'plam — ro'yxat + detal muvaffaqiyat holatlari. */
export const dvirBaseHandlers = [dvirListHandler, dvirGetHandler, dvirPendingCertificationHandler];
