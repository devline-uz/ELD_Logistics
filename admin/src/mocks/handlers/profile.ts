/**
 * Settings › Profile & Security — MSW handler'lari (Bosqich 8.6, fe-testing §MSW).
 */
import { http, HttpResponse } from 'msw';

import type { Profile, SessionInfo, TotpSetup, TotpVerified } from '@/api/types';

import { jsonError, url } from './shared';

export function profileFixture(overrides: Partial<Profile> = {}): Profile {
  return {
    id: 'user-1',
    company_id: 'company-1',
    username: 'jdoe',
    first_name: 'Jane',
    last_name: 'Doe',
    email: 'jane.doe@example.com',
    role_id: 'role-1',
    role_name: 'Fleet Manager',
    scope: 'company',
    status: 'active',
    totp_enabled: false,
    permissions: ['units.read'],
    is_super_admin: false,
    ...overrides,
  };
}

export function sessionFixture(overrides: Partial<SessionInfo> = {}): SessionInfo {
  return {
    id: 'session-1',
    device_type: 'web',
    user_agent: 'Mozilla/5.0 (Macintosh)',
    ip: '203.0.113.0',
    app_version: '1.4.2',
    created_at: '2026-09-01T05:12:00Z',
    last_seen_at: '2026-09-06T07:40:00Z',
    expires_at: '2026-10-06T05:12:00Z',
    current: true,
    status: 'active',
    ...overrides,
  };
}

export const meHandler = (profile: Profile = profileFixture()) =>
  http.get(url('/me'), () => HttpResponse.json({ data: profile }));

export const meErrorHandler = http.get(url('/me'), () => jsonError('INTERNAL', 'boom', 500));

export const sessionsListHandler = (
  sessions: SessionInfo[] = [
    sessionFixture(),
    sessionFixture({ id: 'session-2', current: false, device_type: 'phone', ip: '198.51.100.4' }),
  ],
) => http.get(url('/auth/sessions'), () => HttpResponse.json({ data: sessions }));

export const sessionsListEmptyHandler = http.get(url('/auth/sessions'), () =>
  HttpResponse.json({ data: [] }),
);

export const sessionsListErrorHandler = http.get(url('/auth/sessions'), () =>
  jsonError('INTERNAL', 'boom', 500),
);

export const sessionRevokeHandler = http.delete(
  url('/auth/sessions/:id'),
  () => new HttpResponse(null, { status: 204 }),
);

export const sessionRevokeNotFoundHandler = http.delete(url('/auth/sessions/:id'), () =>
  jsonError('NOT_FOUND', 'Not found', 404),
);

export const totpSetupHandler = http.post(url('/auth/2fa/setup'), () =>
  HttpResponse.json({
    data: {
      issuer: 'ONEBOOK ELD',
      otpauth_url: 'otpauth://totp/ONEBOOK%20ELD:jdoe?secret=JBSWY3DPEHPK3PXP&issuer=ONEBOOK%20ELD',
      secret: 'JBSWY3DPEHPK3PXP',
      digits: 6,
      period: 30,
    } satisfies TotpSetup,
  }),
);

export const totpVerifySuccessHandler = http.post(url('/auth/2fa/verify'), () =>
  HttpResponse.json({
    data: { enabled: true, recovery_codes: ['abc123', 'def456'] } satisfies TotpVerified,
  }),
);

export const totpVerifyInvalidHandler = http.post(url('/auth/2fa/verify'), () =>
  jsonError('VALIDATION_ERROR', 'Invalid code', 422),
);

export const passwordForgotHandler = http.post(url('/auth/password/forgot'), () =>
  HttpResponse.json({ data: { message: 'Accepted' } }, { status: 202 }),
);
