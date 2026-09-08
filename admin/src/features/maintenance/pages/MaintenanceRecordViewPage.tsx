/**
 * History detali — `/maintenance/history/:scheduleUnitId` (5.11, §7.6).
 *
 * ⚠️ Backendda `GET /maintenance-records/{id}` **yo'q** (faqat ro'yxat).
 * Shu sababli marshrut `schedule_unit_id` bo'yicha quriladi:
 * `GET /maintenance-schedule-units/{id}` — reja/unit konteksti (deep-link
 * ishlaydi), moliyaviy maydonlar esa `GET /maintenance-records?unit_id=` dan
 * o'sha qator bo'yicha olinadi. §16 nomzodi sifatida hisobotda qayd etilgan.
 *
 * Pastda **F113** — `PRE-TRIP INSPECTION` / `POST-TRIP INSPECTION` bloklari
 * o'sha unit va sanadagi DVIR'lar bilan to'ldiriladi.
 */
import { useTranslation } from 'react-i18next';
import { useParams } from 'react-router-dom';

import { useMaintenanceRecordsList, useMaintenanceScheduleUnit } from '@/api/queries/maintenance';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { Badge } from '@/components/ui/Badge';
import { Breadcrumb } from '@/components/ui/Breadcrumb';
import { Card } from '@/components/ui/Card';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useUnitSystem } from '@/hooks/useUnitSystem';

import { FieldList } from '../components/FieldList';
import { InspectionBlock } from '../components/InspectionBlock';
import { useIntervalFormat } from '../useIntervalFormat';
import { NA } from '@/lib/format';

export function MaintenanceRecordViewPage() {
  const { t } = useTranslation();
  const { id } = useParams<{ id: string }>();
  const { formatDate } = useDateFormat();
  const { formatDistance } = useUnitSystem();
  const { formatInterval } = useIntervalFormat();

  const scheduleUnit = useMaintenanceScheduleUnit(id);
  const unitId = scheduleUnit.data?.unit_id;

  const records = useMaintenanceRecordsList(unitId ? { unit_id: unitId, per_page: 50 } : {});
  const record = records.data?.data?.find((row) => row.schedule_unit_id === id);

  if (scheduleUnit.isLoading) {
    return <Skeleton variant="card" />;
  }

  if (scheduleUnit.isError || !scheduleUnit.data) {
    return (
      <ErrorState
        message={scheduleUnit.error?.message ?? t('maintenance.record.notFound')}
        onRetry={() => void scheduleUnit.refetch()}
      />
    );
  }

  const row = scheduleUnit.data;
  const performedAt = record?.performed_at ?? row.last_service_at;

  return (
    <div className="flex flex-col gap-4">
      <Breadcrumb
        items={[
          { label: t('maintenance.title'), href: '/maintenance/schedules' },
          { label: t('maintenance.tabs.history'), href: '/maintenance/history' },
          { label: row.unit_number ?? t('maintenance.record.title') },
        ]}
      />

      <h1 className="text-h3 font-bold text-neutral-900">{t('maintenance.record.title')}</h1>

      <Card title={t('maintenance.record.title')}>
        <FieldList
          items={[
            { label: t('maintenance.record.fields.unit'), value: row.unit_number ?? NA },
            {
              label: t('maintenance.record.fields.scheduleName'),
              value: row.schedule_name ?? NA,
            },
            {
              label: t('maintenance.record.fields.type'),
              value: row.schedule_type ? t(`enums.maintenance_type.${row.schedule_type}`) : NA,
            },
            {
              label: t('maintenance.record.fields.status'),
              value: (
                <Badge
                  tone={
                    (record?.status ?? row.status) === 'completed'
                      ? 'success'
                      : (record?.status ?? row.status) === 'cancelled'
                        ? 'neutral'
                        : 'warning'
                  }
                >
                  {t(
                    `enums.maintenance_unit_status.${record?.status ?? row.status ?? 'scheduled'}`,
                  )}
                </Badge>
              ),
            },
            {
              label: t('maintenance.record.fields.performedAt'),
              value: performedAt ? formatDate(performedAt) : NA,
            },
            { label: t('maintenance.record.fields.invoiceNo'), value: record?.invoice_no ?? NA },
            { label: t('maintenance.record.fields.vendor'), value: record?.vendor ?? NA },
            {
              label: t('maintenance.record.fields.cost'),
              value:
                typeof record?.cost === 'number'
                  ? record.cost.toLocaleString('en-US', {
                      style: 'currency',
                      currency: record.currency ?? 'USD',
                    })
                  : NA,
            },
            {
              label: t('maintenance.record.fields.odometer'),
              value: formatDistance(record?.odometer_m ?? row.odometer_m),
            },
            {
              label: t('maintenance.record.fields.engineHours'),
              value:
                typeof (record?.engine_hours ?? row.engine_hours) === 'number'
                  ? t('maintenance.units.engineHours', {
                      count: record?.engine_hours ?? row.engine_hours ?? 0,
                    })
                  : NA,
            },
            {
              label: t('maintenance.view.fields.interval'),
              value: formatInterval(row.interval_value, row.interval_unit),
            },
            {
              label: t('maintenance.record.fields.attachment'),
              value: record?.invoice_key
                ? t('maintenance.history.attachmentPresent')
                : t('maintenance.history.attachmentNone'),
            },
            {
              label: t('maintenance.record.fields.cancelledReason'),
              value: record?.cancelled_reason ?? row.cancelled_reason ?? NA,
            },
            { label: t('maintenance.record.fields.notes'), value: record?.notes ?? NA },
          ]}
        />
      </Card>

      <InspectionBlock type="pre_trip" unitId={unitId} performedAt={performedAt} />
      <InspectionBlock type="post_trip" unitId={unitId} performedAt={performedAt} />
    </div>
  );
}

export default MaintenanceRecordViewPage;
