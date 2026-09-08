/**
 * Trailers — `/trailers` (2.7, `docs/tz/07-3-fleet.md` §7.3.7, 🎨).
 * Sodda CRUD: `Number · Notes · Created · Action`.
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useSearchParams } from 'react-router-dom';
import type { ColumnDef } from '@tanstack/react-table';

import { useTrailerDelete, useTrailersList } from '@/api/queries/trailers';
import type { Trailer } from '@/api/types';
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
import { TrailerFormModal } from '../components/TrailerFormModal';

export function TrailerListPage() {
  const { t } = useTranslation();
  const toast = useToast();
  const { formatDate } = useDateFormat();
  const { canWrite, disabledReason } = useWriteGuard();
  const [searchParams, setSearchParams] = useSearchParams();
  const listParams = useListParams();

  const modal = searchParams.get('modal');
  const editId = searchParams.get('id') ?? undefined;
  const [trailerToDelete, setTrailerToDelete] = useState<Trailer | undefined>(undefined);

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

  const list = useTrailersList(queryParams);
  const remove = useTrailerDelete();

  const editingTrailer = useMemo(
    () => (editId ? list.data?.data?.find((trailer) => trailer.id === editId) : undefined),
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

  const openEditModal = (trailer: Trailer) =>
    setSearchParams(
      (prev) => {
        const next = new URLSearchParams(prev);
        next.set('modal', 'edit');
        if (trailer.id) next.set('id', trailer.id);
        return next;
      },
      { replace: true },
    );

  const columns: ColumnDef<Trailer, unknown>[] = [
    {
      id: 'number',
      accessorKey: 'number',
      header: t('fleet.trailers.columns.number'),
      enableSorting: true,
    },
    { id: 'notes', accessorKey: 'notes', header: t('fleet.trailers.columns.notes') },
    {
      id: 'created_at',
      header: t('fleet.trailers.columns.created'),
      enableSorting: true,
      cell: ({ row }) => formatDate(row.original.created_at),
    },
  ];

  const handleDelete = async () => {
    if (!trailerToDelete?.id) return;
    try {
      await remove.mutateAsync(trailerToDelete.id);
      toast.show({
        variant: 'success',
        message: t('fleet.trailers.toast.deleted', { number: trailerToDelete.number }),
      });
      setTrailerToDelete(undefined);
    } catch (error) {
      toast.show({
        variant: 'error',
        message:
          isApiError(error) && error.status === 409
            ? t('fleet.trailers.toast.deleteConflict')
            : t('errors.unknown'),
      });
    }
  };

  return (
    <>
      <ListScreen
        title={t('fleet.trailers.title')}
        actions={
          <PermissionGate permission={PERM.trailersCreate}>
            <Button onClick={openAddModal}>{t('fleet.trailers.actions.add')}</Button>
          </PermissionGate>
        }
        filtersBar={
          <FiltersBar
            search={listParams.search}
            onSearchChange={listParams.setSearch}
            searchPlaceholder={t('fleet.trailers.filters.searchPlaceholder')}
            activeFilters={listParams.filters}
            onFilterChange={listParams.setFilter}
            onClearAll={listParams.clearFilters}
          />
        }
        table={
          <DataTable
            tableId="trailers"
            columns={columns}
            data={list.data?.data ?? []}
            isLoading={list.isLoading}
            isError={list.isError}
            errorMessage={list.error?.message}
            onRetry={() => void list.refetch()}
            emptyTitle={t('fleet.trailers.empty.title')}
            emptyDescription={
              listParams.hasActiveFilters
                ? t('fleet.trailers.empty.filteredDescription')
                : t('fleet.trailers.empty.description')
            }
            onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
            sort={listParams.sort}
            order={listParams.order}
            onSortChange={listParams.setSort}
            getRowId={(trailer, index) => trailer.id ?? String(index)}
            rowActions={(trailer) => (
              <RowActionsMenu
                ariaLabel={t('fleet.trailers.rowActionsLabel', { number: trailer.number })}
                items={[
                  {
                    key: 'edit',
                    label: t('common.actions.edit'),
                    onSelect: () => openEditModal(trailer),
                    disabled: !canWrite(PERM.trailersUpdate),
                    disabledReason: disabledReason(PERM.trailersUpdate),
                  },
                  {
                    key: 'delete',
                    label: t('common.actions.delete'),
                    danger: true,
                    onSelect: () => setTrailerToDelete(trailer),
                    disabled: !canWrite(PERM.trailersDelete),
                    disabledReason: disabledReason(PERM.trailersDelete),
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

      <TrailerFormModal
        open={modal === 'add' || modal === 'edit'}
        onClose={closeModal}
        trailer={modal === 'edit' ? editingTrailer : undefined}
      />

      <ConfirmDialog
        open={Boolean(trailerToDelete)}
        onClose={() => setTrailerToDelete(undefined)}
        onConfirm={() => void handleDelete()}
        loading={remove.isPending}
        variant="danger"
        description={t('fleet.trailers.confirm.deleteDescription', {
          number: trailerToDelete?.number,
        })}
      />
    </>
  );
}

export default TrailerListPage;
