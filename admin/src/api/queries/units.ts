/**
 * Units — TanStack Query hooklari (2.1, fe-api §3/§7).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET/POST /units`, `GET/PATCH/DELETE /units/{id}`, `POST /units/{id}/activate`,
 * `POST /units/{id}/deactivate`, `POST /units/{id}/assign-driver`,
 * `GET /units/{id}/diagnostics`, `GET /units/{id}/history`, `GET /units/export`,
 * `GET /units/import-template`, `POST /units/import`.
 *
 * Ruxsatlar (`docs/api/permissions.md`): `units.read/create/update/delete/
 * activate/deactivate/assign_driver/diagnostics/export/import`.
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type {
  ListResponse,
  Unit,
  UnitAssignDriver,
  UnitCreate,
  UnitDiagnostics,
  UnitHistoryEntry,
  UnitHistoryParams,
  UnitUpdate,
  UnitsExportParams,
  UnitsImportTemplateParams,
  UnitsListParams,
  ImportResult,
} from '@/api/types';

/** Query key fabrikasi — `['units', <tur>, ...]` (fe-conventions §3). */
export const unitsKeys = {
  all: ['units'] as const,
  lists: () => [...unitsKeys.all, 'list'] as const,
  list: (params: UnitsListParams) => [...unitsKeys.lists(), params] as const,
  details: () => [...unitsKeys.all, 'detail'] as const,
  detail: (id: string) => [...unitsKeys.details(), id] as const,
  diagnostics: (id: string) => [...unitsKeys.all, 'diagnostics', id] as const,
  history: (id: string, params: UnitHistoryParams) =>
    [...unitsKeys.all, 'history', id, params] as const,
};

/** `GET /units` — filtr/sort/pagination bilan ro'yxat (`units.read`). */
export function useUnitsList(
  params: UnitsListParams = {},
): UseQueryResult<ListResponse<Unit>, ApiError> {
  return useQuery({
    queryKey: unitsKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/units', { params: { query: params } });
      return data ?? {};
    },
  });
}

/** `GET /units/{id}` — bitta unit (`units.read`). Cross-tenant → 404. */
export function useUnit(id: string | undefined): UseQueryResult<Unit | undefined, ApiError> {
  return useQuery({
    queryKey: unitsKeys.detail(id ?? ''),
    queryFn: async () => {
      const { data } = await api.GET('/units/{id}', { params: { path: { id: id as string } } });
      return data?.data;
    },
    enabled: Boolean(id),
  });
}

/** `POST /units` — yaratish (`units.create`, `Idempotency-Key` avtomatik). */
export function useUnitCreate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: UnitCreate) => {
      const { data } = await api.POST('/units', { body });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: unitsKeys.lists() });
    },
  });
}

/** `PATCH /units/{id}` — qisman yangilash (`units.update`). */
export function useUnitUpdate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: UnitUpdate }) => {
      const { data } = await api.PATCH('/units/{id}', { params: { path: { id } }, body });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: unitsKeys.lists() });
      void queryClient.invalidateQueries({ queryKey: unitsKeys.detail(id) });
    },
  });
}

/** `DELETE /units/{id}` — soft delete (`units.delete`). 409 → resurs band. */
export function useUnitDelete() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      await api.DELETE('/units/{id}', { params: { path: { id } } });
    },
    onSuccess: (_data, id) => {
      void queryClient.invalidateQueries({ queryKey: unitsKeys.lists() });
      void queryClient.removeQueries({ queryKey: unitsKeys.detail(id) });
    },
  });
}

/** `POST /units/{id}/activate` (`units.activate`). */
export function useUnitActivate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      const { data } = await api.POST('/units/{id}/activate', { params: { path: { id } } });
      return data?.data;
    },
    onSuccess: (_data, id) => {
      void queryClient.invalidateQueries({ queryKey: unitsKeys.lists() });
      void queryClient.invalidateQueries({ queryKey: unitsKeys.detail(id) });
    },
  });
}

/** `POST /units/{id}/deactivate` (`units.deactivate`). */
export function useUnitDeactivate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      const { data } = await api.POST('/units/{id}/deactivate', { params: { path: { id } } });
      return data?.data;
    },
    onSuccess: (_data, id) => {
      void queryClient.invalidateQueries({ queryKey: unitsKeys.lists() });
      void queryClient.invalidateQueries({ queryKey: unitsKeys.detail(id) });
    },
  });
}

/**
 * `POST /units/{id}/assign-driver` (`units.assign_driver`).
 * Yangi `primary` avvalgisini yopadi; nofaol unit/driver → `409`.
 */
export function useUnitAssignDriver() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: UnitAssignDriver }) => {
      const { data } = await api.POST('/units/{id}/assign-driver', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: unitsKeys.detail(id) });
      void queryClient.invalidateQueries({ queryKey: unitsKeys.lists() });
    },
  });
}

/** `GET /units/{id}/diagnostics` (`units.diagnostics`). */
export function useUnitDiagnostics(
  id: string | undefined,
): UseQueryResult<UnitDiagnostics | undefined, ApiError> {
  return useQuery({
    queryKey: unitsKeys.diagnostics(id ?? ''),
    queryFn: async () => {
      const { data } = await api.GET('/units/{id}/diagnostics', {
        params: { path: { id: id as string } },
      });
      return data?.data;
    },
    enabled: Boolean(id),
  });
}

/** `GET /units/{id}/history` (`units.read`) — audit_log + assignment tarixi. */
export function useUnitHistory(
  id: string | undefined,
  params: UnitHistoryParams = {},
): UseQueryResult<ListResponse<UnitHistoryEntry>, ApiError> {
  return useQuery({
    queryKey: unitsKeys.history(id ?? '', params),
    queryFn: async () => {
      const { data } = await api.GET('/units/{id}/history', {
        params: { path: { id: id as string }, query: params },
      });
      return data ?? {};
    },
    enabled: Boolean(id),
  });
}

/** `GET /units/export` (`units.export`) — CSV/XLSX blob, yuklab olish §8. */
export function useUnitsExport() {
  return useMutation({
    mutationFn: async (params: UnitsExportParams = {}) => {
      const { data } = await api.GET('/units/export', {
        params: { query: params },
        parseAs: 'blob',
      });
      return data as Blob;
    },
  });
}

/** `GET /units/import-template` (`units.import`) — CSV/XLSX namuna. */
export function useUnitsImportTemplate() {
  return useMutation({
    mutationFn: async (params: UnitsImportTemplateParams = {}) => {
      const { data } = await api.GET('/units/import-template', {
        params: { query: params },
        parseAs: 'blob',
      });
      return data as Blob;
    },
  });
}

/**
 * `POST /units/import` (`units.import`, multipart) — all-or-nothing (fe §11/F83).
 *
 * ⚠️ **Ma'lum cheklov**: swagger `422` javobini ham `ImportResultEnvelope`
 * (`{data:{imported,total,errors[]}}`) deb belgilaydi — umumiy `{error:{...}}`
 * konvertidan farqli. `client.ts`dagi umumiy `errorMiddleware` faqat `error`
 * blokini biladi, shuning uchun `422` da bu hook **muvaffaqiyatsiz** tugaydi
 * (`ApiError`, qator xatolari yo'qoladi) — `errors[]` hozircha UI'ga
 * yetkazilmaydi. Tuzatish `client.ts`ni o'zgartirishni talab qiladi (bu
 * agentning fayl egaligidan tashqarida) — CR sifatida qayd etilgan (W9 hisobot).
 */
export function useUnitsImport() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (file: File): Promise<ImportResult> => {
      const formData = new FormData();
      formData.append('file', file);
      const { data } = await api.POST('/units/import', {
        body: formData as unknown as { file: string },
      });
      return data?.data ?? {};
    },
    onSuccess: (result) => {
      if ((result.imported ?? 0) > 0) {
        void queryClient.invalidateQueries({ queryKey: unitsKeys.lists() });
      }
    },
  });
}
