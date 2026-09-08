/**
 * Audit log — TanStack Query hooklari (Bosqich 8.1, fe-api §3,
 * `docs/tz/07-9-chat-support-audit.md`, TZ A§17).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET /audit-log`, `GET /audit-log/tables`. Ruxsat: `audit.view` (ikkalasi ham).
 *
 * "TZ A§17 — the single audit trail; the four journals of the UI are
 * filtered views of this endpoint." Ya'ni Company history / Support / boshqa
 * jurnal ekranlari o'z domen endpointlarini ishlatadi (`company.ts`da
 * `useCompanyHistory` — `/company/history`), bu fayl esa **umumiy** audit
 * jurnal ekrani (`/audit` yoki `/settings/audit`) uchun.
 *
 * `old_value`/`new_value` server tomonida maskalanadi (parol xeshi, sessiya
 * tokeni, shifrlangan ustun, haydovchilik guvohnomasi raqami — `[REDACTED]`,
 * `masked: true`). Jadval — append-only: yaratish/o'zgartirish/o'chirish
 * endpointi yo'q.
 */
import { useQuery, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { AuditLogEntry, AuditLogListParams, ListResponse } from '@/api/types';
import type { ApiError } from '@/lib/errors';

/** Query key fabrikasi — `['audit', <tur>, ...]` (fe-conventions §3). */
export const auditKeys = {
  all: ['audit'] as const,
  lists: () => [...auditKeys.all, 'list'] as const,
  list: (params: AuditLogListParams) => [...auditKeys.lists(), params] as const,
  tables: () => [...auditKeys.all, 'tables'] as const,
};

/**
 * `GET /audit-log` (`audit.view`) — yagona audit trail. Filtrlar: `table`,
 * `record_id`, `user`, `action`, `from`/`to`; saralash `order` (`asc|desc`,
 * timestamp bo'yicha, default `desc`) + sahifalash.
 */
export function useAuditLogList(
  params: AuditLogListParams = {},
  options: { enabled?: boolean } = {},
): UseQueryResult<ListResponse<AuditLogEntry>, ApiError> {
  return useQuery({
    queryKey: auditKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/audit-log', { params: { query: params } });
      return data ?? {};
    },
    enabled: options.enabled ?? true,
  });
}

/**
 * `GET /audit-log/tables` (`audit.view`) — kompaniyaning audit qilingan
 * jadval nomlari, `table` filtri dropdown'i uchun. Deyarli o'zgarmaydigan
 * katalog — `staleTime` uzun (fe-api §7, `branches.ts` naqshi).
 */
const TEN_MINUTES_MS = 10 * 60 * 1000;

export function useAuditLogTables(
  options: { enabled?: boolean } = {},
): UseQueryResult<string[], ApiError> {
  return useQuery({
    queryKey: auditKeys.tables(),
    queryFn: async () => {
      const { data } = await api.GET('/audit-log/tables', {});
      return data?.data ?? [];
    },
    staleTime: TEN_MINUTES_MS,
    enabled: options.enabled ?? true,
  });
}
