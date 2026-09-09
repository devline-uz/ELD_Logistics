/**
 * 9.8 — `metric`/`imperial` va `generic`/`us_fmcsa` bo'yicha to'liq e2e
 * o'tish.
 *
 * Admin profilining default kompaniya konteksti `unit_system: imperial`,
 * `regulation_profile: us_fmcsa` (`src/mocks/handlers/company.ts` fixture).
 * Settings › Company orqali almashtirish **butun panel bo'ylab** formatni
 * darhol o'zgartiradi (F145) — alohida `GET /me` so'rovisiz.
 */
import type { Page } from '@playwright/test';

import { adminTest as test, expect } from './fixtures';

async function saveCompanyField(
  page: Page,
  fieldLabel: string,
  optionLabel: string,
): Promise<void> {
  await page.goto('/settings/company');
  await page.getByRole('combobox', { name: fieldLabel }).click();
  await page.getByRole('option', { name: optionLabel, exact: true }).click();
  await page.getByRole('button', { name: 'Save Changes' }).click();
  await page.getByRole('alertdialog').getByRole('button', { name: 'Confirm' }).click();
  await expect(page.getByText('Company profile saved')).toBeVisible();
}

test('unit system: imperial → metric changes the Maintenance Due distance label', async ({
  page,
}) => {
  // `DataTable` `onRowClick` bilan qatorni `role="button"`ga aylantiradi
  // (`role="row"` emas) — shu sabab `tbody tr` CSS lokatori ishlatiladi.
  await page.goto('/maintenance/due');
  const row = page.locator('table tbody tr').first();
  await expect(row).toContainText('mi');

  await saveCompanyField(page, 'Unit system', 'Metric');

  await page.goto('/maintenance/due');
  await expect(page.locator('table tbody tr').first()).toContainText('km');
});

test('regulation profile: us_fmcsa → generic renames report screens and nav', async ({ page }) => {
  await page.goto('/reports/distance-by-region');
  await expect(page.getByRole('heading', { name: 'IFTA Report' })).toBeVisible();

  await page.goto('/reports/regulator');
  await expect(page.getByRole('heading', { name: 'FMCSA Report' })).toBeVisible();

  await saveCompanyField(page, 'Regulation profile', 'Generic');

  await page.goto('/reports/distance-by-region');
  await expect(page.getByRole('heading', { name: 'Distance by Region' })).toBeVisible();

  const nav = page.getByRole('navigation', { name: 'Primary navigation' });
  await nav.getByRole('button', { name: 'Reports' }).click();
  await expect(nav.getByRole('link', { name: 'Distance by Region' })).toBeVisible();

  await page.goto('/reports/regulator');
  await expect(page.getByRole('heading', { name: 'Regulator Export' })).toBeVisible();
});

test('boundary distance values (0, negative remaining, huge odometer) render without crashing in both unit systems', async ({
  page,
}) => {
  // `unit_id=e2e-boundary` — `src/mocks/browser.ts` `maintenanceDueHandler`
  // shu markerni o'qib 3 chegaraviy qatorni qaytaradi (0, manfiy, juda katta
  // odometer, F215). `page.route()` bilan ushlash sinovdan o'tdi: MSW Service
  // Worker ba'zan poyga holatida ustun chiqadi, shuning uchun senariy MSW
  // qatlamining o'zida hal qilinadi.
  await page.goto('/maintenance/due?unit_id=e2e-boundary');
  const rows = page.locator('table tbody tr');
  await expect(rows).toHaveCount(3);

  const bodyText = await page.getByRole('table').innerText();
  expect(bodyText).not.toContain('NaN');
  expect(bodyText).not.toContain('Invalid');
  await expect(page.getByText('Overdue', { exact: true })).toBeVisible();

  await saveCompanyField(page, 'Unit system', 'Metric');
  await page.goto('/maintenance/due?unit_id=e2e-boundary');
  const bodyTextMetric = await page.getByRole('table').innerText();
  expect(bodyTextMetric).not.toContain('NaN');
  expect(bodyTextMetric).not.toContain('Invalid');
});
