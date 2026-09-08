/**
 * Regulator Export / FMCSA — `/reports/regulator` (Bosqich 6.4, §7.8.3).
 *
 * F125: ekran nomi `regulation_profile`ga bog'liq (`useProfileLabel`) — `us_fmcsa` →
 * "FMCSA Report", boshqa 6 profil → "Regulator Export".
 *
 * `GET /reports/export-jobs?type=regulator` (`reports.read`) — job ro'yxati;
 * `POST /reports/export-jobs {type:"regulator"}` (`reports.export`) — Generate modali
 * orqali (`RegulatorGenerateModal`, `ExportJobModal` ustida).
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';

import { useExportJobsList } from '@/api/queries/reports';
import type { ExportJobsListParams } from '@/api/types';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { Button } from '@/components/ui/Button';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { useListParams } from '@/hooks/useListParams';
import { useWriteGuard } from '@/hooks/useWriteGuard';
import { PERM } from '@/lib/permissions';
import { useProfileLabel } from '@/lib/profileLabel';

import { RegulatorGenerateModal } from '../components/RegulatorGenerateModal';
import { RegulatorJobsTable } from '../components/RegulatorJobsTable';
import { useDriverNameById, useDriverOptions } from '../lib/useEntityOptions';
import { useSoftRefetchWhileRunning } from '../lib/useSoftRefetchWhileRunning';

export function RegulatorExportPage() {
  const { t } = useTranslation();
  const listParams = useListParams();
  const writeGuard = useWriteGuard();
  const screenName = useProfileLabel('reports.regulator.screenName');
  const [generateOpen, setGenerateOpen] = useState(false);

  const queryParams = useMemo<ExportJobsListParams>(
    () => ({
      type: 'regulator',
      page: listParams.page,
      per_page: listParams.perPage,
    }),
    [listParams.page, listParams.perPage],
  );

  const jobs = useExportJobsList(queryParams);
  const drivers = useDriverOptions();
  const driverNameById = useDriverNameById(drivers.data);

  const rows = jobs.data?.data ?? [];
  const hasRunningJobs = rows.some((job) => job.status === 'queued' || job.status === 'running');
  useSoftRefetchWhileRunning(hasRunningJobs, () => void jobs.refetch());

  return (
    <div className="flex flex-col gap-4">
      <ListScreen
        title={screenName}
        actions={
          <PermissionGate permission={PERM.reportsExport}>
            <Button
              onClick={() => setGenerateOpen(true)}
              disabled={!writeGuard.canWrite(PERM.reportsExport)}
              title={writeGuard.disabledReason(PERM.reportsExport)}
            >
              {t('reports.regulator.actions.generate')}
            </Button>
          </PermissionGate>
        }
        table={
          <RegulatorJobsTable
            data={rows}
            driverNameById={driverNameById}
            isLoading={jobs.isLoading}
            isError={jobs.isError}
            errorMessage={jobs.error?.message}
            onRetry={() => void jobs.refetch()}
            emptyDescription={t('reports.regulator.empty.description')}
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

      <RegulatorGenerateModal
        open={generateOpen}
        onClose={() => setGenerateOpen(false)}
        driverOptions={drivers.options}
        driversLoading={drivers.isLoading}
        onJobDone={() => void jobs.refetch()}
      />
    </div>
  );
}

export default RegulatorExportPage;
