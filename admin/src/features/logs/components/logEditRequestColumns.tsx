/**
 * Log Edit Requests — jadval ustunlari (7.4.4): `# · Driver · Log date ·
 * Proposed change (from → to, status) · Note · Proposed by · Created ·
 * Status · Action`.
 */
import type { ColumnDef } from '@tanstack/react-table';
import type { TFunction } from 'i18next';

import type { LogEditRequest } from '@/api/types';
import { Badge } from '@/components/ui/Badge';
import type { UseDateFormatResult } from '@/hooks/useDateFormat';

const STATUS_TONE: Record<
  NonNullable<LogEditRequest['status']>,
  'warning' | 'success' | 'error'
> = {
  pending: 'warning',
  approved: 'success',
  rejected: 'error',
};

export interface LogEditRequestColumnsOptions {
  startIndex: number;
  dateFormat: UseDateFormatResult;
  currentUserId: string | undefined;
  canApprove: boolean;
  canReject: boolean;
  onView: (request: LogEditRequest) => void;
  onApprove: (request: LogEditRequest) => void;
  onReject: (request: LogEditRequest) => void;
}

export function buildLogEditRequestColumns(
  t: TFunction,
  options: LogEditRequestColumnsOptions,
): ColumnDef<LogEditRequest, unknown>[] {
  const {
    startIndex,
    dateFormat,
    currentUserId,
    canApprove,
    canReject,
    onView,
    onApprove,
    onReject,
  } = options;

  return [
    {
      id: 'index',
      header: t('logs.editRequests.columns.index'),
      enableHiding: false,
      enableSorting: false,
      cell: ({ row }) => startIndex + row.index + 1,
    },
    {
      id: 'driver_name',
      header: t('logs.editRequests.columns.driver'),
      cell: ({ row }) => row.original.driver_name ?? t('common.na'),
    },
    {
      id: 'log_date',
      header: t('logs.editRequests.columns.logDate'),
      cell: ({ row }) => dateFormat.formatDate(row.original.log_date),
    },
    {
      id: 'proposed_change',
      header: t('logs.editRequests.columns.proposedChange'),
      enableSorting: false,
      cell: ({ row }) => {
        const change = row.original.changes?.[0];
        if (!change) return t('common.na');
        return (
          <span>
            {t(`logs.dutyGrid.status.${change.status.toLowerCase()}`)}{' '}
            {dateFormat.formatTime(change.from)} → {dateFormat.formatTime(change.to)}
          </span>
        );
      },
    },
    {
      id: 'note',
      header: t('logs.editRequests.columns.note'),
      enableSorting: false,
      cell: ({ row }) => row.original.changes?.[0]?.note ?? '',
    },
    {
      id: 'requested_by',
      header: t('logs.editRequests.columns.proposedBy'),
      cell: ({ row }) =>
        row.original.source === 'unidentified_assign'
          ? t('logs.editRequests.source.unidentifiedAssign')
          : t('logs.editRequests.source.adminEdit'),
    },
    {
      id: 'created_at',
      header: t('logs.editRequests.columns.created'),
      cell: ({ row }) => dateFormat.formatDateTime(row.original.created_at),
    },
    {
      id: 'status',
      header: t('logs.editRequests.columns.status'),
      cell: ({ row }) => {
        const status = row.original.status ?? 'pending';
        return <Badge tone={STATUS_TONE[status]}>{t(`logs.editRequests.status.${status}`)}</Badge>;
      },
    },
    {
      id: 'action',
      header: '',
      enableHiding: false,
      enableSorting: false,
      cell: ({ row }) => {
        const request = row.original;
        const isPending = (request.status ?? 'pending') === 'pending';
        const isOwnRequest = Boolean(currentUserId) && request.requested_by === currentUserId;
        return (
          <div className="flex items-center gap-2">
            <button
              type="button"
              className="text-body-sm font-medium text-primary hover:underline"
              onClick={() => onView(request)}
            >
              {t('common.actions.view')}
            </button>
            {isPending && !isOwnRequest && canApprove ? (
              <button
                type="button"
                className="text-body-sm font-medium text-success-dark hover:underline"
                onClick={() => onApprove(request)}
              >
                {t('logs.editRequests.actions.approve')}
              </button>
            ) : null}
            {isPending && canReject ? (
              <button
                type="button"
                className="text-body-sm font-medium text-error-dark hover:underline"
                onClick={() => onReject(request)}
              >
                {t('logs.editRequests.actions.reject')}
              </button>
            ) : null}
          </div>
        );
      },
    },
  ];
}
