/**
 * Logs By Driver — kengaytirilgan ustunlar (Break/Drive/Shift/Cycle/Recap)
 * uchun bitta haydovchining **bir nechta kuni** bo'yicha `hos-summary`
 * (7.4.2). `api/queries/hos.ts`dagi `useHosSummaries` bitta sana × ko'p
 * haydovchi uchun mo'ljallangan (Logs By Unit, F95) — bu yerda aksincha bitta
 * haydovchi × ko'p sana kerak, shuning uchun mahalliy variant (concurrency
 * ≤ 6, staleTime 60s — bir xil siyosat).
 */
import { useQuery, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type { HosSummary } from '@/api/types';

const CONCURRENCY = 6;

export const hosByDateKeys = {
  all: ['logs', 'hos-by-date'] as const,
  batch: (driverId: string, dates: string[]) =>
    [...hosByDateKeys.all, driverId, [...dates].sort()] as const,
};

/** `driverId` bitta, `dates[]` ko'p — natija `date → HosSummary` xaritasi. */
export function useHosSummariesByDate(
  driverId: string | undefined,
  dates: string[],
  options: { enabled?: boolean } = {},
): UseQueryResult<Record<string, HosSummary | undefined>, ApiError> {
  const enabled = (options.enabled ?? true) && Boolean(driverId) && dates.length > 0;
  return useQuery({
    queryKey: hosByDateKeys.batch(driverId ?? '', dates),
    queryFn: async () => {
      const result: Record<string, HosSummary | undefined> = {};
      for (let i = 0; i < dates.length; i += CONCURRENCY) {
        const chunk = dates.slice(i, i + CONCURRENCY);
        const settled = await Promise.allSettled(
          chunk.map((date) =>
            api.GET('/drivers/{id}/hos-summary', {
              params: { path: { id: driverId as string }, query: { date } },
            }),
          ),
        );
        chunk.forEach((date, idx) => {
          const outcome = settled[idx];
          result[date] = outcome?.status === 'fulfilled' ? outcome.value.data?.data : undefined;
        });
      }
      return result;
    },
    enabled,
    staleTime: 60_000,
  });
}
