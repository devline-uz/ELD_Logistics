/**
 * Audit log query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  auditLogEntryFixture,
  auditLogListEmptyHandler,
  auditLogListErrorHandler,
  auditLogListHandler,
  auditLogTablesErrorHandler,
  auditLogTablesHandler,
} from '@/mocks/handlers/audit';

import { useAuditLogList, useAuditLogTables } from './audit';
import { withQueryClient } from './test-utils';

describe('useAuditLogList', () => {
  it('audit trail yozuvlarini qaytaradi', async () => {
    server.use(auditLogListHandler);
    const { result } = renderHook(() => useAuditLogList(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([auditLogEntryFixture()]);
  });

  it("bo'sh natijani qaytaradi", async () => {
    server.use(auditLogListEmptyHandler);
    const { result } = renderHook(() => useAuditLogList({ table: 'units' }), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([]);
  });

  it('422 javobida ApiError bilan tugaydi', async () => {
    server.use(auditLogListErrorHandler);
    const { result } = renderHook(() => useAuditLogList({ from: 'invalid' }), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useAuditLogTables', () => {
  it('audit qilingan jadval nomlarini qaytaradi', async () => {
    server.use(auditLogTablesHandler);
    const { result } = renderHook(() => useAuditLogTables(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toContain('support_tickets');
  });

  it('403 javobida ApiError bilan tugaydi', async () => {
    server.use(auditLogTablesErrorHandler);
    const { result } = renderHook(() => useAuditLogTables(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(403);
  });
});
