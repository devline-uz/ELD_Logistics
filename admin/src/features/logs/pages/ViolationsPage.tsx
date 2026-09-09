/**
 * Violations — `/violations` (3.13, `docs/tz/07-4-logs.md` 7.4.6).
 *
 * **F105 [MUST]**: violation hech qachon o'chirilmaydi — `Delete` amali
 * umuman yo'q, faqat `resolved` badge (`resolved_at`).
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

import { useViolationsList } from '@/api/queries/violations';
import type { Violation, ViolationsListParams } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { FiltersBar, type FilterDef } from '@/components/data/FiltersBar';
import { ListScreen } from '@/components/data/ListScreen';
import { Pagination } from '@/components/data/Pagination';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useListParams } from '@/hooks/useListParams';

import { buildViolationsColumns } from '../components/violationsColumns';

const VIOLATION_TYPES = [
  'form_manner_trailer',
  'form_manner_doc',
  'drive_limit',
  'shift_limit',
  'break_required',
  'cycle_limit',
  'uncertified_log',
  'unidentified_driving',
  'eld_malfunction',
  'missing_dvir',
] as const;

export function ViolationsPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const dateFormat = useDateFormat();
  const listParams = useListParams();

  const queryParams = useMemo<ViolationsListParams>(
    () => ({
      page: listParams.page,
      per_page: listParams.perPage,
      driver_id: listParams.filters.driver_id || undefined,
      type: (listParams.filters.type as ViolationsListParams['type']) || undefined,
      severity: (listParams.filters.severity as ViolationsListParams['severity']) || undefined,
      resolved:
        listParams.filters.resolved === 'true'
          ? true
          : listParams.filters.resolved === 'false'
            ? false
            : undefined,
    }),
    [
      listParams.page,
      listParams.perPage,
      listParams.filters.driver_id,
      listParams.filters.type,
      listParams.filters.severity,
      listParams.filters.resolved,
    ],
  );

  const list = useViolationsList(queryParams);

  // `GET /violations` matn qidiruviga ega emas (swagger) — LogsByUnitPage'dagi
  // naqshga o'xshab, `search` joriy sahifa ichida driver/unit bo'yicha
  // mijoz tomonida filtrlanadi (backend to'liq ro'yxatni bermaydi, faqat
  // ko'rinayotgan sahifani).
  const searchTerm = listParams.search.trim().toLowerCase();
  const rows = useMemo(() => {
    const all = list.data?.data ?? [];
    if (!searchTerm) return all;
    return all.filter((violation) => {
      const haystack = `${violation.driver_name ?? ''} ${violation.unit_id ?? ''}`.toLowerCase();
      return haystack.includes(searchTerm);
    });
  }, [list.data, searchTerm]);

  const columns = buildViolationsColumns(t, {
    startIndex: (listParams.page - 1) * listParams.perPage,
    dateFormat,
    onView: (violation: Violation) =>
      violation.id && navigate(`/violations/${encodeURIComponent(violation.id)}`),
  });

  const filterDefs: FilterDef[] = [
    {
      key: 'type',
      label: t('logs.violationsList.filters.type'),
      options: VIOLATION_TYPES.map((type) => ({
        value: type,
        label: t(`logs.violations.type.${type}`),
      })),
    },
    {
      key: 'severity',
      label: t('logs.violationsList.filters.severity'),
      options: [
        { value: 'warning', label: t('logs.violationsList.severity.warning') },
        { value: 'violation', label: t('logs.violationsList.severity.violation') },
      ],
    },
    {
      key: 'resolved',
      label: t('logs.violationsList.filters.resolved'),
      options: [
        { value: 'true', label: t('common.boolean.yes') },
        { value: 'false', label: t('common.boolean.no') },
      ],
    },
  ];

  return (
    <ListScreen
      title={t('logs.violationsList.title')}
      filtersBar={
        <FiltersBar
          search={listParams.search}
          onSearchChange={listParams.setSearch}
          searchPlaceholder={t('logs.violationsList.filters.searchPlaceholder')}
          filters={filterDefs}
          activeFilters={listParams.filters}
          onFilterChange={listParams.setFilter}
          onClearAll={listParams.clearFilters}
        />
      }
      table={
        <DataTable
          tableId="violations"
          columns={columns}
          data={rows}
          isLoading={list.isLoading}
          isError={list.isError}
          errorMessage={list.error?.message}
          onRetry={() => void list.refetch()}
          emptyTitle={t('logs.violationsList.empty.title')}
          emptyDescription={
            listParams.hasActiveFilters
              ? t('logs.violationsList.empty.filteredDescription')
              : t('logs.violationsList.empty.description')
          }
          onClearFilters={listParams.hasActiveFilters ? listParams.clearFilters : undefined}
          onRowClick={(violation) =>
            violation.id && navigate(`/violations/${encodeURIComponent(violation.id)}`)
          }
          getRowId={(violation, index) => violation.id ?? String(index)}
        />
      }
      pagination={
        <Pagination
          page={listParams.page}
          perPage={listParams.perPage}
          total={list.data?.meta?.total ?? 0}
          onPageChange={listParams.setPage}
          onPerPageChange={listParams.setPerPage}
        />
      }
    />
  );
}

export default ViolationsPage;
