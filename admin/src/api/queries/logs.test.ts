/**
 * Logs query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  dailyLogAddEventImmutableHandler,
  dailyLogCertifyHandler,
  dailyLogCertifyNotReadyHandler,
  dailyLogDetailFixture,
  dailyLogGetHandler,
  dailyLogGetNotFoundHandler,
  dailyLogPdfHandler,
  driverDailyLogsHandler,
  liveUnitFixture,
  trackingLiveForbiddenHandler,
  trackingLiveHandler,
} from '@/mocks/handlers/logs';

import {
  useDailyLog,
  useDailyLogCertify,
  useDailyLogPdf,
  useDriverDailyLogs,
  useLogAddEvent,
  useTrackingLive,
} from './logs';
import { withQueryClient } from './test-utils';

describe('useTrackingLive', () => {
  it('Logs By Unit uchun {data, meta} shaklida qaytaradi', async () => {
    server.use(trackingLiveHandler);
    const { result } = renderHook(() => useTrackingLive(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(result.current.data?.data).toEqual([liveUnitFixture()]);
  });

  it("403 (tracking.view_live yo'q) ApiError bilan tugaydi", async () => {
    server.use(trackingLiveForbiddenHandler);
    const { result } = renderHook(() => useTrackingLive(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(403);
  });
});

describe('useDriverDailyLogs', () => {
  it("driver id bo'yicha ro'yxatni qaytaradi", async () => {
    server.use(driverDailyLogsHandler);
    const { result } = renderHook(() => useDriverDailyLogs('driver-1'), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data?.[0]?.driver_id).toBe('driver-1');
  });

  it("driverId bo'lmasa so'rov yubormaydi", () => {
    const { result } = renderHook(() => useDriverDailyLogs(undefined), {
      wrapper: withQueryClient(),
    });
    expect(result.current.fetchStatus).toBe('idle');
  });
});

describe('useDailyLog', () => {
  it('bitta log detalini qaytaradi', async () => {
    server.use(dailyLogGetHandler);
    const { result } = renderHook(() => useDailyLog('daily-log-1'), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(dailyLogDetailFixture());
  });

  it('404 (cross-tenant) ApiError bilan tugaydi', async () => {
    server.use(dailyLogGetNotFoundHandler);
    const { result } = renderHook(() => useDailyLog('daily-log-999'), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(404);
  });
});

describe('useDailyLogCertify', () => {
  it('muvaffaqiyatli sertifikatlaydi', async () => {
    server.use(dailyLogCertifyHandler);
    const { result } = renderHook(() => useDailyLogCertify(), { wrapper: withQueryClient() });

    result.current.mutate({ id: 'daily-log-1' });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.certification_status).toBe('certified');
  });

  it("409 LOG_NOT_READY (imzo manbai yo'q)", async () => {
    server.use(dailyLogCertifyNotReadyHandler);
    const { result } = renderHook(() => useDailyLogCertify(), { wrapper: withQueryClient() });

    result.current.mutate({ id: 'daily-log-1' });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.code).toBe('LOG_NOT_READY');
  });
});

describe('useLogAddEvent', () => {
  it('409 DR_IMMUTABLE (Q17.1) — avtomatik DR tahrirlanmaydi', async () => {
    server.use(dailyLogAddEventImmutableHandler);
    const { result } = renderHook(() => useLogAddEvent(), { wrapper: withQueryClient() });

    result.current.mutate({
      id: 'daily-log-1',
      body: { status: 'ON', from: '2026-09-06T13:00:00Z', to: '2026-09-06T14:00:00Z', note: 'x' },
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.code).toBe('DR_IMMUTABLE');
  });
});

describe('useDailyLogPdf', () => {
  it('PDF ni Blob sifatida qaytaradi', async () => {
    server.use(dailyLogPdfHandler);
    const { result } = renderHook(() => useDailyLogPdf(), { wrapper: withQueryClient() });

    result.current.mutate('daily-log-1');

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toBeInstanceOf(Blob);
  });
});
