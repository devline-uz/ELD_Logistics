/**
 * DvirDetailPage — integratsiya testi (MSW):
 * - nuqsonlar + fotolar (lightbox) va imzolar **faqat ko'rish** (F107)
 * - `Record repair` tasdiq dialogi bilan; **D30** — imzo mobil ilovadan,
 *   kalitsiz hisobotda tugma `disabled`
 * - `Certify` admin panelda **yo'q** — haydovchi endpointi (kutish matni)
 * - repair 409 `DVIR_INVALID_TRANSITION` xatosini tushunarli ko'rsatadi
 * - `Download PDF` blob URL'ini `revokeObjectURL` bilan tozalaydi (5.5)
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  dvirGetHandler,
  dvirGetWithMechanicSignatureHandler,
  dvirPdfHandler,
  dvirRepairConflictHandler,
  dvirRepairHandler,
} from '@/mocks/handlers/dvir';
import { PERM, type Permission } from '@/lib/permissions';
import { server } from '@/test/msw-server';

import { DvirDetailPage } from './DvirDetailPage';

const ALL_PERMISSIONS: Permission[] = [PERM.dvirRead, PERM.dvirRepair, PERM.dvirExport];

function renderPage(permissions: readonly Permission[] = ALL_PERMISSIONS) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <PermissionsProvider permissions={permissions}>
        <ToastProvider>
          <MemoryRouter initialEntries={['/dvir/dvir-1']}>
            <Routes>
              <Route path="/dvir/:dvirId" element={<DvirDetailPage />} />
            </Routes>
          </MemoryRouter>
        </ToastProvider>
      </PermissionsProvider>
    </QueryClientProvider>,
  );
}

beforeEach(() => {
  if (!URL.createObjectURL) {
    Object.defineProperty(URL, 'createObjectURL', { writable: true, value: () => 'blob:mock' });
  }
  if (!URL.revokeObjectURL) {
    Object.defineProperty(URL, 'revokeObjectURL', { writable: true, value: () => undefined });
  }
});

afterEach(() => {
  server.resetHandlers();
  vi.restoreAllMocks();
});

describe('DvirDetailPage', () => {
  it('shows defects, photos and read-only signatures (F107)', async () => {
    server.use(dvirGetHandler);
    renderPage();

    expect(await screen.findByRole('heading', { name: '1021' })).toBeInTheDocument();
    expect(screen.getByText('Tires')).toBeInTheDocument();
    expect(screen.getByText(/signatures are captured in the driver app/i)).toBeInTheDocument();
    // Imzo qo'yish/yuklash imkoniyati umuman yo'q.
    expect(screen.queryByRole('button', { name: /sign|paste/i })).not.toBeInTheDocument();
  });

  it('opens the photo lightbox', async () => {
    server.use(dvirGetHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByText('Tires');
    await user.click(screen.getByRole('button', { name: /open photo 1 of tires/i }));

    expect(await screen.findByRole('dialog', { name: /photo/i })).toBeInTheDocument();
  });

  it('disables Record repair while the report has no mechanic signature (D30)', async () => {
    const { dvirReportFixture } = await import('@/mocks/handlers/dvir');
    const { http, HttpResponse } = await import('msw');
    const { url } = await import('@/mocks/handlers/shared');
    server.use(
      http.get(url('/dvir-reports/:id'), () =>
        HttpResponse.json({
          data: dvirReportFixture({ mechanic_signature_key: undefined }),
        }),
      ),
    );
    renderPage();

    const button = await screen.findByRole('button', { name: /record repair/i });
    expect(button).toBeDisabled();
    expect(button).toHaveAttribute('title', expect.stringMatching(/captured in the driver app/i));
    // Admin panelda imzo yuklash imkoniyati umuman yo'q.
    expect(document.querySelectorAll('input[type="file"]')).toHaveLength(0);
  });

  it('records a repair, reusing the signature captured in the driver app (D30)', async () => {
    server.use(dvirGetWithMechanicSignatureHandler, dvirRepairHandler);
    const user = userEvent.setup();
    renderPage();

    await user.click(await screen.findByRole('button', { name: /record repair/i }));

    const modal = await screen.findByRole('dialog', { name: /record repair/i });
    await user.type(within(modal).getByLabelText(/mechanic note/i), 'Replaced left front tyre');
    await user.click(within(modal).getByRole('button', { name: /^record repair$/i }));

    const confirm = await screen.findByRole('alertdialog');
    await user.click(within(confirm).getByRole('button', { name: /^confirm$/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/repair recorded/i);
  });

  it('explains a 409 DVIR_INVALID_TRANSITION returned by repair', async () => {
    server.use(dvirGetWithMechanicSignatureHandler, dvirRepairConflictHandler);
    const user = userEvent.setup();
    renderPage();

    await user.click(await screen.findByRole('button', { name: /record repair/i }));
    const modal = await screen.findByRole('dialog', { name: /record repair/i });
    await user.type(within(modal).getByLabelText(/mechanic note/i), 'Replaced left front tyre');
    await user.click(within(modal).getByRole('button', { name: /^record repair$/i }));

    const confirm = await screen.findByRole('alertdialog');
    await user.click(within(confirm).getByRole('button', { name: /^confirm$/i }));

    expect(await screen.findByText(/no longer in a state/i)).toBeInTheDocument();
  });

  it('never offers Certify — the driver certifies in the app', async () => {
    const { dvirReportFixture } = await import('@/mocks/handlers/dvir');
    const { http, HttpResponse } = await import('msw');
    const { url } = await import('@/mocks/handlers/shared');
    server.use(
      http.get(url('/dvir-reports/:id'), () =>
        HttpResponse.json({ data: dvirReportFixture({ status: 'repaired' }) }),
      ),
    );
    renderPage();

    await screen.findByText('Tires');
    expect(screen.queryByRole('button', { name: /certify/i })).not.toBeInTheDocument();
    expect(screen.getByText(/awaiting driver certification/i)).toBeInTheDocument();
  });

  it('hides Record repair when the status does not allow the transition (F106)', async () => {
    const { dvirReportFixture } = await import('@/mocks/handlers/dvir');
    const { http, HttpResponse } = await import('msw');
    const { url } = await import('@/mocks/handlers/shared');
    server.use(
      http.get(url('/dvir-reports/:id'), () =>
        HttpResponse.json({ data: dvirReportFixture({ status: 'certified' }) }),
      ),
    );
    renderPage();

    await screen.findByText('Tires');
    expect(screen.queryByRole('button', { name: /record repair/i })).not.toBeInTheDocument();
  });

  it('revokes the blob URL after the PDF download (no leak)', async () => {
    server.use(dvirGetHandler, dvirPdfHandler);
    // jsdom `<a download>` bosilishini haqiqiy navigatsiyaga urinmasligi
    // uchun to'xtatamiz (konsol shovqini yo'q).
    vi.spyOn(HTMLAnchorElement.prototype, 'click').mockImplementation(() => undefined);
    const createSpy = vi.spyOn(URL, 'createObjectURL').mockReturnValue('blob:dvir');
    const revokeSpy = vi.spyOn(URL, 'revokeObjectURL').mockImplementation(() => undefined);
    const user = userEvent.setup();
    renderPage();

    await user.click(await screen.findByRole('button', { name: /download pdf/i }));

    expect(await screen.findByRole('status')).toHaveTextContent(/downloaded/i);
    expect(createSpy).toHaveBeenCalledTimes(1);
    expect(revokeSpy).toHaveBeenCalledWith('blob:dvir');
  });

  it('hides the write actions without the matching permissions', async () => {
    const { dvirReportFixture } = await import('@/mocks/handlers/dvir');
    const { http, HttpResponse } = await import('msw');
    const { url } = await import('@/mocks/handlers/shared');
    server.use(
      http.get(url('/dvir-reports/:id'), () =>
        HttpResponse.json({ data: dvirReportFixture({ status: 'repaired' }) }),
      ),
    );
    renderPage([PERM.dvirRead]);

    await screen.findByText('Tires');
    expect(screen.queryByRole('button', { name: /record repair/i })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /download pdf/i })).not.toBeInTheDocument();
  });
});
