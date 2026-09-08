/**
 * Log Edit Requests — `/logs/edit-requests` (3.11, `docs/tz/07-4-logs.md`
 * 7.4.4) 🎨 (dizayn yo'q — standart ro'yxat patterni bilan quriladi, F102).
 *
 * **F103 [MUST]**: adminning o'z taklifini o'zi tasdiqlashi UI'da
 * bloklangan — `Approve` tugmasi `requested_by === currentUserId` bo'lganda
 * ko'rinmaydi (backend ham `403` bilan bloklaydi).
 * **Reject** — `reason` majburiy (3–500 belgi, `useLogEditRequestReject`).
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

import {
  useLogEditRequestApprove,
  useLogEditRequestReject,
  useLogEditRequestsList,
} from '@/api/queries/logEditRequests';
import type { LogEditRequest, LogEditRequestsListParams } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { useToast } from '@/components/feedback/toast-context';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';
import { isApiError } from '@/lib/errors';
import { PERM, usePermission } from '@/lib/permissions';
import { useAuthStore } from '@/store/auth-store';

import { buildLogEditRequestColumns } from '../components/logEditRequestColumns';

type TabKey = 'pending' | 'approved' | 'rejected';

export function LogEditRequestsPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const toast = useToast();
  const dateFormat = useDateFormat();
  const can = usePermission();
  const currentUserId = useAuthStore((state) => state.profile?.id);

  const listParams = useListParams();
  const activeTab = (listParams.filters.status as TabKey) || 'pending';

  const [rejecting, setRejecting] = useState<LogEditRequest | undefined>(undefined);

  const queryParams = useMemo<LogEditRequestsListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      status: activeTab,
    }),
    [listParams.page, listParams.perPage, activeTab],
  );

  const list = useLogEditRequestsList(queryParams);
  const approve = useLogEditRequestApprove();
  const reject = useLogEditRequestReject();

  const handleApprove = async (request: LogEditRequest) => {
    if (!request.id) return;
    try {
      await approve.mutateAsync(request.id);
      toast.show({
        variant: 'success',
        message: t('logs.editRequests.toast.approved', { driver: request.driver_name }),
      });
    } catch {
      toast.show({ variant: 'error', message: t('logs.editRequests.toast.approveFailed') });
    }
  };

  const handleRejectConfirm = async (reason?: string) => {
    if (!rejecting?.id || !reason) return;
    try {
      await reject.mutateAsync({ id: rejecting.id, body: { reason } });
      toast.show({
        variant: 'success',
        message: t('logs.editRequests.toast.rejected', { driver: rejecting.driver_name }),
      });
      setRejecting(undefined);
    } catch (error) {
      const message = isApiError(error) ? (error.fields.reason ?? error.message) : undefined;
      toast.show({
        variant: 'error',
        message: message ?? t('logs.editRequests.toast.rejectFailed'),
      });
    }
  };

  const columns = buildLogEditRequestColumns(t, {
    startIndex: (listParams.page - 1) * listParams.perPage,
    dateFormat,
    currentUserId,
    canApprove: can(PERM.logsApproveEdit),
    canReject: can(PERM.logsRejectEdit),
    onView: (request) => request.daily_log_id && navigate(`/logs/view/${request.daily_log_id}`),
    onApprove: (request) => void handleApprove(request),
    onReject: (request) => setRejecting(request),
  });

  return (
    <>
      <ListScreen
        title={t('logs.editRequests.title')}
        tabs={[
          { key: 'pending', label: t('logs.editRequests.tabs.pending') },
          { key: 'approved', label: t('logs.editRequests.tabs.approved') },
          { key: 'rejected', label: t('logs.editRequests.tabs.rejected') },
        ]}
        activeTab={activeTab}
        onTabChange={(key) => listParams.setFilter('status', key === 'pending' ? undefined : key)}
        table={
          <DataTable
            tableId="log-edit-requests"
            columns={columns}
            data={list.data?.data ?? []}
            isLoading={list.isLoading}
            isError={list.isError}
            errorMessage={list.error?.message}
            onRetry={() => void list.refetch()}
            emptyTitle={t('logs.editRequests.empty.title')}
            emptyDescription={t('logs.editRequests.empty.description')}
            getRowId={(request, index) => request.id ?? String(index)}
          />
        }
        pagination={
          <Pagination
            page={listParams.page}
            perPage={listParams.perPage}
            total={list.data?.meta?.total ?? 0}
            onPageChange={listParams.setPage}
            onPerPageChange={listParams.setPerPage}
          />
        }
      />

      <ConfirmDialog
        open={Boolean(rejecting)}
        onClose={() => setRejecting(undefined)}
        onConfirm={(reason) => void handleRejectConfirm(reason)}
        loading={reject.isPending}
        requireReason
        reasonLabel={t('logs.editRequests.rejectDialog.reasonLabel')}
        title={t('logs.editRequests.rejectDialog.title')}
        description={t('logs.editRequests.rejectDialog.description', {
          driver: rejecting?.driver_name,
        })}
      />
    </>
  );
}

export default LogEditRequestsPage;
