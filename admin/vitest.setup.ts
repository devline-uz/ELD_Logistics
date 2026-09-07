import '@testing-library/jest-dom/vitest';
import { afterAll, afterEach, beforeAll } from 'vitest';

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

/**
 * React Router v7 «Future Flag» ogohlantirishlarini bostirish.
 *
 * `app/router.tsx` da `ROUTER_FUTURE` bayroqlari o'rnatilgan, lekin testlarda
 * `MemoryRouter` to'g'ridan-to'g'ri ishlatiladi (16 fayl) va ularning aksariyati
 * bayroqlarni uzatmaydi. Natijada har test yugurishi ~13 KB shovqin chiqaradi —
 * bu subagent kontekstini behuda to'ldiradi (har yugurish ~3k token shovqin).
 *
 * Faqat aynan shu informatsion ogohlantirish bostiriladi; boshqa har qanday
 * `console.warn`/`console.error` o'z holicha chiqadi (W: «konsolda ogohlantirish
 * yo'q» qoidasi kuchida qoladi).
 */
const ROUTER_FUTURE_WARNING = /React Router Future Flag Warning/;
const originalWarn = console.warn;

beforeAll(() => {
  console.warn = (...args: unknown[]) => {
    if (typeof args[0] === 'string' && ROUTER_FUTURE_WARNING.test(args[0])) return;
    originalWarn(...args);
  };
});

afterAll(() => {
  console.warn = originalWarn;
});

/**
 * jsdom `HTMLCanvasElement.prototype.getContext` ni qo'llab-quvvatlamaydi.
 *
 * `axe-core` (a11y testlari) rang kontrastini hisoblash uchun uni chaqiradi va
 * har chaqiruvda to'liq stack-trace bilan «Not implemented» xatosi chiqadi —
 * har test yugurishida ~16 KB shovqin (subagent kontekstini behuda to'ldiradi).
 *
 * Bu funksional muammo emas: `axe` canvas bo'lmasa kontrast tekshiruvini
 * o'tkazib yuboradi (kontrast baribir `a11y-reviewer` tomonidan hex kodlar
 * asosida qo'lda hisoblanadi — 1.17). Shuning uchun `null` qaytaruvchi stub
 * qo'yamiz: xatti-harakat o'zgarmaydi, shovqin yo'qoladi.
 */
HTMLCanvasElement.prototype.getContext = (() => null) as typeof HTMLCanvasElement.prototype.getContext;
