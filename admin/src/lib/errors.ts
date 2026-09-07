/**
 * Backend xatolarini yagona shaklga keltirish.
 *
 * Backend konverti (fe-api §6):
 * ```json
 * { "error": { "code": "VALIDATION_ERROR", "message": "validation failed",
 *              "details": [ { "field": "unit_number", "message": "required" } ] } }
 * ```
 */

/** Backend qaytaradigan ma'lum xato kodlari. */
export const ERROR_CODES = [
  'VALIDATION_ERROR',
  'UNAUTHORIZED',
  'FORBIDDEN',
  'NOT_FOUND',
  'CONFLICT',
  'RATE_LIMITED',
  'SUBSCRIPTION_READONLY',
  'ACCOUNT_INACTIVE',
  'REFRESH_REUSED',
  'INTERNAL',
  'NETWORK_ERROR',
  'UNKNOWN',
] as const;

export type ErrorCode = (typeof ERROR_CODES)[number];

/**
 * Ma'lum kodlar + backend qo'shishi mumkin bo'lgan yangi kodlar.
 * `string & Record<never, never>` — literal takliflarni saqlab qolish uchun.
 */
export type ErrorCodeLike = ErrorCode | (string & Record<never, never>);

/** `code` → i18n kaliti. Kalit topilmasa `errors.unknown` ishlatiladi. */
export const ERROR_I18N_KEYS: Record<ErrorCode, string> = {
  VALIDATION_ERROR: 'errors.validation',
  UNAUTHORIZED: 'errors.unauthorized',
  FORBIDDEN: 'errors.forbidden',
  NOT_FOUND: 'errors.notFound',
  CONFLICT: 'errors.conflict',
  RATE_LIMITED: 'errors.rateLimited',
  SUBSCRIPTION_READONLY: 'errors.subscriptionReadonly',
  ACCOUNT_INACTIVE: 'errors.accountInactive',
  REFRESH_REUSED: 'errors.sessionExpired',
  INTERNAL: 'errors.internal',
  NETWORK_ERROR: 'errors.network',
  UNKNOWN: 'errors.unknown',
};

export const FALLBACK_ERROR_I18N_KEY = ERROR_I18N_KEYS.UNKNOWN;

export interface NormalizedError {
  /** Backend kodi; noma'lum bo'lsa xom qator saqlanadi. */
  code: ErrorCodeLike;
  /** HTTP status; tarmoq xatosida 0. */
  status: number;
  /** Backenddan kelgan xom matn — i18n kaliti bo'lmasagina ko'rsatiladi. */
  message: string;
  /** `details[]` dan yig'ilgan maydon xatolari (react-hook-form `setError` uchun). */
  fields: Record<string, string>;
  /** `429` javobidagi `Retry-After` (sekund). */
  retryAfterSeconds?: number;
  /** 5xx da nusxa olish uchun ko'rsatiladi. */
  traceId?: string;
}

/** `throw` qilinadigan shakl — TanStack Query `error` obyekti sifatida. */
export class ApiError extends Error implements NormalizedError {
  readonly code: ErrorCodeLike;
  readonly status: number;
  readonly fields: Record<string, string>;
  readonly retryAfterSeconds?: number;
  readonly traceId?: string;

  constructor(normalized: NormalizedError) {
    super(normalized.message);
    this.name = 'ApiError';
    this.code = normalized.code;
    this.status = normalized.status;
    this.fields = normalized.fields;
    this.retryAfterSeconds = normalized.retryAfterSeconds;
    this.traceId = normalized.traceId;
  }
}

export function isApiError(value: unknown): value is ApiError {
  return value instanceof ApiError;
}

/** Kodga mos i18n kaliti; noma'lum kodda `errors.unknown`. */
export function errorI18nKey(code: ErrorCodeLike): string {
  return ERROR_I18N_KEYS[code as ErrorCode] ?? FALLBACK_ERROR_I18N_KEY;
}

/**
 * Ko'rsatiladigan matn uchun kalit tanlanadi. Kalit mavjud bo'lmasa xom
 * `message` fallback sifatida qaytariladi va `console.warn` bilan qayd etiladi.
 */
export function resolveErrorMessage(error: NormalizedError): {
  i18nKey: string | null;
  fallback: string;
} {
  const known = ERROR_I18N_KEYS[error.code as ErrorCode];
  if (known) return { i18nKey: known, fallback: error.message };

  console.warn(`[errors] No i18n key for backend error code "${error.code}"`);
  return { i18nKey: null, fallback: error.message };
}

/** HTTP statusdan taxminiy kod — backend `code` bermagan hollarda. */
function codeFromStatus(status: number): ErrorCode {
  if (status === 400 || status === 422) return 'VALIDATION_ERROR';
  if (status === 401) return 'UNAUTHORIZED';
  if (status === 403) return 'FORBIDDEN';
  if (status === 404) return 'NOT_FOUND';
  if (status === 409) return 'CONFLICT';
  if (status === 429) return 'RATE_LIMITED';
  if (status >= 500) return 'INTERNAL';
  return 'UNKNOWN';
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}

/** `details[]` → `{ field: message }`. Noto'g'ri shakldagi elementlar tashlanadi. */
function collectFields(details: unknown): Record<string, string> {
  const fields: Record<string, string> = {};
  if (!Array.isArray(details)) return fields;

  for (const detail of details) {
    if (!isRecord(detail)) continue;
    const { field, message } = detail;
    if (typeof field === 'string' && field.length > 0 && typeof message === 'string') {
      fields[field] = message;
    }
  }
  return fields;
}

function parseRetryAfter(headerValue: string | null): number | undefined {
  if (!headerValue) return undefined;

  const seconds = Number(headerValue);
  if (Number.isFinite(seconds) && seconds >= 0) return seconds;

  const date = Date.parse(headerValue);
  if (Number.isNaN(date)) return undefined;
  return Math.max(0, Math.round((date - Date.now()) / 1000));
}

/**
 * Muvaffaqiyatsiz javobni normalizatsiya qiladi.
 * Body allaqachon o'qilgan bo'lishi mumkin — shuning uchun `parsedBody` beriladi.
 */
export async function normalizeError(
  response: Response,
  parsedBody?: unknown,
): Promise<NormalizedError> {
  let body = parsedBody;

  if (body === undefined) {
    try {
      body = await response.clone().json();
    } catch {
      body = undefined;
    }
  }

  const envelope = isRecord(body) && isRecord(body.error) ? body.error : undefined;

  const code =
    typeof envelope?.code === 'string' && envelope.code.length > 0
      ? envelope.code
      : codeFromStatus(response.status);

  const message =
    typeof envelope?.message === 'string' && envelope.message.length > 0
      ? envelope.message
      : response.statusText || 'Request failed';

  const traceId =
    (typeof envelope?.trace_id === 'string' ? envelope.trace_id : undefined) ??
    response.headers.get('X-Trace-Id') ??
    undefined;

  const normalized: NormalizedError = {
    code,
    status: response.status,
    message,
    fields: collectFields(envelope?.details),
  };

  const retryAfter = parseRetryAfter(response.headers.get('Retry-After'));
  if (retryAfter !== undefined) normalized.retryAfterSeconds = retryAfter;
  if (traceId) normalized.traceId = traceId;

  return normalized;
}

/** Tarmoq/`fetch` darajasidagi xato (javob umuman kelmagan). */
export function normalizeNetworkError(cause: unknown): NormalizedError {
  return {
    code: 'NETWORK_ERROR',
    status: 0,
    message: cause instanceof Error ? cause.message : 'Network request failed',
    fields: {},
  };
}
