/**
 * Drivers — TanStack Query hooklari (2.1, fe-api §3/§7).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET/POST /drivers`, `GET/PATCH/DELETE /drivers/{id}`,
 * `POST /drivers/{id}/activate|deactivate|reset-password`,
 * `GET /drivers/{id}/license` (PII reveal), `GET/POST/DELETE
 * /drivers/{id}/co-drivers(/{co_driver_id})`, `GET /drivers/{id}/activities`,
 * `GET /drivers/export`, `GET /drivers/import-template`, `POST /drivers/import`.
 *
 * Ruxsatlar: `drivers.read/create/update/delete/activate/deactivate/
 * reset_password/license.view/manage_co_drivers/export/import`.
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import { isApiError, type ApiError } from '@/lib/errors';
import type {
  CoDriver,
  CoDriverCreate,
  Driver,
  DriverActivity,
  DriverCreate,
  DriverLicense,
  DriverResetPasswordResult,
  DriverStatusChange,
  DriverUpdate,
  DriversExportParams,
  DriversImportTemplateParams,
  DriversListParams,
  ImportResult,
  ListResponse,
} from '@/api/types';

/** Query key fabrikasi — `['drivers', <tur>, ...]`. */
export const driversKeys = {
  all: ['drivers'] as const,
  lists: () => [...driversKeys.all, 'list'] as const,
  list: (params: DriversListParams) => [...driversKeys.lists(), params] as const,
  details: () => [...driversKeys.all, 'detail'] as const,
  detail: (id: string) => [...driversKeys.details(), id] as const,
  activities: (id: string) => [...driversKeys.all, 'activities', id] as const,
  coDrivers: (id: string) => [...driversKeys.all, 'co-drivers', id] as const,
};

/** `GET /drivers` (`drivers.read`) — `license_no` hech qachon ochiq qaytmaydi. */
export function useDriversList(
  params: DriversListParams = {},
): UseQueryResult<ListResponse<Driver>, ApiError> {
  return useQuery({
    queryKey: driversKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/drivers', { params: { query: params } });
      return data ?? {};
    },
  });
}

/** `GET /drivers/{id}` (`drivers.read`). Cross-tenant → 404. */
export function useDriver(id: string | undefined): UseQueryResult<Driver | undefined, ApiError> {
  return useQuery({
    queryKey: driversKeys.detail(id ?? ''),
    queryFn: async () => {
      const { data } = await api.GET('/drivers/{id}', {
        params: { path: { id: id as string } },
      });
      return data?.data;
    },
    enabled: Boolean(id),
  });
}

/**
 * `POST /drivers` (`drivers.create`). Parol maydoni yo'q — invitation
 * havolasi yuboriladi (F86/qaror 21).
 */
export function useDriverCreate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: DriverCreate) => {
      const { data } = await api.POST('/drivers', { body });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: driversKeys.lists() });
    },
  });
}

/** `PATCH /drivers/{id}` (`drivers.update`). `status`/rol shu yerda o'zgarmaydi. */
export function useDriverUpdate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: DriverUpdate }) => {
      const { data } = await api.PATCH('/drivers/{id}', { params: { path: { id } }, body });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: driversKeys.lists() });
      void queryClient.invalidateQueries({ queryKey: driversKeys.detail(id) });
    },
  });
}

/** `DELETE /drivers/{id}` (`drivers.delete`) — soft delete, sessiyalar bekor. */
export function useDriverDelete() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      await api.DELETE('/drivers/{id}', { params: { path: { id } } });
    },
    onSuccess: (_data, id) => {
      void queryClient.invalidateQueries({ queryKey: driversKeys.lists() });
      void queryClient.removeQueries({ queryKey: driversKeys.detail(id) });
    },
  });
}

/** `POST /drivers/{id}/activate` (`drivers.activate`). `reason` ixtiyoriy. */
export function useDriverActivate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, reason }: { id: string; reason?: string }) => {
      const body: DriverStatusChange | undefined = reason ? { reason } : undefined;
      const { data } = await api.POST('/drivers/{id}/activate', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: driversKeys.lists() });
      void queryClient.invalidateQueries({ queryKey: driversKeys.detail(id) });
    },
  });
}

/**
 * `POST /drivers/{id}/deactivate` (`drivers.deactivate`) — har bir sessiya
 * darhol bekor qilinadi.
 */
export function useDriverDeactivate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, reason }: { id: string; reason?: string }) => {
      const body: DriverStatusChange | undefined = reason ? { reason } : undefined;
      const { data } = await api.POST('/drivers/{id}/deactivate', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: driversKeys.lists() });
      void queryClient.invalidateQueries({ queryKey: driversKeys.detail(id) });
    },
  });
}

/**
 * `POST /drivers/{id}/reset-password` (`drivers.reset_password`) — ✅
 * `Send password reset` (F7.3.4): parol emas, 72 soatlik invitation havolasi
 * qayta yuboriladi (email/SMS), oldingi havola va barcha sessiyalar bekor.
 */
export function useDriverResetPassword() {
  return useMutation({
    mutationFn: async (id: string): Promise<DriverResetPasswordResult> => {
      const { data } = await api.POST('/drivers/{id}/reset-password', {
        params: { path: { id } },
      });
      return data?.data ?? {};
    },
  });
}

/**
 * `GET /drivers/{id}/license` (`drivers.license.view`, F87) — 30 soniyalik
 * "Reveal" oqimi uchun **mutatsiya sifatida** ishlatiladi (bosilganda so'raladi,
 * doimiy keshda saqlanmaydi). Har chaqiruv `audit_log`ga `license_reveal`
 * sifatida yoziladi (backend tomonida).
 */
export function useDriverLicenseReveal() {
  return useMutation({
    mutationFn: async (id: string): Promise<DriverLicense> => {
      const { data } = await api.GET('/drivers/{id}/license', { params: { path: { id } } });
      return data?.data ?? {};
    },
  });
}

/** `GET /drivers/{id}/activities` (`drivers.read`) — `audit_log` asosida. */
export function useDriverActivities(
  id: string | undefined,
): UseQueryResult<ListResponse<DriverActivity>, ApiError> {
  return useQuery({
    queryKey: driversKeys.activities(id ?? ''),
    queryFn: async () => {
      const { data } = await api.GET('/drivers/{id}/activities', {
        params: { path: { id: id as string } },
      });
      return data ?? {};
    },
    enabled: Boolean(id),
  });
}

/** `GET /drivers/{id}/co-drivers` (`drivers.read`) — juftlik ikki tomonda ham. */
export function useDriverCoDrivers(
  id: string | undefined,
): UseQueryResult<ListResponse<CoDriver>, ApiError> {
  return useQuery({
    queryKey: driversKeys.coDrivers(id ?? ''),
    queryFn: async () => {
      const { data } = await api.GET('/drivers/{id}/co-drivers', {
        params: { path: { id: id as string } },
      });
      return data ?? {};
    },
    enabled: Boolean(id),
  });
}

/** `POST /drivers/{id}/co-drivers` (`drivers.manage_co_drivers`). */
export function useDriverCoDriverLink() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: CoDriverCreate }) => {
      const { data } = await api.POST('/drivers/{id}/co-drivers', {
        params: { path: { id } },
        body,
      });
      return data ?? {};
    },
    onSuccess: (_data, { id, body }) => {
      void queryClient.invalidateQueries({ queryKey: driversKeys.coDrivers(id) });
      void queryClient.invalidateQueries({ queryKey: driversKeys.coDrivers(body.co_driver_id) });
    },
  });
}

/**
 * `DELETE /drivers/{id}/co-drivers/{co_driver_id}` (`drivers.manage_co_drivers`)
 * — path shakli (swaggerda kolleksiya shakli `?co_driver_id=` ham bor,
 * ikkalasi ham bitta `driver_pairs` yozuvini soft-delete qiladi).
 */
export function useDriverCoDriverUnlink() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, coDriverId }: { id: string; coDriverId: string }) => {
      await api.DELETE('/drivers/{id}/co-drivers/{co_driver_id}', {
        params: { path: { id, co_driver_id: coDriverId } },
      });
    },
    onSuccess: (_data, { id, coDriverId }) => {
      void queryClient.invalidateQueries({ queryKey: driversKeys.coDrivers(id) });
      void queryClient.invalidateQueries({ queryKey: driversKeys.coDrivers(coDriverId) });
    },
  });
}

/** `GET /drivers/export` (`drivers.export`) — `license_no` doim maskalangan. */
export function useDriversExport() {
  return useMutation({
    mutationFn: async (params: DriversExportParams = {}) => {
      const { data } = await api.GET('/drivers/export', {
        params: { query: params },
        parseAs: 'blob',
      });
      return data as Blob;
    },
  });
}

/** `GET /drivers/import-template` (`drivers.import`). */
export function useDriversImportTemplate() {
  return useMutation({
    mutationFn: async (params: DriversImportTemplateParams = {}) => {
      const { data } = await api.GET('/drivers/import-template', {
        params: { query: params },
        parseAs: 'blob',
      });
      return data as Blob;
    },
  });
}

/**
 * Swagger `422` javobini ham `200` bilan bir xil `ImportResultEnvelope`
 * (`{data:{imported,total,errors[]}}`) deb belgilaydi (D-f9, `units.ts`dagi
 * kabi) — `client.ts`ning `errorMiddleware`si buni taniydi va butun JSON
 * tanani `ApiError.payload`ga saqlaydi.
 */
function isImportResultPayload(payload: unknown): payload is { data?: ImportResult } {
  return typeof payload === 'object' && payload !== null && 'data' in payload;
}

/**
 * `POST /drivers/import` (`drivers.import`, multipart) — all-or-nothing.
 *
 * `422` va `200` bir xil `ImportResult` qaytaradi — ekran `result.errors`ga
 * qarab jadval yoki muvaffaqiyat holatini ko'rsatadi (misol `units.ts`da).
 */
export function useDriversImport() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (file: File): Promise<ImportResult> => {
      const formData = new FormData();
      formData.append('file', file);
      try {
        const { data } = await api.POST('/drivers/import', {
          body: formData as unknown as { file: string },
        });
        return data?.data ?? {};
      } catch (err) {
        if (isApiError(err) && err.status === 422 && isImportResultPayload(err.payload)) {
          return err.payload.data ?? {};
        }
        throw err;
      }
    },
    onSuccess: (result) => {
      if ((result.imported ?? 0) > 0) {
        void queryClient.invalidateQueries({ queryKey: driversKeys.lists() });
      }
    },
  });
}
