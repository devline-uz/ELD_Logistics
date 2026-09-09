/**
 * Oqim 3 — Driver yaratish → invitation → license reveal, **ruxsat bilan va
 * ruxsatsiz** ikki holat (§14.4.3).
 *
 * `admin` roli — `drivers.license.view` bor (Reveal ko'rinadi, qiymat
 * ochiladi). `manager` roli — hammasi bor, shundan tashqari
 * (`src/mocks/browser.ts`) — Reveal tugmasi butunlay DOM'da bo'lmaydi
 * (`PermissionGate`, fe-permissions §9).
 */
import { adminTest, managerTest } from './fixtures';
import { expect } from '@playwright/test';

adminTest('create driver → invitation sent → license reveal with permission', async ({ page }) => {
  await page.goto('/drivers');
  await expect(page.getByRole('heading', { name: 'Driver Management' })).toBeVisible();

  await page.getByRole('button', { name: 'Add Driver' }).click();
  await expect(page.getByRole('dialog', { name: 'Add Driver' })).toBeVisible();

  await page.getByLabel('First Name').fill('Alex');
  await page.getByLabel('Last Name').fill('Rivera');
  await page.getByLabel('Username').fill('alex.rivera');
  await page.getByLabel('Email').fill('alex.rivera@example.com');
  await page.getByLabel('License No').fill('TX-1234-9999');

  await page.getByRole('button', { name: 'Add', exact: true }).click();

  // F-driver create: parol maydoni yo'q — invitation backend tomonidan yuboriladi.
  await expect(page.getByText('Driver created')).toBeVisible();
  await expect(page.getByRole('dialog', { name: 'Add Driver' })).toBeHidden();

  await page.getByRole('cell', { name: 'John', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'John Doe' })).toBeVisible();

  const revealButton = page.getByRole('button', { name: 'Reveal license number' });
  await expect(revealButton).toBeVisible();
  await revealButton.click();
  await expect(page.getByText('TX-9930-4821')).toBeVisible();
});

managerTest('license reveal is not offered without drivers.license.view', async ({ page }) => {
  await page.goto('/drivers/driver-1');
  await expect(page.getByRole('heading', { name: 'John Doe' })).toBeVisible();

  await expect(page.getByRole('button', { name: 'Reveal license number' })).toHaveCount(0);
  await expect(page.getByText('****-4821')).toBeVisible();
});
