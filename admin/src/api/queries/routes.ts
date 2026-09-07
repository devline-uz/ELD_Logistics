/**
 * Routes — TanStack Query hooklari (bosqich 4, §7.7.3, fe-api §3/§7).
 *
 * Endpointlar: `GET/POST /routes`, `GET/PATCH/DELETE /routes/{id}`,
 * `GET /routes/{id}/directions`, `POST /routes/{id}/not-completed`.
 * Ruxsatlar: `routes.read/create/update/delete/complete`.
 *
 * **F118** `ongoing → completed` avtomatik (geofence, backend) — bu faylda
 * qo'lda "complete" mutatsiyasi **yo'q**, faqat `useRouteNotCompleted`.
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type {
  Directions,
  ListResponse,
  Route,
  RouteCreate,
  RouteNotCompleted,
  RoutesListParams,
  RouteUpdate,
} from '@/api/types';

export const routesKeys = {
  all: ['routes'] as const,
  lists: () => [...routesKeys.all, 'list'] as const,
  list: (params: RoutesListParams) => [...routesKeys.lists(), params] as const,
  details: () => [...routesKeys.all, 'detail'] as const,
  detail: (id: string) => [...routesKeys.details(), id] as const,
  directions: (id: string) => [...routesKeys.all, 'directions', id] as const,
};

/** `GET /routes` (`routes.read`). */
export function useRoutesList(
  params: RoutesListParams = {},
): UseQueryResult<ListResponse<Route>, ApiError> {
  return useQuery({
    queryKey: routesKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/routes', { params: { query: params } });
      return data ?? {};
    },
    placeholderData: (previous) => previous,
  });
}

/** `GET /routes/{id}` (`routes.read`). Boshqa kompaniya → 404. */
export function useRoute(id: string | undefined): UseQueryResult<Route | undefined, ApiError> {
  return useQuery({
    queryKey: routesKeys.detail(id ?? ''),
    queryFn: async () => {
      const { data } = await api.GET('/routes/{id}', { params: { path: { id: id as string } } });
      return data?.data;
    },
    enabled: Boolean(id),
  });
}

/**
 * `GET /routes/{id}/directions` (`routes.read`) — Q66.1, provayder bo'lmasa
 * `provider: 'nop'` bilan bo'sh javob (xato emas).
 */
export function useRouteDirections(
  id: string | undefined,
  options: { enabled?: boolean } = {},
): UseQueryResult<Directions | undefined, ApiError> {
  return useQuery({
    queryKey: routesKeys.directions(id ?? ''),
    queryFn: async () => {
      const { data } = await api.GET('/routes/{id}/directions', {
        params: { path: { id: id as string } },
      });
      return data?.data;
    },
    enabled: Boolean(id) && (options.enabled ?? true),
    staleTime: 5 * 60_000,
  });
}

/** `POST /routes` (`routes.create`) — D21: «Create route», `Run Trip` emas. */
export function useRouteCreate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: RouteCreate) => {
      const { data } = await api.POST('/routes', { body });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: routesKeys.lists() });
    },
  });
}

/** `PATCH /routes/{id}` (`routes.update`) — faqat `ongoing` route tahrirlanadi. */
export function useRouteUpdate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: RouteUpdate }) => {
      const { data } = await api.PATCH('/routes/{id}', { params: { path: { id } }, body });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: routesKeys.lists() });
      void queryClient.invalidateQueries({ queryKey: routesKeys.detail(id) });
    },
  });
}

/** `DELETE /routes/{id}` (`routes.delete`) — soft delete. */
export function useRouteDelete() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      await api.DELETE('/routes/{id}', { params: { path: { id } } });
    },
    onSuccess: (_data, id) => {
      void queryClient.invalidateQueries({ queryKey: routesKeys.lists() });
      void queryClient.removeQueries({ queryKey: routesKeys.detail(id) });
    },
  });
}

/**
 * `POST /routes/{id}/not-completed` (`routes.complete`) — F118: bu **yagona**
 * qo'lda yopish yo'li; `ongoing → completed` faqat geofence orqali avtomatik.
 * `ongoing` bo'lmagan route'da `409 INVALID_STATE`.
 */
export function useRouteNotCompleted() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: RouteNotCompleted }) => {
      const { data } = await api.POST('/routes/{id}/not-completed', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: routesKeys.lists() });
      void queryClient.invalidateQueries({ queryKey: routesKeys.detail(id) });
    },
  });
}
