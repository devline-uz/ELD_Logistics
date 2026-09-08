/**
 * Uncertified Logs jadvali — `/reports/uncertified-logs` (Bosqich 6.6, §7.8.5, F128).
 *
 * Ustunlar: `Driver · Log date · Days uncertified · Unit · Totals · Action`.
 *
 * **D33 (backend bo'shlig'i, `docs/tz/16-17-registry-open-questions.md`):**
 * `GET /reports/uncertified-logs` javobi (`UncertifiedLog`) faqat
 * `daily_log_id/driver_id/driver_name/log_date/certification_status/
 * days_overdue` maydonlarini beradi — **`Unit` va `Totals` uchun hech qanday
 * maydon yo'q**. Ustunlar spetsifikatsiya tartibini saqlash uchun ko'rsatiladi,
 * lekin qiymat doim `N/A` + sarlavhada tushuntiruvchi `title`.
 *
 * **D29:** `Send reminder` uchun backend endpointi yo'q — tugma doim
 * `disabled`, sababi tooltip orqali ko'rsatiladi (fe-permissions: "disabled
 * tugma hech qachon sababsiz qolmaydi").
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import type { ColumnDef } from '@tanstack/react-table';

import type { UncertifiedLog } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { Button } from '@/components/ui/Button';
import type { UseDateFormatResult } from '@/hooks/useDateFormat';
import { NA } from '@/lib/format';

export interface UncertifiedLogsTableProps {
  data: UncertifiedLog[];
  isLoading?: boolean;
  isError?: boolean;
  errorMessage?: string;
  onRetry?: () => void;
  emptyDescription?: string;
  onClearFilters?: () => void;
  rowOffset?: number;
  dateFormat: Pick<UseDateFormatResult, 'formatDate'>;
  onOpenLog: (log: UncertifiedLog) => void;
}

export function UncertifiedLogsTable({
  data,
  isLoading,
  isError,
  errorMessage,
  onRetry,
  emptyDescription,
  onClearFilters,
  rowOffset = 0,
  dateFormat,
  onOpenLog,
}: UncertifiedLogsTableProps) {
  const { t } = useTranslation();

  const columns: ColumnDef<UncertifiedLog, unknown>[] = useMemo(
    () => [
      {
        id: 'index',
        header: t('reports.uncertifiedLogs.columns.index'),
        enableHiding: false,
        enableSorting: false,
        cell: ({ row }) => rowOffset + row.index + 1,
      },
      {
        id: 'driver',
        header: t('reports.uncertifiedLogs.columns.driver'),
        cell: ({ row }) => row.original.driver_name ?? NA,
      },
      {
        id: 'log_date',
        header: t('reports.uncertifiedLogs.columns.logDate'),
        cell: ({ row }) => dateFormat.formatDate(row.original.log_date),
      },
      {
        id: 'days_overdue',
        header: t('reports.uncertifiedLogs.columns.daysUncertified'),
        cell: ({ row }) =>
          typeof row.original.days_overdue === 'number' ? row.original.days_overdue : NA,
      },
      {
        id: 'unit',
        header: () => (
          <span title={t('reports.uncertifiedLogs.unitUnavailable')}>
            {t('reports.uncertifiedLogs.columns.unit')}
          </span>
        ),
        // D33 — `UncertifiedLog`da unit maydoni backendda yo'q, doim N/A.
        cell: () => NA,
      },
      {
        id: 'totals',
        header: () => (
          <span title={t('reports.uncertifiedLogs.totalsUnavailable')}>
            {t('reports.uncertifiedLogs.columns.totals')}
          </span>
        ),
        // D33 — `UncertifiedLog`da kunlik totals maydoni backendda yo'q, doim N/A.
        cell: () => NA,
      },
      {
        id: 'action',
        header: t('reports.uncertifiedLogs.columns.action'),
        enableHiding: false,
        enableSorting: false,
        cell: ({ row }) => (
          <div className="flex items-center gap-2">
            <Button
              variant="ghost"
              size="sm"
              disabled
              title={t('reports.uncertifiedLogs.actions.sendReminderUnavailable')}
            >
              {t('reports.uncertifiedLogs.actions.sendReminder')}
            </Button>
            <Button
              variant="secondary"
              size="sm"
              disabled={!row.original.daily_log_id}
              onClick={() => onOpenLog(row.original)}
            >
              {t('reports.uncertifiedLogs.actions.openLog')}
            </Button>
          </div>
        ),
      },
    ],
    [t, rowOffset, dateFormat, onOpenLog],
  );

  return (
    <DataTable
      tableId="reports-uncertified-logs"
      columns={columns}
      data={data}
      isLoading={isLoading}
      isError={isError}
      errorMessage={errorMessage}
      onRetry={onRetry}
      emptyDescription={emptyDescription}
      onClearFilters={onClearFilters}
      getRowId={(log, index) => log.daily_log_id ?? String(index)}
    />
  );
}

export default UncertifiedLogsTable;
