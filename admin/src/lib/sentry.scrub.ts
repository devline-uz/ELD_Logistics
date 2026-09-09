/**
 * Sentry hodisalaridan PII ni olib tashlash (F206) — vazifa 9.12.
 *
 * Alohida modul: `sentry.client.ts` bilan birga **faqat DSN berilganda**
 * yuklanadigan chunk'ga tushadi, shuning uchun boshlang'ich bundle'ga
 * ta'sir qilmaydi. Sezgir maydon nomlari `lib/sensitive.ts` dan qayta
 * ishlatiladi (audit maskasi bilan bitta manba).
 */
import { MASKED_VALUE, isSensitiveField, maskSensitiveValue } from '@/lib/sensitive';

/** Audit maskasidan tashqari — Sentry hodisasi uchun qo'shimcha PII nomlari. */
const PII_FIELD_PATTERN =
  /^(authorization|cookie|set-cookie|proxy-authorization|x-api-key)$|(first|last|middle|full|given|family|driver|user|contact|owner)_?name|^name$|e-?mail|phone|mobile|telephone|address|birth|dob|passport|vin\b|plate/i;

/** URL query'sida maskalanadigan parametrlar. */
const SENSITIVE_QUERY_KEYS = /^(access_token|refresh_token|token|code|id_token|api_key|key)$/i;

const MAX_DEPTH = 6;

function isSensitiveKey(key: string): boolean {
  return isSensitiveField(key) || PII_FIELD_PATTERN.test(key);
}

/** URL ichidagi sezgir query qiymatlarini maskalaydi (fragment ham). */
export function scrubUrl(url: string): string {
  if (!url.includes('?') && !url.includes('#')) return url;
  return url.replace(/([?&#])([^=&#]+)=([^&#]*)/g, (match, sep: string, key: string) =>
    SENSITIVE_QUERY_KEYS.test(decodeURIComponent(key)) || isSensitiveKey(key)
      ? `${sep}${key}=${MASKED_VALUE}`
      : match,
  );
}

/**
 * Ixtiyoriy tuzilmani rekursiv maskalaydi (joyida o'zgartiradi).
 * Sikllar `seen` bilan uziladi, chuqurlik `MAX_DEPTH` bilan cheklanadi.
 */
function scrubValue(value: unknown, depth: number, seen: WeakSet<object>): unknown {
  if (typeof value === 'string') return scrubUrl(value);
  if (value === null || typeof value !== 'object' || depth > MAX_DEPTH) return value;

  if (seen.has(value)) return value;
  seen.add(value);

  if (Array.isArray(value)) {
    for (let i = 0; i < value.length; i += 1) {
      value[i] = scrubValue(value[i], depth + 1, seen);
    }
    return value;
  }

  const record = value as Record<string, unknown>;
  for (const key of Object.keys(record)) {
    const current = record[key];
    if (isSensitiveKey(key)) {
      record[key] =
        typeof current === 'string' ? maskSensitiveValue('password', current) : MASKED_VALUE;
      continue;
    }
    record[key] = scrubValue(current, depth + 1, seen);
  }
  return record;
}

/** Sentry hodisasining PII saqlashi mumkin bo'lgan qismlari. */
interface SentryEventLike {
  request?: {
    headers?: Record<string, string>;
    cookies?: unknown;
    data?: unknown;
    url?: string;
    query_string?: unknown;
  };
  user?: Record<string, unknown>;
  extra?: Record<string, unknown>;
  contexts?: Record<string, unknown>;
  tags?: Record<string, unknown>;
  breadcrumbs?: { data?: unknown; message?: string }[];
}

/**
 * Hodisadan PII ni olib tashlaydi (joyida). Sof funksiya emas — Sentry
 * `beforeSend` shartnomasi bir xil obyektni qaytarishni kutadi.
 */
export function scrubEvent<T extends SentryEventLike>(event: T): T {
  const seen = new WeakSet<object>();

  if (event.request) {
    delete event.request.cookies;
    if (event.request.headers) {
      scrubValue(event.request.headers, 0, seen);
    }
    if (typeof event.request.url === 'string') {
      event.request.url = scrubUrl(event.request.url);
    }
    if (typeof event.request.query_string === 'string') {
      event.request.query_string = scrubUrl(`?${event.request.query_string}`).slice(1);
    } else if (event.request.query_string) {
      scrubValue(event.request.query_string, 0, seen);
    }
    if (event.request.data) {
      event.request.data = scrubValue(event.request.data, 0, seen);
    }
  }

  // Foydalanuvchidan faqat korrelyatsiya uchun `id` qoladi.
  if (event.user) {
    const id = event.user.id;
    event.user = typeof id === 'string' || typeof id === 'number' ? { id } : {};
  }

  for (const key of ['extra', 'contexts', 'tags'] as const) {
    if (event[key]) scrubValue(event[key], 0, seen);
  }

  if (event.breadcrumbs) {
    for (const crumb of event.breadcrumbs) {
      if (crumb.data) crumb.data = scrubValue(crumb.data, 0, seen);
      if (typeof crumb.message === 'string') crumb.message = scrubUrl(crumb.message);
    }
  }

  return event;
}

/** `beforeBreadcrumb` uchun — breadcrumb `data` sini maskalaydi. */
export function scrubBreadcrumbData<T>(data: T): T {
  return scrubValue(data, 0, new WeakSet()) as T;
}
