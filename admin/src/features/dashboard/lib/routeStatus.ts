import type { StatusChipTone } from '@/components/ui/StatusChip';

/**
 * `dashboard.Route.status` — display-status xaritasi (§7.2 "Route's Details").
 *
 * **Backend bo'shlig'i (D34, `docs/tz/16-17-registry-open-questions.md`):**
 * `GET /dashboard/summary` dagi `routes[].status` enum'i besh qiymatli
 * (`planned | in_progress | completed | not_completed | cancelled`), holbuki
 * TZ jadvali va `/routes` domenining o'z enum'i faqat to'rtta qiymat biladi
 * (`ongoing | completed | not_completed | cancelled`, `enums.route_status`
 * kalitlari ham shu to'rttasi). Shu yerda `planned`/`in_progress` ikkalasi
 * ham **`ongoing`** (sariq) sifatida ko'rsatiladi — TZ §7.2 jadvalidagi
 * yagona "hali tugallanmagan" holat shu.
 */
export type DashboardRouteDisplayStatus = 'ongoing' | 'completed' | 'not_completed' | 'cancelled';

const DISPLAY_STATUS_MAP: Record<string, DashboardRouteDisplayStatus> = {
  planned: 'ongoing',
  in_progress: 'ongoing',
  ongoing: 'ongoing',
  completed: 'completed',
  not_completed: 'not_completed',
  cancelled: 'cancelled',
};

export function resolveDashboardRouteDisplayStatus(
  status: string | null | undefined,
): DashboardRouteDisplayStatus {
  return DISPLAY_STATUS_MAP[status ?? ''] ?? 'ongoing';
}

/** §16 qarori: `Ongoing` sariq (warning), `not_completed` xato, `completed` muvaffaqiyat, `cancelled` neytral. */
export const DASHBOARD_ROUTE_STATUS_TONE: Record<DashboardRouteDisplayStatus, StatusChipTone> = {
  ongoing: 'warning',
  completed: 'success',
  not_completed: 'danger',
  cancelled: 'neutral',
};
