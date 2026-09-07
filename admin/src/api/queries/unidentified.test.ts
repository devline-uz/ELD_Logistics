/**
 * Unidentified Driving query hooklari — integratsiya testi (MSW, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  unidentifiedAnnotateHandler,
  unidentifiedAnnotateValidationErrorHandler,
  unidentifiedAssignConflictHandler,
  unidentifiedAssignHandler,
  unidentifiedClaimConflictHandler,
  unidentifiedClaimHandler,
  unidentifiedEventFixture,
  unidentifiedEventsListForbiddenHandler,
  unidentifiedEventsListHandler,
} from '@/mocks/handlers/unidentified';

import {
  useUnidentifiedAnnotate,
  useUnidentifiedAssign,
  useUnidentifiedClaim,
  useUnidentifiedEventsList,
} from './unidentified';
import { withQueryClient } from './test-utils';

describe('useUnidentifiedEventsList', () => {
  it("ro'yxatni {data, meta} shaklida qaytaradi", async () => {
    server.use(unidentifiedEventsListHandler);
    const { result } = renderHook(() => useUnidentifiedEventsList(), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([unidentifiedEventFixture()]);
  });

  it("403 qaytishi mumkin (ikkala ruxsat ham yo'q holat)", async () => {
    server.use(unidentifiedEventsListForbiddenHandler);
    const { result } = renderHook(() => useUnidentifiedEventsList(), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(403);
  });
});

describe('useUnidentifiedAssign', () => {
  it(
    "swagger nuqsoniga qaramay to'g'ri {id} yo'lga va JSON tanaga " +
      "so'rov yuboradi (path substitutsiyasi runtime'da ishlaydi)",
    async () => {
      server.use(unidentifiedAssignHandler);
      const { result } = renderHook(() => useUnidentifiedAssign(), {
        wrapper: withQueryClient(),
      });

      result.current.mutate({
        id: 'unidentified-1',
        body: { driver_id: 'driver-1', note: 'Matches your dispatch for that trip' },
      });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(result.current.data?.source).toBe('unidentified_assign');
      expect(result.current.data?.unidentified_event_id).toBe('unidentified-1');
    },
  );

  it('409 ALREADY_ASSIGNED', async () => {
    server.use(unidentifiedAssignConflictHandler);
    const { result } = renderHook(() => useUnidentifiedAssign(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({ id: 'unidentified-1', body: { driver_id: 'driver-1', note: 'x' } });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.code).toBe('ALREADY_ASSIGNED');
  });
});

describe('useUnidentifiedAnnotate', () => {
  it('izoh bilan annotated qiladi', async () => {
    server.use(unidentifiedAnnotateHandler);
    const { result } = renderHook(() => useUnidentifiedAnnotate(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({
      id: 'unidentified-1',
      body: { annotation: 'Mechanic test drive after brake repair' },
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.status).toBe('annotated');
  });

  it('422 — annotation majburiy', async () => {
    server.use(unidentifiedAnnotateValidationErrorHandler);
    const { result } = renderHook(() => useUnidentifiedAnnotate(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({ id: 'unidentified-1', body: { annotation: '' } });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.fields?.annotation).toBeDefined();
  });
});

describe('useUnidentifiedClaim', () => {
  it("haydovchi blokni o'zi oladi", async () => {
    server.use(unidentifiedClaimHandler);
    const { result } = renderHook(() => useUnidentifiedClaim(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate('unidentified-1');

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.status).toBe('assigned');
  });

  it('409 ALREADY_ASSIGNED', async () => {
    server.use(unidentifiedClaimConflictHandler);
    const { result } = renderHook(() => useUnidentifiedClaim(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate('unidentified-1');

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.code).toBe('ALREADY_ASSIGNED');
  });
});
