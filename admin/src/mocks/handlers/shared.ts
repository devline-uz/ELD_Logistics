/**
 * MSW handler'lari uchun umumiy yordamchilar (2.1, fe-testing §MSW).
 * Naqsh manbai: `src/features/auth/mocks/handlers.ts`.
 */
import { HttpResponse } from 'msw';

import type { ErrorResponse, ListMeta } from '@/api/types';

/**
 * Baza URL — `import.meta.env.VITE_API_BASE_URL` orqali (9.1 tuzatishi).
 *
 * Oldin `@/test/msw-server`dan import qilingan edi — bu fayl **faqat**
 * `mocks/handlers/*` orqali ishlatilsa muammo yo'q (Vitest, `tsc`), lekin
 * `src/mocks/browser.ts` (9.1, real brauzer bundle) ham shu handler'larni
 * import qiladi: `@/test/msw-server` `msw/node`ni import qiladi va u
 * Node'ning `net`/`http` modullariga tayanadi — brauzerda bootstrap vaqtida
 * "Class extends value undefined" xatosi bilan yiqiladi. Vitest'da
 * `vite.config.ts` `test.env.VITE_API_BASE_URL` ham xuddi shu qiymatni
 * beradi (`http://eldapi.test/api/v1`), shuning uchun bu o'zgarish mavjud
 * testlarning birortasini buzmaydi.
 */
export const API_BASE_URL: string = import.meta.env.VITE_API_BASE_URL;

/** Baza URL bilan to'liq yo'l quradi. */
export const url = (path: string): string => `${API_BASE_URL}${path}`;

/** Backend xato konverti — `{"error":{"code","message","details"}}` (fe-api §6). */
export function errorEnvelope(
  code: string,
  message: string,
  details?: Array<{ field: string; message: string }>,
): ErrorResponse {
  return { error: { code, message, details } };
}

/** Tayyor `HttpResponse.json` xato javobi. */
export function jsonError(
  code: string,
  message: string,
  status: number,
  details?: Array<{ field: string; message: string }>,
): Response {
  return HttpResponse.json(errorEnvelope(code, message, details), { status });
}

/** `{page, per_page, total}` — barcha ro'yxat javoblarida bir xil shakl. */
export function listMeta(overrides: Partial<ListMeta> = {}): ListMeta {
  return { page: 1, per_page: 25, total: 1, ...overrides };
}
