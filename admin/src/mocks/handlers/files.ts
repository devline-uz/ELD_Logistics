/**
 * `POST /files/presign` — barcha modullar uchun yagona MSW handler'i.
 *
 * 5-bosqichda DVIR (mexanik imzosi, repair invoice) va Maintenance
 * (`Mark as Complete` invoice) bir xil endpointni ishlatadi, shuning uchun
 * ikkita modul handler'i o'rniga bitta — so'rovdagi `kind` bo'yicha mos
 * fixture qaytaradi (`FileUpload` javobdagi `max_bytes` ga tayanadi).
 *
 * Faylning o'zi `PUT` bilan storage'ga ketadi (XHR) — integratsiya
 * testlarida XHR stub qilinadi.
 */
import { http, HttpResponse } from 'msw';

import { url } from './shared';

const MB = 1024 * 1024;

const PRESIGN_BY_KIND: Record<string, Record<string, unknown>> = {
  signature: {
    upload_url: 'https://storage.example/upload',
    method: 'PUT',
    key: 'c1/signature/2026/09/07/mech.png',
    headers: { 'Content-Type': 'image/png' },
    max_bytes: MB,
    expires_at: '2030-01-01T00:00:00Z',
  },
  invoice: {
    upload_url: 'https://storage.test/invoice.pdf',
    method: 'PUT',
    key: 'c1/invoice/2026/09/inv.pdf',
    headers: { 'Content-Type': 'application/pdf' },
    max_bytes: 10 * MB,
    expires_at: '2030-01-01T00:00:00Z',
  },
};

/** `POST /files/presign` — `kind` bo'yicha mos presign javobi. */
export const filesPresignHandler = http.post(url('/files/presign'), async ({ request }) => {
  const body = (await request.json()) as { kind?: string } | null;
  const preset = PRESIGN_BY_KIND[body?.kind ?? 'invoice'] ?? PRESIGN_BY_KIND.invoice;
  return HttpResponse.json({ data: preset });
});
