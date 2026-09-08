/**
 * Reports filtrlaridagi `Driver` / `Unit` tanlov ro'yxatlari (Bosqich 6.11
 * ko'rigi — dublikat topilmasi). Beshta hisobot ekrani bir xil
 * `useDriversList(...) → filter(id) → map({value,label})` blokini takrorlagan edi;
 * endi bitta manba. `formatPersonName` — `lib/format.ts` (yagona ism formati).
 */
import { useMemo } from 'react';

import { useDriversList } from '@/api/queries/drivers';
import { useUnitsList } from '@/api/queries/units';
import type { Driver, Unit } from '@/api/types';
import type { SelectOption } from '@/components/ui/Select';
import { formatPersonName } from '@/lib/format';

/** Filtr select'lari uchun sahifa hajmi — barcha reports ekranlarida bir xil. */
const OPTIONS_PER_PAGE = 50;

export interface EntityOptionsResult<TEntity> {
  options: SelectOption[];
  isLoading: boolean;
  /** Xom ro'yxat — qo'shimcha bog'lash uchun (masalan `unit_id → vin`). */
  data: TEntity[];
}

export function useDriverOptions(): EntityOptionsResult<Driver> {
  const drivers = useDriversList({ per_page: OPTIONS_PER_PAGE });
  const data = useMemo(() => drivers.data?.data ?? [], [drivers.data]);
  const options = useMemo(
    () =>
      data
        .filter((driver): driver is Driver & { id: string } => Boolean(driver.id))
        .map((driver) => ({ value: driver.id, label: formatPersonName(driver, driver.id) })),
    [data],
  );
  return { options, isLoading: drivers.isLoading, data };
}

/** `driver_id → ko'rsatiladigan ism` xaritasi (jadval katagida ID ni nomga almashtirish). */
export function useDriverNameById(drivers: readonly Driver[]): ReadonlyMap<string, string> {
  return useMemo(() => {
    const map = new Map<string, string>();
    for (const driver of drivers) {
      if (driver.id) map.set(driver.id, formatPersonName(driver, driver.id));
    }
    return map;
  }, [drivers]);
}

export function useUnitOptions(): EntityOptionsResult<Unit> {
  const units = useUnitsList({ per_page: OPTIONS_PER_PAGE });
  const data = useMemo(() => units.data?.data ?? [], [units.data]);
  const options = useMemo(
    () =>
      data
        .filter((unit): unit is Unit & { id: string } => Boolean(unit.id))
        .map((unit) => ({ value: unit.id, label: unit.unit_number ?? unit.id })),
    [data],
  );
  return { options, isLoading: units.isLoading, data };
}
