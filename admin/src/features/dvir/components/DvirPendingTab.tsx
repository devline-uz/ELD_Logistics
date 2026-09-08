/**
 * `Pending certification` tab ma'lumot manbai —
 * `GET /dvir-reports/pending-certification` (5.2).
 *
 * Endpoint faqat `unit_id` filtrini biladi va sahifalashsiz — shuning uchun
 * bu tabda `Pagination` ko'rsatilmaydi.
 */
import { useMemo } from 'react';
import type { ColumnDef } from '@tanstack/react-table';

import { useDvirPendingCertification } from '@/api/queries/dvir';
import type { DvirReport } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';

import { OutOfServiceBanner } from './OutOfServiceBanner';
import { filterBySearch } from '../lib/search';

export interface DvirPendingTabProps {
  unitId?: string;
  columns: ColumnDef<DvirReport, unknown>[];
  searchTerm: string;
  emptyTitle: string;
  emptyDescription: string;
  onRowClick: (report: DvirReport) => void;
}

export function DvirPendingTab({
  unitId,
  columns,
  searchTerm,
  emptyTitle,
  emptyDescription,
  onRowClick,
}: DvirPendingTabProps) {
  const list = useDvirPendingCertification({ unit_id: unitId });
  const rows = useMemo(
    () => filterBySearch(list.data?.data ?? [], searchTerm),
    [list.data, searchTerm],
  );

  return (
    <div className="flex flex-col gap-3">
      {rows.some((report) => report.out_of_service) ? <OutOfServiceBanner /> : null}

      <DataTable
        tableId="dvir-pending"
        columns={columns}
        data={rows}
        isLoading={list.isLoading}
        isError={list.isError}
        errorMessage={list.error?.message}
        onRetry={() => void list.refetch()}
        emptyTitle={emptyTitle}
        emptyDescription={emptyDescription}
        onRowClick={onRowClick}
        getRowId={(report, index) => report.id ?? String(index)}
      />
    </div>
  );
}
