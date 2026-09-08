/**
 * HOS (Hours of Service) — TanStack Query hooklari (3.1, fe-api §3/§7).
 *
 * Endpoint: `GET /drivers/{id}/hos-summary?date=` (`logs.read`).
 *
 * **F98 [MUST].** HOS raqamlari (BREAK/DRIVE/SHIFT/CYCLE, recap) FAQAT
 * backenddan keladi — frontend hech qanday chegarani (masalan `cycle_limit_min`)
 * o'zi hisoblamaydi yoki hardcode qilmaydi. `HosSummary` tipi to'liq
 * `schema.d.ts`dan olingan.
 *
 * **`useHosSummaries` — Logs By Unit kompozitsiyasi (F95/7.4.1).** Ekran
 * `tracking/live` sahifasidagi (≤ 50) haydovchilar uchun `hos-summary`ni
 * faqat kengaytirilgan ustunlar yoqilganda so'raydi. Cheklov shu hook
 * darajasida ta'minlanadi:
 * - **concurrency ≤ 6** — so'rovlar 6 talik ketma-ket to'plamlarda yuboriladi
 *   (bir vaqtning o'zida hech qachon 6 tadan ortiq ochiq so'rov bo'lmaydi);
 * - **staleTime 60 s** — natija 60 soniya keshlanadi, sahifa/filtr
 *   o'zgarmasa qayta so'ralmaydi.
 * Bitta haydovchi uchun so'rov muvaffaqiyatsiz bo'lsa (masalan yangi
 * yollangan haydovchida hali `hos_policy` yo'q → 404) natija xaritasida
 * shu driver `undefined` qoladi — butun batch yiqilmaydi.
 */
import { useQuery, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type { HosSummary, HosSummaryParams } from '@/api/types';

/** Query key fabrikasi — `['hos', <tur>, ...]`. */
export const hosKeys = {
  all: ['hos'] as const,
  summaries: () => [...hosKeys.all, 'summary'] as const,
  summary: (driverId: string, date?: string) =>
    [...hosKeys.summaries(), driverId, date ?? null] as const,
  batches: () => [...hosKeys.all, 'batch'] as const,
  batch: (driverIds: string[], date?: string) =>
    [...hosKeys.batches(), [...driverIds].sort(), date ?? null] as const,
};

/** `GET /drivers/{id}/hos-summary` (`logs.read`) — bitta haydovchi/kun. */
export function useHosSummary(
  driverId: string | undefined,
  date?: string,
): UseQueryResult<HosSummary | undefined, ApiError> {
  return useQuery({
    queryKey: hosKeys.summary(driverId ?? '', date),
    queryFn: async () => {
      const query: HosSummaryParams = date ? { date } : {};
      const { data } = await api.GET('/drivers/{id}/hos-summary', {
        params: { path: { id: driverId as string }, query },
      });
      return data?.data;
    },
    enabled: Boolean(driverId),
    staleTime: 60_000,
  });
}

/** Bir vaqtning o'zida ochiq bo'lishi mumkin bo'lgan so'rovlar soni (F95/7.4.1). */
const HOS_BATCH_CONCURRENCY = 6;

/**
 * Ko'p haydovchi uchun `hos-summary` — `concurrency ≤ 6`, `staleTime 60 s`
 * (yuqoridagi modul izohiga qarang). Natija — `driverId → HosSummary`
 * xaritasi.
 */
export function useHosSummaries(
  driverIds: string[],
  date?: string,
  options: { enabled?: boolean } = {},
): UseQueryResult<Record<string, HosSummary | undefined>, ApiError> {
  const enabled = (options.enabled ?? true) && driverIds.length > 0;
  return useQuery({
    queryKey: hosKeys.batch(driverIds, date),
    queryFn: async () => {
      const query: HosSummaryParams = date ? { date } : {};
      const result: Record<string, HosSummary | undefined> = {};
      for (let i = 0; i < driverIds.length; i += HOS_BATCH_CONCURRENCY) {
        const chunk = driverIds.slice(i, i + HOS_BATCH_CONCURRENCY);
        // Har to'plam ketma-ket kutiladi (F95): shu bilan bir vaqtning
        // o'zida hech qachon HOS_BATCH_CONCURRENCY tadan ortiq so'rov ochiq bo'lmaydi.
        const settled = await Promise.allSettled(
          chunk.map((driverId) =>
            api.GET('/drivers/{id}/hos-summary', {
              params: { path: { id: driverId }, query },
            }),
          ),
        );
        chunk.forEach((driverId, idx) => {
          const outcome = settled[idx];
          result[driverId] = outcome?.status === 'fulfilled' ? outcome.value.data?.data : undefined;
        });
      }
      return result;
    },
    enabled,
    staleTime: 60_000,
  });
}
