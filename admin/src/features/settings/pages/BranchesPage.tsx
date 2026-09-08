/**
 * Settings › Branches — `/settings/branches` (8.3, §7.13.2). Sodda CRUD
 * (`tz.md` §1: "🎨 oddiy CRUD ekran kerak [SHOULD]").
 *
 * `GET/POST /company/branches` (`branches.read`/`branches.create`),
 * `PATCH/DELETE /company/branches/{id}` (`branches.update`/`branches.delete`).
 * O'chirish — soft delete, sabab talab qilinmaydi; foydalanuvchisi bor
 * filial `409 RESOURCE_IN_USE` qaytaradi (`branchErrorMessageKey`).
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';

import {
  useBranchCreate,
  useBranchDelete,
  useBranchesList,
  useBranchUpdate,
} from '@/api/queries/branches';
import type { Branch, BranchesListParams } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import type { RowActionItem } from '@/components/data/RowActionsMenu';
import { useToast } from '@/components/feedback/toast-context';
import { Button } from '@/components/ui/Button';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { useListParams } from '@/hooks/useListParams';
import { PERM, usePermission } from '@/lib/permissions';

import { BranchFormModal } from '../branches/components/BranchFormModal';
import { buildBranchColumns } from '../branches/components/branchColumns';
import { branchErrorMessageKey } from '../branches/lib/errors';
import type { BranchFormValues } from '../branches/lib/schemas';

function toPayload(values: BranchFormValues) {
  return {
    name: values.name.trim(),
    ...(values.address.trim() ? { address: values.address.trim() } : {}),
    ...(values.timezone.trim() ? { timezone: values.timezone.trim() } : {}),
  };
}

export function BranchesPage() {
  const { t } = useTranslation();
  const toast = useToast();
  const can = usePermission();
  const listParams = useListParams();

  const [formOpen, setFormOpen] = useState(false);
  const [editing, setEditing] = useState<Branch | undefined>(undefined);
  const [deleting, setDeleting] = useState<Branch | undefined>(undefined);

  const queryParams = useMemo<BranchesListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      search: listParams.search || undefined,
      ...(listParams.sort ? { sort: listParams.sort as BranchesListParams['sort'] } : {}),
      ...(listParams.order ? { order: listParams.order } : {}),
    }),
    [listParams.page, listParams.perPage, listParams.search, listParams.sort, listParams.order],
  );

  const list = useBranchesList(queryParams);
  const create = useBranchCreate();
  const update = useBranchUpdate();
  const remove = useBranchDelete();

  const buildActions = (branch: Branch): RowActionItem[] => {
    const items: RowActionItem[] = [];
    if (can(PERM.branchesUpdate)) {
      items.push({
        key: 'edit',
        label: t('common.actions.edit'),
        onSelect: () => {
          setEditing(branch);
          setFormOpen(true);
        },
      });
    }
    if (can(PERM.branchesDelete)) {
      items.push({
        key: 'delete',
        label: t('common.actions.delete'),
        danger: true,
        onSelect: () => setDeleting(branch),
      });
    }
    return items;
  };

  const columns = buildBranchColumns(t, { buildActions });

  const confirmDelete = async () => {
    if (!deleting?.id) return;
    try {
      await remove.mutateAsync(deleting.id);
      toast.show({
        variant: 'success',
        message: t('settings.branches.toast.deleted', { name: deleting.name }),
      });
      setDeleting(undefined);
    } catch (error) {
      const moduleKey = branchErrorMessageKey(error);
      toast.show({
        variant: 'error',
        message: moduleKey ? t(moduleKey) : t('settings.branches.toast.failed'),
      });
      setDeleting(undefined);
    }
  };

  return (
    <ListScreen
      title={t('settings.branches.title')}
      actions={
        <PermissionGate permission={PERM.branchesCreate}>
          <Button
            onClick={() => {
              setEditing(undefined);
              setFormOpen(true);
            }}
          >
            {t('settings.branches.add')}
          </Button>
        </PermissionGate>
      }
      filtersBar={
        <FiltersBar
          search={listParams.search}
          onSearchChange={listParams.setSearch}
          searchPlaceholder={t('settings.branches.filters.searchPlaceholder')}
          activeFilters={listParams.filters}
          onFilterChange={listParams.setFilter}
          onClearAll={listParams.clearFilters}
        />
      }
      table={
        <>
          <DataTable
            tableId="settings-branches"
            columns={columns}
            data={list.data?.data ?? []}
            isLoading={list.isLoading}
            isError={list.isError}
            errorMessage={list.error?.message}
            onRetry={() => void list.refetch()}
            emptyTitle={
              listParams.hasActiveFilters
                ? t('settings.branches.empty.filteredTitle')
                : t('settings.branches.empty.title')
            }
            emptyDescription={
              listParams.hasActiveFilters
                ? t('settings.branches.empty.filteredDescription')
                : t('settings.branches.empty.description')
            }
            onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
            sort={listParams.sort}
            order={listParams.order}
            onSortChange={(columnId, order) => listParams.setSort(columnId, order)}
            getRowId={(item, index) => item.id ?? String(index)}
          />

          <BranchFormModal
            open={formOpen}
            onClose={() => setFormOpen(false)}
            branch={editing}
            isPending={create.isPending || update.isPending}
            onCreate={(values) => create.mutateAsync(toPayload(values))}
            onUpdate={(id, values) => update.mutateAsync({ id, body: toPayload(values) })}
            onSuccess={(isEdit, values) =>
              toast.show({
                variant: 'success',
                message: isEdit
                  ? t('settings.branches.toast.updated', { name: values.name })
                  : t('settings.branches.toast.created', { name: values.name }),
              })
            }
          />

          <ConfirmDialog
            open={Boolean(deleting)}
            onClose={() => setDeleting(undefined)}
            onConfirm={() => void confirmDelete()}
            title={t('settings.branches.delete.title')}
            description={t('settings.branches.delete.description', { name: deleting?.name })}
            variant="danger"
            loading={remove.isPending}
          />
        </>
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
  );
}

export default BranchesPage;
