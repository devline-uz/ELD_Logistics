/**
 * `HISTORIES` bloki — Track on Map yon paneli, 3-blok (§7.7.2).
 *
 * `GET /units/{id}/trips?date=` — vertikal timeline, har segment: boshlanish
 * nuqtasi, `Range` (masofa), `Duration`, tugash nuqtasi. Segment bosilganda
 * xaritada polyline yoritiladi (chaqiruvchi `onSelect` orqali).
 */
import { useTranslation } from 'react-i18next';

import type { Trip } from '@/api/types';
import { EmptyState } from '@/components/feedback/EmptyState';
import { ErrorState } from '@/components/feedback/ErrorState';
import { Skeleton } from '@/components/feedback/Skeleton';
import { formatCoordinatePair } from '@/lib/format';
import { useDateFormat } from '@/hooks/useDateFormat';
import { useUnitSystem } from '@/hooks/useUnitSystem';

export interface TripHistoryTimelineProps {
  trips: Trip[];
  selectedTripId: string | undefined;
  onSelect: (tripId: string) => void;
  isLoading: boolean;
  isError: boolean;
  onRetry: () => void;
}

export function TripHistoryTimeline({
  trips,
  selectedTripId,
  onSelect,
  isLoading,
  isError,
  onRetry,
}: TripHistoryTimelineProps) {
  const { t } = useTranslation();
  const { formatTime, formatDuration } = useDateFormat();
  const { formatDistance } = useUnitSystem();

  if (isLoading) {
    return <Skeleton variant="card" count={3} />;
  }

  if (isError) {
    return <ErrorState message={t('tracking.trackOnMap.histories.error')} onRetry={onRetry} />;
  }

  if (trips.length === 0) {
    return (
      <EmptyState
        title={t('tracking.trackOnMap.histories.emptyTitle')}
        description={t('tracking.trackOnMap.histories.emptyDescription')}
      />
    );
  }

  return (
    <ol aria-label={t('tracking.trackOnMap.histories.title')} className="flex flex-col gap-2">
      {trips.map((trip, index) => {
        const selected = trip.id === selectedTripId;
        return (
          <li key={trip.id ?? index}>
            <button
              type="button"
              onClick={() => trip.id && onSelect(trip.id)}
              aria-pressed={selected}
              className={`w-full rounded-md border px-3 py-2 text-start text-body-sm ${
                selected
                  ? 'border-primary bg-light'
                  : 'border-stroke bg-surface hover:bg-surface-muted'
              }`}
            >
              <div className="flex items-center justify-between font-medium text-neutral-900">
                <span>{formatCoordinatePair(trip.start_lat, trip.start_lng)}</span>
                <span>{formatTime(trip.start_at)}</span>
              </div>
              <div className="flex items-center justify-between text-neutral-500">
                <span>
                  {t('tracking.trackOnMap.histories.range')}:{' '}
                  {formatDistance(trip.distance_m ?? undefined)}
                </span>
                <span>
                  {t('tracking.trackOnMap.histories.duration')}:{' '}
                  {formatDuration(
                    typeof trip.duration_sec === 'number' ? trip.duration_sec : undefined,
                    { unit: 'seconds' },
                  )}
                </span>
              </div>
              <div className="flex items-center justify-between text-neutral-900">
                <span>{formatCoordinatePair(trip.end_lat, trip.end_lng)}</span>
                <span>
                  {trip.end_at
                    ? formatTime(trip.end_at)
                    : t('tracking.trackOnMap.histories.ongoing')}
                </span>
              </div>
            </button>
          </li>
        );
      })}
    </ol>
  );
}

export default TripHistoryTimeline;
