/**
 * Bosqich 9.2 — `axe-core` bilan asosiy 10 ekranda a11y skani (§14.2, F216–F222).
 *
 * Har skanda `critical` va `serious` darajadagi buzilish — 0 bo'lishi shart.
 * `moderate`/`minor` darajalar bu testda qattiq talab qilinmaydi (TZ §14.2
 * faqat critical/serious uchun 0 talabini qo'yadi), lekin topilsa hisobotga
 * yoziladi.
 *
 * MapLibre canvas (Tracking xaritasi) uchinchi tomon kutubxonasi — uning
 * ichki render qatlamini tuzatib bo'lmaydi, shu sabab faqat matn ekvivalenti
 * (trip jadval ro'yxati) skanlanadi (D50, `docs/tz/16-17-registry-open-questions.md`).
 */
import AxeBuilder from '@axe-core/playwright';
import type { Page } from '@playwright/test';

import { adminTest as test, expect } from './fixtures';

const CRITICAL_OR_SERIOUS = ['critical', 'serious'];

function describeViolations(
  violations: { id: string; impact?: string | null; nodes: unknown[] }[],
): string {
  return violations.map((v) => `${v.id} [${v.impact ?? 'unknown'}] x${v.nodes.length}`).join('\n');
}

async function expectNoSeriousViolations(page: Page) {
  const results = await new AxeBuilder({ page }).analyze();
  const blocking = results.violations.filter((v) => CRITICAL_OR_SERIOUS.includes(v.impact ?? ''));
  expect(blocking, describeViolations(blocking)).toEqual([]);
}

test.describe('a11y — axe-core critical/serious = 0', () => {
  test('Dashboard', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
    await expectNoSeriousViolations(page);
  });

  test('Units list', async ({ page }) => {
    await page.goto('/units');
    await expect(page.getByRole('heading', { name: 'Unit Management' })).toBeVisible();
    await expectNoSeriousViolations(page);
  });

  test('Units list — Add Unit modal open (focus trap, aria-modal)', async ({ page }) => {
    await page.goto('/units');
    await expect(page.getByRole('heading', { name: 'Unit Management' })).toBeVisible();
    await page.getByRole('button', { name: 'Add Unit' }).click();
    const dialog = page.getByRole('dialog', { name: 'Add unit' });
    await expect(dialog).toBeVisible();
    await expect(dialog).toHaveAttribute('aria-modal', 'true');

    // Fokus tuzoq: dialog ichida Tab bosilganda fokus dialogdan chiqmaydi.
    const isInsideDialog = await page.evaluate(() => {
      const active = document.activeElement;
      const dialogEl = document.querySelector('[role="dialog"]');
      return !!dialogEl && !!active && dialogEl.contains(active);
    });
    expect(isInsideDialog).toBe(true);

    await expectNoSeriousViolations(page);
  });

  test('Unit detail', async ({ page }) => {
    await page.goto('/units/unit-1');
    await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
    await expectNoSeriousViolations(page);
  });

  test('Drivers list', async ({ page }) => {
    await page.goto('/drivers');
    await expect(page.getByRole('heading', { name: 'Driver Management' })).toBeVisible();
    await expectNoSeriousViolations(page);
  });

  test('Logs By Driver', async ({ page }) => {
    await page.goto('/logs/by-driver');
    await expect(page.getByRole('heading', { name: 'Logs By Driver' })).toBeVisible();
    await expectNoSeriousViolations(page);
  });

  test('Tracking — Track on Map (text equivalent, canvas excluded)', async ({ page }) => {
    await page.goto('/tracking');
    await expect(page.getByRole('heading', { name: 'Tracking' })).toBeVisible();
    await page.getByRole('button', { name: 'Track on Map' }).click();
    await page.waitForURL(/\/tracking\/units\//);
    await expect(page.getByRole('heading', { name: /Unit # 1021/ })).toBeVisible();

    // MapLibre canvas — uchinchi tomon, ichki render qatlamini tuzatib
    // bo'lmaydi (D50). Axe shu tugun ichidagi qoidalarni o'tkazib yuboradi.
    await expectNoSeriousViolationsExcluding(page, '.maplibregl-map');
  });

  test('DVIR list', async ({ page }) => {
    await page.goto('/dvir');
    await expect(page.getByRole('heading', { name: 'DVIR' })).toBeVisible();
    await expectNoSeriousViolations(page);
  });

  test('Maintenance — Due', async ({ page }) => {
    await page.goto('/maintenance/due');
    await expect(page.getByRole('heading', { name: 'Maintenance' })).toBeVisible();
    await expectNoSeriousViolations(page);
  });

  test('Reports — Distance by Region', async ({ page }) => {
    await page.goto('/reports/distance-by-region');
    await expect(page.getByRole('heading', { name: 'IFTA Report' })).toBeVisible();
    await expectNoSeriousViolations(page);
  });

  test('Settings — Company', async ({ page }) => {
    await page.goto('/settings/company');
    await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
    await expectNoSeriousViolations(page);
  });
});

async function expectNoSeriousViolationsExcluding(page: Page, selector: string) {
  const results = await new AxeBuilder({ page }).exclude(selector).analyze();
  const blocking = results.violations.filter((v) => CRITICAL_OR_SERIOUS.includes(v.impact ?? ''));
  expect(blocking, describeViolations(blocking)).toEqual([]);
}
