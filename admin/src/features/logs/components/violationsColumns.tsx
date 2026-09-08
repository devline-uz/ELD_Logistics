/**
 * Violations — jadval ustunlari (7.4.6): `# · Date · Driver · Unit · Type ·
 * Severity · Occurred at · Resolved at · Action`.
 *
 * **F105**: `Delete` amali yo'q — faqat `resolved` badge (`resolved_at`).
 */
import type { ColumnDef } from '@tanstack/react-table';
import type { TFunction } from 'i18next';

import type { Violation } from '@/api/types';
import { Badge } from '@/components/ui/Badge';
import type { UseDateFormatResult } from '@/hooks/useDateFormat';

export interface ViolationsColumnsOptions {
  startIndex: number;
  dateFormat: UseDateFormatResult;
  onView: (violation: Violation) => void;
}

export function buildViolationsColumns(
  t: TFunction,
  options: ViolationsColumnsOptions,
): ColumnDef<Violation, unknown>[] {
  const { startIndex, dateFormat, onView } = options;

  return [
    {
      id: 'index',
      header: t('logs.violationsList.columns.index'),
      enableHiding: false,
      enableSorting: false,
      cell: ({ row }) => startIndex + row.index + 1,
    },
    {
      id: 'log_date',
      header: t('logs.violationsList.columns.date'),
      cell: ({ row }) => dateFormat.formatDate(row.original.log_date),
    },
    {
      id: 'driver_name',
      header: t('logs.violationsList.columns.driver'),
      cell: ({ row }) => row.original.driver_name ?? t('common.na'),
    },
    {
      id: 'unit_id',
      header: t('logs.violationsList.columns.unit'),
      cell: ({ row }) => row.original.unit_id ?? t('common.na'),
    },
    {
      id: 'type',
      header: t('logs.violationsList.columns.type'),
      cell: ({ row }) => t(`logs.violations.type.${row.original.type}`),
    },
    {
      id: 'severity',
      header: t('logs.violationsList.columns.severity'),
      cell: ({ row }) => {
        const severity = row.original.severity ?? 'warning';
        return (
          <Badge tone={severity === 'violation' ? 'error' : 'warning'}>
            {t(`logs.violationsList.severity.${severity}`)}
          </Badge>
        );
      },
    },
    {
      id: 'occurred_at',
      header: t('logs.violationsList.columns.occurredAt'),
      cell: ({ row }) => dateFormat.formatDateTime(row.original.occurred_at),
    },
    {
      id: 'resolved_at',
      header: t('logs.violationsList.columns.resolvedAt'),
      cell: ({ row }) =>
        row.original.resolved_at ? (
          <Badge tone="success">{dateFormat.formatDateTime(row.original.resolved_at)}</Badge>
        ) : (
          <span className="text-neutral-400">{t('common.na')}</span>
        ),
    },
    {
      id: 'action',
      header: '',
      enableHiding: false,
      enableSorting: false,
      cell: ({ row }) => (
        <button
          type="button"
          className="text-body-sm font-medium text-primary hover:underline"
          onClick={() => onView(row.original)}
        >
          {t('common.actions.view')}
        </button>
      ),
    },
  ];
}
