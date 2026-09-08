/**
 * Tracking — TanStack Query hooklari (bosqich 4, fe-api §3/§7, `fe-map` skill).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan:
 * `GET /tracking/live`, `GET /units/{id}/trips`, `GET /trips/{id}`,
 * `GET /units/{id}/diagnostics` (fleet moduliga tegishli, `units.ts`da bor).
 *
 * Ruxsatlar: `tracking.view_live`, `tracking.view_history`.
 *
 * **F168 [MUST]** — xarita `bounds` o'zgarishi hech qachon `GET /tracking/live`ni
 * qayta chaqirmaydi. Bu fayldagi hook'lar bboxni bilmaydi ham — filtr faqat
 * `unit_ids`/`branch_id`/`online_status`/`include_inactive` (backend qo'llab-
 * quvvatlaydigan yagona filtrlar), viewport bo'yicha kesish component tomonida.
 *
 * `useTrackingLive` — WS ulanmagan holatlarda ham F163 ("hech qanday holat
 * faqat WS'ga tayanmaydi") qoidasiga mos: `refetchInterval` orqali REST
 * doimo yangilanib turadi (WS voqealari `queryClient.setQueryData` bilan shu
 * keshni to'ldiradi — `features/tracking/hooks/useTrackingChannel.ts`).
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type {
  ListResponse,
  TrackingLiveParams,
  Trip,
  TripDetail,
  TripParams,
  UnitTripsParams,
} from '@/api/types';

export const trackingKeys = {
  all: ['tracking'] as const,
  live: () => [...trackingKeys.all, 'live'] as const,
  liveList: (params: TrackingLiveParams) => [...trackingKeys.live(), params] as const,
  trips: () => [...trackingKeys.all, 'trips'] as const,
  tripsForUnit: (unitId: string, params: UnitTripsParams) =>
    [...trackingKeys.trips(), unitId, params] as const,
  trip: () => [...trackingKeys.all, 'trip'] as const,
  tripDetail: (tripId: string, includePolyline: boolean) =>
    [...trackingKeys.trip(), tripId, includePolyline] as const,
};

/** Live tracking uchun REST fallback yangilanish oralig'i (F163). */
const LIVE_REFETCH_INTERVAL_MS = 15_000;

/** `GET /tracking/live` (`tracking.view_live`) — barcha unit'larning oxirgi holati. */
export function useTrackingLive(
  params: TrackingLiveParams = {},
  options: { enabled?: boolean } = {},
) {
  return useQuery({
    queryKey: trackingKeys.liveList(params),
    queryFn: async () => {
      const { data } = await api.GET('/tracking/live', { params: { query: params } });
      return data ?? {};
    },
    enabled: options.enabled ?? true,
    refetchInterval: LIVE_REFETCH_INTERVAL_MS,
    // Sahifa/filtr o'zgarganda eskisi ko'rinib tursin (fe-screens §6 keepPreviousData).
    placeholderData: (previous) => previous,
  });
}

/** `GET /units/{id}/trips` (`tracking.view_history`) — bir kunlik trip ro'yxati. */
export function useUnitTrips(
  unitId: string | undefined,
  params: UnitTripsParams = {},
): UseQueryResult<ListResponse<Trip>, ApiError> {
  return useQuery({
    queryKey: trackingKeys.tripsForUnit(unitId ?? '', params),
    queryFn: async () => {
      const { data } = await api.GET('/units/{id}/trips', {
        params: { path: { id: unitId as string }, query: params },
      });
      return data ?? {};
    },
    enabled: Boolean(unitId),
  });
}

/**
 * `GET /trips/{id}` (`tracking.view_history`) — **F169 [MUST]**:
 * `include_polyline=true` faqat bitta trip tanlanganda so'raladi
 * (`enabled` chaqiruvchida shunga qarab beriladi, `includePolyline` default `false`).
 */
export function useTrip(
  tripId: string | undefined,
  includePolyline: boolean,
  options: { enabled?: boolean } = {},
): UseQueryResult<TripDetail | undefined, ApiError> {
  return useQuery({
    queryKey: trackingKeys.tripDetail(tripId ?? '', includePolyline),
    queryFn: async () => {
      const query: TripParams = { include_polyline: includePolyline };
      const { data } = await api.GET('/trips/{id}', {
        params: { path: { id: tripId as string }, query },
      });
      return data?.data;
    },
    enabled: Boolean(tripId) && (options.enabled ?? true),
  });
}

/**
 * `GET /routes/{id}/directions` mock uchun yordamchi emas — routes.ts da.
 * Bu yerda faqat manual force-refresh (`Refresh` tugmasi, Q63) uchun
 * invalidatsiya hook'i beriladi.
 */
export function useTrackingRefresh() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async () => {
      await queryClient.invalidateQueries({ queryKey: trackingKeys.all });
    },
  });
}
