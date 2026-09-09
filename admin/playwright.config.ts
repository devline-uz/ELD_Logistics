import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright e2e konfiguratsiyasi (9.1, 9.8).
 *
 * Dev server **MSW yoqilgan holda** ko'tariladi (`VITE_ENABLE_MSW=1`) va
 * `VITE_API_BASE_URL` `src/mocks/handlers/shared.ts`dagi `url()` bazasi bilan
 * bitta manbaga tushiriladi (`http://eldapi.test/api/v1`) — shunda ilova
 * so'rovlari va MSW handler'lari bir xil yo'lda uchrashadi (F226: haqiqiy
 * backendga hech qachon so'rov ketmaydi).
 *
 * `globalSetup` uchta rol (admin/manager/restricted) uchun login qilib,
 * `sessionStorage`dagi refresh tokenni `playwright/.auth/<rol>.session.json`
 * ga yozadi (`e2e/fixtures.ts` keyin shuni o'qiydi) — Playwright'ning rasmiy
 * `storageState` mexanizmi faqat cookie/localStorage'ni qamrab oladi,
 * `sessionStorage`ni emas (fe-testing skill talabi shu sabab moslashtirilgan,
 * quyi hisobotda aytilgan).
 */
export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  reporter: 'html',
  globalSetup: './e2e/global-setup.ts',
  use: {
    baseURL: process.env.E2E_BASE_URL ?? 'http://localhost:5173',
    trace: 'on-first-retry',
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
  webServer: {
    command: 'npm run dev',
    url: process.env.E2E_BASE_URL ?? 'http://localhost:5173',
    reuseExistingServer: !process.env.CI,
    timeout: 60_000,
    env: {
      VITE_ENABLE_MSW: '1',
      VITE_API_BASE_URL: 'http://eldapi.test/api/v1',
    },
  },
});
