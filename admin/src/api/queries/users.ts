/**
 * Users — TanStack Query hooklari (2.1, fe-api §3/§7).
 *
 * Endpointlar `admin/openapi/swagger.json`: `GET/POST /users`,
 * `PATCH/DELETE /users/{id}`, `POST /users/{id}/activate|deactivate|
 * resend-invitation|reset-password`.
 *
 * ⚠️ **Backend bo'shlig'i**: `GET /users/{id}` swaggerda **yo'q** — faqat
 * ro'yxat, yangilash, o'chirish va amal endpointlari bor. `useUser(id)`
 * shuning uchun tarmoqqa so'rov yubormaydi — `['users','list',*]` keshidan
 * moslikni qidiradi. Kesh bo'sh bo'lsa (masalan to'g'ridan-to'g'ri havola
 * bilan kirilganda) `undefined` qaytadi va ekran ro'yxatga qaytarilishi kerak.
 * Yozib qo'yilgan: `docs/tz/16-17-registry-open-questions.md`.
 *
 * Ruxsatlar: `users.read/create/update/delete/invite/reset_password`.
 * Activate/deactivate — alohida kalit **yo'q**, ikkalasi ham `users.update`.
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
import type {
  InvitationSent,
  ListResponse,
  User,
  UserCreate,
  UserUpdate,
  UsersListParams,
} from '@/api/types';

/** Query key fabrikasi — `['users', <tur>, ...]`. */
export const usersKeys = {
  all: ['users'] as const,
  lists: () => [...usersKeys.all, 'list'] as const,
  list: (params: UsersListParams) => [...usersKeys.lists(), params] as const,
  details: () => [...usersKeys.all, 'detail'] as const,
  detail: (id: string) => [...usersKeys.details(), id] as const,
};

/** `GET /users` (`users.read`) — parol/TOTP/PIN hech qachon qaytmaydi. */
export function useUsersList(
  params: UsersListParams = {},
): UseQueryResult<ListResponse<User>, ApiError> {
  return useQuery({
    queryKey: usersKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/users', { params: { query: params } });
      return data ?? {};
    },
  });
}

/** `['users','list',*]` keshidan `id` bo'yicha qidiradi (GET /users/{id} yo'q). */
function findCachedUser(queryClient: QueryClient, id: string): User | undefined {
  const lists = queryClient.getQueriesData<ListResponse<User>>({ queryKey: usersKeys.lists() });
  for (const [, page] of lists) {
    const found = page?.data?.find((user) => user.id === id);
    if (found) return found;
  }
  return undefined;
}

/**
 * "Bitta element" hook — `GET /users/{id}` mavjud emasligi sababli faqat
 * keshdan o'qiydi, tarmoqqa so'rov yubormaydi (yuqoridagi izoh).
 */
export function useUser(id: string | undefined): User | undefined {
  const queryClient = useQueryClient();
  return id ? findCachedUser(queryClient, id) : undefined;
}

/** `POST /users` (`users.create`) — invitation, parol maydoni yo'q. */
export function useUserCreate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: UserCreate) => {
      const { data } = await api.POST('/users', { body });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: usersKeys.lists() });
    },
  });
}

/**
 * `PATCH /users/{id}` (`users.update`). Rol o'zgarsa barcha sessiya bekor
 * qilinadi (backend tomonida).
 */
export function useUserUpdate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: UserUpdate }) => {
      const { data } = await api.PATCH('/users/{id}', { params: { path: { id } }, body });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: usersKeys.lists() });
    },
  });
}

/** `DELETE /users/{id}` (`users.delete`). `409`: o'zi/oxirgi Administrator. */
export function useUserDelete() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      await api.DELETE('/users/{id}', { params: { path: { id } } });
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: usersKeys.lists() });
    },
  });
}

/** `POST /users/{id}/activate` (`users.update`) — alohida `activate` kaliti yo'q. */
export function useUserActivate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      const { data } = await api.POST('/users/{id}/activate', { params: { path: { id } } });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: usersKeys.lists() });
    },
  });
}

/**
 * `POST /users/{id}/deactivate` (`users.update`) — o'zini yoki oxirgi
 * Administratorni bloklashga urinish `409` beradi.
 */
export function useUserDeactivate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      const { data } = await api.POST('/users/{id}/deactivate', { params: { path: { id } } });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: usersKeys.lists() });
    },
  });
}

/** `POST /users/{id}/resend-invitation` (`users.invite`). `202 Accepted`. */
export function useUserResendInvitation() {
  return useMutation({
    mutationFn: async (id: string): Promise<InvitationSent> => {
      const { data } = await api.POST('/users/{id}/resend-invitation', {
        params: { path: { id } },
      });
      return data?.data ?? {};
    },
  });
}

/** `POST /users/{id}/reset-password` (`users.reset_password`). `202 Accepted`. */
export function useUserResetPassword() {
  return useMutation({
    mutationFn: async (id: string): Promise<InvitationSent> => {
      const { data } = await api.POST('/users/{id}/reset-password', {
        params: { path: { id } },
      });
      return data?.data ?? {};
    },
  });
}
