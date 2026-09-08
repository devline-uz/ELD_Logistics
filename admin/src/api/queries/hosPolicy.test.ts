/**
 * HOS Policy query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  hosPolicyFixture,
  hosPolicyGetErrorHandler,
  hosPolicyGetHandler,
  hosPolicyHistoryEntryFixture,
  hosPolicyPublishErrorHandler,
  hosPolicyPublishHandler,
  hosPolicyVersionsEmptyHandler,
  hosPolicyVersionsHandler,
} from '@/mocks/handlers/hosPolicy';

import { useHosPolicy, useHosPolicyPublish, useHosPolicyVersions } from './hosPolicy';
import { withQueryClient } from './test-utils';

describe('useHosPolicy', () => {
  it('joriy amaldagi siyosatni qaytaradi', async () => {
    server.use(hosPolicyGetHandler);
    const { result } = renderHook(() => useHosPolicy(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(hosPolicyFixture());
  });

  it('403 javobida ApiError bilan tugaydi', async () => {
    server.use(hosPolicyGetErrorHandler);
    const { result } = renderHook(() => useHosPolicy(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(403);
  });
});

describe('useHosPolicyPublish', () => {
  it('yangi versiya yaratadi (201)', async () => {
    server.use(hosPolicyPublishHandler);
    const { result } = renderHook(() => useHosPolicyPublish(), { wrapper: withQueryClient() });

    result.current.mutate({
      effective_from: '2026-11-01T00:00:00Z',
      policy: { drive_limit_min: 660 },
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.id).toBe('new-version');
  });

  it("422 javobida (o'tmishdagi effective_from) ApiError bilan tugaydi", async () => {
    server.use(hosPolicyPublishErrorHandler);
    const { result } = renderHook(() => useHosPolicyPublish(), { wrapper: withQueryClient() });

    result.current.mutate({ policy: {} });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useHosPolicyVersions', () => {
  it("`/company/history`ni `action=hos_policy_change` bilan so'raydi", async () => {
    server.use(hosPolicyVersionsHandler);
    const { result } = renderHook(() => useHosPolicyVersions(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([hosPolicyHistoryEntryFixture()]);
  });

  it("bo'sh tarixni qaytaradi", async () => {
    server.use(hosPolicyVersionsEmptyHandler);
    const { result } = renderHook(() => useHosPolicyVersions(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([]);
  });
});
