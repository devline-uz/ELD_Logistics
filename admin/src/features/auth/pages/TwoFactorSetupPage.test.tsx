import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';
import {
  meHandler,
  totpSetupHandler,
  totpVerifyInvalidHandler,
  totpVerifySuccessHandler,
} from '@/features/auth/mocks/handlers';
import { TwoFactorSetupPage } from '@/features/auth/pages/TwoFactorSetupPage';
import { server } from '@/test/msw-server';
import { useAuthStore } from '@/store/auth-store';

function renderSetup() {
  return render(
    <MemoryRouter initialEntries={['/2fa/setup']}>
      <Routes>
        <Route element={<TwoFactorSetupPage />} path="/2fa/setup" />
        <Route element={<div>dashboard</div>} path="/" />
      </Routes>
    </MemoryRouter>,
  );
}

afterEach(() => {
  useAuthStore.getState().reset();
});

describe('TwoFactorSetupPage', () => {
  it('loads the QR code / secret and completes enrolment with a valid code', async () => {
    server.use(totpSetupHandler, totpVerifySuccessHandler, meHandler());
    const user = userEvent.setup();
    renderSetup();

    expect(await screen.findByAltText(/qr code/i)).toBeInTheDocument();
    expect(screen.getByText('JBSWY3DPEHPK3PXP')).toBeInTheDocument();

    await user.type(screen.getByLabelText(/6-digit code/i), '123456');
    await user.click(screen.getByRole('button', { name: /verify and continue/i }));

    await waitFor(() => {
      expect(screen.getByText('dashboard')).toBeInTheDocument();
    });
    expect(useAuthStore.getState().accessToken).toBe('access-token-1');
    expect(useAuthStore.getState().limited).toBe(false);
  });

  it('shows an error for an invalid code and stays on the enrolment screen', async () => {
    server.use(totpSetupHandler, totpVerifyInvalidHandler);
    const user = userEvent.setup();
    renderSetup();

    await screen.findByAltText(/qr code/i);
    await user.type(screen.getByLabelText(/6-digit code/i), '000000');
    await user.click(screen.getByRole('button', { name: /verify and continue/i }));

    expect(await screen.findByRole('alert')).toHaveTextContent(/not valid/i);
  });
});
