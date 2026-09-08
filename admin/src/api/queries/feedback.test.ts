/**
 * Feedback query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  feedbackFixture,
  feedbackListEmptyHandler,
  feedbackListErrorHandler,
  feedbackListHandler,
} from '@/mocks/handlers/feedback';

import { useFeedbackList } from './feedback';
import { withQueryClient } from './test-utils';

describe('useFeedbackList', () => {
  it('reyting oqimini qaytaradi', async () => {
    server.use(feedbackListHandler);
    const { result } = renderHook(() => useFeedbackList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([feedbackFixture()]);
  });

  it("bo'sh natijani qaytaradi", async () => {
    server.use(feedbackListEmptyHandler);
    const { result } = renderHook(() => useFeedbackList({ min_rating: 5 }), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([]);
  });

  it('422 javobida ApiError bilan tugaydi', async () => {
    server.use(feedbackListErrorHandler);
    const { result } = renderHook(() => useFeedbackList({ min_rating: 9 }), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});
