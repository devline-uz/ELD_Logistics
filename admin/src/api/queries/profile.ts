/**
 * Settings › Profile & Security — TanStack Query hooklari (Bosqich 8.6,
 * fe-api §3, `docs/tz/07-13-settings-admin.md` §7.13.6/§7.13.7).
 *
 * Endpointlar `admin/openapi/swagger.json` bilan tasdiqlangan: `GET /me`,
 * `GET /auth/sessions`, `DELETE /auth/sessions/{id}`, `POST /auth/2fa/setup`,
 * `POST /auth/2fa/verify`, `POST /auth/password/forgot`. Barchasi
 * `authenticated` — alohida permission kaliti talab qilmaydi (fe-permissions
 * §8: shaxsiy ekranlar).
 *
 * ⚠️ Backend bo'shliqlari (`docs/tz/16-17-registry-open-questions.md`):
 * - **D40** — profilni yangilash endpointi (`PATCH /me` yoki shunga o'xshash)
 *   swagger'da yo'q; Profile ekrani shu sabab faqat o'qiladi.
 * - **D41** — joriy parol bilan bevosita almashtirish endpointi yo'q; faqat
 *   email-token asosidagi `forgot`/`reset` jufti bor. `useRequestPasswordResetEmail`
 *   shu email oqimini qayta ishlatadi.
 * - **D42** — 2FA'ni o'chirish endpointi yo'q; faqat `setup`/`verify` (yoqish).
 */
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query';

import {
  fetchProfile,
  listSessions,
  requestPasswordReset,
  revokeSession,
  startTotpSetup,
  verifyTotp,
} from '@/api/auth.api';
import type {
  PasswordForgotRequest,
  Profile,
  SessionInfo,
  TotpSetup,
  TotpVerified,
  TotpVerifyRequest,
} from '@/api/types';
import type { ApiError } from '@/lib/errors';
import { authState } from '@/store/auth-store';

/** Query key fabrikasi — `['profile', <tur>]` (fe-conventions §3). */
export const profileKeys = {
  all: ['profile'] as const,
  me: () => [...profileKeys.all, 'me'] as const,
  sessions: () => [...profileKeys.all, 'sessions'] as const,
};

/**
 * `GET /me` — Settings › Profile (7.13.6). Muvaffaqiyatli javob auth
 * store'ga ham yoziladi (nav/profil menyusi bir xil ma'lumotni ko'radi).
 */
export function useMyProfile(): UseQueryResult<Profile, ApiError> {
  return useQuery({
    queryKey: profileKeys.me(),
    queryFn: async () => {
      const profile = await fetchProfile();
      authState().setProfile(profile);
      return profile;
    },
  });
}

/** `GET /auth/sessions` — Settings › Security «Active sessions» (7.13.7). */
export function useMySessions(): UseQueryResult<SessionInfo[], ApiError> {
  return useQuery({
    queryKey: profileKeys.sessions(),
    queryFn: () => listSessions(),
  });
}

/**
 * `DELETE /auth/sessions/{id}` — bitta sessiyani tugatish. Joriy sessiya
 * tugatilganda mahalliy logout — chaqiruvchi komponent tomonida (fe-api §2:
 * `current: true` sessiyani revoke qilish = logout).
 */
export function useRevokeSession() {
  const queryClient = useQueryClient();
  return useMutation<void, ApiError, string>({
    mutationFn: (id) => revokeSession(id),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: profileKeys.sessions() });
    },
  });
}

/** `POST /auth/2fa/setup` — QR/secret, 2FA yoqish oqimining birinchi qadami. */
export function useTotpSetupStart() {
  return useMutation<TotpSetup, ApiError, void>({
    mutationFn: () => startTotpSetup(),
  });
}

/**
 * `POST /auth/2fa/verify` — 6 xonali kodni tasdiqlab 2FA'ni yoqadi.
 * Muvaffaqiyatda auth store'dagi `profile.totp_enabled` ham yangilanadi.
 */
export function useTotpVerifyEnable() {
  const queryClient = useQueryClient();
  return useMutation<TotpVerified, ApiError, TotpVerifyRequest>({
    mutationFn: (body) => verifyTotp(body),
    onSuccess: (result) => {
      if (result.enabled) {
        const current = authState().profile;
        if (current) authState().setProfile({ ...current, totp_enabled: true });
      }
      void queryClient.invalidateQueries({ queryKey: profileKeys.me() });
    },
  });
}

/**
 * `POST /auth/password/forgot` — Settings › Security «Change password» MVP
 * fallback'i (D41): joriy parol bilan bevosita almashtirish endpointi yo'q,
 * shuning uchun mavjud email-tasdiqlash oqimi qayta ishlatiladi. Javob har
 * doim neytral (enumeratsiyaga qarshi, `auth.api.ts`).
 */
export function useRequestPasswordResetEmail() {
  return useMutation<void, ApiError, PasswordForgotRequest>({
    mutationFn: (body) => requestPasswordReset(body),
  });
}
