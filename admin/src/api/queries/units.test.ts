/**
 * Units query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  unitCreateConflictHandler,
  unitCreateHandler,
  unitFixture,
  unitGetNotFoundHandler,
  unitsListErrorHandler,
  unitsListHandler,
} from '@/mocks/handlers/units';

import { useUnit, useUnitCreate, useUnitsList } from './units';
import { withQueryClient } from './test-utils';

describe('useUnitsList', () => {
  it("ro'yxatni {data, meta} shaklida qaytaradi", async () => {
    server.use(unitsListHandler);
    const { result } = renderHook(() => useUnitsList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(result.current.data?.data).toEqual([unitFixture()]);
    expect(result.current.data?.meta?.total).toBe(1);
  });

  it('422 javobida ApiError bilan tugaydi', async () => {
    server.use(unitsListErrorHandler);
    const { result } = renderHook(() => useUnitsList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isError).toBe(true));

    expect(result.current.error?.status).toBe(422);
    expect(result.current.error?.code).toBe('VALIDATION_ERROR');
  });
});

describe('useUnit', () => {
  it("cross-tenant/mavjud bo'lmagan unit uchun 404 qaytaradi (403 emas)", async () => {
    server.use(unitGetNotFoundHandler);
    const { result } = renderHook(() => useUnit('unit-999'), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isError).toBe(true));

    expect(result.current.error?.status).toBe(404);
  });
});

describe('useUnitCreate', () => {
  it('muvaffaqiyatli yaratilgan unitni qaytaradi', async () => {
    server.use(unitCreateHandler);
    const { result } = renderHook(() => useUnitCreate(), { wrapper: withQueryClient() });

    result.current.mutate({
      unit_number: '1099',
      make: 'Volvo',
      model: 'VNL',
      license_plate: 'CC999DD',
      fuel_type: 'diesel',
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.id).toBe('unit-new');
  });

  it('409 (unit_number band) ApiError sifatida qaytadi', async () => {
    server.use(unitCreateConflictHandler);
    const { result } = renderHook(() => useUnitCreate(), { wrapper: withQueryClient() });

    result.current.mutate({
      unit_number: '1021',
      make: 'Volvo',
      model: 'VNL',
      license_plate: 'CC999DD',
      fuel_type: 'diesel',
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(409);
  });
});
