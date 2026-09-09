/**
 * Rol bo'yicha autentifikatsiyalangan `page` fixture (9.1).
 *
 * `global-setup.ts` har rol uchun bitta marta login qilib, refresh tokenni
 * `playwright/.auth/<rol>.session.json` ga yozadi. Bu fixture har test
 * boshida (birinchi `page.goto()`dan OLDIN) `sessionStorage`ga shu tokenni
 * `addInitScript` orqali yozadi — ilova bootstrap bosqichida
 * `POST /auth/refresh` chaqirib haqiqiy sessiyani tiklaydi (fe-api §4),
 * `/login` formasi qayta to'ldirilmaydi.
 */
import { test as base, expect, type Page } from '@playwright/test';
import { readFileSync } from 'node:fs';
import path from 'node:path';

import type { E2eRole } from '../src/mocks/e2e-credentials';

const REFRESH_TOKEN_KEY = 'eld.rt';

function readSession(role: E2eRole): { refreshToken: string } {
  const file = path.join(process.cwd(), 'playwright', '.auth', `${role}.session.json`);
  return JSON.parse(readFileSync(file, 'utf-8')) as { refreshToken: string };
}

/** Berilgan rol uchun oldindan autentifikatsiyalangan `test` instansiyasini yaratadi. */
export function createAuthedTest(role: E2eRole) {
  return base.extend<{ page: Page }>({
    // `runWithPage` — Playwright'ning "use" callback'i; `react-hooks/rules-of-hooks`
    // `use*` nomli funksiyalarni hook deb noto'g'ri aniqlamasligi uchun qayta nomlangan.
    page: async ({ page }, runWithPage) => {
      const { refreshToken } = readSession(role);
      await page.addInitScript(
        ({ key, value }: { key: string; value: string }) => {
          window.sessionStorage.setItem(key, value);
        },
        { key: REFRESH_TOKEN_KEY, value: refreshToken },
      );
      await runWithPage(page);
    },
  });
}

export const adminTest = createAuthedTest('admin');
export const managerTest = createAuthedTest('manager');
export const restrictedTest = createAuthedTest('restricted');

export { expect };
