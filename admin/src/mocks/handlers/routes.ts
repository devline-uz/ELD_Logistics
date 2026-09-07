/**
 * Routes — MSW handler'lari (fe-testing §MSW, §7.7.3).
 */
import { http, HttpResponse } from 'msw';

import type { Directions, ListResponse, Route } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function routeFixture(overrides: Partial<Route> = {}): Route {
  return {
    id: 'route-1',
    unit_id: 'unit-1',
    driver_id: 'driver-1',
    driver_name: 'John Miller',
    origin: { text: 'Dallas, TX', lat: 32.7767, lng: -96.797 },
    destination: { text: 'Chicago, IL', lat: 41.8781, lng: -87.6298 },
    sequence: 1,
    geofence_m: 300,
    status: 'ongoing',
    note: 'Drop at dock 4',
    created_at: '2026-09-06T07:45:00Z',
    started_at: '2026-09-06T08:00:00Z',
    ...overrides,
  };
}

export const routesListHandler = http.get(url('/routes'), () =>
  HttpResponse.json({ data: [routeFixture()], meta: listMeta() } satisfies ListResponse<Route>),
);

export const routesListEmptyHandler = http.get(url('/routes'), () =>
  HttpResponse.json({ data: [], meta: listMeta({ total: 0 }) } satisfies ListResponse<Route>),
);

export const routesListErrorHandler = http.get(url('/routes'), () =>
  jsonError('VALIDATION_ERROR', 'invalid status', 422),
);

export const routeGetHandler = http.get(url('/routes/:id'), ({ params }) =>
  HttpResponse.json({ data: routeFixture({ id: params.id as string }) }),
);

export const routeGetNotFoundHandler = http.get(url('/routes/:id'), () =>
  jsonError('NOT_FOUND', 'Route not found', 404),
);

export const routeCreateHandler = http.post(url('/routes'), () =>
  HttpResponse.json({ data: routeFixture({ id: 'route-new' }) }, { status: 201 }),
);

export const routeCreateValidationErrorHandler = http.post(url('/routes'), () =>
  jsonError('VALIDATION_ERROR', 'validation failed', 422, [
    { field: 'unit_id', message: 'required' },
  ]),
);

export const routeUpdateHandler = http.patch(url('/routes/:id'), ({ params }) =>
  HttpResponse.json({ data: routeFixture({ id: params.id as string }) }),
);

export const routeDeleteHandler = http.delete(
  url('/routes/:id'),
  () => new HttpResponse(null, { status: 204 }),
);

export const routeNotCompletedHandler = http.post(url('/routes/:id/not-completed'), ({ params }) =>
  HttpResponse.json({
    data: routeFixture({
      id: params.id as string,
      status: 'not_completed',
      not_completed_reason: 'breakdown',
    }),
  }),
);

export const routeNotCompletedConflictHandler = http.post(url('/routes/:id/not-completed'), () =>
  jsonError('INVALID_STATE', 'Route is not ongoing', 409),
);

export function directionsFixture(overrides: Partial<Directions> = {}): Directions {
  return {
    route_id: 'route-1',
    provider: 'nominatim',
    origin: { text: 'Dallas, TX', lat: 32.7767, lng: -96.797 },
    destination: { text: 'Chicago, IL', lat: 41.8781, lng: -87.6298 },
    distance_m: 412_345,
    duration_s: 15_600,
    polyline: '_p~iF~ps|U_ulLnnqC',
    ...overrides,
  };
}

export const routeDirectionsHandler = http.get(url('/routes/:id/directions'), () =>
  HttpResponse.json({ data: directionsFixture() }),
);

export const routeDirectionsUnavailableHandler = http.get(url('/routes/:id/directions'), () =>
  HttpResponse.json({ data: directionsFixture({ provider: 'nop', polyline: '' }) }),
);
