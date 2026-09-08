/**
 * `All` tab ma'lumot manbai — `GET /dvir-reports` (5.2).
 *
 * Har tab alohida komponentda: shunda faol bo'lmagan tabning so'rovi
 * **umuman yuborilmaydi** (hooklarni shartli chaqirib bo'lmaydi).
 */
import { useMemo } from 'react';
import type { ColumnDef } from '@tanstack/react-table';

import { useDvirList } from '@/api/queries/dvir';
import type { DvirReport, DvirReportsListParams, PerPage } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { Pagination } from '@/components/data/Pagination';

import { OutOfServiceBanner } from './OutOfServiceBanner';
import { filterBySearch } from '../lib/search';

export interface DvirAllTabProps {
  params: DvirReportsListParams;
  columns: ColumnDef<DvirReport, unknown>[];
  searchTerm: string;
  emptyTitle: string;
  emptyDescription: string;
  onClearFilters?: () => void;
  onRowClick: (report: DvirReport) => void;
  page: number;
  perPage: PerPage;
  onPageChange: (page: number) => void;
  onPerPageChange: (perPage: PerPage) => void;
}

export function DvirAllTab({
  params,
  columns,
  searchTerm,
  emptyTitle,
  emptyDescription,
  onClearFilters,
  onRowClick,
  page,
  perPage,
  onPageChange,
  onPerPageChange,
}: DvirAllTabProps) {
  const list = useDvirList(params);
  const rows = useMemo(
    () => filterBySearch(list.data?.data ?? [], searchTerm),
    [list.data, searchTerm],
  );

  return (
    <div className="flex flex-col gap-3">
      {rows.some((report) => report.out_of_service) ? <OutOfServiceBanner /> : null}

      <DataTable
        tableId="dvir"
        columns={columns}
        data={rows}
        isLoading={list.isLoading}
        isError={list.isError}
        errorMessage={list.error?.message}
        onRetry={() => void list.refetch()}
        emptyTitle={emptyTitle}
        emptyDescription={emptyDescription}
        onClearFilters={onClearFilters}
        onRowClick={onRowClick}
        getRowId={(report, index) => report.id ?? String(index)}
      />

      <Pagination
        page={page}
        perPage={perPage}
        total={list.data?.meta?.total ?? 0}
        onPageChange={onPageChange}
        onPerPageChange={onPerPageChange}
      />
    </div>
  );
}
