/**
 * Qayta ishlatiladigan eksport modali — `POST /reports/export-jobs` + `useExportJob` polling
 * ustida qurilgan (Bosqich 6.2/6.3, fe-api §9). Har bir hisobot ekrani (Activity, Distance by
 * Region, keyingi bosqichlarda Regulator/DVIR) shu komponentni ishlatadi — domenga xos
 * maydonlar `children` slotiga joylashtiriladi, `params` esa chaqiruvchi hisoblagan
 * `ExportParams` obyekti (report turi bo'yicha filtrlar).
 *
 * Holat mashinasi:
 * 1. Job hali yaratilmagan — `children` (report'ga xos maydonlar) + format tanlovi + `Generate`.
 * 2. Job yaratilgan, `queued`/`running` — progress + "Preparing your file…" (fe-screens §6).
 * 3. `done` — muddati o'tmagan bo'lsa yuklab olish havolasi, o'tgan bo'lsa "Link expired".
 * 4. `failed` — xato xabari + `Try again` (jobId tozalanadi, forma qaytadi).
 * 5. `pollingTimedOut` — "hali tayyor emas" xabari (job fonda davom etadi).
 *
 * `Idempotency-Key` — `api/client.ts` middleware'i avtomatik biriktiradi, bu yerda qo'lda
 * boshqarilmaydi.
 */
import { useEffect, useState, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { Loader2 } from 'lucide-react';

import {
  isExportJobDownloadExpired,
  useExportJob,
  useExportJobCreate,
} from '@/api/queries/reports';
import type { ExportJob, ExportJobCreate, ExportParams } from '@/api/types';
import { Alert } from '@/components/feedback/Alert';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Icon } from '@/components/ui/Icon';
import { Modal } from '@/components/ui/Modal';
import { Select, type SelectOption } from '@/components/ui/Select';
import { isApiError } from '@/lib/errors';

import { EXPORT_JOB_STATUS_TONE, openExportJobDownload } from '../lib/exportJobDisplay';

export type ExportJobFormat = NonNullable<ExportJobCreate['format']>;

const ALL_FORMATS: readonly ExportJobFormat[] = ['csv', 'xlsx', 'pdf', 'zip'];

export interface ExportJobModalProps {
  open: boolean;
  onClose: () => void;
  /** `POST /reports/export-jobs` body'sidagi hisobot turi. */
  type: ExportJobCreate['type'];
  /** Modal sarlavhasi — i18n kalit. */
  titleKey: string;
  /**
   * Hisobotga xos filtrlar (`ExportParams`) — chaqiruvchi har render'da hozirgi holatga mos
   * obyekt beradi (masalan tanlangan `quarter`/`year`/`unit_ids`). Job faqat `Generate`
   * bosilgan paytdagi qiymat bilan yaratiladi.
   */
  params: ExportParams;
  /** Ruxsat etilgan formatlar (default — barcha 4ta: `csv|xlsx|pdf|zip`). */
  formats?: readonly ExportJobFormat[];
  /** `Generate` tugmasi bloklanishi kerak bo'lsa (masalan majburiy maydon bo'sh). */
  generateDisabled?: boolean;
  /** `generateDisabled` bo'lganda ko'rsatiladigan sabab (fe-permissions: tugma sababsiz o'chmaydi). */
  generateDisabledReason?: string;
  /** Format tanlovidan oldin render qilinadigan report'ga xos maydonlar. */
  children?: ReactNode;
  /** Job `done` holatiga yetganda bir marta chaqiriladi (masalan ro'yxatni invalidatsiya qilish). */
  onJobDone?: (job: ExportJob) => void;
}

/** Modal ochilganda/yopilganda ichki holatni tozalaydi. */
function useResetOnOpen(open: boolean, reset: () => void): void {
  useEffect(() => {
    if (open) reset();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open]);
}

export function ExportJobModal({
  open,
  onClose,
  type,
  titleKey,
  params,
  formats = ALL_FORMATS,
  generateDisabled,
  generateDisabledReason,
  children,
  onJobDone,
}: ExportJobModalProps) {
  const { t } = useTranslation();
  const [format, setFormat] = useState<ExportJobFormat>(formats[0] ?? 'csv');
  const [jobId, setJobId] = useState<string | undefined>(undefined);
  const [createError, setCreateError] = useState<string | undefined>(undefined);

  const create = useExportJobCreate();
  // `open` shartsiz — modal yopilganda (`onClose`) job hali `queued`/`running` bo'lsa ham
  // polling to'xtashi shart (fe-testing 6.10: "modal yopilganda ham to'xtaydi, unmount leak
  // yo'q"). Faqat `Boolean(jobId)` bilan cheklash — yopilgandan keyin ham fon so'rovlari
  // davom etadigan oqib chiqish (leak) edi.
  const job = useExportJob(jobId, { enabled: open && Boolean(jobId) });

  useResetOnOpen(open, () => {
    setJobId(undefined);
    setCreateError(undefined);
    setFormat(formats[0] ?? 'csv');
  });

  useEffect(() => {
    if (job.data?.status === 'done') {
      onJobDone?.(job.data);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [job.data?.status]);

  const formatOptions: SelectOption<ExportJobFormat>[] = formats.map((value) => ({
    value,
    label: t(`reports.exportJobModal.formats.${value}`),
  }));

  const handleGenerate = async () => {
    setCreateError(undefined);
    try {
      const created = await create.mutateAsync({ type, format, params });
      if (created?.id) {
        setJobId(created.id);
      }
    } catch (error) {
      if (isApiError(error) && error.status === 501) {
        setCreateError(t('reports.exportJobModal.errors.featureDisabled'));
        return;
      }
      setCreateError(isApiError(error) ? error.message : t('errors.unknown'));
    }
  };

  const status = job.data?.status;
  const expired = isExportJobDownloadExpired(job.data);

  const footer = !jobId ? (
    <div className="flex justify-end gap-2">
      <Button variant="secondary" onClick={onClose}>
        {t('common.actions.cancel')}
      </Button>
      <Button
        onClick={() => void handleGenerate()}
        loading={create.isPending}
        disabled={generateDisabled}
        title={generateDisabled ? generateDisabledReason : undefined}
      >
        {t('reports.exportJobModal.actions.generate')}
      </Button>
    </div>
  ) : status === 'failed' ? (
    <div className="flex justify-end gap-2">
      <Button variant="secondary" onClick={onClose}>
        {t('common.actions.close')}
      </Button>
      <Button onClick={() => setJobId(undefined)}>{t('common.actions.tryAgain')}</Button>
    </div>
  ) : status === 'done' && job.data && !expired ? (
    <div className="flex justify-end gap-2">
      <Button variant="secondary" onClick={onClose}>
        {t('common.actions.close')}
      </Button>
      <Button onClick={() => openExportJobDownload(job.data)}>
        {t('reports.exportJobModal.actions.download')}
      </Button>
    </div>
  ) : (
    <div className="flex justify-end">
      <Button variant="secondary" onClick={onClose}>
        {t('common.actions.close')}
      </Button>
    </div>
  );

  return (
    <Modal
      open={open}
      onClose={onClose}
      size="md"
      title={t(titleKey)}
      closeOnBackdrop={!jobId}
      footer={footer}
    >
      <div className="flex flex-col gap-4">
        {createError ? <Alert variant="error" message={createError} /> : null}

        {!jobId ? (
          <>
            {children}
            <Select
              label={t('reports.exportJobModal.formatLabel')}
              required
              value={format}
              onChange={(value) => value && setFormat(value)}
              options={formatOptions}
            />
          </>
        ) : (
          <div className="flex flex-col items-center gap-3 py-6 text-center">
            {status && (status === 'queued' || status === 'running') ? (
              <>
                <Icon icon={Loader2} size={32} className="animate-spin text-primary" />
                <p className="text-body text-neutral-600">
                  {t('reports.exportJobModal.status.preparing')}
                </p>
                <Badge tone={EXPORT_JOB_STATUS_TONE[status]}>
                  {t(`enums.export_job_status.${status}`)}
                </Badge>
              </>
            ) : null}

            {status === 'done' ? (
              expired ? (
                <Alert variant="warning" message={t('reports.exportJobModal.errors.expired')} />
              ) : (
                <Alert variant="success" message={t('reports.exportJobModal.downloadReady')} />
              )
            ) : null}

            {status === 'failed' ? (
              <Alert variant="error" message={job.data?.error ?? t('errors.unknown')} />
            ) : null}

            {job.pollingTimedOut && status !== 'done' && status !== 'failed' ? (
              <Alert variant="info" message={t('reports.exportJobModal.errors.timedOut')} />
            ) : null}
          </div>
        )}
      </div>
    </Modal>
  );
}

export default ExportJobModal;
