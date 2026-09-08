/**
 * HOS Policy — TanStack Query hooklari (Bosqich 8.1, fe-api §3,
 * `docs/tz/07-13-settings-admin.md` §7.13.3).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET /company/hos-policy`, `POST /company/hos-policy`.
 * Ruxsatlar: `hos_policy.read`, `hos_policy.update`.
 *
 * ⚠️ **Versiyalar tarixi uchun alohida "list versions" endpointi yo'q.**
 * `GET /company/hos-policy` faqat **joriy amaldagi** versiyani qaytaradi
 * (swagger: "the hos_policy_versions row whose effective_from is the latest
 * one not in the future"). Tarixni ko'rsatish uchun mavjud audit resursi
 * qayta ishlatiladi: `GET /company/history?action=hos_policy_change`
 * (`company_dto.HistoryEntry` — `field`/`old_value`/`new_value`/`edited_by`
 * diff uchun yetarli, swagger `action` enumida `hos_policy_change` bor).
 * Bu MVP yechimi — agar kelajakda alohida `hos_policy_versions` ro'yxat
 * endpointi qo'shilsa (masalan `effective_from`, `policy` to'liq hujjati bilan
 * bitta so'rovda), `useHosPolicyVersions` shu yerda almashtiriladi.
 *
 * F146/F147 (soat:daqiqa konvertatsiyasi, presetlar, tasdiq dialogi matni) —
 * ekran qatlamining ishi, bu fayl faqat ma'lumot va mutatsiyani beradi.
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type {
  CompanyHistoryEntry,
  CompanyHistoryParams,
  HosPolicy,
  HosPolicyCreate,
  ListResponse,
} from '@/api/types';
import type { ApiError } from '@/lib/errors';

/** `company_dto.HistoryEntry.action` qiymati — HOS policy versiyasi chiqarilganda. */
export const HOS_POLICY_HISTORY_ACTION = 'hos_policy_change';

/** Query key fabrikasi — `['hos-policy', <tur>, ...]` (fe-conventions §3). */
export const hosPolicyKeys = {
  all: ['hos-policy'] as const,
  current: () => [...hosPolicyKeys.all, 'current'] as const,
  versions: () => [...hosPolicyKeys.all, 'versions'] as const,
  versionsList: (params: CompanyHistoryParams) =>
    [...hosPolicyKeys.versions(), 'list', params] as const,
};

/**
 * `GET /company/hos-policy` (`hos_policy.read`) — joriy amaldagi siyosat
 * (7.13.3). Kompaniyada saqlangan versiya bo'lmasa backend FMCSA 70/8
 * defaultiga tushadi (swagger, Q10.1) — bu holat ham shu javobda keladi.
 */
export function useHosPolicy(
  options: { enabled?: boolean } = {},
): UseQueryResult<HosPolicy, ApiError> {
  return useQuery({
    queryKey: hosPolicyKeys.current(),
    queryFn: async () => {
      const { data } = await api.GET('/company/hos-policy', {});
      return data?.data ?? {};
    },
    enabled: options.enabled ?? true,
  });
}

/**
 * `POST /company/hos-policy` (`hos_policy.update`, `Idempotency-Key`
 * avtomatik) — **yangi versiya yaratadi**, eskisini o'zgartirmaydi (F147,
 * Q10.1: retroaktiv violation paydo bo'lmaydi — `effective_from` o'tmishda
 * bo'lolmaydi). Muvaffaqiyatdan keyin joriy siyosat keshi va versiyalar
 * tarixi invalidatsiya qilinadi.
 */
export function useHosPolicyPublish() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: HosPolicyCreate) => {
      const { data } = await api.POST('/company/hos-policy', { body });
      return data?.data;
    },
    onSuccess: (policy) => {
      if (policy) {
        queryClient.setQueryData(hosPolicyKeys.current(), policy);
      }
      void queryClient.invalidateQueries({ queryKey: hosPolicyKeys.current() });
      void queryClient.invalidateQueries({ queryKey: hosPolicyKeys.versions() });
    },
  });
}

/**
 * HOS policy versiyalari tarixi — `GET /company/history` ustida
 * `action=hos_policy_change` bilan (yuqoridagi ⚠️ izohga qarang). `params`da
 * `action` berilsa e'tiborga olinmaydi — har doim shu qiymat bilan almashtiriladi.
 */
export function useHosPolicyVersions(
  params: Omit<CompanyHistoryParams, 'action'> = {},
  options: { enabled?: boolean } = {},
): UseQueryResult<ListResponse<CompanyHistoryEntry>, ApiError> {
  const query: CompanyHistoryParams = { ...params, action: HOS_POLICY_HISTORY_ACTION };
  return useQuery({
    queryKey: hosPolicyKeys.versionsList(query),
    queryFn: async () => {
      const { data } = await api.GET('/company/history', { params: { query } });
      return data ?? {};
    },
    enabled: options.enabled ?? true,
  });
}
