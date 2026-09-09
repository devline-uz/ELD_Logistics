/**
 * `UNIT DIAGNOSTICS` bloki — Track on Map yon paneli, 2-blok (§7.7.2).
 *
 * **F117 [MUST]** Blok nomi har ikkala kirish yo'lida ham `Unit Diagnostics`
 * (dizaynda Tracking'dan kirilganda `Unit Inspection` edi — kanonik emas).
 *
 * `VIN` — `fleet.Unit.vin` dan (`GET /units/{id}`), diagnostikadan EMAS:
 * `fleet.UnitDiagnostics` da `vin` yo'q, faqat `device_serial` bor va u
 * alohida `Device Serial` maydoni sifatida ko'rsatiladi.
 */
import { useTranslation } from 'react-i18next';

import type { UnitDiagnostics } from '@/api/types';
import { Skeleton } from '@/components/feedback/Skeleton';
import { NA } from '@/lib/format';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useUnitSystem } from '@/hooks/useUnitSystem';

export interface UnitDiagnosticsPanelProps {
  diagnostics: UnitDiagnostics | undefined;
  isLoading: boolean;
  /** `GET /units/{id}` → `vin` — diagnostika DTO'sida bu maydon yo'q. */
  vin?: string | undefined;
}

function Field({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex justify-between gap-2 py-1 text-body-sm">
      <span className="text-neutral-600">{label}</span>
      <span className="text-neutral-900">{value}</span>
    </div>
  );
}

export function UnitDiagnosticsPanel({ diagnostics, isLoading, vin }: UnitDiagnosticsPanelProps) {
  const { t } = useTranslation();
  const { formatDistance, formatTemperature } = useUnitSystem();
  const { formatDuration } = useDateFormat();

  if (isLoading) {
    return <Skeleton variant="card" count={4} />;
  }

  const telemetry = diagnostics?.telemetry;
  const percent = (value: number | undefined) =>
    typeof value === 'number' ? `${Math.round(value)}%` : NA;

  return (
    <div>
      <h3 className="mb-1 text-body-sm font-semibold uppercase tracking-wide text-neutral-600">
        {t('tracking.trackOnMap.diagnostics.title')}
      </h3>
      <Field label={t('tracking.trackOnMap.diagnostics.vin')} value={vin ?? NA} />
      <Field
        label={t('tracking.trackOnMap.diagnostics.deviceSerial')}
        value={diagnostics?.device_serial ?? NA}
      />
      <Field
        label={t('tracking.trackOnMap.diagnostics.engineHours')}
        value={
          typeof telemetry?.engine_hours === 'number'
            ? formatDuration(telemetry.engine_hours * 60)
            : NA
        }
      />
      <Field
        label={t('tracking.trackOnMap.diagnostics.odometer')}
        value={formatDistance(telemetry?.odometer_m ?? undefined)}
      />
      <Field
        label={t('tracking.trackOnMap.diagnostics.fuel')}
        value={percent(telemetry?.fuel_pct)}
      />
      <Field
        label={t('tracking.trackOnMap.diagnostics.bus')}
        value={
          diagnostics?.connection_type
            ? t(`enums.connection_type.${diagnostics.connection_type}`)
            : NA
        }
      />
      <Field
        label={t('tracking.trackOnMap.diagnostics.coolantLevel')}
        value={percent(telemetry?.coolant_level_pct)}
      />
      <Field
        label={t('tracking.trackOnMap.diagnostics.coolantTemperature')}
        value={formatTemperature(telemetry?.coolant_temp_c)}
      />
      <Field
        label={t('tracking.trackOnMap.diagnostics.oilLevel')}
        value={percent(telemetry?.oil_level_pct)}
      />

      {diagnostics?.malfunction_codes && diagnostics.malfunction_codes.length > 0 ? (
        <div className="mt-2 rounded-md bg-error-bg p-2 text-body-sm text-error-dark">
          <span className="font-medium">{t('tracking.trackOnMap.diagnostics.malfunctions')}: </span>
          {diagnostics.malfunction_codes.map((code) => code.code).join(', ')}
        </div>
      ) : null}
    </div>
  );
}

export default UnitDiagnosticsPanel;
