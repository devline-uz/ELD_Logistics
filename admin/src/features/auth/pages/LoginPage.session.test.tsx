/**
 * Regressiya testi — D49.
 *
 * Login muvaffaqiyatli bo'lgach `GET /me` chaqirilmasa ruxsatlar bo'sh qoladi
 * va foydalanuvchi himoyalangan birinchi ekranda darhol 403 ga tushadi
 * (`BootstrapGate` faqat ilova ishga tushganda ishlaydi, login'dan keyin emas).
 */
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { afterEach, describe, expect, it } from 'vitest';

import '@/app/i18n';
import { RouteGuard } from '@/app/RouteGuard';
import { PermissionsProvider } from '@/app/providers/PermissionsProvider';
import { ToastProvider } from '@/components/feedback/ToastProvider';
import {
  VALID_PASSWORD,
  VALID_USERNAME,
  appConfigHandler,
  loginSuccessHandler,
  meHandler,
} from '@/features/auth/mocks/handlers';
import { LoginPage } from '@/features/auth/pages/LoginPage';
import { PERM } from '@/lib/permissions';
import { API_BASE_URL, server } from '@/test/msw-server';
import { useAuthStore } from '@/store/auth-store';

const companyHandler = http.get(`${API_BASE_URL}/company`, () =>
  HttpResponse.json({
    data: { id: 'company-1', name: 'Acme', unit_system: 'imperial', timezone: 'UTC' },
  }),
);

function renderApp() {
  return render(
    <PermissionsProvider>
      <ToastProvider>
        <MemoryRouter initialEntries={['/login']}>
          <Routes>
            <Route element={<LoginPage />} path="/login" />
            <Route
              element={
                <RouteGuard permission={PERM.unitsRead}>
                  <div>units list</div>
                </RouteGuard>
              }
              path="/"
            />
          </Routes>
        </MemoryRouter>
      </ToastProvider>
    </PermissionsProvider>,
  );
}

afterEach(() => {
  useAuthStore.getState().reset();
});

describe('LoginPage — session bootstrap (D49)', () => {
  it('loads the profile before navigating, so the first guarded screen is not 403', async () => {
    server.use(appConfigHandler, loginSuccessHandler, meHandler(), companyHandler);
    const user = userEvent.setup();
    renderApp();

    await user.type(screen.getByLabelText(/email or username/i), VALID_USERNAME);
    await user.type(screen.getByLabelText(/^password/i), VALID_PASSWORD);
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    await waitFor(() => {
      expect(screen.getByText('units list')).toBeInTheDocument();
    });
    expect(useAuthStore.getState().profile?.permissions).toContain(PERM.unitsRead);
  });
});
