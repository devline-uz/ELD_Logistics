/**
 * Auth va bootstrap endpointlari (0.11–0.15).
 *
 * Barcha chaqiruvlar `openapi-fetch` klienti orqali (F13). `errorMiddleware`
 * muvaffaqiyatsiz javobda `ApiError` otadi, shuning uchun bu yerda faqat
 * muvaffaqiyatli shakl qaytariladi.
 *
 * Endpointlar `openapi/swagger.json` bilan tasdiqlangan:
 * `POST /auth/login · /auth/refresh · /auth/logout · /auth/2fa/setup ·
 * /auth/2fa/verify · /auth/invitation/accept · /auth/password/forgot ·
 * /auth/password/reset`, `GET /auth/sessions`, `DELETE /auth/sessions/{id}`,
 * `GET /me`, `GET /app/config`, `GET /company`.
 */
import { api } from './client';
import type {
  AppConfig,
  Company,
  InvitationAcceptRequest,
  LoginRequest,
  LoginResult,
  PasswordForgotRequest,
  PasswordResetRequest,
  Profile,
  SessionInfo,
  TotpSetup,
  TotpVerified,
  TotpVerifyRequest,
} from './types';

/** `POST /auth/login` — web sessiyasi (`device_type: "web"`). */
export async function login(body: LoginRequest): Promise<LoginResult> {
  const { data } = await api.POST('/auth/login', { body });
  return data?.data ?? {};
}

/**
 * `POST /auth/logout` — server sessiyasini yopadi.
 * Javobdan qat'i nazar lokal tozalash chaqiruvchi tomonda bajariladi (fe-api §4).
 */
export async function logout(refreshToken?: string | null): Promise<void> {
  await api.POST('/auth/logout', {
    body: refreshToken ? { refresh_token: refreshToken } : {},
  });
}

/** `POST /auth/2fa/setup` — QR (`otpauth_url`) va qo'lda kiritish uchun `secret`. */
export async function startTotpSetup(): Promise<TotpSetup> {
  const { data } = await api.POST('/auth/2fa/setup', {});
  return data?.data ?? {};
}

/**
 * `POST /auth/2fa/verify` — 6 xonali kod yoki tiklash kodi.
 * Cheklangan sessiyani to'liq sessiyaga ko'targanda `tokens` to'ldiriladi.
 */
export async function verifyTotp(body: TotpVerifyRequest): Promise<TotpVerified> {
  const { data } = await api.POST('/auth/2fa/verify', { body });
  return data?.data ?? {};
}

/** `POST /auth/password/forgot` — javob har doim neytral (enumeratsiyaga qarshi). */
export async function requestPasswordReset(body: PasswordForgotRequest): Promise<void> {
  await api.POST('/auth/password/forgot', { body });
}

/** `POST /auth/password/reset` — email havolasidagi token bilan yangi parol. */
export async function resetPassword(body: PasswordResetRequest): Promise<void> {
  await api.POST('/auth/password/reset', { body });
}

/** `POST /auth/invitation/accept` — parol o'rnatishning yagona yo'li (TZ qaror 21). */
export async function acceptInvitation(body: InvitationAcceptRequest): Promise<void> {
  await api.POST('/auth/invitation/accept', { body });
}

/** `GET /auth/sessions` — Settings › Security «Active sessions». */
export async function listSessions(): Promise<SessionInfo[]> {
  const { data } = await api.GET('/auth/sessions', {});
  return data?.data ?? [];
}

/** `DELETE /auth/sessions/{id}` — bitta sessiyani bekor qilish. */
export async function revokeSession(id: string): Promise<void> {
  await api.DELETE('/auth/sessions/{id}', { params: { path: { id } } });
}

/** `GET /me` — profil, rol va ruxsat ro'yxati (`auth_dto.Profile`). */
export async function fetchProfile(): Promise<Profile> {
  const { data } = await api.GET('/me', {});
  return data?.data ?? {};
}

/** `GET /app/config` — public: server vaqti, feature flag'lar, access TTL. */
export async function fetchAppConfig(): Promise<AppConfig> {
  const { data } = await api.GET('/app/config', {});
  return data?.data ?? {};
}

/**
 * `GET /company` — kompaniya konteksti (region, `unit_system`,
 * `regulation_profile`, `timezone`).
 *
 * ⚠️ Spec farqi: `GET /me` javobi (`auth_dto.Profile`) da **`company` bloki
 * yo'q** — faqat `company_id`. Shu sababli kontekst alohida endpointdan
 * olinadi va u `company.read` ruxsatini talab qiladi
 * (`docs/tz/16-17-registry-open-questions.md` → Q15).
 */
export async function fetchCompany(): Promise<Company> {
  const { data } = await api.GET('/company', {});
  return data?.data ?? {};
}
