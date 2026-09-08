/**
 * TrackOnMapPage — integratsiya testi (MSW): yuklanish, `/tracking/live` xato
 * holati + retry, sana navigatori va `VIN`/`Device Serial` manbalarini
 * ajratish (§7.7.2).
 *
 * Xarita `VITE_MAP_STYLE_URL` test muhitida bo'sh — `LazyMapCanvas`
 * `MapUnavailable`ni chizadi va maplibre umuman yuklanmaydi, shuning uchun
 * jsdom'da WebGL kerak emas.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import type { ReactElement } from 'react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { PERM } from '@/lib/permissions';
import { hosSummaryHandler } from '@/mocks/handlers/hos';
import { url } from '@/mocks/handlers/shared';
import {
  liveUnitFixture,
  trackingLiveErrorHandler,
  unitTripsHandler,
} from '@/mocks/handlers/tracking';
import { unitFixture } from '@/mocks/handlers/units';
import { server } from '@/test/msw-server';

import { TrackOnMapPage } from './TrackOnMapPage';

afterEach(() => {
  server.resetHandlers();
});

const liveHandler = http.get(url('/tracking/live'), () =>
  HttpResponse.json({ data: [liveUnitFixture()], meta: { page: 1, per_page: 25, total: 1 } }),
);

const unitHandler = http.get(url('/units/:id'), () =>
  HttpResponse.json({ data: unitFixture({ id: 'unit-1' }) }),
);

/** `device_serial` bor, `vin` yo'q — DTO'da VIN maydoni umuman mavjud emas. */
const diagnosticsHandler = http.get(url('/units/:id/diagnostics'), () =>
  HttpResponse.json({
    data: {
      device_id: 'eld-1',
      device_serial: 'ELD-000123',
      connection_type: 'cellular',
      malfunction_codes: [],
      telemetry: {
        battery_pct: 96.5,
        battery_voltage_v: 13.8,
        coolant_temp_c: 88.4,
        engine_hours: 14_320.75,
        fuel_pct: 62.5,
        odometer_m: 128_430_000,
        oil_level_pct: 78,
        coolant_level_pct: 91.2,
      },
    },
  }),
);

function renderPage() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  function Wrapper(): ReactElement {
    return (
      <QueryClientProvider client={queryClient}>
        <PermissionsProvider
          permissions={[PERM.trackingViewLive, PERM.trackingViewHistory, PERM.unitsDiagnostics]}
        >
          <MemoryRouter initialEntries={['/tracking/units/unit-1']}>
            <Routes>
              <Route path="/tracking/units/:unitId" element={<TrackOnMapPage />} />
            </Routes>
          </MemoryRouter>
        </PermissionsProvider>
      </QueryClientProvider>
    );
  }
  return render(<Wrapper />);
}

describe('TrackOnMapPage', () => {
  it("unit sarlavhasi, haydovchi paneli va trip timeline'ini chizadi", async () => {
    server.use(liveHandler, unitHandler, diagnosticsHandler, unitTripsHandler, hosSummaryHandler);
    renderPage();

    await waitFor(() =>
      expect(screen.getByRole('heading', { name: 'Unit # 1021' })).toBeInTheDocument(),
    );
    expect(await screen.findByText('John Doe')).toBeInTheDocument();
    // Joylashuv — F101 formatida.
    expect(screen.getAllByText('31.5200000, 74.3500000').length).toBeGreaterThan(0);
  });

  it("VIN ni unit DTO'sidan, device serial ni diagnostikadan oladi", async () => {
    server.use(liveHandler, unitHandler, diagnosticsHandler, unitTripsHandler, hosSummaryHandler);
    renderPage();

    expect(await screen.findByText('1FUJGLDR9CLBP8834')).toBeInTheDocument();
    expect(screen.getByText('Device Serial')).toBeInTheDocument();
    expect(screen.getAllByText('ELD-000123').length).toBeGreaterThan(0);
  });

  it("batareyani ko'rsatadi (§7.7.2 1-blok)", async () => {
    server.use(liveHandler, unitHandler, diagnosticsHandler, unitTripsHandler, hosSummaryHandler);
    renderPage();

    expect(await screen.findByText('Battery')).toBeInTheDocument();
    // Batareya `GET /units/{id}/diagnostics` → `telemetry{}` dan keladi —
    // `LiveUnit` DTO'sida bunday maydon yo'q.
    expect(await screen.findByText('97% · 13.8 V')).toBeInTheDocument();
  });

  it("`/tracking/live` yiqilsa ErrorState + retry ko'rsatadi (bo'sh xarita emas)", async () => {
    server.use(trackingLiveErrorHandler, unitHandler, diagnosticsHandler, unitTripsHandler);
    renderPage();

    const alert = await screen.findByRole('alert');
    expect(alert).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Try again' })).toBeInTheDocument();
    // Xarita/yon panel chizilmaydi.
    expect(screen.queryByText('Unit Diagnostics')).not.toBeInTheDocument();
  });

  it("sana navigatori oldingi kunga o'tadi", async () => {
    server.use(liveHandler, unitHandler, diagnosticsHandler, unitTripsHandler, hosSummaryHandler);
    const user = userEvent.setup();
    renderPage();

    const previous = await screen.findByRole('button', { name: 'Previous day' });
    const dayLabel = () => previous.parentElement?.querySelector('span')?.textContent ?? '';
    const before = dayLabel();
    await user.click(previous);
    await waitFor(() => expect(dayLabel()).not.toBe(before));

    await user.click(await screen.findByRole('button', { name: 'Next day' }));
    await waitFor(() => expect(dayLabel()).toBe(before));
  });
});
