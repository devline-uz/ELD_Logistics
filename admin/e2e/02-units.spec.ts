/**
 * Oqim 2 — Unit yaratish → tahrirlash → deaktivatsiya → o'chirish, tasdiq
 * dialoglari bilan (§14.4.2).
 *
 * MSW mock holatsiz (`GET /units` doim bitta `unit-1`/`1021` qatorini
 * qaytaradi) — shuning uchun tasdiqlash **toast matni** orqali (forma
 * qiymatidan olinadi, server javobidan emas), jadval qatorini qayta
 * hisoblash orqali emas.
 */
import { adminTest as test, expect } from './fixtures';

test.beforeEach(async ({ page }) => {
  await page.goto('/units');
  await expect(page.getByRole('heading', { name: 'Unit Management' })).toBeVisible();
});

test('create unit', async ({ page }) => {
  await page.getByRole('button', { name: 'Add Unit' }).click();
  const dialog = page.getByRole('dialog', { name: 'Add unit' });
  await expect(dialog).toBeVisible();

  await dialog.getByLabel('Unit #').fill('2002');
  await dialog.getByLabel('Make').fill('Volvo');
  await dialog.getByLabel('Model').fill('VNL');
  await dialog.getByLabel('License Plate').fill('XYZ123');

  await dialog.getByRole('button', { name: 'Create' }).click();

  await expect(page.getByText('Unit 2002 created')).toBeVisible();
  await expect(dialog).toBeHidden();
});

test('edit unit', async ({ page }) => {
  await page.getByRole('button', { name: 'Actions for unit 1021', exact: true }).click();
  await page.getByRole('menuitem', { name: 'Edit' }).click();

  await expect(page.getByRole('dialog', { name: 'Edit unit' })).toBeVisible();
  await page.getByLabel('Make').fill('Kenworth');
  await page.getByRole('button', { name: 'Save Changes' }).click();

  await expect(page.getByText('Unit 1021 updated')).toBeVisible();
});

test('deactivate unit with confirmation dialog', async ({ page }) => {
  await page.getByRole('button', { name: 'Actions for unit 1021', exact: true }).click();
  await page.getByRole('menuitem', { name: 'Deactivate' }).click();

  const dialog = page.getByRole('alertdialog');
  await expect(dialog).toBeVisible();
  await expect(dialog.getByText(/deactivate/i)).toBeVisible();
  await dialog.getByRole('button', { name: 'Confirm' }).click();

  await expect(page.getByText('Unit 1021 deactivated')).toBeVisible();
});

test('delete unit with confirmation dialog', async ({ page }) => {
  await page.getByRole('button', { name: 'Actions for unit 1021', exact: true }).click();
  await page.getByRole('menuitem', { name: 'Delete' }).click();

  const dialog = page.getByRole('alertdialog');
  await expect(dialog).toBeVisible();
  await dialog.getByRole('button', { name: 'Confirm' }).click();

  await expect(page.getByText('Unit 1021 deleted')).toBeVisible();
});
