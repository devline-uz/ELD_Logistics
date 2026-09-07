/**
 * License No — masklangan qiymat + "Reveal" (2.5, TZ 7.3.5 F87).
 *
 * `drivers.license.view` bo'lmasa "Reveal" umuman ko'rinmaydi
 * (fe-permissions §9). Bosilganda `GET /drivers/{id}/license` chaqiriladi
 * (backend audit_log'ga yozadi), ochilgan qiymat **faqat komponent
 * state'ida** saqlanadi (URL/kesh/localStorage'ga yozilmaydi) va 30
 * soniyadan keyin avtomatik qayta maskalanadi.
 */
import { useEffect, useRef, useState } from 'react';
import { Copy, Eye, EyeOff } from 'lucide-react';
import { useTranslation } from 'react-i18next';

import { useDriverLicenseReveal } from '@/api/queries/drivers';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { IconButton } from '@/components/ui/IconButton';
import { PERM } from '@/lib/permissions';

const REVEAL_DURATION_MS = 30_000;

export interface LicenseRevealProps {
  driverId: string;
  maskedValue?: string;
}

export function LicenseReveal({ driverId, maskedValue }: LicenseRevealProps) {
  const { t } = useTranslation();
  const reveal = useDriverLicenseReveal();
  const [revealedValue, setRevealedValue] = useState<string | undefined>();
  const timerRef = useRef<ReturnType<typeof setTimeout>>();

  useEffect(() => () => window.clearTimeout(timerRef.current), []);

  const handleReveal = () => {
    reveal.mutate(driverId, {
      onSuccess: (data) => {
        setRevealedValue(data.license_no ?? '');
        window.clearTimeout(timerRef.current);
        timerRef.current = setTimeout(() => setRevealedValue(undefined), REVEAL_DURATION_MS);
      },
    });
  };

  const handleHide = () => {
    window.clearTimeout(timerRef.current);
    setRevealedValue(undefined);
  };

  const handleCopy = () => {
    if (revealedValue) {
      void navigator.clipboard.writeText(revealedValue);
    }
  };

  return (
    <span className="inline-flex items-center gap-2">
      <span className="font-mono text-body">{revealedValue ?? maskedValue ?? '—'}</span>

      <PermissionGate permission={PERM.driversLicenseView}>
        {revealedValue ? (
          <>
            <IconButton
              icon={EyeOff}
              size="sm"
              variant="ghost"
              aria-label={t('fleetDrivers.license.hide')}
              onClick={handleHide}
            />
            <IconButton
              icon={Copy}
              size="sm"
              variant="ghost"
              aria-label={t('fleetDrivers.license.copy')}
              onClick={handleCopy}
            />
          </>
        ) : (
          <IconButton
            icon={Eye}
            size="sm"
            variant="ghost"
            aria-label={t('fleetDrivers.license.reveal')}
            loading={reveal.isPending}
            onClick={handleReveal}
          />
        )}
      </PermissionGate>
    </span>
  );
}

export default LicenseReveal;
