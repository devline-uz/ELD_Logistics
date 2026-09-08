/**
 * Tracking ro'yxati ustunlari — `docs/tz/07-7-tracking-routes.md` §7.7.1.
 *
 * `Last Known Location` — `lat`/`lng` (backend reverse-geocode matn bermaydi,
 * F172) 7 xonagacha (§16 format qoidasi) + `last_seen_at` nisbiy vaqt.
 */
import type { ColumnDef } from '@tanstack/react-table';
import type { TFunction } from 'i18next';
import type { ReactNode } from 'react';

import type { LiveUnit } from '@/api/types';
import { Badge, type BadgeTone } from '@/components/ui/Badge';
import { formatCoordinatePair } from '@/lib/format';
import { StatusChip, type StatusChipTone } from '@/components/ui/StatusChip';

export const DUTY_STATUS_TONE: Record<string, StatusChipTone> = {
  OFF: 'neutral',
  SB: 'info',
  DR: 'success',
  ON: 'warning',
};

export const ONLINE_STATUS_TONE: Record<string, BadgeTone> = {
  online: 'success',
  idle: 'warning',
  offline: 'neutral',
  disconnected: 'error',
  malfunction: 'error',
};

export function driverFullName(unit: LiveUnit): string {
  const first = unit.driver?.first_name ?? '';
  const last = unit.driver?.last_name ?? '';
  const name = `${first} ${last}`.trim();
  return name || 'N/A';
}

export interface TrackingColumnsHelpers {
  formatRelative: (value: string | null | undefined) => string;
  formatSpeed: (kmh: number | null | undefined) => string;
  /**
   * WS `unit_last_state` kelgan satr uchun `true` (F115) — `DataTable`
   * (umumiy komponent, tegilmaydi) qator darajasida className qabul qilmaydi,
   * shuning uchun highlight har katak ichida `-mx/-my` bilan to'liq katak
   * maydonini qoplaydigan wrapper orqali beriladi.
   */
  isHighlighted: (unit: LiveUnit) => boolean;
}

function HighlightCell({ highlighted, children }: { highlighted: boolean; children: ReactNode }) {
  return (
    <div
      className={
        highlighted ? '-mx-4 -my-3 bg-light px-4 py-3 transition-colors duration-500' : undefined
      }
    >
      {children}
    </div>
  );
}

export function buildTrackingColumns(
  t: TFunction,
  startIndex: number,
  helpers: TrackingColumnsHelpers,
): ColumnDef<LiveUnit, unknown>[] {
  return [
    {
      id: 'index',
      header: t('tracking.list.columns.index'),
      enableHiding: false,
      enableSorting: false,
      cell: ({ row }) => (
        <HighlightCell highlighted={helpers.isHighlighted(row.original)}>
          {startIndex + row.index + 1}
        </HighlightCell>
      ),
    },
    {
      id: 'driver_name',
      header: t('tracking.list.columns.driverName'),
      cell: ({ row }) => (
        <HighlightCell highlighted={helpers.isHighlighted(row.original)}>
          {driverFullName(row.original)}
        </HighlightCell>
      ),
    },
    {
      id: 'unit_number',
      header: t('tracking.list.columns.unitNumber'),
      cell: ({ row }) => (
        <HighlightCell highlighted={helpers.isHighlighted(row.original)}>
          {row.original.unit_number ?? 'N/A'}
        </HighlightCell>
      ),
    },
    {
      id: 'status',
      header: t('tracking.list.columns.status'),
      cell: ({ row }) => {
        const status = row.original.duty_status ?? 'OFF';
        return (
          <HighlightCell highlighted={helpers.isHighlighted(row.original)}>
            <StatusChip
              status={status}
              tone={DUTY_STATUS_TONE[status] ?? 'neutral'}
              label={t(`enums.duty_status.${status}`, { defaultValue: status })}
            />
          </HighlightCell>
        );
      },
    },
    {
      id: 'device',
      header: t('tracking.list.columns.device'),
      cell: ({ row }) => {
        const status = row.original.online_status ?? 'offline';
        return (
          <HighlightCell highlighted={helpers.isHighlighted(row.original)}>
            <div className="flex flex-col gap-0.5">
              <Badge tone={ONLINE_STATUS_TONE[status] ?? 'neutral'} variant="dot">
                {t(`enums.connection_status.${status}`, { defaultValue: status })}
              </Badge>
              <span className="text-body-sm text-neutral-500">
                {row.original.eld_device_serial ?? 'N/A'}
              </span>
            </div>
          </HighlightCell>
        );
      },
    },
    {
      id: 'speed',
      header: t('tracking.list.columns.speed'),
      cell: ({ row }) => (
        <HighlightCell highlighted={helpers.isHighlighted(row.original)}>
          {helpers.formatSpeed(row.original.speed_kmh)}
        </HighlightCell>
      ),
    },
    {
      id: 'location',
      header: t('tracking.list.columns.location'),
      cell: ({ row }) => (
        <HighlightCell highlighted={helpers.isHighlighted(row.original)}>
          <div className="flex flex-col gap-0.5">
            <span>{formatCoordinatePair(row.original.lat, row.original.lng)}</span>
            <span className="text-body-sm text-neutral-500">
              {helpers.formatRelative(row.original.last_seen_at)}
            </span>
          </div>
        </HighlightCell>
      ),
    },
  ];
}
