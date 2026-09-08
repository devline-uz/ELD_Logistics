/**
 * DashboardPage — integratsiya testi (MSW): KPI render, WS `dashboard_summary`
 * hodisasidan keyin qiymat yangilanishi, xato holati, ruxsatsiz holat
 * (§7.2, fe-testing §MSW).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { act, render, screen, waitFor } from '@testing-library/react';
import type { ReactElement } from 'react';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it, vi } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { RouteGuard } from '@/app/RouteGuard';
import type { DashboardSummary } from '@/api/types';
import {
  dashboardSummaryErrorHandler,
  dashboardSummaryFixture,
  dashboardSummaryHandler,
} from '@/mocks/handlers/dashboard';
import { url } from '@/mocks/handlers/shared';
import { trackingLiveEmptyHandler, trackingLiveHandler } from '@/mocks/handlers/tracking';
import { PERM } from '@/lib/permissions';
import type { RealtimeEvent } from '@/lib/ws';
import { server } from '@/test/msw-server';
import { http, HttpResponse } from 'msw';

import { DashboardPage } from './DashboardPage';

/**
 * `@/hooks/useChannel` mock qilinadi — real soket ochilmaydi, lekin har
 * kanal (`dashboard`/`tracking`) uchun berilgan `onEvent` qo'lga olinadi.
 */
const channelHandlers = new Map<string, (event: RealtimeEvent<unknown>) => void>();
vi.mock('@/hooks/useChannel', () => ({
  useChannel: (
    channel: string,
    _filter: unknown,
    onEvent: (event: RealtimeEvent<unknown>) => void,
  ) => {
    channelHandlers.set(channel, onEvent);
    return { status: 'live' };
  },
}));

afterEach(() => {
  channelHandlers.clear();
  server.resetHandlers();
});

function renderPage(permissions: string[] = [PERM.dashboardRead, PERM.trackingViewLive]) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  function Wrapper(): ReactElement {
    return (
      <QueryClientProvider client={queryClient}>
        <PermissionsProvider permissions={permissions}>
          <MemoryRouter initialEntries={['/']}>
            <RouteGuard permission={PERM.dashboardRead}>
              <DashboardPage />
            </RouteGuard>
          </MemoryRouter>
        </PermissionsProvider>
      </QueryClientProvider>
    );
  }
  return render(<Wrapper />);
}

describe('DashboardPage', () => {
  it('9 KPI kartasi va status blokini backend qiymatlari bilan chizadi', async () => {
    server.use(dashboardSummaryHandler, trackingLiveHandler);
    renderPage();

    await waitFor(() => expect(screen.getByText('38')).toBeInTheDocument());
    expect(screen.getByText('44')).toBeInTheDocument();
    expect(screen.getByText('Active Units')).toBeInTheDocument();
    expect(screen.getByText("Route's Details")).toBeInTheDocument();
    expect(screen.getByText('Dallas, TX')).toBeInTheDocument();
  });

  it('WS `dashboard_summary` hodisasidan keyin KPI qiymati yangilanadi', async () => {
    server.use(dashboardSummaryHandler, trackingLiveEmptyHandler);
    renderPage();

    await waitFor(() => expect(screen.getByText('38')).toBeInTheDocument());

    const nextSummary: DashboardSummary = dashboardSummaryFixture({
      kpi: {
        active_units: 51,
        active_drivers: 44,
        drivers_on_duty: 21,
        violations: 4,
        uncertified_logs: 6,
        unassigned_driving: 3,
        disconnected_eld: 2,
        malfunction_eld: 1,
        pending_log_edits: 2,
      },
    });

    act(() => {
      channelHandlers.get('dashboard')?.({
        type: 'dashboard_summary',
        data: nextSummary,
      });
    });

    await waitFor(() => expect(screen.getByText('51')).toBeInTheDocument());
    expect(screen.queryByText('38')).not.toBeInTheDocument();
  });

  it('summary xatosida KPI va Route Details bloklari mustaqil ErrorState ko’rsatadi', async () => {
    server.use(dashboardSummaryErrorHandler, trackingLiveEmptyHandler);
    renderPage();

    const alerts = await waitFor(() => {
      const found = screen.getAllByRole('alert');
      expect(found.length).toBeGreaterThanOrEqual(2);
      return found;
    });
    expect(alerts.length).toBeGreaterThanOrEqual(2);
  });

  it('xarita bloki alohida so’rovdan foydalanadi — summary yiqilsa ham ishlaydi', async () => {
    server.use(dashboardSummaryErrorHandler, trackingLiveHandler);
    renderPage();

    await waitFor(() => expect(screen.getByText('Units Tracking')).toBeInTheDocument());
    // Xarita bloki tracking/live muvaffaqiyatli bo'lgani uchun xato ko'rsatmaydi:
    // faqat summary blokidagi alert(lar) chiqadi.
    await waitFor(() => expect(screen.getAllByRole('alert').length).toBeGreaterThanOrEqual(1));
  });

  it('`dashboard.read` ruxsati bo’lmasa 403 ekranini ko’rsatadi (redirect/404 emas)', () => {
    renderPage([]);

    expect(screen.getByText('You do not have permission to view this page')).toBeInTheDocument();
    expect(screen.queryByText('Active Units')).not.toBeInTheDocument();
  });

  it('`tracking.view_live` ruxsati bo’lmasa xarita blokida "No access" ko’rsatiladi', async () => {
    server.use(dashboardSummaryHandler);
    renderPage([PERM.dashboardRead]);

    await waitFor(() => expect(screen.getByText('No access')).toBeInTheDocument());
  });

  it("marshrutlar bo'sh bo'lganda 'No routes today' ko'rsatadi", async () => {
    server.use(
      http.get(url('/dashboard/summary'), () =>
        HttpResponse.json({ data: dashboardSummaryFixture({ routes: [] }) }),
      ),
      trackingLiveEmptyHandler,
    );
    renderPage();

    await waitFor(() => expect(screen.getByText('No routes today')).toBeInTheDocument());
  });
});
