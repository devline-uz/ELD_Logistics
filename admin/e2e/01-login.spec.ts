/**
 * Oqim 1 — Login → Dashboard → Logout (§14.4.1).
 *
 * Yagona oqim haqiqiy `/login` formasini to'ldiradi (fe-testing §E2E login
 * strategiyasi) — qolganlari `e2e/fixtures.ts` orqali oldindan
 * autentifikatsiyalangan holatda boshlanadi.
 */
import { test, expect } from '@playwright/test';

import { E2E_CREDENTIALS } from '../src/mocks/e2e-credentials';

test('login → dashboard → logout', async ({ page }) => {
  await page.goto('/login');
  await expect(page.getByRole('heading', { name: 'Sign in' })).toBeVisible();

  await page.getByLabel('Email or username').fill(E2E_CREDENTIALS.admin.username);
  await page.getByLabel(/^Password/).fill(E2E_CREDENTIALS.admin.password);
  await page.getByRole('button', { name: 'Sign in' }).click();

  await page.waitForURL((url) => url.pathname === '/');

  // D49 (yopilgan): login `loadSessionContext()` orqali `GET /me`ni
  // navigatsiyadan oldin so'raydi — sahifani qayta yuklash kerak emas.
  await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();

  await page.getByRole('button', { name: 'Account menu' }).click();
  await page.getByRole('menuitem', { name: 'Sign out' }).click();

  await page.waitForURL((url) => url.pathname === '/login');
  await expect(page.getByRole('heading', { name: 'Sign in' })).toBeVisible();
});

test('invalid credentials show an error without revealing which field is wrong', async ({
  page,
}) => {
  await page.goto('/login');
  await page.getByLabel('Email or username').fill('nobody');
  await page.getByLabel(/^Password/).fill('wrong-password');
  await page.getByRole('button', { name: 'Sign in' }).click();

  await expect(page.getByText('The email/username or password is incorrect.')).toBeVisible();
  await expect(page).toHaveURL(/\/login/);
});
