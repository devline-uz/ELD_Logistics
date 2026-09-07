/**
 * Bootstrap testlari (0.14/0.15): `GET /me` ruxsatlari auth store'ga tushishi,
 * `GET /company` konteksti, va sessiyasiz/401 holatlarida ilova yiqilmasligi.
 */
import { http, HttpResponse } from 'msw';
import { afterEach, describe, expect, it } from 'vitest';

import { runBootstrap } from '@/app/bootstrap';
import { applyTokens } from '@/api/refresh';
import { API_BASE_URL, server } from '@/test/msw-server';
import {
  appConfigHandler,
  meHandler,
  meUnauthorizedHandler,
  profileFixture,
  tokensFixture,
} from '@/features/auth/mocks/handlers';
import { useAuthStore, selectPermissions } from '@/store/auth-store';
import { useCompanyStore } from '@/store/company-store';

const url = (path: string) => `${API_BASE_URL}${path}`;

afterEach(() => {
  useAuthStore.getState().reset();
  useCompanyStore.getState().resetCompany();
  sessionStorage.clear();
});

describe('runBootstrap', () => {
  it('leaves the app anonymous (not an error) when there is no stored session', async () => {
    server.use(appConfigHandler);

    const result = await runBootstrap();

    expect(result).toEqual({ authenticated: false, limited: false });
  });

  it('restores the session and stores /me permissions in the auth store', async () => {
    const profile = profileFixture({ permissions: ['units.read', 'drivers.read'] });
    server.use(
      appConfigHandler,
      http.post(url('/auth/refresh'), () => HttpResponse.json({ data: tokensFixture() })),
      meHandler(profile),
      http.get(url('/company'), () =>
        HttpResponse.json({
          data: { id: 'company-1', region: 'US', unit_system: 'imperial', timezone: 'UTC' },
        }),
      ),
    );
    applyTokens(tokensFixture());
    // Sahifa yangilanganda access token xotiradan yo'qoladi — faqat refresh
    // token qoladi; bootstrap shundan tiklaydi.
    useAuthStore.setState({ accessToken: null, accessTokenExpiresAt: null });

    const result = await runBootstrap();

    expect(result.authenticated).toBe(true);
    expect(selectPermissions(useAuthStore.getState())).toEqual(['units.read', 'drivers.read']);
  });

  it('treats a 401 from /me as anonymous, not a bootstrap failure', async () => {
    server.use(
      appConfigHandler,
      http.post(url('/auth/refresh'), () => HttpResponse.json({ data: tokensFixture() })),
      meUnauthorizedHandler,
    );
    applyTokens(tokensFixture());
    useAuthStore.setState({ accessToken: null, accessTokenExpiresAt: null });

    const result = await runBootstrap();

    expect(result).toEqual({ authenticated: false, limited: false });
  });

  it('throws when /app/config fails, so the caller can show a full-screen error', async () => {
    server.use(http.get(url('/app/config'), () => HttpResponse.json({}, { status: 500 })));

    await expect(runBootstrap()).rejects.toThrow();
  });
});
