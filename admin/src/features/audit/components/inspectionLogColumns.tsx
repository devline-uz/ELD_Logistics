/**
 * Inspection logs — jadval ustunlari (8.11, §7.12). Har satr —
 * `InspectionReport.days[]` dan bitta `DailyLogDetail` (roadside 7 kun +
 * bugun oynasidagi bitta kun).
 */
import type { ColumnDef } from '@tanstack/react-table';
import type { TFunction } from 'i18next';

import type { DailyLogDetail } from '@/api/types';
import { Badge } from '@/components/ui/Badge';
import { StatusChip } from '@/components/ui/StatusChip';
import type { UseDateFormatResult } from '@/hooks/useDateFormat';
import type { UseUnitSystemResult } from '@/hooks/useUnitSystem';
import { NA } from '@/lib/format';

const CERTIFICATION_TONE: Record<
  NonNullable<DailyLogDetail['certification_status']>,
  'warning' | 'success' | 'error'
> = {
  uncertified: 'warning',
  certified: 'success',
  needs_recertify: 'error',
};

export interface InspectionLogColumnsOptions {
  dateFormat: UseDateFormatResult;
  unitSystem: UseUnitSystemResult;
}

export function buildInspectionLogColumns(
  t: TFunction,
  options: InspectionLogColumnsOptions,
): ColumnDef<DailyLogDetail, unknown>[] {
  const { dateFormat, unitSystem } = options;

  return [
    {
      id: 'log_date',
      header: t('inspection.list.columns.date'),
      cell: ({ row }) => dateFormat.formatDateWithWeekday(row.original.log_date),
    },
    {
      id: 'driver_name',
      header: t('inspection.list.columns.driver'),
      cell: ({ row }) => row.original.driver_name ?? NA,
    },
    {
      id: 'co_driver_name',
      header: t('inspection.list.columns.coDriver'),
      cell: ({ row }) => row.original.co_driver_name ?? NA,
    },
    {
      id: 'unit_ids',
      header: t('inspection.list.columns.unitNumber'),
      enableSorting: false,
      cell: ({ row }) => (row.original.unit_ids ?? []).join(', ') || NA,
    },
    {
      id: 'distance_m',
      header: t('inspection.list.columns.distance'),
      cell: ({ row }) => unitSystem.formatDistance(row.original.distance_m),
    },
    {
      id: 'certification_status',
      header: t('inspection.list.columns.certification'),
      cell: ({ row }) => {
        const status = row.original.certification_status ?? 'uncertified';
        return (
          <div className="flex flex-col">
            <Badge tone={CERTIFICATION_TONE[status]}>
              {t(`inspection.list.certificationStatus.${status}`)}
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
      header: t('inspection.list.columns.ready'),
      cell: ({ row }) => (
        <StatusChip
          status={
            row.original.ready
              ? t('inspection.list.ready.ready')
              : t('inspection.list.ready.notReady')
          }
          tone={row.original.ready ? 'success' : 'danger'}
        />
      ),
    },
    {
      id: 'violations',
      header: t('inspection.list.columns.violations'),
      enableSorting: false,
      cell: ({ row }) => {
        const list = row.original.violations ?? [];
        if (list.length === 0) return <span className="text-neutral-400">0</span>;
        const titleText = list
          .map((violation) => t(`inspection.list.violationType.${violation.type}`))
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
}
