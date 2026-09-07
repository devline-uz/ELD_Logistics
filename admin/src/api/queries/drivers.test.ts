/**
 * Drivers query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  driverCreateHandler,
  driverFixture,
  driverLicenseRevealForbiddenHandler,
  driverLicenseRevealHandler,
  driversListHandler,
} from '@/mocks/handlers/drivers';

import { useDriverCreate, useDriverLicenseReveal, useDriversList } from './drivers';
import { withQueryClient } from './test-utils';

describe('useDriversList', () => {
  it("ro'yxatda license_no hech qachon ochiq ko'rinmaydi", async () => {
    server.use(driversListHandler);
    const { result } = renderHook(() => useDriversList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(result.current.data?.data).toEqual([driverFixture()]);
    expect(result.current.data?.data?.[0]).not.toHaveProperty('license_no');
  });
});

describe('useDriverCreate', () => {
  it('parolsiz yaratadi, driver "invited" holatida qaytadi', async () => {
    server.use(driverCreateHandler);
    const { result } = renderHook(() => useDriverCreate(), { wrapper: withQueryClient() });

    result.current.mutate({
      first_name: 'John',
      last_name: 'Doe',
      username: 'jdoe',
      license_no: 'TX-9930-4821',
      email: 'john.doe@example.com',
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.status).toBe('invited');
  });
});

describe('useDriverLicenseReveal', () => {
  it('F87: bosilganda ochiq license_no qaytaradi (mutatsiya, doimiy keshsiz)', async () => {
    server.use(driverLicenseRevealHandler);
    const { result } = renderHook(() => useDriverLicenseReveal(), { wrapper: withQueryClient() });

    result.current.mutate('driver-1');

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.license_no).toBe('TX-9930-4821');
  });

  it("drivers.license.view yo'q bo'lsa 403 qaytadi", async () => {
    server.use(driverLicenseRevealForbiddenHandler);
    const { result } = renderHook(() => useDriverLicenseReveal(), { wrapper: withQueryClient() });

    result.current.mutate('driver-1');

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(403);
  });
});
