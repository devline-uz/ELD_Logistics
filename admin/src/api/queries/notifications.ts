/**
 * Notifications — TanStack Query hooklari (Bosqich 7, fe-api §3/§7, TZ A§19/Q87,
 * `docs/tz-admin-frontend.md` §7.11).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET /notifications`, `POST /notifications/read-all`, `PATCH /notifications/{id}/read`.
 * Ruxsat: `notifications.read` (uchalasi ham).
 *
 * Inbox — **shaxsiy**: boshqa foydalanuvchining bildirishnomalarini o'qishning
 * imkoni yo'q (backend `user_id` bo'yicha chaqiruvchining o'zini oladi — alohida
 * `user_id` query parametri **yo'q**, swagger'da yo'q). `meta.unread` — header
 * dropdown belgisi, `read`/`alert_type` filtrlaridan qat'i nazar butun inboxni
 * hisoblaydi.
 *
 * Real-vaqt: `notification_created` WS hodisasi kelganda `applyNotificationCreatedEvent`
 * chaqiriladi — sof funksiya, `lib/ws.ts`ga bog'lanmaydi (WS egasi chaqiradi).
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
import type { Notification, NotificationListMeta, NotificationsListParams } from '@/api/types';

/** `GET /notifications` javobi — `meta` sahifalash **va** `unread` hisoblagichi. */
export interface NotificationsListResult {
  data?: Notification[];
  meta?: NotificationListMeta;
}

/** Header dropdown belgisi uchun kichik, barqaror so'rov hajmi (10/25/50 dan kichigi yo'q). */
export const NOTIFICATIONS_UNREAD_QUERY_PARAMS: NotificationsListParams = { per_page: 10 };

/** Query key fabrikasi — `['notifications', <tur>, ...]` (fe-conventions §3). */
export const notificationsKeys = {
  all: ['notifications'] as const,
  lists: () => [...notificationsKeys.all, 'list'] as const,
  list: (params: NotificationsListParams) => [...notificationsKeys.lists(), params] as const,
  unreadCount: () => [...notificationsKeys.all, 'unread-count'] as const,
};

/** `GET /notifications` (`notifications.read`) — sahifa (7.11, Notifications ekrani). */
export function useNotificationsList(
  params: NotificationsListParams = {},
  options: { enabled?: boolean } = {},
): UseQueryResult<NotificationsListResult, ApiError> {
  return useQuery({
    queryKey: notificationsKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/notifications', { params: { query: params } });
      return data ?? {};
    },
    enabled: options.enabled ?? true,
  });
}

/**
 * `GET /notifications` (`notifications.read`) — faqat `meta.unread` header
 * dropdown belgisi uchun (7.11). Alohida query key: sahifa parametrlari
 * o'zgarganda ham belgi keshi qayta so'ralmaydi.
 */
export function useNotificationsUnreadCount(
  options: { enabled?: boolean } = {},
): UseQueryResult<number, ApiError> {
  return useQuery({
    queryKey: notificationsKeys.unreadCount(),
    queryFn: async () => {
      const { data } = await api.GET('/notifications', {
        params: { query: NOTIFICATIONS_UNREAD_QUERY_PARAMS },
      });
      return data?.meta?.unread ?? 0;
    },
    enabled: options.enabled ?? true,
  });
}

/**
 * `PATCH /notifications/{id}/read` (`notifications.read`) — idempotent: allaqachon
 * o'qilgan bildirishnoma `updated: 0` bilan `200` qaytaradi. Boshqa foydalanuvchi/
 * kompaniyaniki — `404` (hech qachon `403`).
 */
export function useNotificationRead() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      const { data } = await api.PATCH('/notifications/{id}/read', {
        params: { path: { id } },
      });
      return data?.data;
    },
    onSuccess: (result) => {
      if (result) {
        queryClient.setQueryData(notificationsKeys.unreadCount(), result.unread);
      }
      void queryClient.invalidateQueries({ queryKey: notificationsKeys.lists() });
    },
  });
}

/** `POST /notifications/read-all` (`notifications.read`) — chaqiruvchining butun inboxi (Q88). */
export function useNotificationsReadAll() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async () => {
      const { data } = await api.POST('/notifications/read-all');
      return data?.data;
    },
    onSuccess: (result) => {
      queryClient.setQueryData(notificationsKeys.unreadCount(), result?.unread ?? 0);
      void queryClient.invalidateQueries({ queryKey: notificationsKeys.lists() });
    },
  });
}

/**
 * `notification_created` WS hodisasi kelganda keshni yangilaydi (F163): belgi
 * hisoblagichi darhol o'sadi (agar hodisa allaqachon o'qilgan holatda kelmasa),
 * ro'yxat sahifalari esa keyingi ko'rishda yangi qatorni olishi uchun
 * invalidatsiya qilinadi (kursorsiz oddiy sahifalash — xavfsiz qayta so'rov).
 */
export function applyNotificationCreatedEvent(
  queryClient: QueryClient,
  notification: Notification,
): void {
  if (!notification.read) {
    queryClient.setQueryData<number>(notificationsKeys.unreadCount(), (count) =>
      typeof count === 'number' ? count + 1 : count,
    );
  }
  void queryClient.invalidateQueries({ queryKey: notificationsKeys.lists() });
}
