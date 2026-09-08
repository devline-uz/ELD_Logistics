/**
 * Dashboard — TanStack Query hooklari (Bosqich 7, fe-api §3/§7, TZ A§20,
 * `docs/tz-admin-frontend.md` §7.2).
 *
 * Endpoint `admin/openapi/swagger.json` bilan tasdiqlangan: `GET /dashboard/summary`.
 * Ruxsat: `dashboard.read`.
 *
 * Yagona javob 9 KPI kartasi, duty-status bloki (`ON/OFF/SB/DR`) va bugungi
 * marshrutlar (`Route's Details`) uchun yetarli — barcha oynalar (`day`/`week`)
 * kompaniya vaqt zonasida kesilgan holda backenddan keladi, frontend qayta
 * hisoblamaydi.
 *
 * Real-vaqt: `dashboard_summary` WS hodisasi **xuddi shu payload**ni qayta
 * yuboradi (fe-realtime §8.2 jadvali) — shuning uchun `applyDashboardSummaryEvent`
 * to'g'ridan-to'g'ri `setQueryData` bilan ishlaydi, invalidatsiya/qayta so'rov
 * kerak emas. Bu funksiya sof — `lib/ws.ts`ga bog'lanmaydi, WS egasi
 * (`realtime-engineer`) uni `useChannel('dashboard', …)` ichida chaqiradi.
 */
import { useQuery, type QueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type { DashboardSummary } from '@/api/types';

/** Query key fabrikasi — `['dashboard', <tur>, ...]` (fe-conventions §3). */
export const dashboardKeys = {
  all: ['dashboard'] as const,
  summary: () => [...dashboardKeys.all, 'summary'] as const,
};

/**
 * `GET /dashboard/summary` (`dashboard.read`) — KPI kartalari, status bloki,
 * bugungi marshrutlar. `staleTime: 0` — fe-api §7 SHOULD tavsiyasiga ko'ra
 * (WS bilan yangilanadi, ortiqcha keshlash kerak emas).
 *
 * `options.refetchInterval` — WS ulanmagan/`reconnecting` holatida ekran
 * qatlami 60 s pollingga o'tishi mumkin (F158); default `false` — WS ulangan
 * paytda qo'shimcha so'rov yubormaslik uchun.
 */
export function useDashboardSummary(
  options: { refetchInterval?: number | false; enabled?: boolean } = {},
): UseQueryResult<DashboardSummary | undefined, ApiError> {
  return useQuery({
    queryKey: dashboardKeys.summary(),
    queryFn: async () => {
      const { data } = await api.GET('/dashboard/summary');
      return data?.data;
    },
    staleTime: 0,
    refetchInterval: options.refetchInterval ?? false,
    enabled: options.enabled ?? true,
  });
}

/**
 * `dashboard_summary` WS hodisasi kelganda keshni yangilaydi (F163). Payload
 * server tomonidan `GET /dashboard/summary` bilan **bir xil shaklda** qayta
 * yuboriladi — shuning uchun to'g'ridan-to'g'ri almashtiriladi.
 */
export function applyDashboardSummaryEvent(
  queryClient: QueryClient,
  summary: DashboardSummary,
): void {
  queryClient.setQueryData(dashboardKeys.summary(), summary);
}
