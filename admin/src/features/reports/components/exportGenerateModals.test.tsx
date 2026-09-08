/**
 * Eksport job'i "Generate" oqimidagi **hisobot turiga xos `params` shakli** testlari
 * (Bosqich 6.10, fe-api §9, item 5): `distance_by_region`da `unit_ids` faqat
 * `regions_and_units` rejimida, `regulator`da `from`/`to` faqat `Custom Range`da
 * (`roadside`da klient hisoblagan 8 kunlik oyna).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import type { ReactElement } from 'react';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, describe, expect, it, vi } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import type { ExportJobCreate } from '@/api/types';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { PERM } from '@/lib/permissions';
import { driversListHandler } from '@/mocks/handlers/drivers';
import { dvirListHandler } from '@/mocks/handlers/dvir';
import {
  createExportJobCreateCaptureHandler,
  exportJobFixture,
  reportsActivityHandler,
} from '@/mocks/handlers/reports';
import { url } from '@/mocks/handlers/shared';
import { unitsListHandler } from '@/mocks/handlers/units';
import { server } from '@/test/msw-server';

import { ActivityReportPage } from '../pages/ActivityReportPage';
import { DvirReportPage } from '../pages/DvirReportPage';
import { DistanceReportGenerateModal } from './DistanceReportGenerateModal';
import { RegulatorGenerateModal } from './RegulatorGenerateModal';

function renderWithClient(node: ReactElement): ReactElement {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return <QueryClientProvider client={queryClient}>{node}</QueryClientProvider>;
}

/** Har testda job GET so'roviga `queued` bilan javob beradigan yordamchi handler —
 * `Generate`dan keyingi `useExportJob` pollingi xato bermasligi uchun. */
const jobGetQueuedHandler = http.get(url('/reports/export-jobs/:id'), ({ params }) =>
  HttpResponse.json({ data: exportJobFixture({ id: params.id as string, status: 'queued' }) }),
);

function captureCreate(): { get: () => ExportJobCreate | undefined } {
  let captured: ExportJobCreate | undefined;
  server.use(
    createExportJobCreateCaptureHandler((body) => (captured = body)),
    jobGetQueuedHandler,
  );
  return { get: () => captured };
}

function renderPage(node: ReactElement, initialEntry: string): ReactElement {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return (
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={[PERM.reportsRead, PERM.reportsExport]}>
        <ToastProvider>
          <MemoryRouter initialEntries={[initialEntry]}>{node}</MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>
  );
}

afterEach(() => {
  server.resetHandlers();
  vi.useRealTimers();
});

describe('DistanceReportGenerateModal — `unit_ids` faqat `regions_and_units` rejimida', () => {
  it('`regions_and_units` rejimida tanlangan unit `unit_ids`ga tushadi', async () => {
    const capture = captureCreate();
    const user = userEvent.setup();
    render(
      renderWithClient(
        <DistanceReportGenerateModal
          open
          onClose={() => {}}
          defaultMode="regions_and_units"
          defaultQuarter={3}
          defaultYear={2026}
          unitOptions={[{ value: 'unit-1', label: '1021' }]}
        />,
      ),
    );

    await user.click(screen.getByRole('combobox', { name: 'Units' }));
    await user.click(screen.getByRole('option', { name: '1021' }));
    await user.click(screen.getByRole('button', { name: 'Generate' }));

    await screen.findByText('Preparing your file…');
    expect(capture.get()).toEqual({
      type: 'distance_by_region',
      format: 'csv',
      params: { mode: 'regions_and_units', quarter: 3, year: 2026, unit_ids: ['unit-1'] },
    });
  });

  it("`regions_only` rejimida Units maydoni yo'q va `unit_ids` yuborilmaydi", async () => {
    const capture = captureCreate();
    const user = userEvent.setup();
    render(
      renderWithClient(
        <DistanceReportGenerateModal
          open
          onClose={() => {}}
          defaultMode="regions_only"
          defaultQuarter={3}
          defaultYear={2026}
          unitOptions={[{ value: 'unit-1', label: '1021' }]}
        />,
      ),
    );

    expect(screen.queryByRole('combobox', { name: 'Units' })).not.toBeInTheDocument();
    await user.click(screen.getByRole('button', { name: 'Generate' }));

    await screen.findByText('Preparing your file…');
    const body = capture.get();
    expect(body?.params).toEqual({ mode: 'regions_only', quarter: 3, year: 2026 });
    expect(body?.params).not.toHaveProperty('unit_ids');
  });
});

describe('RegulatorGenerateModal — `from`/`to` faqat `Custom Range`da tanlanadi', () => {
  it('`roadside` (default) — `from`/`to` klient tomonida 8 kunlik oyna sifatida hisoblanadi', async () => {
    vi.useFakeTimers({ shouldAdvanceTime: true });
    vi.setSystemTime(new Date('2026-09-08T12:00:00'));
    const capture = captureCreate();
    const user = userEvent.setup({ delay: null, advanceTimers: vi.advanceTimersByTime });
    render(
      renderWithClient(
        <RegulatorGenerateModal
          open
          onClose={() => {}}
          driverOptions={[{ value: 'driver-1', label: 'John Doe' }]}
        />,
      ),
    );

    await user.click(screen.getByRole('combobox', { name: 'Driver' }));
    await user.click(screen.getByRole('option', { name: 'John Doe' }));
    await user.type(screen.getByLabelText(/Comment/), 'Roadside check');
    await user.click(screen.getByRole('button', { name: 'Generate' }));

    expect(capture.get()).toEqual({
      type: 'regulator',
      format: 'csv',
      params: {
        driver_ids: ['driver-1'],
        from: '2026-09-01',
        to: '2026-09-08',
        comment: 'Roadside check',
      },
    });
  });

  it('`Custom Range` tanlanganda foydalanuvchi tanlagan sanalar yuboriladi', async () => {
    vi.useFakeTimers({ shouldAdvanceTime: true });
    vi.setSystemTime(new Date('2026-09-08T12:00:00'));
    const capture = captureCreate();
    const user = userEvent.setup({ delay: null, advanceTimers: vi.advanceTimersByTime });
    render(
      renderWithClient(
        <RegulatorGenerateModal
          open
          onClose={() => {}}
          driverOptions={[{ value: 'driver-1', label: 'John Doe' }]}
        />,
      ),
    );

    await user.click(screen.getByRole('combobox', { name: 'Type' }));
    await user.click(screen.getByRole('option', { name: 'Custom Range' }));

    await user.click(screen.getByRole('combobox', { name: 'Driver' }));
    await user.click(screen.getByRole('option', { name: 'John Doe' }));
    await user.type(screen.getByLabelText(/Comment/), 'Custom window');

    // "From" — 4-sentabr, "To" — 6-sentabr: 1/2/3/30 kabi raqamlar avvalgi/keyingi oy
    // to'ldiruvchi kunlari bilan to'qnashadi (bir xil kalendar to'rida ikkita "1" chiqadi),
    // shuning uchun 4-29 oralig'idan tanlanadi. `To`ning `maxDate` — bugun (8-sentabr).
    await user.click(screen.getByRole('button', { name: /^From /i }));
    await user.click(screen.getByRole('gridcell', { name: '4' }));
    await user.click(screen.getByRole('button', { name: /^To /i }));
    await user.click(screen.getByRole('gridcell', { name: '6' }));

    await user.click(screen.getByRole('button', { name: 'Generate' }));

    expect(capture.get()).toEqual({
      type: 'regulator',
      format: 'csv',
      params: {
        driver_ids: ['driver-1'],
        from: '2026-09-04',
        to: '2026-09-06',
        comment: 'Custom window',
      },
    });
  });
});

describe('DvirReportPage — eksport `params`i faol filtrlardan quriladi', () => {
  it("filtrlar bo'lmasa `unit_ids`/`driver_ids`/`from`/`to` yuborilmaydi", async () => {
    server.use(driversListHandler, unitsListHandler, dvirListHandler);
    const capture = captureCreate();
    const user = userEvent.setup();
    render(renderPage(<DvirReportPage />, '/reports/dvir'));

    await user.click(await screen.findByRole('button', { name: 'Export' }));
    await user.click(screen.getByRole('button', { name: 'Generate' }));

    await screen.findByText('Preparing your file…');
    expect(capture.get()).toEqual({ type: 'dvir', format: 'csv', params: {} });
  });

  it('faol filtrlar (`unit_id`/`driver_id`/`from`/`to`) `params`ga tushadi', async () => {
    server.use(driversListHandler, unitsListHandler, dvirListHandler);
    const capture = captureCreate();
    const user = userEvent.setup();
    render(
      renderPage(
        <DvirReportPage />,
        '/reports/dvir?unit_id=unit-1&driver_id=driver-1&from=2026-08-01&to=2026-08-08',
      ),
    );

    await user.click(await screen.findByRole('button', { name: 'Export' }));
    await user.click(screen.getByRole('button', { name: 'Generate' }));

    await screen.findByText('Preparing your file…');
    expect(capture.get()).toEqual({
      type: 'dvir',
      format: 'csv',
      params: {
        unit_ids: ['unit-1'],
        driver_ids: ['driver-1'],
        from: '2026-08-01',
        to: '2026-08-08',
      },
    });
  });
});

describe('ActivityReportPage — eksport `params`i `subject` tabiga qarab shakllanadi', () => {
  it("`Units` tabida `unit_ids` yuboriladi, `driver_ids` yo'q", async () => {
    server.use(driversListHandler, unitsListHandler, reportsActivityHandler);
    const capture = captureCreate();
    const user = userEvent.setup();
    render(
      renderPage(
        <ActivityReportPage />,
        '/reports/activity?subject=units&unit_id=unit-1&from=2026-09-01&to=2026-09-07',
      ),
    );

    await user.click(await screen.findByRole('button', { name: 'Download CSV' }));
    await user.click(screen.getByRole('button', { name: 'Generate' }));

    await screen.findByText('Preparing your file…');
    expect(capture.get()).toEqual({
      type: 'activity',
      format: 'csv',
      params: {
        subject: 'units',
        from: '2026-09-01',
        to: '2026-09-07',
        unit_ids: ['unit-1'],
        driver_ids: undefined,
      },
    });
  });

  it("`Drivers` tabida `driver_ids` yuboriladi, `unit_ids` yo'q", async () => {
    server.use(driversListHandler, unitsListHandler, reportsActivityHandler);
    const capture = captureCreate();
    const user = userEvent.setup();
    render(
      renderPage(
        <ActivityReportPage />,
        '/reports/activity?subject=drivers&driver_id=driver-1&from=2026-09-01&to=2026-09-07',
      ),
    );

    await user.click(await screen.findByRole('button', { name: 'Download CSV' }));
    await user.click(screen.getByRole('button', { name: 'Generate' }));

    await screen.findByText('Preparing your file…');
    expect(capture.get()).toEqual({
      type: 'activity',
      format: 'csv',
      params: {
        subject: 'drivers',
        from: '2026-09-01',
        to: '2026-09-07',
        unit_ids: undefined,
        driver_ids: ['driver-1'],
      },
    });
  });
});
