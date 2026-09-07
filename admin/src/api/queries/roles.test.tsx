/**
 * Roles query hooklari — integratsiya testi (MSW orqali). `useRole(id)` faqat
 * `['roles','list',*]` keshidan o'qiydi — `GET /roles/{id}` swaggerda yo'q.
 */
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClientProvider } from '@tanstack/react-query';
import type { ReactNode } from 'react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  roleCreateValidationErrorHandler,
  roleDeleteInUseHandler,
  roleFixture,
  roleUpdateSystemImmutableHandler,
  rolesListHandler,
  systemRoleFixture,
} from '@/mocks/handlers/roles';

import { useRole, useRoleCreate, useRoleDelete, useRoleUpdate, useRolesList } from './roles';
import { createTestQueryClient, withQueryClient } from './test-utils';

describe('useRolesList', () => {
  it('tizim + kompaniya rollarini {data, meta} shaklida qaytaradi', async () => {
    server.use(rolesListHandler);
    const { result } = renderHook(() => useRolesList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([systemRoleFixture(), roleFixture()]);
  });
});

describe('useRole', () => {
  it("GET /roles/{id} yo'qligi sababli faqat ro'yxat keshidan topadi", async () => {
    server.use(rolesListHandler);
    const client = createTestQueryClient();
    const wrapper = ({ children }: { children: ReactNode }) => (
      <QueryClientProvider client={client}>{children}</QueryClientProvider>
    );

    const list = renderHook(() => useRolesList(), { wrapper });
    await waitFor(() => expect(list.result.current.isSuccess).toBe(true));

    const single = renderHook(() => useRole('role-1'), { wrapper });
    expect(single.result.current).toEqual(roleFixture());
  });
});

describe('useRoleCreate', () => {
  it("422 (noma'lum permission kaliti, F94) ApiError sifatida qaytadi", async () => {
    server.use(roleCreateValidationErrorHandler);
    const { result } = renderHook(() => useRoleCreate(), { wrapper: withQueryClient() });

    result.current.mutate({ name: 'Yard', permissions: ['units.frobnicate'], scope: 'company' });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useRoleUpdate', () => {
  it('403 SYSTEM_ROLE_IMMUTABLE (F92) qaytaradi', async () => {
    server.use(roleUpdateSystemImmutableHandler);
    const { result } = renderHook(() => useRoleUpdate(), { wrapper: withQueryClient() });

    result.current.mutate({ id: 'role-admin', body: { permissions: ['units.read'] } });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(403);
  });
});

describe('useRoleDelete', () => {
  it('409 ROLE_IN_USE (F93) qaytaradi', async () => {
    server.use(roleDeleteInUseHandler);
    const { result } = renderHook(() => useRoleDelete(), { wrapper: withQueryClient() });

    result.current.mutate('role-1');

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(409);
  });
});
