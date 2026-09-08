/**
 * ELD Devices query hooklari — integratsiya testi (MSW orqali).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  eldDeviceAssignUnitConflictHandler,
  eldDeviceAssignUnitHandler,
  eldDevicesListEmptyHandler,
  eldDevicesListHandler,
  eldDeviceFixture,
} from '@/mocks/handlers/eldDevices';

import { useEldDeviceAssignUnit, useEldDevicesList } from './eldDevices';
import { withQueryClient } from './test-utils';

describe('useEldDevicesList', () => {
  it("ro'yxatni {data, meta} shaklida qaytaradi", async () => {
    server.use(eldDevicesListHandler);
    const { result } = renderHook(() => useEldDevicesList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([eldDeviceFixture()]);
  });

  it("bo'sh natijada data:[] qaytaradi", async () => {
    server.use(eldDevicesListEmptyHandler);
    const { result } = renderHook(() => useEldDevicesList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([]);
    expect(result.current.data?.meta?.total).toBe(0);
  });
});

describe('useEldDeviceAssignUnit', () => {
  it('muvaffaqiyatli ulaydi', async () => {
    server.use(eldDeviceAssignUnitHandler);
    const { result } = renderHook(() => useEldDeviceAssignUnit(), { wrapper: withQueryClient() });

    result.current.mutate({ id: 'eld-1', body: { unit_id: 'unit-1' } });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
  });

  it('409 ALREADY_ASSIGNED holatini ApiError sifatida qaytaradi', async () => {
    server.use(eldDeviceAssignUnitConflictHandler);
    const { result } = renderHook(() => useEldDeviceAssignUnit(), { wrapper: withQueryClient() });

    result.current.mutate({ id: 'eld-1', body: { unit_id: 'unit-2' } });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(409);
  });
});
