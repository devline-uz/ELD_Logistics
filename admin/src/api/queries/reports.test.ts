/**
 * Reports query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 * `useExportJob` polling shartnomasiga alohida e'tibor: interval o'sishi
 * (2s → 5s → 10s), `done`/`failed`da to'xtash, 5 daqiqalik chegara, unmount'da tozalash.
 */
import { act, renderHook, waitFor } from '@testing-library/react';
import { http, HttpResponse } from 'msw';
import { afterEach, describe, expect, it, vi } from 'vitest';

import { server } from '@/test/msw-server';
import {
  createExportJobProgressionHandler,
  exportJobCreateErrorHandler,
  exportJobCreateFeatureDisabledHandler,
  exportJobCreateHandler,
  exportJobDoneExpiredHandler,
  exportJobDoneHandler,
  exportJobFailedHandler,
  exportJobFixture,
  exportJobNotFoundHandler,
  exportJobsListErrorHandler,
  exportJobsListHandler,
  reportsActivityErrorHandler,
  reportsActivityHandler,
  reportsDistanceByRegionErrorHandler,
  reportsDistanceByRegionHandler,
  reportsUncertifiedLogsErrorHandler,
  reportsUncertifiedLogsHandler,
} from '@/mocks/handlers/reports';
import { url } from '@/mocks/handlers/shared';

import {
  EXPORT_JOB_POLL_MAX_DURATION_MS,
  isExportJobDownloadExpired,
  useExportJob,
  useExportJobCreate,
  useExportJobsList,
  useReportsActivity,
  useReportsDistanceByRegion,
  useReportsUncertifiedLogs,
} from './reports';
import { withQueryClient } from './test-utils';

afterEach(() => {
  server.resetHandlers();
  vi.useRealTimers();
});

describe('useReportsActivity', () => {
  it('Activity Report qatorlarini {data, meta} shaklida qaytaradi', async () => {
    server.use(reportsActivityHandler);
    const { result } = renderHook(
      () => useReportsActivity({ subject: 'units', from: '2026-09-01', to: '2026-09-07' }),
      {
        wrapper: withQueryClient(),
      },
    );

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(result.current.data?.data?.[0]?.name).toBe('1021');
    expect(result.current.data?.data?.[0]?.odometer_change_m).toBe(750_000);
  });

  it('422 javobida ApiError bilan tugaydi', async () => {
    server.use(reportsActivityErrorHandler);
    const { result } = renderHook(
      () => useReportsActivity({ subject: 'units', from: '2026-09-01', to: '2026-09-07' }),
      { wrapper: withQueryClient() },
    );

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useReportsDistanceByRegion', () => {
  it('hisobotni davr `meta`si bilan qaytaradi (F123 — darhol tayyor)', async () => {
    server.use(reportsDistanceByRegionHandler);
    const { result } = renderHook(() => useReportsDistanceByRegion({ quarter: 3, year: 2026 }), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.meta?.total_distance_m).toBe(9_184_320);
    expect(result.current.data?.data?.[0]?.region_code).toBe('US-IL');
  });

  it('422 javobida ApiError bilan tugaydi', async () => {
    server.use(reportsDistanceByRegionErrorHandler);
    const { result } = renderHook(() => useReportsDistanceByRegion({ quarter: 3, year: 2026 }), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useReportsUncertifiedLogs', () => {
  it("8 kundan eskirgan kunlarni ham ro'yxatda qaytaradi (Q19.1)", async () => {
    server.use(reportsUncertifiedLogsHandler);
    const { result } = renderHook(() => useReportsUncertifiedLogs(), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data?.[0]?.days_overdue).toBe(3);
  });

  it('422 javobida ApiError bilan tugaydi', async () => {
    server.use(reportsUncertifiedLogsErrorHandler);
    const { result } = renderHook(() => useReportsUncertifiedLogs(), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useExportJobsList', () => {
  it("export job ro'yxatini qaytaradi", async () => {
    server.use(exportJobsListHandler);
    const { result } = renderHook(() => useExportJobsList({ mine: true }), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data?.[0]?.id).toBe('job-1');
  });

  it('422 javobida ApiError bilan tugaydi', async () => {
    server.use(exportJobsListErrorHandler);
    const { result } = renderHook(() => useExportJobsList({ mine: true }), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
  });
});

describe('useExportJobCreate', () => {
  it("202 javobida navbatga qo'yilgan job'ni qaytaradi", async () => {
    server.use(exportJobCreateHandler);
    const { result } = renderHook(() => useExportJobCreate(), { wrapper: withQueryClient() });

    result.current.mutate({ type: 'distance_by_region', format: 'xlsx' });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.status).toBe('queued');
  });

  it("422 (masalan noto'g'ri format) ApiError bilan tugaydi", async () => {
    server.use(exportJobCreateErrorHandler);
    const { result } = renderHook(() => useExportJobCreate(), { wrapper: withQueryClient() });

    result.current.mutate({ type: 'activity', format: 'zip' });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });

  it('F127: `regulator` turi FMCSA profilida `501 FEATURE_DISABLED` qaytaradi', async () => {
    server.use(exportJobCreateFeatureDisabledHandler);
    const { result } = renderHook(() => useExportJobCreate(), { wrapper: withQueryClient() });

    result.current.mutate({ type: 'regulator', format: 'zip' });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(501);
    expect(result.current.error?.code).toBe('FEATURE_DISABLED');
  });
});

describe('useExportJob — polling shartnomasi (fe-api §9)', () => {
  it("interval 2s → 5s → 10s bo'yicha o'sadi va holat o'zgarishini kuzatadi", async () => {
    vi.useFakeTimers({ shouldAdvanceTime: true });
    server.use(createExportJobProgressionHandler());

    const { result } = renderHook(() => useExportJob('job-1'), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.data?.status).toBe('queued'));

    await act(async () => {
      await vi.advanceTimersByTimeAsync(2_000);
    });
    await waitFor(() => expect(result.current.data?.status).toBe('running'));

    await act(async () => {
      await vi.advanceTimersByTimeAsync(5_000);
    });
    await waitFor(() => expect(result.current.data?.status).toBe('done'));
  });

  it("`done` bo'lganda polling to'xtaydi (keyingi vaqt o'tishi qayta so'rov yubormaydi)", async () => {
    vi.useFakeTimers({ shouldAdvanceTime: true });
    server.use(exportJobDoneHandler);

    const { result } = renderHook(() => useExportJob('job-1'), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.data?.status).toBe('done'));
    const updatedAt = result.current.dataUpdatedAt;

    await act(async () => {
      await vi.advanceTimersByTimeAsync(30_000);
    });

    expect(result.current.dataUpdatedAt).toBe(updatedAt);
    expect(result.current.isFetching).toBe(false);
  });

  it("`failed` bo'lganda polling to'xtaydi va xato matni bor", async () => {
    server.use(exportJobFailedHandler);
    const { result } = renderHook(() => useExportJob('job-1'), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.data?.status).toBe('failed'));
    expect(result.current.data?.error).toBe('the map provider is unavailable');
  });

  it("5 daqiqadan keyin polling to'xtaydi va `pollingTimedOut: true` beriladi", async () => {
    vi.useFakeTimers({ shouldAdvanceTime: true });
    server.use(
      http.get(url('/reports/export-jobs/:id'), ({ params }) =>
        HttpResponse.json({
          data: exportJobFixture({ id: params.id as string, status: 'running' }),
        }),
      ),
    );

    const { result } = renderHook(() => useExportJob('job-1'), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.data?.status).toBe('running'));
    expect(result.current.pollingTimedOut).toBe(false);

    await act(async () => {
      await vi.advanceTimersByTimeAsync(EXPORT_JOB_POLL_MAX_DURATION_MS + 1_000);
    });

    await waitFor(() => expect(result.current.pollingTimedOut).toBe(true));
  });

  it("unmount bo'lganda taymer tozalanadi (keyingi so'rov yuborilmaydi)", async () => {
    vi.useFakeTimers({ shouldAdvanceTime: true });
    let callCount = 0;
    server.use(
      http.get(url('/reports/export-jobs/:id'), ({ params }) => {
        callCount += 1;
        return HttpResponse.json({
          data: exportJobFixture({ id: params.id as string, status: 'queued' }),
        });
      }),
    );

    const { result, unmount } = renderHook(() => useExportJob('job-1'), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.data?.status).toBe('queued'));
    expect(callCount).toBe(1);

    unmount();
    await act(async () => {
      await vi.advanceTimersByTimeAsync(60_000);
    });

    expect(callCount).toBe(1);
  });

  it("cross-tenant/mavjud bo'lmagan job uchun 404 qaytaradi", async () => {
    server.use(exportJobNotFoundHandler);
    const { result } = renderHook(() => useExportJob('job-999'), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(404);
  });
});

describe('isExportJobDownloadExpired', () => {
  it("`download_url`/`expires_at` bo'lmasa false qaytaradi", () => {
    expect(isExportJobDownloadExpired(undefined)).toBe(false);
    expect(isExportJobDownloadExpired(exportJobFixture({ download_url: undefined }))).toBe(false);
  });

  it('24 soatlik oyna ichida false, tashqarisida true qaytaradi (Q75)', () => {
    const job = exportJobFixture({
      download_url: 'https://storage.example.com/x.xlsx',
      expires_at: '2026-09-07T05:12:31Z',
    });

    vi.useFakeTimers();
    vi.setSystemTime(new Date('2026-09-07T05:00:00Z'));
    expect(isExportJobDownloadExpired(job)).toBe(false);

    vi.setSystemTime(new Date('2026-09-07T06:00:00Z'));
    expect(isExportJobDownloadExpired(job)).toBe(true);

    vi.useRealTimers();
  });

  it("statik `exportJobDoneExpiredHandler` orqali muddati o'tgan job simulyatsiyasi", async () => {
    server.use(exportJobDoneExpiredHandler);
    const { result } = renderHook(() => useExportJob('job-1'), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.data?.status).toBe('done'));
    expect(isExportJobDownloadExpired(result.current.data)).toBe(true);
  });
});
