/**
 * TripPlannerTab — integratsiya testi (MSW): segment tanlash (klaviatura bilan
 * ham) va xarita ma'lumotining jadval ekvivalenti (F171, a11y).
 *
 * Testda `VITE_MAP_STYLE_URL` bo'sh — `LazyMapCanvas` `MapUnavailable`ni
 * ko'rsatadi, ya'ni `maplibre-gl` jsdom'da yuklanmaydi. Tekshiriladigan narsa
 * xaritaning o'zi emas, ekranning **matnli/klaviatura** qatlami.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import type { ReactElement } from 'react';
import { afterEach, describe, expect, it } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { url } from '@/mocks/handlers/shared';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';
import { useDateFormat } from '@/hooks/useDateFormat';

import { TripPlannerTab } from './TripPlannerTab';

const TRIPS = [
  {
    id: 'trip-1',
    start_at: '2026-09-06T08:00:00Z',
    end_at: '2026-09-06T10:00:00Z',
    start_lat: 41.311081,
    start_lng: 69.240562,
    end_lat: 41.5,
    end_lng: 69.5,
    distance_m: 42_000,
    duration_sec: 7200,
  },
  {
    id: 'trip-2',
    start_at: '2026-09-06T12:00:00Z',
    end_at: '2026-09-06T14:00:00Z',
    start_lat: 41.5,
    start_lng: 69.5,
    end_lat: 41.9,
    end_lng: 70.1,
    distance_m: 61_000,
    duration_sec: 7200,
  },
];

const tripsHandler = http.get(url('/units/:id/trips'), () =>
  HttpResponse.json({ data: TRIPS, meta: { page: 1, per_page: 25, total: TRIPS.length } }),
);

const tripsEmptyHandler = http.get(url('/units/:id/trips'), () =>
  HttpResponse.json({ data: [], meta: { page: 1, per_page: 25, total: 0 } }),
);

afterEach(() => {
  server.resetHandlers();
});

function Harness(): ReactElement {
  const dateFormat = useDateFormat();
  return (
    <TripPlannerTab
      unitId="unit-1"
      driverId="driver-1"
      logDate="2026-09-06"
      dateFormat={dateFormat}
    />
  );
}

function renderTab() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={[PERM.routesCreate]}>
        <ToastProvider>
          <Harness />
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

describe('TripPlannerTab', () => {
  it('segmentni klaviatura bilan tanlaydi (aria-pressed almashadi)', async () => {
    server.use(tripsHandler);
    const user = userEvent.setup();
    renderTab();

    const list = await screen.findByRole('list', { name: 'Trip segments' });
    const buttons = within(list).getAllByRole('button');
    expect(buttons).toHaveLength(2);
    const [first, second] = buttons;
    if (!first || !second) throw new Error('segment buttons not rendered');
    expect(first).toHaveAttribute('aria-pressed', 'false');

    first.focus();
    await user.keyboard('{Enter}');

    await waitFor(() => expect(first).toHaveAttribute('aria-pressed', 'true'));
    expect(second).toHaveAttribute('aria-pressed', 'false');

    await user.click(second);
    await waitFor(() => expect(second).toHaveAttribute('aria-pressed', 'true'));
    expect(first).toHaveAttribute('aria-pressed', 'false');
  });

  it("xarita ma'lumotini jadval ekvivalenti sifatida beradi (F171)", async () => {
    server.use(tripsHandler);
    const user = userEvent.setup();
    renderTab();

    // Jadval DOM'da har doim mavjud (sr-only) — skrinrider uchun ekvivalent.
    const table = await screen.findByRole('table', { name: 'Trip segments shown on the map' });
    // 1 sarlavha + 2 segment
    await waitFor(() => expect(within(table).getAllByRole('row')).toHaveLength(3));
    expect(within(table).getByText(/41\.3110810, 69\.2405620/)).toBeInTheDocument();

    // "Show as table" tugmasi jadvalni ko'zga ham ko'rinadigan qiladi.
    // Jadval doimo DOM'da bo'lgani uchun tugma disclosure emas, toggle:
    // `aria-pressed` (a11y ko'rigi B4 — `aria-expanded` yolg'on ma'lumot berardi).
    const toggle = screen.getByRole('button', { name: 'Show as table' });
    expect(toggle).toHaveAttribute('aria-pressed', 'false');
    await user.click(toggle);
    expect(screen.getByRole('button', { name: 'Hide table' })).toHaveAttribute(
      'aria-pressed',
      'true',
    );
  });

  it("segment bo'lmaganda jadval bo'sh holat matnini ko'rsatadi", async () => {
    server.use(tripsEmptyHandler);
    renderTab();

    const table = await screen.findByRole('table', { name: 'Trip segments shown on the map' });
    await waitFor(() =>
      expect(within(table).getByText('No trips recorded for this day.')).toBeInTheDocument(),
    );
  });
});
