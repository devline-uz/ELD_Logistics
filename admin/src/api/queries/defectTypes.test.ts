/**
 * Defect Types query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  defectTypeCreateConflictHandler,
  defectTypeCreateHandler,
  defectTypeFixture,
  defectTypesListErrorHandler,
  defectTypesListHandler,
  defectTypeUpdateHandler,
  defectTypeUpdateSystemLockedHandler,
} from '@/mocks/handlers/defectTypes';

import { useDefectTypeCreate, useDefectTypesList, useDefectTypeUpdate } from './defectTypes';
import { withQueryClient } from './test-utils';

describe('useDefectTypesList', () => {
  it("ro'yxatni {data, meta} shaklida qaytaradi", async () => {
    server.use(defectTypesListHandler);
    const { result } = renderHook(() => useDefectTypesList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([defectTypeFixture()]);
  });

  it('422 javobida ApiError bilan tugaydi', async () => {
    server.use(defectTypesListErrorHandler);
    const { result } = renderHook(() => useDefectTypesList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useDefectTypeCreate', () => {
  it('muvaffaqiyatli yaratilgan bandni qaytaradi', async () => {
    server.use(defectTypeCreateHandler);
    const { result } = renderHook(() => useDefectTypeCreate(), { wrapper: withQueryClient() });

    result.current.mutate({ category: 'truck', name: 'Custom defect' });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.id).toBe('defect-type-new');
  });

  it('409 UNIQUE_VIOLATION qaytaradi', async () => {
    server.use(defectTypeCreateConflictHandler);
    const { result } = renderHook(() => useDefectTypeCreate(), { wrapper: withQueryClient() });

    result.current.mutate({ category: 'truck', name: 'Brakes (Service)' });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(409);
  });
});

describe('useDefectTypeUpdate', () => {
  it('muvaffaqiyatli tahrirlaydi', async () => {
    server.use(defectTypeUpdateHandler);
    const { result } = renderHook(() => useDefectTypeUpdate(), { wrapper: withQueryClient() });

    result.current.mutate({ id: 'defect-type-1', body: { is_active: false } });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
  });

  it('409 DEFECT_TYPE_SYSTEM_LOCKED qaytaradi (is_system band)', async () => {
    server.use(defectTypeUpdateSystemLockedHandler);
    const { result } = renderHook(() => useDefectTypeUpdate(), { wrapper: withQueryClient() });

    result.current.mutate({ id: 'defect-type-1', body: { is_active: false } });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(409);
  });
});
