/**
 * Logs — TanStack Query hooklari (3.1, fe-api §3/§7).
 *
 * Logs By Unit / By Driver / Log view ekranlari uchun. Endpointlar
 * `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET /tracking/live`, `GET /drivers/{id}/daily-logs`, `GET /daily-logs/{id}`,
 * `POST /daily-logs/{id}/certify`, `POST /daily-logs/{id}/events`,
 * `GET /daily-logs/{id}/pdf`.
 *
 * Ruxsatlar: `tracking.view_live`, `logs.read`, `logs.certify`,
 * `logs.add_event`, `logs.export`.
 *
 * **F95 [MUST].** Backendda «bir kun × barcha unitlar × HOS hisoblagichlari»
 * beruvchi yagona endpoint yo'q — Logs By Unit ekrani `useTrackingLive` (shu
 * fayl) + `useHosSummaries` (`hos.ts`, concurrency ≤ 6) + `useViolationsList`
 * (`violations.ts`) kompozitsiyasi bilan quriladi (`docs/tz/07-4-logs.md`
 * 7.4.1). `hos-summary` batch cheklovi `hos.ts`da, shu faylda emas.
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type {
  CertifyRequest,
  DailyLogDetail,
  DailyLogSummary,
  DriverDailyLogsParams,
  ListResponse,
  LiveUnit,
  LogEventCreate,
  TrackingLiveParams,
} from '@/api/types';

/** Query key fabrikasi — `['logs', <tur>, ...]` (fe-conventions §3). */
export const logsKeys = {
  all: ['logs'] as const,
  dailyLogsByDriver: () => [...logsKeys.all, 'daily-logs'] as const,
  dailyLogsForDriver: (driverId: string, params: DriverDailyLogsParams) =>
    [...logsKeys.dailyLogsByDriver(), driverId, params] as const,
  dailyLogDetails: () => [...logsKeys.all, 'detail'] as const,
  dailyLogDetail: (id: string) => [...logsKeys.dailyLogDetails(), id] as const,
};

/** `['tracking', <tur>, ...]` — alohida namespace, `logs` bilan aralashmaydi. */
export const trackingKeys = {
  all: ['tracking'] as const,
  live: (params: TrackingLiveParams) => [...trackingKeys.all, 'live', params] as const,
};

/**
 * `GET /tracking/live` (`tracking.view_live`) — Logs By Unit asosiy manbai
 * (unit, driver, duty_status, online_status, joylashuv). §12: masofa metr,
 * tezlik km/h — backend hech qachon konvertatsiya qilmaydi.
 */
export function useTrackingLive(
  params: TrackingLiveParams = {},
): UseQueryResult<ListResponse<LiveUnit>, ApiError> {
  return useQuery({
    queryKey: trackingKeys.live(params),
    queryFn: async () => {
      const { data } = await api.GET('/tracking/live', { params: { query: params } });
      return data ?? {};
    },
  });
}

/**
 * `GET /drivers/{id}/daily-logs` (`logs.read`) — Logs By Driver ro'yxati
 * (default oyna: oxirgi 8 kun, sertifikatsiya oynasi).
 */
export function useDriverDailyLogs(
  driverId: string | undefined,
  params: DriverDailyLogsParams = {},
): UseQueryResult<ListResponse<DailyLogSummary>, ApiError> {
  return useQuery({
    queryKey: logsKeys.dailyLogsForDriver(driverId ?? '', params),
    queryFn: async () => {
      const { data } = await api.GET('/drivers/{id}/daily-logs', {
        params: { path: { id: driverId as string }, query: params },
      });
      return data ?? {};
    },
    enabled: Boolean(driverId),
  });
}

/**
 * `GET /daily-logs/{id}` (`logs.read`) — Log view: `events[]`, `form`,
 * `totals`, `violations[]`, `certification_status`.
 */
export function useDailyLog(
  id: string | undefined,
): UseQueryResult<DailyLogDetail | undefined, ApiError> {
  return useQuery({
    queryKey: logsKeys.dailyLogDetail(id ?? ''),
    queryFn: async () => {
      const { data } = await api.GET('/daily-logs/{id}', {
        params: { path: { id: id as string } },
      });
      return data?.data;
    },
    enabled: Boolean(id),
  });
}

/**
 * `POST /daily-logs/{id}/certify` (`logs.certify`). Q26: admin haydovchi
 * o'rniga sertifikatlay olmaydi — egasi bo'lmagan chaqiruvchi `403` oladi.
 * Imzo manbai `signature_key`/`signature_id`/default'dan; hech biri bo'lmasa
 * `409 LOG_NOT_READY`.
 */
export function useDailyLogCertify() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body = {} }: { id: string; body?: CertifyRequest }) => {
      const { data } = await api.POST('/daily-logs/{id}/certify', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: logsKeys.dailyLogDetail(id) });
      void queryClient.invalidateQueries({ queryKey: logsKeys.dailyLogsByDriver() });
    },
  });
}

/**
 * `POST /daily-logs/{id}/events` (`logs.add_event`) — haydovchining **o'z**
 * tuzatishi (`origin=driver_edit`). ⚠️ Admin panel UI bu hook'ni to'g'ridan-
 * to'g'ri chaqirmaydi: `tz.md` §5.3 (FMCSA §395.30) va F100 bo'yicha admin
 * hech qachon logni bevosita tahrirlamaydi — buning o'rniga
 * `logEditRequests.ts`dagi `useLogEditRequestPropose` ishlatiladi. Hook shu
 * yerda faqat swagger endpointi to'liq qamrov uchun mavjud.
 */
export function useLogAddEvent() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: LogEventCreate }) => {
      const { data } = await api.POST('/daily-logs/{id}/events', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: logsKeys.dailyLogDetail(id) });
    },
  });
}

/**
 * `GET /daily-logs/{id}/pdf` (`logs.export`) — PDF **blob** sifatida.
 * `Authorization` header'i oddiy `<a href>` bilan yuborilmaydi; shu sabab
 * `client.ts`dagi `authMiddleware` (bu yo'l public emas) headerni avtomatik
 * qo'shadigan `openapi-fetch` chaqiruvi ishlatiladi, so'ng chaqiruvchi
 * `URL.createObjectURL(blob)` bilan `<iframe>`/`<a download>` orqali
 * ko'rsatadi (fe-api §8).
 */
export function useDailyLogPdf() {
  return useMutation({
    mutationFn: async (id: string) => {
      const { data } = await api.GET('/daily-logs/{id}/pdf', {
        params: { path: { id } },
        parseAs: 'blob',
      });
      return data as Blob;
    },
  });
}
