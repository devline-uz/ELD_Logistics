/**
 * Routes jadvali ustunlari — §7.7.3: `# · Unit # · Driver · From · To ·
 * Sequence · Geofence · Started · Completed · Status · Action`.
 */
import type { ColumnDef } from '@tanstack/react-table';
import type { TFunction } from 'i18next';

import type { Route } from '@/api/types';
import { StatusChip, type StatusChipTone } from '@/components/ui/StatusChip';
import { NA } from '@/lib/format';

export const ROUTE_STATUS_TONE: Record<string, StatusChipTone> = {
  ongoing: 'info',
  completed: 'success',
  not_completed: 'warning',
  cancelled: 'neutral',
};

export interface RoutesColumnsHelpers {
  formatDateTime: (value: string | null | undefined) => string;
  formatDistance: (meters: number | null | undefined) => string;
}

export function buildRoutesColumns(
  t: TFunction,
  startIndex: number,
  helpers: RoutesColumnsHelpers,
): ColumnDef<Route, unknown>[] {
  return [
    {
      id: 'index',
      header: t('routes.list.columns.index'),
      enableHiding: false,
      enableSorting: false,
      cell: ({ row }) => startIndex + row.index + 1,
    },
    {
      id: 'unit_number',
      header: t('routes.list.columns.unitNumber'),
      cell: ({ row }) => row.original.unit_number ?? NA,
    },
    {
      id: 'driver',
      header: t('routes.list.columns.driver'),
      cell: ({ row }) => row.original.driver_name ?? NA,
    },
    {
      id: 'from',
      header: t('routes.list.columns.from'),
      cell: ({ row }) => row.original.origin?.text ?? NA,
    },
    {
      id: 'to',
      header: t('routes.list.columns.to'),
      cell: ({ row }) => row.original.destination?.text ?? NA,
    },
    {
      id: 'sequence',
      header: t('routes.list.columns.sequence'),
      accessorKey: 'sequence',
      enableSorting: true,
    },
    {
      id: 'geofence',
      header: t('routes.list.columns.geofence'),
      cell: ({ row }) => helpers.formatDistance(row.original.geofence_m),
    },
    {
      id: 'started',
      header: t('routes.list.columns.started'),
      cell: ({ row }) => helpers.formatDateTime(row.original.started_at),
    },
    {
      id: 'completed',
      header: t('routes.list.columns.completed'),
      cell: ({ row }) => helpers.formatDateTime(row.original.completed_at),
    },
    {
      id: 'status',
      header: t('routes.list.columns.status'),
      cell: ({ row }) => {
        const status = row.original.status ?? 'ongoing';
        return (
          <StatusChip
            status={t(`enums.route_status.${status}`, { defaultValue: status })}
            tone={ROUTE_STATUS_TONE[status] ?? 'neutral'}
          />
        );
      },
    },
  ];
}
