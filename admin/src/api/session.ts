/**
 * Sessiya tokenlari uchun modul darajasidagi getter/setter.
 *
 * Middleware'lar React kontekstidan tashqarida ishlaydi, shuning uchun tokenga
 * shu yerdan murojaat qiladi. **Bosqich 0 (B qismi)** da Zustand auth store shu
 * setter'larni chaqiradi — client.ts o'zgarmaydi.
 *
 * Xavfsizlik qoidasi (CLAUDE.md): access token **faqat xotirada**,
 * `localStorage` da token yo'q. Refresh token `sessionStorage` da (kalit `eld.rt`),
 * uni B qismidagi auth store boshqaradi.
 */

let accessToken: string | null = null;
let companyId: string | null = null;

/** Joriy access token (xotirada). */
export function getAccessToken(): string | null {
  return accessToken;
}

export function setAccessToken(token: string | null): void {
  accessToken = token;
}

/**
 * `X-Company-Id` — faqat super_admin boshqa kompaniya nomidan ishlaganda
 * o'rnatiladi; oddiy foydalanuvchida `null` bo'lib qoladi.
 */
export function getCompanyId(): string | null {
  return companyId;
}

export function setCompanyId(id: string | null): void {
  companyId = id;
}

/** Logout / reuse detection: barcha sessiya holatini tozalaydi. */
export function clearSession(): void {
  accessToken = null;
  companyId = null;
}
