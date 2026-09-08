/**
 * Audit log — MSW handler'lari (Bosqich 8.1, fe-testing §MSW).
 */
import { http, HttpResponse } from 'msw';

import type { AuditLogEntry, ListResponse } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function auditLogEntryFixture(overrides: Partial<AuditLogEntry> = {}): AuditLogEntry {
  return {
    id: '3c9a1f2e-5d4b-4a6c-8e1f-0d2b3a4c5e6f',
    table: 'support_tickets',
    record_id: '6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f',
    action: 'update',
    field: 'status',
    old_value: 'new',
    new_value: 'in_progress',
    masked: false,
    edited_by: '8d3e2f1a-4b5c-4d6e-9f70-1a2b3c4d5e6f',
    edited_by_name: 'Anna Ross',
    username: 'anna.ross',
    ts: '2026-09-07T11:30:00Z',
    ...overrides,
  };
}

/** `GET /audit-log` — muvaffaqiyatli. */
export const auditLogListHandler = http.get(url('/audit-log'), () =>
  HttpResponse.json({
    data: [auditLogEntryFixture()],
    meta: listMeta(),
  } satisfies ListResponse<AuditLogEntry>),
);

/** `GET /audit-log` — bo'sh natija. */
export const auditLogListEmptyHandler = http.get(url('/audit-log'), () =>
  HttpResponse.json({
    data: [],
    meta: listMeta({ total: 0 }),
  } satisfies ListResponse<AuditLogEntry>),
);

/** `GET /audit-log` — `422` (noto'g'ri `from`/`to`). */
export const auditLogListErrorHandler = http.get(url('/audit-log'), () =>
  jsonError('VALIDATION_ERROR', 'invalid from/to range', 422),
);

/** `GET /audit-log/tables` — muvaffaqiyatli. */
export const auditLogTablesHandler = http.get(url('/audit-log/tables'), () =>
  HttpResponse.json({ data: ['support_tickets', 'units', 'companies', 'hos_policy_versions'] }),
);

/** `GET /audit-log/tables` — `403`. */
export const auditLogTablesErrorHandler = http.get(url('/audit-log/tables'), () =>
  jsonError('FORBIDDEN', 'audit.view required', 403),
);
