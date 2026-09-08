/**
 * Inspection logs — `/inspection` (8.11, `docs/tz/07-9-chat-support-
 * audit.md` §7.12, `[MAY]`, 🎨 dizayn yo'q).
 *
 * `GET /inspection/logs` bitta haydovchi + bitta sana langari (7 kun+bugun
 * oynasi) uchun hisobot qaytaradi, ro'yxat/pagination emas — haydovchi
 * tanlanmaguncha jadval o'rnida "Select driver first" bo'sh holati
 * ko'rsatiladi (fe-screens §5, "Logs By Driver" patterni,
 * `useInspectionLogsList` `enabled: Boolean(driverId)`).
 *
 * Yozuv amali — faqat "Email report" (`POST /inspection/email`,
 * `inspection.email`), spetsifikatsiyadagi «hisobotni qayta yuborish»ga mos.
 * `POST /inspection/transfer` hooki `api/queries/inspection.ts` da mavjud,
 * lekin natija (`file_key`) uchun yuklab olish oqimi speclanmagani sababli
 * bu ekranga ulanmagan (hisobot, D39).
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

import { useDriversList } from '@/api/queries/drivers';
import { useInspectionLogsList } from '@/api/queries/inspection';
import type { DailyLogDetail } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { ListScreen } from '@/components/data/ListScreen';
import { Button } from '@/components/ui/Button';
import { DatePicker } from '@/components/ui/DatePicker';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { Select, type SelectOption } from '@/components/ui/Select';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';
import { useUnitSystem } from '@/hooks/useUnitSystem';
import { formatPersonName, NA, toDateParam } from '@/lib/format';
import { PERM } from '@/lib/permissions';

import { InspectionEmailModal } from '../components/InspectionEmailModal';
import { buildInspectionLogColumns } from '../components/inspectionLogColumns';

function isoDate(date: Date): string {
  return toDateParam(date);
}

export function InspectionLogsPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const dateFormat = useDateFormat();
  const unitSystem = useUnitSystem();
  const listParams = useListParams();

  const driverId = listParams.filters.driver_id || undefined;
  const date = listParams.filters.date || undefined;
  const [emailModalOpen, setEmailModalOpen] = useState(false);

  const drivers = useDriversList({ per_page: 50 });
  const driverOptions: SelectOption[] = useMemo(
    () =>
      (drivers.data?.data ?? []).map((driver) => ({
        value: driver.id ?? '',
        label: formatPersonName(driver, driver.id ?? ''),
      })),
    [drivers.data],
  );

  const report = useInspectionLogsList({ driver_id: driverId, date });
  const days = report.data?.days ?? [];

  const columns = buildInspectionLogColumns(t, { dateFormat, unitSystem });

  const openLog = (day: DailyLogDetail) => {
    if (day.id) navigate(`/logs/view/${encodeURIComponent(day.id)}`);
  };

  const driverName = report.data?.driver_name ?? NA;

  return (
    <>
      <ListScreen
        title={t('inspection.list.title')}
        actions={
          driverId ? (
            <PermissionGate permission={PERM.inspectionEmail}>
              <Button variant="secondary" onClick={() => setEmailModalOpen(true)}>
                {t('inspection.list.actions.emailReport')}
              </Button>
            </PermissionGate>
          ) : null
        }
        filtersBar={
          <div className="flex flex-wrap items-end gap-3">
            <Select
              label={t('inspection.list.filters.driver')}
              placeholder={t('inspection.list.filters.driverPlaceholder')}
              searchable
              clearable
              loading={drivers.isLoading}
              value={driverId ?? null}
              onChange={(value) => listParams.setFilter('driver_id', value ?? undefined)}
              options={driverOptions}
              className="w-64"
            />
            <DatePicker
              label={t('inspection.list.filters.date')}
              value={date ? new Date(date) : null}
              onChange={(value) => listParams.setFilter('date', value ? isoDate(value) : undefined)}
              className="w-48"
            />
          </div>
        }
        table={
          !driverId ? (
            <div className="rounded-lg border border-stroke bg-surface px-6 py-16 text-center">
              <h3 className="text-body-lg font-semibold text-neutral-900">
                {t('inspection.list.empty.selectDriverTitle')}
              </h3>
              <p className="mt-2 text-body text-neutral-500">
                {t('inspection.list.empty.selectDriverDescription')}
              </p>
            </div>
          ) : (
            <DataTable
              tableId="inspection-logs"
              columns={columns}
              data={days}
              isLoading={report.isLoading}
              isError={report.isError}
              errorMessage={report.error?.message}
              onRetry={() => void report.refetch()}
              emptyTitle={t('inspection.list.empty.title')}
              emptyDescription={t('inspection.list.empty.description')}
              onRowClick={openLog}
              getRowId={(day, index) => day.id ?? String(index)}
            />
          )
        }
      />

      {driverId ? (
        <InspectionEmailModal
          open={emailModalOpen}
          onClose={() => setEmailModalOpen(false)}
          driverId={driverId}
          driverName={driverName}
          date={date}
        />
      ) : null}
    </>
  );
}

export default InspectionLogsPage;
