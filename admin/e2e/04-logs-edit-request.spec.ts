/**
 * Oqim 4 — Logs By Driver → Log view → "Send edit request" (§14.4.4).
 *
 * F100 [MUST]: admin logni to'g'ridan-to'g'ri tahrirlamaydi. Tugma nomi
 * ataylab "Send edit request" — taklif yuborilgandan keyin yozuv **hali
 * o'zgarmaydi**, haydovchi tasdig'i kutiladi (`logs/edit-requests`da
 * "pending" holatda ko'rinadi).
 */
import { adminTest as test, expect } from './fixtures';

test('propose a duty status edit and wait for driver approval', async ({ page }) => {
  await page.goto('/logs/by-driver');
  await expect(page.getByRole('heading', { name: 'Logs By Driver' })).toBeVisible();

  await page.getByRole('combobox', { name: 'Driver' }).click();
  await page.getByRole('option', { name: 'John Doe' }).click();

  // `DataTable` `onRowClick` bilan `<tr role="button">` beradi — brauzer
  // ARIA daraxti bu overrideni ba'zan "row" implicit rolига qaytarib
  // qo'yadi (jadval strukturasi cheklovi tufayli beqaror), shuning uchun
  // CSS lokatori ishlatiladi (`role` emas).
  const logRow = page.locator('table tbody tr').first();
  await logRow.waitFor({ state: 'visible' });
  await logRow.click({ force: true });
  await expect(page.getByRole('heading', { name: 'John Doe' })).toBeVisible();

  await page.getByRole('button', { name: 'Propose edit' }).first().click();
  await expect(page.getByRole('dialog', { name: 'Insert / Edit Duty Status' })).toBeVisible();

  await page.getByLabel('Note').fill('Forgot to switch to ON at the dock');
  await page.getByRole('button', { name: 'Send edit request' }).click();

  // F100: darhol tasdiqlanmaydi — taklif "pending" holatda ro'yxatga tushadi.
  await expect(page.getByText('Edit request sent to the driver for approval')).toBeVisible();
  await page.waitForURL((url) => url.pathname === '/logs/edit-requests');
  await expect(page.getByText(/pending/i).first()).toBeVisible();
});
