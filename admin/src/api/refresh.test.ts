/**
 * Refresh mutex + reuse detection testlari (0.13, fe-api §4).
 */
import { http, HttpResponse } from 'msw';
import { afterEach, describe, expect, it, vi } from 'vitest';

import { getAccessToken, hasStoredRefreshToken } from '@/api/session';
import { applyTokens, refreshTokens, resetRefreshState } from '@/api/refresh';
import { API_BASE_URL, server } from '@/test/msw-server';
import { useAuthStore } from '@/store/auth-store';
import { tokensFixture } from '@/features/auth/mocks/handlers';

const url = (path: string) => `${API_BASE_URL}${path}`;

afterEach(() => {
  useAuthStore.getState().reset();
  resetRefreshState();
  sessionStorage.clear();
});

describe('refreshTokens mutex', () => {
  it('sends exactly one network request for concurrent 401s', async () => {
    let callCount = 0;
    server.use(
      http.post(url('/auth/refresh'), () => {
        callCount += 1;
        return HttpResponse.json({ data: tokensFixture({ access_token: 'refreshed-token' }) });
      }),
    );

    applyTokens(tokensFixture({ access_token: 'old-token' }));
    expect(hasStoredRefreshToken()).toBe(true);

    const [first, second, third] = await Promise.all([
      refreshTokens(),
      refreshTokens(),
      refreshTokens(),
    ]);

    expect(callCount).toBe(1);
    expect(first).toEqual({ ok: true, accessToken: 'refreshed-token' });
    expect(second).toEqual(first);
    expect(third).toEqual(first);
    expect(getAccessToken()).toBe('refreshed-token');
  });

  it('allows a new network request once the in-flight refresh settles', async () => {
    let callCount = 0;
    server.use(
      http.post(url('/auth/refresh'), () => {
        callCount += 1;
        return HttpResponse.json({
          data: tokensFixture({ access_token: `token-${callCount}` }),
        });
      }),
    );

    applyTokens(tokensFixture());
    await refreshTokens();
    await refreshTokens();

    expect(callCount).toBe(2);
  });
});

describe('refreshTokens reuse detection', () => {
  it('performs a full local logout on 401 (token reuse / revoked session)', async () => {
    server.use(
      http.post(url('/auth/refresh'), () =>
        HttpResponse.json(
          { error: { code: 'REFRESH_REUSED', message: 'reused' } },
          { status: 401 },
        ),
      ),
    );

    applyTokens(tokensFixture());
    expect(hasStoredRefreshToken()).toBe(true);

    const outcome = await refreshTokens();

    expect(outcome).toEqual({ ok: false, reason: 'revoked' });
    expect(getAccessToken()).toBeNull();
    expect(hasStoredRefreshToken()).toBe(false);
    expect(useAuthStore.getState().endReason).toBe('session_expired');
  });

  it('does not clear the session on a transient (network/5xx) failure', async () => {
    server.use(http.post(url('/auth/refresh'), () => HttpResponse.error()));

    applyTokens(tokensFixture());
    const outcome = await refreshTokens();

    expect(outcome).toEqual({ ok: false, reason: 'transient' });
    // Access token stays as-is; sessiya bekor qilinmagan (F: faqat reuse/401 to'liq logout qiladi).
    expect(hasStoredRefreshToken()).toBe(true);
  });

  it('never re-attempts a refresh call from within the refresh flow itself (no 401 loop)', async () => {
    const refreshSpy = vi.fn(() =>
      HttpResponse.json({ error: { code: 'UNAUTHORIZED', message: 'no' } }, { status: 401 }),
    );
    server.use(http.post(url('/auth/refresh'), refreshSpy));

    applyTokens(tokensFixture());
    await refreshTokens();

    expect(refreshSpy).toHaveBeenCalledTimes(1);
  });
});
