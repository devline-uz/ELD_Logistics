/**
 * Violations query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  violationFixture,
  violationGetHandler,
  violationGetNotFoundHandler,
  violationsListErrorHandler,
  violationsListHandler,
} from '@/mocks/handlers/violations';

import { useViolation, useViolationsList } from './violations';
import { withQueryClient } from './test-utils';

describe('useViolationsList', () => {
  it("ro'yxatni {data, meta} shaklida qaytaradi", async () => {
    server.use(violationsListHandler);
    const { result } = renderHook(() => useViolationsList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([violationFixture()]);
  });

  it('422 javobida ApiError bilan tugaydi', async () => {
    server.use(violationsListErrorHandler);
    const { result } = renderHook(() => useViolationsList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useViolation', () => {
  it("bitta violationni qaytaradi (F105: resolved_at bilan, o'chirilmagan)", async () => {
    server.use(violationGetHandler);
    const { result } = renderHook(() => useViolation('violation-1'), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.id).toBe('violation-1');
  });

  it('404 qaytaradi', async () => {
    server.use(violationGetNotFoundHandler);
    const { result } = renderHook(() => useViolation('violation-999'), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(404);
  });
});
