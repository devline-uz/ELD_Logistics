/**
 * Export Jobs — umumiy taqdimot yordamchilari (7.8.3 `Job ID` ustuni, 7.8.7 `Params`/`Size`
 * ustunlari). `RegulatorJobsTable` va `ExportJobsTable` ikkalasi ham shu faylni ishlatadi —
 * ustun formatlash bir joyda takrorlanmasligi uchun.
 */
import type { TFunction } from 'i18next';

import type { ExportJob, ExportParams } from '@/api/types';
import type { BadgeTone } from '@/components/ui/Badge';
import { NA } from '@/lib/format';

/**
 * `export_job.status` → `Badge` ohangi. `ExportJobModal`, `RegulatorJobsTable` va
 * `ExportJobsTable` (7.8.3/7.8.7) — uchalasi shu yagona xaritani ishlatadi.
 */
export const EXPORT_JOB_STATUS_TONE: Record<'queued' | 'running' | 'done' | 'failed', BadgeTone> = {
  queued: 'neutral',
  running: 'warning',
  done: 'success',
  failed: 'error',
};

/**
 * Tayyor eksport faylini yangi tabda ochadi. `noopener` — `download_url` tashqi
 * (presigned) manzil, `window.opener` orqali sahifaga kirish berilmaydi.
 */
export function openExportJobDownload(job: ExportJob | undefined): void {
  if (!job?.download_url) return;
  window.open(job.download_url, '_blank', 'noopener');
}

/**
 * `export_job.file_size_b` — baytlarda. Jadvalda kompakt ko'rinish uchun
 * B/KB/MB ga aylantiradi. `lib/units.ts` fayl hajmini bilmaydi (masofa/tezlik
 * uchun), shuning uchun bu yordamchi shu yerda.
 */
export function formatExportJobFileSize(bytes: number | null | undefined): string {
  if (typeof bytes !== 'number' || !Number.isFinite(bytes) || bytes < 0) {
    return NA;
  }
  if (bytes < 1024) {
    return `${bytes} B`;
  }
  const kb = bytes / 1024;
  if (kb < 1024) {
    return `${kb.toFixed(1)} KB`;
  }
  return `${(kb / 1024).toFixed(1)} MB`;
}

export interface ExportParamsSummaryContext {
  /** `driver_ids` uchun oldindan yechilgan ismlar (chaqiruvchi `useDriversList` bilan bog'laydi). */
  driverNames?: readonly string[];
}

/**
 * `export_job.params` (`ExportParams`) — jadval katagi uchun kompakt bitta qatorli
 * xulosa (7.8.7 "Params ustuni — kompakt ko'rinish"). To'liq matn `Tooltip`da ham
 * shu funksiya bilan olinadi (bitta manba — ikkalasi orasida farq yo'q).
 */
export function summarizeExportParams(
  params: ExportParams | null | undefined,
  t: TFunction,
  context: ExportParamsSummaryContext = {},
): string {
  if (!params) {
    return NA;
  }

  const parts: string[] = [];

  if (params.quarter && params.year) {
    parts.push(`Q${params.quarter} ${params.year}`);
  } else if (params.year) {
    parts.push(String(params.year));
  }

  if (params.mode) {
    parts.push(t(`reports.distanceByRegion.generateModal.modeOptions.${params.mode}`));
  }

  if (params.subject) {
    parts.push(t(`reports.activityReport.tabs.${params.subject}`));
  }

  if (params.from || params.to) {
    parts.push(`${params.from ?? NA} – ${params.to ?? NA}`);
  }

  if (context.driverNames && context.driverNames.length > 0) {
    parts.push(context.driverNames.join(', '));
  } else if (params.driver_ids && params.driver_ids.length > 0) {
    parts.push(t('reports.exportJobs.params.driverCount', { count: params.driver_ids.length }));
  }

  if (params.unit_ids && params.unit_ids.length > 0) {
    parts.push(t('reports.exportJobs.params.unitCount', { count: params.unit_ids.length }));
  }

  if (params.comment) {
    parts.push(params.comment);
  }

  return parts.length > 0 ? parts.join(' · ') : NA;
}
