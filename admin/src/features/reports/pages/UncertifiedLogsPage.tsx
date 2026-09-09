/**
 * Uncertified Logs — `/reports/uncertified-logs` (Bosqich 6.6, §7.8.5, F128).
 *
 * `GET /reports/uncertified-logs?driver_id&branch_id` (`reports.read`).
 * F128: 8 kundan eskirgan sertifikatlanmagan kunlar ham shu hisobotda
 * ko'rinadi — filtrda 8 kunlik oyna cheklovi **yo'q** (backend allaqachon
 * shu tarzda qaytaradi, frontend qo'shimcha cheklamaydi).
 *
 * `Branch` filtri faqat `scope=company` administratoriga ko'rsatiladi
 * (fe-permissions §4 — `scope=branch` uchun backend avtomatik cheklaydi).
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

import { useReportsUncertifiedLogs } from '@/api/queries/reports';
import { useBranchesList } from '@/api/queries/branches';
import type { ReportsUncertifiedLogsParams, UncertifiedLog } from '@/api/types';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { Select, type SelectOption } from '@/components/ui/Select';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useIsCompanyScope } from '@/hooks/useScope';
import { useListParams } from '@/hooks/useListParams';

import { UncertifiedLogsTable } from '../components/UncertifiedLogsTable';
import { useDriverOptions } from '../lib/useEntityOptions';

export function UncertifiedLogsPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const dateFormat = useDateFormat();
  const listParams = useListParams();
  const isCompanyScope = useIsCompanyScope();

  const driverFilter = listParams.filters.driver_id || undefined;
  const branchFilter = listParams.filters.branch_id || undefined;

  const drivers = useDriverOptions();
  const branches = useBranchesList({ per_page: 50 }, { enabled: isCompanyScope });

  const branchOptions: SelectOption[] = useMemo(
    () =>
      (branches.data?.data ?? [])
        .filter((branch): branch is typeof branch & { id: string } => Boolean(branch.id))
        .map((branch) => ({ value: branch.id, label: branch.name ?? branch.id })),
    [branches.data],
  );

  const queryParams = useMemo<ReportsUncertifiedLogsParams>(
    () => ({
      driver_id: driverFilter,
      branch_id: isCompanyScope ? branchFilter : undefined,
      page: listParams.page,
      per_page: listParams.perPage,
    }),
    [driverFilter, branchFilter, isCompanyScope, listParams.page, listParams.perPage],
  );

  const list = useReportsUncertifiedLogs(queryParams);

  const hasActiveFilters = Boolean(driverFilter || branchFilter);

  const openLog = (log: UncertifiedLog) => {
    if (log.daily_log_id) navigate(`/logs/view/${encodeURIComponent(log.daily_log_id)}`);
  };

  return (
    <ListScreen
      title={t('reports.uncertifiedLogs.title')}
      filtersBar={
        <div className="flex flex-wrap items-end gap-3">
          <Select
            label={t('reports.uncertifiedLogs.filters.driver')}
            placeholder={t('reports.uncertifiedLogs.filters.driverPlaceholder')}
            searchable
            clearable
            loading={drivers.isLoading}
            value={driverFilter ?? null}
            onChange={(value) => listParams.setFilter('driver_id', value ?? undefined)}
            options={drivers.options}
            className="w-56"
          />
          {isCompanyScope ? (
            <Select
              label={t('reports.uncertifiedLogs.filters.branch')}
              placeholder={t('reports.uncertifiedLogs.filters.branchPlaceholder')}
              clearable
              loading={branches.isLoading}
              value={branchFilter ?? null}
              onChange={(value) => listParams.setFilter('branch_id', value ?? undefined)}
              options={branchOptions}
              className="w-56"
            />
          ) : null}
        </div>
      }
      table={
        <UncertifiedLogsTable
          data={list.data?.data ?? []}
          isLoading={list.isLoading}
          isError={list.isError}
          errorMessage={list.error?.message}
          onRetry={() => void list.refetch()}
          emptyDescription={
            hasActiveFilters
              ? t('reports.uncertifiedLogs.empty.filteredDescription')
              : t('reports.uncertifiedLogs.empty.description')
          }
          onClearFilters={
            hasActiveFilters
              ? () => listParams.setFilters({ driver_id: undefined, branch_id: undefined })
              : undefined
          }
          rowOffset={(listParams.page - 1) * listParams.perPage}
          dateFormat={dateFormat}
          onOpenLog={openLog}
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
  );
}

export default UncertifiedLogsPage;
