/**
 * TanStack Query v5 klienti (0.12).
 *
 * Qayta urinish siyosati (fe-api §6):
 * - `401` — refresh oqimi `client.ts` middleware'ida hal qilinadi, Query
 *   darajasida takrorlash **kerak emas** (aks holda ikki marta so'raladi);
 * - `403`/`404` — takrorlash mantiqsiz, javob o'zgarmaydi;
 * - `422`/`400` — validatsiya, takrorlanmaydi;
 * - qolgan xatolar (`5xx`, tarmoq) — GET uchun 2 marta.
 *
 * Mutation'lar **hech qachon** avtomatik takrorlanmaydi: `Idempotency-Key`
 * forma sessiyasi davomida barqaror, takroriy yuborishni faqat foydalanuvchi
 * boshlaydi (fe-api §5).
 */
import { QueryClient } from '@tanstack/react-query';

import { isApiError } from '@/lib/errors';

/** Takrorlash mantiqsiz bo'lgan HTTP statuslar. */
const NON_RETRYABLE_STATUSES = new Set([400, 401, 403, 404, 409, 422]);

/** GET so'rovlari uchun maksimal qayta urinish soni. */
export const QUERY_MAX_RETRIES = 2;

export function shouldRetryQuery(failureCount: number, error: unknown): boolean {
  if (isApiError(error) && NON_RETRYABLE_STATUSES.has(error.status)) return false;
  return failureCount < QUERY_MAX_RETRIES;
}

export function createQueryClient(): QueryClient {
  return new QueryClient({
    defaultOptions: {
      queries: {
        retry: shouldRetryQuery,
        // Ro'yxatlar uchun standart; `GET /me` kabi kamdan-kam o'zgaradiganlar
        // o'z `staleTime` ini bermaydi (fe-api §7).
        staleTime: 30_000,
        refetchOnWindowFocus: false,
      },
      mutations: {
        retry: false,
      },
    },
  });
}
