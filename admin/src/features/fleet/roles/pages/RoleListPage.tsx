/**
 * Roles & Permissions — `/roles` (2.9, TZ 7.3.10).
 *
 * Ruxsat: ro'yxatni ochish — `can.any([permissions.read, roles.read])` OR
 * istisnosi (fe-permissions §1.2) — `RouteGuard`da o'rnatiladi
 * (`fleet-b.routes.tsx`). F92: tizim rollar tahrirlanmaydi/o'chirilmaydi —
 * tugmalar tooltip bilan `disabled`. F93: `409 ROLE_IN_USE` — aniq xabar.
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { ColumnDef } from '@tanstack/react-table';
import { Link } from 'react-router-dom';

import { useRoleCreate, useRoleDelete, useRoleUpdate, useRolesList } from '@/api/queries/roles';
import type { Role, RoleCreate, RolesListParams, RoleUpdate } from '@/api/types';
import { isApiError } from '@/lib/errors';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar, type FilterDef } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { Modal } from '@/components/ui/Modal';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { useToast } from '@/components/feedback/toast-context';
import { useListParams } from '@/hooks/useListParams';
import { useWriteGuard } from '@/hooks/useWriteGuard';
import { PERM } from '@/lib/permissions';

import { RowActionsMenu, type RowAction } from '@/features/fleet/drivers/components/RowActionsMenu';
import { RoleFormDrawer } from '../components/RoleFormDrawer';

export function RoleListPage() {
  const { t } = useTranslation();
  const toast = useToast();
  const { canWrite, disabledReason } = useWriteGuard();
  const listParams = useListParams();

  const [formOpen, setFormOpen] = useState(false);
  const [editingRole, setEditingRole] = useState<Role | undefined>();
  const [duplicateMode, setDuplicateMode] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState<Role | undefined>();
  const [deleteConflict, setDeleteConflict] = useState<
    { message: string; roleId: string } | undefined
  >();

  const queryParams = useMemo<RolesListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      search: listParams.search || undefined,
      scope: (listParams.filters.scope as RolesListParams['scope']) || undefined,
    }),
    [listParams],
  );

  const rolesQuery = useRolesList(queryParams);
  const createMutation = useRoleCreate();
  const updateMutation = useRoleUpdate();
  const deleteMutation = useRoleDelete();

  const filters: FilterDef[] = [
    {
      key: 'scope',
      label: t('fleetRoles.filters.scope'),
      options: [
        { value: 'company', label: t('fleetRoles.form.scopeCompany') },
        { value: 'branch', label: t('fleetRoles.form.scopeBranch') },
      ],
      placeholder: t('fleetRoles.filters.scope'),
    },
  ];

  const columns = useMemo<ColumnDef<Role, unknown>[]>(
    () => [
      {
        id: 'name',
        header: t('fleetRoles.columns.name'),
        accessorKey: 'name',
        enableSorting: true,
      },
      {
        id: 'scope',
        header: t('fleetRoles.columns.scope'),
        accessorKey: 'scope',
        cell: ({ getValue }) => {
          const scope = getValue() as Role['scope'];
          return t(`fleetRoles.scopeLabel.${scope}`, { defaultValue: scope ?? '' });
        },
      },
      {
        id: 'user_count',
        header: t('fleetRoles.columns.users'),
        accessorKey: 'user_count',
        cell: ({ row, getValue }) => {
          const count = (getValue() as number | undefined) ?? 0;
          return (
            <Link
              className="text-body-sm font-medium text-primary hover:underline"
              to={`/users?role_id=${row.original.id ?? ''}`}
            >
              {count}
            </Link>
          );
        },
      },
      {
        id: 'is_system',
        header: t('fleetRoles.columns.system'),
        accessorKey: 'is_system',
        cell: ({ getValue }) =>
          getValue() ? (
            <Badge tone="info">{t('common.states.yes')}</Badge>
          ) : (
            <Badge tone="neutral">{t('common.states.no')}</Badge>
          ),
      },
    ],
    [t],
  );

  const rows = rolesQuery.data?.data ?? [];
  const total = rolesQuery.data?.meta?.total ?? 0;

  const buildRowActions = (role: Role): RowAction[] => {
    const isSystem = Boolean(role.is_system);
    const actions: RowAction[] = [
      {
        key: 'edit',
        label: t('common.actions.edit'),
        disabled: isSystem || !canWrite(PERM.rolesUpdate),
        disabledReason: isSystem
          ? t('fleetRoles.actions.systemImmutable')
          : disabledReason(PERM.rolesUpdate),
        onSelect: () => {
          setEditingRole(role);
          setDuplicateMode(false);
          setFormOpen(true);
        },
      },
    ];

    if (isSystem) {
      actions.push({
        key: 'duplicate',
        label: t('fleetRoles.actions.duplicate'),
        disabled: !canWrite(PERM.rolesCreate),
        disabledReason: disabledReason(PERM.rolesCreate),
        onSelect: () => {
          setEditingRole(role);
          setDuplicateMode(true);
          setFormOpen(true);
        },
      });
    }

    actions.push({
      key: 'delete',
      label: t('common.actions.delete'),
      danger: true,
      disabled: isSystem || !canWrite(PERM.rolesDelete),
      disabledReason: isSystem
        ? t('fleetRoles.actions.systemImmutable')
        : disabledReason(PERM.rolesDelete),
      onSelect: () => setDeleteTarget(role),
    });

    return actions;
  };

  return (
    <>
      <ListScreen
        title={t('pages.roles.title')}
        actions={
          <PermissionGate permission={PERM.rolesCreate}>
            <Button
              onClick={() => {
                setEditingRole(undefined);
                setDuplicateMode(false);
                setFormOpen(true);
              }}
            >
              {t('fleetRoles.actions.addRole')}
            </Button>
          </PermissionGate>
        }
        filtersBar={
          <FiltersBar
            search={listParams.search}
            onSearchChange={listParams.setSearch}
            searchPlaceholder={t('fleetRoles.filters.searchPlaceholder')}
            filters={filters}
            activeFilters={listParams.filters}
            onFilterChange={listParams.setFilter}
            onClearAll={listParams.clearFilters}
          />
        }
        table={
          <DataTable
            tableId="roles"
            columns={columns}
            data={rows}
            isLoading={rolesQuery.isLoading}
            isError={rolesQuery.isError}
            errorMessage={rolesQuery.error?.message}
            onRetry={() => void rolesQuery.refetch()}
            emptyTitle={
              listParams.hasActiveFilters
                ? t('ui.overlay.emptyState.noResultsTitle')
                : t('fleetRoles.empty.title')
            }
            emptyDescription={
              listParams.hasActiveFilters
                ? t('ui.overlay.emptyState.noResultsDescription')
                : t('fleetRoles.empty.description')
            }
            onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
            sort={listParams.sort}
            order={listParams.order}
            onSortChange={listParams.setSort}
            getRowId={(role, index) => role.id ?? String(index)}
            rowActions={(role) => (
              <RowActionsMenu
                actions={buildRowActions(role)}
                ariaLabel={t('fleetRoles.actions.rowMenuLabel', { name: role.name ?? '' })}
              />
            )}
          />
        }
        pagination={
          <Pagination
            page={listParams.page}
            perPage={listParams.perPage}
            total={total}
            onPageChange={listParams.setPage}
            onPerPageChange={listParams.setPerPage}
          />
        }
      />

      <RoleFormDrawer
        open={formOpen}
        onClose={() => setFormOpen(false)}
        role={editingRole}
        duplicateFrom={duplicateMode}
        submitting={createMutation.isPending || updateMutation.isPending}
        onSubmitCreate={async (body: RoleCreate) => {
          await createMutation.mutateAsync(body);
          toast.show({
            variant: 'success',
            message: t('fleetRoles.toast.created', { name: body.name }),
          });
        }}
        onSubmitUpdate={async (body: RoleUpdate) => {
          if (!editingRole?.id) return;
          await updateMutation.mutateAsync({ id: editingRole.id, body });
          toast.show({ variant: 'success', message: t('fleetRoles.toast.updated') });
        }}
      />

      <ConfirmDialog
        open={Boolean(deleteTarget)}
        onClose={() => setDeleteTarget(undefined)}
        variant="danger"
        loading={deleteMutation.isPending}
        onConfirm={() => {
          if (!deleteTarget?.id) return;
          deleteMutation.mutate(deleteTarget.id, {
            onSuccess: () => {
              toast.show({ variant: 'success', message: t('fleetRoles.toast.deleted') });
              setDeleteTarget(undefined);
            },
            onError: (error) => {
              if (isApiError(error) && error.code === 'CONFLICT') {
                setDeleteConflict({ message: error.message, roleId: deleteTarget.id ?? '' });
              } else {
                toast.show({ variant: 'error', message: t('fleetRoles.toast.deleteFailed') });
              }
              setDeleteTarget(undefined);
            },
          });
        }}
        title={t('ui.overlay.confirmDialog.title')}
        description={t('fleetRoles.confirm.delete', { name: deleteTarget?.name ?? '' })}
      />

      <Modal
        open={Boolean(deleteConflict)}
        onClose={() => setDeleteConflict(undefined)}
        title={t('fleetRoles.confirm.inUseTitle')}
        footer={
          <>
            <Button variant="secondary" onClick={() => setDeleteConflict(undefined)}>
              {t('common.actions.close')}
            </Button>
            {deleteConflict?.roleId ? (
              <Link to={`/users?role_id=${deleteConflict.roleId}`}>
                <Button onClick={() => setDeleteConflict(undefined)}>
                  {t('fleetRoles.confirm.viewUsers')}
                </Button>
              </Link>
            ) : null}
          </>
        }
      >
        <p className="text-body text-neutral-700">{deleteConflict?.message}</p>
      </Modal>
    </>
  );
}

export default RoleListPage;
