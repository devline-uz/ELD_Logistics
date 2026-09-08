/**
 * Log Edit Requests query hooklari — integratsiya testi (MSW, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  logEditRequestApproveForbiddenHandler,
  logEditRequestApproveHandler,
  logEditRequestFixture,
  logEditRequestProposeHandler,
  logEditRequestProposeImmutableHandler,
  logEditRequestRejectHandler,
  logEditRequestRejectValidationErrorHandler,
  logEditRequestsListHandler,
} from '@/mocks/handlers/logEditRequests';

import {
  useLogEditRequestApprove,
  useLogEditRequestPropose,
  useLogEditRequestReject,
  useLogEditRequestsList,
} from './logEditRequests';
import { withQueryClient } from './test-utils';

describe('useLogEditRequestsList', () => {
  it("Pending/Approved/Rejected tablar uchun ro'yxatni qaytaradi", async () => {
    server.use(logEditRequestsListHandler);
    const { result } = renderHook(() => useLogEditRequestsList({ status: 'pending' }), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([logEditRequestFixture()]);
  });
});

describe('useLogEditRequestPropose', () => {
  it("F100: taklif yuboradi — log darhol o'zgarmaydi, `pending` qaytadi", async () => {
    server.use(logEditRequestProposeHandler);
    const { result } = renderHook(() => useLogEditRequestPropose(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({
      daily_log_id: 'daily-log-1',
      driver_id: 'driver-1',
      changes: [
        {
          status: 'ON',
          from: '2026-09-06T13:00:00Z',
          to: '2026-09-06T15:00:00Z',
          note: 'Loading at the dock',
        },
      ],
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.status).toBe('pending');
  });

  it('409 DR_IMMUTABLE (Q17.1) — avtomatik DR taklif bosqichida ham rad etiladi', async () => {
    server.use(logEditRequestProposeImmutableHandler);
    const { result } = renderHook(() => useLogEditRequestPropose(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({
      daily_log_id: 'daily-log-1',
      driver_id: 'driver-1',
      changes: [
        { status: 'ON', from: '2026-09-06T13:00:00Z', to: '2026-09-06T15:00:00Z', note: 'x' },
      ],
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.code).toBe('DR_IMMUTABLE');
  });
});

describe('useLogEditRequestApprove', () => {
  it('muvaffaqiyatli tasdiqlaydi', async () => {
    server.use(logEditRequestApproveHandler);
    const { result } = renderHook(() => useLogEditRequestApprove(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate('log-edit-1');

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.status).toBe('approved');
  });

  it("F103: 403 — o'z taklifini o'zi tasdiqlay olmaydi", async () => {
    server.use(logEditRequestApproveForbiddenHandler);
    const { result } = renderHook(() => useLogEditRequestApprove(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate('log-edit-1');

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(403);
  });
});

describe('useLogEditRequestReject', () => {
  it('sabab bilan rad etadi', async () => {
    server.use(logEditRequestRejectHandler);
    const { result } = renderHook(() => useLogEditRequestReject(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({ id: 'log-edit-1', body: { reason: 'That was my co-driver' } });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.status).toBe('rejected');
  });

  it('422 — sabab majburiy', async () => {
    server.use(logEditRequestRejectValidationErrorHandler);
    const { result } = renderHook(() => useLogEditRequestReject(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({ id: 'log-edit-1', body: { reason: '' } });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.fields?.reason).toBeDefined();
  });
});
