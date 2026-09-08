/**
 * Maintenance katalog qiymatlari (`docs/tz/07-5-dvir-maintenance.md` §7.6).
 * Matn kalitlari `enums.maintenance_*` da — bu yerda faqat xom qiymatlar.
 */

/** `Maintenance Type` katalogi (§16 C3: `Grese` → **Grease**). */
export const MAINTENANCE_TYPES = [
  'oil_change',
  'tyre',
  'engine_oil_change',
  'lights_change',
  'lease_expiry',
  'grease',
] as const;
export type MaintenanceType = (typeof MAINTENANCE_TYPES)[number];

/**
 * `Alert Type` — **backend enum'i** (`swagger.json`:
 * `notification | email | sms | none`).
 *
 * ⚠️ §16 D14 reestrida `maintenance_upcoming`/`maintenance_overdue` yozilgan —
 * bu backendning `alert_type` maydoni emas (u bildirishnoma shabloni nomi).
 * "Backend haqiqat manbai" qoidasi bo'yicha shu ro'yxat ishlatiladi; farq
 * hisobotda §16 nomzodi sifatida qayd etilgan.
 */
export const MAINTENANCE_ALERT_TYPES = ['notification', 'email', 'sms', 'none'] as const;
export type MaintenanceAlertType = (typeof MAINTENANCE_ALERT_TYPES)[number];

/** `Delivery Method` (`tz.md` Q89 / §16 D14). */
export const MAINTENANCE_DELIVERY_METHODS = ['push', 'email', 'sms', 'in_app'] as const;
export type MaintenanceDeliveryMethod = (typeof MAINTENANCE_DELIVERY_METHODS)[number];

/** `GET /maintenance-schedules?status=`. */
export const SCHEDULE_STATUSES = ['active', 'inactive'] as const;

/** `GET /maintenance/due?status=`. */
export const SCHEDULE_UNIT_STATUSES = ['scheduled', 'due', 'completed', 'cancelled'] as const;

/** `GET /maintenance-records?status=`. */
export const RECORD_STATUSES = ['completed', 'cancelled'] as const;

/** `Notes` cheklovi — TZ §18.3 (backend 2000 ga ruxsat beradi, UI 60 da to'xtatadi). */
export const NOTES_MAX_LENGTH = 60;

/** Invoice fayl cheklovi — F111 (PDF/JPG/PNG ≤ 10 MB). */
export const INVOICE_MAX_BYTES = 10 * 1024 * 1024;
export const INVOICE_ACCEPTED_TYPES = ['application/pdf', 'image/jpeg', 'image/png'] as const;
