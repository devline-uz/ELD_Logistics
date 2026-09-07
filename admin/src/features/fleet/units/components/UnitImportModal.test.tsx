/**
 * UnitImportModal — integratsiya testi (2.3, F83 all-or-nothing).
 * `POST /units/import` 422 javobi `ApiError.payload`ga saqlanadi
 * (`client.ts` fe-architect tuzatishi) — bu yerda qator xatolari jadvali
 * o'sha ma'lumotdan chizilishi tekshiriladi.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import type { ReactElement } from 'react';
import { afterEach, describe, expect, it, vi } from 'vitest';

import '@/app/i18n';

import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  unitsImportHandler,
  unitsImportTemplateHandler,
  unitsImportValidationErrorHandler,
} from '@/mocks/handlers/units';
import { server } from '@/test/msw-server';

import { UnitImportModal } from './UnitImportModal';

function renderModal(onClose: () => void = vi.fn()) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  function Wrapper(): ReactElement {
    return (
      <QueryClientProvider client={queryClient}>
        <ToastProvider>
          <UnitImportModal open onClose={onClose} />
        </ToastProvider>
      </QueryClientProvider>
    );
  }
  return render(<Wrapper />);
}

afterEach(() => {
  server.resetHandlers();
});

function makeCsvFile(name = 'units.csv'): File {
  return new File(['unit_number,make,model\n101,Volvo,VNL'], name, { type: 'text/csv' });
}

describe('UnitImportModal', () => {
  it('uploads a file and shows a success summary when everything imports', async () => {
    server.use(unitsImportTemplateHandler, unitsImportHandler);
    const user = userEvent.setup();
    renderModal();

    const input = document.getElementById('unit-import-file') as HTMLInputElement;
    await user.upload(input, makeCsvFile());
    await user.click(screen.getByRole('button', { name: /^upload$/i }));

    expect(await screen.findByText(/imported 3 of 3 rows/i)).toBeInTheDocument();
  });

  it('renders the row-error table and the all-or-nothing message on 422', async () => {
    server.use(unitsImportTemplateHandler, unitsImportValidationErrorHandler);
    const user = userEvent.setup();
    renderModal();

    const input = document.getElementById('unit-import-file') as HTMLInputElement;
    await user.upload(input, makeCsvFile());
    await user.click(screen.getByRole('button', { name: /^upload$/i }));

    expect(await screen.findByText(/nothing was imported\. fix 2 errors/i)).toBeInTheDocument();
    expect(screen.getByText('unit_number')).toBeInTheDocument();
    expect(screen.getByText('vin')).toBeInTheDocument();
    expect(screen.getByText('required')).toBeInTheDocument();
  });

  it('downloads the CSV template', async () => {
    server.use(unitsImportTemplateHandler);
    const user = userEvent.setup();
    renderModal();

    await user.click(screen.getByRole('button', { name: /download csv/i }));

    await waitFor(() =>
      expect(screen.getByRole('button', { name: /download csv/i })).toBeEnabled(),
    );
  });
});
