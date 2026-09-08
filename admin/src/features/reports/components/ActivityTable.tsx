/**
 * Activity Report jadvali — `Drivers`/`Units` tabi bo'yicha ustunlar (7.8.1, F120).
 *
 * Ustun tartibi spetsifikatsiyaga aynan mos: `Driver Name`/`Unit # → Start Odometer →
 * End Odometer → Odometer Change → Driving Time` — `Odometer Change` alohida ustun
 * (`= End − Start`), `End Odometer` oxirgi ustun **emas** (F120).
 *
 * **D31.1 (backend bo'shlig'i):** `ActivityRow`da `driving_time`/engine hours maydoni
 * mavjud emas (swagger tasdiqlangan) — ustun saqlanadi, lekin qiymati doim `N/A` va
 * sarlavhada tushuntiruvchi `title` bor. Backend CR nomzodi — `docs/tz/16-17-…` D31.
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import type { ColumnDef } from '@tanstack/react-table';

import type { ActivityRow } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { NA } from '@/lib/format';
import { useUnitSystem } from '@/hooks/useUnitSystem';

export type ActivitySubject = 'drivers' | 'units';

export interface ActivityTableProps {
  subject: ActivitySubject;
  data: ActivityRow[];
  isLoading?: boolean;
  isError?: boolean;
  errorMessage?: string;
  onRetry?: () => void;
  emptyDescription?: string;
  onClearFilters?: () => void;
  rowOffset?: number;
  onRowClick?: (row: ActivityRow) => void;
}

export function ActivityTable({
  subject,
  data,
  isLoading,
  isError,
  errorMessage,
  onRetry,
  emptyDescription,
  onClearFilters,
  rowOffset = 0,
  onRowClick,
}: ActivityTableProps) {
  const { t } = useTranslation();
  const { formatDistance } = useUnitSystem();

  const columns: ColumnDef<ActivityRow, unknown>[] = useMemo(() => {
    const nameColumn: ColumnDef<ActivityRow, unknown> = {
      id: 'name',
      header: t(
        subject === 'drivers'
          ? 'reports.activityReport.columns.driverName'
          : 'reports.activityReport.columns.unitNumber',
      ),
      cell: ({ row }) => row.original.name ?? NA,
    };

    return [
      {
        id: 'index',
        header: t('reports.activityReport.columns.index'),
        cell: ({ row }) => rowOffset + row.index + 1,
      },
      nameColumn,
      {
        id: 'start_odometer',
        header: t('reports.activityReport.columns.startOdometer'),
        cell: ({ row }) =>
          row.original.has_data === false ? NA : formatDistance(row.original.start_odometer_m),
      },
      {
        id: 'end_odometer',
        header: t('reports.activityReport.columns.endOdometer'),
        cell: ({ row }) =>
          row.original.has_data === false ? NA : formatDistance(row.original.end_odometer_m),
      },
      {
        id: 'odometer_change',
        header: t('reports.activityReport.columns.odometerChange'),
        cell: ({ row }) =>
          row.original.has_data === false ? NA : formatDistance(row.original.odometer_change_m),
      },
      {
        id: 'driving_time',
        header: () => (
          <span title={t('reports.activityReport.drivingTimeUnavailable')}>
            {t('reports.activityReport.columns.drivingTime')}
          </span>
        ),
        // D31.1 — `ActivityRow`da bu maydon backendda yo'q, doim N/A (registry D31).
        cell: () => NA,
      },
    ];
  }, [t, subject, rowOffset, formatDistance]);

  return (
    <DataTable
      tableId={`reports-activity-${subject}`}
      columns={columns}
      data={data}
      isLoading={isLoading}
      isError={isError}
      errorMessage={errorMessage}
      onRetry={onRetry}
      emptyDescription={emptyDescription}
      onClearFilters={onClearFilters}
      onRowClick={onRowClick}
      getRowId={(row, index) => row.subject_id ?? String(index)}
    />
  );
}

export default ActivityTable;
