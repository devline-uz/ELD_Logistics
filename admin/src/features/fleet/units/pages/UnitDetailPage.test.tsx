/**
 * UnitDetailPage — integratsiya testi (MSW): View/Activities/Diagnostics
 * tablari, cross-tenant 404 → "topilmadi" (403 emas), Diagnostics permission
 * gate (2.2, §7.3.2).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import type { ReactElement } from 'react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  unitDiagnosticsHandler,
  unitGetHandler,
  unitGetNotFoundHandler,
  unitHistoryHandler,
} from '@/mocks/handlers/units';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { UnitActivitiesPage, UnitDetailPage, UnitDiagnosticsPage } from './UnitDetailPage';

function renderAt(
  path: string,
  permissions: readonly string[] = [PERM.unitsRead, PERM.unitsDiagnostics, PERM.unitsAssignDriver],
) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  function Wrapper(): ReactElement {
    return (
      <QueryClientProvider client={queryClient}>
        <PermissionsProvider permissions={permissions}>
          <ToastProvider>
            <MemoryRouter initialEntries={[path]}>
              <Routes>
                <Route path="/units/:unitId" element={<UnitDetailPage />} />
                <Route path="/units/:unitId/activities" element={<UnitActivitiesPage />} />
                <Route path="/units/:unitId/diagnostics" element={<UnitDiagnosticsPage />} />
              </Routes>
            </MemoryRouter>
          </ToastProvider>
        </PermissionsProvider>
      </QueryClientProvider>
    );
  }
  return render(<Wrapper />);
}

afterEach(() => {
  server.resetHandlers();
});

describe('UnitDetailPage', () => {
  it('renders unit details on the info tab', async () => {
    server.use(unitGetHandler);
    renderAt('/units/unit-1');

    expect(await screen.findByRole('heading', { name: /unit # 1021/i })).toBeInTheDocument();
    expect(screen.getByText('Freightliner')).toBeInTheDocument();
    expect(screen.getByText('ELD-000123')).toBeInTheDocument();
  });

  it('shows "not found" (not a permission error) for a cross-tenant unit', async () => {
    server.use(unitGetNotFoundHandler);
    renderAt('/units/unit-999');

    expect(await screen.findByText(/could not be found/i)).toBeInTheDocument();
    expect(screen.queryByText(/permission/i)).not.toBeInTheDocument();
  });

  it('renders the activities timeline', async () => {
    server.use(unitGetHandler, unitHistoryHandler);
    renderAt('/units/unit-1/activities');

    expect(await screen.findByText(/status changed from/i)).toBeInTheDocument();
    expect(screen.getByText('Jane Admin')).toBeInTheDocument();
  });

  it('renders diagnostics when units.diagnostics is granted', async () => {
    server.use(unitGetHandler, unitDiagnosticsHandler);
    renderAt('/units/unit-1/diagnostics');

    expect(await screen.findByText('Geotab')).toBeInTheDocument();
  });

  it('hides diagnostics content without units.diagnostics permission', async () => {
    server.use(unitGetHandler, unitDiagnosticsHandler);
    renderAt('/units/unit-1/diagnostics', [PERM.unitsRead]);

    await screen.findByRole('heading', { name: /unit # 1021/i });
    expect(await screen.findByText(/do not have permission/i)).toBeInTheDocument();
  });
});
