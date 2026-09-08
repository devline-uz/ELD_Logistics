/**
 * Support — TanStack Query hooklari (Bosqich 8.1, fe-api §3,
 * `docs/tz/07-9-chat-support-audit.md`, Q77/Q78).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET /support-tickets`, `GET /support-tickets/{id}`,
 * `GET /support-tickets/{id}/messages`, `POST /support-tickets/{id}/messages`,
 * `PATCH /support-tickets/{id}/status`.
 * Ruxsatlar: `support.read` (`GET`lar), `support.update_status` (`PATCH .../status`),
 * `support.create` (`POST .../messages` — javob yozish).
 *
 * Cross-tenant/boshqa haydovchining ticket'i **404** qaytaradi, hech qachon
 * **403** (swagger, fe-api §1). Lifecycle faqat oldinga siljiydi:
 * `new → in_progress → resolved` — orqaga/qaytariq urinish `409 INVALID_STATE`.
 *
 * `POST /support-tickets` (ticket yaratish) bu faylda **yozilmagan** — bosqich
 * ko'lami faqat ro'yxat/detal/thread/status (vazifa ta'rifi). Ticket'ni
 * haydovchi ilovasi yaratadi; admin panel javob yozadi va statusni boshqaradi.
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type {
  ListResponse,
  SupportTicket,
  SupportTicketMessage,
  SupportTicketMessageCreate,
  SupportTicketMessagesParams,
  SupportTicketStatusUpdate,
  SupportTicketsListParams,
} from '@/api/types';
import type { ApiError } from '@/lib/errors';

/** Query key fabrikasi — `['support', <tur>, ...]` (fe-conventions §3). */
export const supportKeys = {
  all: ['support'] as const,
  tickets: () => [...supportKeys.all, 'tickets'] as const,
  ticketsList: (params: SupportTicketsListParams) =>
    [...supportKeys.tickets(), 'list', params] as const,
  ticketDetail: (id: string) => [...supportKeys.tickets(), 'detail', id] as const,
  ticketMessages: (id: string) => [...supportKeys.tickets(), id, 'messages'] as const,
  ticketMessagesList: (id: string, params: SupportTicketMessagesParams) =>
    [...supportKeys.ticketMessages(id), params] as const,
};

/** `GET /support-tickets` (`support.read`) — Support & History navbati. */
export function useSupportTicketsList(
  params: SupportTicketsListParams = {},
  options: { enabled?: boolean } = {},
): UseQueryResult<ListResponse<SupportTicket>, ApiError> {
  return useQuery({
    queryKey: supportKeys.ticketsList(params),
    queryFn: async () => {
      const { data } = await api.GET('/support-tickets', { params: { query: params } });
      return data ?? {};
    },
    enabled: options.enabled ?? true,
  });
}

/** `GET /support-tickets/{id}` (`support.read`) — ticket detali. */
export function useSupportTicketDetail(
  id: string | undefined,
  options: { enabled?: boolean } = {},
): UseQueryResult<SupportTicket, ApiError> {
  return useQuery({
    queryKey: supportKeys.ticketDetail(id ?? ''),
    queryFn: async () => {
      const { data } = await api.GET('/support-tickets/{id}', {
        params: { path: { id: id as string } },
      });
      return data?.data ?? {};
    },
    enabled: Boolean(id) && (options.enabled ?? true),
  });
}

/**
 * `GET /support-tickets/{id}/messages` (`support.read`) — thread, eskidan
 * yangiga ("oldest first", swagger).
 */
export function useSupportTicketMessages(
  id: string | undefined,
  params: SupportTicketMessagesParams = {},
  options: { enabled?: boolean } = {},
): UseQueryResult<ListResponse<SupportTicketMessage>, ApiError> {
  return useQuery({
    queryKey: supportKeys.ticketMessagesList(id ?? '', params),
    queryFn: async () => {
      const { data } = await api.GET('/support-tickets/{id}/messages', {
        params: { path: { id: id as string }, query: params },
      });
      return data ?? {};
    },
    enabled: Boolean(id) && (options.enabled ?? true),
  });
}

/**
 * `POST /support-tickets/{id}/messages` (`support.create`, `Idempotency-Key`
 * avtomatik) — javob yozish, ko'pi bilan 3 ta biriktirma. Muvaffaqiyatdan
 * keyin thread va detal (`message_count`) invalidatsiya qilinadi.
 */
export function useSupportTicketMessageCreate(id: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: SupportTicketMessageCreate) => {
      const { data } = await api.POST('/support-tickets/{id}/messages', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: supportKeys.ticketMessages(id) });
      void queryClient.invalidateQueries({ queryKey: supportKeys.ticketDetail(id) });
      void queryClient.invalidateQueries({ queryKey: supportKeys.tickets() });
    },
  });
}

/**
 * `PATCH /support-tickets/{id}/status` (`support.update_status`) — faqat
 * oldinga: `new → in_progress → resolved`. Orqaga/qaytariq urinish
 * `409 INVALID_STATE` (ekranda toast + ro'yxat invalidatsiyasi, fe-api §6).
 */
export function useSupportTicketStatusUpdate(id: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: SupportTicketStatusUpdate) => {
      const { data } = await api.PATCH('/support-tickets/{id}/status', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: (ticket) => {
      if (ticket) {
        queryClient.setQueryData(supportKeys.ticketDetail(id), ticket);
      }
      void queryClient.invalidateQueries({ queryKey: supportKeys.ticketDetail(id) });
      void queryClient.invalidateQueries({ queryKey: supportKeys.tickets() });
    },
  });
}
