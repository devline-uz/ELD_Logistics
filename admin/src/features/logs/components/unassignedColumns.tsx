/**
 * Unassigned Driving — jadval ustunlari (7.4.5): `# · Unit # · Start · End ·
 * Duration · Distance · Start/End location · Status · Action`.
 *
 * **F104**: 8 kundan ortiq `pending` — satr `error` fonda.
 */
import type { ColumnDef } from '@tanstack/react-table';
import type { TFunction } from 'i18next';

import type { TrackingUnidentifiedEvent } from '@/api/types';
import { Badge } from '@/components/ui/Badge';
import type { UseDateFormatResult } from '@/hooks/useDateFormat';
import type { UseUnitSystemResult } from '@/hooks/useUnitSystem';

const STATUS_TONE: Record<
  NonNullable<TrackingUnidentifiedEvent['status']>,
  'warning' | 'success' | 'info'
> = {
  pending: 'warning',
  assigned: 'success',
  annotated: 'info',
};

export const OVERDUE_PENDING_DAYS = 8;

export interface UnassignedColumnsOptions {
  startIndex: number;
  dateFormat: UseDateFormatResult;
  unitSystem: UseUnitSystemResult;
  canAssign: boolean;
  canAnnotate: boolean;
  onAssign: (event: TrackingUnidentifiedEvent) => void;
  onAnnotate: (event: TrackingUnidentifiedEvent) => void;
}

export function buildUnassignedColumns(
  t: TFunction,
  options: UnassignedColumnsOptions,
): ColumnDef<TrackingUnidentifiedEvent, unknown>[] {
  const { startIndex, dateFormat, unitSystem, canAssign, canAnnotate, onAssign, onAnnotate } =
    options;

  return [
    {
      id: 'index',
      header: t('logs.unassigned.columns.index'),
      enableHiding: false,
      enableSorting: false,
      cell: ({ row }) => startIndex + row.index + 1,
    },
    {
      id: 'unit_number',
      accessorKey: 'unit_number',
      header: t('logs.unassigned.columns.unitNumber'),
    },
    {
      id: 'start_at',
      header: t('logs.unassigned.columns.start'),
      cell: ({ row }) => dateFormat.formatDateTime(row.original.start_at),
    },
    {
      id: 'end_at',
      header: t('logs.unassigned.columns.end'),
      cell: ({ row }) => dateFormat.formatDateTime(row.original.end_at),
    },
    {
      id: 'duration',
      header: t('logs.unassigned.columns.duration'),
      enableSorting: false,
      cell: ({ row }) => {
        const start = row.original.start_at ? new Date(row.original.start_at).getTime() : NaN;
        const end = row.original.end_at ? new Date(row.original.end_at).getTime() : NaN;
        if (Number.isNaN(start) || Number.isNaN(end)) return t('common.na');
        return dateFormat.formatDuration((end - start) / 60000);
      },
    },
    {
      id: 'distance_m',
      header: t('logs.unassigned.columns.distance'),
      cell: ({ row }) => unitSystem.formatDistance(row.original.distance_m),
    },
    {
      id: 'status',
      header: t('logs.unassigned.columns.status'),
      cell: ({ row }) => {
        const status = row.original.status ?? 'pending';
        const overdue = isOverduePending(row.original);
        return (
          <div className="flex items-center gap-1.5">
            <Badge tone={overdue ? 'error' : STATUS_TONE[status]}>
              {t(`logs.unassigned.status.${status}`)}
            </Badge>
            {overdue ? (
              <span className="text-body-sm font-medium text-error-dark">
                {t('logs.unassigned.overdue', { days: row.original.pending_days })}
              </span>
            ) : null}
          </div>
        );
      },
    },
    {
      id: 'action',
      header: '',
      enableHiding: false,
      enableSorting: false,
      cell: ({ row }) => {
        const event = row.original;
        const canAct = (event.status ?? 'pending') === 'pending';
        if (!canAct) return null;
        return (
          <div className="flex items-center gap-2">
            {canAssign ? (
              <button
                type="button"
                className="text-body-sm font-medium text-primary hover:underline"
                onClick={() => onAssign(event)}
              >
                {t('logs.unassigned.actions.assign')}
              </button>
            ) : null}
            {canAnnotate ? (
              <button
                type="button"
                className="text-body-sm font-medium text-neutral-700 hover:underline"
                onClick={() => onAnnotate(event)}
              >
                {t('logs.unassigned.actions.annotate')}
              </button>
            ) : null}
          </div>
        );
      },
    },
  ];
}

export function isOverduePending(event: TrackingUnidentifiedEvent): boolean {
  return (
    (event.status ?? 'pending') === 'pending' && (event.pending_days ?? 0) >= OVERDUE_PENDING_DAYS
  );
}
