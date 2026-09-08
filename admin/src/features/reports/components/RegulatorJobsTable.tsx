/**
 * Regulator Export / FMCSA — job jadvali (7.8.3).
 *
 * F126: `Submission ID` emas — **`Job ID`** = `export_job.id` (backend enum'i
 * `queued|running|done|failed`, dizayndagi `Pending/Information` ishlatilmaydi).
 * `Driver Name`/`Comment`/`Start Date`/`End Date` — `export_job.params` (`ExportParams`)
 * dan o'qiladi; haydovchi nomi chaqiruvchi bergan `driverNameById` xaritasi bilan
 * bog'lanadi (`GET /reports/export-jobs` javobi faqat `driver_ids` UUID beradi).
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import type { ColumnDef } from '@tanstack/react-table';

import type { ExportJob } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { Badge } from '@/components/ui/Badge';
import { formatDateTime, NA } from '@/lib/format';

import { ExportJobDownloadAction } from './ExportJobDownloadAction';
import { EXPORT_JOB_STATUS_TONE } from '../lib/exportJobDisplay';

export interface RegulatorJobsTableProps {
  data: ExportJob[];
  driverNameById: ReadonlyMap<string, string>;
  isLoading?: boolean;
  isError?: boolean;
  errorMessage?: string;
  onRetry?: () => void;
  emptyDescription?: string;
  rowOffset?: number;
}

export function RegulatorJobsTable({
  data,
  driverNameById,
  isLoading,
  isError,
  errorMessage,
  onRetry,
  emptyDescription,
  rowOffset = 0,
}: RegulatorJobsTableProps) {
  const { t } = useTranslation();

  const columns: ColumnDef<ExportJob, unknown>[] = useMemo(
    () => [
      {
        id: 'index',
        header: t('reports.regulator.columns.index'),
        cell: ({ row }) => rowOffset + row.index + 1,
      },
      {
        id: 'driver_name',
        header: t('reports.regulator.columns.driverName'),
        cell: ({ row }) => {
          const driverId = row.original.params?.driver_ids?.[0];
          return (driverId && driverNameById.get(driverId)) ?? NA;
        },
      },
      {
        id: 'comment',
        header: t('reports.regulator.columns.comment'),
        cell: ({ row }) => row.original.params?.comment ?? NA,
      },
      {
        id: 'start_date',
        header: t('reports.regulator.columns.startDate'),
        cell: ({ row }) => row.original.params?.from ?? NA,
      },
      {
        id: 'end_date',
        header: t('reports.regulator.columns.endDate'),
        cell: ({ row }) => row.original.params?.to ?? NA,
      },
      {
        id: 'status',
        header: t('reports.regulator.columns.status'),
        cell: ({ row }) => {
          const status = row.original.status;
          return status ? (
            <Badge tone={EXPORT_JOB_STATUS_TONE[status]}>
              {t(`enums.export_job_status.${status}`)}
            </Badge>
          ) : (
            NA
          );
        },
      },
      {
        id: 'processed_time',
        header: t('reports.regulator.columns.processedTime'),
        cell: ({ row }) =>
          row.original.finished_at ? formatDateTime(row.original.finished_at) : NA,
      },
      {
        id: 'job_id',
        header: t('reports.regulator.columns.jobId'),
        cell: ({ row }) => <span className="font-mono text-body-sm">{row.original.id}</span>,
      },
      {
        id: 'action',
        header: t('reports.regulator.columns.action'),
        enableHiding: false,
        cell: ({ row }) => <ExportJobDownloadAction job={row.original} />,
      },
    ],
    [t, rowOffset, driverNameById],
  );

  return (
    <DataTable
      tableId="reports-regulator-jobs"
      columns={columns}
      data={data}
      isLoading={isLoading}
      isError={isError}
      errorMessage={errorMessage}
      onRetry={onRetry}
      emptyDescription={emptyDescription}
      getRowId={(row, index) => row.id ?? String(index)}
    />
  );
}

export default RegulatorJobsTable;
