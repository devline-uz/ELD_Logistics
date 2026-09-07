/**
 * Branches katalogi — TanStack Query hooki (bosqich 2 ko'rigi B1).
 *
 * `GET /company/branches` — `scope=company` administratori Unit/Driver/User
 * Add/Edit formalarida va ro'yxat filtrlarida filialni tanlashi uchun
 * (`docs/tz/07-3-fleet.md` §7.3.1, §7.3.4, §7.3.9). `scope=branch`
 * foydalanuvchisi uchun bu select **yashiriladi** — backend baribir
 * `branch_id` ni o'z filialiga cheklaydi.
 *
 * Deyarli o'zgarmaydigan katalog — `staleTime` uzun (fe-api §7).
 */
import { useQuery, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { Branch, BranchesListParams, ListResponse } from '@/api/types';
import type { ApiError } from '@/lib/errors';

const TEN_MINUTES_MS = 10 * 60 * 1000;

/** Query key fabrikasi — `['branches', <tur>, ...]`. */
export const branchesKeys = {
  all: ['branches'] as const,
  lists: () => [...branchesKeys.all, 'list'] as const,
  list: (params: BranchesListParams) => [...branchesKeys.lists(), params] as const,
};

/**
 * `GET /company/branches`. `enabled: false` — `scope=company` bo'lmagan
 * sessiyalarda so'rov umuman yuborilmasin (Branch select/filtri
 * ko'rsatilmaydi, backend baribir cheklaydi, lekin keraksiz so'rov shart
 * emas).
 */
export function useBranchesList(
  params: BranchesListParams = {},
  options: { enabled?: boolean } = {},
): UseQueryResult<ListResponse<Branch>, ApiError> {
  return useQuery({
    queryKey: branchesKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/company/branches', { params: { query: params } });
      return data ?? {};
    },
    staleTime: TEN_MINUTES_MS,
    enabled: options.enabled ?? true,
  });
}
