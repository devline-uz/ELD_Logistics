/**
 * Super Admin — `/companies*` query hooklari integratsiya testi
 * (MSW orqali, 9.15, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import {
  adminCompanyCreateConflictHandler,
  adminCompanyCreateHandler,
  adminCompanyFixture,
  adminCompaniesListEmptyHandler,
  adminCompaniesListForbiddenHandler,
  adminCompaniesListHandler,
  adminCompanySubscriptionUpdateHandler,
  adminCompanySubscriptionUpdateNotFoundHandler,
  adminCompanyUpdateHandler,
  adminCompanyUpdateNotFoundHandler,
} from '@/mocks/handlers/companies';
import { server } from '@/test/msw-server';

import {
  useAdminCompaniesList,
  useAdminCompanyCreate,
  useAdminCompanySubscriptionUpdate,
  useAdminCompanyUpdate,
} from './companies';
import { withQueryClient } from './test-utils';

describe('useAdminCompaniesList', () => {
  it('tenant ro’yxatini qaytaradi', async () => {
    server.use(adminCompaniesListHandler);
    const { result } = renderHook(() => useAdminCompaniesList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([adminCompanyFixture()]);
  });

  it("bo'sh natijani qaytaradi", async () => {
    server.use(adminCompaniesListEmptyHandler);
    const { result } = renderHook(() => useAdminCompaniesList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([]);
  });

  it('super_admin bayrog’i yo’qligida 403 qaytaradi', async () => {
    server.use(adminCompaniesListForbiddenHandler);
    const { result } = renderHook(() => useAdminCompaniesList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(403);
  });
});

describe('useAdminCompanyCreate', () => {
  it('yangi tenant yaratadi (201)', async () => {
    server.use(adminCompanyCreateHandler);
    const { result } = renderHook(() => useAdminCompanyCreate(), { wrapper: withQueryClient() });

    result.current.mutate({
      name: 'Northside Freight Co',
      region: 'US',
      regulation_profile: 'us_fmcsa',
      timezone: 'America/Chicago',
      unit_system: 'imperial',
      administrator: { email: 'jane@example.com', first_name: 'Jane', last_name: 'Doe' },
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.company?.id).toBe('company-new');
    expect(result.current.data?.roles_created).toBe(8);
  });

  it('409 javobida ApiError bilan tugaydi (nom band)', async () => {
    server.use(adminCompanyCreateConflictHandler);
    const { result } = renderHook(() => useAdminCompanyCreate(), { wrapper: withQueryClient() });

    result.current.mutate({
      name: 'Onebook Logistics LLC',
      region: 'US',
      regulation_profile: 'us_fmcsa',
      timezone: 'America/Chicago',
      unit_system: 'imperial',
      administrator: { email: 'jane@example.com', first_name: 'Jane', last_name: 'Doe' },
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(409);
  });
});

describe('useAdminCompanyUpdate', () => {
  it('kompaniyani yangilaydi', async () => {
    server.use(adminCompanyUpdateHandler);
    const { result } = renderHook(() => useAdminCompanyUpdate(), { wrapper: withQueryClient() });

    result.current.mutate({ id: 'company-1', body: { name: 'Updated Company Name' } });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.name).toBe('Updated Company Name');
  });

  it('mavjud bo’lmagan id uchun 404 qaytaradi', async () => {
    server.use(adminCompanyUpdateNotFoundHandler);
    const { result } = renderHook(() => useAdminCompanyUpdate(), { wrapper: withQueryClient() });

    result.current.mutate({ id: 'company-999', body: { name: 'x' } });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(404);
  });
});

describe('useAdminCompanySubscriptionUpdate', () => {
  it('obuna holatini yangilaydi', async () => {
    server.use(adminCompanySubscriptionUpdateHandler);
    const { result } = renderHook(() => useAdminCompanySubscriptionUpdate(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({ id: 'company-1', body: { subscription_status: 'grace' } });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.subscription_status).toBe('grace');
  });

  it('mavjud bo’lmagan id uchun 404 qaytaradi', async () => {
    server.use(adminCompanySubscriptionUpdateNotFoundHandler);
    const { result } = renderHook(() => useAdminCompanySubscriptionUpdate(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({ id: 'company-999', body: { subscription_status: 'active' } });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(404);
  });
});
