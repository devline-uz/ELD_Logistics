/**
 * `unit_id → Unit` lug'ati.
 *
 * Maintenance DTO'lari faqat `unit_id` + `unit_number` beradi, ekran esa
 * `License Plate` (Due) va `Make & Model` (History) ustunlarini talab qiladi
 * (§7.6). Ular `GET /units` dan olinadi va shu yerda birlashtiriladi —
 * backendga qo'shimcha maydon so'ralmaydi (§16 nomzodi sifatida hisobotda).
 */
import { useMemo } from 'react';

import { useUnitsList } from '@/api/queries/units';
import type { Unit } from '@/api/types';

export interface UseUnitLookupResult {
  units: Unit[];
  byId: Map<string, Unit>;
  isLoading: boolean;
}

/** Barcha aktiv unit'lar (formadagi tanlov ro'yxati uchun ham ishlatiladi). */
export function useUnitLookup(): UseUnitLookupResult {
  const list = useUnitsList({ per_page: 50, status: 'active' });

  return useMemo(() => {
    const units = list.data?.data ?? [];
    const byId = new Map<string, Unit>();
    for (const unit of units) {
      if (unit.id) byId.set(unit.id, unit);
    }
    return { units, byId, isLoading: list.isLoading };
  }, [list.data, list.isLoading]);
}
