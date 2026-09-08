/**
 * Reports — TanStack Query hooklari (Bosqich 6.1, fe-api §9, `docs/tz/07-8-reports.md`).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET /reports/activity`, `GET /reports/distance-by-region`,
 * `GET /reports/uncertified-logs`, `GET /reports/export-jobs`,
 * `POST /reports/export-jobs`, `GET /reports/export-jobs/{id}`.
 *
 * Ruxsatlar: `reports.read` (barcha `GET`), `reports.export` (`POST /reports/export-jobs`).
 *
 * ⚠️ **`regulation_profile` — 7 qiymat** (swagger `companies_dto.Company`/`company_dto.Company`,
 * D27): `us_fmcsa`, `generic`, `canada`, `texas`, `california`, `alaska`, `hawaii`. Ekran
 * nomi almashinuvi **faqat `us_fmcsa`** profilida bo'ladi:
 * - Distance by Region (7.8.2, F122) → `us_fmcsa`: "IFTA Report", boshqa 6 tasi: "Distance by
 *   Region".
 * - Regulator Export (7.8.3, F125) → `us_fmcsa`: "FMCSA Report", boshqa 6 tasi: "Regulator
 *   Export".
 * Bu fayl profilni bilmaydi (`GET /me`/`company` orqali keladi) — i18n kalit tanlovi ekran
 * qatlamining ishi. `POST /reports/export-jobs {type:"regulator"}` `us_fmcsa` (va qolgan
 * FMCSA-shaklidagi profillar) uchun **501 FEATURE_DISABLED** qaytarishi mumkin — swagger
 * tavsifi: "every FMCSA profile answers 501 FEATURE_DISABLED until the FMCSA output file and
 * web service ship" (F127). `generic` profilda PDF+CSV darhol ishlaydi. Ekran bu holatni
 * alohida xabar bilan ko'rsatishi kerak — umumiy `errorMiddleware` `501`ni maxsus
 * belgilamaydi, xato kodi `FEATURE_DISABLED` bo'lib qaytadi.
 *
 * ⚠️ **Uncertified Logs `Send reminder` (7.8.5, F128) uchun backend endpointi yo'q**
 * (swagger'da `/notifications` faqat `GET`/`read`). `docs/tz/16-17-registry-open-questions.md`
 * D29 ga qayd etildi — bu faylda mos mutatsiya **yozilmagan**, ekran agenti tugmani
 * `disabled` holatda qoldirishi kerak.
 */
import { useEffect, useRef, useState } from 'react';

import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type {
  ActivityRow,
  ExportJob,
  ExportJobCreate,
  ExportJobsListParams,
  ListResponse,
  ReportsActivityParams,
  ReportsDistanceByRegionParams,
  ReportsUncertifiedLogsParams,
  RegionDistanceRow,
  DistanceByRegionMeta,
  UncertifiedLog,
} from '@/api/types';

/** Query key fabrikasi — `['reports', <tur>, ...]` (fe-conventions §3). */
export const reportsKeys = {
  all: ['reports'] as const,
  activity: (params: ReportsActivityParams) => [...reportsKeys.all, 'activity', params] as const,
  distanceByRegion: (params: ReportsDistanceByRegionParams) =>
    [...reportsKeys.all, 'distance-by-region', params] as const,
  uncertifiedLogs: (params: ReportsUncertifiedLogsParams) =>
    [...reportsKeys.all, 'uncertified-logs', params] as const,
  exportJobs: () => [...reportsKeys.all, 'export-jobs'] as const,
  exportJobsList: (params: ExportJobsListParams) =>
    [...reportsKeys.exportJobs(), 'list', params] as const,
  exportJobDetail: (id: string) => [...reportsKeys.exportJobs(), 'detail', id] as const,
};

/** `GET /reports/activity` (`reports.read`) — Activity Report, `subject` tabi (7.8.1). */
export function useReportsActivity(
  params: ReportsActivityParams,
  options: { enabled?: boolean } = {},
): UseQueryResult<ListResponse<ActivityRow>, ApiError> {
  return useQuery({
    queryKey: reportsKeys.activity(params),
    queryFn: async () => {
      const { data } = await api.GET('/reports/activity', { params: { query: params } });
      return data ?? {};
    },
    enabled: options.enabled ?? true,
  });
}

/** `GET /reports/distance-by-region` javobi — `meta` sahifalash emas, davr xulosasi. */
export interface DistanceByRegionResult {
  data: RegionDistanceRow[];
  meta?: DistanceByRegionMeta;
}

/**
 * `GET /reports/distance-by-region` (`reports.read`) — IFTA/Distance by Region (7.8.2).
 * F123: hisobot kunlik agregatdan (`unit_region_distance_daily`) darhol tayyor — "5-kunda
 * tayyor" ogohlantirishi UI'da ko'rsatilmaydi.
 */
export function useReportsDistanceByRegion(
  params: ReportsDistanceByRegionParams,
  options: { enabled?: boolean } = {},
): UseQueryResult<DistanceByRegionResult, ApiError> {
  return useQuery({
    queryKey: reportsKeys.distanceByRegion(params),
    queryFn: async () => {
      const { data } = await api.GET('/reports/distance-by-region', {
        params: { query: params },
      });
      return (data ?? { data: [] }) as DistanceByRegionResult;
    },
    enabled: options.enabled ?? true,
  });
}

/**
 * `GET /reports/uncertified-logs` (`reports.read`) — Uncertified Logs (7.8.5, F128).
 * 8 kundan eskirgan kunlar ham shu ro'yxatda ko'rinadi (Q19.1).
 */
export function useReportsUncertifiedLogs(
  params: ReportsUncertifiedLogsParams = {},
  options: { enabled?: boolean } = {},
): UseQueryResult<ListResponse<UncertifiedLog>, ApiError> {
  return useQuery({
    queryKey: reportsKeys.uncertifiedLogs(params),
    queryFn: async () => {
      const { data } = await api.GET('/reports/uncertified-logs', { params: { query: params } });
      return data ?? {};
    },
    enabled: options.enabled ?? true,
  });
}

/**
 * `GET /reports/export-jobs` (`reports.read`) — Export Jobs ro'yxati (7.8.7, F129).
 * `mine: true` — default (o'z eksportlarim), `Show all` toggle `mine: false` yuboradi.
 */
export function useExportJobsList(
  params: ExportJobsListParams = { mine: true },
): UseQueryResult<ListResponse<ExportJob>, ApiError> {
  return useQuery({
    queryKey: reportsKeys.exportJobsList(params),
    queryFn: async () => {
      const { data } = await api.GET('/reports/export-jobs', { params: { query: params } });
      return data ?? {};
    },
  });
}

/**
 * `POST /reports/export-jobs` (`reports.export`, `Idempotency-Key` avtomatik) — asinxron
 * eksport navbatga qo'yiladi, `202 {id, status:"queued"}` qaytaradi (fe-api §9). Ekran bu
 * javobdagi `id` bilan `useExportJob(id)` orqali pollingni boshlaydi.
 *
 * Ochiq (`queued`/`running`) job bor ekan — bir xil `type`+`params` bilan yangi so'rov
 * yuborilmasligi kerak (fe-api §9); bu tekshiruv ekran qatlamida (`useExportJobsList` dan
 * olingan ro'yxat ustida) amalga oshiriladi, bu yerda majburlanmaydi.
 */
export function useExportJobCreate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: ExportJobCreate) => {
      const { data } = await api.POST('/reports/export-jobs', { body });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: reportsKeys.exportJobs() });
    },
  });
}

/** Poll oralig'i: 2s → 5s → 10s (o'sib boradi), keyin barqaror 10s (fe-api §9). */
export const EXPORT_JOB_POLL_INTERVALS_MS = [2_000, 5_000, 10_000] as const;

/** Poll maksimal davomiyligi — 5 daqiqa (fe-api §9). */
export const EXPORT_JOB_POLL_MAX_DURATION_MS = 5 * 60 * 1000;

/**
 * `UseQueryResult` — v5 da holat bo'yicha diskriminatsiya qilingan **union** tip
 * (`interface ... extends` bilan kengaytirilmaydi), shuning uchun kesishma orqali.
 */
export type UseExportJobResult = UseQueryResult<ExportJob | undefined, ApiError> & {
  /**
   * `true` — 5 daqiqalik poll oynasi tugadi va job hali `queued`/`running` holatida qoldi.
   * Ekran bu holatda pollingni to'xtatib, «hali tayyor emas, /reports/exports sahifasini
   * tekshiring» degan xabar ko'rsatishi kerak (job fonda davom etadi, tayyor bo'lganda
   * `notifications` kanali orqali bildirishnoma keladi).
   */
  pollingTimedOut: boolean;
};

/**
 * `GET /reports/export-jobs/{id}` (`reports.read`) — export job holatini kuzatish (7.8.3/7.8.7,
 * fe-api §9). **Bosqichning eng muhim hooki.**
 *
 * Poll strategiyasi — TanStack Query `refetchInterval` funksiyasi orqali (o'z `setTimeout`
 * yozilmagan, komponent unmount bo'lganda TanStack avtomatik tozalaydi):
 * - 1-so'rovdan keyin 2s, 2-dan keyin 5s, 3-dan keyin va undan keyin barqaror 10s kutiladi.
 * - `status: "done"` yoki `"failed"` (swagger enum, boshqa qiymat yo'q) — polling **to'xtaydi**.
 * - So'rovlar boshlanganidan 5 daqiqadan oshsa — polling **to'xtaydi**, `pollingTimedOut: true`.
 *
 * `status: "done"` bo'lganda `data.download_url` — presigned, **24 soat** amal qiladi
 * (`data.expires_at`, swagger: "the download stops working" — Q75). Muddati o'tgan holatni
 * `isExportJobDownloadExpired(data)` bilan tekshiring — `download_url` maydoni saqlanib
 * qolishi mumkin, lekin havola ishlamay qoladi.
 *
 * ```tsx
 * const { data: job, pollingTimedOut, isLoading } = useExportJob(jobId);
 * if (isLoading) return <Skeleton />;
 * if (job?.status === 'failed') return <ErrorState message={job.error} />;
 * if (job?.status === 'done') {
 *   return isExportJobDownloadExpired(job)
 *     ? <Button disabled>Link expired — re-run export</Button>
 *     : <a href={job.download_url} target="_blank" rel="noopener">Download</a>;
 * }
 * if (pollingTimedOut) return <p>Still preparing — check Reports › Exports later.</p>;
 * return <ProgressIndicator status={job?.status} />;
 * ```
 */
export function useExportJob(
  id: string | undefined,
  options: { enabled?: boolean } = {},
): UseExportJobResult {
  // Poll boshlanish vaqti — `id` almashganda (yangi job kuzatilganda) qayta boshlanadi.
  // Render vaqtida ref'ni yangilash — React'ning "prop o'zgarganda holatni moslashtirish"
  // naqshi, faqat useState o'rniga useRef (qayta render kerak emas, faqat keyingi
  // `refetchInterval` chaqiruvida to'g'ri qiymat kerak).
  const idRef = useRef(id);
  const startedAtRef = useRef(Date.now());
  if (idRef.current !== id) {
    idRef.current = id;
    startedAtRef.current = Date.now();
  }

  const query = useQuery({
    queryKey: reportsKeys.exportJobDetail(id ?? ''),
    queryFn: async () => {
      const { data } = await api.GET('/reports/export-jobs/{id}', {
        params: { path: { id: id as string } },
      });
      return data?.data;
    },
    enabled: Boolean(id) && (options.enabled ?? true),
    refetchInterval: (currentQuery) => {
      const job = currentQuery.state.data;
      if (job?.status === 'done' || job?.status === 'failed') {
        return false;
      }
      if (Date.now() - startedAtRef.current >= EXPORT_JOB_POLL_MAX_DURATION_MS) {
        return false;
      }
      const fetchCount = currentQuery.state.dataUpdateCount;
      const stageIndex = Math.max(
        0,
        Math.min(fetchCount - 1, EXPORT_JOB_POLL_INTERVALS_MS.length - 1),
      );
      return EXPORT_JOB_POLL_INTERVALS_MS[stageIndex];
    },
  });

  // "Hali tayyor emas" holati — faqat UI xabari uchun, TanStack pollingiga ta'sir qilmaydi
  // (yuqoridagi `refetchInterval` allaqachon o'zi to'xtatadi). Alohida `setTimeout` shu
  // yerda faqat React holatini yangilash uchun kerak — unmount/`id` almashganda tozalanadi.
  const [pollingTimedOut, setPollingTimedOut] = useState(false);
  const statusRef = useRef(query.data?.status);
  statusRef.current = query.data?.status;

  useEffect(() => {
    setPollingTimedOut(false);
    if (!id) {
      return;
    }
    const timer = setTimeout(() => {
      if (statusRef.current !== 'done' && statusRef.current !== 'failed') {
        setPollingTimedOut(true);
      }
    }, EXPORT_JOB_POLL_MAX_DURATION_MS);
    return () => clearTimeout(timer);
  }, [id]);

  return { ...query, pollingTimedOut };
}

/**
 * `export_job.download_url` muddati tugaganini tekshiradi (fe-api §9, Q75 — 24 soat).
 * Ro'yxatda (`Export Jobs`, 7.8.7) muddati o'tgan job'da `Download` o'rniga
 * «Link expired — re-run export» ko'rsatiladi.
 */
export function isExportJobDownloadExpired(
  job: Pick<ExportJob, 'download_url' | 'expires_at'> | undefined,
): boolean {
  if (!job?.download_url || !job.expires_at) {
    return false;
  }
  return Date.parse(job.expires_at) <= Date.now();
}
