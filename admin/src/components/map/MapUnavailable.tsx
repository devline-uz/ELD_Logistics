/**
 * `VITE_MAP_STYLE_URL` bo'sh bo'lgan holat — buyurtmachi haqiqiy MapTiler
 * kalitini hali bermagan (D-Q1). Xarita o'rniga aniq xabar — **crash emas**.
 */
import { MapPinOff } from 'lucide-react';
import { useTranslation } from 'react-i18next';

export interface MapUnavailableProps {
  className?: string;
}

export function MapUnavailable({ className }: MapUnavailableProps) {
  const { t } = useTranslation();

  return (
    <div
      role="status"
      className={`flex flex-col items-center justify-center gap-3 rounded-lg border border-dashed border-stroke bg-surface-muted px-6 py-16 text-center ${className ?? ''}`}
    >
      <MapPinOff aria-hidden="true" className="h-10 w-10 text-neutral-400" />
      <h3 className="text-body-lg font-semibold text-neutral-900">
        {t('map.unavailable.title')}
      </h3>
      <p className="max-w-sm text-body text-neutral-500">{t('map.unavailable.description')}</p>
    </div>
  );
}

export default MapUnavailable;
