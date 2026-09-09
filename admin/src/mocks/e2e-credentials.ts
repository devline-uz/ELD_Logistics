/**
 * E2E rol/kirish ma'lumotlari (9.1) — **bog'liqliksiz** modul.
 *
 * `src/mocks/browser.ts` (brauzer, `msw/browser`) va `e2e/global-setup.ts`
 * (Node, Playwright) ikkalasi ham shu faylni import qiladi. Agar bu
 * konstantalar `browser.ts` ichida qolsa, `global-setup.ts` ularni olish
 * uchun `msw/browser`ni Node muhitida import qilishga majbur bo'lardi —
 * noto'g'ri muhitda ishga tushirilgan `setupWorker` xato beradi.
 */
export type E2eRole = 'admin' | 'manager' | 'restricted';

export const E2E_CREDENTIALS: Record<E2eRole, { username: string; password: string }> = {
  admin: { username: 'e2e.admin', password: 'Passw0rd!1' },
  // `manager` — drivers.license.view'siz boshqa hammasi (3-oqim "ruxsatsiz" holati).
  manager: { username: 'e2e.manager', password: 'Passw0rd!1' },
  restricted: { username: 'e2e.viewer', password: 'Passw0rd!1' },
};
