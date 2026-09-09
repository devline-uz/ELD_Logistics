/**
 * Oqim 5 — Tracking → Track on Map → trip tanlash (§14.4.5).
 *
 * `VITE_MAP_STYLE_URL` bo'sh — MapLibre canvas render kutilmaydi (F9 ochiq
 * savol). Shu sabab bu test xaritani emas, uning **matn ekvivalentini**
 * (F171 — trip jadval ekvivalenti, Histories ro'yxati) tekshiradi.
 */
import { adminTest as test, expect } from './fixtures';

test('track a unit on the map and select a trip from history', async ({ page }) => {
  await page.goto('/tracking');
  await expect(page.getByRole('heading', { name: 'Tracking' })).toBeVisible();

  await page.getByRole('button', { name: 'Track on Map' }).click();
  await page.waitForURL(/\/tracking\/units\//);

  await expect(page.getByRole('heading', { name: /Unit # 1021/ })).toBeVisible();

  // F171 — xarita matn ekvivalenti: trip segmentlari jadvali doim mavjud.
  await expect(page.getByText('Trip segments shown on the map')).toBeAttached();

  const histories = page.getByRole('list', { name: 'Histories' });
  await expect(histories).toBeVisible();
  const firstTrip = histories.getByRole('listitem').first().getByRole('button');
  await firstTrip.click();
  await expect(firstTrip).toHaveAttribute('aria-pressed', 'true');
});
