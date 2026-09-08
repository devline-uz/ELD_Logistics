/**
 * Dashboard query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import type { QueryClient } from '@tanstack/react-query';

import { server } from '@/test/msw-server';
import {
  dashboardSummaryEmptyHandler,
  dashboardSummaryErrorHandler,
  dashboardSummaryFixture,
  dashboardSummaryHandler,
} from '@/mocks/handlers/dashboard';

import { applyDashboardSummaryEvent, dashboardKeys, useDashboardSummary } from './dashboard';
import { createTestQueryClient, withQueryClient } from './test-utils';

describe('useDashboardSummary', () => {
  it('KPI, status va marshrutlarni {data} shaklida qaytaradi', async () => {
    server.use(dashboardSummaryHandler);
    const { result } = renderHook(() => useDashboardSummary(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.kpi?.active_units).toBe(38);
    expect(result.current.data?.status).toEqual({ on: 9, dr: 12, sb: 5, off: 18 });
    expect(result.current.data?.routes).toHaveLength(1);
  });

  it("bo'sh kunda ham status bloki 0 bilan qaytadi", async () => {
    server.use(dashboardSummaryEmptyHandler);
    const { result } = renderHook(() => useDashboardSummary(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.routes).toEqual([]);
    expect(result.current.data?.kpi?.active_units).toBe(0);
  });

  it('429 javobida ApiError bilan tugaydi', async () => {
    server.use(dashboardSummaryErrorHandler);
    const { result } = renderHook(() => useDashboardSummary(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(429);
  });
});

describe('applyDashboardSummaryEvent', () => {
  it('`dashboard_summary` WS hodisasi keshni to‘g‘ridan-to‘g‘ri almashtiradi', () => {
    const queryClient: QueryClient = createTestQueryClient();
    const summary = dashboardSummaryFixture({
      kpi: { ...dashboardSummaryFixture().kpi, active_units: 99 },
    });

    applyDashboardSummaryEvent(queryClient, summary);

    expect(queryClient.getQueryData(dashboardKeys.summary())).toEqual(summary);
  });
});
