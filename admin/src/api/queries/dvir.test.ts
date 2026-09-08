/**
 * DVIR query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  dvirCertifyConflictHandler,
  dvirCertifyHandler,
  dvirGetHandler,
  dvirGetNotFoundHandler,
  dvirListErrorHandler,
  dvirListHandler,
  dvirPdfHandler,
  dvirPendingCertificationHandler,
  dvirRepairConflictHandler,
  dvirRepairHandler,
  dvirReportFixture,
} from '@/mocks/handlers/dvir';

import {
  useDvirCertify,
  useDvirList,
  useDvirPdfDownload,
  useDvirPendingCertification,
  useDvirRepair,
  useDvirReport,
} from './dvir';
import { withQueryClient } from './test-utils';

describe('useDvirList', () => {
  it("ro'yxatni {data, meta} shaklida qaytaradi", async () => {
    server.use(dvirListHandler);
    const { result } = renderHook(() => useDvirList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(result.current.data?.data).toEqual([dvirReportFixture()]);
    expect(result.current.data?.meta?.total).toBe(1);
  });

  it('422 javobida ApiError bilan tugaydi', async () => {
    server.use(dvirListErrorHandler);
    const { result } = renderHook(() => useDvirList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useDvirPendingCertification', () => {
  it('`repaired` holatidagi hisobotlarni qaytaradi', async () => {
    server.use(dvirPendingCertificationHandler);
    const { result } = renderHook(() => useDvirPendingCertification(), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data?.[0]?.status).toBe('repaired');
  });
});

describe('useDvirReport', () => {
  it("cross-tenant/mavjud bo'lmagan hisobot uchun 404 qaytaradi (403 emas)", async () => {
    server.use(dvirGetNotFoundHandler);
    const { result } = renderHook(() => useDvirReport('dvir-999'), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(404);
  });

  it('muvaffaqiyatli hisobotni qaytaradi', async () => {
    server.use(dvirGetHandler);
    const { result } = renderHook(() => useDvirReport('dvir-1'), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.id).toBe('dvir-1');
  });
});

describe('useDvirRepair', () => {
  it("`repaired` holatiga o'tkazadi", async () => {
    server.use(dvirRepairHandler);
    const { result } = renderHook(() => useDvirRepair(), { wrapper: withQueryClient() });

    result.current.mutate({
      id: 'dvir-1',
      body: { mechanic_note: 'Replaced tyre', mechanic_signature_key: 'c1/signature/mech.png' },
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.status).toBe('repaired');
  });

  it('409 DVIR_INVALID_TRANSITION xatosini qaytaradi', async () => {
    server.use(dvirRepairConflictHandler);
    const { result } = renderHook(() => useDvirRepair(), { wrapper: withQueryClient() });

    result.current.mutate({
      id: 'dvir-1',
      body: { mechanic_note: 'x', mechanic_signature_key: 'c1/signature/mech.png' },
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(409);
  });
});

describe('useDvirCertify', () => {
  it("`certified` holatiga o'tkazadi", async () => {
    server.use(dvirCertifyHandler);
    const { result } = renderHook(() => useDvirCertify(), { wrapper: withQueryClient() });

    result.current.mutate({ id: 'dvir-1', body: { signature_key: 'c1/signature/sig.png' } });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.status).toBe('certified');
    expect(result.current.data?.out_of_service).toBe(false);
  });

  it('409 DVIR_INVALID_TRANSITION xatosini qaytaradi', async () => {
    server.use(dvirCertifyConflictHandler);
    const { result } = renderHook(() => useDvirCertify(), { wrapper: withQueryClient() });

    result.current.mutate({ id: 'dvir-1', body: { signature_key: 'c1/signature/sig.png' } });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(409);
  });
});

describe('useDvirPdfDownload', () => {
  it('Blob sifatida PDF qaytaradi', async () => {
    server.use(dvirPdfHandler);
    const { result } = renderHook(() => useDvirPdfDownload(), { wrapper: withQueryClient() });

    result.current.mutate('dvir-1');

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toBeInstanceOf(Blob);
  });
});
