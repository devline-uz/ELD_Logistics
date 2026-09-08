/**
 * Users query hooklari — integratsiya testi (MSW orqali). `useUser(id)` faqat
 * `['users','list',*]` keshidan o'qiydi — `GET /users/{id}` swaggerda yo'q.
 */
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClientProvider } from '@tanstack/react-query';
import type { ReactNode } from 'react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import { userFixture, usersListHandler } from '@/mocks/handlers/users';

import { useUser, useUsersList } from './users';
import { createTestQueryClient, withQueryClient } from './test-utils';

describe('useUsersList', () => {
  it("ro'yxatni {data, meta} shaklida qaytaradi", async () => {
    server.use(usersListHandler);
    const { result } = renderHook(() => useUsersList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([userFixture()]);
  });
});

describe('useUser', () => {
  it("GET /users/{id} yo'qligi sababli faqat ro'yxat keshidan topadi", async () => {
    server.use(usersListHandler);
    const client = createTestQueryClient();
    const wrapper = ({ children }: { children: ReactNode }) => (
      <QueryClientProvider client={client}>{children}</QueryClientProvider>
    );

    const list = renderHook(() => useUsersList(), { wrapper });
    await waitFor(() => expect(list.result.current.isSuccess).toBe(true));

    const single = renderHook(() => useUser('user-1'), { wrapper });
    expect(single.result.current).toEqual(userFixture());
  });

  it("kesh bo'sh bo'lsa undefined qaytaradi", () => {
    const { result } = renderHook(() => useUser('unknown-id'), { wrapper: withQueryClient() });
    expect(result.current).toBeUndefined();
  });
});
