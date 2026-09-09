/**
 * Unit jadvali ustunlari (2.2, `docs/tz/07-3-fleet.md` §7.3.1, §16 N13).
 *
 * `Make & Model` va `ELD` — kanonik nomlar (dizayndagi `Manufacturer - Model`
 * / `Device ID` emas). `ELD` ustunida qurilma **serial raqami** ko'rsatiladi,
 * bo'sh bo'lsa xato rangda `Not Found`.
 */
import type { ColumnDef } from '@tanstack/react-table';
import type { TFunction } from 'i18next';

import type { Unit } from '@/api/types';
import { Badge } from '@/components/ui/Badge';

export function buildUnitColumns(t: TFunction, startIndex: number): ColumnDef<Unit, unknown>[] {
  return [
    {
      id: 'index',
      header: t('fleet.units.columns.index'),
      enableHiding: false,
      enableSorting: false,
      cell: ({ row }) => startIndex + row.index + 1,
    },
    {
      id: 'unit_number',
      accessorKey: 'unit_number',
      header: t('fleet.units.columns.unitNumber'),
      enableSorting: true,
    },
    {
      id: 'license_plate',
      header: t('fleet.units.columns.licensePlate'),
      cell: ({ row }) => (
        <div>
          <div>{row.original.license_plate ?? '—'}</div>
          {row.original.plate_region ? (
            <div className="text-body-sm text-neutral-600">{row.original.plate_region}</div>
          ) : null}
        </div>
      ),
    },
    {
      id: 'make_model',
      header: t('fleet.units.columns.makeModel'),
      cell: ({ row }) => `${row.original.make ?? ''} ${row.original.model ?? ''}`.trim() || '—',
    },
    {
      id: 'year',
      accessorKey: 'year',
      header: t('fleet.units.columns.year'),
      enableSorting: true,
      cell: ({ row }) => row.original.year ?? '—',
    },
    {
      id: 'eld',
      header: t('fleet.units.columns.eld'),
      cell: ({ row }) =>
        row.original.eld_device_serial ? (
          row.original.eld_device_serial
        ) : (
          <span className="text-error-dark">{t('fleet.units.eldNotFound')}</span>
        ),
    },
    {
      id: 'vin',
      accessorKey: 'vin',
      header: t('fleet.units.columns.vin'),
      cell: ({ row }) =>
        row.original.vin ? (
          <span className="max-w-[10ch] truncate" title={row.original.vin}>
            {row.original.vin}
          </span>
        ) : (
          '—'
        ),
    },
    {
      id: 'status',
      header: t('fleet.units.columns.status'),
      enableSorting: true,
      cell: ({ row }) =>
        row.original.out_of_service ? (
          <Badge tone="error">{t('fleet.units.status.outOfService')}</Badge>
        ) : (
          <Badge tone={row.original.status === 'active' ? 'success' : 'neutral'}>
            {t(`fleet.units.status.${row.original.status ?? 'inactive'}`)}
          </Badge>
        ),
    },
  ];
}
