/**
 * `lib/units.ts` ni kompaniya `unit_system` iga bog'laydi (F197).
 *
 * Komponentlar `lib/units.ts` ni bevosita chaqirish o'rniga shu hook orqali
 * ishlatadi — `unitSystem` parametrini har joyda qo'lda uzatish shart emas.
 */
import { useMemo } from 'react';

import {
  formatDistance,
  formatSpeed,
  formatTemperature,
  formatVolume,
  formatWeight,
  parseDistance,
  parseSpeed,
  parseTemperature,
  parseVolume,
  parseWeight,
  type UnitSystem,
} from '@/lib/units';
import { useCompanyStore } from '@/store/company-store';

export interface UseUnitSystemResult {
  unitSystem: UnitSystem;
  formatDistance: (meters: number | null | undefined) => string;
  parseDistance: (value: number | null | undefined) => number | null;
  formatSpeed: (kmh: number | null | undefined) => string;
  parseSpeed: (value: number | null | undefined) => number | null;
  formatTemperature: (celsius: number | null | undefined) => string;
  parseTemperature: (value: number | null | undefined) => number | null;
  formatVolume: (liters: number | null | undefined) => string;
  parseVolume: (value: number | null | undefined) => number | null;
  formatWeight: (kg: number | null | undefined) => string;
  parseWeight: (value: number | null | undefined) => number | null;
}

/** Company store'dagi `unit_system` ga bog'langan formatlash/parse funksiyalari. */
export function useUnitSystem(): UseUnitSystemResult {
  const unitSystem = useCompanyStore((state) => state.company.unitSystem);

  return useMemo(
    () => ({
      unitSystem,
      formatDistance: (meters) => formatDistance(meters, unitSystem),
      parseDistance: (value) => parseDistance(value, unitSystem),
      formatSpeed: (kmh) => formatSpeed(kmh, unitSystem),
      parseSpeed: (value) => parseSpeed(value, unitSystem),
      formatTemperature: (celsius) => formatTemperature(celsius, unitSystem),
      parseTemperature: (value) => parseTemperature(value, unitSystem),
      formatVolume: (liters) => formatVolume(liters, unitSystem),
      parseVolume: (value) => parseVolume(value, unitSystem),
      formatWeight: (kg) => formatWeight(kg, unitSystem),
      parseWeight: (value) => parseWeight(value, unitSystem),
    }),
    [unitSystem],
  );
}
