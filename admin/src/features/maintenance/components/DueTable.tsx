/**
 * `Due` jadvali — `Due` tabi va reja ichidagi «N Units» ekrani uchun bitta
 * komponent (ustunlar to'plami §7.6 bo'yicha **bir xil**).
 *
 * **N11/F109**: `Remaining Frequency` va `Reminder Sent` ustunlari bo'sh va
 * to'la holatda **bir xil** — ustunlar `data` uzunligidan qat'i nazar
 * o'zgarmaydi.
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import type { ColumnDef } from '@tanstack/react-table';

import type { MaintenanceScheduleUnit, SortOrder } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { RowActionsMenu } from '@/components/data/RowActionsMenu';
import { Badge } from '@/components/ui/Badge';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useWriteGuard } from '@/hooks/useWriteGuard';
import { PERM } from '@/lib/permissions';

import { useIntervalFormat } from '../useIntervalFormat';
import { useUnitLookup } from '../useUnitLookup';
import { NA } from '@/lib/format';

export interface DueTableProps {
  tableId: string;
  data: MaintenanceScheduleUnit[];
  isLoading?: boolean;
  isError?: boolean;
  errorMessage?: string;
  onRetry?: () => void;
  emptyDescription?: string;
  onClearFilters?: () => void;
  /** Sahifadagi birinchi qator raqami (`#` ustuni uchun). */
  rowOffset?: number;
  onView?: (row: MaintenanceScheduleUnit) => void;
  onComplete?: (row: MaintenanceScheduleUnit) => void;
  onCancel?: (row: MaintenanceScheduleUnit) => void;
  sort?: string;
  order?: SortOrder;
}

export function DueTable({
  tableId,
  data,
  isLoading,
  isError,
  errorMessage,
  onRetry,
  emptyDescription,
  onClearFilters,
  rowOffset = 0,
  onView,
  onComplete,
  onCancel,
}: DueTableProps) {
  const { t } = useTranslation();
  const { formatInterval } = useIntervalFormat();
  const { formatDateTime } = useDateFormat();
  const { byId } = useUnitLookup();
  const { canWrite, disabledReason } = useWriteGuard();

  const columns: ColumnDef<MaintenanceScheduleUnit, unknown>[] = useMemo(
    () => [
      {
        id: 'index',
        header: t('maintenance.due.columns.index'),
        cell: ({ row }) => rowOffset + row.index + 1,
      },
      {
        id: 'unit_number',
        header: t('maintenance.due.columns.unit'),
        cell: ({ row }) => row.original.unit_number ?? NA,
      },
      {
        id: 'license_plate',
        header: t('maintenance.due.columns.licensePlate'),
        cell: ({ row }) => byId.get(row.original.unit_id ?? '')?.license_plate ?? NA,
      },
      {
        id: 'type',
        header: t('maintenance.due.columns.type'),
        cell: ({ row }) =>
          row.original.schedule_type
            ? t(`enums.maintenance_type.${row.original.schedule_type}`)
            : NA,
      },
      {
        id: 'schedule_name',
        header: t('maintenance.due.columns.name'),
        cell: ({ row }) => row.original.schedule_name ?? NA,
      },
      {
        id: 'remaining',
        header: t('maintenance.due.columns.remainingFrequency'),
        cell: ({ row }) => {
          const text = formatInterval(row.original.remaining, row.original.interval_unit);
          // F110/§16 C4: `remaining < 0` → **Overdue** (qizil), imlo to'g'rilangan.
          if (row.original.overdue) {
            return (
              <span className="flex items-center gap-2">
                <span className="text-error-dark">{text}</span>
                <Badge tone="error">{t('maintenance.due.overdue')}</Badge>
              </span>
            );
          }
          return text;
        },
      },
      {
        id: 'reminder_sent_at',
        header: t('maintenance.due.columns.reminderSent'),
        cell: ({ row }) =>
          row.original.reminder_sent_at
            ? formatDateTime(row.original.reminder_sent_at)
            : t('maintenance.due.reminderNotSent'),
      },
    ],
    [t, byId, formatInterval, formatDateTime, rowOffset],
  );

  return (
    <DataTable
      tableId={tableId}
      columns={columns}
      data={data}
      isLoading={isLoading}
      isError={isError}
      errorMessage={errorMessage}
      onRetry={onRetry}
      emptyTitle={t('maintenance.empty.title')}
      emptyDescription={emptyDescription ?? t('maintenance.empty.description')}
      onClearFilters={onClearFilters}
      getRowId={(row, index) => row.id ?? String(index)}
      onRowClick={onView}
      rowActions={(row) => {
        const closed = row.status === 'completed' || row.status === 'cancelled';
        return (
          <RowActionsMenu
            ariaLabel={t('maintenance.due.rowActionsLabel', { unit: row.unit_number })}
            items={[
              {
                key: 'view',
                label: t('maintenance.actions.view'),
                onSelect: () => onView?.(row),
              },
              {
                key: 'complete',
                label: t('maintenance.actions.markComplete'),
                onSelect: () => onComplete?.(row),
                disabled: closed || !canWrite(PERM.maintenanceComplete),
                disabledReason: disabledReason(PERM.maintenanceComplete),
              },
              {
                key: 'cancel',
                label: t('maintenance.actions.cancel'),
                danger: true,
                onSelect: () => onCancel?.(row),
                disabled: closed || !canWrite(PERM.maintenanceCancel),
                disabledReason: disabledReason(PERM.maintenanceCancel),
              },
            ]}
          />
        );
      }}
    />
  );
}

export default DueTable;
