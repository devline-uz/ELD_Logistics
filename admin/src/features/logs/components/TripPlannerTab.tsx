/**
 * Trip Planner tabi (7.4.3(d)). Xarita — `LazyTripMapPanel` (F165: na
 * `MapCanvas`, na maplibre qatlam hook'lari to'g'ridan-to'g'ri import
 * qilinmaydi — aks holda `LogViewPage` chunk'i 800 KB maplibre'ni tortadi).
 * Segmentlar ro'yxati `GET /units/{id}/trips` dan (`api/queries/tracking.ts`
 * dagi markaziy `useUnitTrips`), "Create route" formasi `POST /routes` ga
 * (`api/queries/routes.ts` dagi `useRouteCreate` — u `/routes` ro'yxatini ham
 * invalidatsiya qiladi). Mahalliy `lib/tripPlannerApi.ts` dublikati o'chirildi
 * (TD1).
 *
 * Xarita qatlamlari:
 * - `useTripPolylineLayer` — kunning segmentlari (`start_lat/lng` →
 *   `end_lat/lng`) umumiy chiziqlar sifatida; segment tanlanganda u faol
 *   chiziqqa aylanadi, raqamli to'xtash markerlari qo'yiladi va `fitBounds`
 *   chaqiriladi. To'liq geometriya (`include_polyline=true`) bu yerda
 *   so'ralmaydi — F169 (ro'yxat/planner ko'rinishi).
 * - `useGeofenceLayer` — forma `To` maydonidagi koordinata atrofida
 *   `geofenceRadiusM` radiusli doira (F170). `To` koordinata sifatida
 *   o'qilmasa doira chizilmaydi.
 *
 * A11y (F171): xarita yagona manba emas — segmentlar `MapDataTable` jadvali
 * sifatida ham beriladi va xarita `aria-describedby` orqali unga ishora
 * qiladi.
 *
 * **F101**: koordinatalar 7 xonali o'nlik format bilan ko'rsatiladi
 * (`toFixed(7)`), vergul juftlik ajratgichi.
 */
import { useId, useMemo, useState } from 'react';
import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { z } from 'zod';

import { Alert } from '@/components/feedback/Alert';
import { useToast } from '@/components/feedback/toast-context';
import { applyServerErrors } from '@/components/form/applyServerErrors';
import { FormInput } from '@/components/form/FormInput';
import { FormTextarea } from '@/components/form/FormTextarea';
import { Button } from '@/components/ui/Button';
import { ErrorState } from '@/components/feedback/ErrorState';
import { PermissionGate } from '@/components/ui/PermissionGate';
import { Skeleton } from '@/components/feedback/Skeleton';
import { LazyTripMapPanel } from '@/components/map/LazyTripMapPanel';
import { MapDataTable } from '@/components/map/MapDataTable';
import type { TripStopMarker } from '@/components/map/useTripPolylineLayer';
import type { LngLatTuple } from '@/components/map/polyline';
import type { Trip } from '@/api/types';
import { useRouteCreate } from '@/api/queries/routes';
import { useUnitTrips } from '@/api/queries/tracking';
import { formatCoordinatePair } from '@/lib/format';
import type { UseDateFormatResult } from '@/hooks/useDateFormat';
import { PERM } from '@/lib/permissions';

/**
 * `geofenceRadiusM` — `<input type="number">` orqali keladi, lekin
 * `FormInput` (`components/form/FormInput.tsx`) qiymatni har doim **string**
 * sifatida `field.onChange`ga uzatadi (raqamga avtomatik aylantirmaydi) —
 * shu sabab bu yerda satr sifatida saqlanadi va submit vaqtida `Number()`ga
 * o'giriladi (`z.coerce.number()` ishlatilmadi — `zodResolver`ning input/
 * output generic turlarini mos kelmay qoladi, TS xatosi beradi).
 */
const createRouteSchema = z.object({
  from: z.string().min(1, 'required').max(200),
  to: z.string().min(1, 'required').max(200),
  geofenceRadiusM: z
    .string()
    .regex(/^\d+$/, 'must be a whole number')
    .refine((value) => Number(value) >= 50 && Number(value) <= 5000, 'must be between 50 and 5000'),
  note: z.string().max(500).optional(),
});

type CreateRouteFormValues = z.infer<typeof createRouteSchema>;

export interface TripPlannerTabProps {
  unitId: string | undefined;
  driverId: string;
  logDate: string;
  dateFormat: UseDateFormatResult;
}

/** Trip segmentining ikki uchi ham koordinataga ega bo'lsa — `[start, end]`. */
function tripLine(trip: Trip): LngLatTuple[] | undefined {
  if (
    typeof trip.start_lat !== 'number' ||
    typeof trip.start_lng !== 'number' ||
    typeof trip.end_lat !== 'number' ||
    typeof trip.end_lng !== 'number'
  ) {
    return undefined;
  }
  return [
    [trip.start_lng, trip.start_lat],
    [trip.end_lng, trip.end_lat],
  ];
}

/**
 * `To` maydoni "lat, lng" ko'rinishida bo'lsa geofence markazini beradi
 * (`Copy last location` aynan shu formatda yozadi). Manzil matni kiritilgan
 * bo'lsa `undefined` qaytadi va doira chizilmaydi — frontend geocoding
 * qilmaydi (F172).
 */
function parseCoordinate(text: string | undefined): LngLatTuple | undefined {
  if (!text) return undefined;
  const match = /^\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*$/.exec(text);
  if (!match) return undefined;
  const lat = Number(match[1]);
  const lng = Number(match[2]);
  if (Math.abs(lat) > 90 || Math.abs(lng) > 180) return undefined;
  return [lng, lat];
}

export function TripPlannerTab({ unitId, driverId, logDate, dateFormat }: TripPlannerTabProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const trips = useUnitTrips(unitId, logDate ? { date: logDate } : {});
  const createRoute = useRouteCreate();
  const [selectedTripId, setSelectedTripId] = useState<string | undefined>(undefined);
  const tableId = useId();

  const form = useForm<CreateRouteFormValues>({
    resolver: zodResolver(createRouteSchema),
    defaultValues: { from: '', to: '', geofenceRadiusM: '300', note: '' },
  });

  const tripRows = useMemo(() => trips.data?.data ?? [], [trips.data]);
  const selectedTrip = tripRows.find((trip) => trip.id === selectedTripId);

  /** Tanlanmagan segmentlar — 30% shaffof umumiy chiziqlar. */
  const overviewLines = useMemo(
    () =>
      tripRows
        .filter((trip) => trip.id !== selectedTripId)
        .map(tripLine)
        .filter((line): line is LngLatTuple[] => line !== undefined),
    [tripRows, selectedTripId],
  );

  const activeLine = useMemo(
    () => (selectedTrip ? tripLine(selectedTrip) : undefined),
    [selectedTrip],
  );

  /** Tanlangan segmentning boshlanish/tugash nuqtalari — raqamli markerlar. */
  const stops = useMemo<TripStopMarker[]>(
    () =>
      activeLine
        ? activeLine.map((lngLat, index) => ({
            index: index + 1,
            lngLat,
            label: String(index + 1),
          }))
        : [],
    [activeLine],
  );

  const destinationText = form.watch('to');
  const geofenceRadiusText = form.watch('geofenceRadiusM');
  const destination = useMemo(() => parseCoordinate(destinationText), [destinationText]);
  const geofenceM = /^\d+$/.test(geofenceRadiusText) ? Number(geofenceRadiusText) : undefined;

  const mapCenter = destination ?? activeLine?.[0] ?? overviewLines[0]?.[0];

  const copyLastLocation = () => {
    const lastTrip = tripRows[tripRows.length - 1];
    if (typeof lastTrip?.end_lat !== 'number' || typeof lastTrip.end_lng !== 'number') return;
    form.setValue('from', formatCoordinatePair(lastTrip.end_lat, lastTrip.end_lng), {
      shouldDirty: true,
    });
  };

  const onSubmit = form.handleSubmit(async (values) => {
    if (!unitId) return;
    try {
      await createRoute.mutateAsync({
        unit_id: unitId,
        driver_id: driverId,
        origin: { text: values.from },
        destination: { text: values.to },
        geofence_m: Number(values.geofenceRadiusM),
        note: values.note || undefined,
      });
      toast.show({ variant: 'success', message: t('logs.view.tripPlanner.toast.created') });
      form.reset({ from: '', to: '', geofenceRadiusM: '300', note: '' });
    } catch (error) {
      applyServerErrors(form, error);
    }
  });

  return (
    <div className="flex flex-col gap-4">
      <div className="h-64 overflow-hidden rounded-lg border border-stroke">
        <LazyTripMapPanel
          ariaLabel={t('logs.view.tripPlanner.mapAriaLabel')}
          ariaDescribedBy={tableId}
          className="h-full w-full"
          overviewLines={overviewLines}
          activeLine={activeLine}
          stops={stops}
          destination={destination}
          geofenceM={geofenceM}
          initialCenter={mapCenter}
          initialZoom={mapCenter ? 10 : undefined}
        />
      </div>

      <div>
        <h3 className="mb-2 text-body font-semibold text-neutral-900">
          {t('logs.view.tripPlanner.segmentsTitle')}
        </h3>
        {trips.isLoading ? (
          <Skeleton variant="table-row" count={3} />
        ) : trips.isError ? (
          <ErrorState message={trips.error?.message} onRetry={() => void trips.refetch()} />
        ) : tripRows.length === 0 ? (
          <p className="text-body-sm text-neutral-600">{t('logs.view.tripPlanner.noTrips')}</p>
        ) : (
          <ul aria-label={t('logs.view.tripPlanner.segmentsTitle')} className="flex flex-col gap-2">
            {tripRows.map((trip, index) => {
              const selected = trip.id === selectedTripId;
              return (
                <li key={trip.id ?? index}>
                  <button
                    type="button"
                    aria-pressed={selected}
                    disabled={!tripLine(trip)}
                    onClick={() => setSelectedTripId(trip.id)}
                    className={`w-full rounded-md border p-3 text-start text-body-sm disabled:cursor-not-allowed disabled:opacity-60 ${
                      selected
                        ? 'border-primary bg-light'
                        : 'border-stroke bg-surface hover:bg-surface-muted'
                    }`}
                  >
                    <span className="flex flex-wrap justify-between gap-2">
                      <span>
                        {dateFormat.formatDateTime(trip.start_at)} –{' '}
                        {dateFormat.formatDateTime(trip.end_at)}
                      </span>
                      <span className="text-neutral-600">
                        {formatCoordinatePair(trip.start_lat, trip.start_lng)}
                      </span>
                    </span>
                  </button>
                </li>
              );
            })}
          </ul>
        )}

        {/* F171 — xarita ma'lumotining jadval ekvivalenti. */}
        <MapDataTable
          id={tableId}
          className="mt-2"
          caption={t('logs.view.tripPlanner.table.caption')}
          emptyLabel={t('logs.view.tripPlanner.noTrips')}
          rows={tripRows}
          getRowKey={(trip, index) => trip.id ?? String(index)}
          columns={[
            {
              key: 'index',
              header: t('logs.view.tripPlanner.table.index'),
              cell: (_trip, index) => index + 1,
            },
            {
              key: 'start',
              header: t('logs.view.tripPlanner.table.start'),
              cell: (trip) =>
                `${dateFormat.formatDateTime(trip.start_at)} ${formatCoordinatePair(trip.start_lat, trip.start_lng)}`,
            },
            {
              key: 'end',
              header: t('logs.view.tripPlanner.table.end'),
              cell: (trip) =>
                `${dateFormat.formatDateTime(trip.end_at)} ${formatCoordinatePair(trip.end_lat, trip.end_lng)}`,
            },
          ]}
        />
      </div>

      <PermissionGate permission={PERM.routesCreate}>
        <form
          className="flex flex-col gap-3 rounded-lg border border-stroke p-4"
          noValidate
          onSubmit={(event) => {
            event.preventDefault();
            void onSubmit();
          }}
        >
          <h3 className="text-body font-semibold text-neutral-900">
            {t('logs.view.tripPlanner.formTitle')}
          </h3>
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
            <div className="flex flex-col gap-1">
              <FormInput
                name="from"
                control={form.control}
                label={t('logs.view.tripPlanner.fields.from')}
                required
              />
              <button
                type="button"
                onClick={copyLastLocation}
                className="self-start text-body-sm font-medium text-primary hover:underline"
              >
                {t('logs.view.tripPlanner.copyLastLocation')}
              </button>
            </div>
            <FormInput
              name="to"
              control={form.control}
              label={t('logs.view.tripPlanner.fields.to')}
              required
            />
            <FormInput
              name="geofenceRadiusM"
              type="number"
              control={form.control}
              label={t('logs.view.tripPlanner.fields.geofenceRadius')}
            />
          </div>
          <FormTextarea
            name="note"
            control={form.control}
            label={t('logs.view.tripPlanner.fields.note')}
            rows={2}
          />
          {!unitId ? <Alert variant="warning" message={t('logs.view.tripPlanner.noUnit')} /> : null}
          <div>
            <Button type="submit" loading={createRoute.isPending} disabled={!unitId}>
              {t('logs.view.tripPlanner.submit')}
            </Button>
          </div>
        </form>
      </PermissionGate>
    </div>
  );
}
