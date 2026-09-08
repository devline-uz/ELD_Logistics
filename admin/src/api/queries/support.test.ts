/**
 * Support query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  supportTicketDetailHandler,
  supportTicketDetailNotFoundHandler,
  supportTicketFixture,
  supportTicketMessageCreateErrorHandler,
  supportTicketMessageCreateHandler,
  supportTicketMessageFixture,
  supportTicketMessagesHandler,
  supportTicketsListErrorHandler,
  supportTicketsListHandler,
  supportTicketStatusUpdateConflictHandler,
  supportTicketStatusUpdateHandler,
} from '@/mocks/handlers/support';

import {
  useSupportTicketDetail,
  useSupportTicketMessageCreate,
  useSupportTicketMessages,
  useSupportTicketsList,
  useSupportTicketStatusUpdate,
} from './support';
import { withQueryClient } from './test-utils';

describe('useSupportTicketsList', () => {
  it('navbatni qaytaradi', async () => {
    server.use(supportTicketsListHandler);
    const { result } = renderHook(() => useSupportTicketsList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([supportTicketFixture()]);
  });

  it('422 javobida ApiError bilan tugaydi', async () => {
    server.use(supportTicketsListErrorHandler);
    const { result } = renderHook(() => useSupportTicketsList({ status: 'new' }), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useSupportTicketDetail', () => {
  it('ticket detalini qaytaradi', async () => {
    server.use(supportTicketDetailHandler);
    const { result } = renderHook(() => useSupportTicketDetail('ticket-1'), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.id).toBe('ticket-1');
  });

  it('boshqa kompaniyaniki uchun 404 qaytaradi', async () => {
    server.use(supportTicketDetailNotFoundHandler);
    const { result } = renderHook(() => useSupportTicketDetail('ticket-999'), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(404);
  });

  it("`id` bo'lmasa so'rov yubormaydi", () => {
    const { result } = renderHook(() => useSupportTicketDetail(undefined), {
      wrapper: withQueryClient(),
    });

    expect(result.current.fetchStatus).toBe('idle');
  });
});

describe('useSupportTicketMessages', () => {
  it('thread xabarlarini qaytaradi', async () => {
    server.use(supportTicketMessagesHandler);
    const { result } = renderHook(() => useSupportTicketMessages('ticket-1'), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([
      supportTicketMessageFixture({ ticket_id: 'ticket-1' }),
    ]);
  });
});

describe('useSupportTicketMessageCreate', () => {
  it('javob yozadi (201)', async () => {
    server.use(supportTicketMessageCreateHandler);
    const { result } = renderHook(() => useSupportTicketMessageCreate('ticket-1'), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({ text: 'We shipped a replacement cable today.', attachments: [] });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.id).toBe('msg-new');
  });

  it('422 javobida (4-biriktirma) ApiError bilan tugaydi', async () => {
    server.use(supportTicketMessageCreateErrorHandler);
    const { result } = renderHook(() => useSupportTicketMessageCreate('ticket-1'), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({ text: 'x', attachments: ['a', 'b', 'c', 'd'] });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useSupportTicketStatusUpdate', () => {
  it('statusni yangilaydi', async () => {
    server.use(supportTicketStatusUpdateHandler);
    const { result } = renderHook(() => useSupportTicketStatusUpdate('ticket-1'), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({ status: 'in_progress' });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.status).toBe('in_progress');
  });

  it('409 (orqaga siljish) ApiError bilan tugaydi', async () => {
    server.use(supportTicketStatusUpdateConflictHandler);
    const { result } = renderHook(() => useSupportTicketStatusUpdate('ticket-1'), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({ status: 'new' });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(409);
  });
});
