/**
 * Permission catalogue — TanStack Query hooki (2.1, fe-api §3/§7).
 *
 * Endpoint `admin/openapi/swagger.json`: `GET /permissions` — ruxsat
 * `permissions.read` **yoki** `roles.read` (OR istisno, `docs/api/
 * permissions.md`). Roles ekrani (F90) checkbox guruhlarini shu javobdan
 * quradi — xom satr hech qachon qo'lda yozilmaydi.
 *
 * Deyarli o'zgarmaydigan katalog — `staleTime` uzun (fe-api §7: `GET /me`/
 * `GET /permissions` ~10 daqiqa).
 */
import { useQuery, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type { PermissionModule } from '@/api/types';

const TEN_MINUTES_MS = 10 * 60 * 1000;

/** Query key — bitta statik ro'yxat, parametrsiz. */
export const permissionsKeys = {
  all: ['permissions'] as const,
  list: () => [...permissionsKeys.all, 'list'] as const,
};

/** `GET /permissions` (`permissions.read` yoki `roles.read`). */
export function usePermissionsList(): UseQueryResult<PermissionModule[], ApiError> {
  return useQuery({
    queryKey: permissionsKeys.list(),
    queryFn: async () => {
      const { data } = await api.GET('/permissions', {});
      return data?.data ?? [];
    },
    staleTime: TEN_MINUTES_MS,
  });
}
