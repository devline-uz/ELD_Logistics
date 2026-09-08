/**
 * `ExportJobModal` — job oqimi testi (Bosqich 6.2, fe-api §9): `Generate` bosilgach
 * job holatiga qarab forma → progress → yuklab olish/failed/`501` ko'rinishlariga o'tadi.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { act, render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { useState, type ReactElement } from 'react';
import { afterEach, describe, expect, it, vi } from 'vitest';

import type { ExportJobCreate } from '@/api/types';
import {
  createExportJobCreateCaptureHandler,
  exportJobCreateFeatureDisabledHandler,
  exportJobCreateHandler,
  exportJobFailedHandler,
  exportJobFixture,
} from '@/mocks/handlers/reports';
import { EXPORT_JOB_POLL_MAX_DURATION_MS } from '@/api/queries/reports';
import { url } from '@/mocks/handlers/shared';
import { server } from '@/test/msw-server';

/**
 * `exportJobDoneHandler` (mocks/handlers/reports.ts) `expires_at`ni sobit sanaga
 * qattiq yozgan — testlar orasidagi haqiqiy "bugun" bilan to'qnashmasligi uchun
 * bu yerda muddati doim kelajakda bo'lgan alohida `done` handler yaratiladi.
 */
const exportJobDoneNotExpiredHandler = http.get(url('/reports/export-jobs/:id'), ({ params }) =>
  HttpResponse.json({
    data: exportJobFixture({
      id: params.id as string,
      status: 'done',
      download_url: 'https://storage.example.com/onebook/job-1.xlsx',
      expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
    }),
  }),
);

import { ExportJobModal } from './ExportJobModal';

function renderModal(
  onClose = () => {},
  formats: readonly ('csv' | 'xlsx' | 'pdf')[] = ['csv', 'xlsx', 'pdf'],
): ReactElement {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return (
    <QueryClientProvider client={queryClient}>
      <ExportJobModal
        open
        onClose={onClose}
        type="activity"
        titleKey="reports.activityReport.exportModal.title"
        params={{ subject: 'units', from: '2026-09-01', to: '2026-09-07' }}
        formats={formats}
      />
    </QueryClientProvider>
  );
}

/** `open`ni ichki `useState` bilan boshqaradigan qobiq — yopilgandan keyin ham
 * pollingning to'xtashini tekshirish uchun (`onClose` orqali `open=false`). */
function ExportModalHarness(props: {
  formats?: readonly ('csv' | 'xlsx' | 'pdf')[];
}): ReactElement {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  const [open, setOpen] = useState(true);
  return (
    <QueryClientProvider client={queryClient}>
      <ExportJobModal
        open={open}
        onClose={() => setOpen(false)}
        type="activity"
        titleKey="reports.activityReport.exportModal.title"
        params={{ subject: 'units', from: '2026-09-01', to: '2026-09-07' }}
        formats={props.formats ?? ['csv', 'xlsx', 'pdf']}
      />
    </QueryClientProvider>
  );
}

afterEach(() => {
  server.resetHandlers();
  vi.useRealTimers();
});

describe('ExportJobModal', () => {
  it('job `done` bo‘lganda yuklab olish tugmasini ko‘rsatadi', async () => {
    server.use(exportJobCreateHandler, exportJobDoneNotExpiredHandler);
    const user = userEvent.setup();
    render(renderModal());

    await user.click(screen.getByRole('button', { name: 'Generate' }));

    expect(await screen.findByText('Your file is ready.')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Download' })).toBeInTheDocument();
  });

  it('job `failed` bo‘lganda xato va `Try again` tugmasini ko‘rsatadi', async () => {
    server.use(exportJobCreateHandler, exportJobFailedHandler);
    const user = userEvent.setup();
    render(renderModal());

    await user.click(screen.getByRole('button', { name: 'Generate' }));

    expect(await screen.findByText('the map provider is unavailable')).toBeInTheDocument();
    const retry = screen.getByRole('button', { name: 'Try again' });
    await user.click(retry);
    expect(screen.getByRole('button', { name: 'Generate' })).toBeInTheDocument();
  });

  it('`501 FEATURE_DISABLED` bo‘lganda maxsus xabar ko‘rsatadi (F127)', async () => {
    server.use(exportJobCreateFeatureDisabledHandler);
    const user = userEvent.setup();
    render(renderModal());

    await user.click(screen.getByRole('button', { name: 'Generate' }));

    expect(await screen.findByText('This export is not available yet.')).toBeInTheDocument();
  });

  it("job `done`, lekin muddati o'tgan bo'lsa yuklab olish o'rniga sabab ko'rsatadi", async () => {
    const expiredHandler = http.get(url('/reports/export-jobs/:id'), ({ params }) =>
      HttpResponse.json({
        data: exportJobFixture({
          id: params.id as string,
          status: 'done',
          download_url: 'https://storage.example.com/onebook/job-1.xlsx',
          expires_at: new Date(Date.now() - 60_000).toISOString(),
        }),
      }),
    );
    server.use(exportJobCreateHandler, expiredHandler);
    const user = userEvent.setup();
    render(renderModal());

    await user.click(screen.getByRole('button', { name: 'Generate' }));

    expect(await screen.findByText('Link expired — re-run export.')).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Download' })).not.toBeInTheDocument();
  });
});

describe('ExportJobModal — format tanlovi (payload)', () => {
  it("`formats` propi cheklangan bo'lsa faqat ruxsat etilgan formatlar ko'rinadi", async () => {
    render(renderModal(undefined, ['csv', 'xlsx']));
    const user = userEvent.setup();

    await user.click(screen.getByRole('combobox', { name: 'Generate as' }));

    expect(screen.getByRole('option', { name: 'CSV' })).toBeInTheDocument();
    expect(screen.getByRole('option', { name: 'XLSX' })).toBeInTheDocument();
    expect(screen.queryByRole('option', { name: 'PDF' })).not.toBeInTheDocument();
    expect(screen.queryByRole('option', { name: 'ZIP' })).not.toBeInTheDocument();
  });

  it.each([
    ['csv', 'CSV'],
    ['xlsx', 'XLSX'],
    ['pdf', 'PDF'],
  ] as const)(
    '`%s` tanlansa `POST /reports/export-jobs` ga `type`+`format`+`params` to‘g‘ri yuboriladi',
    async (format, label) => {
      let captured: ExportJobCreate | undefined;
      server.use(
        createExportJobCreateCaptureHandler((body) => (captured = body)),
        http.get(url('/reports/export-jobs/:id'), ({ params }) =>
          HttpResponse.json({
            data: exportJobFixture({ id: params.id as string, status: 'queued' }),
          }),
        ),
      );
      const user = userEvent.setup();
      render(renderModal());

      await user.click(screen.getByRole('combobox', { name: 'Generate as' }));
      await user.click(screen.getByRole('option', { name: label }));
      await user.click(screen.getByRole('button', { name: 'Generate' }));

      await screen.findByText('Preparing your file…');
      expect(captured).toEqual({
        type: 'activity',
        format,
        params: { subject: 'units', from: '2026-09-01', to: '2026-09-07' },
      });
    },
  );
});

describe('ExportJobModal — pollingning to‘xtashi', () => {
  it("modal yopilganda (`Close`) polling to'xtaydi — keyingi so'rov yuborilmaydi", async () => {
    vi.useFakeTimers({ shouldAdvanceTime: true });
    let callCount = 0;
    server.use(
      exportJobCreateHandler,
      http.get(url('/reports/export-jobs/:id'), ({ params }) => {
        callCount += 1;
        return HttpResponse.json({
          data: exportJobFixture({ id: params.id as string, status: 'running' }),
        });
      }),
    );
    const user = userEvent.setup({ delay: null });
    render(<ExportModalHarness />);

    await user.click(screen.getByRole('button', { name: 'Generate' }));
    await waitFor(() => expect(callCount).toBeGreaterThan(0));
    const callsAtClose = callCount;

    // Modal sarlavhasidagi X ham, footerdagi "Close" tugmasi ham `onClose`ni chaqiradi —
    // footerdagisini oxirgisi sifatida tanlaymiz (ikkalasi ham "Close" nomlangan).
    const closeButtons = screen.getAllByRole('button', { name: 'Close' });
    await user.click(closeButtons[closeButtons.length - 1]!);

    await act(async () => {
      await vi.advanceTimersByTimeAsync(60_000);
    });

    expect(callCount).toBe(callsAtClose);
  });

  it('5 daqiqadan keyin "hali tayyor emas" xabari ko\'rsatiladi', async () => {
    vi.useFakeTimers({ shouldAdvanceTime: true });
    server.use(
      exportJobCreateHandler,
      http.get(url('/reports/export-jobs/:id'), ({ params }) =>
        HttpResponse.json({
          data: exportJobFixture({ id: params.id as string, status: 'running' }),
        }),
      ),
    );
    const user = userEvent.setup({ delay: null });
    render(renderModal());

    await user.click(screen.getByRole('button', { name: 'Generate' }));
    await screen.findByText('Preparing your file…');

    await act(async () => {
      await vi.advanceTimersByTimeAsync(EXPORT_JOB_POLL_MAX_DURATION_MS + 1_000);
    });

    expect(
      await screen.findByText('Still preparing — check Reports › Export Jobs later.'),
    ).toBeInTheDocument();
  });
});
