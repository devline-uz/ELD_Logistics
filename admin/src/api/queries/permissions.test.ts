/**
 * Permission catalogue query hooki — integratsiya testi (MSW orqali).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  permissionModulesFixture,
  permissionsListForbiddenHandler,
  permissionsListHandler,
} from '@/mocks/handlers/permissions';

import { usePermissionsList } from './permissions';
import { withQueryClient } from './test-utils';

describe('usePermissionsList', () => {
  it("modul bo'yicha guruhlangan katalogni qaytaradi", async () => {
    server.use(permissionsListHandler);
    const { result } = renderHook(() => usePermissionsList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(permissionModulesFixture());
  });

  it('403 (na permissions.read, na roles.read) ApiError sifatida qaytadi', async () => {
    server.use(permissionsListForbiddenHandler);
    const { result } = renderHook(() => usePermissionsList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(403);
  });
});
