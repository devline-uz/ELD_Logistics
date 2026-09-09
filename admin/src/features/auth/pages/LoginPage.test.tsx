import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  VALID_PASSWORD,
  VALID_USERNAME,
  appConfigHandler,
  loginInvalidCredentialsHandler,
  loginRateLimitedHandler,
  loginRequiresTotpSetupHandler,
  loginSuccessHandler,
  meHandler,
} from '@/features/auth/mocks/handlers';
import { LoginPage } from '@/features/auth/pages/LoginPage';
import { server } from '@/test/msw-server';
import { useAuthStore } from '@/store/auth-store';

function renderLogin(initialPath = '/login') {
  return render(
    <ToastProvider>
      <MemoryRouter initialEntries={[initialPath]}>
        <Routes>
          <Route element={<LoginPage />} path="/login" />
          <Route element={<div>2fa setup screen</div>} path="/2fa/setup" />
          <Route element={<div>2fa verify screen</div>} path="/2fa/verify" />
          <Route element={<div>dashboard</div>} path="/" />
        </Routes>
      </MemoryRouter>
    </ToastProvider>,
  );
}

afterEach(() => {
  useAuthStore.getState().reset();
});

describe('LoginPage', () => {
  it('signs in with valid credentials and stores the access token in memory only', async () => {
    server.use(appConfigHandler, loginSuccessHandler, meHandler());
    const user = userEvent.setup();
    renderLogin();

    await user.type(screen.getByLabelText(/email or username/i), VALID_USERNAME);
    await user.type(screen.getByLabelText(/^password/i), VALID_PASSWORD);
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    await waitFor(() => {
      expect(screen.getByText('dashboard')).toBeInTheDocument();
    });

    expect(useAuthStore.getState().accessToken).toBe('access-token-1');
    expect(localStorage.getItem('eld.rt')).toBeNull();
    expect(sessionStorage.getItem('eld.rt')).toBe('refresh-token-1');
  });

  it('shows a single, field-agnostic error for invalid credentials', async () => {
    server.use(appConfigHandler, loginInvalidCredentialsHandler);
    const user = userEvent.setup();
    renderLogin();

    await user.type(screen.getByLabelText(/email or username/i), 'nobody');
    await user.type(screen.getByLabelText(/^password/i), 'wrong-password');
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    expect(await screen.findByRole('alert')).toHaveTextContent(
      /email\/username or password is incorrect/i,
    );
  });

  it('shows a retry countdown on 429 rate limiting', async () => {
    server.use(appConfigHandler, loginRateLimitedHandler);
    const user = userEvent.setup();
    renderLogin();

    await user.type(screen.getByLabelText(/email or username/i), VALID_USERNAME);
    await user.type(screen.getByLabelText(/^password/i), VALID_PASSWORD);
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    expect(await screen.findByRole('alert')).toHaveTextContent(/too many sign-in attempts/i);
    expect(await screen.findByRole('button', { name: /try again in 30s/i })).toBeDisabled();
  });

  it('routes to /2fa/setup when the account requires TOTP enrolment', async () => {
    server.use(appConfigHandler, loginRequiresTotpSetupHandler);
    const user = userEvent.setup();
    renderLogin();

    await user.type(screen.getByLabelText(/email or username/i), VALID_USERNAME);
    await user.type(screen.getByLabelText(/^password/i), VALID_PASSWORD);
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    await waitFor(() => {
      expect(screen.getByText('2fa setup screen')).toBeInTheDocument();
    });
    expect(useAuthStore.getState().limited).toBe(true);
  });
});
