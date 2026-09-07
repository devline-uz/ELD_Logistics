/**
 * Defect Types — TanStack Query hooklari (5.1, fe-api §3/§7,
 * `docs/tz/07-5-dvir-maintenance.md` §7.6.1).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET/POST /defect-types`, `PATCH /defect-types/{id}`.
 *
 * Ruxsatlar (`docs/api/permissions.md`): `defect_types.read/create/update`.
 * ⚠️ **`delete` yo'q** — swagger'da `DELETE /defect-types/{id}` operatsiyasi
 * mavjud emas. `is_system=true` yozuvlar (61 ta FMCSA standart bandi) —
 * o'qish uchun ochiq, lekin tahrirlashda `409 DEFECT_TYPE_SYSTEM_LOCKED`
 * qaytaradi; UI deaktivatsiya (`is_active=false`) orqali "o'chirish"ni
 * simulyatsiya qiladi (tarixiy hisobotlar buzilmasligi uchun).
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type {
  DefectType,
  DefectTypeCreate,
  DefectTypesListParams,
  DefectTypeUpdate,
  ListResponse,
} from '@/api/types';

/** Query key fabrikasi — `['defectTypes', <tur>, ...]` (fe-conventions §3). */
export const defectTypesKeys = {
  all: ['defectTypes'] as const,
  lists: () => [...defectTypesKeys.all, 'list'] as const,
  list: (params: DefectTypesListParams) => [...defectTypesKeys.lists(), params] as const,
};

/**
 * `GET /defect-types` — `category|is_active|is_critical` filtri
 * (`defect_types.read`).
 */
export function useDefectTypesList(
  params: DefectTypesListParams = {},
): UseQueryResult<ListResponse<DefectType>, ApiError> {
  return useQuery({
    queryKey: defectTypesKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/defect-types', { params: { query: params } });
      return data ?? {};
    },
  });
}

/**
 * `POST /defect-types` (`defect_types.create`) — kompaniya darajasidagi
 * yangi band. `name` kategoriya ichida kompaniya bo'yicha unikal → `409
 * UNIQUE_VIOLATION`.
 */
export function useDefectTypeCreate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: DefectTypeCreate) => {
      const { data } = await api.POST('/defect-types', { body });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: defectTypesKeys.lists() });
    },
  });
}

/**
 * `PATCH /defect-types/{id}` (`defect_types.update`). Standart (`is_system`)
 * bandlar uchun `409 DEFECT_TYPE_SYSTEM_LOCKED`; nom to'qnashuvida `409
 * UNIQUE_VIOLATION`.
 */
export function useDefectTypeUpdate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: DefectTypeUpdate }) => {
      const { data } = await api.PATCH('/defect-types/{id}', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: defectTypesKeys.lists() });
    },
  });
}
