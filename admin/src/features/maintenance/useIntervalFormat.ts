/**
 * `interval_value` + `interval_unit` juftligini ekranga chiqarish (5.8).
 *
 * Masofa — `lib/units.ts` orqali (`formatIntervalDistance`, yorliq bilan);
 * `days`/`engine_hours` — i18n ko'plik kalitlari orqali. Hech qanday matn
 * konkatenatsiyasi yo'q (fe-design-system §9).
 */
import { useCallback } from 'react';
import { useTranslation } from 'react-i18next';

import { useUnitSystem } from '@/hooks/useUnitSystem';

import { formatIntervalDistance, isDistanceUnit, type IntervalUnit } from './intervalUnits';
import { NA } from '@/lib/format';

export interface UseIntervalFormatResult {
  /** `25,000.0 km` · `30 days` · `250 engine hours` · `N/A`. */
  formatInterval: (value: number | null | undefined, unit: IntervalUnit | undefined) => string;
}

export function useIntervalFormat(): UseIntervalFormatResult {
  const { t } = useTranslation();
  const { unitSystem } = useUnitSystem();

  const formatInterval = useCallback(
    (value: number | null | undefined, unit: IntervalUnit | undefined) => {
      if (typeof value !== 'number' || !Number.isFinite(value)) return NA;
      if (isDistanceUnit(unit)) return formatIntervalDistance(value, unit, unitSystem);
      if (unit === 'engine_hours') {
        return t('maintenance.units.engineHours', { count: value });
      }
      return t('maintenance.units.days', { count: value });
    },
    [t, unitSystem],
  );

  return { formatInterval };
}
