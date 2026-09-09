/**
 * Logs By Unit — jadval ustunlari (7.4.1). `LiveUnit` asosiy manba,
 * `hosByDriver` — kengaytirilgan ustunlar yoqilgandagina to'ldiriladi
 * (F95), `violationsByUnit` — bitta `GET /violations` so'rovidan guruhlangan.
 */
import type { ColumnDef } from '@tanstack/react-table';
import type { TFunction } from 'i18next';

import type { HosSummary, LiveUnit, Violation } from '@/api/types';
import { Badge } from '@/components/ui/Badge';
import { StatusChip } from '@/components/ui/StatusChip';
import type { UseDateFormatResult } from '@/hooks/useDateFormat';
import { formatPersonName } from '@/lib/format';
import { dutyStatusTone, onlineStatusTone } from '@/lib/statusTone';

export interface LogsByUnitColumnsOptions {
  startIndex: number;
  showExtended: boolean;
  hosByDriver: Record<string, HosSummary | undefined>;
  violationsByUnit: Map<string, Violation[]>;
  dateFormat: UseDateFormatResult;
  onOpenLog: (unit: LiveUnit) => void;
}

function driverName(t: TFunction, unit: LiveUnit): string {
  return formatPersonName(unit.driver, t('logs.byUnit.unassignedDriver'));
}

export function buildLogsByUnitColumns(
  t: TFunction,
  options: LogsByUnitColumnsOptions,
): ColumnDef<LiveUnit, unknown>[] {
  const { startIndex, showExtended, hosByDriver, violationsByUnit, dateFormat, onOpenLog } =
    options;

  const baseColumns: ColumnDef<LiveUnit, unknown>[] = [
    {
      id: 'index',
      header: t('logs.byUnit.columns.index'),
      enableHiding: false,
      enableSorting: false,
      cell: ({ row }) => startIndex + row.index + 1,
    },
    {
      id: 'device_status',
      header: t('logs.byUnit.columns.deviceStatus'),
      cell: ({ row }) => {
        const status = row.original.online_status ?? 'offline';
        return (
          <Badge tone={onlineStatusTone(status)}>{t(`logs.byUnit.onlineStatus.${status}`)}</Badge>
        );
      },
    },
    {
      id: 'unit_number',
      accessorKey: 'unit_number',
      header: t('logs.byUnit.columns.unitNumber'),
      enableSorting: false,
    },
    {
      id: 'driver_name',
      header: t('logs.byUnit.columns.driverName'),
      cell: ({ row }) => driverName(t, row.original),
    },
    {
      id: 'status',
      header: t('logs.byUnit.columns.status'),
      cell: ({ row }) => {
        const status = row.original.duty_status ?? 'OFF';
        return <StatusChip status={status} tone={dutyStatusTone(status)} />;
      },
    },
    {
      id: 'last_known_location',
      header: t('logs.byUnit.columns.lastKnownLocation'),
      cell: ({ row }) => {
        const { lat, lng, last_seen_at } = row.original;
        if (lat === undefined || lng === undefined) return t('common.na');
        return (
          <div className="flex flex-col">
            <span>
              {lat.toFixed(4)}, {lng.toFixed(4)}
            </span>
            <span className="text-body-sm text-neutral-600">
              {dateFormat.formatRelative(last_seen_at)}
            </span>
          </div>
        );
      },
    },
    {
      id: 'warnings_violations',
      header: t('logs.byUnit.columns.warningsViolations'),
      cell: ({ row }) => {
        const unitId = row.original.unit_id;
        const list = (unitId && violationsByUnit.get(unitId)) || [];
        if (list.length === 0) return <span className="text-neutral-400">0</span>;
        const titleText = list
          .map((violation) => t(`logs.violations.type.${violation.type}`))
          .join(', ');
        const hasHardViolation = list.some((violation) => violation.severity === 'violation');
        return (
          <span title={titleText}>
            <Badge tone={hasHardViolation ? 'error' : 'warning'}>{list.length}</Badge>
          </span>
        );
      },
    },
  ];

  if (!showExtended) {
    baseColumns.push({
      id: 'open_log',
      header: '',
      enableHiding: false,
      enableSorting: false,
      cell: ({ row }) => (
        <button
          type="button"
          className="text-body-sm font-medium text-primary hover:underline"
          onClick={(event) => {
            event.stopPropagation();
            onOpenLog(row.original);
          }}
        >
          {t('logs.byUnit.openLog')}
        </button>
      ),
    });
    return baseColumns;
  }

  const counterColumn = (
    id: 'break_left_min' | 'drive_left_min' | 'shift_left_min' | 'cycle_left_min',
    labelKey: string,
  ): ColumnDef<LiveUnit, unknown> => ({
    id,
    header: t(labelKey),
    cell: ({ row }) => {
      const driverId = row.original.driver?.id;
      const summary = driverId ? hosByDriver[driverId] : undefined;
      return dateFormat.formatDuration(summary?.counters?.[id] ?? null);
    },
  });

  return [
    ...baseColumns,
    counterColumn('break_left_min', 'logs.hos.rings.break'),
    counterColumn('drive_left_min', 'logs.hos.rings.drive'),
    counterColumn('shift_left_min', 'logs.hos.rings.shift'),
    counterColumn('cycle_left_min', 'logs.hos.rings.cycle'),
    {
      id: 'recap',
      header: t('logs.byUnit.columns.recap'),
      cell: ({ row }) => {
        const driverId = row.original.driver?.id;
        const summary = driverId ? hosByDriver[driverId] : undefined;
        const nextDay = summary?.recap?.[0];
        return nextDay
          ? dateFormat.formatDuration(nextDay.gained_next_min ?? null)
          : t('common.na');
      },
    },
    {
      id: 'open_log',
      header: '',
      enableHiding: false,
      enableSorting: false,
      cell: ({ row }) => (
        <button
          type="button"
          className="text-body-sm font-medium text-primary hover:underline"
          onClick={(event) => {
            event.stopPropagation();
            onOpenLog(row.original);
          }}
        >
          {t('logs.byUnit.openLog')}
        </button>
      ),
    },
  ];
}
