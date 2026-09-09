/**
 * Logs By Driver — jadval ustunlari (7.4.2).
 */
import type { ColumnDef } from '@tanstack/react-table';
import type { TFunction } from 'i18next';

import type { DailyLogSummary, HosSummary, Violation } from '@/api/types';
import { Badge } from '@/components/ui/Badge';
import { StatusChip } from '@/components/ui/StatusChip';
import type { UseDateFormatResult } from '@/hooks/useDateFormat';
import type { UseUnitSystemResult } from '@/hooks/useUnitSystem';

const CERTIFICATION_TONE: Record<
  NonNullable<DailyLogSummary['certification_status']>,
  'warning' | 'success' | 'error'
> = {
  uncertified: 'warning',
  certified: 'success',
  needs_recertify: 'error',
};

export interface LogsByDriverColumnsOptions {
  startIndex: number;
  showExtended: boolean;
  hosByDate: Record<string, HosSummary | undefined>;
  violationsByLogId: Map<string, Violation[]>;
  dateFormat: UseDateFormatResult;
  unitSystem: UseUnitSystemResult;
}

export function buildLogsByDriverColumns(
  t: TFunction,
  options: LogsByDriverColumnsOptions,
): ColumnDef<DailyLogSummary, unknown>[] {
  const { startIndex, showExtended, hosByDate, violationsByLogId, dateFormat, unitSystem } =
    options;

  const baseColumns: ColumnDef<DailyLogSummary, unknown>[] = [
    {
      id: 'index',
      header: t('logs.byDriver.columns.index'),
      enableHiding: false,
      enableSorting: false,
      cell: ({ row }) => startIndex + row.index + 1,
    },
    {
      id: 'log_date',
      header: t('logs.byDriver.columns.date'),
      cell: ({ row }) => dateFormat.formatDate(row.original.log_date),
    },
    {
      id: 'unit_ids',
      header: t('logs.byDriver.columns.unitNumber'),
      enableSorting: false,
      cell: ({ row }) => (row.original.unit_ids ?? []).join(', ') || t('common.na'),
    },
    {
      id: 'distance_m',
      header: t('logs.byDriver.columns.distance'),
      cell: ({ row }) => unitSystem.formatDistance(row.original.distance_m),
    },
    {
      id: 'off_min',
      header: t('logs.byDriver.columns.off'),
      cell: ({ row }) => dateFormat.formatDuration(row.original.totals?.off_min ?? null),
    },
    {
      id: 'sb_min',
      header: t('logs.byDriver.columns.sb'),
      cell: ({ row }) => dateFormat.formatDuration(row.original.totals?.sb_min ?? null),
    },
    {
      id: 'drive_min',
      header: t('logs.byDriver.columns.dr'),
      cell: ({ row }) => dateFormat.formatDuration(row.original.totals?.drive_min ?? null),
    },
    {
      id: 'on_min',
      header: t('logs.byDriver.columns.on'),
      cell: ({ row }) => dateFormat.formatDuration(row.original.totals?.on_min ?? null),
    },
    {
      id: 'certification_status',
      header: t('logs.byDriver.columns.certification'),
      cell: ({ row }) => {
        const status = row.original.certification_status ?? 'uncertified';
        return (
          <div className="flex flex-col">
            <Badge tone={CERTIFICATION_TONE[status]}>
              {t(`logs.byDriver.certificationStatus.${status}`)}
            </Badge>
            {row.original.signed_at ? (
              <span className="text-body-sm text-neutral-600">
                {dateFormat.formatDateTime(row.original.signed_at)}
              </span>
            ) : null}
          </div>
        );
      },
    },
    {
      id: 'ready',
      header: t('logs.byDriver.columns.ready'),
      cell: ({ row }) => (
        <StatusChip
          status={
            row.original.ready ? t('logs.byDriver.ready.ready') : t('logs.byDriver.ready.notReady')
          }
          tone={row.original.ready ? 'success' : 'danger'}
        />
      ),
    },
    {
      id: 'warnings_violations',
      header: t('logs.byDriver.columns.warningsViolations'),
      enableSorting: false,
      cell: ({ row }) => {
        const logId = row.original.id;
        const list = (logId && violationsByLogId.get(logId)) || [];
        if (list.length === 0) return <span className="text-neutral-400">0</span>;
        const titleText = list
          .map((violation) => t(`logs.violations.type.${violation.type}`))
          .join(', ');
        const hasHardViolation = list.some((violation) => violation.severity === 'violation');
        return (
          <span title={titleText}>
            <Badge tone={hasHardViolation ? 'error' : 'warning'}>{list.length}</Badge>
          </span>
        );
      },
    },
  ];

  if (!showExtended) return baseColumns;

  const counterColumn = (
    id: 'break_left_min' | 'drive_left_min' | 'shift_left_min' | 'cycle_left_min',
    labelKey: string,
  ): ColumnDef<DailyLogSummary, unknown> => ({
    id,
    header: t(labelKey),
    enableSorting: false,
    cell: ({ row }) => {
      const summary = row.original.log_date ? hosByDate[row.original.log_date] : undefined;
      return dateFormat.formatDuration(summary?.counters?.[id] ?? null);
    },
  });

  return [
    ...baseColumns,
    counterColumn('break_left_min', 'logs.hos.rings.break'),
    counterColumn('drive_left_min', 'logs.hos.rings.drive'),
    counterColumn('shift_left_min', 'logs.hos.rings.shift'),
    counterColumn('cycle_left_min', 'logs.hos.rings.cycle'),
    {
      id: 'recap',
      header: t('logs.byUnit.columns.recap'),
      enableSorting: false,
      cell: ({ row }) => {
        const summary = row.original.log_date ? hosByDate[row.original.log_date] : undefined;
        const nextDay = summary?.recap?.[0];
        return nextDay
          ? dateFormat.formatDuration(nextDay.gained_next_min ?? null)
          : t('common.na');
      },
    },
  ];
}
