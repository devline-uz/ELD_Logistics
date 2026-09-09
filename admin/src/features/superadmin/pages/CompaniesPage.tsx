/**
 * Super Admin — `/companies` (9.15, §7.14, `[MAY]`). `GET/POST /companies`,
 * `PATCH /companies/{id}`, `PATCH /companies/{id}/subscription`.
 *
 * Ruxsat — `super_admin` bayrog'i (rol emas, `PERM` katalogida yo'q, F33).
 * Marshrut darajasida `RouteGuard superAdminOnly` bilan yopilgan
 * (`app/router/superadmin.routes.tsx`) — bu sahifa ichida qo'shimcha
 * tekshiruv shart emas.
 *
 * ⚠️ Backend bo'shlig'i (D55): `GET /companies/{id}` yo'q — Edit/Subscription
 * formalari ro'yxat qatoridagi obyektni ishlatadi (`docs/tz/16-17-registry-
 * open-questions.md`).
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

import {
  useAdminCompaniesList,
  useAdminCompanyCreate,
  useAdminCompanySubscriptionUpdate,
  useAdminCompanyUpdate,
} from '@/api/queries/companies';
import type { AdminCompaniesListParams, AdminCompany } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import type { RowActionItem } from '@/components/data/RowActionsMenu';
import { useToast } from '@/components/feedback/toast-context';
import { Button } from '@/components/ui/Button';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';

import { buildCompanyColumns } from '../components/companyColumns';
import { CompanyFormModal } from '../components/CompanyFormModal';
import { SubscriptionFormModal } from '../components/SubscriptionFormModal';
import { enterCompany } from '../lib/impersonation';
import { REGION_VALUES, SUBSCRIPTION_STATUS_VALUES } from '../lib/schemas';

const TABLE_ID = 'superadmin-companies';

export function CompaniesPage() {
  const { t } = useTranslation();
  const toast = useToast();
  const navigate = useNavigate();
  const dateFormat = useDateFormat();
  const listParams = useListParams();

  const [formOpen, setFormOpen] = useState(false);
  const [editing, setEditing] = useState<AdminCompany | undefined>(undefined);
  const [subscriptionTarget, setSubscriptionTarget] = useState<AdminCompany | undefined>(undefined);

  const queryParams = useMemo<AdminCompaniesListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      search: listParams.search || undefined,
      status: (listParams.filters.status as AdminCompaniesListParams['status']) || undefined,
      region: (listParams.filters.region as AdminCompaniesListParams['region']) || undefined,
      ...(listParams.sort ? { sort: listParams.sort as AdminCompaniesListParams['sort'] } : {}),
      ...(listParams.order ? { order: listParams.order } : {}),
    }),
    [
      listParams.page,
      listParams.perPage,
      listParams.search,
      listParams.filters.status,
      listParams.filters.region,
      listParams.sort,
      listParams.order,
    ],
  );

  const list = useAdminCompaniesList(queryParams);
  const create = useAdminCompanyCreate();
  const update = useAdminCompanyUpdate();
  const subscription = useAdminCompanySubscriptionUpdate();

  const buildActions = (company: AdminCompany): RowActionItem[] => [
    {
      key: 'edit',
      label: t('common.actions.edit'),
      onSelect: () => {
        setEditing(company);
        setFormOpen(true);
      },
    },
    {
      key: 'subscription',
      label: t('superadmin.companies.actions.subscription'),
      onSelect: () => setSubscriptionTarget(company),
    },
    {
      key: 'enter',
      label: t('superadmin.companies.actions.enter'),
      onSelect: () => {
        enterCompany(company);
        toast.show({
          variant: 'info',
          message: t('superadmin.impersonation.toast.entered', { company: company.name }),
        });
        void navigate('/');
      },
    },
  ];

  const columns = buildCompanyColumns(t, { dateFormat, buildActions });

  return (
    <ListScreen
      title={t('superadmin.companies.title')}
      actions={
        <Button
          onClick={() => {
            setEditing(undefined);
            setFormOpen(true);
          }}
        >
          {t('superadmin.companies.add')}
        </Button>
      }
      filtersBar={
        <FiltersBar
          search={listParams.search}
          onSearchChange={listParams.setSearch}
          searchPlaceholder={t('superadmin.companies.filters.searchPlaceholder')}
          filters={[
            {
              key: 'status',
              label: t('superadmin.companies.filters.status'),
              options: SUBSCRIPTION_STATUS_VALUES.map((value) => ({
                value,
                label: t(`superadmin.companies.status.${value}`),
              })),
            },
            {
              key: 'region',
              label: t('superadmin.companies.filters.region'),
              options: REGION_VALUES.map((value) => ({
                value,
                label: t(`superadmin.companies.region.${value}`),
              })),
            },
          ]}
          activeFilters={listParams.filters}
          onFilterChange={listParams.setFilter}
          onClearAll={listParams.clearFilters}
        />
      }
      table={
        <>
          <DataTable
            tableId={TABLE_ID}
            columns={columns}
            data={list.data?.data ?? []}
            isLoading={list.isLoading}
            isError={list.isError}
            errorMessage={list.error?.message}
            onRetry={() => void list.refetch()}
            emptyTitle={
              listParams.hasActiveFilters
                ? t('superadmin.companies.empty.filteredTitle')
                : t('superadmin.companies.empty.title')
            }
            emptyDescription={
              listParams.hasActiveFilters
                ? t('superadmin.companies.empty.filteredDescription')
                : t('superadmin.companies.empty.description')
            }
            onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
            sort={listParams.sort}
            order={listParams.order}
            onSortChange={(columnId, order) => listParams.setSort(columnId, order)}
            getRowId={(item, index) => item.id ?? String(index)}
          />

          <CompanyFormModal
            open={formOpen}
            onClose={() => setFormOpen(false)}
            company={editing}
            isPending={create.isPending || update.isPending}
            onCreate={(body) => create.mutateAsync(body)}
            onUpdate={(id, body) => update.mutateAsync({ id, body })}
            onSuccess={(isEdit, name) =>
              toast.show({
                variant: 'success',
                message: isEdit
                  ? t('superadmin.companies.toast.updated', { name })
                  : t('superadmin.companies.toast.created', { name }),
              })
            }
          />

          <SubscriptionFormModal
            open={Boolean(subscriptionTarget)}
            onClose={() => setSubscriptionTarget(undefined)}
            company={subscriptionTarget}
            isPending={subscription.isPending}
            onSubmit={(id, body) => subscription.mutateAsync({ id, body })}
            onSuccess={(name) =>
              toast.show({
                variant: 'success',
                message: t('superadmin.companies.toast.subscriptionUpdated', { name }),
              })
            }
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

export default CompaniesPage;
