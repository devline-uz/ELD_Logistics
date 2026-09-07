/**
 * Shipping Documents — `/shipping-documents` (2.7, `docs/tz/07-3-fleet.md`
 * §7.3.8, 🎨). Sodda CRUD: `Number · Notes · Created · Action`.
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useSearchParams } from 'react-router-dom';
import type { ColumnDef } from '@tanstack/react-table';

import {
  useShippingDocumentDelete,
  useShippingDocumentsList,
} from '@/api/queries/shippingDocuments';
import type { ShippingDocument } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { useToast } from '@/components/feedback/toast-context';
import { Button } from '@/components/ui/Button';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';
import { useWriteGuard } from '@/hooks/useWriteGuard';
import { isApiError } from '@/lib/errors';
import { PERM } from '@/lib/permissions';

import { RowActionsMenu } from '@/components/data/RowActionsMenu';
import { ShippingDocumentFormModal } from '../components/ShippingDocumentFormModal';

export function ShippingDocumentListPage() {
  const { t } = useTranslation();
  const toast = useToast();
  const { formatDate } = useDateFormat();
  const { canWrite, disabledReason } = useWriteGuard();
  const [searchParams, setSearchParams] = useSearchParams();
  const listParams = useListParams();

  const modal = searchParams.get('modal');
  const editId = searchParams.get('id') ?? undefined;
  const [documentToDelete, setDocumentToDelete] = useState<ShippingDocument | undefined>(undefined);

  const queryParams = useMemo(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      sort: listParams.sort,
      order: listParams.order,
      search: listParams.search || undefined,
    }),
    [listParams.page, listParams.perPage, listParams.sort, listParams.order, listParams.search],
  );

  const list = useShippingDocumentsList(queryParams);
  const remove = useShippingDocumentDelete();

  const editingDocument = useMemo(
    () => (editId ? list.data?.data?.find((document) => document.id === editId) : undefined),
    [editId, list.data],
  );

  const closeModal = () =>
    setSearchParams(
      (prev) => {
        const next = new URLSearchParams(prev);
        next.delete('modal');
        next.delete('id');
        return next;
      },
      { replace: true },
    );

  const openAddModal = () =>
    setSearchParams(
      (prev) => {
        const next = new URLSearchParams(prev);
        next.set('modal', 'add');
        next.delete('id');
        return next;
      },
      { replace: true },
    );

  const openEditModal = (document: ShippingDocument) =>
    setSearchParams(
      (prev) => {
        const next = new URLSearchParams(prev);
        next.set('modal', 'edit');
        if (document.id) next.set('id', document.id);
        return next;
      },
      { replace: true },
    );

  const columns: ColumnDef<ShippingDocument, unknown>[] = [
    {
      id: 'number',
      accessorKey: 'number',
      header: t('fleet.shippingDocuments.columns.number'),
      enableSorting: true,
    },
    { id: 'notes', accessorKey: 'notes', header: t('fleet.shippingDocuments.columns.notes') },
    {
      id: 'created_at',
      header: t('fleet.shippingDocuments.columns.created'),
      enableSorting: true,
      cell: ({ row }) => formatDate(row.original.created_at),
    },
  ];

  const handleDelete = async () => {
    if (!documentToDelete?.id) return;
    try {
      await remove.mutateAsync(documentToDelete.id);
      toast.show({
        variant: 'success',
        message: t('fleet.shippingDocuments.toast.deleted', { number: documentToDelete.number }),
      });
      setDocumentToDelete(undefined);
    } catch (error) {
      toast.show({
        variant: 'error',
        message:
          isApiError(error) && error.status === 409
            ? t('fleet.shippingDocuments.toast.deleteConflict')
            : t('errors.unknown'),
      });
    }
  };

  return (
    <>
      <ListScreen
        title={t('fleet.shippingDocuments.title')}
        actions={
          <PermissionGate permission={PERM.shippingDocumentsCreate}>
            <Button onClick={openAddModal}>{t('fleet.shippingDocuments.actions.add')}</Button>
          </PermissionGate>
        }
        filtersBar={
          <FiltersBar
            search={listParams.search}
            onSearchChange={listParams.setSearch}
            searchPlaceholder={t('fleet.shippingDocuments.filters.searchPlaceholder')}
            activeFilters={listParams.filters}
            onFilterChange={listParams.setFilter}
            onClearAll={listParams.clearFilters}
          />
        }
        table={
          <DataTable
            tableId="shippingDocuments"
            columns={columns}
            data={list.data?.data ?? []}
            isLoading={list.isLoading}
            isError={list.isError}
            errorMessage={list.error?.message}
            onRetry={() => void list.refetch()}
            emptyTitle={t('fleet.shippingDocuments.empty.title')}
            emptyDescription={
              listParams.hasActiveFilters
                ? t('fleet.shippingDocuments.empty.filteredDescription')
                : t('fleet.shippingDocuments.empty.description')
            }
            onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
            sort={listParams.sort}
            order={listParams.order}
            onSortChange={listParams.setSort}
            getRowId={(document, index) => document.id ?? String(index)}
            rowActions={(document) => (
              <RowActionsMenu
                ariaLabel={t('fleet.shippingDocuments.rowActionsLabel', {
                  number: document.number,
                })}
                items={[
                  {
                    key: 'edit',
                    label: t('common.actions.edit'),
                    onSelect: () => openEditModal(document),
                    disabled: !canWrite(PERM.shippingDocumentsUpdate),
                    disabledReason: disabledReason(PERM.shippingDocumentsUpdate),
                  },
                  {
                    key: 'delete',
                    label: t('common.actions.delete'),
                    danger: true,
                    onSelect: () => setDocumentToDelete(document),
                    disabled: !canWrite(PERM.shippingDocumentsDelete),
                    disabledReason: disabledReason(PERM.shippingDocumentsDelete),
                  },
                ]}
              />
            )}
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

      <ShippingDocumentFormModal
        open={modal === 'add' || modal === 'edit'}
        onClose={closeModal}
        document={modal === 'edit' ? editingDocument : undefined}
      />

      <ConfirmDialog
        open={Boolean(documentToDelete)}
        onClose={() => setDocumentToDelete(undefined)}
        onConfirm={() => void handleDelete()}
        loading={remove.isPending}
        variant="danger"
        description={t('fleet.shippingDocuments.confirm.deleteDescription', {
          number: documentToDelete?.number,
        })}
      />
    </>
  );
}

export default ShippingDocumentListPage;
