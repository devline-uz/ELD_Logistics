/**
 * Marker kartochkasi — jonli kuzatuv xaritasidagi popup tarkibi
 * (`fe-map` skill, dizayn o'lchami 200×217 px).
 *
 * Domenga xos hisob-kitob (masofa/vaqt formatlash, duty status rangi) chaqiruvchi
 * tomonidan tayyorlanadi — bu komponent faqat taqdimot qatlami, shunda u
 * oddiy render (jadval/list) va MapLibre popup (`mountUnitMarkerCard`) ikkalasida
 * ham bir xil ishlaydi va alohida test qilinadi.
 */
import { createRoot, type Root } from 'react-dom/client';
import { ExternalLink } from 'lucide-react';
import { useTranslation } from 'react-i18next';

import { Badge, type BadgeTone } from '@/components/ui/Badge';
import { StatusChip, type StatusChipTone } from '@/components/ui/StatusChip';

export interface UnitMarkerCardProps {
  driverName: string;
  dutyStatus: string;
  dutyStatusTone: StatusChipTone;
  unitNumber: string;
  odometer: string;
  location: string;
  hasCoordinates: boolean;
  relativeTime: string;
  onlineTone: BadgeTone;
  onlineLabel: string;
  onViewTracking: () => void;
}

/** 200×217 px kartochka — `fe-map` skill jadvali. */
export function UnitMarkerCard({
  driverName,
  dutyStatus,
  dutyStatusTone,
  unitNumber,
  odometer,
  location,
  hasCoordinates,
  relativeTime,
  onlineTone,
  onlineLabel,
  onViewTracking,
}: UnitMarkerCardProps) {
  const { t } = useTranslation();

  return (
    <div className="flex w-[200px] flex-col gap-1.5 rounded-lg bg-surface p-3 text-body-sm">
      <div className="flex items-center justify-between gap-2">
        <span className="truncate font-semibold text-neutral-900">{driverName}</span>
        <Badge tone={onlineTone} variant="dot">
          {onlineLabel}
        </Badge>
      </div>

      <StatusChip status={dutyStatus} tone={dutyStatusTone} label={dutyStatus} />

      <dl className="grid grid-cols-[auto_1fr] gap-x-2 gap-y-0.5 text-neutral-600">
        <dt>{t('map.markerCard.unitNumber')}</dt>
        <dd className="text-neutral-900">{unitNumber}</dd>
        <dt>{t('map.markerCard.odometer')}</dt>
        <dd className="text-neutral-900">{odometer}</dd>
        <dt>{t('map.markerCard.location')}</dt>
        <dd className="flex items-center gap-1 truncate text-neutral-900">
          <span className="truncate">{location}</span>
          {hasCoordinates ? (
            <ExternalLink aria-hidden="true" className="h-3 w-3 shrink-0 text-neutral-400" />
          ) : null}
        </dd>
      </dl>

      <span className="text-neutral-400">{relativeTime}</span>

      <button
        type="button"
        onClick={onViewTracking}
        className="mt-1 self-start text-body-sm font-medium text-primary hover:underline"
      >
        {t('map.markerCard.viewTracking')}
      </button>
    </div>
  );
}

/**
 * `UnitMarkerCard`ni MapLibre `Popup.setDOMContent` uchun mount qiladi.
 * Alohida React root — popup konteyneri router/i18n providerlar daraxtidan
 * tashqarida, shuning uchun `onViewTracking` closure orqali navigatsiya
 * qilinadi (href emas).
 */
export function mountUnitMarkerCard(container: HTMLElement, props: UnitMarkerCardProps): Root {
  const root = createRoot(container);
  root.render(<UnitMarkerCard {...props} />);
  return root;
}

export default UnitMarkerCard;
