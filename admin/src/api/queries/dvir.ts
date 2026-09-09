/**
 * DVIR — TanStack Query hooklari (5.1, fe-api §3/§7, `docs/tz/07-5-dvir-maintenance.md` §7.5).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET /dvir-reports`, `GET /dvir-reports/pending-certification`,
 * `GET /dvir-reports/{id}`, `POST /dvir-reports/{id}/repair`,
 * `POST /dvir-reports/{id}/certify`, `GET /dvir-reports/{id}/pdf`.
 *
 * Ruxsatlar (`docs/api/permissions.md`): `dvir.read/create/repair/certify/export`.
 *
 * ⚠️ **Admin DVIR yaratmaydi** (F107, `tz.md` Q31). Swagger'da `POST /dvir-reports`
 * mavjud, lekin bu — faqat mobil, haydovchi tomonidan chaqiriladigan endpoint
 * (`x-permission: dvir.create`, tavsif: «mobile, driver only»; admin chaqirsa
 * `403 DVIR_ADMIN_CREATE_DENIED»). Shu sabab bu faylda `useDvirCreate` hooki
 * **yo'q** — `dvir.create` ruxsat kaliti faqat menyu/marshrut ko'rinishini
 * yashirish uchun ishlatiladi, mutatsiya yozilmaydi.
 *
 * **F106 — 6 holatli status state machine (backend enum'i, dizayndagi 7
 * qiymatdan farqli — moslashtirish jadvali `docs/tz/07-5-dvir-maintenance.md`da):**
 * 1. `draft` — mobilda lokal, admin ro'yxatida ko'rsatilmaydi
 * 2. `submitted_no_defects`
 * 3. `submitted_defects_found`
 * 4. `repaired`
 * 5. `certified`
 * 6. `closed_no_certification` — unit inactive bo'lganda 7 kundan keyin avtomatik yopiladi
 *
 * ⚠️ Fotolar (`Defect.photo_keys`) va imzolar (`driver_signature_key`,
 * `mechanic_signature_key`, `certification_signature_key`) — obyekt-saqlash
 * **kaliti** (masalan `c1/signature/2026/09/06/sig.png`), URL emas (Bosqich 3
 * `signature_key` bilan bir xil naqsh). Ko'rish uchun ekran agenti bu kalitni
 * fayl ko'rish endpointiga/`files` prefiksiga aylantiradi — bu hook qatlami
 * kalitni xom holicha qaytaradi.
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import { unitsKeys } from '@/api/queries/units';
import { assertBlobType } from '@/lib/download';
import type { ApiError } from '@/lib/errors';
import type {
  DvirCertify,
  DvirPendingCertificationParams,
  DvirRepair,
  DvirReport,
  DvirReportsListParams,
  ListResponse,
} from '@/api/types';

/** Query key fabrikasi — `['dvir', <tur>, ...]` (fe-conventions §3). */
export const dvirKeys = {
  all: ['dvir'] as const,
  lists: () => [...dvirKeys.all, 'list'] as const,
  list: (params: DvirReportsListParams) => [...dvirKeys.lists(), params] as const,
  pendingCertifications: () => [...dvirKeys.all, 'pending-certification'] as const,
  pendingCertification: (params: DvirPendingCertificationParams) =>
    [...dvirKeys.pendingCertifications(), params] as const,
  details: () => [...dvirKeys.all, 'detail'] as const,
  detail: (id: string) => [...dvirKeys.details(), id] as const,
};

/** `GET /dvir-reports` — `All` tab, filtr/sort/pagination bilan (`dvir.read`). */
export function useDvirList(
  params: DvirReportsListParams = {},
): UseQueryResult<ListResponse<DvirReport>, ApiError> {
  return useQuery({
    queryKey: dvirKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/dvir-reports', { params: { query: params } });
      return data ?? {};
    },
  });
}

/**
 * `GET /dvir-reports/pending-certification` — `Pending certification` tab
 * (`dvir.read`). Faqat `unit_id` filtri.
 */
export function useDvirPendingCertification(
  params: DvirPendingCertificationParams = {},
): UseQueryResult<ListResponse<DvirReport>, ApiError> {
  return useQuery({
    queryKey: dvirKeys.pendingCertification(params),
    queryFn: async () => {
      const { data } = await api.GET('/dvir-reports/pending-certification', {
        params: { query: params },
      });
      return data ?? {};
    },
  });
}

/** `GET /dvir-reports/{id}` — detal (`dvir.read`). Cross-tenant → 404. */
export function useDvirReport(
  id: string | undefined,
): UseQueryResult<DvirReport | undefined, ApiError> {
  return useQuery({
    queryKey: dvirKeys.detail(id ?? ''),
    queryFn: async () => {
      const { data } = await api.GET('/dvir-reports/{id}', {
        params: { path: { id: id as string } },
      });
      return data?.data;
    },
    enabled: Boolean(id),
  });
}

/**
 * `POST /dvir-reports/{id}/repair` (`dvir.repair`) — `submitted_defects_found`
 * → `repaired`. Modal: mexanik izohi (majburiy), invoice fayl (ixtiyoriy, §10
 * `kind=invoice`). Boshqa holatdan chaqirilsa `409 DVIR_INVALID_TRANSITION`.
 */
export function useDvirRepair() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: DvirRepair }) => {
      const { data } = await api.POST('/dvir-reports/{id}/repair', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: dvirKeys.lists() });
      void queryClient.invalidateQueries({ queryKey: dvirKeys.detail(id) });
      // `repaired` — sertifikatlash kutilayotgan hisobot: pending ro'yxati o'zgaradi.
      void queryClient.invalidateQueries({ queryKey: dvirKeys.pendingCertifications() });
    },
  });
}

/**
 * `POST /dvir-reports/{id}/certify` (`dvir.certify`) — `repaired` →
 * `certified`. Boshqa holatdan chaqirilsa `409 DVIR_INVALID_TRANSITION`.
 * Kritik nuqsonli hisobot sertifikatlanganda unit `out_of_service`dan chiqadi
 * (F108) — shuning uchun units ro'yxati ham invalidatsiya qilinadi.
 */
export function useDvirCertify() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: DvirCertify }) => {
      const { data } = await api.POST('/dvir-reports/{id}/certify', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: dvirKeys.lists() });
      void queryClient.invalidateQueries({ queryKey: dvirKeys.detail(id) });
      void queryClient.invalidateQueries({ queryKey: dvirKeys.pendingCertifications() });
      void queryClient.invalidateQueries({ queryKey: unitsKeys.all });
    },
  });
}

/**
 * `GET /dvir-reports/{id}/pdf` (`dvir.export`) — **Blob** sifatida yuklab
 * olinadi, `Authorization` header talab qiladi (`client.ts` middleware'idan
 * avtomatik) → oddiy `<a href>` ishlamaydi (fe-api §8 yuklab olish oqimi).
 * Javob `application/pdf` yoki (Chrome mavjud bo'lmasa) `text/html` bo'lishi
 * mumkin — TD12: `assertBlobType` xato sahifasini PDF sifatida saqlanishdan
 * to'xtatadi va `UnexpectedFileTypeError` tashlaydi.
 */
export function useDvirPdfDownload() {
  return useMutation({
    mutationFn: async (id: string) => {
      const { data } = await api.GET('/dvir-reports/{id}/pdf', {
        params: { path: { id } },
        parseAs: 'blob',
      });
      return assertBlobType(data as Blob, 'application/pdf');
    },
  });
}
