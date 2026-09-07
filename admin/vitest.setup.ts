import '@testing-library/jest-dom/vitest';
import { afterAll, afterEach } from 'vitest';

import { server } from '@/test/msw-server';

/**
 * MSW (fe-testing §MSW) — `server.listen()` **shu yerda, sinxron** chaqiriladi
 * (`beforeAll` ichida emas).
 *
 * Sabab: `src/api/client.ts` va `src/api/refresh.ts` `createClient()` ni
 * modul yuklanish vaqtida (top-level) chaqiradi va `globalThis.fetch` ni
 * o'sha payt qiymati bilan "muzlatib" oladi. Agar `server.listen()` `beforeAll`
 * ichida bo'lsa, u testlar ishga tushganda chaqiriladi — bu paytda sinov
 * fayli allaqachon import qilingan va `api` klienti eski (patch qilinmagan)
 * `fetch` havolasini ushlab qolgan bo'ladi, MSW hech narsani ushlay olmaydi.
 * Setup fayli test faylining `import`laridan **oldin** to'liq bajariladi,
 * shuning uchun shu yerdagi sinxron `listen()` chaqiruvi patch'ni klient
 * modullari yuklanishidan oldin qo'llaydi.
 */
server.listen({ onUnhandledRequest: 'error' });

afterEach(() => {
  server.resetHandlers();
});

afterAll(() => {
  server.close();
});
