/**
 * Settings › Profile & Security query hooklari — integratsiya testi (MSW,
 * fe-testing §MSW).
 */
import { renderHook, waitFor } from '@testing-library/react';
import { afterEach, describe, expect, it } from 'vitest';

import {
  meErrorHandler,
  meHandler,
  passwordForgotHandler,
  profileFixture,
  sessionFixture,
  sessionRevokeHandler,
  sessionsListHandler,
  totpSetupHandler,
  totpVerifyInvalidHandler,
  totpVerifySuccessHandler,
} from '@/mocks/handlers/profile';
import { server } from '@/test/msw-server';
import { useAuthStore } from '@/store/auth-store';

import {
  useMyProfile,
  useMySessions,
  useRequestPasswordResetEmail,
  useRevokeSession,
  useTotpSetupStart,
  useTotpVerifyEnable,
} from './profile';
import { withQueryClient } from './test-utils';

afterEach(() => {
  useAuthStore.getState().reset();
});

describe('useMyProfile', () => {
  it('GET /me natijasini qaytaradi va auth store-ga yozadi', async () => {
    server.use(meHandler(profileFixture({ first_name: 'Alex' })));
    const { result } = renderHook(() => useMyProfile(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.first_name).toBe('Alex');
    expect(useAuthStore.getState().profile?.first_name).toBe('Alex');
  });

  it('xato javobda ApiError bilan tugaydi', async () => {
    server.use(meErrorHandler);
    const { result } = renderHook(() => useMyProfile(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(500);
  });
});

describe('useMySessions / useRevokeSession', () => {
  it("sessiyalar ro'yxatini qaytaradi", async () => {
    server.use(sessionsListHandler());
    const { result } = renderHook(() => useMySessions(), { wrapper: withQueryClient() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toHaveLength(2);
  });

  it('sessiyani tugatadi', async () => {
    server.use(sessionRevokeHandler);
    const { result } = renderHook(() => useRevokeSession(), { wrapper: withQueryClient() });

    result.current.mutate(sessionFixture().id ?? '');
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
  });
});

describe('useTotpSetupStart / useTotpVerifyEnable', () => {
  it('QR/secret oladi va kodni tasdiqlab yoqadi', async () => {
    server.use(totpSetupHandler, totpVerifySuccessHandler);
    const setup = renderHook(() => useTotpSetupStart(), { wrapper: withQueryClient() });
    setup.result.current.mutate();
    await waitFor(() => expect(setup.result.current.isSuccess).toBe(true));
    expect(setup.result.current.data?.secret).toBe('JBSWY3DPEHPK3PXP');

    const verify = renderHook(() => useTotpVerifyEnable(), { wrapper: withQueryClient() });
    verify.result.current.mutate({ code: '123456' });
    await waitFor(() => expect(verify.result.current.isSuccess).toBe(true));
    expect(verify.result.current.data?.enabled).toBe(true);
  });

  it("422 noto'g'ri kodda ApiError bilan tugaydi", async () => {
    server.use(totpVerifyInvalidHandler);
    const { result } = renderHook(() => useTotpVerifyEnable(), { wrapper: withQueryClient() });

    result.current.mutate({ code: '000000' });
    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.status).toBe(422);
  });
});

describe('useRequestPasswordResetEmail', () => {
  it('POST /auth/password/forgot ni chaqiradi', async () => {
    server.use(passwordForgotHandler);
    const { result } = renderHook(() => useRequestPasswordResetEmail(), {
      wrapper: withQueryClient(),
    });

    result.current.mutate({ login: 'jdoe' });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
  });
});
