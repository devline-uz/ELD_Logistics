/**
 * MSW handler'lari uchun umumiy yordamchilar (2.1, fe-testing §MSW).
 * Naqsh manbai: `src/features/auth/mocks/handlers.ts`.
 */
import { HttpResponse } from 'msw';

import { API_BASE_URL } from '@/test/msw-server';
import type { ErrorResponse, ListMeta } from '@/api/types';

/** `src/test/msw-server.ts` dagi baza URL bilan to'liq yo'l quradi. */
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
