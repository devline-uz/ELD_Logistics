/**
 * User Management — `/users` (2.8, TZ 7.3.9).
 *
 * Ruxsat: `users.read`. `Export Users` tugmasi **yo'q** — backendda
 * `/users/export` endpointi mavjud emas (N16, `docs/tz/16-17-registry-
 * open-questions.md`).
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { ColumnDef } from '@tanstack/react-table';

import { useBranchesList } from '@/api/queries/branches';
import {
  useUserActivate,
  useUserCreate,
  useUserDeactivate,
  useUserDelete,
  useUserResendInvitation,
  useUserResetPassword,
  useUserUpdate,
  useUsersList,
} from '@/api/queries/users';
import type { User, UserCreate, UsersListParams, UserUpdate } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar, type FilterDef } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { useToast } from '@/components/feedback/toast-context';
import { useListParams } from '@/hooks/useListParams';
import { useIsCompanyScope } from '@/hooks/useScope';
import { useWriteGuard } from '@/hooks/useWriteGuard';
import { PERM } from '@/lib/permissions';

import { RowActionsMenu, type RowActionItem } from '@/components/data/RowActionsMenu';
import { UserFormModal } from '../components/UserFormModal';

const DATA_TABLE_TO_API_SORT: Record<string, UsersListParams['sort']> = {
  first_name: 'first_name',
  last_name: 'last_name',
  username: 'username',
  email: 'email',
  status: 'status',
};

export function UserListPage() {
  const { t } = useTranslation();
  const toast = useToast();
  const { canWrite, disabledReason } = useWriteGuard();
  const listParams = useListParams();

  const [formOpen, setFormOpen] = useState(false);
  const [editingUser, setEditingUser] = useState<User | undefined>();
  const [deactivateTarget, setDeactivateTarget] = useState<User | undefined>();
  const [deleteTarget, setDeleteTarget] = useState<User | undefined>();
  const [resetPasswordTarget, setResetPasswordTarget] = useState<User | undefined>();

  const queryParams = useMemo<UsersListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      search: listParams.search || undefined,
      sort: listParams.sort ? DATA_TABLE_TO_API_SORT[listParams.sort] : undefined,
      order: listParams.order,
      status: (listParams.filters.status as UsersListParams['status']) || undefined,
      role_id: listParams.filters.role_id || undefined,
      branch_id: listParams.filters.branch_id || undefined,
    }),
    [listParams],
  );

  const usersQuery = useUsersList(queryParams);
  const createMutation = useUserCreate();
  const updateMutation = useUserUpdate();
  const activateMutation = useUserActivate();
  const deactivateMutation = useUserDeactivate();
  const deleteMutation = useUserDelete();
  const resendInvitationMutation = useUserResendInvitation();
  const resetPasswordMutation = useUserResetPassword();

  const isCompanyScope = useIsCompanyScope();
  const branchesQuery = useBranchesList({ per_page: 50 }, { enabled: isCompanyScope });

  const filters: FilterDef[] = [
    {
      key: 'status',
      label: t('fleetUsers.filters.status'),
      options: [
        { value: 'invited', label: t('enums.user_status.invited') },
        { value: 'active', label: t('enums.user_status.active') },
        { value: 'inactive', label: t('enums.user_status.inactive') },
      ],
      placeholder: t('fleetUsers.filters.status'),
    },
    ...(isCompanyScope
      ? [
          {
            key: 'branch_id',
            label: t('common.filters.branch'),
            options: (branchesQuery.data?.data ?? []).map((branch) => ({
              value: branch.id ?? '',
              label: branch.name ?? branch.id ?? '',
            })),
            placeholder: t('common.filters.branch'),
          } satisfies FilterDef,
        ]
      : []),
  ];

  const columns = useMemo<ColumnDef<User, unknown>[]>(
    () => [
      {
        id: 'first_name',
        header: t('fleetUsers.columns.firstName'),
        accessorKey: 'first_name',
        enableSorting: true,
      },
      {
        id: 'last_name',
        header: t('fleetUsers.columns.lastName'),
        accessorKey: 'last_name',
        enableSorting: true,
      },
      {
        id: 'email',
        header: t('fleetUsers.columns.email'),
        accessorKey: 'email',
        enableSorting: true,
      },
      {
        id: 'role',
        header: t('fleetUsers.columns.role'),
        accessorFn: (row) => row.role?.name ?? '',
        cell: ({ getValue }) => (getValue() as string) || t('common.states.notAvailable'),
      },
      {
        id: 'phone',
        header: t('fleetUsers.columns.phone'),
        accessorKey: 'phone',
        cell: ({ getValue }) =>
          (getValue() as string | undefined) ?? t('common.states.notAvailable'),
      },
      {
        id: 'branch_name',
        header: t('fleetUsers.columns.branch'),
        accessorKey: 'branch_name',
        cell: ({ getValue }) =>
          (getValue() as string | undefined) ?? t('common.states.notAvailable'),
      },
      {
        id: 'status',
        header: t('fleetUsers.columns.status'),
        accessorKey: 'status',
        enableSorting: true,
        cell: ({ getValue }) => {
          const status = getValue() as User['status'];
          const tone =
            status === 'invited' ? 'warning' : status === 'active' ? 'success' : 'neutral';
          return (
            <Badge tone={tone}>
              {t(`enums.user_status.${status}`, { defaultValue: status ?? '' })}
            </Badge>
          );
        },
      },
    ],
    [t],
  );

  const rows = usersQuery.data?.data ?? [];
  const total = usersQuery.data?.meta?.total ?? 0;

  const buildRowActions = (user: User): RowActionItem[] => {
    const name = `${user.first_name ?? ''} ${user.last_name ?? ''}`.trim();
    const actions: RowActionItem[] = [];

    if (canWrite(PERM.usersUpdate)) {
      actions.push({
        key: 'edit',
        label: t('common.actions.edit'),
        onSelect: () => {
          setEditingUser(user);
          setFormOpen(true);
        },
      });
    }

    if (user.status === 'invited') {
      actions.push({
        key: 'resend-invitation',
        label: t('fleetUsers.actions.resendInvitation'),
        disabled: !canWrite(PERM.usersInvite),
        disabledReason: disabledReason(PERM.usersInvite),
        onSelect: () =>
          resendInvitationMutation.mutate(user.id ?? '', {
            onSuccess: () =>
              toast.show({
                variant: 'success',
                message: t('fleetUsers.toast.invitationResent', { name }),
              }),
            onError: () =>
              toast.show({
                variant: 'error',
                message: t('fleetUsers.toast.invitationResendFailed'),
              }),
          }),
      });
    }

    actions.push({
      key: 'reset-password',
      label: t('fleetUsers.actions.sendPasswordReset'),
      disabled: !canWrite(PERM.usersResetPassword),
      disabledReason: disabledReason(PERM.usersResetPassword),
      onSelect: () => setResetPasswordTarget(user),
    });

    if (user.status === 'active') {
      actions.push({
        key: 'deactivate',
        label: t('common.actions.deactivate'),
        disabled: !canWrite(PERM.usersUpdate),
        disabledReason: disabledReason(PERM.usersUpdate),
        onSelect: () => setDeactivateTarget(user),
      });
    } else if (user.status === 'inactive') {
      actions.push({
        key: 'activate',
        label: t('common.actions.activate'),
        disabled: !canWrite(PERM.usersUpdate),
        disabledReason: disabledReason(PERM.usersUpdate),
        onSelect: () =>
          activateMutation.mutate(user.id ?? '', {
            onSuccess: () =>
              toast.show({
                variant: 'success',
                message: t('fleetUsers.toast.activated', { name }),
              }),
            onError: (error) =>
              toast.show({
                variant: 'error',
                message:
                  error.code === 'CONFLICT' ? error.message : t('fleetUsers.toast.activateFailed'),
              }),
          }),
      });
    }

    actions.push({
      key: 'delete',
      label: t('common.actions.delete'),
      danger: true,
      disabled: !canWrite(PERM.usersDelete),
      disabledReason: disabledReason(PERM.usersDelete),
      onSelect: () => setDeleteTarget(user),
    });

    return actions;
  };

  return (
    <>
      <ListScreen
        title={t('pages.users.title')}
        actions={
          <PermissionGate permission={PERM.usersCreate}>
            <Button
              onClick={() => {
                setEditingUser(undefined);
                setFormOpen(true);
              }}
            >
              {t('fleetUsers.actions.inviteUser')}
            </Button>
          </PermissionGate>
        }
        filtersBar={
          <FiltersBar
            search={listParams.search}
            onSearchChange={listParams.setSearch}
            searchPlaceholder={t('fleetUsers.filters.searchPlaceholder')}
            filters={filters}
            activeFilters={listParams.filters}
            onFilterChange={listParams.setFilter}
            onClearAll={listParams.clearFilters}
          />
        }
        table={
          <DataTable
            tableId="users"
            columns={columns}
            data={rows}
            isLoading={usersQuery.isLoading}
            isError={usersQuery.isError}
            errorMessage={usersQuery.error?.message}
            onRetry={() => void usersQuery.refetch()}
            emptyTitle={
              listParams.hasActiveFilters
                ? t('ui.overlay.emptyState.noResultsTitle')
                : t('fleetUsers.empty.title')
            }
            emptyDescription={
              listParams.hasActiveFilters
                ? t('ui.overlay.emptyState.noResultsDescription')
                : t('fleetUsers.empty.description')
            }
            onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
            sort={listParams.sort}
            order={listParams.order}
            onSortChange={listParams.setSort}
            getRowId={(user, index) => user.id ?? String(index)}
            rowActions={(user) => (
              <RowActionsMenu
                items={buildRowActions(user)}
                ariaLabel={t('fleetUsers.actions.rowMenuLabel', {
                  name: `${user.first_name ?? ''} ${user.last_name ?? ''}`.trim(),
                })}
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

      <UserFormModal
        open={formOpen}
        onClose={() => setFormOpen(false)}
        user={editingUser}
        submitting={createMutation.isPending || updateMutation.isPending}
        onSubmitCreate={async (body: UserCreate) => {
          await createMutation.mutateAsync(body);
          toast.show({ variant: 'success', message: t('fleetUsers.toast.invited') });
        }}
        onSubmitUpdate={async (body: UserUpdate) => {
          if (!editingUser?.id) return;
          await updateMutation.mutateAsync({ id: editingUser.id, body });
          toast.show({ variant: 'success', message: t('fleetUsers.toast.updated') });
        }}
      />

      <ConfirmDialog
        open={Boolean(deactivateTarget)}
        onClose={() => setDeactivateTarget(undefined)}
        loading={deactivateMutation.isPending}
        onConfirm={() => {
          if (!deactivateTarget?.id) return;
          deactivateMutation.mutate(deactivateTarget.id, {
            onSuccess: () => {
              toast.show({ variant: 'success', message: t('fleetUsers.toast.deactivated') });
              setDeactivateTarget(undefined);
            },
            onError: (error) => {
              toast.show({
                variant: 'error',
                message:
                  error.code === 'CONFLICT'
                    ? error.message
                    : t('fleetUsers.toast.deactivateFailed'),
              });
              setDeactivateTarget(undefined);
            },
          });
        }}
        title={t('ui.overlay.confirmDialog.title')}
        description={t('fleetUsers.confirm.deactivate', {
          name: `${deactivateTarget?.first_name ?? ''} ${deactivateTarget?.last_name ?? ''}`.trim(),
        })}
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
              toast.show({ variant: 'success', message: t('fleetUsers.toast.deleted') });
              setDeleteTarget(undefined);
            },
            onError: (error) => {
              toast.show({
                variant: 'error',
                message:
                  error.code === 'CONFLICT' ? error.message : t('fleetUsers.toast.deleteFailed'),
              });
              setDeleteTarget(undefined);
            },
          });
        }}
        title={t('ui.overlay.confirmDialog.title')}
        description={t('fleetUsers.confirm.delete', {
          name: `${deleteTarget?.first_name ?? ''} ${deleteTarget?.last_name ?? ''}`.trim(),
        })}
      />

      <ConfirmDialog
        open={Boolean(resetPasswordTarget)}
        onClose={() => setResetPasswordTarget(undefined)}
        loading={resetPasswordMutation.isPending}
        onConfirm={() => {
          if (!resetPasswordTarget?.id) return;
          resetPasswordMutation.mutate(resetPasswordTarget.id, {
            onSuccess: () => {
              toast.show({ variant: 'success', message: t('fleetUsers.toast.passwordResetSent') });
              setResetPasswordTarget(undefined);
            },
            onError: () => {
              toast.show({ variant: 'error', message: t('fleetUsers.toast.passwordResetFailed') });
              setResetPasswordTarget(undefined);
            },
          });
        }}
        title={t('fleetUsers.confirm.resetPasswordTitle')}
        description={t('fleetUsers.confirm.resetPassword', {
          name: `${resetPasswordTarget?.first_name ?? ''} ${resetPasswordTarget?.last_name ?? ''}`.trim(),
        })}
      />
    </>
  );
}

export default UserListPage;
