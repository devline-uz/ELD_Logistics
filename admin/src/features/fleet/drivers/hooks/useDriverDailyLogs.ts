/**
 * `GET /drivers/{id}/daily-logs` (`drivers.read`) — Driver View "Daily logs" tabi (2.4, TZ 7.3.5).
 *
 * ⚠️ **Mahalliy hook**: bu endpoint `admin/openapi/swagger.json`da bor, lekin
 * `src/api/queries/**` (umumiy fayllar, bu agentning fayl egaligidan tashqarida)
 * hali `useDriverDailyLogs` bilan boyitilmagan. Konventsiyaga mos (query key,
 * `ApiError` xato tipi) mahalliy nusxa — `docs/tz/16-17-registry-open-questions.md`
 * ga yozilgan gap: umumiy `api/queries/drivers.ts` kengaytirilganda bu fayl olib
 * tashlanadi va import shu yerdan almashtiriladi.
 */
import { useQuery, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type { DailyLogSummary, ListResponse } from '@/api/types';

export interface DriverDailyLogsParams {
  from?: string;
  to?: string;
  page?: number;
  per_page?: number;
}

export const driverDailyLogsKeys = {
  all: ['drivers', 'daily-logs'] as const,
  list: (id: string, params: DriverDailyLogsParams) =>
    [...driverDailyLogsKeys.all, id, params] as const,
};

export function useDriverDailyLogs(
  id: string | undefined,
  params: DriverDailyLogsParams = {},
): UseQueryResult<ListResponse<DailyLogSummary>, ApiError> {
  return useQuery({
    queryKey: driverDailyLogsKeys.list(id ?? '', params),
    queryFn: async () => {
      const { data } = await api.GET('/drivers/{id}/daily-logs', {
        params: { path: { id: id as string }, query: params },
      });
      return data ?? {};
    },
    enabled: Boolean(id),
  });
}
