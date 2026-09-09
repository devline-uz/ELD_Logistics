/**
 * Unit View + Activities + Diagnostics — `/units/:unitId` (2.2,
 * `docs/tz/07-3-fleet.md` §7.3.2).
 *
 * ⚠️ **Ma'lum cheklov (backend bo'shlig'i, §16-17 ga yozilgan):** spec
 * "Drivers (primary + (co))" maydonini talab qiladi, lekin swagger'da
 * unit uchun joriy tayinlangan haydovchilar ro'yxatini qaytaradigan endpoint
 * yo'q (`Unit` DTO'sida driver maydoni yo'q, `GET /units/{id}/history` faqat
 * audit/assignment **tarixi**ni beradi, joriy holatni emas). Bu yerda
 * "Drivers" bloki `N/A` + "Assign driver" tugmasi bilan ko'rsatiladi; to'liq
 * ro'yxat backend `GET /units/{id}/assignments` (yoki shunga o'xshash)
 * qo'shilgach ulanadi.
 */
import { useMemo, useState, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate, useParams } from 'react-router-dom';

import { useUnit, useUnitDiagnostics, useUnitHistory } from '@/api/queries/units';
import { Breadcrumb } from '@/components/ui/Breadcrumb';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { Tabs } from '@/components/ui/Tabs';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useUnitSystem } from '@/hooks/useUnitSystem';
import { PERM } from '@/lib/permissions';

import { UnitAssignDriverModal } from '../components/UnitAssignDriverModal';

type UnitTab = 'info' | 'activities' | 'diagnostics';

function DetailField({ label, value }: { label: string; value: ReactNode }) {
  const { t } = useTranslation();
  return (
    <div>
      <dt className="text-body-sm text-neutral-600">{label}</dt>
      <dd className="text-body text-neutral-900">{value ?? t('common.na')}</dd>
    </div>
  );
}

export function UnitDetailPage({ tab = 'info' }: { tab?: UnitTab }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { unitId } = useParams<{ unitId: string }>();
  const { formatDate, formatDateTime } = useDateFormat();
  const { formatDistance, formatTemperature } = useUnitSystem();

  const [assignOpen, setAssignOpen] = useState(false);

  const unit = useUnit(unitId);
  const history = useUnitHistory(unitId, {});
  const diagnostics = useUnitDiagnostics(tab === 'diagnostics' ? unitId : undefined);

  const tabs = useMemo(
    () => [
      { id: 'info', label: t('fleet.units.detail.tabs.info') },
      { id: 'activities', label: t('fleet.units.detail.tabs.activities') },
      { id: 'diagnostics', label: t('fleet.units.detail.tabs.diagnostics') },
    ],
    [t],
  );

  if (unit.isLoading) {
    return <Skeleton variant="card" count={4} />;
  }

  if (unit.isError || !unit.data) {
    return (
      <ErrorState
        title={t('errors.notFound')}
        message={t('fleet.units.detail.notFound')}
        onRetry={() => void unit.refetch()}
      />
    );
  }

  const data = unit.data;

  const goToTab = (id: string) => {
    if (id === 'info') navigate(`/units/${unitId}`);
    else navigate(`/units/${unitId}/${id}`);
  };

  return (
    <div className="flex flex-col gap-4">
      <Breadcrumb
        items={[
          { label: t('fleet.units.title'), href: '/units' },
          { label: t('fleet.units.detail.breadcrumb', { unitNumber: data.unit_number }) },
        ]}
      />

      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-h3 font-bold text-neutral-900">
          {t('fleet.units.detail.heading', { unitNumber: data.unit_number })}
        </h1>
        <PermissionGate permission={PERM.unitsAssignDriver}>
          <Button variant="secondary" onClick={() => setAssignOpen(true)}>
            {t('fleet.units.detail.assignDriver')}
          </Button>
        </PermissionGate>
      </div>

      <Tabs
        tabs={tabs}
        activeId={tab}
        onChange={goToTab}
        ariaLabel={t('fleet.units.detail.tabsLabel')}
      />

      {tab === 'info' ? (
        <div id="tabpanel-info" role="tabpanel" aria-labelledby="tab-info" tabIndex={0}>
          <dl className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <DetailField label={t('fleet.units.detail.fields.drivers')} value={t('common.na')} />
            <DetailField
              label={t('fleet.units.detail.fields.eld')}
              value={data.eld_device_serial}
            />
            <DetailField
              label={t('fleet.units.detail.fields.activatedOn')}
              value={formatDate(data.activated_on)}
            />
            <DetailField label={t('fleet.units.detail.fields.vin')} value={data.vin} />
            <DetailField label={t('fleet.units.detail.fields.make')} value={data.make} />
            <DetailField label={t('fleet.units.detail.fields.model')} value={data.model} />
            <DetailField label={t('fleet.units.detail.fields.year')} value={data.year} />
            <DetailField
              label={t('fleet.units.detail.fields.sleeperBerth')}
              value={
                data.sleeper_berth
                  ? t('fleet.units.detail.available')
                  : t('fleet.units.detail.notAvailable')
              }
            />
            <DetailField
              label={t('fleet.units.detail.fields.licensePlate')}
              value={
                data.plate_region
                  ? `${data.license_plate} (${data.plate_region})`
                  : data.license_plate
              }
            />
            <DetailField
              label={t('fleet.units.detail.fields.fuelType')}
              value={data.fuel_type ? t(`fleet.units.fuelTypes.${data.fuel_type}`) : undefined}
            />
            <DetailField label={t('fleet.units.detail.fields.branch')} value={data.branch_name} />
            <DetailField label={t('fleet.units.detail.fields.notes')} value={data.notes} />
            <DetailField
              label={t('fleet.units.detail.fields.status')}
              value={
                <Badge tone={data.status === 'active' ? 'success' : 'neutral'}>
                  {t(`fleet.units.status.${data.status ?? 'inactive'}`)}
                </Badge>
              }
            />
            <DetailField
              label={t('fleet.units.detail.fields.outOfService')}
              value={
                <Badge tone={data.out_of_service ? 'error' : 'success'}>
                  {data.out_of_service ? t('common.boolean.yes') : t('common.boolean.no')}
                </Badge>
              }
            />
          </dl>
        </div>
      ) : null}

      {tab === 'activities' ? (
        <div
          id="tabpanel-activities"
          role="tabpanel"
          aria-labelledby="tab-activities"
          tabIndex={0}
          className="overflow-x-auto rounded-lg border border-stroke"
        >
          <table className="w-full border-collapse text-body-sm">
            <thead className="bg-surface-muted">
              <tr>
                <th scope="col" className="px-3 py-2 text-start font-medium">
                  {t('fleet.units.detail.activities.columns.timestamp')}
                </th>
                <th scope="col" className="px-3 py-2 text-start font-medium">
                  {t('fleet.units.detail.activities.columns.action')}
                </th>
                <th scope="col" className="px-3 py-2 text-start font-medium">
                  {t('fleet.units.detail.activities.columns.changedBy')}
                </th>
                <th scope="col" className="px-3 py-2 text-start font-medium">
                  {t('fleet.units.detail.activities.columns.details')}
                </th>
              </tr>
            </thead>
            <tbody>
              {history.isLoading ? (
                <tr>
                  <td colSpan={4} className="p-4">
                    <Skeleton count={3} />
                  </td>
                </tr>
              ) : history.isError ? (
                <tr>
                  <td colSpan={4} className="p-4">
                    <ErrorState onRetry={() => void history.refetch()} />
                  </td>
                </tr>
              ) : (history.data?.data ?? []).length === 0 ? (
                <tr>
                  <td colSpan={4} className="p-8 text-center text-body text-neutral-600">
                    {t('fleet.units.detail.activities.empty')}
                  </td>
                </tr>
              ) : (
                (history.data?.data ?? []).map((entry) => (
                  <tr key={entry.id} className="border-t border-stroke">
                    <td className="px-3 py-2">{formatDateTime(entry.at)}</td>
                    <td className="px-3 py-2">
                      {t(`fleet.units.detail.activities.actions.${entry.action ?? 'update'}`)}
                    </td>
                    <td className="px-3 py-2">{entry.actor_name ?? t('common.na')}</td>
                    <td className="px-3 py-2">
                      {entry.field
                        ? t('fleet.units.detail.activities.fieldChange', {
                            field: entry.field,
                            oldValue: entry.old_value ?? t('common.na'),
                            newValue: entry.new_value ?? t('common.na'),
                          })
                        : t('common.na')}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      ) : null}

      {tab === 'diagnostics' ? (
        <div
          id="tabpanel-diagnostics"
          role="tabpanel"
          aria-labelledby="tab-diagnostics"
          tabIndex={0}
        >
          <PermissionGate
            permission={PERM.unitsDiagnostics}
            fallback={
              <ErrorState
                title={t('ui.overlay.emptyState.noAccessTitle')}
                message={t('fleet.units.detail.diagnostics.forbidden')}
              />
            }
          >
            {diagnostics.isLoading ? (
              <Skeleton variant="card" count={3} />
            ) : diagnostics.isError || !diagnostics.data ? (
              <ErrorState onRetry={() => void diagnostics.refetch()} />
            ) : (
              <dl className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
                <DetailField
                  label={t('fleet.units.detail.diagnostics.fields.deviceSerial')}
                  value={diagnostics.data.device_serial}
                />
                <DetailField
                  label={t('fleet.units.detail.diagnostics.fields.vendor')}
                  value={diagnostics.data.device_vendor}
                />
                <DetailField
                  label={t('fleet.units.detail.diagnostics.fields.model')}
                  value={diagnostics.data.device_model}
                />
                <DetailField
                  label={t('fleet.units.detail.diagnostics.fields.firmware')}
                  value={diagnostics.data.device_firmware}
                />
                <DetailField
                  label={t('fleet.units.detail.diagnostics.fields.connectionType')}
                  value={diagnostics.data.connection_type}
                />
                <DetailField
                  label={t('fleet.units.detail.diagnostics.fields.connectionState')}
                  value={diagnostics.data.connection_state}
                />
                <DetailField
                  label={t('fleet.units.detail.diagnostics.fields.simPresent')}
                  value={
                    diagnostics.data.sim_present ? t('common.boolean.yes') : t('common.boolean.no')
                  }
                />
                <DetailField
                  label={t('fleet.units.detail.diagnostics.fields.lastSeen')}
                  value={formatDateTime(diagnostics.data.last_seen_at)}
                />
                <DetailField
                  label={t('fleet.units.detail.diagnostics.fields.odometer')}
                  value={formatDistance(diagnostics.data.telemetry?.odometer_m)}
                />
                <DetailField
                  label={t('fleet.units.detail.diagnostics.fields.engineHours')}
                  value={
                    diagnostics.data.telemetry?.engine_hours !== undefined
                      ? diagnostics.data.telemetry.engine_hours
                      : undefined
                  }
                />
                <DetailField
                  label={t('fleet.units.detail.diagnostics.fields.fuel')}
                  value={
                    diagnostics.data.telemetry?.fuel_pct !== undefined
                      ? `${diagnostics.data.telemetry.fuel_pct}%`
                      : undefined
                  }
                />
                <DetailField
                  label={t('fleet.units.detail.diagnostics.fields.coolantTemp')}
                  value={formatTemperature(diagnostics.data.telemetry?.coolant_temp_c)}
                />
                <DetailField
                  label={t('fleet.units.detail.diagnostics.fields.malfunctionCodes')}
                  value={
                    diagnostics.data.malfunction_codes &&
                    diagnostics.data.malfunction_codes.length > 0
                      ? diagnostics.data.malfunction_codes.map((code) => code.code).join(', ')
                      : t('fleet.units.detail.diagnostics.none')
                  }
                />
              </dl>
            )}
          </PermissionGate>
        </div>
      ) : null}

      {assignOpen ? (
        <UnitAssignDriverModal open onClose={() => setAssignOpen(false)} unitId={unitId} />
      ) : null}
    </div>
  );
}

/** `/units/:unitId/activities` — marshrut darajasida alohida komponent (route-helpers `ComponentType`). */
export function UnitActivitiesPage() {
  return <UnitDetailPage tab="activities" />;
}

/** `/units/:unitId/diagnostics` — marshrut darajasida alohida komponent. */
export function UnitDiagnosticsPage() {
  return <UnitDetailPage tab="diagnostics" />;
}

export default UnitDetailPage;
