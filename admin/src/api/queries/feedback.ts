/**
 * Feedback — TanStack Query hooklari (Bosqich 8.1, fe-api §3,
 * `docs/tz/07-9-chat-support-audit.md`, Q80).
 *
 * Endpoint `admin/openapi/swagger.json` bilan tasdiqlangan: `GET /feedback`.
 * Ruxsat: `feedback.read`.
 *
 * ⚠️ **Alohida detal endpointi yo'q** (`POST /feedback` ham yo'q admin uchun —
 * yaratish faqat haydovchi ilovasidan `feedback.create` bilan). Swagger:
 * "Feedback is never answered, so there is no detail, update or delete
 * route." Ro'yxat qatori (`support_dto.Feedback`) allaqachon `driver_name`,
 * `app_rating`, `text`, `submitted_at`ni o'z ichiga oladi — ekran "detal"ni
 * shu qatordan (modal/expand) ko'rsatishi kifoya, qo'shimcha so'rov kerak
 * emas. Shuning uchun bu faylda alohida `useFeedbackDetail` **yozilmagan**.
 */
import { useQuery, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { Feedback, FeedbackListParams, ListResponse } from '@/api/types';
import type { ApiError } from '@/lib/errors';

/** Query key fabrikasi — `['feedback', <tur>, ...]` (fe-conventions §3). */
export const feedbackKeys = {
  all: ['feedback'] as const,
  lists: () => [...feedbackKeys.all, 'list'] as const,
  list: (params: FeedbackListParams) => [...feedbackKeys.lists(), params] as const,
};

/**
 * `GET /feedback` (`feedback.read`) — ilova reytingi oqimi. Filtrlar:
 * `driver_id`, `min_rating` (1..5), `from`/`to`; saralash `submitted_at|app_rating`.
 */
export function useFeedbackList(
  params: FeedbackListParams = {},
  options: { enabled?: boolean } = {},
): UseQueryResult<ListResponse<Feedback>, ApiError> {
  return useQuery({
    queryKey: feedbackKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/feedback', { params: { query: params } });
      return data ?? {};
    },
    enabled: options.enabled ?? true,
  });
}
