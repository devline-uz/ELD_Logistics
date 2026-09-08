/**
 * Maintenance query hooklari — integratsiya testi (MSW orqali, fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { server } from '@/test/msw-server';
import {
  maintenanceCancelConflictHandler,
  maintenanceCancelHandler,
  maintenanceCompleteHandler,
  maintenanceCompleteNoReadingHandler,
  maintenanceDueListHandler,
  maintenanceRecordFixture,
  maintenanceRecordsListHandler,
  maintenanceScheduleCreateHandler,
  maintenanceScheduleDeleteHandler,
  maintenanceScheduleFixture,
  maintenanceScheduleGetNotFoundHandler,
  maintenanceSchedulesListErrorHandler,
  maintenanceSchedulesListHandler,
  maintenanceScheduleUnitFixture,
  maintenanceScheduleUpdateHandler,
} from '@/mocks/handlers/maintenance';

import {
  useMaintenanceCancel,
  useMaintenanceComplete,
  useMaintenanceDue,
  useMaintenanceRecordsList,
  useMaintenanceSchedule,
  useMaintenanceScheduleCreate,
  useMaintenanceScheduleDelete,
  useMaintenanceSchedulesList,
  useMaintenanceScheduleUpdate,
} from './maintenance';
import { withQueryClient } from './test-utils';

describe('useMaintenanceSchedulesList — Schedule tab', () => {
  it("ro'yxatni {data, meta} shaklida qaytaradi", async () => {
    server.use(maintenanceSchedulesListHandler);
    const { result } = renderHook(() => useMaintenanceSchedulesList(), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([maintenanceScheduleFixture()]);
  });

  it('422 javobida ApiError bilan tugaydi', async () => {
    server.use(maintenanceSchedulesListErrorHandler);
    const { result } = renderHook(() => useMaintenanceSchedulesList(), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useMaintenanceSchedule', () => {
  it("cross-tenant/mavjud bo'lmagan reja uchun 404 qaytaradi", async () => {
    server.use(maintenanceScheduleGetNotFoundHandler);
    const { result } = renderHook(() => useMaintenanceSchedule('schedule-999'), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(404);
  });
});

describe('useMaintenanceScheduleCreate', () => {
  it('muvaffaqiyatli yaratilgan rejani qaytaradi', async () => {
    server.use(maintenanceScheduleCreateHandler);
    const { result } = renderHook(() => useMaintenanceScheduleCreate(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({
      name: 'Engine oil change',
      interval_unit: 'km',
      interval_value: 25000,
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.id).toBe('schedule-new');
  });
});

describe('useMaintenanceScheduleUpdate', () => {
  it('muvaffaqiyatli tahrirlaydi', async () => {
    server.use(maintenanceScheduleUpdateHandler);
    const { result } = renderHook(() => useMaintenanceScheduleUpdate(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({ id: 'schedule-1', body: { name: 'Updated' } });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
  });
});

describe('useMaintenanceScheduleDelete', () => {
  it('muvaffaqiyatli o‘chiradi (204)', async () => {
    server.use(maintenanceScheduleDeleteHandler);
    const { result } = renderHook(() => useMaintenanceScheduleDelete(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate('schedule-1');
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
  });
});

describe('useMaintenanceDue — Due tab', () => {
  it("ro'yxatni {data, meta} shaklida qaytaradi (remaining/overdue bilan)", async () => {
    server.use(maintenanceDueListHandler);
    const { result } = renderHook(() => useMaintenanceDue(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([maintenanceScheduleUnitFixture()]);
  });

  it('`schedule_id` filtri bilan "N Units" ekranida qayta ishlatiladi', async () => {
    server.use(maintenanceDueListHandler);
    const { result } = renderHook(() => useMaintenanceDue({ schedule_id: 'schedule-1' }), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data?.[0]?.schedule_id).toBe('schedule-1');
  });
});

describe('useMaintenanceComplete', () => {
  it("`completed` holatiga o'tkazadi va yangi next_due_value beradi", async () => {
    server.use(maintenanceCompleteHandler);
    const { result } = renderHook(() => useMaintenanceComplete(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({
      id: 'schedule-unit-1',
      body: { invoice_no: 'INV-1', vendor: 'Vendor', cost: 100 },
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.status).toBe('completed');
  });

  it('422 MAINTENANCE_NO_READING qaytaradi', async () => {
    server.use(maintenanceCompleteNoReadingHandler);
    const { result } = renderHook(() => useMaintenanceComplete(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({ id: 'schedule-unit-1', body: {} });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useMaintenanceCancel', () => {
  it("`cancelled` holatiga o'tkazadi", async () => {
    server.use(maintenanceCancelHandler);
    const { result } = renderHook(() => useMaintenanceCancel(), { wrapper: withQueryClient() });

    result.current.mutate({ id: 'schedule-unit-1', body: { cancelled_reason: 'Unit sold' } });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.status).toBe('cancelled');
  });

  it('409 MAINTENANCE_INVALID_STATE qaytaradi', async () => {
    server.use(maintenanceCancelConflictHandler);
    const { result } = renderHook(() => useMaintenanceCancel(), { wrapper: withQueryClient() });

    result.current.mutate({ id: 'schedule-unit-1', body: { cancelled_reason: 'x' } });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(409);
  });
});

describe('useMaintenanceRecordsList — History tab', () => {
  it("ro'yxatni {data, meta} shaklida qaytaradi", async () => {
    server.use(maintenanceRecordsListHandler);
    const { result } = renderHook(() => useMaintenanceRecordsList(), {
      wrapper: withQueryClient(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.data).toEqual([maintenanceRecordFixture()]);
  });
});
