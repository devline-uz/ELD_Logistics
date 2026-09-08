/**
 * Tracking — MSW handler'lari (fe-testing §MSW, bosqich 4).
 */
import { http, HttpResponse } from 'msw';

import type { ListResponse, LiveUnit, Trip, TripDetail } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function liveUnitFixture(overrides: Partial<LiveUnit> = {}): LiveUnit {
  return {
    unit_id: 'unit-1',
    unit_number: '1021',
    driver: { id: 'driver-1', first_name: 'John', last_name: 'Doe' },
    duty_status: 'DR',
    online_status: 'online',
    eld_device_serial: 'ELD-000123',
    speed_kmh: 62.5,
    heading_deg: 180,
    lat: 31.52,
    lng: 74.35,
    odometer_m: 128_430_000,
    last_seen_at: '2026-09-07T05:12:00Z',
    out_of_service: false,
    ...overrides,
  };
}

export const trackingLiveHandler = http.get(url('/tracking/live'), () =>
  HttpResponse.json({
    data: [liveUnitFixture()],
    meta: listMeta(),
  } satisfies ListResponse<LiveUnit>),
);

export const trackingLiveEmptyHandler = http.get(url('/tracking/live'), () =>
  HttpResponse.json({ data: [], meta: listMeta({ total: 0 }) } satisfies ListResponse<LiveUnit>),
);

export const trackingLiveErrorHandler = http.get(url('/tracking/live'), () =>
  jsonError('VALIDATION_ERROR', 'invalid online_status', 422),
);

export function tripFixture(overrides: Partial<Trip> = {}): Trip {
  return {
    id: 'trip-1',
    unit_id: 'unit-1',
    unit_number: '1021',
    driver: { id: 'driver-1', first_name: 'John', last_name: 'Doe' },
    start_at: '2026-09-06T05:12:00Z',
    end_at: '2026-09-06T07:44:00Z',
    start_lat: 31.52,
    start_lng: 74.35,
    end_lat: 31.98,
    end_lng: 74.91,
    distance_m: 152_300,
    duration_sec: 9120,
    max_speed_kmh: 104.2,
    open: false,
    ...overrides,
  };
}

export const unitTripsHandler = http.get(url('/units/:id/trips'), () =>
  HttpResponse.json({ data: [tripFixture()], meta: listMeta() } satisfies ListResponse<Trip>),
);

export const unitTripsEmptyHandler = http.get(url('/units/:id/trips'), () =>
  HttpResponse.json({ data: [], meta: listMeta({ total: 0 }) } satisfies ListResponse<Trip>),
);

export const unitTripsNotFoundHandler = http.get(url('/units/:id/trips'), () =>
  jsonError('NOT_FOUND', 'Unit not found', 404),
);

export function tripDetailFixture(overrides: Partial<TripDetail> = {}): TripDetail {
  return {
    ...tripFixture(),
    point_count: 412,
    polyline: '_p~iF~ps|U_ulLnnqC',
    polyline_key: 'unit-1/trips/2026/09/trip-1.polyline',
    ...overrides,
  };
}

export const tripGetHandler = http.get(url('/trips/:id'), () =>
  HttpResponse.json({ data: tripDetailFixture() }),
);

export const tripGetNotFoundHandler = http.get(url('/trips/:id'), () =>
  jsonError('NOT_FOUND', 'Trip not found', 404),
);
