/**
 * `alert_type` (16 qiymat, swagger `notifications.Notification.alert_type` enum)
 * bo'yicha yordamchi sof funksiyalar — 7.8, TZ §7.11 F143/F144.
 */

/** Swagger enum'idagi barcha 16 qiymat — sahifa filtri shu ro'yxatdan quriladi. */
export const ALERT_TYPES = [
  'hos_warning',
  'hos_violation',
  'route_assigned',
  'route_completed',
  'dvir_defects',
  'dvir_critical',
  'log_edit_request',
  'log_edit_resolved',
  'uncertified_log',
  'unidentified_driving',
  'eld_disconnected',
  'eld_malfunction',
  'maintenance_upcoming',
  'maintenance_overdue',
  'chat_message',
  'subscription_expiring',
] as const;

export type AlertType = (typeof ALERT_TYPES)[number];

export type AlertSeverity = 'error' | 'warning' | 'neutral';

/** Jadval/badge rangi — fe-design-system semantik xaritasi bilan mos. */
export function alertSeverity(alertType: string | null | undefined): AlertSeverity {
  if (!alertType) return 'neutral';
  if (
    alertType.endsWith('_violation') ||
    alertType === 'dvir_critical' ||
    alertType === 'eld_malfunction' ||
    alertType === 'eld_disconnected'
  ) {
    return 'error';
  }
  if (
    alertType === 'hos_warning' ||
    alertType === 'dvir_defects' ||
    alertType === 'uncertified_log' ||
    alertType === 'subscription_expiring' ||
    alertType.startsWith('maintenance_')
  ) {
    return 'warning';
  }
  return 'neutral';
}

/**
 * F143 — faqat `*_violation`/`dvir_critical`/`eld_malfunction` real-vaqt
 * hodisalari toast chiqaradi (replay bo'lmasa). Qolganlari faqat keshni
 * yangilaydi (belgi soni, ro'yxat).
 */
export function shouldToastForAlertType(alertType: string | null | undefined): boolean {
  if (!alertType) return false;
  return (
    alertType.endsWith('_violation') ||
    alertType === 'dvir_critical' ||
    alertType === 'eld_malfunction'
  );
}
