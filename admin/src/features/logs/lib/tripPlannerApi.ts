/**
 * Trip Planner tabi (7.4.3(d)) uchun mahalliy so'rovlar.
 *
 * ⚠️ **Ma'lum bo'shliq.** `api/queries/` da trips/routes uchun tayyor hook
 * hali yo'q (bu ekran agenti `api/queries/**`ga yozmaydi — W2/fayl egaligi).
 * Shu sabab bu yerda `@/api/client` to'g'ridan-to'g'ri chaqiriladi —
 * `LogsByUnitPage.openLog` da ishlatilgan naqsh bilan bir xil. Doimiy hook
 * kerak bo'lsa (`useUnitTrips`, `useRouteCreate`) — `api/queries/routes.ts`
 * yozilishi tavsiya etiladi (hisobotda qayd etilgan).
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import { api } from '@/api/client';
import type { ApiError } from '@/lib/errors';
import type { ListResponse, RouteCreate, Trip } from '@/api/types';

export const tripPlannerKeys = {
  all: ['logs', 'trip-planner'] as const,
  trips: (unitId: string, date?: string) =>
    [...tripPlannerKeys.all, 'trips', unitId, date ?? null] as const,
};

/** `GET /units/{id}/trips?date=` (`tracking.view_history`). */
export function useUnitTripsForDate(
  unitId: string | undefined,
  date?: string,
): UseQueryResult<ListResponse<Trip>, ApiError> {
  return useQuery({
    queryKey: tripPlannerKeys.trips(unitId ?? '', date),
    queryFn: async () => {
      const { data } = await api.GET('/units/{id}/trips', {
        params: { path: { id: unitId as string }, query: date ? { date } : {} },
      });
      return data ?? {};
    },
    enabled: Boolean(unitId),
  });
}

/** `POST /routes` (`routes.create`) — "Create route" formasi. */
export function useRouteCreate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: RouteCreate) => {
      const { data } = await api.POST('/routes', { body });
      return data?.data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: tripPlannerKeys.all });
    },
  });
}
