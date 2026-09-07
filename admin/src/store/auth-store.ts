/**
 * Auth store — sessiya holatining yagona manbai (0.12).
 *
 * Xavfsizlik qoidalari (fe-security §4, F205):
 * - `accessToken` **faqat shu store'da**, ya'ni JS xotirasida. `persist`
 *   middleware **ishlatilmaydi**, `localStorage` ga hech narsa yozilmaydi.
 * - `refreshToken` bu yerda **saqlanmaydi** — u faqat `sessionStorage` da
 *   (`src/api/refresh-token.ts`, kalit `eld.rt`). Shu sababli store snapshot'i
 *   dev-tools yoki xato hisobotiga tushsa ham refresh token oshkor bo'lmaydi.
 *
 * Store faqat **holat** saqlaydi — hech qanday tarmoq chaqiruvi yo'q. API
 * bilan ishlash `src/api/session.ts` va `src/api/auth.api.ts` da.
 */
import { create } from 'zustand';

import type { Profile } from '@/api/types';

/** Sessiya nima uchun tugagani — `/login?reason=` va toast matni uchun. */
export type SessionEndReason = 'user' | 'idle_timeout' | 'session_expired';

export interface AuthState {
  /** Xotiradagi access token. Sahifa yangilanganda yo'qoladi — bu kutilgan. */
  accessToken: string | null;
  /** Access token amal qilish muddati (epoch ms) — proaktiv refresh uchun. */
  accessTokenExpiresAt: number | null;
  sessionId: string | null;
  /**
   * Cheklangan token: `requires_totp_setup: true`. Faqat `/auth/2fa/*`
   * chaqiriluvchi, boshqa barcha marshrutlar bloklangan (TZ §7.1.2).
   */
  limited: boolean;
  profile: Profile | null;
  /** `X-Company-Id` — faqat super_admin boshqa tenant nomidan ishlaganda. */
  impersonatedCompanyId: string | null;
  /** Oxirgi logout sababi — `/login` ekrani shu bo'yicha xabar ko'rsatadi. */
  endReason: SessionEndReason | null;
  /**
   * `POST /auth/login` javobidagi sessiya bayroqlari (fe-api §4).
   *
   * Ilgari React Context orqali (`SessionFlagsProvider` props) uzatilardi;
   * bu yerga ko'chirildi, chunki bayroqlar login javobining bir qismi —
   * boshqa har qanday sessiya holati kabi bitta manbada (store) yashashi
   * kerak, testlar esa `useAuthStore.setState()` bilan to'g'ridan-to'g'ri
   * sozlay oladi (Context'dagi kabi provayder daraxtini aylanib o'tmasdan).
   */
  subscriptionReadonly: boolean;
  /** Boshqa web sessiya majburan yopilgan — bir martalik toast (0.22). */
  replacedSession: boolean;
}

export interface AuthActions {
  setTokens: (input: {
    accessToken: string;
    expiresInSeconds: number;
    sessionId?: string | null;
    limited?: boolean;
    subscriptionReadonly?: boolean;
    replacedSession?: boolean;
  }) => void;
  setProfile: (profile: Profile | null) => void;
  setImpersonatedCompanyId: (id: string | null) => void;
  setEndReason: (reason: SessionEndReason | null) => void;
  /** Bir martalik toast ko'rsatilgach `replacedSession` ni pasaytirish uchun. */
  setSessionFlags: (
    flags: Partial<Pick<AuthState, 'subscriptionReadonly' | 'replacedSession'>>,
  ) => void;
  /** To'liq tozalash — logout, reuse detection, idle timeout. */
  reset: (reason?: SessionEndReason | null) => void;
}

const INITIAL_STATE: AuthState = {
  accessToken: null,
  accessTokenExpiresAt: null,
  sessionId: null,
  limited: false,
  profile: null,
  impersonatedCompanyId: null,
  endReason: null,
  subscriptionReadonly: false,
  replacedSession: false,
};

export const useAuthStore = create<AuthState & AuthActions>((set) => ({
  ...INITIAL_STATE,

  setTokens: ({
    accessToken,
    expiresInSeconds,
    sessionId,
    limited,
    subscriptionReadonly,
    replacedSession,
  }) =>
    set((state) => ({
      accessToken,
      accessTokenExpiresAt: Date.now() + Math.max(0, expiresInSeconds) * 1000,
      sessionId: sessionId ?? state.sessionId,
      limited: limited ?? state.limited,
      subscriptionReadonly: subscriptionReadonly ?? state.subscriptionReadonly,
      replacedSession: replacedSession ?? state.replacedSession,
      endReason: null,
    })),

  setProfile: (profile) => set({ profile }),
  setImpersonatedCompanyId: (impersonatedCompanyId) => set({ impersonatedCompanyId }),
  setEndReason: (endReason) => set({ endReason }),
  setSessionFlags: (flags) => set(flags),

  reset: (reason = null) => set({ ...INITIAL_STATE, endReason: reason }),
}));

/** React'dan tashqarida (middleware, refresh mutex) o'qish uchun. */
export function authState(): AuthState & AuthActions {
  return useAuthStore.getState();
}

/** Foydalanuvchi tizimga kirganmi (cheklangan 2FA sessiyasi hisoblanmaydi). */
export function selectIsAuthenticated(state: AuthState): boolean {
  return state.accessToken !== null && !state.limited;
}

/** Barqaror bo'sh ro'yxat — selektor har chaqiruvda yangi massiv qaytarmasligi uchun. */
const NO_PERMISSIONS: readonly string[] = Object.freeze([]);

/** Ruxsat ro'yxati — `PermissionsProvider` ga uzatiladi (0.15). */
export function selectPermissions(state: AuthState): readonly string[] {
  return state.profile?.permissions ?? NO_PERMISSIONS;
}

/** `super_admin` bayrog'i — rol emas (F33). */
export function selectIsSuperAdmin(state: AuthState): boolean {
  return state.profile?.is_super_admin === true;
}

/**
 * Sessiya `scope`i (`company | branch | self`) — Branch select/filtrini
 * faqat `scope=company` administratoriga ko'rsatish uchun (bosqich 2
 * ko'rigi B1). `branch`/`self` uchun backend baribir o'z filialiga
 * cheklaydi, shuning uchun UI select shunchaki keraksiz.
 */
export function selectScope(state: AuthState): Profile['scope'] {
  return state.profile?.scope;
}

/** `subscription_readonly` / `replacedSession` — `useWriteGuard`, `SubscriptionBanner` uchun. */
export function selectSessionFlags(
  state: AuthState,
): Pick<AuthState, 'subscriptionReadonly' | 'replacedSession'> {
  return {
    subscriptionReadonly: state.subscriptionReadonly,
    replacedSession: state.replacedSession,
  };
}
