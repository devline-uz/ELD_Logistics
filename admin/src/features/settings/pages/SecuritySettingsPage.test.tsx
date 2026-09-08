/**
 * `SecuritySettingsPage` — `/settings/security` (7.13.7): parol almashtirish
 * (joriy parol majburiy, F151/D41), 2FA yoqish oqimi, faol sessiyalar +
 * revoke tasdig'i (joriy sessiyani revoke qilish = logout).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  meHandler,
  passwordForgotHandler,
  profileFixture,
  sessionFixture,
  sessionRevokeHandler,
  sessionsListHandler,
  totpSetupHandler,
  totpVerifySuccessHandler,
} from '@/mocks/handlers/profile';
import { server } from '@/test/msw-server';
import { useAuthStore } from '@/store/auth-store';

import { SecuritySettingsPage } from './SecuritySettingsPage';

function renderPage() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <ToastProvider>
        <MemoryRouter initialEntries={['/settings/security']}>
          <Routes>
            <Route element={<SecuritySettingsPage />} path="/settings/security" />
            <Route element={<div>login screen</div>} path="/login" />
          </Routes>
        </MemoryRouter>
      </ToastProvider>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  useAuthStore.getState().reset();
});

describe('SecuritySettingsPage', () => {
  it("parolni joriy parolsiz o'zgartirishga urinishda validatsiya xatosi ko'rsatadi (F151/D41)", async () => {
    server.use(meHandler(profileFixture()), sessionsListHandler());
    const user = userEvent.setup();
    renderPage();

    await screen.findByRole('heading', { name: /change password/i });
    await user.type(screen.getByLabelText(/^new password/i), 'Str0ngPassphrase');
    await user.type(screen.getByLabelText(/confirm new password/i), 'Str0ngPassphrase');
    await user.click(screen.getByRole('button', { name: /send password reset email/i }));

    expect(await screen.findByText(/enter your current password/i)).toBeInTheDocument();
  });

  it("barcha maydonlar to'g'ri bo'lsa parol tiklash emailini yuboradi", async () => {
    server.use(
      meHandler(profileFixture({ username: 'jdoe' })),
      sessionsListHandler(),
      passwordForgotHandler,
    );
    const user = userEvent.setup();
    renderPage();

    await screen.findByRole('heading', { name: /change password/i });
    await user.type(screen.getByLabelText(/^current password/i), 'OldPassw0rd');
    await user.type(screen.getByLabelText(/^new password/i), 'Str0ngPassphrase');
    await user.type(screen.getByLabelText(/confirm new password/i), 'Str0ngPassphrase');
    await user.click(screen.getByRole('button', { name: /send password reset email/i }));

    expect(await screen.findByText(/reset link sent/i)).toBeInTheDocument();
  });

  it("2FA yoqish: QR ko'rsatiladi va kod tasdiqlangach yoqilgani bildiriladi", async () => {
    server.use(
      meHandler(profileFixture({ totp_enabled: false })),
      sessionsListHandler(),
      totpSetupHandler,
      totpVerifySuccessHandler,
    );
    const user = userEvent.setup();
    renderPage();

    await user.click(await screen.findByRole('button', { name: /enable two-factor/i }));
    expect(await screen.findByAltText(/qr code/i)).toBeInTheDocument();

    await user.type(screen.getByLabelText(/6-digit code/i), '123456');
    await user.click(screen.getByRole('button', { name: /verify and enable/i }));

    expect(await screen.findByText(/two-factor authentication is enabled/i)).toBeInTheDocument();
  });

  it("yoqilgan 2FA uchun o'chirish mavjud emasligini ko'rsatadi (D42)", async () => {
    server.use(meHandler(profileFixture({ totp_enabled: true })), sessionsListHandler());
    renderPage();

    expect(await screen.findByText(/disabling two-factor authentication/i)).toBeInTheDocument();
  });

  it('boshqa sessiyani revoke qiladi (tasdiqlash bilan)', async () => {
    server.use(meHandler(profileFixture()), sessionsListHandler(), sessionRevokeHandler);
    const user = userEvent.setup();
    renderPage();

    await screen.findByRole('heading', { name: /active sessions/i });
    const revokeButtons = await screen.findAllByRole('button', { name: /^revoke$/i });
    await user.click(revokeButtons[1]!);

    await user.click(screen.getByRole('button', { name: /^confirm$/i }));

    await waitFor(() => {
      expect(screen.queryByText(/are you absolutely sure/i)).not.toBeInTheDocument();
    });
  });

  it('joriy sessiyani revoke qilish tasdiqdan keyin login ekraniga chiqaradi', async () => {
    server.use(
      meHandler(profileFixture()),
      sessionsListHandler([sessionFixture()]),
      sessionRevokeHandler,
    );
    const user = userEvent.setup();
    renderPage();

    await screen.findByRole('heading', { name: /active sessions/i });
    await user.click(await screen.findByRole('button', { name: /^revoke$/i }));
    expect(screen.getByText(/revoking it will sign you out/i)).toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: /^confirm$/i }));

    await waitFor(() => {
      expect(screen.getByText('login screen')).toBeInTheDocument();
    });
  });
});
