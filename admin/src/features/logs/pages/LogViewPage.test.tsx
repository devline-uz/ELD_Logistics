/**
 * LogViewPage — integratsiya testi (MSW): HOS halqalari, Driver's Log tabi
 * (DutyGrid + voqealar + LOG FORM), va F100 — "Propose edit" faqat
 * `SendEditRequestPanel`ni ochadi, hech qanday to'g'ridan-to'g'ri tahrir yo'q
 * (3.6–3.9, `docs/tz/07-4-logs.md` 7.4.3).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { http, HttpResponse } from 'msw';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import { hosSummaryHandler } from '@/mocks/handlers/hos';
import { dailyLogDetailFixture, driverDailyLogsHandler } from '@/mocks/handlers/logs';
import { url } from '@/mocks/handlers/shared';
import { PERM } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { LogViewPage } from './LogViewPage';

/**
 * `mocks/handlers/logs.ts`dagi umumiy `dailyLogGetHandler`ning voqealari
 * `event_type`siz (faqat `status`) — bu yerda `duty_status` turi va
 * `locked: false` bilan qayta yozilgan, chunki "Propose edit" faqat tahrir
 * qilinadigan (qulflanmagan `duty_status`) hodisalarda ko'rinadi (Q17.1).
 */
const dailyLogGetHandlerWithEditableEvent = http.get(url('/daily-logs/:id'), ({ params }) =>
  HttpResponse.json({
    data: dailyLogDetailFixture({
      id: params.id as string,
      events: [
        {
          id: 'event-1',
          event_type: 'duty_status',
          status: 'ON',
          event_time: '2026-09-06T13:00:00Z',
          origin: 'driver',
          locked: false,
          unit_id: 'unit-1',
          unit_number: '1021',
        },
      ],
    }),
  }),
);

if (!Element.prototype.scrollIntoView) {
  Element.prototype.scrollIntoView = () => undefined;
}

function renderPage() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={[PERM.logsRead, PERM.logsProposeEdit, PERM.logsExport]}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/logs/view/daily-log-1']}>
            <Routes>
              <Route path="/logs/view/:logId" element={<LogViewPage />} />
            </Routes>
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  server.resetHandlers();
});

describe('LogViewPage', () => {
  it("renders the driver's header, HOS rings and the events table", async () => {
    server.use(dailyLogGetHandlerWithEditableEvent, hosSummaryHandler, driverDailyLogsHandler);
    renderPage();

    expect(await screen.findByRole('heading', { name: 'John Doe' })).toBeInTheDocument();
    expect(screen.getByText('BREAK')).toBeInTheDocument();
    expect(screen.getByText('DRIVE')).toBeInTheDocument();
  });

  it('opens the "Send edit request" panel instead of editing the log directly (F100)', async () => {
    server.use(dailyLogGetHandlerWithEditableEvent, hosSummaryHandler, driverDailyLogsHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByRole('heading', { name: 'John Doe' });
    await user.click(screen.getByRole('button', { name: /propose edit/i }));

    const dialog = await screen.findByRole('dialog');
    expect(dialog).toHaveTextContent(/not changed until the driver approves/i);
    expect(screen.getByRole('button', { name: /send edit request/i })).toBeInTheDocument();
  });
});
