/**
 * Log Edit Requests — TanStack Query hooklari (3.1, fe-api §3/§7).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET /log-edit-requests` (`logs.read`), `POST /log-edit-requests`
 * (`logs.propose_edit`), `POST /log-edit-requests/{id}/approve`
 * (`logs.approve_edit`), `POST /log-edit-requests/{id}/reject`
 * (`logs.reject_edit`).
 *
 * **⚠️ F100 [MUST] Taklif → tasdiq modeli.** `tz.md` §5.3 (FMCSA §395.30):
 * admin panel logni **hech qachon** to'g'ridan-to'g'ri tahrirlamaydi.
 * `useLogEditRequestPropose` faqat `pending` yozuv yaratadi — o'zgarish
 * haydovchi tasdiqlagandan keyingina kuchga kiradi (`approve`). Backend
 * ta'rifi (swagger) ham buni tasdiqlaydi: «only the driver … may approve/
 * reject». `logs.approve_edit`/`logs.reject_edit` ruxsatlari admin ekranida
 * — kompaniya siyosatiga qarab boshqa administrator ko'rib chiqishi mumkin
 * bo'lgan navbat sifatida — ishlatiladi (7.4.4).
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type {
  ListResponse,
  LogEditReject,
  LogEditRequest,
  LogEditRequestCreate,
  LogEditRequestsListParams,
} from '@/api/types';

import { logsKeys } from './logs';

/** Query key fabrikasi — `['log-edit-requests', <tur>, ...]`. */
export const logEditRequestsKeys = {
  all: ['log-edit-requests'] as const,
  lists: () => [...logEditRequestsKeys.all, 'list'] as const,
  list: (params: LogEditRequestsListParams) => [...logEditRequestsKeys.lists(), params] as const,
};

/** `GET /log-edit-requests` (`logs.read`) — Pending/Approved/Rejected tablar. */
export function useLogEditRequestsList(
  params: LogEditRequestsListParams = {},
): UseQueryResult<ListResponse<LogEditRequest>, ApiError> {
  return useQuery({
    queryKey: logEditRequestsKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/log-edit-requests', { params: { query: params } });
      return data ?? {};
    },
  });
}

/**
 * `POST /log-edit-requests` (`logs.propose_edit`) — taklif yuborish.
 * ⚠️ Log **darhol o'zgarmaydi**: yozuv `pending` holatda saqlanadi, faqat
 * haydovchi tasdiqlasa amal qiladi (F100). `changes[].note` majburiy,
 * avtomatik `DR` intervalini qisqartirish/qayta tasniflash `409
 * DR_IMMUTABLE` bilan rad etiladi (Q17.1) — bu tekshiruv UI darajasida ham
 * (tugma `disabled`) takrorlanadi, backend baribir yakuniy hakam.
 */
export function useLogEditRequestPropose() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: LogEditRequestCreate) => {
      const { data } = await api.POST('/log-edit-requests', { body });
      return data?.data;
    },
    onSuccess: (data) => {
      void queryClient.invalidateQueries({ queryKey: logEditRequestsKeys.lists() });
      if (data?.daily_log_id) {
        void queryClient.invalidateQueries({
          queryKey: logsKeys.dailyLogDetail(data.daily_log_id),
        });
      }
    },
  });
}

/**
 * `POST /log-edit-requests/{id}/approve` (`logs.approve_edit`).
 * **F103:** admin o'z taklifini o'zi tasdiqlay olmaydi — ekran `Approve`
 * tugmasini taklif qiluvchi (`requested_by === currentUserId`) uchun
 * yashiradi; backend ham buni bloklaydi (`403`).
 */
export function useLogEditRequestApprove() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      const { data } = await api.POST('/log-edit-requests/{id}/approve', {
        params: { path: { id } },
      });
      return data?.data;
    },
    onSuccess: (data) => {
      void queryClient.invalidateQueries({ queryKey: logEditRequestsKeys.lists() });
      if (data?.daily_log_id) {
        void queryClient.invalidateQueries({
          queryKey: logsKeys.dailyLogDetail(data.daily_log_id),
        });
      }
    },
  });
}

/**
 * `POST /log-edit-requests/{id}/reject` (`logs.reject_edit`) — **sabab
 * majburiy** (`LogEditReject.reason`, 3-500 belgi). Log hech qanday
 * o'zgarishsiz qoladi, admin sababni ko'radi.
 */
export function useLogEditRequestReject() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body }: { id: string; body: LogEditReject }) => {
      const { data } = await api.POST('/log-edit-requests/{id}/reject', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: logEditRequestsKeys.lists() });
    },
  });
}
