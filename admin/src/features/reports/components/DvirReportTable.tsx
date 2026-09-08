/**
 * DVIR Report jadvali — `/reports/dvir` (Bosqich 6.5, §7.8.4, F107).
 *
 * Ustunlar: `# · Driver · Unit · Type · Status · Performed at · Location`.
 * **F107 [MUST]: bu jadvalda imzo joylashtirish/ko'rish elementi yo'q** — faqat
 * ro'yxat ko'rsatiladi, `dvirColumns.tsx` (features/dvir) dagi `Action` ustuni
 * ataylab olib tashlangan (admin bu ekrandan hech qanday DVIR amalini bajarmaydi).
 *
 * Status rang xaritasi `features/dvir/lib/status.ts`dagi `dvirStatusTone` bilan
 * bir xil, lekin ESLint `no-restricted-imports` features kesishmasini
 * taqiqlagani uchun mustaqil (kichik, ~10 qatorlik) nusxa sifatida saqlanadi.
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import type { ColumnDef } from '@tanstack/react-table';

import type { DvirReport } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { Badge, type BadgeTone } from '@/components/ui/Badge';
import type { UseDateFormatResult } from '@/hooks/useDateFormat';
import { NA, formatPersonName } from '@/lib/format';

type DvirStatus = NonNullable<DvirReport['status']>;

const STATUS_TONE: Record<DvirStatus, BadgeTone> = {
  draft: 'neutral',
  submitted_no_defects: 'info',
  submitted_defects_found: 'error',
  repaired: 'warning',
  certified: 'success',
  closed_no_certification: 'error',
};

export interface DvirReportTableProps {
  data: DvirReport[];
  isLoading?: boolean;
  isError?: boolean;
  errorMessage?: string;
  onRetry?: () => void;
  emptyDescription?: string;
  onClearFilters?: () => void;
  rowOffset?: number;
  dateFormat: Pick<UseDateFormatResult, 'formatDateTime'>;
}

export function DvirReportTable({
  data,
  isLoading,
  isError,
  errorMessage,
  onRetry,
  emptyDescription,
  onClearFilters,
  rowOffset = 0,
  dateFormat,
}: DvirReportTableProps) {
  const { t } = useTranslation();

  const columns: ColumnDef<DvirReport, unknown>[] = useMemo(
    () => [
      {
        id: 'index',
        header: t('reports.dvirReport.columns.index'),
        enableHiding: false,
        enableSorting: false,
        cell: ({ row }) => rowOffset + row.index + 1,
      },
      {
        id: 'driver',
        header: t('reports.dvirReport.columns.driver'),
        cell: ({ row }) => formatPersonName(row.original.driver),
      },
      {
        id: 'unit',
        header: t('reports.dvirReport.columns.unit'),
        cell: ({ row }) => row.original.unit_number ?? row.original.unit_id ?? NA,
      },
      {
        id: 'type',
        header: t('reports.dvirReport.columns.type'),
        cell: ({ row }) => (row.original.type ? t(`enums.dvir_type.${row.original.type}`) : NA),
      },
      {
        id: 'status',
        header: t('reports.dvirReport.columns.status'),
        cell: ({ row }) => {
          const status = row.original.status;
          if (!status) return NA;
          return <Badge tone={STATUS_TONE[status]}>{t(`enums.dvir_status.${status}`)}</Badge>;
        },
      },
      {
        id: 'performed_at',
        header: t('reports.dvirReport.columns.performedAt'),
        cell: ({ row }) => dateFormat.formatDateTime(row.original.performed_at),
      },
      {
        id: 'location',
        header: t('reports.dvirReport.columns.location'),
        cell: ({ row }) => row.original.location_text ?? NA,
      },
    ],
    [t, rowOffset, dateFormat],
  );

  return (
    <DataTable
      tableId="reports-dvir"
      columns={columns}
      data={data}
      isLoading={isLoading}
      isError={isError}
      errorMessage={errorMessage}
      onRetry={onRetry}
      emptyDescription={emptyDescription}
      onClearFilters={onClearFilters}
      getRowId={(report, index) => report.id ?? String(index)}
    />
  );
}

export default DvirReportTable;
