/**
 * Notification settings — matritsa holati va saqlash payload'i (8.5, §7.13.4).
 *
 * Sof funksiyalar: `NotificationMatrix` UI komponenti va `NotificationSettingsPage`
 * shular ustiga quriladi. Faqat **o'zgargan** qatorlar `PATCH` payload'iga
 * kiradi (backend, Q89: "faqat `settings[]` da ko'rsatilgan turlar yoziladi").
 */
import type { NotificationSetting, NotificationSettingUpdate } from '@/api/types';
import { isNotificationChannelLocked } from '@/api/queries/notificationSettings';

export const NOTIFICATION_CHANNELS = ['push', 'email', 'sms', 'telegram'] as const;
export type NotificationChannel = (typeof NOTIFICATION_CHANNELS)[number];

export interface NotificationMatrixRow {
  alertType: string;
  enabled: boolean;
  channels: NotificationChannel[];
  recipientRoles: string[];
}

/** `NotificationSetting` (backend) → qator holati (UI). */
export function settingToRow(setting: NotificationSetting): NotificationMatrixRow {
  return {
    alertType: setting.alert_type ?? '',
    enabled: setting.enabled ?? true,
    channels: [...(setting.channels ?? [])] as NotificationChannel[],
    recipientRoles: [...(setting.recipient_roles ?? [])],
  };
}

export function settingsToRows(settings: readonly NotificationSetting[]): NotificationMatrixRow[] {
  return settings.map(settingToRow);
}

function sortedEqual(a: readonly string[], b: readonly string[]): boolean {
  const left = [...a].sort();
  const right = [...b].sort();
  return left.length === right.length && left.every((value, index) => value === right[index]);
}

/** Ikki qator bir xil ma'lumotni ifodalaydimi (saqlash uchun "o'zgargan" tekshiruvi). */
export function rowsEqual(a: NotificationMatrixRow, b: NotificationMatrixRow): boolean {
  return (
    a.enabled === b.enabled &&
    sortedEqual(a.channels, b.channels) &&
    sortedEqual(a.recipientRoles, b.recipientRoles)
  );
}

/**
 * F148 (Q89): `hos_*`/`eld_*` turlarda `push` kanali hech qachon
 * o'chirilmaydi — payload qurilishida ham himoyalanadi (UI ustidan
 * ishonib bo'lmaydi, F148 ikki qatlamda ta'minlanadi).
 */
export function enforceLockedChannels(row: NotificationMatrixRow): NotificationMatrixRow {
  if (isNotificationChannelLocked(row.alertType, 'push') && !row.channels.includes('push')) {
    return { ...row, channels: [...row.channels, 'push'] };
  }
  return row;
}

/**
 * `original` bilan solishtirib faqat o'zgargan qatorlarni `PATCH` payload'iga
 * yig'adi. `original` da yo'q (yangi) qator uchraса — baribir kiritiladi
 * (backend ro'yxati statik 16 ta, bu holat amalda bo'lmaydi, himoya sifatida).
 */
export function buildNotificationSettingsPayload(
  original: readonly NotificationMatrixRow[],
  draft: readonly NotificationMatrixRow[],
): NotificationSettingUpdate[] {
  const originalByType = new Map(original.map((row) => [row.alertType, row]));

  const changed: NotificationSettingUpdate[] = [];
  for (const row of draft) {
    const safeRow = enforceLockedChannels(row);
    const before = originalByType.get(safeRow.alertType);
    if (before && rowsEqual(before, safeRow)) continue;

    changed.push({
      alert_type: safeRow.alertType as NotificationSettingUpdate['alert_type'],
      enabled: safeRow.enabled,
      channels: safeRow.channels,
      recipient_roles: safeRow.recipientRoles,
    });
  }
  return changed;
}

/** Bitta katak (checkbox) uchun yangi kanal ro'yxatini hisoblaydi. */
export function toggleChannel(
  row: NotificationMatrixRow,
  channel: NotificationChannel,
  checked: boolean,
): NotificationMatrixRow {
  if (isNotificationChannelLocked(row.alertType, channel) && !checked) {
    // Majburiy katak — o'chirib bo'lmaydi, holat o'zgarmaydi.
    return row;
  }
  const next = checked
    ? [...new Set([...row.channels, channel])]
    : row.channels.filter((item) => item !== channel);
  return { ...row, channels: next };
}
