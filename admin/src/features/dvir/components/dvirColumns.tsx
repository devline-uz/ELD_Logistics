/**
 * DVIR ro'yxati ustunlari (§7.5): `# · Driver Name · Unit # / Trailer · Type ·
 * Defects · Location · Created At · Status · Action`.
 *
 * `Defects` — nuqsonlar soni; kritik bo'lsa qizil ikonka (F108).
 */
import type { ColumnDef } from '@tanstack/react-table';
import type { TFunction } from 'i18next';
import { AlertTriangle } from 'lucide-react';

import type { DvirReport } from '@/api/types';
import { Icon } from '@/components/ui/Icon';
import type { UseDateFormatResult } from '@/hooks/useDateFormat';
import { formatPersonName } from '@/lib/format';

import { DvirStatusBadge } from './DvirStatusBadge';

export interface DvirColumnsOptions {
  startIndex: number;
  dateFormat: UseDateFormatResult;
  onView: (report: DvirReport) => void;
}

function driverName(report: DvirReport, t: TFunction): string {
  return formatPersonName(report.driver, t('common.na'));
}

export function buildDvirColumns(
  t: TFunction,
  options: DvirColumnsOptions,
): ColumnDef<DvirReport, unknown>[] {
  const { startIndex, dateFormat, onView } = options;

  return [
    {
      id: 'index',
      header: t('dvir.list.columns.index'),
      enableHiding: false,
      enableSorting: false,
      cell: ({ row }) => startIndex + row.index + 1,
    },
    {
      id: 'driver',
      header: t('dvir.list.columns.driver'),
      cell: ({ row }) => driverName(row.original, t),
    },
    {
      id: 'unit',
      header: t('dvir.list.columns.unit'),
      cell: ({ row }) => {
        const trailers = row.original.trailer_ids?.length ?? 0;
        const unit = row.original.unit_number ?? row.original.unit_id ?? t('common.na');
        return trailers > 0 ? `${unit} / ${trailers}` : unit;
      },
    },
    {
      id: 'type',
      header: t('dvir.list.columns.type'),
      cell: ({ row }) =>
        row.original.type ? t(`enums.dvir_type.${row.original.type}`) : t('common.na'),
    },
    {
      id: 'defects',
      header: t('dvir.list.columns.defects'),
      cell: ({ row }) => {
        const count = row.original.defects?.length ?? 0;
        return (
          <span className="inline-flex items-center gap-1">
            {row.original.has_critical_defect ? (
              <Icon
                icon={AlertTriangle}
                size={16}
                className="text-error-base"
                label={t('dvir.list.criticalDefectTitle')}
              />
            ) : null}
            <span>{t('dvir.list.defectsCount', { count })}</span>
          </span>
        );
      },
    },
    {
      id: 'location',
      header: t('dvir.list.columns.location'),
      cell: ({ row }) => row.original.location_text ?? t('common.na'),
    },
    {
      id: 'created_at',
      header: t('dvir.list.columns.createdAt'),
      cell: ({ row }) => dateFormat.formatDateTime(row.original.created_at),
    },
    {
      id: 'status',
      header: t('dvir.list.columns.status'),
      cell: ({ row }) => <DvirStatusBadge status={row.original.status} />,
    },
    {
      id: 'action',
      header: t('dvir.list.columns.action'),
      enableHiding: false,
      enableSorting: false,
      cell: ({ row }) => (
        <button
          type="button"
          className="text-body-sm font-medium text-primary hover:underline"
          onClick={(event) => {
            event.stopPropagation();
            onView(row.original);
          }}
        >
          {t('dvir.actions.view')}
        </button>
      ),
    },
  ];
}
