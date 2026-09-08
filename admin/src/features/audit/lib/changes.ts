/**
 * Histories (`/audit`) — `Changes` ustuni matni
 * (`docs/tz/07-9-chat-support-audit.md` §7.10.3).
 *
 * Formatlash mantiqi `@/lib/auditChange` da umumiy (Company history bilan
 * bir xil DTO shakli) — bu yerda faqat modulning i18n kalitlari bog'lanadi.
 */
import type { TFunction } from 'i18next';

import type { AuditLogEntry } from '@/api/types';
import { formatFieldChange, type FieldChangeEntry } from '@/lib/auditChange';

const AUDIT_CHANGE_KEYS = {
  deleted: 'audit.list.changeDeleted',
  updated: 'audit.list.changeUpdated',
  fieldOnly: 'audit.list.changeField',
} as const;

/**
 * `field` yo'q bo'lsa (`login`/`logout`/`export` amallarida ustun farqi yo'q)
 * → `N/A`. Aks holda `<field>` bo'yicha o'zgarish matni.
 */
export function formatAuditChange(
  t: TFunction,
  entry: Pick<AuditLogEntry, 'action' | 'field' | 'old_value' | 'new_value'> & FieldChangeEntry,
): string {
  return formatFieldChange(t, entry, AUDIT_CHANGE_KEYS);
}
