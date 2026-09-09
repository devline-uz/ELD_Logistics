/**
 * Maintenance reja **View** ekrani — `/maintenance/schedules/:id` (5.9, §7.6).
 *
 * `View (single)`: `Unit # · Schedule Name · Maintenance type · Last service
 * value · Maintenance Frequency · Next Frequency · Remind before · Alert Type ·
 * Delivery Method · Notify co-driver · Notes`.
 * `View (multiple)`: yuqoridagilar + `UNITS` jadvali
 * (`Unit · Last service value · Next Frequency · Remaining`) va guruh
 * ekraniga havola.
 *
 * Barcha son qiymatlari `useIntervalFormat` orqali — foydalanuvchi birlik
 * tizimida, yorliq bilan (5.8).
 */
import { useTranslation } from 'react-i18next';
import { Link, useParams } from 'react-router-dom';

import { useMaintenanceDue, useMaintenanceSchedule } from '@/api/queries/maintenance';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { Badge } from '@/components/ui/Badge';
import { Breadcrumb } from '@/components/ui/Breadcrumb';
import { Card } from '@/components/ui/Card';

import { FieldList } from '../components/FieldList';
import { useIntervalFormat } from '../useIntervalFormat';
import { NA } from '@/lib/format';

export function MaintenanceScheduleViewPage() {
  const { t } = useTranslation();
  const { id } = useParams<{ id: string }>();
  const { formatInterval } = useIntervalFormat();

  const schedule = useMaintenanceSchedule(id);
  const rows = useMaintenanceDue(id ? { schedule_id: id, per_page: 50 } : { per_page: 50 });

  const units = rows.data?.data ?? [];
  const isMultiple = units.length > 1;
  const data = schedule.data;

  if (schedule.isLoading) {
    return <Skeleton variant="card" />;
  }

  if (schedule.isError || !data) {
    return <ErrorState message={schedule.error?.message} onRetry={() => void schedule.refetch()} />;
  }

  const single = units[0];

  return (
    <div className="flex flex-col gap-4">
      <Breadcrumb
        items={[
          { label: t('maintenance.title'), href: '/maintenance/schedules' },
          { label: t('maintenance.tabs.schedules'), href: '/maintenance/schedules' },
          { label: data.name ?? t('maintenance.view.title') },
        ]}
      />

      <h1 className="text-h3 font-bold text-neutral-900">{data.name}</h1>

      <Card title={t('maintenance.view.title')}>
        <FieldList
          items={[
            {
              label: t('maintenance.view.fields.unit'),
              value: isMultiple ? (
                <Link
                  to={`/maintenance/schedules/${encodeURIComponent(id ?? '')}/units`}
                  className="text-primary hover:underline"
                >
                  {t('maintenance.schedules.unitCount', { count: units.length })}
                </Link>
              ) : (
                (single?.unit_number ?? NA)
              ),
            },
            { label: t('maintenance.view.fields.name'), value: data.name ?? NA },
            {
              label: t('maintenance.view.fields.type'),
              value: data.type ? t(`enums.maintenance_type.${data.type}`) : NA,
            },
            {
              label: t('maintenance.view.fields.lastServiceValue'),
              value: isMultiple
                ? NA
                : formatInterval(single?.last_service_value, data.interval_unit),
            },
            {
              label: t('maintenance.view.fields.interval'),
              value: formatInterval(data.interval_value, data.interval_unit),
            },
            {
              label: t('maintenance.view.fields.nextFrequency'),
              value: isMultiple ? NA : formatInterval(single?.next_due_value, data.interval_unit),
            },
            {
              label: t('maintenance.view.fields.remindBefore'),
              value: formatInterval(data.reminder_before_value, data.interval_unit),
            },
            {
              label: t('maintenance.view.fields.alertType'),
              value: data.alert_type ? t(`enums.maintenance_alert_type.${data.alert_type}`) : NA,
            },
            {
              label: t('maintenance.view.fields.deliveryMethods'),
              value:
                data.delivery_methods && data.delivery_methods.length > 0
                  ? data.delivery_methods
                      .map((method) => t(`enums.maintenance_delivery_method.${method}`))
                      .join(', ')
                  : NA,
            },
            {
              label: t('maintenance.view.fields.notifyCoDriver'),
              value: data.notify_co_driver ? t('maintenance.view.yes') : t('maintenance.view.no'),
            },
            {
              label: t('maintenance.view.fields.status'),
              value: (
                <Badge tone={data.status === 'active' ? 'success' : 'neutral'}>
                  {t(`enums.maintenance_schedule_status.${data.status ?? 'inactive'}`)}
                </Badge>
              ),
            },
            { label: t('maintenance.view.fields.notes'), value: data.notes ?? NA },
          ]}
        />
      </Card>

      {isMultiple ? (
        <Card
          title={t('maintenance.view.unitsSectionTitle')}
          actions={
            <Link
              to={`/maintenance/schedules/${encodeURIComponent(id ?? '')}/units`}
              className="text-body-sm text-primary hover:underline"
            >
              {t('maintenance.view.openUnits')}
            </Link>
          }
        >
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-body">
              <thead className="bg-surface-muted">
                <tr>
                  <th
                    scope="col"
                    className="px-4 py-3 text-start text-body-sm font-medium uppercase tracking-wide text-neutral-600"
                  >
                    {t('maintenance.view.unitsColumns.unit')}
                  </th>
                  <th
                    scope="col"
                    className="px-4 py-3 text-start text-body-sm font-medium uppercase tracking-wide text-neutral-600"
                  >
                    {t('maintenance.view.unitsColumns.lastServiceValue')}
                  </th>
                  <th
                    scope="col"
                    className="px-4 py-3 text-start text-body-sm font-medium uppercase tracking-wide text-neutral-600"
                  >
                    {t('maintenance.view.unitsColumns.nextFrequency')}
                  </th>
                  <th
                    scope="col"
                    className="px-4 py-3 text-start text-body-sm font-medium uppercase tracking-wide text-neutral-600"
                  >
                    {t('maintenance.view.unitsColumns.remaining')}
                  </th>
                </tr>
              </thead>
              <tbody>
                {units.map((row) => (
                  <tr key={row.id} className="border-t border-stroke">
                    <td className="px-4 py-3">{row.unit_number ?? NA}</td>
                    <td className="px-4 py-3">
                      {formatInterval(row.last_service_value, row.interval_unit)}
                    </td>
                    <td className="px-4 py-3">
                      {formatInterval(row.next_due_value, row.interval_unit)}
                    </td>
                    <td className={`px-4 py-3 ${row.overdue ? 'text-error-dark' : ''}`}>
                      {formatInterval(row.remaining, row.interval_unit)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      ) : null}
    </div>
  );
}

export default MaintenanceScheduleViewPage;
