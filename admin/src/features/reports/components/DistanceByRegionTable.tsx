/**
 * Distance by Region / IFTA jadvali — `Units`/`Regions` tabi (7.8.2).
 *
 * `mode=regions_and_units` → `Unit # · VIN · Region · Distance` (backendda `Month` maydoni
 * yo'q — **D31.2** ga ko'ra ustun olib tashlangan, `docs/tz/16-17-…`).
 * `mode=regions_only` → `Region · Total distance`.
 *
 * `VIN` `RegionDistanceRow`da yo'q — chaqiruvchi `unit_id` bo'yicha `GET /units`dan
 * bog'lab, `vin` maydonini qatorga qo'shib beradi (D31.2).
 */
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import type { ColumnDef } from '@tanstack/react-table';

import type { RegionDistanceRow } from '@/api/types';
import { DataTable } from '@/components/data/DataTable';
import { useUnitSystem } from '@/hooks/useUnitSystem';
import { NA } from '@/lib/format';

export type DistanceReportMode = 'regions_and_units' | 'regions_only';

export type DistanceRegionRowWithVin = RegionDistanceRow & { vin?: string | null };

export interface DistanceByRegionTableProps {
  mode: DistanceReportMode;
  data: DistanceRegionRowWithVin[];
  isLoading?: boolean;
  isError?: boolean;
  errorMessage?: string;
  onRetry?: () => void;
  emptyDescription?: string;
  onClearFilters?: () => void;
}

export function DistanceByRegionTable({
  mode,
  data,
  isLoading,
  isError,
  errorMessage,
  onRetry,
  emptyDescription,
  onClearFilters,
}: DistanceByRegionTableProps) {
  const { t } = useTranslation();
  const { formatDistance } = useUnitSystem();

  const columns: ColumnDef<DistanceRegionRowWithVin, unknown>[] = useMemo(() => {
    if (mode === 'regions_only') {
      return [
        {
          id: 'region',
          header: t('reports.distanceByRegion.columns.region'),
          cell: ({ row }) => row.original.region_name ?? row.original.region_code ?? NA,
        },
        {
          id: 'total_distance',
          header: t('reports.distanceByRegion.columns.totalDistance'),
          cell: ({ row }) => formatDistance(row.original.distance_m),
        },
      ];
    }

    return [
      {
        id: 'unit_number',
        header: t('reports.distanceByRegion.columns.unitNumber'),
        cell: ({ row }) => row.original.unit_number ?? NA,
      },
      {
        id: 'vin',
        header: t('reports.distanceByRegion.columns.vin'),
        cell: ({ row }) => row.original.vin ?? NA,
      },
      {
        id: 'region',
        header: t('reports.distanceByRegion.columns.region'),
        cell: ({ row }) => row.original.region_name ?? row.original.region_code ?? NA,
      },
      {
        id: 'distance',
        header: t('reports.distanceByRegion.columns.distance'),
        cell: ({ row }) => formatDistance(row.original.distance_m),
      },
    ];
  }, [mode, t, formatDistance]);

  return (
    <DataTable
      tableId={`reports-distance-by-region-${mode}`}
      columns={columns}
      data={data}
      isLoading={isLoading}
      isError={isError}
      errorMessage={errorMessage}
      onRetry={onRetry}
      emptyDescription={emptyDescription}
      onClearFilters={onClearFilters}
      getRowId={(row, index) => `${row.region_code ?? 'r'}-${row.unit_id ?? index}`}
    />
  );
}

export default DistanceByRegionTable;
