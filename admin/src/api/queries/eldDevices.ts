/**
 * ELD Devices — TanStack Query hooklari (2.1, fe-api §3/§7).
 *
 * Endpointlar `admin/openapi/swagger.json`: `GET/POST /eld-devices`,
 * `GET/PATCH/DELETE /eld-devices/{id}`, `POST /eld-devices/{id}/assign-unit`.
 * Ekran dizaynda yo'q edi (🎨, F88) — standart ro'yxat patterni.
 *
 * Ruxsatlar: `eld_devices.read/create/update/delete/assign_unit`.
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type {
  EldDevice,
  EldDeviceAssignUnit,
  EldDeviceCreate,
  EldDeviceUpdate,
  EldDevicesListParams,
  ListResponse,
} from '@/api/types';

/** Query key fabrikasi — `['eldDevices', <tur>, ...]`. */
export const eldDevicesKeys = {
  all: ['eldDevices'] as const,
  lists: () => [...eldDevicesKeys.all, 'list'] as const,
  list: (params: EldDevicesListParams) => [...eldDevicesKeys.lists(), params] as const,
  details: () => [...eldDevicesKeys.all, 'detail'] as const,
  detail: (id: string) => [...eldDevicesKeys.details(), id] as const,
};

/** `GET /eld-devices` (`eld_devices.read`). */
export function useEldDevicesList(
  params: EldDevicesListParams = {},
): UseQueryResult<ListResponse<EldDevice>, ApiError> {
  return useQuery({
    queryKey: eldDevicesKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/eld-devices', { params: { query: params } });
      return data ?? {};
    },
  });
}

/** `GET /eld-devices/{id}` (`eld_devices.read`). Cross-tenant → 404. */
export function useEldDevice(
  id: string | undefined,
): UseQueryResult<EldDevice | undefined, ApiError> {
  return useQuery({
    queryKey: eldDevicesKeys.detail(id ?? ''),
    queryFn: async () => {
      const { data } = await api.GET('/eld-devices/{id}', {
        params: { path: { id: id as string } },
      });
      return data?.data;
    },
    enabled: Boolean(id),
  });
}

/** `POST /eld-devices` (`eld_devices.create`). `(company_id, serial)` unikal. */
export function useEldDeviceCreate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: EldDeviceCreate) => {
      const { data } = await api.POST('/eld-devices', { body });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: eldDevicesKeys.lists() });
    },
  });
}

/** `PATCH /eld-devices/{id}` (`eld_devices.update`). */
export function useEldDeviceUpdate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: EldDeviceUpdate }) => {
      const { data } = await api.PATCH('/eld-devices/{id}', { params: { path: { id } }, body });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: eldDevicesKeys.lists() });
      void queryClient.invalidateQueries({ queryKey: eldDevicesKeys.detail(id) });
    },
  });
}

/** `DELETE /eld-devices/{id}` (`eld_devices.delete`) — ochiq assignment yopiladi. */
export function useEldDeviceDelete() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      await api.DELETE('/eld-devices/{id}', { params: { path: { id } } });
    },
    onSuccess: (_data, id) => {
      void queryClient.invalidateQueries({ queryKey: eldDevicesKeys.lists() });
      void queryClient.removeQueries({ queryKey: eldDevicesKeys.detail(id) });
    },
  });
}

/**
 * `POST /eld-devices/{id}/assign-unit` (`eld_devices.assign_unit`).
 * `unit_id: null` — qurilmani ajratadi. `409 ALREADY_ASSIGNED`/`INVALID_STATE`.
 * Unit tomonidagi keshni ham eskirtiradi (`units` ro'yxati `eld_device_serial`
 * ko'rsatadi) — chaqiruvchi `unitsKeys` ni alohida invalidatsiya qilishi kerak
 * (bu modul `units.ts`ga bog'liq bo'lmaydi, W2).
 */
export function useEldDeviceAssignUnit() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: EldDeviceAssignUnit }) => {
      const { data } = await api.POST('/eld-devices/{id}/assign-unit', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: eldDevicesKeys.lists() });
      void queryClient.invalidateQueries({ queryKey: eldDevicesKeys.detail(id) });
    },
  });
}
