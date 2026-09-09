/**
 * DVIR detali — `/dvir/:dvirId` (5.3–5.5, `docs/tz/07-5-dvir-maintenance.md`
 * §7.5).
 *
 * Bloklari: sarlavha + status · unit/trailer · tur · vaqt/joylashuv/odometer ·
 * nuqsonlar (kategoriya, `is_critical`, fotolar ≤ 5 lightbox bilan, izoh) ·
 * imzolar (**faqat ko'rish** — F107) · holat tarixi.
 *
 * Amallar (holat mashinasiga qat'iy bog'langan, F106):
 * - `Record repair` — faqat `submitted_defects_found` (`dvir.repair`),
 *   tasdiq dialogi bilan; **D30** — mexanik imzosi mobil ilovada olinadi,
 *   hisobotda `mechanic_signature_key` bo'lmasa tugma `disabled` va sababi
 *   ko'rsatiladi (admin panel imzoni umuman olmaydi)
 * - `Download PDF` — `dvir.export`, blob → `revokeObjectURL` (leak yo'q)
 *
 * ⚠️ `Certify` amali admin panelda **yo'q**: `POST /dvir-reports/{id}/certify`
 * tavsifiga ko'ra bu haydovchi endpointi — chaqiruvchi driver record'ga ega
 * bo'lishi shart va imzo haydovchiniki. `repaired` holatida tugma o'rniga
 * kutish holati tushuntiriladi (haydovchi mobil ilovada tasdiqlaydi).
 *
 * **F108**: `out_of_service` bo'lsa sahifa tepasida qizil banner.
 */
import { useState, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate, useParams } from 'react-router-dom';
import { AlertTriangle } from 'lucide-react';

import { useDvirPdfDownload, useDvirRepair, useDvirReport } from '@/api/queries/dvir';
import type { DvirDefect } from '@/api/types';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { useToast } from '@/components/feedback/toast-context';
import { Badge } from '@/components/ui/Badge';
import { Breadcrumb } from '@/components/ui/Breadcrumb';
import { Button } from '@/components/ui/Button';
import { Icon } from '@/components/ui/Icon';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useUnitSystem } from '@/hooks/useUnitSystem';
import { saveBlob } from '@/lib/download';
import { formatPersonName } from '@/lib/format';
import { PERM } from '@/lib/permissions';

import { DvirStatusBadge } from '../components/DvirStatusBadge';
import { DvirStatusHistory } from '../components/DvirStatusHistory';
import { OutOfServiceBanner } from '../components/OutOfServiceBanner';
import { PhotoLightbox } from '../components/PhotoLightbox';
import { RecordRepairModal } from '../components/RecordRepairModal';
import { SignatureView } from '../components/SignatureView';
import {
  awaitsDriverCertification,
  canRecordRepair,
  isRepairBlockedByMissingSignature,
} from '../lib/status';
import { resolveStorageUrl } from '@/lib/storage';

function Field({ label, value }: { label: string; value: ReactNode }) {
  return (
    <div>
      <dt className="text-body-sm text-neutral-600">{label}</dt>
      <dd className="text-body text-neutral-900">{value}</dd>
    </div>
  );
}

function Section({ title, children }: { title: string; children: ReactNode }) {
  return (
    <section className="flex flex-col gap-3 rounded-lg border border-stroke bg-surface p-4">
      <h2 className="text-body-lg font-semibold text-neutral-900">{title}</h2>
      {children}
    </section>
  );
}

export function DvirDetailPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const toast = useToast();
  const dateFormat = useDateFormat();
  const unitSystem = useUnitSystem();
  const { dvirId } = useParams<{ dvirId: string }>();

  const report = useDvirReport(dvirId);
  const repair = useDvirRepair();
  const pdf = useDvirPdfDownload();

  const [repairOpen, setRepairOpen] = useState(false);
  const [lightbox, setLightbox] = useState<
    { photoKeys: string[]; index: number; name: string } | undefined
  >(undefined);

  if (report.isLoading) {
    return <Skeleton variant="card" count={4} />;
  }

  if (report.isError || !report.data) {
    return (
      <ErrorState
        title={t('errors.notFound')}
        message={t('dvir.detail.notFound')}
        onRetry={() => void report.refetch()}
      />
    );
  }

  const data = report.data;
  const unitLabel = data.unit_number ?? data.unit_id ?? t('common.na');

  const handleDownloadPdf = async () => {
    try {
      const blob = await pdf.mutateAsync(data.id ?? '');
      saveBlob(blob, `dvir-${unitLabel}-${(data.id ?? '').slice(0, 8)}.pdf`);
      toast.show({ variant: 'success', message: t('dvir.toast.pdfDownloaded') });
    } catch {
      toast.show({ variant: 'error', message: t('dvir.toast.pdfFailed') });
    }
  };

  return (
    <div className="flex flex-col gap-4">
      <Breadcrumb items={[{ label: t('dvir.list.title'), href: '/dvir' }, { label: unitLabel }]} />

      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <h1 className="text-h3 font-bold text-neutral-900">{unitLabel}</h1>
          <DvirStatusBadge status={data.status} />
        </div>

        <div className="flex flex-wrap items-center gap-2">
          {canRecordRepair(data) ? (
            <PermissionGate permission={PERM.dvirRepair}>
              <Button variant="secondary" onClick={() => setRepairOpen(true)}>
                {t('dvir.actions.recordRepair')}
              </Button>
            </PermissionGate>
          ) : null}

          {/* D30: imzo mobil ilovada olinadi — kalitsiz amal boshlanmaydi. */}
          {isRepairBlockedByMissingSignature(data) ? (
            <PermissionGate permission={PERM.dvirRepair}>
              <Button variant="secondary" disabled title={t('dvir.repair.signatureMissing')}>
                {t('dvir.actions.recordRepair')}
              </Button>
            </PermissionGate>
          ) : null}

          <PermissionGate permission={PERM.dvirExport}>
            <Button onClick={() => void handleDownloadPdf()} loading={pdf.isPending}>
              {t('dvir.actions.downloadPdf')}
            </Button>
          </PermissionGate>
        </div>
      </div>

      {data.out_of_service ? <OutOfServiceBanner /> : null}

      {awaitsDriverCertification(data.status) ? (
        <div
          role="status"
          className="rounded-lg border border-stroke bg-light p-4 text-neutral-700"
        >
          <p className="text-body font-semibold">{t('dvir.detail.certification.awaitingTitle')}</p>
          <p className="text-body-sm">{t('dvir.detail.certification.awaitingDescription')}</p>
        </div>
      ) : null}

      <Section title={t('dvir.detail.sections.summary')}>
        <dl className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <Field label={t('dvir.detail.fields.unit')} value={unitLabel} />
          <Field
            label={t('dvir.detail.fields.trailers')}
            value={data.trailer_ids?.length ? data.trailer_ids.join(', ') : t('common.na')}
          />
          <Field
            label={t('dvir.detail.fields.type')}
            value={data.type ? t(`enums.dvir_type.${data.type}`) : t('common.na')}
          />
          <Field
            label={t('dvir.detail.fields.source')}
            value={data.source ? t(`enums.dvir_source.${data.source}`) : t('common.na')}
          />
          <Field
            label={t('dvir.detail.fields.driver')}
            value={formatPersonName(data.driver, t('common.na'))}
          />
          <Field
            label={t('dvir.detail.fields.performedAt')}
            value={dateFormat.formatDateTime(data.performed_at ?? data.created_at)}
          />
          <Field
            label={t('dvir.detail.fields.location')}
            value={data.location_text ?? t('common.na')}
          />
          <Field
            label={t('dvir.detail.fields.coordinates')}
            value={
              data.lat !== undefined && data.lng !== undefined
                ? `${data.lat.toFixed(7)}, ${data.lng.toFixed(7)}`
                : t('common.na')
            }
          />
          <Field
            label={t('dvir.detail.fields.odometer')}
            value={
              data.odometer_m !== undefined
                ? unitSystem.formatDistance(data.odometer_m)
                : t('common.na')
            }
          />
          <Field
            label={t('dvir.detail.fields.engineHours')}
            value={data.engine_hours ?? t('common.na')}
          />
        </dl>
      </Section>

      <Section title={t('dvir.detail.sections.defects')}>
        {(data.defects ?? []).length === 0 ? (
          <p className="text-body-sm text-neutral-600">{t('dvir.detail.defects.empty')}</p>
        ) : (
          <ul className="flex flex-col gap-4">
            {(data.defects ?? []).map((defect: DvirDefect, defectIndex: number) => {
              const name = defect.name ?? t('common.na');
              const photoKeys = defect.photo_keys ?? [];
              return (
                <li
                  key={`${defect.defect_type_id ?? 'defect'}-${defectIndex}`}
                  className="flex flex-col gap-2 border-b border-stroke pb-4 last:border-b-0 last:pb-0"
                >
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="text-body font-medium text-neutral-900">{name}</span>
                    {defect.category ? (
                      <Badge tone="neutral">{t(`enums.defect_category.${defect.category}`)}</Badge>
                    ) : null}
                    {defect.is_critical ? (
                      <Badge tone="error">
                        <span className="inline-flex items-center gap-1">
                          <Icon icon={AlertTriangle} size={14} />
                          {t('dvir.detail.defects.critical')}
                        </span>
                      </Badge>
                    ) : null}
                  </div>

                  {defect.note ? (
                    <p className="text-body-sm text-neutral-600">{defect.note}</p>
                  ) : null}

                  {photoKeys.length > 0 ? (
                    <ul className="flex flex-wrap gap-2">
                      {photoKeys.map((photoKey, photoIndex) => {
                        const src = resolveStorageUrl(photoKey);
                        return (
                          <li key={photoKey}>
                            <button
                              type="button"
                              className="h-20 w-20 overflow-hidden rounded-md border border-stroke bg-neutral-100"
                              aria-label={t('dvir.detail.defects.openPhoto', {
                                index: photoIndex + 1,
                                name,
                              })}
                              onClick={() => setLightbox({ photoKeys, index: photoIndex, name })}
                            >
                              {src ? (
                                <img
                                  src={src}
                                  alt={t('dvir.detail.defects.photoAlt', {
                                    index: photoIndex + 1,
                                    name,
                                  })}
                                  className="h-full w-full object-cover"
                                />
                              ) : (
                                <span className="flex h-full w-full items-center justify-center text-body-sm text-neutral-600">
                                  {photoIndex + 1}
                                </span>
                              )}
                            </button>
                          </li>
                        );
                      })}
                    </ul>
                  ) : null}
                </li>
              );
            })}
          </ul>
        )}
      </Section>

      <Section title={t('dvir.detail.sections.signatures')}>
        <p className="text-body-sm text-neutral-600">{t('dvir.detail.signatures.viewOnly')}</p>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
          <SignatureView
            label={t('dvir.detail.signatures.driver')}
            signatureKey={data.driver_signature_key}
          />
          <SignatureView
            label={t('dvir.detail.signatures.mechanic')}
            signatureKey={data.mechanic_signature_key}
          />
          <SignatureView
            label={t('dvir.detail.signatures.certification')}
            signatureKey={data.certification_signature_key}
          />
        </div>
      </Section>

      <Section title={t('dvir.detail.sections.history')}>
        <DvirStatusHistory report={data} dateFormat={dateFormat} />
      </Section>

      <div>
        <Button variant="ghost" onClick={() => navigate('/dvir')}>
          {t('dvir.actions.back')}
        </Button>
      </div>

      <RecordRepairModal
        open={repairOpen}
        mechanicSignatureKey={data.mechanic_signature_key ?? ''}
        onClose={() => setRepairOpen(false)}
        isPending={repair.isPending}
        onSubmit={(body) => repair.mutateAsync({ id: data.id ?? '', body })}
        onSuccess={() =>
          toast.show({
            variant: 'success',
            message: t('dvir.toast.repairRecorded', { unit: unitLabel }),
          })
        }
      />

      <PhotoLightbox
        open={Boolean(lightbox)}
        onClose={() => setLightbox(undefined)}
        photoKeys={lightbox?.photoKeys ?? []}
        initialIndex={lightbox?.index ?? 0}
        defectName={lightbox?.name ?? ''}
      />
    </div>
  );
}

export default DvirDetailPage;
