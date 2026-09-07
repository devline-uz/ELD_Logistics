/**
 * Violations — TanStack Query hooklari (3.1, fe-api §3/§7).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET /violations`, `GET /violations/{id}` (`violations.read`).
 *
 * **F105.** Violation server tomonida yaratiladi va **hech qachon
 * o'chirilmaydi** — yopilganda ham `resolved_at`/`resolved_reason` bilan
 * ro'yxatda qoladi. Shu sabab bu faylda `DELETE` mutatsiyasi **yo'q**.
 */
import { useQuery, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type { ListResponse, Violation, ViolationsListParams } from '@/api/types';

/** Query key fabrikasi — `['violations', <tur>, ...]`. */
export const violationsKeys = {
  all: ['violations'] as const,
  lists: () => [...violationsKeys.all, 'list'] as const,
  list: (params: ViolationsListParams) => [...violationsKeys.lists(), params] as const,
  details: () => [...violationsKeys.all, 'detail'] as const,
  detail: (id: string) => [...violationsKeys.details(), id] as const,
};

/**
 * `GET /violations` (`violations.read`) — 10 turdagi `type` + `severity` +
 * `resolved` + `driver_id` + sana oralig'i, mustaqil filtrlar (Q59).
 */
export function useViolationsList(
  params: ViolationsListParams = {},
): UseQueryResult<ListResponse<Violation>, ApiError> {
  return useQuery({
    queryKey: violationsKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/violations', { params: { query: params } });
      return data ?? {};
    },
  });
}

/**
 * `GET /violations/{id}` (`violations.read`) — bitta yozuv, `policy_version_id`
 * va (yopilgan bo'lsa) `resolved_reason` bilan. Yozuv hech qachon olib
 * tashlanmaydi (F105).
 */
export function useViolation(
  id: string | undefined,
): UseQueryResult<Violation | undefined, ApiError> {
  return useQuery({
    queryKey: violationsKeys.detail(id ?? ''),
    queryFn: async () => {
      const { data } = await api.GET('/violations/{id}', {
        params: { path: { id: id as string } },
      });
      return data?.data;
    },
    enabled: Boolean(id),
  });
}
