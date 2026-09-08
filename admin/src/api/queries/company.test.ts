/**
 * Company query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  companyFixture,
  companyGetErrorHandler,
  companyGetHandler,
  companyHistoryEntryFixture,
  companyHistoryListEmptyHandler,
  companyHistoryListErrorHandler,
  companyHistoryListHandler,
  companyUpdateErrorHandler,
  companyUpdateHandler,
} from '@/mocks/handlers/company';

import { useCompany, useCompanyHistory, useCompanyUpdate } from './company';
import { withQueryClient } from './test-utils';

describe('useCompany', () => {
  it('kompaniya profilini qaytaradi', async () => {
    server.use(companyGetHandler);
    const { result } = renderHook(() => useCompany(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(companyFixture());
  });

  it('403 javobida ApiError bilan tugaydi', async () => {
    server.use(companyGetErrorHandler);
    const { result } = renderHook(() => useCompany(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(403);
  });
});

describe('useCompanyUpdate', () => {
  it('muvaffaqiyatli yangilaydi', async () => {
    server.use(companyUpdateHandler);
    const { result } = renderHook(() => useCompanyUpdate(), { wrapper: withQueryClient() });

    result.current.mutate({ timezone: 'America/Denver' });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.timezone).toBe('America/Denver');
  });

  it('422 javobida maydon xatosi bilan tugaydi', async () => {
    server.use(companyUpdateErrorHandler);
    const { result } = renderHook(() => useCompanyUpdate(), { wrapper: withQueryClient() });

    result.current.mutate({ name: 'A' });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.fields?.name).toBeDefined();
  });
});

describe('useCompanyHistory', () => {
  it('jurnal yozuvlarini qaytaradi', async () => {
    server.use(companyHistoryListHandler);
    const { result } = renderHook(() => useCompanyHistory(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([companyHistoryEntryFixture()]);
  });

  it("bo'sh natijani qaytaradi", async () => {
    server.use(companyHistoryListEmptyHandler);
    const { result } = renderHook(() => useCompanyHistory({ table: 'companies' }), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([]);
  });

  it('422 javobida ApiError bilan tugaydi', async () => {
    server.use(companyHistoryListErrorHandler);
    const { result } = renderHook(() => useCompanyHistory({ from: 'invalid' }), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});
