/**
 * Inspection logs query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import {
  inspectionEmailSendErrorHandler,
  inspectionEmailSendHandler,
  inspectionLogsEmptyHandler,
  inspectionLogsErrorHandler,
  inspectionLogsHandler,
  inspectionReportFixture,
  inspectionTransferHandler,
} from '@/mocks/handlers/inspection';
import { server } from '@/test/msw-server';

import { useInspectionEmailSend, useInspectionLogsList, useInspectionTransfer } from './inspection';
import { withQueryClient } from './test-utils';

describe('useInspectionLogsList', () => {
  it("driver_id bo'lmasa so'rov yubormaydi", () => {
    server.use(inspectionLogsHandler);
    const { result } = renderHook(() => useInspectionLogsList({}), {
      wrapper: withQueryClient(),
    });

    expect(result.current.fetchStatus).toBe('idle');
    expect(result.current.data).toBeUndefined();
  });

  it('driver_id bilan roadside hisobotni qaytaradi', async () => {
    server.use(inspectionLogsHandler);
    const { result } = renderHook(
      () => useInspectionLogsList({ driver_id: 'driver-1', date: '2026-09-06' }),
      { wrapper: withQueryClient() },
    );

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(inspectionReportFixture());
    expect(result.current.data?.days).toHaveLength(1);
  });

  it("kunlar bo'sh bo'lsa bo'sh massiv qaytaradi", async () => {
    server.use(inspectionLogsEmptyHandler);
    const { result } = renderHook(() => useInspectionLogsList({ driver_id: 'driver-1' }), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.days).toEqual([]);
  });

  it('403 javobida ApiError bilan tugaydi', async () => {
    server.use(inspectionLogsErrorHandler);
    const { result } = renderHook(() => useInspectionLogsList({ driver_id: 'driver-1' }), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(403);
  });
});

describe('useInspectionEmailSend', () => {
  it('202 qaytganda muvaffaqiyatli tugaydi', async () => {
    server.use(inspectionEmailSendHandler);
    const { result } = renderHook(() => useInspectionEmailSend(), { wrapper: withQueryClient() });

    result.current.mutate({ email: 'inspector@dot.gov', driver_id: 'driver-1' });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
  });

  it("422 (noto'g'ri email) da ApiError bilan tugaydi", async () => {
    server.use(inspectionEmailSendErrorHandler);
    const { result } = renderHook(() => useInspectionEmailSend(), { wrapper: withQueryClient() });

    result.current.mutate({ email: 'not-an-email', driver_id: 'driver-1' });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useInspectionTransfer', () => {
  it("eksport fayli metama'lumotini qaytaradi", async () => {
    server.use(inspectionTransferHandler);
    const { result } = renderHook(() => useInspectionTransfer(), { wrapper: withQueryClient() });

    result.current.mutate({ driver_id: 'driver-1', date: '2026-09-06' });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.format).toBe('csv_pdf_zip');
  });
});
