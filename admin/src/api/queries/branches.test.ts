/**
 * Branches query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  branchCreateErrorHandler,
  branchCreateHandler,
  branchDeleteHandler,
  branchDeleteInUseHandler,
  branchFixture,
  branchesListEmptyHandler,
  branchesListHandler,
  branchUpdateHandler,
  branchUpdateNotFoundHandler,
} from '@/mocks/handlers/branches';

import { useBranchCreate, useBranchDelete, useBranchesList, useBranchUpdate } from './branches';
import { withQueryClient } from './test-utils';

describe('useBranchesList', () => {
  it('katalogni qaytaradi', async () => {
    server.use(branchesListHandler);
    const { result } = renderHook(() => useBranchesList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([branchFixture()]);
  });

  it("bo'sh natijani qaytaradi", async () => {
    server.use(branchesListEmptyHandler);
    const { result } = renderHook(() => useBranchesList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([]);
  });
});

describe('useBranchCreate', () => {
  it('yangi filial yaratadi (201)', async () => {
    server.use(branchCreateHandler);
    const { result } = renderHook(() => useBranchCreate(), { wrapper: withQueryClient() });

    result.current.mutate({ name: 'Houston Terminal', address: 'a', timezone: 'America/Chicago' });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.id).toBe('branch-new');
  });

  it('422 javobida ApiError bilan tugaydi', async () => {
    server.use(branchCreateErrorHandler);
    const { result } = renderHook(() => useBranchCreate(), { wrapper: withQueryClient() });

    result.current.mutate({ name: '', address: 'a', timezone: 'America/Chicago' });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useBranchUpdate', () => {
  it('filialni yangilaydi', async () => {
    server.use(branchUpdateHandler);
    const { result } = renderHook(() => useBranchUpdate(), { wrapper: withQueryClient() });

    result.current.mutate({ id: 'branch-1', body: { name: 'Updated Terminal' } });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.name).toBe('Updated Terminal');
  });

  it('boshqa tenant filiali uchun 404 qaytaradi', async () => {
    server.use(branchUpdateNotFoundHandler);
    const { result } = renderHook(() => useBranchUpdate(), { wrapper: withQueryClient() });

    result.current.mutate({ id: 'branch-999', body: { name: 'x' } });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(404);
  });
});

describe('useBranchDelete', () => {
  it("filialni o'chiradi (204)", async () => {
    server.use(branchDeleteHandler);
    const { result } = renderHook(() => useBranchDelete(), { wrapper: withQueryClient() });

    result.current.mutate('branch-1');

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
  });

  it('foydalanuvchisi bor filial uchun 409 qaytaradi', async () => {
    server.use(branchDeleteInUseHandler);
    const { result } = renderHook(() => useBranchDelete(), { wrapper: withQueryClient() });

    result.current.mutate('branch-1');

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(409);
  });
});
