/**
 * Unidentified Driving / Unassigned Driving — TanStack Query hooklari
 * (3.1, fe-api §3/§7, `tz.md` §10.4, `docs/tz/07-4-logs.md` 7.4.5).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET /unidentified-events`, `POST /unidentified-events/{id}/assign`
 * (`logs.assign_unidentified`), `POST /unidentified-events/{id}/annotate`
 * (`logs.annotate_unidentified`), `POST /unidentified-events/{id}/claim`
 * (`logs.claim_unidentified`, odatda mobil ilova chaqiradi, admin panelda
 * kamdan-kam ishlatiladi — to'liq qamrov uchun shu yerda ham mavjud).
 *
 * **⚠️ OR mantiq istisnosi (ekran agenti bilishi kerak).** Swagger
 * `GET /unidentified-events` uchun `x-permission: logs.assign_unidentified`
 * deb ko'rsatadi, lekin backend bu ro'yxatni **`logs.assign_unidentified`
 * YOKI `logs.read`** bilan ham ochadi — faqat yozuv amallari (`assign`,
 * `annotate`) o'zining alohida ruxsatini talab qiladi. Ekran shu sabab
 * ro'yxat ko'rinishini `usePermission().can.any(['logs.assign_unidentified',
 * 'logs.read'])` bilan tekshirishi kerak, yagona `can('logs.assign_unidentified')`
 * bilan EMAS — aks holda faqat `logs.read`ga ega foydalanuvchi ro'yxatni
 * butunlay yo'qotadi.
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type {
  ListResponse,
  LogEditRequest,
  TrackingUnidentifiedEvent,
  UnidentifiedAnnotate,
  UnidentifiedAssign,
  UnidentifiedEvent,
  UnidentifiedEventsListParams,
} from '@/api/types';

/** Query key fabrikasi — `['unidentified-events', <tur>, ...]`. */
export const unidentifiedKeys = {
  all: ['unidentified-events'] as const,
  lists: () => [...unidentifiedKeys.all, 'list'] as const,
  list: (params: UnidentifiedEventsListParams) => [...unidentifiedKeys.lists(), params] as const,
};

/**
 * `GET /unidentified-events` — OR-ruxsat istisnosi yuqoridagi modul
 * izohida. Filtrlar: `status` (`pending|assigned|annotated`), `unit_id`,
 * `from`/`to` (RFC3339). 8 kundan ortiq `pending` — F104 (Dashboard KPI).
 */
export function useUnidentifiedEventsList(
  params: UnidentifiedEventsListParams = {},
): UseQueryResult<ListResponse<TrackingUnidentifiedEvent>, ApiError> {
  return useQuery({
    queryKey: unidentifiedKeys.list(params),
    queryFn: async () => {
      const { data } = await api.GET('/unidentified-events', { params: { query: params } });
      return data ?? {};
    },
  });
}

/**
 * `POST /unidentified-events/{id}/assign` (`logs.assign_unidentified`).
 *
 * ⚠️ **Swagger nuqsoni.** Ushbu operatsiya spec'da ikkita `in: body`
 * parametrga ega (`id` — yo'l identifikatori va asosiy `body` —
 * `UnidentifiedAssign`). `swagger2openapi` konvertatsiyasi buni bitta
 * `requestBody`ga siqib qo'yadi va `id` yo'l parametrini butunlay yo'qotadi
 * (`openapi/openapi3.json`da `x-s2o-warning: "... has multiple
 * requestBodies"`; natijada `schema.d.ts`da bu operatsiya `path: never`,
 * `requestBody: string` bilan generatsiya bo'lgan — `POST /units/import`
 * uchun ishlatilgan `body as unknown as <shape>` naqshiga o'xshash holat,
 * lekin bu safar `path` ham buzilgan).
 *
 * `openapi-fetch`ning `createFinalURL` funksiyasi `options.params.path`ni
 * ish vaqtida (generatsiya qilingan TS tipidan mustaqil) o'qiydi — shuning
 * uchun quyidagi kastlar faqat kompilyatsiya uchun, ish vaqtida `{id}` va
 * JSON tana to'g'ri yuboriladi. Bu — backend spec nuqsoni, `schema.d.ts`
 * qo'lda tuzatilmaydi (W7); nuqson §16/§17 reestriga alohida qayd etiladi.
 */
export function useUnidentifiedAssign() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({
      id,
      body,
    }: {
      id: string;
      body: UnidentifiedAssign;
    }): Promise<LogEditRequest | undefined> => {
      const { data } = await api.POST('/unidentified-events/{id}/assign', {
        params: { path: { id } } as unknown as {
          query?: never;
          header?: never;
          path?: never;
          cookie?: never;
        },
        body: body as unknown as string,
      });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: unidentifiedKeys.lists() });
    },
  });
}

/**
 * `POST /unidentified-events/{id}/annotate` (`logs.annotate_unidentified`)
 * — izoh bilan «unassigned» qoldirish (masalan mexanik test-drive).
 * `annotation` majburiy, 3-500 belgi.
 */
export function useUnidentifiedAnnotate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({
      id,
      body,
    }: {
      id: string;
      body: UnidentifiedAnnotate;
    }): Promise<UnidentifiedEvent | undefined> => {
      const { data } = await api.POST('/unidentified-events/{id}/annotate', {
        params: { path: { id } },
        body,
      });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: unidentifiedKeys.lists() });
    },
  });
}

/**
 * `POST /unidentified-events/{id}/claim` (`logs.claim_unidentified`) —
 * haydovchi blokni o'zi oladi, ikkinchi tasdiq shart emas. Boshqa
 * haydovchiga taklif qilingan blok `409 ALREADY_ASSIGNED` qaytaradi.
 */
export function useUnidentifiedClaim() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string): Promise<UnidentifiedEvent | undefined> => {
      const { data } = await api.POST('/unidentified-events/{id}/claim', {
        params: { path: { id } },
      });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: unidentifiedKeys.lists() });
    },
  });
}
