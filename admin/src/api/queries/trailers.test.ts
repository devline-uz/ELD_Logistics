/**
 * Trailers query hooklari — integratsiya testi (MSW orqali).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  trailerCreateConflictHandler,
  trailerCreateHandler,
  trailerFixture,
  trailersListHandler,
} from '@/mocks/handlers/trailers';

import { useTrailerCreate, useTrailersList } from './trailers';
import { withQueryClient } from './test-utils';

describe('useTrailersList', () => {
  it("ro'yxatni {data, meta} shaklida qaytaradi", async () => {
    server.use(trailersListHandler);
    const { result } = renderHook(() => useTrailersList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([trailerFixture()]);
  });
});

describe('useTrailerCreate', () => {
  it('muvaffaqiyatli yaratadi', async () => {
    server.use(trailerCreateHandler);
    const { result } = renderHook(() => useTrailerCreate(), { wrapper: withQueryClient() });

    result.current.mutate({ number: 'TR-9001' });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.id).toBe('trailer-new');
  });

  it('409 (number band) ApiError sifatida qaytadi', async () => {
    server.use(trailerCreateConflictHandler);
    const { result } = renderHook(() => useTrailerCreate(), { wrapper: withQueryClient() });

    result.current.mutate({ number: 'TR-4410' });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(409);
  });
});
