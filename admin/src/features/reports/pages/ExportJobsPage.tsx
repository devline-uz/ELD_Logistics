/**
 * Export Jobs — `/reports/exports` (Bosqich 6.7, §7.8.7).
 *
 * `GET /reports/export-jobs?status&type&mine&page&per_page` (`reports.read`).
 * F129: `mine=true` — default (o'z eksportlarim); `Show all` toggle kompaniya
 * bo'yicha ko'rsatadi (`mine=false`).
 *
 * "Requested by" — `export_job.requested_by` faqat UUID (swagger, `Profile`/`User`
 * bilan join yo'q). Joriy foydalanuvchining o'z joblari (`mine=true`, default holat)
 * sessiya profilidan ism bilan ko'rinadi; boshqa foydalanuvchilar `GET /users`
 * ro'yxatidan (agar mavjud bo'lsa) bog'lanadi, aks holda qisqartirilgan ID
 * ko'rsatiladi (backend to'liq requester-ism join bermaydi — `docs/tz/16-17-…` D31).
 */
import { useCallback, useMemo } from 'react';
import { useTranslation } from 'react-i18next';

import { useExportJobsList } from '@/api/queries/reports';
import { useUsersList } from '@/api/queries/users';
import type { ExportJob, ExportJobCreate, ExportJobsListParams } from '@/api/types';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { Select, type SelectOption } from '@/components/ui/Select';
import { Switch } from '@/components/ui/Switch';
import { useListParams } from '@/hooks/useListParams';
import { formatPersonName } from '@/lib/format';
import { useProfileLabel } from '@/lib/profileLabel';
import { useAuthStore } from '@/store/auth-store';

import { ExportJobsTable } from '../components/ExportJobsTable';
import { useSoftRefetchWhileRunning } from '../lib/useSoftRefetchWhileRunning';

const JOB_TYPES: NonNullable<ExportJobCreate['type']>[] = [
  'distance_by_region',
  'regulator',
  'activity',
  'hos',
  'dvir',
];

const JOB_STATUSES = ['queued', 'running', 'done', 'failed'] as const;

export function ExportJobsPage() {
  const { t } = useTranslation();
  const listParams = useListParams();
  const profile = useAuthStore((state) => state.profile);

  const distanceByRegionLabel = useProfileLabel('reports.exportJobs.types.distance_by_region');
  const regulatorLabel = useProfileLabel('reports.exportJobs.types.regulator');

  // `ExportJobsTable` ustunlari `typeLabels`ga bog'liq — har render'da yangi obyekt
  // bo'lsa ustunlar `useMemo`i doim qayta hisoblanardi.
  const typeLabels: Record<NonNullable<ExportJobCreate['type']>, string> = useMemo(
    () => ({
      distance_by_region: distanceByRegionLabel,
      regulator: regulatorLabel,
      activity: t('reports.exportJobs.types.activity'),
      hos: t('reports.exportJobs.types.hos'),
      dvir: t('reports.exportJobs.types.dvir'),
    }),
    [t, distanceByRegionLabel, regulatorLabel],
  );

  const statusFilter = listParams.filters.status || undefined;
  const typeFilter = listParams.filters.type || undefined;
  const showAll = listParams.filters.mine === 'false';

  const queryParams = useMemo<ExportJobsListParams>(
    () => ({
      mine: !showAll,
      status: statusFilter as ExportJobsListParams['status'],
      type: typeFilter as ExportJobsListParams['type'],
      page: listParams.page,
      per_page: listParams.perPage,
    }),
    [showAll, statusFilter, typeFilter, listParams.page, listParams.perPage],
  );

  const jobs = useExportJobsList(queryParams);

  // "Show all" yoqilganda boshqa foydalanuvchilar ismi kerak bo'lishi mumkin. `users.read`
  // bo'lmasa backend `403` qaytaradi, `users.data` bo'sh qoladi va quyida qisqartirilgan
  // ID ga tushiladi — bu yerda alohida ruxsat tekshiruvi shart emas (F35 amal emas, faqat
  // taqdimot yordamchisi).
  const users = useUsersList({ per_page: 50 });
  const userNameById = useMemo(() => {
    const map = new Map<string, string>();
    for (const user of users.data?.data ?? []) {
      if (user.id) map.set(user.id, formatPersonName(user, user.id));
    }
    return map;
  }, [users.data]);

  const resolveRequestedBy = useCallback(
    (job: ExportJob): string => {
      if (!job.requested_by) return t('common.na');
      if (profile?.id && job.requested_by === profile.id) {
        return formatPersonName(profile);
      }
      const name = userNameById.get(job.requested_by);
      if (name) return name;
      return `${job.requested_by.slice(0, 8)}…`;
    },
    [profile, userNameById, t],
  );

  const statusOptions: SelectOption[] = JOB_STATUSES.map((status) => ({
    value: status,
    label: t(`enums.export_job_status.${status}`),
  }));
  const typeOptions: SelectOption[] = JOB_TYPES.map((type) => ({
    value: type,
    label: typeLabels[type],
  }));

  const rows = jobs.data?.data ?? [];
  const hasRunningJobs = rows.some((job) => job.status === 'queued' || job.status === 'running');
  useSoftRefetchWhileRunning(hasRunningJobs, () => void jobs.refetch());

  const hasActiveFilters = Boolean(statusFilter || typeFilter);

  return (
    <ListScreen
      title={t('reports.exportJobs.title')}
      filtersBar={
        <div className="flex flex-wrap items-end gap-3">
          <Select
            label={t('reports.exportJobs.filters.status')}
            placeholder={t('reports.exportJobs.filters.statusPlaceholder')}
            clearable
            value={statusFilter ?? null}
            onChange={(value) => listParams.setFilter('status', value ?? undefined)}
            options={statusOptions}
            className="w-40"
          />
          <Select
            label={t('reports.exportJobs.filters.type')}
            placeholder={t('reports.exportJobs.filters.typePlaceholder')}
            clearable
            value={typeFilter ?? null}
            onChange={(value) => listParams.setFilter('type', value ?? undefined)}
            options={typeOptions}
            className="w-48"
          />
          <div className="ms-auto">
            <Switch
              label={t('reports.exportJobs.filters.showAll')}
              checked={showAll}
              onChange={(event) =>
                listParams.setFilter('mine', event.target.checked ? 'false' : undefined)
              }
            />
          </div>
        </div>
      }
      table={
        <ExportJobsTable
          data={rows}
          typeLabels={typeLabels}
          resolveRequestedBy={resolveRequestedBy}
          isLoading={jobs.isLoading}
          isError={jobs.isError}
          errorMessage={jobs.error?.message}
          onRetry={() => void jobs.refetch()}
          emptyDescription={
            hasActiveFilters
              ? t('reports.exportJobs.empty.filteredDescription')
              : t('reports.exportJobs.empty.description')
          }
          onClearFilters={
            hasActiveFilters
              ? () => listParams.setFilters({ status: undefined, type: undefined })
              : undefined
          }
          rowOffset={(listParams.page - 1) * listParams.perPage}
        />
      }
      pagination={
        <Pagination
          page={listParams.page}
          perPage={listParams.perPage}
          total={jobs.data?.meta?.total ?? 0}
          onPageChange={listParams.setPage}
          onPerPageChange={listParams.setPerPage}
        />
      }
    />
  );
}

export default ExportJobsPage;
