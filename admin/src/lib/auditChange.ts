/**
 * Audit/history "Changes" ustuni uchun yagona matn quruvchi.
 *
 * `GET /audit-logs` (`auditlog_dto.Entry`) va `GET /company/history`
 * (`company_dto.HistoryEntry`) bir xil `field`/`old_value`/`new_value`
 * shaklini qaytaradi, shuning uchun formatlash mantiqi shu yerda —
 * `features/audit` va `features/settings` bir-birini import qila olmaydi
 * (fe-conventions §2), umumiy narsa `lib/` ga chiqadi.
 *
 * Qiymatlar `maskSensitiveValue` orqali o'tadi (fe-security §5, F206) —
 * audit yozuvi parol/token qoldig'ini ochiq ko'rsatmasligi kerak.
 * Bo'sh qiymat idiomasi — `N/A` (§16).
 */
import type { TFunction } from 'i18next';

import { maskSensitiveValue } from '@/lib/sensitive';

/** Ikkala DTO uchun umumiy minimal shakl. */
export interface FieldChangeEntry {
  action?: string | null;
  field?: string | null;
  old_value?: string | null;
  new_value?: string | null;
}

/** Modul o'z i18n kalitlarini beradi (kalitlar `locales/en/<modul>.json` da). */
export interface FieldChangeKeys {
  /** `Deleted {{field}}` — `delete`/`soft_delete` amallari uchun. */
  deleted: string;
  /** `Updated {{field}}: {{oldValue}} → {{newValue}}`. */
  updated: string;
  /** `Changed {{field}}` — eski/yangi qiymat yo'q bo'lganda. */
  fieldOnly: string;
  /**
   * `field` umuman yo'q bo'lganda (login/logout/export) ishlatiladigan kalit.
   * Berilmasa — `common.na`.
   */
  actionKey?: (action: string) => string | undefined;
}

const DELETE_ACTIONS = new Set(['delete', 'soft_delete']);

export function formatFieldChange(
  t: TFunction,
  entry: FieldChangeEntry,
  keys: FieldChangeKeys,
): string {
  const action = entry.action ?? 'update';

  if (!entry.field) {
    const actionKey = keys.actionKey?.(action);
    return actionKey ? t(actionKey) : t('common.na');
  }

  if (DELETE_ACTIONS.has(action)) {
    return t(keys.deleted, { field: entry.field });
  }

  if (entry.old_value !== undefined && entry.new_value !== undefined) {
    return t(keys.updated, {
      field: entry.field,
      oldValue: maskSensitiveValue(entry.field, entry.old_value) || t('common.na'),
      newValue: maskSensitiveValue(entry.field, entry.new_value) || t('common.na'),
    });
  }

  return t(keys.fieldOnly, { field: entry.field });
}
