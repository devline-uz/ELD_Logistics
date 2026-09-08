/**
 * HOS query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  hosSummaryFixture,
  hosSummaryHandler,
  hosSummaryNotFoundHandler,
} from '@/mocks/handlers/hos';
import { url } from '@/mocks/handlers/shared';

import { useHosSummaries, useHosSummary } from './hos';
import { withQueryClient } from './test-utils';

describe('useHosSummary', () => {
  it("F98: hisoblagichlar to'liq backend javobidan keladi", async () => {
    server.use(hosSummaryHandler);
    const { result } = renderHook(() => useHosSummary('driver-1', '2026-09-07'), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(hosSummaryFixture());
  });

  it('404 (haydovchi topilmadi) ApiError bilan tugaydi', async () => {
    server.use(hosSummaryNotFoundHandler);
    const { result } = renderHook(() => useHosSummary('driver-999'), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(404);
  });

  it("driverId bo'lmasa so'rov yubormaydi", () => {
    const { result } = renderHook(() => useHosSummary(undefined), { wrapper: withQueryClient() });
    expect(result.current.fetchStatus).toBe('idle');
  });
});

describe('useHosSummaries', () => {
  it("F95: bir vaqtning o'zida ≤6 so'rov bilan barcha haydovchilarni xaritaga yig'adi", async () => {
    let concurrent = 0;
    let maxConcurrent = 0;
    server.use(
      http.get(url('/drivers/:id/hos-summary'), async ({ params }) => {
        concurrent += 1;
        maxConcurrent = Math.max(maxConcurrent, concurrent);
        await new Promise((resolve) => setTimeout(resolve, 5));
        concurrent -= 1;
        return HttpResponse.json({
          data: hosSummaryFixture({ driver_id: params.id as string }),
        });
      }),
    );

    const driverIds = Array.from({ length: 14 }, (_, i) => `driver-${i}`);
    const { result } = renderHook(() => useHosSummaries(driverIds, '2026-09-07'), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(Object.keys(result.current.data ?? {})).toHaveLength(14);
    expect(maxConcurrent).toBeLessThanOrEqual(6);
  });

  it("bitta haydovchi so'rovi xato bo'lsa ham butun batch yiqilmaydi", async () => {
    server.use(
      http.get(url('/drivers/:id/hos-summary'), ({ params }) => {
        if (params.id === 'driver-bad') {
          return HttpResponse.json(
            { error: { code: 'NOT_FOUND', message: 'not found' } },
            { status: 404 },
          );
        }
        return HttpResponse.json({ data: hosSummaryFixture({ driver_id: params.id as string }) });
      }),
    );

    const { result } = renderHook(() => useHosSummaries(['driver-1', 'driver-bad'], '2026-09-07'), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.['driver-1']).toBeDefined();
    expect(result.current.data?.['driver-bad']).toBeUndefined();
  });

  it("bo'sh driverIds bilan so'rov yubormaydi", () => {
    const { result } = renderHook(() => useHosSummaries([], '2026-09-07'), {
      wrapper: withQueryClient(),
    });
    expect(result.current.fetchStatus).toBe('idle');
  });
});
