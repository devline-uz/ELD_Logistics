/**
 * Global setup — login bitta marta har rol uchun (9.1, fe-testing §E2E login
 * strategiyasi). 8 oqimning ikkinchisidan boshlab `/login` formasi qaytadan
 * to'ldirilmaydi — `sessionStorage`dagi refresh token shu yerda olinadi va
 * `e2e/fixtures.ts` har test boshida `page.addInitScript` orqali qayta
 * yozadi (Playwright rasmiy `storageState` faqat cookie/localStorage'ni
 * qamrab oladi, `sessionStorage`ni emas — shu sabab moslashtirilgan yechim).
 *
 * Uchta rol (`src/mocks/browser.ts` `E2E_CREDENTIALS`):
 * - `admin` — barcha ruxsatlar (1/2/4/5/6/7-oqimlar).
 * - `manager` — hammasi, `drivers.license.view`dan tashqari (3-oqim
 *   "ruxsatsiz" license reveal holati).
 * - `restricted` — faqat `dashboard.read` (8-oqim: yashirilgan menyular,
 *   403/404 ekranlari).
 */
import { chromium, type FullConfig } from '@playwright/test';
import { mkdirSync, writeFileSync } from 'node:fs';
import path from 'node:path';

import { E2E_CREDENTIALS, type E2eRole } from '../src/mocks/e2e-credentials';

const AUTH_DIR = path.join(process.cwd(), 'playwright', '.auth');
const ROLES: E2eRole[] = ['admin', 'manager', 'restricted'];
const REFRESH_TOKEN_KEY = 'eld.rt';

export default async function globalSetup(config: FullConfig): Promise<void> {
  mkdirSync(AUTH_DIR, { recursive: true });

  const baseURL =
    config.projects[0]?.use.baseURL ?? process.env.E2E_BASE_URL ?? 'http://localhost:5173';

  const browser = await chromium.launch();
  try {
    for (const role of ROLES) {
      const context = await browser.newContext({ baseURL });
      const page = await context.newPage();
      const { username, password } = E2E_CREDENTIALS[role];

      await page.goto('/login');
      await page.getByLabel('Email or username').fill(username);
      await page.getByLabel(/^Password/).fill(password);
      await page.getByRole('button', { name: 'Sign in' }).click();
      await page.waitForURL((url) => url.pathname === '/', { timeout: 15_000 });

      const refreshToken = await page.evaluate(
        (key) => window.sessionStorage.getItem(key),
        REFRESH_TOKEN_KEY,
      );
      if (!refreshToken) {
        throw new Error(`[global-setup] "${role}" uchun refresh token topilmadi`);
      }

      writeFileSync(
        path.join(AUTH_DIR, `${role}.session.json`),
        JSON.stringify({ refreshToken }, null, 2),
      );

      await context.close();
    }
  } finally {
    await browser.close();
  }
}
