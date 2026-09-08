/**
 * Export Jobs — umumiy jadval (7.8.7). Ustunlar: `# · Type · Format · Params ·
 * Requested by · Created · Started · Finished · Size · Status · Download`.
 *
 * `Params` — `summarizeExportParams` bilan kompakt bitta qatorga siqiladi, to'liq
 * matn `Tooltip`da (bir manba — jadval va tooltip orasida nomuvofiqlik bo'lmaydi).
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import type { ColumnDef } from '@tanstack/react-table';

import type { ExportJob, ExportJobCreate } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { Badge } from '@/components/ui/Badge';
import { Tooltip } from '@/components/ui/Tooltip';
import { formatDateTime, NA } from '@/lib/format';

import { ExportJobDownloadAction } from './ExportJobDownloadAction';
import {
  EXPORT_JOB_STATUS_TONE,
  formatExportJobFileSize,
  summarizeExportParams,
} from '../lib/exportJobDisplay';

export interface ExportJobsTableProps {
  data: ExportJob[];
  typeLabels: Record<NonNullable<ExportJobCreate['type']>, string>;
  resolveRequestedBy: (job: ExportJob) => string;
  isLoading?: boolean;
  isError?: boolean;
  errorMessage?: string;
  onRetry?: () => void;
  emptyDescription?: string;
  onClearFilters?: () => void;
  rowOffset?: number;
}

export function ExportJobsTable({
  data,
  typeLabels,
  resolveRequestedBy,
  isLoading,
  isError,
  errorMessage,
  onRetry,
  emptyDescription,
  onClearFilters,
  rowOffset = 0,
}: ExportJobsTableProps) {
  const { t } = useTranslation();

  const columns: ColumnDef<ExportJob, unknown>[] = useMemo(
    () => [
      {
        id: 'index',
        header: t('reports.exportJobs.columns.index'),
        cell: ({ row }) => rowOffset + row.index + 1,
      },
      {
        id: 'type',
        header: t('reports.exportJobs.columns.type'),
        cell: ({ row }) => (row.original.type ? typeLabels[row.original.type] : NA),
      },
      {
        id: 'format',
        header: t('reports.exportJobs.columns.format'),
        cell: ({ row }) =>
          row.original.format ? t(`reports.exportJobModal.formats.${row.original.format}`) : NA,
      },
      {
        id: 'params',
        header: t('reports.exportJobs.columns.params'),
        cell: ({ row }) => {
          const summary = summarizeExportParams(row.original.params, t);
          return summary === NA ? (
            NA
          ) : (
            <Tooltip content={summary}>
              <button
                type="button"
                className="inline-block max-w-xs cursor-help truncate align-bottom text-start"
              >
                {summary}
              </button>
            </Tooltip>
          );
        },
      },
      {
        id: 'requested_by',
        header: t('reports.exportJobs.columns.requestedBy'),
        cell: ({ row }) => resolveRequestedBy(row.original),
      },
      {
        id: 'created_at',
        header: t('reports.exportJobs.columns.created'),
        cell: ({ row }) => formatDateTime(row.original.created_at),
      },
      {
        id: 'started_at',
        header: t('reports.exportJobs.columns.started'),
        cell: ({ row }) => formatDateTime(row.original.started_at),
      },
      {
        id: 'finished_at',
        header: t('reports.exportJobs.columns.finished'),
        cell: ({ row }) => formatDateTime(row.original.finished_at),
      },
      {
        id: 'size',
        header: t('reports.exportJobs.columns.size'),
        cell: ({ row }) => formatExportJobFileSize(row.original.file_size_b),
      },
      {
        id: 'status',
        header: t('reports.exportJobs.columns.status'),
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
        id: 'download',
        header: t('reports.exportJobs.columns.download'),
        enableHiding: false,
        cell: ({ row }) => <ExportJobDownloadAction job={row.original} />,
      },
    ],
    [t, rowOffset, typeLabels, resolveRequestedBy],
  );

  return (
    <DataTable
      tableId="reports-export-jobs"
      columns={columns}
      data={data}
      isLoading={isLoading}
      isError={isError}
      errorMessage={errorMessage}
      onRetry={onRetry}
      emptyDescription={emptyDescription}
      onClearFilters={onClearFilters}
      getRowId={(row, index) => row.id ?? String(index)}
    />
  );
}

export default ExportJobsTable;
