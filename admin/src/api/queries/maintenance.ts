/**
 * Maintenance — TanStack Query hooklari (5.1, fe-api §3/§7,
 * `docs/tz/07-5-dvir-maintenance.md` §7.6).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET/POST /maintenance-schedules`, `GET/PATCH/DELETE /maintenance-schedules/{id}`,
 * `GET /maintenance/due`, `GET /maintenance-schedule-units/{id}`,
 * `POST /maintenance-schedule-units/{id}/complete`,
 * `POST /maintenance-schedule-units/{id}/cancel`, `GET /maintenance-records`.
 *
 * Ruxsatlar (`docs/api/permissions.md`):
 * `maintenance.read/create/update/delete/complete/cancel`.
 *
 * **Uchta tab — uchta alohida manba (bir-biriga proyeksiya emas):**
 * - `Schedule` → `GET /maintenance-schedules?status=&q=` (rejalar, `unit_count`)
 * - `Due` → `GET /maintenance/due?unit_id=&schedule_id=&status=` (unit×schedule
 *   qatorlari; default faqat `scheduled`/`due`, yopilganini ko'rish uchun
 *   `status=completed|cancelled` beriladi)
 * - `History` → `GET /maintenance-records?unit_id=&status=completed|cancelled&from=&to=`
 *   (yakunlangan/bekor qilingan yozuvlar arxivi)
 *
 * `Schedule` jadvalidagi «N Units» qatori bosilganda `/maintenance/schedules/:id/units`
 * ekraniga o'tiladi — bu **yangi endpoint emas**, xuddi shu `useMaintenanceDue`
 * hooki `schedule_id` filtri bilan qayta ishlatiladi (breadcrumb: `Due › N units`).
 *
 * **Bir va ko'p unit rejimi:** `ScheduleCreate.units[]` (ixtiyoriy, ≤500 dona)
 * — bitta unit tanlansa `Single Unit`, bir nechtasi `Multiple Units` rejimini
 * beradi; backendda alohida maydon yo'q, faqat massiv uzunligi farq qiladi.
 * Har unit uchun `last_service_value` ixtiyoriy — berilmasa backend joriy
 * telemetriyadan (odometer/engine hours) yoki yaratilish sanasidan (`days`)
 * o'zi hisoblaydi.
 *
 * ⚠️ **Birlik konvertatsiyasi bu qatlamda QILINMAYDI.** `interval_unit`/
 * `ScheduleUnit.interval_unit` — `km|mi|days|engine_hours` enum, foydalanuvchi
 * tanlagan birlikda backendga **to'g'ridan-to'g'ri** yuboriladi (masofa maydoni
 * SI'ga majburiy konvertatsiya qilinmaydi — schema shuni talab qilmaydi,
 * backend `km` va `mi`ni alohida birlik sifatida saqlaydi). `odometer_m` —
 * xom telemetriya (metr), faqat ko'rish uchun; ekran bu ikkisini
 * chalkashtirmasligi kerak (`lib/units.ts` orqali formatlash — ekran ishi).
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type {
  ListResponse,
  MaintenanceCancel,
  MaintenanceComplete,
  MaintenanceDueParams,
  MaintenanceRecord,
  MaintenanceRecordsListParams,
  MaintenanceSchedule,
  MaintenanceScheduleCreate,
  MaintenanceSchedulesListParams,
  MaintenanceScheduleUnit,
  MaintenanceScheduleUpdate,
} from '@/api/types';

/** Query key fabrikasi — `['maintenance', <tur>, ...]` (fe-conventions §3). */
export const maintenanceKeys = {
  all: ['maintenance'] as const,
  scheduleLists: () => [...maintenanceKeys.all, 'schedules', 'list'] as const,
  scheduleList: (params: MaintenanceSchedulesListParams) =>
    [...maintenanceKeys.scheduleLists(), params] as const,
  scheduleDetails: () => [...maintenanceKeys.all, 'schedules', 'detail'] as const,
  scheduleDetail: (id: string) => [...maintenanceKeys.scheduleDetails(), id] as const,
  dues: () => [...maintenanceKeys.all, 'due'] as const,
  due: (params: MaintenanceDueParams) => [...maintenanceKeys.dues(), params] as const,
  scheduleUnitDetails: () => [...maintenanceKeys.all, 'schedule-unit', 'detail'] as const,
  scheduleUnitDetail: (id: string) => [...maintenanceKeys.scheduleUnitDetails(), id] as const,
  records: () => [...maintenanceKeys.all, 'records', 'list'] as const,
  recordList: (params: MaintenanceRecordsListParams) =>
    [...maintenanceKeys.records(), params] as const,
};

/** `GET /maintenance-schedules` — `Schedule` tabi (`maintenance.read`). */
export function useMaintenanceSchedulesList(
  params: MaintenanceSchedulesListParams = {},
): UseQueryResult<ListResponse<MaintenanceSchedule>, ApiError> {
  return useQuery({
    queryKey: maintenanceKeys.scheduleList(params),
    queryFn: async () => {
      const { data } = await api.GET('/maintenance-schedules', { params: { query: params } });
      return data ?? {};
    },
  });
}

/** `GET /maintenance-schedules/{id}` — bitta reja (`maintenance.read`). */
export function useMaintenanceSchedule(
  id: string | undefined,
): UseQueryResult<MaintenanceSchedule | undefined, ApiError> {
  return useQuery({
    queryKey: maintenanceKeys.scheduleDetail(id ?? ''),
    queryFn: async () => {
      const { data } = await api.GET('/maintenance-schedules/{id}', {
        params: { path: { id: id as string } },
      });
      return data?.data;
    },
    enabled: Boolean(id),
  });
}

/** `POST /maintenance-schedules` — `Add Maintenance` (`maintenance.create`). */
export function useMaintenanceScheduleCreate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: MaintenanceScheduleCreate) => {
      const { data } = await api.POST('/maintenance-schedules', { body });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: maintenanceKeys.scheduleLists() });
      void queryClient.invalidateQueries({ queryKey: maintenanceKeys.dues() });
    },
  });
}

/** `PATCH /maintenance-schedules/{id}` — tahrirlash (`maintenance.update`). */
export function useMaintenanceScheduleUpdate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: MaintenanceScheduleUpdate }) => {
      const { data } = await api.PATCH('/maintenance-schedules/{id}', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: maintenanceKeys.scheduleLists() });
      void queryClient.invalidateQueries({ queryKey: maintenanceKeys.scheduleDetail(id) });
      void queryClient.invalidateQueries({ queryKey: maintenanceKeys.dues() });
    },
  });
}

/**
 * `DELETE /maintenance-schedules/{id}` — soft delete (`maintenance.delete`).
 * `/maintenance-records` tarixi saqlanib qoladi (Q32) — u invalidatsiya
 * qilinmaydi.
 */
export function useMaintenanceScheduleDelete() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      await api.DELETE('/maintenance-schedules/{id}', { params: { path: { id } } });
    },
    onSuccess: (_data, id) => {
      void queryClient.invalidateQueries({ queryKey: maintenanceKeys.scheduleLists() });
      void queryClient.removeQueries({ queryKey: maintenanceKeys.scheduleDetail(id) });
      void queryClient.invalidateQueries({ queryKey: maintenanceKeys.dues() });
    },
  });
}

/**
 * `GET /maintenance/due` — `Due` tabi **va** reja ichidagi "N Units" ekrani
 * (`schedule_id` filtri bilan qayta ishlatiladi, `maintenance.read`).
 *
 * `options.enabled` — so'rov faqat kerak bo'lganda yuboriladi (masalan
 * `Schedule` tabida biriktirilgan unitlar **faqat** tahrirlash modali
 * ochilganda kerak; aks holda har tab ochilishida ortiqcha so'rov ketardi).
 */
export function useMaintenanceDue(
  params: MaintenanceDueParams = {},
  options: { enabled?: boolean } = {},
): UseQueryResult<ListResponse<MaintenanceScheduleUnit>, ApiError> {
  return useQuery({
    queryKey: maintenanceKeys.due(params),
    queryFn: async () => {
      const { data } = await api.GET('/maintenance/due', { params: { query: params } });
      return data ?? {};
    },
    enabled: options.enabled ?? true,
  });
}

/** `GET /maintenance-schedule-units/{id}` — bitta unit×reja qatori (`maintenance.read`). */
export function useMaintenanceScheduleUnit(
  id: string | undefined,
): UseQueryResult<MaintenanceScheduleUnit | undefined, ApiError> {
  return useQuery({
    queryKey: maintenanceKeys.scheduleUnitDetail(id ?? ''),
    queryFn: async () => {
      const { data } = await api.GET('/maintenance-schedule-units/{id}', {
        params: { path: { id: id as string } },
      });
      return data?.data;
    },
    enabled: Boolean(id),
  });
}

/**
 * `POST /maintenance-schedule-units/{id}/complete` (`maintenance.complete`)
 * — `MARK MAINTENANCE AS COMPLETE` modali: Invoice #, Vendor, Cost, Date,
 * invoice fayl (ixtiyoriy, §10 `kind=invoice`, PDF/JPG/PNG ≤10 MB — F111).
 * Allaqachon yopilgan qator → `409 MAINTENANCE_INVALID_STATE`; telemetriyasiz
 * unit (km/mi/engine_hours jadvali) → `422 MAINTENANCE_NO_READING`.
 */
export function useMaintenanceComplete() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: MaintenanceComplete }) => {
      const { data } = await api.POST('/maintenance-schedule-units/{id}/complete', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: maintenanceKeys.dues() });
      void queryClient.invalidateQueries({ queryKey: maintenanceKeys.records() });
      void queryClient.invalidateQueries({ queryKey: maintenanceKeys.scheduleUnitDetail(id) });
      void queryClient.invalidateQueries({ queryKey: maintenanceKeys.scheduleLists() });
    },
  });
}

/**
 * `POST /maintenance-schedule-units/{id}/cancel` (`maintenance.cancel`) —
 * sabab majburiy, moliyaviy maydonlar yo'q (bekor qilingan yozuvda hech
 * qachon invoice/vendor/cost bo'lmaydi, Q43).
 */
export function useMaintenanceCancel() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: MaintenanceCancel }) => {
      const { data } = await api.POST('/maintenance-schedule-units/{id}/cancel', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: (_data, { id }) => {
      void queryClient.invalidateQueries({ queryKey: maintenanceKeys.dues() });
      void queryClient.invalidateQueries({ queryKey: maintenanceKeys.records() });
      void queryClient.invalidateQueries({ queryKey: maintenanceKeys.scheduleUnitDetail(id) });
    },
  });
}

/**
 * `GET /maintenance-records` — `History` tabi **va** DVIR History detalidagi
 * `PRE/POST-TRIP INSPECTION` bloki uchun emas (u `dvir.ts`dagi
 * `useDvirList`ni `unit_id`/`from`/`to` bilan chaqiradi, F113;
 * `maintenance-records` faqat texnik xizmat arxivi, `maintenance.read`).
 */
export function useMaintenanceRecordsList(
  params: MaintenanceRecordsListParams = {},
): UseQueryResult<ListResponse<MaintenanceRecord>, ApiError> {
  return useQuery({
    queryKey: maintenanceKeys.recordList(params),
    queryFn: async () => {
      const { data } = await api.GET('/maintenance-records', { params: { query: params } });
      return data ?? {};
    },
  });
}
