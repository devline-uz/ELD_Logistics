/**
 * Driver View — `/drivers/:driverId` (2.4, TZ 7.3.5).
 *
 * Tablar: Information (+ Co-Drivers bloki) · Activities · Daily logs.
 *
 * `GET /drivers/{id}` haqiqiy tarmoq so'rovi (`drivers.read`) — Users/Roles
 * dan farqli, bu endpoint swaggerda bor. Cross-tenant/o'chirilgan haydovchi
 * → backend `404` qaytaradi, `useDriver` `ApiError` bilan `isError` bo'ladi.
 */
import { useState, type ReactNode } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';

import { useDriver, useDriverActivities, useDriverUpdate } from '@/api/queries/drivers';
import { Badge } from '@/components/ui/Badge';
import { Breadcrumb } from '@/components/ui/Breadcrumb';
import { Button } from '@/components/ui/Button';
import { EmptyState } from '@/components/feedback/EmptyState';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { Tabs } from '@/components/ui/Tabs';
import { useDateFormat } from '@/hooks/useDateFormat';

import { CoDriversPanel } from '../components/CoDriversPanel';
import { DriverFormModal } from '../components/DriverFormModal';
import { LicenseReveal } from '../components/LicenseReveal';
import { useDriverDailyLogs } from '../hooks/useDriverDailyLogs';
import { useToast } from '@/components/feedback/toast-context';
import type { DriverUpdate } from '@/api/types';

type DetailTab = 'information' | 'activities' | 'dailyLogs';

function InfoRow({ label, value }: { label: string; value: ReactNode }) {
  return (
    <div className="flex flex-col gap-0.5 py-2">
      <span className="text-body-sm text-neutral-500">{label}</span>
      <span className="text-body text-neutral-900">{value}</span>
    </div>
  );
}

export function DriverDetailPage() {
  const { t } = useTranslation();
  const { formatDateTime, formatDate } = useDateFormat();
  const { driverId } = useParams<{ driverId: string }>();
  const navigate = useNavigate();
  const toast = useToast();

  const [tab, setTab] = useState<DetailTab>('information');
  const [editOpen, setEditOpen] = useState(false);

  const driverQuery = useDriver(driverId);
  const driver = driverQuery.data;
  const updateMutation = useDriverUpdate();

  const activitiesQuery = useDriverActivities(tab === 'activities' ? driverId : undefined);
  const dailyLogsQuery = useDriverDailyLogs(tab === 'dailyLogs' ? driverId : undefined);

  if (!driverId) {
    return <ErrorState message={t('common.states.notFound')} />;
  }

  if (driverQuery.isLoading) {
    return (
      <div className="flex flex-col gap-4">
        <Skeleton variant="text" count={3} />
        <Skeleton variant="card" />
      </div>
    );
  }

  if (driverQuery.isError || !driver) {
    const isNotFound = driverQuery.error?.status === 404;
    return (
      <ErrorState
        title={isNotFound ? t('common.states.notFound') : t('common.states.error')}
        message={isNotFound ? t('fleetDrivers.detail.notFound') : driverQuery.error?.message}
        onRetry={isNotFound ? () => navigate('/drivers') : () => void driverQuery.refetch()}
        retryLabel={isNotFound ? t('fleetDrivers.detail.backToList') : undefined}
      />
    );
  }

  const fullName = `${driver.first_name ?? ''} ${driver.last_name ?? ''}`.trim();

  return (
    <div className="flex flex-col gap-4">
      <Breadcrumb
        items={[
          { label: t('pages.drivers.title'), href: '/drivers' },
          { label: fullName || t('pages.driverDetail.title') },
        ]}
      />

      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <h1 className="text-h3 font-bold text-neutral-900">{fullName}</h1>
          <Badge
            tone={
              driver.status === 'active'
                ? 'success'
                : driver.status === 'invited'
                  ? 'warning'
                  : 'neutral'
            }
          >
            {t(`enums.driver_status.${driver.status}`, { defaultValue: driver.status ?? '' })}
          </Badge>
        </div>
        <Button variant="secondary" onClick={() => setEditOpen(true)}>
          {t('common.actions.edit')}
        </Button>
      </div>

      <Tabs
        ariaLabel={t('fleetDrivers.detail.tabsLabel')}
        idPrefix="driver-detail"
        activeId={tab}
        onChange={(id) => setTab(id as DetailTab)}
        tabs={[
          { id: 'information', label: t('fleetDrivers.detail.tabs.information') },
          { id: 'activities', label: t('fleetDrivers.detail.tabs.activities') },
          { id: 'dailyLogs', label: t('fleetDrivers.detail.tabs.dailyLogs') },
        ]}
      />

      {tab === 'information' ? (
        <div className="flex flex-col gap-6">
          <div className="grid grid-cols-1 gap-x-6 gap-y-1 rounded-lg border border-stroke p-4 sm:grid-cols-3">
            <InfoRow label={t('fleetDrivers.form.username')} value={driver.username ?? '—'} />
            <InfoRow label={t('fleetDrivers.form.email')} value={driver.email ?? '—'} />
            <InfoRow label={t('fleetDrivers.form.phone')} value={driver.phone ?? '—'} />
            <InfoRow
              label={t('fleetDrivers.form.licenseNo')}
              value={<LicenseReveal driverId={driverId} maskedValue={driver.license_no_masked} />}
            />
            <InfoRow
              label={t('fleetDrivers.form.licenseRegion')}
              value={driver.license_region ?? '—'}
            />
            <InfoRow
              label={t('fleetDrivers.form.defaultUnit')}
              value={driver.default_unit_number ?? '—'}
            />
            <InfoRow
              label={t('fleetDrivers.form.fleetManager')}
              value={driver.fleet_manager_name ?? '—'}
            />
            <InfoRow
              label={t('fleetDrivers.form.homeTerminal')}
              value={driver.home_terminal ?? '—'}
            />
            <InfoRow
              label={t('fleetDrivers.columns.activatedOn')}
              value={formatDate(driver.activated_on)}
            />
          </div>

          <CoDriversPanel driverId={driverId} />
        </div>
      ) : null}

      {tab === 'activities' ? (
        activitiesQuery.isLoading ? (
          <Skeleton variant="table-row" count={5} />
        ) : activitiesQuery.isError ? (
          <ErrorState
            message={activitiesQuery.error?.message}
            onRetry={() => void activitiesQuery.refetch()}
          />
        ) : (activitiesQuery.data?.data ?? []).length === 0 ? (
          <EmptyState
            title={t('fleetDrivers.detail.activitiesEmptyTitle')}
            description={t('fleetDrivers.detail.activitiesEmptyDescription')}
          />
        ) : (
          <div className="overflow-x-auto rounded-lg border border-stroke">
            <table className="w-full border-collapse text-body">
              <thead className="bg-surface-muted">
                <tr>
                  <th
                    scope="col"
                    className="px-4 py-3 text-start text-body-sm font-medium uppercase text-neutral-500"
                  >
                    {t('fleetDrivers.detail.activitiesColumns.timestamp')}
                  </th>
                  <th
                    scope="col"
                    className="px-4 py-3 text-start text-body-sm font-medium uppercase text-neutral-500"
                  >
                    {t('fleetDrivers.detail.activitiesColumns.editedBy')}
                  </th>
                  <th
                    scope="col"
                    className="px-4 py-3 text-start text-body-sm font-medium uppercase text-neutral-500"
                  >
                    {t('fleetDrivers.detail.activitiesColumns.activity')}
                  </th>
                </tr>
              </thead>
              <tbody>
                {(activitiesQuery.data?.data ?? []).map((activity) => (
                  <tr key={activity.id} className="border-t border-stroke">
                    <td className="px-4 py-3">{formatDateTime(activity.occurred_at)}</td>
                    <td className="px-4 py-3">{activity.actor_id ?? '—'}</td>
                    <td className="px-4 py-3">
                      {activity.field
                        ? t('fleetDrivers.detail.activitySummary', {
                            field: activity.field,
                            oldValue: activity.old_value ?? '—',
                            newValue: activity.new_value ?? '—',
                          })
                        : activity.action}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )
      ) : null}

      {tab === 'dailyLogs' ? (
        dailyLogsQuery.isLoading ? (
          <Skeleton variant="table-row" count={5} />
        ) : dailyLogsQuery.isError ? (
          <ErrorState
            message={dailyLogsQuery.error?.message}
            onRetry={() => void dailyLogsQuery.refetch()}
          />
        ) : (dailyLogsQuery.data?.data ?? []).length === 0 ? (
          <EmptyState
            title={t('fleetDrivers.detail.dailyLogsEmptyTitle')}
            description={t('fleetDrivers.detail.dailyLogsEmptyDescription')}
          />
        ) : (
          <div className="overflow-x-auto rounded-lg border border-stroke">
            <table className="w-full border-collapse text-body">
              <thead className="bg-surface-muted">
                <tr>
                  <th
                    scope="col"
                    className="px-4 py-3 text-start text-body-sm font-medium uppercase text-neutral-500"
                  >
                    {t('fleetDrivers.detail.dailyLogsColumns.date')}
                  </th>
                  <th
                    scope="col"
                    className="px-4 py-3 text-start text-body-sm font-medium uppercase text-neutral-500"
                  >
                    {t('fleetDrivers.detail.dailyLogsColumns.certification')}
                  </th>
                  <th
                    scope="col"
                    className="px-4 py-3 text-start text-body-sm font-medium uppercase text-neutral-500"
                  >
                    {t('fleetDrivers.detail.dailyLogsColumns.coDriver')}
                  </th>
                  <th
                    scope="col"
                    className="px-4 py-3 text-start text-body-sm font-medium uppercase text-neutral-500"
                  >
                    {t('fleetDrivers.detail.dailyLogsColumns.action')}
                  </th>
                </tr>
              </thead>
              <tbody>
                {(dailyLogsQuery.data?.data ?? []).map((log) => (
                  <tr key={log.id} className="border-t border-stroke">
                    <td className="px-4 py-3">{formatDate(log.log_date)}</td>
                    <td className="px-4 py-3">
                      <Badge
                        tone={
                          log.certification_status === 'certified'
                            ? 'success'
                            : log.certification_status === 'needs_recertify'
                              ? 'warning'
                              : 'neutral'
                        }
                      >
                        {t(`fleetDrivers.detail.certificationStatus.${log.certification_status}`, {
                          defaultValue: log.certification_status ?? '',
                        })}
                      </Badge>
                    </td>
                    <td className="px-4 py-3">
                      {log.co_driver_name ?? t('common.states.notAvailable')}
                    </td>
                    <td className="px-4 py-3">
                      <Link
                        className="text-body-sm font-medium text-primary hover:underline"
                        to={`/logs/by-driver?driver_id=${driverId}&date=${log.log_date ?? ''}`}
                      >
                        {t('fleetDrivers.detail.viewLog')}
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )
      ) : null}

      {editOpen ? (
        <DriverFormModal
          open={editOpen}
          onClose={() => setEditOpen(false)}
          driver={driver}
          submitting={updateMutation.isPending}
          onSubmitCreate={() => Promise.resolve(undefined)}
          onSubmitUpdate={async (body: DriverUpdate) => {
            if (!driver.id) return;
            await updateMutation.mutateAsync({ id: driver.id, body });
            toast.show({ variant: 'success', message: t('fleetDrivers.toast.updated') });
          }}
        />
      ) : null}
    </div>
  );
}

export default DriverDetailPage;
