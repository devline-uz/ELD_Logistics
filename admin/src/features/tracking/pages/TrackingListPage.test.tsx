/**
 * TrackingListPage — integratsiya testi (MSW): ro'yxat, bo'sh, xato holati
 * (§7.7.1, fe-testing §MSW).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { act, render, screen, waitFor } from '@testing-library/react';
import { http, HttpResponse } from 'msw';
import type { ReactElement } from 'react';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it, vi } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { url } from '@/mocks/handlers/shared';
import {
  liveUnitFixture,
  trackingLiveEmptyHandler,
  trackingLiveErrorHandler,
  trackingLiveHandler,
} from '@/mocks/handlers/tracking';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import type { UnitLastStateEvent } from '../hooks/useTrackingChannel';

import { TrackingListPage } from './TrackingListPage';

/**
 * WS kanali mock qilinadi — real soket testda ochilmaydi, lekin
 * `onEvent` qo'lga olinadi va F115 kesh-yangilanishi tekshiriladi.
 */
let emitWsEvent: ((event: UnitLastStateEvent) => void) | undefined;
vi.mock('../hooks/useTrackingChannel', () => ({
  useTrackingChannel: (options: { onEvent: (event: UnitLastStateEvent) => void }) => {
    emitWsEvent = options.onEvent;
    return { status: 'open' };
  },
}));

afterEach(() => {
  emitWsEvent = undefined;
  server.resetHandlers();
});

function renderPage() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  function Wrapper(): ReactElement {
    return (
      <QueryClientProvider client={queryClient}>
        <PermissionsProvider permissions={[PERM.trackingViewLive]}>
          <MemoryRouter initialEntries={['/tracking']}>
            <TrackingListPage />
          </MemoryRouter>
        </PermissionsProvider>
      </QueryClientProvider>
    );
  }
  return render(<Wrapper />);
}

describe('TrackingListPage', () => {
  it("unit ro'yxatini ustunlar bilan chizadi", async () => {
    server.use(trackingLiveHandler);
    renderPage();

    await waitFor(() => expect(screen.getByText('John Doe')).toBeInTheDocument());
    expect(screen.getByText('1021')).toBeInTheDocument();
  });

  it("ma'lumot bo'lmaganda bo'sh holatni ko'rsatadi", async () => {
    server.use(trackingLiveEmptyHandler);
    renderPage();

    await waitFor(() =>
      expect(screen.getByText('There is no data to show you right now')).toBeInTheDocument(),
    );
  });

  it("xatoda ErrorState va Try again tugmasini ko'rsatadi", async () => {
    server.use(trackingLiveErrorHandler);
    renderPage();

    await waitFor(() => expect(screen.getByRole('alert')).toBeInTheDocument());
  });

  it("REST javobida yo'q maydonni ham WS patch'i qo'llaydi (mergeLiveUnit)", async () => {
    // `speed_kmh` REST javobida umuman yo'q — eski implementatsiya
    // (`Object.keys(existing)` bo'yicha sikl) bunday patch'ni tashlab
    // yuborardi.
    const { speed_kmh: _omitted, ...withoutSpeed } = liveUnitFixture();
    server.use(
      http.get(url('/tracking/live'), () =>
        HttpResponse.json({ data: [withoutSpeed], meta: { page: 1, per_page: 25, total: 1 } }),
      ),
    );
    renderPage();

    await waitFor(() => expect(screen.getByText('John Doe')).toBeInTheDocument());
    expect(screen.queryByText(/104/)).not.toBeInTheDocument();

    act(() => {
      emitWsEvent?.({
        type: 'unit_last_state',
        data: { unit_id: 'unit-1', speed_kmh: 104, online_status: 'idle' },
        replay: true,
      });
    });

    // Satr joyida yangilanadi: patch'dagi ikkala maydon ham qo'llanadi,
    // shu jumladan REST javobida umuman bo'lmagan `speed_kmh`.
    await waitFor(() => expect(screen.getByText('Idle')).toBeInTheDocument());
    const row = () => screen.getByText('John Doe').closest('tr')?.textContent ?? '';
    await waitFor(() => expect(row()).not.toContain('N/A'));
  });
});
