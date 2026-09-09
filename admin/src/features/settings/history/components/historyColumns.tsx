/**
 * Company history jadval ustunlari (8.7, §7.13.5): `Edited By · Changes ·
 * Date`. F149: dizayndagi uchta mustaqil qidiruv (`Search Driver` ·
 * `Search Dispatcher` · `Search Unit`) o'rniga bitta `user` + `table`
 * filtri — `Dispatcher` so'zi (begona rol nomi) bu ekranda umuman
 * ishlatilmaydi (§16).
 */
import type { ColumnDef } from '@tanstack/react-table';
import type { TFunction } from 'i18next';

import type { CompanyHistoryEntry } from '@/api/types';
import type { UseDateFormatResult } from '@/hooks/useDateFormat';
import { formatFieldChange } from '@/lib/auditChange';

export interface HistoryColumnsOptions {
  dateFormat: Pick<UseDateFormatResult, 'formatDateTime'>;
}

const KNOWN_ACTIONS = new Set([
  'create',
  'update',
  'delete',
  'soft_delete',
  'hos_policy_change',
  'subscription_change',
]);

/**
 * `action`/`field`/`old_value`/`new_value` → o'qiladigan "Changes" matni.
 * Umumiy mantiq `@/lib/auditChange` da (Histories ekrani bilan bir xil DTO
 * shakli) — bu yerda faqat modul i18n kalitlari bog'lanadi.
 */
export function formatHistoryChange(t: TFunction, entry: CompanyHistoryEntry): string {
  return formatFieldChange(t, entry, {
    deleted: 'settings.history.changeDeleted',
    updated: 'settings.history.changeUpdated',
    fieldOnly: 'settings.history.changeField',
    actionKey: (action) =>
      KNOWN_ACTIONS.has(action)
        ? `settings.history.actions.${action}`
        : 'settings.history.actions.update',
  });
}

export function buildHistoryColumns(
  t: TFunction,
  options: HistoryColumnsOptions,
): ColumnDef<CompanyHistoryEntry, unknown>[] {
  return [
    {
      id: 'edited_by',
      header: t('settings.history.columns.editedBy'),
      enableHiding: false,
      cell: ({ row }) => row.original.edited_by_name ?? t('common.na'),
    },
    {
      id: 'changes',
      header: t('settings.history.columns.changes'),
      cell: ({ row }) => (
        <div className="flex flex-col">
          <span>{formatHistoryChange(t, row.original)}</span>
          {row.original.table_name ? (
            <span className="text-body-sm text-neutral-600">{row.original.table_name}</span>
          ) : null}
        </div>
      ),
    },
    {
      id: 'date',
      header: t('settings.history.columns.date'),
      cell: ({ row }) => options.dateFormat.formatDateTime(row.original.ts),
    },
  ];
}
