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
  driversImportHandler,
  driversImportValidationErrorHandler,
  driversListHandler,
} from '@/mocks/handlers/drivers';

import {
  useDriverCreate,
  useDriverLicenseReveal,
  useDriversImport,
  useDriversList,
} from './drivers';
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

describe('useDriversImport', () => {
  it('200 da barcha qatorlar importlanganini qaytaradi', async () => {
    server.use(driversImportHandler);
    const { result } = renderHook(() => useDriversImport(), { wrapper: withQueryClient() });

    result.current.mutate(new File(['username\njdoe'], 'drivers.csv', { type: 'text/csv' }));

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual({ imported: 2, total: 2, errors: [] });
  });

  it(
    "422 all-or-nothing javobida qator xatolarini to'liq qaytaradi " +
      '(D-f9: units.ts bilan bir xil mexanizm)',
    async () => {
      server.use(driversImportValidationErrorHandler);
      const { result } = renderHook(() => useDriversImport(), { wrapper: withQueryClient() });

      result.current.mutate(new File(['username\n,'], 'drivers.csv', { type: 'text/csv' }));

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(result.current.data).toEqual({
        imported: 0,
        total: 2,
        errors: [
          { row: 1, field: 'username', message: 'must be 4-32 characters of [a-z0-9._]' },
          { row: 2, field: 'license_no', message: 'required' },
        ],
      });
    },
  );
});
