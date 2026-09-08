/**
 * Refresh token saqlash — **faqat `sessionStorage`** (fe-security §4, F14/F205).
 *
 * Nima uchun `sessionStorage`: backend `POST /auth/refresh` httpOnly cookie
 * o'rnatmaydi (oddiy JSON `TokensEnvelope`), `v1` esa muzlatilgan. `sessionStorage`
 * tab yopilganda o'chadi va boshqa tabga tarqalmaydi. `localStorage` da token
 * **hech qachon** saqlanmaydi.
 *
 * Backend httpOnly cookie qo'shsa (CR) — shu modul butunlay olib tashlanadi
 * (`docs/tz/16-17-registry-open-questions.md` → D-f1).
 */

/** `sessionStorage` kaliti. */
export const REFRESH_TOKEN_KEY = 'eld.rt';

/**
 * `localStorage` da qolib ketgan eski token bo'lsa (oldingi versiya yoki qo'lda
 * qo'yilgan) — o'qilmaydi, faqat o'chiriladi.
 */
const LEGACY_KEYS = ['eld.rt', 'access_token', 'refresh_token'] as const;

function storage(): Storage | null {
  try {
    return typeof sessionStorage === 'undefined' ? null : sessionStorage;
  } catch {
    // Cookie/site-data bloklangan brauzerda `sessionStorage` ga murojaat otadi.
    return null;
  }
}

export function readRefreshToken(): string | null {
  try {
    return storage()?.getItem(REFRESH_TOKEN_KEY) ?? null;
  } catch {
    return null;
  }
}

export function writeRefreshToken(token: string | null): void {
  try {
    const store = storage();
    if (!store) return;
    if (token === null || token === '') {
      store.removeItem(REFRESH_TOKEN_KEY);
    } else {
      store.setItem(REFRESH_TOKEN_KEY, token);
    }
  } catch {
    // Saqlash imkoni bo'lmasa sessiya faqat joriy sahifa umriga qoladi.
  }
}

export function clearRefreshToken(): void {
  writeRefreshToken(null);
}

/** `localStorage` da token qoldirmaslik kafolati — ilova ishga tushganda. */
export function purgeLegacyTokenStorage(): void {
  try {
    if (typeof localStorage === 'undefined') return;
    for (const key of LEGACY_KEYS) localStorage.removeItem(key);
  } catch {
    // e'tiborsiz — brauzer saqlashni bloklagan.
  }
}
