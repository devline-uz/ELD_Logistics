/**
 * Backend xatolarini yagona shaklga keltirish.
 *
 * Backend konverti (fe-api §6):
 * ```json
 * { "error": { "code": "VALIDATION_ERROR", "message": "validation failed",
 *              "details": [ { "field": "unit_number", "message": "required" } ] } }
 * ```
 */

/**
 * Backend qaytaradigan ma'lum xato kodlari.
 *
 * Ro'yxat `openapi/swagger.json` dagi barcha `4xx`/`5xx` javob
 * tavsiflarida uchraydigan kodlarni qamrab oladi (9.7, i18n-keeper) — shu
 * tufayli `resolveErrorMessage` hech qachon noma'lum kod uchun
 * `console.warn` chiqarmaydi va foydalanuvchiga doim ma'noli matn
 * ko'rsatiladi. Ba'zi kodlar (`DVIR_INVALID_TRANSITION`,
 * `DEFECT_TYPE_SYSTEM_LOCKED`, `UNIQUE_VIOLATION`, `RESOURCE_IN_USE`)
 * modul darajasida ham aniqroq matn bilan qayta belgilanadi
 * (`features/dvir/lib/errors.ts`, `features/settings/branches/lib/errors.ts`)
 * — markaziy xarita faqat fallback vazifasini bajaradi.
 */
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
  'ALREADY_ASSIGNED',
  'BAD_REQUEST',
  'BATCH_TOO_LARGE',
  'DEFECT_TYPE_SYSTEM_LOCKED',
  'DEFECT_TYPE_UNKNOWN',
  'DRIVING_MODE_BLOCKED',
  'DR_IMMUTABLE',
  'DVIR_ADMIN_CREATE_DENIED',
  'DVIR_INVALID_TRANSITION',
  'EVENT_IMMUTABLE',
  'FEATURE_DISABLED',
  'FILE_TOO_LARGE',
  'FILE_TYPE_INVALID',
  'IDEMPOTENCY_CONFLICT',
  'INTERNAL_ERROR',
  'INVALID_CREDENTIALS',
  'INVALID_STATE',
  'INVITATION_EXPIRED',
  'INVITATION_INVALID',
  'INVITATION_USED',
  'LAST_ADMINISTRATOR',
  'LOCKED_OUT',
  'LOG_NOT_READY',
  'MAINTENANCE_INVALID_STATE',
  'MAINTENANCE_NO_READING',
  'MESSAGE_TOO_LONG',
  'PASSWORD_WEAK',
  'PAYLOAD_TOO_LARGE',
  'PIN_INVALID',
  'PIN_LOCKED',
  'PIN_NOT_SET',
  'PIN_REQUIRED',
  'RESOURCE_IN_USE',
  'ROLE_IN_USE',
  'SELF_TARGET_FORBIDDEN',
  'SERVICE_UNAVAILABLE',
  'SESSION_EXPIRED',
  'STORAGE_ERROR',
  'SUBSCRIPTION_EXPIRED',
  'SYSTEM_ROLE_IMMUTABLE',
  'TIME_IN_FUTURE',
  'TOKEN_INVALID',
  'TOKEN_REUSED',
  'TOKEN_REVOKED',
  'TOTP_ALREADY_ENABLED',
  'TOTP_INVALID',
  'TOTP_REQUIRED',
  'TOTP_SETUP_REQUIRED',
  'UNIQUE_VIOLATION',
  'UPSTREAM_ERROR',
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
  ALREADY_ASSIGNED: 'errors.alreadyAssigned',
  BAD_REQUEST: 'errors.badRequest',
  BATCH_TOO_LARGE: 'errors.batchTooLarge',
  DEFECT_TYPE_SYSTEM_LOCKED: 'errors.defectTypeSystemLocked',
  DEFECT_TYPE_UNKNOWN: 'errors.defectTypeUnknown',
  DRIVING_MODE_BLOCKED: 'errors.drivingModeBlocked',
  DR_IMMUTABLE: 'errors.drImmutable',
  DVIR_ADMIN_CREATE_DENIED: 'errors.dvirAdminCreateDenied',
  DVIR_INVALID_TRANSITION: 'errors.dvirInvalidTransition',
  EVENT_IMMUTABLE: 'errors.eventImmutable',
  FEATURE_DISABLED: 'errors.featureDisabled',
  FILE_TOO_LARGE: 'errors.fileTooLarge',
  FILE_TYPE_INVALID: 'errors.fileTypeInvalid',
  IDEMPOTENCY_CONFLICT: 'errors.idempotencyConflict',
  INTERNAL_ERROR: 'errors.internal',
  INVALID_CREDENTIALS: 'errors.invalidCredentials',
  INVALID_STATE: 'errors.invalidState',
  INVITATION_EXPIRED: 'errors.invitationExpired',
  INVITATION_INVALID: 'errors.invitationInvalid',
  INVITATION_USED: 'errors.invitationUsed',
  LAST_ADMINISTRATOR: 'errors.lastAdministrator',
  LOCKED_OUT: 'errors.lockedOut',
  LOG_NOT_READY: 'errors.logNotReady',
  MAINTENANCE_INVALID_STATE: 'errors.maintenanceInvalidState',
  MAINTENANCE_NO_READING: 'errors.maintenanceNoReading',
  MESSAGE_TOO_LONG: 'errors.messageTooLong',
  PASSWORD_WEAK: 'errors.passwordWeak',
  PAYLOAD_TOO_LARGE: 'errors.payloadTooLarge',
  PIN_INVALID: 'errors.pinInvalid',
  PIN_LOCKED: 'errors.pinLocked',
  PIN_NOT_SET: 'errors.pinNotSet',
  PIN_REQUIRED: 'errors.pinRequired',
  RESOURCE_IN_USE: 'errors.resourceInUse',
  ROLE_IN_USE: 'errors.roleInUse',
  SELF_TARGET_FORBIDDEN: 'errors.selfTargetForbidden',
  SERVICE_UNAVAILABLE: 'errors.serviceUnavailable',
  SESSION_EXPIRED: 'errors.sessionExpired',
  STORAGE_ERROR: 'errors.storageError',
  SUBSCRIPTION_EXPIRED: 'errors.subscriptionExpired',
  SYSTEM_ROLE_IMMUTABLE: 'errors.systemRoleImmutable',
  TIME_IN_FUTURE: 'errors.timeInFuture',
  TOKEN_INVALID: 'errors.sessionExpired',
  TOKEN_REUSED: 'errors.sessionExpired',
  TOKEN_REVOKED: 'errors.sessionExpired',
  TOTP_ALREADY_ENABLED: 'errors.totpAlreadyEnabled',
  TOTP_INVALID: 'errors.totpInvalid',
  TOTP_REQUIRED: 'errors.totpRequired',
  TOTP_SETUP_REQUIRED: 'errors.totpSetupRequired',
  UNIQUE_VIOLATION: 'errors.uniqueViolation',
  UPSTREAM_ERROR: 'errors.upstreamError',
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
  /**
   * Ba'zi endpointlar (masalan `POST /units|drivers/import`, TZ 2.3/D-f9)
   * muvaffaqiyatsiz javobda ham standart `{error:...}` konvertidan farqli,
   * domenga xos tanani qaytaradi (masalan `ImportResultEnvelope`:
   * `{data:{imported,total,errors[]}}`). `client.ts`dagi `errorMiddleware`
   * shu turdagi so'rovlar uchun butun JSON tanani shu yerga saqlaydi;
   * chaqiruvchi (masalan `useUnitsImport`) uni o'zi generatsiya qilingan
   * tipga o'qiydi. Boshqa endpointlarda `undefined`.
   */
  readonly payload?: unknown;

  constructor(normalized: NormalizedError, payload?: unknown) {
    super(normalized.message);
    this.name = 'ApiError';
    this.code = normalized.code;
    this.status = normalized.status;
    this.fields = normalized.fields;
    this.retryAfterSeconds = normalized.retryAfterSeconds;
    this.traceId = normalized.traceId;
    this.payload = payload;
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
