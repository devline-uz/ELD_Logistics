/**
 * Haydovchi bloki — Track on Map yon paneli, 1-blok (§7.7.2):
 * nomi + ogohlantirish ikonkasi, online holati, joylashuv, batareya, tezlik,
 * vaqt tamg'asi, `Shift ends in HH:MM:SS` (`hos-summary`dan, F98 — hisob
 * frontendda qilinmaydi, faqat backend `shift_left_min`ni formatlaydi).
 */
import { AlertTriangle } from 'lucide-react';
import { useTranslation } from 'react-i18next';

import type { HosSummary, LiveUnit } from '@/api/types';
import { Badge, type BadgeTone } from '@/components/ui/Badge';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useUnitSystem } from '@/hooks/useUnitSystem';

import { ONLINE_STATUS_TONE } from './trackingColumns';

export interface DriverInfoPanelProps {
  unit: LiveUnit | undefined;
  hosSummary: HosSummary | undefined;
  hasMalfunction: boolean;
}

function formatCoordinate(value: number | undefined | null): string {
  return typeof value === 'number' ? value.toFixed(7) : 'N/A';
}

export function DriverInfoPanel({ unit, hosSummary, hasMalfunction }: DriverInfoPanelProps) {
  const { t } = useTranslation();
  const { formatSpeed } = useUnitSystem();
  const { formatDateTime, formatDuration } = useDateFormat();

  const driverName = `${unit?.driver?.first_name ?? ''} ${unit?.driver?.last_name ?? ''}`.trim() || 'N/A';
  const onlineStatus = unit?.online_status ?? 'offline';
  const onlineTone: BadgeTone = ONLINE_STATUS_TONE[onlineStatus] ?? 'neutral';
  const shiftLeftMin = hosSummary?.counters?.shift_left_min;

  return (
    <div>
      <div className="flex items-center justify-between gap-2">
        <span className="flex items-center gap-1.5 text-body-lg font-semibold text-neutral-900">
          {driverName}
          {hasMalfunction ? (
            <AlertTriangle
              aria-label={t('tracking.trackOnMap.driver.malfunctionWarning')}
              className="h-4 w-4 text-error-base"
            />
          ) : null}
        </span>
        <Badge tone={onlineTone} variant="dot">
          {t(`enums.connection_status.${onlineStatus}`, { defaultValue: onlineStatus })}
        </Badge>
      </div>

      <dl className="mt-2 flex flex-col gap-1 text-body-sm">
        <div className="flex justify-between">
          <dt className="text-neutral-500">{t('tracking.trackOnMap.driver.location')}</dt>
          <dd className="text-neutral-900">
            {formatCoordinate(unit?.lat)}, {formatCoordinate(unit?.lng)}
          </dd>
        </div>
        <div className="flex justify-between">
          <dt className="text-neutral-500">{t('tracking.trackOnMap.driver.speed')}</dt>
          <dd className="text-neutral-900">{formatSpeed(unit?.speed_kmh)}</dd>
        </div>
        <div className="flex justify-between">
          <dt className="text-neutral-500">{t('tracking.trackOnMap.driver.timestamp')}</dt>
          <dd className="text-neutral-900">{formatDateTime(unit?.last_seen_at)}</dd>
        </div>
        <div className="flex justify-between">
          <dt className="text-neutral-500">{t('tracking.trackOnMap.driver.shiftEnds')}</dt>
          <dd className="text-neutral-900">
            {typeof shiftLeftMin === 'number'
              ? formatDuration(shiftLeftMin, { withSeconds: true })
              : 'N/A'}
          </dd>
        </div>
      </dl>
    </div>
  );
}

export default DriverInfoPanel;
