/**
 * Ro'yxat qatoridagi `Download` amali — `RegulatorJobsTable` (7.8.3) va
 * `ExportJobsTable` (7.8.7) bir xil holat mashinasini ishlatadi:
 * `done` + muddati o'tmagan → yuklab olish; boshqa barcha holat — sababi bilan
 * `disabled` (fe-permissions F35: hech qanday tugma sababsiz o'chmaydi).
 */
import { useTranslation } from 'react-i18next';

import { isExportJobDownloadExpired } from '@/api/queries/reports';
import type { ExportJob } from '@/api/types';
import { Button } from '@/components/ui/Button';

import { openExportJobDownload } from '../lib/exportJobDisplay';

export interface ExportJobDownloadActionProps {
  job: ExportJob;
}

export function ExportJobDownloadAction({ job }: ExportJobDownloadActionProps) {
  const { t } = useTranslation();
  const expired = isExportJobDownloadExpired(job);
  const label = t('reports.exportJobModal.actions.download');

  if (job.status === 'done' && job.download_url && !expired) {
    return (
      <Button variant="secondary" size="sm" onClick={() => openExportJobDownload(job)}>
        {label}
      </Button>
    );
  }

  const reason =
    job.status === 'failed'
      ? (job.error ?? t('errors.unknown'))
      : job.status === 'done' && expired
        ? t('reports.exportJobModal.errors.expired')
        : t('reports.exportJobModal.status.preparing');

  return (
    <Button
      variant="secondary"
      size="sm"
      disabled
      title={reason}
      aria-label={`${label}: ${reason}`}
    >
      {label}
    </Button>
  );
}

export default ExportJobDownloadAction;
