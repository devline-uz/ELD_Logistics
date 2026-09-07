import createClient, { type Middleware } from 'openapi-fetch';

import { ApiError, normalizeError } from '@/lib/errors';

import { getAccessToken, getCompanyId } from './session';
import type { paths } from './schema';

/** Bearer token talab qilmaydigan endpointlar. */
const PUBLIC_PATHS = ['/app/config', '/auth/login', '/auth/refresh', '/auth/password/'];

/** Idempotency-Key yuboriladigan metodlar (fe-api §5). */
const MUTATING_METHODS = new Set(['POST', 'PUT', 'PATCH', 'DELETE']);

export const IDEMPOTENCY_HEADER = 'Idempotency-Key';
export const COMPANY_HEADER = 'X-Company-Id';

function isPublic(schemaPath: string): boolean {
  return PUBLIC_PATHS.some((prefix) => schemaPath.startsWith(prefix));
}

/** `crypto.randomUUID` mavjud bo'lmagan muhitlar uchun zaxira. */
function randomUuid(): string {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID();
  }
  return `${Date.now().toString(16)}-${Math.random().toString(16).slice(2, 14)}`;
}

/** 1. `Authorization: Bearer <access>` — token xotiradagi sessiyadan olinadi. */
export const authMiddleware: Middleware = {
  onRequest({ request, schemaPath }) {
    if (isPublic(schemaPath)) return undefined;

    const token = getAccessToken();
    if (!token) return undefined;

    request.headers.set('Authorization', `Bearer ${token}`);
    return request;
  },
};

/** 2. `X-Company-Id` — faqat super_admin boshqa kompaniya kontekstida ishlaganda. */
export const companyMiddleware: Middleware = {
  onRequest({ request }) {
    if (request.headers.has(COMPANY_HEADER)) return undefined;

    const companyId = getCompanyId();
    if (!companyId) return undefined;

    request.headers.set(COMPANY_HEADER, companyId);
    return request;
  },
};

/**
 * 3. `Idempotency-Key` — o'zgartiruvchi so'rovlar uchun.
 *
 * Chaqiruvchi kalitni o'zi bergan bo'lsa (forma sessiyasi davomida barqaror
 * kalit — `useIdempotencyKey()`), u qayta yozilmaydi.
 */
export const idempotencyMiddleware: Middleware = {
  onRequest({ request }) {
    if (!MUTATING_METHODS.has(request.method.toUpperCase())) return undefined;
    if (request.headers.has(IDEMPOTENCY_HEADER)) return undefined;

    request.headers.set(IDEMPOTENCY_HEADER, randomUuid());
    return request;
  },
};

/**
 * 4. Xato normalizatsiyasi — muvaffaqiyatsiz javob `ApiError` sifatida otiladi,
 * shunda TanStack Query `error` yagona shaklda oladi (`lib/errors.ts`).
 *
 * Eslatma: 401 dagi refresh oqimi (mutex + bir marta takrorlash) **B qismida**
 * shu middleware'dan oldin turadigan `refreshMiddleware` sifatida qo'shiladi.
 */
export const errorMiddleware: Middleware = {
  async onResponse({ response }) {
    if (response.ok) return undefined;

    throw new ApiError(await normalizeError(response));
  },
  onError({ error }) {
    if (error instanceof ApiError) return error;
    return undefined;
  },
};

export const api = createClient<paths>({
  baseUrl: import.meta.env.VITE_API_BASE_URL,
  headers: { Accept: 'application/json' },
});

api.use(authMiddleware);
api.use(companyMiddleware);
api.use(idempotencyMiddleware);
api.use(errorMiddleware);

export default api;
