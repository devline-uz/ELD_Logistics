/**
 * Auth modul uchun MSW handler'lari (fe-testing §MSW, F213).
 *
 * Shakl `src/api/schema.d.ts` bilan mos (`LoginResult`, `Tokens`, `TOTPSetup`,
 * `TOTPVerified`, `ErrorBody`) — tip xatosi orqali spec'dan chetga chiqish
 * darhol ko'rinadi.
 */
import { http, HttpResponse } from 'msw';

import { API_BASE_URL } from '@/test/msw-server';
import type {
  ErrorResponse,
  ItemResponse,
  LoginResult,
  Profile,
  TotpSetup,
  TotpVerified,
  Tokens,
} from '@/api/types';

const url = (path: string) => `${API_BASE_URL}${path}`;

export const VALID_PASSWORD = 'Str0ngPassphrase';
export const VALID_USERNAME = 'jdoe';

export function tokensFixture(overrides: Partial<Tokens> = {}): Tokens {
  return {
    access_token: 'access-token-1',
    expires_in: 900,
    refresh_token: 'refresh-token-1',
    refresh_expires_at: '2026-10-06T05:12:00Z',
    token_type: 'Bearer',
    ...overrides,
  };
}

export function loginResultFixture(overrides: Partial<LoginResult> = {}): LoginResult {
  return {
    ...tokensFixture(),
    session_id: 'session-1',
    requires_totp_setup: false,
    replaced_session: false,
    subscription_readonly: false,
    ...overrides,
  };
}

export function profileFixture(overrides: Partial<Profile> = {}): Profile {
  return {
    id: 'user-1',
    company_id: 'company-1',
    username: VALID_USERNAME,
    first_name: 'Jane',
    last_name: 'Doe',
    permissions: ['units.read', 'company.read'],
    is_super_admin: false,
    ...overrides,
  };
}

function errorEnvelope(
  code: string,
  message: string,
  details?: Array<{ field: string; message: string }>,
): ErrorResponse {
  return { error: { code, message, details } };
}

/** `GET /app/config` — barcha testlarda kerak (bootstrap universal). */
export const appConfigHandler = http.get(url('/app/config'), () =>
  HttpResponse.json({
    data: {
      server_time: new Date().toISOString(),
      feature_flags: {},
      access_token_ttl_seconds: 900,
      support_email: 'support@example.com',
    },
  }),
);

/** Muvaffaqiyatli login (2FA yo'q, cheklanmagan). */
export const loginSuccessHandler = http.post(url('/auth/login'), async ({ request }) => {
  const body = (await request.json()) as { username?: string; password?: string };

  if (body.username !== VALID_USERNAME || body.password !== VALID_PASSWORD) {
    return HttpResponse.json(errorEnvelope('UNAUTHORIZED', 'Invalid credentials'), {
      status: 401,
    });
  }

  const result: ItemResponse<LoginResult> = { data: loginResultFixture() };
  return HttpResponse.json(result);
});

/** `401` — har doim noto'g'ri parol. */
export const loginInvalidCredentialsHandler = http.post(url('/auth/login'), () =>
  HttpResponse.json(errorEnvelope('UNAUTHORIZED', 'Invalid credentials'), { status: 401 }),
);

/** `429` — login rate limit (5/min/IP, fe-api §1). */
export const loginRateLimitedHandler = http.post(url('/auth/login'), () =>
  HttpResponse.json(errorEnvelope('RATE_LIMITED', 'Too many requests'), {
    status: 429,
    headers: { 'Retry-After': '30' },
  }),
);

/** Login `requires_totp_setup: true` bilan javob beradi — cheklangan sessiya. */
export const loginRequiresTotpSetupHandler = http.post(url('/auth/login'), () =>
  HttpResponse.json({
    data: loginResultFixture({
      requires_totp_setup: true,
      refresh_token: '',
      access_token: 'limited-access-token',
    }),
  } satisfies ItemResponse<LoginResult>),
);

/** Login `totp_code` maydoni talab qilinishini bildiradi (allaqachon yoqilgan 2FA). */
export const loginRequiresTotpCodeHandler = http.post(url('/auth/login'), async ({ request }) => {
  const body = (await request.json()) as { totp_code?: string };
  if (body.totp_code === '123456') {
    return HttpResponse.json({ data: loginResultFixture() } satisfies ItemResponse<LoginResult>);
  }
  return HttpResponse.json(
    errorEnvelope('VALIDATION_ERROR', 'validation failed', [
      { field: 'totp_code', message: 'A verification code is required.' },
    ]),
    { status: 422 },
  );
});

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
    data: {
      enabled: true,
      recovery_codes: ['abc123', 'def456'],
      tokens: tokensFixture(),
    } satisfies TotpVerified,
  }),
);

export const totpVerifyInvalidHandler = http.post(url('/auth/2fa/verify'), () =>
  HttpResponse.json(errorEnvelope('VALIDATION_ERROR', 'Invalid code'), { status: 422 }),
);

export function meHandler(profile: Profile = profileFixture()) {
  return http.get(url('/me'), () => HttpResponse.json({ data: profile }));
}

export const meUnauthorizedHandler = http.get(url('/me'), () =>
  HttpResponse.json(errorEnvelope('UNAUTHORIZED', 'Not authenticated'), { status: 401 }),
);

/** Bazaviy to'plam — `/app/config` har testda kerak. */
export const baseHandlers = [appConfigHandler];
