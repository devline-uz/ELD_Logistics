/**
 * `entity_type` → ekran marshruti xaritasi (7.8, TZ `07-9-chat-support-audit.md`
 * §7.11 F142). Bitta joyda saqlanadi — dropdown va sahifa ikkalasi ham shu
 * funksiyani chaqiradi.
 *
 * Backend `entity_type` ni erkin `string` sifatida qaytaradi (swagger'da enum
 * yo'q, misol qiymati `"violations"`). Noma'lum qiymat — navigatsiyasiz,
 * xato bermaydi (F142 talabi: xatosiz jimgina e'tiborsiz qoldiriladi).
 */

/**
 * `entity_id` backenddan keladigan ishonchsiz satr — marshrutga qo'shishdan
 * oldin kodlanadi (fe-security §2). Kodlanmagan holda `\\evil.com` yoki `..`
 * kabi qiymat `navigate()` da ochiq redirect / boshqa ekranga sakrashga
 * olib kelishi mumkin (react-router GHSA-wrjc-x8rr-h8h6).
 */
function safeId(entityId: string): string {
  return encodeURIComponent(entityId);
}

/** `entity_id` talab qiladigan turlar — id yo'q bo'lsa link tuzilmaydi. */
const ID_REQUIRED_LINKS: Readonly<Record<string, (entityId: string) => string>> = {
  violations: (id) => `/violations/${safeId(id)}`,
  violation: (id) => `/violations/${safeId(id)}`,
  dvir: (id) => `/dvir/${safeId(id)}`,
  dvir_report: (id) => `/dvir/${safeId(id)}`,
  dvir_reports: (id) => `/dvir/${safeId(id)}`,
};

/** Maintenance oilasidagi barcha turlar bitta ro'yxatga tushadi. */
const MAINTENANCE_DUE_PATH = '/maintenance/due';

/** `entity_id`dan qat'i nazar bitta ro'yxat/ekranga olib boradigan turlar. */
const STATIC_LINKS: Readonly<Record<string, string>> = {
  log_edit_request: '/logs/edit-requests',
  log_edit_requests: '/logs/edit-requests',
  maintenance: MAINTENANCE_DUE_PATH,
  maintenance_schedule: MAINTENANCE_DUE_PATH,
  maintenance_schedule_unit: MAINTENANCE_DUE_PATH,
  chat: '/chat',
  chat_message: '/chat',
  chat_thread: '/chat',
  unidentified_driving: '/logs/unassigned',
};

/**
 * `entity_type` (+ ixtiyoriy `entity_id`) ni ekran marshrutiga aylantiradi.
 * Noma'lum tur yoki id talab qilinib topilmasa — `null` (navigatsiyasiz).
 */
export function resolveNotificationPath(
  entityType: string | null | undefined,
  entityId: string | null | undefined,
): string | null {
  if (!entityType) return null;
  const key = entityType.toLowerCase();

  const idRequiredBuilder = ID_REQUIRED_LINKS[key];
  if (idRequiredBuilder) {
    return entityId ? idRequiredBuilder(entityId) : null;
  }

  const staticLink = STATIC_LINKS[key];
  if (staticLink) return staticLink;

  // `maintenance_upcoming` / `maintenance_overdue` kabi prefiks variantlari.
  if (key.startsWith('maintenance')) return MAINTENANCE_DUE_PATH;

  return null;
}
