/**
 * Sessiya fasadi — React'dan tashqarida ishlaydigan kod (`client.ts`
 * middleware'lari, refresh mutex) uchun yagona kirish nuqtasi.
 *
 * Holat manbai — `src/store/auth-store.ts` (Zustand). Bu modul faqat o'qish
 * qulayligi va sessiyani tugatish hodisasini tarqatish uchun.
 *
 * Xavfsizlik (fe-security §4): access token **faqat xotirada** (store),
 * refresh token **faqat `sessionStorage`** (`refresh-token.ts`).
 */
import { authState, type SessionEndReason } from '@/store/auth-store';

import { clearRefreshToken, readRefreshToken } from './refresh-token';

export { REFRESH_TOKEN_KEY, readRefreshToken, writeRefreshToken } from './refresh-token';

/** Joriy access token (xotirada). */
export function getAccessToken(): string | null {
  return authState().accessToken;
}

export function setAccessToken(token: string | null): void {
  if (token === null) {
    authState().reset();
    return;
  }
  authState().setTokens({ accessToken: token, expiresInSeconds: 0 });
}

/** Access token amal qilish muddati (epoch ms) yoki `null`. */
export function getAccessTokenExpiry(): number | null {
  return authState().accessTokenExpiresAt;
}

/**
 * `X-Company-Id` — faqat super_admin boshqa kompaniya nomidan ishlaganda
 * o'rnatiladi; oddiy foydalanuvchida `null` bo'lib qoladi.
 */
export function getCompanyId(): string | null {
  return authState().impersonatedCompanyId;
}

export function setCompanyId(id: string | null): void {
  authState().setImpersonatedCompanyId(id);
}

/* ------------------------------------------------------------------ *
 * Sessiya tugashi haqidagi hodisa
 * ------------------------------------------------------------------ */

export type SessionEndListener = (reason: SessionEndReason) => void;

const listeners = new Set<SessionEndListener>();

/**
 * Sessiya tugaganda chaqiriladigan tinglovchi.
 *
 * Ro'yxatdan o'tuvchilar: React qatlami (`queryClient.clear()` + `/login` ga
 * redirect), refresh taymeri (proaktiv refreshni bekor qilish), keyingi
 * bosqichda WebSocket klienti (`ws.close()` — fe-security §11).
 */
export function onSessionEnded(listener: SessionEndListener): () => void {
  listeners.add(listener);
  return () => {
    listeners.delete(listener);
  };
}

/**
 * To'liq lokal logout: xotira + `sessionStorage` tozalanadi va barcha
 * tinglovchilar xabardor qilinadi. Tarmoq chaqiruvi qilmaydi — `POST /auth/logout`
 * ni chaqiruvchi tomon (`auth.api.ts`) bajaradi.
 */
export function endSession(reason: SessionEndReason = 'user'): void {
  clearRefreshToken();
  authState().reset(reason);
  for (const listener of listeners) listener(reason);
}

/** `clearSession()` — `endSession('user')` uchun mos nom (mavjud chaqiruvlar). */
export function clearSession(): void {
  endSession('user');
}

/** Refresh token mavjudmi — bootstrap sessiyani tiklashga urinishi kerakmi. */
export function hasStoredRefreshToken(): boolean {
  return readRefreshToken() !== null;
}
