/**
 * Company — TanStack Query hooklari (Bosqich 8.1, fe-api §3,
 * `docs/tz/07-13-settings-admin.md` §7.13.1/§7.13.5).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET /company`, `PATCH /company`, `GET /company/history`.
 * Ruxsatlar: `company.read`, `company.update`, `company.history.view`.
 *
 * Logo yuklash — mavjud presign oqimi orqali (`api/queries/files.ts`,
 * `presignFile({kind: 'logo', ...})`); bu faylda alohida logo mutatsiyasi
 * **yozilmagan**. Ekran presign orqali `key` oladi, so'ng `useCompanyUpdate`
 * bilan `{logo_key: key}` yuboradi.
 *
 * ⚠️ `GET /company` ilova yuklanganda `app/bootstrap.ts` orqali ham (Zustand
 * company kontekstiga, `api/auth.api.ts` dagi imperativ `fetchCompany()` bilan)
 * chaqiriladi. Bu ikkalasi **mustaqil**: bootstrap — bir martalik ilova holati,
 * `useCompany()` — Settings › Company ekranining server-state manbai (o'z keshi
 * bilan). F145 [MUST]: `unit_system`/`regulation_profile` o'zgarganda ekran
 * tasdiq dialogi ko'rsatib, saqlangandan keyin butun UI qayta formatlanishi
 * uchun `GET /me`ni (bootstrap qatlami orqali) qayta so'raydi — bu ekran
 * qatlamining mas'uliyati, bu fayl faqat mutatsiyani bajaradi.
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type {
  Company,
  CompanyHistoryEntry,
  CompanyHistoryParams,
  CompanyUpdate,
  ListResponse,
} from '@/api/types';
import type { ApiError } from '@/lib/errors';

/** Query key fabrikasi — `['company', <tur>, ...]` (fe-conventions §3). */
export const companyKeys = {
  all: ['company'] as const,
  detail: () => [...companyKeys.all, 'detail'] as const,
  history: () => [...companyKeys.all, 'history'] as const,
  historyList: (params: CompanyHistoryParams) =>
    [...companyKeys.history(), 'list', params] as const,
};

/** `GET /company` (`company.read`) — Settings › Company profili (7.13.1). */
export function useCompany(options: { enabled?: boolean } = {}): UseQueryResult<Company, ApiError> {
  return useQuery({
    queryKey: companyKeys.detail(),
    queryFn: async () => {
      const { data } = await api.GET('/company', {});
      return data?.data ?? {};
    },
    enabled: options.enabled ?? true,
  });
}

/**
 * `PATCH /company` (`company.update`, `Idempotency-Key` avtomatik) — profil/
 * sozlamalarni yangilash (7.13.1). Tashlab ketilgan maydonlar o'zgarmaydi;
 * `settings` yuborilsa **butun** hujjatni almashtiradi (swagger: "settings
 * replaces the whole settings document").
 */
export function useCompanyUpdate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: CompanyUpdate) => {
      const { data } = await api.PATCH('/company', { body });
      return data?.data;
    },
    onSuccess: (company) => {
      if (company) {
        queryClient.setQueryData(companyKeys.detail(), company);
      }
      void queryClient.invalidateQueries({ queryKey: companyKeys.detail() });
    },
  });
}

/**
 * `GET /company/history` (`company.history.view`) — Company history journali
 * (7.13.5, F149). Backend `client IP`ni hech qachon qaytarmaydi (swagger).
 * Filtrlar: `table`, `action`, `record_id`, `user`, `from`, `to` + sahifalash.
 * Dizayndagi uchta mustaqil qidiruv o'rniga ✅ bitta `user` + `table` filtri
 * (§16 F149) — bu tanlov ekran qatlamida amalga oshiriladi.
 */
export function useCompanyHistory(
  params: CompanyHistoryParams = {},
  options: { enabled?: boolean } = {},
): UseQueryResult<ListResponse<CompanyHistoryEntry>, ApiError> {
  return useQuery({
    queryKey: companyKeys.historyList(params),
    queryFn: async () => {
      const { data } = await api.GET('/company/history', { params: { query: params } });
      return data ?? {};
    },
    enabled: options.enabled ?? true,
  });
}
