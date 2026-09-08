/**
 * Branches — TanStack Query hooklari (bosqich 2 ko'rigi B1, kengaytirildi
 * bosqich 8.1: Settings › Branches CRUD, `docs/tz/07-13-settings-admin.md`
 * §7.13.2).
 *
 * `GET /company/branches` — `scope=company` administratori Unit/Driver/User
 * Add/Edit formalarida va ro'yxat filtrlarida filialni tanlashi uchun
 * (`docs/tz/07-3-fleet.md` §7.3.1, §7.3.4, §7.3.9) **va** Settings ›
 * Branches jadvali uchun ishlatiladi. `scope=branch` foydalanuvchisi uchun
 * bu select **yashiriladi** — backend baribir `branch_id` ni o'z filialiga
 * cheklaydi.
 *
 * `POST/PATCH/DELETE /company/branches[/{id}]` (`branches.create/update/delete`)
 * — sodda CRUD (TZ §1: "🎨 oddiy CRUD ekran kerak [SHOULD]"). O'chirish —
 * soft delete; foydalanuvchisi bor filial `409 RESOURCE_IN_USE` qaytaradi.
 * Boshqa tenant filiali `404`, hech qachon `403` (swagger).
 *
 * Deyarli o'zgarmaydigan katalog — `staleTime` uzun (fe-api §7).
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type {
  Branch,
  BranchCreate,
  BranchesListParams,
  BranchUpdate,
  ListResponse,
} from '@/api/types';
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

/** `POST /company/branches` (`branches.create`, `Idempotency-Key` avtomatik). */
export function useBranchCreate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: BranchCreate) => {
      const { data } = await api.POST('/company/branches', { body });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: branchesKeys.lists() });
    },
  });
}

/**
 * `PATCH /company/branches/{id}` (`branches.update`). Nom to'qnashuvida `409
 * UNIQUE_VIOLATION`.
 */
export function useBranchUpdate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: BranchUpdate }) => {
      const { data } = await api.PATCH('/company/branches/{id}', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: branchesKeys.lists() });
    },
  });
}

/**
 * `DELETE /company/branches/{id}` (`branches.delete`) — soft delete.
 * Foydalanuvchisi bor filial `409 RESOURCE_IN_USE` qaytaradi.
 */
export function useBranchDelete() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      await api.DELETE('/company/branches/{id}', { params: { path: { id } } });
      return id;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: branchesKeys.lists() });
    },
  });
}
