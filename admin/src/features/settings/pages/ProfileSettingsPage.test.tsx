/**
 * `ProfileSettingsPage` — `/settings/profile` (7.13.6): loading/empty/error
 * holatlari + D40 (backend'da yangilash endpointi yo'q — faqat o'qish).
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import { afterEach, describe, expect, it } from 'vitest';

import { meErrorHandler, meHandler, profileFixture } from '@/mocks/handlers/profile';
import { server } from '@/test/msw-server';
import { useAuthStore } from '@/store/auth-store';

import { ProfileSettingsPage } from './ProfileSettingsPage';

function renderPage() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <ProfileSettingsPage />
    </QueryClientProvider>,
  );
}

afterEach(() => {
  useAuthStore.getState().reset();
});

describe('ProfileSettingsPage', () => {
  it("yuklanish holatida skeleton ko'rsatadi", () => {
    server.use(meHandler());
    renderPage();
    expect(screen.getByRole('heading', { name: /my profile/i })).toBeInTheDocument();
  });

  it("profil ma'lumotlarini ko'rsatadi va tahrirlash mavjud emasligini eslatadi (D40)", async () => {
    server.use(meHandler(profileFixture({ first_name: 'Alex', last_name: 'Smith' })));
    renderPage();

    expect(await screen.findByText('Alex Smith')).toBeInTheDocument();
    expect(screen.getByText(/editing your name, email and phone/i)).toBeInTheDocument();
  });

  it("xato bo'lsa ErrorState va Try again tugmasini ko'rsatadi", async () => {
    server.use(meErrorHandler);
    renderPage();

    expect(await screen.findByRole('alert')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /try again/i })).toBeInTheDocument();
  });
});
