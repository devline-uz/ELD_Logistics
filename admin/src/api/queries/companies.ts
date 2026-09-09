/**
 * Super Admin — `/companies*` TanStack Query hooklari (9.15, §7.14).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET/POST /companies`, `PATCH /companies/{id}`, `PATCH /companies/{id}/subscription`.
 *
 * Ruxsat — `x-permission: super_admin` (rol emas, alohida bayroq, F33).
 * `PERM` katalogida kaliti yo'q — UI `useIsSuperAdmin()`/`can.isSuperAdmin`
 * bilan tekshiradi (fe-permissions §1).
 *
 * ⚠️ Backend bo'shlig'i (D55, `docs/tz/16-17-registry-open-questions.md`):
 * `GET /companies/{id}` yo'q — bitta kompaniyani olish faqat ro'yxat orqali.
 * Shu sabab Edit/Subscription formalari ro'yxat qatoridagi obyektni ishlatadi,
 * alohida `useCompany(id)` query'i yo'q.
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type {
  AdminCompaniesListParams,
  AdminCompany,
  AdminCompanyCreate,
  AdminCompanyCreated,
  AdminCompanyUpdate,
  ListResponse,
  SubscriptionUpdate,
} from '@/api/types';
import type { ApiError } from '@/lib/errors';

/** Query key fabrikasi — `['admin-companies', <tur>, ...]` (fe-conventions §3). */
export const adminCompaniesKeys = {
  all: ['admin-companies'] as const,
  lists: () => [...adminCompaniesKeys.all, 'list'] as const,
  list: (params: AdminCompaniesListParams) => [...adminCompaniesKeys.lists(), params] as const,
};

/** `GET /companies` — platforma tenant ro'yxati (`super_admin`). */
export function useAdminCompaniesList(
  params: AdminCompaniesListParams = {},
): UseQueryResult<ListResponse<AdminCompany>, ApiError> {
  return useQuery({
    queryKey: adminCompaniesKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/companies', { params: { query: params } });
      return data ?? {};
    },
  });
}

/**
 * `POST /companies` (`super_admin`, `Idempotency-Key` avtomatik) — yangi
 * tenant + FMCSA 70/8 default HOS policy + tizim rollari nusxasi + taklif
 * qilingan Administrator (72 soat). Taklif tokeni javobda qaytarilmaydi.
 */
export function useAdminCompanyCreate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: AdminCompanyCreate): Promise<AdminCompanyCreated | undefined> => {
      const { data } = await api.POST('/companies', { body });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: adminCompaniesKeys.lists() });
    },
  });
}

/** `PATCH /companies/{id}` (`super_admin`) — qisman yangilash. Noma'lum `id` → `404`. */
export function useAdminCompanyUpdate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({
      id,
      body,
    }: {
      id: string;
      body: AdminCompanyUpdate;
    }): Promise<AdminCompany | undefined> => {
      const { data } = await api.PATCH('/companies/{id}', { params: { path: { id } }, body });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: adminCompaniesKeys.lists() });
    },
  });
}

/**
 * `PATCH /companies/{id}/subscription` (`super_admin`) — MVP billing qo'lda:
 * platforma administratori to'lovdan keyin `subscription_end_at`ni uzaytiradi.
 * `grace` — muddat tugagandan keyingi 7 kun, `readonly` admin panelni
 * muzlatadi (haydovchi ilovasi HOS yozishda davom etadi).
 */
export function useAdminCompanySubscriptionUpdate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({
      id,
      body,
    }: {
      id: string;
      body: SubscriptionUpdate;
    }): Promise<AdminCompany | undefined> => {
      const { data } = await api.PATCH('/companies/{id}/subscription', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: adminCompaniesKeys.lists() });
    },
  });
}
