/**
 * Shipping Documents query hooklari — integratsiya testi (MSW orqali).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  shippingDocumentCreateHandler,
  shippingDocumentDeleteHandler,
  shippingDocumentFixture,
  shippingDocumentsListHandler,
} from '@/mocks/handlers/shippingDocuments';

import {
  useShippingDocumentCreate,
  useShippingDocumentDelete,
  useShippingDocumentsList,
} from './shippingDocuments';
import { withQueryClient } from './test-utils';

describe('useShippingDocumentsList', () => {
  it("ro'yxatni {data, meta} shaklida qaytaradi", async () => {
    server.use(shippingDocumentsListHandler);
    const { result } = renderHook(() => useShippingDocumentsList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([shippingDocumentFixture()]);
  });
});

describe('useShippingDocumentCreate', () => {
  it('muvaffaqiyatli yaratadi', async () => {
    server.use(shippingDocumentCreateHandler);
    const { result } = renderHook(() => useShippingDocumentCreate(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({ number: 'BOL-1' });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.id).toBe('ship-doc-new');
  });
});

describe('useShippingDocumentDelete', () => {
  it("204 muvaffaqiyatli o'chiradi", async () => {
    server.use(shippingDocumentDeleteHandler);
    const { result } = renderHook(() => useShippingDocumentDelete(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate('ship-doc-1');

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
  });
});
