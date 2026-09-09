/**
 * Oqim 8 — Permission: cheklangan rol bilan kirish → yashirilgan menyular va
 * 403/404 ekranlari (§14.4.8).
 *
 * `restricted` roli faqat `dashboard.read`ga ega (`src/mocks/browser.ts`).
 */
import { restrictedTest as test, expect } from './fixtures';

test('restricted role only sees Dashboard in the nav', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();

  const nav = page.getByRole('navigation', { name: 'Primary navigation' });
  await expect(nav.getByRole('link', { name: 'Dashboard' })).toBeVisible();
  await expect(nav.getByText('Fleet Management')).toHaveCount(0);
  await expect(nav.getByText('Tracking')).toHaveCount(0);
  await expect(nav.getByText('Maintenance')).toHaveCount(0);
  await expect(nav.getByText('Reports')).toHaveCount(0);
});

test('direct navigation to a guarded route shows 403, not a redirect or 404', async ({ page }) => {
  await page.goto('/units');
  await expect(
    page.getByRole('heading', { name: 'You do not have permission to view this page' }),
  ).toBeVisible();
  await expect(page).toHaveURL(/\/units/);
});

test('unknown route shows 404', async ({ page }) => {
  await page.goto('/this-route-does-not-exist');
  await expect(page.getByRole('heading', { name: 'Not found' })).toBeVisible();
});
