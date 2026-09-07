/**
 * Shipping Documents — TanStack Query hooklari (2.1, fe-api §3/§7).
 *
 * Endpointlar `admin/openapi/swagger.json`: `GET/POST /shipping-documents`,
 * `GET/PATCH/DELETE /shipping-documents/{id}`. Dizaynda yo'q edi (🎨) — sodda
 * CRUD (`docs/tz/07-3-fleet.md` §7.3.8).
 *
 * Ruxsatlar: `shipping_documents.read/create/update/delete`.
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type {
  CatalogCreate,
  CatalogUpdate,
  ListResponse,
  ShippingDocument,
  ShippingDocumentsListParams,
} from '@/api/types';

/** Query key fabrikasi — `['shippingDocuments', <tur>, ...]`. */
export const shippingDocumentsKeys = {
  all: ['shippingDocuments'] as const,
  lists: () => [...shippingDocumentsKeys.all, 'list'] as const,
  list: (params: ShippingDocumentsListParams) =>
    [...shippingDocumentsKeys.lists(), params] as const,
  details: () => [...shippingDocumentsKeys.all, 'detail'] as const,
  detail: (id: string) => [...shippingDocumentsKeys.details(), id] as const,
};

/** `GET /shipping-documents` (`shipping_documents.read`). Faqat `search` filtri. */
export function useShippingDocumentsList(
  params: ShippingDocumentsListParams = {},
): UseQueryResult<ListResponse<ShippingDocument>, ApiError> {
  return useQuery({
    queryKey: shippingDocumentsKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/shipping-documents', { params: { query: params } });
      return data ?? {};
    },
  });
}

/** `GET /shipping-documents/{id}` (`shipping_documents.read`). Cross-tenant → 404. */
export function useShippingDocument(
  id: string | undefined,
): UseQueryResult<ShippingDocument | undefined, ApiError> {
  return useQuery({
    queryKey: shippingDocumentsKeys.detail(id ?? ''),
    queryFn: async () => {
      const { data } = await api.GET('/shipping-documents/{id}', {
        params: { path: { id: id as string } },
      });
      return data?.data;
    },
    enabled: Boolean(id),
  });
}

/** `POST /shipping-documents` (`shipping_documents.create`). `(company_id, number)` unikal. */
export function useShippingDocumentCreate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: CatalogCreate) => {
      const { data } = await api.POST('/shipping-documents', { body });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: shippingDocumentsKeys.lists() });
    },
  });
}

/** `PATCH /shipping-documents/{id}` (`shipping_documents.update`). */
export function useShippingDocumentUpdate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: CatalogUpdate }) => {
      const { data } = await api.PATCH('/shipping-documents/{id}', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: shippingDocumentsKeys.lists() });
      void queryClient.invalidateQueries({ queryKey: shippingDocumentsKeys.detail(id) });
    },
  });
}

/** `DELETE /shipping-documents/{id}` (`shipping_documents.delete`) — soft delete. */
export function useShippingDocumentDelete() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      await api.DELETE('/shipping-documents/{id}', { params: { path: { id } } });
    },
    onSuccess: (_data, id) => {
      void queryClient.invalidateQueries({ queryKey: shippingDocumentsKeys.lists() });
      void queryClient.removeQueries({ queryKey: shippingDocumentsKeys.detail(id) });
    },
  });
}
