/**
 * Roles — TanStack Query hooklari (2.1, fe-api §3/§7).
 *
 * Endpointlar `admin/openapi/swagger.json`: `GET/POST /roles`,
 * `PATCH/DELETE /roles/{id}`.
 *
 * ⚠️ **Backend bo'shlig'i**: `GET /roles/{id}` swaggerda **yo'q** (`users.ts`
 * dagi bilan bir xil naqsh) — `useRole(id)` faqat `['roles','list',*]`
 * keshidan qidiradi, tarmoqqa so'rov yubormaydi. Yozib qo'yilgan:
 * `docs/tz/16-17-registry-open-questions.md`.
 *
 * Ruxsatlar: `roles.read/create/update/delete`.
 * `409 ROLE_IN_USE` (o'chirish) va `403 SYSTEM_ROLE_IMMUTABLE` (F92/F93)
 * — `ApiError.code`/`status` orqali chaqiruvchi UI'da ishlov beradi.
 */
import {
  useMutation,
  useQuery,
  useQueryClient,
  type QueryClient,
  type UseQueryResult,
} from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type { ListResponse, Role, RoleCreate, RoleUpdate, RolesListParams } from '@/api/types';

/** Query key fabrikasi — `['roles', <tur>, ...]`. */
export const rolesKeys = {
  all: ['roles'] as const,
  lists: () => [...rolesKeys.all, 'list'] as const,
  list: (params: RolesListParams) => [...rolesKeys.lists(), params] as const,
  details: () => [...rolesKeys.all, 'detail'] as const,
  detail: (id: string) => [...rolesKeys.details(), id] as const,
};

/** `GET /roles` (`roles.read`) — tizim shablonlari + kompaniya rollari. */
export function useRolesList(
  params: RolesListParams = {},
): UseQueryResult<ListResponse<Role>, ApiError> {
  return useQuery({
    queryKey: rolesKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/roles', { params: { query: params } });
      return data ?? {};
    },
  });
}

/** `['roles','list',*]` keshidan `id` bo'yicha qidiradi (GET /roles/{id} yo'q). */
function findCachedRole(queryClient: QueryClient, id: string): Role | undefined {
  const lists = queryClient.getQueriesData<ListResponse<Role>>({ queryKey: rolesKeys.lists() });
  for (const [, page] of lists) {
    const found = page?.data?.find((role) => role.id === id);
    if (found) return found;
  }
  return undefined;
}

/** "Bitta element" hook — faqat keshdan (yuqoridagi izoh). */
export function useRole(id: string | undefined): Role | undefined {
  const queryClient = useQueryClient();
  return id ? findCachedRole(queryClient, id) : undefined;
}

/**
 * `POST /roles` (`roles.create`). Har bir `permissions[]` kaliti
 * `GET /permissions` ro'yxatida bo'lishi shart — noma'lum kalit `422`.
 */
export function useRoleCreate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: RoleCreate) => {
      const { data } = await api.POST('/roles', { body });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: rolesKeys.lists() });
    },
  });
}

/**
 * `PATCH /roles/{id}` (`roles.update`). Tizim roli → `403
 * SYSTEM_ROLE_IMMUTABLE` (F92). Har o'zgarish egalarining sessiyasini bekor
 * qiladi (backend tomonida).
 */
export function useRoleUpdate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: RoleUpdate }) => {
      const { data } = await api.PATCH('/roles/{id}', { params: { path: { id } }, body });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: rolesKeys.lists() });
      void queryClient.invalidateQueries({ queryKey: rolesKeys.detail(id) });
    },
  });
}

/**
 * `DELETE /roles/{id}` (`roles.delete`). `409 ROLE_IN_USE` — foydalanuvchilari
 * bor (F93); `403 SYSTEM_ROLE_IMMUTABLE` — tizim roli (F92).
 */
export function useRoleDelete() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      await api.DELETE('/roles/{id}', { params: { path: { id } } });
    },
    onSuccess: (_data, id) => {
      void queryClient.invalidateQueries({ queryKey: rolesKeys.lists() });
      void queryClient.removeQueries({ queryKey: rolesKeys.detail(id) });
    },
  });
}
