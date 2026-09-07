/**
 * Trip Planner tabi (7.4.3(d)). Xarita — **placeholder** (4-bosqichda
 * to'ldiriladi, TZ ochiq talab). Segmentlar ro'yxati `GET /units/{id}/trips`
 * dan, "Create route" formasi `POST /routes` ga yuboriladi.
 *
 * **F101**: koordinatalar 7 xonali o'nlik format bilan ko'rsatiladi
 * (`toFixed(7)`), vergul juftlik ajratgichi.
 */
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
import type { UseDateFormatResult } from '@/hooks/useDateFormat';
import { PERM } from '@/lib/permissions';

import { useRouteCreate, useUnitTripsForDate } from '../lib/tripPlannerApi';

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

function formatCoordinate(lat?: number, lng?: number): string {
  if (lat === undefined || lng === undefined) return '';
  return `${lat.toFixed(7)}, ${lng.toFixed(7)}`;
}

export function TripPlannerTab({ unitId, driverId, logDate, dateFormat }: TripPlannerTabProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const trips = useUnitTripsForDate(unitId, logDate);
  const createRoute = useRouteCreate();

  const form = useForm<CreateRouteFormValues>({
    resolver: zodResolver(createRouteSchema),
    defaultValues: { from: '', to: '', geofenceRadiusM: '300', note: '' },
  });

  const copyLastLocation = () => {
    const lastTrip = trips.data?.data?.[trips.data.data.length - 1];
    const text = formatCoordinate(lastTrip?.end_lat, lastTrip?.end_lng);
    if (text) form.setValue('from', text, { shouldDirty: true });
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
      {/* Xarita — 4-bosqichda haqiqiy komponent bilan almashtiriladi (TZ 7.4.3(d)). */}
      <div className="flex h-64 items-center justify-center rounded-lg border border-dashed border-stroke bg-surface-muted text-body-sm text-neutral-500">
        {t('logs.view.tripPlanner.mapPlaceholder')}
      </div>

      <div>
        <h3 className="mb-2 text-body font-semibold text-neutral-900">
          {t('logs.view.tripPlanner.segmentsTitle')}
        </h3>
        {trips.isLoading ? (
          <Skeleton variant="table-row" count={3} />
        ) : trips.isError ? (
          <ErrorState message={trips.error?.message} onRetry={() => void trips.refetch()} />
        ) : (trips.data?.data ?? []).length === 0 ? (
          <p className="text-body-sm text-neutral-500">{t('logs.view.tripPlanner.noTrips')}</p>
        ) : (
          <ul className="flex flex-col gap-2">
            {(trips.data?.data ?? []).map((trip) => (
              <li key={trip.id} className="rounded-md border border-stroke p-3 text-body-sm">
                <div className="flex flex-wrap justify-between gap-2">
                  <span>
                    {dateFormat.formatDateTime(trip.start_at)} –{' '}
                    {dateFormat.formatDateTime(trip.end_at)}
                  </span>
                  <span className="text-neutral-500">
                    {formatCoordinate(trip.start_lat, trip.start_lng)}
                  </span>
                </div>
              </li>
            ))}
          </ul>
        )}
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
