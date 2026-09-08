/**
 * Inspection logs — TanStack Query hooklari (Bosqich 8.11, fe-api §3,
 * `docs/tz/07-9-chat-support-audit.md` §7.12, D39 3-band).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET /inspection/logs` (`inspection.view`), `POST /inspection/email`
 * (`inspection.email`), `POST /inspection/transfer` (`inspection.transfer`).
 *
 * ⚠️ **Nomiga qaramay `GET /inspection/logs` ro'yxat emas.** Swagger tavsifi:
 * "7 days plus today for one driver: every log day with its events, its Log
 * Form and its violations" — bitta haydovchi + bitta sana langari (`date`)
 * uchun 7 kun + bugungi kun oynasidagi kunlar ro'yxatini (`InspectionReport.
 * days[]`) qaytaradi. `page`/`per_page` yo'q. Topshiriqda so'ralgan hook nomi
 * (`useInspectionLogsList`) saqlangan, lekin qaytaradigan qiymat
 * `InspectionReport | undefined` — bitta hisobot obyekti. Ekran "Logs By
 * Driver" ("Select a driver first") patterniga mos: `enabled` faqat
 * `driver_id` bo'lganda `true`.
 *
 * `POST /inspection/transfer` — regulator eksport fayli (`file_key`/
 * `format`/`size_bytes`) qaytaradi, yuklab olish havolasi yo'q (presign yo'q)
 * — shu sababli bu bosqichda faqat hook yoziladi, ekranga ulanmaydi (hisobot,
 * D39 yangilanishi).
 */
import { useMutation, useQuery, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type {
  InspectionEmail,
  InspectionLogsParams,
  InspectionReport,
  InspectionTransfer,
  InspectionTransferResult,
} from '@/api/types';
import type { ApiError } from '@/lib/errors';

/** Query key fabrikasi — `['inspection', <tur>, ...]` (fe-conventions §3). */
export const inspectionKeys = {
  all: ['inspection'] as const,
  reports: () => [...inspectionKeys.all, 'report'] as const,
  report: (params: InspectionLogsParams) => [...inspectionKeys.reports(), params] as const,
};

/**
 * `GET /inspection/logs` (`inspection.view`) — bitta haydovchi uchun roadside
 * oyna hisoboti. `driver_id` bo'lmasa so'rov yuborilmaydi (ekran "Select a
 * driver" bo'sh holatini ko'rsatadi).
 */
export function useInspectionLogsList(
  params: InspectionLogsParams = {},
  options: { enabled?: boolean } = {},
): UseQueryResult<InspectionReport | undefined, ApiError> {
  return useQuery({
    queryKey: inspectionKeys.report(params),
    queryFn: async () => {
      const { data } = await api.GET('/inspection/logs', { params: { query: params } });
      return data?.data;
    },
    enabled: (options.enabled ?? true) && Boolean(params.driver_id),
  });
}

/**
 * `POST /inspection/email` (`inspection.email`, `Idempotency-Key` avtomatik)
 * — roadside oynani PDF sifatida ko'rsatilgan manzilga yuboradi (`202`).
 */
export function useInspectionEmailSend() {
  return useMutation({
    mutationFn: async (body: InspectionEmail) => {
      const { data } = await api.POST('/inspection/email', { body });
      return data;
    },
  });
}

/**
 * `POST /inspection/transfer` (`inspection.transfer`, `Idempotency-Key`
 * avtomatik) — regulator eksport faylini generatsiya qiladi. `us_fmcsa`
 * profilida FMCSA ELD output fayli hali yetkazilmagan bo'lsa `501
 * FEATURE_DISABLED` qaytaradi (swagger tavsifi).
 */
export function useInspectionTransfer() {
  return useMutation({
    mutationFn: async (body: InspectionTransfer): Promise<InspectionTransferResult | undefined> => {
      const { data } = await api.POST('/inspection/transfer', { body });
      return data?.data;
    },
  });
}
