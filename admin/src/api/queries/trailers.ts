/**
 * Trailers — TanStack Query hooklari (2.1, fe-api §3/§7).
 *
 * Endpointlar `admin/openapi/swagger.json`: `GET/POST /trailers`,
 * `GET/PATCH/DELETE /trailers/{id}`. Dizaynda yo'q edi (🎨) — sodda CRUD
 * (`docs/tz/07-3-fleet.md` §7.3.7).
 *
 * Ruxsatlar: `trailers.read/create/update/delete`.
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type {
  CatalogCreate,
  CatalogUpdate,
  ListResponse,
  Trailer,
  TrailersListParams,
} from '@/api/types';

/** Query key fabrikasi — `['trailers', <tur>, ...]`. */
export const trailersKeys = {
  all: ['trailers'] as const,
  lists: () => [...trailersKeys.all, 'list'] as const,
  list: (params: TrailersListParams) => [...trailersKeys.lists(), params] as const,
  details: () => [...trailersKeys.all, 'detail'] as const,
  detail: (id: string) => [...trailersKeys.details(), id] as const,
};

/** `GET /trailers` (`trailers.read`). Faqat `search` filtri bor. */
export function useTrailersList(
  params: TrailersListParams = {},
): UseQueryResult<ListResponse<Trailer>, ApiError> {
  return useQuery({
    queryKey: trailersKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/trailers', { params: { query: params } });
      return data ?? {};
    },
  });
}

/** `GET /trailers/{id}` (`trailers.read`). Cross-tenant → 404. */
export function useTrailer(id: string | undefined): UseQueryResult<Trailer | undefined, ApiError> {
  return useQuery({
    queryKey: trailersKeys.detail(id ?? ''),
    queryFn: async () => {
      const { data } = await api.GET('/trailers/{id}', {
        params: { path: { id: id as string } },
      });
      return data?.data;
    },
    enabled: Boolean(id),
  });
}

/** `POST /trailers` (`trailers.create`). `(company_id, number)` unikal. */
export function useTrailerCreate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: CatalogCreate) => {
      const { data } = await api.POST('/trailers', { body });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: trailersKeys.lists() });
    },
  });
}

/** `PATCH /trailers/{id}` (`trailers.update`). */
export function useTrailerUpdate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: CatalogUpdate }) => {
      const { data } = await api.PATCH('/trailers/{id}', { params: { path: { id } }, body });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: trailersKeys.lists() });
      void queryClient.invalidateQueries({ queryKey: trailersKeys.detail(id) });
    },
  });
}

/** `DELETE /trailers/{id}` (`trailers.delete`) — soft delete, raqam qayta ishlatiladi. */
export function useTrailerDelete() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      await api.DELETE('/trailers/{id}', { params: { path: { id } } });
    },
    onSuccess: (_data, id) => {
      void queryClient.invalidateQueries({ queryKey: trailersKeys.lists() });
      void queryClient.removeQueries({ queryKey: trailersKeys.detail(id) });
    },
  });
}
