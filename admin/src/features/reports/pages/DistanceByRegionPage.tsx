/**
 * Distance by Region / IFTA — `/reports/distance-by-region` (Bosqich 6.3, §7.8.2).
 *
 * F122: ekran nomi `regulation_profile`ga bog'liq (`useProfileLabel`) — `us_fmcsa` →
 * "IFTA Report", boshqa 6 profil → "Distance by Region".
 * F123: "5-kunda tayyor" eslatmasi ko'rsatilmaydi — hisobot kunlik agregatdan darhol keladi.
 *
 * `GET /reports/distance-by-region?quarter*&year*&mode&unit_id` (`reports.read`). Tablar
 * `Units`(`mode=regions_and_units`)/`Regions`(`mode=regions_only`) — URL'da saqlanadi.
 * `Region` filtri backendda yo'q (D31.3) — mavjud qatorlar orasida **klient tomonida**
 * qo'llaniladi.
 */
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';

import { useReportsDistanceByRegion } from '@/api/queries/reports';
import type { ReportsDistanceByRegionParams } from '@/api/types';
import { ListScreen } from '@/components/data/ListScreen';
import { Button } from '@/components/ui/Button';
import { KpiCard } from '@/components/ui/KpiCard';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { Select, type SelectOption } from '@/components/ui/Select';
import { useListParams } from '@/hooks/useListParams';
import { useUnitSystem } from '@/hooks/useUnitSystem';
import { useWriteGuard } from '@/hooks/useWriteGuard';
import { PERM } from '@/lib/permissions';
import { useProfileLabel } from '@/lib/profileLabel';
import { useCompanyStore } from '@/store/company-store';

import {
  DistanceByRegionTable,
  type DistanceReportMode,
} from '../components/DistanceByRegionTable';
import { DistanceReportGenerateModal } from '../components/DistanceReportGenerateModal';
import { buildYearOptions, currentQuarter, QUARTER_OPTIONS } from '../lib/reportFilters';
import { useUnitOptions } from '../lib/useEntityOptions';

export function DistanceByRegionPage() {
  const { t } = useTranslation();
  const listParams = useListParams();
  const writeGuard = useWriteGuard();
  const { formatDistance } = useUnitSystem();
  const companyRegion = useCompanyStore((state) => state.company.region);
  const screenName = useProfileLabel('reports.distanceByRegion.screenName');
  const [generateOpen, setGenerateOpen] = useState(false);

  const mode: DistanceReportMode =
    listParams.filters.tab === 'regions' ? 'regions_only' : 'regions_and_units';
  const quarter = Number(listParams.filters.quarter) || currentQuarter();
  const year = Number(listParams.filters.year) || new Date().getFullYear();
  const regionFilter = listParams.filters.region || undefined;
  const unitFilter = listParams.filters.unit_id || undefined;

  const units = useUnitOptions();
  const vinByUnitId = useMemo(() => {
    const map = new Map<string, string | null | undefined>();
    for (const unit of units.data) {
      if (unit.id) map.set(unit.id, unit.vin);
    }
    return map;
  }, [units.data]);

  const queryParams = useMemo<ReportsDistanceByRegionParams>(
    () => ({ quarter, year, mode, unit_id: mode === 'regions_and_units' ? unitFilter : undefined }),
    [quarter, year, mode, unitFilter],
  );

  const report = useReportsDistanceByRegion(queryParams);

  const rows = useMemo(() => report.data?.data ?? [], [report.data]);
  const regionOptions: SelectOption[] = useMemo(() => {
    const seen = new Map<string, string>();
    for (const row of rows) {
      if (row.region_code) seen.set(row.region_code, row.region_name ?? row.region_code);
    }
    return Array.from(seen.entries()).map(([value, label]) => ({ value, label }));
  }, [rows]);

  const filteredRows = useMemo(
    () => (regionFilter ? rows.filter((row) => row.region_code === regionFilter) : rows),
    [rows, regionFilter],
  );

  const rowsWithVin = useMemo(
    () =>
      filteredRows.map((row) => ({
        ...row,
        vin: row.unit_id ? vinByUnitId.get(row.unit_id) : undefined,
      })),
    [filteredRows, vinByUnitId],
  );

  // D31.6 — backendda "home jurisdiction" bayrog'i yo'q; `company.region` bilan
  // qatorning `country`sini solishtirib in/out-of-region hisoblanadi (taxmin, registry D31).
  const { inRegionM, outOfRegionM } = useMemo(() => {
    let inRegion = 0;
    let outOfRegion = 0;
    for (const row of filteredRows) {
      const distance = row.distance_m ?? 0;
      if (companyRegion && row.country === companyRegion) inRegion += distance;
      else outOfRegion += distance;
    }
    return { inRegionM: inRegion, outOfRegionM: outOfRegion };
  }, [filteredRows, companyRegion]);

  const yearOptions = useMemo(() => buildYearOptions(), []);
  const hasActiveFilters = Boolean(regionFilter || unitFilter);

  return (
    <div data-print-root className="flex flex-col gap-4">
      <ListScreen
        title={screenName}
        tabs={[
          { key: 'units', label: t('reports.distanceByRegion.tabs.units') },
          { key: 'regions', label: t('reports.distanceByRegion.tabs.regions') },
        ]}
        activeTab={mode === 'regions_only' ? 'regions' : 'units'}
        onTabChange={(key) => listParams.setFilter('tab', key)}
        actions={
          <PermissionGate permission={PERM.reportsExport}>
            <Button
              onClick={() => setGenerateOpen(true)}
              disabled={!writeGuard.canWrite(PERM.reportsExport)}
              title={writeGuard.disabledReason(PERM.reportsExport)}
            >
              {t('reports.distanceByRegion.actions.generate')}
            </Button>
          </PermissionGate>
        }
        filtersBar={
          <div className="flex flex-col gap-3">
            <div className="grid grid-cols-2 gap-4 sm:grid-cols-4 sm:max-w-2xl">
              <KpiCard
                label={t('reports.distanceByRegion.kpi.inRegion')}
                value={formatDistance(inRegionM)}
                tone="success"
                loading={report.isLoading}
              />
              <KpiCard
                label={t('reports.distanceByRegion.kpi.outOfRegion')}
                value={formatDistance(outOfRegionM)}
                tone="warning"
                loading={report.isLoading}
              />
              <KpiCard
                label={t('reports.distanceByRegion.kpi.total')}
                value={formatDistance(inRegionM + outOfRegionM)}
                tone="primary"
                loading={report.isLoading}
              />
            </div>

            <div className="flex flex-wrap items-end gap-3">
              <Select
                label={t('reports.distanceByRegion.filters.year')}
                required
                value={String(year)}
                onChange={(value) => listParams.setFilter('year', value ?? undefined)}
                options={yearOptions}
                className="w-32"
              />
              <Select
                label={t('reports.distanceByRegion.filters.quarter')}
                required
                value={String(quarter)}
                onChange={(value) => listParams.setFilter('quarter', value ?? undefined)}
                options={QUARTER_OPTIONS}
                className="w-24"
              />
              <Select
                label={t('reports.distanceByRegion.filters.region')}
                placeholder={t('reports.distanceByRegion.filters.regionPlaceholder')}
                clearable
                value={regionFilter ?? null}
                onChange={(value) => listParams.setFilter('region', value ?? undefined)}
                options={regionOptions}
                className="w-48"
              />
              {mode === 'regions_and_units' ? (
                <Select
                  label={t('reports.distanceByRegion.filters.unit')}
                  placeholder={t('reports.distanceByRegion.filters.unitPlaceholder')}
                  searchable
                  clearable
                  loading={units.isLoading}
                  value={unitFilter ?? null}
                  onChange={(value) => listParams.setFilter('unit_id', value ?? undefined)}
                  options={units.options}
                  className="w-48"
                />
              ) : null}
            </div>
          </div>
        }
        table={
          <DistanceByRegionTable
            mode={mode}
            data={rowsWithVin}
            isLoading={report.isLoading}
            isError={report.isError}
            errorMessage={report.error?.message}
            onRetry={() => void report.refetch()}
            emptyDescription={
              hasActiveFilters
                ? t('reports.distanceByRegion.empty.filteredDescription')
                : t('reports.distanceByRegion.empty.description')
            }
            onClearFilters={
              hasActiveFilters
                ? () => listParams.setFilters({ region: undefined, unit_id: undefined })
                : undefined
            }
          />
        }
      />

      <DistanceReportGenerateModal
        open={generateOpen}
        onClose={() => setGenerateOpen(false)}
        defaultMode={mode}
        defaultQuarter={quarter}
        defaultYear={year}
        unitOptions={units.options}
      />
    </div>
  );
}

export default DistanceByRegionPage;
